# V10 外部設計

入力CSVは `edge_id,from_artifact,to_artifact,version,requirement_evidence,design_evidence,code_evidence,test_evidence,contradicted` を持つ。出力JSONは各エッジの `confidence`, `status`, `evidence` を返す。

- confidence = 要件×0.2 + 設計×0.2 + コード×0.3 + テスト×0.3
- 反証ありはconfidenceを0.5以下とする。
- 反証あり、またはconfidence 0.8未満は `PENDING`、それ以外は `APPROVED_CANDIDATE` とする。
