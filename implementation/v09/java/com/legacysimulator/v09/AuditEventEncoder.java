package com.legacysimulator.v09;

import java.util.LinkedHashMap;
import java.util.Map;

// V9-FIX-001 ADD: 各世代の監査ログを既存Mapperが読める形式で生成する。
public final class AuditEventEncoder {
    public String toCobolFixed(AuditEvent event) {
        String record = fixed(event.transactionKey(), 20, "取引キー")
                + fixed(event.operatorId(), 10, "操作者")
                + fixed(event.reasonCode(), 5, "理由コード")
                + fixed(event.inputDigest(), 32, "入力ダイジェスト")
                + fixed(event.occurredAt().toString(), 25, "発生時刻");
        return fixed(record, 100, "COBOL監査レコード");
    }

    public String toLegacySpring(AuditEvent event) {
        return tabSafe(event.transactionKey()) + "\t" + tabSafe(event.operatorId()) + "\t"
                + tabSafe(event.inputDigest()) + "\t" + tabSafe(event.reasonCode()) + "\t"
                + tabSafe(event.occurredAt().toString());
    }

    public Map<String, String> toSpringBoot(AuditEvent event) {
        Map<String, String> values = new LinkedHashMap<>();
        values.put("transactionKey", event.transactionKey());
        values.put("operatorId", event.operatorId());
        values.put("inputDigest", event.inputDigest());
        values.put("reasonCode", event.reasonCode());
        values.put("occurredAt", event.occurredAt().toString());
        return values;
    }

    private String fixed(String value, int length, String name) {
        if (value == null || value.length() > length) {
            throw new IllegalArgumentException(name + "が固定長へ収まりません");
        }
        StringBuilder result = new StringBuilder(value);
        while (result.length() < length) result.append(' ');
        return result.toString();
    }

    private String tabSafe(String value) {
        if (value == null || value.indexOf('\t') >= 0 || value.indexOf('\r') >= 0 || value.indexOf('\n') >= 0) {
            throw new IllegalArgumentException("旧Spring監査項目に区切り文字は使用できません");
        }
        return value;
    }
}
