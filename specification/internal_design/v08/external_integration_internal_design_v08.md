# V8 内部設計

- `PartnerAdapter` が接続先応答を `CanonicalResponse` へ変換する。
- `DuplicateResponseGuard` が `partner:transactionId` を重複排除キーとする。
- `IntegrationState` が初回受付時の `sequence` を保持し、JDBC再送検索と `RetryDispatchJob` がその昇順を維持する。
- 初回送信は状態を作成し、再送は既存状態を更新する。同一取引の状態行を再作成しない。
- 接続Clientは契約照会=`ContractSoapClient`、本人確認=`KycEsbClient`、代理店基盤=`AgencyQueueClient` とする。
- 接続先差分をアダプタ内へ限定し、COBOLの固定長位置は変更しない。

## 業務継続補正

- V8-FIX-001: 更新時刻順での再送と、再送時の状態行再作成を廃止し、初回キュー番号順・既存状態更新へ補正した。
- V8-FIX-002: 実装設定を外部設計の通信方式へ合わせた。旧Clientクラスは変更履歴として残すが、Spring Beanには登録しない。
