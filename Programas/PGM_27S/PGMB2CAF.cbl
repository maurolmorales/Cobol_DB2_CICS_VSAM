       IDENTIFICATION DIVISION. 
       PROGRAM-ID. PGMB2CAF. 

      ***************************************************************
      *                   CLASE SINCRÓNICA 27                       *
      *                   ===================                       *
      *  Construir un programa COBOL que utilice SQL embebido       *
      *  (Embedded SQL) para interactuar con tablas DB2.            *
      *  Leer registros desde el archivo VSAM de novedades validadas*
      *  de clientes NOVECLI.KSDS.VSAM, con layout TBVCLIEN         *
      *  (244 bytes, clave primaria de 17 bytes desde la posición 1)*
      *  Por cada registro leído, realizar un INSERT en la tabla    *
      *  TBCURCLI.                                                  *
      *  Manejar errores SQL:                                       *
      *  - Si ocurre clave duplicada, mostrar el registro como      *
      *    erróneo y continuar el proceso.                          *
      *  Completar en el INSERT todos los campos/columnas requeridos*
      *  por la tabla DB2 a partir del contenido del archivo.       *
      *  Al finalizar, mostrar por DISPLAY:                         *
      *  - Total de novedades leídas.                               *
      *  - Total de novedades insertadas correctamente.             *
      *  - Total de novedades erróneas (por ejemplo, por clave      *
      *    duplicada).                                              *
      ***************************************************************

      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  
       ENVIRONMENT DIVISION. 
       INPUT-OUTPUT SECTION. 
  
       FILE-CONTROL. 
           SELECT NOVEDADES ASSIGN TO DDENTRA 
           ORGANIZATION IS INDEXED 
           ACCESS       IS SEQUENTIAL 
           RECORD KEY   IS FS-KEY 
           FILE STATUS  IS FS-NOVEDADES. 
  
      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
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
       77  WS-REG-SALIDA           PIC X(244). 
  
       01  WS-NOMAPE-COMPLETO. 
           05 WS-NOMAPE-NOMBRE     PIC X(15). 
           05 WS-NOMAPE-APELLIDO   PIC X(15). 

      *-----------  SQL  --------------------------------------------- 
       77  WS-SQLCODE         PIC +++999 USAGE DISPLAY  VALUE ZEROS. 
       77  NOT-FOUND               PIC S9(9) COMP       VALUE  +100. 
       77  NOTFOUND-FORMAT         PIC -ZZZZZZZZZZ. 

      *-----------  VARIABLES  ---------------------------------------  
       77  REG-TIPDOC        PIC X(2)                   VALUE SPACES.
       77  REG-NRODOC        PIC S9(11)V USAGE COMP-3   VALUE ZEROES.
       77  REG-NROCLI        PIC S9(3)V USAGE COMP-3    VALUE ZEROES.
       77  REG-NOMAPE        PIC X(30)                  VALUE SPACES.
       77  REG-FECNAC        PIC X(10)                  VALUE SPACES.
       77  REG-SEXO          PIC X(1)                   VALUE SPACES.
  
      *---- SQLCA COMMUNICATION AREA CON EL DB2  --------------------- 
           EXEC SQL INCLUDE SQLCA    END-EXEC. 
      *     EXEC SQL INCLUDE TBCURCLI END-EXEC. 
      *     COPY TBVCLIEN. 

      *///////////////////////////////////////////////////////////////
       01  DCLTBCURCLI. 
           10 CLI-TIPDOC      PIC X(2).                 *> TIPDOC
           10 CLI-NRODOC      PIC S9(11)V USAGE COMP-3. *> NRODOC
           10 CLI-NROCLI      PIC S9(3)V USAGE COMP-3.  *> NROCLI
           10 CLI-NOMAPE      PIC X(30).                *> NOMAPE
           10 CLI-FECNAC      PIC X(10).                *> FECNAC
           10 CLI-SEXO        PIC X(1).                 *> FECNAC

      *    TBVCLIEN (NOVEDADES)
      *    COPY DE ARCHIVO DE NOVEDADES VALIDADAS CLIENTES VSAM       
      *    LARGO REGISTRO 244 BYTES                                   
      *    KEY (1,17)                                                
      *    TIPO_NOVEDAD; TIPO_DOCUMENTO; NRO_DOCUMENTO; NRO_SECUENCIA
      *    INTEGRIDAD REFERENCIAL CON CUENTAS A TRAVÉS NRO CLIENTE
       01  WK-TBCLIE. 
           10 WK-CLI-TIPO-NOVEDAD        PIC X(2). 
           10 WK-CLI-TIPO-DOCUMENTO      PIC X(2). 
           10 WK-CLI-NRO-DOCUMENTO       PIC 9(11). 
           10 WK-CLI-NRO-SEC             PIC 9(2). 
           10 WK-CLI-NRO-CLIENTE         PIC 9(5). 
           10 WK-CLI-NOMBRE-CLIENTE      PIC X(30). 
           10 WK-CLI-APELLIDO-CLIENTE    PIC X(30). 
           10 WK-CLI-DOMICILIO           PIC X(30). 
           10 WK-CLI-CIUDAD              PIC X(30). 
           10 WK-CLI-CODIGO-POSTAL       PIC X(8). 
           10 WK-CLI-NACIONALIDAD        PIC X(30). 
           10 WK-CLI-FECHA-DE-ALTA       PIC X(10). 
           10 WK-CLI-FECHA-DE-BAJA       PIC X(10). 
           10 WK-CLI-ESTADO-CIVIL        PIC X(2). 
           10 WK-CLI-SEXO                PIC X(2). 
           10 WK-CLI-CORREO-ELECTRONICO  PIC X(30). 
           10 WK-CLI-FECHA-NACIMIENTO    PIC X(10). 
      *//////////////////////////////////////////////////////////////

  
       77  FILLER        PIC X(26) VALUE '* FINAL  WORKING-STORAGE *'. 
  
      *|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       PROCEDURE DIVISION. 
  
      *-------------------------------------------------------------
       0000-MAIN-PROCESS-I. 
  
           PERFORM 1000-INICIO-I  THRU 1000-INICIO-F. 
           PERFORM 2000-PROCESO-I THRU 2000-PROCESO-F 
                                  UNTIL WS-FIN-LECTURA. 
           PERFORM 9999-FINAL-I THRU 9999-FINAL-F. 

       0000-MAIN-PROCESS-F. GOBACK. 
  
  
      *-------------------------------------------------------------
       1000-INICIO-I. 
  
           OPEN INPUT NOVEDADES. 
           SET WS-NO-FIN-LECTURA TO TRUE. 
  
           IF FS-NOVEDADES IS NOT EQUAL '00' THEN 
              DISPLAY '* ERROR EN OPEN ENTRADA INICIO = ' FS-NOVEDADES 
              MOVE 9999 TO RETURN-CODE 
              SET  WS-FIN-LECTURA TO TRUE 

              PERFORM 9999-FINAL-I THRU 9999-FINAL-F 
           END-IF. 
  
       1000-INICIO-F. EXIT. 
  
  
      *-------------------------------------------------------------- 
       2000-PROCESO-I. 
  
           PERFORM 2100-LEER-I THRU 2100-LEER-F. 
  
           IF FS-NOVEDADES IS EQUAL '00' THEN
           
      *       para unir el nombre con el apellido.                                                                  
              MOVE SPACES TO WS-NOMAPE-COMPLETO 
              STRING 
               WK-CLI-NOMBRE-CLIENTE DELIMITED BY SPACE 
               ', ' DELIMITED BY SIZE 
               WK-CLI-APELLIDO-CLIENTE DELIMITED BY SPACE 
               INTO WS-NOMAPE-COMPLETO 
  
  
              MOVE WK-CLI-TIPO-DOCUMENTO     TO REG-TIPDOC 
              MOVE WK-CLI-NRO-DOCUMENTO      TO REG-NRODOC 
              MOVE WK-CLI-NRO-CLIENTE        TO REG-NROCLI 
              MOVE WS-NOMAPE-COMPLETO        TO REG-NOMAPE 
              MOVE WK-CLI-FECHA-NACIMIENTO   TO REG-FECNAC 
              MOVE WK-CLI-SEXO               TO REG-SEXO 
  
              DISPLAY "-> TIPDOC: " REG-TIPDOC 
              DISPLAY "-> NRODOC: " REG-NRODOC 
              DISPLAY "-> NROCLI: " REG-NROCLI 
              DISPLAY "-> NOMAPE: " REG-NOMAPE 
              DISPLAY "-> FECNAC: " REG-FECNAC 
              DISPLAY "-> SEXO:   " REG-SEXO 
  
              EXEC SQL 
                 INSERT INTO KC02803.TBCURCLI 
                    ( TIPDOC, 
                      NRODOC, 
                      NROCLI, 
                      NOMAPE, 
                      FECNAC, 
                      SEXO ) 
                 VALUES ( 
                      :REG-TIPDOC, 
                      :REG-NRODOC, 
                      :REG-NROCLI, 
                      :REG-NOMAPE, 
                      :REG-FECNAC, 
                      :REG-SEXO 
                    ) 
              END-EXEC

      *       EXEC SQL 
      *          DELETE FROM KC02803.TBCURCLI 
      *                 WHERE NRODOC = :REG-NRODOC 
      *       END-EXEC 
  
              IF SQLCODE = NOT-FOUND THEN
                 MOVE SQLCODE TO NOTFOUND-FORMAT
                 DISPLAY 'PROYECTO VACíO: ' NOTFOUND-FORMAT
              ELSE 
                 IF SQLCODE = 0 THEN
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
           IF FS-NOVEDADES IS NOT EQUAL '00' THEN
              DISPLAY '* ERROR EN CLOSE ENTRADA = ' FS-NOVEDADES 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-LECTURA TO TRUE 
           END-IF. 
  
       9999-FINAL-F.  EXIT.                              