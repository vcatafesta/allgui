#include "hmg.ch"

FUNCTION main

   DEFINE WINDOW m at 0,0 width 800 height 600 main On Init ShowPie() backcolor { 255,255,255}

      DEFINE BUTTON x
         ROW 10
         COL 10
         CAPTION "Draw"
         ACTION showpie()
      END BUTTON

      DEFINE BUTTON Button_1
         ROW   10
         COL   150
         CAPTION   'Print'
         ACTION PRINT GRAPH OF m PREVIEW DIALOG
      END BUTTON

   END WINDOW

   m.center

   m.activate

   RETURN NIL

FUNCTION showpie

   ERASE WINDOW m

   DRAW GRAPH IN WINDOW m AT 100,100 ;
      TO 500,500 ;
      TITLE "Sales" ;
      TYPE PIE ;
      SERIES {1500,1800,200,500,800} ;
      DEPTH 25 ;
      SERIENAMES {"Product 1","Product 2","Product 3","Product 4","Product 5"} ;
      COLORS {{255,0,0},{0,0,255},{255,255,0},{0,255,0},{255,128,64},{128,0,128}} ;
      3DVIEW ;
      SHOWXVALUES ;
      SHOWLEGENDS NOBORDER

   RETURN NIL
