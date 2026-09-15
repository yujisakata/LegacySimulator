package com.legacysimulator.v05;

import java.nio.file.*;
import java.util.*;
import java.io.*;
import java.sql.*;

/** V5-ADD-002: 夜間専用接続。点検後に全量を一括公開する。 */
public final class SnapshotImportJob {
    public static String load(Connection c,Path directory,java.sql.Date businessDate) throws Exception {
        Properties meta=new Properties();
        try(InputStream in=Files.newInputStream(directory.resolve("snapshot.properties"))) { meta.load(in); }
        FixedLengthInquiryConverter.require("Q5".equals(meta.getProperty("format")),"Manifest format");
        java.sql.Date asOf=FixedLengthInquiryConverter.date(meta.getProperty("asOf",""));
        FixedLengthInquiryConverter.require(asOf!=null && !asOf.after(businessDate),"Future or missing snapshot date");
        String countText=meta.getProperty("count","");
        FixedLengthInquiryConverter.require(countText.matches("[0-9]+"),"Manifest count");
        int count=Integer.parseInt(countText);
        byte[] bytes=Files.readAllBytes(directory.resolve("snapshot.dat"));
        String hash=SnapshotExportJob.hash(bytes);
        FixedLengthInquiryConverter.require(hash.equals(meta.getProperty("sha256")),"Manifest checksum");
        List<String> lines=new ArrayList<String>();
        java.nio.charset.CharsetDecoder decoder=java.nio.charset.StandardCharsets.US_ASCII.newDecoder();
        try(BufferedReader reader=new BufferedReader(new InputStreamReader(new ByteArrayInputStream(bytes),decoder))) {
            String line; while((line=reader.readLine())!=null) lines.add(line);
        }
        FixedLengthInquiryConverter.require(lines.size()==count,"Manifest count mismatch");
        List<InquiryRecord> records=new ArrayList<InquiryRecord>();
        Set<String> numbers=new HashSet<String>();
        for(String s:lines) {
            InquiryRecord r=new FixedLengthInquiryConverter().convert(s);
            FixedLengthInquiryConverter.require(asOf.equals(r.asOf),"Mixed snapshot dates");
            FixedLengthInquiryConverter.require(numbers.add(r.number),"Duplicate snapshot number");
            records.add(r);
        }
        FixedLengthInquiryConverter.require(c.getAutoCommit(),"Importer requires a dedicated connection");
        c.setAutoCommit(false);
        try {
            try(Statement st=c.createStatement(); ResultSet rs=st.executeQuery("SELECT AS_OF, CONTENT_HASH, RECORD_COUNT FROM INQUIRY_STATE WHERE ID=1 FOR UPDATE")) {
                if(!rs.next()) throw new SQLException("Missing publication state");
                java.sql.Date old=rs.getDate(1);
                if(old!=null) {
                    FixedLengthInquiryConverter.require(!asOf.before(old),"Older snapshot");
                    if(asOf.equals(old)) {
                        FixedLengthInquiryConverter.require(hash.equals(rs.getString(2)) && count==rs.getInt(3),"Conflicting same-date snapshot");
                        c.rollback(); return "UNCHANGED";
                    }
                }
            }
            try(Statement st=c.createStatement()) { st.executeUpdate("DELETE FROM INQUIRY_SNAPSHOT"); }
            try(PreparedStatement st=c.prepareStatement("INSERT INTO INQUIRY_SNAPSHOT (APP_NUMBER,PRODUCT,STATUS,AMOUNT,RESPONSIBILITY_DATE,PROCESS_DATE,RECEIPT_DATE,RULE_CODE,APPLIED_DATE,AS_OF,REASON,APPROVAL) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)")) {
                for(InquiryRecord r:records) {
                    st.setString(1,r.number); st.setString(2,r.product); st.setString(3,r.status);
                    st.setBigDecimal(4,r.amount); st.setDate(5,r.responsibility); st.setDate(6,r.processed);
                    st.setDate(7,r.received); st.setString(8,r.rule); st.setDate(9,r.applied);
                    st.setDate(10,r.asOf); st.setString(11,r.reason); st.setString(12,r.approval);
                    st.executeUpdate();
                }
            }
            try(PreparedStatement st=c.prepareStatement("UPDATE INQUIRY_STATE SET AS_OF=?,CONTENT_HASH=?,RECORD_COUNT=? WHERE ID=1")) {
                st.setDate(1,asOf); st.setString(2,hash); st.setInt(3,count);
                if(st.executeUpdate()!=1) throw new SQLException("Publication state missing");
            }
            c.commit(); return "PUBLISHED";
        } catch(Exception e) {
            try { c.rollback(); } catch(SQLException rollback) { e.addSuppressed(rollback); }
            throw e;
        } finally { c.setAutoCommit(true); }
    }
    public static void main(String[] args) throws Exception {
        if(args.length!=2) throw new IllegalArgumentException("snapshotDirectory businessDate");
        try(Connection c=DriverManager.getConnection(System.getenv("V5_IMPORT_URL"),System.getenv("V5_IMPORT_USER"),System.getenv("V5_IMPORT_PASSWORD"))) {
            System.out.println(load(c,Paths.get(args[0]),FixedLengthInquiryConverter.date(args[1])));
        }
    }
}
