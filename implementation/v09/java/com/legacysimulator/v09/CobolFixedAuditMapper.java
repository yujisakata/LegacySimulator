package com.legacysimulator.v09;

import java.time.OffsetDateTime;

// V9-ADD-006: COBOLの100文字固定長ログを共通監査イベントへ変換する。
public final class CobolFixedAuditMapper implements SourceAuditMapper {
    public String sourceSystem() { return "COBOL"; }
    public AuditEvent map(String raw) {
        if (raw == null || raw.length() != 100) throw new IllegalArgumentException("COBOL監査ログは100文字です");
        String transactionKey = raw.substring(0, 20).trim();
        String operatorId = raw.substring(20, 30).trim();
        String reasonCode = raw.substring(30, 35).trim();
        String inputDigest = raw.substring(35, 67).trim();
        OffsetDateTime occurredAt = OffsetDateTime.parse(raw.substring(67, 92));
        return new AuditEvent(sourceSystem(), transactionKey, operatorId, inputDigest, reasonCode, occurredAt);
    }
}
