/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2002-08 Roberto Lopez <harbourminigui@gmail.com>
* http://harbourminigui.googlepages.com/
* Copyright 2005-2008 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"
#include "resource.h"

#define PROGRAM 'Timer'
#define VERSION ' version 1.1'
#define COPYRIGHT ' Grigory Filatov, 2005-2008'

#define IDOK                1
#define IDCANCEL            2

STATIC lBlock := .F.
STATIC SoundFileName := ""
STATIC Description := ""

PROCEDURE Main()

   SET MULTIPLE OFF WARNING

   SoundFileName += GetWindowsFolder() + "\Media\Ding.wav"
   Description += "Warning !"

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH 0 HEIGHT 0 ;
         TITLE PROGRAM ;
         MAIN NOSHOW ;
         NOTIFYICON IDI_ICON ;
         NOTIFYTOOLTIP PROGRAM ;
         ON NOTIFYCLICK Settings()

      DEFINE NOTIFY MENU
         ITEM '&About...'   ACTION ShellAbout( "", ;
            PROGRAM + VERSION + CRLF + ;
            IF(IsXPThemeActive(), "", "Copyright ") + Chr(169) + COPYRIGHT, ;
            LoadMainIcon(GetInstance(), IDI_ICON) )
         SEPARATOR
         ITEM 'E&xit'      ACTION Form_1.Release
      END MENU

   END WINDOW

   Form_1.NotifyTooltip := PROGRAM + ' is OFF'

   ACTIVATE WINDOW Form_1

   RETURN

PROCEDURE Settings()

   IF lBlock == .T.

      RETURN
   ENDIF

   DEFINE DIALOG Form_2 OF Form_1 ;
      RESOURCE IDD_DIALOG ;
      ON INIT { |hDlg| lBlock := .T., SetForegroundWindow(hDlg) } ;
      ON RELEASE lBlock := .F.

   REDEFINE BUTTON Btn_1 ID IDOK ;
      ACTION OnOK()

   REDEFINE BUTTON Btn_2 ID IDCANCEL ;
      ACTION ( ;
      Form_1.NotifyTooltip := PROGRAM + ' is ' + ;
      iif( IsControlDefined( Timer_1, Form_1 ) .and. Form_1.Timer_1.Enabled, 'ON', 'OFF' ), ;
      _ReleaseWindow ( 'Form_2' ) )

   REDEFINE BUTTON Btn_3 ID IDC_QUIT ;
      ACTION _ReleaseWindow ( 'Form_1' )

   REDEFINE TEXTBOX TextBox_1 ID IDC_TIME ;
      VALUE 5 NUMERIC

   REDEFINE TEXTBOX TextBox_2 ID IDC_DESCRIPTION ;
      VALUE Description

   REDEFINE TEXTBOX TextBox_3 ID IDC_FILE ;
      VALUE SoundFileName

   REDEFINE BUTTON Btn_4 ID IDC_BROWSE ;
      ACTION OnBrowseForFile()

   REDEFINE BUTTON Btn_5 ID IDC_TEST ;
      ACTION OnTest()

END DIALOG

RETURN

PROCEDURE OnOK()

   LOCAL time := Form_2.TextBox_1.Value

   IF IsControlDefined( Timer_1, Form_1 )
      Form_1.Timer_1.Value := time * 60000
      Form_1.Timer_1.Enabled := .T.
   ELSE
      DEFINE TIMER Timer_1 OF Form_1 INTERVAL time * 60000 ACTION TimerAction() ONCE
   ENDIF

   Form_1.NotifyTooltip := PROGRAM + ' is ON'
   Description := Form_2.TextBox_2.Value

   _ReleaseWindow ( 'Form_2' )

   RETURN

PROCEDURE OnBrowseForFile()

   LOCAL cFile := GetFile( { {"Audio files (*.wav)", "*.wav"}, {"All files (*.*)", "*.*"} }, ;
      "Select a sound", cFilePath(SoundFileName), , .T. )

   IF File( cFile )
      SoundFileName := cFile
      Form_2.TextBox_3.Value := SoundFileName
   ENDIF

   RETURN

PROCEDURE OnTest()

   IF Empty( SoundFileName )
      PlayAsterisk()
   ELSE
      PLAY WAVE SoundFileName
   ENDIF

   RETURN

PROCEDURE TimerAction()

   IF Empty( SoundFileName )
      PlayAsterisk()
   ELSE
      PLAY WAVE SoundFileName
   ENDIF

   MsgAlert( Description, "Timer" )
   Form_1.NotifyTooltip := PROGRAM + ' is OFF'

   RETURN

#pragma BEGINDUMP

#include <mgdefs.h>

HB_FUNC( LOADMAINICON )
{
   HICON himage;
   HINSTANCE hInstance  = ( HINSTANCE ) HB_PARNL( 1 );  // handle to application instance
   WORD      wIconName  = ( WORD )      hb_parni( 2 );  // resource identifier

   himage = ( HICON ) LoadImage( hInstance, MAKEINTRESOURCE (wIconName), IMAGE_ICON,
            0, 0, LR_DEFAULTCOLOR );

   HB_RETNL( ( LONG_PTR ) himage );
}

#pragma ENDDUMP

