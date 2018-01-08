/*
HMG DEMO
(c) 2010 Roberto Lopez
*/

#include "minigui.ch"

FUNCTION Main

   DEFINE WINDOW Win1   ;
         ROW 10      ;
         COL 10      ;
         WIDTH 400      ;
         HEIGHT 400      ;
         TITLE 'HMG common dialogs'   ;
         WindowType  MAIN

      DEFINE MAIN MENU

         DEFINE POPUP 'Dialogs'

            POPUP 'GetFile'
               MENUITEM 'Test'        OnClick GetFile_Test()
               MENUITEM 'Extensions'  OnClick GetFile_Extensions()
               MENUITEM 'Multiselect' OnClick GetFile_Multiselect()
            END POPUP

            POPUP 'GetFolder'
               MENUITEM 'No Params'     OnClick GetFolder_NoParams()
               MENUITEM 'Title and Path'  OnClick GetFolder_Params()
            END POPUP

            POPUP 'GetColor'
               MENUITEM 'Test'   ONCLICK GetColor_Test()
            END POPUP

            POPUP 'GetFont'
               MENUITEM 'Test'   ONCLICK GetFont_Test()
            END POPUP

            POPUP 'PutFile'
               MENUITEM 'Test'   ONCLICK PutFile_Test()
            END POPUP

            POPUP 'InputBox'
               MENUITEM 'Test'   ONCLICK InputBox_Test()
            END POPUP

            POPUP 'Create/Remove Folder'
               MENUITEM 'CreateFolder'   ONCLICK MsgInfo( If( CreateFolder( 'NewFolder' ), 'New Folder Creation is Successful', 'New Folder Creation Failed' ) )
               MENUITEM 'RemoveFolder'   ONCLICK MsgInfo( If( RemoveFolder( 'NewFolder' ), 'Folder Removal is Successful', 'Folder Removal Failed' ) )
            END POPUP

            POPUP 'Get/Set CurrentFolder'
               MENUITEM 'GetCurrentFolder'   ONCLICK MsgInfo( GetCurrentFolder() )
               MENUITEM 'SetCurrentFolder'   ONCLICK MsgInfo( If( SetCurrentFolder( '\minigui' ), '\minigui is the current folder', 'Folder not found!' ) )
            END POPUP

         END POPUP

      END MENU

      @ 10 , 10 EditBox Edit1 ;
         WIDTH 365 ;
         HEIGHT 320 ;
         Value  '' NoHScroll

   END WINDOW

   CENTER WINDOW Win1
   ACTIVATE WINDOW Win1

   RETURN NIL

FUNCTION GetFile_Test()

   LOCAL x

   Win1.Edit1.Value := "GetFile( aFilters, cTitle, cInitFolder )" + CRLF + ;
      "Return STRING, path + filename or an empty STRING" + CRLF

   x := GetFile( )
   Win1.Edit1.Value := Win1.Edit1.Value + CRLF + "Return " + x

   RETURN NIL

FUNCTION GetFile_Extensions()

   LOCAL x

   Win1.Edit1.Value := "GetFile( aFilters, cTitle, cInitFolder, lMultiselect, lNoChangeDirectory )" + CRLF + ;
      "Return STRING, path + filename or an empty STRING" + CRLF

   x := GetFile( {{ 'Src', '*.prg' }}, 'Select file', 'c:\minigui\source', .F., .T. )
   Win1.Edit1.Value := Win1.Edit1.Value + CRLF + "Return " + x

   RETURN NIL

FUNCTION GetFile_Multiselect()

   LOCAL x, s := "", n

   Win1.Edit1.Value := "GetFile( aFilter, cTitle, cInitFolder, lMultiSelect, lNoChangeDirectory )" + CRLF + ;
      "If MultiSelect = .T. when return ARRAY" + CRLF + ;
      " Accept return ARRAY, Cancel an empty ARRAY" + CRLF + ;
      " Each item = path + filename" + CRLF

   x := GetFile( {{ 'Src', '*.prg;*.c' },{ 'text', '*.txt;*.doc' }}, 'Select file', 'c:\minigui\source', .T., .T. )

   s := "Return array len = " + hb_ValToStr( Len( x ) ) + CRLF
   FOR n := 1 To Len( x )
      s += x[ n ] + CRLF
   NEXT

   Win1.Edit1.Value :=  Win1.Edit1.Value + s

   RETURN NIL

FUNCTION GetFolder_NoParams()

   LOCAL x

   Win1.Edit1.Value := "GetFolder() No parameters." + CRLF + ;
      " Accept return STRING with path name, Cancel an empty STRING" + CRLF

   x := GetFolder()
   Win1.Edit1.Value := Win1.Edit1.Value + CRLF + "Return " + x

   RETURN NIL

FUNCTION GetFolder_Params()

   LOCAL x

   Win1.Edit1.Value := "GetFolder( cTitle, cInitFolder )." + CRLF + ;
      " Accept return string with path name, Cancel an empty string" + CRLF + ;
      " Extension. cInitFolder. Dialog box open the Init folder" + CRLF

   x := GetFolder( "Select Directory", "c:\minigui" )
   Win1.Edit1.Value := Win1.Edit1.Value + CRLF + "Return " + x

   RETURN NIL

FUNCTION GetColor_Test()

   LOCAL x

   Win1.Edit1.Value := "GetColor( xColor )." + CRLF + ;
      " Accept return ARRAY R G B, Cancel an empty ARRAY" + CRLF

   x := GetColor( { 255, 0, 0 } )

   Win1.Edit1.Value :=  Win1.Edit1.Value + CRLF + "Return Array " + CRLF + ;
      "Item 1= " + hb_ValToStr( x[ 1 ]) + CRLF + ;
      "Item 2= " + hb_ValToStr( x[ 2 ]) + CRLF + ;
      "Item 3= " + hb_ValToStr( x[ 3 ]) + CRLF

   RETURN NIL

FUNCTION GetFont_Test()

   LOCAL x

   Win1.Edit1.Value := "GetFont( cInitFontName, nInitFontSize, lBold, lItalic, anInitColor, lUnderLine, lStrikeOut, nCharset )" + CRLF + ;
      " Accept return ARRAY, Cancel an empty ARRAY" + CRLF

   x := GetFont( "Arial", 12, .T., .T., nil, .T., .T., nil )

   Win1.Edit1.Value :=  Win1.Edit1.Value + CRLF + "Return Array :" + CRLF + ;
      "Item 1= " + hb_ValToStr( x[ 1 ]) + CRLF + ;
      "Item 2= " + hb_ValToStr( x[ 2 ]) + CRLF + ;
      "Item 3= " + hb_ValToStr( x[ 3 ]) + CRLF + ;
      "Item 4= " + hb_ValToStr( x[ 4 ]) + CRLF + ;
      "Item 5= " + "{" + hb_ValToStr( x[ 5 ][ 1 ]) + "," + hb_ValToStr( x[ 5 ][ 2 ]) + "," + hb_ValToStr( x[ 5 ][ 3 ]) + "}" + CRLF + ;
      "Item 6= " + hb_ValToStr( x[ 6 ]) + CRLF + ;
      "Item 7= " + hb_ValToStr( x[ 7 ]) + CRLF + ;
      "Item 8= " + hb_ValToStr( x[ 8 ]) + CRLF

   RETURN NIL

FUNCTION PutFile_Test()

   LOCAL x

   Win1.Edit1.Value := "PutFile( aFilters, cTitle, cInitFolder, lNoChangeDirectory, cFileName)" + CRLF + ;
      "Return STRING, path + filename or an empty STRING" + CRLF + ;
      " Extension. Predefined cFileName" + CRLF

   x := PutFile( {{ 'Src', '*.prg' }}, 'Select file', 'c:\minigui\source', .f., "test" )

   Win1.Edit1.Value := Win1.Edit1.Value + CRLF + "Return " + x

   RETURN NIL

FUNCTION InputBox_Test()

   LOCAL x

   Win1.Edit1.Value := "InputBox()" + CRLF

   x := InputBox ( 'Enter text', 'InputBox Demo', 'Default Value' )

   Win1.Edit1.Value := Win1.Edit1.Value + CRLF + "Return " + hb_ValToStr( x )

   RETURN NIL
