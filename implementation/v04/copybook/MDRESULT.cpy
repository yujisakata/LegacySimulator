      * V3-001 医療系主契約の80文字査定結果レコード。
      *V4-001 DEL 41～80桁は空白とする。
       01  RESULT-RECORD.
           05  RES-APP-NUMBER              PIC X(10).
           05  RES-RESULT-CODE             PIC X(02).
           05  RES-APPROVAL-CLASS          PIC X(01).
           05  RES-REASON-CODE             PIC X(03).
           05  RES-RESPONSIBILITY-DATE     PIC X(08).
           05  RES-PROCESS-DATE            PIC X(08).
           05  RES-RECEIPT-DATE            PIC X(08).
      *V4-001 DEL 05 RES-RESERVED PIC X(40).
           05  RES-RESERVED                PIC X(24).

      *V4-001 ADD 65-75。制度と使用基準日を保存する。
           05  RES-REG-RULE                PIC X(3).
           05  RES-REG-DATE                PIC X(8).
           05  RES-V4-RESERVED             PIC X(5).
