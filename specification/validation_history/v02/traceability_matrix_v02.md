# V2トレーサビリティ・マトリクス

**文書ID:** DOC-VAL-V2-003

| 業務ルール | 要件 | 外部機能 | COBOL実装 | テスト | 状態 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| BR-V2-RDR-001, 002 | FR-V2-001 | F-V2-001 | NBENTRY/1000 | TC-V2-003, 015, 022 | verified |
| BR-V2-RDR-003 | FR-V2-002, 009 | F-V2-001, 002 | NBENTRY/2100,2200; NBASSESS/3810,3830 | V1互換19件、TC-V2-001,032 | verified |
| BR-V2-CMP-001 | FR-V2-006 | F-V2-002 | NBASSESS/3810,3830 | TC-V2-002,014,026～029 | verified |
| BR-V2-CMP-002 | FR-V2-007 | F-V2-002 | NBASSESS/3820,3840 | TC-V2-022～025 | verified |
| BR-V2-AD-001 | FR-V2-003 | F-V2-002 | NBASSESS/3820 | TC-V2-002～005 | verified |
| BR-V2-AD-002 | FR-V2-002,003 | F-V2-002 | NBASSESS/3820 | TC-V2-003,004,006～009 | verified |
| BR-V2-AD-003 | FR-V2-003 | F-V2-002 | NBASSESS/3820 | TC-V2-010 | verified |
| BR-V2-AD-004,005 | FR-V2-004 | F-V2-002 | NBASSESS/3825 | TC-V2-003,006,007,011～013 | verified |
| BR-V2-HI-001 | FR-V2-005 | F-V2-002 | NBASSESS/3840 | TC-V2-014～017 | verified |
| BR-V2-HI-002 | FR-V2-002,005 | F-V2-002 | NBASSESS/3840 | TC-V2-015～018 | verified |
| BR-V2-HI-003,004 | FR-V2-005 | F-V2-002 | NBASSESS/3845 | TC-V2-015,019～021 | verified |
| 出力・継続 | FR-V2-008,010 | F-V2-003 | NBRESULT; NBASSESS/3800,4000 | TC-V2-022～034 | verified |
| 固定長互換 | NFR-V2-001～005 | F-V2-001～003 | V2 COPY句、NBASSESS | V1互換19件 | verified |
| 代表試験 | NFR-V2-006,007 | 検証資産 | run-tests.ps1 | V2 34件、未実施組合せ記録 | verified |
| 後続受渡し | NFR-V2-008 | 運用追補 | ASSESSMENT 41～64桁 | 実機結合は移行前確認 | documented |

V2追加ルール14件は要件、設計、実装、テストへ接続されている。後続証券発行バッチ本体との結合は別部門確認のため、状態をdocumentedとして区別する。
