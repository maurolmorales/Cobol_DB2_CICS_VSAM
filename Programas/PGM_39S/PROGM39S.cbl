       IDENTIFICATION DIVISION. *> modificación
       PROGRAM-ID. PROGM39S. 
      
      *****************************************************************
      *                   CLASE SINCRÓNICA 39                         *
      *                   ===================                         *
      *    MODIFICACION DE CLIENTES                                   *
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
                                         "NOMBRE/APELLIDO OBLIGATORIO".
             05 CT-MNS-03         PIC X(72) VALUE 
                    'TIPO Y NÚMERO DOCUMENTO INEXISTENTES - REINGRESE'. 
             05 CT-MNS-04         PIC X(72) VALUE 
                                          'TIPO DE DOCUMENTO INVALIDO'. 
             05 CT-MNS-05         PIC X(72) VALUE 
                                        'NUMERO DE DOCUMENTO INVALIDO'. 
             05 CT-MNS-06         PIC X(72) VALUE 
                                        'CLIENTE MODIFICADO CON ÉXITO'. 
             05 CT-MNS-07         PIC X(72) VALUE 
                                          'SEXO INVALIDO - REINGRESAR'.
             05 CT-MNS-08         PIC X(72) VALUE 
                                        'PROBLEMA CON ARCHIVO PERSONA'. 
             05 CT-MNS-09         PIC X(72) VALUE     'TECLA INVALIDA'. 
             05 CT-MNS-EXIT       PIC X(72) VALUE 
                                                'FIN TRANSACCION T199'. 
             05 CT-MNS-10         PIC X(72) VALUE     'ERROR SEND    '.  
             05 CT-MNS-11         PIC X(72) VALUE     'FECHA INVÁLIDA'.
        
           03 CT-DATASET          PIC X(08)           VALUE 'PERSOCAF'. 
           03 CT-DATASET-LEN      PIC S9(04) COMP     VALUE 160. 
           03 CT-DATASET-KEYLEN   PIC S9(04) COMP     VALUE 13. 
           
      *-------------------------------------------------------------- 
       01  WS-VARIABLES. 
           03 WS-MAP            PIC X(07)          VALUE 'MAP5CAF'. 
           03 WS-MAPSET         PIC X(07)          VALUE 'MAP5CAF'. 
           03 WS-TRANSACTION       PIC X(04)          VALUE 'FCAF'. 
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
           COPY MAP5CAF. 
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
       01 DFHCOMMAREA PIC X(160). 
        
        
      *|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       PROCEDURE DIVISION. 
        
       MAIN-PROGRAM-INICIO. 
        
           PERFORM 1000-INICIO-I   THRU 1000-INICIO-F 
           PERFORM 2000-PROCESO-I  THRU 2000-PROCESO-F 
           PERFORM 9999-FINAL-I    THRU 9999-FINAL-F. 
        
       MAIN-PROGRAM-FINAL. EXIT. 
        
        
      *------------------------------------------------------------- 
       1000-INICIO-I. 
        
           MOVE LOW-VALUES TO MAP5CAFO. 
           MOVE DFHCOMMAREA TO WS-COMMAREA. 
        
           IF EIBCALEN = 0 THEN 
      
              MOVE LENGTH OF MAP5CAFO TO WS-LONG 
              MOVE CT-MNS-01 TO MSGO 
              PERFORM 8000-SEND-MAPA-I THRU 8000-SEND-MAPA-F
              PERFORM 9999-FINAL-I THRU 9999-FINAL-F 
      
           END-IF. 
        
       1000-INICIO-F. EXIT. 
        
        
      *------------------------------------------------------------- 
       2000-PROCESO-I. 
           
           MOVE LENGTH OF MAP5CAFO TO WS-LONG 
      
           EXEC CICS RECEIVE 
              MAP    (WS-MAP) 
              MAPSET (WS-MAPSET) 
              INTO   (MAP5CAFI) 
              RESP   (WS-RESP) 
           END-EXEC 
      
           EVALUATE WS-RESP 
      
              WHEN DFHRESP(NORMAL) 
                 CONTINUE
      
              WHEN DFHRESP (MAPFAIL) 
                 MOVE LOW-VALUES TO MAP5CAFO 
                 MOVE CT-MNS-01  TO MSGO 
                 PERFORM 8000-SEND-MAPA-I THRU 8000-SEND-MAPA-F
                 PERFORM 9999-FINAL-I THRU 9999-FINAL-F 
      
              WHEN OTHER 
                 MOVE CT-MNS-08  TO MSGO 
                 PERFORM 8000-SEND-MAPA-I THRU 8000-SEND-MAPA-F
                 PERFORM 9999-FINAL-I THRU 9999-FINAL-F
      
           END-EVALUATE
      
           MOVE TIPDOCI TO WS-USER-TIPDOC
           MOVE NUMDOCI TO WS-USER-NRODOC
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
      
           PERFORM 3700-VERIF-FECHA-I THRU 3700-VERIF-FECHA-F       
      
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
              WHEN NOMAPEI = SPACES OR NOMAPEI = LOW-VALUES
                   MOVE -1 TO NOMAPEL 
                   SET CLIENTEOK-NO TO TRUE 
                   MOVE CT-MNS-02  TO MSGO 
              WHEN FECHAOK-NO 
                   SET CLIENTEOK-NO TO TRUE 
                   MOVE CT-MNS-11  TO MSGO     
              WHEN NOT (SEXOI = 'F' OR  SEXOI = 'M' OR SEXOI = 'O') 
                   MOVE -1 TO SEXOL 
                   SET CLIENTEOK-NO TO TRUE 
                   MOVE CT-MNS-07  TO MSGO                     
              WHEN OTHER 
                   CONTINUE 
      
           END-EVALUATE. 
      
       3150-VALIDAR-F. EXIT. 
      
      
      *-------------------------------------------------------------
       3700-VERIF-FECHA-I. 
      
           SET FECHAOK TO TRUE. 
      
           MOVE ANIOI TO WS-ANIO 
           MOVE MESI  TO WS-MES 
           MOVE DIAI  TO WS-DIA 
      
           IF WS-ANIO IS NOT NUMERIC OR 
              WS-MES  IS NOT NUMERIC OR 
              WS-DIA  IS NOT NUMERIC THEN
                 SET FECHAOK-NO TO TRUE 
           END-IF 
      
           IF FECHAOK THEN
              IF WS-ANIO < 1950 OR WS-ANIO > 2020 THEN
                 SET FECHAOK-NO TO TRUE 
              END-IF 
      
              IF WS-MES < 01 OR WS-MES > 12 THEN
                 SET FECHAOK-NO TO TRUE 
              END-IF 
      
              IF WS-MES = 02 THEN
                 IF WS-DIA > 28 THEN
                    SET FECHAOK-NO TO TRUE 
                 END-IF 
              END-IF 
      
              IF WS-MES IS EQUAL TO 4  OR 
                 WS-MES IS EQUAL TO 6  OR 
                 WS-MES IS EQUAL TO 9  OR 
                 WS-MES IS EQUAL TO 11 AND 
                 WS-DIA > 30 THEN
                    SET FECHAOK-NO TO TRUE 
              END-IF 
              IF WS-MES IS EQUAL TO 
                 (1 OR 3 OR 5 OR 7 OR 8 OR 10 OR 12) AND 
                 WS-DIA > 31 THEN
                    SET FECHAOK-NO TO TRUE 
              END-IF 
      
           END-IF. 
      
       3700-VERIF-FECHA-F. EXIT.       
      
      
      *------------------------------------------------------------- 
       3200-PF3-I. 
      
           MOVE LOW-VALUES TO MAP5CAFO. 
           MOVE CT-MNS-01 TO MSGO.
        
       3200-PF3-F. EXIT. 
        
        
      *------------------------------------------------------------- 
       3400-PF4-I. 
        
           EXEC CICS XCTL 
              PROGRAM ('PGMMECAF') 
              COMMAREA (WS-COMMAREA) 
           END-EXEC. 
        
       3400-PF4-F. EXIT. 
      
      
      *------------------------------------------------------------- 
       3300-PF12-I. 
      
           EXEC CICS XCTL 
              PROGRAM ('PGMMECAF') 
           END-EXEC. 
        
       3300-PF12-F. EXIT. 
        
      
      *------------------------------------------------------------- 
       5000-READ-I. 
      
           MOVE TIPDOCI TO WS-USER-TIPDOC 
           MOVE NUMDOCI TO WS-USER-NRODOC 
      
           EXEC CICS READ 
              DATASET (CT-DATASET) 
              UPDATE
              RIDFLD  (WS-USER-DATA) 
              INTO    (REG-PERSONA) 
              LENGTH  (CT-DATASET-LEN) 
              EQUAL 
              RESP    (WS-RESP) 
           END-EXEC 
      
           EVALUATE WS-RESP 
      
              WHEN DFHRESP(NORMAL) 
                 PERFORM 5000-REWRITE-I THRU 5000-REWRITE-F 
      
              WHEN DFHRESP(NOTFND) 
                 MOVE CT-MNS-03        TO MSGO 
                 MOVE WS-USER-TIPDOC   TO TIPDOCO 
                 MOVE WS-USER-NRODOC   TO NUMDOCO 
      
              WHEN OTHER 
                 MOVE CT-MNS-08  TO MSGO 
      
           END-EVALUATE.
      
       5000-READ-F. EXIT. 
      
      
      *------------------------------------------------------------- 
       5000-REWRITE-I. 
        
           MOVE TIPDOCI TO WS-USER-TIPDOC 
           MOVE NUMDOCI TO WS-USER-NRODOC 
           
           MOVE SPACES       TO REG-PERSONA. 
           MOVE TIPDOCI      TO PER-TIP-DOC. 
           MOVE NUMDOCI      TO PER-NRO-DOC. 
           MOVE ZEROS        TO PER-CLI-NRO. 
           MOVE NOMAPEI      TO PER-NOMAPE. 
           MOVE WS-FECHA-VAL TO PER-CLI-AAAAMMDD. 
           MOVE SPACES       TO PER-DIRECCION. 
           MOVE SPACES       TO PER-LOCALIDAD. 
           MOVE SPACES       TO PER-EMAIL. 
           MOVE SPACES       TO PER-TELEFONO. 
           MOVE SEXOI        TO PER-SEXO.         
      
           EXEC CICS REWRITE 
                DATASET (CT-DATASET) 
                FROM    (REG-PERSONA) 
                LENGTH  (CT-DATASET-LEN)
                RESP    (WS-RESP)  
           END-EXEC 
        
           EVALUATE WS-RESP 
              
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
      
              WHEN DFHRESP(NOTFND) 
                 MOVE CT-MNS-03        TO MSGO 
      
              WHEN OTHER 
                 MOVE CT-MNS-08  TO MSGO 
           END-EVALUATE 
        
           PERFORM 8000-SEND-MAPA-I THRU 8000-SEND-MAPA-F.
        
       5000-REWRITE-F. EXIT. 
        
        
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
      
      
      *---------------------------------------------------------- 
       8000-SEND-MAPA-I.
      
           PERFORM 7000-TIME-I THRU 7000-TIME-F 
      
           EXEC CICS SEND 
               MAP    (WS-MAP) 
               MAPSET (WS-MAPSET) 
               FROM   (MAP5CAFO) 
               LENGTH (WS-LONG) 
               ERASE 
               RESP   (WS-RESP) 
           END-EXEC.
      
       8000-SEND-MAPA-F. EXIT.
       
       
      *------------------------------------------------------------- 
       9999-FINAL-I. 
        
           EXEC CICS RETURN
              TRANSID  (WS-TRANSACTION) 
              COMMAREA (WS-COMMAREA) 
           END-EXEC. 
        
       9999-FINAL-F. EXIT.