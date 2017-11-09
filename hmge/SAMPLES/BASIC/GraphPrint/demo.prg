/*
* MINIGUI - Harbour Win32 GUI library Demo
* DATA PROVIDED BY NETMARKETSHARE.COM FOR SEPTEMBER 2017
*/

#include "hmg.ch"

// define the static arrays for graph show and print routines
STATIC aSeries, aSerieNames, aColors

FUNCTION Main

   aSeries := { ;
      47.21, ;
      29.09, ;
      5.89, ;
      5.69, ;
      3.84, ;
      3.04, ;
      1.24, ;
      4.01  ;
      }

   aSerieNames := { ;
      "Windows 7", ;
      "Windows 10", ;
      "Windows 8.1", ;
      "Windows XP", ;
      "Mac OS X 10.12", ;
      "Linux", ;
      "Windows 8", ;
      "Other: Mac OS < 10.12, Win Vista, Win NT" ;
      }

   // using of Netscape 216 color's scheme (51 * n)
   aColors := { ;
      { 51, 102, 153 }, ;
      { 51, 153, 51 }, ;
      { 204, 51, 51 }, ;
      { 204, 153, 0 }, ;
      { 51, 153, 204 }, ;
      { 204, 102, 0 }, ;
      { 102, 102, 153 }, ;
      { 0, 51, 102 } ;
      }

   SET FONT TO GetDefaultFontName(), 10

   DEFINE WINDOW m ;
         AT 0, 0 ;
         WIDTH 720 HEIGHT 600 ;
         MAIN ;
         TITLE "Print Pie Graph" ;
         BACKCOLOR { 216, 208, 200 }

      DEFINE BUTTON d
         ROW 10
         COL 10
         CAPTION "Draw"
         ACTION showpie()
      END BUTTON

      DEFINE BUTTON p
         ROW 40
         COL 10
         CAPTION "Print"
         ACTION ( showpie(), printpie() )
      END BUTTON

   END WINDOW

   m.Center()
   m.Activate()

   RETURN NIL

FUNCTION showpie

   ERASE WINDOW m

   Create_CONTEXT_Menu( ThisWindow.Name )

   // initialise a default font name
   IF Empty( _HMG_DefaultFontName )
      _HMG_DefaultFontName := GetDefaultFontName()
   ENDIF

   // initialise a default font size
   IF Empty( _HMG_DefaultFontSize )
      _HMG_DefaultFontSize := GetDefaultFontSize()
   ENDIF

   DEFINE PIE IN WINDOW m
   ROW 10
   COL 160
   BOTTOM 550
   RIGHT 560
   TITLE "Desktop Operating System Market Share"
   SERIES aSeries
   DEPTH 25
   SERIENAMES aSerieNames
   COLORS aColors
   3DVIEW .T.
   SHOWXVALUES .T.
   SHOWLEGENDS .T.
   DATAMASK "99.99"
END PIE

RETURN NIL

FUNCTION printpie

   PRINT GRAPH IN WINDOW m ;
      AT 10, 160 ;
      TO 550, 560 ;
      TITLE "Desktop Operating System Market Share" ;
      TYPE PIE ;
      SERIES aSeries ;
      DEPTH 25 ;
      SERIENAMES aSerieNames ;
      COLORS aColors ;
      3DVIEW ;
      SHOWXVALUES ;
      SHOWLEGENDS DATAMASK "99.99"

   RETURN NIL

PROCEDURE Create_CONTEXT_Menu ( cForm )

   IF IsContextMenuDefined () == .T.
      Release_CONTEXT_Menu ( cForm )
   ENDIF

   IsContextMenuDefined ( .T. )

   DEFINE CONTEXT MENU OF &cForm

      ITEM 'Change Graph Font Name' ACTION ;
         ( _HMG_DefaultFontName := GetFont ( _HMG_DefaultFontName, _HMG_DefaultFontSize, .F., .F., { 0, 0, 0 }, .F., .F., 0 ) [ 1 ], showpie() )

      ITEM 'Change Graph Font Size' ACTION ;
         ( _HMG_DefaultFontSize := GetFont ( _HMG_DefaultFontName, _HMG_DefaultFontSize, .F., .F., { 0, 0, 0 }, .F., .F., 0 ) [ 2 ], showpie() )

   END MENU

   RETURN

PROCEDURE Release_CONTEXT_Menu ( cForm )

   IF IsContextMenuDefined () == .F.
      MsgInfo ( "Context Menu not defined" )

      RETURN
   ENDIF

   IsContextMenuDefined ( .F. )

   RELEASE CONTEXT MENU OF &cForm

   RETURN

FUNCTION IsContextMenuDefined ( lNewValue )

   STATIC IsContextMenuDefined := .F.
   LOCAL lOldValue := IsContextMenuDefined

   IF ISLOGICAL( lNewValue )
      IsContextMenuDefined := lNewValue
   ENDIF

   RETURN lOldValue

