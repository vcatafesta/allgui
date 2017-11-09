/*
* MINIGUI - Harbour Win32 GUI library Demo
*/

#include "minigui.ch"

STATIC aSer

FUNCTION Main

   LOCAL lChanged := .t.

   aSer:={ {14280, 20420, 12870, 25347, 7640},;
      { 8350, 10315, 15870, 5347, 12340},;
      {12345, -8945, 10560, 15600, 17610} }

   DEFINE WINDOW GraphTest ;
         At 0,0 ;
         Width 640 ;
         Height 480 ;
         Title "Printing graphs, bars, lines and points" ;
         Main ;
         Icon "Main" ;
         Nomaximize Nosize ;
         Backcolor {216,208,200} ;
         On Init DrawBarGraph ( aSer )

      @ 410,40 COMBOBOX Combo_1 ;
         ITEMS {'Bars','Lines','Points'} ;
         VALUE 1 ;
         ON CHANGE iif(lChanged,escoja(graphtest.combo_1.value),nil) ;
         ON DROPDOWN (lChanged := .f.) ;
         ON CLOSEUP (lChanged := .t.,escoja(graphtest.combo_1.value))

      DEFINE BUTTON Button_1
         Row   410
         Col   260
         Caption   'Print'
         Action  PrintGraph(graphtest.combo_1.value)
      END BUTTON

      DEFINE BUTTON Button_2
         Row   410
         Col   460
         Caption   'Exit'
         Action  GraphTest.Release
      END BUTTON

   END WINDOW

   CENTER WINDOW GraphTest
   ACTIVATE WINDOW GraphTest

   RETURN NIL

PROCEDURE escoja(op)

   IF op=1
      drawbargraph( aser)
   ELSEIF op=2
      drawlinesgraph( aser )
   ELSE
      drawpointsgraph( aser )
   ENDIF

   RETURN

PROCEDURE DrawBarGraph ( aSer )

   ERASE WINDOW GraphTest

   DRAW GRAPH                     ;
      IN WINDOW GraphTest               ;
      AT 20,20                  ;
      TO 400,610                  ;
      TITLE "Sales and Product"            ;
      TYPE BARS                  ;
      SERIES aSer                  ;
      YVALUES {"Jan","Feb","Mar","Apr","May"}         ;
      DEPTH 15                  ;
      BARWIDTH 15                  ;
      HVALUES 5                  ;
      SERIENAMES {"Serie 1","Serie 2","Serie 3"}      ;
      COLORS { {128,128,255}, {255,102, 10}, {55,201, 48} }   ;
      3DVIEW                      ;
      SHOWGRID                                 ;
      SHOWXVALUES                              ;
      SHOWYVALUES                              ;
      SHOWLEGENDS SHOWDATAVALUES DATAMASK "999,999"

   RETURN

PROCEDURE DrawLinesGraph ( aSer )

   ERASE WINDOW GraphTest

   DRAW GRAPH                     ;
      IN WINDOW GraphTest               ;
      AT 20,20                  ;
      TO 400,610                  ;
      TITLE "Sales and Product"            ;
      TYPE LINES                  ;
      SERIES aSer                  ;
      YVALUES {"Jan","Feb","Mar","Apr","May"}         ;
      DEPTH 15                  ;
      BARWIDTH 15                  ;
      HVALUES 5                  ;
      SERIENAMES {"Serie 1","Serie 2","Serie 3"}      ;
      COLORS { {128,128,255}, {255,102, 10}, {55,201, 48} }   ;
      3DVIEW                      ;
      SHOWGRID                                 ;
      SHOWXVALUES                              ;
      SHOWYVALUES                              ;
      SHOWLEGENDS SHOWDATAVALUES DATAMASK "999,999"

   RETURN

PROCEDURE DrawPointsGraph ( aSer )

   ERASE WINDOW GraphTest

   DRAW GRAPH                     ;
      IN WINDOW GraphTest               ;
      AT 20,20                  ;
      TO 400,610                  ;
      TITLE "Sales and Product"            ;
      TYPE POINTS                  ;
      SERIES aSer                  ;
      YVALUES {"Jan","Feb","Mar","Apr","May"}         ;
      DEPTH 15                  ;
      BARWIDTH 15                  ;
      HVALUES 5                  ;
      SERIENAMES {"Serie 1","Serie 2","Serie 3"}      ;
      COLORS { {128,128,255}, {255,102, 10}, {55,201, 48} }   ;
      3DVIEW                      ;
      SHOWGRID                                 ;
      SHOWXVALUES                              ;
      SHOWYVALUES                              ;
      SHOWLEGENDS SHOWDATAVALUES DATAMASK "99,999"

   RETURN

PROCEDURE PrintGraph(op)

   IF op=1
      PRINT GRAPH                     ;
         IN WINDOW GraphTest               ;
         AT 20,20                  ;
         TO 400,610                  ;
         TITLE "Sales and Product"            ;
         TYPE BARS                  ;
         SERIES aSer                  ;
         YVALUES {"Jan","Feb","Mar","Apr","May"}         ;
         DEPTH 15                  ;
         BARWIDTH 15                  ;
         HVALUES 5                  ;
         SERIENAMES {"Serie 1","Serie 2","Serie 3"}      ;
         COLORS { {128,128,255}, {255,102, 10}, {55,201, 48} }   ;
         3DVIEW                      ;
         SHOWGRID                                 ;
         SHOWXVALUES                              ;
         SHOWYVALUES                              ;
         SHOWLEGENDS SHOWDATAVALUES DATAMASK "999,999"
   ELSEIF op=2
      PRINT GRAPH                     ;
         IN WINDOW GraphTest               ;
         AT 20,20                  ;
         TO 400,610                  ;
         TITLE "Sales and Product"            ;
         TYPE LINES                  ;
         SERIES aSer                  ;
         YVALUES {"Jan","Feb","Mar","Apr","May"}         ;
         DEPTH 15                  ;
         BARWIDTH 15                  ;
         HVALUES 5                  ;
         SERIENAMES {"Serie 1","Serie 2","Serie 3"}      ;
         COLORS { {128,128,255}, {255,102, 10}, {55,201, 48} }   ;
         3DVIEW                      ;
         SHOWGRID                                 ;
         SHOWXVALUES                              ;
         SHOWYVALUES                              ;
         SHOWLEGENDS SHOWDATAVALUES DATAMASK "999,999"
   ELSE
      PRINT GRAPH                     ;
         IN WINDOW GraphTest               ;
         AT 20,20                  ;
         TO 400,610                  ;
         TITLE "Sales and Product"            ;
         TYPE POINTS                  ;
         SERIES aSer                  ;
         YVALUES {"Jan","Feb","Mar","Apr","May"}         ;
         DEPTH 15                  ;
         BARWIDTH 15                  ;
         HVALUES 5                  ;
         SERIENAMES {"Serie 1","Serie 2","Serie 3"}      ;
         COLORS { {128,128,255}, {255,102, 10}, {55,201, 48} }   ;
         3DVIEW                      ;
         SHOWGRID                                 ;
         SHOWXVALUES                              ;
         SHOWYVALUES                              ;
         SHOWLEGENDS SHOWDATAVALUES DATAMASK "99,999"
   ENDIF

   RETURN

