# 新契約査定システム テスト成績書 (V2)

**文書ID:** DOC-VAL-V2-004  
**実施日:** 2026年8月22日  
**検証環境:** Windows Native、MSYS2 UCRT64、GnuCOBOL 3.2.0

## 結果

| 項目 | 結果 |
| :--- | :--- |
| NBASSESSコンパイル | 合格 |
| NBENTRYコンパイル | 合格 |
| V1主契約互換 | 19/19件合格 |
| V2代表ケース | 34/34件合格 |
| 合計完全一致 | 53/53件合格 |
| 入力件数 / 出力件数 | 53 / 53 |
| データエラー件数 | 10件、期待どおり |
| プログラム戻り値 | 0 |

データエラー10件は、V1互換の結果08が4件、V2の主契約結果08が2件、特約結果Eが4件である。いずれもケース上で意図した異常入力である。

## 実行証跡

```text
Reference fixtures verified: 19 V1 compatibility + 34 V2 cases.
NBASSESS INPUT : 0000053
NBASSESS OUTPUT: 0000053
NBASSESS ERROR : 0000010
V2 COBOL comparison passed: 53 records.
```

## 制約

本成績はGnuCOBOLによる教材検証結果である。実機EBCDIC、実機JCLおよび証券発行バッチとの結合は本番移行前確認へ引き継ぐ。

