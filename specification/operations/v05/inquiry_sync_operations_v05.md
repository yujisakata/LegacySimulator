# V5 照会同期 運用手順

対象Version: V5<br>
想定読者: 取込・Web・COBOL運用担当

## 開始条件

COBOL運用が同一締めで確定した全量のAPPLICATION.DAT/ASSESSMENT.DAT/MEDICAL.DAT/MEDASSESS.DATを渡す。V4査定失敗時の部分出力は渡さない。日次差分ではない。結果未連携の申込は申込だけ含めてよい。番号の全社一意性を保つ。

照会DBは管理者がschemaを適用して作成する。WebはSELECTのみ、取込は両表のSELECT/INSERT/UPDATE/DELETEを持つ別ユーザー。取込環境変数V5_IMPORT_URL、V5_IMPORT_USER、V5_IMPORT_PASSWORDは配布先で設定する。ソースやログにパスワードを転記しない。

## 手順

1. V4全量ファイルの締め日と配布版を確認。
2. 実行ごとに別の出力ディレクトリを用意し、[run-inquiry-sync.ps1](../../../implementation/v05/jcl/run-inquiry-sync.ps1)へV4InputDirectory、SnapshotDirectory、AsOf、BusinessDateを指定。
3. Q5を生成し、マニフェストの基準日/件数/ハッシュを確認。
4. PUBLISHEDなら新世代公開、UNCHANGEDなら同一内容の再実行として終了。
5. 入力4ファイル、Q5、マニフェスト、モジュール版、終了ログを一組で保管。

## 異常と復旧

変換不正・件数不一致・ハッシュ不一致・古い基準日・同日別内容は公開しない。DB例外ではトランザクションを戻し、前回正常世代を維持する。エラーを無視して一部行だけ反映する運用はしない。

同日同内容なら再実行可能。同日の別内容への差替えは今回の通常手順には含めない。正式な次基準日の全量として再抽出する。故意に日付だけを書き換えて通さない。

画面の基準日が前回のままなら、COBOL査定の停止と即断しない。COBOL完了→抽出→転送→取込→Web接続の順に確認する。未公開503と、公開済みで番号なし404、結果未連携NULL表示を区別する。

## 記録の範囲

この手順は新規照会の運用を定義する。V4の例外判断の背景は[引継ぎメモ](inquiry_handoff_operations_v05.md)から参照し、未確認の業務背景を本手順で確定したことにはしない。
