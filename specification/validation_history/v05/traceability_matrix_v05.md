# V5 要件・実装・試験・判断対応表

対象Version: V5<br>
想定読者: 検証・講師。全情報を当時の全担当者が持っていたとはしない。

正本: [要件](../../requirements/v05/java_inquiry_additional_requirements_v05.md)。クラスは[実装一覧](../../../implementation/v05/README.md)、試験は[V5IntegrationTest](../../../test/v05/java/V5IntegrationTest.java)。

| 要件 | 主な実装 | 実行試験 | 判断 |
|---|---|---|---|
| FR001 | Servlet.render / DAO.find | HTTP V4 result、product-specific label | D05-03/05/06 |
| FR002 | DAOのSELECT、DB権限分離 | Web DB permission rejects write×3 | D05-02/12 |
| FR003 | ExportJob.join | 実V4、duplicate/orphan/mismatch/length/lane | D05-03/04 |
| FR004 | Converter/Record/Servlet | pending、blank amount、zero amount、JDBC NULL | D05-06/07/08 |
| FR005 | Converter.convert/date | invalid Q5 0～19、zero date、leap | D05-07 |
| FR006 | ImportJob.load | checksum/count、malformed row、insertion failure、rollback、empty | D05-09 |
| FR007 | AS_OF保持、Servlet.render、DAO | future、initial unavailable、HTTP日付、not found | D05-11 |
| FR008 | Importの状態ロックと順序、DAO同一SQL | idempotent、same day conflict、older、concurrent、reader | D05-09/10 |
| FR009 | Servlet.service/escape、コンテナ認証 | HTTP 401/403/400/404/405/503、escaping | D05-12/13 |
| FR010 | 同期スクリプト、運用手順 | コマンド初回/再実行、V4ハッシュ維持 | D05-01/02/14 |

[意思決定台帳](../../development_history/v05/decision_log_v05.md)から各D05へ追跡できる。困難性K05、知識保有者、途中案は[実施記録の入口](../../requirements/v05/README.md)を参照。
