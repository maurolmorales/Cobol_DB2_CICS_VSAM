//USUARIOF JOB CLASS=A,MSGCLASS=O,MSGLEVEL=(1,1),NOTIFY=&SYSUID, 
//             TIME=(,5) 
//************************************************ 
//*       EJEMPLO EJECUCION JOB BATCH            * 
//************************************************ 
//STEP1    EXEC PGM=IDCAMS,COND=(8,LT) 
//SYSPRINT DD SYSOUT=* 
//SYSIN    DD * 
     DELETE   USUARIO.ARCHIVOS.CLIENTES.SORT 
     DELETE   USUARIO.ARCHIVOS.LISTADO 
     SET MAXCC=0 
//************************************************ 
//*       ORDENAMIENTO DEL ARCHIVO               * 
//************************************************ 
//STEP2     EXEC PGM=SORT,COND=EVEN 
//SYSOUT    DD SYSOUT=* 
//SORTIN    DD DSN=USUARIO.ARCHIVOS.CLIENTES,DISP=SHR 
//SORTOUT   DD DSN=USUARIO.ARCHIVOS.CLIENTES.SORT,DISP=(,CATLG), 
//          UNIT=SYSDA,VOL=SER=ZASWO1, 
//          DCB=(LRECL=50,BLKSIZE=6200,RECFM=FB), 
//          SPACE=(TRK,(1,1),RLSE) 
//SYSIN     DD * 
  SORT      FORMAT=BI,FIELDS=(14,2,A,16,2,A) 
//************************************************ 
//*       EJECUCION PROGRAMA                     * 
//************************************************ 
//STEP3    EXEC PGM=PGM5CCAF 
//STEPLIB  DD DSN=USUARIO.CURSOS.PGMLIB,DISP=SHR 
//DDENTRA  DD DSN=USUARIO.ARCHIVOS.CLIENTES.SORT,DISP=SHR 
//DDLISTA  DD DSN=USUARIO.ARCHIVOS.LISTADO,UNIT=SYSDA, 
//             DCB=(LRECL=133,BLKSIZE=1330,RECFM=FB), 
//             SPACE=(TRK,(1,1),RLSE),DISP=(,CATLG,CATLG) 
//SYSOUT   DD DSN=USUARIO.SYSOUT,DISP=SHR 
//SYSUDUMP DD SYSOUT=* 
//SYSIN    DD SYSOUT=* 