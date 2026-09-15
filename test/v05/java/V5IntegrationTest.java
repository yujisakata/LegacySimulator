import com.legacysimulator.v05.*;
import java.io.*;
import java.net.*;
import java.nio.file.*;
import java.nio.charset.StandardCharsets;
import java.sql.*;
import java.util.*;
import java.util.concurrent.*;
import java.security.Principal;
import org.h2.jdbcx.JdbcDataSource;
import org.apache.catalina.*;
import org.apache.catalina.startup.Tomcat;
import org.apache.catalina.realm.*;
import org.apache.catalina.authenticator.BasicAuthenticator;
import org.apache.tomcat.util.descriptor.web.*;

/** 2026年の実行検証。当時の代表試験と区別する。 */
public final class V5IntegrationTest {
    static int checks=0;
    static Path work;
    static String url="jdbc:h2:mem:v5test";
    interface Action { void run() throws Exception; }
    static void ok(boolean value,String label) {
        if(!value) throw new AssertionError(label);
        checks++; System.out.println("PASS "+label);
    }
    static void rejects(Action a,String label) throws Exception {
        try { a.run(); } catch(Exception expected) { ok(true,label+" ["+expected.getClass().getSimpleName()+"]"); return; }
        throw new AssertionError("Expected rejection: "+label);
    }
    static String change(String s,int offset,String value) {
        return s.substring(0,offset)+value+s.substring(offset+value.length());
    }
    static String record(String number,String product,String amount,String day) {
        return "Q5"+number+product+"01"+amount+"199504021995050119950331NEW19950402"+day+"000U"+"                             ";
    }
    static String pending(String number,String amount,String day) {
        return "Q5"+number+"MI  "+amount+"                "+"19950331"+"           "+day+"    "+"                             ";
    }
    static Path snapshot(String label,String day,String... lines) throws Exception {
        Path dir=work.resolve(label); Files.createDirectories(dir);
        StringBuilder text=new StringBuilder();for(String line:lines)text.append(line).append('\n');
        byte[] data=text.toString().getBytes(StandardCharsets.US_ASCII);
        Files.write(dir.resolve("snapshot.dat"),data);
        Properties p=new Properties();p.setProperty("format","Q5");p.setProperty("asOf",day);
        p.setProperty("count",Integer.toString(lines.length));p.setProperty("sha256",SnapshotExportJob.hash(data));
        try(OutputStream out=Files.newOutputStream(dir.resolve("snapshot.properties"))) {p.store(out,"test");}
        return dir;
    }
    static String load(Path path) throws Exception {
        try(Connection c=DriverManager.getConnection(url,"LOADER","loader-test-only")) {
            return SnapshotImportJob.load(c,path,java.sql.Date.valueOf("2000-05-31"));
        }
    }
    static void schema(Path root) throws Exception {
        try(Connection c=DriverManager.getConnection(url+";DB_CLOSE_DELAY=-1","sa","");Statement st=c.createStatement()) {
            String sql=new String(Files.readAllBytes(root.resolve("implementation/v05/sql/inquiry_schema.sql")),StandardCharsets.UTF_8).replace("\ufeff","");
            sql=sql.replaceAll("(?m)--[^\r\n]*","");
            for(String part:sql.split(";")) if(part.trim().length()>0)st.execute(part);
            st.execute("CREATE USER WEB PASSWORD 'web-test-only'");
            st.execute("CREATE USER LOADER PASSWORD 'loader-test-only'");
            for(String table:new String[]{"INQUIRY_SNAPSHOT","INQUIRY_STATE"}) {
                st.execute("GRANT SELECT ON "+table+" TO WEB");
                st.execute("GRANT SELECT,INSERT,UPDATE,DELETE ON "+table+" TO LOADER");
            }
        }
    }
    static JdbcDataSource webSource() {
        JdbcDataSource ds=new JdbcDataSource();ds.setURL(url);ds.setUser("WEB");ds.setPassword("web-test-only");return ds;
    }
    static void converters() throws Exception {
        FixedLengthInquiryConverter c=new FixedLengthInquiryConverter();
        String q=record("0000000001","WL","01000000","20000501");
        ok(q.length()==100,"Q5 declared physical length");
        for(String product:new String[]{"WL","MI","CI"})
            ok(c.convert(change(q,12,product)).product.equals(product),"product "+product);
        for(int i=1;i<=9;i++) ok(c.convert(change(q,14,"0"+i)).status.equals("0"+i),"status 0"+i);
        ok(c.convert(pending("0000000002","        ","20000501")).amount==null,"blank amount NULL");
        ok(c.convert(pending("0000000002","00000000","20000501")).amount.signum()==0,"zero amount is zero");
        for(int offset:new int[]{24,32,40,51}) {
            InquiryRecord r=c.convert(change(q,offset,"00000000"));
            ok((offset==24?r.responsibility:offset==32?r.processed:offset==40?r.received:r.applied)==null,"zero date NULL at "+offset);
        }
        ok(c.convert(change(q,24,"20000229")).responsibility.toString().equals("2000-02-29"),"century leap day");
        final String[] bad={q.substring(1),q+" ",change(q,0,"XX"),change(q,2,"ABCDEFGHIJ"),change(q,12,"XX"),change(q,14,"AC"),change(q,16,"12X00000"),change(q,16," 1000000"),change(q,24,"19000229"),change(q,24,"20000230"),change(q,24,"21000101"),change(q,24,"20001301"),change(q,24,"20000100"),change(q,48,"BAD"),change(q,59,"00000000"),change(q,67,"XYZ"),change(q,70,"X"),change(q,71,"X"),change(q,16,"１２３４５６７８"),change(q,14,"  ")};
        for(int i=0;i<bad.length;i++){final String b=bad[i];rejects(()->c.convert(b),"invalid Q5 "+i);}
        ok(ContractInquiryServlet.escape("<>&\"'").equals("&lt;&gt;&amp;&quot;&#39;"),"HTML escaping");
        ok(ContractInquiryServlet.render(c.convert(pending("0000000002","        ","20000501"))).contains("査定結果未連携"),"pending not approval");
    }
    static void database() throws Exception {
        JdbcInquiryDao dao=new JdbcInquiryDao(webSource());
        rejects(()->dao.find("0000000001"),"initial snapshot unavailable");
        Path first=snapshot("first","20000501",record("0000000001","WL","00000000","20000501"),pending("0000000002","        ","20000501"));
        ok(load(first).equals("PUBLISHED"),"initial full publication");
        ok(dao.find("0000000001").amount.signum()==0,"JDBC zero preserved");
        ok(dao.find("0000000002").amount==null,"JDBC NULL preserved");
        ok(dao.find("9999999999")==null,"not found");
        ok(load(first).equals("UNCHANGED"),"idempotent retry");
        Path conflict=snapshot("conflict","20000501",record("0000000003","CI","01000000","20000501"));
        rejects(()->load(conflict),"same day conflict");
        Path old=snapshot("old","20000430",record("0000000001","WL","01000000","20000430"));
        rejects(()->load(old),"older snapshot rejected");
        Path future=snapshot("future","20000601",record("0000000001","WL","01000000","20000601"));
        rejects(()->load(future),"future snapshot rejected");
        Path duplicate=snapshot("duplicate","20000502",record("0000000001","WL","01000000","20000502"),record("0000000001","CI","01000000","20000502"));
        rejects(()->load(duplicate),"duplicate snapshot rejected");
        Path mixed=snapshot("mixed","20000502",record("0000000001","WL","01000000","20000501"));
        rejects(()->load(mixed),"mixed dates rejected");
        Path badHash=snapshot("badHash","20000502",record("0000000001","WL","01000000","20000502"));
        Files.write(badHash.resolve("snapshot.dat"),new byte[]{1});
        rejects(()->load(badHash),"checksum failure");
        Path badCount=snapshot("badCount","20000502",record("0000000001","WL","01000000","20000502"));
        String props=new String(Files.readAllBytes(badCount.resolve("snapshot.properties")),StandardCharsets.ISO_8859_1).replace("count=1","count=2");
        Files.write(badCount.resolve("snapshot.properties"),props.getBytes(StandardCharsets.ISO_8859_1));
        rejects(()->load(badCount),"count mismatch");
        Path badRow=snapshot("badRow","20000502",record("0000000001","WL","01000000","20000502"),change(record("0000000003","MI","00005000","20000502"),24,"20000230"));
        rejects(()->load(badRow),"later malformed row aborts publication");
        ok(dao.find("0000000002")!=null && dao.find("0000000003")==null,"old snapshot survives validation failures");
        // Force a real JDBC failure AFTER DELETE and one successful INSERT.
        try(Connection c=DriverManager.getConnection(url,"sa","");Statement st=c.createStatement()) {
            st.execute("ALTER TABLE INQUIRY_SNAPSHOT ADD CONSTRAINT TEST_FAILURE CHECK (APP_NUMBER <> '0000000009')");
        }
        Path dbFail=snapshot("dbFail","20000502",record("0000000003","MI","00005000","20000502"),record("0000000009","WL","01000000","20000502"));
        rejects(()->load(dbFail),"JDBC insertion failure");
        ok(dao.find("0000000001")!=null && dao.find("0000000002")!=null && dao.find("0000000003")==null,"rollback restores previous whole snapshot");
        try(Connection c=webSource().getConnection();Statement st=c.createStatement()) {
            for(String sql:new String[]{"DELETE FROM INQUIRY_SNAPSHOT","UPDATE INQUIRY_STATE SET RECORD_COUNT=9","INSERT INTO INQUIRY_SNAPSHOT(APP_NUMBER,PRODUCT,AS_OF) VALUES('9999999999','WL',DATE '2000-05-01')"}) {
                rejects(()->st.executeUpdate(sql),"Web DB permission rejects write");
            }
        }
        // Hold the state lock: a second importer must not publish around it.
        final Path second=snapshot("second","20000502",record("0000000003","MI","00005000","20000502"));
        ExecutorService pool=Executors.newFixedThreadPool(2);
        try(Connection lock=DriverManager.getConnection(url,"LOADER","loader-test-only")) {
            lock.setAutoCommit(false);
            try(Statement st=lock.createStatement();ResultSet rs=st.executeQuery("SELECT * FROM INQUIRY_STATE WHERE ID=1 FOR UPDATE")){rs.next();}
            CountDownLatch started=new CountDownLatch(1);
            Future<String> f=pool.submit(()->{started.countDown();return load(second);});
            started.await(); Thread.sleep(100);
            ok(!f.isDone(),"concurrent importer waits for state lock");
            ok(dao.find("0000000001").asOf.toString().equals("2000-05-01"),"reader sees previous published generation");
            lock.commit();ok(f.get(10,TimeUnit.SECONDS).equals("PUBLISHED"),"waiting importer publishes");
        } finally {pool.shutdownNow();}
        ok(dao.find("0000000001")==null && dao.find("0000000003")!=null,"full replacement removes absent rows");
        Path empty=snapshot("empty","20000503");ok(load(empty).equals("PUBLISHED"),"declared zero row snapshot");
        ok(dao.find("0000000003")==null,"empty publication is not initial unavailable");
    }
    static void endToEnd(Path v4) throws Exception {
        Path exported=work.resolve("v4-export");
        SnapshotExportJob.export(v4.resolve("APPLICATION.DAT"),v4.resolve("ASSESSMENT.DAT"),v4.resolve("MEDICAL.DAT"),v4.resolve("MEDASSESS.DAT"),"20000504",exported);
        List<String> lines=SnapshotExportJob.lines(exported.resolve("snapshot.dat"));
        ok(lines.size()==3,"real V4 output joined for three products");
        for(String line:lines) {
            InquiryRecord r=new FixedLengthInquiryConverter().convert(line);
            ok(r.status.equals("03")&&r.rule.equals("NEW")&&r.applied.toString().equals("1995-04-02"),"V4 redisclosure copied "+r.product);
        }
        ok(load(exported).equals("PUBLISHED"),"V4 to JDBC publication");
        String original=new String(Files.readAllBytes(v4.resolve("APPLICATION.DAT")),StandardCharsets.US_ASCII);
        Path duplicate=work.resolve("duplicate-v4.dat"); Files.write(duplicate,(original+original).getBytes(StandardCharsets.US_ASCII));
        rejects(()->SnapshotExportJob.export(duplicate,v4.resolve("ASSESSMENT.DAT"),v4.resolve("MEDICAL.DAT"),v4.resolve("MEDASSESS.DAT"),"20000505",work.resolve("bad-export")),"V4 duplicate application");
        Path mismatch=work.resolve("mismatch.dat");
        String r=SnapshotExportJob.lines(v4.resolve("ASSESSMENT.DAT")).get(0);
        Files.write(mismatch,(change(r,32,"19950403")+"\n").getBytes(StandardCharsets.US_ASCII));
        rejects(()->SnapshotExportJob.export(v4.resolve("APPLICATION.DAT"),mismatch,v4.resolve("MEDICAL.DAT"),v4.resolve("MEDASSESS.DAT"),"20000505",work.resolve("bad-export")),"V4 receipt mismatch");
        Path blank=work.resolve("blank.dat");Files.write(blank,new byte[0]);
        rejects(()->SnapshotExportJob.export(blank,v4.resolve("ASSESSMENT.DAT"),v4.resolve("MEDICAL.DAT"),v4.resolve("MEDASSESS.DAT"),"20000505",work.resolve("bad-export")),"V4 orphan result");
        Path duplicateResult=work.resolve("duplicate-result.dat");
        Files.write(duplicateResult,(r+"\n"+r+"\n").getBytes(StandardCharsets.US_ASCII));
        rejects(()->SnapshotExportJob.export(v4.resolve("APPLICATION.DAT"),duplicateResult,v4.resolve("MEDICAL.DAT"),v4.resolve("MEDASSESS.DAT"),"20000505",work.resolve("bad-export")),"V4 duplicate result");
        Path shortInput=work.resolve("short-input.dat");Files.write(shortInput,"123\n".getBytes(StandardCharsets.US_ASCII));
        rejects(()->SnapshotExportJob.export(shortInput,blank,blank,blank,"20000505",work.resolve("bad-export")),"V4 physical application length");
        rejects(()->SnapshotExportJob.export(blank,shortInput,blank,blank,"20000505",work.resolve("bad-export")),"V4 physical result length");
        Path wrongLane=work.resolve("wrong-lane.dat");
        String app=SnapshotExportJob.lines(v4.resolve("APPLICATION.DAT")).get(0);
        Files.write(wrongLane,(change(app,68,"MI")+"\n").getBytes(StandardCharsets.US_ASCII));
        rejects(()->SnapshotExportJob.export(wrongLane,blank,blank,blank,"20000505",work.resolve("bad-export")),"V4 wrong product lane");
        Path crossLane=work.resolve("cross-lane.dat");Files.write(crossLane,(change(app,68,"CI")+"\n").getBytes(StandardCharsets.US_ASCII));
        rejects(()->SnapshotExportJob.export(v4.resolve("APPLICATION.DAT"),blank,crossLane,blank,"20000505",work.resolve("bad-export")),"V4 duplicate across lanes");
        Path processMismatch=work.resolve("process-mismatch.dat");Files.write(processMismatch,(change(r,24,"19950502")+"\n").getBytes(StandardCharsets.US_ASCII));
        rejects(()->SnapshotExportJob.export(v4.resolve("APPLICATION.DAT"),processMismatch,blank,blank,"20000505",work.resolve("bad-export")),"V4 process mismatch");
        Path pendingExport=work.resolve("pending-export");
        SnapshotExportJob.export(v4.resolve("APPLICATION.DAT"),blank,v4.resolve("MEDICAL.DAT"),blank,"20000505",pendingExport);
        for(String s:SnapshotExportJob.lines(pendingExport.resolve("snapshot.dat"))) ok(new FixedLengthInquiryConverter().convert(s).status==null,"V4 pending joined");
    }
    static class TestRealm extends RealmBase {
        protected String getPassword(String username){return username.equals("clerk")||username.equals("viewer") ? "test-only" : null;}
        protected Principal getPrincipal(String username){return new GenericPrincipal(username,getPassword(username),username.equals("clerk")?Arrays.asList("inquiry"):Collections.<String>emptyList());}
    }
    static class Response {int code;String body;String cache;}
    static Response http(int port,String method,String query,String user) throws Exception {
        HttpURLConnection c=(HttpURLConnection)new URL("http://127.0.0.1:"+port+"/inquiry"+query).openConnection();
        c.setRequestMethod(method);c.setConnectTimeout(3000);c.setReadTimeout(3000);
        if(user!=null)c.setRequestProperty("Authorization","Basic "+Base64.getEncoder().encodeToString((user+":test-only").getBytes(StandardCharsets.US_ASCII)));
        Response r=new Response();r.code=c.getResponseCode();r.cache=c.getHeaderField("Cache-Control");
        InputStream in=r.code>=400?c.getErrorStream():c.getInputStream();
        ByteArrayOutputStream bytes=new ByteArrayOutputStream();
        if(in!=null)try(InputStream stream=in){byte[] b=new byte[4096];int n;while((n=stream.read(b))!=-1)bytes.write(b,0,n);}
        r.body=new String(bytes.toByteArray(),StandardCharsets.UTF_8);c.disconnect();return r;
    }
    static void web() throws Exception {
        Tomcat tomcat=new Tomcat();tomcat.setBaseDir(work.resolve("tomcat").toString());tomcat.setHostname("127.0.0.1");tomcat.setPort(0);
        tomcat.getConnector().setProperty("address","127.0.0.1");
        Path doc=work.resolve("webroot");Files.createDirectories(doc);
        Context ctx=tomcat.addContext("",doc.toString());ctx.setRealm(new TestRealm());
        ctx.setLoginConfig(new LoginConfig("BASIC","V5 test realm",null,null));
        SecurityConstraint constraint=new SecurityConstraint();constraint.setAuthConstraint(true);constraint.addAuthRole("**");
        SecurityCollection collection=new SecurityCollection();collection.addPattern("/*");constraint.addCollection(collection);ctx.addConstraint(constraint);
        ctx.getPipeline().addValve(new BasicAuthenticator());
        Tomcat.addServlet(ctx,"inquiry",new ContractInquiryServlet(new JdbcInquiryDao(webSource())));ctx.addServletMappingDecoded("/inquiry","inquiry",false);
        try {
            tomcat.start();int port=tomcat.getConnector().getLocalPort();
            ok(http(port,"GET","",null).code==401,"HTTP unauthenticated 401");
            ok(http(port,"GET","","viewer").code==403,"HTTP wrong role 403");
            ok(http(port,"GET","","clerk").body.contains("申込番号"),"HTTP input form");
            ok(http(port,"GET","?number=abc","clerk").code==400,"HTTP invalid number 400");
            ok(http(port,"GET","?number=9999999999","clerk").code==404,"HTTP missing 404");
            ok(http(port,"POST","?number=0000000001","clerk").code==405,"HTTP update 405");
            List<String> lines=SnapshotExportJob.lines(work.resolve("v4-export/snapshot.dat"));
            for(String s:lines) {
                InquiryRecord r=new FixedLengthInquiryConverter().convert(s);
                Response response=http(port,"GET","?number="+r.number,"clerk");
                ok(response.code==200 && response.body.contains("謝絶") && response.body.contains("2000-05-04")&&response.body.contains("1995-04-02"),"HTTP V4 result "+r.product);
                ok(response.body.contains(r.product.equals("WL")?"死亡保険金額":r.product.equals("MI")?"入院日額":"診断給付金"),"HTTP product-specific amount label "+r.product);
                ok("no-store".equals(response.cache),"HTTP no cache "+r.product);
            }
            try(Connection c=DriverManager.getConnection(url,"sa","");Statement st=c.createStatement()){st.execute("REVOKE SELECT ON INQUIRY_SNAPSHOT FROM WEB");}
            Response error=http(port,"GET","?number=0000000001","clerk");
            ok(error.code==503 && !error.body.contains("jdbc:")&&!error.body.contains("SQLException"),"HTTP database failure 503 without internals");
        } finally {tomcat.stop();tomcat.destroy();}
    }
    public static void main(String[] args) throws Exception {
        Path root=Paths.get(args[0]);work=Paths.get(args[1]);Files.createDirectories(work);
        converters();schema(root);database();endToEnd(Paths.get(args[2]));web();
        Files.write(work.resolve("result.json"),("{\"status\":\"PASS\",\"assertions\":"+checks+"}").getBytes(StandardCharsets.UTF_8));
        System.out.println("V5 ALL PASS: "+checks+" assertions");
    }
}
