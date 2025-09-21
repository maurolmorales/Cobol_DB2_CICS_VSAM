       IDENTIFICATION DIVISION. 
       PROGRAM-ID. PROGM44S. 
      ******************************************************************
      *                   CLASE ASÍNCRONA 44
      *                   ==================
      *  - Hacer query que acceda a tabla TBCURCTA y traiga todas las 
      *    filas con la condición: FECSAL < 2025-06-05  
      *    
      *  - Hacer CORTE DE CONTROL por SUCURSAL y TIPO DE CUENTA​.
      *
      *  - Por corte de SUCURSAL: imprimir el total de clientes y el 
      *    total de saldos correspondiente a la sucursal​.
      
      *  - Por corte de TIPO DE CUENTA: imprimir el total de saldos
      *    correspondiente al tipo de cuenta
      
      ******************************************************************
      
      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       ENVIRONMENT DIVISION. 
       CONFIGURATION SECTION. 
      
       SPECIAL-NAMES. 
           DECIMAL-POINT IS COMMA. 
      
       INPUT-OUTPUT SECTION. 
       FILE-CONTROL. 
      
           SELECT LISTADO ASSIGN DDLISTA 
           FILE STATUS IS FS-LISTADO. 
      
      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       DATA DIVISION. 
       FILE SECTION. 
      
       FD  LISTADO 
           BLOCK CONTAINS 0 RECORDS 
           RECORDING MODE IS F. 
       01  REG-SALIDA     PIC X(93). 
      
      
       WORKING-STORAGE SECTION. 
      *========================* 
      
      *----------- STATUS ARCHIVOS  --------------------------------- 
       77  FS-LISTADO              PIC XX       VALUE SPACES. 
      
       77  WS-STATUS-FIN           PIC X. 
           88  WS-FIN-LECTURA         VALUE 'Y'. 
           88  WS-NO-FIN-LECTURA      VALUE 'N'. 


      *-----------  CORTE DE CONTROL  ------------------------ 
       77  WS-MAYOR-ANT    PIC S9(2)V USAGE COMP-3   VALUE ZEROES. 
       77  WS-MENOR-ANT    PIC XX                    VALUE SPACES. 
       77  WS-PRIMER-REG   PIC XX                    VALUE 'SI'. 
      
      *    VARIABLES TOMADAS DE LA TABLA DEL CURSOR. 
       77  REG-TIPCUEN   PIC X(2)                    VALUE SPACES. 
       77  REG-NROCUEN   PIC S9(5)V USAGE COMP-3     VALUE ZEROES. 
       77  REG-SUCUEN    PIC S9(2)V USAGE COMP-3     VALUE ZEROES. 
       77  REG-NROCLI    PIC S9(3)V USAGE COMP-3     VALUE ZEROES. 
       77  REG-SALDO     PIC S9(5)V9(2) USAGE COMP-3 VALUE ZEROES. 
       77  REG-FECSAL    PIC X(10)                   VALUE SPACES. 
      
      
      *----------- ACUMULADORES ------------------------------ 
       77  WS-MAYOR-CANT         PIC 999             VALUE ZEROES. 
       77  WS-MENOR-CANT         PIC 999             VALUE ZEROES. 
       77  WS-SALD-MAY-SUM   PIC S9(5)V9(2) USAGE COMP-3 VALUE ZEROES. 
       77  WS-SALD-MEN-SUM   PIC S9(5)V9(2) USAGE COMP-3 VALUE ZEROES. 
       77  WS-SALD-TOT-SUM   PIC S9(5)V9(2) USAGE COMP-3 VALUE ZEROES. 
       77  WS-REGISTROS-CANT     PIC 999             VALUE ZEROES. 
       01  WS-LEIDOS-CANT        PIC 9(05)           VALUE ZEROES. 
       01  WS-IMPRESOS-CANT      PIC 9(05)           VALUE ZEROES. 
      
      *----------- FORMATEO ---------------------------------- 
       77  WS-MAYOR-PRINT        PIC ZZ9             VALUE ZEROES. 
       77  WS-MENOR-PRINT        PIC ZZ9             VALUE ZEROES. 
       77  WS-REGISTROS-PRINT    PIC ZZ9             VALUE ZEROES. 
       77  WS-SALDO-PRINT        PIC -$$$$$$$9,99    VALUE ZEROES. 
      
      *-----------  SQL  -------------------------------------- 
       77  WS-SQLCODE     PIC +++999 USAGE DISPLAY   VALUE ZEROES. 
       77  NOT-FOUND               PIC S9(9) COMP VALUE  +100. 
       77  NOTFOUND-FORMAT         PIC -ZZZZZZZZZZ. 
      
      
      *-----------  IMPRESION  --------------------------------- 
       77  WS-PIPE                 PIC XXX           VALUE '|'. 
       77  WS-LINE                 PIC X(93)         VALUE ALL '='. 
       77  WS-LINE2                PIC X(93)         VALUE ALL '-'. 
       77  WS-LINE3                PIC X(58)         VALUE ALL '-'. 
       77  WS-SEPARATE             PIC X(93)         VALUE SPACES. 
       77  WS-LINEA-FIJA           PIC 9(02)         VALUE 80. 
      
       77  WS-CUENTA-LINEA         PIC 9(02)         VALUE ZEROS. 
       77  WS-CUENTA-PAGINA        PIC 9(02)         VALUE 01. 
      
      *    TITULO: 
       01  IMP-TITULO. 
           03  FILLER              PIC X(07)    VALUE 'FECHA: '. 
           03  FILLER              PIC X(03)    VALUE SPACES. 
           03  IMP-TIT-DD          PIC Z9       VALUE ZEROES. 
           03  FILLER              PIC X        VALUE '-'. 
           03  IMP-TIT-MM          PIC Z9       VALUE ZEROES. 
           03  FILLER              PIC X        VALUE '-'. 
           03  FILLER              PIC 99       VALUE 20. 
           03  IMP-TIT-AA          PIC 99       VALUE ZEROES. 
           03  FILLER              PIC X(13)    VALUE SPACES. 
           03  FILLER              PIC X(18)    VALUE 
               'DETALLE DE CUENTAS'. 
           03  FILLER              PIC X(13)    VALUE SPACES. 
           03  FILLER              PIC X(08)    VALUE 'PGMFBCAF'. 
           03  FILLER              PIC X(02)    VALUE SPACES. 
           03  FILLER              PIC X(14)    VALUE 'NUMERO PAGINA:'. 
           03  IMP-TIT-PAGINA      PIC Z9       VALUE ZEROES. 
           03  FILLER              PIC X(03)    VALUE SPACES. 
      
      
      *    SUBTITULO-SUCUEN: 
       01  IMP-SUBT-SUCUEN. 
           03  FILLER              PIC X         VALUE SPACES. 
           03  FILLER              PIC X(10)     VALUE 'SUCURSAL: '. 
           03  FILLER              PIC X         VALUE SPACES. 
           03  IMP-SUCUEN-SUB      PIC Z. 
           03  FILLER              PIC X         VALUE SPACES. 
      
      *    SUBTITULO-TIPCUEN: 
       01  IMP-SUBT-TIPCUEN. 
           03  FILLER              PIC X(05)     VALUE SPACES. 
           03  FILLER              PIC X(16)     VALUE 
           'TIPO DE CUENTA: '. 
           03  FILLER              PIC X         VALUE SPACES. 
           03  IMP-TIPCUEN-SUB     PIC X(20)     VALUE SPACES. 
           03  FILLER              PIC X         VALUE SPACES. 
      
      *    ENCABEZADO REGISTRO: 
       01  IMP-HEADER-REG-IMP. 
           03 FILLER               PIC X(03)           VALUE ' | '. 
           03 TIPCUEN              PIC X(07)           VALUE 'TIPCUEN'. 
           03 FILLER               PIC X(03)           VALUE ' | '. 
           03 NROCUEN              PIC X(07)           VALUE 'NROCUEN'. 
           03 FILLER               PIC X(03)           VALUE ' | '. 
           03 FILLER               PIC X(05)           VALUE SPACES. 
           03 SALDO                PIC X(05)           VALUE 'SALDO'. 
           03 FILLER               PIC X(03)           VALUE ' | '. 
           03 NROCLI               PIC X(06)           VALUE 'NROCLI'. 
           03 FILLER               PIC X(03)           VALUE ' | '. 
           03 FILLER               PIC X(04)           VALUE SPACES. 
           03 FECSAL               PIC X(06)           VALUE 'FECSAL'. 
           03 FILLER               PIC X(03)           VALUE ' | '. 
      
      *    IMPRESIÓN REGISTRO: 
       01  IMP-REG-LISTADO. 
           03 IMP-COL-1            PIC X(03)           VALUE SPACES. 
           03 FILLER               PIC X(05)           VALUE SPACES. 
           03 IMP-TIPCUEN          PIC ZZ. 
           03 IMP-COL-2            PIC X(03)           VALUE SPACES. 
           03 FILLER               PIC X(02)           VALUE SPACES. 
           03 IMP-NROCUEN          PIC ZZZZZ. 
           03 IMP-COL-3            PIC X(03)           VALUE SPACES. 
           03 IMP-SALDO            PIC -$$$$$9,99. 
           03 IMP-COL-4            PIC X(03)           VALUE SPACES. 
           03 FILLER               PIC X(03)           VALUE SPACES. 
           03 IMP-NROCLI           PIC ZZZ. 
           03 IMP-COL-5            PIC X(03)           VALUE SPACES. 
           03 IMP-FECSAL           PIC Z(10). 
           03 IMP-COL-6            PIC X(03)           VALUE SPACES. 
      
      *    IMPRESION FOOTER: 
       01  IMP-FOOTER-REG-IMP. 
           03 FILLER               PIC X(01)        VALUE SPACES. 
           03 FILLER               PIC X(10)        VALUE SPACES. 
           03 FILLER               PIC X(01)        VALUE SPACES. 
           03 FILLER               PIC X(10)        VALUE 'CANTIDAD: '. 
           03 FILLER               PIC X(01)        VALUE SPACES. 
           03 IMP-DATA-PRINT       PIC ZZZ. 
           03 FILLER               PIC X(01)        VALUE SPACES. 
           03 FILLER               PIC X(09)        VALUE 'IMPORTE: '. 
           03 FILLER               PIC X(01)        VALUE SPACES. 
           03 IMP-SALDO-PRINT      PIC -$$$$$$$9,99. 
           03 FILLER               PIC X(01)        VALUE SPACES. 
      
      *-----------  FECHA DE PROCESO  ------------------------ 
       01  WS-FECHA. 
           03  WS-FECHA-AA         PIC 99            VALUE ZEROS. 
           03  WS-FECHA-MM         PIC 99            VALUE ZEROS. 
           03  WS-FECHA-DD         PIC 99            VALUE ZEROS. 
      
       01  WS-FECHA-COMPUESTA      PIC X(10). 
       01  FECHA-MODIF. 
           03  FM-ANIO      PIC 9(4). 
           03  FM-SEP1      PIC X VALUE '-'. 
           03  FM-MES       PIC 9(2). 
           03  FM-SEP2      PIC X VALUE '-'. 
           03  FM-DIA       PIC 9(2). 

      *//////////////// COPYS //////////////////////////////////////
      ******************************************************************
      * COBOL DECLARATION FOR TABLE KC02803.TBCURCTA                   *
      ******************************************************************
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
      *//////////////////////////////////////////////////////////////
      
      *---- SQLCA COMMUNICATION AREA CON EL DB2  -------------------- 
           EXEC SQL INCLUDE SQLCA END-EXEC. 
      *      EXEC SQL INCLUDE TBCURCTA END-EXEC. 
      
           EXEC SQL 
              DECLARE CURSORCTA CURSOR FOR 
                 SELECT A.TIPCUEN, 
                        A.NROCUEN, 
                        A.SUCUEN, 
                        A.NROCLI, 
                        A.SALDO, 
                        A.FECSAL 
                 FROM KC02803.TBCURCTA A 
                 WHERE A.FECSAL < '2025-06-05' 
                 ORDER BY A.SUCUEN, A.TIPCUEN 
      
           END-EXEC. 
      
      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
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
           ACCEPT WS-FECHA FROM DATE 
           MOVE WS-FECHA-AA TO IMP-TIT-AA 
           MOVE WS-FECHA-MM TO IMP-TIT-MM 
           MOVE WS-FECHA-DD TO IMP-TIT-DD 
           MOVE WS-LINEA-FIJA TO WS-CUENTA-LINEA 
      
           OPEN OUTPUT LISTADO 
           IF FS-LISTADO IS NOT EQUAL '00' THEN 
              DISPLAY '* ERROR EN OPEN LISTADO = ' FS-LISTADO 
              MOVE 9999 TO RETURN-CODE 
              SET  WS-FIN-LECTURA TO TRUE 
           END-IF 
      
           EXEC SQL OPEN CURSORCTA END-EXEC 
           IF SQLCODE NOT EQUAL ZEROS THEN 
              MOVE SQLCODE TO WS-SQLCODE 
              DISPLAY '* ERROR OPEN CURSOR = ' WS-SQLCODE 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-LECTURA TO TRUE 
           END-IF 
      
           PERFORM 4000-LEER-FETCH-I THRU 4000-LEER-FETCH-F 
           
           IF WS-FIN-LECTURA THEN 
              DISPLAY '* TABLA VACÍA EN INICIO' 
           ELSE 
              MOVE REG-SUCUEN TO WS-MAYOR-ANT 
              MOVE REG-TIPCUEN TO WS-MENOR-ANT 
              ADD 1 TO WS-MAYOR-CANT 
              ADD 1 TO WS-MENOR-CANT 
              ADD REG-SALDO TO WS-SALD-MEN-SUM 
              DISPLAY 'SUCUEN = ' WS-MAYOR-ANT 
      
           END-IF. 
      
       1000-INICIO-F. EXIT. 
      
      
      *-------------------------------------------------------------- 
       2000-PROCESO-I. 
      
           IF WS-PRIMER-REG EQUAL 'SI' THEN 
              MOVE 'NO' TO WS-PRIMER-REG 
              PERFORM 6500-IMPRIMIR-TITULO-I 
                 THRU 6500-IMPRIMIR-TITULO-F 
              PERFORM 6700-IMP-HEADER-MAYOR-I 
                 THRU 6700-IMP-HEADER-MAYOR-F 
              PERFORM 6700-IMP-HEADER-REG-I 
                 THRU 6700-IMP-HEADER-REG-F 
              PERFORM 6800-IMP-HEADER-MENOR-I 
                 THRU 6800-IMP-HEADER-MENOR-F 
              PERFORM 6900-IMP-REGISTRO-I 
                 THRU 6900-IMP-REGISTRO-F 
           ELSE 
              PERFORM 4000-LEER-FETCH-I THRU 4000-LEER-FETCH-F 
      
              EVALUATE SQLCODE 
                 WHEN ZERO 
                    PERFORM 6000-VERIF-TITULOS-I 
                       THRU 6000-VERIF-TITULOS-F 
                 WHEN NOT-FOUND 
                     SET WS-FIN-LECTURA TO TRUE 
                 WHEN OTHER 
                    MOVE SQLCODE TO NOTFOUND-FORMAT 
                    DISPLAY 'ERROR DB2: ' NOTFOUND-FORMAT 
              END-EVALUATE 
      
              IF WS-FIN-LECTURA THEN 
                 PERFORM 2200-CORTE-MAYOR-I THRU 2200-CORTE-MAYOR-F 
              ELSE 
      
                 IF REG-SUCUEN IS EQUAL WS-MAYOR-ANT THEN 
                    ADD 1 TO WS-MAYOR-CANT 
      
                    IF REG-TIPCUEN IS EQUAL WS-MENOR-ANT THEN 
                       ADD 1 TO WS-MENOR-CANT 
                       ADD REG-SALDO TO WS-SALD-MEN-SUM 
                       PERFORM 6900-IMP-REGISTRO-I 
                          THRU 6900-IMP-REGISTRO-F 
                    ELSE 
                       PERFORM 2300-CORTE-MENOR-I 
                          THRU 2300-CORTE-MENOR-F 
                    END-IF 
                 ELSE 
                    PERFORM 2200-CORTE-MAYOR-I 
                       THRU 2200-CORTE-MAYOR-F 
                 END-IF 
              END-IF 
           END-IF. 
      
       2000-PROCESO-F. EXIT. 
      
      
      *---------------------------------- CORTE DE CONTROL MAYOR  ----
       2200-CORTE-MAYOR-I. 
      
           IF NOT WS-FIN-LECTURA THEN 
              ADD WS-SALD-MEN-SUM TO WS-SALD-MAY-SUM 
              DISPLAY 'SUCUEN ' REG-SUCUEN 
              PERFORM 6850-IMP-FOOTER-I 
                 THRU 6850-IMP-FOOTER-F 
              PERFORM 6700-IMP-HEADER-MAYOR-I 
                 THRU 6700-IMP-HEADER-MAYOR-F 
              PERFORM 6700-IMP-HEADER-REG-I 
                 THRU 6700-IMP-HEADER-REG-F 
      
              PERFORM 2300-CORTE-MENOR-I THRU 2300-CORTE-MENOR-F 
      
      *       MOSTRAR/ACUMULAR RESULTADOS DEL GRUPO MAYOR. 
              MOVE WS-MAYOR-ANT TO WS-MAYOR-PRINT 
              MOVE WS-SALD-MAY-SUM  TO WS-SALDO-PRINT 
              DISPLAY '_________________________________' 
              DISPLAY 'TOTAL ' WS-MAYOR-PRINT ' ' WS-SALDO-PRINT 
              DISPLAY ' ' 
              DISPLAY ' ' 
      
      *       ACTUALIZAR VARIABLE "ANTERIOR MAYOR" CON EL NUEVO VALOR. 
              MOVE REG-SUCUEN  TO WS-MAYOR-ANT 
      *       SUMAR EL ACUMULADO MAYOR AL ACUMULADO TOTAL. 
              ADD WS-SALD-MAY-SUM TO WS-SALD-TOT-SUM 
      *       RESETEAR ACUMULADORES DEL MAYOR (Y DEL MENOR TAMBIéN). 
              MOVE ZERO TO WS-SALD-MAY-SUM 
              MOVE 1 TO WS-MAYOR-CANT 
           ELSE 
              PERFORM 6850-IMP-FOOTER-I 
                 THRU 6850-IMP-FOOTER-F 
           END-IF. 
      
       2200-CORTE-MAYOR-F. EXIT. 
      
      *----------------------------------- CORTE DE CONTROL MENOR ---- 
       2300-CORTE-MENOR-I. 
      
           IF NOT WS-FIN-LECTURA THEN 
      
      *       MOSTRAR/ACUMULAR RESULTADOS DEL GRUPO MENOR. 
              MOVE WS-MENOR-CANT TO WS-MENOR-PRINT 
              MOVE WS-SALD-MEN-SUM TO WS-SALDO-PRINT 
              DISPLAY 'TIPCUEN: ' WS-MENOR-PRINT '  $ ' WS-SALDO-PRINT 
              PERFORM 6800-IMP-HEADER-MENOR-I 
                 THRU 6800-IMP-HEADER-MENOR-F 
              PERFORM 6900-IMP-REGISTRO-I 
                 THRU 6900-IMP-REGISTRO-F 
      
      *       SUMAR EL ACUMULADO MENOR AL ACUMULADO MAYOR. 
      *       ADD WS-SALD-MEN-SUM TO WS-SALD-MAY-SUM 
      *       RESETEAR ACUMULADORES DEL MENOR. 
              MOVE ZERO TO WS-SALD-MEN-SUM 
              MOVE ZERO TO WS-MENOR-CANT 
              MOVE REG-TIPCUEN TO WS-MENOR-ANT 
      *    ACTUALIZAR VARIABLE "ANTERIOR MENOR" CON EL NUEVO VALOR. 
              ADD 1 TO WS-MENOR-CANT 
              ADD REG-SALDO TO WS-SALD-MEN-SUM 
      
           ELSE 
              MOVE ZERO TO WS-MENOR-CANT 
              MOVE ZERO TO WS-SALD-MEN-SUM 
           END-IF. 
      
       2300-CORTE-MENOR-F. EXIT. 
      
      *--------------------------------------------------------------- 
       4000-LEER-FETCH-I. 
      
           EXEC SQL 
              FETCH CURSORCTA INTO :DCLTBCURCTA.CTA-TIPCUEN, 
                                   :DCLTBCURCTA.CTA-NROCUEN, 
                                   :DCLTBCURCTA.CTA-SUCUEN, 
                                   :DCLTBCURCTA.CTA-NROCLI, 
                                   :DCLTBCURCTA.CTA-SALDO, 
                                   :DCLTBCURCTA.CTA-FECSAL 
           END-EXEC 
      
           EVALUATE SQLCODE 
              WHEN ZEROS 
                 MOVE SPACES      TO IMP-REG-LISTADO 
                 MOVE ' | ' TO IMP-COL-1 IMP-COL-2 IMP-COL-3 
                 MOVE ' | ' TO IMP-COL-4 IMP-COL-5 IMP-COL-6 
                 MOVE CTA-TIPCUEN TO REG-TIPCUEN IMP-TIPCUEN 
                 MOVE CTA-NROCUEN TO REG-NROCUEN IMP-NROCUEN 
                 MOVE CTA-SUCUEN  TO REG-SUCUEN  IMP-SUCUEN-SUB 
                 MOVE CTA-NROCLI  TO REG-NROCLI  IMP-NROCLI 
                 MOVE CTA-SALDO   TO REG-SALDO   IMP-SALDO 
                 MOVE CTA-FECSAL  TO REG-FECSAL  FECHA-MODIF 
                 MOVE FECHA-MODIF TO IMP-FECSAL 
                 ADD 1            TO WS-LEIDOS-CANT 
      
              WHEN +100 
                 SET WS-FIN-LECTURA TO TRUE 
      *           MOVE 99999 TO WS-CLI-CLAVE 
              WHEN OTHER 
                 MOVE SQLCODE TO WS-SQLCODE 
                 DISPLAY 'ERROR FETCH CURSOR: ' WS-SQLCODE 
                 SET WS-FIN-LECTURA TO TRUE 
      *           MOVE 99999 TO WS-CLI-CLAVE 
           END-EVALUATE. 
      
       4000-LEER-FETCH-F. EXIT. 
      
      
      *--------------------------------------------------------- 
       6000-VERIF-TITULOS-I. 
      
           IF WS-CUENTA-LINEA GREATER WS-LINEA-FIJA THEN 
              WRITE REG-SALIDA FROM WS-SEPARATE AFTER 1 
              PERFORM 6500-IMPRIMIR-TITULO-I 
                 THRU 6500-IMPRIMIR-TITULO-F 
           END-IF 
      
           IF FS-LISTADO IS NOT EQUAL '00' THEN 
              DISPLAY '* ERROR EN WRITE LISTADO = ' FS-LISTADO 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-LECTURA TO TRUE 
           END-IF 
      
           ADD 1 TO WS-CUENTA-LINEA. 
      
       6000-VERIF-TITULOS-F. EXIT. 
      
      
      *--------------------------------------------------------- 
       6500-IMPRIMIR-TITULO-I. 
      
           MOVE WS-CUENTA-PAGINA TO IMP-TIT-PAGINA 
           MOVE 1 TO WS-CUENTA-LINEA 
           ADD  1 TO WS-CUENTA-PAGINA 
      
           WRITE REG-SALIDA FROM WS-SEPARATE AFTER PAGE 
           WRITE REG-SALIDA FROM IMP-TITULO  AFTER PAGE 
           WRITE REG-SALIDA FROM WS-LINE AFTER PAGE 
           IF FS-LISTADO IS NOT EQUAL '00' THEN 
              DISPLAY '* ERROR EN WRITE LISTADO = ' FS-LISTADO 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-LECTURA TO TRUE 
           END-IF. 
      
       6500-IMPRIMIR-TITULO-F. EXIT. 
      
      
      *-------------------------------------------------------- 
       6700-IMP-HEADER-MAYOR-I. 
      
           ADD 1 TO WS-CUENTA-LINEA 
           MOVE  REG-SUCUEN TO IMP-SUCUEN-SUB 
           WRITE REG-SALIDA FROM WS-SEPARATE AFTER 1 
           WRITE REG-SALIDA FROM WS-SEPARATE AFTER 1 
           WRITE REG-SALIDA FROM IMP-SUBT-SUCUEN AFTER 1. 
      
       6700-IMP-HEADER-MAYOR-F. EXIT. 
      
      
      *-------------------------------------------------------- 
       6700-IMP-HEADER-REG-I. 
      
           ADD 1 TO WS-CUENTA-LINEA 
           WRITE REG-SALIDA FROM IMP-HEADER-REG-IMP AFTER 1 
           WRITE REG-SALIDA FROM WS-LINE3 AFTER 1. 
      
       6700-IMP-HEADER-REG-F. EXIT. 
      
      
      *-------------------------------------------------------- 
       6800-IMP-HEADER-MENOR-I. 
      
           EVALUATE REG-TIPCUEN 
              WHEN 01 
                 MOVE 'CAJA DE AHORROS' TO IMP-TIPCUEN-SUB 
              WHEN 02 
                 MOVE 'CUENTAS CORRIENTES' TO IMP-TIPCUEN-SUB 
              WHEN 03 
                 MOVE 'PLAZO FIJO' TO IMP-TIPCUEN-SUB 
              WHEN OTHER 
                 MOVE 'ERROR NOMBRE CUENTA' TO IMP-TIPCUEN-SUB 
           END-EVALUATE 
      
           ADD 1 TO WS-CUENTA-LINEA 
           MOVE  REG-SUCUEN TO IMP-SUCUEN-SUB 
           WRITE REG-SALIDA FROM IMP-SUBT-TIPCUEN AFTER 1. 
      
       6800-IMP-HEADER-MENOR-F. EXIT. 
      
      
      *-------------------------------------------------------- 
       6900-IMP-REGISTRO-I. 
      
           ADD 1 TO WS-CUENTA-LINEA 
           ADD 1 TO WS-IMPRESOS-CANT 
           WRITE REG-SALIDA FROM IMP-REG-LISTADO AFTER 1. 
      
       6900-IMP-REGISTRO-F. EXIT. 
      
      
      *-------------------------------------------------------- 
       6850-IMP-FOOTER-I. 
      
           MOVE ZERO TO IMP-SALDO-PRINT 
           MOVE WS-MAYOR-CANT TO IMP-DATA-PRINT 
           MOVE WS-SALD-MAY-SUM TO IMP-SALDO-PRINT 
           WRITE REG-SALIDA FROM WS-LINE3 AFTER 1 
           WRITE REG-SALIDA FROM IMP-FOOTER-REG-IMP AFTER 1. 
      
       6850-IMP-FOOTER-F. EXIT. 
      
      
      *-------------------------------------------------------------- 
       9999-FINAL-I. 
      
           MOVE WS-REGISTROS-CANT TO WS-REGISTROS-PRINT 
           MOVE WS-SALD-TOT-SUM   TO WS-SALDO-PRINT 
           DISPLAY '____________________________________________' 
           DISPLAY 'LEIDOS      : ' WS-LEIDOS-CANT 
           DISPLAY 'IMPRESOS    : ' WS-IMPRESOS-CANT 
           DISPLAY 'TOTAL SALDOS: ' WS-SALDO-PRINT 
      
           EXEC SQL CLOSE CURSORCTA END-EXEC 
      
           CLOSE LISTADO 
           IF FS-LISTADO IS NOT EQUAL '00' THEN
              DISPLAY '* ERROR EN WRITE LISTADO = ' FS-LISTADO 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-LECTURA TO TRUE 
           END-IF. 
      
       9999-FINAL-F. EXIT. 