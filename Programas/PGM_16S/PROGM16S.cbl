       IDENTIFICATION DIVISION. 
       PROGRAM-ID. PROGM16S. 
       
      *****************************************************************
      *                   CLASE SINCRÓNICA 16
      *                   ===================
      * Este programa usa SQL embebido con un cursor que une        
      * las tablas TBCURCTA y TBCURCLI.                             
      * El DBRM generado se debe registrar en DB2 mediante un BIND, 
      * que crea o actualiza el PACKAGE y el PLAN para ejecutar     
      * correctamente las sentencias SQL en runtime.                
      *****************************************************************
      
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
      
      *----------- SQL ----------------------------------------------
       77  WS-SQLCODE       PIC +++999 USAGE DISPLAY VALUE ZEROS. 
       77  REG-SALDO               PIC -Z(09).99     VALUE ZEROES.
       77  REG-TIPCUEN             PIC Z9            VALUE ZEROES.
       77  REG-NROCUEN             PIC 9(05)         VALUE ZEROES.
       77  REG-SUCUEN              PIC 99            VALUE ZEROES.
      

      *//////////////////////////////////////////////////////////////
      * COBOL DECLARATION FOR TABLE KC02803.TBCURCLI
      *    EXEC SQL DECLARE KC02803.TBCURCLI TABLE                     
      *    ( TIPDOC                         CHAR(2) NOT NULL,          
      *      NRODOC                         DECIMAL(11, 0) NOT NULL,   
      *      NROCLI                         DECIMAL(3, 0) NOT NULL,    
      *      NOMAPE                         CHAR(30) NOT NULL,         
      *      FECNAC                         DATE NOT NULL,             
      *      SEXO                           CHAR(1) NOT NULL           
      *    ) END-EXEC.                                                 
       01  DCLTBCURCLI.                                                 
           10 CLI-TIPDOC           PIC X(2).                            
           10 CLI-NRODOC           PIC S9(11)V USAGE COMP-3.            
           10 CLI-NROCLI           PIC S9(3)V USAGE COMP-3.             
           10 CLI-NOMAPE           PIC X(30).                           
           10 CLI-FECNAC           PIC X(10).                           
           10 CLI-SEXO             PIC X(1).                            
      *--------------------------------------------------------------
      * COBOL DECLARATION FOR TABLE KC02803.TBCURCTA
      *    EXEC SQL DECLARE KC02803.TBCURCTA TABLE                      
      *    ( TIPCUEN                        CHAR(2) NOT NULL,           
      *      NROCUEN                        DECIMAL(5, 0) NOT NULL,     
      *      SUCUEN                         DECIMAL(2, 0) NOT NULL,     
      *      NROCLI                         DECIMAL(3, 0) NOT NULL,     
      *      SALDO                          DECIMAL(7, 2) NOT NULL,     
      *      FECSAL                         DATE NOT NULL               
      *    ) END-EXEC.                                                  
       01  DCLTBCURCTA.                                                 
           10 CTA-TIPCUEN          PIC X(2).                            
           10 CTA-NROCUEN          PIC S9(5)V USAGE COMP-3.             
           10 CTA-SUCUEN           PIC S9(2)V USAGE COMP-3.             
           10 CTA-NROCLI           PIC S9(3)V USAGE COMP-3.             
           10 CTA-SALDO            PIC S9(5)V9(2) USAGE COMP-3.         
           10 CTA-FECSAL           PIC X(10).                        
      *//////////////////////////////////////////////////////////////



           EXEC SQL INCLUDE SQLCA    END-EXEC. 
      *     EXEC SQL INCLUDE TBCURCTA END-EXEC. 
      *     EXEC SQL INCLUDE TBCURCLI END-EXEC. 
      
            EXEC SQL 
              DECLARE ITEM_CURSOR CURSOR FOR 
                 SELECT A.TIPCUEN, 
                        A.NROCUEN, 
                        A.SUCUEN, 
                        A.NROCLI, 
                        B.NOMAPE, 
                        A.SALDO, 
                        A.FECSAL 
                 FROM  KC02803.TBCURCTA A 
                 INNER JOIN KC02803.TBCURCLI B 
                 ON  A.NROCLI = B.NROCLI 
                 WHERE A.SALDO > 0 
                 ORDER BY A.SUCUEN ASC
                                         
            END-EXEC. 
      
      
       77  FILLER PIC X(26) VALUE '* FINAL  WORKING-STORAGE *'. 
      
      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
       PROCEDURE DIVISION. 
      
       MAIN-PROGRAM-I. 
      
           PERFORM 1000-INICIO-I  THRU 1000-INICIO-F 
           PERFORM 2000-PROCESO-I THRU 2000-PROCESO-F
                                       UNTIL WS-FIN-LECTURA
           PERFORM 9999-FINAL-I   THRU 9999-FINAL-F. 
      
       MAIN-PROGRAM-F. GOBACK. 
      
      
      *--------------------------------------------------------------
       1000-INICIO-I. 
      
           SET WS-NO-FIN-LECTURA TO TRUE 
      
           EXEC SQL OPEN ITEM_CURSOR END-EXEC 
            IF SQLCODE NOT EQUAL ZEROS THEN
              MOVE SQLCODE TO WS-SQLCODE 
              DISPLAY '* ERROR OPEN CURSOR = ' WS-SQLCODE 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-LECTURA TO TRUE 
           END-IF
      
           PERFORM 2100-FETCH-I THRU 2100-FETCH-F 
           
           IF WS-FIN-LECTURA THEN 
              DISPLAY '* TABLA VACÍA EN INICIO' 
           ELSE 
              MOVE REG-SUCUEN TO WS-SUCUEN-ANT 
              ADD 1 TO WS-CUENTAS-CANT 
      
           END-IF.            
      
       1000-INICIO-F. EXIT. 
      
      
      *-------------------------------------------------------------
       2000-PROCESO-I. 
       
           PERFORM 2100-FETCH-I THRU 2100-FETCH-F 
      
           IF WS-FIN-LECTURA THEN 
              PERFORM 2200-CORTE-I THRU 2200-CORTE-F 
           ELSE 
              IF REG-SUCUEN IS EQUAL TO WS-SUCUEN-ANT THEN
                 ADD 1 TO WS-CUENTAS-CANT
              ELSE
                 PERFORM 2200-CORTE-I THRU 2200-CORTE-F
                 MOVE REG-SUCUEN TO WS-SUCUEN-ANT 
                 ADD 1 TO WS-CUENTAS-CANT 
              END-IF    
           END-IF.
      
       2000-PROCESO-F. EXIT. 
      
      
      *--------------------------------------------------------------
       2100-FETCH-I.
      
           EXEC SQL 
              FETCH ITEM_CURSOR INTO :DCLTBCURCTA.CTA-TIPCUEN,
                                     :DCLTBCURCTA.CTA-NROCUEN,
                                     :DCLTBCURCTA.CTA-SUCUEN,
                                     :DCLTBCURCTA.CTA-NROCLI,
                                     :DCLTBCURCLI.CLI-NOMAPE,
                                     :DCLTBCURCTA.CTA-SALDO,
                                     :DCLTBCURCTA.CTA-FECSAL
           END-EXEC
      
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
           MOVE 0 TO WS-CUENTAS-CANT
      
           DISPLAY ' ' 
           DISPLAY '---------------------------------' 
           DISPLAY 'SUCURSAL: '  WS-SUCUEN-ANT 
           DISPLAY 'CANTIDAD DE CUENTAS: ' WS-CUENTA-PRINT.
      
       2200-CORTE-F. EXIT. 
      
      
      
      *--------------------------------------------------------------
       9999-FINAL-I. 
      
           MOVE WS-TOTAL TO WS-TOTAL-PRINT
      
           EXEC SQL CLOSE ITEM_CURSOR  END-EXEC
           IF SQLCODE NOT EQUAL ZEROS THEN
              MOVE SQLCODE TO WS-SQLCODE 
              DISPLAY '* ERROR CLOSE CURSOR = ' WS-SQLCODE 
              MOVE 9999 TO RETURN-CODE 
           END-IF
      
           DISPLAY ' ' 
           DISPLAY '=================================' 
           DISPLAY 'TOTAL CUENTAS: ' WS-TOTAL-PRINT. 
      
       9999-FINAL-F. EXIT. 