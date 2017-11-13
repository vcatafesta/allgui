/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
* http://harbourminigui.googlepages.com/
* Copyright 2006 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM 'Desktop Notes'
#define VERSION ' version 1.1'
#define COPYRIGHT ' 2006 Grigory Filatov'

#define NTRIM( n )   hb_ntos( n )

#define CLR_DEFAULT   0xff000000

#define MAX_SHEETS   99

#define IDX_FORM_NAME   1
#define IDX_FORM_ROW   2
#define IDX_FORM_COL   3
#define IDX_FORM_ONTOP   4
#define IDX_FORM_FONT   5
#define IDX_FORM_COLOR   6
#define IDX_FORM_TEXT   7
#define IDX_FORM_POSTED   8

MEMVAR cFileDat, cActForm

STATIC lExit := .f., nRow := 10, nCol := 10, nSheets := 0, ;
   aDefaultFont := { 'System' , 10 , .t., .f., { 0, 0, 0 }, .f., .f., 1 }, ;
   aDefaultColor := { 128 , 255 , 128 }, aNotes := {}, nForms := 0

PROCEDURE Main()

   SET MULTIPLE OFF

   SET PROGRAMMATICCHANGE OFF

   PUBLIC cFileDat := GetStartUpFolder() + "\Notes.dat"

   DEFINE WINDOW Form_0 ;
         AT 0,0 ;
         WIDTH 0 HEIGHT 0 ;
         TITLE PROGRAM ;
         MAIN NOSHOW ;
         ON INIT OpenNotes() ;
         ON RELEASE ( lExit := .T., SaveNotes() ) ;
         NOTIFYICON 'MAIN' ;
         NOTIFYTOOLTIP PROGRAM + ": Left click for a new sheet" ;
         ON NOTIFYCLICK AddNote()

      DEFINE NOTIFY MENU
         ITEM '&New message...'  ACTION AddNote() DEFAULT
         SEPARATOR
         ITEM '&Mail to author...' ACTION ShellExecute(0, "open", "rundll32.exe", ;
            "url.dll,FileProtocolHandler " + ;
            "mailto:gfilatov@inbox.ru?cc=&bcc=" + ;
            "&subject=Desktop%20Notes%20Feedback", , 1)
         ITEM 'A&bout...'      ACTION ShellAbout( "", PROGRAM + VERSION + ;
            CRLF + Chr(169) + COPYRIGHT, LoadIconByName("MAIN", 32, 32) )
         SEPARATOR
         ITEM 'E&xit'        ACTION Form_0.Release
      END MENU

   END WINDOW

   ACTIVATE WINDOW Form_0

   RETURN

PROCEDURE AddNote()

   LOCAL cForm, aFont, aColor

   IF Empty( Len(aNotes) )
      aColor := aDefaultColor
      aFont := aDefaultFont
   ELSE
      aFont := aNotes[Len(aNotes)][IDX_FORM_FONT]
      aColor := aNotes[Len(aNotes)][IDX_FORM_COLOR]
   ENDIF

   nForms++
   cForm := 'Form_' + NTRIM(nForms)

   nSheets++
   IF nSheets > MAX_SHEETS
      MsgStop( "Quantity of sheets is very big!", "Stop!", , .f. )

      RETURN
   ENDIF
   Form_0.NotifyTooltip := PROGRAM + ": " + NTRIM(nSheets) + " sheet(s)"

   nRow += 20
   nCol += 20

   IF nRow > GetDesktopHeight() - 260
      nRow := 30
      nCol += 30
   ENDIF

   IF nCol > GetDesktopWidth() - 220
      nRow += 30
      nCol := 30
   ENDIF

   IF ( nSheets - 1 ) % 10 == 0
      nRow := 30
      nCol += 30
   ENDIF

   AADD( aNotes, { cForm, nRow, nCol, .F., aFont, aColor, "", .T. } )

   EditNote( cForm )

   RETURN

PROCEDURE EditNote( cForm )

   LOCAL nForm := aScan( aNotes, {|e| e[IDX_FORM_NAME] == cForm} )
   LOCAL aFont, aColor, cText

   IF nForm > 0
      aFont := aNotes[nForm][IDX_FORM_FONT]
      aColor := aNotes[nForm][IDX_FORM_COLOR]
      cText := aNotes[nForm][IDX_FORM_TEXT]

      IF nRow < 0
         nRow := 0
      ENDIF
      IF nCol < 0
         nCol := 0
      ENDIF

      DEFINE WINDOW &cForm ;
            AT nRow, nCol ;
            WIDTH 202 + GetBorderWidth() HEIGHT 260 + GetBorderHeight() + IF(IsXPThemeActive(), 6, 0) ;
            TITLE PROGRAM ;
            ICON "MAIN" ;
            CHILD ;
            TOPMOST ;
            NOMINIMIZE NOMAXIMIZE NOSIZE ;
            ON INIT InitNote(cForm) ;
            ON RELEASE CloseNote( cForm ) ;
            FONT 'Tahoma' SIZE 8

         DEFINE IMAGELIST ImageList_1 ;
            BUTTONSIZE 32, 32 ;
            IMAGE { IF( IsXPThemeActive(), 'MENUXP', 'MENU' ) } ;
            COLORMASK CLR_DEFAULT ;
            IMAGECOUNT 3 ;
            MASK

         DEFINE TOOLBAREX ToolBar_1 BUTTONSIZE 30,30 IMAGELIST 'ImageList_1' FLAT

         BUTTON Button_1 ;
            PICTUREINDEX 0 ;
            TOOLTIP "Post note (Ctrl+P)" ;
            ACTION PostNote( cForm ) ;
            SEPARATOR

         BUTTON Button_2 ;
            PICTUREINDEX 1 ;
            TOOLTIP "Change font (Ctrl+F)" ;
            ACTION ( aNotes[nForm][IDX_FORM_FONT] := ChangeFont( cForm, aFont ), ;
            aFont := aNotes[nForm][IDX_FORM_FONT] )

         BUTTON Button_3 ;
            PICTUREINDEX 2 ;
            TOOLTIP "Change color (Ctrl+L)" ;
            ACTION ( aNotes[nForm][IDX_FORM_COLOR] := ChangeColor( cForm, aColor, aFont ), ;
            aColor := aNotes[nForm][IDX_FORM_COLOR] )

      END TOOLBAR

      CreateEdit_1( cForm, cText, aColor, aFont )

      ON KEY CONTROL+P ACTION PostNote( cForm )
      ON KEY CONTROL+F ACTION DoMethod( cForm, "Button_2", "OnClick" )
      ON KEY CONTROL+L ACTION DoMethod( cForm, "Button_3", "OnClick" )

      DEFINE TIMER Timer_1    ;
         INTERVAL 50   ;
         ACTION ( DoMethod( cForm, "Timer_1", "Release" ), ;
         SetForeGroundWindow( GetFormHandle(cForm) ), DoMethod( cForm, "Edit_1", "Setfocus" ) )

   END WINDOW

   DoMethod( cForm, 'Activate' )
ENDIF

RETURN

PROCEDURE CreateEdit_1( cForm, cText, aColor, aFont )

   LOCAL aPos

   @ 40,1 EDITBOX Edit_1 OF &cForm ;
      HEIGHT 198 WIDTH 198 ;
      VALUE cText ;
      BACKCOLOR aColor FONTCOLOR aFont[5] ;
      MAXLENGTH 276 ;
      ON CHANGE ( aPos := GetRowCol( cForm ), IF( aPos[1] > 10 .and. aPos[2] > 10, PlayBeep(), ) ) ;
      NOVSCROLL NOHSCROLL

   SetProperty( cForm, 'Edit_1', 'FontName', aFont[1] )
   SetProperty( cForm, 'Edit_1', 'FontSize', aFont[2] )
   SetProperty( cForm, 'Edit_1', 'FontBold', aFont[3] )
   SetProperty( cForm, 'Edit_1', 'FontItalic', aFont[4] )
   SetProperty( cForm, 'Edit_1', 'FontUnderline', aFont[6] )
   SetProperty( cForm, 'Edit_1', 'FontStrikeout', aFont[7] )

   RETURN

FUNCTION GetRowCol( cForm )

   LOCAL s , c , i , e , q

   s := GetProperty( cForm, 'Edit_1', 'Value' )
   c := GetProperty( cForm, 'Edit_1', 'CaretPos' )
   e := 0
   q := 0

   FOR i := 1 to c
      IF substr ( s , i , 1 ) == chr(13)
         e++
         q := 0
      ELSE
         q++
      ENDIF
   NEXT i

   RETURN { e+1, q }

FUNCTION ChangeFont( cForm, aFont )

   LOCAL cText := GetProperty( cForm, 'Edit_1', 'Value' ), ;
      aColor := GetProperty( cForm, 'Edit_1', 'BackColor' )
   LOCAL aNewFont := GetFont( aFont[1], aFont[2], aFont[3], aFont[4], aFont[5], aFont[6], aFont[7] )

   IF !Empty( aNewFont[1] )

      aFont := aNewFont

      DoMethod( cForm, "Edit_1", "Release" )

      CreateEdit_1( cForm, cText, aColor, aFont )

   ENDIF

   RETURN aFont

FUNCTION ChangeColor( cForm, aColor, aFont )

   LOCAL cText := GetProperty( cForm, 'Edit_1', 'Value' )
   LOCAL nColor := ChooseColor( NIL, RGB( aColor[1], aColor[2], aColor[3] ) )

   aColor := { GetRed(nColor), GetGreen(nColor), GetBlue(nColor) }

   DoMethod( cForm, "Edit_1", "Release" )

   CreateEdit_1( cForm, cText, aColor, aFont )

   RETURN aColor

PROCEDURE InitNote( cForm )

   LOCAL nForm := aScan( aNotes, {|e| e[IDX_FORM_NAME] == cForm} )
   LOCAL nItem := aScan( aNotes, {|e| e[IDX_FORM_POSTED] == .F.} )

   aNotes[nForm][IDX_FORM_POSTED] := .F.
   SetForeGroundWindow( GetFormHandle(cForm) )

   IF nItem > 0
      PostNote( aNotes[nItem][IDX_FORM_NAME] )
   ENDIF

   RETURN

PROCEDURE CloseNote( cForm )

   LOCAL nForm := aScan( aNotes, {|e| e[IDX_FORM_NAME] == cForm} )

   IF IsControlDefined( ImageList_1, &cForm )
      RELEASE IMAGELIST ImageList_1 OF &cForm
   ENDIF

   IF lExit

      aNotes[nForm][IDX_FORM_ROW] := GetProperty( cForm, 'Row' )
      aNotes[nForm][IDX_FORM_COL] := GetProperty( cForm, 'Col' )

   ELSE

      ADEL( aNotes, nForm )
      ASIZE( aNotes, Len(aNotes) - 1 )

      nSheets--
      Form_0.NotifyTooltip := PROGRAM + ": " + ;
         IF( Empty(nSheets), "Emptily", NTRIM(nSheets) + " sheet(s)" )
   ENDIF

   SaveNotes()

   RETURN

PROCEDURE SaveNotes()

   LOCAL aData := {}, n := aScan( aNotes, {|e| e[IDX_FORM_POSTED] == .F.} )

   IF n > 0
      aNotes[n][IDX_FORM_ROW] := GetProperty( aNotes[n][IDX_FORM_NAME], 'Row' ) + GetTitleHeight() + 44
      aNotes[n][IDX_FORM_COL] := GetProperty( aNotes[n][IDX_FORM_NAME], 'Col' ) + 4
   ENDIF

   aEval( aNotes, {|e| aAdd( aData, { e[2], e[3], e[4], e[5], e[6], e[7] } )} )

   BEGIN INI FILE cFileDat

      FOR n := 1 To MAX_SHEETS
         IF Empty( Len(_GetIni( NTRIM(n), "Color", {}, aData ) ) )
            EXIT
         ENDIF
         DEL SECTION NTRIM(n)
      NEXT

      aEval( aData, {|e, n| _SetIni( NTRIM(n), "Row", e[1] ), ;
         _SetIni( NTRIM(n), "Col", e[2] ), ;
         _SetIni( NTRIM(n), "OnTop", e[3] ), ;
         _SetIni( NTRIM(n), "Font", e[4] ), ;
         _SetIni( NTRIM(n), "Color", e[5] ), ;
         _SetIni( NTRIM(n), "Text", StrTran(e[6], CRLF, " ") )} )

   END INI

   RETURN

PROCEDURE PostNote( cForm )

   LOCAL nForm := aScan( aNotes, {|e| e[IDX_FORM_NAME] == cForm} )
   LOCAL lOnTop, aFont, aColor, cText

   IF nForm > 0
      aNotes[nForm][IDX_FORM_POSTED] := .T.
      aNotes[nForm][IDX_FORM_ROW] := GetProperty( cForm, 'Row' )
      aNotes[nForm][IDX_FORM_COL] := GetProperty( cForm, 'Col' )
      aNotes[nForm][IDX_FORM_TEXT] := StrTran( GetProperty( cForm, 'Edit_1', 'Value' ), CRLF, " " )

      SaveNotes()

      lOnTop := aNotes[nForm][IDX_FORM_ONTOP]
      aFont := aNotes[nForm][IDX_FORM_FONT]
      aColor := aNotes[nForm][IDX_FORM_COLOR]
      cText := aNotes[nForm][IDX_FORM_TEXT]

      lExit := .T.
      DoMethod( cForm, 'Release' )

      IF lOnTop

         DEFINE WINDOW &cForm ;
               AT aNotes[nForm][IDX_FORM_ROW] + GetTitleHeight() + 44, aNotes[nForm][IDX_FORM_COL] + 4 ;
               WIDTH 200 HEIGHT 200 ;
               CHILD ;
               TOPMOST ;
               NOCAPTION NOSIZE ;
               ON INIT lExit := .F. ;
               ON RELEASE ( nRow := GetProperty( cForm, 'Row' ) - GetTitleHeight() - 44, ;
               nCol := GetProperty( cForm, 'Col' ) - 4, CloseNote( cForm ) ) ;
               ON PAINT OnPaintWindow( cForm, aColor, cText ) ;
               ON MOUSECLICK MoveActiveWindow()

         ELSE

            DEFINE WINDOW &cForm ;
                  AT aNotes[nForm][IDX_FORM_ROW] + GetTitleHeight() + 44, aNotes[nForm][IDX_FORM_COL] + 4 ;
                  WIDTH 200 HEIGHT 200 ;
                  CHILD ;
                  NOCAPTION NOSIZE ;
                  ON INIT lExit := .F. ;
                  ON RELEASE ( nRow := GetProperty( cForm, 'Row' ) - GetTitleHeight() - 44, ;
                  nCol := GetProperty( cForm, 'Col' ) - 4, CloseNote( cForm ) ) ;
                  ON PAINT OnPaintWindow( cForm, aColor, cText ) ;
                  ON MOUSECLICK MoveActiveWindow()

            ENDIF

            DRAW RECTANGLE IN WINDOW &cForm ;
               AT 0,0 TO 200,200 ;
               FILLCOLOR aColor

            @ 4,4 LABEL Label_1 HEIGHT 192 WIDTH 192 ;
               VALUE cText ;
               BACKCOLOR aColor FONTCOLOR aFont[5] ;
               ACTION MoveActiveWindow()

            SetProperty( cForm, 'Label_1', 'FontName', aFont[1] )
            SetProperty( cForm, 'Label_1', 'FontSize', aFont[2] )
            SetProperty( cForm, 'Label_1', 'FontBold', aFont[3] )
            SetProperty( cForm, 'Label_1', 'FontItalic', aFont[4] )
            SetProperty( cForm, 'Label_1', 'FontUnderline', aFont[6] )
            SetProperty( cForm, 'Label_1', 'FontStrikeout', aFont[7] )

            DEFINE CONTEXT MENU
               ITEM '&Edit note' ACTION ( lExit := .T., DoMethod( cForm, 'Release' ), ;
                  lExit := .F., EditNote( cForm ) ) DEFAULT
               ITEM '&Delete this note' ACTION DoMethod( cForm, 'Release' )
               SEPARATOR
               ITEM 'Always on &top' ACTION ( SetProperty( cForm, 'ONTOP', 'Checked', ;
                  !GetProperty( cForm, 'ONTOP', 'Checked' ) ), ;
                  aNotes[nForm][IDX_FORM_ONTOP] := GetProperty( cForm, 'ONTOP', 'Checked' ), ;
                  SetWindowPos( GetFormHandle(cForm), IF(aNotes[nForm][IDX_FORM_ONTOP] == .T., -1, -2), ;
                  0, 0, 0, 0, 3 ) ) NAME ONTOP
            END MENU

            SetProperty( cForm, 'ONTOP', 'Checked', lOnTop )

            ON KEY CONTROL+E ACTION ( lExit := .T., DoMethod( cForm, 'Release' ), lExit := .F., EditNote( cForm ) )

         END WINDOW

         DoMethod( cForm, 'Activate' )
      ENDIF

      RETURN

PROCEDURE OnPaintWindow( cForm, aColor, cText )

   DRAW RECTANGLE IN WINDOW &cForm ;
      AT 0,0 TO 200,200 ;
      FILLCOLOR aColor

   SetProperty( cForm, 'Label_1', 'Value', cText )

   RETURN

   #define HTCAPTION          2
   #define WM_NCLBUTTONDOWN   161

PROCEDURE MoveActiveWindow( hWnd )

   DEFAULT hWnd To GetActiveWindow()

   PostMessage( hWnd, WM_NCLBUTTONDOWN, HTCAPTION, 0 )

   RETURN

PROCEDURE OpenNotes()

   LOCAL aData := {}, nCnt := 1, n, cText := ""

   PRIVATE cActForm := {}

   IF File( cFileDat )

      BEGIN INI FILE cFileDat

         WHILE !Empty( Len( _GetIni( NTRIM(nCnt), "Color", {}, aData ) ) )
            nCnt++
         ENDDO

         IF nCnt - 1 > 0
            FOR n := 1 To nCnt - 1
               aAdd( aData,  { _GetIni( NTRIM(n), "Row", 0, nRow ), ;
                  _GetIni( NTRIM(n), "Col", 0, nCol ), ;
                  _GetIni( NTRIM(n), "OnTop", .f., lExit ), ;
                  _GetIni( NTRIM(n), "Font", {}, aData ), ;
                  _GetIni( NTRIM(n), "Color", {}, aData ), ;
                  _GetIni( NTRIM(n), "Text", "", cText ) } )
            NEXT
         ENDIF

      END INI

      aEval( aData, {|e| LoadNotes( e[1], e[2], e[3], e[4], e[5], e[6] )} )

   ENDIF

   IF LEN( cActForm ) > 0

      Form_0.NotifyTooltip := PROGRAM + ": " + NTRIM(nSheets) + " sheet(s)"

      _ActivateWindow( cActForm )

   ENDIF

   RETURN

PROCEDURE LoadNotes( nSaveRow, nSaveCol, lOnTop, aFont, aColor, cText )

   LOCAL cForm, nForm

   nSheets++
   nForms++
   cForm := 'Form_' + NTRIM(nForms)

   AADD( aNotes, { cForm, nSaveRow, nSaveCol, lOnTop, aFont, aColor, cText, .T. } )

   nForm := aScan( aNotes, {|e| e[IDX_FORM_NAME] == cForm} )

   IF lOnTop

      DEFINE WINDOW &cForm ;
            AT aNotes[nForm][IDX_FORM_ROW], aNotes[nForm][IDX_FORM_COL] ;
            WIDTH 200 HEIGHT 200 ;
            CHILD ;
            TOPMOST ;
            NOCAPTION NOSIZE ;
            ON RELEASE ( nRow := GetProperty( cForm, 'Row' ) - GetTitleHeight() - 44, ;
            nCol := GetProperty( cForm, 'Col' ) - 4, CloseNote( cForm ) ) ;
            ON PAINT OnPaintWindow( cForm, aColor, cText ) ;
            ON MOUSECLICK MoveActiveWindow()

      ELSE

         DEFINE WINDOW &cForm ;
               AT aNotes[nForm][IDX_FORM_ROW], aNotes[nForm][IDX_FORM_COL] ;
               WIDTH 200 HEIGHT 200 ;
               CHILD ;
               NOCAPTION NOSIZE ;
               ON RELEASE ( nRow := GetProperty( cForm, 'Row' ) - GetTitleHeight() - 44, ;
               nCol := GetProperty( cForm, 'Col' ) - 4, CloseNote( cForm ) ) ;
               ON PAINT OnPaintWindow( cForm, aColor, cText ) ;
               ON MOUSECLICK MoveActiveWindow()

         ENDIF

         DRAW RECTANGLE IN WINDOW &cForm ;
            AT 0,0 TO 200,200 ;
            FILLCOLOR aColor

         @ 4,4 LABEL Label_1 HEIGHT 192 WIDTH 192 ;
            VALUE cText ;
            BACKCOLOR aColor FONTCOLOR aFont[5] ;
            ACTION MoveActiveWindow()

         SetProperty( cForm, 'Label_1', 'FontName', aFont[1] )
         SetProperty( cForm, 'Label_1', 'FontSize', aFont[2] )
         SetProperty( cForm, 'Label_1', 'FontBold', aFont[3] )
         SetProperty( cForm, 'Label_1', 'FontItalic', aFont[4] )
         SetProperty( cForm, 'Label_1', 'FontUnderline', aFont[6] )
         SetProperty( cForm, 'Label_1', 'FontStrikeout', aFont[7] )

         DEFINE CONTEXT MENU
            ITEM '&Edit note' ACTION ( lExit := .T., DoMethod( cForm, 'Release' ), ;
               lExit := .F., EditNote( cForm ) ) DEFAULT
            ITEM '&Delete this note' ACTION DoMethod( cForm, 'Release' )
            SEPARATOR
            ITEM 'Always on &top' ACTION ( SetProperty( cForm, 'ONTOP', 'Checked', ;
               !GetProperty( cForm, 'ONTOP', 'Checked' ) ), ;
               aNotes[nForm][IDX_FORM_ONTOP] := GetProperty( cForm, 'ONTOP', 'Checked' ), ;
               SetWindowPos( GetFormHandle(cForm), IF(aNotes[nForm][IDX_FORM_ONTOP] == .T., -1, -2), ;
               0, 0, 0, 0, 3 ) ) NAME ONTOP
         END MENU

         SetProperty( cForm, 'ONTOP', 'Checked', lOnTop )

         ON KEY CONTROL+E ACTION ( lExit := .T., DoMethod( cForm, 'Release' ), lExit := .F., EditNote( cForm ) )

      END WINDOW

      AADD( cActForm, cForm )

      RETURN

      #define WM_SYSCOMMAND   274
      #define SC_CLOSE   61536

FUNCTION _ReleaseWindow (FormName)

   LOCAL FormCount , b , i , x

   b := _HMG_InteractiveClose
   _HMG_InteractiveClose := 1

   FormCount := len (_HMG_aFormHandles)

   IF .Not. _IsWindowDefined (Formname)
      MsgMiniGuiError("Window: "+ FormName + " is not defined. Program terminated" )
   ENDIF

   IF .Not. _IsWindowActive (Formname)
      MsgMiniGuiError("Window: "+ FormName + " is not active. Program terminated" )
   ENDIF

   IF _HMG_ThisEventType == 'WINDOW_RELEASE'
      IF GetFormIndex (FormName) == _HMG_ThisIndex
         MsgMiniGuiError("Release a window in its own 'on release' procedure or release the main window in any 'on release' procedure is not allowed. Program terminated" )
      ENDIF
   ENDIF

   * If the window to release is the main application window, release all
   * windows command will be executed

   IF GetWindowType (FormName) == 'A'

      IF _HMG_ThisEventType == 'WINDOW_RELEASE'
         MsgMiniGuiError("Release a window in its own 'on release' procedure or release the main window in any 'on release' procedure is not allowed. Program terminated" )
      ELSE
         ReleaseAllWindows()
      ENDIF

   ENDIF

   i := GetFormIndex ( Formname )

   * Release Window

   IF   _hmg_aformtype [i] == 'M'   ;
         .and.            ;
         _hmg_activemodalhandle <> _hmg_aformhandles [i]

      EnableWindow ( _hmg_aformhandles [i] )
      SendMessage( _hmg_aformhandles [i] , WM_SYSCOMMAND, SC_CLOSE, 0 )

   ELSE

      FOR x := 1 To FormCount
         IF _hmg_aFormParentHandle [x] == _hmg_aformhandles [i]
            _hmg_aFormParentHandle [x] := _hmg_MainHandle
         ENDIF
      NEXT x

      EnableWindow ( _hmg_aformhandles [i] )
      SendMessage( _hmg_aformhandles [i] , WM_SYSCOMMAND, SC_CLOSE, 0 )

   ENDIF

   _HMG_InteractiveClose := b

   RETURN NIL

STATIC FUNCTION drawrect( window,row,col,row1,col1,penrgb,penwidth,fillrgb )

   LOCAL i := GetFormIndex ( Window )
   LOCAL FormHandle := _HMG_aFormHandles [i] , fill

   IF formhandle > 0

      IF valtype(penrgb) == "U"
         penrgb = {0,0,0}
      ENDIF

      IF valtype(penwidth) == "U"
         penwidth = 1
      ENDIF

      IF valtype(fillrgb) == "U"
         fillrgb := {255,255,255}
         fill := .f.
      ELSE
         fill := .t.
      ENDIF

      rectdraw( FormHandle,row,col,row1,col1,penrgb,penwidth,fillrgb,fill )

      aadd( _HMG_aFormGraphTasks [i] , { || rectdraw( FormHandle,row,col,row1,col1,penrgb,penwidth,fillrgb,fill) } )

   ENDIF

   RETURN NIL

