/*
* MINIGUI - Harbour Win32 GUI library
* Copyright 2012 Janusz Pora <januszpora@onet.eu>
* 2014: Modified by Andrey Verchenko <verchenkoag@gmail.com>. Dmitrov, Russia
*/

#include "minigui.ch"

// store config file to current folder
#define INI_FILE_WIN_CFG  ChangeFileExt( Application.ExeName, ".config" )
// OR store config file to temporary folder
//#define INI_FILE_WIN_CFG  GetTempFolder() + "\" + cFileNoPath( ChangeFileExt( Application.ExeName, ".config" ) )

// Function: Restore the window coordinates of the ini-file

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
      col    := VAL( GetIni( cSection , "col"    , "0", cPathFileConfig ) )
      row    := VAL( GetIni( cSection , "row"    , "0", cPathFileConfig ) )
      width  := VAL( GetIni( cSection , "width"  , "0", cPathFileConfig ) )
      height := VAL( GetIni( cSection , "height" , "0", cPathFileConfig ) )

      col    := IFNIL( col, actpos[1], col )
      row    := IFNIL( row, actpos[2], row )
      width  := IFNIL( width, actpos[3] - actpos[1], width )
      height := IFNIL( height, actpos[4] - actpos[2], height )
      // If there are no sections, ie Variables are 0
      IF width > 0 .AND. height > 0
         MoveWindow( GetFormHandle( FormName ) , col , row , width , height , .t. )
      ENDIF
   ENDIF

   RETURN NIL

   // Function: Save the coordinates of the window in the ini-file

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
      cText += "Copyright     = " + MsgAboutDim(1) + CRLF
      cText += "Assistants_1  = " + MsgAboutDim(2) + CRLF
      cText += "Assistants_2  = " + MsgAboutDim(3) + CRLF
      cText += "Assistants_3  = " + MsgAboutDim(4) + CRLF
      cText += CRLF + CRLF
      HB_MemoWrit( cPathFileConfig, cText )
   ENDIF

   col    := actpos[1]
   row    := actpos[2]
   width  := actpos[3] - actpos[1]
   height := actpos[4] - actpos[2]

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

