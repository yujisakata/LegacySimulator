# V5 技術基準

対象Version: V5（2000年相当）<br>
想定読者: 開発・教材検証担当

[技術プロファイル](../../../technical_constraints/version_profiles.yml)に従い、COBOLの更新系とJava Servlet/JDBCの照会系を併存させる。Spring、ORM、原簿のJava更新、COBOL査定の置換は行わない。追加は夜間連携・参照DB・照会画面。

## 当時の設定と2026年の実行環境

2000年相当として再現するのは組織、手続き、責務、Servlet/JDBCによる構成、固定長連携。実行ソースの互換レベルはJava 8で、try-with-resourcesやNIOは2026年の検証環境での確実な入出力処理に使用する。2000年のJDKでそのままコンパイルできるという主張はしない。

現環境はJRE 8u421、ECJ 3.26.0、Tomcat embedded 9.0.121、H2 2.2.224、javax.annotation 1.3.2。Tomcat/H2は2026年の代替実行環境であり、当時の製品選定履歴ではない。実際のJDBCトランザクションとServletのHTTP動作を検証する。テストサーバは127.0.0.1の動的ポートで試験終了時に停止する。

公式仕様の確認先: [Tomcat 9のJava・Servlet対応](https://tomcat.apache.org/migration-9)、[H2公式リリース](https://github.com/h2database/h2database/releases)。取得したjarは[依存ロック](../../../test/v05/dependencies.lock.json)にURLとSHA-256を記録する。

大量データのスループット、本番の認証基盤、実メインフレーム文字コード変換、全支社接続は未検証。Q5の業務文字はASCIIに限定して曖昧な自動文字変換をしない。
