/*
* MiniGUI Demo
* (c) 2005 Grigory Filatov
*/

#include "minigui.ch"

FUNCTION Main

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH 400 ;
         HEIGHT 200 ;
         TITLE 'Hello World!' ;
         MAIN ;
         ON MOUSECLICK MoveActiveWindow()

      DEFINE LABEL Label_1
         ROW   10
         COL   10
         VALUE 'Click Me!'
         ACTION MoveActiveWindow()
         OnMouseHover FileCursor( "hand32-32.cur" )
      END LABEL

      ON KEY ESCAPE ACTION ThisWindow.Release

   END WINDOW

   Form_1.Cursor := "hand32-32.cur"

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

   RETURN NIL

#define HTCAPTION          2
#define WM_NCLBUTTONDOWN   161

PROCEDURE MoveActiveWindow( hWnd )

   DEFAULT hWnd := GetActiveWindow()

   PostMessage( hWnd, WM_NCLBUTTONDOWN, HTCAPTION, 0 )

   FileCursor( "Grabbed32-32.cur" )

   RETURN
