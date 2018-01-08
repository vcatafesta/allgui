/*
* HMG - Harbour Win32 GUI library Demo
*/

#include "hmg.ch"

FUNCTION Main

   LOCAL aSer:={ {14280,20420,12870,25347, 7640}, ;
      { 8350,10315,15870, 5347,12340}, ;
      {12345, -8945,10560,15600,17610} }

   DEFINE WINDOW GraphTest ;
         At 0,0 ;
         WIDTH 640 ;
         HEIGHT 480 ;
         TITLE "Graph" ;
         MAIN ;
         NOMAXIMIZE ;
         ICON "Main" ;
         BACKCOLOR { 255 , 255 , 255 } ;
         ON INIT DrawBarGraph ( aSer ) ;

      DEFINE BUTTON Button_1
         ROW   415
         COL   20
         CAPTION   'Bars'
         ACTION DrawBarGraph ( aSer )
      END BUTTON

      DEFINE BUTTON Button_2
         ROW   415
         COL   185
         CAPTION   'Lines'
         ACTION DrawLinesGraph ( aSer )
      END BUTTON

      DEFINE BUTTON Button_3
         ROW   415
         COL   340
         CAPTION   'Points'
         ACTION DrawPointsGraph ( aSer )
      END BUTTON

      DEFINE BUTTON Button_4
         ROW   415
         COL   500
         CAPTION   'Print'
         ACTION PRINT GRAPH OF GraphTest PREVIEW DIALOG
      END BUTTON

   END WINDOW

   GraphTest.Center

   ACTIVATE WINDOW GraphTest

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
      SHOWLEGENDS                   ;
      NOBORDER

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
      SHOWLEGENDS                   ;
      NOBORDER

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
      SHOWLEGENDS                   ;
      NOBORDER

   RETURN
