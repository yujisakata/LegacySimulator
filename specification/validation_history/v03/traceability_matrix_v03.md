# V3トレーサビリティ・マトリクス

**文書ID:** DOC-VAL-V3-003

| 業務ルール | 要件 | 設計機能 | COBOL実装 | テスト | 状態 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| BR-V3-COM-001 | FR-V3-001 | F-V3-001,002 | MDENTRY、MDASSESS | TC-V3-001,014 | verified |
| BR-V3-COM-002 | FR-V3-005 | F-V3-002 | MDASSESS/3300,3500～3700 | TC-V3-025～029 | verified |
| BR-V3-COM-003 | FR-V3-006 | F-V3-001,002 | MDENTRY/1000、MDASSESS/3100 | TC-V3-030 | verified |
| BR-V3-COM-004 | FR-V3-002 | F-V3-001,002 | MDENTRY/2000、MDASSESS/3100 | TC-V3-024 | verified |
| BR-V3-MI-001 | FR-V3-003 | F-V3-002 | MDASSESS/3100 | TC-V3-001～003 | verified |
| BR-V3-MI-002 | FR-V3-003 | F-V3-002 | MDASSESS/3250 | TC-V3-001,002,004,008 | verified |
| BR-V3-MI-003,004 | FR-V3-003 | F-V3-002 | MDASSESS/3400 | TC-V3-004～012 | verified |
| BR-V3-CI-001 | FR-V3-004 | F-V3-002 | MDASSESS/3100 | TC-V3-013～016 | verified |
| BR-V3-CI-002 | FR-V3-004 | F-V3-002 | MDASSESS/3250 | TC-V3-014,015,017,021 | verified |
| BR-V3-CI-003,004 | FR-V3-004 | F-V3-002 | MDASSESS/3400 | TC-V3-017～023 | verified |
| 固定長・個別配布 | NFR-V3-001～005 | F-V3-003,004 | COPY句、MDJOB01 | ビルド、32件長さ確認 | verified |
| 差分文書・試験区別 | NFR-V3-006～008 | 別冊設計・検証履歴 | 対象外 | 試験仕様3章 | documented |

V3業務ルール12件は要件、別冊設計、実装、V3試験へ接続されている。1990年当時の既存商品試験範囲は原証跡がないため、後世回帰と区別して記録する。

