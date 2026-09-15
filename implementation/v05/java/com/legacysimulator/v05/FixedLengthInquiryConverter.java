package com.legacysimulator.v05;

import java.math.BigDecimal;
import java.sql.Date;
import java.text.ParsePosition;
import java.text.SimpleDateFormat;
import java.util.Locale;

/** V5-ADD-001: 空白・ゼロを区別するQ5変換。 */
public final class FixedLengthInquiryConverter {
    public InquiryRecord convert(String line) {
        require(line.length()==100, "Q5 length must be 100");
        for (int i=0;i<line.length();i++)
            require(line.charAt(i)>=32 && line.charAt(i)<=126, "Non ASCII field");
        require(line.startsWith("Q5"), "Q5 marker required");
        require(line.substring(71).trim().length()==0, "Reserved field must be blank");
        String number=line.substring(2,12), product=line.substring(12,14);
        require(number.matches("[0-9]{10}"), "Invalid application number");
        require(product.equals("WL")||product.equals("MI")||product.equals("CI"), "Invalid product");
        String status=code(line.substring(14,16));
        require(status==null || status.matches("0[1-9]"), "Invalid result code");
        String money=line.substring(16,24);
        BigDecimal amount=null;
        if (!money.equals("        ")) {
            require(money.matches("[0-9]{8}"), "Invalid amount");
            amount=new BigDecimal(money);
        }
        Date responsibility=date(line.substring(24,32));
        Date processed=date(line.substring(32,40));
        Date received=date(line.substring(40,48));
        String rule=code(line.substring(48,51));
        require(rule==null || rule.equals("OLD")||rule.equals("NEW")||rule.equals("ERR"), "Invalid rule");
        Date applied=date(line.substring(51,59)), asOf=date(line.substring(59,67));
        require(asOf!=null, "Snapshot date required");
        String reason=code(line.substring(67,70)), approval=code(line.substring(70,71));
        require(reason==null || (" 000 DAT PRD AGE AMT WDR DEF EXP MED APR REQ OLD NEW RDR ").contains(" "+reason+" "), "Invalid reason");
        require(approval==null || approval.matches("[UMN]"), "Invalid approval");
        if (status==null) require(responsibility==null && processed==null && rule==null && applied==null && reason==null && approval==null, "Pending result fields must be null");
        return new InquiryRecord(number,product,status,amount,responsibility,processed,received,rule,applied,asOf,reason,approval);
    }
    public static String code(String s) { return s.trim().length()==0 ? null : s; }
    public static Date date(String s) {
        if (s.equals("00000000") || s.equals("        ")) return null;
        require(s.matches("[0-9]{8}"), "Invalid date characters");
        int year=Integer.parseInt(s.substring(0,4));
        require(year>=1900 && year<=2099, "Date year out of range");
        SimpleDateFormat f=new SimpleDateFormat("yyyyMMdd",Locale.ROOT);
        f.setLenient(false);
        ParsePosition pos=new ParsePosition(0);
        require(f.parse(s,pos)!=null && pos.getIndex()==8, "Invalid calendar date");
        return Date.valueOf(s.substring(0,4)+"-"+s.substring(4,6)+"-"+s.substring(6,8));
    }
    public static void require(boolean ok,String message) {
        if (!ok) throw new IllegalArgumentException(message);
    }
}
