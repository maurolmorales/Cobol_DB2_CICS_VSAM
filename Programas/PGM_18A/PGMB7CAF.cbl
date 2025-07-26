       IDENTIFICATION DIVISION. 
       PROGRAM-ID. PGMB7CAF. 
 
      ****************************************************************
      *    CLASE ASINCRÓNICA 18                                      *
      *    ====================                                      *
      *    - DB2 CURSORES                                            *
      *    - APAREAMIENTO DE TBCURCLI CON TBCURCTA                   *
      ****************************************************************
 
      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       ENVIRONMENT DIVISION. 
       CONFIGURATION SECTION. 
 
       SPECIAL-NAMES. 
           DECIMAL-POINT IS COMMA. 
 

      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       DATA DIVISION. 
 
       WORKING-STORAGE SECTION.
      *========================* 
 
      *----------- ARCHIVOS ----------------------------------------- 

       77  WS-STATUS-FIN           PIC X. 
           88  WS-FIN-LECTURA         VALUE 'Y'. 
           88  WS-NO-FIN-LECTURA      VALUE 'N'. 
 
       77  WS-STATUS-CLI           PIC X. 
           88  WS-FIN-CLI             VALUE 'Y'. 
           88  WS-NO-FIN-CLI          VALUE 'N'.            

       77  WS-STATUS-CTA           PIC X. 
           88  WS-FIN-CTA             VALUE 'Y'. 
           88  WS-NO-FIN-CTA          VALUE 'N'. 

     
      *-----------  VARIABLES  --------------------------------------- 
       77  WS-ENCONTRADOS-CANT        PIC 999           VALUE ZEROES. 
       77  WS-LEIDOS-TBCURCTA-CANT    PIC 999           VALUE ZEROES. 
       77  WS-LEIDOS-TBCURCLI-CANT    PIC 999           VALUE ZEROES. 
       77  WS-NO-ENCONTRADO-CANT      PIC 999           VALUE ZEROES. 

      *----------- FORMATEO ------------------------------------------ 
       77  WS-REGISTROS-PRINT         PIC ZZ9           VALUE ZEROES. 
       
      *-----------  SQL  ---------------------------------------------
       77  WS-SQLCODE           PIC +++999 USAGE DISPLAY   VALUE ZEROS. 
       77  NOT-FOUND            PIC S9(9)  COMP            VALUE  +100. 
       77  NOTFOUND-FORMAT      PIC -ZZZZZZZZZZ.

       77  REG-TIPDOC-CLI       PIC X(2)                  VALUE SPACES.
       77  REG-NRODOC-CLI       PIC S9(11)V USAGE COMP-3  VALUE ZEROES.
       77  REG-NROCLI-CLI       PIC S9(03)V USAGE COMP-3  VALUE ZEROES.
       77  REG-NOMAPE-CLI       PIC X(30)                 VALUE SPACES.

       77  REG-NROCLI-CTA       PIC S9(3)V USAGE COMP-3   VALUE ZEROES.
       77  REG-SUCUEN-CTA       PIC S9(2)V USAGE COMP-3   VALUE ZEROES.


      *////////////  COPYS  /////////////////////////////////////////
      *    TBCURCLI
            EXEC SQL DECLARE KC02787.TBCURCLI TABLE 
           ( TIPDOC             CHAR(2) NOT NULL, 
             NRODOC             DECIMAL(11, 0) NOT NULL, 
             NROCLI             DECIMAL(3, 0) NOT NULL, 
             NOMAPE             CHAR(30) NOT NULL, 
             FECNAC             DATE NOT NULL, 
             SEXO               CHAR(1) NOT NULL 
           ) END-EXEC. 
       01  DCLTBCURCLI. 
           10 WSC-TIPDOC        PIC X(2).                 *> TIPDOC
           10 WSC-NRODOC        PIC S9(11)V USAGE COMP-3. *> NRODOC
           10 WSC-NROCLI        PIC S9(3)V USAGE COMP-3.  *> NROCLI
           10 WSC-NOMAPE        PIC X(30).                *> NOMAPE
           10 WSC-FECNAC        PIC X(10).                *> FECNAC
           10 WSC-SEXO          PIC X(1).                 *> FECNAC

      *    TBCURCTA
           EXEC SQL DECLARE ORIGEN.TBCURCTA TABLE 
           ( TIPCUEN            CHAR(2) NOT NULL, 
             NROCUEN            DECIMAL(5, 0) NOT NULL, 
             SUCUEN             DECIMAL(2, 0) NOT NULL, 
             NROCLI             DECIMAL(3, 0) NOT NULL, 
             SALDO              DECIMAL(7, 2) NOT NULL, 
             FECSAL             DATE NOT NULL 
           ) END-EXEC. 
       01  DCLTBCURCTA. 
           10 CTA-TIPCUEN        PIC X(2). 
           10 CTA-NROCUEN        PIC S9(5)V      USAGE COMP-3. 
           10 CTA-SUCUEN         PIC S9(2)V      USAGE COMP-3. 
           10 CTA-NROCLI         PIC S9(3)V      USAGE COMP-3. 
           10 CTA-SALDO          PIC S9(5)V9(2)  USAGE COMP-3. 
           10 CTA-FECSAL         PIC X(10).    

      *    NOVCTA  LARGO REGISTRO 23
       01  WS-REG-CTA. 
           10 WS-TIPCUEN           PIC X(2). 
           10 WS-NROCUEN           PIC S9(5)V USAGE COMP-3. 
           10 WS-SUCUEN            PIC S9(2)V USAGE COMP-3. 
           10 WS-NROCLI            PIC S9(3)V USAGE COMP-3. 
           10 WS-SALDO             PIC S9(5)V9(2) USAGE COMP-3. 
           10 WS-FECSAL            PIC X(10). 
      *///////////////////////////////////////////////////////////////
      


      *---- SQLCA COMMUNICATION AREA CON EL DB2  --------------------- 
           EXEC SQL INCLUDE SQLCA END-EXEC.                      
      *     EXEC SQL INCLUDE TBCURCLI END-EXEC.                   
      *     EXEC SQL INCLUDE TBCURCTA END-EXEC.                   

           EXEC SQL                                              
              DECLARE TBCURCLI CURSOR FOR                  
                 SELECT TIPDOC, 
                        NRODOC, 
                        NROCLI, 
                        NOMAPE 
                 FROM KC02787.TBCURCLI 
                 ORDER BY NROCLI ASC 
           END-EXEC.                                             

           EXEC SQL 
              DECLARE TBCURCTA CURSOR FOR 
                 SELECT NROCLI, 
                        SUCUEN 
                 FROM KC02787.TBCURCTA 
                 ORDER BY NROCLI ASC 
           END-EXEC

 
      *|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
       PROCEDURE DIVISION. 
 
       MAIN-PROGRAM-I. 

           PERFORM 1000-INICIO-I  THRU  1000-INICIO-F. 
           PERFORM 2000-PROCESO-I THRU  2000-PROCESO-F 
                                  UNTIL WS-FIN-LECTURA. 
           PERFORM 9999-FINAL-I   THRU  9999-FINAL-F. 
              
       MAIN-PROGRAM-F. GOBACK. 
 
      *-------------------------------------------------------------- 
       1000-INICIO-I. 
           
           SET WS-NO-FIN-LECTURA TO TRUE
 
           EXEC SQL OPEN TBCURCLI END-EXEC
           IF SQLCODE NOT EQUAL ZEROS                            
              MOVE SQLCODE TO WS-SQLCODE                         
              DISPLAY '* ERROR OPEN CURSOR = ' WS-SQLCODE        
              MOVE 9999 TO RETURN-CODE                           
              SET WS-FIN-LECTURA TO TRUE                         
           END-IF                                               

           EXEC SQL OPEN TBCURCTA END-EXEC.                     
           IF SQLCODE NOT EQUAL ZEROS                            
              MOVE SQLCODE TO WS-SQLCODE                         
              DISPLAY '* ERROR OPEN CURSOR = ' WS-SQLCODE        
              MOVE 9999 TO RETURN-CODE                           
              SET WS-FIN-LECTURA TO TRUE                         
           END-IF                                              

           IF WS-NO-FIN-LECTURA THEN
              PERFORM 2100-LEER-TBCURCLI-I THRU 2100-LEER-TBCURCLI-F 
              PERFORM 4000-LEER-TBCURCTA-I THRU 4000-LEER-TBCURCTA-F 
           END-IF.

       1000-INICIO-F. EXIT. 
 
 
      *-------------------------------------------------------------- 
       2000-PROCESO-I. 

           IF WS-FIN-CLI AND WS-FIN-CTA THEN
              SET WS-FIN-LECTURA TO TRUE
           END-IF

           IF WS-NO-FIN-LECTURA THEN
              IF REG-NROCLI-CLI = REG-NROCLI-CTA THEN
                 PERFORM 5000-PROCESAR-MAESTRO-I 
                    THRU 5000-PROCESAR-MAESTRO-F 
                 PERFORM 4000-LEER-TBCURCTA-I  
                    THRU 4000-LEER-TBCURCTA-F 
              ELSE 
                 IF REG-NROCLI-CLI > REG-NROCLI-CTA THEN
                    DISPLAY ">>> CUENTA SIN NOVEDAD "
                    ADD 1 TO WS-NO-ENCONTRADO-CANT
                    PERFORM 4000-LEER-TBCURCTA-I 
                       THRU 4000-LEER-TBCURCTA-F 
                 ELSE 
                    DISPLAY ">>> CUENTA SIN CLIENTE EN TBCURCLI"
                    PERFORM 2100-LEER-TBCURCLI-I 
                       THRU 2100-LEER-TBCURCLI-F 
                 END-IF 
              END-IF 
           END-IF. 

       2000-PROCESO-F. EXIT. 
 
 

      *--------------------------------------------------------------
       2100-LEER-TBCURCLI-I. 

           EXEC SQL 
              FETCH TBCURCLI INTO  :DCLTBCURCLI.WSC-TIPDOC,
                                   :DCLTBCURCLI.WSC-NRODOC,
                                   :DCLTBCURCLI.WSC-NROCLI,
                                   :DCLTBCURCLI.WSC-NOMAPE
           END-EXEC. 

           EVALUATE TRUE 
              WHEN SQLCODE EQUAL ZEROS 
                 MOVE WSC-TIPDOC TO REG-TIPDOC-CLI
                 MOVE WSC-NRODOC TO REG-NRODOC-CLI
                 MOVE WSC-NROCLI TO REG-NROCLI-CLI
                 MOVE WSC-NOMAPE TO REG-NOMAPE-CLI
                 ADD 1 TO WS-LEIDOS-TBCURCLI-CANT
              WHEN SQLCODE EQUAL +100 
                 SET WS-FIN-CLI TO TRUE 
                 MOVE 99999 TO REG-NROCLI-CLI  
              WHEN OTHER 
                 MOVE SQLCODE TO WS-SQLCODE 
                 DISPLAY 'ERROR FETCH CURSOR: ' WS-SQLCODE 
                 SET WS-FIN-CLI TO TRUE 
                 MOVE 99999 TO REG-NROCLI-CLI  
           END-EVALUATE. 

       2100-LEER-TBCURCLI-F. EXIT. 


      *-------------------------------------------------------------- 
       4000-LEER-TBCURCTA-I.                                        
  
           EXEC SQL                                              
              FETCH TBCURCTA INTO  :DCLTBCURCTA.CTA-NROCLI,     
                                   :DCLTBCURCTA.CTA-SUCUEN     
           END-EXEC                                             
  
           EVALUATE TRUE                                         
              WHEN SQLCODE EQUAL ZEROS                           
                 MOVE CTA-NROCLI TO REG-NROCLI-CTA
                 MOVE CTA-SUCUEN TO REG-SUCUEN-CTA
                 ADD 1 TO WS-LEIDOS-TBCURCTA-CANT
              WHEN SQLCODE EQUAL +100                            
                 SET WS-FIN-CTA TO TRUE
                 MOVE 99999 TO REG-NROCLI-CTA                      
              WHEN OTHER                                         
                 MOVE SQLCODE TO WS-SQLCODE                      
                 DISPLAY 'ERROR FETCH CURSOR: ' WS-SQLCODE       
                 SET WS-FIN-CTA TO TRUE 
                 MOVE 99999 TO REG-NROCLI-CTA                      
           END-EVALUATE.                                          

       4000-LEER-TBCURCTA-F. EXIT.                                  

 
      *----------------------------------------------------------------
       5000-PROCESAR-MAESTRO-I.                                  
          
              DISPLAY "--------------------------------------"
              DISPLAY "CLIENTES ENCONTRADOS EN TABLA CLIENTES"
              DISPLAY "TIPDOC: " REG-TIPDOC-CLI
              DISPLAY "NRODOC: " REG-NRODOC-CLI
              DISPLAY "NROCLI: " REG-NROCLI-CLI
              DISPLAY "NOMAPE: " REG-NOMAPE-CLI
              DISPLAY "SUCUEN: " REG-SUCUEN-CTA
              DISPLAY "-------------------" 
              ADD 1 TO WS-ENCONTRADOS-CANT.

       5000-PROCESAR-MAESTRO-F. EXIT.                            
       

      *--------------------------------------------------------------
       9999-FINAL-I. 

           EXEC SQL  CLOSE TBCURCTA  END-EXEC. 
           EXEC SQL  CLOSE TBCURCLI  END-EXEC. 

           DISPLAY '**********************************************' 
           MOVE WS-ENCONTRADOS-CANT TO WS-REGISTROS-PRINT
           DISPLAY 'ENCONTRADOS:      ' WS-ENCONTRADOS-CANT    
           MOVE WS-LEIDOS-TBCURCLI-CANT TO WS-REGISTROS-PRINT
           DISPLAY 'LEIDOS TBCURCLI:  ' WS-LEIDOS-TBCURCLI-CANT
           MOVE WS-LEIDOS-TBCURCTA-CANT TO WS-REGISTROS-PRINT
           DISPLAY 'LEIDOS TBCURCTA:  ' WS-LEIDOS-TBCURCTA-CANT
           MOVE WS-NO-ENCONTRADO-CANT TO WS-REGISTROS-PRINT
           DISPLAY 'NO ENCONTRADOS:   ' WS-NO-ENCONTRADO-CANT.

       9999-FINAL-F. EXIT. 