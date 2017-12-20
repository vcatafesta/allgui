/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2014 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

PROCEDURE Main

   LOCAL lSuccess

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH 350 ;
         HEIGHT 300 ;
         TITLE 'Registry DWORD Value Test' ;
         MAIN

      DEFINE MAIN MENU

         DEFINE POPUP "Test"
            MENUITEM 'Read Registry'   ACTION ReadRegistryTest()
            MENUITEM 'Write Registry'   ACTION WriteRegistryTest()
            SEPARATOR
            ITEM 'Exit'         ACTION Form_1.Release
         END POPUP

      END MENU

      ON KEY F12 ACTION MsgInfo( "Hotkey F12 is pressed" ) TO lSuccess
      IF lSuccess
         MsgInfo( "Hotkey F12 was established successfully." )
      ENDIF

   END WINDOW

   Form_1.Center
   Form_1.Activate

   RETURN

PROCEDURE ReadRegistryTest()

   LOCAL hKey := HKEY_LOCAL_MACHINE
   LOCAL cKey := "SOFTWARE\Microsoft\Windows NT\CurrentVersion\AeDebug"
   LOCAL cVar := "UserDebuggerHotKey"

   MsgInfo( GetRegistryValue( hKey , cKey , cVar , 'N' ), ;
      "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AeDebug\UserDebuggerHotKey" )

   RETURN

PROCEDURE WriteRegistryTest()

   LOCAL hKey := HKEY_LOCAL_MACHINE
   LOCAL cKey := "SOFTWARE\Microsoft\Windows NT\CurrentVersion\AeDebug"
   LOCAL cVar := "UserDebuggerHotKey"
   LOCAL cValue, cBakValue, cNewValue

   IF MsgYesNo( 'This will change HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AeDebug\UserDebuggerHotKey.', 'Are you sure?' )

      cBakValue := GetRegistryValue( hKey, cKey, cVar, 'N' )
      IF Empty( cBakValue )
         cNewValue := '21'
      ELSE
         cNewValue := hb_ntos( cBakValue )
      ENDIF

      cValue := InputBox( '' , 'New Value:' , cNewValue )

      IF .Not. Empty( cValue )
         IF .Not. SetRegistryValue( hKey , cKey , cVar , Val( cValue ) )
            MsgAlert( 'Write Registry is failure!' , 'Error' )
         ELSE
            MsgInfo( 'You must reboot your computer for this setting has been activated.' )
         ENDIF
      ENDIF

   ENDIF

   RETURN
