# V4～V10 実装資産構成記録

**計測日:** 2026年9月8日  
**対象拡張子:** COBOL、COPY句、JCL、Java、SQL、XML、PowerShell

| Version | 実装資産数 | 実装行数 | 主な構成 |
|---|---:|---:|---|
| V4 | 5 | 337 | 端末COBOL、査定COBOL、入力・結果COPY句、JCL |
| V5 | 12 | 356 | Servlet、照会Service、JDBC DAO、夜間取込、SQL、Web設定、JCL |
| V6 | 15 | 377 | Controller、受付集約、Service、Repository、正式商品コード、固定長Gateway、二系統バッチ、SQL、XML |
| V7 | 15 | 268 | 社員・代理店Controller、権限、共通Service、固定長補完、受付番号相関、障害振分け、SQL、XML |
| V8 | 22 | 437 | SOAP・ESB・Queue Client、共通モデル、順序保持状態Repository、重複排除、再送Job、移行SQL、XML |
| V9 | 23 | 519 | 発生元別Mapper/Emitter、監査Repository、夜間集約、時刻相関、KYC Outbox永続化・再送、SQL、XML |
| V10 | 11 | 293 | 証拠評価Module、資産走査、影響検索、Version付きゴールデン比較、Java 21グラフ・レビューModel |

行数は品質そのものではなく、V1～V3に存在した複数の実行責務をV4以降でも実物として示せるかを確認する補助指標である。`test/check-source-inventory.ps1` がVersion別の資産数・行数下限を検査する。
