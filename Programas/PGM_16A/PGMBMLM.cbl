       IDENTIFICATION DIVISION. 
       PROGRAM-ID. PGMBMLM. 
      ************************************************************ 
      *    CLASE ASINCRÓNICA 16                                  *
      *    ====================                                  *
      *    -  CORTE DE CONTROL                                   * 
      *    -  CONSULTA DB2                                       *
      ************************************************************ 
 
      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
       ENVIRONMENT DIVISION. 
       CONFIGURATION SECTION. 
       SPECIAL-NAMES. 
           DECIMAL-POINT IS COMMA. 
 
 
      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
       DATA DIVISION. 
       FILE SECTION. 
 
 
       WORKING-STORAGE SECTION. 
      *=======================*
       77  FILLER        PIC X(26) VALUE '* INICIO WORKING-STORAGE *'. 
       
      *----------- ARCHIVOS ------------------------------------------  
       77  WS-STATUS-FIN           PIC X. 
           88  WS-FIN-LECTURA                        VALUE 'Y'. 
           88  WS-NO-FIN-LECTURA                     VALUE 'N'. 
 
 
      *----------- VARIABLES  ---------------------------------------- 
       77  WS-SUCUEN-ANT           PIC 99            VALUE ZERO. 
 
 
      *----------- ACUMULADORES -------------------------------------- 
       77  WS-CUENTAS-CANT         PIC 99            VALUE ZEROES. 
       77  WS-TOTAL                PIC 9(9)V99       VALUE ZEROES.
       77  WS-CUENTA-PRINT         PIC Z9.
       77  WS-TOTAL-PRINT          PIC ZZZ9.
 

      *//////////// COPY  ///////////////////////////////////////////
       01  DCLTBCURCLI.                                          
           10 WSC-TIPDOC           PIC X(2).                     
           10 WSC-NRODOC           PIC S9(11)V USAGE COMP-3.     
           10 WSC-NROCLI           PIC S9(3)V USAGE COMP-3.      
           10 WSC-NOMAPE           PIC X(30).                    
           10 WSC-FECNAC           PIC X(10).                    
           10 WSC-SEXO             PIC X(1).                     

       01  DCLTBCURCTA.                                                  
           10 CTA-TIPCUEN          PIC X(2).                             
           10 CTA-NROCUEN          PIC S9(5)V USAGE COMP-3.              
           10 CTA-SUCUEN           PIC S9(2)V USAGE COMP-3.              
           10 CTA-NROCLI           PIC S9(3)V USAGE COMP-3.              
           10 CTA-SALDO            PIC S9(5)V9(2) USAGE COMP-3.          
           10 CTA-FECSAL           PIC X(10).                                  
      *//////////////////////////////////////////////////////////////


      *----------- SQL ----------------------------------------------
       77  WS-SQLCODE     PIC +++999 USAGE DISPLAY VALUE ZEROS. 
       77  REG-SALDO      PIC -Z(09).99     VALUE ZEROES.
       77  REG-TIPCUEN    PIC Z9            VALUE ZEROES.
       77  REG-NROCUEN    PIC 9(05)         VALUE ZEROES.
       77  REG-SUCUEN     PIC 99            VALUE ZEROES.
 
           EXEC SQL INCLUDE SQLCA    END-EXEC. 
      *     EXEC SQL INCLUDE TBCURCTA END-EXEC. 
      *     EXEC SQL INCLUDE TBCURCLI END-EXEC. 
 
            EXEC SQL 
              DECLARE ITEM_CURSOR CURSOR
              FOR 
              SELECT A.TIPCUEN, 
                     A.NROCUEN, 
                     A.SUCUEN, 
                     A.NROCLI, 
                     B.NOMAPE, 
                     A.SALDO, 
                     A.FECSAL 
              FROM  KC02787.TBCURCTA A 
              INNER JOIN 
                    KC02787.TBCURCLI B 
              ON  A.NROCLI = B.NROCLI 
              WHERE A.SALDO > 0 
              ORDER BY A.SUCUEN ASC
                                        
            END-EXEC. 
  
 
       77  FILLER PIC X(26) VALUE '* FINAL  WORKING-STORAGE *'. 
 
      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
       PROCEDURE DIVISION. 
  
       MAIN-PROGRAM-I. 
  
           PERFORM 1000-INICIO-I  THRU 1000-INICIO-F. 
           PERFORM 2000-PROCESO-I THRU 2000-PROCESO-F
                                  UNTIL WS-FIN-LECTURA. 
           PERFORM 9999-FINAL-I   THRU 9999-FINAL-F. 
 
       MAIN-PROGRAM-F. GOBACK. 
 
 
      *--------------------------------------------------------------
       1000-INICIO-I. 
 
           SET WS-NO-FIN-LECTURA TO TRUE. 
 
           EXEC SQL OPEN ITEM_CURSOR END-EXEC. 
 
           IF SQLCODE NOT EQUAL ZEROS 
              MOVE SQLCODE TO WS-SQLCODE 
              DISPLAY '* ERROR OPEN CURSOR = ' WS-SQLCODE 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-LECTURA TO TRUE 
           END-IF. 
  
       1000-INICIO-F. EXIT. 
 
 
      *-------------------------------------------------------------
       2000-PROCESO-I. 
       
           PERFORM 2100-FETCH-I THRU 2100-FETCH-F 
 
           IF WS-FIN-LECTURA THEN 
              PERFORM 2200-CORTE-I THRU 2200-CORTE-F 
           ELSE 
              IF WS-SUCUEN-ANT IS EQUAL TO ZERO 
                 MOVE REG-SUCUEN TO WS-SUCUEN-ANT
                 ADD 1 TO WS-CUENTAS-CANT
              ELSE
                 IF REG-SUCUEN IS EQUAL TO WS-SUCUEN-ANT THEN
                    ADD 1 TO WS-CUENTAS-CANT
                 ELSE
                    PERFORM 2200-CORTE-I THRU 2200-CORTE-F
                    MOVE REG-SUCUEN TO WS-SUCUEN-ANT 
                    ADD 1 TO WS-CUENTAS-CANT 
                 END-IF
              END-IF    
           END-IF.
 
       2000-PROCESO-F. EXIT. 
 
 
      *--------------------------------------------------------------
       2100-FETCH-I.
 
           EXEC SQL 
              FETCH ITEM_CURSOR 
                 INTO 
                    :DCLTBCURCTA.CTA-TIPCUEN,
                    :DCLTBCURCTA.CTA-NROCUEN,
                    :DCLTBCURCTA.CTA-SUCUEN,
                    :DCLTBCURCTA.CTA-NROCLI,
                    :DCLTBCURCLI.WSC-NOMAPE,
                    :DCLTBCURCTA.CTA-SALDO,
                    :DCLTBCURCTA.CTA-FECSAL
           END-EXEC. 

           EVALUATE TRUE 
              WHEN SQLCODE EQUAL ZEROS 
                 MOVE CTA-SALDO   TO REG-SALDO 
                 MOVE CTA-TIPCUEN TO REG-TIPCUEN 
                 MOVE CTA-NROCUEN TO REG-NROCUEN 
                 MOVE CTA-SUCUEN  TO REG-SUCUEN 
              WHEN SQLCODE EQUAL +100 
                 SET WS-FIN-LECTURA TO TRUE 
              WHEN OTHER 
                 MOVE SQLCODE TO WS-SQLCODE 
                 DISPLAY 'ERROR FETCH CURSOR: ' WS-SQLCODE 
                 SET WS-FIN-LECTURA TO TRUE 
           END-EVALUATE. 
 
       2100-FETCH-F. EXIT.
 
  
      *---- CORTE DE CONTROL POR SUCUEN ----------------------------- 
       2200-CORTE-I. 
 
           MOVE WS-CUENTAS-CANT TO WS-CUENTA-PRINT
           ADD WS-CUENTAS-CANT TO WS-TOTAL 
 
           DISPLAY ' ' 
           DISPLAY '---------------------------------' 
           DISPLAY 'SUCURSAL: '  WS-SUCUEN-ANT 
           DISPLAY 'CANTIDAD DE CUENTAS: ' WS-CUENTA-PRINT 
 
           MOVE 0 TO WS-CUENTAS-CANT. 
 
       2200-CORTE-F. EXIT. 
 
 
 
      *--------------------------------------------------------------
       9999-FINAL-I. 
 
           EXEC SQL  CLOSE ITEM_CURSOR  END-EXEC. 

           MOVE WS-TOTAL TO WS-TOTAL-PRINT
 
           IF SQLCODE NOT EQUAL ZEROS 
              MOVE SQLCODE TO WS-SQLCODE 
              DISPLAY '* ERROR CLOSE CURSOR = ' WS-SQLCODE 
              MOVE 9999 TO RETURN-CODE 
           END-IF. 

           DISPLAY ' ' 
           DISPLAY '====================================' 
           DISPLAY 'TOTAL GENERAL DE CUENTAS: ' WS-TOTAL-PRINT. 
 
       9999-FINAL-F. EXIT. 