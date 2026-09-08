      * V3-001 医療系主契約の120文字申込レコード。
      * 61～68桁は商品コードに応じて保障額の意味を変える。
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
           05  APP-RESERVED                PIC X(46).

