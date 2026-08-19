# **物理ファイル・レコード仕様書**

**文書ID:** DOC-INT-005  

---

## **1. 物理ファイル情報**
* **ファイル物理名:** `/data/input/POL_APPLY.DAT`
* **ブロックサイズ / レコード長:** [FB / 200バイト]

## **2. 物理構造定義 (COBOL Copybook / C Structure)**
```cobol
01  APPLY-RECORD.
    05  APP-REC-TYPE       PIC X(02).
    05  APP-NO             PIC 9(10).
    05  APP-INSURED-NAME   PIC X(40).
    05  FILLER             PIC X(148).
```
