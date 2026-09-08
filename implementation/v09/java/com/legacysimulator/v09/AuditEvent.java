package com.legacysimulator.v09;

import java.time.OffsetDateTime;

// V9-ADD-001: 全世代に共通するJava 11互換の監査必須項目。
public final class AuditEvent {
    private final String sourceSystem;
    private final String transactionKey;
    private final String operatorId;
    private final String inputDigest;
    private final String reasonCode;
    private final OffsetDateTime occurredAt;
    public AuditEvent(String sourceSystem, String transactionKey, String operatorId,
                      String inputDigest, String reasonCode, OffsetDateTime occurredAt) {
        this.sourceSystem = sourceSystem;
        this.transactionKey = transactionKey;
        this.operatorId = operatorId;
        this.inputDigest = inputDigest;
        this.reasonCode = reasonCode;
        this.occurredAt = occurredAt;
    }
    public String sourceSystem() { return sourceSystem; }
    public String transactionKey() { return transactionKey; }
    public String operatorId() { return operatorId; }
    public String inputDigest() { return inputDigest; }
    public String reasonCode() { return reasonCode; }
    public OffsetDateTime occurredAt() { return occurredAt; }
}
