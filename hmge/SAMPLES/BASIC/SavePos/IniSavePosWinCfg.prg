/*
* MINIGUI - Harbour Win32 GUI library
* Copyright 2012 Janusz Pora <januszpora@onet.eu>
* 2014: Modified by Andrey Verchenko <verchenkoag@gmail.com>. Dmitrov, Russia
*/

#include "minigui.ch"

// store config file to current folder
#define INI_FILE_WIN_CFG  ChangeFileExt( Application.ExeName, ".cfg" )
// OR store config file to temporary folder
//#define INI_FILE_WIN_CFG  GetTempFolder() + "\" + cFileNoPath( ChangeFileExt( Application.ExeName, ".cfg" ) )

PROCEDURE Main

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH 600 ;
         HEIGHT 300 ;
         TITLE 'Example: saving and restoring of window position through the ini file' ;
         BACKCOLOR {0,176,240} ;
         MAIN ;
         ON INIT IniGetPosWindow() ;
         ON RELEASE IniSetPosWindow()

      @ 20, 20 LABEL Label_1 ;
         VALUE 'Change the position of this window, exit the program and then restart' ;
         WIDTH 400 HEIGHT 50 TRANSPARENT

      @ 100, 10 BUTTON Button_1 ;
         CAPTION 'Exit' ACTION   ThisWindow.Release DEFAULT

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

   RETURN

FUNCTION IniGetPosWindow( FormName, cProgName )

   LOCAL cSection, actpos := {0,0,0,0}
   LOCAL col , row , width , height
   LOCAL cPathFileConfig

   DEFAULT FormName := _HMG_ThisFormName
   DEFAULT cProgName := GetProperty(FormName, "Title")

   cPathFileConfig := INI_FILE_WIN_CFG

   GetWindowRect( GetFormHandle( FormName ), actpos )
   cSection := FormName

   IF FILE( cPathFileConfig )
      COL    := VAL( GetIni( cSection , "col"    , "0", cPathFileConfig ) )
      ROW    := VAL( GetIni( cSection , "row"    , "0", cPathFileConfig ) )
      WIDTH  := VAL( GetIni( cSection , "width"  , "0", cPathFileConfig ) )
      HEIGHT := VAL( GetIni( cSection , "height" , "0", cPathFileConfig ) )

      COL    := IFNIL( col, actpos[1], col )
      ROW    := IFNIL( row, actpos[2], row )
      WIDTH  := IFNIL( width, actpos[3] - actpos[1], width )
      HEIGHT := IFNIL( height, actpos[4] - actpos[2], height )
      // If there are no sections, ie Variables are 0
      IF width > 0 .AND. height > 0
         MoveWindow( GetFormHandle( FormName ) , col , row , width , height , .t. )
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION IniSetPosWindow( FormName, cProgName )

   LOCAL cSection, actpos := {0,0,0,0}
   LOCAL col , row , width , height
   LOCAL cText, cPathFileConfig

   DEFAULT FormName := _HMG_ThisFormName
   DEFAULT cProgName := GetProperty(FormName, "Title")

   cPathFileConfig := INI_FILE_WIN_CFG

   GetWindowRect( GetFormHandle( FormName ), actpos )
   cSection := FormName

   IF ! File( cPathFileConfig )
      cText := "[Information]" + CRLF
      cText += "Program = " + Application.ExeName + CRLF
      cText += "Free Open Source Software = " + Version() + CRLF
      cText += "Free Compiler = " + hb_compiler() + CRLF
      cText += "Free Library  = " + MiniGUIVersion() + CRLF
      cText += CRLF + CRLF
      HB_MemoWrit( cPathFileConfig, cText )
   ENDIF

   COL    := actpos[1]
   ROW    := actpos[2]
   WIDTH  := actpos[3] - actpos[1]
   HEIGHT := actpos[4] - actpos[2]

   WriteIni( cSection, "TitleWin" , cProgName       , cPathFileConfig )
   WriteIni( cSection, "col"      , HB_NToS(col)    , cPathFileConfig )
   WriteIni( cSection, "row"      , HB_NToS(row)    , cPathFileConfig )
   WriteIni( cSection, "width"    , HB_NToS(width)  , cPathFileConfig )
   WriteIni( cSection, "height"   , HB_NToS(height) , cPathFileConfig )

   RETURN NIL

STATIC FUNCTION GetIni( cSection, cEntry, cDefault, cFile )

   RETURN GetPrivateProfileString(cSection, cEntry, cDefault, cFile )

STATIC FUNCTION WriteIni( cSection, cEntry, cValue, cFile )

   RETURN( WritePrivateProfileString( cSection, cEntry, cValue, cFile ) )
