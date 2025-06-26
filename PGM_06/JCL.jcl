//USUARIOF JOB CLASS=A,MSGCLASS=O,MSGLEVEL=(1,1),NOTIFY=&SYSUID, 
//             TIME=(,5) 
//************************************ 
//* EJEMPLO EJECUCION JOB BATCH      * 
//************************************ 
//* 
//STEP1    EXEC PGM=IDCAMS,COND=(8,LT) 
//SYSPRINT DD SYSOUT=* 
//SYSIN    DD * 
  DELETE   USUARIO.ARCHIVO.SORT 
  SET MAXCC = 0 
//* 
//********************************* 
//*     SORT POR SUC 
//********************************* 
//STEP2    EXEC PGM=SORT,COND=EVEN 
//SYSOUT   DD SYSOUT=* 
//SORTIN   DD DSN=USUARIO.ARCHIVOS,DISP=SHR 
//SORTOUT  DD DSN=USUARIO.ARCHIVO.SORT,DISP=(,CATLG), 
//          UNIT=SYSDA,VOL=SER=ZASWO1, 
//          DCB=(LRECL=20,BLKSIZE=2000,RECFM=FB), 
//          SPACE=(TRK,(1,1),RLSE) 
//SYSIN    DD * 
  SORT  FORMAT=BI,FIELDS=(1,2,A) 
//* 
//************************************ 
//* EJECUCION PROGRAMA PGM2CAFF      * 
//************************************ 
//STEP4    EXEC PGM=PGM2CCAF 
//STEPLIB  DD DSN=USUARIO.CURSOS.PGMLIB,DISP=SHR 
//DDENTRA  DD DSN=USUARIO.ARCHIVO.SORT,DISP=SHR 
//SYSOUT   DD DSN=USUARIO.SYSOUT,DISP=SHR 
//SYSUDUMP DD SYSOUT=* 
//SYSIN    DD SYSOUT=* 
// 