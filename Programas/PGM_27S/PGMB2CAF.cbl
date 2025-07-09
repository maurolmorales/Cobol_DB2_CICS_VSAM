       IDENTIFICATION DIVISION. 
       PROGRAM-ID. PGMB2CAF. 
      ************************************** 
      *                                    * 
      *  PROGRAMA DE PRUEBA DE COMPILADOR  * 
      *  A SU VEZ SIRVE COMO MODELO DB2    * 
      *                                    * 
      ************************************** 
      *|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
                                                                        
       ENVIRONMENT DIVISION. 
       INPUT-OUTPUT SECTION. 
                                                                        
       FILE-CONTROL. 
           SELECT NOVEDADES ASSIGN TO DDENTRA 
           ORGANIZATION IS INDEXED 
           ACCESS       IS SEQUENTIAL 
           RECORD KEY   IS FS-KEY 
           FILE STATUS  IS FS-NOVEDADES. 
                                                                        
      *|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       DATA DIVISION. 
       FILE SECTION. 
                                                                        
       FD  NOVEDADES. 
       01  FS-DATA. 
           05 FS-KEY                     PIC X(17). 
           05 FS-DESC                    PIC X(227). 
                                                                        
       WORKING-STORAGE SECTION. 
      *=======================* 
                                                                        
      *----   ARCHIVO  --------------------------------------------- 
       77  FS-NOVEDADES            PIC XX       VALUE SPACES. 
                                                                        
       77  WS-STATUS-FIN           PIC X. 
           88  WS-FIN-LECTURA                   VALUE 'Y'. 
           88  WS-NO-FIN-LECTURA                VALUE 'N'. 
       77  WS-REG-CANT             PIC 999      VALUE ZEROES. 
       77  WS-GRABADOS             PIC 99       VALUE ZEROES. 
       77  WS-ERRORES              PIC 99       VALUE ZEROES. 
       77  NOT-FOUND               PIC S9(9) COMP VALUE  +100. 
       77  WS-REG-SALIDA           PIC X(244). 
       77  NOTFOUND-FORMAT         PIC -ZZZZZZZZZZ. 
                                                                        
       01  WS-NOMAPE-COMPLETO. 
           05 WS-NOMAPE-NOMBRE     PIC X(15). 
           05 WS-NOMAPE-APELLIDO   PIC X(15). 
                                                                        
                                                                        
      *---- SQLCA COMMUNICATION AREA CON EL DB2  --------------------- 
           EXEC SQL INCLUDE SQLCA    END-EXEC. 
           EXEC SQL INCLUDE TBCURCLI END-EXEC. 
                                                                        
           COPY TBVCLIEN. 
                                                                        
       77  FILLER        PIC X(26) VALUE '* FINAL  WORKING-STORAGE *'. 
                                                                        
      *|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       PROCEDURE DIVISION. 
                                                                        
      *----  CUERPO PRINCIPAL DEL PROGRAMA  ------------------------- 
       0000-MAIN-PROCESS-I. 
                                                                        
           PERFORM 1000-INICIO-I  THRU 1000-INICIO-F. 
           PERFORM 2000-PROCESO-I THRU 2000-PROCESO-F 
                                  UNTIL WS-FIN-LECTURA. 
           PERFORM 9999-FINAL-I THRU 9999-FINAL-F. 

       0000-MAIN-PROCESS-F. GOBACK. 
                                                                        
                                                                        
      *--  CUERPO INICIO APERTURA FILES  --------------------------- 
       1000-INICIO-I. 
                                                                        
           OPEN INPUT NOVEDADES. 
           SET WS-NO-FIN-LECTURA TO TRUE. 
                                                                        
           IF FS-NOVEDADES IS NOT EQUAL '00' 
              DISPLAY '* ERROR EN OPEN ENTRADA INICIO = ' FS-NOVEDADES 
              SET  WS-FIN-LECTURA TO TRUE 
              MOVE 3333 TO RETURN-CODE 
              PERFORM 9999-FINAL-I THRU 9999-FINAL-F 
           END-IF. 
                                                                        
       1000-INICIO-F. EXIT. 
                                                                        
                                                                        
      *-------------------------------------------------------------- 
       2000-PROCESO-I. 
                                                                        
           PERFORM 2100-LEER-I THRU 2100-LEER-F. 
                                                                        
           IF FS-NOVEDADES IS EQUAL '00' 
           
      *    para unir el nombre con el apellido.                                                                  
           MOVE SPACES TO WS-NOMAPE-COMPLETO 
           STRING 
               WK-CLI-NOMBRE-CLIENTE DELIMITED BY SPACE 
               ', ' DELIMITED BY SIZE 
               WK-CLI-APELLIDO-CLIENTE DELIMITED BY SPACE 
               INTO WS-NOMAPE-COMPLETO 
                                                                        
                                                                        
              MOVE WK-CLI-TIPO-DOCUMENTO     TO WSC-TIPDOC 
              MOVE WK-CLI-NRO-DOCUMENTO      TO WSC-NRODOC 
              MOVE WK-CLI-NRO-CLIENTE        TO WSC-NROCLI 
              MOVE WS-NOMAPE-COMPLETO        TO WSC-NOMAPE 
              MOVE WK-CLI-FECHA-NACIMIENTO   TO WSC-FECNAC 
              MOVE WK-CLI-SEXO               TO WSC-SEXO 
                                                                        
              DISPLAY "-> TIPDOC: " WSC-TIPDOC 
              DISPLAY "-> NRODOC: " WSC-NRODOC 
              DISPLAY "-> NROCLI: " WSC-NROCLI 
              DISPLAY "-> NOMAPE: " WSC-NOMAPE 
              DISPLAY "-> FECNAC: " WSC-FECNAC 
              DISPLAY "-> SEXO:   " WSC-SEXO 
                                                                        
              EXEC SQL 
                 INSERT INTO KC02787.TBCURCLI 
                    ( TIPDOC, 
                      NRODOC, 
                      NROCLI, 
                      NOMAPE, 
                      FECNAC, 
                      SEXO ) 
                 VALUES ( 
                      :WSC-TIPDOC, 
                      :WSC-NRODOC, 
                      :WSC-NROCLI, 
                      :WSC-NOMAPE, 
                      :WSC-FECNAC, 
                      :WSC-SEXO 
                    ) 
              END-EXEC 
                                                                        
      *       EXEC SQL 
      *          DELETE FROM KC02787.TBCURCLI 
      *                 WHERE NRODOC = :WSC-NRODOC 
      *       END-EXEC 
                                                                        
              IF SQLCODE = NOT-FOUND 
                 DISPLAY 'PROYECTO VACíO: ' 
              ELSE 
                 IF SQLCODE = 0 
                    ADD  1 TO WS-GRABADOS 
                    DISPLAY 'REGISTRO GRABADO: ' WS-GRABADOS 
                 ELSE 
                    MOVE SQLCODE TO NOTFOUND-FORMAT 
                    DISPLAY 'ERROR DB2: ' NOTFOUND-FORMAT 
                    MOVE 1 TO WS-ERRORES 
                 END-IF 
              END-IF 
           END-IF. 
                                                                        
       2000-PROCESO-F. EXIT. 
                                                                        
      *-------------------------------------------------------------- 
       2100-LEER-I. 
                                                                        
           READ NOVEDADES INTO WK-TBCLIE 
                                                                        
           EVALUATE FS-NOVEDADES 
              WHEN '00' 
                 ADD 1 TO WS-REG-CANT 
                 CONTINUE 
              WHEN '10' 
                 SET WS-FIN-LECTURA TO TRUE 
              WHEN OTHER 
                 DISPLAY '*ERROR EN LECTURA ENTRADA INICIO : ' 
                                                  FS-NOVEDADES 
                 DISPLAY "ERROR: " WK-TBCLIE 
                 SET WS-FIN-LECTURA TO TRUE 
           END-EVALUATE. 

       2100-LEER-F. EXIT. 
                                                                        
      *-------------------------------------------------------------- 
       9999-FINAL-I. 
                                                                        
           DISPLAY "TOTAL DE REGISTROS: " WS-REG-CANT 
           DISPLAY "TOTAL DE GRABADOS: " WS-GRABADOS 
           DISPLAY "TOTAL DE ERRORES: " WS-ERRORES 
                                                                        
           CLOSE NOVEDADES 
           IF FS-NOVEDADES  IS NOT EQUAL '00' 
              DISPLAY '* ERROR EN CLOSE ENTRADA = ' FS-NOVEDADES 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-LECTURA TO TRUE 
           END-IF. 
                                                                        
       9999-FINAL-F.  EXIT.                                                                                                                                                                            