# Legacy Evolution Simulator

企業システムが業務変更、法制度、技術移行、組織変更を経て複雑化し、知識の対応関係が変化する過程を再現する研究・教育用リポジトリである。

## 現在の実行可能範囲

V1（1980年）からV10（2026年）までを、業務要求、追加要件、設計判断、影響分析、外部・内部設計、実装、テスト、トレーサビリティのVersion別成果物として収録している。過去Versionは上書きせず、当時の制約に応じた差分と全量ソースを併存させる。

| Version | 実装の実物 | 現環境での検証 |
|---|---|---|
| V1～V3 | COBOLオンライン・査定バッチ・固定長 | GnuCOBOLコンパイル＋104件 |
| V4 | 施行日・再告知を扱うCOBOL | GnuCOBOLコンパイル＋8件 |
| V5 | Java参照専用変換・照会サービス | 変換4件＋更新禁止制約 |
| V6 | Spring世代受付・80文字連携・高額分離 | 受付境界5件 |
| V7 | チャネル権限・固定長予約領域 | 権限4件＋受渡し3件 |
| V8 | 外部アダプタ・再送・重複排除 | 連携4件＋接続/再送構造 |
| V9 | 監査時刻正規化・相関・KYC分離 | 時刻相関4件＋形式往復3件 |
| V10 | 確信度付き知識復元ツール | 16エッジ実行 |

- [V1業務仕様](specification/business_specification/v01/new_business_business_specification_v01.md)
- [V1要件定義](specification/requirements/v01/new_business_system_requirements_v01.md)
- [V1外部設計](specification/external_design/v01/new_business_system_design_v01.md)
- [V1内部設計](specification/internal_design/v01/new_business_cobol_design_v01.md)
- [V1実装](implementation/v01/README.md)
- [V1テスト](test/v01/README.md)
- [V1トレーサビリティ](specification/validation_history/v01/traceability_matrix_v01.md)

## 検証

検証資産のみを確認する場合:

```powershell
./test/v01/scripts/run-tests.ps1 -ReferenceOnly
```

GnuCOBOLが利用できる環境では、COBOLのコンパイルと19件の完全一致比較を実行する。

```powershell
./test/v01/scripts/run-tests.ps1
```

全Versionをまとめて検証する。

```powershell
.\test\run-all-versions.ps1
```

一括検証では最初にV4～V10の実装資産数と行数の下限を確認し、その後に各Versionの振る舞いを実行する。構成と計測値は [V4～V10実装資産構成記録](specification/validation_history/source_inventory_v04_v10.md) を参照する。

業務継続に直接影響する不整合の補正と、業務を継続できても形式知が同期していない箇所の区別は、[文書・コード不整合の業務継続補正](specification/validation_history/business_continuity_correction_summary_v06_v10.md) にまとめている。

V5～V9のJavaソースとV10のJava 21モデルは実物として収録している。現在の端末にはJDKがないため、PowerShellによる参照挙動とソース制約を実行し、Javaコンパイルは未実施として成績書に記録している。

V2以降は`scenario/version_timeline.yml`のイベントを適用し、V1を上書きせずVersion別成果物として追加する。

## 開発者向け進化分析

V1～V10で、各時点の合理的な判断が次Versionの変更条件へ変わり、V10でコード変換だけではモダナイズを開始できなくなる過程をVersion別に整理している。

- [V1～V10 開発者向け進化分析](specification/evolution_analysis/README.md)
- [暗黙知・文書／コード非同期・知識散在の発生原因分析](specification/evolution_analysis/tacit_knowledge_and_artifact_drift_root_cause_analysis.md)
- [V9→V10分析・横断総括](specification/evolution_analysis/v10_modernization_readiness_analysis.md)

## V2 特約追加

V2（1985年、災害死亡特約・入院特約の同時発売）は、変更要求から実行テストまでを収録している。V1原本を維持し、V2ソースは単独でコンパイルできる全量版として管理する。

- [V2要求成果物の索引](specification/requirements/v02/README.md)
- [V2変更要求](specification/requirements/v02/rider_addition_change_request_v02.md)
- [V2追加要件](specification/requirements/v02/new_business_additional_requirements_v02.md)
- [V2影響分析](specification/impact_analysis/v02/new_business_impact_analysis_v02.md)
- [V2外部設計](specification/external_design/v02/new_business_system_design_delta_v02.md)
- [V2内部設計](specification/internal_design/v02/new_business_cobol_design_v02.md)
- [V2実装](implementation/v02/README.md)
- [V2テスト](test/v02/README.md)
- [V2トレーサビリティ](specification/validation_history/v02/traceability_matrix_v02.md)
- [V2テスト成績](specification/validation_history/v02/test_result_v02.md)

V2をコンパイルし、V1互換19件とV2代表34件を実行する。

```powershell
./test/v02/scripts/run-tests.ps1
```

## V3 医療系商品の複製開発

V3（1990年）は、医療保険MI・がん保険CIを商品別プログラムとして追加する。原本設計を維持し、差分別冊と全量COBOLを管理する。

- [V3差分成果物の索引](specification/requirements/v03/README.md)
- [V3変更要求](specification/requirements/v03/medical_product_change_request_v03.md)
- [V3追加要件](specification/requirements/v03/medical_additional_requirements_v03.md)
- [V3影響分析](specification/impact_analysis/v03/medical_product_impact_analysis_v03.md)
- [V3外部設計別冊](specification/external_design/v03/medical_product_design_addendum_v03.md)
- [V3内部設計別冊](specification/internal_design/v03/medical_cobol_design_v03.md)
- [V3実装](implementation/v03/README.md)
- [V3テスト](test/v03/README.md)
- [V3トレーサビリティ](specification/validation_history/v03/traceability_matrix_v03.md)
- [V3テスト成績](specification/validation_history/v03/test_result_v03.md)

V1～V3の後世回帰を実行する。

```powershell
./test/v03/scripts/run-regression.ps1
```

## 実物デモ

経営者・開発者向けに、業務イベントと制約から要件、設計、COBOL、テストまでを実ファイルで辿るローカルデモを収録している。

```powershell
.\showcase\start-demo.ps1
```

画面の説明と7分・20分の進行例は [showcase/README.md](showcase/README.md) と [showcase/DEMO_GUIDE.md](showcase/DEMO_GUIDE.md) を参照する。
