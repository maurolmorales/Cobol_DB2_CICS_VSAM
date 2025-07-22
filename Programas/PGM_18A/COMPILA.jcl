//USUARIOF JOB CLASS=A,MSGCLASS=O,MSGLEVEL=(1,1),NOTIFY=&SYSUID 
//*********************************************** 
//*   COMPILADOR COBOL/DB2 BATCH                * 
//*   XX =    DIGITAR SU USERID ALUMNO          * 
//*   GOPGM DIGITAR SU PROGRAM-ID               * 
//*********************************************** 
//JCLLIB   JCLLIB ORDER=ORIGEN.CURSOS.PROCLIB 
//STEP1    EXEC COMPDB2, 
//         ALUMLIB=USUARIO.CURSOS, 
//         GOPGM=PGMB6CAF 
//PC.SYSLIB  DD DSN=USUARIO.CURSOS.DCLGEN,DISP=SHR 
//COB.SYSLIB DD DSN=ORIGEN.COPYLIB,DISP=SHR 