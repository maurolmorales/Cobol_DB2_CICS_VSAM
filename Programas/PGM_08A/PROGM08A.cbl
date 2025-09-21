       IDENTIFICATION DIVISION. 
       PROGRAM-ID. PROGM08A. 
      ***************************************************************
      *    CLASE 8 ASINCRÓNICA                                      *
      *    ===================                                      *
      *    - Construir un programa COBOL que valide registros       *
      *      leídos desde un archivo de novedades de clientes.      *
      *    - Validar:                                               *
      *    - Campos numéricos y fechas, incluyendo lógica de fechas *
      *      válidas (meses, días, años bisiestos, etc.).           *
      *    - Que fecha de nacimiento tenga un año menor al actual.  *
      *    - Formatear con espacios las fechas de alta y baja si    *
      *      están vacías.                                          *
      *    - En caso de errores:                                    *
      *    - Mostrar por DISPLAY los campos tipo y número de        *
      *      documento junto con el detalle de cada error encontrado*
      *    - Si el registro es válido:                              *
      *    - Grabarlo en un archivo de novedades validadas,         *
      *      agregando número de secuencia según el orden de ingreso*
      *    - Al finalizar, mostrar por DISPLAY:                     *
      *    - Total de novedades leídas.                             *
      *    - Total de novedades con errores.                        *
      *    - Total de registros grabados correctamente.             *
      ***************************************************************
      
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
      
      *---- MENSAJE DE ERROR  ----------------------------------------
       77  WS-MESSAGE-ERROR           PIC X(32)   VALUE SPACES.
      
      *---- MENSAJE DE ERROR  ----------------------------------------
       77  WS-CANT-NUM-PRINT          PIC ZZ9.
      
      *//// COPY PARA ESTRUCTURA DE DATOS ////////////////////////////
      
      *    COPY CPNOVCLI. 
      *    LAYOUT NOVEDAD CLIENTES
      *    KC02788.ALU9999.NOVCLIEN
      *    LARGO 50 BYTES
       01  WS-REG-NOVCLIE. 
      * VALIDOS  DU - PA - PE - CI         * 
           03  NOV-TIP-DOC         PIC X(02)    VALUE SPACES. 
           03  NOV-NRO-DOC         PIC 9(11)    VALUE ZEROS. 
      * VALIDOS  NRO SUCURSAL ENTRE 1 Y 99 
           03  NOV-SUC             PIC 9(02)    VALUE ZEROS. 
      * VALIDOS  TIPO CUENTA 01 = CUENTAS CORRIENTES 
      *          TIPO CUENTA 02 = CAJA DE AHORROS 
      *          TIPO CUENTA 03 = PLAZO FIJO 
           03  NOV-CLI-TIPO        PIC 9(02)    VALUE ZEROS. 
           03  NOV-CLI-NRO         PIC 9(03)    VALUE ZEROS. 
           03  NOV-CLI-IMP         PIC S9(09)V99 COMP-3 VALUE ZEROS. 
      * FORMATO NOV-CLI-FECHA (AAAAMMDD) 
      *      AAAA = AñO 
      *      MM = MES 
      *      DD  = DIA 
      * VALIDOS  ENTRE DIA 1 Y 31 DEL AñO (SEGúN MES) 
      *          CONSIDERAR 29 FEBRERO (BISIESTO) 
      *          AñO NUMéRICO, MAYOR A 2024 
           03  NOV-CLI-FECHA       PIC X(8)             VALUE ZEROS. 
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
           IF FS-ENTRADA IS NOT EQUAL '00' THEN
              DISPLAY '* ERROR EN OPEN SUCURSAL= ' FS-ENTRADA 
              MOVE 9999 TO RETURN-CODE 
              SET  FS-ENTRADA-FIN TO TRUE 
           ELSE 
              PERFORM 2100-LEER-I  THRU 2100-LEER-F 
           END-IF 
      
           OPEN OUTPUT SALIDA 
           IF FS-SALIDA IS NOT EQUAL '00' THEN
              DISPLAY '* ERROR EN OPEN SALIDA = ' FS-SALIDA 
              MOVE 9999 TO RETURN-CODE 
              SET  FS-ENTRADA-FIN TO TRUE 
           END-IF. 
      
       1000-INICIO-F. EXIT. 
      
      
      *--------------------------------------------------------------- 
       2000-PROCESO-I. 
              
           PERFORM 2010-VERIFICAR-I THRU 2010-VERIFICAR-F
           PERFORM 2100-LEER-I THRU 2100-LEER-F. 
      
       2000-PROCESO-F. EXIT. 
      
      
      *--------------------------------------------------------------- 
       2010-VERIFICAR-I. 
      
           MOVE 'SI' TO WS-REG-VALIDO 
      
           IF NOV-TIP-DOC = 'DU' OR 
              NOV-TIP-DOC = 'PA' OR 
              NOV-TIP-DOC = 'PE' OR 
              NOV-TIP-DOC = 'CI' THEN
              CONTINUE 
           ELSE
              MOVE 'TIPO DOC NO VALIDO' TO WS-MESSAGE-ERROR
              PERFORM 2025-HANDLE-ERROR-I 
                 THRU 2025-HANDLE-ERROR-F
           END-IF
      
           IF NOV-NRO-DOC IS NOT NUMERIC THEN
              MOVE 'NUMDOC NO ES NUMÉRICO' TO WS-MESSAGE-ERROR
              PERFORM 2025-HANDLE-ERROR-I 
                 THRU 2025-HANDLE-ERROR-F              
           END-IF 
      
           IF NOV-SUC = 01 OR 
              NOV-SUC = 02 OR 
              NOV-SUC = 03 THEN
              CONTINUE 
           ELSE
              MOVE 'NOVSUC NO CORRESPONDE' TO WS-MESSAGE-ERROR
              PERFORM 2025-HANDLE-ERROR-I 
                 THRU 2025-HANDLE-ERROR-F              
           END-IF
      
           PERFORM 2020-VERIF-FECHA THRU 2020-VERIF-FECHA-F 
      
           IF WS-REG-VALIDO = 'SI' THEN
              PERFORM 2200-GRABAR-REG THRU 2200-GRABAR-REG-F 
           ELSE 
              ADD 1 TO WS-CANT-ERRONEOS
           END-IF.
      
       2010-VERIFICAR-F. EXIT.
      
      *--------------------------------------------------------------- 
       2020-VERIF-FECHA. 
      
           MOVE NOV-CLI-FECHA TO WS-FECHA 
      
           IF FECHA-ANIO < 2025 THEN
              MOVE 'AÑO INVÁLIDO < 2025' TO WS-MESSAGE-ERROR 
              PERFORM 2025-HANDLE-ERROR-I 
                 THRU 2025-HANDLE-ERROR-F   
           END-IF 
      
           IF FECHA-MES < 1 OR FECHA-MES > 12 THEN
              MOVE 'MES FUERA DE RANGO' TO WS-MESSAGE-ERROR 
              PERFORM 2025-HANDLE-ERROR-I 
                 THRU 2025-HANDLE-ERROR-F                
           ELSE 
               EVALUATE FECHA-MES 
                  WHEN 1 
                  WHEN 3 
                  WHEN 5 
                  WHEN 7 
                  WHEN 08 
                  WHEN 10 
                  WHEN 12 
                     IF FECHA-DIA < 1 OR FECHA-DIA > 31 THEN
                       MOVE 'DÍA INVÁLIDO PARA MES DE 31 DÍAS' 
                         TO WS-MESSAGE-ERROR         
                       PERFORM 2025-HANDLE-ERROR-I 
                          THRU 2025-HANDLE-ERROR-F                          
                     END-IF 
                  WHEN 4 
                  WHEN 6 
                  WHEN 9 
                  WHEN 11 
                        IF FECHA-DIA < 1 OR FECHA-DIA > 30 THEN
                          MOVE 'DÍA INVÁLIDO PARA MES DE 30 DÍAS' 
                            TO WS-MESSAGE-ERROR 
                          PERFORM 2025-HANDLE-ERROR-I 
                             THRU 2025-HANDLE-ERROR-F 
                        END-IF 
                  WHEN 2 
                    IF (FECHA-ANIO / 4) * 4 = FECHA-ANIO AND 
                       (FECHA-ANIO / 100) * 100 NOT = FECHA-ANIO 
                       OR (FECHA-ANIO / 400) * 400 = FECHA-ANIO THEN
                       IF FECHA-DIA < 1 OR FECHA-DIA > 29 THEN
                          MOVE 'FEBRERO INVÁLIDO EN BISIESTO' 
                            TO WS-MESSAGE-ERROR 
                          PERFORM 2025-HANDLE-ERROR-I 
                             THRU 2025-HANDLE-ERROR-F          
                       END-IF 
                     ELSE 
                       IF FECHA-DIA < 1 OR FECHA-DIA > 28 THEN
                          MOVE 'FEBRERO INVÁLIDO' TO WS-MESSAGE-ERROR 
                          PERFORM 2025-HANDLE-ERROR-I 
                             THRU 2025-HANDLE-ERROR-F                           
                        END-IF 
                     END-IF 
                  WHEN OTHER 
                     MOVE 'MES INVÁLIDO DEFAULT' TO WS-MESSAGE-ERROR 
                     PERFORM 2025-HANDLE-ERROR-I 
                        THRU 2025-HANDLE-ERROR-F 
               END-EVALUATE 
           END-IF. 
      
       2020-VERIF-FECHA-F. EXIT. 
      
      
      *--------------------------------------------------------------- 
       2025-HANDLE-ERROR-I. 
      
           MOVE 'NO' TO WS-REG-VALIDO 
           DISPLAY '----------------------------' 
           DISPLAY  ' REGISTRO INVÁLIDO: ' NOV-TIP-DOC 
                    ' NRO: ' NOV-NRO-DOC 
                    ' CAUSA: ' WS-MESSAGE-ERROR. 
      
       2025-HANDLE-ERROR-F. EXIT.
      
      
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
      
           MOVE WS-CANT-LEIDOS TO NOV-SECUEN 
           MOVE WS-REG-NOVCLIE TO NOV-RESTO 
           WRITE REG-SALIDA FROM REG-NOVCLIE-VAL 
      
           EVALUATE FS-SALIDA 
              WHEN '00' 
                 ADD 1 TO WS-CANT-GRABADOS 
                 DISPLAY '----------------------------' 
                 DISPLAY 'REGISTRO OK - DOC: ' NOV-TIP-DOC 
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
      
           IF RETURN-CODE NOT EQUAL 9999 THEN
              PERFORM  3010-CLOSE-FILES 
                 THRU  3010-CLOSE-FILES-F 
              PERFORM  3020-MOSTRAR-TOTALES
                 THRU  3020-MOSTRAR-TOTALES-F 
           END-IF. 
              
       3000-FINAL-F. EXIT. 
      
      
      *--------------------------------------------------------------- 
       3010-CLOSE-FILES. 
      
           CLOSE ENTRADA 
           IF FS-ENTRADA  IS NOT EQUAL '00' THEN
              DISPLAY '* ERROR EN CLOSE SUCURSAL = ' FS-ENTRADA 
              MOVE 9999 TO RETURN-CODE 
           END-IF 
      
           CLOSE SALIDA 
           IF FS-SALIDA   IS NOT EQUAL '00' THEN
              DISPLAY '* ERROR EN CLOSE = ' FS-SALIDA 
              MOVE 9999 TO RETURN-CODE 
           END-IF. 
      
       3010-CLOSE-FILES-F. EXIT. 
      
      
      *--------------------------------------------------------------- 
       3020-MOSTRAR-TOTALES. 
           
           DISPLAY '==============================' 
      
           MOVE WS-CANT-LEIDOS TO WS-CANT-NUM-PRINT
           DISPLAY ' TOTAL DE ENTRADAS LEIDAS:    ' WS-CANT-NUM-PRINT 
      
           MOVE WS-CANT-GRABADOS TO WS-CANT-NUM-PRINT
           DISPLAY ' TOTAL DE REGISTROS GRABADOS: ' WS-CANT-NUM-PRINT 
      
           MOVE WS-CANT-ERRONEOS TO WS-CANT-NUM-PRINT
           DISPLAY ' TOTAL DE REGISTROS ERRÓNEOS: ' WS-CANT-NUM-PRINT. 
      
       3020-MOSTRAR-TOTALES-F. EXIT. 