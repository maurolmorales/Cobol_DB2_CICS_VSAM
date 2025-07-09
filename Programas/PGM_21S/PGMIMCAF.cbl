       IDENTIFICATION DIVISION. 
       PROGRAM-ID. PGMIMCAF. 

      ************************************************************** 
      *    CLASE SINCRÓNICA 21                                     * 
      *                                                            * 
      *  ESTE PROGRAMA PROCESA UN ARCHIVO DE ENTRADA DE CLIENTES   * 
      *  ORDENADO POR TIPO DE DOCUMENTO, REALIZANDO UN CORTE DE    * 
      *  CONTROL POR CADA CAMBIO DE TIPO DE DOCUMENTO.             * 
      *                                                            * 
      *  FUNCIONALIDADES PRINCIPALES:                              * 
      *  - LEE REGISTROS DE UN ARCHIVO DE ENTRADA (ENTRADA).       * 
      *  - GENERA UN LISTADO IMPRESO DE SALIDA (LISTADO) CON       * 
      *    INFORMACIóN DETALLADA Y FORMATEADA DE CADA CLIENTE.     * 
      *  - REALIZA UN CORTE DE CONTROL CADA VEZ QUE DETECTA UN     * 
      *    CAMBIO EN EL TIPO DE DOCUMENTO, MOSTRANDO SUBTOTALES    * 
      *    POR GRUPO.                                              * 
      *  - CONTROLA Y ORGANIZA LA PAGINACIóN, TíTULOS Y            * 
      *    SUBTíTULOS DEL LISTADO, AGREGANDO LíNEAS DE SEPARACIóN  * 
      *    Y TOTALES PARCIALES Y FINALES.                          * 
      *                                                            * 
      *  - MANEJA EL CONTROL DE LíNEA POR PáGINA PARA              * 
      *    REIMPRIMIR TíTULOS CUANDO ES NECESARIO.                 * 
      *  - MUESTRA ESTADíSTICAS DE REGISTROS LEíDOS E IMPRESOS.    * 
      *                                                            * 
      *  - CONTEMPLA VALIDACIONES DE APERTURA/CIERRE DE ARCHIVOS   * 
      *    Y MUESTRA MENSAJES DE ERROR POR PANTALLA CUANDO SE      * 
      *    PRODUCEN INCIDENTES.                                    * 
      ************************************************************** 
 
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
       01  REG-ENTRADA       PIC X(50). 
 
       FD  LISTADO 
           BLOCK CONTAINS 0 RECORDS 
           RECORDING MODE IS F. 
       01  REG-SALIDA        PIC X(132). 
 
 
       WORKING-STORAGE SECTION. 
      *======================= 
 
      *----------- ARCHIVOS ------------------------------------------ 
       77  FS-ENT                  PIC XX        VALUE SPACES. 
       77  FS-LISTADO              PIC XX        VALUE ZEROS. 
 
       77  WS-STATUS-FIN           PIC X. 
           88  WS-FIN-LECTURA                    VALUE 'Y'. 
           88  WS-NO-FIN-LECTURA                 VALUE 'N'. 
 
      *----------- VARIABLES  ---------------------------------------- 
       77  WS-TIPO-DOC-ANT        PIC XX         VALUE SPACES. 
 
      *----------- ACUMULADORES -------------------------------------- 
       77  WS-TIPO-DOC-CANT       PIC 999        VALUE ZEROES. 
       77  WS-REGISTROS-CANT      PIC 999        VALUE ZEROES. 
 
      *----  CONTADOR DE LEIDOS Y GRABADOS  ------------------------- 
       77  WS-LEIDOS-ENTRADA      PIC 9(05)      VALUE ZEROS. 
       77  WS-IMPRESOS            PIC 9(05)      VALUE ZEROS. 
 
      *----  FECHA DE PROCESO  -------------------------------------- 
       01  WS-FECHA. 
           03  WS-FECHA-AA        PIC 99         VALUE ZEROS. 
           03  WS-FECHA-MM        PIC 99         VALUE ZEROS. 
           03  WS-FECHA-DD        PIC 99         VALUE ZEROS. 
 
 
      *----------- IMPRESION ----------------------------------------- 
       77  WS-TIPO-DOC-PRINT      PIC ZZ9        VALUE ZEROES. 
       77  WS-REGISTROS-PRINT     PIC ZZ9        VALUE ZEROES. 
       77  WS-PIPE                PIC XXX        VALUE '|'. 
       77  WS-LINE                PIC X(132)     VALUE ALL '='. 
       77  WS-LINE2               PIC X(132)     VALUE ALL '-'. 
       77  WS-SEPARATE            PIC X(132)     VALUE SPACES. 
 
      * ULTIMA LINEA POR PáGINA 40 
       77  WS-CUENTA-LINEA        PIC 9(02)      VALUE ZEROS. 
       77  WS-CUENTA-PAGINA       PIC 9(02)      VALUE 01. 
 
      *----------- COPYS --------------------------------------------- 
      *        COPY CPCLIENS. 

      ************************************** 
      *         LAYOUT  ARCHIVO   CLIENTES * 
      *KC02788.ALU9999.CURSOS.CLIENTE      * 
      *         LARGO 50 BYTES             * 
      ************************************** 
       01  REG-CLIENTES. 
      *VALORES POSIBLES CLIS-TIP-DOC = DU, PA, PE 
           03  CLIS-TIP-DOC        PIC X(02)    VALUE SPACES. 
           03  CLIS-NRO-DOC        PIC 9(11)    VALUE ZEROS. 
      *VALORES POSIBLES CLIS-SUC= 01, 02, 03,......10 
           03  CLIS-SUC            PIC 9(02)    VALUE ZEROS. 
      *VALORES POSIBLES CLIS-TIPO= 01, 02, 03 
      * 01: CUENTAS CORRIENTES, 02: CAJA DE AHORROS; 03: PLAZO FIJO 
           03  CLIS-TIPO           PIC 9(02)    VALUE ZEROS. 
           03  CLIS-NRO            PIC 9(03)    VALUE ZEROS. 
           03  CLIS-IMPORTE        PIC S9(09)V99 COMP-3 VALUE ZEROS. 
      *VALORES POSIBLES CLIS-AAAAMMDD DEBE SER FECHA LóGICA 
           03  CLIS-AAAAMMDD       PIC 9(08)            VALUE ZEROS. 
      *VALOR EXTRAIDO DE PERSONAS 
           03  CLIS-LOCALIDAD      PIC X(15)    VALUE SPACES. 
           03  FILLER              PIC X(01)    VALUE SPACES.




      *----   IMRESION SALIDA 133----------------------------------- 
      * ULTIMA LINEA POR PáGINA 40 
       01  WS-REG-LISTADO. 
           03  WS-COL1            PIC X          VALUE SPACES. 
           03  WS-TIPDOC-IMP      PIC X(17)      VALUE SPACES. 
           03  WS-COL2            PIC X          VALUE SPACES. 
           03  WS-NUMDOC-IMP      PIC ZZZZZZZ.ZZZZ.999. 
           03  WS-COL3            PIC X          VALUE SPACES. 
           03  WS-SUC-IMP         PIC ZZZZZZ99. 
           03  WS-COL4            PIC X          VALUE SPACES. 
           03  WS-SUCTIPO-IMP     PIC ZZZZZZZZZ99. 
           03  WS-COL5            PIC X          VALUE SPACES. 
           03  WS-SUCNUM-IMP      PIC ZZZZ999. 
           03  WS-COL6            PIC X          VALUE SPACES. 
           03  WS-IMP-IMP         PIC -$ZZZZZZ9,99. 
           03  WS-COL7            PIC X          VALUE SPACES. 
           03  WS-FECHA-IMP       PIC ZZZZ/ZZ/ZZ. 
           03  WS-COL8            PIC X          VALUE SPACES. 
           03  WS-LOC-IMP         PIC X(15)      VALUE SPACES. 
           03  WS-COL9            PIC X          VALUE SPACES. 
 
      *----   TITULO   ---------------------------------------------- 
       01  WS-TITULO. 
           03  FILLER             PIC X          VALUE SPACES. 
           03  WS-SUC-TIT         PIC ZZ9        VALUE ZEROS. 
           03  FILLER             PIC X(05)      VALUE SPACES. 
           03  FILLER             PIC X(35)      VALUE 
                              'TOTAL CLIENTE/CUENTA POR SUCURSAL: '. 
           03  FILLER             PIC X          VALUE SPACES. 
           03  WS-DD-TIT          PIC Z9         VALUE ZEROS. 
           03  FILLER             PIC X          VALUE '-'. 
           03  WS-MM-TIT          PIC Z9         VALUE ZEROS. 
           03  FILLER             PIC X          VALUE '-'. 
           03  FILLER             PIC 99         VALUE 20. 
           03  WS-AA-TIT          PIC 99         VALUE ZEROS. 
           03  FILLER             PIC X(4)       VALUE SPACES. 
           03  FILLER             PIC X(15)      VALUE 
                                                    'NUMERO PAGINA: '. 
           03  WS-PAG-IMP         PIC Z9         VALUE ZEROS. 
           03  FILLER             PIC X(41)      VALUE SPACES. 
 
      *----   SUBTITULO   ----------------------------------------- 
       01  WS-SUBTITULO. 
           03  FILLER             PIC X          VALUE '|'. 
           03  WS-TIPDOC-SUB      PIC X(17)      VALUE 
                                                 'TIPO DE DOCUMENTO'. 
           03  FILLER             PIC X          VALUE '|'. 
           03  WS-NUMDOC-SUB      PIC X(16)      VALUE 
                                                 'NRO DE DOCUMENTO'. 
           03  FILLER             PIC X          VALUE '|'. 
           03  WS-SUC-SUB         PIC X(8)       VALUE 'SUCURSAL'. 
           03  FILLER             PIC X          VALUE '|'. 
           03  WS-SUCTIPO-SUB     PIC X(11)      VALUE 'TIPO CUENTA'. 
           03  FILLER             PIC X          VALUE '|'. 
           03  WS-SUCNUM-SUB      PIC X(7)       VALUE 'NUM-CTA'. 
           03  FILLER             PIC X          VALUE '|'. 
           03  WS-IMP-SUB         PIC X(12)      VALUE 'IMPORTE'. 
           03  FILLER             PIC X          VALUE '|'. 
           03  WS-FECHA-SUB       PIC X(10)      VALUE 'FECHA'. 
           03  FILLER             PIC X          VALUE '|'. 
           03  WS-LOC-SUB         PIC X(13)      VALUE 'LOCALIDAD'. 
           03  FILLER             PIC X          VALUE '|'. 
 
      *----   CORTE CONTROL----------------------------------------- 
       01  WS-CORTE-IMP. 
           03  FILLER             PIC X(10)      VALUE SPACES. 
           03  FILLER             PIC X(21)      VALUE 
                                            'CANTIDAD TIPO CUENTA '. 
           03  WS-TIPDOC-CORT     PIC X(2)       VALUE SPACES. 
           03  FILLER             PIC X(3)       VALUE SPACES. 
           03  WS-CANT-CORT       PIC ZZ9        VALUE ZEROES. 
           03  FILLER             PIC X(9)       VALUE SPACES. 
           03  FILLER             PIC X(96)      VALUE SPACES. 
 
      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       PROCEDURE DIVISION. 
 
       MAIN-PROGRAM-I. 

           PERFORM 1000-INICIO-I  THRU 1000-INICIO-F. 
           PERFORM 2000-PROCESO-I THRU 2000-PROCESO-F
                                 UNTIL WS-FIN-LECTURA. 
           PERFORM 9999-FINAL-I   THRU 9999-FINAL-F. 

       MAIN-PROGRAM-F. GOBACK. 
 
 
      *-------------------------------------------------------------- 
       1000-INICIO-I. 

           ACCEPT WS-FECHA FROM DATE. 
           MOVE WS-FECHA-AA TO WS-AA-TIT. 
           MOVE WS-FECHA-MM TO WS-MM-TIT. 
           MOVE WS-FECHA-DD TO WS-DD-TIT. 
           MOVE 18 TO WS-CUENTA-LINEA. 
           SET WS-NO-FIN-LECTURA TO TRUE. 
 
           OPEN INPUT ENTRADA. 
           IF FS-ENT IS NOT EQUAL '00' 
              DISPLAY '* ERROR EN OPEN ENTRADA INICIO = ' FS-ENT 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-LECTURA TO TRUE 
           END-IF. 

           OPEN OUTPUT LISTADO. 
           IF FS-LISTADO IS NOT EQUAL '00' 
              DISPLAY '* ERROR EN OPEN LISTADO = ' FS-LISTADO 
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
 
      *--------------------------------------------------------------
       2000-PROCESO-I. 
           MOVE SPACES            TO  WS-REG-LISTADO. 
           MOVE CLIS-TIP-DOC      TO  WS-TIPDOC-IMP 
           MOVE WS-PIPE           TO  WS-COL1 
           MOVE CLIS-NRO-DOC      TO  WS-NUMDOC-IMP 
           MOVE WS-PIPE           TO  WS-COL2 
           MOVE CLIS-SUC          TO  WS-SUC-IMP 
           MOVE WS-PIPE           TO  WS-COL3 
           MOVE CLIS-TIPO         TO  WS-SUCTIPO-IMP 
           MOVE WS-PIPE           TO  WS-COL4 
           MOVE CLIS-NRO          TO  WS-SUCNUM-IMP 
           MOVE WS-PIPE           TO  WS-COL5 
           MOVE CLIS-IMPORTE      TO  WS-IMP-IMP 
           MOVE WS-PIPE           TO  WS-COL6 
           MOVE CLIS-AAAAMMDD     TO  WS-FECHA-IMP 
           MOVE WS-PIPE           TO  WS-COL7 
           MOVE CLIS-LOCALIDAD    TO  WS-LOC-IMP 
           MOVE WS-PIPE           TO  WS-COL8 
 
           PERFORM 6000-GRABAR-SALIDA-I 
              THRU 6000-GRABAR-SALIDA-F 
 
           PERFORM 2100-LEER-I THRU 2100-LEER-F 
 
           IF WS-FIN-LECTURA THEN 
              PERFORM 2200-CORTE-MAYOR-I 
                THRU 2200-CORTE-MAYOR-F 
           ELSE 
              IF CLIS-TIP-DOC IS EQUAL WS-TIPO-DOC-ANT THEN 
                 ADD 1 TO WS-TIPO-DOC-CANT 
              ELSE 
                 PERFORM 2200-CORTE-MAYOR-I 
                    THRU 2200-CORTE-MAYOR-F 
                 PERFORM 6500-IMPRIMIR-TITULOS-I 
                    THRU  6500-IMPRIMIR-TITULOS-F 
              END-IF 
           END-IF. 
       2000-PROCESO-F. EXIT. 
                                                                      
                                                                      
      *---- CORTE DE CONTROL POR TIP-DOC -----------------------------
       2200-CORTE-MAYOR-I. 
                                                                      
           MOVE WS-TIPO-DOC-CANT TO WS-TIPO-DOC-PRINT 
           DISPLAY 'TOTAL TIPO DOCU = ' WS-TIPO-DOC-PRINT 
           MOVE WS-TIPO-DOC-ANT TO WS-TIPDOC-CORT 
           MOVE WS-TIPO-DOC-PRINT TO WS-CANT-CORT 
           PERFORM 2110-CORTE-IMPRIME-I 
              THRU 2110-CORTE-IMPRIME-F 
           MOVE 1 TO WS-CUENTA-LINEA. 
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
                 ADD 1 TO WS-LEIDOS-ENTRADA 
                 CONTINUE 
              WHEN '10' 
                 SET WS-FIN-LECTURA TO TRUE 
              WHEN OTHER 
                 DISPLAY '*ERROR EN LECTURA ENTRADA INICIO : ' FS-ENT 
                 MOVE 9999 TO RETURN-CODE 
                 SET WS-FIN-LECTURA TO TRUE 
           END-EVALUATE. 

       2100-LEER-F. EXIT. 
 
 
      *----  PARRAFO PARA GRABAR LA SALIDA ACTUALIZADA  ------------- 
       6000-GRABAR-SALIDA-I. 

           IF WS-CUENTA-LINEA GREATER 15 THEN 
 
              WRITE REG-SALIDA FROM WS-SEPARATE AFTER 1 
 
              PERFORM 6500-IMPRIMIR-TITULOS-I 
                 THRU 6500-IMPRIMIR-TITULOS-F 
 
           END-IF. 
 
           WRITE REG-SALIDA FROM WS-REG-LISTADO AFTER 1 
 
           IF FS-LISTADO IS NOT EQUAL '00' THEN 
              DISPLAY '* ERROR EN WRITE LISTADO = ' FS-LISTADO 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-LECTURA TO TRUE 
           END-IF. 
 
           ADD 1 TO WS-IMPRESOS 
           ADD 1 TO WS-CUENTA-LINEA. 

       6000-GRABAR-SALIDA-F. EXIT. 

      *-------------------------------------------------------------- 
       6500-IMPRIMIR-TITULOS-I. 

           MOVE WS-CUENTA-PAGINA TO WS-PAG-IMP. 
           MOVE 1 TO WS-CUENTA-LINEA. 
           ADD  1 TO WS-CUENTA-PAGINA. 
           MOVE CLIS-TIP-DOC TO WS-SUC-TIT. 
 
           WRITE REG-SALIDA FROM WS-TITULO AFTER PAGE 
           PERFORM 6500-IMPRIMIR-SUBTITULOS-I 
              THRU 6500-IMPRIMIR-SUBTITULOS-F 
 
      *    WRITE REG-SALIDA FROM WS-LINE2 AFTER 1 
 
           IF FS-LISTADO IS NOT EQUAL '00' 
              DISPLAY '* ERROR EN WRITE LISTADO = ' FS-LISTADO 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-LECTURA TO TRUE 
           END-IF. 

       6500-IMPRIMIR-TITULOS-F. EXIT. 
 
      *-------------------------------------------------------------- 
       6500-IMPRIMIR-SUBTITULOS-I. 

           MOVE 1 TO WS-CUENTA-LINEA. 
           WRITE REG-SALIDA FROM WS-SUBTITULO AFTER 1 
           WRITE REG-SALIDA FROM WS-LINE2 AFTER 1. 

       6500-IMPRIMIR-SUBTITULOS-F. EXIT. 
 
 
      *------------------------------------------------------------- 
       2110-CORTE-IMPRIME-I. 

           WRITE REG-SALIDA FROM WS-LINE     AFTER 1 
           WRITE REG-SALIDA FROM WS-CORTE-IMP AFTER 1 
           WRITE REG-SALIDA FROM WS-SEPARATE AFTER 1 
           WRITE REG-SALIDA FROM WS-SEPARATE AFTER 1.

       2110-CORTE-IMPRIME-F. 

      *------------------------------------------------------------- 
       9999-FINAL-I. 

           MOVE WS-REGISTROS-CANT TO WS-REGISTROS-PRINT 
           DISPLAY '**********************************************' 
           DISPLAY 'TOTAL REGISTROS = ' WS-REGISTROS-PRINT 
 
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
 
           DISPLAY 'LEIDOS:     ' WS-LEIDOS-ENTRADA 
           DISPLAY 'IMPRESOS:   ' WS-IMPRESOS. 
 
       9999-FINAL-F. EXIT.