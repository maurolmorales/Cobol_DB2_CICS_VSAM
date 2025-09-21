       IDENTIFICATION DIVISION. 
       PROGRAM-ID. PROGM23S. 
       
      *************************************************** 
      *    CLASE SINCRÓNICA 23                          *
      *    ===================                          *
      *    - DOBLE CORTE DE CONTROL                     *
      *    - ARCHIVO DE ENTRADA VSAM                    *
      *************************************************** 
       
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
       01  REG-ENTRADA  PIC X(50). 
       
       
       WORKING-STORAGE SECTION. 
      *======================= 
       
      *----------- ARCHIVOS ------------------------------------------ 
       77  FS-ENT                  PIC XX       VALUE SPACES. 
       
       77  WS-STATUS-FIN           PIC X. 
           88  WS-FIN-LECTURA                   VALUE 'Y'. 
           88  WS-NO-FIN-LECTURA                VALUE 'N'. 
       
      *----------- VARIABLES  ---------------------------------------- 
       77  WS-NRO-SUC-ANT        PIC 99          VALUE ZEROES. 
       77  WS-TIP-CUE-ANT        PIC XX          VALUE SPACES. 
       
      *----------- ACUMULADORES -------------------------------------- 
       77  WS-NRO-SUC-SUMA       PIC S9(9)V99     VALUE ZEROES. 
       77  WS-TIP-CUE-SUMA       PIC S9(9)V99     VALUE ZEROES. 
       77  WS-REG-CANT           PIC 999          VALUE ZEROES. 
       77  WS-TOTAL-CANT         PIC S9(12)V99    VALUE ZEROES. 
       
      *----------- PRINT ------------------------------------------- 
       77  WS-REGISTROS-PRINT      PIC ZZ9. 
       77  WS-SALDO-PRINT          PIC -$ZZZ.ZZZ.ZZ9,99. 
       
      *////   COPYS  //////////////////////////////////////////////// 
      
      *    COPY CPCLIE. 
      *    LAYOUT MAESTRO CLIENTES
      *    KC02788.ALU9999.CURSOS.CLIENT1.KSDS.VSAM
      *    LARGO 50 BYTES
      *    VSAM KSDS KEY (1,13)
      *    ALT KEY NRO-CLI  (18,3)
       01  REG-CLIENTE. 
           03  CLI-TIP-DOC        PIC X(02)    VALUE SPACES. 
           03  CLI-NRO-DOC        PIC 9(11)    VALUE ZEROS. 
           03  CLI-NRO-SUC        PIC 9(02)    VALUE ZEROS. 
           03  CLI-TIP-CUE        PIC XX       VALUE SPACES. 
           03  CLI-NRO            PIC 9(03)    VALUE ZEROS. 
           03  CLI-SALDO          PIC S9(09)V99 COMP-3 VALUE ZEROS. 
           03  CLI-AAAAMMDD       PIC 9(08)            VALUE ZEROS. 
           03  CLI-SEXO           PIC X        VALUE SPACES. 
           03  CLI-NOMAPE         PIC X(15)    VALUE SPACES. 
           
      */////////////////////////////////////////////////////////////


      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       PROCEDURE DIVISION. 
      *  CUERPO PRINCIPAL DEL PROGRAMA     * 
       
       MAIN-PROGRAM-I. 
       
           PERFORM 1000-INICIO-I  THRU 1000-INICIO-F
           PERFORM 2000-PROCESO-I THRU 2000-PROCESO-F 
                                       UNTIL WS-FIN-LECTURA 
           PERFORM 9999-FINAL-I   THRU 9999-FINAL-F. 

       MAIN-PROGRAM-F. GOBACK. 


      *------------------------------------------------------------ 
       1000-INICIO-I. 

           SET WS-NO-FIN-LECTURA TO TRUE 
       
           OPEN INPUT ENTRADA 
           IF FS-ENT IS NOT EQUAL '00' THEN
              DISPLAY '* ERROR EN OPEN ENTRADA INICIO = ' FS-ENT 
              SET  WS-FIN-LECTURA TO TRUE 
           END-IF 
       
           PERFORM 2100-LEER-I THRU 2100-LEER-F 
       
           IF WS-FIN-LECTURA THEN
              DISPLAY '* ARCHIVO ENTRADA VACÍO EN INICIO' FS-ENT 
           ELSE 
              MOVE CLI-NRO-SUC TO WS-NRO-SUC-ANT 
              MOVE CLI-TIP-CUE TO WS-TIP-CUE-ANT 
              MOVE CLI-SALDO TO WS-TIP-CUE-SUMA 
              DISPLAY '=================================' 
              DISPLAY 'NUM SUC: ' WS-NRO-SUC-ANT 
              DISPLAY '---------------------------------' 
           END-IF.

       1000-INICIO-F. EXIT. 
       
       
      **------------------------------------------------------------ 
       2000-PROCESO-I. 

           PERFORM 2100-LEER-I THRU 2100-LEER-F 
       
           IF WS-FIN-LECTURA THEN 
              PERFORM 2200-CORTE-MAYOR-I THRU 2200-CORTE-MAYOR-F 
           ELSE 
              IF CLI-NRO-SUC IS EQUAL WS-NRO-SUC-ANT THEN 
                 IF CLI-TIP-CUE IS EQUAL WS-TIP-CUE-ANT THEN 
                    ADD CLI-SALDO TO WS-TIP-CUE-SUMA 
                 ELSE 
                    PERFORM 2300-CORTE-MENOR-I 
                       THRU 2300-CORTE-MENOR-F 
                 END-IF 
              ELSE 
                 PERFORM 2200-CORTE-MAYOR-I 
                    THRU 2200-CORTE-MAYOR-F 
              END-IF 
           END-IF. 
           
       2000-PROCESO-F. EXIT. 
       
       
      *--------------------------------------------------------------- 
       2200-CORTE-MAYOR-I. 
       
           PERFORM 2300-CORTE-MENOR-I THRU 2300-CORTE-MENOR-F 
       
           ADD  WS-NRO-SUC-SUMA TO WS-TOTAL-CANT 
           MOVE WS-NRO-SUC-SUMA TO WS-SALDO-PRINT 
           MOVE CLI-NRO-SUC TO WS-NRO-SUC-ANT 
       
           DISPLAY '---------------------------------' 
           DISPLAY 'TOTAL: ' WS-SALDO-PRINT 
           DISPLAY '=================================' 
           
           IF NOT WS-FIN-LECTURA THEN
              DISPLAY ' ' 
              DISPLAY ' ' 
              DISPLAY 'NUM SUC: ' WS-NRO-SUC-ANT 
       
           MOVE ZERO TO WS-NRO-SUC-SUMA 
           END-IF. 
       
       2200-CORTE-MAYOR-F. EXIT. 
       
       
       
      *-------------------------------------------------------------- 
       2300-CORTE-MENOR-I. 
       
           ADD WS-TIP-CUE-SUMA TO WS-NRO-SUC-SUMA 
           MOVE WS-TIP-CUE-SUMA  TO WS-SALDO-PRINT 
           DISPLAY 'IMPORTE ' WS-TIP-CUE-ANT  ': '  WS-SALDO-PRINT 
           MOVE CLI-SALDO TO WS-TIP-CUE-SUMA. 
           MOVE CLI-TIP-CUE TO WS-TIP-CUE-ANT. 
       
       2300-CORTE-MENOR-F. EXIT. 
       

       
      *-------------------------------------------------------------- 
       2100-LEER-I. 

           READ ENTRADA INTO REG-CLIENTE 
       
           EVALUATE FS-ENT 
              WHEN '00' 
                 ADD 1 TO WS-REG-CANT 
                 CONTINUE 
              WHEN '10' 
                 SET WS-FIN-LECTURA TO TRUE 
              WHEN OTHER 
                 DISPLAY '*ERROR EN LECTURA ENTRADA INICIO : ' FS-ENT 
                 SET WS-FIN-LECTURA TO TRUE 
           END-EVALUATE. 

       2100-LEER-F. EXIT. 


       
      *-------------------------------------------------------------- 
       9999-FINAL-I. 

           MOVE WS-REG-CANT TO WS-REGISTROS-PRINT 
           MOVE WS-TOTAL-CANT TO WS-SALDO-PRINT 
       
           DISPLAY ' ' 
           DISPLAY '**********************************************' 
           DISPLAY 'TOTAL REGISTROS = ' WS-REGISTROS-PRINT. 
           DISPLAY 'TOTAL IMPORTES  = ' WS-SALDO-PRINT. 
       
           CLOSE ENTRADA 
           IF FS-ENT IS NOT EQUAL '00' THEN
              DISPLAY '* ERROR EN CLOSE ENTRADA = ' FS-ENT 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-LECTURA TO TRUE 
           END-IF. 

       9999-FINAL-F. EXIT.