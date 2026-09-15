# V5 実Java・JDBC・HTTP検証

対象Version: V5<br>
想定読者: 検証担当

```powershell
.\test\v05\scripts\prepare-dependencies.ps1
.\test\v05\scripts\run-tests.ps1
python test/v05/scripts/verify_mutations.py
```

初回は依存取得用ネットワークが必要。Java 8実行環境、Python 3、PowerShell、V4用GnuCOBOLを使用する。ECJでコンパイルし、jarのSHA-256を照合する。Java試験を省略して合格にする経路はない。

101アサーション、V4実COBOL3商品の接続、実H2の権限/rollback/並行処理、実TomcatのHTTPを検証する。誤変更3件の検出力確認は別コマンド。結果はbuild/v05のresult.json、mutation-result.json、last-run.txt。実行ごとのファイルはrun-UUIDへ保存する。

旧cases/inquiry_cases.csvの4件は40文字の参考fixtureとして変更せず保存する。今回の正式入力は100文字Q5であり、旧4件を実行済みの正式インターフェース試験として数えない。

[成果物入口](../../specification/requirements/v05/README.md)、[検証仕様](../../specification/validation_history/v05/test_specification_v05.md)を参照。
