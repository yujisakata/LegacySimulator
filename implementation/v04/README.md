# V4 告知制度対応の実装

対象Version: V4・緊急補正後<br>
想定読者: 開発・検証担当

[最終要件](../../specification/requirements/v04/regulatory_additional_requirements_v04.md)を実装する。WLはV2のNBENTRY/NBASSESS、MI/CIはV3のMDENTRY/MDASSESSを局所変更して継承した。過去Versionのファイルは変更しない。

| 入力系統 | 受付 | 申込 | 査定 | 結果 |
|---|---|---|---|---|
| 終身・特約 | online/NBENTRY.cbl | APPLICATION.DAT | batch/NBASSESS.cbl | ASSESSMENT.DAT |
| 医療・がん | online/MDENTRY.cbl | MEDICAL.DAT | batch/MDASSESS.cbl | MEDASSESS.DAT |

両系統はREGDATE.DATを読む。雛形は[制度日マスタ](master/REGDATE.DAT)。申込は120文字、結果80文字で、追加項目は予約領域内に配置する。[COPY一覧](copybook/)と[レイアウト](../../specification/external_design/v04/regulatory_effective_date_design_v04.md)を参照する。

```powershell
.\test\v04\scripts\run-tests.ps1
```

上記はコンパイルして隔離一時ディレクトリで検証する。実際の入力ファイルを使う場合、作業ディレクトリにAPPLICATION.DAT、MEDICAL.DAT、REGDATE.DATを配置し、[実行ジョブ](jcl/run-job-v04.ps1)へ渡す。受付実行時もREGDATE.DATが必要で、COB_LS_FIXED=TRUEとGnuCOBOLのDLL検索パスを設定する。手入力端末の代替として標準入力を使う。

ソースのV4-001は制度対応、V4-002は再告知補正、V4-003は教材実行環境の入出力対応。最新ソースの3150には、施行前の設計追補にない再告知分岐が含まれる。[障害票](../../specification/validation_history/v04/incident_patch_note_v04.md)を併読する。

作業開始時に残っていた旧RG系8件のfixtureは、[旧fixtureの位置付け](../../test/v04/README.md)の通り参考資産として保存した。今回の配布は既存査定を継承したNB/MD系であり、RG系80文字入力・40文字出力とは別インターフェースである。
