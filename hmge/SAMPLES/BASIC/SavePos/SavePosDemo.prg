/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2012 Janusz Pora <januszpora@onet.eu>
*/

#include "minigui.ch"

PROCEDURE Main

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH 400 ;
         HEIGHT 200 ;
         TITLE 'Application Title' ;
         MAIN ;
         ON INIT GetRegPosWindow() ;
         ON RELEASE SetRegPosWindow()

      DEFINE BUTTON Button_4
         ROW   100
         COL   10
         CAPTION 'Exit'
         ACTION   ThisWindow.Release
      END BUTTON

      @ 15,15 LABEL Label_1 ;
         VALUE 'Change the position of this window, exit the program and then restart' ;
         WIDTH 300 HEIGHT 50

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

   RETURN

FUNCTION GetRegPosWindow( FormName, cProgName )

   LOCAL cExeName := cFileNoPath( Application.ExeName )
   LOCAL hKey := HKEY_CURRENT_USER
   LOCAL cKey
   LOCAL actpos := {0,0,0,0}
   LOCAL col , row , width , height

   DEFAULT FormName := _HMG_ThisFormName
   DEFAULT cProgName := SubStr( cExeName, 1, RAt( '.', cExeName )-1 )

   GetWindowRect( GetFormHandle( FormName ), actpos )
   cKey := "Software\MiniGUI\" + cProgName + "\" + FormName

   IF IsRegistryKey( hKey, cKey )
      col    := GetRegistryValue( hKey, cKey, "col", 'N' )
      row    := GetRegistryValue( hKey, cKey, "row", 'N' )
      width  := GetRegistryValue( hKey, cKey, "width", 'N' )
      height := GetRegistryValue( hKey, cKey, "height", 'N' )
      col    := IFNIL( col, actpos[1], col )
      row    := IFNIL( row, actpos[2], row )
      width  := IFNIL( width, actpos[3] - actpos[1], width )
      height := IFNIL( height, actpos[4] - actpos[2], height )

      MoveWindow( GetFormHandle( FormName ) , col , row , width , height , .t. )
   ENDIF

   RETURN NIL

FUNCTION SetRegPosWindow( FormName, cProgName )

   LOCAL cExeName := cFileNoPath( Application.ExeName )
   LOCAL hKey := HKEY_CURRENT_USER
   LOCAL cKey
   LOCAL actpos := {0,0,0,0}
   LOCAL col , row , width , height

   DEFAULT FormName := _HMG_ThisFormName
   DEFAULT cProgName := SubStr( cExeName, 1, RAt( '.', cExeName )-1 )

   GetWindowRect( GetFormHandle( FormName ), actpos )
   cKey := "Software\MiniGUI\" + cProgName + "\" + FormName

   IF !IsRegistryKey( hKey, cKey )
      IF !CreateRegistryKey( hKey, cKey )

         RETURN NIL
      ENDIF
   ENDIF
   IF IsRegistryKey( hKey, cKey )
      col    := actpos[1]
      row    := actpos[2]
      width  := actpos[3] - actpos[1]
      height := actpos[4] - actpos[2]
      SetRegistryValue( hKey, cKey, "col", col )
      SetRegistryValue( hKey, cKey, "row", row )
      SetRegistryValue( hKey, cKey, "width", width )
      SetRegistryValue( hKey, cKey, "height", height )
   ENDIF

   RETURN NIL
