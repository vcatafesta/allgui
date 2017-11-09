/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2016 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

/******
*       Template for application
*/

PROCEDURE Main

   SET FONT TO GetDefaultFontName(), GetDefaultFontSize()

   SET DEFAULT ICON TO "MAIN"

   SET CENTERWINDOW RELATIVE PARENT

   DEFINE WINDOW MainWin ;
         MAIN ;
         CLIENTAREA 600, 400 ;
         TITLE 'Template Demo' ;
         BKBRUSH 'PAPER' ;
         ICON "MAIN"

      CreateMainMenu()

      DEFINE STATUSBAR KEYBOARD FONT 'Tahoma' SIZE 9

      END STATUSBAR

      ON KEY ALT+X ACTION { || QuickExit() }

   END WINDOW

   CENTER WINDOW MainWin
   ACTIVATE WINDOW MainWin

   RETURN

   ****** End of Main ******

   /******
   *       CreateMainMenu()
   *       Cteate Main Menu
   */

STATIC PROCEDURE CreateMainMenu

   DEFINE MAIN MENU OF MainWin

      POPUP '&File'
         ITEM '&Child Window' ACTION Child_Click()
         ITEM '&Modal Window' ACTION Modal_Click()
         SEPARATOR
         ITEM 'E&xit' + Chr(9) + 'Alt+X' ACTION { || QuickExit() }
      END POPUP

   END MENU

   RETURN

   ****** End of CreateMainMenu ******

   /******
   *       QuickExit()
   *       Exit from application
   */

STATIC PROCEDURE QuickExit

   QUIT

   RETURN

   ***** End of QuickExit ******

   /******
   *       Child_Click()
   *       Cteate Child Window
   */

PROCEDURE Child_Click

   IF IsWindowDefined ( ChildWin )
      DoMethod ( "ChildWin", "SetFocus" )

      RETURN
   ENDIF

   DEFINE WINDOW ChildWin ;
         CHILD ;
         CLIENTAREA 400, 300 ;
         MINWIDTH 200 ;
         MINHEIGHT 200 ;
         TITLE 'Child Window'

      ON KEY ESCAPE ACTION ThisWindow.Release()

   END WINDOW

   ChildWin.Center()

   ChildWin.Activate()

   RETURN

   ***** End of Child_Click ******

   /******
   *       Modal_Click()
   *       Cteate Modal Window
   */

PROCEDURE Modal_Click

   DEFINE WINDOW ModalWin ;
         MODAL ;
         CLIENTAREA 400, 300 ;
         MINWIDTH 200 ;
         MINHEIGHT 200 ;
         TITLE 'Modal Window'

      ON KEY ESCAPE ACTION ThisWindow.Release()

   END WINDOW

   ModalWin.Center()

   ModalWin.Activate()

   RETURN

   ***** End of Modal_Click ******

