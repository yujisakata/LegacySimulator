# V2 COBOL実装

V1の全量ソースを基礎に、2特約を追加した単独ビルド可能なV2実装である。

- batch/NBASSESS.cbl: 主契約査定とAD・HI査定
- online/NBENTRY.cbl: 主契約・特約の端末登録
- copybook/NBAPPL.cpy: 120文字申込レコード
- copybook/NBRESULT.cpy: 80文字結果レコード
- jcl/NBJOB01.jcl: 日次査定ジョブ

変更番号 V2-001 のDELコメントは置換前行、ADD START/ENDは追加範囲を示す。V1配下のソースはV2対応によって編集しない。

