//USUARIOD JOB CLASS=A,MSGCLASS=O,MSGLEVEL=(1,1),NOTIFY=&SYSUID 
//JOBLIB  DD  DSN=DSND10.SDSNLOAD,DISP=SHR 
//*--------------------------------------------------------------
//* Este JCL ejecuta el programa COBOL con SQL embebido en DB2.  
//*--------------------------------------------------------------
//*STEP1    EXEC PGM=IEFBR14 
//*DD1      DD DSN=USUARIO.CURSOS.DB2.SALIDA,UNIT=SYSDA, 
//*            DCB=(LRECL=80,BLKSIZE=8000,RECFM=FB), 
//*            SPACE=(TRK,(1,1),RLSE),DISP=(,CATLG) 
//*--------------------------------------------------------------
//STEP2    EXEC PGM=IKJEFT01,DYNAMNBR=20,COND=(4,LT) 
//SYSTSPRT DD SYSOUT=* 
//DDENTRA  DD DSN=USUARIO.NOVECLI.KSDS.VSAM,DISP=SHR 
//SYSOUT   DD DSN=USUARIO.SYSOUT,DISP=SHR 
//SYSTSIN  DD * 
  DSN SYSTEM(DBDG) 
  RUN  PROGRAM(PGMBMLM) PLAN(CURSOCAF) + 
      LIB('USUARIO.CURSOS.PGMLIB') 
  END 
//SYSPRINT DD SYSOUT=* 
//SYSUDUMP DD SYSOUT=* 
//SYSIN    DD * 
// 