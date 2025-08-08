       IDENTIFICATION DIVISION. 
       PROGRAM-ID. MLMB2CAF. 
  
      **************************************************************** 
      *    CLASE SINCRÓNICA 28 
      *    ====================
      *    - SELECT DB2 CURSOR
      *    - IMPRESIÓN
      *    - SALIDA QSAM
      **************************************************************** 
  
      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       ENVIRONMENT DIVISION. 
       CONFIGURATION SECTION. 
  
       SPECIAL-NAMES. 
           DECIMAL-POINT IS COMMA. 
  
       INPUT-OUTPUT SECTION. 
       FILE-CONTROL. 
           SELECT LISTADO ASSIGN DDLISTA 
           FILE STATUS IS FS-LISTADO. 
  
      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       DATA DIVISION. 
       FILE SECTION. 
  
       FD  LISTADO 
           BLOCK CONTAINS 0 RECORDS 
           RECORDING MODE IS F. 
       01  REG-SALIDA     PIC X(123). 
  
       WORKING-STORAGE SECTION. 
      *========================* 
  
      *----------- ARCHIVOS ----------------------------------------- 
       77  FS-LISTADO              PIC XX               VALUE SPACES. 

       77  WS-STATUS-FIN           PIC X. 
           88  WS-FIN-LECTURA         VALUE 'Y'. 
           88  WS-NO-FIN-LECTURA      VALUE 'N'. 
  
       77  WS-STATUS-NOV           PIC X. 
           88  WS-FIN-NOV             VALUE 'Y'. 
           88  WS-NO-FIN-NOV          VALUE 'N'. 
  
      *-----------  VARIABLES  --------------------------------------- 
       77  REG-TIPCUEN         PIC X(2)                  VALUE SPACES. 
       77  REG-NROCUEN         PIC S9(5)V USAGE COMP-3   VALUE ZEROES. 
       77  REG-SUCUEN          PIC S9(2)V USAGE COMP-3   VALUE ZEROES. 
       77  REG-NOMAPE          PIC X(30)                 VALUE SPACES. 
       77  REG-NROCLI          PIC S9(3)V USAGE COMP-3   VALUE ZEROES. 
       77  REG-SALDO         PIC S9(5)V9(2) USAGE COMP-3 VALUE ZEROES. 
       77  REG-FECSAL          PIC X(10)                 VALUE SPACES. 
  
      *----------- ACUMULADORES -------------------------------------- 
       77  WS-REGISTROS-CANT     PIC 999                 VALUE ZEROES. 
  
      *-----------  SQL  --------------------------------------------- 
       77  WS-SQLCODE            PIC +++999 USAGE DISPLAY VALUE ZEROS. 
       77  NOT-FOUND               PIC S9(9) COMP         VALUE  +100. 
       77  NOTFOUND-FORMAT         PIC -ZZZZZZZZZZ. 
  
      *-----------  IMPRESION  --------------------------------------- 
       77  WS-TIPO-DOC-PRINT       PIC ZZ9              VALUE ZEROES. 
       77  WS-REGISTROS-PRINT      PIC ZZ9              VALUE ZEROES. 
       77  WS-PIPE                 PIC XXX              VALUE ' | '. 
       77  WS-LINE                 PIC X(132)           VALUE ALL '='. 
       77  WS-LINE2                PIC X(132)           VALUE ALL '-'. 
       77  WS-SEPARATE             PIC X(132)           VALUE SPACES. 
       77  WS-CUENTA-LINEA         PIC 9(02)            VALUE ZEROS. 
       77  WS-CUENTA-PAGINA        PIC 9(02)            VALUE 01. 
  
      *    CONTADOR DE LEIDOS Y GRABADOS 
       01  WS-LEIDOS               PIC 9(05)            VALUE ZEROS. 
       01  WS-IMPRESOS             PIC 9(05)            VALUE ZEROS. 
  
      *    TITULO: 
       01  IMP-TITULO. 
           03  FILLER              PIC X(3)             VALUE SPACES. 
           03  FILLER              PIC X(05)            VALUE SPACES. 
           03  FILLER              PIC X(42)            VALUE 
            'LISTADO DE CLIENTES CON SALDO MAYOR A CERO' . 
           03  FILLER              PIC X                VALUE SPACES. 
           03  IMP-TIT-DD          PIC Z9               VALUE ZEROS. 
           03  FILLER              PIC X                VALUE '-'. 
           03  IMP-TIT-MM          PIC Z9               VALUE ZEROS. 
           03  FILLER              PIC X                VALUE '-'. 
           03  FILLER              PIC 99               VALUE 20. 
           03  IMP-TIT-AA          PIC 99               VALUE ZEROS. 
           03  FILLER              PIC X(4)             VALUE SPACES. 
           03  FILLER              PIC X(15)            VALUE 
                                          'NUMERO PAGINA: '. 
           03  IMP-TIT-PAGINA      PIC Z9               VALUE ZEROS. 
           03  FILLER              PIC X(41)            VALUE SPACES. 
  
      *    SUBTITULO: 
       01  IMP-SUBTITULO. 
           03  FILLER              PIC X(03)           VALUE ' | '. 
           03  FILLER              PIC X(07)           VALUE 'TIPCUEN'. 
           03  FILLER              PIC X(03)           VALUE ' | '. 
           03  FILLER              PIC X(07)           VALUE 'NROCUEN'. 
           03  FILLER              PIC X(03)           VALUE ' | '. 
           03  FILLER              PIC X(06)           VALUE 'SUCUEN'. 
           03  FILLER              PIC X(03)           VALUE ' | '. 
           03  FILLER              PIC X(06)           VALUE 'NROCLI'. 
           03  FILLER              PIC X(03)           VALUE ' | '. 
           03  FILLER              PIC X(13)           VALUE SPACES. 
           03  FILLER              PIC X(06)           VALUE 'NOMAPE'. 
           03  FILLER              PIC X(13)           VALUE SPACES. 
           03  FILLER              PIC X(03)           VALUE ' | '. 
           03  FILLER              PIC X(05)           VALUE SPACES. 
           03  FILLER              PIC X(06)           VALUE 'SALDO'. 
           03  FILLER              PIC X(05)           VALUE SPACES. 
           03  FILLER              PIC X(03)           VALUE ' | '. 
           03  FILLER              PIC X(03)           VALUE SPACES. 
           03  FILLER              PIC X(06)           VALUE 'FECSAL'. 
           03  FILLER              PIC X(03)           VALUE SPACES. 
           03  FILLER              PIC X(03)           VALUE ' | '. 
  
      *    REGISTROS 
       01  IMP-REG-LISTADO. 
           03  IMP-COL1            PIC X(03)            VALUE SPACES. 
           03  FILLER              PIC X(05)            VALUE SPACES. 
           03  IMP-TIPCUEN         PIC X(2)             VALUE SPACES. 
           03  IMP-COL2            PIC X(03)            VALUE SPACES. 
           03  FILLER              PIC X(2)             VALUE SPACES. 
           03  IMP-NROCUEN         PIC Z(05). 
           03  IMP-COL3            PIC X(03)            VALUE SPACES. 
           03  FILLER              PIC X(4)             VALUE SPACES. 
           03  IMP-SUCUEN          PIC ZZ.
           03  IMP-COL4            PIC X(03)            VALUE SPACES. 
           03  FILLER              PIC X(3)             VALUE SPACES. 
           03  IMP-NROCLI          PIC ZZZ. 
           03  IMP-COL5            PIC X(03)            VALUE SPACES. 
           03  FILLER              PIC X(2)             VALUE SPACES. 
           03  IMP-NOMAPE          PIC X(30)            VALUE SPACES. 
           03  IMP-COL6            PIC X(03)            VALUE SPACES. 
           03  FILLER              PIC X(2)             VALUE SPACES. 
           03  IMP-SALDO           PIC -$Z.ZZZ.ZZZ,99. 
           03  IMP-COL7            PIC X(03)            VALUE SPACES. 
           03  FILLER              PIC X(2)             VALUE SPACES. 
           03  IMP-FECSAL          PIC X(10)            VALUE SPACES. 
           03  IMP-COL8            PIC X(03)            VALUE SPACES. 

      *-----------  FECHA DE PROCESO  ------------------------------- 
       01  WS-FECHA. 
           03  WS-FECHA-AA         PIC 99               VALUE ZEROS. 
           03  WS-FECHA-MM         PIC 99               VALUE ZEROS. 
           03  WS-FECHA-DD         PIC 99               VALUE ZEROS. 

       01  WS-FECHA-COMPUESTA      PIC X(10). 

       01  FECHA-MODIF. 
           03  FM-ANIO             PIC 9(4). 
           03  FM-SEP1             PIC X VALUE '-'. 
           03  FM-MES              PIC 9(2). 
           03  FM-SEP2             PIC X VALUE '-'. 
           03  FM-DIA              PIC 9(2). 
  
      *//////////////////////  COPY EMBEBIDO  //////////////////////
       01  DCLTBCURCLI.                                                 
           10 CLI-TIPDOC           PIC X(2).                            
           10 CLI-NRODOC           PIC S9(11)V USAGE COMP-3.            
           10 CLI-NROCLI           PIC S9(3)V USAGE COMP-3.             
           10 CLI-NOMAPE           PIC X(30).                           
           10 CLI-FECNAC           PIC X(10).                           
           10 CLI-SEXO             PIC X(1).                            

       01  DCLTBCURCTA.                                            
           10 CTA-TIPCUEN          PIC X(2).                       
           10 CTA-NROCUEN          PIC S9(5)V USAGE COMP-3.        
           10 CTA-SUCUEN           PIC S9(2)V USAGE COMP-3.        
           10 CTA-NROCLI           PIC S9(3)V USAGE COMP-3.        
           10 CTA-SALDO            PIC S9(5)V9(2) USAGE COMP-3.    
           10 CTA-FECSAL           PIC X(10).                      
      *//////////////////////////////////////////////////////////////


      *---- SQLCA COMMUNICATION AREA CON EL DB2  --------------------- 
           EXEC SQL INCLUDE SQLCA END-EXEC. 

      *    PARA REEMPLAZAR POR LA COPY EMBEBIDA.
      *    EXEC SQL INCLUDE TBCURCTA END-EXEC. 
      *    EXEC SQL INCLUDE TBCURCLI END-EXEC. 
      
           EXEC SQL 
              DECLARE CURSOR_CLI CURSOR FOR 
                 SELECT A.TIPCUEN, 
                        A.NROCUEN, 
                        A.SUCUEN, 
                        A.NROCLI, 
                        B.NOMAPE, 
                        A.SALDO, 
                        A.FECSAL 
                 FROM  KC02803.TBCURCTA A 
                 INNER JOIN KC02803.TBCURCLI B 
                 ON A.NROCLI = B.NROCLI 
                 WHERE A.SALDO > 0 
           END-EXEC. 
  
      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       PROCEDURE DIVISION. 
  
       MAIN-PROGRAM-I. 
  
           PERFORM 1000-INICIO-I  THRU  1000-INICIO-F. 
           PERFORM 2000-PROCESO-I THRU  2000-PROCESO-F 
                                  UNTIL WS-FIN-LECTURA. 
           PERFORM 9999-FINAL-I   THRU  9999-FINAL-F. 
  
       MAIN-PROGRAM-F. GOBACK. 
  
  
      *-------------------------------------------------------------- 
       1000-INICIO-I. 

           SET WS-NO-FIN-LECTURA TO TRUE. 
  
           ACCEPT WS-FECHA FROM DATE. 
           MOVE WS-FECHA-AA TO IMP-TIT-AA. 
           MOVE WS-FECHA-MM TO IMP-TIT-MM. 
           MOVE WS-FECHA-DD TO IMP-TIT-DD. 
      *    MOVE 10 TO WS-CUENTA-LINEA. 
  
           OPEN OUTPUT LISTADO. 
           IF FS-LISTADO IS NOT EQUAL '00' 
              DISPLAY '* ERROR EN OPEN LISTADO = ' FS-LISTADO 
              MOVE 9999 TO RETURN-CODE 
              SET  WS-FIN-LECTURA TO TRUE 
           END-IF. 
  
           EXEC SQL OPEN CURSOR_CLI END-EXEC. 
           IF SQLCODE NOT EQUAL ZEROS 
              MOVE SQLCODE TO WS-SQLCODE 
              DISPLAY '* ERROR OPEN CURSOR = ' WS-SQLCODE 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-LECTURA TO TRUE 
           END-IF. 

           PERFORM 4000-LEER-FETCH-I THRU 4000-LEER-FETCH-F. 
  
           IF WS-FIN-LECTURA 
              DISPLAY '* ARCHIVO ENTRADA VACÍO EN INICIO' FS-LISTADO 
           ELSE 
              PERFORM 6500-IMPRIMIR-TITULOS-I 
                 THRU 6500-IMPRIMIR-TITULOS-F 
           END-IF. 
  
       1000-INICIO-F. EXIT. 
  
  
      *-------------------------------------------------------------- 
       2000-PROCESO-I. 

           IF SQLCODE = NOT-FOUND THEN 
              DISPLAY 'FIN DE DATOS. NO HAY MÁS REGISTROS.' 
           ELSE 
              IF SQLCODE = 0 THEN 
                 MOVE SPACES       TO IMP-REG-LISTADO 
                 MOVE WS-PIPE      TO IMP-COL1 
                 MOVE REG-TIPCUEN  TO IMP-TIPCUEN 
                 MOVE WS-PIPE      TO IMP-COL2 
                 MOVE REG-NROCUEN  TO IMP-NROCUEN 
                 MOVE WS-PIPE      TO IMP-COL3 
                 MOVE REG-SUCUEN   TO IMP-SUCUEN 
                 MOVE WS-PIPE      TO IMP-COL4 
                 MOVE REG-NROCLI   TO IMP-NROCLI 
                 MOVE WS-PIPE      TO IMP-COL5 
                 MOVE REG-NOMAPE   TO IMP-NOMAPE 
                 MOVE WS-PIPE      TO IMP-COL6 
                 MOVE REG-SALDO    TO IMP-SALDO 
                 MOVE WS-PIPE      TO IMP-COL7 
                 MOVE REG-FECSAL   TO IMP-FECSAL 
                 MOVE WS-PIPE      TO IMP-COL8 
      
                 PERFORM 6000-GRABAR-SALIDA-I
                    THRU 6000-GRABAR-SALIDA-F 
       
                 PERFORM 4000-LEER-FETCH-I 
                    THRU 4000-LEER-FETCH-F
              ELSE 
                 MOVE SQLCODE TO NOTFOUND-FORMAT 
                 DISPLAY 'ERROR DB2: ' NOTFOUND-FORMAT 
              END-IF 
           END-IF. 
  
       2000-PROCESO-F. EXIT. 
  

  
      *-------------------------------------------------------------- 
       4000-LEER-FETCH-I. 
  
           EXEC SQL 
              FETCH CURSOR_CLI INTO :DCLTBCURCTA.CTA-TIPCUEN, 
                                    :DCLTBCURCTA.CTA-NROCUEN, 
                                    :DCLTBCURCTA.CTA-SUCUEN, 
                                    :DCLTBCURCTA.CTA-NROCLI, 
                                    :DCLTBCURCLI.CLI-NOMAPE, 
                                    :DCLTBCURCTA.CTA-SALDO, 
                                    :DCLTBCURCTA.CTA-FECSAL 
           END-EXEC. 
  
           EVALUATE TRUE 
              WHEN SQLCODE EQUAL ZEROS 
                 MOVE CTA-TIPCUEN  TO REG-TIPCUEN 
                 MOVE CTA-NROCUEN  TO REG-NROCUEN 
                 MOVE CTA-SUCUEN   TO REG-SUCUEN 
                 MOVE CLI-NOMAPE   TO REG-NOMAPE 
                 MOVE CTA-NROCLI   TO REG-NROCLI 
                 MOVE CTA-SALDO    TO REG-SALDO 
                 MOVE CTA-FECSAL   TO REG-FECSAL 
                 ADD 1 TO WS-LEIDOS 
              WHEN SQLCODE EQUAL +100 
                 SET WS-FIN-LECTURA TO TRUE 
      *           MOVE 99999 TO WS-CLI-CLAVE 
              WHEN OTHER 
                 MOVE SQLCODE TO WS-SQLCODE 
                 DISPLAY 'ERROR FETCH CURSOR: ' WS-SQLCODE 
                 SET WS-FIN-LECTURA TO TRUE 
      *           MOVE 99999 TO WS-CLI-CLAVE 
           END-EVALUATE. 
  
       4000-LEER-FETCH-F. EXIT. 
  
  
      *-------------------------------------------------------------- 
       6000-GRABAR-SALIDA-I. 
  
           IF WS-CUENTA-LINEA GREATER 15 THEN 
              WRITE REG-SALIDA FROM WS-SEPARATE AFTER 1 
              PERFORM 6500-IMPRIMIR-TITULOS-I 
                 THRU 6500-IMPRIMIR-TITULOS-F 
           END-IF. 
  
           WRITE REG-SALIDA FROM IMP-REG-LISTADO AFTER 1. 

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
  
           MOVE WS-CUENTA-PAGINA TO IMP-TIT-PAGINA. 
           MOVE 0 TO WS-CUENTA-LINEA. 
           ADD  1 TO WS-CUENTA-PAGINA. 
           WRITE REG-SALIDA FROM IMP-TITULO AFTER PAGE. 
  
           PERFORM 6600-IMPRIMIR-SUBTITULOS-I 
              THRU 6600-IMPRIMIR-SUBTITULOS-F 
  
           IF FS-LISTADO IS NOT EQUAL '00' 
              DISPLAY '* ERROR EN WRITE LISTADO = ' FS-LISTADO 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-LECTURA TO TRUE 
           END-IF. 
  
       6500-IMPRIMIR-TITULOS-F. EXIT. 
  
  
      *-------------------------------------------------------------- 
       6600-IMPRIMIR-SUBTITULOS-I. 
  
           MOVE 1 TO WS-CUENTA-LINEA. 
           WRITE REG-SALIDA FROM WS-LINE2 AFTER 1. 
           WRITE REG-SALIDA FROM IMP-SUBTITULO AFTER 1 
           WRITE REG-SALIDA FROM WS-LINE2 AFTER 1. 
  
       6600-IMPRIMIR-SUBTITULOS-F. EXIT. 
  
  
      *-------------------------------------------------------------- 
       9999-FINAL-I. 
  
           EXEC SQL CLOSE CURSOR_CLI END-EXEC. 
  
           CLOSE LISTADO 
           IF FS-LISTADO IS NOT EQUAL '00' 
              DISPLAY '* ERROR EN CLOSE LISTADO = ' 
              FS-LISTADO 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-LECTURA TO TRUE 
           END-IF. 
  
           DISPLAY 'LEIDOS:     ' WS-LEIDOS. 
           DISPLAY 'IMPRESOS:   ' WS-IMPRESOS. 
  
       9999-FINAL-F. EXIT.                 