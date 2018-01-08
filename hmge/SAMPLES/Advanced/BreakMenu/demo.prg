/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
* http://harbourminigui.googlepages.com/
* BreakMenu demo
* (c) 2006 Vladimir Chumachenko <ChVolodymyr@yandex.ru>
*  HMG 1.0 Experimental Build 17
*/

#include "minigui.ch"

PROCEDURE Main

   DEFINE WINDOW Form_1 ;
         At 0, 0 ;
         WIDTH 400 ;
         HEIGHT 200 ;
         TITLE 'Menu Break Test' ;
         MAIN ;
         NotifyIcon 'demo.ico'

      DEFINE MAIN MENU

         POPUP 'File'

            Item 'Open'      Action MsgInfo ( 'File:Open'  )
            Item 'Save'      Action MsgInfo ( 'File:Save'  )
            Item 'Print'      Action MsgInfo ( 'File:Print' )
            Item 'Save As...'   Action MsgInfo ( 'File:Save As' ) Disabled
            SEPARATOR
            Item 'Exit' Action Form_1.Release

         END POPUP

         POPUP 'Test'
            Item 'Item 1' Action MsgInfo ( 'Item 1' )
            Item 'Item 2' Action MsgInfo ( 'Item 2' )
            Item 'Item 3' Action MsgInfo ( 'Item 3' )

            // Remark:
            // Menu Item with BreakMenu clause begin a new column

            Item 'Item 3.1' Action MsgInfo ( 'Item 3.1' ) BreakMenu Separator
            Item 'Item 3.2' Action MsgInfo ( 'Item 3.2' )
            SEPARATOR
            Item 'Item 3.3' Action MsgInfo ( 'Item 3.3' )

            MENUITEM 'Item 3.3.1' Action MsgInfo ( 'Item 3.3.1' ) BreakMenu
            MENUITEM 'Item 3.3.2' Action MsgInfo ( 'Item 3.3.2' )

         END POPUP

      END MENU

      DEFINE CONTEXT menu
         Item 'Open'   Action MsgInfo ( 'File:Open'  )

         POPUP 'Save'
            Item 'Save'    Action MsgInfo ( 'File:Save'  )
            Item 'Save As...' Action MsgInfo ( 'File:Save As' ) Disabled
         END POPUP

         Item 'Print'   Action MsgInfo ( 'File:Print' )
         SEPARATOR
         Item 'Exit'   Action Form_1.Release

         Item 'Item 1' Action MsgInfo ( 'Item 1' ) BreakMenu Separator
         Item 'Item 2' Action MsgInfo ( 'Item 2' )
         Item 'Item 3' Action MsgInfo ( 'Item 3' )

      END MENU

      Define notify menu
         Item '1st file' Action MsgInfo ( '1st file opened' )
         Item '2nd file' Action MsgInfo ( '2nd file opened' )

         Item 'About' Action MsgInfo ( 'About dialog' ) BreakMenu Separator
         SEPARATOR
         Item 'Options' Action MsgInfo ( 'Options dialog' )
         SEPARATOR
         Item 'Exit' Action Form_1.Release

      END MENU

   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

   RETURN
