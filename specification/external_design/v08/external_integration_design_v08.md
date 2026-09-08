# V8 外部設計

共通中間形式は `partner`, `transactionId`, `status`, `payload`, `sequence` を持つ。通信方式は契約照会=`SOAP`、本人確認=`ESB`、代理店基盤=`QUEUE` とする。外部応答待ちは受付状態を保持し、成功時にだけCOBOL固定長生成へ進む。
