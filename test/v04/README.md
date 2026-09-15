# V4テスト

対象Version: V4補正後<br>
想定読者: 教材検証担当（2026年追加自動検証）

商品別NB/MDの4プログラムをコンパイルし、統合800件、逆順800件、V1～V3の既存期待値85件、受付・査定連携98件、マスタ不正48件、入出力10件、マスタ変更2件を確認する。

```powershell
.\test\v04\scripts\run-tests.ps1
```

[検証仕様](../../specification/validation_history/v04/test_specification_v04.md)と[最終要件](../../specification/requirements/v04/regulatory_additional_requirements_v04.md)を参照。Python 3の標準ライブラリを使用し、追加pipパッケージは不要。結果はbuild/v04/verification.json。

追加の検出力確認は、上記実行後の同じPowerShellで `python test/v04/scripts/verify_mutations.py --bin build/v04` を実行する。配布ソースを変更せず、一時コピーの再告知補正を無効化した場合と境界の比較を変更した場合を4プログラムで試し、8通りすべてを検出する。

## 既存8件の位置付け

regulatory_cases.csvは作業開始時に残っていた旧RG系の参考fixtureとして変更せず保持した。入力80/結果40の独立した制度判定用であり、今回の申込120/結果80の統合査定とはインターフェースが異なる。新旧基準、再告知の両方向、入力区分不正という意図をintegrated_cases.csvへ展開した。旧8件を今回の実行済み件数には加算しない。
