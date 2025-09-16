       IDENTIFICATION DIVISION. 
       PROGRAM-ID. PROGM13S. 

      *****************************************************************
      *    CLASE SINCRÓNICA 13                                        *
      *    ===================                                        *
      *  ESTE PROGRAMA PROCESA UN ARCHIVO SECUENCIAL DE CLIENTES,     *
      *  LEYENDO TODOS LOS REGISTROS Y AGRUPáNDOLOS POR ESTADO CIVIL. *
      *  REALIZA UN CONTEO ACUMULADO POR CADA ESTADO CIVIL MEDIANTE   *
      *  UNA TéCNICA DE CORTE DE CONTROL.                             *
      *  - ABRIR ARCHIVO DE ENTRADA Y VALIDAR SU ESTADO.              *
      *  - LEER REGISTROS SECUENCIALES.                               *
      *  - COMPARAR ESTADO CIVIL ACTUAL CON EL ANTERIOR.              *
      *  - REALIZAR CORTES DE CONTROL AL CAMBIAR DE ESTADO CIVIL.     *
      *  - MOSTRAR TOTAL POR ESTADO CIVIL Y TOTAL GENERAL.            *
      *  - MANEJAR ERRORES DE APERTURA, LECTURA Y CIERRE DEL ARCHIVO. *
      *****************************************************************

      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       ENVIRONMENT DIVISION. 
       CONFIGURATION SECTION. 

       SPECIAL-NAMES. 
           DECIMAL-POINT IS COMMA. 
 
       INPUT-OUTPUT SECTION. 
       FILE-CONTROL. 
           SELECT ENTRADA ASSIGN DDENTRA 
           FILE STATUS IS FS-ENT. 
 
      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       DATA DIVISION. 
       FILE SECTION. 
 
       FD  ENTRADA 
           BLOCK CONTAINS 0 RECORDS 
           RECORDING MODE IS F. 
       01  REG-ENTRADA PIC X(93). 
 
 
       WORKING-STORAGE SECTION.
      *========================*  
 
      *----  ARCHIVOS  --------------------------------------------- 
       77  FS-ENT                PIC XX            VALUE SPACES. 
       77  WS-STATUS-FIN         PIC X. 
           88  WS-FIN-LECTURA                      VALUE 'Y'. 
           88  WS-NO-FIN-LECTURA                   VALUE 'N'. 
 
      *----   VARIABLES   ------------------------------------------ 
       77  WS-CANT-REG           PIC 999           VALUE ZEROES. 
       77  WS-CANT-REG-PRINT     PIC ZZZZZ         VALUE ZEROS. 
       77  WS-EST-CIV-ANT        PIC X(10)         VALUE ZEROES. 
       77  WS-EST-CIV-CANT       PIC 99            VALUE ZEROS. 
       77  WS-EST-CIV-CANT-PRINT PIC ZZZ9          VALUE ZEROS. 
 
 
      *//////////////////////////////////////////////////////////////
      *     COPY CLICOB. 
       01  WS-REG-CLICOB. 
      * TIPO DOCUMENTO VALIDOS: 'DU'; 'PA'; 'PE'; 'CI' 
           03  WS-SUC-TIP-DOC      PIC XX       VALUE SPACES. 
           03  WS-SUC-NRO-DOC      PIC 9(11)    VALUE ZEROS. 
           03  WS-SUC-NOMAPE       PIC X(30)    VALUE SPACES. 
      * ESTADO CIVIL   VALIDOS: 'SOLTERO   '; 'VIUDO     ' 
      *                         'DIVORCIADO'; 'CASADO    ' 
           03  WS-SUC-EST-CIV      PIC X(10)    VALUE SPACES. 
      * SEXO           VALIDOS: 'F'; 'M'; 'O' 
           03  WS-SUC-SEXO         PIC X        VALUE SPACES. 
           03  FILLER              PIC X(39)    VALUE SPACES. 
      *//////////////////////////////////////////////////////////////           
                                                                  
 
 
      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       PROCEDURE DIVISION. 
 
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
           IF FS-ENT IS NOT EQUAL '00' THEN 
              DISPLAY '* ERROR EN OPEN ENTRADA INICIO = ' FS-ENT 
              SET  WS-FIN-LECTURA TO TRUE 
           END-IF. 
 
      * LEER EL PRIMER REGISTRO FUERA DEL LOOP PRINCIPAL 
           PERFORM 2500-LEER-I THRU 2500-LEER-F. 
           
           IF WS-FIN-LECTURA THEN 
              DISPLAY '* ARCHIVO ENTRADA VACÍO EN INICIO' FS-ENT 
           ELSE 
              MOVE WS-SUC-EST-CIV TO WS-EST-CIV-ANT 
              ADD 1 TO WS-EST-CIV-CANT 
           END-IF. 

       1000-INICIO-F. EXIT. 
 
 
      *--------------------------------------------------------------- 
       2000-PROCESO-I. 

           PERFORM 2500-LEER-I THRU 2500-LEER-F 
 
           IF WS-FIN-LECTURA THEN 
              PERFORM 2600-CORTE-EST-CIV-I 
                 THRU 2600-CORTE-EST-CIV-F 
           ELSE 
              IF WS-SUC-EST-CIV = WS-EST-CIV-ANT THEN 
                 ADD 1 TO WS-EST-CIV-CANT 
              ELSE 
                 PERFORM 2600-CORTE-EST-CIV-I 
                    THRU 2600-CORTE-EST-CIV-F 
              END-IF 
           END-IF. 

       2000-PROCESO-F. EXIT. 
 
 
      *--------------------------------------------------------------- 
       2500-LEER-I. 

           READ ENTRADA INTO WS-REG-CLICOB 
           EVALUATE FS-ENT 
              WHEN '00' 
                 ADD 1 TO WS-CANT-REG 
                 CONTINUE 
              WHEN '10' 
                 SET WS-FIN-LECTURA TO TRUE 
              WHEN OTHER 
                 DISPLAY '*ERROR EN LECTURA ENTRADA INICIO : ' FS-ENT 
                 SET WS-FIN-LECTURA TO TRUE 
           END-EVALUATE. 

       2500-LEER-F. EXIT. 

 
      *--------------------------------------------------------------- 
       2600-CORTE-EST-CIV-I. 

           MOVE WS-EST-CIV-CANT TO WS-EST-CIV-CANT-PRINT 
           DISPLAY 'TOTAL DE ' WS-EST-CIV-ANT 
                                 ':  '  WS-EST-CIV-CANT-PRINT 
           MOVE WS-SUC-EST-CIV TO WS-EST-CIV-ANT 
           MOVE 1 TO WS-EST-CIV-CANT. 

       2600-CORTE-EST-CIV-F. EXIT. 
 
 
      *--------------------------------------------------------------- 
       9999-FINAL-I. 

           MOVE WS-CANT-REG TO WS-CANT-REG-PRINT 
           DISPLAY '**********************************************' 
           DISPLAY 'TOTAL DE REGISTROS = '  WS-CANT-REG-PRINT 

           CLOSE ENTRADA 
           IF FS-ENT IS NOT EQUAL '00' THEN
              DISPLAY '* ERROR EN CLOSE ENTRADA = ' FS-ENT 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-LECTURA TO TRUE 
           END-IF. 

       9999-FINAL-F. EXIT. 
 
