/*
* MINIGUI - Harbour Win32 GUI library Demo
* Program   : Simple Editor
* Version   : 1.5
* Creator   : Luis Vasquez P
* Mail      : luisvasquezcl@yahoo.com
* Rewritter : Grigory Filatov
* Mail      : gfilatov@front.ru
*/

ANNOUNCE RDDSYS

#include "minigui.ch"
#include "winprint.ch"

#define _CERRADO 0
#define _ABIERTO 1

#define _TAB CHR(9)
#define MsgAlert( c ) MsgEXCLAMATION( c, "Attention" )

STATIC lCreated, cArchivo, ctexto
STATIC nAbierto, cLastOpen, cLastSave
STATIC nTop, nLeft, nWidth, nHeight
STATIC cFontName, nFontSize, lBold, lItalic, aColour, lUnderline, lStrikeOut, nFontChar
STATIC lWordWrap, lSaveNeeded

MEMVAR cStatusBar

FUNCTION main()

   PRIVATE cStatusBar   := 'Filename: '

   cArchivo      := ""
   cTexto         := ""
   lCreated       := .F.
   nAbierto      := _CERRADO
   lWordWrap      := .F.
   lSaveNeeded      := .F.

   SET CENTERWINDOW RELATIVE PARENT
   Configuracion()

   DEFINE WINDOW Frm1 ;
         at nTop, nLeft ;
         WIDTH ColChartopix(nWidth) height Rowchartopix(nHeight) ;
         TITLE 'Simple Editor' ;
         ICON 'main' ;
         MAIN ;
         ON INIT nuevo() ;
         on maximize ( frm1.tmr1.enabled := .t. ) ;
         on size ( frm1.tmr1.enabled := .t. )

      DEFINE STATUSBAR
         statusItem cStatusbar action { || IF( nAbierto==_CERRADO, abrir(), guardar() ) }
      END STATUSBAR

      DEFINE MAIN MENU
         POPUP '&File'
            item '&New'+_TAB+'Ctrl+N'      action { || IF( nAbierto==_CERRADO, nuevo(), ) }
            item '&Open...'+_TAB+'Ctrl+O'      action { || IF( nAbierto==_CERRADO .OR. EMPTY(Frm1.edit.Value), abrir(), ) }
            item '&Save as...'+_TAB+'Ctrl+S'   action { || IF( nAbierto=_ABIERTO, guardar(), ) }
            item '&Close'+_TAB+'Ctrl+C'      action { || IF( nAbierto==_ABIERTO, ocultar(), ) }
            SEPARATOR
            item 'Pre&view Print...'+_TAB+'Ctrl+V'   action IF( nAbierto==_ABIERTO, print(.t.), )
            item '&Print...'+_TAB+'Ctrl+P'      action IF( nAbierto==_ABIERTO, print(.f.), )
            SEPARATOR
            item 'E&xit'+_TAB+'Ctrl+X' action Salir()
         END POPUP
         POPUP 'Opt&ions'
            item '&Default font'+_TAB+'Ctrl+D'   action (Frm1.edit.fontname := 'Arial',Frm1.edit.fontsize := 10, ;
               Frm1.edit.fontbold := .f.,Frm1.edit.fontitalic := .f.,Frm1.edit.fontUnderline := .f.,Frm1.edit.fontStrikeout := .f.)
            item 'O&EM font'+_TAB+'Ctrl+E'      action (Frm1.edit.fontname := 'Terminal',Frm1.edit.fontsize := 12, ;
               Frm1.edit.fontbold := .f.,Frm1.edit.fontitalic := .f.,Frm1.edit.fontUnderline := .f.,Frm1.edit.fontStrikeout := .f.)
            SEPARATOR
            item 'Word Wrap'         action (lWordWrap:=!lWordWrap,Frm1.WordWrap.Checked := lWordWrap, ;
               Frm1.edit.release,lCreated := .f.,nuevo(),frm1.tmr1.enabled := .t.) name WordWrap
            item 'Set fon&t...'+_TAB+'Ctrl+T'   action Selecfont()
         END POPUP
         POPUP '&Help'
            item '&About'+_TAB+'Ctrl+A' action Acercade()
         END POPUP
      END MENU

      DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 24, 18 FLAT RIGHTTEXT

         BUTTON Button_1  ;
            CAPTION '&New' ;
            PICTURE 'NEW' ;
            ACTION { || IF( nAbierto==_CERRADO, nuevo(), ) }

         BUTTON Button_2  ;
            CAPTION '&Open' ;
            PICTURE 'OPEN' ;
            ACTION { || IF( nAbierto==_CERRADO .OR. EMPTY(Frm1.edit.Value), abrir(), MsgAlert('Please close the current document')) }

         BUTTON Button_3  ;
            CAPTION '&Save' ;
            PICTURE 'SAVE' ;
            ACTION { || IF( nAbierto==_ABIERTO, guardar(), ) }

         BUTTON Button_4  ;
            CAPTION '&Close' ;
            PICTURE 'CLOSE' ;
            ACTION { || IF( nAbierto==_ABIERTO, ocultar(), ) } ;
            SEPARATOR

         BUTTON Button_5  ;
            CAPTION 'Print Pre&view' ;
            PICTURE 'PRINTER' ;
            ACTION { || IF( nAbierto==_ABIERTO, print(.t.), ) } ;
            SEPARATOR

         BUTTON Button_6  ;
            CAPTION 'E&xit' ;
            PICTURE 'EXIT' ;
            ACTION { || Salir() }

      END TOOLBAR

      Frm1.WordWrap.Checked := lWordWrap
      Frm1.Button_3.Enabled := lSaveNeeded

      ON KEY CONTROL+N ACTION ( IF( nAbierto==_CERRADO, nuevo(), ) )
      ON KEY CONTROL+O ACTION ( IF( nAbierto==_CERRADO .OR. EMPTY(Frm1.edit.Value), abrir(), ) )
      ON KEY CONTROL+S ACTION ( IF( nAbierto==_ABIERTO, guardar(), ) )
      ON KEY CONTROL+C ACTION ( IF( nAbierto==_ABIERTO, ocultar(), ) )

      ON KEY CONTROL+V ACTION ( IF( nAbierto==_ABIERTO, print(.t.), ) )
      ON KEY CONTROL+P ACTION ( IF( nAbierto==_ABIERTO, print(.f.), ) )

      ON KEY CONTROL+X ACTION Salir()

      ON KEY CONTROL+D ACTION (Frm1.edit.fontname := 'Arial',Frm1.edit.fontsize := 10, ;
         Frm1.edit.fontbold := .f.,Frm1.edit.fontitalic := .f.,Frm1.edit.fontUnderline := .f.,Frm1.edit.fontStrikeout := .f.)
      ON KEY CONTROL+E ACTION (Frm1.edit.fontname := 'Terminal',Frm1.edit.fontsize := 12, ;
         Frm1.edit.fontbold := .f.,Frm1.edit.fontitalic := .f.,Frm1.edit.fontUnderline := .f.,Frm1.edit.fontStrikeout := .f.)
      ON KEY CONTROL+T ACTION Selecfont()
      ON KEY CONTROL+A ACTION Acercade()

      Define timer tmr1 interval 20 action autosize()

   END WINDOW

   IF nTop=0.and.nLeft=0
      CENTER WINDOW Frm1
   ENDIF

   ACTIVATE WINDOW Frm1

   RETURN NIL

PROCEDURE editor()

   DEFINE EDITBOX edit
      ROW      rowchartopix(2) + 2
      COL      colchartopix(0)
      WIDTH      colchartopix( nWidth - 1 )
      HEIGHT      rowchartopix( nHeight - 7 )
      PARENT      frm1
      FONTNAME   cFontName
      FONTSIZE   nFontSize
      FONTBOLD   lBold
      FONTITALIC   lItalic
      FONTUNDERLINE   lUnderline
      fontStrikeout   lStrikeOut
      FONTCOLOR   aColour
      BACKCOLOR   { 240, 240, 241 }
      HScrollBar   !lWordWrap
      ONCHANGE   (lSaveNeeded := .T., Frm1.Button_3.Enabled := lSaveNeeded)
   END editbox

   setfocus edit of frm1
   lCreated := .t.

   RETURN

PROCEDURE autosize()

   IF lCreated
      frm1.tmr1.enabled := .f.
      Frm1.edit.width := Frm1.width - ColChartopix(1) - iif(IsThemed(), GetBorderWidth(), 0)
      Frm1.edit.height := Frm1.height - Rowchartopix(7) - iif(IsThemed(), GetBorderHeight() + 8, 0)
   ENDIF

   RETURN

PROCEDURE mostrar()

   show control edit of frm1
   setfocus edit of frm1
   nAbierto   := _ABIERTO

   RETURN

PROCEDURE ocultar()

   IF lSaveNeeded
      IF MsgYesNo("The current document was changed."+CRLF+"Save these changes?","Alert")
         guardar()
      ENDIF
   ENDIF
   Frm1.edit.fontname := cFontName
   hide control edit of frm1
   nAbierto   := _CERRADO
   cTexto      := ""
   cArchivo   := ""
   Frm1.statusbar.item(1) := cStatusBar + cArchivo
   lSaveNeeded := .F.
   Frm1.Button_3.Enabled := lSaveNeeded

   RETURN

PROCEDURE nuevo()

   IF empty(cTexto)
      cArchivo := "Untitled"
      Frm1.statusbar.item(1) := cStatusBar + cArchivo
   ENDIF
   IF lCreated
      mostrar()
   ELSE
      editor()
   ENDIF
   Frm1.edit.Value := cTexto
   Frm1.edit.fontcolor := aColour
   nAbierto   := _ABIERTO
   lSaveNeeded := .F.
   Frm1.Button_3.Enabled := lSaveNeeded

   RETURN

PROCEDURE abrir()

   LOCAL cVar :=""

   cArchivo   := Getfile( { {"Texts", "*.txt"}, {"All Files", "*.*"} }, "Select a File", cLastOpen, .f., .t. )
   IF !empty( cArchivo )
      cTexto := Memoread( cArchivo )
      cLastOpen := cFilePath( cArchivo )
      IF lCreated
         mostrar()
      ELSE
         editor()
      ENDIF
      Frm1.statusbar.item(1) := cStatusBar + cArchivo
      IF ISOEMTEXT(substr(cTexto,5,50))
         Frm1.edit.fontname := 'Terminal'
         Frm1.edit.fontsize := 12
      ENDIF
      Frm1.edit.Value := cTexto
      nAbierto   := _ABIERTO
      lSaveNeeded := .F.
      Frm1.Button_3.Enabled := lSaveNeeded
   ENDIF

   RETURN

PROCEDURE guardar()

   LOCAL cvar := ""

   cArchivo := Putfile( { {"Texts", "*.txt"}, {"All Files", "*.*"} }, "Save to File", cLastSave, .t., cArchivo )
   IF !Empty( cArchivo )
      cVar   := Frm1.edit.Value
#ifndef __XHARBOUR__
      hb_Memowrit( IF(AT(".", cArchivo) > 0, cArchivo, cArchivo+".txt") , cVar )
#else
      Memowrit( IF(AT(".", cArchivo) > 0, cArchivo, cArchivo+".txt") , cVar , .F. )
#endif
      cLastSave := cFilePath( cArchivo )
      lSaveNeeded := .F.
      ocultar()
   ENDIF

   RETURN

#define MAX_LINE 146
#define MAX_PORT 98

PROCEDURE print(lPrev)

   LOCAL hbprn, cLine, nLines := 0, nLine := 0, ;
      nPage := 1, nMaxWidth := 0, nMaxLine, nCnt

   cTexto := Frm1.edit.Value
   IF !empty(cTexto)
      cTexto := IF( ISOEMTEXT(substr(cTexto,5,50)), HB_OEMTOANSI(cTexto), cTexto )
      nLines := MLCOUNT( cTexto, MAX_LINE )
      FOR nCnt := 1 To nLines
         nMaxWidth := MAX( nMaxWidth, Len( RTrim( MemoLine(cTexto, MAX_LINE, nCnt) ) ) )
      NEXT
      INIT PRINTSYS
      hbprn:TextName := 'for '+IF(EMPTY(cArchivo), "Untitled", cArchivo)
      IF lprev
         SELECT BY DIALOG PREVIEW
         SET PREVIEW RECT Frm1.Row,Frm1.Col,(Frm1.Row)+Frm1.Height,(Frm1.Col)+Max(740,Frm1.Width)
      ELSE
         SELECT BY DIALOG
      ENDIF
      IF EMPTY(HBPRNERROR)
         DEFINE FONT "f0" NAME cFontName SIZE nFontSize
         SELECT FONT "f0"
         START DOC
         IF nMaxWidth < MAX_PORT
            SET PAGE ORIENTATION DMORIENT_PORTRAIT PAPERSIZE DMPAPER_A4 FONT "f0"
         ELSE
            SET PAGE ORIENTATION DMORIENT_LANDSCAPE PAPERSIZE DMPAPER_A4 FONT "f0"
         ENDIF

         IF lprev
            IF HBPRNMAXCOL > MAX_LINE
               MsgAlert('Text width is greater than page width')
            ENDIF
         ENDIF

         nMaxLine := HBPRNMAXROW - 1

         START PAGE

         @nLine, nMaxWidth / IF(nMaxWidth < MAX_PORT, 1.5, 2) SAY "- " + Ltrim(Str(nPage++)) + " -" TO PRINT

         FOR nCnt := 1 To nLines

            cLine := RTrim( MemoLine(cTexto, MAX_LINE, nCnt) )

            @++nLine, 6 SAY cLine TO PRINT

            IF nCnt == nLines .OR. nLine > nMaxLine
               IF nCnt # nLines
               END PAGE
               nLine := 0
               START PAGE
               @nLine, nMaxWidth / IF(nMaxWidth < MAX_PORT, 1.5, 2) SAY "- " + Ltrim(Str(nPage++)) + " -" TO PRINT
            ENDIF
         ENDIF
      NEXT

   END PAGE
END DOC
RELEASE PRINTSYS
ENDIF
ENDIF

RETURN

PROCEDURE Salir()

   LOCAL cCfg   := '.\edt.ini'

   BEGIN INI FILE cCfg
      SET SECTION "Position" ENTRY "Top" TO Frm1.Row
      SET SECTION "Position" ENTRY "Left" TO Frm1.Col
      SET SECTION "Position" ENTRY "Width" TO ColPixToChar(Frm1.Width)
      SET SECTION "Position" ENTRY "Height" TO RowPixToChar(Frm1.Height)
      SET SECTION "Setup" ENTRY "LastOpen" TO cLastOpen
      SET SECTION "Setup" ENTRY "LastSave" TO cLastSave
      SET SECTION "Setup" ENTRY "WordWrap" TO lWordWrap
   END INI
   QUIT

   RETURN

PROCEDURE Acercade()

   LOCAL aTexto := array( 9 )
   LOCAL i, clbl

   atexto[1] := 'Program   : Simple Editor v.1.5'
   atexto[2] := 'Creator   : Luis Vasquez P'
   atexto[3] := 'Mail      : luisvasquezcl@yahoo.com'
   atexto[4] := ''
   aTexto[5] := 'Rewritter : Grigory Filatov'
   aTexto[6] := 'Mail      : gfilatov@front.ru'
   atexto[7] := ''
   atexto[8] := 'Compiler  : Harbour v.3.2.0'
   aTexto[9] := 'Library   : Minigui v.2.1.1'

   DEFINE WINDOW Frm2 ;
         at 0, 0 ;
         WIDTH colchartopix(34) + iif(IsThemed(), GetBorderWidth(), 0) ;
         HEIGHT rowchartopix(15) + iif(IsThemed(), GetBorderHeight() + 6, 0) ;
         TITLE 'About' ;
         ICON 'main' ;
         modal ;
         FONT 'Courier New' size 9

      FOR i := 1 to Len(aTexto)
         clbl := "LBL"+strzero(i, 2)
         @ Rowchartopix(i), Colchartopix(1) label &cLBL value aTexto[i] width 300 height 14
      NEXT

      @ Rowchartopix(i+1), Colchartopix(22) button BTN1 caption 'OK' default ;
         ACTION Frm2.release width 74 height 22 font 'MS Sans Serif' size 9

   END WINDOW
   CENTER WINDOW Frm2
   ACTIVATE WINDOW Frm2

   RETURN

PROCEDURE configuracion()

   LOCAL cCfg   := '.\edt.ini'

   cLastOpen := "" ; cLastSave := ""
   nTop :=0 ; nLeft := 0 ; nWidth := 94 ; nHeight := 40
   cFontName   := 'Arial'
   nFontSize   := 10
   lBold := .f. ; lItalic := .f. ; lUnderline := .f. ; lStrikeOut := .f. ; nFontChar := 0
   IF !file( cCfg )
      BEGIN INI FILE cCfg
         SET SECTION "Position" ENTRY "Top" TO 0
         SET SECTION "Position" ENTRY "Left" TO 0
         SET SECTION "Position" ENTRY "Width" TO nWidth
         SET SECTION "Position" ENTRY "Height" TO nHeight
         SET SECTION "Setup" ENTRY "WordWrap" TO lWordWrap
         SET SECTION "Font" ENTRY "Name" TO cFontName
         SET SECTION "Font" ENTRY "Size" TO nFontSize
         SET SECTION "Font" ENTRY "Bold" TO lBold
         SET SECTION "Font" ENTRY "Color" TO {0,0,0}
         SET SECTION "Font" ENTRY "Italic" TO lItalic
         SET SECTION "Font" ENTRY "Underline" TO lUnderline
         SET SECTION "Font" ENTRY "StrikeOut" TO lStrikeOut
         SET SECTION "Font" ENTRY "Charset" TO nFontChar
      END INI
   ELSE
      BEGIN INI FILE cCfg
         GET nTop SECTION "Position" ENTRY "Top" DEFAULT 0
         GET nLeft SECTION "Position" ENTRY "Left" DEFAULT 0
         GET nWidth SECTION "Position" ENTRY "Width" DEFAULT nWidth
         GET nHeight SECTION "Position" ENTRY "Height" DEFAULT nHeight
         GET cLastOpen SECTION "Setup" ENTRY "LastOpen" DEFAULT ""
         GET cLastSave SECTION "Setup" ENTRY "LastSave" DEFAULT ""
         GET lWordWrap SECTION "Setup" ENTRY "WordWrap" DEFAULT lWordWrap
         GET cFontName SECTION "Font" ENTRY "Name" DEFAULT cFontName
         GET nFontSize SECTION "Font" ENTRY "Size" DEFAULT nFontSize
         GET lBold SECTION "Font" ENTRY "Bold" DEFAULT lBold
         GET lItalic SECTION "Font" ENTRY "Italic" DEFAULT lItalic
         GET aColour SECTION "Font" ENTRY "Color" DEFAULT {0,0,0}
         GET lUnderline SECTION "Font" ENTRY "Underline" DEFAULT lUnderline
         GET lStrikeOut SECTION "Font" ENTRY "StrikeOut" DEFAULT lStrikeOut
         GET nFontChar SECTION "Font" ENTRY "Charset" DEFAULT nFontChar
      END INI
   ENDIF

   RETURN

PROCEDURE Selecfont()

   LOCAL aFnt

   aFnt := Getfont( cFontName, nFontSize, lBold, lItalic, aColour, lUnderline, lStrikeOut, nFontChar )
   IF !empty(aFnt[1])
      Grabaconfig( aFnt[1], aFnt[2], aFnt[3], aFnt[4], aFnt[5], aFnt[6], aFnt[7], aFnt[8] )
      Frm1.edit.fontname := cFontName
      Frm1.edit.fontsize := nFontSize
      Frm1.edit.fontbold := lBold
      Frm1.edit.fontitalic := lItalic
      Frm1.edit.fontcolor := aColour
      Frm1.edit.fontUnderline := lUnderline
      Frm1.edit.fontStrikeout := lStrikeOut
      _SetFontCharset ( 'edit', 'Frm1', nFontChar )
   ENDIF

   RETURN

PROCEDURE GrabaConfig( cFnt, nSize, lb, li, ac, lu, ls, nc )

   LOCAL cCfg   := '.\edt.ini'

   BEGIN INI FILE cCfg
      SET SECTION "Font" ENTRY "Name" TO cFnt
      SET SECTION "Font" ENTRY "Size" TO nSize
      SET SECTION "Font" ENTRY "Bold" TO lB
      SET SECTION "Font" ENTRY "Italic" TO lI
      SET SECTION "Font" ENTRY "Color" TO ac
      SET SECTION "Font" ENTRY "Underline" TO lU
      SET SECTION "Font" ENTRY "StrikeOut" TO lS
      SET SECTION "Font" ENTRY "Charset" TO nC
   END INI
   cFontName   := cFnt
   nFontSize   := nSize
   lBold      := lb
   lItalic      := li
   aColour      := ac
   lUnderline   := lu
   lStrikeOut   := ls
   nFontChar   := nc

   RETURN

   /*
   */

STATIC FUNCTION RowCharToPix( nValor )

   RETURN nValor*14
   /*
   */

STATIC FUNCTION ColCharToPix( nValor )

   RETURN nValor*8
   /*
   */

STATIC FUNCTION RowPixToChar( nValor )

   RETURN Round(nValor/14,0)
   /*
   */

STATIC FUNCTION ColPixToChar( nValor )

   RETURN Round(nValor/8,0)
   /*
   */

STATIC FUNCTION LenChartopix( cText )

   RETURN ColChartopix( len( cText )+1 )
   /*
   */

STATIC FUNCTION cFilePath( cPathMask )

   LOCAL n := RAt( "\", cPathMask )

   RETURN If( n > 0, Left( cPathMask, n - 1), Left( cPathMask, 2 ) + "\" )

FUNCTION _SetFontCharset ( ControlName, ParentForm , Value  )

   LOCAL i , h , n , s , ab , ai , au , as , x

   i := GetControlIndex ( ControlName, ParentForm )
   DeleteObject ( _HMG_aControlFontHandle [i] )
   h := _HMG_aControlHandles [i]
   n := _HMG_aControlFontName [i]
   s := _HMG_aControlFontSize [i]
   ab := _HMG_aControlFontAttributes [i] [1]
   ai := _HMG_aControlFontAttributes [i] [2]
   au := _HMG_aControlFontAttributes [i] [3]
   as := _HMG_aControlFontAttributes [i] [4]

   _HMG_aControlFontHandle [i] := _SetFont ( h , n , s , ab , ai , au , as , 0, Value )

   RETURN NIL
