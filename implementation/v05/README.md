# V5 実装

V4までのCOBOL中核を維持し、固定長スナップショットから参照専用レコードを構築するJavaソースを追加した。Javaから契約原簿を更新するAPIやSQLは実装していない。

`java/com/legacysimulator/v05` は、Servlet、読取専用JDBC DAO、HTML応答、夜間取込を含む。Web照会はSELECTだけを使用し、夜間取込は照会用複製DBだけを全件入れ替える。Servlet APIを含む当時相当のアプリケーションサーバ依存関係が必要である。
