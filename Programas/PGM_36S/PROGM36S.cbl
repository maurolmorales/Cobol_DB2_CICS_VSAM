       IDENTIFICATION DIVISION. *> ALTA 
       PROGRAM-ID. PROGM36S. 
      
      ***************************************************************** 
      *                   CLASE SINCRÓNICA 36                         * 
      *                   ===================                         * 
      *    ALTA DE CLIENTES                                           * 
      *                                                               * 
      ***************************************************************** 
      
      *|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       DATA DIVISION. 
       FILE SECTION. 
      
       WORKING-STORAGE SECTION. 
      *=======================* 
      
       01  CT-CONSTANTES. 
           03 CT-MSGO. 
              05 CT-MNS-01         PIC X(72)           VALUE 
                                  'INGRESE LOS DATOS Y PRESIONE ENTER'. 
              05 CT-MNS-02         PIC X(72)           VALUE 
                          'TIPO Y NRO DE DOC EXISTENTES - REINGRESAR '. 
              05 CT-MNS-03         PIC X(72)           VALUE 
                            'TIPO DE DOCUMENTO INVALIDO - REINGRESAR '. 
              05 CT-MNS-04         PIC X(72)           VALUE 
                              'NRO DE DOCUMENTO INVALIDO - REINGRESAR'. 
              05 CT-MNS-05         PIC X(72)           VALUE 
                             'NOMBRE Y APELLIDO INVALIDO - REINGRESAR'. 
              05 CT-MNS-06         PIC X(72)           VALUE 
                           'FECHA DE NACIMIENTO INVALIDA - REINGRESAR'. 
              05 CT-MNS-07         PIC X(72)           VALUE 
                                          'SEXO INVALIDO - REINGRESAR'. 
              05 CT-MNS-08         PIC X(72)           VALUE 
                                      'CLIENTE DADO DE ALTA CON EXITO'. 
              05 CT-MNS-09         PIC X(72)           VALUE 
                                     'PROBLEMA CON EL ARCHIVO PERSONA'. 
              05 CT-MNS-10         PIC X(72)           VALUE 
                                                      'TECLA INVALIDA'. 
              05 CT-MNS-EXIT       PIC X(72)           VALUE 
                                                'FIN TRANSACCION T308'. 
           03 CT-DATASET           PIC X(08)           VALUE 
                                                            'PERSOCAF'. 
           03 CT-DATASET-LEN       PIC S9(04) COMP     VALUE 160. 
           03 CT-DATASET-KEYLEN    PIC S9(04) COMP     VALUE 13. 
      
      *-------------------------------------------------------------- 
       01  WS-VARIABLES. 
           03 WS-MAP-00            PIC X(07)           VALUE 'MAP3CAF'. 
           03 WS-MAPSET-00         PIC X(07)           VALUE 'MAP3CAF'. 
           03 WS-TRANSACTION       PIC X(04)           VALUE 'DCAF'. 
           03 WS-LONG              PIC S9(04) COMP. 
           03 WS-COMLONG           PIC S9(04) COMP. 
           03 WS-ABSTIME           PIC S9(16) COMP     VALUE +0. 
           03 WS-FECHA             PIC X(10)           VALUE SPACES. 
           03 WS-SEP-DATE          PIC X               VALUE '/'. 
           03 WS-HORA              PIC X(08)           VALUE SPACES. 
           03 WS-SEP-HOUR          PIC X               VALUE ':'. 
           03 WS-RESP              PIC S9(04) COMP. 
           03 SW-CONFIRMAR         PIC X               VALUE 'Y'. 
           03 WS-NORMAL            PIC X               VALUE '*'. 
           03 WS-ENTER             PIC X               VALUE ' '. 
      
      
      *------------------------------------------------------------- 
           COPY MAP3CAF. 
           COPY DFHBMSCA. 
           COPY DFHAID. 
           COPY CPPERSON. 

      *------------------------------------------------------------- 
       01  WS-COMMAREA. 
           03 WS-USER-DATA. 
              05 WS-USER-TIPDOC    PIC X(02). 
              05 WS-USER-NRODOC    PIC 9(11). 
           03 WS-TIP-DOC           PIC X(02). 
              88 WS-TIP-DOC-BOOLEAN                    VALUE 'DU' 
                                                             'PA' 
                                                             'PE'. 
           03 WS-PRIMERA           PIC 9. 
           03 FILLER               PIC X(4). 
      
      
      *-----------   VARIABLES DE VALIDACION   ---------------------- 
       01  WS-FECHA-VAL. 
           03 WS-ANIO              PIC 9(04)           VALUE ZEROS. 
           03 WS-MES               PIC 9(02)           VALUE ZEROS. 
           03 WS-DIA               PIC 9(02)           VALUE ZEROS. 
      
       77  WS-FECHA-VALIDA         PIC X. 
           88 FECHAOK                                  VALUE 'Y'. 
           88 FECHAOK-NO                               VALUE 'N'. 
      
       77  WS-CLIENTE-VALIDO       PIC X. 
           88 CLIENTEOK                                VALUE 'Y'. 
           88 CLIENTEOK-NO                             VALUE 'N'. 
      
      
       LINKAGE SECTION. 
      *================* 
       01 DFHCOMMAREA PIC X(20). 
      
      *|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       PROCEDURE DIVISION. 
      
       MAIN-PROGRAM-INICIO. 
       
           PERFORM 1000-INICIO-I  THRU 1000-INICIO-F 
           PERFORM 2000-PROCESO-I THRU 2000-PROCESO-F 
           PERFORM 9999-FINAL-I   THRU 9999-FINAL-F. 
       
       MAIN-PROGRAM-FINAL. EXIT. 
       
      *------------------------------------------------------------- 
       1000-INICIO-I. 
       
           MOVE LOW-VALUES TO MAP3CAFO 
           MOVE DFHCOMMAREA TO WS-COMMAREA 
       
           IF EIBCALEN = 0 THEN 
       
              MOVE LENGTH OF MAP3CAFO TO WS-LONG 
              MOVE CT-MNS-01 TO MSGO 
              PERFORM 8000-SENDMAP-I THRU 8000-SENDMAP-F
              PERFORM 9999-FINAL-I THRU 9999-FINAL-F 
      
           END-IF. 
       
       1000-INICIO-F. EXIT. 
      
      
      *------------------------------------------------------------- 
       2000-PROCESO-I. 
      
           MOVE LENGTH OF MAP3CAFO TO WS-LONG 
      
           EXEC CICS RECEIVE 
              MAP    (WS-MAP-00) 
              MAPSET (WS-MAPSET-00) 
              INTO   (MAP3CAFI) 
              RESP   (WS-RESP) 
           END-EXEC 
      
           EVALUATE WS-RESP 
      
              WHEN DFHRESP(NORMAL) 
                 CONTINUE 
      
              WHEN DFHRESP(DUPREC) 
                 MOVE WS-RESP TO MSGO 
      
              WHEN OTHER 
                 MOVE CT-MNS-09 TO MSGO 
                 
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
      
              WHEN DFHPF12 
                PERFORM 3300-PF12-I  THRU 3300-PF12-F 
      
              WHEN OTHER 
                 MOVE CT-MNS-10 TO  MSGO 
                 PERFORM 8000-SENDMAP-I THRU 8000-SENDMAP-F
           END-EVALUATE. 
      
       3000-TECLAS-F. EXIT. 
      
      
      *------------------------------------------------------------- 
       3100-ENTER-I. 
      
           PERFORM 3150-VALIDAR-I THRU 3150-VALIDAR-F 
      
           IF CLIENTEOK THEN 
              PERFORM 5000-WRITE-I THRU 5000-WRITE-F 
           ELSE 
              PERFORM 8000-SENDMAP-I THRU 8000-SENDMAP-F
           END-IF. 
      
       3100-ENTER-F. EXIT. 
      
      *------------------------------------------------------------- 
       3150-VALIDAR-I. 
      
           SET CLIENTEOK TO TRUE
           MOVE TIPDOCI TO WS-TIP-DOC
      
           PERFORM 3700-VERIF-FECHA-I THRU 3700-VERIF-FECHA-F 
      
           EVALUATE TRUE 
      
              WHEN NOT WS-TIP-DOC-BOOLEAN 
                   SET CLIENTEOK-NO TO TRUE 
                   MOVE CT-MNS-03  TO MSGO 
              WHEN NOT WS-TIP-DOC-BOOLEAN 
                   SET CLIENTEOK-NO TO TRUE 
                   MOVE CT-MNS-03  TO MSGO 
              WHEN NUMDOCI IS NOT NUMERIC 
                   SET CLIENTEOK-NO TO TRUE 
                   MOVE CT-MNS-04  TO MSGO 
              WHEN NUMDOCI IS EQUAL ZEROS 
                   SET CLIENTEOK-NO TO TRUE 
                   MOVE CT-MNS-04  TO MSGO 
              WHEN NOMAPEI IS EQUAL TO (SPACES OR LOW-VALUES) 
                   MOVE -1 TO NOMAPEL 
                   SET CLIENTEOK-NO TO TRUE 
                   MOVE CT-MNS-05  TO MSGO 
              WHEN FECHAOK-NO 
                   SET CLIENTEOK-NO TO TRUE 
                   MOVE CT-MNS-06  TO MSGO 
              WHEN NOT (SEXOI = 'F' OR SEXOI = 'M' OR SEXOI = 'O') 
                   MOVE -1 TO SEXOL 
                   SET CLIENTEOK-NO TO TRUE 
                   MOVE CT-MNS-07  TO MSGO 
              WHEN OTHER 
                   CONTINUE 
      
           END-EVALUATE. 
      
       3150-VALIDAR-F. EXIT. 
      
      
      *------------------------------------------------------------- 
       3700-VERIF-FECHA-I. 
      
           SET FECHAOK TO TRUE 
      
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
      
              IF WS-MES < 00 OR WS-MES > 13 THEN 
                 SET FECHAOK-NO TO TRUE 
              END-IF 
      
              IF WS-MES = 02 THEN 
                 IF WS-DIA > 28 THEN 
                    SET FECHAOK-NO TO TRUE 
                 END-IF 
              END-IF 
      
              IF WS-MES IS EQUAL TO (4 OR 6 OR 9 OR 11) AND 
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
      
           MOVE LOW-VALUES TO MAP3CAFO 
           PERFORM 7000-TIME-I THRU 7000-TIME-F 
           MOVE CT-MNS-01 TO MSGO 
      
           PERFORM 8000-SENDMAP-I THRU 8000-SENDMAP-F.
      
       3200-PF3-F. EXIT. 
      
      
      *------------------------------------------------------------- 
       3300-PF12-I. 
      
           EXEC CICS XCTL 
              PROGRAM ('PGMMECAF') 
           END-EXEC.
      
       3300-PF12-F. EXIT. 
      
      
      *------------------------------------------------------------- 
       5000-WRITE-I. 
      
           MOVE TIPDOCI TO WS-USER-TIPDOC 
           MOVE NUMDOCI TO WS-USER-NRODOC 
      
           MOVE SPACES       TO REG-PERSONA 
           MOVE TIPDOCI      TO PER-TIP-DOC 
           MOVE NUMDOCI      TO PER-NRO-DOC 
           MOVE ZEROS        TO PER-CLI-NRO 
           MOVE NOMAPEI      TO PER-NOMAPE 
           MOVE WS-FECHA-VAL TO PER-CLI-AAAAMMDD 
           MOVE SPACES       TO PER-DIRECCION 
           MOVE SPACES       TO PER-LOCALIDAD 
           MOVE SPACES       TO PER-EMAIL 
           MOVE SPACES       TO PER-TELEFONO 
           MOVE SEXOI        TO PER-SEXO 
      
           EXEC CICS WRITE 
              FILE      (CT-DATASET) 
              FROM      (REG-PERSONA) 
              RIDFLD    (WS-USER-DATA) 
              LENGTH    (CT-DATASET-LEN) 
              KEYLENGTH (CT-DATASET-KEYLEN) 
              RESP      (WS-RESP) 
           END-EXEC 
      
           EVALUATE WS-RESP 
              WHEN DFHRESP(DUPREC) 
                 MOVE CT-MNS-02  TO MSGO 
              WHEN DFHRESP(NORMAL) 
                 MOVE CT-MNS-08  TO MSGO 
              WHEN OTHER 
                 MOVE CT-MNS-09  TO MSGO 
           END-EVALUATE 
      
           PERFORM 8000-SENDMAP-I THRU 8000-SENDMAP-F.
      
       5000-WRITE-F. EXIT. 
      
      
      *------------------------------------------------------------- 
       7000-TIME-I. 
      
           EXEC CICS ASKTIME 
              ABSTIME (WS-ABSTIME) 
           END-EXEC. 
      
           EXEC CICS FORMATTIME 
              ABSTIME (WS-ABSTIME) 
              DDMMYYYY (WS-FECHA) DATESEP(WS-SEP-DATE) 
              TIME (WS-HORA) TIMESEP(WS-SEP-HOUR) 
           END-EXEC 
      
           MOVE WS-FECHA TO FECHAO. 
      
       7000-TIME-F. EXIT. 
      
      *------------------------------------------------------------- 
       8000-SENDMAP-I.
           
           PERFORM 7000-TIME-I THRU 7000-TIME-F 
      
           EXEC CICS SEND 
              MAP    (WS-MAP-00) 
              MAPSET (WS-MAPSET-00) 
              FROM   (MAP3CAFO) 
              LENGTH (WS-LONG) 
              ERASE 
           END-EXEC.
      
       8000-SENDMAP-F. EXIT.
      *------------------------------------------------------------- 
       9999-FINAL-I. 
      
           EXEC CICS RETURN 
              TRANSID  (WS-TRANSACTION) 
              COMMAREA (WS-COMMAREA) 
            END-EXEC. 
      
       9999-FINAL-F. EXIT.