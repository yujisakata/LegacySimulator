# V5 内部設計

- `FixedLengthInquiryConverter` が固定位置を切り出し、空白をnullへ変換する。
- `InquirySnapshotService` は `findByContractNumber` のみを公開し、不変Mapを保持する。
- SQL資産はSELECTとテーブル定義だけを保持し、更新SQLをアプリケーションへ置かない。
- 夜間ジョブ `INQSYNC` がCOBOL出力から照会DBロードへ一方向に接続する。

過去処理を削除せず、V5追加部には日本語の変更識別コメントを付ける。
