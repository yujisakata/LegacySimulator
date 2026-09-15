# V5 Java内部設計

対象Version: V5最終配布<br>
想定読者: Java保守・検証担当

| クラス | 責務 | 接続先 |
|---|---|---|
| SnapshotExportJob | V4の2系統4ファイルをキー突合、100文字Q5と宣言を生成 | 確定した受渡しファイルのみ |
| FixedLengthInquiryConverter | 長さ・文字・コード・日付・空白/ゼロを点検し型へ変換 | 外部接続なし |
| InquiryRecord | 照会用の項目を保持。査定判断を持たない | 外部接続なし |
| SnapshotImportJob | 宣言と内容を点検し全量公開。再実行と順序を管理 | 取込権限の照会DB |
| JdbcInquiryDao | 公開日と1行を単一のSELECTで取得 | SELECT限定の照会DB |
| ContractInquiryServlet | 認証主体/役割、番号、メソッドを点検して表示 | DAOのみ |

## 取込順序

1. manifest形式、業務日との関係、ハッシュ、件数を点検。
2. ハッシュ計算と同じバイト列を変換する。全行の形式・重複・基準日の一致を確認。
3. 専用JDBC接続でトランザクション開始。INQUIRY_STATEのID=1をFOR UPDATEで取得。
4. 古い基準日・同日別内容を拒否。同日同内容は変更なしで成功。
5. 全照会行をDELETEし、新全量をINSERT。メタデータを更新してcommit。
6. 失敗時rollback。接続を呼出元でclose。

Web DAOは公開状態と行を同一SQLで読む。未公開NULLはSQLException、公開済みで番号なしはnullとしてServletが区別する。SQLパラメータはPreparedStatement。

## 配布と責任境界

[SQL](../../../implementation/v05/sql/inquiry_schema.sql)を管理者が適用し、取込・照会ユーザーを別作成する。WebのJNDI名はjdbc/InquiryReadOnly。パスワードをソースへ埋め込まない。テスト用ユーザーは隔離したテストDB内だけに作成する。

正確な再判定はCOBOLの責務。本設計では30日猶予・決裁境界・再告知優先をJavaの規則へ移植しない。新旧資料からこれらの理由を説明する作業は[V4→V5分析](../../evolution_analysis/v05_transition_analysis.md)の対象。
