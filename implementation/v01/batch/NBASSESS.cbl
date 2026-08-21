       IDENTIFICATION DIVISION.
       PROGRAM-ID. NBASSESS.
       AUTHOR. V1-NEW-BUSINESS-TEAM.
      *
      * V1 NIGHTLY NEW-BUSINESS ASSESSMENT.
      * BUSINESS RULES: BR-V1-DEF/AGE/PRD/AMT/AUT/RES/WDR.
      *
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
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
       FD  APPLICATION-FILE
           RECORD CONTAINS 120 CHARACTERS.
           COPY "NBAPPL.cpy".

       FD  RESULT-FILE
           RECORD CONTAINS 80 CHARACTERS.
           COPY "NBRESULT.cpy".

       WORKING-STORAGE SECTION.
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

      *    BR-V1-WDR-001: CUSTOMER WITHDRAWAL HAS PRIORITY.
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
                   PERFORM 3250-APPLY-BUSINESS-RULES
               END-IF
           END-IF.

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
                       PERFORM 3400-PROCESS-AUTHORITY
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
      *    BR-V1-RES-001: LATEST OF APPLICATION, DISCLOSURE,
      *    AND FIRST PREMIUM RECEIPT DATES.
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
               DISPLAY "NBASSESS: OUTPUT WRITE ERROR "
                   WS-RESULT-STATUS
               MOVE "Y" TO WS-FATAL-FLAG
               MOVE 12 TO RETURN-CODE
           END-IF.

       9000-FINALIZE.
           IF WS-APPLICATION-OPEN = "Y"
               CLOSE APPLICATION-FILE
           END-IF
           IF WS-RESULT-OPEN = "Y"
               CLOSE RESULT-FILE
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
