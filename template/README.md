# **エンタープライズ・システム ドキュメント体系＆テンプレート索引**

本ディレクトリ（`template/`）は、エンタープライズシステム構築、保守、およびモダナイゼーション研究において使用する標準ドキュメントテンプレート集です。

---

## **ドキュメント体系階層構造**

```
template/
├── README.md                          # 本インデックスファイル
├── 01_business/                       # 1. ビジネス・概念層
│   ├── business_specification_template.md # [仕様] ビジネス仕様書
│   ├── business_rules_template.md         # [仕様] ビジネスルール仕様書
│   ├── business_flow_template.md          # [仕様] 業務フロー図・定義書
│   ├── business_glossary_template.md      # [定義] 業務用語集
│   ├── product_definition_template.md     # [定義] 商品定義書・約款
│   ├── actuarial_basis_template.md        # [仕様] 数理仕様書（計算基礎書）
│   └── regulatory_rules_template.md       # [解説] 法令・ガイドライン解説書
├── 02_requirements/                   # 2. 要件定義層
│   ├── usecase_specification_template.md  # [要件] ユースケース仕様書
│   ├── system_boundary_io_template.md     # [要件] システム境界・入出力一覧
│   ├── screen_definition_template.md      # [要件] 画面定義書
│   ├── report_definition_template.md      # [要件] 帳票定義書
│   ├── external_interface_req_template.md # [要件] 外部システム連携要件定義書
│   ├── non_functional_req_template.md     # [要件] 非機能要件定義書
│   └── change_request_template.md         # [変更] 変更要求書 (CR)
├── 03_external_design/                # 3. 外部設計層
│   ├── system_architecture_template.md    # [設計] システム構成図・他システム関係図
│   ├── functional_hierarchy_template.md   # [設計] 機能構造図・機能一覧表
│   ├── logical_erd_template.md            # [設計] 論理DB構造図 (ERD)
│   ├── data_dictionary_template.md        # [設計] データ辞書・エンティティ定義
│   ├── online_function_design_template.md # [設計] 機能設計書 (オンライン)
│   ├── batch_function_design_template.md  # [設計] 機能設計書 (バッチ)
│   └── external_file_spec_template.md     # [設計] 外部ファイルレイアウト仕様書
├── 04_internal_design/                # 4. 内部設計層
│   ├── online_detail_design_template.md   # [詳細] 詳細設計書 (オンライン)
│   ├── batch_detail_design_template.md    # [詳細] 詳細設計書 (バッチ)
│   ├── common_component_spec_template.md  # [詳細] 共通モジュール仕様書
│   ├── physical_schema_template.md        # [詳細] 物理DB設計書 (DDL)
│   ├── physical_record_layout_template.md # [詳細] 物理ファイル・レコード仕様書
│   └── common_processing_design_template.md# [詳細] 共通処理方式設計書
├── 05_technical_baseline/             # 5. 技術・基盤共通層
│   ├── technical_constraints_template.md  # [共通] 技術制約書
│   ├── coding_standards_template.md       # [共通] コーディング規約・標準化ガイドライン
│   ├── infrastructure_spec_template.md    # [共通] インフラ・環境構成仕様書
│   └── job_schedule_spec_template.md      # [共通] ジョブスケジュール仕様書
└── 06_validation_history/             # 6. テスト・検証・変更履歴層
    ├── test_specification_template.md     # [検証] テスト仕様書・成績書
    ├── golden_dataset_spec_template.md    # [検証] 回帰テスト用データセット仕様書
    ├── incident_patch_note_template.md    # [履歴] 障害報告書・緊急改修記録
    ├── adr_template.md                    # [履歴] アーキテクチャ決定記録 (ADR)
    ├── handover_notes_template.md         # [履歴] 引継書・ベンダ申し送り事項
    └── design_deliberation_log_template.md# [履歴] 設計検討・知識構造記録（思考ログ）
```

---

## **ドキュメント運用ガイドライン**

1. **トレーサビリティの維持**:
   - 各ドキュメントには、上位ドキュメント（参照元）および下位ドキュメント（影響先）の明示的なリンクを記述してください。
2. **変更履歴の徹底**:
   - 仕様改訂時は、必ず文書先頭の「改訂履歴」テーブルに改訂日、改訂者、変更理由（CR番号等）を記録してください。
3. **数値・パラメータの分離**:
   - 業務仕様書本体には定数を直接書き込まず、『ビジネスルール仕様書』として独立定義・参照させてください。
