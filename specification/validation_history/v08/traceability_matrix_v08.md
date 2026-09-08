# V8 トレーサビリティ

| 要件 | 実装/文書 | テスト |
|---|---|---|
| V8-FR-001, V8-FR-002 | `PartnerAdapter`, `CanonicalResponse`, 接続先別Client、Spring設定 | V8-T01, V8-T06 |
| V8-FR-003 | `IntegrationState`, `JdbcIntegrationStateRepository`, `RetryDispatchJob` | V8-T02, V8-T05 |
| V8-FR-004 | `DuplicateResponseGuard` | V8-T03 |
| V8-NFR-001, V8-ORG-001 | 外部設計、責任分界 | V8-T04 |
