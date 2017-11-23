/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
* http://harbourminigui.googlepages.com/
*/

#include "MiniGUI.ch"
#include "i_qhtm.ch"
#include "i_winuser.ch"

PROCEDURE Main

   LOCAL cfile := "about.htm"
   LOCAL cHtml := Memoread( cfile )

   IF !qhtm_init()

      RETURN
   ENDIF

   SET EVENTS FUNCTION TO MYEVENTS

   DEFINE WINDOW Form_1 AT 0, 0      ;
         WIDTH 415         ;
         HEIGHT 230         ;
         TITLE "QHTM demo"      ;
         ICON "demo.ico"         ;
         MAIN NOMAXIMIZE NOSIZE      ;
         ON RELEASE qhtm_end()

      IF !file(cfile)
         cfile := GetFile( { {"HTML files (*.htm)", "*.htm"}, {"All files (*.*)", "*.*"} }, ;
            "Select a file", GetStartupFolder(), , .T. )
      ENDIF

      @ 10,12 QHTM Html_1 ;
         VALUE cHtml ;
         WIDTH Form_1.Width - 28 ;
         HEIGHT Form_1.Height - GetTitleHeight() - 32 ;
         ON CHANGE {|lParam| QHTM_MessageBox( "The link is: " + QHTM_GetLink( lParam ) ) } ;
         BORDER
   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

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
