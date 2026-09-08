package com.legacysimulator.v09;

import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

// V9-ADD-003: 取引キーで多世代イベントを抽出しUTC順に並べる。
public final class AuditCorrelationService {
    public List<AuditEvent> correlate(String key, List<AuditEvent> events) {
        return events.stream().filter(e -> key.equals(e.transactionKey()))
                .sorted(Comparator.comparing(e -> e.occurredAt().toInstant()))
                .collect(Collectors.toList());
    }
}
