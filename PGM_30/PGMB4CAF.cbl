       IDENTIFICATION DIVISION. 
       PROGRAM-ID. PGMB4CAF. 
      **************************************************************
      *                                                            * 
      *    PROGRAMA EJERCICIO CLASE 30                             *
      *    - ABRE EL ARCHIVO DE NOVEDADES (VSAM)                   *
      *    - CONSULTA SI YA EXISTE EN DB2                          *
      *    - MODIFICA LA FECHA DE NACIMIENTO LLAMANDO MEDIANTE     *
      *    UNA LLAMADA DINÁMICA CALL PRARA QUE DEVUELTA LA FECHA   *
      *    CON UN MES MENOS.                                       *
      *    - HACE EL INSERT EN DB2                                 *
      *                                                            * 
      **************************************************************
  
      *|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       ENVIRONMENT DIVISION. 
       CONFIGURATION SECTION. 
  
       SPECIAL-NAMES. 
           DECIMAL-POINT IS COMMA. 
  
       INPUT-OUTPUT SECTION. 
       FILE-CONTROL. 
           SELECT NOVEDADES ASSIGN TO DDENTRA 
           ORGANIZATION IS INDEXED 
           ACCESS       IS SEQUENTIAL 
           RECORD KEY   IS FS-KEY 
           FILE STATUS  IS FS-NOVEDADES. 
  
      *|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       DATA DIVISION. 
       FILE SECTION. 
  
       FD  NOVEDADES. 
       01  FS-DATA. 
           05 FS-KEY                     PIC X(17). 
           05 FS-DESC                    PIC X(227). 

  
       WORKING-STORAGE SECTION. 
      *=======================* 
  
      *----------- ARCHIVOS ------------------------------------------ 
       77  FS-NOVEDADES            PIC XX         VALUE SPACES. 
       77  WS-STATUS-FIN           PIC X. 
           88  WS-FIN-LECTURA                     VALUE 'Y'. 
           88  WS-NO-FIN-LECTURA                  VALUE 'N'. 
           
       77  WS-PGMRUT               PIC X(8)       VALUE 'PGMRUCAF'. 
       77  NOT-FOUND               PIC S9(9) COMP VALUE  +100. 
       77  NOTFOUND-FORMAT         PIC -ZZZZZZZZZZ. 
  
      *----------- VARIABLES  ---------------------------------------- 
       77  WS-NOMAPE-COMPLETO      PIC X(62). 
       77  WS-FECHA-COMPUESTA      PIC X(10). 
  
       01  FECHA-MODIF. 
           03  FM-ANIO      PIC 9(4). 
           03  FM-SEP1      PIC X VALUE '-'. 
           03  FM-MES       PIC 9(2). 
           03  FM-SEP2      PIC X VALUE '-'. 
           03  FM-DIA       PIC 9(2). 
  
      *----------- ACUMULADORES -------------------------------------- 
       77  WS-NOVE-LEIDAS-CANT     PIC 999        VALUE ZEROES. 
       77  WS-NOVE-INSERT-CANT     PIC 999        VALUE ZEROES. 
       77  WS-NOVE-ERRONEA-CANT    PIC 999        VALUE ZEROES. 
  
      *----------- SQL ---------------------------------------------- 
       77  WS-SQLCODE     PIC +++999 USAGE DISPLAY VALUE ZEROS. 
       77  REG-SALDO      PIC -Z(09).99           VALUE ZEROES. 
       77  REG-TIPCUEN    PIC Z9                  VALUE ZEROES. 
       77  REG-NROCUEN    PIC 9(05)               VALUE ZEROES. 
       77  REG-SUCUEN     PIC 99                  VALUE ZEROES. 

  
      *      EXEC SQL INCLUDE SQLCA    END-EXEC. 
      *      EXEC SQL INCLUDE TBCURCLI END-EXEC. 
      *      COPY TBVCLIEN. 
      

      *##############################################################
      *     EXEC SQL INCLUDE TBCURCLI END-EXEC. 
            EXEC SQL DECLARE KC02787.TBCURCLI TABLE 
           ( TIPDOC                         CHAR(2) NOT NULL, 
             NRODOC                         DECIMAL(11, 0) NOT NULL, 
             NROCLI                         DECIMAL(3, 0) NOT NULL, 
             NOMAPE                         CHAR(30) NOT NULL, 
             FECNAC                         DATE NOT NULL, 
             SEXO                           CHAR(1) NOT NULL 
           ) END-EXEC. 
      ******************************************************************
      * COBOL DECLARATION FOR TABLE KC02787.TBCURCLI                   *
      ******************************************************************
       01  DCLTBCURCLI. 
           10 WSC-TIPDOC      PIC X(2).                 *> TIPDOC
           10 WSC-NRODOC      PIC S9(11)V USAGE COMP-3. *> NRODOC
           10 WSC-NROCLI      PIC S9(3)V USAGE COMP-3.  *> NROCLI
           10 WSC-NOMAPE      PIC X(30).                *> NOMAPE
           10 WSC-FECNAC      PIC X(10).                *> FECNAC
           10 WSC-SEXO        PIC X(1).                 *> FECNAC

      *           COPY TBVCLIEN. 
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
      *##############################################################
  
      *--------------------------------------------------------------- 
       LINKAGE SECTION. 
       01  LK-COMUNICACION. 
           03 LK-SIGLO    PIC 99. 
           03 LK-ANIO     PIC 99. 
           03 LK-MES      PIC 99. 
           03 LK-DIA      PIC 99. 
           03 FILLER      PIC X(22). 

       77  FILLER PIC X(26) VALUE '* FINAL  WORKING-STORAGE *'. 
  
  
      *|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       PROCEDURE DIVISION USING LK-COMUNICACION. 
  
       MAIN-PROGRAM-I. 
  
           PERFORM 1000-INICIO-I  THRU 1000-INICIO-F. 
           PERFORM 2000-PROCESO-I THRU 2000-PROCESO-F 
                                  UNTIL WS-FIN-LECTURA. 
           PERFORM 9999-FINAL-I   THRU 9999-FINAL-F. 
  
       MAIN-PROGRAM-F. GOBACK. 
  
  
      *-------------------------------------------------------------- 
       1000-INICIO-I. 
  
           OPEN INPUT NOVEDADES. 
           SET WS-NO-FIN-LECTURA TO TRUE. 
           DISPLAY "PRUEBA 1"
  
           IF FS-NOVEDADES IS NOT EQUAL '00' 
             DISPLAY '* ERROR EN OPEN ENTRADA INICIO = ' FS-NOVEDADES 
             SET  WS-FIN-LECTURA TO TRUE 
             MOVE 3333 TO RETURN-CODE
             PERFORM 9999-FINAL-I THRU 9999-FINAL-F 
           END-IF. 
           
       1000-INICIO-F. EXIT. 
  
  
      *------------------------------------------------------------- 
       2000-PROCESO-I. 
  
           PERFORM 2100-LEER-I THRU 2100-LEER-F. 
  
           IF FS-NOVEDADES IS EQUAL '00' THEN 
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
                 SELECT TIPDOC INTO :WSC-TIPDOC 
                 FROM  KC02787.TBCURCLI 
                 WHERE TIPDOC = :WSC-TIPDOC 
                 AND   NRODOC = :WSC-NRODOC 
              END-EXEC 
  
              IF SQLCODE = 0 THEN 
                 DISPLAY 'REGISTRO YA EXISTENTE: ' WSC-TIPDOC 
                                               ' ' WSC-NRODOC 
              ELSE 
                 IF SQLCODE = NOT-FOUND THEN 
  
                 PERFORM 2200-DESCOM-FECHA-I 
                    THRU 2200-DESCOM-FECHA-F 
  
                 CALL WS-PGMRUT USING LK-COMUNICACION 
  
                 PERFORM 2210-COMPONER-FECHA-I 
                    THRU 2210-COMPONER-FECHA-F 
  
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
  
                    IF SQLCODE = 0 THEN 
                       ADD 1 TO WS-NOVE-INSERT-CANT 
                       DISPLAY "REGISTRO INGRESADO OK"
                    ELSE 
                       MOVE SQLCODE TO NOTFOUND-FORMAT 
                       DISPLAY 'ERROR INSERT = ' NOTFOUND-FORMAT 
                       ADD 1 TO WS-NOVE-ERRONEA-CANT 
                    END-IF 
                    DISPLAY "---------------------------------"
              END-IF 
           END-IF. 
  
       2000-PROCESO-F. EXIT. 
  
      *-------------------------------------------------------------- 
       2100-LEER-I. 
  
           READ NOVEDADES INTO WK-TBCLIE 
  
           EVALUATE FS-NOVEDADES 
              WHEN '00' 
                 ADD 1 TO WS-NOVE-LEIDAS-CANT 
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
       2200-DESCOM-FECHA-I. 
  
           MOVE WSC-FECNAC     TO FECHA-MODIF. 
           MOVE FECHA-MODIF    TO LK-COMUNICACION. 
           MOVE FM-MES         TO LK-MES. 
           MOVE FM-DIA         TO LK-DIA. 

           DISPLAY " "    
           DISPLAY "FECHA ENTRADA:   " WSC-FECNAC. 
  
       2200-DESCOM-FECHA-F. EXIT. 

  
      *-------------------------------------------------------------- 
       2210-COMPONER-FECHA-I. 
  
           MOVE LK-COMUNICACION TO FECHA-MODIF. 
           MOVE LK-MES          TO FM-MES. 
           MOVE LK-DIA          TO FM-DIA. 
           MOVE '-'             TO FM-SEP1. 
           MOVE '-'             TO FM-SEP2. 
           MOVE FECHA-MODIF     TO WS-FECHA-COMPUESTA. 

           DISPLAY "FECHA COMPUESTA: " WS-FECHA-COMPUESTA. 

       2210-COMPONER-FECHA-F. EXIT. 

  
      *-------------------------------------------------------------- 
       9999-FINAL-I. 
  
           DISPLAY "TOTAL DE REGISTROS: " WS-NOVE-LEIDAS-CANT 
           DISPLAY "TOTAL DE GRABADOS: " WS-NOVE-INSERT-CANT 
           DISPLAY "TOTAL DE ERRORES: " WS-NOVE-ERRONEA-CANT 
           EXEC SQL ROLLBACK   END-EXEC. 
  
           CLOSE NOVEDADES 
           IF FS-NOVEDADES  IS NOT EQUAL '00' 
              DISPLAY '* ERROR EN CLOSE ENTRADA = ' FS-NOVEDADES 
              MOVE 9999 TO RETURN-CODE 
              SET WS-FIN-LECTURA TO TRUE 
           END-IF. 
  
       9999-FINAL-F. EXIT.  