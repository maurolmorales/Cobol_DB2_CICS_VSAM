//USUARIOJ JOB CLASS=A,MSGCLASS=O,MSGLEVEL=(1,1),NOTIFY=&SYSUID, 
//             TIME=(,5) 
//************************************ 
//* EJEMPLO EJECUCION JOB BATCH      * 
//************************************ 
//STEP1    EXEC PGM=IDCAMS,COND=(8,LT) 
//SYSPRINT DD SYSOUT=* 
//SYSIN    DD * 
     DELETE   USUARIO.ARCHIVOS.CLIENTE.SORT 
     SET MAXCC=0 
/* 
//********************************* 
//*     SORT POR SUC-SEXO         * 
//********************************* 
//STEP2     EXEC PGM=SORT,COND=EVEN 
//SYSOUT    DD SYSOUT=* 
//SORTIN    DD DSN=USUARIO.ARCHIVOS.CLIENTE,DISP=SHR 
//SORTOUT   DD DSN=USUARIO.ARCHIVOS.CLIENTE.SORT,DISP=(,CATLG), 
//          UNIT=SYSDA,VOL=SER=ZASWO1, 
//          DCB=(LRECL=50,BLKSIZE=6200,RECFM=FB), 
//          SPACE=(TRK,(1,1),RLSE) 
//SYSIN     DD * 
  SORT      FORMAT=BI,FIELDS=(1,2,A) 
/* 
//************************************ 
//* EJECUCION PROGRAMA CLIENTE       * 
//************************************ 
//STEP4    EXEC PGM=PGMPRUAR 
//STEPLIB  DD DSN=USUARIO.CURSOS.PGMLIB,DISP=SHR 
//DDENTRA  DD DSN=USUARIO.ARCHIVOS.CLIENTE.SORT,DISP=SHR 
//SYSOUT   DD DSN=USUARIO.SYSOUT,DISP=SHR 
//SYSUDUMP DD SYSOUT=* 
//SYSIN    DD SYSOUT=* 