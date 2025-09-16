       IDENTIFICATION DIVISION. 
       PROGRAM-ID. PROGM11A. 
 
      *************************************************************** 
      *    CLASE 11 ASÍNCRONA                                       * 
      *    ==================                                       * 
      *    - Implementar un corte de control por tipo de documento. *
      *    - Imprimir los registros de clientes leídos desde un     *
      *      archivo.                                               *
      *    - Generar un archivo de salida en formato FBA (Fixed     *
      *      Block Address) con registros de 132 bytes.             *
      *                                                             * 
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
                                                                        
           SELECT LISTADO ASSIGN DDLISTA 
           FILE STATUS IS FS-LISTADO. 
                                                                        
      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       DATA DIVISION. 
       FILE SECTION. 
                                                                        
       FD  ENTRADA 
           BLOCK CONTAINS 0 RECORDS 
           RECORDING MODE IS F. 
       01  REG-ENTRADA  PIC X(93). 
                                                                        
       FD  LISTADO 
           BLOCK CONTAINS 0 RECORDS 
           RECORDING MODE IS F. 
       01  REG-SALIDA   PIC X(132). 
                                                                        
       WORKING-STORAGE SECTION. 
      *========================* 
      *----------- ARCHIVOS ----------------------------------------- 
       77  FS-ENTRADA              PIC XX       VALUE SPACES. 
       77  FS-LISTADO              PIC XX       VALUE SPACES. 
                                                                        
       77  WS-STATUS-FIN           PIC X. 
           88  WS-FIN-LECTURA         VALUE 'Y'. 
           88  WS-NO-FIN-LECTURA      VALUE 'N'. 
                                                                        
       77  WS-STATUS-NOV           PIC X. 
           88  WS-FIN-NOV             VALUE 'Y'. 
           88  WS-NO-FIN-NOV          VALUE 'N'. 
                                                                        
       77  WS-STATUS-ENT           PIC X. 
           88  WS-FIN-ENT             VALUE 'Y'. 
           88  WS-NO-FIN-ENT          VALUE 'N'. 
 
      *-----------  VARIABLES  ------------------------------- 
       77  WS-TIPO-DOC-ANT         PIC XX               VALUE SPACES. 
                                                                        
      *----------- ACUMULADORES ------------------------------ 
       77  WS-TIPO-DOC-CANT        PIC 999               VALUE ZEROES. 
       77  WS-REGISTROS-CANT       PIC 999               VALUE ZEROES. 
                                                                        
      *-----------  IMPRESION  --------------------------------- 
       77  WS-TIPO-DOC-PRINT       PIC ZZ9. 
       77  WS-REGISTROS-PRINT      PIC ZZ9. 
       77  WS-PIPE                 PIC XXX              VALUE '|'. 
       77  WS-LINE                 PIC X(132)           VALUE ALL '='. 
       77  WS-LINE2                PIC X(132)           VALUE ALL '-'. 
       77  WS-SEPARATE             PIC X(132)           VALUE SPACES. 
       77  WS-CUENTA-LINEA         PIC 9(02)            VALUE ZEROS. 
       77  WS-CUENTA-PAGINA        PIC 9(02)            VALUE 01. 
       
      *-----------  FECHA DE PROCESO  ------------------------ 
       01  WS-FECHA. 
           03  WS-FECHA-AA         PIC 99                VALUE ZEROS. 
           03  WS-FECHA-MM         PIC 99                VALUE ZEROS. 
           03  WS-FECHA-DD         PIC 99                VALUE ZEROS. 
                                                                        
       01  WS-FECHA-VAR. 
           03  WS-FECHA-VAR-AA     PIC 9999              VALUE ZEROES. 
           03  WS-FECHA-VAR-MM     PIC 99                VALUE ZEROES. 
           03  WS-FECHA-VAR-DD     PIC 99                VALUE ZEROES. 
                                                                        
       01  FECHA-MODIF. 
           03  FM-DIA              PIC 9(2). 
           03  FM-SEP1             PIC X                VALUE '-'. 
           03  FM-MES              PIC 9(2). 
           03  FM-SEP2             PIC X                VALUE '-'. 
           03  FM-ANIO             PIC 9(4). 
 
      *    CONTADOR DE LEIDOS Y GRABADOS 
       01  WS-LEIDOS               PIC 9(05)            VALUE ZEROS. 
       01  WS-IMPRESOS             PIC 9(05)            VALUE ZEROS. 
                                                                        
       01  IMP-REG-LISTADO. 
           03  IMP-COL1            PIC X(03). 
           03  FILLER              PIC X(04)           VALUE SPACES. 
           03  IMP-TIP-DOC         PIC XX. 
           03  FILLER              PIC X(01)           VALUE SPACES. 
           03  IMP-COL2            PIC X(03). 
           03  FILLER              PIC X(01)           VALUE SPACES. 
           03  IMP-NRO-DOC         PIC ZZZ.ZZZ.ZZZ.ZZZ. 
           03  IMP-COL3            PIC X(03). 
           03  IMP-SUC             PIC 9(02). 
           03  IMP-COL4            PIC X(03). 
           03  IMP-TIPO            PIC 9(02). 
           03  IMP-COL5            PIC X(03). 
           03  IMP-NRO             PIC 9(03). 
           03  IMP-COL6            PIC X(03). 
           03  IMP-IMPORTE         PIC -$ZZ.ZZZ.ZZZ,99. 
           03  IMP-COL7            PIC X(03). 
           03  IMP-FECHA           PIC ZZZZZZZZZZ. 
           03  IMP-COL8            PIC X(03). 
           03  IMP-LOCALIDAD       PIC X(15). 
           03  IMP-COL9            PIC X(03). 

      *    TITULO: 
       01  IMP-TITULO. 
           03  FILLER              PIC X                VALUE SPACES. 
           03  IMP-TIT-SUCURSAL    PIC XX. 
           03  FILLER              PIC X(05)            VALUE SPACES. 
           03  FILLER              PIC X(35)            VALUE 
                     'TOTAL CLIENTE/CUENTA POR SUCURSAL: ' . 
           03  FILLER              PIC X                VALUE SPACES. 
           03  IMP-TIT-DD          PIC Z9               VALUE ZEROES. 
           03  FILLER              PIC X                VALUE '-'. 
           03  IMP-TIT-MM          PIC Z9               VALUE ZEROES. 
           03  FILLER              PIC X                VALUE '-'. 
           03  FILLER              PIC 99               VALUE 20. 
           03  IMP-TIT-AA          PIC 99               VALUE ZEROES. 
           03  FILLER              PIC X(4)             VALUE SPACES. 
           03  FILLER              PIC X(15)            VALUE 
                                          'NUMERO PAGINA: '. 
           03  IMP-TIT-PAGINA      PIC Z9               VALUE ZEROES. 
           03  FILLER              PIC X(41)            VALUE SPACES. 
  
      *    SUBTITULO: 
       01  IMP-SUBTITULO. 
           03  FILLER              PIC X                  VALUE '|'. 
           03  IMP-TIP-DOC-SUB     PIC X(09)              VALUE 
               "TIPO DOC.". 
           03  FILLER              PIC X                  VALUE '|'. 
           03  FILLER              PIC X                  VALUE SPACE. 
           03  IMP-NRO-DOC-SUB     PIC X(14)              VALUE 
               "NUM. DOCUMENTO". 
           03  FILLER              PIC X(03)              VALUE SPACE. 
           03  FILLER              PIC X                  VALUE '|'. 
           03  IMP-SUC-SUB         PIC X(04)              VALUE 
               "SUC.". 
           03  FILLER              PIC X                  VALUE '|'. 
           03  IMP-TIPO-SUB        PIC X(04)              VALUE 
               "TIPO". 
           03  FILLER              PIC X                  VALUE '|'. 
           03  FILLER              PIC X                  VALUE SPACE. 
           03  IMP-NRO-SUB         PIC X(04)              VALUE 
               "NUM.". 
           03  FILLER              PIC X                  VALUE '|'. 
           03  FILLER              PIC X(4)               VALUE SPACE. 
           03  IMP-IMPORTE-SUB     PIC X(12)              VALUE 
               "IMPORTE". 
           03  FILLER              PIC X(1)               VALUE SPACE. 
           03  FILLER              PIC X                  VALUE '|'. 
           03  FILLER              PIC X(3)               VALUE SPACE. 
           03  IMP-FECHA-SUB       PIC X(05)              VALUE 
               "FECHA". 
           03  FILLER              PIC X(4)               VALUE SPACE. 
           03  FILLER              PIC X                  VALUE '|'. 
           03  FILLER              PIC X(4)               VALUE SPACE. 
           03  IMP-LOCALIDAD-SUB   PIC X(09)              VALUE 
               "LOCALIDAD". 
           03  FILLER              PIC X(4)               VALUE SPACE. 
           03  FILLER              PIC X                  VALUE '|'. 

      *    CORTE CONTROL IMPRESO: 
       01  IMP-CORTE-IMP. 
           03  FILLER              PIC X(10)            VALUE SPACES. 
           03  FILLER              PIC X(21)            VALUE 
           'CANTIDAD TIPO CUENTA '. 
           03  IMP-TIPODOC-CORTE   PIC X(2)             VALUE SPACES. 
           03  FILLER              PIC X(3)             VALUE SPACES. 
           03  IMP-CANT-CORTE      PIC ZZ9              VALUE ZEROES. 
           03  FILLER              PIC X(9)             VALUE SPACES. 
           03  FILLER              PIC X(96)            VALUE SPACES. 


      */////////// COPYS //////////////////////////////////////////// 
      *    COPY CPCLIENS. 

      ************************************** 
      *    LAYOUT  ARCHIVO   CLIENTES      * 
      *    KC02788.ALU9999.CURSOS.CLIENTE  * 
      *    LARGO 50 BYTES                  * 
      ************************************** 
       01  REG-CLIENTES. 
           03  CLIS-TIP-DOC        PIC X(02)            VALUE SPACES. 
           03  CLIS-NRO-DOC        PIC 9(11)            VALUE ZEROES. 
           03  CLIS-SUC            PIC 9(02)            VALUE ZEROES. 
           03  CLIS-TIPO           PIC 9(02)            VALUE ZEROES. 
           03  CLIS-NRO            PIC 9(03)            VALUE ZEROES. 
           03  CLIS-IMPORTE        PIC S9(09)V99 COMP-3 VALUE ZEROES. 
           03  CLIS-AAAAMMDD       PIC 9(08)            VALUE ZEROES. 
           03  CLIS-LOCALIDAD      PIC X(15)            VALUE SPACES. 
           03  FILLER              PIC X(01)            VALUE SPACES. 
      *//////////////////////////////////////////////////////////////

      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       PROCEDURE DIVISION. 
                                                                        
       MAIN-PROGRAM-I. 
                                                                        
           PERFORM 1000-INICIO-I  THRU  1000-INICIO-F. 
           PERFORM 2000-PROCESO-I THRU  2000-PROCESO-F 
                                  UNTIL WS-FIN-LECTURA. 
           PERFORM 9999-FINAL-I   THRU  9999-FINAL-F. 
                                                                        
       MAIN-PROGRAM-F. GOBACK. 
                                                                        
                                                                        
      *-------------------------------------------------------------- 
       1000-INICIO-I. 
                                                                        
           ACCEPT WS-FECHA FROM DATE. 
           MOVE WS-FECHA-AA TO IMP-TIT-AA. 
           MOVE WS-FECHA-MM TO IMP-TIT-MM. 
           MOVE WS-FECHA-DD TO IMP-TIT-DD. 
           MOVE 15 TO WS-CUENTA-LINEA. 
           SET WS-NO-FIN-LECTURA TO TRUE. 
                                                                        
           OPEN INPUT ENTRADA. 
           IF FS-ENTRADA IS NOT EQUAL '00' 
              DISPLAY '* ERROR EN OPEN ENTRADA INICIO = ' FS-ENTRADA 
              SET  WS-FIN-LECTURA TO TRUE 
           END-IF. 
           OPEN OUTPUT LISTADO. 
           IF FS-LISTADO IS NOT EQUAL '00' 
              DISPLAY '* ERROR EN OPEN LISTADO = ' FS-LISTADO 
              MOVE 9999 TO RETURN-CODE 
              SET  WS-FIN-LECTURA TO TRUE 
           END-IF. 
                                                                        
      * LEER EL PRIMER REGISTRO FUERA DEL LOOP PRINCIPAL 
           PERFORM 2100-LEER-I THRU 2100-LEER-F. 
                                                                        
           IF WS-FIN-LECTURA 
              DISPLAY '* ARCHIVO ENTRADA VACÍO EN INICIO' FS-ENTRADA 
           ELSE 
              MOVE CLIS-TIP-DOC TO WS-TIPO-DOC-ANT 
              ADD 1 TO  WS-TIPO-DOC-CANT 
              DISPLAY '=================================' 
              DISPLAY 'TIPO-DOC = ' WS-TIPO-DOC-ANT 
      *       IMPRESION TITULOS 
              PERFORM 6500-IMPRIMIR-TITULOS-I 
                 THRU 6500-IMPRIMIR-TITULOS-F 
           END-IF. 
       1000-INICIO-F. EXIT. 
                                                                        
      *-------------------------------------------------------------- 
       2000-PROCESO-I. 
                                                                        
           MOVE SPACES             TO  IMP-REG-LISTADO 
           MOVE  WS-PIPE           TO  IMP-COL1 
           MOVE  CLIS-TIP-DOC      TO  IMP-TIP-DOC 
           MOVE  WS-PIPE           TO  IMP-COL2 
           MOVE  CLIS-NRO-DOC      TO  IMP-NRO-DOC 
           MOVE  WS-PIPE           TO  IMP-COL3 
           MOVE  CLIS-SUC          TO  IMP-SUC 
           MOVE  WS-PIPE           TO  IMP-COL4 
           MOVE  CLIS-TIPO         TO  IMP-TIPO 
           MOVE  WS-PIPE           TO  IMP-COL5 
           MOVE  CLIS-NRO          TO  IMP-NRO 
           MOVE  WS-PIPE           TO  IMP-COL6 
           MOVE  CLIS-IMPORTE      TO  IMP-IMPORTE 
           MOVE  WS-PIPE           TO  IMP-COL7 
           MOVE  CLIS-AAAAMMDD     TO  WS-FECHA-VAR 
           MOVE  WS-FECHA-VAR-AA   TO  FM-ANIO 
           MOVE  WS-FECHA-VAR-MM   TO  FM-MES 
           MOVE  WS-FECHA-VAR-DD   TO  FM-DIA 
           MOVE  FECHA-MODIF       TO  IMP-FECHA 
           MOVE  WS-PIPE           TO  IMP-COL8 
           MOVE  CLIS-LOCALIDAD    TO  IMP-LOCALIDAD 
           MOVE  WS-PIPE           TO  IMP-COL9 
                                                                       
           PERFORM 6000-GRABAR-SALIDA-I THRU 6000-GRABAR-SALIDA-F 
           PERFORM 2100-LEER-I THRU 2100-LEER-F 
                                                                       
           IF WS-FIN-LECTURA THEN 
              PERFORM 2200-CORTE-MAYOR-I THRU 2200-CORTE-MAYOR-F 
           ELSE 
              IF CLIS-TIP-DOC IS EQUAL WS-TIPO-DOC-ANT THEN 
                 ADD 1 TO  WS-TIPO-DOC-CANT 
              ELSE 
                 PERFORM 2200-CORTE-MAYOR-I THRU 2200-CORTE-MAYOR-F 
              END-IF 
           END-IF. 
                                                                       
       2000-PROCESO-F. EXIT. 
                                                                       
                                                                       
      *---- CORTE DE CONTROL MAYOR  --------------------------- 
       2200-CORTE-MAYOR-I. 
                                                                       
           MOVE WS-TIPO-DOC-ANT  TO IMP-TIPODOC-CORTE 
           MOVE WS-TIPO-DOC-CANT TO IMP-CANT-CORTE 

           MOVE  WS-TIPO-DOC-CANT  TO WS-TIPO-DOC-PRINT 
           DISPLAY 'TOTAL TIPO DOCU = ' WS-TIPO-DOC-PRINT 
           MOVE CLIS-TIP-DOC  TO WS-TIPO-DOC-ANT 
                                                                        
           PERFORM 6700-CORTE-IMPRIME-I THRU 6700-CORTE-IMPRIME-F 
                                                                        
           IF NOT WS-FIN-LECTURA 
             DISPLAY ' ' 
             DISPLAY '=================================' 
             DISPLAY 'TIP-DOC = ' WS-TIPO-DOC-ANT 
           END-IF. 
                                                                        
           MOVE 1 TO  WS-TIPO-DOC-CANT. 
                                                                        
       2200-CORTE-MAYOR-F. EXIT. 
                                                                        
                                                                        
      *-------------------------------------------------------------- 
       2100-LEER-I. 
                                                                        
           READ ENTRADA INTO REG-CLIENTES 
                          AT END SET WS-FIN-LECTURA TO TRUE 
                          MOVE HIGH-VALUE TO REG-CLIENTES. 
                                                                        
           EVALUATE FS-ENTRADA 
              WHEN '00' 
                 ADD 1 TO WS-REGISTROS-CANT 
                 ADD 1 TO WS-LEIDOS 
                 CONTINUE 
              WHEN '10' 
                 SET WS-FIN-LECTURA TO TRUE 
              WHEN OTHER 
                 DISPLAY '*ERROR EN LECTURA ENTRADA INICIO : ' 
                                                     FS-ENTRADA 
                 SET WS-FIN-LECTURA TO TRUE 
           END-EVALUATE. 
                                                                        
       2100-LEER-F. EXIT. 
                                                                        
                                                                        
      *--------------------------------------------------------- 
       6000-GRABAR-SALIDA-I. 
                                                                        
           IF WS-CUENTA-LINEA GREATER 15 THEN 
              WRITE REG-SALIDA FROM WS-SEPARATE AFTER 1 
              PERFORM 6500-IMPRIMIR-TITULOS-I 
                 THRU 6500-IMPRIMIR-TITULOS-F 
           END-IF. 
           WRITE REG-SALIDA FROM IMP-REG-LISTADO AFTER 1. 
                                                                        
           IF FS-LISTADO IS NOT EQUAL '00' THEN 
              DISPLAY '* ERROR EN WRITE LISTADO = ' FS-LISTADO 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-LECTURA TO TRUE 
           END-IF. 
                                                                        
           ADD 1 TO WS-IMPRESOS 
           ADD 1 TO WS-CUENTA-LINEA. 
                                                                        
       6000-GRABAR-SALIDA-F. EXIT. 
                                                                        
      *--------------------------------------------------------- 
       6500-IMPRIMIR-TITULOS-I. 
                                                                        
           MOVE WS-CUENTA-PAGINA TO IMP-TIT-PAGINA. 
           MOVE 1 TO WS-CUENTA-LINEA. 
           ADD  1 TO WS-CUENTA-PAGINA. 
           MOVE CLIS-TIP-DOC TO IMP-TIT-SUCURSAL. 
           WRITE REG-SALIDA FROM IMP-TITULO AFTER PAGE. 
                                                                        
           PERFORM 6600-IMPRIMIR-SUBTITULOS-I 
              THRU 6600-IMPRIMIR-SUBTITULOS-F 
                                                                        
           IF FS-LISTADO IS NOT EQUAL '00' 
              DISPLAY '* ERROR EN WRITE LISTADO = ' FS-LISTADO 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-LECTURA TO TRUE 
           END-IF. 
                                                                        
       6500-IMPRIMIR-TITULOS-F. EXIT. 
                                                                        
      *-------------------------------------------------------- 
       6600-IMPRIMIR-SUBTITULOS-I. 
                                                                        
           MOVE 1 TO WS-CUENTA-LINEA. 
           WRITE REG-SALIDA FROM WS-LINE2 AFTER 1. 
           WRITE REG-SALIDA FROM IMP-SUBTITULO AFTER 1 
           WRITE REG-SALIDA FROM WS-LINE2 AFTER 1. 
                                                                        
       6600-IMPRIMIR-SUBTITULOS-F. EXIT. 
                                                                        
      *-------------------------------------------------------- 
       6700-CORTE-IMPRIME-I. 
                                                                        
           WRITE REG-SALIDA FROM WS-LINE       AFTER 1 
           WRITE REG-SALIDA FROM IMP-CORTE-IMP AFTER 1 
           WRITE REG-SALIDA FROM WS-SEPARATE   AFTER 1 
           WRITE REG-SALIDA FROM WS-SEPARATE   AFTER 1. 
                                                                        
       6700-CORTE-IMPRIME-F. 
                                                                        
      *-------------------------------------------------------------- 
       9999-FINAL-I. 
                                                                        
           MOVE WS-REGISTROS-CANT TO WS-REGISTROS-PRINT 
           DISPLAY ' ' 
           DISPLAY '==============================================' 
           DISPLAY 'TOTAL REGISTROS = ' WS-REGISTROS-PRINT. 

           CLOSE ENTRADA 
           IF FS-ENTRADA IS NOT EQUAL '00' 
              DISPLAY '* ERROR EN CLOSE ENTRADA = ' FS-ENTRADA 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-LECTURA TO TRUE 
           END-IF. 
                                                                        
           CLOSE LISTADO 
           IF FS-LISTADO IS NOT EQUAL '00' 
              DISPLAY '* ERROR EN CLOSE LISTADO = ' FS-LISTADO 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-LECTURA TO TRUE 
           END-IF. 
                                                                        
           DISPLAY 'LEIDOS:     ' WS-LEIDOS. 
           DISPLAY 'IMPRESOS:   ' WS-IMPRESOS. 
                                                                        
       9999-FINAL-F. EXIT.                                                                                                                                     