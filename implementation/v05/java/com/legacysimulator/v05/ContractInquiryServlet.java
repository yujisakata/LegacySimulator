package com.legacysimulator.v05;

import java.io.IOException;
import java.util.Optional;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

// V5-ADD-013: 支社向け参照専用Servlet。
public final class ContractInquiryServlet extends HttpServlet {
    private InquirySnapshotService service;
    private InquiryResponseWriter responseWriter;

    public void init() throws ServletException {
        Object serviceObject = getServletContext().getAttribute("inquirySnapshotService");
        if (!(serviceObject instanceof InquirySnapshotService)) {
            throw new ServletException("照会サービスが初期化されていません");
        }
        service = (InquirySnapshotService) serviceObject;
        responseWriter = new InquiryResponseWriter();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("Shift_JIS");
        response.setCharacterEncoding("Shift_JIS");
        response.setContentType("text/html; charset=Shift_JIS");
        String contractNumber = normalize(request.getParameter("contractNumber"));
        if (contractNumber == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "契約番号は10桁です");
            return;
        }
        Optional<InquiryRecord> record = service.findByContractNumber(contractNumber);
        if (!record.isPresent()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "契約が見つかりません");
            return;
        }
        responseWriter.write(response.getWriter(), record.get());
    }

    private String normalize(String value) {
        if (value == null) return null;
        String trimmed = value.trim();
        return trimmed.length() == 10 ? trimmed : null;
    }
}
