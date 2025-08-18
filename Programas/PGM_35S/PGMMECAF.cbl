       IDENTIFICATION DIVISION. *> menu
       PROGRAM-ID. PGMMECAF. 
      
      *****************************************************************
      *                   CLASE SINCRÓNICA 35                         *
      *                   ===================                         *
      *    MENÚ DE CLIENTES                                           *
      *                                                               *
      *****************************************************************
      
      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       DATA DIVISION. 
       FILE SECTION. 
      
       WORKING-STORAGE SECTION.
      *=======================*  
      
       01  CT-CONSTANTES. 
           03 CT-MSGO. 
             05 CT-MNS-01         PIC X(72) VALUE 
                                           'INGRESE LA OPCION DESEADA'. 
             05 CT-MNS-02         PIC X(72) VALUE   'INGRESO DE DATOS'. 
             05 CT-MNS-03         PIC X(72) VALUE     'TECLA INVALIDA'. 
             05 CT-MNS-08         PIC X(72) VALUE 'DOCUMENTO INVALIDO'. 
             05 CT-MNS-EXIT       PIC X(72) VALUE 
                                                'FIN TRANSACCION BCAF'. 
      
      *--------------------------------------------------------------
       01  WS-VARIABLES. 
           03 WS-MAP              PIC X(07)            VALUE 'MAP2CAF'. 
           03 WS-MAPSET           PIC X(07)            VALUE 'MAP2CAF'. 
           03 WS-TRANSACTION      PIC X(04)            VALUE    'BCAF'. 
           03 WS-LONG             PIC S9(04) COMP. 
           03 WS-ABSTIME          PIC S9(16) COMP      VALUE +0. 
           03 WS-FECHA            PIC X(10)            VALUE SPACES. 
           03 WS-SEP-DATE         PIC X                VALUE '/'. 
           03 WS-HORA             PIC X(08)            VALUE SPACES. 
           03 WS-SEP-HOUR         PIC X                VALUE ':'. 
           03 WS-RESP             PIC S9(04) COMP. 
           03 WS-ERR              PIC X(15). 
      
       01  WS-COMMAREA. 
           03 WS-USER-DATA. 
             05 WS-USER-TIPDOC    PIC X(02). 
             05 WS-USER-NUMDOC    PIC 9(11). 
           03 WS-TIP-DOC           PIC X(02). 
             88 WS-TIP-DOC-BOOLEAN                     VALUE 'DU' 
                                                             'PA' 
                                                             'PE'. 
           03 FILLER               PIC X(5). 
      
      
       COPY MAP2CAF. 
       COPY DFHBMSCA. 
       COPY DFHAID. 
      
       LINKAGE SECTION. 
      *================* 
       01 DFHCOMMAREA PIC X(20). 
      
      *|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       PROCEDURE DIVISION. 
      
       MAIN-PROGRAM-I. 
      
           PERFORM 1000-INICIO-I   THRU 1000-INICIO-F
           PERFORM 2000-PROCESO-I  THRU 2000-PROCESO-F
           PERFORM 9999-FINAL-I    THRU 9999-FINAL-F.
      
       MAIN-PROGRAM-F. GOBACK.
      
      
      *----------------------------------------------------------- 
       1000-INICIO-I. 
      
           MOVE LOW-VALUES TO MAP2CAFO
           MOVE DFHCOMMAREA TO WS-COMMAREA 
      
           IF EIBCALEN = 0 THEN 
      
              MOVE LENGTH OF MAP2CAFO TO WS-LONG 
              MOVE CT-MNS-01 TO MSGO 
              PERFORM 8000-SEND-MAPA-I THRU 8000-SEND-MAPA-F
              PERFORM 9999-FINAL-I THRU 9999-FINAL-F
      
           ELSE  
              MOVE LENGTH OF MAP2CAFO TO WS-LONG 
              EXEC CICS RECEIVE 
                  MAP    (WS-MAP) 
                  MAPSET (WS-MAPSET) 
                  INTO   (MAP2CAFI) 
                  RESP   (WS-RESP) 
              END-EXEC 
           END-IF. 
      
       1000-INICIO-F. EXIT. 
      
      
      *---------------------------------------------------------- 
       2000-PROCESO-I. 
      
           EVALUATE WS-RESP 
              WHEN DFHRESP (NORMAL) 
                 PERFORM 2500-PULSAR-TECLA-I 
                    THRU 2500-PULSAR-TECLA-F
              WHEN DFHRESP (MAPFAIL) 
      *           MOVE LENGTH OF MAP2CAFO TO WS-LONG 
                 MOVE LOW-VALUES TO MAP2CAFO 
                 MOVE CT-MNS-01  TO MSGO 
      
                 PERFORM 8000-SEND-MAPA-I 
                    THRU 8000-SEND-MAPA-F
              WHEN OTHER 
                 MOVE CT-MNS-02 TO MSGO 
           END-EVALUATE.
      
      
       2000-PROCESO-F. EXIT. 
      
      
      *---------------------------------------------------------- 
       2500-PULSAR-TECLA-I. 
      
             EVALUATE EIBAID 
      
             WHEN DFHPF1 
                 PERFORM 3000-PF1-I THRU 3000-PF1-F 
      
             WHEN DFHPF2 
                 PERFORM 3500-PF2-I THRU 3500-PF2-F 
      
             WHEN DFHPF3 
                 PERFORM 4000-PF3-I THRU 4000-PF3-F 
      
             WHEN DFHPF4 
                 PERFORM 4500-PF4-I THRU 4500-PF4-F 
      
             WHEN DFHPF5 
                 PERFORM 4600-PF5-I THRU 4600-PF5-F 
      
             WHEN DFHPF6 
                 PERFORM 4700-PF6-I THRU 4700-PF6-F 
      
             WHEN DFHPF12 
                 PERFORM 5500-PF12-I THRU 5500-PF12-F 
      
             WHEN OTHER 
                 MOVE CT-MNS-03 TO MSGO 
                 PERFORM 8000-SEND-MAPA-I THRU 8000-SEND-MAPA-F
             END-EVALUATE. 
      
       2500-PULSAR-TECLA-F. EXIT. 
      
      *------------------  (ALTA)  ------------------------------ 
       3000-PF1-I. 
      
           EXEC CICS XCTL 
                PROGRAM ('PGMALCAF') 
           END-EXEC. 
      
       3000-PF1-F. EXIT. 
      
      *------------------  (BAJA)  ------------------------------ 
       3500-PF2-I. 
      
           EXEC CICS XCTL 
               PROGRAM ('PGMBACAF') 
           END-EXEC. 
      
       3500-PF2-F. EXIT. 
      
      *---------------------  (MODIFICAR)  ------------------------ 
       4000-PF3-I. 
      
           EXEC CICS XCTL 
               PROGRAM ('PGMMOCAF') 
           END-EXEC. 
      
       4000-PF3-F. EXIT. 
      
      *--------------------  (CONSULTA)  ------------------------ 
       4500-PF4-I. 
      
           EXEC CICS XCTL 
               PROGRAM ('PGMPRCAF') 
           END-EXEC. 
      
       4500-PF4-F. EXIT. 
      
      *----------------  (LIMPIAR)  ----------------------------- 
       4600-PF5-I. 
      
           MOVE LOW-VALUES TO MAP2CAFO 
           MOVE CT-MNS-01 TO MSGO 
                                                                      
           PERFORM 8000-SEND-MAPA-I THRU 8000-SEND-MAPA-F.
      
       4600-PF5-F. EXIT. 
      
      *----------------  (CONSULTA GENERAL)  -------------------- 
       4700-PF6-I. 
           MOVE 'FUNCIÓN DE CONSULTA GENERAL' TO MSGO.
           
      *     MOVE TIPDOCI TO WS-TIP-DOC. 
      *     IF NOT WS-TIP-DOC-BOOLEAN 
      *        INITIALIZE MAP2CAFO 
      *        MOVE CT-MNS-08 TO MSGO 
      *     ELSE 
      *        IF NUMDOCI NOT NUMERIC 
      *           INITIALIZE MAP2CAFO 
      *           MOVE CT-MNS-08 TO MSGO 
      *        ELSE 
      *           MOVE TIPDOCI TO WS-USER-TIPDOC 
      *           MOVE NUMDOCI TO WS-USER-NUMDOC 
      *           EXEC CICS XCTL
      *               PROGRAM ('PGMACCAF') 
      *               COMMAREA (WS-COMMAREA) 
      *           END-EXEC 
      *        END-IF 
      *     END-IF. 
      
       4700-PF6-F. EXIT. 
      
      *-------------------  (SALIR)  ------------------------------- 
      *                   
       5500-PF12-I. 
      
           EXEC CICS SEND
               CONTROL
               ERASE 
           END-EXEC 
      
           EXEC CICS SEND
               TEXT 
               FROM (CT-MNS-EXIT) 
           END-EXEC 
      
           EXEC CICS RETURN 
           END-EXEC. 
      
       5500-PF12-F. EXIT. 
      
      
      *---------------------------------------------------------- 
       7000-TIME-I. 
      
           EXEC CICS ASKTIME 
             ABSTIME (WS-ABSTIME) 
           END-EXEC 
      
           EXEC CICS FORMATTIME 
             ABSTIME (WS-ABSTIME) 
             DDMMYYYY (WS-FECHA) DATESEP(WS-SEP-DATE) 
             TIME (WS-HORA) TIMESEP(WS-SEP-HOUR) 
           END-EXEC 
      
           MOVE WS-FECHA TO FECHAO. 
      
       7000-TIME-F. EXIT. 
      
      *---------------------------------------------------------- 
       8000-SEND-MAPA-I.
      
           PERFORM 7000-TIME-I THRU 7000-TIME-F 
           EXEC CICS SEND 
               MAP    (WS-MAP) 
               MAPSET (WS-MAPSET) 
               FROM   (MAP2CAFO) 
               LENGTH (WS-LONG) 
               ERASE 
               FREEKB 
           END-EXEC. 
      
       8000-SEND-MAPA-F. EXIT.
      
      *---------------------------------------------------------- 
       9999-FINAL-I. 
      
           EXEC CICS RETURN
              TRANSID  (WS-TRANSACTION) 
              COMMAREA (WS-COMMAREA) 
           END-EXEC.  
      
       9999-FINAL-F. EXIT. 