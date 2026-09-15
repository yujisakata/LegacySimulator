       IDENTIFICATION DIVISION.
       PROGRAM-ID. NBENTRY.
      *V2-001 DEL AUTHOR. V1-NEW-BUSINESS-TEAM.
       AUTHOR. V2-NEW-BUSINESS-TEAM.
      *
      * 変更履歴
      * V2-001 1985-07-01 AD特約・HI特約の入力を追加。
      * 置換前のV1実行行はDELコメントとして保存する。

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT REGULATION-FILE ASSIGN TO "REGDATE.DAT"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-REG-STATUS.

           SELECT OPTIONAL APPLICATION-FILE
               ASSIGN TO "APPLICATION.DAT"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-FILE-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  APPLICATION-FILE
           RECORD CONTAINS 120 CHARACTERS.
           COPY "NBAPPL.cpy".

       FD  REGULATION-FILE
           RECORD VARYING FROM 1 TO 256 CHARACTERS
           DEPENDING ON WS-REG-LENGTH.
       01  REGULATION-RECORD               PIC X(256).

       WORKING-STORAGE SECTION.
      *V4-001 ADD 制度日マスタと制度選択作業域。
       01  WS-REG-STATUS                   PIC XX.
       01  WS-REG-LENGTH                   PIC 9(4) COMP.
       01  WS-EFFECTIVE-DATE               PIC X(8).
       01  WS-REG-DATE                     PIC X(8).
       01  WS-REG-RULE                     PIC X(3).
       01  WS-REG-ANSWER                   PIC X.
       01  WS-REG-ERROR                    PIC X.
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

       01  WS-DATE-VALID                   PIC X.
           88 DATE-IS-VALID                VALUE "Y".
       01  WS-LEAP-YEAR                    PIC X.

       01  WS-FILE-STATUS                  PIC XX VALUE SPACES.
       01  WS-VALID-FLAG                   PIC X VALUE "Y".
       01  WS-AGE                          PIC 99 VALUE ZERO.
       01  WS-AMOUNT                       PIC 9(8) VALUE ZERO.
      *V2-001 ADD START - 特約入力点検用作業領域。
       01  WS-AD-AMOUNT                    PIC 9(8) VALUE ZERO.
       01  WS-HI-BENEFIT                   PIC 9(6) VALUE ZERO.
      *V2-001 ADD END.

       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 1100-LOAD-REGULATION
           INITIALIZE APPLICATION-RECORD
           PERFORM 1000-ACCEPT-INPUT
           PERFORM 1200-ACCEPT-REGULATION
           PERFORM 2000-VALIDATE-INPUT
           PERFORM 3150-SELECT-REGULATION
           IF WS-REG-ERROR = "Y"
               MOVE "N" TO WS-VALID-FLAG
           END-IF
           DISPLAY "APPLIED RULE: " WS-REG-RULE
               " DATE: " WS-REG-DATE
           IF WS-VALID-FLAG = "Y"
               PERFORM 3000-WRITE-RECORD
           ELSE
               MOVE 8 TO RETURN-CODE
           END-IF
           STOP RUN.

       1000-ACCEPT-INPUT.
           DISPLAY "APPLICATION NUMBER (10 DIGITS): "
               WITH NO ADVANCING
           ACCEPT APP-NUMBER
           DISPLAY "APPLICATION DATE (YYYYMMDD): "
               WITH NO ADVANCING
           ACCEPT APP-APPLICATION-DATE
           DISPLAY "DISCLOSURE DATE (YYYYMMDD): "
               WITH NO ADVANCING
           ACCEPT APP-DISCLOSURE-DATE
           DISPLAY "PREMIUM DATE (YYYYMMDD OR ZERO): "
               WITH NO ADVANCING
           ACCEPT APP-PREMIUM-DATE
           DISPLAY "RECEIPT DATE (YYYYMMDD): "
               WITH NO ADVANCING
           ACCEPT APP-RECEIPT-DATE
           DISPLAY "PROCESS DATE (YYYYMMDD): "
               WITH NO ADVANCING
           ACCEPT APP-PROCESS-DATE
           DISPLAY "DEFICIENCY DATE (YYYYMMDD OR ZERO): "
               WITH NO ADVANCING
           ACCEPT APP-DEFICIENCY-DATE
           DISPLAY "AGE: " WITH NO ADVANCING
           ACCEPT APP-AGE-TEXT
           DISPLAY "DEATH BENEFIT AMOUNT (YEN): "
               WITH NO ADVANCING
           ACCEPT APP-AMOUNT-TEXT
           DISPLAY "PRODUCT (WL): " WITH NO ADVANCING
           ACCEPT APP-PRODUCT-CODE
           DISPLAY "DOCUMENT COMPLETE (Y/N): "
               WITH NO ADVANCING
           ACCEPT APP-DOCUMENT-COMPLETE
           DISPLAY "MEDICAL CLASS (S/M): "
               WITH NO ADVANCING
           ACCEPT APP-MEDICAL-CLASS
           DISPLAY "MANAGER DECISION (A/P/D/BLANK): "
               WITH NO ADVANCING
           ACCEPT APP-MANAGER-DECISION
           DISPLAY "WITHDRAWAL (Y/N): " WITH NO ADVANCING
           ACCEPT APP-WITHDRAWAL
      *V2-001 DEL MOVE SPACES TO APP-RESERVED.
      *V2-001 ADD START - FR-V2-001 特約端末入力。
           DISPLAY "AD RIDER CODE (AD OR BLANK): "
               WITH NO ADVANCING
           ACCEPT APP-AD-CODE
           DISPLAY "AD RIDER AMOUNT (YEN OR ZERO): "
               WITH NO ADVANCING
           ACCEPT APP-AD-AMOUNT-TEXT
           DISPLAY "AD DECISION (A/P/D/BLANK): "
               WITH NO ADVANCING
           ACCEPT APP-AD-DECISION
           DISPLAY "HI RIDER CODE (HI OR BLANK): "
               WITH NO ADVANCING
           ACCEPT APP-HI-CODE
           DISPLAY "HI DAILY BENEFIT (YEN OR ZERO): "
               WITH NO ADVANCING
           ACCEPT APP-HI-BENEFIT-TEXT
           DISPLAY "HI DECISION (A/P/D/BLANK): "
               WITH NO ADVANCING
           ACCEPT APP-HI-DECISION
           MOVE SPACES TO APP-V4-RESERVED.
      *V2-001 ADD END.

       2000-VALIDATE-INPUT.
           IF APP-NUMBER IS NOT NUMERIC
               DISPLAY "ERROR: APPLICATION NUMBER"
               MOVE "N" TO WS-VALID-FLAG
           END-IF
           IF APP-PRODUCT-CODE NOT = "WL"
               DISPLAY "ERROR: V1 PRODUCT MUST BE WL"
               MOVE "N" TO WS-VALID-FLAG
           END-IF
           IF APP-AGE-TEXT IS NUMERIC
               MOVE APP-AGE-TEXT TO WS-AGE
               IF WS-AGE < 15 OR WS-AGE > 65
                   DISPLAY "ERROR: AGE MUST BE 15 THROUGH 65"
                   MOVE "N" TO WS-VALID-FLAG
               END-IF
           ELSE
               DISPLAY "ERROR: AGE MUST BE NUMERIC"
               MOVE "N" TO WS-VALID-FLAG
           END-IF
           IF APP-AMOUNT-TEXT IS NUMERIC
               MOVE APP-AMOUNT-TEXT TO WS-AMOUNT
               IF WS-AMOUNT = ZERO OR WS-AMOUNT > 50000000
                   DISPLAY "ERROR: AMOUNT MUST BE 1 THROUGH 50000000"
                   MOVE "N" TO WS-VALID-FLAG
               END-IF
           ELSE
               DISPLAY "ERROR: AMOUNT MUST BE NUMERIC"
               MOVE "N" TO WS-VALID-FLAG
      *V2-001 DEL END-IF.
           END-IF
      *V2-001 ADD START - FR-V2-002 特約入力点検。
           PERFORM 2100-VALIDATE-AD-INPUT
           PERFORM 2200-VALIDATE-HI-INPUT.
      *V2-001 ADD END.

      *V2-001 ADD START - FR-V2-002 ADコード・金額整合性。
       2100-VALIDATE-AD-INPUT.
           IF APP-AD-CODE = SPACES OR APP-AD-CODE = "00"
               IF (APP-AD-AMOUNT-TEXT = SPACES
                   OR APP-AD-AMOUNT-TEXT = "00000000")
                   AND APP-AD-DECISION = SPACE
                   MOVE SPACES TO APP-AD-CODE
                   MOVE "00000000" TO APP-AD-AMOUNT-TEXT
               ELSE
                   DISPLAY "ERROR: AD NONE REQUIRES ZERO AMOUNT"
                   MOVE "N" TO WS-VALID-FLAG
               END-IF
           ELSE
               IF APP-AD-CODE = "AD"
                   IF APP-AD-AMOUNT-TEXT IS NUMERIC
                       MOVE APP-AD-AMOUNT-TEXT TO WS-AD-AMOUNT
                       IF WS-AD-AMOUNT = ZERO
                           DISPLAY "ERROR: AD AMOUNT MUST BE POSITIVE"
                           MOVE "N" TO WS-VALID-FLAG
                       END-IF
                   ELSE
                       DISPLAY "ERROR: AD AMOUNT MUST BE NUMERIC"
                       MOVE "N" TO WS-VALID-FLAG
                   END-IF
                   IF APP-AD-DECISION NOT = SPACE
                       AND APP-AD-DECISION NOT = "A"
                       AND APP-AD-DECISION NOT = "P"
                       AND APP-AD-DECISION NOT = "D"
                       DISPLAY "ERROR: AD DECISION"
                       MOVE "N" TO WS-VALID-FLAG
                   END-IF
               ELSE
                   DISPLAY "ERROR: AD CODE"
                   MOVE "N" TO WS-VALID-FLAG
               END-IF
           END-IF.
      *V2-001 ADD END.

      *V2-001 ADD START - FR-V2-002 HIコード・日額整合性。
       2200-VALIDATE-HI-INPUT.
           IF APP-HI-CODE = SPACES OR APP-HI-CODE = "00"
               IF (APP-HI-BENEFIT-TEXT = SPACES
                   OR APP-HI-BENEFIT-TEXT = "000000")
                   AND APP-HI-DECISION = SPACE
                   MOVE SPACES TO APP-HI-CODE
                   MOVE "000000" TO APP-HI-BENEFIT-TEXT
               ELSE
                   DISPLAY "ERROR: HI NONE REQUIRES ZERO BENEFIT"
                   MOVE "N" TO WS-VALID-FLAG
               END-IF
           ELSE
               IF APP-HI-CODE = "HI"
                   IF APP-HI-BENEFIT-TEXT IS NUMERIC
                       MOVE APP-HI-BENEFIT-TEXT TO WS-HI-BENEFIT
                       IF WS-HI-BENEFIT = ZERO
                           DISPLAY "ERROR: HI BENEFIT MUST BE POSITIVE"
                           MOVE "N" TO WS-VALID-FLAG
                       END-IF
                   ELSE
                       DISPLAY "ERROR: HI BENEFIT MUST BE NUMERIC"
                       MOVE "N" TO WS-VALID-FLAG
                   END-IF
                   IF APP-HI-DECISION NOT = SPACE
                       AND APP-HI-DECISION NOT = "A"
                       AND APP-HI-DECISION NOT = "P"
                       AND APP-HI-DECISION NOT = "D"
                       DISPLAY "ERROR: HI DECISION"
                       MOVE "N" TO WS-VALID-FLAG
                   END-IF
               ELSE
                   DISPLAY "ERROR: HI CODE"
                   MOVE "N" TO WS-VALID-FLAG
               END-IF
           END-IF.
      *V2-001 ADD END.

       3000-WRITE-RECORD.
           OPEN EXTEND APPLICATION-FILE
      *V4-003 ADD 初回登録時のOPTIONAL新規作成を正常扱い。
           IF WS-FILE-STATUS = "00" OR "05"
               WRITE APPLICATION-RECORD
               IF WS-FILE-STATUS = "00"
                   DISPLAY "APPLICATION REGISTERED: " APP-NUMBER
                   MOVE 0 TO RETURN-CODE
               ELSE
                   DISPLAY "ERROR: WRITE STATUS " WS-FILE-STATUS
                   MOVE 12 TO RETURN-CODE
               END-IF
               CLOSE APPLICATION-FILE
      *V4-003 ADD バッファ書出し失敗を正常扱いしない。
               IF WS-FILE-STATUS NOT = "00"
                   MOVE 12 TO RETURN-CODE
               END-IF
           ELSE
               DISPLAY "ERROR: OPEN STATUS " WS-FILE-STATUS
               MOVE 12 TO RETURN-CODE
           END-IF.

      *V4-001 ADD 制度入力。非選択回答は空白を許容。
       1200-ACCEPT-REGULATION.
           DISPLAY "REDISCLOSURE (Y/N/BLANK): "
           ACCEPT APP-REDISCLOSURE
           DISPLAY "OLD DECLINE CONDITION (Y/N/BLANK): "
           ACCEPT APP-OLD-ANSWER
           DISPLAY "NEW DECLINE CONDITION (Y/N/BLANK): "
           ACCEPT APP-NEW-ANSWER.
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

