/*
* MINIGUI - Harbour Win32 GUI library Demo
*/

#include "minigui.ch"

STATIC aYValues := { "MINIGUI", "FW", "Xailer", "None", "HWGUI", "T-Gtk", "GTWVW", "Wvt" }

FUNCTION Main

   /*
   MINIGUI   226   706
   FW   220   692
   Xailer   30   111
   NONE   29   71
   HWGUI   17   45
   T-Gtk   15   45
   GTWVW   12   27
   Wvt   6   16
   */
   LOCAL aSer:={ {226,220,30,29,17,15,12,6},;
      {706,692,111,71,45,45,27,16} }

   DEFINE WINDOW GraphTest ;
         At 0,0 ;
         WIDTH 640 ;
         HEIGHT 480 ;
         TITLE "Graph" ;
         MAIN ;
         ICON "Main" ;
         NOMAXIMIZE nosize ;
         ON INIT DrawBarGraph ( aSer )

      DEFINE BUTTON Button_1
         ROW   405
         COL   50
         CAPTION   'Bars'
         ACTION DrawBarGraph ( aSer )
      END BUTTON

      DEFINE BUTTON Button_2
         ROW   405
         COL   250
         CAPTION   'Lines'
         ACTION DrawLinesGraph ( aSer )
      END BUTTON

      DEFINE BUTTON Button_3
         ROW   405
         COL   450
         CAPTION   'Points'
         ACTION DrawPointsGraph ( aSer )
      END BUTTON

      ON KEY ESCAPE ACTION ThisWindow.Release

   END WINDOW

   GraphTest.Center

   ACTIVATE WINDOW GraphTest

   RETURN NIL

PROCEDURE DrawBarGraph ( aSer )

   ERASE WINDOW GraphTest

   DRAW GRAPH                     ;
      IN WINDOW GraphTest               ;
      AT 20,20                  ;
      TO 400,620                  ;
      TITLE "XACC 2004 Results by GUI"         ;
      TYPE BARS                  ;
      SERIES aSer                  ;
      YVALUES aYValues               ;
      DEPTH 15                  ;
      BARWIDTH 15                  ;
      HVALUES 5                  ;
      SERIENAMES {"Votes","Rates"}            ;
      COLORS { {128,128,255}, {255,102, 10} }         ;
      3DVIEW                      ;
      SHOWGRID                                 ;
      SHOWXVALUES                              ;
      SHOWYVALUES                              ;
      SHOWLEGENDS

   RETURN

PROCEDURE DrawLinesGraph ( aSer )

   ERASE WINDOW GraphTest

   DRAW GRAPH                     ;
      IN WINDOW GraphTest               ;
      AT 20,20                  ;
      TO 400,620                  ;
      TITLE "XACC 2004 Results by GUI"         ;
      TYPE LINES                  ;
      SERIES aSer                  ;
      YVALUES aYValues               ;
      DEPTH 15                  ;
      BARWIDTH 15                  ;
      HVALUES 5                  ;
      SERIENAMES {"Votes","Rates"}            ;
      COLORS { {128,128,255}, {255,102, 10} }         ;
      3DVIEW                      ;
      SHOWGRID                                 ;
      SHOWXVALUES                              ;
      SHOWYVALUES                              ;
      SHOWLEGENDS

   RETURN

PROCEDURE DrawPointsGraph ( aSer )

   ERASE WINDOW GraphTest

   DRAW GRAPH                     ;
      IN WINDOW GraphTest               ;
      AT 20,20                  ;
      TO 400,620                  ;
      TITLE "XACC 2004 Results by GUI"         ;
      TYPE POINTS                  ;
      SERIES aSer                  ;
      YVALUES aYValues               ;
      DEPTH 15                  ;
      BARWIDTH 15                  ;
      HVALUES 5                  ;
      SERIENAMES {"Votes","Rates"}            ;
      COLORS { {128,128,255}, {255,102, 10} }         ;
      3DVIEW                      ;
      SHOWGRID                                 ;
      SHOWXVALUES                              ;
      SHOWYVALUES                              ;
      SHOWLEGENDS

   RETURN
