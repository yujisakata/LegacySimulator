package com.legacysimulator.v05;

import java.io.IOException;
import java.io.PrintWriter;

// V5-ADD-012: JSPへ渡す前の簡易HTML応答。基準日を必ず表示する。
public final class InquiryResponseWriter {
    public void write(PrintWriter writer, InquiryRecord record) throws IOException {
        writer.println("<html><head><title>契約進捗照会</title></head><body>");
        writer.println("<h1>契約進捗照会</h1>");
        writer.println("<dl>");
        row(writer, "契約番号", record.getContractNumber());
        row(writer, "進捗状態", record.hasStatus() ? record.getStatus() : "未登録");
        row(writer, "保険金額", record.hasInsuredAmount() ? record.getInsuredAmount().toPlainString() : "未登録");
        row(writer, "データ基準日", record.getAsOfDate());
        writer.println("</dl>");
        writer.println("<p>表示内容は前夜時点の場合があります。</p>");
        writer.println("</body></html>");
    }

    private void row(PrintWriter writer, String label, String value) {
        writer.println("<dt>" + escape(label) + "</dt><dd>" + escape(value) + "</dd>");
    }

    private String escape(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
    }
}
