//COMPTEST JOB CLASS=A,MSGCLASS=O,MSGLEVEL=(0,0),NOTIFY=&SYSUID, 
//             TIME=(,3) 
//JCLLIB   JCLLIB ORDER=KC02787.CURSOS.PROCLIB 
//*********************************************** 
//*   COMPILADOR COBOL BATCH                    * 
//*   ALUMLIB DIGITAR SU USERID ALUMNO          * 
//*   GOPGM DIGITAR SU PROGRAM-ID               * 
//*   SI SE DESEA USAR COPY SACAR ASTERISCO     * 
//*      A COBOL.SYSLIB                         * 
//*********************************************** 
//STEP1    EXEC COMPCOTE, 
//         ALUMLIB=KC03CAF.CURSOS, 
//         GOPGM=PGMDCCAF 
//COBOL.SYSLIB DD DSN=KC02788.ALU9999.COPYLIB,DISP=SHR 