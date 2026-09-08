# V2ゴールデンデータ仕様

**文書ID:** DOC-VAL-V2-002

## 正本

- V1互換期待値: test/v01/expected/ASSESSMENT.DAT の1～40桁
- V2期待値: test/v02/cases/rider_cases.csv の Expected 列
- 固定長組立てと比較: test/v02/scripts/run-tests.ps1

V2のCSVは入力値と主契約・AD・HIの期待結果を同じ行で宣言する。実行スクリプトが120文字入力と80文字期待結果を組み立て、COBOL出力と文字単位で比較する。

## 固定値

- V1互換入力の75～120桁は全空白とする。
- V1互換出力のAD・HIは N/N/000、額ゼロとする。
- V2結果の65～80桁は空白とする。
- 非承諾時の責任開始日は 00000000 とする。
