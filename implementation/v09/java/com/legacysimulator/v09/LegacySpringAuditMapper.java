package com.legacysimulator.v09;

import java.time.OffsetDateTime;

// V9-ADD-007: 旧Springのタブ区切りログを共通形式へ変換する。
public final class LegacySpringAuditMapper implements SourceAuditMapper {
    public String sourceSystem() { return "LEGACY_SPRING"; }
    public AuditEvent map(String raw) {
        String[] values = raw.split("\\t", -1);
        if (values.length != 5) throw new IllegalArgumentException("旧Spring監査ログは5項目です");
        return new AuditEvent(sourceSystem(), values[0], values[1], values[2], values[3],
                OffsetDateTime.parse(values[4]));
    }
}
