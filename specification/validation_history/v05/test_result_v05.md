# V5 実行検証結果

対象Version: V5<br>
想定読者: 検証・講師<br>
検証日: 2026-09-15

## 実行結果

Javaアプリ6クラスを実コンパイルし、実H2 JDBCとTomcat Servlet/HTTPを用いた101アサーションが合格した。V4の実COBOL3商品を入力にして、Q5生成→DB公開→ブラウザ向けHTTPの経路を確認した。

NULL/0の区別、主契約謝絶と商品別金額、制度基準日と照会基準日の区別を確認した。取込途中のDB書込失敗から前回全量へ戻ること、WebユーザーのINSERT/UPDATE/DELETE拒否、並行取込の状態ロック、古い/同日別内容の拒否も確認した。

空白を0へ誤変換する変更、失敗時rollbackをcommitに変える変更、MIの金額表示名を取り違える変更を、一時コピーで実行し、3件ともテストが検出した。配布ソースにこれらの変更は含めない。

実行用run-inquiry-sync.ps1も永続H2と取込専用ユーザーで実行し、3件のPUBLISHED、同内容再実行のUNCHANGEDを確認した。

## 途中の失敗と修正

初回のコンパイルではECJへ渡すclasspathワイルドカードを修正した。初回のDB試験では管理者専用のDB_CLOSE_DELAY設定を非管理者接続URLから除去した。権限を増やして回避する方法は採らなかった。

詳細は[作成実施記録](../../development_history/v05/work_log_v05.md)に保持する。初回失敗ログと最終ログは[検証ログ一覧](logs/README.md)から参照できる。

## 証拠

[検証証跡JSON](verification_evidence_v05.json)に件数、依存jar、対象ソース/試験ハッシュ、V4不変確認を保存する。[誤変更検出JSON](mutation_evidence_v05.json)に3件の検出箇所を保存する。[要件対応表](traceability_matrix_v05.md)と[検証仕様](test_specification_v05.md)も併読する。

Tomcat停止時にJREのSeedGeneratorスレッドの警告が出た。専用試験プロセスは終了し、サーバを常駐させていない。DB障害試験のSQL例外は意図した故障注入のログで、画面に内部情報が出ないことを確認した。

実本番製品・全支社・大量性能の検証を行ったという意味ではない。2000年の限定試験と今回の追加試験は[配布記録](release_scope_record_v05.md)で区別している。
