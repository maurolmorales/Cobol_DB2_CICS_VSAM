      ******************************************************************
      * DCLGEN TABLE(ORIGEN.TBCURCLI)                                  *
      *        LIBRARY(USUARIO.CURSOS.DCLGEN(TBCURCLI))                *
      *        ACTION(REPLACE)                                         *
      *        LANGUAGE(COBOL)                                         *
      *        NAMES(WSC-)                                             *
      *        QUOTE                                                   *
      *        COLSUFFIX(YES)                                          *
      * ... IS THE DCLGEN COMMAND THAT MADE THE FOLLOWING STATEMENTS   *
      ******************************************************************
           EXEC SQL DECLARE ORIGEN.TBCURCLI TABLE 
           ( TIPDOC                         CHAR(2) NOT NULL, 
             NRODOC                         DECIMAL(11, 0) NOT NULL, 
             NROCLI                         DECIMAL(3, 0) NOT NULL, 
             NOMAPE                         CHAR(30) NOT NULL, 
             FECNAC                         DATE NOT NULL, 
             SEXO                           CHAR(1) NOT NULL 
           ) END-EXEC. 
      ******************************************************************
      * COBOL DECLARATION FOR TABLE ORIGEN.TBCURCLI                   *
      ******************************************************************
       01  DCLTBCURCLI. 
           10 WSC-TIPDOC      PIC X(2).                 *> TIPDOC
           10 WSC-NRODOC      PIC S9(11)V USAGE COMP-3. *> NRODOC
           10 WSC-NROCLI      PIC S9(3)V USAGE COMP-3.  *> NROCLI
           10 WSC-NOMAPE      PIC X(30).                *> NOMAPE
           10 WSC-FECNAC      PIC X(10).                *> FECNAC
           10 WSC-SEXO        PIC X(1).                 *> FECNAC
      ******************************************************************
      * THE NUMBER OF COLUMNS DESCRIBED BY THIS DECLARATION IS 6       *
      ******************************************************************
