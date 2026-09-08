# V10 実装

`tools` 配下は、資産棚卸しとSHA-256、影響候補検索、固定長ゴールデン比較、証拠台帳からの確信度付き知識エッジ生成を実行する。`java` 配下はJava 21解析基盤向けのノード、エッジ、確信度ポリシー、レビュー、調査結果モデルであり、現行ソースを書き換えない。

実行例:

```powershell
.\implementation\v10\tools\recover-knowledge.ps1 `
  -InputPath .\implementation\v10\evidence\knowledge_edges.csv `
  -OutputPath .\implementation\v10\output\knowledge_edges.json
```
