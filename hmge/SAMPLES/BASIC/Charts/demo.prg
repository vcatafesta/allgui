/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2008 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

STATIC aSer1, aSer2, aSer3
STATIC aSerName1, aSerName2, aSerName3
STATIC aSerVal1, aSerVal3
STATIC aClrs, nGraphType

PROCEDURE Main

   IF !IsWinNT() .AND. !CheckMDAC()
      MsgStop( 'This Program Runs In Win2000/XP Only!', 'Stop' )

      RETURN
   ENDIF

   aClrs := { RED,;
      LGREEN,;
      YELLOW,;
      BLUE,;
      WHITE,;
      GRAY,;
      FUCHSIA,;
      TEAL,;
      NAVY,;
      MAROON,;
      GREEN,;
      OLIVE,;
      PURPLE,;
      SILVER,;
      AQUA,;
      BLACK,;
      RED,;
      LGREEN,;
      YELLOW,;
      BLUE   }

   DEFINE WINDOW GraphTest ;
         AT 0,0 ;
         WIDTH 640 ;
         HEIGHT 580 ;
         TITLE "Charts ADO Demo by Grigory Filatov" ;
         MAIN ;
         ICON "Chart.ico" ;
         NOMAXIMIZE NOSIZE ;
         BACKCOLOR iif(ISVISTAORLATER(), {220, 220, 220}, Nil) ;
         FONT "Tahoma" SIZE 9 ;
         ON INIT OpenTable()

      DEFINE BUTTON Button_1
         Row   510
         Col   30
         Caption   'Chart &1'
         Action  drawchart_1( aser1 )
      END BUTTON

      DEFINE BUTTON Button_2
         Row   510
         Col   150
         Caption   'Chart &2'
         Action  drawchart_2( aser2 )
      END BUTTON

      DEFINE BUTTON Button_3
         Row   510
         Col   270
         Caption   'Chart &3'
         Action  drawchart_3( aser3 )
      END BUTTON

      DEFINE BUTTON Button_4
         Row   510
         Col   390
         Caption   '&Print'
         Action  PrintGraph( nGraphType )
      END BUTTON

      DEFINE BUTTON Button_5
         Row   510
         Col   510
         Caption   'E&xit'
         Action  GraphTest.Release
      END BUTTON

   END WINDOW

   GraphTest.Center

   ACTIVATE WINDOW GraphTest

   RETURN

PROCEDURE DrawChart_1 ( aSer )

   nGraphType := 1

   ERASE WINDOW GraphTest

   DRAW GRAPH                     ;
      IN WINDOW GraphTest               ;
      AT 20,20                  ;
      TO 500,610                  ;
      TITLE "Population (top 10 values)"         ;
      TYPE BARS                  ;
      SERIES aSer                  ;
      YVALUES aSerVal1               ;
      DEPTH 12                  ;
      BARWIDTH 12                  ;
      HVALUES 10                  ;
      SERIENAMES aSerName1               ;
      COLORS aClrs                  ;
      3DVIEW                      ;
      SHOWXGRID                                 ;
      SHOWXVALUES                              ;
      SHOWLEGENDS LEGENDSWIDTH 70 DATAMASK "9,999,999"

   GraphTest.Button_1.SetFocus

   RETURN

PROCEDURE DrawChart_2 ( aSer )

   nGraphType := 2

   ERASE WINDOW GraphTest

   DRAW GRAPH                     ;
      IN WINDOW GraphTest               ;
      AT 20,130                  ;
      TO 490,500                  ;
      TITLE "Area size (top 10 values)"         ;
      TYPE PIE                  ;
      SERIES aSer                  ;
      DEPTH 15                  ;
      SERIENAMES aSerName2               ;
      COLORS aClrs                  ;
      3DVIEW                      ;
      SHOWXVALUES                              ;
      SHOWLEGENDS

   GraphTest.Button_2.SetFocus

   RETURN

PROCEDURE DrawChart_3 ( aSer )

   nGraphType := 3

   ERASE WINDOW GraphTest

   DRAW GRAPH                     ;
      IN WINDOW GraphTest               ;
      AT 20,0                     ;
      TO 500,590                  ;
      TITLE "Population density (top 20 values)"      ;
      TYPE BARS                  ;
      SERIES aSer                  ;
      YVALUES aSerVal3               ;
      DEPTH 4                     ;
      BARWIDTH 8                  ;
      HVALUES 5                  ;
      SERIENAMES aSerName3               ;
      COLORS aClrs                  ;
      3DVIEW                      ;
      SHOWXGRID                                 ;
      SHOWXVALUES                              ;
      SHOWLEGENDS LEGENDSWIDTH 105 DATAMASK "9 999"

   GraphTest.Button_3.SetFocus

   RETURN

PROCEDURE PrintGraph()

   GraphTest.Button_4.SetFocus

   SWITCH nGraphType
   CASE 1
      PRINT GRAPH                     ;
         IN WINDOW GraphTest               ;
         AT 20,20                  ;
         TO 500,610                  ;
         TITLE "Population (top 10 values)"         ;
         TYPE BARS                  ;
         SERIES aSer1                  ;
         YVALUES aSerVal1               ;
         DEPTH 12                  ;
         BARWIDTH 12                  ;
         HVALUES 10                  ;
         SERIENAMES aSerName1               ;
         COLORS aClrs                  ;
         3DVIEW                      ;
         SHOWXGRID                                 ;
         SHOWXVALUES                              ;
         SHOWLEGENDS LEGENDSWIDTH 70 DATAMASK "9,999,999"   ;
         LIBRARY HBPRINT
      EXIT
   CASE 2
      PRINT GRAPH                     ;
         IN WINDOW GraphTest               ;
         AT 20,130                  ;
         TO 490,500                  ;
         TITLE "Area size (top 10 values)"         ;
         TYPE PIE                  ;
         SERIES aSer2                  ;
         DEPTH 15                  ;
         SERIENAMES aSerName2               ;
         COLORS aClrs                  ;
         3DVIEW                      ;
         SHOWXVALUES                              ;
         SHOWLEGENDS                  ;
         LIBRARY HBPRINT
      EXIT
   CASE 3
      PRINT GRAPH                     ;
         IN WINDOW GraphTest               ;
         AT 20,0                     ;
         TO 500,590                  ;
         TITLE "Population density (top 20 values)"      ;
         TYPE BARS                  ;
         SERIES aSer3                  ;
         YVALUES aSerVal3               ;
         DEPTH 4                     ;
         BARWIDTH 8                  ;
         HVALUES 5                  ;
         SERIENAMES aSerName3               ;
         COLORS aClrs                  ;
         3DVIEW                      ;
         SHOWXGRID                                 ;
         SHOWXVALUES                              ;
         SHOWLEGENDS LEGENDSWIDTH 105 DATAMASK "9 999"      ;
         LIBRARY HBPRINT
   end

   RETURN

PROCEDURE OpenTable

   LOCAL n
   LOCAL Sql
   LOCAL cn := CreateObject("ADODB.Connection")
   LOCAL rs := CreateObject("ADODB.Recordset")

   cn:Open("Provider=Microsoft.Jet.OLEDB.4.0;Data Source=demo.mdb")

   // Request data for Chart 1
   sql := "SELECT TOP 10 * FROM Country ORDER BY Population DESC"

   rs:Open(sql, cn, 2, 3)  // top 10 values

   // One serie data
   aSer1 := Array(10, 1)
   aSerVal1 := Array(10)
   aSerName1 := Array(10)

   n := 0
   rs:MoveFirst()
   DO WHILE !rs:EoF()
      n++
      aSer1[n, 1] := Rs:Fields["Population"]:Value() / 1000
      aSerVal1[n] := Rs:Fields["Name"]:Value()
      aSerName1[n]:= aSerVal1[n]
      rs:MoveNext()
   ENDDO
   rs:Close()

   // Request data for Chart 2
   sql := "SELECT TOP 10 * FROM Country ORDER BY Area DESC"

   rs:Open(sql, cn, 2, 3)  // top 10 values

   // One serie data
   aSer2 := Array(10)
   aSerName2 := Array(10)

   n := 0
   rs:MoveFirst()
   DO WHILE !rs:EoF()
      n++
      aSer2[n] := Rs:Fields["Area"]:Value() / 1000
      aSerName2[n]:= Rs:Fields["Name"]:Value()
      rs:MoveNext()
   ENDDO
   rs:Close()

   // Request data for Chart 3
   sql := "SELECT TOP 20 Name, Population/Area as off FROM Country ORDER BY Population/Area DESC"

   rs:Open(sql, cn, 2, 3)  // top 20 values

   // One serie data
   aSer3 := Array(20, 1)
   aSerVal3 := Array(20)
   aSerName3 := Array(20)

   n := 0
   rs:MoveFirst()
   DO WHILE !rs:EoF()
      n++
      aSer3[n, 1] := Rs:Fields["Off"]:Value()
      aSerVal3[n] := Rs:Fields["Name"]:Value()
      aSerName3[n]:= Transform( aSer3[n, 1], "9 999.999" ) + ' ' + aSerVal3[n]
      rs:MoveNext()
   ENDDO
   rs:Close()

   cn:Close()

   // First chart drawing
   DrawChart_1( aser1 )

   RETURN

STATIC FUNCTION CheckMDAC()

   LOCAL oReg, cKey := ""

   OPEN REGISTRY oReg KEY HKEY_LOCAL_MACHINE ;
      SECTION "Software\CLASSES\MDACVer.Version\CurVer"

   GET VALUE cKey NAME "" OF oReg

   CLOSE REGISTRY oReg

   RETURN !EMPTY(cKey)
