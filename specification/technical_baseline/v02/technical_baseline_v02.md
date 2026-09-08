# 新契約査定システム 技術基準書 (V2)

**文書ID:** DOC-TEC-V2-001  
**基準:** [V1技術基準](../v01/technical_baseline_v01.md)

## 1. 継承事項

ANSI COBOL相当、固定形式、ファイル受渡し、120/80文字固定長、JCL相当というV1基準を継承する。RDB、可変長、共通ルールエンジンは導入しない。

## 2. V2追加基準

- ソースは72桁以内の固定形式とする。
- 変更番号 V2-001 とADD/DELコメントで改修箇所を追跡する。
- 置換前の実行行はDELコメントで保存する。
- COPY句の合計長を申込120、結果80で維持する。
- 教材検証はMSYS2 UCRT64のGnuCOBOL 3.2.0で行う。

## 3. 配置

| 区分 | 配置 |
| :--- | :--- |
| V2ソース | implementation/v02/ |
| V2検証補助 | test/v02/scripts/ |
| V2ケース | test/v02/cases/ |
| V2試験仕様・成績 | specification/validation_history/v02/ |

