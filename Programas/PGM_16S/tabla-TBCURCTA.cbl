      ******************************************************************
      * DCLGEN TABLE(ORIGEN.TBCURCTA)                                 *
      *        LIBRARY(USUARIO.CURSOS.DCLGEN(TBCURCTA))                *
      *        ACTION(REPLACE)                                         *
      *        LANGUAGE(COBOL)                                         *
      *        NAMES(WS-)                                              *
      *        QUOTE                                                   *
      *        COLSUFFIX(YES)                                          *
      * ... IS THE DCLGEN COMMAND THAT MADE THE FOLLOWING STATEMENTS   *
      ******************************************************************
           EXEC SQL DECLARE ORIGEN.TBCURCTA TABLE 
           ( TIPCUEN                        CHAR(2) NOT NULL, 
             NROCUEN                        DECIMAL(5, 0) NOT NULL, 
             SUCUEN                         DECIMAL(2, 0) NOT NULL, 
             NROCLI                         DECIMAL(3, 0) NOT NULL, 
             SALDO                          DECIMAL(7, 2) NOT NULL, 
             FECSAL                         DATE NOT NULL 
           ) END-EXEC. 
      ******************************************************************
      * COBOL DECLARATION FOR TABLE ORIGEN.TBCURCTA                   *
      ******************************************************************
       01  DCLTBCURCTA. 
           10 WS-TIPCUEN     PIC X(2).                     *> TIPCUEN 
           10 WS-NROCUEN     PIC S9(5)V     USAGE COMP-3.  *> NROCUEN
           10 WS-SUCUEN      PIC S9(2)V     USAGE COMP-3.  *> SUCUEN
           10 WS-NROCLI      PIC S9(3)V     USAGE COMP-3.  *> NROCLI
           10 WS-SALDO       PIC S9(5)V9(2) USAGE COMP-3.  *> SALDO
           10 WS-FECSAL      PIC X(10).                    *> FECSAL
      ******************************************************************
      * THE NUMBER OF COLUMNS DESCRIBED BY THIS DECLARATION IS 6       *
      ******************************************************************      