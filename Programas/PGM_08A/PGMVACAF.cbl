       IDENTIFICATION DIVISION. 
       PROGRAM-ID. PGMVACAF. 
      ************************************************************
      *                                                          *
      *  CURSO: DESARROLLO COBOL - CLASE 8 ASINCRÓNICA           *
      *  PROGRAMA: PGMVACAF                                      *
      *  DESCRIPCIÓN:                                            *
      *    PROCESA NOVEDADES DE CLIENTES DESDE UN ARCHIVO DE     *
      *    ENTRADA, REALIZA VALIDACIONES DE TIPO DE DOCUMENTO Y  *
      *    FECHAS, Y GENERA UN ARCHIVO DE SALIDA CON REGISTROS   *
      *    CORRECTOS.                                            *
      *                                                          *
      ************************************************************

      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       ENVIRONMENT DIVISION. 
       INPUT-OUTPUT SECTION. 
       FILE-CONTROL. 
 
           SELECT ENTRADA  ASSIGN DDENTRA 
                  FILE STATUS IS FS-ENTRADA. 
 
           SELECT SALIDA   ASSIGN DDSALID 
                  FILE STATUS IS FS-SALIDA. 
 
      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       DATA DIVISION. 
       FILE SECTION. 
 
       FD  ENTRADA 
           BLOCK CONTAINS 0 RECORDS 
           RECORDING MODE IS F. 
       01  REG-ENTRADA    PIC X(50). 
 
       FD  SALIDA 
           BLOCK CONTAINS 0 RECORDS 
           RECORDING MODE IS F. 
       01  REG-SALIDA     PIC X(55). 
                                      
       
       WORKING-STORAGE SECTION. 
      *=======================*

       77  FILLER        PIC X(26) VALUE '* INICIO WORKING-STORAGE *'. 
 
      *---- FILE STATUS ---------------------------------------------- 
       77  FS-ENTRADA                 PIC XX      VALUE SPACES. 
           88  FS-ENTRADA-FIN                     VALUE '10'. 
                                                  
       77  FS-SALIDA                  PIC XX      VALUE SPACES. 
           88  FS-SALIDA-FIN                      VALUE '10'. 
 
      *---- VERIFICA SI EL REGISTRO ES ERRONEO ----------------------- 
       77  WS-REG-VALIDO              PIC X(02)   VALUE 'SI'. 
 
      *---- CONTADOR DE REGISTROS QUE CUMPLEN LA CONDICION ----------- 
       77  WS-CANT-CONDICION          PIC 9(3)    VALUE ZEROS. 
       77  WS-COND-EDIT               PIC Z(3)    VALUE ZEROS. 
 
      *---- CONTADOR DE TOTALES -------------------------------------- 
       77  WS-CANT-LEIDOS             PIC 9(3)    VALUE ZEROS. 
       77  WS-CANT-GRABADOS           PIC 9(3)    VALUE ZEROS. 
       77  WS-CANT-ERRONEOS           PIC 9(3)    VALUE ZEROS. 
 

      *//// COPY PARA ESTRUCTURA DE DATOS ////////////////////////////
      
      *    COPY CPNOVCLI. 

      *    LAYOUT NOVEDAD CLIENTES
      *    KC02788.ALU9999.NOVCLIEN
      *    LARGO 50 BYTES
       01  WS-REG-NOVCLIE. 
           03  NOV-TIP-DOC         PIC X(02)    VALUE SPACES. 
           03  NOV-NRO-DOC         PIC 9(11)    VALUE ZEROS. 
           03  NOV-SUC             PIC 9(02)    VALUE ZEROS. 
           03  NOV-CLI-TIPO        PIC 9(02)    VALUE ZEROS. 
           03  NOV-CLI-NRO         PIC 9(03)    VALUE ZEROS. 
           03  NOV-CLI-IMP         PIC S9(09)V99 COMP-3 VALUE ZEROS. 
           03  NOV-CLI-FECHA       PIC X(8)     VALUE ZEROS. 
           03  FILLER              PIC X(16)    VALUE SPACES. 

      *    COPY CPNCLIV. 

      *    LAYOUT NOVEDAD CLIENTES
      *    KC03XXX.NOVCLIEN.VALID
      *    ES EL CPNOVCLI VALIDADO
      *    LARGO 55 BYTES
       01 REG-NOVCLIE-VAL. 
           03  NOV-SECUEN          PIC 9(05)    VALUE ZEROS. 
           03  NOV-RESTO           PIC X(50)    VALUE SPACES.
           
      *///////////////////////////////////////////////////////////////

      *---- PARA CONTROLAR LAS FECHAS --------------------------------- 
       01  WS-FECHA. 
           05 FECHA-ANIO              PIC 9(4). 
           05 FECHA-MES               PIC 9(2). 
           05 FECHA-DIA               PIC 9(2). 
 
       01  FILLER        PIC X(26) VALUE '* FINAL  WORKING-STORAGE *'. 

 
      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       PROCEDURE DIVISION. 
 
       MAIN-PROGRAM-I. 
 
           PERFORM 1000-INICIO-I  THRU 1000-INICIO-F 
           PERFORM 2000-PROCESO-I THRU 2000-PROCESO-F 
                                 UNTIL FS-ENTRADA-FIN 
           PERFORM 3000-FINAL-I   THRU 3000-FINAL-F. 

       MAIN-PROGRAM-F. GOBACK. 


 
      *----  CUERPO INICIO APERTURA ARCHIVOS -------------------------
       1000-INICIO-I. 

           OPEN INPUT  ENTRADA 
           IF FS-ENTRADA IS NOT EQUAL '00' 
              DISPLAY '* ERROR EN OPEN SUCURSAL= ' FS-ENTRADA 
              MOVE 9999 TO RETURN-CODE 
              SET  FS-ENTRADA-FIN TO TRUE 
           ELSE 
              PERFORM 2100-LEER-I  THRU 2100-LEER-F 
           END-IF 

           OPEN OUTPUT SALIDA 
           IF FS-SALIDA IS NOT EQUAL '00' 
              DISPLAY '* ERROR EN OPEN SALIDA = ' FS-SALIDA 
              MOVE 9999 TO RETURN-CODE 
              SET  FS-ENTRADA-FIN TO TRUE 
           END-IF. 

       1000-INICIO-F. EXIT. 


      *--------------------------------------------------------------- 
       2000-PROCESO-I. 

           IF NOV-TIP-DOC = 'DU' OR 
              NOV-TIP-DOC = 'PA' OR 
              NOV-TIP-DOC = 'PE' OR 
              NOV-TIP-DOC = 'CI' 

              PERFORM 2010-VERIF-FECHA THRU 2010-VERIF-FECHA-F 

              IF WS-REG-VALIDO = 'SI' 
                 PERFORM 2200-GRABAR-REG THRU 2200-GRABAR-REG-F 
              END-IF 
           ELSE 
              DISPLAY '----------------------------' 
              DISPLAY  'TIPO DOCUMENTO INVÁLIDO: ' NOV-TIP-DOC 
                       ' NRO: ' NOV-NRO-DOC 
              ADD 1 TO WS-CANT-ERRONEOS 
           END-IF 
 
           PERFORM 2100-LEER-I THRU 2100-LEER-F. 

       2000-PROCESO-F. EXIT. 


 
      *--------------------------------------------------------------- 
       2010-VERIF-FECHA. 

           MOVE 'SI' TO WS-REG-VALIDO 
           MOVE NOV-CLI-FECHA TO WS-FECHA 
 
           IF FECHA-ANIO < 2025 
               DISPLAY '----------------------------' 
               DISPLAY 'AÑO INVÁLIDO < 2025 - DOC NRO: ' NOV-NRO-DOC 
               MOVE 'NO' TO WS-REG-VALIDO 
               ADD 1 TO WS-CANT-ERRONEOS 
           END-IF 
 
           IF FECHA-MES < 1 OR FECHA-MES > 12 
               DISPLAY '----------------------------' 
               DISPLAY 'MES INVÁLIDO DOC NRO: ' NOV-NRO-DOC 
               MOVE 'NO' TO WS-REG-VALIDO 
               ADD 1 TO WS-CANT-ERRONEOS 
           ELSE 
               EVALUATE FECHA-MES 
                  WHEN 1 
                  WHEN 3 
                  WHEN 5 
                  WHEN 7 
                  WHEN 08 
                  WHEN 10 
                  WHEN 12 
                     IF FECHA-DIA < 1 OR FECHA-DIA > 31 
                        DISPLAY '----------------------------' 
                        DISPLAY 'DÍA INVÁLIDO PARA MES DE 31 DÍAS' 
                                 ' NRO: ' NOV-NRO-DOC 
                        MOVE 'NO' TO WS-REG-VALIDO 
                        ADD 1 TO WS-CANT-ERRONEOS 
                     END-IF 
                  WHEN 4 
                  WHEN 6 
                  WHEN 9 
                  WHEN 11 
                        IF FECHA-DIA < 1 OR FECHA-DIA > 30 
                           DISPLAY '----------------------------' 
                           DISPLAY 'DÍA INVÁLIDO PARA MES DE 30 DÍAS' 
                                   ' NRO: ' NOV-NRO-DOC 
                           MOVE 'NO' TO WS-REG-VALIDO 
                           ADD 1 TO WS-CANT-ERRONEOS 
                        END-IF 
                  WHEN 2 
                    IF (FECHA-ANIO / 4) * 4 = FECHA-ANIO AND 
                       (FECHA-ANIO / 100) * 100 NOT = FECHA-ANIO 
                       OR (FECHA-ANIO / 400) * 400 = FECHA-ANIO 
                       IF FECHA-DIA < 1 OR FECHA-DIA > 29 
                          DISPLAY '----------------------------' 
                          DISPLAY 'FEBRERO INVÁLIDO EN BISIESTO' 
                                   ' NRO: ' NOV-NRO-DOC 
                          MOVE 'NO' TO WS-REG-VALIDO 
                          ADD 1 TO WS-CANT-ERRONEOS 
                       END-IF 
                     ELSE 
                        IF FECHA-DIA < 1 OR FECHA-DIA > 28 
                            DISPLAY '----------------------------' 
                            DISPLAY 'FEBRERO INVÁLIDO' 
                                     ' NRO: ' NOV-NRO-DOC 
                            MOVE 'NO' TO WS-REG-VALIDO 
                            ADD 1 TO WS-CANT-ERRONEOS 
                        END-IF 
                     END-IF 
                  WHEN OTHER 
                     DISPLAY '----------------------------' 
                     DISPLAY 'MES INVÁLIDO NRO: ' NOV-NRO-DOC 
                     MOVE 'NO' TO WS-REG-VALIDO 
                     ADD 1 TO WS-CANT-ERRONEOS 
               END-EVALUATE 
           END-IF. 

       2010-VERIF-FECHA-F. EXIT. 


 
      *--------------------------------------------------------------- 
       2100-LEER-I. 

           READ ENTRADA  INTO WS-REG-NOVCLIE 
 
           EVALUATE FS-ENTRADA 
              WHEN '00' 
                 ADD 1 TO WS-CANT-LEIDOS 
              WHEN '10' 
                 CONTINUE 
              WHEN OTHER 
                 DISPLAY '* ERROR EN LECTURA = ' FS-ENTRADA 
                 MOVE 9999 TO RETURN-CODE 
                 SET FS-ENTRADA-FIN  TO TRUE 
           END-EVALUATE. 

       2100-LEER-F. EXIT. 


 
      *---- GRABAR REGISTRO ------------------------------------------
       2200-GRABAR-REG. 

           ADD 1 TO NOV-SECUEN 
           MOVE WS-REG-NOVCLIE TO NOV-RESTO 
           WRITE REG-SALIDA FROM REG-NOVCLIE-VAL 
 
           EVALUATE FS-SALIDA 
              WHEN '00' 
                 ADD 1 TO WS-CANT-GRABADOS 
                 DISPLAY '----------------------------' 
                 DISPLAY 'REGISTRO VALIDADO OK - DOC: ' NOV-TIP-DOC 
                                               ' NRO: ' NOV-NRO-DOC 
              WHEN '10' 
                 CONTINUE 
              WHEN OTHER 
                 DISPLAY '* ERROR EN GRABAR REGISTRO = ' FS-SALIDA 
                 MOVE 9999 TO RETURN-CODE 
                 SET FS-ENTRADA-FIN  TO TRUE 
           END-EVALUATE. 

       2200-GRABAR-REG-F. EXIT. 


 
      *--------------------------------------------------------------- 
       3000-FINAL-I. 

           IF RETURN-CODE NOT EQUAL 9999 
            PERFORM  3010-CLOSE-FILES      THRU  3010-CLOSE-FILES-F 
            PERFORM  3020-MOSTRAR-TOTALES  THRU  3020-MOSTRAR-TOTALES-F 
           END-IF. 
           
       3000-FINAL-F. EXIT. 


      *--------------------------------------------------------------- 
       3010-CLOSE-FILES. 

           CLOSE ENTRADA 
           IF FS-ENTRADA  IS NOT EQUAL '00' 
              DISPLAY '* ERROR EN CLOSE SUCURSAL = ' FS-ENTRADA 
              MOVE 9999 TO RETURN-CODE 
           END-IF 
                                                                     
           CLOSE SALIDA 
           IF FS-SALIDA   IS NOT EQUAL '00' 
              DISPLAY '* ERROR EN CLOSE = ' FS-SALIDA 
              MOVE 9999 TO RETURN-CODE 
           END-IF. 

       3010-CLOSE-FILES-F. EXIT. 

 
      *--------------------------------------------------------------- 
       3020-MOSTRAR-TOTALES. 
       
           DISPLAY '==============================' 
           DISPLAY ' TOTAL DE ENTRADAS LEIDAS '     WS-CANT-LEIDOS 
           DISPLAY ' TOTAL DE REGISTROS GRABADOS  ' WS-CANT-GRABADOS 
           DISPLAY ' TOTAL DE REGISTROS ERRÓNEOS  ' WS-CANT-ERRONEOS. 

       3020-MOSTRAR-TOTALES-F. EXIT. 