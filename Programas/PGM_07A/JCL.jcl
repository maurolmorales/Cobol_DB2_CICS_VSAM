//USUARIOF JOB CLASS=A,MSGCLASS=O,MSGLEVEL=(1,1),NOTIFY=&SYSUID, 
//             TIME=(,3) 
//******************************************* 
//* JCL PARA EJECUTAR EL PROGRAMA PGMCORT2  * 
//******************************************* 
//STEP1    EXEC PGM=IDCAMS,COND=(8,LT) 
//SYSPRINT DD SYSOUT=* 
//SYSIN    DD * 
  DELETE   USUARIO.ARCHIVO.ORD 
           SET MAXCC = 0 
/* 
//********************************* 
//*   SORT POR TIPO DOC Y SEXO    * 
//********************************* 
//STEP2     EXEC PGM=SORT,COND=EVEN 
//SYSOUT    DD SYSOUT=* 
//SORTIN    DD DSN=USUARIO.ARCHIVO,DISP=SHR 
//SORTOUT   DD DSN=USUARIO.ARCHIVO.ORD,DISP=(,CATLG), 
//          UNIT=SYSDA,VOL=SER=ZASWO1, 
//          DCB=(LRECL=93,BLKSIZE=9300,RECFM=FB), 
//          SPACE=(TRK,(1,1),RLSE) 
//SYSIN     DD * 
  SORT      FORMAT=BI,FIELDS=(1,2,A,54,1,A) 
/* 
//********************************* 
//*       PROCESO DIARIO          * 
//********************************* 
//STEP3    EXEC PGM=PGMCORT2 
//STEPLIB  DD DSN=USUARIO.CURSOS.PGMLIB,DISP=SHR 
//DDENTRA  DD DSN=USUARIO.ARCHIVO.ORD,DISP=SHR 
//SYSOUT   DD DSN=USUARIO.SYSOUT,DISP=SHR 
//SYSUDUMP DD SYSOUT=* 
//SYSIN    DD * 
// 