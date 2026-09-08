package com.legacysimulator.v09;

import java.time.Instant;

// V9-ADD-002: 元のオフセットをAuditEventに残したままUTC比較値を得る。
public final class AuditTimeNormalizer {
    public Instant normalize(AuditEvent event) { return event.occurredAt().toInstant(); }
}
