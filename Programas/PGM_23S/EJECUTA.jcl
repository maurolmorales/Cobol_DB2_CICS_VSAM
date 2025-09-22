//KC03CAFZ JOB CLASS=A,MSGCLASS=O,MSGLEVEL=(1,1),NOTIFY=&SYSUID, 
//             TIME=(,5) 
//*-------------------------------------------------------
//* EJECUCION PROGRAMA CON VSAM          
//* DONDE DDCLIEN ES EL ASSING DEL       
//* INPUT VSAM EN EL PROGRAMA            
//*-------------------------------------------------------
//STEP1    EXEC PGM=IDCAMS,COND=(8,LT) 
//SYSPRINT DD SYSOUT=* 
//SYSIN    DD * 
     DELETE   KC03CAF.ARCHIVOS.DATA.SORT 
     SET MAXCC=0 
//*-------------------------------------------------------
//*     SORT                         
//*-------------------------------------------------------
//STEP2     EXEC PGM=SORT,COND=EVEN 
//SYSOUT    DD SYSOUT=* 
//SORTIN    DD DSN=KC02788.ALU9999.CLIENT1.KSDS.VSAM,DISP=SHR 
//SORTOUT   DD DSN=KC03CAF.ARCHIVOS.DATA.SORT,DISP=(,CATLG), 
//          UNIT=SYSDA,VOL=SER=ZASWO1, 
//          DCB=(LRECL=50,BLKSIZE=6200,RECFM=FB), 
//          SPACE=(TRK,(1,1),RLSE) 
//SYSIN     DD * 
  SORT      FORMAT=BI,FIELDS=(14,2,A,16,2,A) 
/* 
//*-------------------------------------------------------
//* EJECUCION DEL PROGRAMA                   
//*-------------------------------------------------------
//STEP3    EXEC PGM=PGMDCCAF 
//STEPLIB  DD DSN=KC03CAF.CURSOS.PGMLIB,DISP=SHR 
//DDENTRA  DD DSN=KC03CAF.ARCHIVOS.DATA.SORT,DISP=SHR 
//SYSOUT   DD DSN=KC03CAF.SYSOUT,DISP=SHR 
//SYSUDUMP DD SYSOUT=* 
// 