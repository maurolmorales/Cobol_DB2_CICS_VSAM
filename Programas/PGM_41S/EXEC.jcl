//KC03CAFJ JOB CLASS=A,MSGCLASS=O,MSGLEVEL=(1,1),NOTIFY=&SYSUID, 
//             TIME=(,3) ,RESTART=STEP2 
//JOBLIB   DD DSN=DSND10.SDSNLOAD,DISP=SHR 
//         DD DSN=KC03CAF.CURSOS.PGMLIB,DISP=SHR 
//*----------------------------------------------------------------* 
//*  PASO OPCIONAL: BORRADO DE ARCHIVOS CON IDCAMS                 * 
//*----------------------------------------------------------------* 
//STEP1    EXEC PGM=IDCAMS,COND=(8,LT) 
//SYSPRINT DD SYSOUT=* 
//SYSIN    DD * 
  DELETE   KC03CAF.ARCHIVOS.ERRORES 
  SET MAXCC=0 
/* 
//*************************************************************** 
//*      EJECUTAR PROGRAMA COBOL CON SQL EMBEBIDO               * 
//*************************************************************** 
//* 
//STEP2    EXEC PGM=IKJEFT01,DYNAMNBR=20,COND=(4,LT) 
//SYSTSPRT DD SYSOUT=* 
//DDENTRA  DD DSN=KC03CAF.ARCHIVOS.NOVECLIE,DISP=SHR 
//DDSALID  DD DSN=KC03CAF.ARCHIVOS.ERRORES,UNIT=SYSDA, 
//            DCB=(LRECL=133,BLKSIZE=1330,RECFM=FB), 
//            SPACE=(TRK,(1,1),RLSE),DISP=(,CATLG,CATLG) 
//SYSOUT   DD DSN=KC03CAF.SYSOUT,DISP=SHR 
//SYSTSIN  DD * 
  DSN SYSTEM(DBDG) 
  RUN  PROGRAM(PGMD1CAF) PLAN(CURSOCAF) + 
      LIB('KC03CAF.CURSOS.PGMLIB') 
  END 
//SYSPRINT DD SYSOUT=* 
//SYSUDUMP DD SYSOUT=* 
//SYSIN    DD * 
//* 
// 