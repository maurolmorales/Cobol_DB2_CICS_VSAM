//USUARIOV JOB CLASS=A,MSGCLASS=O,MSGLEVEL=(1,1),NOTIFY=&SYSUID, 
//             TIME=(,5)  ,RESTART=DEFAIX 
//******************************** 
//*          EJEMPLO             * 
//*   IDCAMS DELETE CLUSTER      * 
//******************************** 
//DELCLUS  EXEC PGM=IDCAMS,COND=(8,LT) 
//SYSPRINT DD SYSOUT=* 
//SYSIN    DD * 
     DELETE   USUARIO.NOVECLI.KSDS.VSAM CLUSTER PURGE 
     DELETE   USUARIO.NOVECLI.CL 
//* 
//******************************** 
//*       EJEMPLO KSDS           * 
//*   IDCAMS DEFINE CLUSTER      * 
//******************************** 
//DEFKSDS  EXEC PGM=IDCAMS,COND=(8,LT) 
//SYSPRINT DD SYSOUT=* 
//SYSIN    DD * 
  DEFINE CLUSTER(NAME(USUARIO.NOVECLI.KSDS.VSAM) - 
         CONTROLINTERVALSIZE(4096) - 
         VOLUMES(KCTR57) - 
         CYL(1 1) - 
         KEYS(17 0) - 
         RECORDSIZE(244 244) - 
         FREESPACE(10 5) - 
         SHR(2 3)) - 
  DATA   (NAME(USUARIO.NOVECLI.KSDS.VSAM.DATA)) - 
  INDEX  (NAME(USUARIO.NOVECLI.KSDS.VSAM.INDX)) 
//* 
//********************************* 
//* EJEMPLO1 ORDENA NOVECLI       * 
//********************************* 
//SORT1     EXEC PGM=SORT,COND=EVEN 
//SYSOUT    DD SYSOUT=* 
//SORTIN    DD DSN=USUARIO.NOVECLI,DISP=SHR 
//SORTOUT   DD DSN=USUARIO.NOVECLI.CL, 
//            DCB=(LRECL=244,BLKSIZE=0,RECFM=FB), 
//            SPACE=(TRK,(1,1),RLSE),DISP=(,CATLG) 
//SYSIN     DD * 
 SORT FORMAT=BI,FIELDS=(1,17,A) 
//* 
//******************************** 
//*        EJEMPLO REPRO         * 
//* IDCAMS PARA CARGAR KSDS VSAM * 
//* NOVECLI = SALIDA PROGRAMA    * 
//******************************** 
//DEFREPRO EXEC PGM=IDCAMS,REGION=0M 
//NOVECLI  DD DSN=USUARIO.NOVECLI.CL,DISP=SHR 
//SALIDA   DD DSN=USUARIO.NOVECLI.KSDS.VSAM,DISP=SHR 
//SYSPRINT DD SYSOUT=* 
//SYSIN    DD * 
  REPRO INFILE(NOVECLI) OUTFILE(SALIDA) REPLACE 
//* 