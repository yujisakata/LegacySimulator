package com.legacysimulator.v09;

// V9-ADD-005: 発生元ごとのログ形式を共通監査イベントへ変換する境界。
public interface SourceAuditMapper {
    String sourceSystem();
    AuditEvent map(String rawRecord);
}
