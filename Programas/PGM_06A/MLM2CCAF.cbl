       IDENTIFICATION DIVISION. 
       PROGRAM-ID. MLM2CCAF. 
 
      *************************************************** 
      *    CLASE ASINCRóNICA 6:                         * 
      *    ===================                          *
      *    - CORTE DE CONTROL                           *
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
       01  REG-ENTRADA  PIC X(20). 


       WORKING-STORAGE SECTION. 
      *=======================* 
 
      *----------- ARCHIVOS ------------------------------------------ 
       77  FS-ENT                  PIC XX               VALUE SPACES. 
       77  WS-STATUS-FIN           PIC X. 
           88  WS-FIN-LECTURA            VALUE 'Y'. 
           88  WS-NO-FIN-LECTURA         VALUE 'N'. 
 
      *----------- VARIABLES  ---------------------------------------- 
       77  WS-SUC-NRO-ANT          PIC 99               VALUE ZEROES. 
 
 
      *----------- ACUMULADORES -------------------------------------- 
       77  WS-IMPORTE-ACUM         PIC 9(9)V99          VALUE ZEROES. 
       77  WS-TOTAL                PIC 9(9)V99          VALUE ZEROES. 
 
 
      *----------- IMPRESION ----------------------------------------- 
       77  WS-IMPORTE-PRINT        PIC $ZZZ.ZZZ.ZZ9,99. 
       77  WS-TOTAL-PRINT          PIC $ZZZ.ZZZ.ZZ9,99. 
 
 
      */////////// COPYS ///////////////////////////////////////////// 
      *    COPY CORTE. 
      ************************************** 
      *     LAYOUT SUCURSAL                * 
      *     LARGO REGISTRO = 20 BYTES      * 
      ************************************** 
       01  WS-REG-SUCURSAL. 
           03  WS-SUC-NRO          PIC 9(02)    VALUE ZEROS. 
           03  WS-SUC-IMPORTE      PIC S9(7)V99 COMP-3  VALUE ZEROS. 
           03  WS-SUC-TIPN         PIC X(02)    VALUE ZEROS. 
           03  WS-SUC-TIPC. 
               05  WS-SUC-TIPC1    PIC 9(02)    VALUE ZEROS. 
               05  WS-SUC-TIPC2    PIC 9(01)    VALUE ZEROS. 
           03  FILLER              PIC X(8)     VALUE SPACES. 

      *///////////////////////////////////////////////////////////////


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
 
           OPEN INPUT ENTRADA. 
           IF FS-ENT IS NOT EQUAL '00' 
              DISPLAY '* ERROR EN OPEN ENTRADA INICIO = ' FS-ENT 
              SET  WS-FIN-LECTURA TO TRUE 
           END-IF. 
 
      * LEER EL PRIMER REGISTRO FUERA DEL LOOP PRINCIPAL 
           PERFORM 2100-LEER-I THRU 2100-LEER-F. 
 
           IF WS-FIN-LECTURA 
              DISPLAY '* ARCHIVO ENTRADA VACÍO EN INICIO' FS-ENT 
           ELSE 
              MOVE WS-SUC-NRO     TO WS-SUC-NRO-ANT 
              ADD  WS-SUC-IMPORTE TO WS-IMPORTE-ACUM 
           END-IF. 

       1000-INICIO-F. EXIT. 
       
 
      *--------------------------------------------------------------- 
       2000-PROCESO-I. 

           PERFORM 2100-LEER-I THRU 2100-LEER-F 
 
           IF WS-FIN-LECTURA THEN 
              PERFORM 2200-CORTE-MAYOR-I THRU 2200-CORTE-MAYOR-F 
           ELSE 
              IF WS-SUC-NRO IS EQUAL WS-SUC-NRO-ANT THEN 
                 ADD WS-SUC-IMPORTE TO WS-IMPORTE-ACUM 
              ELSE 
                 PERFORM 2200-CORTE-MAYOR-I THRU 2200-CORTE-MAYOR-F 
                 MOVE WS-SUC-NRO TO WS-SUC-NRO-ANT 
                 ADD  WS-SUC-IMPORTE TO WS-IMPORTE-ACUM 
              END-IF 
           END-IF. 

       2000-PROCESO-F. EXIT. 


      *---- CORTE DE CONTROL POR NUM-SUC ----------------------------- 
       2200-CORTE-MAYOR-I. 

           MOVE WS-IMPORTE-ACUM  TO WS-IMPORTE-PRINT 
           ADD WS-IMPORTE-ACUM TO WS-TOTAL 
 
           DISPLAY ' ' 
           DISPLAY '=================================' 
           DISPLAY 'NUM-SUC: ' WS-SUC-NRO-ANT 
           DISPLAY 'IMPORTE: ' WS-IMPORTE-PRINT 
           DISPLAY '---------------------------------' 
           DISPLAY ' ' 
 
           MOVE 0 TO WS-IMPORTE-ACUM. 

       2200-CORTE-MAYOR-F. EXIT. 


      *--------------------------------------------------------------- 
       2100-LEER-I. 

           READ ENTRADA INTO WS-REG-SUCURSAL 
 
           EVALUATE FS-ENT 
              WHEN '00' 
                 CONTINUE 
              WHEN '10' 
                 SET WS-FIN-LECTURA TO TRUE 
              WHEN OTHER 
                 DISPLAY '*ERROR EN LECTURA ENTRADA INICIO : ' FS-ENT 
                 SET WS-FIN-LECTURA TO TRUE 
           END-EVALUATE. 

       2100-LEER-F. EXIT. 
                           
 
      *--------------------------------------------------------------- 
       9999-FINAL-I.

           MOVE WS-TOTAL TO WS-TOTAL-PRINT 
           DISPLAY ' ' 
           DISPLAY '**********************************************' 
           DISPLAY 'IMPORTE TOTAL = ' WS-TOTAL-PRINT. 
 
           CLOSE ENTRADA 
           IF FS-ENT IS NOT EQUAL '00' 
              DISPLAY '* ERROR EN CLOSE ENTRADA = ' FS-ENT 
 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-LECTURA TO TRUE 
           END-IF. 
 
       9999-FINAL-F.  EXIT. 