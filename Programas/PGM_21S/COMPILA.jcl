//KC03CAFC JOB CLASS=A,MSGCLASS=O,MSGLEVEL=(1,1),NOTIFY=&SYSUID, 
//             TIME=(,3) 
//JCLLIB       JCLLIB ORDER=KC02788.ALU9999.PROCLIB 
//*----------------------------------------------------------------
//*   COMPILADOR COBOL BATCH
//*----------------------------------------------------------------
//STEP1  EXEC COMPCOBO, 
//       ALUMLIB=KC03CAF.CURSOS, 
//       GOPGM=PROGM21S
//COBOL.SYSLIB DD DSN=KC02788.ALU9999.COPYLIB,DISP=SHR 
//