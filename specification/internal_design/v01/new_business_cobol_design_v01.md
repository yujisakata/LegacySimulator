# 新契約査定システム COBOL詳細設計書 (V1)

**文書ID:** DOC-INT-V1-001  
**対象Version:** V1（1980年）  
**上位文書:** [外部設計書](../../external_design/v01/new_business_system_design_v01.md)

## 1. プログラム構成

| プログラムID | ソース | 役割 | 入出力 |
| :--- | :--- | :--- | :--- |
| `PRG-V1-ONL-001` | `NBENTRY.cbl` | 文字端末から申込レコードを登録 | 端末→APPLICATION.DAT |
| `PRG-V1-BAT-001` | `NBASSESS.cbl` | 日次査定と結果ファイル作成 | APPLICATION.DAT→ASSESSMENT.DAT |
| `CPY-V1-001` | `NBAPPL.cpy` | 申込レコードの物理定義 | 120文字 |
| `CPY-V1-002` | `NBRESULT.cpy` | 査定結果レコードの物理定義 | 80文字 |

## 2. NBENTRY段落設計

| 段落 | 処理 |
| :--- | :--- |
| `1000-ACCEPT-INPUT` | 端末から全入力項目を受け付ける。 |
| `2000-VALIDATE-INPUT` | 商品WL、年齢15〜65、金額1〜5,000万円を点検する。 |
| `3000-WRITE-RECORD` | 予約領域を空白にし、APPLICATION.DATへ追記する。 |

オンライン処理は事務担当者の誤入力を早期に返すための基本点検だけを行う。日付整合性、期限、決裁経路は夜間処理を正とする。

## 3. NBASSESS段落設計

| 段落 | 処理 | 対応要件 |
| :--- | :--- | :--- |
| `0000-MAIN` | 初期化、読込ループ、終了処理 | NFR-V1-002 |
| `1000-INITIALIZE` | ファイルオープン、ステータス確認 | FR-V1-010 |
| `2000-READ-APPLICATION` | 1件読込、EOF設定 | FR-V1-010 |
| `3000-ASSESS-APPLICATION` | 結果初期化と優先順位制御 | FR-V1-002〜009 |
| `3100-VALIDATE-CODES` | 商品、フラグ、年齢、金額の検証 | FR-V1-002 |
| `3200-VALIDATE-DATES` | 必須日付、任意日付のGregorian検証 | FR-V1-002, 008 |
| `3300-PROCESS-DEFICIENCY` | 不備経過日数から04/05を決定 | FR-V1-003 |
| `3400-PROCESS-AUTHORITY` | 一次／二次決裁と最終結果を決定 | FR-V1-004〜006 |
| `3500-SET-RESPONSIBILITY` | 三要件の最大日を設定 | FR-V1-008, 009 |
| `3600-CONVERT-DATE` | 日付を通算日に変換 | FR-V1-003 |
| `4000-WRITE-RESULT` | 80文字の結果を出力し件数加算 | FR-V1-010 |
| `9000-FINALIZE` | クローズ、件数表示、戻り値設定 | NFR-V1-002 |

## 4. 判定擬似コード

```text
if withdrawal = Y                         -> 06/N/WDR
else if format or required code invalid   -> 08/N/(reason)
else if age outside 15..65                -> 08/N/AGE
else if product != WL                     -> 08/N/PRD
else if amount > 50,000,000               -> 03/N/AMT
else if documents = N and elapsed <= 30   -> 04/N/DEF
else if documents = N and elapsed >= 31   -> 05/N/EXP
else if any of three requirement dates=0  -> 09/N/REQ
else if amount > 20,000,000 or medical=M:
    decision blank                        -> 07/N/APR
    decision A                            -> 01/M/000
    decision P                            -> 02/M/MED
    decision D                            -> 03/M/MED
else                                      -> 01/U/000
```

## 5. データと定数

業務定数 `15`、`65`、`20000000`、`50000000`、`30` はNBASSESSのWORKING-STORAGEに一か所だけ定義し、業務ルールIDをコメントで付す。後続Versionでは、当該Versionの変更要求なしに値や配置を変更しない。

## 6. ファイル制御

- `APPLICATION.DAT`: INPUT、LINE SEQUENTIAL
- `ASSESSMENT.DAT`: OUTPUT、LINE SEQUENTIAL
- ファイルステータス00以外は運用メッセージを表示する。
- 結果ファイルはジョブ実行ごとに再作成する。
- 入力レコードと出力レコードは常に1対1とする。

## 7. 戻り値

| RETURN-CODE | 意味 |
| ---: | :--- |
| 0 | 正常完了。レコード単位のデータエラーを含み得る。 |
| 8 | 入出力件数不一致。 |
| 12 | ファイル入出力異常。 |

## 8. 意図的に採用しない設計

- RDBによる申込・結果管理
- 共通ルールエンジン
- オブジェクト指向、DI、Web UI
- 自動的な外部サービス照会
- 後続Versionを先取りした予約領域利用

これらはV1の技術制約と業務要求に対して不要であり、後世の利便性を理由に導入しない。
