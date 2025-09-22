       IDENTIFICATION DIVISION. 
       PROGRAM-ID. PROGM40S. 
      
      ******************************************************************
      *                   CLASE SINCRÓNICA 40                          *
      *                   ===================                          *
      *   Programa COBOL con SQL embebido que accede a las tablas      *
      *   TBCURCTA (mandatoria) y TBCURCLI,                            *
      *   realizando un LEFT OUTER JOIN por NROCLI.                    *
      *                                                                *
      *   - Seleccionar datos de clientes y cuentas mediante cursores. *
      *   - Listar los registros apareados mostrando:                  *
      *       NROCLI, TIPDOC, NRODOC, NOMAPE y SUCUEN.                 *
      *   - Informar cuando existen cuentas sin cliente asociado por   *
      *       consola: "CLIENTES ENCONTRADOS EN TABLA CLIENTES".       *
      *   - Calcular y mostrar totales estadísticos:                   *
      *       · Leídos en TBCURCLI (NOMAPE distinto de NULL)           *
      *       · Leídos en TBCURCTA (todas las filas del JOIN)          *
      *       · Encontrados (con NOMAPE distinto de NULL)              *
      *       · No encontrados (con NOMAPE NULL)                       *
      *                                                                *
      ******************************************************************
      
      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       ENVIRONMENT DIVISION. 
       CONFIGURATION SECTION. 
      
       SPECIAL-NAMES. 
           DECIMAL-POINT IS COMMA. 
      
       INPUT-OUTPUT SECTION. 
       FILE-CONTROL. 
           SELECT IMPRIME ASSIGN DDLISTA 
           FILE STATUS IS FS-IMPRIME. 
      
      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       DATA DIVISION. 
       FILE SECTION. 
  
       FD  IMPRIME 
           BLOCK CONTAINS 0 RECORDS 
           RECORDING MODE IS F. 
       01  REG-SALIDA     PIC X(124).        
      
       WORKING-STORAGE SECTION.
      *========================* 
      
      *----------- ARCHIVOS ----------------------------------------- 
       77  FS-IMPRIME              PIC XX               VALUE SPACES. 
      
       77  WS-STATUS-FIN           PIC X. 
           88  WS-FIN-LECTURA         VALUE 'Y'. 
           88  WS-NO-FIN-LECTURA      VALUE 'N'. 
      
      
      *-----------  VARIABLES  --------------------------------------- 
       77  WS-ENCONTRADOS-CANT        PIC 999           VALUE ZEROES. 
       77  WS-LEIDOS-CANT             PIC 999           VALUE ZEROES. 
       77  WS-NO-ENCONTRADO-CANT      PIC 999           VALUE ZEROES. 
             
      
      *----------- FORMATEO ------------------------------------------ 
       77  WS-REGISTROS-PRINT         PIC ZZ9           VALUE ZEROES. 
       
      *-----------  SQL  ---------------------------------------------
       77  WS-SQLCODE           PIC +++999 USAGE DISPLAY   VALUE ZEROS. 
       77  NOT-FOUND            PIC S9(9)  COMP            VALUE  +100. 
      
       01  REG-PROG. 
           05  REG-TIPDOC-CLI   PIC X(02)                 VALUE SPACES. 
           05  REG-NRODOC-CLI   PIC S9(11)V USAGE COMP-3  VALUE ZEROES. 
           05  REG-NROCLI-CLI   PIC S9(03)V USAGE COMP-3  VALUE ZEROES. 
           05  REG-NOMAPE-CLI   PIC X(30)                 VALUE SPACES. 
           05  REG-SUCUEN-CTA   PIC S9(02)V USAGE COMP-3  VALUE ZEROES. 
      
      *-----------  IMPRIME  ----------------------------------------
       01  FILE-TITULO. 
           05 FILLER  PIC X(11) VALUE SPACES. 
           05 FILLER  PIC X(38) VALUE 
                              "CLIENTES ENCONTRADOS EN TABLA CLIENTES". 
      
       01  FILE-FILA   PIC X(67) VALUE ALL '-'.

       01  FILE-SUBTITULO. 
           05 FILLER         PIC X(02)                  VALUE '| '. 
           05 FILLER         PIC X(06)                  VALUE "TIPDOC".
           05 FILLER         PIC X(03)                  VALUE ' | '. 
           05 FILLER         PIC X(03)                  VALUE SPACES. 
           05 FILLER         PIC X(06)                  VALUE 'NRODOC'.
           05 FILLER         PIC X(03)                  VALUE SPACES. 
           05 FILLER         PIC X(03)                  VALUE ' | '. 
           05 FILLER         PIC X(01)                  VALUE SPACES. 
           05 FILLER         PIC X(06)                  VALUE 'NROCLI'.
           05 FILLER         PIC X(03)                  VALUE ' | '. 
           05 FILLER         PIC X(12)                  VALUE SPACES. 
           05 FILLER         PIC X(06)                  VALUE 'NOMAPE'.
           05 FILLER         PIC X(12)                  VALUE SPACES. 
           05 FILLER         PIC X(02)                  VALUE ' |'. 
                                                                       
       01  FILE-REGISTRO. 
           05 FILLER         PIC X(02)                  VALUE '| '. 
           05 FILLER         PIC X(04)                  VALUE SPACES. 
           05 FILE-TIPDOC    PIC X(02)                  VALUE SPACES. 
           05 FILLER         PIC X(03)                  VALUE " | ". 
           05 FILE-NRODOC    PIC -Z(11)                 VALUE ZEROES. 
           05 FILLER         PIC X(03)                  VALUE " | ". 
           05 FILLER         PIC X(03)                  VALUE SPACES. 
           05 FILE-NROCLI    PIC -Z(03)                 VALUE ZEROES. 
           05 FILLER         PIC X(03)                  VALUE " | ". 
           05 FILE-NOMAPE    PIC X(30)                  VALUE SPACES. 
           05 FILLER         PIC X(03)                  VALUE " | ". 
      
      
      *////////////  COPYS  /////////////////////////////////////////
      *    COBOL DECLARATION FOR TABLE KC02803.TBCURCLI     
           EXEC SQL DECLARE KC02803.TBCURCLI TABLE 
           ( TIPDOC                         CHAR(2) NOT NULL, 
             NRODOC                         DECIMAL(11, 0) NOT NULL, 
             NROCLI                         DECIMAL(3, 0) NOT NULL, 
             NOMAPE                         CHAR(30) NOT NULL, 
             FECNAC                         DATE NOT NULL, 
             SEXO                           CHAR(1) NOT NULL 
           ) END-EXEC. 
       01  DCLTBCURCLI. 
           10 CLI-TIPDOC           PIC  X(02). 
           10 CLI-NRODOC           PIC S9(11)V USAGE COMP-3. 
           10 CLI-NROCLI           PIC S9(03)V  USAGE COMP-3. 
           10 CLI-NOMAPE           PIC  X(30). 
           10 CLI-FECNAC           PIC  X(10). 
           10 CLI-SEXO             PIC  X(01). 
      *------------------------------------------------------------
      *     COBOL DECLARATION FOR TABLE KC02803.TBCURCTA             
           EXEC SQL DECLARE KC02803.TBCURCTA TABLE 
           ( TIPCUEN                        CHAR(2) NOT NULL, 
             NROCUEN                        DECIMAL(5, 0) NOT NULL, 
             SUCUEN                         DECIMAL(2, 0) NOT NULL, 
             NROCLI                         DECIMAL(3, 0) NOT NULL, 
             SALDO                          DECIMAL(7, 2) NOT NULL, 
             FECSAL                         DATE NOT NULL 
           ) END-EXEC. 
       01  DCLTBCURCTA. 
           10 CTA-TIPCUEN          PIC X(2). 
           10 CTA-NROCUEN          PIC S9(5)V USAGE COMP-3. 
           10 CTA-SUCUEN           PIC S9(2)V USAGE COMP-3. 
           10 CTA-NROCLI           PIC S9(3)V USAGE COMP-3. 
           10 CTA-SALDO            PIC S9(5)V9(2) USAGE COMP-3. 
           10 CTA-FECSAL           PIC X(10). 
      *///////////////////////////////////////////////////////////////
       
      
      
      *---- SQLCA COMMUNICATION AREA CON EL DB2  --------------------- 
           EXEC SQL INCLUDE SQLCA END-EXEC.                      
      *     EXEC SQL INCLUDE TBCURCLI END-EXEC.                   
      *     EXEC SQL INCLUDE TBCURCTA END-EXEC.                   
      
           EXEC SQL    
      
              DECLARE ITEM_CURSOR CURSOR FOR 
                 SELECT B.TIPDOC, 
                        B.NRODOC, 
                        B.NROCLI, 
                        B.NOMAPE,
                        A.SUCUEN
                 FROM KC02803.TBCURCTA A 
                 LEFT OUTER JOIN KC02803.TBCURCLI B 
                 ON A.NROCLI = B.NROCLI 
                 ORDER BY A.NROCLI ASC
      
           END-EXEC
      
      
      *|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
       PROCEDURE DIVISION. 
      
       MAIN-PROGRAM-I. 
      
           PERFORM 1000-INICIO-I  THRU 1000-INICIO-F 
           PERFORM 2000-PROCESO-I THRU 2000-PROCESO-F 
                                       UNTIL WS-FIN-LECTURA 
           PERFORM 9999-FINAL-I   THRU 9999-FINAL-F. 
              
       MAIN-PROGRAM-F. GOBACK. 
      
      *-------------------------------------------------------------- 
       1000-INICIO-I. 
           
           SET WS-NO-FIN-LECTURA TO TRUE
      
           OPEN OUTPUT IMPRIME 
           IF FS-IMPRIME IS NOT EQUAL '00' THEN
              DISPLAY '* ERROR EN OPEN IMPRIME = ' FS-IMPRIME 
              MOVE 9999 TO RETURN-CODE 
              SET  WS-FIN-LECTURA TO TRUE 
           END-IF 
      
           EXEC SQL OPEN ITEM_CURSOR END-EXEC
           IF SQLCODE NOT EQUAL ZEROS THEN
              MOVE SQLCODE TO WS-SQLCODE                         
              DISPLAY '* ERROR OPEN CURSOR = ' WS-SQLCODE        
              MOVE 9999 TO RETURN-CODE                           
              SET WS-FIN-LECTURA TO TRUE                         
           END-IF                                               
      
           IF WS-NO-FIN-LECTURA THEN 
              WRITE REG-SALIDA FROM FILE-TITULO 
              WRITE REG-SALIDA FROM FILE-FILA 
              WRITE REG-SALIDA FROM FILE-SUBTITULO 
              WRITE REG-SALIDA FROM FILE-FILA 
           END-IF. 
      
       1000-INICIO-F. EXIT. 
      
      
      *-------------------------------------------------------------- 
       2000-PROCESO-I. 

           PERFORM 4000-LEER-FETCH-I THRU 4000-LEER-FETCH-F
      
           IF SQLCODE = NOT-FOUND THEN 
              DISPLAY 'FIN DE DATOS. NO HAY MÁS REGISTROS.' 
           END-IF 
                                                                     
           IF WS-NO-FIN-LECTURA AND REG-NROCLI-CLI > 0  THEN 
              PERFORM 5000-PROCESAR-MAESTRO-I 
                 THRU 5000-PROCESAR-MAESTRO-F 
           END-IF. 
                                                                     
       2000-PROCESO-F. EXIT. 
      
      *-------------------------------------------------------------- 
       4000-LEER-FETCH-I. 
      
           EXEC SQL 
              FETCH ITEM_CURSOR INTO 
                    :DCLTBCURCLI.CLI-TIPDOC,
                    :DCLTBCURCLI.CLI-NRODOC,
                    :DCLTBCURCLI.CLI-NROCLI,
                    :DCLTBCURCLI.CLI-NOMAPE,
                    :DCLTBCURCTA.CTA-SUCUEN
           END-EXEC 
      
           EVALUATE SQLCODE 
      
              WHEN ZEROS 
                 MOVE CLI-TIPDOC  TO REG-TIPDOC-CLI
                 MOVE CLI-NRODOC  TO REG-NRODOC-CLI 
                 MOVE CLI-NROCLI  TO REG-NROCLI-CLI 
                 MOVE CLI-NOMAPE  TO REG-NOMAPE-CLI
                 MOVE CTA-SUCUEN  TO REG-SUCUEN-CTA
                 ADD 1 TO WS-ENCONTRADOS-CANT 
                 ADD 1 TO WS-LEIDOS-CANT
      
              WHEN +100 
                 SET WS-FIN-LECTURA TO TRUE 
      
              WHEN -305
                 DISPLAY 'CUENTA SIN CLIENTE EN TBCURCLI' 
                 MOVE 0          TO REG-NROCLI-CLI
                 MOVE SPACES     TO REG-NOMAPE-CLI
                 MOVE CTA-SUCUEN TO REG-SUCUEN-CTA
                 ADD 1 TO WS-NO-ENCONTRADO-CANT
                 ADD 1 TO WS-LEIDOS-CANT
      
              WHEN OTHER 
                 MOVE SQLCODE TO WS-SQLCODE 
                 DISPLAY 'ERROR EN FETCH CURSOR: ' WS-SQLCODE 
                 SET WS-FIN-LECTURA TO TRUE 
      
           END-EVALUATE. 
  
       4000-LEER-FETCH-F. EXIT. 
      
      *----------------------------------------------------------------
       5000-PROCESAR-MAESTRO-I. 
           
           MOVE REG-TIPDOC-CLI TO FILE-TIPDOC 
           MOVE REG-NRODOC-CLI TO FILE-NRODOC 
           MOVE REG-NROCLI-CLI TO FILE-NROCLI 
           MOVE REG-NOMAPE-CLI TO FILE-NOMAPE 
           WRITE REG-SALIDA FROM FILE-REGISTRO.
      
       5000-PROCESAR-MAESTRO-F. EXIT.
           
      
      *--------------------------------------------------------------
       9999-FINAL-I. 
      
           EXEC SQL  CLOSE ITEM_CURSOR  END-EXEC 
      
           CLOSE IMPRIME   
           IF FS-IMPRIME IS NOT EQUAL '00' THEN
              DISPLAY '* ERROR EN CLOSE IMPRIME = ' FS-IMPRIME 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-LECTURA TO TRUE 
           END-IF 

           DISPLAY '*******************************'
           MOVE WS-LEIDOS-CANT        TO WS-REGISTROS-PRINT 
           DISPLAY 'LEIDOS:            ' WS-REGISTROS-PRINT 
           MOVE WS-ENCONTRADOS-CANT   TO WS-REGISTROS-PRINT 
           DISPLAY 'ENCONTRADOS:       ' WS-REGISTROS-PRINT 
           MOVE WS-NO-ENCONTRADO-CANT TO WS-REGISTROS-PRINT 
           DISPLAY 'NO ENCONTRADOS:    ' WS-REGISTROS-PRINT. 
      
       9999-FINAL-F. EXIT. 