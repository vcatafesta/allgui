#include "minigui.ch"

FUNCTION main

   DEFINE WINDOW m main ;
         clientarea 640, 480 ;
         Title "Print Pie Graph" ;
         backcolor {216,208,200}

      DEFINE BUTTON x
         row 10
         col 10
         caption "Draw"
         action showpie()
      END BUTTON

      DEFINE BUTTON x1
         row 40
         col 10
         caption "Print"
         action ( showpie(), printpie() )
      END BUTTON

   END WINDOW
   m.center
   m.activate

   RETURN NIL

FUNCTION showpie

   ERASE WINDOW m

   DRAW GRAPH IN WINDOW m;
      AT 80,40;
      TO 460,600;
      TITLE "Product Sales in 2010 (1,000$)";
      TYPE PIE;
      SERIES {1800,1500,1200,800,600,300};
      DEPTH 25;
      SERIENAMES {"Product 1","Product 2","Product 3","Product 4","Product 5","Product 6"};
      COLORS {{255,0,0},{0,0,255},{255,255,0},{0,255,0},{255,128,64},{128,0,128}};
      3DVIEW;
      SHOWXVALUES;
      SHOWLEGENDS RIGHT DATAMASK "99,999"

   RETURN NIL

FUNCTION printpie

   LOCAL cPrinter

   cPrinter := GetPrinter()

   IF Empty (cPrinter)

      RETURN NIL
   ENDIF

   SetDefaultPrinter (cPrinter)

   PRINT GRAPH IN WINDOW m;
      AT 80,40;
      TO 460,600;
      TITLE "Product Sales in 2010 (1,000$)";
      TYPE PIE;
      SERIES {1800,1500,1200,800,600,300};
      DEPTH 25;
      SERIENAMES {"Product 1","Product 2","Product 3","Product 4","Product 5","Product 6"};
      COLORS {{255,0,0},{0,0,255},{255,255,0},{0,255,0},{255,128,64},{128,0,128}};
      3DVIEW;
      SHOWXVALUES;
      SHOWLEGENDS RIGHT DATAMASK "99,999"

   RETURN NIL

   #ifndef __XHARBOUR__

#pragma BEGINDUMP

#include "hbapi.h"

HB_FUNC_TRANSLATE( SETDEFAULTPRINTER, WIN_PRINTERSETDEFAULT )

#pragma ENDDUMP

   #endif
