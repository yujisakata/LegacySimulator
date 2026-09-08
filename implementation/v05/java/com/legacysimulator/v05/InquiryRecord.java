package com.legacysimulator.v05;

import java.math.BigDecimal;

// V5-ADD-001: 夜間複製された参照専用データを表すJavaBean。
// 当時のServlet/JSPから利用できるよう、recordではなく明示的なgetterを持つ。
public final class InquiryRecord {
    private final String contractNumber;
    private final String status;
    private final BigDecimal insuredAmount;
    private final String asOfDate;

    public InquiryRecord(String contractNumber, String status,
                         BigDecimal insuredAmount, String asOfDate) {
        if (contractNumber == null || contractNumber.length() != 10) {
            throw new IllegalArgumentException("契約番号は10桁です");
        }
        if (asOfDate == null || asOfDate.length() != 8) {
            throw new IllegalArgumentException("基準日はYYYYMMDDです");
        }
        this.contractNumber = contractNumber;
        this.status = status;
        this.insuredAmount = insuredAmount;
        this.asOfDate = asOfDate;
    }

    public String getContractNumber() { return contractNumber; }
    public String getStatus() { return status; }
    public BigDecimal getInsuredAmount() { return insuredAmount; }
    public String getAsOfDate() { return asOfDate; }

    public boolean hasStatus() { return status != null; }
    public boolean hasInsuredAmount() { return insuredAmount != null; }
}
