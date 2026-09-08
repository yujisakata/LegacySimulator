# V7 外部設計

要求コンテキストは `channel`（EMPLOYEE/AGENCY）、`operatorId`、`agencyId` を持つ。対象申込の `ownerAgencyId` と照合し、EMPLOYEEは許可、AGENCYは両代理店番号が一致する場合だけ許可する。

固定長位置はV6を維持し、予約領域26-27に既定値 `OF/AG`、28-37に代理店番号を追加する。
