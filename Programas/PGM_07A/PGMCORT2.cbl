       IDENTIFICATION DIVISION. 
       PROGRAM-ID. PGMCORT2. 
 
      ************************************************** 
      *  ASINCRONICA 7: CORTE CONTROL                  * 
      *  ============================                  * 
      *  - HACE UN CORTE DE CONTROL POR WS-SUC-NRO     * 
      *  - Y OTRO CORTE DE CONTROL POR WS-SUC-TIPC1    * 
      ************************************************** 
 
      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       ENVIRONMENT DIVISION. 
       CONFIGURATION SECTION. 
 
       SPECIAL-NAMES. 
           DECIMAL-POINT IS COMMA. 
 
       INPUT-OUTPUT SECTION. 
       FILE-CONTROL. 
           SELECT ENTRADA ASSIGN DDENTRA 
           FILE STATUS IS FS-ENT. 
 
      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       DATA DIVISION. 
       FILE SECTION. 
       FD  ENTRADA 
           BLOCK CONTAINS 0 RECORDS 
           RECORDING MODE IS F. 
       01  REG-ENTRADA  PIC X(93). 


      *---------------------------------------------------------------
       WORKING-STORAGE SECTION. 
 
      *---- ARCHIVOS ------------------------------------------------- 
       77  FS-ENT                  PIC XX         VALUE SPACES. 
 
       77  WS-STATUS-FIN           PIC X. 
           88  WS-FIN-LECTURA                     VALUE 'Y'. 
           88  WS-NO-FIN-LECTURA                  VALUE 'N'. 
 
      *---- VARIABLES  ----------------------------------------------- 
       77  WS-TIP-DOC-ANT          PIC XX         VALUE SPACES. 
       77  WS-SEXO-ANT             PIC X          VALUE SPACES. 
 
      *---- ACUMULADORES --------------------------------------------- 
       77  WS-TIP-DOC-CANT         PIC 999        VALUE ZEROES. 
       77  WS-SEXO-CANT            PIC 999        VALUE ZEROES. 
       77  WS-REGISTROS-CANT       PIC 999        VALUE ZEROES. 
 
      *---- IMPRESION ------------------------------------------------ 
       77  WS-TIP-DOC-PRINT        PIC ZZ9        VALUE ZEROES. 
       77  WS-SEXO-PRINT           PIC ZZ9        VALUE ZEROES. 
       77  WS-REGISTROS-PRINT      PIC ZZ9        VALUE ZEROES. 
 
      *---- COPYS ------------------------------------------------- 
      *     COPY CLICOB. 
      **********************************
      *    LAYOUT SUCURSAL             *
      *    ARCHIVO QSAM DE 93 BYTES    *
      **********************************
       01  WS-REG-CLICOB. 
           03  WS-SUC-TIP-DOC      PIC XX       VALUE SPACES. 
           03  WS-SUC-NRO-DOC      PIC 9(11)    VALUE ZEROS. 
           03  WS-SUC-NOMAPE       PIC X(30)    VALUE SPACES. 
           03  WS-SUC-EST-CIV      PIC X(10)    VALUE SPACES. 
           03  WS-SUC-SEXO         PIC X        VALUE SPACES. 
           03  FILLER              PIC X(39)    VALUE SPACES. 
                           
 
      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       PROCEDURE DIVISION. 
      *  CUERPO PRINCIPAL DEL PROGRAMA     * 
 
       MAIN-PROGRAM-INICIO. 
           PERFORM 1000-INICIO-I  THRU  1000-INICIO-F. 
           PERFORM 2000-PROCESO-I THRU  2000-PROCESO-F 
                                  UNTIL WS-FIN-LECTURA. 
           PERFORM 9999-FINAL-I   THRU  9999-FINAL-F. 
       MAIN-PROGRAM-FINAL. GOBACK. 
 
 
      *--------------------------------------------------------------- 
       1000-INICIO-I. 

           SET WS-NO-FIN-LECTURA TO TRUE. 
 
           OPEN INPUT  ENTRADA. 
 
           IF FS-ENT IS NOT EQUAL '00' 
              DISPLAY '* ERROR EN OPEN ENTRADA INICIO = ' FS-ENT 
              SET  WS-FIN-LECTURA TO TRUE 
           END-IF. 
 
 
      * LEER EL PRIMER REGISTRO FUERA DEL LOOP PRINCIPAL 
           PERFORM 2500-LEER-I THRU 2500-LEER-F. 
 
           IF WS-FIN-LECTURA 
              DISPLAY '* ARCHIVO ENTRADA VACÍO EN INICIO' FS-ENT 
           ELSE 
              MOVE WS-SUC-TIP-DOC TO WS-TIP-DOC-ANT 
              MOVE WS-SUC-SEXO TO WS-SEXO-ANT 
              ADD 1 TO WS-TIP-DOC-CANT 
              ADD 1 TO WS-SEXO-CANT 
              DISPLAY '=================================' 
              DISPLAY 'TIPO-DOC = ' WS-TIP-DOC-ANT 
              DISPLAY '---------------------------------' 
           END-IF. 

       1000-INICIO-F. EXIT. 
 
 
      *--------------------------------------------------------------- 
       2000-PROCESO-I.

           PERFORM 2500-LEER-I THRU 2500-LEER-F 
 
           IF WS-FIN-LECTURA THEN 
              PERFORM 2300-CORTE-TIPDOC-I THRU 2300-CORTE-TIPDOC-F 
           ELSE 
              IF WS-SUC-TIP-DOC = "DU" OR "PA" OR "PE" OR "CI" THEN 
                 IF WS-SUC-TIP-DOC IS EQUAL WS-TIP-DOC-ANT THEN 
                    ADD 1 TO WS-TIP-DOC-CANT 
                    IF WS-SUC-SEXO IS EQUAL WS-SEXO-ANT THEN 
                       ADD 1 TO WS-SEXO-CANT 
                    ELSE 
                       PERFORM 2600-CORTE-SEXO-I 
                          THRU 2600-CORTE-SEXO-F 
                    END-IF 
                 ELSE 
                    PERFORM 2300-CORTE-TIPDOC-I 
                       THRU 2300-CORTE-TIPDOC-F 
                 END-IF 
              END-IF 
           END-IF. 

       2000-PROCESO-F. EXIT. 
 
 
      *____ CORTE DE CONTROL POR TIP-DOC ____________________________ 
       2300-CORTE-TIPDOC-I. 

           PERFORM 2600-CORTE-SEXO-I THRU 2600-CORTE-SEXO-F 
 
           MOVE WS-TIP-DOC-CANT  TO WS-TIP-DOC-PRINT 
           DISPLAY 'TOTAL TIPO DOCU = ' WS-TIP-DOC-PRINT 
           MOVE WS-SUC-TIP-DOC  TO WS-TIP-DOC-ANT 
 
           IF NOT WS-FIN-LECTURA 
             DISPLAY ' ' 
             DISPLAY '=================================' 
             DISPLAY 'TIP-DOC = ' WS-TIP-DOC-ANT 
             DISPLAY '---------------------------------' 
           END-IF. 
 
           MOVE 1 TO WS-TIP-DOC-CANT 
           MOVE 1 TO WS-SEXO-CANT. 
      *    MOVE WS-SUC-SEXO   TO WS-SEXO-ANT. 

       2300-CORTE-TIPDOC-F. EXIT. 


 
      *____ CORTE DE CONTROL POR SEXO  ______________________________ 
       2600-CORTE-SEXO-I. 

           MOVE WS-SEXO-CANT TO WS-SEXO-PRINT 
           DISPLAY 'TOTAL SEXO ' WS-SEXO-ANT  ' '  WS-SEXO-PRINT 
 
           MOVE 1 TO WS-SEXO-CANT 
           MOVE WS-SUC-SEXO TO WS-SEXO-ANT. 

       2600-CORTE-SEXO-F. EXIT. 



      *--------------------------------------------------------------- 
       2500-LEER-I. 

           READ ENTRADA INTO WS-REG-CLICOB 
 
           EVALUATE FS-ENT 
              WHEN '00' 
                 ADD 1 TO WS-REGISTROS-CANT 
                 CONTINUE 
              WHEN '10' 
                 SET WS-FIN-LECTURA TO TRUE 
              WHEN OTHER 
                 DISPLAY '*ERROR EN LECTURA ENTRADA INICIO : ' FS-ENT 
                 SET WS-FIN-LECTURA TO TRUE 
           END-EVALUATE. 

       2500-LEER-F. EXIT. 
 
 
 
 
      *--------------------------------------------------------------- 
       9999-FINAL-I. 

           MOVE WS-REGISTROS-CANT TO WS-REGISTROS-PRINT 

           DISPLAY ' ' 
           DISPLAY '**********************************************' 
           DISPLAY 'TOTAL REGISTROS = ' WS-REGISTROS-PRINT. 
 
           CLOSE ENTRADA 
           IF FS-ENT IS NOT EQUAL '00' 
              DISPLAY '* ERROR EN CLOSE ENTRADA = ' FS-ENT 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-LECTURA TO TRUE 
           END-IF. 

       9999-FINAL-F. EXIT. 

