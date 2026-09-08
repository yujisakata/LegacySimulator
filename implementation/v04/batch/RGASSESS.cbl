       IDENTIFICATION DIVISION.
       PROGRAM-ID. RGASSESS.
       AUTHOR. V4-REGULATORY-TEAM.
      *
      * 変更履歴
      * V4-001 1995-03-01 告知制度の施行日判定を追加。
      * V4-002 1995-04-02 再告知時の基準日選択を補正。
      * 置換前の実行行はDELコメントとして保存する。
      *
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT DISCLOSURE-FILE ASSIGN TO "DISCLOSE.DAT"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-IN-STATUS.
           SELECT RESULT-FILE ASSIGN TO "RGRESULT.DAT"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-OUT-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  DISCLOSURE-FILE RECORD CONTAINS 80 CHARACTERS.
       01  DISCLOSURE-RECORD.
           05  IN-APP-NUMBER              PIC X(10).
           05  IN-RECEIPT-DATE            PIC X(08).
           05  IN-DISCLOSURE-DATE         PIC X(08).
           05  IN-REDISCLOSURE-FLAG       PIC X(01).
           05  IN-OLD-ANSWER              PIC X(01).
           05  IN-NEW-ANSWER              PIC X(01).
           05  IN-RESERVED                PIC X(51).

       FD  RESULT-FILE RECORD CONTAINS 40 CHARACTERS.
       01  RESULT-RECORD.
           05  OUT-APP-NUMBER             PIC X(10).
           05  OUT-RULE-VERSION           PIC X(03).
           05  OUT-RESULT-CODE            PIC X(02).
           05  OUT-REASON-CODE            PIC X(03).
           05  OUT-APPLIED-DATE           PIC X(08).
           05  OUT-RESERVED               PIC X(14).

       WORKING-STORAGE SECTION.
       01  WS-FILE-STATUS.
           05  WS-IN-STATUS               PIC XX VALUE SPACES.
           05  WS-OUT-STATUS              PIC XX VALUE SPACES.
       01  WS-CONTROL.
           05  WS-EOF                     PIC X VALUE "N".
               88  END-OF-FILE                  VALUE "Y".
           05  WS-DATA-ERROR              PIC X VALUE "N".
               88  DATA-ERROR                   VALUE "Y".
       01  WS-COUNTERS.
           05  WS-INPUT-COUNT             PIC 9(7) VALUE ZERO.
           05  WS-OUTPUT-COUNT            PIC 9(7) VALUE ZERO.
       01  WS-EFFECTIVE-DATE              PIC X(8)
                                           VALUE "19950401".

       PROCEDURE DIVISION.
       0000-MAIN.
           OPEN INPUT DISCLOSURE-FILE
           OPEN OUTPUT RESULT-FILE
           IF WS-IN-STATUS NOT = "00" OR WS-OUT-STATUS NOT = "00"
               DISPLAY "RGASSESS OPEN ERROR"
               MOVE 12 TO RETURN-CODE
               STOP RUN
           END-IF
           PERFORM 2000-READ
           PERFORM UNTIL END-OF-FILE
               PERFORM 3000-ASSESS
               PERFORM 4000-WRITE
               PERFORM 2000-READ
           END-PERFORM
           CLOSE DISCLOSURE-FILE RESULT-FILE
           DISPLAY "RGASSESS INPUT : " WS-INPUT-COUNT
           DISPLAY "RGASSESS OUTPUT: " WS-OUTPUT-COUNT
           MOVE 0 TO RETURN-CODE
           STOP RUN.

       2000-READ.
           READ DISCLOSURE-FILE
               AT END MOVE "Y" TO WS-EOF
               NOT AT END ADD 1 TO WS-INPUT-COUNT
           END-READ.

       3000-ASSESS.
           INITIALIZE RESULT-RECORD
           MOVE IN-APP-NUMBER TO OUT-APP-NUMBER
           MOVE "N" TO WS-DATA-ERROR
           IF IN-APP-NUMBER IS NOT NUMERIC
               PERFORM 3900-DATA-ERROR
           END-IF
           IF IN-RECEIPT-DATE IS NOT NUMERIC
               PERFORM 3900-DATA-ERROR
           END-IF
           IF IN-DISCLOSURE-DATE IS NOT NUMERIC
               PERFORM 3900-DATA-ERROR
           END-IF
           IF IN-REDISCLOSURE-FLAG NOT = "Y"
               AND IN-REDISCLOSURE-FLAG NOT = "N"
               PERFORM 3900-DATA-ERROR
           END-IF
           IF IN-OLD-ANSWER NOT = "Y" AND IN-OLD-ANSWER NOT = "N"
               PERFORM 3900-DATA-ERROR
           END-IF
           IF IN-NEW-ANSWER NOT = "Y" AND IN-NEW-ANSWER NOT = "N"
               PERFORM 3900-DATA-ERROR
           END-IF
           IF NOT DATA-ERROR
               PERFORM 3100-SELECT-APPLIED-DATE
               PERFORM 3200-SELECT-RULE
           END-IF.

       3100-SELECT-APPLIED-DATE.
      *V4-002 DEL MOVE IN-RECEIPT-DATE TO OUT-APPLIED-DATE.
      *V4-002 ADD START - 再告知時だけ告知日を優先する。
           IF IN-REDISCLOSURE-FLAG = "Y"
               MOVE IN-DISCLOSURE-DATE TO OUT-APPLIED-DATE
           ELSE
               MOVE IN-RECEIPT-DATE TO OUT-APPLIED-DATE
           END-IF.
      *V4-002 ADD END.

       3200-SELECT-RULE.
      *V4-001 ADD START - 制度施行日で新旧段落を呼び分ける。
           IF OUT-APPLIED-DATE >= WS-EFFECTIVE-DATE
               MOVE "NEW" TO OUT-RULE-VERSION
               PERFORM 3400-NEW-RULE
           ELSE
               MOVE "OLD" TO OUT-RULE-VERSION
               PERFORM 3300-OLD-RULE
           END-IF.
      *V4-001 ADD END.

       3300-OLD-RULE.
           IF IN-OLD-ANSWER = "Y"
               MOVE "03" TO OUT-RESULT-CODE
               MOVE "OLD" TO OUT-REASON-CODE
           ELSE
               MOVE "01" TO OUT-RESULT-CODE
               MOVE "000" TO OUT-REASON-CODE
           END-IF.

       3400-NEW-RULE.
           IF IN-NEW-ANSWER = "Y"
               MOVE "03" TO OUT-RESULT-CODE
               MOVE "NEW" TO OUT-REASON-CODE
           ELSE
               MOVE "01" TO OUT-RESULT-CODE
               MOVE "000" TO OUT-REASON-CODE
           END-IF.

       3900-DATA-ERROR.
           MOVE "Y" TO WS-DATA-ERROR
           MOVE "ERR" TO OUT-RULE-VERSION
           MOVE "08" TO OUT-RESULT-CODE
           MOVE "DAT" TO OUT-REASON-CODE
           MOVE "00000000" TO OUT-APPLIED-DATE.

       4000-WRITE.
           WRITE RESULT-RECORD
           IF WS-OUT-STATUS NOT = "00"
               DISPLAY "RGASSESS WRITE ERROR " WS-OUT-STATUS
               MOVE 12 TO RETURN-CODE
               STOP RUN
           END-IF
           ADD 1 TO WS-OUTPUT-COUNT.

