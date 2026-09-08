# V3 医療系商品COBOL実装

終身保険の手続き型処理を複製し、医療保険MI・がん保険CIの商品固有条件を追加した全量ソースである。

- batch/MDASSESS.cbl: MI・CI日次査定
- online/MDENTRY.cbl: MI・CI端末登録
- copybook/MDAPPL.cpy: 120文字医療系申込
- copybook/MDRESULT.cpy: 80文字医療系結果
- jcl/MDJOB01.jcl: 商品別ジョブステップ

変更箇所はV3-001 ADD/DELで追跡し、説明コメントは日本語で記載する。V1・V2ソースは編集しない。

