/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
* http://harbourminigui.googlepages.com/
*/

#include "MiniGUI.ch"
#include "i_qhtm.ch"
#include "i_winuser.ch"

PROCEDURE Main

   LOCAL cfile := "winlist.htm"

   IF !qhtm_init()

      RETURN
   ENDIF

   SET EVENTS FUNCTION TO MYEVENTS

   DEFINE WINDOW Form_1 AT 0, 0      ;
         WIDTH 830         ;
         HEIGHT 600         ;
         TITLE "QHTM demo"      ;
         ICON "demo.ico"         ;
         MAIN             ;
         ON MAXIMIZE qhtm_resize()   ;
         ON SIZE qhtm_resize()      ;
         ON RELEASE qhtm_end()      ;
         BACKCOLOR WHITE

      IF !file(cfile)
         cfile := GetFile( { {"HTML files (*.htm)", "*.htm"}, {"All files (*.*)", "*.*"} }, ;
            "Select a file", GetStartupFolder(), , .T. )
      ENDIF

      @ 0,0 QHTM Html_1 ;
         FILE cfile ;
         WIDTH Form_1.Width - GetBorderWidth()*2 ;
         HEIGHT Form_1.Height - GetTitleHeight() - GetBorderHeight()*2 ;
         ON CHANGE {|lParam| QHTM_MessageBox( "The link is: " + QHTM_GetLink( lParam ) ) }

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

   RETURN

PROCEDURE qhtm_resize

   LOCAL width := Form_1.Width - GetBorderWidth()*2, height := Form_1.Height - GetTitleHeight() - GetBorderHeight()*2

   //   Form_1.Html_1.Width := width
   //   Form_1.Html_1.Height := height
   _SetControlSizePos ( "Html_1", "Form_1", 0, 0, width, height )

   RETURN

FUNCTION MyEvents ( hWnd, nMsg, wParam, lParam )

   LOCAL i

   DO CASE

   CASE nMsg == WM_NOTIFY

      i := Ascan ( _HMG_aControlIds , wParam )

      IF i > 0

         IF _HMG_aControlType [i] = "QHTM"

            IF valtype( _HMG_aControlChangeProcedure [i] ) == 'B'
               Eval( _HMG_aControlChangeProcedure [i], lParam )
            ENDIF

         ENDIF

      ENDIF

   OTHERWISE

      RETURN Events ( hWnd, nMsg, wParam, lParam )

   ENDCASE

   RETURN (0)
