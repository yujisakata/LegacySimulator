# V6 内部設計

- `EntryValidationService`: 必須、年齢0～120、V3から継続する正式商品コード `WL/MI/CI` を点検する。
- `CobolEntryFileGateway`: 80文字の固定長レコードを生成する。
- `BatchLaneSelector`: 20,000,000以上をHIGHへ振り分ける。
- XML設定で各部品の依存関係を定義し、COBOL査定を置換しない。

V6追加行には `V6-ADD` の日本語コメントを付す。

## 業務継続補正

`V6-FIX-001`では、Spring側だけで使用していた`MD/CA`を廃止し、V3 COBOLが受理する`MI/CI`へ統一した。別コード体系を導入する変換要件・変換設計が存在しないため、固定長11～12桁には正式商品コードをそのまま出力する。
