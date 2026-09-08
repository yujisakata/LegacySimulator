# V9 トレーサビリティ

| 要件 | 実装 | テスト |
|---|---|---|
| V9-FR-001, V9-NFR-001 | `AuditEvent`, `AuditEventEncoder`, `GenerationAuditEmitter` | V9-T01, V9-T05 |
| V9-FR-002 | `AuditTimeNormalizer` | V9-T02 |
| V9-FR-003 | `AuditCorrelationService`, 世代別Mapper/Emitter | V9-T03, V9-T05 |
| V9-FR-004 | `KycReleaseSequence`, `JdbcKycOutboxRepository`, `OutboxPublishJob` | V9-T04, V9-T06 |
