# 新契約査定システム COBOL詳細設計書 (V2)

**文書ID:** DOC-INT-V2-001  
**上位文書:** [V2外部設計追補](../../external_design/v02/new_business_system_design_delta_v02.md)

## 1. 変更管理規約

変更番号 V2-001 を全V2 COBOL成果物で共通使用する。

```cobol
      *V2-001 DEL 旧行をコメントとして保存する
      *V2-001 ADD START
           追加処理
      *V2-001 ADD END
```

- 旧行を置き換える場合は、旧行をDELコメントとして残す。
- 追加範囲はADD STARTとADD ENDで囲む。
- 業務規則IDまたは要件IDを近接コメントへ記載する。
- V1版は編集せず、V2版を全量ソースとして管理する。

## 2. COPY句変更

V1の APP-RESERVED PIC X(46) と RES-RESERVED PIC X(40) をDELコメントで保存し、同じ合計長になる特約項目へ細分化する。レコード長と既存項目位置は変えない。

## 3. NBENTRY追加段落

| 段落 | 処理 | 要件 |
| :--- | :--- | :--- |
| 1000-ACCEPT-INPUT | V1入力後にAD・HI項目を受け付ける。 | FR-V2-001 |
| 2100-VALIDATE-AD-INPUT | コード・金額・決裁の基本整合を点検する。 | FR-V2-002 |
| 2200-VALIDATE-HI-INPUT | コード・日額・決裁の基本整合を点検する。 | FR-V2-002 |

申込なしの場合は金額をゼロへ正規化する。年齢、主契約額との比較、決裁経路の最終判断はNBASSESSを正とする。

## 4. NBASSESS追加段落

| 段落 | 処理 | 要件・規則 |
| :--- | :--- | :--- |
| 3800-PROCESS-RIDERS | 特約出力初期化と2特約の順次呼出し | FR-V2-006～008 |
| 3810-PROCESS-AD-RIDER | 申込有無、互換値、主契約結果を制御 | RDR-003, CMP-001 |
| 3820-ASSESS-AD-RIDER | 年齢、額、主契約比較、決裁を判定 | AD-001～005 |
| 3830-PROCESS-HI-RIDER | 申込有無、互換値、主契約結果を制御 | RDR-003, CMP-001 |
| 3840-ASSESS-HI-RIDER | 年齢、日額、決裁を判定 | HI-001～004 |
| 3850/3860 | 特約入力エラーを設定 | FR-V2-010 |

## 5. 特約判定擬似コード

```text
no-rider code and zero/blank amount and blank decision -> N/N/000
invalid code or inconsistent no-rider fields           -> E/N/COD
valid application and main result != 01               -> X/N/MNC
AD age outside 15..60                                 -> D/N/AGE
AD amount outside range/increment                     -> D/N/AMT
AD amount > main amount                               -> D/N/CMP
HI age outside 15..60                                 -> D/N/AGE
HI daily benefit not in 3000/5000/10000               -> D/N/AMT
primary route                                          -> A/U/000
secondary + blank/A/P/D decision                       -> R/A/P/D, class M
other decision                                         -> E/N/APR
```

## 6. エラー件数

V1の主契約結果08に加え、ADまたはHIがEのレコードをデータエラー件数へ加算する。同一レコードに複数のエラーがあっても件数は1件とする。

