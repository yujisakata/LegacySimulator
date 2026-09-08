package com.legacysimulator.v06;

import java.math.BigDecimal;
import java.util.Date;

// V6-ADD-006: Java受付DBで管理する申込集約。査定結果確定前の状態だけを保持する。
public final class EntryApplication {
    public static final String RECEIVED = "RECEIVED";
    public static final String READY_FOR_COBOL = "READY_FOR_COBOL";
    public static final String SENT_TO_COBOL = "SENT_TO_COBOL";
    public static final String ASSESSED = "ASSESSED";

    private final String applicationNumber;
    private final String productCode;
    private final int age;
    private final BigDecimal insuredAmount;
    private String status;
    private Date receivedAt;

    public EntryApplication(EntryRequest request, Date receivedAt) {
        this.applicationNumber = request.applicationNumber();
        this.productCode = request.productCode();
        this.age = request.age();
        this.insuredAmount = request.insuredAmount();
        this.status = RECEIVED;
        this.receivedAt = new Date(receivedAt.getTime());
    }

    public String getApplicationNumber() { return applicationNumber; }
    public String getProductCode() { return productCode; }
    public int getAge() { return age; }
    public BigDecimal getInsuredAmount() { return insuredAmount; }
    public String getStatus() { return status; }
    public Date getReceivedAt() { return new Date(receivedAt.getTime()); }

    public void markReadyForCobol() { status = READY_FOR_COBOL; }
    public void markSentToCobol() { status = SENT_TO_COBOL; }
    public void markAssessed() { status = ASSESSED; }

    // V6-ADD-018: DBから再構成するときだけ、保存済み状態を復元する。
    void restoreStatus(String persistedStatus) {
        if (!RECEIVED.equals(persistedStatus) && !READY_FOR_COBOL.equals(persistedStatus)
                && !SENT_TO_COBOL.equals(persistedStatus) && !ASSESSED.equals(persistedStatus)) {
            throw new IllegalArgumentException("未定義の受付状態です: " + persistedStatus);
        }
        status = persistedStatus;
    }
}
