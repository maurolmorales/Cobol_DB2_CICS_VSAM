       IDENTIFICATION DIVISION. 
       PROGRAM-ID. PROGM21S. 

      ******************************************************************
      *                    CLASE SINCRÓNICA 21                         *
      *                    ===================                         *
      *  ESTE PROGRAMA PROCESA UN ARCHIVO DE ENTRADA DE CLIENTES       *
      *  ORDENADO POR TIPO DE DOCUMENTO, REALIZANDO UN CORTE DE        *
      *  CONTROL POR CADA CAMBIO DE TIPO DE DOCUMENTO.                 *
      *                                                                *
      *  FUNCIONALIDADES PRINCIPALES:                                  *
      *  - LEE REGISTROS DE UN ARCHIVO DE ENTRADA (ENTRADA).           *
      *  - GENERA UN LISTADO IMPRESO DE SALIDA (LISTADO) CON           *
      *    INFORMACIóN DETALLADA Y FORMATEADA DE CADA CLIENTE.         *
      *  - REALIZA UN CORTE DE CONTROL CADA VEZ QUE DETECTA UN         *
      *    CAMBIO EN EL TIPO DE DOCUMENTO, MOSTRANDO SUBTOTALES        *
      *    POR GRUPO.                                                  *
      *  - CONTROLA Y ORGANIZA LA PAGINACIóN, TíTULOS Y                *
      *    SUBTíTULOS DEL LISTADO, AGREGANDO LíNEAS DE SEPARACIóN      *
      *    Y TOTALES PARCIALES Y FINALES.                              *
      *                                                                *
      *  - MANEJA EL CONTROL DE LíNEA POR PáGINA PARA                  *
      *    REIMPRIMIR TíTULOS CUANDO ES NECESARIO.                     *
      *  - MUESTRA ESTADíSTICAS DE REGISTROS LEíDOS E IMPRESOS.        *
      *                                                                *
      *  - CONTEMPLA VALIDACIONES DE APERTURA/CIERRE DE ARCHIVOS       *
      *    Y MUESTRA MENSAJES DE ERROR POR PANTALLA CUANDO SE          *
      *    PRODUCEN INCIDENTES.                                        *
      ******************************************************************
      
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
      *========================* 
      
      *----------- ARCHIVOS ------------------------------------------ 
       77  FS-ENT                  PIC XX        VALUE SPACES. 
       77  FS-LISTADO              PIC XX        VALUE ZEROS. 
      
       77  WS-STATUS-FIN           PIC X. 
           88  WS-FIN-LECTURA                    VALUE 'Y'. 
           88  WS-NO-FIN-LECTURA                 VALUE 'N'. 
      
      *----------- VARIABLES  ---------------------------------------- 
       77  WS-TIPO-DOC-ANT        PIC XX         VALUE SPACES. 
       77  WS-PRIMER-REG          PIC XX         VALUE 'SI'. 
            
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
       77  IMP-TIPO-DOC-PRINT      PIC ZZ9        VALUE ZEROES. 
       77  IMP-REGISTROS-PRINT     PIC ZZ9        VALUE ZEROES. 
       77  IMP-PIPE                PIC X(03)      VALUE ' | '. 
       77  IMP-LINE                PIC X(132)     VALUE ALL '='. 
       77  IMP-LINE2               PIC X(132)     VALUE ALL '-'. 
       77  IMP-SEPARATE            PIC X(132)     VALUE SPACES. 
      
      * ULTIMA LINEA POR PáGINA 40 
       77  IMP-CUENTA-LINEA        PIC 9(02)      VALUE ZEROS. 
       77  IMP-CUENTA-PAGINA       PIC 9(02)      VALUE 01. 
      
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
           03  WS-COL1            PIC X(03)             VALUE SPACES. 
           03  WS-TIPDOC-IMP      PIC X(17)             VALUE SPACES. 
           03  WS-COL2            PIC X(03)             VALUE SPACES. 
           03  WS-NUMDOC-IMP      PIC ZZZZZZZ.ZZZZ.999. 
           03  WS-COL3            PIC X(03)             VALUE SPACES. 
           03  WS-SUC-IMP         PIC ZZZZZZ99. 
           03  WS-COL4            PIC X(03)             VALUE SPACES. 
           03  WS-SUCTIPO-IMP     PIC ZZZZZZZZZ99. 
           03  WS-COL5            PIC X(03)             VALUE SPACES. 
           03  WS-SUCNUM-IMP      PIC ZZZZ999. 
           03  WS-COL6            PIC X(03)             VALUE SPACES. 
           03  WS-IMP-IMP         PIC -$ZZZZZZ9,99. 
           03  WS-COL7            PIC X(03)             VALUE SPACES. 
           03  WS-FECHA-IMP       PIC ZZZZ/ZZ/ZZ. 
           03  WS-COL8            PIC X(03)             VALUE SPACES. 
           03  WS-LOC-IMP         PIC X(15)             VALUE SPACES. 
           03  WS-COL9            PIC X(03)             VALUE SPACES. 
      
      *----   TITULO   ---------------------------------------------- 
       01  IMP-TITULO. 
           03  FILLER             PIC X                 VALUE SPACES. 
           03  IMP-SUC-TIT        PIC ZZ9               VALUE ZEROES. 
           03  FILLER             PIC X(05)             VALUE SPACES. 
           03  FILLER             PIC X(35)             VALUE 
                                 'TOTAL CLIENTE/CUENTA POR SUCURSAL: '.
           03  FILLER             PIC X                 VALUE SPACES. 
           03  IMP-DD-TIT         PIC Z9                VALUE ZEROES. 
           03  FILLER             PIC X                 VALUE '-'. 
           03  IMP-MM-TIT         PIC Z9                VALUE ZEROES. 
           03  FILLER             PIC X                 VALUE '-'. 
           03  FILLER             PIC 99                VALUE 20. 
           03  IMP-AA-TIT         PIC 99                VALUE ZEROES. 
           03  FILLER             PIC X(04)             VALUE SPACES. 
           03  FILLER             PIC X(15)  VALUE 'NUMERO PAGINA: '. 
           03  IMP-PAG-IMP        PIC Z9                VALUE ZEROES. 
           03  FILLER             PIC X(41)             VALUE SPACES. 
      
      *----   SUBTITULO   ----------------------------------------- 
       01  IMP-SUBTITULO. 
           03  FILLER             PIC X(03)  VALUE ' | '. 
           03  IMP-TIPDOC-SUB     PIC X(17)  VALUE 'TIPO DE DOCUMENTO'. 
           03  FILLER             PIC X(03)  VALUE ' | '. 
           03  IMP-NUMDOC-SUB     PIC X(16)  VALUE 'NRO DE DOCUMENTO'. 
           03  FILLER             PIC X(03)  VALUE ' | '. 
           03  IMP-SUC-SUB        PIC X(08)  VALUE 'SUCURSAL'. 
           03  FILLER             PIC X(03)  VALUE ' | '. 
           03  IMP-SUCTIPO-SUB    PIC X(11)  VALUE 'TIPO CUENTA'. 
           03  FILLER             PIC X(03)  VALUE ' | '. 
           03  IMP-SUCNUM-SUB     PIC X(07)  VALUE 'NUM-CTA'. 
           03  FILLER             PIC X(03)  VALUE ' | '. 
           03  IMP-IMP-SUB        PIC X(12)  VALUE 'IMPORTE'. 
           03  FILLER             PIC X(03)  VALUE ' | '. 
           03  IMP-FECHA-SUB      PIC X(10)  VALUE 'FECHA'. 
           03  FILLER             PIC X(03)  VALUE ' | '. 
           03  IMP-LOC-SUB        PIC X(13)  VALUE 'LOCALIDAD'. 
           03  FILLER             PIC X(03)  VALUE ' | '. 
      
      *----   CORTE CONTROL----------------------------------------- 
       01  IMP-CORTE. 
           03  FILLER             PIC X(10)             VALUE SPACES. 
           03  FILLER             PIC X(21)             VALUE 
                                             'CANTIDAD TIPO CUENTA '. 
           03  IMP-TIPDOC-CORT    PIC X(02)             VALUE SPACES. 
           03  FILLER             PIC X(03)             VALUE SPACES. 
           03  IMP-CANT-CORT      PIC ZZ9               VALUE ZEROES. 
           03  FILLER             PIC X(09)             VALUE SPACES. 
           03  FILLER             PIC X(96)             VALUE SPACES. 
      
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
      
           ACCEPT WS-FECHA FROM DATE 
           MOVE WS-FECHA-AA TO IMP-AA-TIT 
           MOVE WS-FECHA-MM TO IMP-MM-TIT 
           MOVE WS-FECHA-DD TO IMP-DD-TIT 
           MOVE 18 TO IMP-CUENTA-LINEA 
           SET WS-NO-FIN-LECTURA TO TRUE 
      
           OPEN INPUT ENTRADA 
           IF FS-ENT IS NOT EQUAL '00' THEN
              DISPLAY '* ERROR EN OPEN ENTRADA INICIO = ' FS-ENT 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-LECTURA TO TRUE 
           END-IF 
      
           OPEN OUTPUT LISTADO 
           IF FS-LISTADO IS NOT EQUAL '00' THEN
              DISPLAY '* ERROR EN OPEN LISTADO = ' FS-LISTADO 
              MOVE 9999 TO RETURN-CODE 
              SET  WS-FIN-LECTURA TO TRUE 
           END-IF 
      
           PERFORM 2100-LEER-I THRU 2100-LEER-F 
      
           IF WS-PRIMER-REG = 'SI' THEN 
              MOVE 'NO' TO WS-PRIMER-REG 
              IF WS-FIN-LECTURA THEN
                 DISPLAY '* ARCHIVO ENTRADA VACÍO EN INICIO' FS-ENT 
              ELSE 
                 MOVE CLIS-TIP-DOC TO WS-TIPO-DOC-ANT 
                 ADD 1 TO WS-TIPO-DOC-CANT 
                 DISPLAY '=================================' 
                 DISPLAY 'TIPO-DOC: ' WS-TIPO-DOC-ANT 
              END-IF
           END-IF. 
      
       1000-INICIO-F. EXIT. 
      
      *--------------------------------------------------------------
       2000-PROCESO-I. 

           PERFORM 2100-LEER-I THRU 2100-LEER-F 
      
           MOVE SPACES            TO  WS-REG-LISTADO
           MOVE CLIS-TIP-DOC      TO  WS-TIPDOC-IMP 
           MOVE IMP-PIPE          TO  WS-COL1 
           MOVE CLIS-NRO-DOC      TO  WS-NUMDOC-IMP 
           MOVE IMP-PIPE          TO  WS-COL2 
           MOVE CLIS-SUC          TO  WS-SUC-IMP 
           MOVE IMP-PIPE          TO  WS-COL3 
           MOVE CLIS-TIPO         TO  WS-SUCTIPO-IMP 
           MOVE IMP-PIPE          TO  WS-COL4 
           MOVE CLIS-NRO          TO  WS-SUCNUM-IMP 
           MOVE IMP-PIPE          TO  WS-COL5 
           MOVE CLIS-IMPORTE      TO  WS-IMP-IMP 
           MOVE IMP-PIPE          TO  WS-COL6 
           MOVE CLIS-AAAAMMDD     TO  WS-FECHA-IMP 
           MOVE IMP-PIPE          TO  WS-COL7 
           MOVE CLIS-LOCALIDAD    TO  WS-LOC-IMP 
           MOVE IMP-PIPE          TO  WS-COL8 
      
           PERFORM 6000-GRABAR-SALIDA-I THRU 6000-GRABAR-SALIDA-F 
      
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
      
           MOVE WS-TIPO-DOC-CANT TO IMP-TIPO-DOC-PRINT 
           DISPLAY 'TOTAL TIPO DOCU = ' IMP-TIPO-DOC-PRINT 
           MOVE WS-TIPO-DOC-ANT TO IMP-TIPDOC-CORT 
           MOVE IMP-TIPO-DOC-PRINT TO IMP-CANT-CORT 
           PERFORM 2110-CORTE-IMPRIME-I THRU 2110-CORTE-IMPRIME-F 
           MOVE 1 TO IMP-CUENTA-LINEA. 
           MOVE CLIS-TIP-DOC  TO WS-TIPO-DOC-ANT 
      
           IF NOT WS-FIN-LECTURA THEN
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
      
           IF IMP-CUENTA-LINEA GREATER 15 THEN 
              WRITE REG-SALIDA FROM IMP-SEPARATE AFTER 1 
              PERFORM 6500-IMPRIMIR-TITULOS-I 
                 THRU 6500-IMPRIMIR-TITULOS-F 
           END-IF  
  
           WRITE REG-SALIDA FROM WS-REG-LISTADO AFTER 1 
           IF FS-LISTADO IS NOT EQUAL '00' THEN 
              DISPLAY '* ERROR EN WRITE LISTADO = ' FS-LISTADO 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-LECTURA TO TRUE 
           END-IF 
      
           ADD 1 TO WS-IMPRESOS 
           ADD 1 TO IMP-CUENTA-LINEA. 
      
       6000-GRABAR-SALIDA-F. EXIT. 
      
      *-------------------------------------------------------------- 
       6500-IMPRIMIR-TITULOS-I. 
      
           MOVE IMP-CUENTA-PAGINA TO IMP-PAG-IMP 
           MOVE 1 TO IMP-CUENTA-LINEA 
           ADD  1 TO IMP-CUENTA-PAGINA 
           MOVE CLIS-TIP-DOC TO IMP-SUC-TIT 
      
           WRITE REG-SALIDA FROM IMP-TITULO AFTER PAGE 
           PERFORM 6500-IMPRIMIR-SUBTITULOS-I 
              THRU 6500-IMPRIMIR-SUBTITULOS-F 
      
           IF FS-LISTADO IS NOT EQUAL '00' THEN
              DISPLAY '* ERROR EN WRITE LISTADO = ' FS-LISTADO 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-LECTURA TO TRUE 
           END-IF. 
      
       6500-IMPRIMIR-TITULOS-F. EXIT. 
      
      *-------------------------------------------------------------- 
       6500-IMPRIMIR-SUBTITULOS-I. 
      
           MOVE 1 TO IMP-CUENTA-LINEA 
           WRITE REG-SALIDA FROM IMP-SUBTITULO AFTER 1 
           WRITE REG-SALIDA FROM IMP-LINE2 AFTER 1. 
      
       6500-IMPRIMIR-SUBTITULOS-F. EXIT. 
      
      
      *------------------------------------------------------------- 
       2110-CORTE-IMPRIME-I. 
      
           WRITE REG-SALIDA FROM IMP-LINE  AFTER 1 
           WRITE REG-SALIDA FROM IMP-CORTE AFTER 1 
           WRITE REG-SALIDA FROM IMP-SEPARATE AFTER 1 
           WRITE REG-SALIDA FROM IMP-SEPARATE AFTER 1.
      
       2110-CORTE-IMPRIME-F. 
      
      *------------------------------------------------------------- 
       9999-FINAL-I. 
      
           MOVE WS-REGISTROS-CANT TO IMP-REGISTROS-PRINT 
           DISPLAY '**********************************************' 
           DISPLAY 'TOTAL REGISTROS = ' IMP-REGISTROS-PRINT 
      
           CLOSE ENTRADA 
           IF FS-ENT IS NOT EQUAL '00' THEN 
              DISPLAY '* ERROR EN CLOSE ENTRADA = ' FS-ENT 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-LECTURA TO TRUE 
           END-IF 
      
           CLOSE LISTADO 
           IF FS-LISTADO IS NOT EQUAL '00' THEN
              DISPLAY '* ERROR EN CLOSE LISTADO = ' FS-LISTADO 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-LECTURA TO TRUE 
           END-IF    
      
           DISPLAY 'LEIDOS:     ' WS-LEIDOS-ENTRADA 
           DISPLAY 'IMPRESOS:   ' WS-IMPRESOS. 
      
       9999-FINAL-F. EXIT.