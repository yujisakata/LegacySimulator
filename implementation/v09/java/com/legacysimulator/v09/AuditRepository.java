package com.legacysimulator.v09;

import java.time.Instant;
import java.util.List;

// V9-ADD-009: 監査DBへの追記と取引キー検索を提供する境界。
public interface AuditRepository {
    boolean appendIfAbsent(AuditEvent event);
    List<AuditEvent> find(String transactionKey, Instant from, Instant to);
}
