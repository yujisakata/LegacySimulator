package com.legacysimulator.v08;

// V8-ADD-006: 外部通信方式に依存しない送信要求。
public final class PartnerRequest {
    private final String applicationNumber;
    private final String transactionId;
    private final String partner;
    private final String payload;
    public PartnerRequest(String applicationNumber, String transactionId, String partner, String payload) {
        this.applicationNumber = applicationNumber;
        this.transactionId = transactionId;
        this.partner = partner;
        this.payload = payload;
    }
    public String getApplicationNumber() { return applicationNumber; }
    public String getTransactionId() { return transactionId; }
    public String getPartner() { return partner; }
    public String getPayload() { return payload; }
}
