# V2テスト

run-tests.ps1はV1ゴールデン19件を予約領域全空白のまま再実行し、主契約結果1～40桁の互換性を確認する。続いてV2特約34件の全80桁をCSVの期待値と比較する。

```powershell
.\test\v02\scripts\run-tests.ps1
```

ReferenceOnlyを指定すると、固定長と期待値定義だけを検証する。

