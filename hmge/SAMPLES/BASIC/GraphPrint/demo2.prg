/*
* MINIGUI - Harbour Win32 GUI library Demo
*/

#include "minigui.ch"

#define DGREEN         {  0, 128, 0}
#define DCYAN          {  0, 128, 128}
#define LGRAY          {192, 192, 192}
#define DBLUE          {  0,   0, 128}
#define CYAN           {  0, 255, 255}

STATIC aSer, aColors, aYvals, cTitle

FUNCTION Main

   cTitle:="Salesperson : Steve Von Denis"
   aSer:={ {72000, 55000, 118000, 92000, 70000, 19500, 115000, 99000, 94000, 72000, 32000, 6000} }
   aColors:={ BLUE, DGREEN, DCYAN, RED, PURPLE, BROWN, LGRAY, GRAY, DBLUE, GREEN, CYAN, FUCHSIA }

   aYvals := Array(12)
   aeval(aYvals, {|x,i| aYvals[i] := left(cmonth(stod(str(year(date()),4)+strzero(i,2)+"01")),3)})

   DEFINE WINDOW GraphTest ;
         At 0,0 ;
         WIDTH 800 ;
         HEIGHT 620 ;
         TITLE "Printing bar" ;
         Main ;
         ICON "Main" ;
         Nomaximize Nosize ;
         BACKCOLOR {216,208,200} ;
         On Init DrawBarGraph()

      @ 552,40 COMBOBOX Combo_1 ;
         ITEMS {'MiniPrint', 'HbPrinter'} ;
         VALUE 1

      DEFINE BUTTON Button_1
         ROW   550
         COL   260
         Caption   'Print'
         Action  PrintGraph(GraphTest.Combo_1.Value)
      END BUTTON

      DEFINE BUTTON Button_2
         ROW   550
         COL   460
         Caption   'Exit'
         Action  GraphTest.Release
      END BUTTON

   END WINDOW

   CENTER WINDOW GraphTest
   ACTIVATE WINDOW GraphTest

   RETURN NIL

PROCEDURE DrawBarGraph

   ERASE WINDOW GraphTest

   DRAW GRAPH                     ;
      IN WINDOW GraphTest               ;
      AT 10,10                  ;
      TO 545,785                  ;
      TITLE cTitle                  ;
      TYPE BARS                  ;
      SERIES aSer                  ;
      YVALUES aYvals                  ;
      DEPTH 15                  ;
      BARWIDTH 5                  ;
      HVALUES 12.5                  ;
      SERIENAMES {"Series 1"}               ;
      COLORS aColors                  ;
      3DVIEW                     ;
      SHOWXGRID                                 ;
      SHOWXVALUES                              ;
      SHOWYVALUES                              ;
      DATAMASK "999,999"

   RETURN

PROCEDURE PrintGraph( nlib )

   IF nlib == 1
      PRINT GRAPH                     ;
         IN WINDOW GraphTest               ;
         AT 10,10                  ;
         TO 545,785                  ;
         TITLE cTitle                  ;
         TYPE BARS                  ;
         SERIES aSer                  ;
         YVALUES aYvals                  ;
         DEPTH 15                  ;
         BARWIDTH 5                  ;
         HVALUES 12.5                  ;
         SERIENAMES {"Series 1"}               ;
         COLORS aColors                  ;
         3DVIEW                     ;
         SHOWXGRID                                 ;
         SHOWXVALUES                              ;
         SHOWYVALUES                              ;
         DATAMASK "999,999"
   ELSE
      PRINT GRAPH                     ;
         IN WINDOW GraphTest               ;
         AT 10,10                  ;
         TO 545,785                  ;
         TITLE cTitle                  ;
         TYPE BARS                  ;
         SERIES aSer                  ;
         YVALUES aYvals                  ;
         DEPTH 15                  ;
         BARWIDTH 5                  ;
         HVALUES 12.5                  ;
         SERIENAMES {"Series 1"}               ;
         COLORS aColors                  ;
         3DVIEW                     ;
         SHOWXGRID                                 ;
         SHOWXVALUES                              ;
         SHOWYVALUES                              ;
         DATAMASK "999,999" LIBRARY HBPRINT
   ENDIF

   RETURN
