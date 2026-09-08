       IDENTIFICATION DIVISION.
       PROGRAM-ID. RGENTRY.
       AUTHOR. V4-REGULATORY-TEAM.
      *
      * 変更履歴
      * V4-003 1995-03-01 新旧告知項目と再告知情報の端末登録を追加。
      * 過去処理を置換する場合はDELコメントとして保存する。
      *
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT OPTIONAL DISCLOSURE-FILE
               ASSIGN TO "DISCLOSE.DAT"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-FILE-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  DISCLOSURE-FILE
           RECORD CONTAINS 80 CHARACTERS.
           COPY "RGDISC.cpy".

       WORKING-STORAGE SECTION.
       01  WS-FILE-STATUS                  PIC XX VALUE SPACES.
       01  WS-VALID-FLAG                   PIC X VALUE "Y".
           88  INPUT-VALID                       VALUE "Y".
           88  INPUT-INVALID                     VALUE "N".
       01  WS-EFFECTIVE-DATE              PIC X(08)
                                           VALUE "19950401".
       01  WS-APPLIED-DATE                PIC X(08) VALUE SPACES.

       PROCEDURE DIVISION.
       0000-MAIN.
           INITIALIZE DISCLOSURE-RECORD
           PERFORM 1000-ACCEPT-INPUT
           PERFORM 2000-VALIDATE-INPUT
           IF INPUT-VALID
               PERFORM 3000-CONFIRM-RULE
               PERFORM 4000-WRITE-RECORD
           ELSE
               MOVE 8 TO RETURN-CODE
           END-IF
           STOP RUN.

       1000-ACCEPT-INPUT.
           DISPLAY "APPLICATION NUMBER (10 DIGITS): "
               WITH NO ADVANCING
           ACCEPT IN-APP-NUMBER
           DISPLAY "RECEIPT DATE (YYYYMMDD): "
               WITH NO ADVANCING
           ACCEPT IN-RECEIPT-DATE
           DISPLAY "DISCLOSURE DATE (YYYYMMDD): "
               WITH NO ADVANCING
           ACCEPT IN-DISCLOSURE-DATE
           DISPLAY "REDISCLOSURE (Y/N): "
               WITH NO ADVANCING
           ACCEPT IN-REDISCLOSURE-FLAG
           DISPLAY "OLD DISCLOSURE ANSWER (Y/N): "
               WITH NO ADVANCING
           ACCEPT IN-OLD-ANSWER
           DISPLAY "NEW DISCLOSURE ANSWER (Y/N): "
               WITH NO ADVANCING
           ACCEPT IN-NEW-ANSWER
           MOVE SPACES TO IN-RESERVED.

       2000-VALIDATE-INPUT.
           IF IN-APP-NUMBER IS NOT NUMERIC
               DISPLAY "ERROR: APPLICATION NUMBER"
               MOVE "N" TO WS-VALID-FLAG
           END-IF
           IF IN-RECEIPT-DATE IS NOT NUMERIC
               DISPLAY "ERROR: RECEIPT DATE"
               MOVE "N" TO WS-VALID-FLAG
           END-IF
           IF IN-DISCLOSURE-DATE IS NOT NUMERIC
               DISPLAY "ERROR: DISCLOSURE DATE"
               MOVE "N" TO WS-VALID-FLAG
           END-IF
           IF IN-REDISCLOSURE-FLAG NOT = "Y"
               AND IN-REDISCLOSURE-FLAG NOT = "N"
               DISPLAY "ERROR: REDISCLOSURE FLAG"
               MOVE "N" TO WS-VALID-FLAG
           END-IF
           IF IN-OLD-ANSWER NOT = "Y"
               AND IN-OLD-ANSWER NOT = "N"
               DISPLAY "ERROR: OLD ANSWER"
               MOVE "N" TO WS-VALID-FLAG
           END-IF
           IF IN-NEW-ANSWER NOT = "Y"
               AND IN-NEW-ANSWER NOT = "N"
               DISPLAY "ERROR: NEW ANSWER"
               MOVE "N" TO WS-VALID-FLAG
           END-IF.

       3000-CONFIRM-RULE.
      *V4-003 ADD START - 登録時点で適用予定制度を確認表示する。
           MOVE IN-RECEIPT-DATE TO WS-APPLIED-DATE
           IF REDISCLOSURE
               MOVE IN-DISCLOSURE-DATE TO WS-APPLIED-DATE
           END-IF
           IF WS-APPLIED-DATE >= WS-EFFECTIVE-DATE
               DISPLAY "RULE TO APPLY: NEW / " WS-APPLIED-DATE
           ELSE
               DISPLAY "RULE TO APPLY: OLD / " WS-APPLIED-DATE
           END-IF.
      *V4-003 ADD END.

       4000-WRITE-RECORD.
           OPEN EXTEND DISCLOSURE-FILE
           IF WS-FILE-STATUS NOT = "00"
               DISPLAY "ERROR: OPEN STATUS " WS-FILE-STATUS
               MOVE 12 TO RETURN-CODE
           ELSE
               WRITE DISCLOSURE-RECORD
               IF WS-FILE-STATUS = "00"
                   DISPLAY "DISCLOSURE REGISTERED: " IN-APP-NUMBER
                   MOVE 0 TO RETURN-CODE
               ELSE
                   DISPLAY "ERROR: WRITE STATUS " WS-FILE-STATUS
                   MOVE 12 TO RETURN-CODE
               END-IF
               CLOSE DISCLOSURE-FILE
           END-IF.

