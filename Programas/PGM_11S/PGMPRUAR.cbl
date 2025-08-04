       IDENTIFICATION DIVISION. 
       PROGRAM-ID. PGMPRUAR. 
   
      ***************************************************************
      *    CLASE SINCRÓNICA 11                                      *
      *    ===================                                      *
      *    - Construir un nuevo programa en COBOL a partir de un    *
      *      esqueleto dado.                                        *
      *    - Practicar y validar el concepto de programación COBOL  *
      *      mediante una funcionalidad completa.                   *
      *    - Leer registros del archivo CLIENTES.                   *
      *    - Filtrar registros donde CLI-TIP-DOC = 'DU'.            *
      *    - Sumar los saldos (CLI-SALDO) de esos registros.        *
      *    - Mostrar el total acumulado por pantalla al finalizar.  *
      ***************************************************************

      *|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       ENVIRONMENT DIVISION. 
       CONFIGURATION SECTION. 
       SPECIAL-NAMES. 
           DECIMAL-POINT IS COMMA. 
   
       INPUT-OUTPUT SECTION. 
       FILE-CONTROL. 
           SELECT CLIENTES ASSIGN DDENTRA 
           FILE STATUS IS WS-FILE-CLI. 
   
   
      *|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       DATA DIVISION. 
       FILE SECTION. 

       FD  CLIENTES 
           BLOCK CONTAINS 0 RECORDS 
           RECORDING MODE IS F. 
       01  REG-CLI            PIC X(50). 
   
   
       WORKING-STORAGE SECTION. 
      *=======================* 
   
       77  FILLER  PIC X(26) VALUE '* INICIO WORKING-STORAGE *'. 
       77  FILLER  PIC X(26) VALUE '* CODIGOS RETORNO FILES  *'. 
       77  WS-FILE-CLI                PIC XX      VALUE SPACES. 
       77  WS-STATUS-CLI              PIC X. 
           88 WS-FIN-CLI                          VALUE 'Y'. 
           88 WS-NO-FIN-CLI                       VALUE 'N'. 
      * ACUMULADOR DE SALDOS 
       77  WS-TOTALIZADOR    PIC S9(11)V99  COMP-3  VALUE ZEROS. 
       77  WS-DU             PIC XX                 VALUE 'DU'. 
       77  WS-CANT-LEIDOS    PIC 9(05)              VALUE ZEROS. 
       77  WS-CANT-DU        PIC 9(05)              VALUE ZEROS. 
       77  WS-CLI-EDIT       PIC ZZZZ9. 
       77  WS-TOT-EDIT       PIC -ZZ.ZZZ.ZZZ.ZZ9,99. 
  
      */////////////////////////////////////////////////////////////
      *     COPY CPCLI. 

       01  REG-CLIENTE. 
           03  CLI-TIP-DOC        PIC X(02)          VALUE SPACES. 
           03  CLI-NRO-DOC        PIC 9(11)          VALUE ZEROES. 
           03  CLI-NRO-SUC        PIC 9(02)          VALUE ZEROES. 
           03  CLI-TIP-CUE        PIC XX             VALUE SPACES. 
           03  CLI-NRO            PIC 9(03)          VALUE ZEROES. 
           03  CLI-SALDO          PIC S9(09)V99 COMP-3 VALUE ZEROS. 
           03  CLI-AAAAMMDD       PIC 9(08)          VALUE ZEROES. 
           03  CLI-SEXO           PIC X              VALUE SPACES. 
           03  CLI-NOMAPE         PIC X(15)          VALUE SPACES. 
      */////////////////////////////////////////////////////////////
  
      *|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       PROCEDURE DIVISION. 
  
       MAIN-PROGRAM-I. 
  
           PERFORM 1000-INICIO-I  THRU 1000-INICIO-F. 
           PERFORM 2000-PROCESO-I THRU 2000-PROCESO-F 
                                 UNTIL WS-FIN-CLI. 
           PERFORM 9999-FINAL-I   THRU 9999-FINAL-F. 
  
       MAIN-PROGRAM-F. GOBACK. 
  
      *------------------------------------------------------------- 
       1000-INICIO-I. 
  
           SET WS-NO-FIN-CLI TO TRUE. 
  
           OPEN INPUT  CLIENTES. 
           IF WS-FILE-CLI IS NOT EQUAL '00' 
              DISPLAY '* ERROR EN OPEN SUCURSAL = ' WS-FILE-CLI 
              MOVE 9999 TO RETURN-CODE 
              SET  WS-FIN-CLI  TO TRUE 
           END-IF. 
  
       1000-INICIO-F. EXIT. 
  
      *------------------------------------------------------------- 
       2000-PROCESO-I. 
   
           PERFORM 2500-LEER-I THRU 2500-LEER-F. 
  
           IF CLI-TIP-DOC EQUAL WS-DU THEN 
              ADD CLI-SALDO TO WS-TOTALIZADOR 
              ADD 1 TO WS-CANT-DU 
           END-IF. 
   
       2000-PROCESO-F. EXIT. 
   
      *-------------------------------------------------------------- 
       2500-LEER-I. 
  
           READ CLIENTES  INTO REG-CLIENTE 
           EVALUATE WS-FILE-CLI 
              WHEN '00' 
                 ADD 1 TO WS-CANT-LEIDOS 
              WHEN '10' 
                 SET WS-FIN-CLI TO TRUE 
              WHEN OTHER 
                 DISPLAY '* ERROR EN LECTURA CLIENTES = ' WS-FILE-CLI 
                 MOVE 9999 TO RETURN-CODE 
                 SET WS-FIN-CLI TO TRUE 
           END-EVALUATE. 
  
       2500-LEER-F. EXIT. 
   
      *-------------------------------------------------------------- 
       9999-FINAL-I. 
 
           CLOSE CLIENTES 
           IF WS-FILE-CLI IS NOT EQUAL '00' 
              DISPLAY '* ERROR EN CLOSE CLIENTES = ' WS-FILE-CLI 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-CLI  TO TRUE 
           END-IF 
   
           DISPLAY ' ' 
           MOVE WS-CANT-LEIDOS TO  WS-CLI-EDIT 
           DISPLAY 'CANTIDAD REGISTROS LEIDOS: ' WS-CLI-EDIT 
           MOVE WS-CANT-DU  TO WS-CLI-EDIT 
           DISPLAY 'CANTIDAD DE DU:            ' WS-CLI-EDIT 
           MOVE WS-TOTALIZADOR TO  WS-TOT-EDIT 
           DISPLAY 'TOTAL DE SALDOS = ' WS-TOT-EDIT. 
  
       9999-FINAL-F. EXIT.