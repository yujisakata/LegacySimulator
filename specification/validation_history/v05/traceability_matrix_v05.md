# V5 トレーサビリティ

| 要件 | 設計 | 実装 | テスト |
|---|---|---|---|
| V5-FR-001 | 外部設計 固定長入力 | `FixedLengthInquiryConverter` | V5-T01 |
| V5-FR-002, V5-NFR-001 | 内部設計 参照限定 | `InquirySnapshotService`, `inquiry_schema.sql` | V5-T02 |
| V5-FR-003, V5-NFR-002 | 外部設計 応答項目 | `InquiryRecord` | V5-T01 |
| V5-OPS-001 | 引継ぎ・運用手順 | `INQSYNC.jcl` | 文書レビュー |
