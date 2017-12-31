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
         Width 640 ;
         Height 480 ;
         Title "Graph" ;
         Main ;
         Icon "Main" ;
         nomaximize nosize ;
         On Init DrawBarGraph ( aSer )

      DEFINE BUTTON Button_1
         Row   405
         Col   50
         Caption   'Bars'
         Action DrawBarGraph ( aSer )
      END BUTTON

      DEFINE BUTTON Button_2
         Row   405
         Col   250
         Caption   'Lines'
         Action DrawLinesGraph ( aSer )
      END BUTTON

      DEFINE BUTTON Button_3
         Row   405
         Col   450
         Caption   'Points'
         Action DrawPointsGraph ( aSer )
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
