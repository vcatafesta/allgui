/*
* MINIGUI - Harbour Win32 GUI library Demo
*/

#include "minigui.ch"

STATIC aYValues := { "MINIGUI", "FW", "Xailer", "None", "HWGUI", "T-Gtk", "GTWVW", "Wvt" }, ;
   lShowData := .f., nGraph := 1

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
         Icon "Graph.ico" ;
         nomaximize nosize ;
         On Init DrawBarGraph ( aSer )

      DEFINE BUTTON Button_1
         Row   405
         Col   40
         Caption   'Bars'
         Action DrawBarGraph ( aSer )
      END BUTTON

      DEFINE BUTTON Button_2
         Row   405
         Col   180
         Caption   'Lines'
         Action DrawLinesGraph ( aSer )
      END BUTTON

      DEFINE BUTTON Button_3
         Row   405
         Col   320
         Caption   'Points'
         Action DrawPointsGraph ( aSer )
      END BUTTON

      Define CheckButton Button_4
         Row   405
         Col   460
         Width   120
         Caption   'Show Data Values'
         OnChange ( lShowData := !lShowData, ;
            if(nGraph = 1, DrawBarGraph ( aSer ), ;
            if(nGraph = 2, DrawLinesGraph ( aSer ), ;
            DrawPointsGraph ( aSer ))) )
      END CheckButton

      ON KEY ESCAPE ACTION ThisWindow.Release

   END WINDOW

   GraphTest.Center

   ACTIVATE WINDOW GraphTest

   RETURN NIL

PROCEDURE DrawBarGraph ( aSer )

   nGraph := 1

   ERASE WINDOW GraphTest

   DEFINE GRAPH IN WINDOW GraphTest

   ROW 20
   COL 20
   BOTTOM 400
   RIGHT 620

   TITLE "XACC 2004 Results by GUI"
   GRAPHTYPE BARS
   SERIES aSer
   YVALUES aYValues
   DEPTH 15
   BARWIDTH 15
   HVALUES 5
   SERIENAMES {"Votes","Rates"}
   COLORS { {128,128,255}, {255,102, 10} }
   3DVIEW .T.
   SHOWGRID .T.
   SHOWXVALUES .T.
   SHOWYVALUES .T.
   SHOWLEGENDS .T.
   DATAMASK "999"
   SHOWDATAVALUES lShowData

END GRAPH

RETURN

PROCEDURE DrawLinesGraph ( aSer )

   nGraph := 2

   ERASE WINDOW GraphTest

   DEFINE GRAPH IN WINDOW GraphTest

   ROW 20
   COL 20
   BOTTOM 400
   RIGHT 620

   TITLE "XACC 2004 Results by GUI"
   GRAPHTYPE LINES
   SERIES aSer
   YVALUES aYValues
   DEPTH 15
   BARWIDTH 15
   HVALUES 5
   SERIENAMES {"Votes","Rates"}
   COLORS { {128,128,255}, {255,102, 10} }
   3DVIEW .T.
   SHOWGRID .T.
   SHOWXVALUES .T.
   SHOWYVALUES .T.
   SHOWLEGENDS .T.
   DATAMASK "999"
   SHOWDATAVALUES lShowData

END GRAPH

RETURN

PROCEDURE DrawPointsGraph ( aSer )

   nGraph := 3

   ERASE WINDOW GraphTest

   DEFINE GRAPH IN WINDOW GraphTest

   ROW 20
   COL 20
   BOTTOM 400
   RIGHT 620

   TITLE "XACC 2004 Results by GUI"
   GRAPHTYPE POINTS
   SERIES aSer
   YVALUES aYValues
   DEPTH 15
   BARWIDTH 15
   HVALUES 5
   SERIENAMES {"Votes","Rates"}
   COLORS { {128,128,255}, {255,102, 10} }
   3DVIEW .T.
   SHOWGRID .T.
   SHOWXVALUES .T.
   SHOWYVALUES .T.
   SHOWLEGENDS .T.
   DATAMASK "999"
   SHOWDATAVALUES lShowData

END GRAPH

RETURN
