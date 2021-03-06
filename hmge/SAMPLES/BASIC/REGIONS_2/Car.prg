/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2002-2007 Roberto Lopez <harbourminigui@gmail.com>
* Copyright 2005-2007 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM 'Car Skin Demo'
#define VERSION ' version 1.0'
#define COPYRIGHT ' 2005-2007 Grigory Filatov'

PROCEDURE Main()

   SET MULTIPLE OFF

   SET INTERACTIVECLOSE OFF

   DEFINE WINDOW Form_0 ;
         AT 0,0 ;
         WIDTH 0 HEIGHT 0 ;
         TITLE PROGRAM ;
         ICON 'MAIN' ;
         MAIN NOSHOW ;
         ON INIT CreateSkinedForm(0, 0, .F.) ;
         NOTIFYICON 'MAIN' ;
         NOTIFYTOOLTIP PROGRAM ;
         ON NOTIFYCLICK HideShow()

   END WINDOW

   ACTIVATE WINDOW Form_0

   RETURN

STATIC PROCEDURE CreateSkinedForm( nTop, nLeft, lMinimized )

   LOCAL aWinSize := BmpSize( "CAR" )

   DEFINE WINDOW Form_1 ;
         AT nTop, nLeft ;
         WIDTH aWinSize[1] HEIGHT aWinSize[2] ;
         CHILD ;
         TOPMOST NOCAPTION ;
         NOMINIMIZE NOMAXIMIZE NOSIZE ;
         ON INIT ( ( SET REGION OF Form_1 BITMAP CAR TRANSPARENT COLOR {252, 4, 252} ), ;
         Form_1.Topmost := .f., r_menu(), IF(lMinimized, Form_1.Hide, ) ) ;
         ON GOTFOCUS SetHandCursor( GetControlHandle("Image_1", "Form_1") )

      @ 0,0 IMAGE Image_1 ;
         PICTURE "CAR" ;
         WIDTH Form_1.Width HEIGHT Form_1.Height ;
         ACTION MoveActiveWindow()

   END WINDOW

   IF EMPTY(nTop) .AND. EMPTY(nLeft)
      CENTER WINDOW Form_1
   ENDIF

   ACTIVATE WINDOW Form_1

   RETURN

#define HTCAPTION          2
#define WM_NCLBUTTONDOWN   161

PROCEDURE MoveActiveWindow(hWnd)

   DEFAULT hWnd := GetActiveWindow()

   PostMessage(hWnd, WM_NCLBUTTONDOWN, HTCAPTION, 0)
   RC_Cursor("CATCH")

   RETURN

STATIC PROCEDURE HideShow()

   IF IsWindowVisible( GetFormHandle( "Form_1" ) )
      Form_1.Hide
   ELSE
      Form_1.Topmost := .t.
      Form_1.Show
      Form_1.Topmost := .f.
   ENDIF

   r_menu()

   RETURN

STATIC PROCEDURE r_menu()

   DEFINE NOTIFY MENU OF Form_0
      ITEM IF( IsWindowVisible( GetFormHandle( "Form_1" ) ), '&Hide', '&Show' ) ;
         ACTION HideShow()
      ITEM '&About...'   ACTION ShellAbout( "", PROGRAM + VERSION + CRLF + ;
         "Copyright " + Chr(169) + COPYRIGHT, LoadIconByName( "MAIN", 32, 32 ) )
      SEPARATOR
      ITEM '&Exit'      ACTION Form_0.Release
   END MENU

   RETURN
