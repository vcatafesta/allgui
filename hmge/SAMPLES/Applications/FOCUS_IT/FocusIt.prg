/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2003-2012 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM 'Focus It'
#define COPYRIGHT ' Grigory Filatov, 2003-2012'

STATIC hActiveWnd := 0
STATIC lOnTop := .T.

FUNCTION Main()

   LOCAL bAction

   SET MULTIPLE OFF

   SET GLOBAL HOTKEYS ON

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH 0 HEIGHT 0 ;
         TITLE PROGRAM ;
         MAIN NOSHOW ;
         NOTIFYICON "MAIN" ;
         NOTIFYTOOLTIP PROGRAM + ": Right Click for Menu" ;
         ON NOTIFYCLICK ( lOnTop := ! lOnTop, ;
         Form_1.Timer_1.Enabled := ! Form_1.Timer_1.Enabled, ;
         Form_1.NotifyIcon := IF(Form_1.Timer_1.Enabled, "MAIN", "STOP"), ;
         Form_1.OnTop.Checked := lOnTop )

      bAction := _GetNotifyIconLeftClick ( Application.FormName )

      DEFINE NOTIFY MENU
         ITEM 'On &Top Focused Window' + Chr(9) + 'Shift+Esc' ;
            ACTION Eval( bAction ) NAME OnTop CHECKED
         SEPARATOR
         ITEM '&Mail to author...' ;
            ACTION ShellExecute(0, "open", "rundll32.exe", ;
            "url.dll,FileProtocolHandler " + ;
            "mailto:gfilatov@inbox.ru?cc=&bcc=" + ;
            "&subject=Focus%20It%20Feedback:" + ;
            "&body=How%20are%20you%2C%20Grigory%3F", , 1)
         ITEM '&About...'   ACTION ShellAbout( "About " + PROGRAM + "#", PROGRAM + ' version 1.1' + ;
            CRLF + "Copyright " + Chr(169) + COPYRIGHT, LoadTrayIcon(GetInstance(), "MAIN", 32, 32) )
         SEPARATOR
         ITEM 'E&xit'   ACTION Form_1.Release
      END MENU

      // Define global hotkey
      ON KEY SHIFT+ESCAPE ACTION Eval( bAction )

      DEFINE TIMER Timer_1 INTERVAL 250 ACTION SetActiveWindow()

   END WINDOW

   ACTIVATE WINDOW Form_1

   RETURN NIL

FUNCTION SetActiveWindow()

   LOCAL hWnd := GetWindowFromPoint()

   IF !EMPTY( hWnd ) .AND. hActiveWnd # hWnd .AND. IsCursorOnDesktop( GetCursorPos() )

      IF lOnTop
         SetWindowPos( hActiveWnd, -2, 0, 0, 0, 0, 3 )
         SetWindowPos( hWnd, -1, 0, 0, 0, 0, 3 )
      ENDIF

      hActiveWnd := hWnd

      SetForegroundWindow( hWnd )

   ENDIF

   RETURN NIL

FUNCTION IsCursorOnDesktop( aCursorPos )

   LOCAL aAreaDesk := GetDesktopArea()

   RETURN ( aCursorPos[1] > aAreaDesk[1] .and. aCursorPos[1] > aAreaDesk[2] .and. ;
      aCursorPos[2] < aAreaDesk[3] .and. aCursorPos[2] < aAreaDesk[4] )

FUNCTION _GetNotifyIconLeftClick ( FormName )

   LOCAL i := GetFormIndex ( FormName )

   RETURN ( _HMG_aFormNotifyIconLeftClick [i] )

#pragma BEGINDUMP

#include <windows.h>

#include "hbapi.h"

#ifdef __XHARBOUR__
   #define HB_STORNI( n, x, y ) hb_storni( n, x, y )
#else
   #define HB_STORNI( n, x, y ) hb_storvni( n, x, y )
#endif

HB_FUNC ( GETWINDOWFROMPOINT )
{
   HWND hWnd;
   POINT pt;

   GetCursorPos(&pt);

   hWnd = WindowFromPoint(pt);

   if ( hWnd != NULL )
      hb_retnl ( (LONG) hWnd );
   else
      hb_retnl ( 0 );
}

HB_FUNC ( GETDESKTOPAREA )
{
   RECT rect;
   SystemParametersInfo( SPI_GETWORKAREA, 1, &rect, 0 );

   hb_reta(4);
   HB_STORNI( (INT) rect.top, -1, 1 );
   HB_STORNI( (INT) rect.left, -1, 2 );
   HB_STORNI( (INT) rect.bottom, -1, 3 );
   HB_STORNI( (INT) rect.right, -1, 4 );
}

#pragma ENDDUMP
