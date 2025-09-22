//KC03CAFJ JOB CLASS=A,MSGCLASS=O,MSGLEVEL=(1,1),NOTIFY=&SYSUID, 
//             TIME=(,5) 
//*---------------------------------------------------------------
//* EJEMPLO EJECUCION JOB BATCH        
//*---------------------------------------------------------------
//STEP1    EXEC PGM=IDCAMS,COND=(8,LT) 
//SYSPRINT DD SYSOUT=* 
//SYSIN    DD * 
     DELETE   KC03CAF.ARCHIVOS.CLICOB.SORT 
     SET MAXCC=0 
//*---------------------------------------------------------------
//*       SORT                        
//*---------------------------------------------------------------
//STEP2     EXEC PGM=SORT,COND=EVEN 
//SYSOUT    DD SYSOUT=* 
//SORTIN    DD DSN=KC03CAF.ARCHIVOS.CLICOB,DISP=SHR 
//SORTOUT   DD DSN=KC03CAF.ARCHIVOS.CLICOB.SORT,DISP=(,CATLG), 
//          UNIT=SYSDA,VOL=SER=ZASWO1, 
//          DCB=(LRECL=93,BLKSIZE=9300,RECFM=FB), 
//          SPACE=(TRK,(1,1),RLSE) 
//SYSIN     DD * 
  SORT      FORMAT=BI,FIELDS=(44,10,A) 
//*---------------------------------------------------------------
//* EJECUCION PROGRAMA                 
//*---------------------------------------------------------------
//STEP4    EXEC PGM=PGMC1CAF 
//STEPLIB  DD DSN=KC03CAF.CURSOS.PGMLIB,DISP=SHR 
//DDENTRA  DD DSN=KC03CAF.ARCHIVOS.CLICOB.SORT,DISP=SHR 
//SYSOUT   DD DSN=KC03CAF.SYSOUT,DISP=SHR 
//SYSUDUMP DD SYSOUT=* 
//SYSIN    DD SYSOUT=* 