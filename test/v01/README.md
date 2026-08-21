# V1テスト

V1の業務ルール境界と固定長インターフェースを、19件のゴールデンケースで検証する。

## ファイル

- `cases/assessment_cases.csv`: 人がレビューできるテスト条件と期待値
- `expected/ASSESSMENT.DAT`: 80文字固定長の承認済み期待結果
- `scripts/build-v01.ps1`: GnuCOBOLビルド補助
- `scripts/run-tests.ps1`: レコード生成、COBOL実行、完全一致比較

## 実行

GnuCOBOLが利用できる環境:

```powershell
./test/v01/scripts/run-tests.ps1
```

GnuCOBOLがない環境で、CSVとゴールデンファイルの件数・桁数・期待値転記だけを検証する場合:

```powershell
./test/v01/scripts/run-tests.ps1 -ReferenceOnly
```

`ReferenceOnly`はCOBOL実装の試験合格を意味しない。実装の正式な成績は、GnuCOBOLまたは互換COBOL処理系で通常モードを実行した結果として記録する。
