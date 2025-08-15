//KC03CAF1 JOB CLASS=A,MSGCLASS=O,MSGLEVEL=(1,1),NOTIFY=&SYSUID, 
//             TIME=(,5) ,RESTART=DEFAIC 
//******************************** 
//*          EJEMPLO             * 
//* IDCAMS ALOCAR VSAM KSDS Y AIX* 
//*                              * 
//* REEMPLAZAR 03CAF POR USER ID * 
//*                              * 
//******************************** 
//******************************** 
//*          EJEMPLO             * 
//*   IDCAMS DELETE CLUSTER      * 
//******************************** 
//DELCLUS  EXEC PGM=IDCAMS 
//SYSPRINT DD SYSOUT=* 
//SYSIN    DD * 
     DELETE   KC03CAF.CURSOS.PERSONA.KSDS.VSAM PURGE 
     SET MAXCC=0 
//******************************** 
//*       EJEMPLO KSDS           * 
//*   IDCAMS DEFINE CLUSTER      * 
//******************************** 
//DEFKSDS  EXEC PGM=IDCAMS 
//SYSPRINT DD SYSOUT=* 
//SYSIN    DD * 
  DEFINE CLUSTER(NAME(KC03CAF.CURSOS.PERSONA.KSDS.VSAM) - 
         CONTROLINTERVALSIZE(4096) - 
         VOLUMES(KCTR56) - 
         CYL(1 1) - 
         KEYS(13 0) - 
         RECORDSIZE(160 160) - 
         FREESPACE(10 5) - 
         SHR(2 3)) - 
  DATA   (NAME(KC03CAF.CURSOS.PERSONA.KSDS.VSAM.DATA)) - 
  INDEX  (NAME(KC03CAF.CURSOS.PERSONA.KSDS.VSAM.INDX)) 
//* 
//************************************** 
//*EJEMPLO  ORDENA POR CLAVE PRIMARIA  * 
//*  TIPO Y NRO DOCUMENTO              * 
//************************************** 
//STEP2       EXEC PGM=SORT,COND=EVEN 
//SYSOUT    DD SYSOUT=* 
//SORTIN    DD DSN=KC02788.ALU9999.CURSOS.PERSONA.BACKUP,DISP=SHR 
//SORTOUT   DD DSN=KC03CAF.CURSOS.PERSONA.CLAS,DISP=SHR 
//SYSIN     DD * 
  SORT     FORMAT=BI,FIELDS=(1,13,A) 
//******************************** 
//*        EJEMPLO REPRO         * 
//* IDCAMS PARA CARGAR KSDS VSAM * 
//******************************** 
//DEFREPRO EXEC PGM=IDCAMS,REGION=0M 
//PERSONA  DD DSN=KC03CAF.CURSOS.PERSONA.CLAS,DISP=SHR 
//SALIDA   DD DSN=KC03CAF.CURSOS.PERSONA.KSDS.VSAM,DISP=SHR 
//SYSPRINT DD SYSOUT=* 
//SYSIN    DD * 
  REPRO INFILE(PERSONA) OUTFILE(SALIDA) REPLACE 
//******************************** 
//*       EJEMPLO KSDS           * 
//* IDCAMS DEFINE AIX POR NROCLI * 
//******************************** 
//DEFAIX   EXEC PGM=IDCAMS,COND=(4,LT) 
//SYSPRINT DD SYSOUT=* 
//SYSIN    DD * 
  DEFINE AIX (NAME(KC03CAF.CURSOS.PERSONA.KSDS.VSAM.AIX) - 
         RELATE(KC03CAF.CURSOS.PERSONA.KSDS.VSAM) - 
         KEYS(3 13) - 
         VOLUMES(KCTR56) - 
         FREESPACE(5 1) - 
         CYL(1 1) - 
         RECORDSIZE(160 160) - 
         CONTROLINTERVALSIZE(2048) - 
         NONUNIQUEKEY - 
         SHR(2 3)) - 
  DATA  (NAME(KC03CAF.CURSOS.PERSONA.KSDS.VSAM.AIX.DATA)) - 
  INDEX (NAME(KC03CAF.CURSOS.PERSONA.KSDS.VSAM.AIX.INDX)) 
//******************************** 
//*       EJEMPLO KSDS           * 
//* IDCAMS DEFINE PATH BLDINDEX  * 
//******************************** 
//DEFPATH  EXEC PGM=IDCAMS,COND=(4,LT) 
//SYSPRINT DD SYSOUT=* 
//SYSIN    DD * 
  DEFINE PATH (NAME(KC03CAF.CURSOS.PERSONA.KSDS.VSAM.PATH) - 
         PATHENTRY(KC03CAF.CURSOS.PERSONA.KSDS.VSAM.AIX)) 
  BLDINDEX - 
         IDS(KC03CAF.CURSOS.PERSONA.KSDS.VSAM) - 
         ODS(KC03CAF.CURSOS.PERSONA.KSDS.VSAM.AIX) - 
         ESORT 
//* 
//            