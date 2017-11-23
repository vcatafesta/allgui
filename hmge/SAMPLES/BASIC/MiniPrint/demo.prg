#include "minigui.ch"
#include "miniprint.ch"

FUNCTION Main()

   //   AVAILABLE LIBRARY INTERFACE LANGUAGES

   //   SET LANGUAGE TO ENGLISH (DEFAULT)
   //   SET LANGUAGE TO SPANISH
   //   SET LANGUAGE TO PORTUGUESE
   //   SET LANGUAGE TO ITALIAN
   //   SET LANGUAGE TO GERMAN
   //   SET LANGUAGE TO FRENCH

   DEFINE WINDOW Win_1 ;
         AT 0,0 ;
         WIDTH 400 ;
         HEIGHT 400 ;
         TITLE 'MiniPrint Library Test' ;
         MAIN

      DEFINE MAIN MENU
         DEFINE POPUP 'File'
            MENUITEM 'Default Printer' ACTION PrintTest1()
            MENUITEM 'User Selected Printer' ACTION PrintTest2()
            MENUITEM 'User Selected Printer And Settings' ACTION PrintTest3()
            MENUITEM 'User Selected Printer And Settings (Preview)' ACTION PrintTest4()
         END POPUP
      END MENU

   END WINDOW

   MAXIMIZE WINDOW Win_1

   ACTIVATE WINDOW Win_1

   RETURN NIL

PROCEDURE PrintTest1()

   SELECT PRINTER DEFAULT ;
      ORIENTATION   PRINTER_ORIENT_PORTRAIT ;
      PAPERSIZE   PRINTER_PAPER_LETTER ;
      QUALITY      PRINTER_RES_MEDIUM

   PrintDoc()

   MsgInfo('Print Finished')

   RETURN

PROCEDURE PrintTest2()

   LOCAL cPrinter

   cPrinter := GetPrinter()

   IF Empty (cPrinter)

      RETURN
   ENDIF

   SELECT PRINTER cPrinter ;
      ORIENTATION   PRINTER_ORIENT_PORTRAIT ;
      PAPERSIZE   PRINTER_PAPER_LETTER ;
      QUALITY      PRINTER_RES_MEDIUM

   PrintDoc()

   MsgInfo('Print Finished')

   RETURN

PROCEDURE PrintTest3()

   LOCAL lSuccess

   SELECT PRINTER DIALOG TO lSuccess

   IF lSuccess == .T.
      PrintDoc()
      MsgInfo('Print Finished')
   ENDIF

   RETURN

PROCEDURE PrintTest4()

   LOCAL lSuccess

   SELECT PRINTER DIALOG TO lSuccess PREVIEW

   IF lSuccess == .T.
      PrintDoc()
      MsgInfo('Print Finished')
   ENDIF

   RETURN

PROCEDURE PrintDoc

   // Measure Units Are Millimeters

   START PRINTDOC

      START PRINTPAGE

         @ 20,20 PRINT "Filled Rectangle Sample:" ;
            FONT "Arial" ;
            SIZE 20

         @ 30,20 PRINT LINE ;
            TO 30,190 ;
            COLOR {255,255,0} ;
            DOTTED

         @ 40,20 PRINT RECTANGLE ;
            TO 50,190 ;
            PENWIDTH 0.1;
            COLOR {255,255,0}

         @ 60,20 PRINT RECTANGLE ;
            TO 100,190 ;
            COLOR {255,255,0};
            FILLED NOBORDER

         @ 110,20 PRINT RECTANGLE ;
            TO 150,190 ;
            PENWIDTH 0.1;
            COLOR {255,255,0};
            ROUNDED

         @ 160,20 PRINT RECTANGLE ;
            TO 200,190 ;
            PENWIDTH 0.1;
            COLOR {255,255,0};
            FILLED;
            ROUNDED

         @ 170,40 PRINT "Filled Rectangle Sample:" ;
            FONT "Arial" ;
            SIZE 44 COLOR GRAY ANGLE 45

      END PRINTPAGE

      START PRINTPAGE

         @ 20,20 PRINT "Filled Rectangle Sample:" ;
            FONT "Arial" ;
            SIZE 20

         @ 30,20 PRINT LINE ;
            TO 30,190 ;
            DOTTED

         @ 40,20 PRINT RECTANGLE ;
            TO 50,190 ;
            PENWIDTH 0.1

         @ 60,20 PRINT RECTANGLE ;
            TO 100,190 ;
            PENWIDTH 0.1;
            FILLED

         @ 110,20 PRINT RECTANGLE ;
            TO 150,190 ;
            PENWIDTH 0.1;
            ROUNDED

         @ 160,20 PRINT RECTANGLE ;
            TO 200,190 ;
            PENWIDTH 0.1;
            FILLED;
            ROUNDED

      END PRINTPAGE

   END PRINTDOC

   RETURN
