# V5 Java照会・夜間複製の実装

対象Version: V5（2000年相当）<br>
想定読者: 開発・検証担当

V4 COBOLを変更せず、確定した申込/査定結果のファイルから照会用複製を作る。新規Javaは6クラス。査定・再告知規則をJavaへ移植していない。

| 資産 | 役割 |
|---|---|
| [SnapshotExportJob](java/com/legacysimulator/v05/SnapshotExportJob.java) | V4の4ファイル→Q5とマニフェスト |
| [FixedLengthInquiryConverter](java/com/legacysimulator/v05/FixedLengthInquiryConverter.java) | 100文字点検、空白/ゼロ/日付の変換 |
| [InquiryRecord](java/com/legacysimulator/v05/InquiryRecord.java) | 照会項目の保持 |
| [SnapshotImportJob](java/com/legacysimulator/v05/SnapshotImportJob.java) | 全件点検、JDBC一括公開、再取込 |
| [JdbcInquiryDao](java/com/legacysimulator/v05/JdbcInquiryDao.java) | SELECT権限接続で取得 |
| [ContractInquiryServlet](java/com/legacysimulator/v05/ContractInquiryServlet.java) | 認証・権限・入力点検とHTML照会 |
| [SQL](sql/inquiry_schema.sql) | 照会DBの状態とレコード |
| [web.xml](web/WEB-INF/web.xml) | /inquiry、JNDIデータソース参照 |
| [同期ジョブ](jcl/run-inquiry-sync.ps1) | 抽出成功後に取込を実行 |

## 実行検証

```powershell
.\test\v05\scripts\prepare-dependencies.ps1
.\test\v05\scripts\run-tests.ps1
python test/v05/scripts/verify_mutations.py
```

初回の依存取得にはネットワークが必要。jarはbuild/v05/depsだけへ置き、SHA-256を検査する。システムへJDK/サーバをインストールしない。テストは実V4 COBOL、実H2 JDBC、実Tomcat HTTPを使い、ローカル動的ポートのサーバを終了時に停止する。

## 配布先への組込み

build-v05.ps1で作成したbuild/v05/classes/com以下をWebアプリのWEB-INF/classesへ配置し、web/WEB-INF/web.xmlを使用する。Servlet APIはコンテナが供給する。配布先管理者がSQLを適用し、SELECTのみのユーザーでJNDI jdbc/InquiryReadOnlyを構成する。認証済みPrincipalとinquiryロールを社内コンテナから提供する。独自ログイン画面や共通パスワードを実装していない。

夜間取込用接続は環境変数V5_IMPORT_URL/V5_IMPORT_USER/V5_IMPORT_PASSWORD。[同期手順](../../specification/operations/v05/inquiry_sync_operations_v05.md)を参照。DB作成用の管理資格情報をWeb/取込へ流用しない。

Java 8構文、Tomcat 9、H2は2026年の再現実行環境である。[技術基準](../../specification/technical_baseline/v05/technical_baseline_v05.md)の通り、2000年のJDKや特定本番製品で実行したという主張ではない。
