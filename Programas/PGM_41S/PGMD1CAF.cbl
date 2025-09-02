       IDENTIFICATION DIVISION. 
       PROGRAM-ID. PGMD1CAF. 
 
      *************************************************************** 
      *    MODELO DE DOS CORTE CONTROL                              *
      *    ============================                             *
      *  FUNCIONAMIENTO
      *  * Leer las novedades de clientes (modificaciones).
      *  * Validar los datos según el tipo de novedad (ej.: si solo 
      *  cambia NROCLI  → solo validar ese campo).
      *  * Si la validación es correcta → hacer UPDATE en la tabla 
      *  TBCURCLI.
      *
      *  Si hay error generar un listado (FBA 132 bytes) con detalle:
      *  - Título: MODIFICACIONES LEÍDAS – Detalle de errores
      *  - Subtítulo con columnas: TIPO DOC, NUM DOC, NROCLI, APELLIDO,
      *    SEXO, FECHA NAC.     
      *  
      *  ESTADÍSTICAS AL FINAL
      *    Total modificaciones leídas.
      *    Total con error.
      *    Total grabadas en la tabla.
      *    
      ****************************************************************
      
      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       ENVIRONMENT DIVISION. 
       CONFIGURATION SECTION. 
      
       SPECIAL-NAMES. 
           DECIMAL-POINT IS COMMA. 
      
       INPUT-OUTPUT SECTION. 
       FILE-CONTROL. 
      
           SELECT ENTRADA ASSIGN DDENTRA
           FILE STATUS IS FS-NOVEDADES.
      
           SELECT SALIDA  ASSIGN DDSALID
           FILE STATUS IS FS-SALIDA.
      
      
      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       DATA DIVISION. 
       FILE SECTION.
      
       FD  ENTRADA                                              
           BLOCK CONTAINS 0 RECORDS                             
           RECORDING MODE IS F.                                 
       01  REG-ENTRADA  PIC X(80).                              
      
       FD  SALIDA                                               
           BLOCK CONTAINS 0 RECORDS                             
           RECORDING MODE IS F.                                 
       01  REG-SALIDA   PIC X(133).                           
      
      
       WORKING-STORAGE SECTION.
      *========================* 
      
      *----------- STATUS ARCHIVOS  --------------------------------- 
       77  FS-NOVEDADES           PIC XX       VALUE SPACES.    
       77  FS-SALIDA              PIC XX       VALUE SPACES.    
      
       77  WS-STATUS-FIN          PIC X. 
           88  WS-FIN-LECTURA         VALUE 'Y'. 
           88  WS-NO-FIN-LECTURA      VALUE 'N'. 
      
       77  WS-STATUS-NOV          PIC X. 
           88  WS-FIN-NOV             VALUE 'Y'. 
           88  WS-NO-FIN-NOV          VALUE 'N'. 
      
       77  WS-STATUS-ENT          PIC X. 
           88  WS-FIN-ENT             VALUE 'Y'. 
           88  WS-NO-FIN-ENT          VALUE 'N'.            
      
      *-----------  CONTADORES  -------------------------------------
       77  TOT-MOD-LEIDAS         PIC 999        VALUE ZEROES.
       77  TOT-MOD-ERRORES        PIC 999        VALUE ZEROES.
       77  TOT-MOD-GRABADAS       PIC 999        VALUE ZEROES.
       77  WS-FORMATO-PRINT       PIC ZZ9        VALUE ZEROES. 
      
      *-------------  VARIABLES -------------------------------------
       77  WS-PRIMER-ERROR        PIC X(02)      VALUE 'SI'. 
       77  WS-MESSAGE-ERROR       PIC X(32)      VALUE SPACES. 
      
       77  REG-TIPDOC           PIC X(02)        VALUE SPACES.
       77  REG-NRODOC           PIC S9(11)V USAGE COMP-3 VALUE ZEROES.
       77  REG-NROCLI           PIC S9(03)V USAGE COMP-3 VALUE ZEROES.
       77  REG-NOMAPE           PIC X(30)        VALUE SPACES.
       77  REG-SEXO             PIC X(01)        VALUE SPACES.
       77  REG-FECNAC           PIC X(08)        VALUE SPACES.
      
      *-----------  SQL  -------------------------------------- 
       77  WS-SQLCODE     PIC +++999 USAGE DISPLAY VALUE ZEROS. 
       77  NOT-FOUND              PIC S9(9) COMP VALUE  +100.  
       77  NOTFOUND-FORMAT        PIC -ZZZZZZZZZZ.             
      
      *-----------  IMPRESION  --------------------------------- 
       77  WS-PIPE                PIC XXX        VALUE '|'.      
       77  WS-LINE                PIC X(132)     VALUE ALL '='.  
       77  WS-LINE2               PIC X(132)     VALUE ALL '-'. 
       77  WS-SEPARATE             PIC X(132)    VALUE SPACES.
       77  IMP-TITULO             PIC X(42)      VALUE 
                          'MODIFICACIONES LEÍDAS - Detalle de errores'.
       
       01  IMP-MJE-ERROR.
           03  FILLER            PIC X(18) VALUE 'MOTIVO DEL ERROR: '.
           03  MJE-ERROR         PIC X(40).
      
       01  IMP-SUBTITULO.                                        
           03  FILLER              PIC X(03)        VALUE ' | '.
           03  IMP-TIP-DOC         PIC X(07)    VALUE 'TIP-DOC'. 
           03  FILLER              PIC X(03)        VALUE ' | '.
           03  FILLER              PIC X(04)    VALUE SPACES.  
           03  IMP-NRO-DOC         PIC X(07)    VALUE 'NRO-DOC'. 
           03  FILLER              PIC X(03)        VALUE ' | '.
           03  IMP-CLI-NRO         PIC X(07)    VALUE 'NRO-CLI'. 
           03  FILLER              PIC X(03)        VALUE ' | '.
           03  FILLER              PIC X(12)    VALUE SPACES.  
           03  IMP-CLI-NOMBRE      PIC X(06)    VALUE 'NOMAPE'. 
           03  FILLER              PIC X(12)    VALUE SPACES.  
           03  FILLER              PIC X(03)        VALUE ' | '.
           03  IMP-CLI-SEXO        PIC X(04)    VALUE 'SEXO'. 
           03  FILLER              PIC X(03)        VALUE ' | '.
           03  IMP-CLI-FENAC       PIC X(09)    VALUE 'FECHA NAC'. 
           03  FILLER              PIC X(03)        VALUE ' | '.
      
       01  IMP-REG-ERRONEO.
           03  FILLER              PIC X(03)        VALUE ' | '.
           03  FILLER              PIC X(05)    VALUE SPACES.      
           03  IMP-TIPDOC          PIC X(02).
           03  FILLER              PIC X(03)        VALUE ' | '.
           03  IMP-NRODOC          PIC X(11).
           03  FILLER              PIC X(03)        VALUE ' | '.   
           03  FILLER              PIC X(04)    VALUE SPACES.     
           03  IMP-NROCLI          PIC X(03).
           03  FILLER              PIC X(03)        VALUE ' | '.
           03  IMP-NOMAPE          PIC X(30).
           03  FILLER              PIC X(03)        VALUE ' | '.
           03  FILLER              PIC X(03)    VALUE SPACES.  
           03  IMP-SEXO            PIC X(01).
           03  FILLER              PIC X(03)        VALUE ' | '.
           03  FILLER              PIC X(01)    VALUE SPACES.  
           03  IMP-FECNAC          PIC X(08).
           03  FILLER              PIC X(03)        VALUE ' | '.
      
      *//////////////// COPYS //////////////////////////////////////
      *    EXEC SQL DECLARE KC02803.TBCURCLI TABLE                     
      *    ( TIPDOC                         CHAR(2) NOT NULL,          
      *      NRODOC                         DECIMAL(11, 0) NOT NULL,   
      *      NROCLI                         DECIMAL(3, 0) NOT NULL,    
      *      NOMAPE                         CHAR(30) NOT NULL,         
      *      FECNAC                         DATE NOT NULL,             
      *      SEXO                           CHAR(1) NOT NULL           
      *    ) END-EXEC. 
       01  DCLTBCURCLI. 
           10 CLI-TIPDOC      PIC X(2).                 
           10 CLI-NRODOC      PIC S9(11)V USAGE COMP-3. 
           10 CLI-NROCLI      PIC S9(3)V USAGE COMP-3.  
           10 CLI-NOMAPE      PIC X(30).                
           10 CLI-FECNAC      PIC X(10).                
           10 CLI-SEXO        PIC X(1).                 
      
      *-----------------------------------------------------------
       01  WS-REG-NOVECLI. 
      
      * TIP-NOV = AL  ALTA CLIENTE 
      * TIP-NOV = CL  MODIF. NRO CLIENTE 
      * TIP-NOV = CN  MODIF. NOMBRE DEL CLIENTE 
      * TIP-NOV = CX  MODIF. SEXO 
           03  NOV-TIP-NOV         PIC X(02)    VALUE SPACES. 
      
      * TIP-DOC = DU; PA; PE 
           03  NOV-TIP-DOC         PIC X(02)    VALUE SPACES. 
      
      * NRO-DOC = NUMERICO 
           03  NOV-NRO-DOC         PIC 9(11)    VALUE ZEROS. 

      * CLI-NRO = NUMERICO 
           03  NOV-CLI-NRO         PIC 9(03)    VALUE ZEROS. 

      * CLI-NOMBRE NOT EQUAL SPACES - 

      * CONDICION PARA GENERAR EL DATO DE PRUEBA: 
      * LAS 6 PRIMERAS LETRAS DE NOV-CLI-NOMBRE SERáN LAS 6 PRAS LETRAS 
      * DEL APELLIDO DEL PROGRAMADOR QUE ARMA LOS DATOS DE PRUEBA 
           03  NOV-CLI-NOMBRE      PIC X(30)    VALUE SPACES. 

      * CLI-FECNAC FECHA LÓGICA (AAAAMMDD) 
           03  NOV-CLI-FENAC       PIC X(08)    VALUE SPACES. 

      * CLI-SEXO = F; M; O 
           03  NOV-CLI-SEXO        PIC X        VALUE SPACES. 
           03  FILLER              PIC X(23)    VALUE SPACES. 
      
      *//////////////////////////////////////////////////////////////
      
      *     COPY NOVECLIE. 
      
      *---- SQLCA COMMUNICATION AREA CON EL DB2  --------------- 
           EXEC SQL INCLUDE SQLCA END-EXEC.                      
           EXEC SQL INCLUDE TBCURCLI END-EXEC.                   
      
      *     EXEC SQL                                              
      *        DECLARE INNERJOIN  CURSOR FOR                      
      *       SENTENCIA SQL..                                     
      *     END-EXEC.                                             
      
      
      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       PROCEDURE DIVISION. 
      
       MAIN-PROGRAM-I. 
      
           PERFORM 1000-INICIO-I  THRU  1000-INICIO-F. 
           PERFORM 2000-PROCESO-I THRU  2000-PROCESO-F 
                                  UNTIL WS-FIN-LECTURA. 
           PERFORM 9999-FINAL-I   THRU  9999-FINAL-F. 
               
       MAIN-PROGRAM-F. GOBACK. 
      
      
      *-------------------------------------------------------------- 
       1000-INICIO-I. 
           
           SET WS-NO-FIN-LECTURA TO TRUE 
      
           OPEN INPUT ENTRADA.                                   
           IF FS-NOVEDADES IS NOT EQUAL '00' THEN                
              DISPLAY '* ERROR EN OPEN ENTRADA INICIO = ' FS-NOVEDADES
              SET  WS-FIN-LECTURA TO TRUE                        
           END-IF                                               
      
           OPEN OUTPUT SALIDA                                    
           IF FS-SALIDA IS NOT EQUAL '00' THEN                  
              DISPLAY '* ERROR EN OPEN SALIDA = ' FS-SALIDA      
              MOVE 9999 TO RETURN-CODE                           
              SET  WS-FIN-LECTURA TO TRUE                        
           END-IF                                               
      
           PERFORM 2100-LEER-I THRU 2100-LEER-F. 
      
       1000-INICIO-F. EXIT. 
      
      
      *-------------------------------------------------------------- 
       2000-PROCESO-I. 
      
           PERFORM 2200-VERIFICAR-I THRU 2200-VERIFICAR-F 
           PERFORM 2100-LEER-I THRU 2100-LEER-F.
      
       2000-PROCESO-F. EXIT. 
      
      
      *--------------------------------------------------------------
       2100-LEER-I. 
      
           READ ENTRADA INTO WS-REG-NOVECLI 
                       
           EVALUATE FS-NOVEDADES 
      
              WHEN '00' 
                 ADD 1 TO TOT-MOD-LEIDAS 
      
              WHEN '10' 
                 SET WS-FIN-LECTURA TO TRUE 
      
              WHEN OTHER 
                 DISPLAY '*ERROR EN LECTURA ENTRADA INICIO : ' 
                                                 FS-NOVEDADES 
                 SET WS-FIN-LECTURA TO TRUE 
      
           END-EVALUATE. 
      
       2100-LEER-F. EXIT. 
      
      *--------------------------------------------------------------
       2200-VERIFICAR-I.
      
           EVALUATE NOV-TIP-NOV
      
               WHEN 'CL'
                 IF NOV-CLI-NRO IS NUMERIC THEN
                    PERFORM 2400-GRABAR-REG-I 
                       THRU 2400-GRABAR-REG-F
                 ELSE 
                    MOVE 'EL NÚMERO DE CLIENTE NO ES NUMÉRICO' 
                      TO WS-MESSAGE-ERROR
                    PERFORM 2300-HANDLE-ERROR-I
                       THRU 2300-HANDLE-ERROR-F
                 END-IF 
      
               WHEN 'CN'
                 IF NOV-CLI-NOMBRE IS NOT EQUAL TO SPACES THEN
                    PERFORM 2400-GRABAR-REG-I 
                       THRU 2400-GRABAR-REG-F
                 ELSE 
                    MOVE 'NOMBRE NO DEBE ESTAR VACÍO'
                      TO WS-MESSAGE-ERROR
                    PERFORM 2300-HANDLE-ERROR-I
                       THRU 2300-HANDLE-ERROR-F
                 END-IF               
      
               WHEN 'CX'
                 IF NOV-CLI-SEXO = 'F' OR
                    NOV-CLI-SEXO = 'M' OR
                    NOV-CLI-SEXO = 'O' THEN
                       PERFORM 2400-GRABAR-REG-I
                          THRU 2400-GRABAR-REG-F
                 ELSE 
                    MOVE 'SEXO INVÁLIDO' TO WS-MESSAGE-ERROR
                    PERFORM 2300-HANDLE-ERROR-I
                       THRU 2300-HANDLE-ERROR-F
                 END-IF                
                  
               WHEN OTHER
                 MOVE 'TIPO DE NOVEDAD NO VÁLIDO' TO WS-MESSAGE-ERROR
                 PERFORM 2300-HANDLE-ERROR-I
                    THRU 2300-HANDLE-ERROR-F
      
           END-EVALUATE.
      
       2200-VERIFICAR-F. EXIT.
      
      
      *--------------------------------------------------------------
       2300-HANDLE-ERROR-I.
      
           IF WS-PRIMER-ERROR = 'SI' THEN
              MOVE 'NO' TO WS-PRIMER-ERROR 
              WRITE REG-SALIDA FROM IMP-TITULO
              WRITE REG-SALIDA FROM IMP-SUBTITULO
              WRITE REG-SALIDA FROM WS-SEPARATE
           END-IF
      
           MOVE NOV-TIP-DOC       TO REG-TIPDOC 
           MOVE NOV-NRO-DOC       TO REG-NRODOC 
           MOVE NOV-CLI-NRO       TO REG-NROCLI 
           MOVE NOV-CLI-NOMBRE    TO REG-NOMAPE 
           MOVE NOV-CLI-FENAC     TO REG-FECNAC 
           MOVE NOV-CLI-SEXO      TO REG-SEXO 
           MOVE WS-MESSAGE-ERROR TO MJE-ERROR
              
           WRITE REG-SALIDA FROM IMP-MJE-ERROR
           WRITE REG-SALIDA FROM IMP-REG-ERRONEO

           ADD 1 TO TOT-MOD-ERRORES. 
      
       2300-HANDLE-ERROR-F. EXIT.
      
      
      *--------------------------------------------------------------
       2400-GRABAR-REG-I.
           
           IF FS-NOVEDADES IS EQUAL '00' THEN
           
              MOVE NOV-TIP-DOC       TO REG-TIPDOC IMP-TIPDOC
              MOVE NOV-NRO-DOC       TO REG-NRODOC IMP-NRODOC
              MOVE NOV-CLI-NRO       TO REG-NROCLI IMP-NROCLI
              MOVE NOV-CLI-NOMBRE    TO REG-NOMAPE IMP-NOMAPE
              MOVE NOV-CLI-FENAC     TO REG-FECNAC IMP-FECNAC
              MOVE NOV-CLI-SEXO      TO REG-SEXO   IMP-SEXO
      
              EVALUATE NOV-TIP-NOV
                 WHEN 'CL'
                    PERFORM 2410-UPDATE-CL-I THRU 2410-UPDATE-CL-F
      
                 WHEN 'CN'
                    PERFORM 2420-UPDATE-CN-I THRU 2420-UPDATE-CN-F  
      
                 WHEN 'CX'   
                    PERFORM 2430-UPDATE-CX-I THRU 2430-UPDATE-CX-F  
      
                 WHEN OTHER
                    MOVE 'TIPO DE NOVEDAD NO VÁLIDO' 
                      TO WS-MESSAGE-ERROR
                    PERFORM 2300-HANDLE-ERROR-I
                       THRU 2300-HANDLE-ERROR-F
              END-EVALUATE 
      
              IF SQLCODE = NOT-FOUND THEN
                 MOVE SQLCODE TO NOTFOUND-FORMAT
                 DISPLAY 'REGISTRO NO ENCONTRADO: ' NOTFOUND-FORMAT
              ELSE 
                 IF SQLCODE = 0 THEN
                    ADD 1 TO TOT-MOD-GRABADAS 
                    DISPLAY 'REGISTRO GRABADO'
                 ELSE 
                    MOVE SQLCODE TO NOTFOUND-FORMAT 
                    DISPLAY 'ERROR DB2: ' NOTFOUND-FORMAT 
                 END-IF 
              END-IF 
           END-IF. 
      
       2400-GRABAR-REG-F. EXIT.
      
      *--------------------------------------------------------------
       2410-UPDATE-CL-I.
      
           EXEC SQL UPDATE KC02803.TBCURCLI
              SET NROCLI   = :REG-NROCLI
              WHERE TIPDOC = :REG-TIPDOC 
                AND NRODOC = :REG-NRODOC
           END-EXEC.
      
       2410-UPDATE-CL-F. EXIT.
      
      *--------------------------------------------------------------
       2420-UPDATE-CN-I.
           
           EXEC SQL UPDATE KC02803.TBCURCLI
              SET NOMAPE   = :REG-NOMAPE
              WHERE TIPDOC = :REG-TIPDOC
              AND   NRODOC = :REG-NRODOC
           END-EXEC.
      
       2420-UPDATE-CN-F. EXIT.
      
      *--------------------------------------------------------------
       2430-UPDATE-CX-I.
      
           EXEC SQL UPDATE KC02803.TBCURCLI
              SET SEXO     = :REG-SEXO
              WHERE TIPDOC = :REG-TIPDOC
                AND NRODOC = :REG-NRODOC
           END-EXEC.
      
       2430-UPDATE-CX-F. EXIT.
      
      
      *--------------------------------------------------------------
       9999-FINAL-I. 
              
           DISPLAY '**********************************************' 
           MOVE TOT-MOD-LEIDAS TO WS-FORMATO-PRINT
           DISPLAY 'TOTAL MODIFICACIONES LEÍDAS: ' WS-FORMATO-PRINT
      
           MOVE TOT-MOD-ERRORES TO WS-FORMATO-PRINT
           DISPLAY 'TOTAL MODIFICACIONES CON ERROR: ' WS-FORMATO-PRINT
      
           MOVE TOT-MOD-GRABADAS TO WS-FORMATO-PRINT
           DISPLAY 'TOTAL MODIFICACIONES GRABADAS EN TABLA​: '
                                                      WS-FORMATO-PRINT
      
           CLOSE ENTRADA                                         
           IF FS-NOVEDADES IS NOT EQUAL '00' THEN                    
              DISPLAY '* ERROR EN CLOSE ENTRADA = ' FS-NOVEDADES   
              MOVE 9999 TO RETURN-CODE                           
              SET WS-FIN-LECTURA TO TRUE                         
           END-IF                                               
      
           CLOSE SALIDA                                          
           IF FS-SALIDA IS NOT EQUAL '00' THEN                     
              DISPLAY '* ERROR EN CLOSE = ' FS-SALIDA            
              MOVE 9999 TO RETURN-CODE                           
              SET WS-FIN-LECTURA TO TRUE                         
           END-IF.                                               
      
       9999-FINAL-F. EXIT. 