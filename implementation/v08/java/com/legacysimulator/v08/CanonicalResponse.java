package com.legacysimulator.v08;

// V8-ADD-001: 接続方式から独立したJava 8互換の共通中間形式。
public final class CanonicalResponse {
    private final String partner;
    private final String transactionId;
    private final String status;
    private final String payload;
    private final long sequence;
    public CanonicalResponse(String partner, String transactionId, String status, String payload, long sequence) {
        this.partner = partner;
        this.transactionId = transactionId;
        this.status = status;
        this.payload = payload;
        this.sequence = sequence;
    }
    public String partner() { return partner; }
    public String transactionId() { return transactionId; }
    public String status() { return status; }
    public String payload() { return payload; }
    public long sequence() { return sequence; }
    public String deduplicationKey() { return partner + ":" + transactionId; }
}
