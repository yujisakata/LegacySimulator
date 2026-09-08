      * V4-ADD-003 告知制度対応の80文字入力レコード。
      * 旧制度回答と新制度回答を併存し、再査定を再現する。
       01  DISCLOSURE-RECORD.
           05  IN-APP-NUMBER              PIC X(10).
           05  IN-RECEIPT-DATE            PIC X(08).
           05  IN-DISCLOSURE-DATE         PIC X(08).
           05  IN-REDISCLOSURE-FLAG       PIC X(01).
               88  REDISCLOSURE                 VALUE "Y".
               88  NOT-REDISCLOSURE             VALUE "N".
           05  IN-OLD-ANSWER              PIC X(01).
           05  IN-NEW-ANSWER              PIC X(01).
           05  IN-RESERVED                PIC X(51).

