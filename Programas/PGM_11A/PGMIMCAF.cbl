       IDENTIFICATION DIVISION. 
       PROGRAM-ID. PGMIMCAF. 
 
      ************************************************** 
      *    CLASE 11 ASÍNCRONA                          * 
      *                                                * 
      *    -  CORTE DE CONTROL                         * 
      *    -  IMPRESION                                * 
      *    -  ARCHIVO ENTRADA QSAM                     * 
      *    -  ARCHIVO SALIDA  QSAM                     * 
      *                                                * 
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

           SELECT LISTADO ASSIGN DDLISTA 
           FILE STATUS IS WS-FS-LISTADO.            
 
      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       DATA DIVISION. 
       FILE SECTION. 
       
       FD  ENTRADA 
           BLOCK CONTAINS 0 RECORDS 
           RECORDING MODE IS F. 
       01  REG-ENTRADA    PIC X(93). 

       FD  LISTADO 
           BLOCK CONTAINS 0 RECORDS 
           RECORDING MODE IS F. 
       01  REG-SALIDA     PIC X(132).        
 
       WORKING-STORAGE SECTION.
      *=======================* 
 
      *----------- ARCHIVOS ------------------------------------------ 
       77  FS-ENT                  PIC XX               VALUE SPACES. 
       77  WS-FS-LISTADO           PIC XX               VALUE ZEROES. 
 
       77  WS-STATUS-FIN           PIC X. 
           88  WS-FIN-LECTURA            VALUE 'Y'. 
           88  WS-NO-FIN-LECTURA         VALUE 'N'. 
 
      *----------- VARIABLES  ---------------------------------------- 
       77  WS-TIPO-DOC-ANT         PIC XX               VALUE SPACES. 
 
      *----------- ACUMULADORES -------------------------------------- 
       77  WS-TIPO-DOC-CANT        PIC 999              VALUE ZEROES. 
       77  WS-REGISTROS-CANT       PIC 999              VALUE ZEROES. 

      *----  CONTADOR DE LEIDOS Y GRABADOS  -------------------------
       01  WS-LEIDOS-FILE1         PIC 9(05)            VALUE ZEROS. 
       01  WS-IMPRESOS             PIC 9(05)            VALUE ZEROS. 

      *----  FECHA DE PROCESO  --------------------------------------
       01  WS-FECHA. 
           03  WS-FECHA-AA         PIC 99               VALUE ZEROS. 
           03  WS-FECHA-MM         PIC 99               VALUE ZEROS. 
           03  WS-FECHA-DD         PIC 99               VALUE ZEROS.
 
      *----------- IMPRESION ----------------------------------------- 
       77  WS-TIPO-DOC-PRINT       PIC ZZ9.
       77  WS-REGISTROS-PRINT      PIC ZZ9. 
       77  WS-TOTALES-PRINT        PIC ZZZZ9.              

      */////////// COPYS /////////////////////////////////////////////
      *     COPY CPCLIENS. 
      ************************************** 
      *    LAYOUT  ARCHIVO   CLIENTES      * 
      *    KC02788.ALU9999.CURSOS.CLIENTE  * 
      *    LARGO 50 BYTES                  * 
      ************************************** 
       01  REG-CLIENTES. 
           03  CLIS-TIP-DOC        PIC X(02)    VALUE SPACES. 
           03  CLIS-NRO-DOC        PIC 9(11)    VALUE ZEROS. 
           03  CLIS-SUC            PIC 9(02)    VALUE ZEROS. 
           03  CLIS-TIPO           PIC 9(02)    VALUE ZEROS. 
           03  CLIS-NRO            PIC 9(03)    VALUE ZEROS. 
           03  CLIS-IMPORTE        PIC S9(09)V99 COMP-3 VALUE ZEROS. 
           03  CLIS-AAAAMMDD       PIC 9(08)            VALUE ZEROS. 
           03  CLIS-LOCALIDAD      PIC X(15)    VALUE SPACES. 
           03  FILLER              PIC X(01)    VALUE SPACES. 
      *///////////////////////////////////////////////////////////////


      *----   IMRESION SALIDA 133----------------------------------- 
       01  WS-REG-LISTADO. 
           03  FILLER              PIC X        VALUE SPACES. 
           03  WS-TIP-DOC          PIC XX       VALUE SPACES. 
           03  FILLER              PIC X        VALUE SPACES. 
           03  WS-NRO-DOC          PIC 9(11)    VALUE ZEROES. 
           03  FILLER              PIC X        VALUE SPACES. 
           03  WS-SUC-DOC          PIC 99       VALUE ZEROS. 
           03  FILLER              PIC X        VALUE SPACES. 
           03  WS-TIPO-DOC         PIC 99       VALUE ZEROES.  
           03  FILLER              PIC X        VALUE SPACES. 
           03  WS-NRO              PIC 999      VALUE ZEROES. 
           03  FILLER              PIC X        VALUE SPACES. 
           03  WS-IMPORTE-DOC      PIC S9(09)V99 VALUE ZEROES. 
           03  FILLER              PIC X        VALUE SPACES. 
           03  WS-FECHA-DOC        PIC 9(08)    VALUE ZEROES. 
           03  FILLER              PIC X        VALUE SPACES. 
           03  WS-LOCALIDAD        PIC X(15)    VALUE SPACES. 
           03  FILLER              PIC X(1)    VALUE SPACES.      

      * ULTIMA LINEA POR PáGINA 60 
       77  WS-CUENTA-LINEA         PIC 9(02)    VALUE ZEROS. 
       77  WS-CUENTA-PAGINA        PIC 9(02)    VALUE 01.


       01  WS-TITULO. 
           03  FILLER              PIC X        VALUE SPACES. 
           03  WS-SUCURSAL         PIC ZZ9      VALUE ZEROS. 
           03  FILLER              PIC X(05)    VALUE SPACES. 
           03  FILLER              PIC X(35)    VALUE 
                               'TOTAL CLIENTE/CUENTA POR SUCURSAL: ' . 
           03  FILLER              PIC X        VALUE SPACES. 
           03  WS-DD               PIC Z9       VALUE ZEROS. 
           03  FILLER              PIC X        VALUE '-'. 
           03  WS-MM               PIC Z9       VALUE ZEROS. 
           03  FILLER              PIC X        VALUE '-'. 
           03  FILLER              PIC 99       VALUE 20. 
           03  WS-AA               PIC 99       VALUE ZEROS. 
           03  FILLER              PIC X(4)     VALUE SPACES. 
           03  FILLER              PIC X(15)    VALUE 
                                                    'NUMERO PAGINA: '. 
           03  WS-PAGINA           PIC Z9       VALUE ZEROS. 
           03  FILLER              PIC X(41)    VALUE SPACES. 



      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       PROCEDURE DIVISION. 
 
       MAIN-PROGRAM-I. 

           PERFORM 1000-INICIO-I  THRU  1000-INICIO-F. 
           PERFORM 2000-PROCESO-I 
              THRU 2000-PROCESO-F UNTIL WS-FIN-LECTURA. 
           PERFORM 9999-FINAL-I   THRU  9999-FINAL-F. 

       MAIN-PROGRAM-L. GOBACK. 
 
 
      *_______________________________________________________________ 
       1000-INICIO-I. 

           ACCEPT WS-FECHA FROM DATE. 
           MOVE WS-FECHA-AA TO WS-AA. 
           MOVE WS-FECHA-MM TO WS-MM. 
           MOVE WS-FECHA-DD TO WS-DD. 
           MOVE 62 TO WS-CUENTA-LINEA. 

           SET WS-NO-FIN-LECTURA TO TRUE. 
 
           OPEN INPUT ENTRADA. 
           IF FS-ENT IS NOT EQUAL '00' 
              DISPLAY '* ERROR EN OPEN ENTRADA INICIO = ' FS-ENT 
              SET  WS-FIN-LECTURA TO TRUE 
           END-IF. 

           OPEN OUTPUT LISTADO. 
           IF WS-FS-LISTADO IS NOT EQUAL '00' 
              DISPLAY '* ERROR EN OPEN LISTADO = ' WS-FS-LISTADO 
              MOVE 9999 TO RETURN-CODE 
              SET  WS-FIN-LECTURA TO TRUE 
           END-IF. 
 
           PERFORM 2100-LEER-I THRU 2100-LEER-F 
 
           IF WS-FIN-LECTURA 
              DISPLAY '* ARCHIVO ENTRADA VACÍO EN INICIO' FS-ENT 
           ELSE 
              MOVE CLIS-TIP-DOC TO WS-TIPO-DOC-ANT 
              ADD 1 TO WS-TIPO-DOC-CANT 
              DISPLAY '=================================' 
              DISPLAY 'TIPO-DOC: ' WS-TIPO-DOC-ANT 
           END-IF. 
           
       1000-INICIO-F. EXIT. 
 
 
      *_______________________________________________________________ 
       2000-PROCESO-I. 

           MOVE SPACES             TO  WS-REG-LISTADO. 
           MOVE  CLIS-TIP-DOC      TO  WS-TIP-DOC 
           MOVE  CLIS-NRO-DOC      TO  WS-NRO-DOC 
           MOVE  CLIS-SUC          TO  WS-SUC-DOC 
           MOVE  CLIS-TIPO         TO  WS-TIPO-DOC    
           MOVE  CLIS-NRO          TO  WS-NRO 
           MOVE  CLIS-IMPORTE      TO  WS-IMPORTE-DOC 
           MOVE  CLIS-AAAAMMDD     TO  WS-FECHA-DOC    
           MOVE  CLIS-LOCALIDAD    TO  WS-LOCALIDAD.

           PERFORM 6000-GRABAR-SALIDA-I
              THRU 6000-GRABAR-SALIDA-F.

           PERFORM 2100-LEER-I 
              THRU 2100-LEER-F 
 
           IF WS-FIN-LECTURA THEN 
              PERFORM 2200-CORTE-MAYOR-I 
                 THRU 2200-CORTE-MAYOR-F 
           ELSE 
              IF CLIS-TIP-DOC IS EQUAL WS-TIPO-DOC-ANT THEN 
                 ADD 1 TO WS-TIPO-DOC-CANT 
              ELSE 
                 PERFORM 2200-CORTE-MAYOR-I 
                    THRU 2200-CORTE-MAYOR-F 
              END-IF 
           END-IF. 

       2000-PROCESO-F. EXIT. 



      *--------------------------------------------------------------
       6000-GRABAR-SALIDA-I. 

           IF WS-CUENTA-LINEA GREATER 60 THEN
              PERFORM 6500-IMPRIMIR-TITULOS-I 
                 THRU 6500-IMPRIMIR-TITULOS-F
           END-IF. 
 
           WRITE REG-SALIDA  FROM WS-REG-LISTADO AFTER 1. 
           IF WS-FS-LISTADO IS NOT EQUAL '00' THEN 
              DISPLAY '* ERROR EN WRITE LISTADO = ' WS-FS-LISTADO 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-LECTURA TO TRUE 
           END-IF. 
 
             ADD 1 TO WS-IMPRESOS 
             ADD 1 TO WS-CUENTA-LINEA. 

       6000-GRABAR-SALIDA-F. EXIT.       


      *--------------------------------------------------------------
       6500-IMPRIMIR-TITULOS-I. 

           MOVE WS-CUENTA-PAGINA TO WS-PAGINA. 
           MOVE 1 TO WS-CUENTA-LINEA. 
           ADD  1 TO WS-CUENTA-PAGINA. 
           MOVE  CLIS-TIP-DOC TO WS-SUCURSAL. 
           WRITE REG-SALIDA FROM WS-TITULO AFTER PAGE. 
 
           IF WS-FS-LISTADO IS NOT EQUAL '00' 
              DISPLAY '* ERROR EN WRITE LISTADO = ' WS-FS-LISTADO 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-LECTURA TO TRUE 
           END-IF. 

       6500-IMPRIMIR-TITULOS-F. EXIT. 


      *--------------------------------------------------------------
       2200-CORTE-MAYOR-I. 
 
           MOVE WS-TIPO-DOC-CANT TO WS-TIPO-DOC-PRINT 
           DISPLAY 'TOTAL TIPO DOCU = ' WS-TIPO-DOC-PRINT 
           MOVE CLIS-TIP-DOC  TO WS-TIPO-DOC-ANT 
 
           IF NOT WS-FIN-LECTURA 
             DISPLAY ' ' 
             DISPLAY '=================================' 
             DISPLAY 'TIP-DOC = ' WS-TIPO-DOC-ANT 
           END-IF 
           MOVE 1 TO WS-TIPO-DOC-CANT. 
 
       2200-CORTE-MAYOR-F. EXIT. 


      *-------------------------------------------------------------- 
       2100-LEER-I. 

           READ ENTRADA INTO REG-CLIENTES 
 
           EVALUATE FS-ENT 
              WHEN '00' 
                 ADD 1 TO WS-REGISTROS-CANT 
                 ADD 1 TO WS-LEIDOS-FILE1 
                 CONTINUE 
              WHEN '10' 
                 SET WS-FIN-LECTURA TO TRUE 
              WHEN OTHER 
                 DISPLAY '*ERROR EN LECTURA ENTRADA INICIO : ' FS-ENT 
                 MOVE 9999 TO RETURN-CODE
                 SET WS-FIN-LECTURA TO TRUE 
           END-EVALUATE. 
           
       2100-LEER-F. EXIT. 


      *--------------------------------------------------------------- 
       9999-FINAL-I. 

           MOVE WS-REGISTROS-CANT TO WS-REGISTROS-PRINT 
           DISPLAY '**********************************************' 
           DISPLAY 'TOTAL REGISTROS = ' WS-REGISTROS-PRINT.

           CLOSE ENTRADA 
           IF FS-ENT IS NOT EQUAL '00' 
              DISPLAY '* ERROR EN CLOSE ENTRADA = ' FS-ENT 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-LECTURA TO TRUE 
           END-IF. 

           CLOSE LISTADO 
           IF WS-FS-LISTADO IS NOT EQUAL '00' 
              DISPLAY '* ERROR EN CLOSE LISTADO = ' WS-FS-LISTADO 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-LECTURA TO TRUE 
           END-IF. 

           MOVE WS-LEIDOS-FILE1 TO WS-REGISTROS-PRINT 
           DISPLAY 'LEIDOS:     ' WS-REGISTROS-PRINT 
           MOVE WS-IMPRESOS     TO WS-REGISTROS-PRINT 
           DISPLAY 'IMPRESOS:   ' WS-REGISTROS-PRINT.      
                              
       9999-FINAL-F. EXIT. 