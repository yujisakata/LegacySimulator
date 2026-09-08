# ナレッジ管理

このディレクトリは、業務、要件、設計、実装、データ、テスト、運用、組織を結ぶ知識構造をVersionごとに記録する。

個別の文書やコードを「ノード」、それらの対応関係と判断理由を「エッジ」として扱う。有識者とは、単に多くのノードを知る人物ではなく、変更要求から影響先までのエッジをたどれる組織能力として定義する。

## ファイル

- [`../specification/evolution_analysis/tacit_knowledge_and_artifact_drift_root_cause_analysis.md`](../specification/evolution_analysis/tacit_knowledge_and_artifact_drift_root_cause_analysis.md): 暗黙知、文書／コード非同期、知識散在が生まれた原因の事実ベース横断分析
- `history_of_check.md`: 生命保険査定ルールの歴史調査
- `knowledge_model.yml`: ノード、エッジ、知識状態、確信度の共通定義
- `knowledge_evolution.yml`: V1〜V10における知識状態の変化
- `examples/v01_30day_rule.yml`: V1の30日猶予ルールを知識グラフとして表した例
- `examples/v01_baseline_trace.yml`: V1の業務・要件・設計・COBOL・テストを結ぶベースライン例
- `examples/v02_rider_requirements.yml`: V2特約追加イベントから追加要件までの知識構造
- `examples/v02_rider_implementation_trace.yml`: V2追加要件から設計・COBOL・実行テストまでの知識構造
- `examples/v03_medical_product_trace.yml`: V3商品別複製と差分設計・知識分散の構造

## 管理上の原則

1. 業務上の意図と現行実装の動作を分けて記録する。
2. 「コードに書かれている」だけでは、業務上正しいと確定しない。
3. AIによる推定には、根拠、反証、確信度を付ける。
4. 有識者名そのものではなく、役割、保持知識、参照可能期間を記録する。
5. 確認できなくなった知識も削除せず、`unconfirmed`として履歴を残す。
6. Version更新時は、追加されたエッジだけでなく、確認手段を失ったエッジも記録する。

## V10での利用

V10では、コード、データ、ログ、テスト、断片文書、ヒアリングを証拠としてエッジを復元する。復元結果は、次のいずれかに分類する。

- 文書と実装の双方で確認済み
- 複数の実行証拠から確認済み
- コード構造から推論可能
- AIによる候補で、業務レビュー待ち
- 証拠不足で未確認
