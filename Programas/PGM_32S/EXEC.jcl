//KC03CAFD JOB  CLASS=A,MSGCLASS=O,MSGLEVEL=(1,1),NOTIFY=&SYSUID 
//JOBLIB   DD   DSN=DSND10.SDSNLOAD,DISP=SHR 
//         DD   DSN=KC03CAF.CURSOS.PGMLIB,DISP=SHR 
//*************************************************************** 
//*      EJECUTAR PROGRAMA COBOL CON SQL EMBEBIDO               * 
//*************************************************************** 
//*----------------------------------------------------------------* 
//*  BORRADO DE ARCHIVOS CON IDCAMS 
//*----------------------------------------------------------------* 
//STEP1    EXEC PGM=IDCAMS,COND=(8,LT) 
//SYSPRINT DD SYSOUT=* 
//SYSIN    DD * 
  DELETE   KC03CAF.ARCHIVOS.NOVCTA.ORD 
  SET MAXCC=0 
/* 
//*----------------------------------------------------------------* 
//*  SORT DE ARCHIVOS 
//*----------------------------------------------------------------* 
//STEP2    EXEC PGM=SORT,COND=EVEN 
//SYSOUT   DD SYSOUT=* 
//SORTIN   DD DSN=KC03CAF.ARCHIVOS.NOVCTA,DISP=SHR 
//SORTOUT  DD DSN=KC03CAF.ARCHIVOS.NOVCTA.ORD,DISP=(,CATLG), 
//             UNIT=SYSDA,VOL=SER=ZASWO1, 
//             DCB=(LRECL=23,BLKSIZE=27991,RECFM=FB), 
//             SPACE=(TRK,(1,1),RLSE) 
//SYSIN    DD * 
  SORT FORMAT=BI,FIELDS=(1,2,A,3,3,A) 
/* 
//*----------------------------------------------------------------* 
//* PROGRAMA CON DB2 BAJO TSO (IKJEFT01) 
//*----------------------------------------------------------------* 
//STEP3    EXEC PGM=IKJEFT01,DYNAMNBR=20,COND=(4,LT) 
//SYSTSPRT DD   SYSOUT=* 
//DDENTRA  DD   DSN=KC03CAF.ARCHIVOS.NOVCTA.ORD,DISP=SHR 
//SYSOUT   DD   DSN=KC03CAF.SYSOUT,DISP=SHR 
//SYSTSIN  DD   * 
  DSN SYSTEM(DBDG) 
  RUN  PROGRAM(PGMB5CAF) PLAN(CURSOCAF) + 
      LIB('KC03CAF.CURSOS.PGMLIB') 
  END 
//SYSPRINT DD   SYSOUT=* 
//SYSUDUMP DD   SYSOUT=* 
//SYSIN    DD   * 
//* 
//              