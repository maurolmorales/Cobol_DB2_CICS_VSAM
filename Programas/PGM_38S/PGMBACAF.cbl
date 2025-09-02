       IDENTIFICATION DIVISION. *> baja
       PROGRAM-ID. PGMBACAF. 
      
      *****************************************************************
      *                   CLASE SINCRÓNICA 38                         *
      *                   ===================                         *
      *    BAJA DE CLIENTES                                           *
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
             05 CT-MNS-02         PIC X(72) VALUE *>*/*/**/** */ */
                            'DATOS INGRESADOS INCORRECTOS - REINGRESE'. 
             05 CT-MNS-03         PIC X(72) VALUE 
                    'TIPO Y NÚMERO DOCUMENTO INEXISTENTES - REINGRESE'. 
             05 CT-MNS-04         PIC X(72) VALUE 
                                          'TIPO DE DOCUMENTO INVALIDO'. 
             05 CT-MNS-05         PIC X(72) VALUE 
                                        'NUMERO DE DOCUMENTO INVALIDO'. 
             05 CT-MNS-06         PIC X(72) VALUE 'CLIENTE BORRADO OK'.
             05 CT-MNS-08         PIC X(72) VALUE 
                                        'PROBLEMA CON ARCHIVO PERSONA'. 
             05 CT-MNS-09         PIC X(72) VALUE     'TECLA INVALIDA'. 
             05 CT-MNS-10         PIC X(72) VALUE 'CLIENTE ENCONTRADO'. 
      
           03 CT-DATASET          PIC X(08)           VALUE 'PERSOCAF'. 
           03 CT-DATASET-LEN      PIC S9(04) COMP     VALUE 160. 
           03 CT-DATASET-KEYLEN   PIC S9(04) COMP     VALUE 13. 
      *-------------------------------------------------------------- 
       01  WS-VARIABLES. 
           03 WS-MAP-00            PIC X(07)          VALUE 'MAP4CAF'. 
           03 WS-MAPSET-00         PIC X(07)          VALUE 'MAP4CAF'. 
           03 WS-TRANSACTION       PIC X(04)          VALUE 'ECAF'. 
           03 WS-LONG              PIC S9(04) COMP. 
           03 WS-COMLONG           PIC S9(04) COMP. 
           03 WS-ABSTIME           PIC S9(16) COMP    VALUE +0. 
           03 WS-FECHA             PIC X(10)          VALUE SPACES. 
           03 WS-SEP-DATE          PIC X              VALUE '/'. 
           03 WS-HORA              PIC X(08)          VALUE SPACES. 
           03 WS-SEP-HOUR          PIC X              VALUE ':'. 
           03 WS-RESP              PIC S9(04) COMP. 
 
      *------------------------------------------------------------- 
           COPY MAP4CAF. 
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
      
       MAIN-PROGRAM-FINAL. EXIT. 
      
      *------------------------------------------------------------- 
       1000-INICIO-I. 
      
           MOVE LOW-VALUES TO MAP4CAFO. 
           MOVE DFHCOMMAREA TO WS-COMMAREA. 
      
           IF EIBCALEN = 0 THEN 
      
              MOVE LENGTH OF MAP4CAFO TO WS-LONG 
              MOVE CT-MNS-01 TO MSGO 
              PERFORM 8000-SEND-MAPA-I THRU 8000-SEND-MAPA-F 
              PERFORM 9999-FINAL-I THRU 9999-FINAL-F 
      
           END-IF. 
      
       1000-INICIO-F. EXIT. 
      
      
      *------------------------------------------------------------- 
       2000-PROCESO-I. 
      
           MOVE LENGTH OF MAP4CAFO TO WS-LONG 

           EXEC CICS RECEIVE 
              MAP    (WS-MAP-00) 
              MAPSET (WS-MAPSET-00) 
              INTO   (MAP4CAFI) 
              RESP   (WS-RESP) 
           END-EXEC 
      
           EVALUATE WS-RESP 
      
              WHEN DFHRESP(NORMAL) 
                 MOVE TIPDOCI TO WS-USER-TIPDOC 
                 MOVE NUMDOCI TO WS-USER-NRODOC 

              WHEN DFHRESP(MAPFAIL)
                 MOVE CT-MNS-01 TO MSGO

              WHEN OTHER 
                 MOVE CT-MNS-01 TO MSGO

           END-EVALUATE 
      
           PERFORM 3000-TECLAS-I THRU 3000-TECLAS-F. 
      
       2000-PROCESO-F. EXIT. 
      
      
      *------------------------------------------------------------- 
       3000-TECLAS-I. 
      
           EVALUATE EIBAID 
      
              WHEN DFHENTER 
                 PERFORM 3100-ENTER-I THRU 3100-ENTER-F 
      
              WHEN DFHPF3 
                 PERFORM 3200-PF3-I   THRU 3200-PF3-F 
      
              WHEN DFHPF4 
                 PERFORM 3400-PF4-I THRU 3400-PF4-F 
      
              WHEN DFHPF12 
                 PERFORM 3300-PF12-I  THRU 3300-PF12-F 
      
              WHEN OTHER 
                 MOVE CT-MNS-09 TO  MSGO 
      
           END-EVALUATE
      
           PERFORM 8000-SEND-MAPA-I THRU 8000-SEND-MAPA-F.
      
       3000-TECLAS-F. EXIT. 
      
      *------------------------------------------------------------- 
       3100-ENTER-I. 
      
           PERFORM 3150-VALIDAR-I THRU 3150-VALIDAR-F 
      
           IF CLIENTEOK THEN 
              PERFORM 5000-READ-I THRU 5000-READ-F 
           END-IF. 
      
       3100-ENTER-F. EXIT. 
      
      *------------------------------------------------------------- 
       3150-VALIDAR-I. 
      
           SET CLIENTEOK TO TRUE. 
           MOVE TIPDOCI TO WS-TIP-DOC. 
      
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
      
           MOVE LOW-VALUES TO MAP4CAFO.
           MOVE CT-MNS-01 TO MSGO.
      
       3200-PF3-F. EXIT. 
      
      
      *------------------------------------------------------------- 
       3300-PF12-I. 
      
           EXEC CICS XCTL 
              PROGRAM ('PGMMECAF') 
           END-EXEC. 
      
       3300-PF12-F. EXIT. 
      
      
      *------------------------------------------------------------- 
       3400-PF4-I. 
      
           IF CLIENTEOK THEN
              MOVE TIPDOCI TO WS-USER-TIPDOC 
              MOVE NUMDOCI TO WS-USER-NRODOC 
       
              EXEC CICS DELETE 
                 DATASET (CT-DATASET)
                 RIDFLD  (WS-USER-DATA) 
                 RESP    (WS-RESP)
              END-EXEC
       
              EVALUATE WS-RESP
                 WHEN DFHRESP(NORMAL)
                    MOVE CT-MNS-06 TO MSGO
       
                 WHEN DFHRESP(NOTFND)
                    MOVE CT-MNS-03 TO MSGO
       
                 WHEN OTHER
                    MOVE CT-MNS-08 TO MSGO
       
              END-EVALUATE

           ELSE 
                 MOVE CT-MNS-02 TO MSGO   
           END-IF. 
      
       3400-PF4-F. EXIT. 
      
      
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
                 MOVE CT-MNS-10        TO MSGO 
                 MOVE PER-TIP-DOC      TO TIPDOCO 
                 MOVE PER-NRO-DOC      TO NUMDOCO 
      
              WHEN OTHER 
                 MOVE CT-MNS-08  TO MSGO 
      
           END-EVALUATE.
      
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
              MAP    (WS-MAP-00) 
              MAPSET (WS-MAPSET-00) 
              FROM   (MAP4CAFO) 
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