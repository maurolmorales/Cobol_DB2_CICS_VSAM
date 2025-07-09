      *    NOVECLI
      ************************************** 
      *         LAYOUT NOVEDAD CLIENTES    * 
      *         LARGO 50 BYTES             * 
      ************************************** 
       01  WS-REG-NOVCLIE. 
           03  NOV-TIP-DOC         PIC X(02)    VALUE SPACES. 
           03  NOV-NRO-DOC         PIC 9(11)    VALUE ZEROS. 
           03  NOV-SUC             PIC 9(02)    VALUE ZEROS. 
           03  NOV-CLI-TIPO        PIC 9(02)    VALUE ZEROS. 
           03  NOV-CLI-NRO         PIC 9(03)    VALUE ZEROS. 
           03  NOV-CLI-IMP         PIC S9(09)V99 COMP-3 VALUE ZEROS. 
           03  FILLER              PIC X(24)    VALUE SPACES. 
