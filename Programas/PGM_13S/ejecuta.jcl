//USUARIOJ JOB CLASS=A,MSGCLASS=O,MSGLEVEL=(1,1),NOTIFY=&SYSUID, 
//             TIME=(,5) 
//************************************ 
//* EJEMPLO EJECUCION JOB BATCH      * 
//************************************ 
//STEP1    EXEC PGM=IDCAMS,COND=(8,LT) 
//SYSPRINT DD SYSOUT=* 
//SYSIN    DD * 
     DELETE   USUARIO.ARCHIVOS.CLICOB.SORT 
     SET MAXCC=0 
//*********************************** 
//*       SORT POR ESTADO CIVIL     * 
//*********************************** 
//STEP2     EXEC PGM=SORT,COND=EVEN 
//SYSOUT    DD SYSOUT=* 
//SORTIN    DD DSN=USUARIO.ARCHIVOS.CLICOB,DISP=SHR 
//SORTOUT   DD DSN=USUARIO.ARCHIVOS.CLICOB.SORT,DISP=(,CATLG), 
//          UNIT=SYSDA,VOL=SER=ZASWO1, 
//          DCB=(LRECL=93,BLKSIZE=9300,RECFM=FB), 
//          SPACE=(TRK,(1,1),RLSE) 
//SYSIN     DD * 
  SORT      FORMAT=BI,FIELDS=(44,10,A) 
//************************************ 
//* EJECUCION PROGRAMA PGMC1CAF      * 
//************************************ 
//STEP4    EXEC PGM=PGMC1CAF 
//STEPLIB  DD DSN=USUARIO.CURSOS.PGMLIB,DISP=SHR 
//DDENTRA  DD DSN=USUARIO.ARCHIVOS.CLICOB.SORT,DISP=SHR 
//SYSOUT   DD DSN=USUARIO.SYSOUT,DISP=SHR 
//SYSUDUMP DD SYSOUT=* 
//SYSIN    DD SYSOUT=* 