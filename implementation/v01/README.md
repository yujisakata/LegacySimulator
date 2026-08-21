# V1実装

1980年の新契約査定ベースラインを、COBOL、固定長ファイル、JCL相当の構成で表現する。

## 構成

- `online/NBENTRY.cbl`: 文字端末から申込を登録する。
- `batch/NBASSESS.cbl`: 夜間に申込を査定し、結果を出力する。
- `copybook/NBAPPL.cpy`: 120文字の申込レコード。
- `copybook/NBRESULT.cpy`: 80文字の査定結果レコード。
- `jcl/NBJOB01.jcl`: 日次ジョブのJCL相当サンプル。

## 実行時ファイル

プログラムのカレントディレクトリに次の物理名を配置する。

- 入力: `APPLICATION.DAT`
- 出力: `ASSESSMENT.DAT`

GnuCOBOLによる教材環境でのビルド・テスト方法は、`test/v01/README.md`を参照する。GnuCOBOLはV1本番構成ではなく、現代環境でCOBOL資産を検証するための手段である。

## 設計上の基準

- 業務ルールの正本は`specification/business_specification/v01/`に置く。
- 入出力位置の正本はV1外部設計書に置く。
- COBOL段落の責務はV1内部設計書に置く。
- 予約領域は空白のまま出力し、V1では別用途に使用しない。
