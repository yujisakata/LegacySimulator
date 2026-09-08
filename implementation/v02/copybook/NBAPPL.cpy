       01  APPLICATION-RECORD.
           05  APP-NUMBER                  PIC X(10).
           05  APP-APPLICATION-DATE        PIC X(08).
           05  APP-DISCLOSURE-DATE         PIC X(08).
           05  APP-PREMIUM-DATE            PIC X(08).
           05  APP-RECEIPT-DATE            PIC X(08).
           05  APP-PROCESS-DATE            PIC X(08).
           05  APP-DEFICIENCY-DATE         PIC X(08).
           05  APP-AGE-TEXT                PIC X(02).
           05  APP-AMOUNT-TEXT             PIC X(08).
           05  APP-PRODUCT-CODE            PIC X(02).
           05  APP-DOCUMENT-COMPLETE       PIC X(01).
           05  APP-MEDICAL-CLASS           PIC X(01).
           05  APP-MANAGER-DECISION        PIC X(01).
           05  APP-WITHDRAWAL              PIC X(01).
      *V2-001 DEL 05 APP-RESERVED          PIC X(46).
      *V2-001 ADD START - V1予約領域へ特約入力項目を追加。
           05  APP-AD-CODE                 PIC X(02).
           05  APP-AD-AMOUNT-TEXT          PIC X(08).
           05  APP-AD-DECISION             PIC X(01).
           05  APP-HI-CODE                 PIC X(02).
           05  APP-HI-BENEFIT-TEXT         PIC X(06).
           05  APP-HI-DECISION             PIC X(01).
           05  APP-V2-RESERVED             PIC X(26).
      *V2-001 ADD END.
