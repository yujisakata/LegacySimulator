package com.legacysimulator.v09;

import java.time.OffsetDateTime;
import java.util.Map;

// V9-ADD-008: Spring BootのJSON解析結果を共通形式へ変換する。
// JSONライブラリの世代差をMapper外へ出さないため、解析済みMapを受け取る。
public final class BootJsonAuditMapper {
    public AuditEvent map(Map<String, String> values) {
        return new AuditEvent("SPRING_BOOT", required(values, "transactionKey"),
                required(values, "operatorId"), required(values, "inputDigest"),
                required(values, "reasonCode"), OffsetDateTime.parse(required(values, "occurredAt")));
    }
    private String required(Map<String, String> values, String key) {
        String value = values.get(key);
        if (value == null || value.isEmpty()) throw new IllegalArgumentException("監査項目がありません: " + key);
        return value;
    }
}
