      * V4-ADD-004 告知制度対応の40文字結果レコード。
      * 適用した基準日を出力し、新旧判定を後から説明可能にする。
       01  RESULT-RECORD.
           05  OUT-APP-NUMBER             PIC X(10).
           05  OUT-RULE-VERSION           PIC X(03).
               88  OLD-RULE-APPLIED             VALUE "OLD".
               88  NEW-RULE-APPLIED             VALUE "NEW".
               88  RULE-DATA-ERROR              VALUE "ERR".
           05  OUT-RESULT-CODE            PIC X(02).
           05  OUT-REASON-CODE            PIC X(03).
           05  OUT-APPLIED-DATE           PIC X(08).
           05  OUT-RESERVED               PIC X(14).

