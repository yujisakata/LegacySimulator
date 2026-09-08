# V3ゴールデンデータ仕様

**文書ID:** DOC-VAL-V3-002

## 正本

- 入力・期待値宣言: test/v03/cases/medical_cases.csv
- 固定長組立て・比較: test/v03/scripts/run-tests.ps1
- 後世回帰: test/v03/scripts/run-regression.ps1

CSVからMEDICAL.DATの120文字とMEDASSESS.DATの80文字期待値を組み立てる。61～68桁は8桁ゼロ埋め、75～120桁と結果41～80桁は原則空白とする。

TC-V3-030だけは予約領域不正を確認するため75桁目へXを設定する。

