       IDENTIFICATION DIVISION. 
       PROGRAM-ID. PROGM32S. 
      ******************************************************************
      *                    CLASE SINCRÓNICA 32                         *
      *                    ===================                         *
      *  Seleccionar todos las columnas de la tabla KC02803.TBCURCTA
      *  necesarias para hacer apareo por TIPCUEN y NROCUEN.
      * 
      *  Leer secuencialmente el archivo NOVCTA por la clave 
      *  WS-TIPCUEN y WS-NROCUEN.
      *
      *  Cuando se da el apareo OK:
      *  - buscar el cliente de tabla TBCURCTA en la tabla TBCURCLI; 
      *    cuando no exista el cliente; mostrar por display “cliente 
      *    no encontrado”
      *
      *  - Sumar totales de saldo del archivo NOVCTA; en el saldo de
      *    tabla y mostrar el resultado por DISPLAY junto al número de
      *    cliente, nombre del cliente, tipo de cuenta, nro de cuenta;
      *    ejemplo: TIPO DE CUENTA, NRO CUENTA, NROCLI, NOMBRE CLIENTE
      *    SALDO ACTUALIZADO ​  
      *
      *  Según resultado apareo:
      *  -​ Cuando está en el archivo y no está en la TABLA; mostrar
      *    “NOVEDAD NO ENCONTRADA”
      *  -​ Cuando no está en el archivo y está en la TABLA; mostrar
      *    “CUENTA SIN NOVEDAD”
      *  
      *  Al finalizar, mostrar totales generales de saldos actualizados
      *    de cuentas apareadas y totales estadísticos:
      *  -  LEÍDOS ARCHIVO,
      *  -  ENCONTRADOS,
      *  -  NO ENCONTRADOS.    
      
      **************************************************************
  
      *|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       ENVIRONMENT DIVISION. 
       CONFIGURATION SECTION. 
      
       SPECIAL-NAMES. 
           DECIMAL-POINT IS COMMA. 
      
       INPUT-OUTPUT SECTION. 
      
       FILE-CONTROL. 
           SELECT NOVEDADES ASSIGN TO DDENTRA 
           FILE STATUS  IS FS-NOVEDADES. 
      
      *|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       DATA DIVISION. 
       FILE SECTION. 
  
       FD  NOVEDADES
           BLOCK CONTAINS 0 RECORDS 
           RECORDING MODE IS F. 
       01  REG-NOVEDADES    PIC X(23). 
      
      
       WORKING-STORAGE SECTION. 
      *=======================* 
  
      *----------- ARCHIVOS ---------------------------------------- 
       77  FS-NOVEDADES            PIC XX         VALUE SPACES. 
      
       77  WS-STATUS-FIN           PIC X. 
           88  WS-FIN-LECTURA                     VALUE 'Y'. 
           88  WS-NO-FIN-LECTURA                  VALUE 'N'. 
      
       01  WS-STATUS-NOV           PIC X. 
           88  WS-FIN-NOV                         VALUE 'Y'. 
           88  WS-NO-FIN-NOV                      VALUE 'N'.
      
       01  WS-STATUS-FETCH          PIC X. 
           88  WS-FIN-FETCH                       VALUE 'Y'. 
           88  WS-NO-FIN-FETCH                    VALUE 'N'.     
            
       77  NOT-FOUND               PIC S9(9) COMP VALUE  +100. 
       77  NOTFOUND-FORMAT         PIC -ZZZZZZZZZZ. 
      
      
      *----------- ACUMULADORES -------------------------------------- 
       77  WS-NOVE-LEIDAS-CANT     PIC 999              VALUE ZEROES. 
       77  WS-NOVE-INSERT-CANT     PIC 999              VALUE ZEROES. 
       77  WS-NOVE-ERRONEA-CANT    PIC 999              VALUE ZEROES. 
       77  WS-SALDO-CANT           PIC S9(6)V9(2)       VALUE ZEROES.
       77  WS-NUMERO-PRINT         PIC -ZZZZZZZZZZZZZ9.
       77  WS-SALDO-PRINT          PIC -$$$$$$$$99,99.
       77  WS-SALDO2-PRINT         PIC -$$$$$$$$99,99.
      
      *----------- SQL ---------------------------------------------- 
       77  WS-SQLCODE            PIC +++999 USAGE DISPLAY VALUE ZEROS. 
      
      *    VARIABLES AUXILIARES 
       01  WS-CLAVE-FETCH.
           10  REG-TIPCUEN     PIC X(2)                 VALUE SPACES.
           10  REG-NROCUEN     PIC S9(5)V USAGE COMP-3  VALUE ZEROES. 
       77  REG-SUCUEN          PIC S9(2)V USAGE COMP-3  VALUE ZEROES. 
       77  REG-NROCLI          PIC S9(3)V USAGE COMP-3  VALUE ZEROES. 
       77  REG-SALDO       PIC S9(5)V9(2) USAGE COMP-3  VALUE ZEROES.
       77  REG-FECSAL      PIC X(10)                    VALUE SPACES.
       77  REG-NOMAPE      PIC X(30)                    VALUE SPACES.
      
       01  WS-CLAVE-NOV. 
           10  NOV-TIPCUEN      PIC X(2). 
           10  NOV-NROCUEN      PIC S9(5)V USAGE COMP-3. 
      
      *      
             EXEC SQL INCLUDE SQLCA    END-EXEC. 
      *      EXEC SQL INCLUDE TBCURCLI END-EXEC. 
      *      EXEC SQL INCLUDE TBCURCTA END-EXEC. 
      
      *      COPY NOVCTA. 
       
      
      *///////////////////////////////////////////////////////////////
      * COBOL DECLARATION FOR TABLE KC02803.TBCURCLI
      
      *    EXEC SQL DECLARE KC02803.TBCURCLI TABLE                     
      *    ( TIPDOC                         CHAR(2) NOT NULL,          
      *      NRODOC                         DECIMAL(11, 0) NOT NULL,   
      *      NROCLI                         DECIMAL(3, 0) NOT NULL,    
      *      NOMAPE                         CHAR(30) NOT NULL,         
      *      FECNAC                         DATE NOT NULL,             
      *      SEXO                           CHAR(1) NOT NULL           
      *    ) END-EXEC.                                                 
       01  DCLTBCURCLI.                                                 
           10 CLI-TIPDOC           PIC X(2).                            
           10 CLI-NRODOC           PIC S9(11)V USAGE COMP-3.            
           10 CLI-NROCLI           PIC S9(3)V USAGE COMP-3.             
           10 CLI-NOMAPE           PIC X(30).                           
           10 CLI-FECNAC           PIC X(10).                           
           10 CLI-SEXO             PIC X(1).                            
      
      * COBOL DECLARATION FOR TABLE KC02803.TBCURCTA
      
      *    EXEC SQL DECLARE KC02803.TBCURCTA TABLE                      
      *    ( TIPCUEN                        CHAR(2) NOT NULL,           
      *      NROCUEN                        DECIMAL(5, 0) NOT NULL,     
      *      SUCUEN                         DECIMAL(2, 0) NOT NULL,     
      *      NROCLI                         DECIMAL(3, 0) NOT NULL,     
      *      SALDO                          DECIMAL(7, 2) NOT NULL,     
      *      FECSAL                         DATE NOT NULL               
      *    ) END-EXEC.                                                  
       01  DCLTBCURCTA.                                                 
           10 CTA-TIPCUEN          PIC X(2).                            
           10 CTA-NROCUEN          PIC S9(5)V USAGE COMP-3.             
           10 CTA-SUCUEN           PIC S9(2)V USAGE COMP-3.             
           10 CTA-NROCLI           PIC S9(3)V USAGE COMP-3.             
           10 CTA-SALDO            PIC S9(5)V9(2) USAGE COMP-3.         
           10 CTA-FECSAL           PIC X(10).                  
      
      
      *    NOVCTA
      * LARGO REGISTRO 23                                           
       01  WS-REG-CTA. 
           10 WS-TIPCUEN           PIC X(2). 
           10 WS-NROCUEN           PIC S9(5)V USAGE COMP-3. 
           10 WS-SUCUEN            PIC S9(2)V USAGE COMP-3. 
           10 WS-NROCLI            PIC S9(3)V USAGE COMP-3. 
           10 WS-SALDO             PIC S9(5)V9(2) USAGE COMP-3. 
           10 WS-FECSAL            PIC X(10). 
      *//////////////////////////////////////////////////////////////
           
           EXEC SQL 
      
              DECLARE INNERJOIN CURSOR FOR 
      
              SELECT A.TIPCUEN, 
                     A.NROCUEN, 
                     A.SUCUEN, 
                     A.NROCLI, 
                     A.SALDO, 
                     B.NOMAPE 
              FROM KC02803.TBCURCTA A 
              LEFT JOIN KC02803.TBCURCLI B 
              ON A.NROCLI = B.NROCLI 
              WHERE A.SUCUEN = 1 
              ORDER BY A.TIPCUEN ASC, A.NROCUEN ASC
                                        
           END-EXEC. 
                     
      
       77  FILLER PIC X(26) VALUE '* FINAL  WORKING-STORAGE *'. 
      
      
      *|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       PROCEDURE DIVISION.
  
       MAIN-PROGRAM-I. 
  
           PERFORM 1000-INICIO-I  THRU 1000-INICIO-F. 
           PERFORM 2000-PROCESO-I THRU 2000-PROCESO-F 
                                       UNTIL WS-FIN-LECTURA. 
           PERFORM 9999-FINAL-I   THRU 9999-FINAL-F. 
  
       MAIN-PROGRAM-F. GOBACK. 
  
  
      *-------------------------------------------------------------- 
       1000-INICIO-I. 
  
           SET WS-NO-FIN-LECTURA TO TRUE. 
      
           OPEN INPUT NOVEDADES. 
           IF FS-NOVEDADES IS NOT EQUAL '00' THEN
             DISPLAY '* ERROR EN OPEN ENTRADA INICIO = ' FS-NOVEDADES 
             SET  WS-FIN-LECTURA TO TRUE 
             MOVE 9999 TO RETURN-CODE
             PERFORM 9999-FINAL-I THRU 9999-FINAL-F 
           END-IF. 
           
           EXEC SQL OPEN INNERJOIN END-EXEC. 
           IF SQLCODE NOT EQUAL ZEROS THEN
              MOVE SQLCODE TO WS-SQLCODE 
              DISPLAY '* ERROR OPEN CURSOR = ' WS-SQLCODE 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-LECTURA TO TRUE 
           END-IF. 
      
           IF WS-NO-FIN-LECTURA THEN
              PERFORM 4000-LEER-FETCH-I THRU 4000-LEER-FETCH-F 
              PERFORM 3000-LEER-NOVED-I THRU 3000-LEER-NOVED-F 
           END-IF.   
           
       1000-INICIO-F. EXIT. 
      
      
      *------------------------------------------------------------- 
       2000-PROCESO-I. 
              
           IF WS-FIN-NOV AND WS-FIN-FETCH THEN
              SET WS-FIN-LECTURA TO TRUE
           ELSE               
              IF WS-CLAVE-FETCH = WS-CLAVE-NOV THEN
                 PERFORM 5000-PROCESAR-MAESTRO-I 
                    THRU 5000-PROCESAR-MAESTRO-F 
                 PERFORM 3000-LEER-NOVED-I 
                    THRU 3000-LEER-NOVED-F 
              ELSE 
                 IF WS-CLAVE-FETCH > WS-CLAVE-NOV THEN
                    DISPLAY "-------------------"
                    DISPLAY "NOVEDAD NO ENCONTRADA"
                    DISPLAY "-------------------"
                    PERFORM 4000-LEER-FETCH-I 
                       THRU 4000-LEER-FETCH-F 
                 ELSE 
                    DISPLAY "-------------------"
                    DISPLAY "CUENTA SIN NOVEDAD"
                    DISPLAY "-------------------"
                    ADD 1 TO WS-NOVE-ERRONEA-CANT
                    PERFORM 3000-LEER-NOVED-I 
                       THRU 3000-LEER-NOVED-F 
                 END-IF 
              END-IF 
           END-IF.              
      
       2000-PROCESO-F. EXIT. 
      
      
      *-------------------------------------------------------------- 
       3000-LEER-NOVED-I. 
  
           READ NOVEDADES INTO WS-REG-CTA  
                          AT END SET WS-FIN-NOV TO TRUE 
                          MOVE HIGH-VALUE TO WS-REG-CTA. 
  
           EVALUATE FS-NOVEDADES 
              WHEN '00' 
                 ADD 1 TO WS-NOVE-LEIDAS-CANT 
                 MOVE WS-TIPCUEN TO NOV-TIPCUEN *> PARA LA CLAVE NOV.
                 MOVE WS-NROCUEN TO NOV-NROCUEN
              WHEN '10' 
                 SET WS-FIN-NOV TO TRUE 
                 MOVE HIGH-VALUE TO NOV-TIPCUEN
                 MOVE 99999999 TO NOV-NROCUEN
              WHEN OTHER 
                 DISPLAY '*ERROR EN LECTURA ENTRADA INICIO : ' 
                                                  FS-NOVEDADES 
                 SET WS-FIN-NOV TO TRUE 
                 MOVE HIGH-VALUE TO NOV-TIPCUEN
                 MOVE 99999999 TO NOV-NROCUEN                 
           END-EVALUATE. 
      
       3000-LEER-NOVED-F. EXIT. 
      
      *-------------------------------------------------------------- 
       4000-LEER-FETCH-I. 
      
           EXEC SQL 
              FETCH INNERJOIN INTO :DCLTBCURCTA.CTA-TIPCUEN,
                                   :DCLTBCURCTA.CTA-NROCUEN,
                                   :DCLTBCURCTA.CTA-SUCUEN,
                                   :DCLTBCURCTA.CTA-NROCLI,
                                   :DCLTBCURCTA.CTA-SALDO,
                                   :DCLTBCURCLI.CLI-NOMAPE
           END-EXEC. 
      
           EVALUATE TRUE 
              WHEN SQLCODE EQUAL ZEROS 
                 MOVE CTA-TIPCUEN TO REG-TIPCUEN  
                 MOVE CTA-NROCUEN TO REG-NROCUEN  
                 MOVE CTA-SUCUEN  TO REG-SUCUEN   
                 MOVE CTA-NROCLI  TO REG-NROCLI   
                 MOVE CTA-SALDO   TO REG-SALDO    
                 MOVE CLI-NOMAPE  TO REG-NOMAPE   
              WHEN SQLCODE = -305
                 MOVE 'SIN NOMBRE' TO REG-NOMAPE
                   CONTINUE 
              WHEN SQLCODE EQUAL +100 
                 SET WS-FIN-FETCH TO TRUE 
                 MOVE HIGH-VALUE TO REG-TIPCUEN
                 MOVE 99999999 TO REG-NROCUEN
              WHEN OTHER 
                 MOVE SQLCODE TO WS-SQLCODE 
                 DISPLAY 'ERROR FETCH CURSOR: ' WS-SQLCODE 
                 SET WS-FIN-FETCH TO TRUE 
                 MOVE HIGH-VALUE TO REG-TIPCUEN
                 MOVE 99999999 TO REG-NROCUEN
           END-EVALUATE. 
      
       4000-LEER-FETCH-F. EXIT.
      
      
      *---------------------------------------------------------------
       5000-PROCESAR-MAESTRO-I. 
      
           IF REG-NROCUEN = WS-NROCUEN AND
              REG-NROCLI  = WS-NROCLI  THEN
                 COMPUTE WS-SALDO-CANT = REG-SALDO + WS-SALDO 
                 DISPLAY "-------------------"
                 DISPLAY "APAREO OK: "
                 DISPLAY "TIPO DE CUENTA: "       REG-TIPCUEN
                 MOVE REG-NROCUEN TO WS-NUMERO-PRINT
                 DISPLAY "NRO CUENTA: "           WS-NUMERO-PRINT
                 MOVE REG-NROCLI TO WS-NUMERO-PRINT
                 DISPLAY "NROCLI: "               WS-NUMERO-PRINT 
                 MOVE WS-SALDO-CANT TO WS-SALDO2-PRINT
                 MOVE WS-SALDO TO WS-SALDO-PRINT
                 DISPLAY "$: " WS-SALDO2-PRINT " = " REG-SALDO
                                             " + "   WS-SALDO-PRINT 
                 DISPLAY "NOMBRE CLIENTE:"        REG-NOMAPE 
                 DISPLAY "SALDO ACTUALIZADO CTA " WS-SALDO2-PRINT 
                 DISPLAY "-------------------" 
                 ADD 1 TO WS-NOVE-INSERT-CANT   
                 MOVE ZERO TO WS-SALDO-CANT
           END-IF.   
       
       5000-PROCESAR-MAESTRO-F. EXIT. 
      
      
      *-------------------------------------------------------------- 
       9999-FINAL-I. 
      
           DISPLAY "TOTAL DE LEÍDOS ARCHIVO: " WS-NOVE-LEIDAS-CANT
           DISPLAY "TOTAL DE ENCONTRADOS: "    WS-NOVE-INSERT-CANT
           DISPLAY "TOTAL DE NO ENCONTRADOS: " WS-NOVE-ERRONEA-CANT
           
           EXEC SQL  CLOSE INNERJOIN  END-EXEC. 
           CLOSE NOVEDADES 
           IF FS-NOVEDADES  IS NOT EQUAL '00' THEN
              DISPLAY '* ERROR EN CLOSE ENTRADA = ' FS-NOVEDADES 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-LECTURA TO TRUE 
           END-IF. 
      
       9999-FINAL-F. EXIT.