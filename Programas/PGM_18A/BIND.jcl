//USUARIOF JOB CLASS=A,MSGCLASS=O,MSGLEVEL=(1,1),NOTIFY=&SYSUID 
//JOBLIB   DD  DSN=DSND10.SDSNLOAD,DISP=SHR 
//STEP1    EXEC PGM=IKJEFT01,DYNAMNBR=20,COND=(4,LT) 
//**************************************************** 
//*                                                  * 
//* DBRMLIB  DD  DSN=USUARIO.CURSOS.DBRMLIB,DISP=SHR * 
//*                                                  * 
//**************************************************** 
//DBRMLIB  DD  DSN=USUARIO.CURSOS.DBRMLIB,DISP=SHR 
//SYSTSPRT DD SYSOUT=* 
//SYSTSIN  DD * 
  DSN SYSTEM(DBDG) 
  RUN  PROGRAM(DSNTIAD) PLAN(DSNTIA13) - 
       LIB('DSND10.DBDG.RUNLIB.LOAD') 
  BIND PLAN(CURSOCAF) MEMBER(PGMB6CAF)+ 
      CURRENTDATA(NO) ACT(REP) ISO(CS) ENCODING(EBCDIC) 
  END 
//SYSPRINT DD SYSOUT=* 
//SYSUDUMP DD SYSOUT=* 
//SYSIN    DD * 