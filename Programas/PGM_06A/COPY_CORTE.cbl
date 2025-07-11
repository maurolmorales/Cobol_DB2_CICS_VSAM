      *////////////////// (CORTE) //////////////////////////////////////
      ************************************** 
      *     LAYOUT SUCURSAL                * 
      *     LARGO REGISTRO = 20 BYTES      * 
      ************************************** 
       01  WS-REG-SUCURSAL. 
      *     POSICIóN RELATIVA (1:2) NÚMERO DE SUCURSAL 
           03  WS-SUC-NRO          PIC 9(02)    VALUE ZEROS. 
      *     POSICIóN RELATIVA (3:5) IMPORTE 
           03  WS-SUC-IMPORTE      PIC S9(7)V99 COMP-3  VALUE ZEROS. 
      *     POSICIóN RELATIVA (8:2) TIPO NOVEDAD 
      *     AL=ALTA; BA= BAJA; DE=DéBITO; CR=CRéDITO 
           03  WS-SUC-TIPN         PIC X(02)    VALUE ZEROS. 
      *     POSICIóN RELATIVA (10:3) TIPO CUENTA 
      *     WS-SUC-TIPC1 = 01 (CTA. CORRIENTE) OR 02 (CAJA AHORROS) 
      *     WS-SUC-TIPC1 = 03 (PLAZO FIJO) 
      *     WS-SUC-TIPC2 = 1 ($) OR 2 (U$S) 
      *     011=CC$     ;  021=CAJA DE AHORROS$   ; 031=PLAZO FIJO $ 
      *     012=CC U$S  ;  022=CAJA DE AHORROS U$S; 032=PLAZO FIJO U$S 
           03  WS-SUC-TIPC. 
               05  WS-SUC-TIPC1    PIC 9(02)    VALUE ZEROS. 
               05  WS-SUC-TIPC2    PIC 9(01)    VALUE ZEROS. 
      *      POSICIóN RELATIVA (13:08) PARA USO FUTURO 
           03  FILLER              PIC X(8)     VALUE SPACES. 
           
