# V10 トレーサビリティ

| 要件 | 実装 | テスト |
|---|---|---|
| V10-FR-001, V10-FR-002 | `knowledge_edges.csv`, `recover-knowledge.ps1` | V10-T01, V10-T05 |
| V10-FR-003 | 反証上限ロジック | V10-T02 |
| V10-FR-004 | `compare-golden.ps1`, 証拠台帳、期待確信度 | V10-T01, V10-T06 |
| V10-NFR-001 | `EvidenceEdge.ReviewStatus` | V10-T03 |
| V10-NFR-002 | 別出力パス | V10-T04 |
