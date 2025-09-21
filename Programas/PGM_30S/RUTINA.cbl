       IDENTIFICATION DIVISION. 
       PROGRAM-ID. PGMRUCAF. 
      ******************************************************************
      *          PROGRAMA RUTINA PARA EJERCICIO CLASE 30               *
      *                                                                *
      *     - OBTIENE LA FECHA POR LINKAGE                             *
      *     - RESTA 1 AL MES                                           *
      *     - DEVUELVE EL MES MODIFICADO.                              *
      *                                                                *
      ******************************************************************
      
      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
       ENVIRONMENT DIVISION. 
       INPUT-OUTPUT SECTION. 
       FILE-CONTROL.
      
      *||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||  
       DATA DIVISION. 
       FILE SECTION. 
      
       WORKING-STORAGE SECTION. 
      *=======================*
      
       77  FILLER        PIC X(26) VALUE '* INICIO WORKING-STORAGE *'. 
       
        01  WS-RECIBIDO. 
           03  WS-RECI-SIGLO  PIC 99       VALUE ZEROS. 
           03  WS-RECI-ANIO   PIC 99       VALUE ZEROS. 
           03  WS-RECI-MES    PIC 99       VALUE ZEROS. 
           03  WS-RECI-DIA    PIC 99       VALUE ZEROS. 
           03  FILLER         PIC X(22)    VALUE SPACES. 
      
       01  WS-AREA. 
           03  WS-AREA-SIGLO  PIC 99       VALUE ZEROS. 
           03  WS-AREA-ANIO   PIC 99       VALUE ZEROS. 
           03  WS-AREA-MES    PIC 99       VALUE ZEROS. 
           03  WS-AREA-DIA    PIC 99       VALUE ZEROS. 
           03  FILLER         PIC X(22)    VALUE SPACES. 
  
       77  WS-RESULTADO       PIC 9(4)     VALUE ZEROS. 
  
       77  FILLER PIC X(26) VALUE '* FINAL  WORKING-STORAGE *'. 
      
      *-------------------------------------------------------------- 
       LINKAGE SECTION. 
      *================* 
        01 LK-COMUNICACION. 
           03 LK-SIGLO    PIC 99. 
           03 LK-ANIO     PIC 99. 
           03 LK-MES      PIC 99. 
           03 LK-DIA      PIC 99. 
           03 FILLER      PIC X(22). 
      
      *|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
       PROCEDURE DIVISION USING LK-COMUNICACION. 
  
       MAIN-PROGRAM. 
  
           PERFORM 1000-INICIO THRU 1000-INICIO-F 
  
           IF RETURN-CODE = ZEROS THEN
              PERFORM 2000-PROCESO THRU 2000-PROCESO-F 
           END-IF 
  
           PERFORM 9999-FINAL THRU 9999-FINAL-F. 
  
       MAIN-PROGRAM-F. GOBACK. 
      
      *----  CUERPO INICIO INDICES -----------------------------------
       1000-INICIO. 
      
           MOVE ZEROS           TO RETURN-CODE 
           MOVE LK-COMUNICACION TO WS-RECIBIDO
           MOVE LK-SIGLO        TO WS-AREA-SIGLO 
           MOVE LK-ANIO         TO WS-AREA-ANIO 
           MOVE LK-MES          TO WS-AREA-MES 
           MOVE LK-DIA          TO WS-AREA-DIA 
      
           PERFORM 1100-VALIDAR-AREA THRU 1100-VALIDAR-AREA-F. 
      
       1000-INICIO-F. EXIT. 
      
                                                                     
      *---------------------------------------------------------------
       1100-VALIDAR-AREA. 
      
           IF WS-AREA-MES = ZEROS OR 
              WS-AREA-MES > 12    OR
              WS-AREA-ANIO = ZEROS THEN 
                 MOVE 05 TO RETURN-CODE 
           END-IF. 
  
       1100-VALIDAR-AREA-F. EXIT. 
      
      
      *----  CUERPO PRINCIPAL DE PROCESO ----------------------------
       2000-PROCESO. 
      
           IF WS-AREA-MES = 1 THEN
              SUBTRACT 1 FROM WS-AREA-ANIO
              MOVE 12 TO WS-AREA-MES
           ELSE
              SUBTRACT 1 FROM WS-AREA-MES
           END-IF.
  
       2000-PROCESO-F. EXIT. 
  
      *----  CUERPO FINAL MUESTRA RESULTADO -------------------------
       9999-FINAL. 
  
           MOVE WS-AREA TO LK-COMUNICACION 
           DISPLAY "***PGMRUT - CóDIGO DE RETORNO ES   ****** " 
                                     RETURN-CODE 
           DISPLAY "   FECHA RECIBIDA: "  WS-RECIBIDO
           DISPLAY "   FECHA ENVIADA : "  WS-AREA. 
  
       9999-FINAL-F. EXIT. 