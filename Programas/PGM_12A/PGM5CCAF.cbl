       IDENTIFICATION DIVISION. 
       PROGRAM-ID. PGM5CCAF. 
                                                                        
      ***************************************************************
      *  CLASE ASINCRONICA 12                                       *
      *  ====================                                       *
      *  - Construir un programa COBOL con doble corte de control:  *
      *    - Corte mayor por Sucursal (CLIS-SUC).                   *
      *    - Corte menor por Tipo de Cuenta (CLIS-TIPO).            *
      *  - Leer registros desde un archivo secuencial de 50 bytes   * 
      *    de largo fijo, con estructura CPCLIENS.                  *
      *  - Para cada Sucursal, imprimir:                            *
      *    - El número de sucursal.                                 *
      *    - El total acumulado de importes (CLIS-IMPORTE)          *
      *      correspondientes a esa sucursal, con máscara que       *
      *      elimine ceros no significativos.                       *
      *  - Para cada Tipo de Cuenta dentro de cada sucursal:        *
      *    - Imprimir el tipo de cuenta.                            *
      *    - Imprimir el total acumulado de importes para ese tipo. *
      *  - Al final del programa, imprimir:                         *
      *    - Total general de importes acumulados en todo el        *
      *      archivo, también con formato limpio (sin ceros no      *
      *      significativos).                                       *
      *************************************************************** 
                                                                        
      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       ENVIRONMENT DIVISION. 
       CONFIGURATION SECTION. 
                                                                        
       SPECIAL-NAMES. 
           DECIMAL-POINT IS COMMA. 
                                                                        
       INPUT-OUTPUT SECTION. 
       FILE-CONTROL. 
                                                                        
           SELECT ENTRADA ASSIGN DDENTRA 
           FILE STATUS IS FS-ENT. 
                                                                        
           SELECT LISTADO ASSIGN DDLISTA 
           FILE STATUS IS FS-LISTADO. 
                                                                        
      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       DATA DIVISION. 
       FILE SECTION. 
                                                                        
       FD  ENTRADA 
           BLOCK CONTAINS 0 RECORDS 
           RECORDING MODE IS F. 
       01  REG-ENTRADA  PIC X(50). 
                                                                        
       FD  LISTADO 
           BLOCK CONTAINS 0 RECORDS 
           RECORDING MODE IS F. 
       01  REG-SALIDA        PIC X(132). 
                                                                        
                                                                        
       WORKING-STORAGE SECTION. 
      *=======================* 
                                                                        
      *---- ARCHIVOS ------------------------------------------------- 
       77  FS-ENT                  PIC XX               VALUE SPACES. 
       77  FS-LISTADO              PIC XX               VALUE ZEROS. 
                                                                        
       77  WS-STATUS-FIN           PIC X. 
           88  WS-FIN-LECTURA            VALUE 'Y'. 
           88  WS-NO-FIN-LECTURA         VALUE 'N'. 
                                                                        
      *---- VARIABLES  ----------------------------------------------- 
       77  WS-SUC-ANT              PIC 99               VALUE ZEROES. 
       77  WS-TIPO-ANT             PIC 99               VALUE ZEROES. 
                                                                        
      *---- ACUMULADORES --------------------------------------------- 
       77  WS-SUC-CANT             PIC 999              VALUE ZEROES. 
       77  WS-TIPO-CANT            PIC 999              VALUE ZEROES. 
       77  WS-REGISTROS-CANT       PIC 999              VALUE ZEROES. 
       77  WS-IMP-TIPO-SUM         PIC S9(09)V99 COMP-3 VALUE ZEROES. 
       77  WS-IMP-SUC-SUM          PIC S9(09)V99 COMP-3 VALUE ZEROES. 
       77  WS-TOTAL-SUM            PIC S9(09)V99 COMP-3 VALUE ZEROES. 
                                                                        
      *---- IMPRESION ------------------------------------------------ 
       77  WS-SUC-PRINT            PIC ZZ9              VALUE ZEROES. 
       77  WS-TIPO-PRINT           PIC ZZ9              VALUE ZEROES. 
       77  WS-REGISTROS-PRINT      PIC ZZ9              VALUE ZEROES. 
       77  WS-SALDO-PRINT          PIC -$ZZZ.ZZZ.ZZ9,99. 
       77  WS-SEPARADOR-IMP        PIC X(20)            VALUE SPACES. 
       77  WS-ESPACIADO-IMP        PIC X                VALUE SPACES. 
                                                                        
       01  WS-SUC-LINEA-IMP. 
           03  WS-TEXT1-IMP        PIC X(10)            VALUE SPACES. 
           03  WS-SUC-IMP          PIC 99               VALUE ZEROES. 
           03  FILLER              PIC XX               VALUE SPACES. 
                                                                        
       01  WS-TIPO-LINEA-IMP. 
           03  WS-TEXT2-IMP        PIC X(06)            VALUE SPACES. 
           03  WS-TIPO-IMP         PIC Z9               VALUE ZEROES. 
           03  WS-TEXT3-IMP        PIC XX               VALUE SPACES. 
           03  WS-IMP-TIPO-IMP     PIC -$ZZZ.ZZZ.ZZ9,99. 
                                                                        
       01  WS-TOTALR-LINEA-IMP. 
           03  WS-TEXT4-IMP        PIC X(18)            VALUE SPACES. 
           03  WS-REGISTROS-IMP    PIC ZZ9              VALUE ZEROES. 
                                                                        
       01  WS-TOTALS-LINEA-IMP. 
           03  WS-TEXT5-IMP        PIC X(14)            VALUE SPACES. 
           03  WS-SALDO-IMP        PIC -$ZZZ.ZZZ.ZZ9,99. 
                                                                        
                                                                        
                                                                        
      *////////////////////////////////////////////////////////////// 
      *       COPY CPCLIENS. 
      ************************************** 
      *         LAYOUT  ARCHIVO   CLIENTES * 
      *KC02788.ALU9999.CURSOS.CLIENTE      * 
      *         LARGO 50 BYTES             * 
      ************************************** 
       01  REG-CLIENTES. 
           03  CLIS-TIP-DOC        PIC X(02)            VALUE SPACES. 
           03  CLIS-NRO-DOC        PIC 9(11)            VALUE ZEROS. 
           03  CLIS-SUC            PIC 9(02)            VALUE ZEROS. 
           03  CLIS-TIPO           PIC 9(02)            VALUE ZEROS. 
           03  CLIS-NRO            PIC 9(03)            VALUE ZEROS. 
           03  CLIS-IMPORTE        PIC S9(09)V99 COMP-3 VALUE ZEROS. 
           03  CLIS-AAAAMMDD       PIC 9(08)            VALUE ZEROS. 
           03  CLIS-LOCALIDAD      PIC X(15)            VALUE SPACES. 
           03  FILLER              PIC X(01)            VALUE SPACES. 
      *////////////////////////////////////////////////////////////// 



      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       PROCEDURE DIVISION. 
                                                                        
                                                                        
       MAIN-PROGRAM-INICIO. 
                                                                        
           PERFORM 1000-INICIO-I  THRU  1000-INICIO-F. 
           PERFORM 2000-PROCESO-I THRU  2000-PROCESO-F 
                                  UNTIL WS-FIN-LECTURA. 
           PERFORM 9999-FINAL-I   THRU  9999-FINAL-F. 
                                                                        
       MAIN-PROGRAM-FINAL. GOBACK. 
                                                                        
                                                                        
      *-------------------------------------------------------------- 
       1000-INICIO-I. 
                                                                        
           SET WS-NO-FIN-LECTURA TO TRUE. 
                                                                        
           OPEN INPUT  ENTRADA. 
           IF FS-ENT IS NOT EQUAL '00' 
              DISPLAY '* ERROR EN OPEN ENTRADA INICIO = ' FS-ENT 
              SET  WS-FIN-LECTURA TO TRUE 
           END-IF. 
                                                                        
           OPEN OUTPUT LISTADO. 
           IF FS-LISTADO IS NOT EQUAL '00' 
              DISPLAY '* ERROR EN OPEN LISTADO = ' FS-LISTADO 
              MOVE 9999 TO RETURN-CODE 
              SET  WS-FIN-LECTURA TO TRUE 
           END-IF. 
                                                                        
           PERFORM 2500-LEER-I THRU 2500-LEER-F. 
                                                                        
           IF WS-FIN-LECTURA 
              DISPLAY '* ARCHIVO ENTRADA VACÍO EN INICIO' FS-ENT 
           ELSE 
              MOVE CLIS-SUC  TO WS-SUC-ANT 
              MOVE CLIS-TIPO  TO WS-TIPO-ANT 
              ADD 1 TO WS-SUC-CANT 
              ADD 1 TO WS-TIPO-CANT 
              ADD CLIS-IMPORTE TO WS-IMP-TIPO-SUM 
              DISPLAY '=================================' 
              DISPLAY 'SUCURSAL: ' WS-SUC-ANT 
              DISPLAY '---------------------------------' 
              
      *       IMPRESION                                                               
              MOVE "SUCURSAL: "      TO  WS-TEXT1-IMP 
              MOVE CLIS-SUC          TO  WS-SUC-IMP 
              WRITE REG-SALIDA FROM WS-SUC-LINEA-IMP AFTER 1 
           END-IF. 
                                                                        
       1000-INICIO-F. EXIT. 
                                                                        
                                                                        
      *-------------------------------------------------------------- 
       2000-PROCESO-I. 
                                                                        
           PERFORM 2500-LEER-I THRU 2500-LEER-F 
                                                                        
           IF WS-FIN-LECTURA THEN 
              PERFORM 2300-CORTE-MAYOR-I THRU 2300-CORTE-MAYOR-F 
           ELSE 
              IF CLIS-SUC IS EQUAL WS-SUC-ANT THEN 
                 ADD 1 TO WS-SUC-CANT 
                 IF CLIS-TIPO  IS EQUAL WS-TIPO-ANT THEN 
                    ADD 1 TO WS-TIPO-CANT 
                    ADD CLIS-IMPORTE TO WS-IMP-TIPO-SUM 
                 ELSE 
                    PERFORM 2600-CORTE-MENOR-I 
                       THRU 2600-CORTE-MENOR-F 
                 END-IF 
              ELSE 
                 PERFORM 2300-CORTE-MAYOR-I 
                    THRU 2300-CORTE-MAYOR-F 
              END-IF 
           END-IF. 

       2000-PROCESO-F. EXIT. 
                                                                        
                                                                        
      *---- CORTE DE CONTROL POR SUCURSAL  ---------------------------
       2300-CORTE-MAYOR-I. 
                                                                        
           PERFORM 2600-CORTE-MENOR-I THRU 2600-CORTE-MENOR-F 
                                                                        
           MOVE WS-SUC-CANT  TO WS-SUC-PRINT 
           MOVE WS-IMP-SUC-SUM TO WS-SALDO-PRINT 
           DISPLAY 'TOTAL => CANT: ' WS-SUC-PRINT 
                          ' SALDO: ' WS-SALDO-PRINT 
                                                                        
                                                                        
           MOVE CLIS-SUC TO WS-SUC-ANT 
           ADD WS-IMP-SUC-SUM TO WS-TOTAL-SUM 
           MOVE ZERO TO WS-IMP-SUC-SUM 
                                                                        
           IF NOT WS-FIN-LECTURA 
             DISPLAY ' ' 
             DISPLAY '=================================' 
             DISPLAY 'SUCURSAL: ' WS-SUC-ANT 
             DISPLAY '---------------------------------' 

      *      IMPRESION                                                                        
             MOVE SPACES       TO WS-SUC-LINEA-IMP 
             MOVE " "          TO WS-ESPACIADO-IMP 
             WRITE REG-SALIDA FROM WS-ESPACIADO-IMP AFTER 1 
                                                                        
             MOVE "SUCURSAL: " TO WS-TEXT1-IMP 
             MOVE CLIS-SUC     TO WS-SUC-IMP 
             WRITE REG-SALIDA FROM WS-SUC-LINEA-IMP AFTER 1 

           END-IF. 
                                                                        
           MOVE 1 TO WS-SUC-CANT 
           MOVE 1 TO WS-TIPO-CANT. 
                                                                        
       2300-CORTE-MAYOR-F. EXIT. 
                                                                        
                                                                        
      *---- CORTE DE CONTROL POR TIPO  -------------------------------
       2600-CORTE-MENOR-I. 
                                                                        
           MOVE WS-TIPO-CANT TO WS-TIPO-PRINT 
           MOVE WS-IMP-TIPO-SUM TO WS-SALDO-PRINT 
           DISPLAY 'TIPO: ' WS-TIPO-ANT 
                   ' CANT: ' WS-TIPO-PRINT 
                   ' SALDO: ' WS-SALDO-PRINT 

      *    IMPRESION           
           MOVE SPACES            TO  WS-TIPO-LINEA-IMP 
           MOVE "TIPO: "          TO  WS-TEXT2-IMP 
           MOVE WS-TIPO-ANT       TO  WS-TIPO-IMP 
           MOVE "  "              TO  WS-TEXT3-IMP 
           MOVE WS-IMP-TIPO-SUM   TO  WS-IMP-TIPO-IMP 
           WRITE REG-SALIDA FROM WS-TIPO-LINEA-IMP AFTER 1 
                                                                        
           ADD WS-IMP-TIPO-SUM TO WS-IMP-SUC-SUM 
           MOVE 1 TO WS-TIPO-CANT 
           MOVE CLIS-IMPORTE TO WS-IMP-TIPO-SUM 
           MOVE CLIS-TIPO  TO WS-TIPO-ANT. 
                                                                        
       2600-CORTE-MENOR-F. EXIT. 
                                                                        
                                                                        
      *-------------------------------------------------------------- 
       2500-LEER-I. 
                                                                        
           READ ENTRADA INTO REG-CLIENTES 
                                                                        
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
                                                                     
                                                                     
      *--------------------------------------------------------------
       9999-FINAL-I. 
                                                                     
           MOVE WS-REGISTROS-CANT TO WS-REGISTROS-PRINT 
           MOVE WS-TOTAL-SUM TO WS-SALDO-PRINT 
           DISPLAY ' ' 
           DISPLAY '**********************************************' 
           DISPLAY 'TOTAL REGISTROS = ' WS-REGISTROS-PRINT. 
           DISPLAY 'TOTAL SALDO = ' WS-SALDO-PRINT. 

      *    IMPRESION                                                                     
           MOVE SPACES       TO WS-SUC-LINEA-IMP 
           MOVE "********************" TO WS-SEPARADOR-IMP 
           MOVE "TOTAL REGISTROS = " TO WS-TEXT4-IMP 
           MOVE WS-REGISTROS-PRINT TO WS-REGISTROS-IMP 
           MOVE "TOTAL SALDO = " TO WS-TEXT5-IMP 
           MOVE WS-SALDO-PRINT TO WS-SALDO-IMP 
                                                                     
           WRITE REG-SALIDA FROM WS-SEPARADOR-IMP AFTER 1 
           WRITE REG-SALIDA FROM WS-TOTALR-LINEA-IMP AFTER 1 
           WRITE REG-SALIDA FROM WS-TOTALS-LINEA-IMP AFTER 1 
                                                                     
                                                                     
           CLOSE ENTRADA 
           IF FS-ENT IS NOT EQUAL '00' 
              DISPLAY '* ERROR EN CLOSE ENTRADA = ' FS-ENT 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-LECTURA TO TRUE 
           END-IF. 
                                                                        
           CLOSE LISTADO 
           IF FS-LISTADO IS NOT EQUAL '00' 
              DISPLAY '* ERROR EN CLOSE LISTADO = ' FS-LISTADO 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-LECTURA TO TRUE 
           END-IF. 
                                                                        
       9999-FINAL-F. EXIT.                                                                                                                                                       