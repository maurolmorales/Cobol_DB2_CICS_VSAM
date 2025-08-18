       IDENTIFICATION DIVISION. *> consulta
       PROGRAM-ID. PGMPRCAF. 
      
      *****************************************************************
      *                   CLASE SINCRÓNICA 37                         *
      *                   ===================                         *
      *    CONSULTA DE CLIENTES                                       *
      *                                                               *
      *****************************************************************
      
      *|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       DATA DIVISION. 
       FILE SECTION. 
      
       WORKING-STORAGE SECTION. 
      *=======================* 
      
      *------------------------------------------------------------ 
       01  CT-CONSTANTES. 
           03 CT-MSGO. 
             05 CT-MNS-01         PIC X(72) VALUE 
                                  'INGRESE LOS DATOS Y PRESIONE ENTER'. 
             05 CT-MNS-02         PIC X(72) VALUE 
                            'DATOS INGRESADOS INCORRECTOS - REINGRESE'. 
             05 CT-MNS-03         PIC X(72) VALUE 
                    'TIPO Y NÚMERO DOCUMENTO INEXISTENTES - REINGRESE'. 
             05 CT-MNS-04         PIC X(72) VALUE 
                                          'TIPO DE DOCUMENTO INVALIDO'. 
             05 CT-MNS-05         PIC X(72) VALUE 
                                        'NUMERO DE DOCUMENTO INVALIDO'. 
             05 CT-MNS-06         PIC X(72) VALUE 'CLIENTE ENCONTRADO'. 
             05 CT-MNS-08         PIC X(72) VALUE 
                                        'PROBLEMA CON ARCHIVO PERSONA'. 
             05 CT-MNS-09         PIC X(72) VALUE     'TECLA INVALIDA'. 
             05 CT-MNS-EXIT       PIC X(72) VALUE 
                                                'FIN TRANSACCION T199'. 
      
           03 CT-DATASET          PIC X(08)           VALUE 'PERSOCAF'. 
           03 CT-DATASET-LEN      PIC S9(04) COMP     VALUE 160. 
           03 CT-DATASET-KEYLEN   PIC S9(04) COMP     VALUE 13. 
      *-------------------------------------------------------------- 
       01  WS-VARIABLES. 
           03 WS-MAP               PIC X(07)          VALUE 'MAP1CAF'. 
           03 WS-MAPSET            PIC X(07)          VALUE 'MAP1CAF'. 
           03 WS-TRANSACTION       PIC X(04)          VALUE 'ACAF'. 
           03 WS-LONG              PIC S9(04) COMP. 
           03 WS-COMLONG           PIC S9(04) COMP. 
           03 WS-ABSTIME           PIC S9(16) COMP    VALUE +0. 
           03 WS-FECHA             PIC X(10)          VALUE SPACES. 
           03 WS-SEP-DATE          PIC X              VALUE '/'. 
           03 WS-HORA              PIC X(08)          VALUE SPACES. 
           03 WS-SEP-HOUR          PIC X              VALUE ':'. 
           03 WS-RESP              PIC S9(04) COMP. 
           03 SW-CONFIRMAR         PIC X              VALUE 'Y'. 
           03 WS-NORMAL            PIC X              VALUE '*'. 
           03 WS-ENTER             PIC X              VALUE ' '. 
      
      
      *------------------------------------------------------------- 
           COPY MAP1CAF. 
           COPY DFHBMSCA. 
           COPY DFHAID. 
           COPY CPPERSON. 
      
      *------------------------------------------------------------- 
       01  WS-COMMAREA. 
           03 WS-USER-DATA. 
              05 WS-USER-TIPDOC        PIC X(02). 
              05 WS-USER-NRODOC        PIC 9(11). 
           03 WS-TIP-DOC               PIC X(02). 
              88 WS-TIP-DOC-BOOLEAN                    VALUE 'DU' 
                                                             'PA' 
                                                             'PE'. 
           03 WS-PRIMERA               PIC 9. 
           03 FILLER                   PIC X(4). 
      
      
      *-----------   VARIABLES DE VALIDACION   ---------------------- 
       01  WS-FECHA-VAL. 
           03 WS-ANIO                  PIC 9(04)      VALUE ZEROS. 
           03 WS-MES                   PIC 9(02)      VALUE ZEROS. 
           03 WS-DIA                   PIC 9(02)      VALUE ZEROS. 
      
       77  WS-FECHA-VALIDA             PIC X. 
           88 FECHAOK                                 VALUE 'Y'. 
           88 FECHAOK-NO                              VALUE 'N'. 
      
       77  WS-CLIENTE-VALIDO           PIC X. 
           88 CLIENTEOK                               VALUE 'Y'. 
           88 CLIENTEOK-NO                            VALUE 'N'. 
      
      
       LINKAGE SECTION. 
      *================* 
       01 DFHCOMMAREA PIC X(20). 
      
      
      *|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       PROCEDURE DIVISION. 
      
       MAIN-PROGRAM-INICIO. 
      
           PERFORM 1000-INICIO-I   THRU 1000-INICIO-F 
           PERFORM 2000-PROCESO-I  THRU 2000-PROCESO-F 
           PERFORM 9999-FINAL-I    THRU 9999-FINAL-F. 
      
       MAIN-PROGRAM-FINAL. GOBACK. 
      
      *------------------------------------------------------------- 
       1000-INICIO-I. 
      
           MOVE LOW-VALUES TO MAP1CAFO 
           MOVE DFHCOMMAREA TO WS-COMMAREA
      
           IF EIBCALEN = 0 THEN 
      
              MOVE LENGTH OF MAP1CAFO TO WS-LONG 
              MOVE CT-MNS-01 TO MSGO 
              PERFORM 8000-SEND-MAPA-I THRU 8000-SEND-MAPA-F
              PERFORM 9999-FINAL-I THRU 9999-FINAL-F 
      
           ELSE  
      
              MOVE LENGTH OF MAP1CAFO TO WS-LONG 
              EXEC CICS RECEIVE 
                 MAP    (WS-MAP) 
                 MAPSET (WS-MAPSET) 
                 INTO   (MAP1CAFI) 
                 RESP   (WS-RESP) 
              END-EXEC 
      
           END-IF. 
      
       1000-INICIO-F. EXIT. 
       
       
      *------------------------------------------------------------- 
       2000-PROCESO-I. 
      
           EVALUATE WS-RESP 
      
              WHEN DFHRESP(NORMAL) 
                 PERFORM 3000-TECLAS-I 
                    THRU 3000-TECLAS-F
                 MOVE TIPDOCI TO WS-USER-TIPDOC 
                 MOVE NUMDOCI TO WS-USER-NRODOC 
      
              WHEN DFHRESP (MAPFAIL) 
                 MOVE LOW-VALUES TO MAP1CAFO 
                 MOVE CT-MNS-01  TO MSGO 
                 PERFORM 8000-SEND-MAPA-I 
                    THRU 8000-SEND-MAPA-F  
      
              WHEN OTHER 
                 MOVE CT-MNS-08  TO MSGO 
      
           END-EVALUATE.
      
       2000-PROCESO-F. EXIT. 
      
      
      *------------------------------------------------------------- 
       3000-TECLAS-I. 
      
           EVALUATE EIBAID 
      
              WHEN DFHENTER 
                 PERFORM 3100-ENTER-I THRU 3100-ENTER-F 
                                                                        
              WHEN DFHPF3 
                 PERFORM 3200-PF3-I   THRU 3200-PF3-F 
                                                                        
              WHEN DFHPF9 
                 PERFORM 3400-PF9-I THRU 3400-PF9-F 
                                                                        
              WHEN DFHPF12 
                 PERFORM 3300-PF12-I  THRU 3300-PF12-F 
                                                                        
              WHEN OTHER 
                 MOVE CT-MNS-09 TO  MSGO 
                 PERFORM 8000-SEND-MAPA-I 
                    THRU 8000-SEND-MAPA-F 
      
           END-EVALUATE. 
      
       3000-TECLAS-F. EXIT. 
       
      
      *------------------------------------------------------------- 
       3100-ENTER-I. 
      
           PERFORM 3150-VALIDAR-I THRU 3150-VALIDAR-F 
      
           IF CLIENTEOK THEN 
      
              PERFORM 5000-READ-I THRU 5000-READ-F 
      
           ELSE 
                 MOVE CT-MNS-02 TO MSGO
                 PERFORM 8000-SEND-MAPA-I 
                    THRU 8000-SEND-MAPA-F 
      
           END-IF. 
      
       3100-ENTER-F. EXIT. 
      
      *------------------------------------------------------------- 
       3150-VALIDAR-I. 
      
           SET CLIENTEOK TO TRUE 
           MOVE TIPDOCI TO WS-TIP-DOC
      
           EVALUATE TRUE 
      
              WHEN NOT WS-TIP-DOC-BOOLEAN 
                   SET CLIENTEOK-NO TO TRUE 
                   MOVE CT-MNS-04  TO MSGO 
      
              WHEN NUMDOCI IS NOT NUMERIC 
                   SET CLIENTEOK-NO TO TRUE 
                   MOVE CT-MNS-05  TO MSGO 
      
              WHEN NUMDOCI IS EQUAL ZEROS 
                   SET CLIENTEOK-NO TO TRUE 
                   MOVE CT-MNS-05  TO MSGO 
      
              WHEN OTHER 
                   CONTINUE 
      
           END-EVALUATE. 
      
      
       3150-VALIDAR-F. EXIT. 
      
      
      *------------------------------------------------------------- 
       3200-PF3-I. 
      
           MOVE LOW-VALUES TO MAP1CAFO
           MOVE CT-MNS-01 TO MSGO 
           PERFORM 8000-SEND-MAPA-I 
              THRU 8000-SEND-MAPA-F.
      
       3200-PF3-F. EXIT. 
      
      
      *------------------------------------------------------------- 
       3300-PF12-I. 
      
           EXEC CICS SEND CONTROL 
              ERASE 
           END-EXEC 
      
      *     EXEC CICS XCTL 
      *        PROGRAM ('PGMMED1F') 
      *     END-EXEC. 
      
           EXEC CICS SEND 
              TEXT FROM (CT-MNS-EXIT) 
           END-EXEC 
      
           EXEC CICS 
              RETURN 
           END-EXEC. 
      
       3300-PF12-F. EXIT. 
      
      
      *------------------------------------------------------------- 
       3400-PF9-I. 
      
           EXEC CICS XCTL 
              PROGRAM ('PGMMECAF') 
           END-EXEC. 
      
       3400-PF9-F. EXIT. 
      
      
      *------------------------------------------------------------- 
       5000-READ-I. 
      
           MOVE TIPDOCI TO WS-USER-TIPDOC 
           MOVE NUMDOCI TO WS-USER-NRODOC 
      
           EXEC CICS READ 
              DATASET (CT-DATASET) 
              RIDFLD  (WS-USER-DATA) 
              INTO    (REG-PERSONA) 
              LENGTH  (CT-DATASET-LEN) 
              EQUAL 
              RESP    (WS-RESP) 
           END-EXEC 
      
           EVALUATE WS-RESP 
      
              WHEN DFHRESP(NOTFND) 
                 MOVE CT-MNS-03        TO MSGO 
                 MOVE WS-USER-TIPDOC   TO TIPDOCO 
                 MOVE WS-USER-NRODOC   TO NUMDOCO 
      
              WHEN DFHRESP(NORMAL) 
                 MOVE CT-MNS-06        TO MSGO 
                 MOVE PER-TIP-DOC      TO TIPDOCO 
                 MOVE PER-NRO-DOC      TO NUMDOCO 
                 MOVE PER-NOMAPE       TO NOMAPEO 
                 MOVE PER-CLI-AAAAMMDD TO WS-FECHA-VAL 
                 MOVE WS-DIA           TO DIAO 
                 MOVE WS-MES           TO MESO 
                 MOVE WS-ANIO          TO ANIOO 
                 MOVE PER-SEXO         TO SEXOO 
      
              WHEN OTHER 
                 MOVE CT-MNS-08  TO MSGO 
      
           END-EVALUATE 
      
           PERFORM 8000-SEND-MAPA-I THRU 8000-SEND-MAPA-F.
      
       5000-READ-F. EXIT. 
      
      
      *------------------------------------------------------------- 
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
      
      
      *------------------------------------------------------------- 
       8000-SEND-MAPA-I.
      
           PERFORM 7000-TIME-I THRU 7000-TIME-F 
           EXEC CICS SEND 
               MAP    (WS-MAP) 
               MAPSET (WS-MAPSET) 
               FROM   (MAP1CAFO) 
               LENGTH (WS-LONG) 
               ERASE 
               FREEKB 
           END-EXEC. 
      
       8000-SEND-MAPA-F. EXIT.
            
      *------------------------------------------------------------- 
       9999-FINAL-I. 
      
           EXEC CICS RETURN
              TRANSID  (WS-TRANSACTION) 
              COMMAREA (WS-COMMAREA) 
           END-EXEC. 
      
       9999-FINAL-F. EXIT. 