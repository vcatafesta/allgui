/*
* MiniGUI DLL Demo
* Sample for using NirCmd DLL
* For more information about NirCmd:
* http://www.nirsoft.net/utils/nircmd.html
* (c) 2010-2016 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"
#include "hbdyn.ch"

PROCEDURE Main

   SET HELPFILE TO 'NirCmd.chm'

   SET FONT TO _GetSysFont(), 9

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH 400 ;
         HEIGHT 230 + iif(IsWinXPorLater(), GetBorderHeight(), 0) ;
         TITLE 'NirCmd DLL Test' ;
         ICON 'NirCmd.ico' ;
         MAIN ;
         ON INTERACTIVECLOSE MsgYesNo ( 'Are You Sure ?', 'Exit' )

      DEFINE BUTTON Button_1
         ROW   10
         COL   10
         WIDTH   170
         CAPTION 'Open CD-ROM Door'
         ACTION OpenCDRom_Click()
      END BUTTON

      DEFINE BUTTON Button_2
         ROW   40
         COL   10
         WIDTH   170
         CAPTION 'Close CD-ROM Door'
         ACTION CloseCDRom_Click()
      END BUTTON

      DEFINE BUTTON Button_3
         ROW   70
         COL   10
         WIDTH   170
         CAPTION 'Mute System Volume'
         ACTION MuteVolume_Click()
      END BUTTON

      DEFINE BUTTON Button_4
         ROW   100
         COL   10
         WIDTH   170
         CAPTION 'Unmute System Volume'
         ACTION UnmuteVolume_Click()
      END BUTTON

      DEFINE BUTTON Button_5
         ROW   130
         COL   10
         WIDTH   170
         IF IsWinXPorLater()
            CAPTION 'Show the task manager'
            ACTION TaskManager_Click()
         ELSE
            CAPTION 'Turn Monitor Off'
            ACTION MonitorOff_Click()
         ENDIF
      END BUTTON

      DEFINE BUTTON Button_5a
         ROW   160
         COL   10
         WIDTH   170
         CAPTION 'Save screenshot in clipboard'
         ACTION savescreenshot_Click()
      END BUTTON

      DEFINE BUTTON Button_6
         ROW   10
         COL   200
         WIDTH   150
         CAPTION 'Start the screen saver'
         ACTION StartSS_Click()
      END BUTTON

      DEFINE BUTTON Button_7
         ROW   40
         COL   200
         WIDTH   150
         CAPTION 'Disable the screen saver'
         ACTION DisableSS_Click()
      END BUTTON

      DEFINE BUTTON Button_8
         ROW   70
         COL   200
         WIDTH   150
         CAPTION 'Enable the screen saver'
         ACTION EnableSS_Click()
      END BUTTON

      DEFINE BUTTON Button_9
         ROW   100
         COL   200
         WIDTH   150
         CAPTION 'Clear the clipboard'
         ACTION ClearClipboard_Click()
      END BUTTON

      DEFINE BUTTON Button_10
         ROW   130
         COL   200
         WIDTH   150
         CAPTION 'Display a tray balloon'
         ACTION TrayBalloon_Click()
      END BUTTON

      DEFINE BUTTON Button_10a
         ROW   160
         COL   200
         WIDTH   150
         IF IsWinXPorLater()
            CAPTION 'Flash this window'
            ACTION FlashWin_Click()
         ELSE
            CAPTION 'Cancel'
            ACTION ThisWindow.Release()
         ENDIF
      END BUTTON

      ON KEY F1 ACTION DISPLAY HELP MAIN
      ON KEY ESCAPE ACTION ThisWindow.Release()

   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

   RETURN

PROCEDURE OpenCDRom_Click()

   DoNirCmd( "cdrom open" )

   RETURN

PROCEDURE CloseCDRom_Click()

   DoNirCmd( "cdrom close" )

   RETURN

PROCEDURE MuteVolume_Click()

   DoNirCmd( "mutesysvolume 1" )

   RETURN

PROCEDURE UnmuteVolume_Click()

   DoNirCmd( "mutesysvolume 0" )

   RETURN

PROCEDURE MonitorOff_Click()

   MsgAlert('Monitor will be off for 10 seconds!', 'Warning')
   DoNirCmd( "monitor off" )
   inkey(10)
   DoNirCmd( "monitor on" )

   RETURN

PROCEDURE StartSS_Click()

   DoNirCmd( "screensaver" )

   RETURN

PROCEDURE EnableSS_Click()

   DoNirCmd( [regsetval sz "HKCU\control panel\desktop" "ScreenSaveActive" 1] )

   RETURN

PROCEDURE DisableSS_Click()

   DoNirCmd( [regsetval sz "HKCU\control panel\desktop" "ScreenSaveActive" 0] )

   RETURN

PROCEDURE ClearClipboard_Click()

   DoNirCmd( "clipboard clear" )

   RETURN

PROCEDURE TrayBalloon_Click()

   EXECUTE FILE "nircmd.exe" PARAMETERS [trayballoon "Hello" "This is the text that will be appear inside the balloon!" "shell32.dll,-154" 10000]

   RETURN

PROCEDURE TaskManager_Click()

   EXECUTE FILE "nircmd.exe" PARAMETERS "sendkeypress ctrl+shift+esc"

   RETURN

PROCEDURE savescreenshot_Click()

   Form_1.Minimize
   EXECUTE FILE "nircmd.exe" PARAMETERS "savescreenshot *clipboard*"
   Form_1.Restore

   RETURN

PROCEDURE FlashWin_Click()

   EXECUTE FILE "nircmd.exe" PARAMETERS [win flash title 'NirCmd DLL Test']

   RETURN

   // BOOL WINAPI DoNirCmd(LPSTR lpszCommand)

FUNCTION DoNirCmd( cCommand )

   RETURN HMG_CallDLL( "NIRCMD.DLL", HB_DYN_CTYPE_BOOL, "DoNirCmd", cCommand )

