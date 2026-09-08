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
           SELECT OPTIONAL APPLICATION-FILE
               ASSIGN TO "APPLICATION.DAT"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-FILE-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  APPLICATION-FILE
           RECORD CONTAINS 120 CHARACTERS.
           COPY "NBAPPL.cpy".

       WORKING-STORAGE SECTION.
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
           INITIALIZE APPLICATION-RECORD
           PERFORM 1000-ACCEPT-INPUT
           PERFORM 2000-VALIDATE-INPUT
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
           MOVE SPACES TO APP-V2-RESERVED.
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
           IF WS-FILE-STATUS = "00"
               WRITE APPLICATION-RECORD
               IF WS-FILE-STATUS = "00"
                   DISPLAY "APPLICATION REGISTERED: " APP-NUMBER
                   MOVE 0 TO RETURN-CODE
               ELSE
                   DISPLAY "ERROR: WRITE STATUS " WS-FILE-STATUS
                   MOVE 12 TO RETURN-CODE
               END-IF
               CLOSE APPLICATION-FILE
           ELSE
               DISPLAY "ERROR: OPEN STATUS " WS-FILE-STATUS
               MOVE 12 TO RETURN-CODE
           END-IF.
