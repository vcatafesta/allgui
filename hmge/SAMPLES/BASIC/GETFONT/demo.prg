/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
* http://harbourminigui.googlepages.com/
*/

#include "minigui.ch"

FUNCTION Main

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH 640 HEIGHT 480 ;
         TITLE 'Harbour MiniGUI Demo' ;
         MAIN

      DEFINE MAIN MENU
         POPUP 'Common &Dialog Functions'
            ITEM 'GetFont()'   ACTION GetFont_Click()
         END POPUP
      END MENU

   END WINDOW

   Form_1.Center()

   Form_1.Activate()

   RETURN NIL

PROCEDURE GetFont_Click

   LOCAL a

   a := GetFont ( 'Arial' , 12 , .f. , .t. , {0,0,255} , .f. , .f. , 0 )

   IF empty ( a [1] )

      MsgInfo ('Cancelled')

   ELSE

      MsgInfo( a [1] + Str( a [2] ) )

      IF  a [3] == .t.
         MsgInfo ("Bold")
      ELSE
         MsgInfo ("Non Bold")
      ENDIF

      IF  a [4] == .t.
         MsgInfo ("Italic")
      ELSE
         MsgInfo ("Non Italic")
      ENDIF

      MsgInfo ( str( a [5][1]) +str( a [5][2]) +str( a [5][3]), 'Color' )

      IF  a [6] == .t.
         MsgInfo ("Underline")
      ELSE
         MsgInfo ("Non Underline")
      ENDIF

      IF  a [7] == .t.
         MsgInfo ("StrikeOut")
      ELSE
         MsgInfo ("Non StrikeOut")
      ENDIF

      MsgInfo ( str ( a [8] ) , 'Charset' )

   ENDIF

   RETURN

