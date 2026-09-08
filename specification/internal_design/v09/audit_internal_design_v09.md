# V9 内部設計

- `AuditEvent` が監査必須項目と元オフセットを保持する。
- `AuditTimeNormalizer` がOffsetDateTimeをInstantへ正規化する。
- `AuditCorrelationService` が取引キーでイベントを時系列化する。
- `KycReleaseSequence` はDB保存成功後だけメッセージ発行を許可する。
- `AuditEventEncoder` と `GenerationAuditEmitter` が、COBOL 100文字固定長、旧Springタブ区切り、Spring Boot構造化項目を各世代の実行境界から出力する。各形式は対応Mapperで同じ必須項目へ復元できる。
- `JdbcKycOutboxRepository` は本人確認結果とOutboxを同一DBトランザクションで確定する。
- `OutboxPublishJob` は未発行行を作成時刻順に再送し、発行成功後だけ発行済みにする。

## 業務継続補正

- V9-FIX-001: 集約側Mapperだけだった構成へ、各世代のログ生成境界を追加した。
- V9-FIX-002: インターフェースだけだったOutbox永続化と未発行再送を実装した。
