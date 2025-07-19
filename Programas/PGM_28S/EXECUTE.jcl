//USUARIOD JOB  CLASS=A,MSGCLASS=O,MSGLEVEL=(1,1),NOTIFY=&SYSUID 
//JOBLIB   DD   DSN=DSND10.SDSNLOAD,DISP=SHR 
//         DD   DSN=USUARIO.CURSOS.PGMLIB,DISP=SHR 
//*************************************************************** 
//* OPCIONAL: CREAR ARCHIVO DE SALIDA LA PRIMERA VEZ            * 
//*************************************************************** 
//*CREAFILE EXEC PGM=IEFBR14 
//*DD1      DD   DSN=USUARIO.DB2.SALIDA,UNIT=SYSDA, 
//*              DCB=(LRECL=80,BLKSIZE=8000,RECFM=FB), 
//*              SPACE=(TRK,(1,1),RLSE),DISP=(NEW,CATLG,DELETE) 
//*************************************************************** 
//* ELIMINAR ARCHIVO DE SALIDA ORDENADO                         * 
//*************************************************************** 
//DELFILE  EXEC PGM=IDCAMS 
//SYSPRINT DD SYSOUT=* 
//SYSIN    DD * 
  DELETE USUARIO.ARCHIVOS.LISTADO 
  SET MAXCC=0 
/* 
//*************************************************************** 
//* OPCIONAL: ORDENAMIENTO DEL ARCHIVO LISTADO                  * 
//*************************************************************** 
//*SRTLISTA EXEC PGM=SORT 
//*SYSOUT   DD SYSOUT=* 
//*SORTIN   DD DSN=USUARIO.ARCHIVOS.LISTADO,DISP=SHR 
//*SORTOUT  DD DSN=USUARIO.ARCHIVOS.LISTADO.SORT, 
//*            DISP=(NEW,CATLG,DELETE), 
//*            UNIT=SYSDA,VOL=SER=ZASWO1, 
//*            DCB=(LRECL=20,BLKSIZE=2000,RECFM=FB), 
//*            SPACE=(TRK,(1,1),RLSE) 
//*SYSIN    DD * 
//*  SORT FIELDS=(1,2,CH,A) 
//* 
//*************************************************************** 
//* EJECUCIÓN DEL PROGRAMA MLMB2CAF                             * 
//*************************************************************** 
//EJECMLM  EXEC PGM=IKJEFT01,DYNAMNBR=20 
//SYSTSPRT DD SYSOUT=* 
//*DDENTRA  DD DSN=USUARIO.ARCHIVOS.LISTADO,DISP=SHR 
//DDLISTA  DD DSN=USUARIO.ARCHIVOS.LISTADO, 
//            DISP=(NEW,CATLG,DELETE), 
//            UNIT=SYSDA,VOL=SER=ZASWO1, 
//            DCB=(LRECL=124,BLKSIZE=12400,RECFM=FB), 
//            SPACE=(TRK,(1,1),RLSE) 
//SYSOUT   DD SYSOUT=* 
//SYSTSIN  DD * 
  DSN SYSTEM(DBDG) 
  RUN PROGRAM(MLMB2CAF) PLAN(CURSOCAF) + 
      LIB('USUARIO.CURSOS.PGMLIB') 
  END 
/* 
//SYSPRINT DD SYSOUT=* 
//SYSUDUMP DD SYSOUT=* 