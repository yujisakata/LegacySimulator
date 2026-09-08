# Legacy Evolution 実物デモ

V1～V3の業務イベント、制約、要件、設計、COBOL、テストを一つの画面で辿るローカルデモである。説明用に作り直したサンプルではなく、`LegacySimulator` ワークスペースの実ファイルと実テストを使う。

## 起動

リポジトリ直下の PowerShell 7 で実行する。

```powershell
.\showcase\start-demo.ps1
```

初回は画面のビルド後、`http://127.0.0.1:3000` を開く。再起動時にビルドを省略する場合は次のとおり。

```powershell
.\showcase\start-demo.ps1 -SkipBuild
```

終了する場合:

```powershell
.\showcase\stop-demo.ps1
```

## デモで確認できること

- V1～V3をクリックして開く、業務イベント、制約、設計判断の詳細
- 記録に残る全検討案と、採用案・利点・懸念・選択理由の比較
- 要件・設計・テストを紙面風に整形した実文書ビュー
- COBOL・COPY句を変更コメント付きで表示するコードビュー
- COBOLで過去処理をコメントとして残す `DEL` と追加箇所を示す `ADD`
- V1 19件、V2 53件、V1～V3回帰テストのライブ実行
- 変更の積み重ねに伴って増える、保守時に確認すべき関係

表示用データは起動時に `evidence.manifest.json` と実ファイルから再生成される。ライブ検証APIは `127.0.0.1:4311` のみで待ち受け、`v1`、`v2`、`regression` の登録済みテストだけを受け付ける。

説明の進行例は [DEMO_GUIDE.md](DEMO_GUIDE.md) を参照する。
