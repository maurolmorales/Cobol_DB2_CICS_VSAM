 //COMPTEST JOB CLASS=A,MSGCLASS=O,MSGLEVEL=(0,0),NOTIFY=&SYSUID, 
 //             TIME=(,3) 
 //JCLLIB   JCLLIB ORDER=USUARIO.CURSOS.PROCLIB 
//***************************************************************
//* Este JCL realiza la precompilación, compilación y link-edit *
//* de un programa COBOL con SQL embebido.                     *
//* La precompilación separa el código COBOL del SQL y genera   *
//* un DBRM que luego debe ser registrado con un BIND.          *
//***************************************************************
 //STEP1    EXEC COMPCOTE, 
 //         ALUMLIB=USUARIO.CURSOS, 
 //         GOPGM=PGMB2CAF 
 //COBOL.SYSLIB DD DSN=ORIGEN.COPYLIB,DISP=SHR 