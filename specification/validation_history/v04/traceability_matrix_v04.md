# V4最終要件・コード・検証対応

対象Version: V4補正後<br>
想定読者: 教材検証者・講師。1995年当時の統合設計書ではない。

正本は[最終要件](../../requirements/v04/regulatory_additional_requirements_v04.md)。コードは[実装一覧](../../../implementation/v04/README.md)、ケースは[CSV](../../../test/v04/cases/integrated_cases.csv)、実行は[検証プログラム](../../../test/v04/scripts/verify_v04.py)を参照する。

| 要件 | 実装箇所 | 検証根拠 |
|---|---|---|
| FR-V4-001 | NB/MDのENTRY/ASSESS:3150 | MATRIX全商品、PROCESS-DATE-INDEPENDENT、master_change |
| FR-V4-002 | NB/MD ASSESS:3350/3360/3370 | MATRIXの選択回答N/Y、DECLINE-BEFORE-MANAGER |
| FR-V4-003 | ASSESS:3000/3250/3300/3400/3500、NB:3800 | 継承85件、WITHDRAWAL、DEF-30/31、WAIT、MANAGER、AMOUNT、RIDERS-NEW |
| FR-V4-004 | 商品系統別APPL/RESULT COPY、MD:3100 | 120/80文字完全一致、特約結果、V3予約不正ケース |
| FR-V4-005 | 4プログラム:3150 | MATRIX空白条件、INVALID-Redisclosure/OldAnswer/NewAnswer |
| FR-V4-006 | ASSESS:3000と3150、RESULT COPY | CSVのExpectedRule/ExpectedAppliedDate、全80文字比較 |
| FR-V4-007 | ASSESS:2000/3900/4000/9000 | 入出力件数、混在800件、逆順、ioの10条件 |
| FR-V4-008 | 4プログラム:1100とマスタFD | invalid_master 48条件、master_change 2条件 |
| FR-V4-009 | ENTRY:1200/3150/3000 | online 98条件、受付ファイルを実バッチへ投入 |
| FR-V4-010 | 4プログラム:3150のV4-002 | MATRIX-02-YとMATRIX-20-Yの全回答、BAD-DATE-00000000 |

## 説明情報の対応

技術・納期・組織制約は[技術基準](../../technical_baseline/v04/technical_baseline_v04.md)と[検討記録](../../business_specification/v04/regulatory_design_deliberation_v04.md)、設計との差は[障害票](incident_patch_note_v04.md)、暗黙知と保有者は[講師向け知識記録](../../../knowledge/examples/v04_regulatory_knowledge_distribution.md)、7つの課題は[V3→V4分析](../../evolution_analysis/v04_transition_analysis.md)に対応する。
