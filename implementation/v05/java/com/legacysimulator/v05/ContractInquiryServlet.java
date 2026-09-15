package com.legacysimulator.v05;

import java.io.*;
import java.sql.SQLException;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.naming.InitialContext;
import javax.sql.DataSource;

/** V5-ADD-003: 参照専用照会。認証は社内Servletコンテナへ委ねる。 */
public final class ContractInquiryServlet extends HttpServlet {
    private static final long serialVersionUID=1L;
    private JdbcInquiryDao dao;
    public ContractInquiryServlet() { }
    public ContractInquiryServlet(JdbcInquiryDao dao) { this.dao=dao; }
    public void init() throws ServletException {
        if(dao==null) {
            try { dao=new JdbcInquiryDao((DataSource)new InitialContext().lookup("java:comp/env/jdbc/InquiryReadOnly")); }
            catch(Exception e) { throw new ServletException("Inquiry data source unavailable",e); }
        }
    }
    protected void service(HttpServletRequest request,HttpServletResponse response) throws ServletException,IOException {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        response.setHeader("Cache-Control","no-store");
        if(request.getUserPrincipal()==null) { response.setStatus(401); response.getWriter().write("認証が必要です"); return; }
        if(!request.isUserInRole("inquiry")) { response.setStatus(403); response.getWriter().write("照会権限が必要です"); return; }
        if(!"GET".equals(request.getMethod())) { response.setStatus(405); response.setHeader("Allow","GET"); return; }
        String number=request.getParameter("number");
        if(number==null) {
            response.getWriter().write("<!doctype html><html lang=ja><meta charset=UTF-8><title>契約進捗照会</title><h1>契約進捗照会</h1><form method=get><label>申込番号 <input name=number maxlength=10 required></label><button>照会</button></form></html>"); return;
        }
        if(!number.matches("[0-9]{10}")) { response.setStatus(400); response.getWriter().write("申込番号は10桁の数字で入力してください"); return; }
        try {
            InquiryRecord r=dao.find(number);
            if(r==null) { response.setStatus(404); response.getWriter().write("該当する申込はありません"); return; }
            response.getWriter().write(render(r));
        } catch(SQLException e) {
            getServletContext().log("Inquiry database unavailable",e);
            response.setStatus(503); response.getWriter().write("照会データを取得できません。時間をおいて再度お試しください。");
        }
    }
    public static String escape(Object value) {
        if(value==null) return "未設定";
        return value.toString().replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;");
    }
    public static String render(InquiryRecord r) {
        String[] statuses={"査定結果未連携","承諾","延期","謝絶","不備照会中","失効","取下げ","二次決裁待ち","入力エラー","三要件待ち"};
        String status=r.status==null ? statuses[0] : statuses[Integer.parseInt(r.status)];
        String amountLabel=r.product.equals("WL") ? "死亡保険金額" : r.product.equals("MI") ? "入院日額" : "診断給付金";
        StringBuilder b=new StringBuilder("<!doctype html><html lang=ja><meta charset=UTF-8><title>契約進捗照会</title><h1>契約進捗照会</h1>");
        b.append("<p>夜間連携時点の情報です。現在の査定状況と異なる場合があります。</p><p>主契約の照会です。特約明細は対象外です。</p><dl>");
        row(b,"申込番号",r.number); row(b,"商品",r.product); row(b,"主契約進捗",status);
        row(b,amountLabel,r.amount==null ? "未設定" : r.amount.toPlainString()+" 円");
        row(b,"責任開始日",r.responsibility); row(b,"処理日",r.processed); row(b,"受付日",r.received);
        row(b,"適用制度",r.rule==null ? "制度判定なし" : r.rule.equals("ERR") ? "制度入力エラー" : r.rule);
        row(b,"制度基準日",r.applied); row(b,"理由",r.reason); row(b,"照会データ基準日",r.asOf);
        return b.append("</dl></html>").toString();
    }
    private static void row(StringBuilder b,String label,Object value) {
        b.append("<dt>").append(label).append("</dt><dd>").append(escape(value)).append("</dd>");
    }
}
