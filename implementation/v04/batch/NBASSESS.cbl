       IDENTIFICATION DIVISION.
       PROGRAM-ID. NBASSESS.
      *V2-001 DEL AUTHOR. V1-NEW-BUSINESS-TEAM.
       AUTHOR. V2-NEW-BUSINESS-TEAM.
      *
      * 変更履歴
      * V2-001 1985-07-01 AD特約・HI特約の査定処理を追加。
      * 置換前のV1実行行はDELコメントとして保存する。
      *
      *V2-001 DEL V1夜間新契約査定処理。
      * V2夜間新契約査定処理。
      * 業務ルール: BR-V1-DEF/AGE/PRD/AMT/AUT/RES/WDR。
      *
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT REGULATION-FILE ASSIGN TO "REGDATE.DAT"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-REG-STATUS.

           SELECT APPLICATION-FILE
               ASSIGN TO "APPLICATION.DAT"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-APPLICATION-STATUS.
           SELECT RESULT-FILE
               ASSIGN TO "ASSESSMENT.DAT"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-RESULT-STATUS.

       DATA DIVISION.
       FILE SECTION.
      *V4-001 ADD 物理レコード長を検証する。
       FD  APPLICATION-FILE
           RECORD VARYING FROM 1 TO 4096 CHARACTERS
           DEPENDING ON WS-INPUT-LENGTH.
       01  INPUT-BUFFER                    PIC X(4096).

       FD  RESULT-FILE
           RECORD CONTAINS 80 CHARACTERS.
           COPY "NBRESULT.cpy".

       FD  REGULATION-FILE
           RECORD VARYING FROM 1 TO 256 CHARACTERS
           DEPENDING ON WS-REG-LENGTH.
       01  REGULATION-RECORD               PIC X(256).

       WORKING-STORAGE SECTION.
           COPY "NBAPPL.cpy".
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
      *    BR-V1-AGE-001
           05  WS-MINIMUM-AGE              PIC 99 VALUE 15.
           05  WS-MAXIMUM-AGE              PIC 99 VALUE 65.
      *    BR-V1-AUT-001 / BR-V1-AUT-002
           05  WS-PRIMARY-LIMIT            PIC 9(8)
                                               VALUE 20000000.
      *    BR-V1-AMT-001
           05  WS-MAXIMUM-AMOUNT           PIC 9(8)
                                               VALUE 50000000.
      *    BR-V1-DEF-001
           05  WS-DEFICIENCY-LIMIT         PIC 99 VALUE 30.
      *V2-001 ADD START - 特約業務定数。
      *    BR-V2-AD-001 / BR-V2-HI-001
           05  WS-RIDER-MINIMUM-AGE         PIC 99 VALUE 15.
           05  WS-RIDER-MAXIMUM-AGE         PIC 99 VALUE 60.
      *    BR-V2-AD-002 / BR-V2-AD-004
           05  WS-AD-MINIMUM-AMOUNT         PIC 9(8)
                                               VALUE 01000000.
           05  WS-AD-PRIMARY-LIMIT          PIC 9(8)
                                               VALUE 10000000.
           05  WS-AD-MAXIMUM-AMOUNT         PIC 9(8)
                                               VALUE 20000000.
           05  WS-AD-AMOUNT-UNIT            PIC 9(8)
                                               VALUE 01000000.
      *V2-001 ADD END.

       01  WS-NUMERIC-FIELDS.
           05  WS-AGE                      PIC 99 VALUE ZERO.
           05  WS-AMOUNT                   PIC 9(8) VALUE ZERO.
           05  WS-ELAPSED-DAYS             PIC S9(9) VALUE ZERO.
           05  WS-PROCESS-SERIAL           PIC 9(9) VALUE ZERO.
           05  WS-DEFICIENCY-SERIAL        PIC 9(9) VALUE ZERO.
      *V2-001 ADD START - 特約数値作業領域。
           05  WS-AD-AMOUNT                PIC 9(8) VALUE ZERO.
           05  WS-AD-REMAINDER             PIC 9(8) VALUE ZERO.
           05  WS-HI-BENEFIT               PIC 9(6) VALUE ZERO.
      *V2-001 ADD END.

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
               DISPLAY "NBASSESS: INPUT OPEN ERROR "
                   WS-APPLICATION-STATUS
               MOVE "Y" TO WS-FATAL-FLAG
               MOVE 12 TO RETURN-CODE
           ELSE
               MOVE "Y" TO WS-APPLICATION-OPEN
           END-IF

           IF NOT FATAL-ERROR
               OPEN OUTPUT RESULT-FILE
               IF WS-RESULT-STATUS NOT = "00"
                   DISPLAY "NBASSESS: OUTPUT OPEN ERROR "
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
               DISPLAY "NBASSESS: INPUT READ ERROR "
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
      *V2-001 DEL END-IF.
               END-IF
      *V2-001 ADD START - FR-V2-006/007/008.
           PERFORM 3800-PROCESS-RIDERS.
      *V2-001 ADD END.

       3100-VALIDATE-CODES.
           IF APP-NUMBER IS NOT NUMERIC
               PERFORM 3900-SET-DATA-ERROR
           END-IF

           IF NOT RECORD-ERROR
               IF APP-PRODUCT-CODE NOT = "WL"
                   MOVE "Y" TO WS-RECORD-ERROR
                   MOVE "08"  TO RES-RESULT-CODE
                   MOVE "N"   TO RES-APPROVAL-CLASS
                   MOVE "PRD" TO RES-REASON-CODE
               END-IF
           END-IF

           IF NOT RECORD-ERROR
               IF APP-AGE-TEXT IS NUMERIC
                   MOVE APP-AGE-TEXT TO WS-AGE
                   IF WS-AGE < WS-MINIMUM-AGE
                       OR WS-AGE > WS-MAXIMUM-AGE
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
           END-IF.

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
      *    BR-V1-AMT-001
           IF WS-AMOUNT > WS-MAXIMUM-AMOUNT
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
      *    BR-V1-AUT-001 / BR-V1-AUT-002
           IF WS-AMOUNT > WS-PRIMARY-LIMIT
               OR APP-MEDICAL-CLASS = "M"
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

      *V2-001 ADD START - V2特約査定処理。
       3800-PROCESS-RIDERS.
           MOVE "N"   TO RES-AD-RESULT RES-HI-RESULT
           MOVE "N"   TO RES-AD-APPROVAL RES-HI-APPROVAL
           MOVE "000" TO RES-AD-REASON RES-HI-REASON
           MOVE "00000000" TO RES-AD-AMOUNT
           MOVE "000000"   TO RES-HI-BENEFIT
           IF APP-AD-AMOUNT-TEXT IS NUMERIC
               MOVE APP-AD-AMOUNT-TEXT TO RES-AD-AMOUNT
           END-IF
           IF APP-HI-BENEFIT-TEXT IS NUMERIC
               MOVE APP-HI-BENEFIT-TEXT TO RES-HI-BENEFIT
           END-IF
           PERFORM 3810-PROCESS-AD-RIDER
           PERFORM 3830-PROCESS-HI-RIDER.

      *    FR-V2-002/006およびBR-V2-RDR-003/CMP-001。
       3810-PROCESS-AD-RIDER.
           IF APP-AD-CODE = SPACES OR APP-AD-CODE = "00"
               IF (APP-AD-AMOUNT-TEXT = SPACES
                   OR APP-AD-AMOUNT-TEXT = "00000000")
                   AND APP-AD-DECISION = SPACE
                   CONTINUE
               ELSE
                   PERFORM 3850-SET-AD-INPUT-ERROR
               END-IF
           ELSE
               IF APP-AD-CODE NOT = "AD"
                   PERFORM 3850-SET-AD-INPUT-ERROR
               ELSE
                   IF RES-RESULT-CODE NOT = "01"
                       MOVE "X"   TO RES-AD-RESULT
                       MOVE "N"   TO RES-AD-APPROVAL
                       MOVE "MNC" TO RES-AD-REASON
                   ELSE
                       PERFORM 3820-ASSESS-AD-RIDER
                   END-IF
               END-IF
           END-IF.

      *    FR-V2-003/004およびBR-V2-AD-001～AD-005。
       3820-ASSESS-AD-RIDER.
           IF APP-AD-AMOUNT-TEXT IS NOT NUMERIC
               MOVE "E"   TO RES-AD-RESULT
               MOVE "N"   TO RES-AD-APPROVAL
               MOVE "AMT" TO RES-AD-REASON
           ELSE
               MOVE APP-AD-AMOUNT-TEXT TO WS-AD-AMOUNT
               COMPUTE WS-AD-REMAINDER =
                   FUNCTION MOD(WS-AD-AMOUNT, WS-AD-AMOUNT-UNIT)
               IF WS-AGE < WS-RIDER-MINIMUM-AGE
                   OR WS-AGE > WS-RIDER-MAXIMUM-AGE
                   MOVE "D"   TO RES-AD-RESULT
                   MOVE "N"   TO RES-AD-APPROVAL
                   MOVE "AGE" TO RES-AD-REASON
               ELSE
                   IF WS-AD-AMOUNT < WS-AD-MINIMUM-AMOUNT
                       OR WS-AD-AMOUNT > WS-AD-MAXIMUM-AMOUNT
                       OR WS-AD-REMAINDER NOT = ZERO
                       MOVE "D"   TO RES-AD-RESULT
                       MOVE "N"   TO RES-AD-APPROVAL
                       MOVE "AMT" TO RES-AD-REASON
                   ELSE
                       IF WS-AD-AMOUNT > WS-AMOUNT
                           MOVE "D"   TO RES-AD-RESULT
                           MOVE "N"   TO RES-AD-APPROVAL
                           MOVE "CMP" TO RES-AD-REASON
                       ELSE
                           PERFORM 3825-PROCESS-AD-AUTHORITY
                       END-IF
                   END-IF
               END-IF
           END-IF.

       3825-PROCESS-AD-AUTHORITY.
           IF WS-AD-AMOUNT > WS-AD-PRIMARY-LIMIT
               OR APP-MEDICAL-CLASS = "M"
               EVALUATE APP-AD-DECISION
                   WHEN SPACE
                       MOVE "R"   TO RES-AD-RESULT
                       MOVE "M"   TO RES-AD-APPROVAL
                       MOVE "000" TO RES-AD-REASON
                   WHEN "A"
                       MOVE "A"   TO RES-AD-RESULT
                       MOVE "M"   TO RES-AD-APPROVAL
                       MOVE "000" TO RES-AD-REASON
                   WHEN "P"
                       MOVE "P"   TO RES-AD-RESULT
                       MOVE "M"   TO RES-AD-APPROVAL
                       MOVE "MED" TO RES-AD-REASON
                   WHEN "D"
                       MOVE "D"   TO RES-AD-RESULT
                       MOVE "M"   TO RES-AD-APPROVAL
                       MOVE "MED" TO RES-AD-REASON
                   WHEN OTHER
                       MOVE "E"   TO RES-AD-RESULT
                       MOVE "N"   TO RES-AD-APPROVAL
                       MOVE "APR" TO RES-AD-REASON
               END-EVALUATE
           ELSE
               IF APP-AD-DECISION = SPACE
                   MOVE "A"   TO RES-AD-RESULT
                   MOVE "U"   TO RES-AD-APPROVAL
                   MOVE "000" TO RES-AD-REASON
               ELSE
                   MOVE "E"   TO RES-AD-RESULT
                   MOVE "N"   TO RES-AD-APPROVAL
                   MOVE "APR" TO RES-AD-REASON
               END-IF
           END-IF.

      *    FR-V2-002/006およびBR-V2-RDR-003/CMP-001。
       3830-PROCESS-HI-RIDER.
           IF APP-HI-CODE = SPACES OR APP-HI-CODE = "00"
               IF (APP-HI-BENEFIT-TEXT = SPACES
                   OR APP-HI-BENEFIT-TEXT = "000000")
                   AND APP-HI-DECISION = SPACE
                   CONTINUE
               ELSE
                   PERFORM 3860-SET-HI-INPUT-ERROR
               END-IF
           ELSE
               IF APP-HI-CODE NOT = "HI"
                   PERFORM 3860-SET-HI-INPUT-ERROR
               ELSE
                   IF RES-RESULT-CODE NOT = "01"
                       MOVE "X"   TO RES-HI-RESULT
                       MOVE "N"   TO RES-HI-APPROVAL
                       MOVE "MNC" TO RES-HI-REASON
                   ELSE
                       PERFORM 3840-ASSESS-HI-RIDER
                   END-IF
               END-IF
           END-IF.

      *    FR-V2-005およびBR-V2-HI-001～HI-004。
       3840-ASSESS-HI-RIDER.
           IF APP-HI-BENEFIT-TEXT IS NOT NUMERIC
               MOVE "E"   TO RES-HI-RESULT
               MOVE "N"   TO RES-HI-APPROVAL
               MOVE "AMT" TO RES-HI-REASON
           ELSE
               MOVE APP-HI-BENEFIT-TEXT TO WS-HI-BENEFIT
               IF WS-AGE < WS-RIDER-MINIMUM-AGE
                   OR WS-AGE > WS-RIDER-MAXIMUM-AGE
                   MOVE "D"   TO RES-HI-RESULT
                   MOVE "N"   TO RES-HI-APPROVAL
                   MOVE "AGE" TO RES-HI-REASON
               ELSE
                   IF WS-HI-BENEFIT NOT = 03000
                       AND WS-HI-BENEFIT NOT = 05000
                       AND WS-HI-BENEFIT NOT = 10000
                       MOVE "D"   TO RES-HI-RESULT
                       MOVE "N"   TO RES-HI-APPROVAL
                       MOVE "AMT" TO RES-HI-REASON
                   ELSE
                       PERFORM 3845-PROCESS-HI-AUTHORITY
                   END-IF
               END-IF
           END-IF.

       3845-PROCESS-HI-AUTHORITY.
           IF APP-MEDICAL-CLASS = "M"
               EVALUATE APP-HI-DECISION
                   WHEN SPACE
                       MOVE "R"   TO RES-HI-RESULT
                       MOVE "M"   TO RES-HI-APPROVAL
                       MOVE "000" TO RES-HI-REASON
                   WHEN "A"
                       MOVE "A"   TO RES-HI-RESULT
                       MOVE "M"   TO RES-HI-APPROVAL
                       MOVE "000" TO RES-HI-REASON
                   WHEN "P"
                       MOVE "P"   TO RES-HI-RESULT
                       MOVE "M"   TO RES-HI-APPROVAL
                       MOVE "MED" TO RES-HI-REASON
                   WHEN "D"
                       MOVE "D"   TO RES-HI-RESULT
                       MOVE "M"   TO RES-HI-APPROVAL
                       MOVE "MED" TO RES-HI-REASON
                   WHEN OTHER
                       MOVE "E"   TO RES-HI-RESULT
                       MOVE "N"   TO RES-HI-APPROVAL
                       MOVE "APR" TO RES-HI-REASON
               END-EVALUATE
           ELSE
               IF APP-HI-DECISION = SPACE
                   MOVE "A"   TO RES-HI-RESULT
                   MOVE "U"   TO RES-HI-APPROVAL
                   MOVE "000" TO RES-HI-REASON
               ELSE
                   MOVE "E"   TO RES-HI-RESULT
                   MOVE "N"   TO RES-HI-APPROVAL
                   MOVE "APR" TO RES-HI-REASON
               END-IF
           END-IF.

       3850-SET-AD-INPUT-ERROR.
           MOVE "E"   TO RES-AD-RESULT
           MOVE "N"   TO RES-AD-APPROVAL
           MOVE "COD" TO RES-AD-REASON.

       3860-SET-HI-INPUT-ERROR.
           MOVE "E"   TO RES-HI-RESULT
           MOVE "N"   TO RES-HI-APPROVAL
           MOVE "COD" TO RES-HI-REASON.
      *V2-001 ADD END.

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
      *V2-001 DEL IF RES-RESULT-CODE = "08"
      *V2-001 DEL     ADD 1 TO WS-ERROR-COUNT
      *V2-001 DEL END-IF
      *V2-001 ADD START - FR-V2-010 エラーは1レコード1件。
               IF RES-RESULT-CODE = "08"
                   OR RES-AD-RESULT = "E"
                   OR RES-HI-RESULT = "E"
                   ADD 1 TO WS-ERROR-COUNT
               END-IF
      *V2-001 ADD END
           ELSE
               DISPLAY "NBASSESS: OUTPUT WRITE ERROR "
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

           DISPLAY "NBASSESS INPUT : " WS-INPUT-COUNT
           DISPLAY "NBASSESS OUTPUT: " WS-OUTPUT-COUNT
           DISPLAY "NBASSESS ERROR : " WS-ERROR-COUNT

           IF NOT FATAL-ERROR
               IF WS-INPUT-COUNT NOT = WS-OUTPUT-COUNT
                   MOVE 8 TO RETURN-CODE
               ELSE
                   MOVE 0 TO RETURN-CODE
               END-IF
           END-IF.
