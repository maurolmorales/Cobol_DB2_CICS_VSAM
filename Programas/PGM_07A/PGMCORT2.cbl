       IDENTIFICATION DIVISION. 
       PROGRAM-ID. PGMCORT2. 
      
      ***************************************************************
      *                   CLASE ASINCRONICA 7                       *
      *                   ===================                       *
      *    - Construir un programa que resuelva:                    *
      *       - Corte mayor por TIPO DE DOCUMENTO (WS-SUC-TIP-DOC). *
      *       - Corte menor por SEXO (WS-SUC-SEXO).                 *
      *    - Procesar registros de un archivo secuencial con        *
      *      estructura fija de 93 bytes.                           *
      *    - Considerar solo documentos válidos: 'DU', 'PA', 'PE',  *
      *      'CI'.                                                  *
      *    - Contar y mostrar:                                      *
      *       - Cantidad de registros por SEXO al finalizar cada    *
      *         grupo de SEXO.                                      *
      *       - Cantidad de registros por TIPO DE DOCUMENTO al      *
      *         finalizar cada grupo de TIPO.                       *
      *    - Mostrar al final del programa el total general de      *
      *      registros leídos.                                      *
      *    - Controlar el caso en que el archivo esté vacío.        *
      ***************************************************************
      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       ENVIRONMENT DIVISION. 
       CONFIGURATION SECTION. 
      
       SPECIAL-NAMES. 
           DECIMAL-POINT IS COMMA. 
      
       INPUT-OUTPUT SECTION. 
       FILE-CONTROL. 
           SELECT ENTRADA ASSIGN DDENTRA 
           FILE STATUS IS FS-ENTRADA. 
      
      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       DATA DIVISION. 
       FILE SECTION. 
      
       FD  ENTRADA 
           BLOCK CONTAINS 0 RECORDS 
           RECORDING MODE IS F. 
       01  REG-ENTRADA  PIC X(93). 
      
       WORKING-STORAGE SECTION. 
      *=======================* 
      
      *---- ARCHIVOS ------------------------------------------------- 
       77  FS-ENTRADA              PIC XX         VALUE SPACES. 
      
       77  WS-STATUS-FIN           PIC X. 
           88  WS-FIN-LECTURA                     VALUE 'Y'. 
           88  WS-NO-FIN-LECTURA                  VALUE 'N'. 
      
      *---- VARIABLES  ----------------------------------------------- 
       77  WS-TIP-DOC-ANT          PIC XX         VALUE SPACES. 
       77  WS-SEXO-ANT             PIC X          VALUE SPACES. 
       77  WS-PRIMER-REG           PIC XX         VALUE 'SI'. 
      
      *---- ACUMULADORES --------------------------------------------- 
       77  WS-TIP-DOC-CANT         PIC 999        VALUE ZEROES. 
       77  WS-SEXO-CANT            PIC 999        VALUE ZEROES. 
       77  WS-REGISTROS-CANT       PIC 999        VALUE ZEROES. 
      
      *---- IMPRESION ------------------------------------------------ 
       77  WS-TIP-DOC-PRINT        PIC ZZ9        VALUE ZEROES. 
       77  WS-SEXO-PRINT           PIC ZZ9        VALUE ZEROES. 
       77  WS-REGISTROS-PRINT      PIC ZZ9        VALUE ZEROES. 
      
      *//////////////////////////////////////////////////////////////
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
      */////////////////////////////////////////////////////////////
      
      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       PROCEDURE DIVISION. 
      
       MAIN-PROGRAM-INICIO. 
      
           PERFORM 1000-INICIO-I  THRU 1000-INICIO-F 
           PERFORM 2000-PROCESO-I THRU 2000-PROCESO-F 
                                       UNTIL WS-FIN-LECTURA 
           PERFORM 9999-FINAL-I   THRU 9999-FINAL-F. 
      
       MAIN-PROGRAM-FINAL. GOBACK. 
      
      
      *--------------------------------------------------------------- 
       1000-INICIO-I. 
      
           SET WS-NO-FIN-LECTURA TO TRUE 
      
           OPEN INPUT  ENTRADA 
           IF FS-ENTRADA IS NOT EQUAL '00' THEN 
              DISPLAY '* ERROR EN OPEN ENTRADA INICIO = ' FS-ENTRADA 
              SET  WS-FIN-LECTURA TO TRUE 
           END-IF 
      
      * LEER EL PRIMER REGISTRO FUERA DEL LOOP PRINCIPAL 
           PERFORM 2500-LEER-I THRU 2500-LEER-F 
      
           IF WS-PRIMER-REG = 'SI' THEN 
              MOVE 'NO' TO WS-PRIMER-REG 
              IF WS-FIN-LECTURA THEN 
                 DISPLAY '* ARCHIVO ENTRADA VACÍO EN INICIO' FS-ENTRADA 
              ELSE 
                 MOVE WS-SUC-TIP-DOC TO WS-TIP-DOC-ANT 
                 MOVE WS-SUC-SEXO TO WS-SEXO-ANT 
                 ADD 1 TO WS-TIP-DOC-CANT 
                 ADD 1 TO WS-SEXO-CANT 
                 PERFORM 2700-PRINT-HEADER-I THRU 2700-PRINT-HEADER-F
              END-IF 
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
      
      
      *---- CORTE DE CONTROL POR TIP-DOC ---------------------------- 
       2300-CORTE-TIPDOC-I. 
      
           PERFORM 2600-CORTE-SEXO-I THRU 2600-CORTE-SEXO-F 
      
           MOVE WS-TIP-DOC-CANT  TO WS-TIP-DOC-PRINT 
           DISPLAY 'TOTAL TIPO DOCU = ' WS-TIP-DOC-PRINT 
           MOVE WS-SUC-TIP-DOC  TO WS-TIP-DOC-ANT 
      
           IF NOT WS-FIN-LECTURA 
              PERFORM 2700-PRINT-HEADER-I THRU 2700-PRINT-HEADER-F
           END-IF. 
      
           MOVE 1 TO WS-TIP-DOC-CANT 
           MOVE 1 TO WS-SEXO-CANT. 
      *    MOVE WS-SUC-SEXO   TO WS-SEXO-ANT. 
      
       2300-CORTE-TIPDOC-F. EXIT. 
      
      
      *---- CORTE DE CONTROL POR SEXO  ------------------------------ 
       2600-CORTE-SEXO-I. 
      
           MOVE WS-SEXO-CANT TO WS-SEXO-PRINT 
           DISPLAY 'TOTAL SEXO ' WS-SEXO-ANT  ' '  WS-SEXO-PRINT 
      
           MOVE 1 TO WS-SEXO-CANT 
           MOVE WS-SUC-SEXO TO WS-SEXO-ANT. 
      
       2600-CORTE-SEXO-F. EXIT. 
      
      *--------------------------------------------------------------- 
       2500-LEER-I. 
      
           READ ENTRADA INTO WS-REG-CLICOB 
      
           EVALUATE FS-ENTRADA 
              WHEN '00' 
                 ADD 1 TO WS-REGISTROS-CANT 
                 CONTINUE 
              WHEN '10' 
                 SET WS-FIN-LECTURA TO TRUE 
              WHEN OTHER 
                 DISPLAY '*ERROR EN LECTURA ENTRADA INICIO : ' 
                                                             FS-ENTRADA 
                 SET WS-FIN-LECTURA TO TRUE 
           END-EVALUATE. 
      
       2500-LEER-F. EXIT. 
         
      *--------------------------------------------------------------- 
       2700-PRINT-HEADER-I.
      
             DISPLAY ' ' 
             DISPLAY '=================================' 
             DISPLAY 'TIP-DOC = ' WS-TIP-DOC-ANT 
             DISPLAY ' '.
      
       2700-PRINT-HEADER-F. EXIT.
      
      
      *--------------------------------------------------------------- 
       9999-FINAL-I. 
      
           MOVE WS-REGISTROS-CANT TO WS-REGISTROS-PRINT 
           DISPLAY ' ' 
           DISPLAY '**********************************************' 
           DISPLAY 'TOTAL REGISTROS = ' WS-REGISTROS-PRINT 
      
           CLOSE ENTRADA 
           IF FS-ENTRADA IS NOT EQUAL '00' 
              DISPLAY '* ERROR EN CLOSE ENTRADA = ' FS-ENTRADA 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-LECTURA TO TRUE 
           END-IF. 
      
       9999-FINAL-F. EXIT.