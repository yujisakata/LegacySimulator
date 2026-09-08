       01  RESULT-RECORD.
           05  RES-APP-NUMBER              PIC X(10).
           05  RES-RESULT-CODE             PIC X(02).
           05  RES-APPROVAL-CLASS          PIC X(01).
           05  RES-REASON-CODE             PIC X(03).
           05  RES-RESPONSIBILITY-DATE     PIC X(08).
           05  RES-PROCESS-DATE            PIC X(08).
           05  RES-RECEIPT-DATE            PIC X(08).
      *V2-001 DEL 05 RES-RESERVED          PIC X(40).
      *V2-001 ADD START - V1予約領域へ特約結果項目を追加。
           05  RES-AD-RESULT               PIC X(01).
           05  RES-AD-APPROVAL             PIC X(01).
           05  RES-AD-REASON               PIC X(03).
           05  RES-AD-AMOUNT               PIC X(08).
           05  RES-HI-RESULT               PIC X(01).
           05  RES-HI-APPROVAL             PIC X(01).
           05  RES-HI-REASON               PIC X(03).
           05  RES-HI-BENEFIT              PIC X(06).
           05  RES-V2-RESERVED             PIC X(16).
      *V2-001 ADD END.
