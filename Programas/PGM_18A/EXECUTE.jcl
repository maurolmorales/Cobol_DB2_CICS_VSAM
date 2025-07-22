//KC03CAFD JOB  CLASS=A,MSGCLASS=O,MSGLEVEL=(1,1),NOTIFY=&SYSUID 
//JOBLIB   DD   DSN=DSND10.SDSNLOAD,DISP=SHR 
//         DD   DSN=KC03CAF.CURSOS.PGMLIB,DISP=SHR 
//*----------------------------------------------------------------* 
//*   PROGRAMA CON DB2 BAJO TSO (IKJEFT01)                         * 
//*----------------------------------------------------------------* 
//STEP3    EXEC PGM=IKJEFT01,DYNAMNBR=20,COND=(4,LT) 
//SYSTSPRT DD   SYSOUT=* 
//SYSOUT   DD   DSN=KC03CAF.SYSOUT,DISP=SHR 
//SYSTSIN  DD   * 
  DSN SYSTEM(DBDG) 
  RUN  PROGRAM(PGMB7CAF) PLAN(CURSOCAF) + 
      LIB('KC03CAF.CURSOS.PGMLIB') 
  END 
//SYSPRINT DD   SYSOUT=* 
//SYSUDUMP DD   SYSOUT=* 
//SYSIN    DD   * 
//* 