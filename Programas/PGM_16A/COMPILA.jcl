//KC03CAFF JOB CLASS=A,MSGCLASS=O,MSGLEVEL=(1,1),NOTIFY=&SYSUID 
//*********************************************** 
//*   COMPILADOR COBOL/DB2 BATCH                * 
//*   XX =    DIGITAR SU USERID ALUMNO          * 
//*   GOPGM DIGITAR SU PROGRAM-ID               * 
//*********************************************** 
//JCLLIB   JCLLIB ORDER=KC02787.CURSOS.PROCLIB 
//STEP1    EXEC COMPDB2, 
//         ALUMLIB=KC03CAF.CURSOS, 
//         GOPGM=PGMBMLM 
//PC.SYSLIB  DD DSN=KC03CAF.CURSOS.DCLGEN,DISP=SHR 
//COB.SYSLIB DD DSN=KC02788.ALU9999.COPYLIB,DISP=SHR 