# V9 実装

COBOL固定長、旧Springタブ区切り、Spring Boot JSONを共通監査イベントへ写像し、UTC正規化、JDBC保存、夜間集約、取引キー相関を行う。本人確認の独立リリースではOutboxを介し、共有DB保存後のメッセージ発行順を明示する。
