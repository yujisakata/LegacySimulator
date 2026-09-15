# V5検証ログ

対象Version: V5<br>
想定読者: 検証・講師

- [初回失敗](initial_failure.log): H2管理設定を非管理接続へ渡した問題。
- [最終検証](final_verification.log): コンパイル、V4実行、101アサーション。SQL例外は意図した権限取消試験のサーバログを含む。
- [同期コマンド初回](job_first.log): PUBLISHED。
- [同期コマンド再実行](job_retry.log): UNCHANGED。

ローカル検証の絶対パス・動的ポート・実行時刻を含む。資格情報はテスト専用DBのものをコード側で使用し、本番の情報は使用していない。コンパイラやJREの警告を削除せず保存する。
