       IDENTIFICATION DIVISION.
      *V3-001 DEL PROGRAM-ID. NBASSESS.
       PROGRAM-ID. MDASSESS.
      *V3-001 DEL AUTHOR. V1-NEW-BUSINESS-TEAM.
       AUTHOR. V3-MEDICAL-PRODUCT-TEAM.
      *
      * 変更履歴
      * V3-001 1990-04-01 医療保険・がん保険査定を追加。
      * 置換前の実行行はDELコメントとして保存する。
      *
      *V3-001 DEL V1夜間新契約査定処理。
      * V3医療系主契約の夜間査定処理。
      * 業務ルール: BR-V3-COM/MI/CI。
      *
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT REGULATION-FILE ASSIGN TO "REGDATE.DAT"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-REG-STATUS.

           SELECT APPLICATION-FILE
      *V3-001 DEL     ASSIGN TO "APPLICATION.DAT"
               ASSIGN TO "MEDICAL.DAT"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-APPLICATION-STATUS.
           SELECT RESULT-FILE
      *V3-001 DEL     ASSIGN TO "ASSESSMENT.DAT"
               ASSIGN TO "MEDASSESS.DAT"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-RESULT-STATUS.

       DATA DIVISION.
       FILE SECTION.
      *V4-001 ADD 物理レコード長を検証する。
       FD  APPLICATION-FILE
           RECORD VARYING FROM 1 TO 4096 CHARACTERS
           DEPENDING ON WS-INPUT-LENGTH.
      *V3-001 DEL COPY "NBAPPL.cpy".
       01  INPUT-BUFFER                    PIC X(4096).

       FD  RESULT-FILE
           RECORD CONTAINS 80 CHARACTERS.
      *V3-001 DEL COPY "NBRESULT.cpy".
           COPY "MDRESULT.cpy".

       FD  REGULATION-FILE
           RECORD VARYING FROM 1 TO 256 CHARACTERS
           DEPENDING ON WS-REG-LENGTH.
       01  REGULATION-RECORD               PIC X(256).

       WORKING-STORAGE SECTION.
           COPY "MDAPPL.cpy".
      *V4-001 ADD 制度日マスタと制度選択作業域。
       01  WS-REG-STATUS                   PIC XX.
       01  WS-REG-LENGTH                   PIC 9(4) COMP.
       01  WS-EFFECTIVE-DATE               PIC X(8).
       01  WS-REG-DATE                     PIC X(8).
       01  WS-REG-RULE                     PIC X(3).
       01  WS-REG-ANSWER                   PIC X.
       01  WS-REG-ERROR                    PIC X.
       01  WS-INPUT-LENGTH                 PIC 9(4) COMP.

       01  WS-FILE-STATUS.
           05  WS-APPLICATION-STATUS       PIC XX VALUE SPACES.
           05  WS-RESULT-STATUS            PIC XX VALUE SPACES.

       01  WS-SWITCHES.
           05  WS-END-OF-FILE              PIC X VALUE "N".
               88  END-OF-FILE                   VALUE "Y".
           05  WS-RECORD-ERROR             PIC X VALUE "N".
               88  RECORD-ERROR                  VALUE "Y".
           05  WS-FATAL-FLAG               PIC X VALUE "N".
               88  FATAL-ERROR                   VALUE "Y".
           05  WS-APPLICATION-OPEN         PIC X VALUE "N".
           05  WS-RESULT-OPEN              PIC X VALUE "N".
           05  WS-DATE-VALID               PIC X VALUE "N".
               88  DATE-IS-VALID                 VALUE "Y".
           05  WS-LEAP-YEAR                PIC X VALUE "N".

       01  WS-COUNTERS.
           05  WS-INPUT-COUNT              PIC 9(7) VALUE ZERO.
           05  WS-OUTPUT-COUNT             PIC 9(7) VALUE ZERO.
           05  WS-ERROR-COUNT              PIC 9(7) VALUE ZERO.

       01  WS-BUSINESS-CONSTANTS.
      *V3-001 DEL BR-V1-AGE-001 終身保険の年齢定数。
      *V3-001 DEL 05 WS-MINIMUM-AGE PIC 99 VALUE 15.
      *V3-001 DEL 05 WS-MAXIMUM-AGE PIC 99 VALUE 65.
      *V3-001 DEL BR-V1-AUT-001/002 終身保険の決裁境界。
      *V3-001 DEL 05 WS-PRIMARY-LIMIT PIC 9(8) VALUE 20000000.
      *V3-001 DEL BR-V1-AMT-001 終身保険の上限額。
      *V3-001 DEL 05 WS-MAXIMUM-AMOUNT PIC 9(8) VALUE 50000000.
      *V3-001 ADD START - 医療系商品の年齢・決裁定数。
           05  WS-MI-MINIMUM-AGE           PIC 99 VALUE 00.
           05  WS-MI-MAXIMUM-AGE           PIC 99 VALUE 70.
           05  WS-CI-MINIMUM-AGE           PIC 99 VALUE 20.
           05  WS-CI-MAXIMUM-AGE           PIC 99 VALUE 65.
           05  WS-MI-SECONDARY-AMOUNT      PIC 9(8)
                                               VALUE 00010000.
           05  WS-CI-SECONDARY-AMOUNT      PIC 9(8)
                                               VALUE 03000000.
      *V3-001 ADD END.
      *    BR-V1-DEF-001
           05  WS-DEFICIENCY-LIMIT         PIC 99 VALUE 30.

       01  WS-NUMERIC-FIELDS.
           05  WS-AGE                      PIC 99 VALUE ZERO.
           05  WS-AMOUNT                   PIC 9(8) VALUE ZERO.
           05  WS-ELAPSED-DAYS             PIC S9(9) VALUE ZERO.
           05  WS-PROCESS-SERIAL           PIC 9(9) VALUE ZERO.
           05  WS-DEFICIENCY-SERIAL        PIC 9(9) VALUE ZERO.

       01  WS-DATE-AREA.
           05  WS-DATE-IN                  PIC X(8) VALUE SPACES.
           05  WS-DATE-PARTS REDEFINES WS-DATE-IN.
               10  WS-YEAR-TEXT            PIC X(4).
               10  WS-MONTH-TEXT           PIC X(2).
               10  WS-DAY-TEXT             PIC X(2).
           05  WS-YEAR                     PIC 9(4) VALUE ZERO.
           05  WS-MONTH                    PIC 99 VALUE ZERO.
           05  WS-DAY                      PIC 99 VALUE ZERO.
           05  WS-MAX-DAY                  PIC 99 VALUE ZERO.
           05  WS-TEMP-YEAR                PIC 9(4) VALUE ZERO.
           05  WS-Q4                       PIC 9(4) VALUE ZERO.
           05  WS-Q100                     PIC 9(4) VALUE ZERO.
           05  WS-Q400                     PIC 9(4) VALUE ZERO.
           05  WS-QUOTIENT                 PIC 9(4) VALUE ZERO.
           05  WS-REMAINDER                PIC 9(4) VALUE ZERO.
           05  WS-DATE-SERIAL              PIC 9(9) VALUE ZERO.
           05  WS-MONTH-INDEX              PIC 99 VALUE ZERO.
           05  WS-MONTH-DATA               PIC X(24)
               VALUE "312831303130313130313031".
           05  WS-MONTH-TABLE REDEFINES WS-MONTH-DATA.
               10  WS-DAYS-IN-MONTH        PIC 99 OCCURS 12 TIMES.

       PROCEDURE DIVISION.
       0000-MAIN.
      *V4-001 ADD 配布済みマスタを読み込む。
           PERFORM 1100-LOAD-REGULATION
           PERFORM 1000-INITIALIZE
           IF NOT FATAL-ERROR
               PERFORM 2000-READ-APPLICATION
               PERFORM UNTIL END-OF-FILE OR FATAL-ERROR
                   PERFORM 3000-ASSESS-APPLICATION
                   PERFORM 4000-WRITE-RESULT
                   IF NOT FATAL-ERROR
                       PERFORM 2000-READ-APPLICATION
                   END-IF
               END-PERFORM
           END-IF
           PERFORM 9000-FINALIZE
           STOP RUN.

       1000-INITIALIZE.
           OPEN INPUT APPLICATION-FILE
           IF WS-APPLICATION-STATUS NOT = "00"
               DISPLAY "MDASSESS: INPUT OPEN ERROR "
                   WS-APPLICATION-STATUS
               MOVE "Y" TO WS-FATAL-FLAG
               MOVE 12 TO RETURN-CODE
           ELSE
               MOVE "Y" TO WS-APPLICATION-OPEN
           END-IF

           IF NOT FATAL-ERROR
               OPEN OUTPUT RESULT-FILE
               IF WS-RESULT-STATUS NOT = "00"
                   DISPLAY "MDASSESS: OUTPUT OPEN ERROR "
                       WS-RESULT-STATUS
                   MOVE "Y" TO WS-FATAL-FLAG
                   MOVE 12 TO RETURN-CODE
               ELSE
                   MOVE "Y" TO WS-RESULT-OPEN
               END-IF
           END-IF.

       2000-READ-APPLICATION.
           READ APPLICATION-FILE
               AT END
                   MOVE "Y" TO WS-END-OF-FILE
               NOT AT END
                   ADD 1 TO WS-INPUT-COUNT
      *V4-001 ADD 短い行・長い行を受け付けない。
                   IF WS-INPUT-LENGTH NOT = 120
                       MOVE "Y" TO WS-FATAL-FLAG
                       MOVE 12 TO RETURN-CODE
                   ELSE
                       MOVE INPUT-BUFFER(1:120)
                           TO APPLICATION-RECORD
                   END-IF
           END-READ
           IF WS-APPLICATION-STATUS NOT = "00"
               AND WS-APPLICATION-STATUS NOT = "10"
               DISPLAY "MDASSESS: INPUT READ ERROR "
                   WS-APPLICATION-STATUS
               MOVE "Y" TO WS-FATAL-FLAG
               MOVE 12 TO RETURN-CODE
           END-IF.

       3000-ASSESS-APPLICATION.
           INITIALIZE RESULT-RECORD
           MOVE "00000000" TO RES-RESPONSIBILITY-DATE
           MOVE APP-NUMBER       TO RES-APP-NUMBER
           MOVE APP-PROCESS-DATE TO RES-PROCESS-DATE
           MOVE APP-RECEIPT-DATE TO RES-RECEIPT-DATE
           MOVE "N" TO WS-RECORD-ERROR

      *    BR-V1-WDR-001: 顧客による取下げを優先する。
           IF APP-WITHDRAWAL = "Y"
               MOVE "06"  TO RES-RESULT-CODE
               MOVE "N"   TO RES-APPROVAL-CLASS
               MOVE "WDR" TO RES-REASON-CODE
           ELSE
               PERFORM 3100-VALIDATE-CODES
               IF NOT RECORD-ERROR
                   PERFORM 3200-VALIDATE-DATES
               END-IF
               IF NOT RECORD-ERROR
      *V4-001 ADD 制度入力を点検してから業務査定する。
                   PERFORM 3150-SELECT-REGULATION
                   MOVE WS-REG-RULE TO RES-REG-RULE
                   MOVE WS-REG-DATE TO RES-REG-DATE
                   IF WS-REG-ERROR = "Y"
                       PERFORM 3900-SET-DATA-ERROR
                   ELSE
                       PERFORM 3250-APPLY-BUSINESS-RULES
                   END-IF
               END-IF
           END-IF.

       3100-VALIDATE-CODES.
           IF APP-NUMBER IS NOT NUMERIC
               PERFORM 3900-SET-DATA-ERROR
           END-IF

           IF NOT RECORD-ERROR
      *V3-001 DEL IF APP-PRODUCT-CODE NOT = "WL"
      *V3-001 ADD START - BR-V3-COM-004 商品コード点検。
               IF APP-PRODUCT-CODE NOT = "MI"
                   AND APP-PRODUCT-CODE NOT = "CI"
      *V3-001 ADD END
                   MOVE "Y" TO WS-RECORD-ERROR
                   MOVE "08"  TO RES-RESULT-CODE
                   MOVE "N"   TO RES-APPROVAL-CLASS
                   MOVE "PRD" TO RES-REASON-CODE
               END-IF
           END-IF

           IF NOT RECORD-ERROR
               IF APP-AGE-TEXT IS NUMERIC
                   MOVE APP-AGE-TEXT TO WS-AGE
      *V3-001 DEL IF WS-AGE < WS-MINIMUM-AGE
      *V3-001 DEL     OR WS-AGE > WS-MAXIMUM-AGE
      *V3-001 ADD START - BR-V3-MI-001/CI-001 年齢条件。
                   IF (APP-PRODUCT-CODE = "MI"
                       AND (WS-AGE < WS-MI-MINIMUM-AGE
                       OR WS-AGE > WS-MI-MAXIMUM-AGE))
                       OR (APP-PRODUCT-CODE = "CI"
                       AND (WS-AGE < WS-CI-MINIMUM-AGE
                       OR WS-AGE > WS-CI-MAXIMUM-AGE))
      *V3-001 ADD END
                       MOVE "Y" TO WS-RECORD-ERROR
                       MOVE "08"  TO RES-RESULT-CODE
                       MOVE "N"   TO RES-APPROVAL-CLASS
                       MOVE "AGE" TO RES-REASON-CODE
                   END-IF
               ELSE
                   MOVE "Y" TO WS-RECORD-ERROR
                   MOVE "08"  TO RES-RESULT-CODE
                   MOVE "N"   TO RES-APPROVAL-CLASS
                   MOVE "AGE" TO RES-REASON-CODE
               END-IF
           END-IF

           IF NOT RECORD-ERROR
               IF APP-AMOUNT-TEXT IS NUMERIC
                   MOVE APP-AMOUNT-TEXT TO WS-AMOUNT
                   IF WS-AMOUNT = ZERO
                       MOVE "Y" TO WS-RECORD-ERROR
                       MOVE "08"  TO RES-RESULT-CODE
                       MOVE "N"   TO RES-APPROVAL-CLASS
                       MOVE "AMT" TO RES-REASON-CODE
                   END-IF
               ELSE
                   MOVE "Y" TO WS-RECORD-ERROR
                   MOVE "08"  TO RES-RESULT-CODE
                   MOVE "N"   TO RES-APPROVAL-CLASS
                   MOVE "AMT" TO RES-REASON-CODE
               END-IF
           END-IF

           IF NOT RECORD-ERROR
               IF APP-DOCUMENT-COMPLETE NOT = "Y"
                   AND APP-DOCUMENT-COMPLETE NOT = "N"
                   PERFORM 3900-SET-DATA-ERROR
               END-IF
           END-IF

           IF NOT RECORD-ERROR
               IF APP-MEDICAL-CLASS NOT = "S"
                   AND APP-MEDICAL-CLASS NOT = "M"
                   PERFORM 3900-SET-DATA-ERROR
               END-IF
           END-IF

           IF NOT RECORD-ERROR
               IF APP-MANAGER-DECISION NOT = SPACE
                   AND APP-MANAGER-DECISION NOT = "A"
                   AND APP-MANAGER-DECISION NOT = "P"
                   AND APP-MANAGER-DECISION NOT = "D"
                   PERFORM 3900-SET-DATA-ERROR
               END-IF
           END-IF

           IF NOT RECORD-ERROR
               IF APP-WITHDRAWAL NOT = "N"
                   PERFORM 3900-SET-DATA-ERROR
               END-IF
           END-IF
      *V3-001 ADD START - FR-V3-006 予約領域は空白必須。
           IF NOT RECORD-ERROR
               IF APP-RESERVED NOT = SPACES
                   OR APP-V4-RESERVED NOT = SPACES
                   MOVE "Y"   TO WS-RECORD-ERROR
                   MOVE "08"  TO RES-RESULT-CODE
                   MOVE "N"   TO RES-APPROVAL-CLASS
                   MOVE "RDR" TO RES-REASON-CODE
               END-IF
           END-IF.
      *V3-001 ADD END.

       3200-VALIDATE-DATES.
           MOVE APP-APPLICATION-DATE TO WS-DATE-IN
           PERFORM 3600-CONVERT-DATE
           IF NOT DATE-IS-VALID
               PERFORM 3900-SET-DATA-ERROR
           END-IF

           IF NOT RECORD-ERROR
               IF APP-DISCLOSURE-DATE NOT = "00000000"
                   MOVE APP-DISCLOSURE-DATE TO WS-DATE-IN
                   PERFORM 3600-CONVERT-DATE
                   IF NOT DATE-IS-VALID
                       PERFORM 3900-SET-DATA-ERROR
                   END-IF
               END-IF
           END-IF

           IF NOT RECORD-ERROR
               MOVE APP-RECEIPT-DATE TO WS-DATE-IN
               PERFORM 3600-CONVERT-DATE
               IF NOT DATE-IS-VALID
                   PERFORM 3900-SET-DATA-ERROR
               END-IF
           END-IF

           IF NOT RECORD-ERROR
               MOVE APP-PROCESS-DATE TO WS-DATE-IN
               PERFORM 3600-CONVERT-DATE
               IF DATE-IS-VALID
                   MOVE WS-DATE-SERIAL TO WS-PROCESS-SERIAL
               ELSE
                   PERFORM 3900-SET-DATA-ERROR
               END-IF
           END-IF

           IF NOT RECORD-ERROR
               IF APP-PREMIUM-DATE NOT = "00000000"
                   MOVE APP-PREMIUM-DATE TO WS-DATE-IN
                   PERFORM 3600-CONVERT-DATE
                   IF NOT DATE-IS-VALID
                       PERFORM 3900-SET-DATA-ERROR
                   END-IF
               END-IF
           END-IF

           IF NOT RECORD-ERROR
               IF APP-DOCUMENT-COMPLETE = "N"
                   MOVE APP-DEFICIENCY-DATE TO WS-DATE-IN
                   PERFORM 3600-CONVERT-DATE
                   IF DATE-IS-VALID
                       MOVE WS-DATE-SERIAL
                           TO WS-DEFICIENCY-SERIAL
                       IF WS-PROCESS-SERIAL < WS-DEFICIENCY-SERIAL
                           PERFORM 3900-SET-DATA-ERROR
                       END-IF
                   ELSE
                       PERFORM 3900-SET-DATA-ERROR
                   END-IF
               END-IF
           END-IF.

       3250-APPLY-BUSINESS-RULES.
      *V3-001 DEL BR-V1-AMT-001 死亡保険金額上限。
      *V3-001 DEL IF WS-AMOUNT > WS-MAXIMUM-AMOUNT
      *V3-001 ADD START - BR-V3-MI-002/CI-002 保障額条件。
           IF (APP-PRODUCT-CODE = "MI"
               AND WS-AMOUNT NOT = 00003000
               AND WS-AMOUNT NOT = 00005000
               AND WS-AMOUNT NOT = 00010000)
               OR (APP-PRODUCT-CODE = "CI"
               AND WS-AMOUNT NOT = 01000000
               AND WS-AMOUNT NOT = 02000000
               AND WS-AMOUNT NOT = 03000000)
      *V3-001 ADD END
               MOVE "03"  TO RES-RESULT-CODE
               MOVE "N"   TO RES-APPROVAL-CLASS
               MOVE "AMT" TO RES-REASON-CODE
           ELSE
               IF APP-DOCUMENT-COMPLETE = "N"
                   PERFORM 3300-PROCESS-DEFICIENCY
               ELSE
                   PERFORM 3500-CHECK-THREE-REQUIREMENTS
                   IF RES-RESULT-CODE NOT = "09"
      *V4-001 DEL PERFORM 3400-PROCESS-AUTHORITY
                       PERFORM 3350-PROCESS-DISCLOSURE
                   END-IF
               END-IF
           END-IF.

       3300-PROCESS-DEFICIENCY.
      *    BR-V1-DEF-001
           COMPUTE WS-ELAPSED-DAYS =
               WS-PROCESS-SERIAL - WS-DEFICIENCY-SERIAL
           IF WS-ELAPSED-DAYS <= WS-DEFICIENCY-LIMIT
               MOVE "04"  TO RES-RESULT-CODE
               MOVE "N"   TO RES-APPROVAL-CLASS
               MOVE "DEF" TO RES-REASON-CODE
           ELSE
               MOVE "05"  TO RES-RESULT-CODE
               MOVE "N"   TO RES-APPROVAL-CLASS
               MOVE "EXP" TO RES-REASON-CODE
           END-IF.

       3400-PROCESS-AUTHORITY.
      *V3-001 DEL BR-V1-AUT-001/002 終身保険の決裁境界。
      *V3-001 DEL IF WS-AMOUNT > WS-PRIMARY-LIMIT
      *V3-001 DEL     OR APP-MEDICAL-CLASS = "M"
      *V3-001 ADD START - BR-V3-MI-003/004、CI-003/004。
           IF APP-MEDICAL-CLASS = "M"
               OR (APP-PRODUCT-CODE = "MI"
               AND WS-AMOUNT = WS-MI-SECONDARY-AMOUNT)
               OR (APP-PRODUCT-CODE = "CI"
               AND WS-AMOUNT = WS-CI-SECONDARY-AMOUNT)
      *V3-001 ADD END
               EVALUATE APP-MANAGER-DECISION
                   WHEN "A"
                       MOVE "01"  TO RES-RESULT-CODE
                       MOVE "M"   TO RES-APPROVAL-CLASS
                       MOVE "000" TO RES-REASON-CODE
                       PERFORM 3550-SET-RESPONSIBILITY
                   WHEN "P"
                       MOVE "02"  TO RES-RESULT-CODE
                       MOVE "M"   TO RES-APPROVAL-CLASS
                       MOVE "MED" TO RES-REASON-CODE
                   WHEN "D"
                       MOVE "03"  TO RES-RESULT-CODE
                       MOVE "M"   TO RES-APPROVAL-CLASS
                       MOVE "MED" TO RES-REASON-CODE
                   WHEN OTHER
                       MOVE "07"  TO RES-RESULT-CODE
                       MOVE "N"   TO RES-APPROVAL-CLASS
                       MOVE "APR" TO RES-REASON-CODE
               END-EVALUATE
           ELSE
               MOVE "01"  TO RES-RESULT-CODE
               MOVE "U"   TO RES-APPROVAL-CLASS
               MOVE "000" TO RES-REASON-CODE
               PERFORM 3550-SET-RESPONSIBILITY
           END-IF.

       3500-CHECK-THREE-REQUIREMENTS.
      *    BR-V1-RES-001
           IF APP-APPLICATION-DATE = "00000000"
               OR APP-DISCLOSURE-DATE = "00000000"
               OR APP-PREMIUM-DATE = "00000000"
               MOVE "09"  TO RES-RESULT-CODE
               MOVE "N"   TO RES-APPROVAL-CLASS
               MOVE "REQ" TO RES-REASON-CODE
           END-IF.

       3550-SET-RESPONSIBILITY.
      *    BR-V1-RES-001: 申込日・告知日・第1回保険料領収日の
      *    最も遅い日を責任開始日とする。
           MOVE APP-APPLICATION-DATE
               TO RES-RESPONSIBILITY-DATE
           IF APP-DISCLOSURE-DATE > RES-RESPONSIBILITY-DATE
               MOVE APP-DISCLOSURE-DATE
                   TO RES-RESPONSIBILITY-DATE
           END-IF
           IF APP-PREMIUM-DATE > RES-RESPONSIBILITY-DATE
               MOVE APP-PREMIUM-DATE
                   TO RES-RESPONSIBILITY-DATE
           END-IF.

       3600-CONVERT-DATE.
           MOVE "N" TO WS-DATE-VALID
           MOVE ZERO TO WS-DATE-SERIAL WS-YEAR WS-MONTH WS-DAY
           IF WS-DATE-IN IS NUMERIC
               AND WS-DATE-IN NOT = "00000000"
               MOVE WS-YEAR-TEXT  TO WS-YEAR
               MOVE WS-MONTH-TEXT TO WS-MONTH
               MOVE WS-DAY-TEXT   TO WS-DAY
               IF WS-YEAR >= 1900 AND WS-YEAR <= 2099
                   AND WS-MONTH >= 1 AND WS-MONTH <= 12
                   MOVE WS-DAYS-IN-MONTH(WS-MONTH)
                       TO WS-MAX-DAY
                   PERFORM 3650-CHECK-LEAP-YEAR
                   IF WS-MONTH = 2 AND WS-LEAP-YEAR = "Y"
                       ADD 1 TO WS-MAX-DAY
                   END-IF
                   IF WS-DAY >= 1 AND WS-DAY <= WS-MAX-DAY
                       PERFORM 3700-CALCULATE-SERIAL
                       MOVE "Y" TO WS-DATE-VALID
                   END-IF
               END-IF
           END-IF.

       3650-CHECK-LEAP-YEAR.
           MOVE "N" TO WS-LEAP-YEAR
           DIVIDE WS-YEAR BY 4 GIVING WS-QUOTIENT
               REMAINDER WS-REMAINDER
           IF WS-REMAINDER = ZERO
               MOVE "Y" TO WS-LEAP-YEAR
               DIVIDE WS-YEAR BY 100 GIVING WS-QUOTIENT
                   REMAINDER WS-REMAINDER
               IF WS-REMAINDER = ZERO
                   MOVE "N" TO WS-LEAP-YEAR
                   DIVIDE WS-YEAR BY 400 GIVING WS-QUOTIENT
                       REMAINDER WS-REMAINDER
                   IF WS-REMAINDER = ZERO
                       MOVE "Y" TO WS-LEAP-YEAR
                   END-IF
               END-IF
           END-IF.

       3700-CALCULATE-SERIAL.
           COMPUTE WS-TEMP-YEAR = WS-YEAR - 1
           DIVIDE WS-TEMP-YEAR BY 4 GIVING WS-Q4
               REMAINDER WS-REMAINDER
           DIVIDE WS-TEMP-YEAR BY 100 GIVING WS-Q100
               REMAINDER WS-REMAINDER
           DIVIDE WS-TEMP-YEAR BY 400 GIVING WS-Q400
               REMAINDER WS-REMAINDER
           COMPUTE WS-DATE-SERIAL =
               (WS-TEMP-YEAR * 365) + WS-Q4 - WS-Q100
               + WS-Q400 + WS-DAY
           PERFORM VARYING WS-MONTH-INDEX FROM 1 BY 1
               UNTIL WS-MONTH-INDEX >= WS-MONTH
               ADD WS-DAYS-IN-MONTH(WS-MONTH-INDEX)
                   TO WS-DATE-SERIAL
           END-PERFORM
           IF WS-MONTH > 2 AND WS-LEAP-YEAR = "Y"
               ADD 1 TO WS-DATE-SERIAL
           END-IF.

      *V4-001 ADD マスタ不正時は業務ファイルを開かない。
       1100-LOAD-REGULATION.
           OPEN INPUT REGULATION-FILE
           IF WS-REG-STATUS NOT = "00"
               DISPLAY "REGULATION MASTER OPEN ERROR"
               MOVE 12 TO RETURN-CODE
               STOP RUN
           END-IF
           READ REGULATION-FILE
           IF WS-REG-STATUS NOT = "00" OR WS-REG-LENGTH NOT = 8
               CLOSE REGULATION-FILE
               DISPLAY "REGULATION MASTER RECORD ERROR"
               MOVE 12 TO RETURN-CODE
               STOP RUN
           END-IF
           MOVE REGULATION-RECORD(1:8) TO WS-EFFECTIVE-DATE
           MOVE WS-EFFECTIVE-DATE TO WS-DATE-IN
           PERFORM 3600-CONVERT-DATE
           IF NOT DATE-IS-VALID
               CLOSE REGULATION-FILE
               DISPLAY "REGULATION MASTER DATE ERROR"
               MOVE 12 TO RETURN-CODE
               STOP RUN
           END-IF
           READ REGULATION-FILE
           IF WS-REG-STATUS NOT = "10"
               CLOSE REGULATION-FILE
               DISPLAY "REGULATION MASTER EXTRA RECORD"
               MOVE 12 TO RETURN-CODE
               STOP RUN
           END-IF
           CLOSE REGULATION-FILE
           IF WS-REG-STATUS NOT = "00"
               MOVE 12 TO RETURN-CODE
               STOP RUN
           END-IF.

      *V4-001 ADD 受付日を用いた新旧選択。
       3150-SELECT-REGULATION.
           MOVE "N" TO WS-REG-ERROR
           MOVE "ERR" TO WS-REG-RULE
           MOVE "00000000" TO WS-REG-DATE
           MOVE SPACE TO WS-REG-ANSWER
           MOVE APP-RECEIPT-DATE TO WS-DATE-IN
           PERFORM 3600-CONVERT-DATE
           IF NOT DATE-IS-VALID
               MOVE "Y" TO WS-REG-ERROR
           END-IF
           IF APP-REDISCLOSURE NOT = SPACE AND "N" AND "Y"
               MOVE "Y" TO WS-REG-ERROR
           END-IF
           IF APP-OLD-ANSWER NOT = SPACE AND "N" AND "Y"
               MOVE "Y" TO WS-REG-ERROR
           END-IF
           IF APP-NEW-ANSWER NOT = SPACE AND "N" AND "Y"
               MOVE "Y" TO WS-REG-ERROR
           END-IF
           IF WS-REG-ERROR = "N"
               MOVE APP-RECEIPT-DATE TO WS-REG-DATE
      *V4-002 ADD 障害票INC-V4-001の対象分岐。
               IF APP-REDISCLOSURE = "Y"
                   MOVE APP-DISCLOSURE-DATE TO WS-DATE-IN
                   PERFORM 3600-CONVERT-DATE
                   IF DATE-IS-VALID
                       MOVE APP-DISCLOSURE-DATE TO WS-REG-DATE
                   ELSE
                       MOVE "Y" TO WS-REG-ERROR
                   END-IF
               END-IF
      *V4-002 ADD END.
               IF WS-REG-DATE < WS-EFFECTIVE-DATE
                   MOVE "OLD" TO WS-REG-RULE
                   MOVE APP-OLD-ANSWER TO WS-REG-ANSWER
                   IF APP-REGULATION-DATA = SPACES
                       MOVE "N" TO WS-REG-ANSWER
                   END-IF
               ELSE
                   MOVE "NEW" TO WS-REG-RULE
                   MOVE APP-NEW-ANSWER TO WS-REG-ANSWER
               END-IF
               IF WS-REG-ANSWER NOT = "N" AND "Y"
                   MOVE "Y" TO WS-REG-ERROR
               END-IF
           END-IF
           IF WS-REG-ERROR = "Y"
               MOVE "ERR" TO WS-REG-RULE
               MOVE "00000000" TO WS-REG-DATE
           END-IF.

      *V4-001 ADD 新旧段落を残し、選択制度で呼び分ける。
       3350-PROCESS-DISCLOSURE.
           IF WS-REG-RULE = "OLD"
               PERFORM 3360-OLD-DISCLOSURE
           ELSE
               PERFORM 3370-NEW-DISCLOSURE
           END-IF.
       3360-OLD-DISCLOSURE.
           IF WS-REG-ANSWER = "Y"
               MOVE "03" TO RES-RESULT-CODE
               MOVE "N" TO RES-APPROVAL-CLASS
               MOVE "OLD" TO RES-REASON-CODE
           ELSE
               PERFORM 3400-PROCESS-AUTHORITY
           END-IF.
       3370-NEW-DISCLOSURE.
           IF WS-REG-ANSWER = "Y"
               MOVE "03" TO RES-RESULT-CODE
               MOVE "N" TO RES-APPROVAL-CLASS
               MOVE "NEW" TO RES-REASON-CODE
           ELSE
               PERFORM 3400-PROCESS-AUTHORITY
           END-IF.

       3900-SET-DATA-ERROR.
           MOVE "Y"   TO WS-RECORD-ERROR
           MOVE "08"  TO RES-RESULT-CODE
           MOVE "N"   TO RES-APPROVAL-CLASS
           MOVE "DAT" TO RES-REASON-CODE.

       4000-WRITE-RESULT.
           WRITE RESULT-RECORD
           IF WS-RESULT-STATUS = "00"
               ADD 1 TO WS-OUTPUT-COUNT
               IF RES-RESULT-CODE = "08"
                   ADD 1 TO WS-ERROR-COUNT
               END-IF
           ELSE
               DISPLAY "MDASSESS: OUTPUT WRITE ERROR "
                   WS-RESULT-STATUS
               MOVE "Y" TO WS-FATAL-FLAG
               MOVE 12 TO RETURN-CODE
           END-IF.

       9000-FINALIZE.
           IF WS-APPLICATION-OPEN = "Y"
               CLOSE APPLICATION-FILE
      *V4-003 ADD 終了時の入出力異常を検出する。
               IF WS-APPLICATION-STATUS NOT = "00"
                   MOVE "Y" TO WS-FATAL-FLAG
                   MOVE 12 TO RETURN-CODE
               END-IF
           END-IF
           IF WS-RESULT-OPEN = "Y"
               CLOSE RESULT-FILE
      *V4-003 ADD 終了時の入出力異常を検出する。
               IF WS-RESULT-STATUS NOT = "00"
                   MOVE "Y" TO WS-FATAL-FLAG
                   MOVE 12 TO RETURN-CODE
               END-IF
           END-IF

           DISPLAY "MDASSESS INPUT : " WS-INPUT-COUNT
           DISPLAY "MDASSESS OUTPUT: " WS-OUTPUT-COUNT
           DISPLAY "MDASSESS ERROR : " WS-ERROR-COUNT

           IF NOT FATAL-ERROR
               IF WS-INPUT-COUNT NOT = WS-OUTPUT-COUNT
                   MOVE 8 TO RETURN-CODE
               ELSE
                   MOVE 0 TO RETURN-CODE
               END-IF
           END-IF.
