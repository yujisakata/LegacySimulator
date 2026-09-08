# V9 外部設計

監査イベントは `sourceSystem`, `transactionKey`, `operatorId`, `inputDigest`, `reasonCode`, `occurredAt`, `offset` を持つ。検索は取引キーとUTC期間を条件とする。本人確認アダプタは結果を共有DBへ確定後、同じ取引キーのメッセージを発行する。
