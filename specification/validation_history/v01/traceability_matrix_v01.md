# V1トレーサビリティ・マトリクス

**文書ID:** DOC-VAL-V1-003  
**対象Version:** V1  
**目的:** 業務ルールから要件、設計、実装、テストまでの対応関係を明示する。

| 業務ルール | 要件 | 外部機能 | COBOL実装 | テスト | 状態 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `BR-V1-DEF-001` | FR-V1-003 | F-V1-002 | `NBASSESS/3300-PROCESS-DEFICIENCY` | TC-V1-011〜013 | documented |
| `BR-V1-AGE-001` | FR-V1-002 | F-V1-001, 002 | `NBENTRY/2000`, `NBASSESS/3100` | TC-V1-001, 008〜010 | documented |
| `BR-V1-PRD-001` | FR-V1-002 | F-V1-001, 002 | `NBENTRY/2000`, `NBASSESS/3100` | TC-V1-017 | documented |
| `BR-V1-AMT-001` | FR-V1-002, 006 | F-V1-001, 002 | `NBENTRY/2000`, `NBASSESS/3250` | TC-V1-006, 007 | documented |
| `BR-V1-AUT-001` | FR-V1-004 | F-V1-002 | `NBASSESS/3400-PROCESS-AUTHORITY` | TC-V1-001, 009 | documented |
| `BR-V1-AUT-002` | FR-V1-005 | F-V1-002 | `NBASSESS/3400-PROCESS-AUTHORITY` | TC-V1-002〜006, 018 | documented |
| `BR-V1-SLA-001` | NFR-V1-002 | F-V1-003 | `NBJOB01.jcl`、運用確認 | IT-V1-002, 004 | documented |
| `BR-V1-RES-001` | FR-V1-008, 009 | F-V1-002 | `NBASSESS/3500,3550` | TC-V1-001, 006, 015, 019 | documented |
| `BR-V1-WDR-001` | FR-V1-007 | F-V1-002 | `NBASSESS/3000` | TC-V1-014 | documented |
| 運用継続 | FR-V1-010 | F-V1-002, 003 | `NBASSESS/2000,4000,9000` | IT-V1-001〜003 | documented |

## 判定

- 必須業務ルール9件は、すべて要件・設計・実装・テストへ接続されている。
- COBOL実行によるテスト証拠は、互換コンパイラで通常モードを実施した時点で`verified_by`として確定する。
- 現在の状態は対応関係が文書化された`documented`であり、実行証拠の確信度はテスト成績書に従う。
