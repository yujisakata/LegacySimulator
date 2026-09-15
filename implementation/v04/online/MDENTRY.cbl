       IDENTIFICATION DIVISION.
      *V3-001 DEL PROGRAM-ID. NBENTRY.
       PROGRAM-ID. MDENTRY.
      *V3-001 DEL AUTHOR. V1-NEW-BUSINESS-TEAM.
       AUTHOR. V3-MEDICAL-PRODUCT-TEAM.
      *
      * 変更履歴
      * V3-001 1990-04-01 医療系商品の端末登録を追加。
      * 置換前の実行行はDELコメントとして保存する。

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT REGULATION-FILE ASSIGN TO "REGDATE.DAT"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-REG-STATUS.

           SELECT OPTIONAL APPLICATION-FILE
      *V3-001 DEL     ASSIGN TO "APPLICATION.DAT"
               ASSIGN TO "MEDICAL.DAT"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-FILE-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  APPLICATION-FILE
           RECORD CONTAINS 120 CHARACTERS.
      *V3-001 DEL COPY "NBAPPL.cpy".
           COPY "MDAPPL.cpy".

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
      *V3-001 DEL DISPLAY "DEATH BENEFIT AMOUNT (YEN): "
      *V3-001 DEL     WITH NO ADVANCING
      *V3-001 ADD START - 商品別保障額を入力する。
           DISPLAY "PRODUCT BENEFIT AMOUNT (YEN): "
               WITH NO ADVANCING
      *V3-001 ADD END
           ACCEPT APP-AMOUNT-TEXT
      *V3-001 DEL DISPLAY "PRODUCT (WL): " WITH NO ADVANCING
      *V3-001 ADD START - MIまたはCIを入力する。
           DISPLAY "PRODUCT (MI/CI): " WITH NO ADVANCING
      *V3-001 ADD END
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
           MOVE SPACES TO APP-RESERVED.

       2000-VALIDATE-INPUT.
           IF APP-NUMBER IS NOT NUMERIC
               DISPLAY "ERROR: APPLICATION NUMBER"
               MOVE "N" TO WS-VALID-FLAG
           END-IF
      *V3-001 DEL IF APP-PRODUCT-CODE NOT = "WL"
      *V3-001 DEL     DISPLAY "ERROR: V1 PRODUCT MUST BE WL"
      *V3-001 DEL     MOVE "N" TO WS-VALID-FLAG
      *V3-001 DEL END-IF
      *V3-001 ADD START - BR-V3-COM-004 商品コード点検。
           IF APP-PRODUCT-CODE NOT = "MI"
               AND APP-PRODUCT-CODE NOT = "CI"
               DISPLAY "ERROR: PRODUCT MUST BE MI OR CI"
               MOVE "N" TO WS-VALID-FLAG
           END-IF
      *V3-001 ADD END
           IF APP-AGE-TEXT IS NUMERIC
               MOVE APP-AGE-TEXT TO WS-AGE
      *V3-001 DEL IF WS-AGE < 15 OR WS-AGE > 65
      *V3-001 DEL     DISPLAY "ERROR: AGE MUST BE 15 THROUGH 65"
      *V3-001 DEL     MOVE "N" TO WS-VALID-FLAG
      *V3-001 DEL END-IF
      *V3-001 ADD START - BR-V3-MI-001/CI-001 年齢条件。
               IF (APP-PRODUCT-CODE = "MI"
                   AND (WS-AGE < 0 OR WS-AGE > 70))
                   OR (APP-PRODUCT-CODE = "CI"
                   AND (WS-AGE < 20 OR WS-AGE > 65))
                   DISPLAY "ERROR: AGE OUTSIDE PRODUCT RANGE"
                   MOVE "N" TO WS-VALID-FLAG
               END-IF
      *V3-001 ADD END
           ELSE
               DISPLAY "ERROR: AGE MUST BE NUMERIC"
               MOVE "N" TO WS-VALID-FLAG
           END-IF
           IF APP-AMOUNT-TEXT IS NUMERIC
               MOVE APP-AMOUNT-TEXT TO WS-AMOUNT
      *V3-001 DEL IF WS-AMOUNT = ZERO
      *V3-001 DEL     OR WS-AMOUNT > 50000000
      *V3-001 DEL     DISPLAY "ERROR: AMOUNT RANGE"
      *V3-001 DEL     MOVE "N" TO WS-VALID-FLAG
      *V3-001 DEL END-IF
      *V3-001 ADD START - BR-V3-MI-002/CI-002 保障額条件。
               IF (APP-PRODUCT-CODE = "MI"
                   AND WS-AMOUNT NOT = 00003000
                   AND WS-AMOUNT NOT = 00005000
                   AND WS-AMOUNT NOT = 00010000)
                   OR (APP-PRODUCT-CODE = "CI"
                   AND WS-AMOUNT NOT = 01000000
                   AND WS-AMOUNT NOT = 02000000
                   AND WS-AMOUNT NOT = 03000000)
                   DISPLAY "ERROR: AMOUNT OUTSIDE PRODUCT VALUES"
                   MOVE "N" TO WS-VALID-FLAG
               END-IF
      *V3-001 ADD END
           ELSE
               DISPLAY "ERROR: AMOUNT MUST BE NUMERIC"
               MOVE "N" TO WS-VALID-FLAG
           END-IF.

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

