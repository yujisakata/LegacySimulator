package com.legacysimulator.v05;

import java.nio.file.*;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.security.MessageDigest;
import java.io.*;

/** V5-ADD-002: 確定したV4受渡しファイルを結合。原簿へ接続しない。 */
public final class SnapshotExportJob {
    public static List<String> lines(Path file) throws IOException {
        return Files.readAllLines(file,StandardCharsets.US_ASCII);
    }
    public static String hash(byte[] data) throws Exception {
        StringBuilder b=new StringBuilder();
        for(byte v:MessageDigest.getInstance("SHA-256").digest(data))
            b.append(String.format(Locale.ROOT,"%02x",v & 255));
        return b.toString();
    }
    public static void export(Path nbInput,Path nbResult,Path mdInput,Path mdResult,
            String asOf,Path directory) throws Exception {
        FixedLengthInquiryConverter.require(FixedLengthInquiryConverter.date(asOf)!=null,"Snapshot date required");
        SortedMap<String,String> all=new TreeMap<String,String>();
        join(nbInput,nbResult,true,asOf,all);
        join(mdInput,mdResult,false,asOf,all);
        StringBuilder body=new StringBuilder();
        for(String line:all.values()) body.append(line).append('\n');
        byte[] data=body.toString().getBytes(StandardCharsets.US_ASCII);
        Files.createDirectories(directory);
        Files.write(directory.resolve("snapshot.dat"),data);
        Properties meta=new Properties();
        meta.setProperty("format","Q5"); meta.setProperty("asOf",asOf);
        meta.setProperty("count",Integer.toString(all.size()));
        meta.setProperty("sha256",hash(data));
        // 最後にマニフェストを配置。途中ファイルはハッシュ不一致で拒否される。
        try(OutputStream out=Files.newOutputStream(directory.resolve("snapshot.properties"))) {
            meta.store(out,"V5 full snapshot");
        }
    }
    private static void join(Path input,Path result,boolean wl,String asOf,
            Map<String,String> all) throws Exception {
        Map<String,String> results=new HashMap<String,String>();
        for(String s:lines(result)) {
            FixedLengthInquiryConverter.require(s.length()==80,"V4 result length");
            FixedLengthInquiryConverter.require(results.put(s.substring(0,10),s)==null,"Duplicate result");
        }
        Set<String> seen=new HashSet<String>();
        for(String s:lines(input)) {
            FixedLengthInquiryConverter.require(s.length()==120,"V4 application length");
            String key=s.substring(0,10), product=s.substring(68,70);
            FixedLengthInquiryConverter.require(seen.add(key),"Duplicate application");
            FixedLengthInquiryConverter.require(wl ? product.equals("WL") : product.equals("MI")||product.equals("CI"),"Wrong source lane");
            String r=results.remove(key);
            if (r!=null) {
                FixedLengthInquiryConverter.require(s.substring(34,42).equals(r.substring(32,40)),"Receipt date mismatch");
                FixedLengthInquiryConverter.require(s.substring(42,50).equals(r.substring(24,32)),"Process date mismatch");
            }
            String q="Q5"+key+product+(r==null ? "  " : r.substring(10,12))
                +s.substring(60,68)+(r==null ? "                " : r.substring(16,32))
                +s.substring(34,42)+(r==null ? "           " : r.substring(64,75))
                +asOf+(r==null ? "    " : r.substring(13,16)+r.substring(12,13))
                +"                             ";
            new FixedLengthInquiryConverter().convert(q);
            FixedLengthInquiryConverter.require(all.put(key,q)==null,"Duplicate number across lanes");
        }
        FixedLengthInquiryConverter.require(results.isEmpty(),"Orphan result");
    }
    public static void main(String[] args) throws Exception {
        if(args.length!=6) throw new IllegalArgumentException("nbInput nbResult mdInput mdResult asOf outputDirectory");
        export(Paths.get(args[0]),Paths.get(args[1]),Paths.get(args[2]),Paths.get(args[3]),args[4],Paths.get(args[5]));
    }
}
