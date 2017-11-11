/*----------------------------------------------------------------------------
HMG - Harbour Windows GUI library source code

Copyright 2002-2016 Roberto Lopez <mail.box.hmg@gmail.com>
http://sites.google.com/site/hmgweb/

Head of HMG project:

2002-2012 Roberto Lopez <mail.box.hmg@gmail.com>
http://sites.google.com/site/hmgweb/

2012-2016 Dr. Claudio Soto <srvet@adinet.com.uy>
http://srvet.blogspot.com

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this software; see the file COPYING. If not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA (or
visit the web site http://www.gnu.org/).

As a special exception, you have permission for additional uses of the text
contained in this release of HMG.

The exception is that, if you link the HMG library with other
files to produce an executable, this does not by itself cause the resulting
executable to be covered by the GNU General Public License.
Your use of that executable is in no way restricted on account of linking the
HMG library code into it.

Parts of this project are based upon:

"Harbour GUI framework for Win32"
Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
Copyright 2001 Antonio Linares <alinares@fivetech.com>
www - http://www.harbour-project.org

"Harbour Project"
Copyright 1999-2008, http://www.harbour-project.org/

"WHAT32"
Copyright 2002 AJ Wos <andrwos@aust1.net>

"HWGUI"
Copyright 2001-2008 Alexander S.Kresin <alex@belacy.belgorod.su>

---------------------------------------------------------------------------*/
MEMVAR _HMG_SYSDATA

#include "hmg.ch"
#include "common.ch"
#include "fileio.ch"

#define EM_SETBKGNDCOLOR        1091  // ok

FUNCTION _DefineRichEditBox ( ControlName, ;
      ParentForm, ;
      x, ;
      y, ;
      w, ;
      h, ;
      value, ;
      fontname, ;
      fontsize, ;
      tooltip, ;
      MaxLength, ;
      gotfocus, ;
      change, ;
      lostfocus, ;
      READonly, ;
      break, ;
      HelpId, ;
      invisible, ;
      notabstop , ;
      bold, ;
      italic, ;
      underline, ;
      strikeout , ;
      field, ;
      backcolor, ;
      noHscroll, noVscroll, selectionchange, OnLink, OnVScroll )

   LOCAL i  , cParentForm , mVar , ContainerHandle := 0 , k := 0
   LOCAL ControlHandle
   LOCAL FontHandle
   LOCAL WorkArea

   DEFAULT invisible    TO .F.
   DEFAULT notabstop    TO .F.
   DEFAULT W            TO 120
   DEFAULT H            TO 240
   DEFAULT VALUE        TO ''
   DEFAULT noHscroll    TO .F.
   DEFAULT noVscroll    TO .F.
   DEFAULT MaxLength    TO -1  // 64000

   IF MaxLength == 0
      MaxLength := -1   // for compatibility with TextBox and EditBox
   ENDIF

   IF ValType ( Field ) != 'U'
      IF  HB_UAT ( '>', Field ) == 0
         MsgHMGError ("Control: " + ControlName + " Of " + ParentForm + " : You must specify a fully qualified field name. Program Terminated")
      ELSE
         WorkArea := HB_ULEFT ( Field , HB_UAT ( '>', Field ) - 2 )
         IF Select (WorkArea) != 0
            Value := &(Field)
         ENDIF
      ENDIF
   ENDIF

   IF _HMG_SYSDATA [ 264 ] = .T.
      ParentForm := _HMG_SYSDATA [ 223 ]
      IF .Not. Empty (_HMG_SYSDATA [ 224 ]) .And. ValType(FontName) == "U"
         FontName := _HMG_SYSDATA [ 224 ]
      ENDIF
      IF .Not. Empty (_HMG_SYSDATA [ 182 ]) .And. ValType(FontSize) == "U"
         FontSize := _HMG_SYSDATA [ 182 ]
      ENDIF
   ENDIF
   IF _HMG_SYSDATA [ 183 ] > 0
      IF _HMG_SYSDATA [ 240 ] == .F.
         x    := x + _HMG_SYSDATA [ 334 ] [_HMG_SYSDATA [ 183 ]]
         y    := y + _HMG_SYSDATA [ 333 ] [_HMG_SYSDATA [ 183 ]]
         ParentForm := _HMG_SYSDATA [ 332 ] [_HMG_SYSDATA [ 183 ]]
      ENDIF
   ENDIF

   IF .Not. _IsWindowDefined (ParentForm)
      MsgHMGError("Window: "+ ParentForm + " is not defined. Program terminated")
   ENDIF

   IF _IsControlDefined (ControlName,ParentForm)
      MsgHMGError ("Control: " + ControlName + " Of " + ParentForm + " Already defined. Program Terminated")
   ENDIF

   mVar := '_' + ParentForm + '_' + ControlName

   cParentForm := ParentForm

   ParentForm = GetFormHandle (ParentForm)

   IF valtype(x) == "U" .or. valtype(y) == "U"

      IF _HMG_SYSDATA [ 216 ] == 'TOOLBAR'
         Break := .T.
      ENDIF

      _HMG_SYSDATA [ 216 ]   := 'RICHEDIT'

      i := GetFormIndex ( cParentForm )

      IF i > 0

         ControlHandle := InitRichEditBox ( _HMG_SYSDATA [ 87 ] [i] , 0, x, y, w, h, '', 0 , MaxLength , readonly, invisible, notabstop, noHscroll, noVscroll )
         IF valtype(fontname) != "U" .and. valtype(fontsize) != "U"
            FontHandle := _SetFont (ControlHandle,FontName,FontSize,bold,italic,underline,strikeout)
         ELSE
            FontHandle := _SetFont (ControlHandle,_HMG_SYSDATA [ 342 ],_HMG_SYSDATA [ 343 ],bold,italic,underline,strikeout)
         ENDIF

         AddSplitBoxItem ( Controlhandle , _HMG_SYSDATA [ 87 ] [i] , w , break , , , , _HMG_SYSDATA [ 258 ] )
         Containerhandle := _HMG_SYSDATA [ 87 ] [i]

         IF HMG_LEN(value) > 0
            SetWindowText ( ControlHandle , value )
         ENDIF

      ENDIF

   ELSE

      ControlHandle := InitRichEditBox ( ParentForm, 0, x, y, w, h, '', 0 , MaxLength , readonly, invisible, notabstop,  noHscroll, noVscroll)
      IF valtype(fontname) != "U" .and. valtype(fontsize) != "U"
         FontHandle := _SetFont (ControlHandle,FontName,FontSize,bold,italic,underline,strikeout)
      ELSE
         FontHandle := _SetFont (ControlHandle,_HMG_SYSDATA [ 342 ],_HMG_SYSDATA [ 343 ],bold,italic,underline,strikeout)
      ENDIF

      IF HMG_LEN(value) > 0
         SetWindowText ( ControlHandle , value )
      ENDIF

   ENDIF

   IF _HMG_SYSDATA [ 265 ] = .T.
      aAdd ( _HMG_SYSDATA [ 142 ] , Controlhandle )
   ENDIF

   IF valtype(tooltip) != "U"
      SetToolTip ( ControlHandle , tooltip , GetFormToolTipHandle (cParentForm) )
   ENDIF

   RichEditBox_SetRTFTextMode   ( ControlHandle , .T. )   // ADD
   RichEditBox_SetAutoURLDetect ( ControlHandle , .T. )   // ADD

   k := _GetControlFree()

   PUBLIC &mVar. := k

   _HMG_SYSDATA [1] [k] := "RICHEDIT"
   _HMG_SYSDATA [2] [k] :=  ControlName
   _HMG_SYSDATA [3] [k] :=  ControlHandle
   _HMG_SYSDATA [4] [k] :=  ParentForm
   _HMG_SYSDATA [  5 ]  [k] :=  0
   _HMG_SYSDATA [  6 ]  [k] :=  ""
   _HMG_SYSDATA [  7 ]  [k] :=  Field
   _HMG_SYSDATA [  8 ]  [k] :=  NIL
   _HMG_SYSDATA [  9 ]  [k] :=  ""
   _HMG_SYSDATA [ 10 ]  [k] :=  lostfocus
   _HMG_SYSDATA [ 11 ]  [k] :=  gotfocus
   _HMG_SYSDATA [ 12 ] [k] :=   change
   _HMG_SYSDATA [ 13 ]  [k] :=  .F.
   _HMG_SYSDATA [ 14 ]  [k] :=  backcolor
   _HMG_SYSDATA [ 15 ]  [k] :=  Nil
   _HMG_SYSDATA [ 16 ]  [k] :=  ""
   _HMG_SYSDATA [ 17 ]   [k] := {}
   _HMG_SYSDATA [ 18 ]  [k] :=  y
   _HMG_SYSDATA [ 19 ]  [k] :=  x
   _HMG_SYSDATA [ 20 ]   [k] := w
   _HMG_SYSDATA [ 21 ]   [k] := h
   _HMG_SYSDATA [ 22 ]   [k] := selectionchange
   _HMG_SYSDATA [ 23 ]  [k] :=  iif ( _HMG_SYSDATA [ 183 ] > 0 ,_HMG_SYSDATA [ 333 ] [_HMG_SYSDATA [ 183 ]] , -1 )
   _HMG_SYSDATA [ 24 ]  [k] :=  iif ( _HMG_SYSDATA [ 183 ] > 0 ,_HMG_SYSDATA [ 334 ] [_HMG_SYSDATA [ 183 ]] , -1 )
   _HMG_SYSDATA [ 25 ]  [k] :=  ""
   _HMG_SYSDATA [ 26 ] [k] :=   ContainerHandle
   _HMG_SYSDATA [ 27 ]  [k] :=  fontname
   _HMG_SYSDATA [ 28 ]  [k] :=  fontsize
   _HMG_SYSDATA [ 29 ]  [k] :=  {bold,italic,underline,strikeout}
   _HMG_SYSDATA [ 30 ]   [k] :=  tooltip
   _HMG_SYSDATA [ 31 ]  [k] :=  OnLink
   _HMG_SYSDATA [ 32 ]  [k] :=  OnVScroll
   _HMG_SYSDATA [ 33 ]   [k] :=  ''
   _HMG_SYSDATA [ 34 ]  [k] :=   if(invisible,.f.,.t.)
   _HMG_SYSDATA [ 35 ]  [k] :=   HelpId
   _HMG_SYSDATA [ 36 ]  [k] :=   FontHandle
   _HMG_SYSDATA [ 37 ]  [k] :=   0
   _HMG_SYSDATA [ 38 ]  [k] :=   .T.
   _HMG_SYSDATA [ 39 ] [k] := 0
   _HMG_SYSDATA [ 40 ] [k] := { NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL }

   IF valtype ( Field ) != 'U'
      aAdd ( _HMG_SYSDATA [ 89 ]   [ GetFormIndex ( cParentForm ) ] , k )
   ENDIF

   IF valtype ( BackColor ) == 'A'
      IF HMG_LEN ( BackColor ) == 3
         SendMessage ( _HMG_SYSDATA [3] [k] , EM_SETBKGNDCOLOR  , 0 , RGB ( BackColor[1] , BackColor[2] , BackColor[3] ) )
      ENDIF
   ENDIF

   RETURN NIL

PROCEDURE _DataRichEditBoxRefresh (i)

   LOCAL Field

   Field      := _HMG_SYSDATA [  7 ] [i]

   _SetValue ( '' , '' , &Field , i )

   RETURN

PROCEDURE _DataRichEditBoxSave ( ControlName , ParentForm)

   LOCAL Field , i

   i := GetControlIndex ( ControlName , ParentForm)

   Field := _HMG_SYSDATA [  7 ] [i]

   REPLACE &Field WITH _GetValue ( Controlname , ParentForm )

   RETURN

   * by Dr. Claudio Soto, January 2014

FUNCTION RichEditBox_SetCaretPos ( hWndControl , nPos )

   LOCAL aSelRange := { nPos, nPos}

   RichEditBox_SetSelRange ( hWndControl, aSelRange )

   RETURN NIL

FUNCTION RichEditBox_GetCaretPos ( hWndControl )

   LOCAL aSelRange := RichEditBox_GetSelRange ( hWndControl )

   RETURN aSelRange [2]

FUNCTION RichEditBox_SelectAll ( hWndControl )

   LOCAL aSelRange := { 0, -1}

   RichEditBox_SetSelRange ( hWndControl, aSelRange )

   RETURN NIL

FUNCTION RichEditBox_UnSelectAll ( hWndControl )

   LOCAL nPos := RichEditBox_GetCaretPos ( hWndControl )

   RichEditBox_SetCaretPos ( hWndControl , nPos )

   RETURN NIL

FUNCTION RichEditBox_ReplaceText ( hWndControl, cFind, cReplace, lMatchCase, lWholeWord, lSelectFindText )

   LOCAL lDown := .T.
   LOCAL aPos  := {0,0}

   aPos := RichEditBox_GetSelRange ( hWndControl )
   RichEditBox_SetSelRange ( hWndControl, { aPos[1] , aPos[1] } )
   aPos := RichEditBox_FindText ( hWndControl, cFind, lDown, lMatchCase, lWholeWord, lSelectFindText )
   IF aPos[1] <> -1
      RichEditBox_SetSelRange ( hWndControl, aPos )
      RichEditBox_SetText ( hWndControl , .T. , cReplace )
      aPos := RichEditBox_FindText ( hWndControl, cFind, lDown, lMatchCase, lWholeWord, lSelectFindText )
   ENDIF

   RETURN aPos

FUNCTION RichEditBox_ReplaceAllText ( hWndControl, cFind, cReplace, lMatchCase, lWholeWord, lSelectFindText )

   LOCAL aPos  := {0,0}

   WHILE aPos [1] <> -1
      aPos := RichEditBox_ReplaceText ( hWndControl, cFind, cReplace, lMatchCase, lWholeWord, lSelectFindText )
      DO EVENTS
   ENDDO

   RETURN aPos

FUNCTION RichEditBox_AddTextAndSelect ( hWndControl , nPos, cText )

   LOCAL StartCaretPos, EndCaretPos, DeltaCaretPos

   RichEditBox_SetCaretPos ( hWndControl , -1 )
   StartCaretPos := RichEditBox_GetCaretPos ( hWndControl )

   RichEditBox_SetText ( hWndControl, .T., cText )
   RichEditBox_SetCaretPos ( hWndControl , -1 )
   EndCaretPos := RichEditBox_GetCaretPos ( hWndControl )

   RichEditBox_SetSelRange ( hWndControl, { StartCaretPos, EndCaretPos } )

   IF nPos <= -1 .OR. nPos > EndCaretPos
      RichEditBox_SetSelRange ( hWndControl, { StartCaretPos, -1 } )
   ELSE
      DeltaCaretPos := EndCaretPos - StartCaretPos

      RichEditBox_SelClear ( hWndControl )

      RichEditBox_SetCaretPos ( hWndControl , nPos )
      RichEditBox_SetText ( hWndControl, .T., cText )
      RichEditBox_SetSelRange ( hWndControl, { nPos, nPos + DeltaCaretPos } )
   ENDIF

   RETURN NIL

FUNCTION RichEditBox_RTFPrint ( hWndControl, aSelRange, nLeft, nTop, nRight, nBottom, PrintPageCodeBlock )

   LOCAL nPageWidth, nPageHeight
   LOCAL nNextChar := 0
   LOCAL nTextLength := RichEditBox_GetTextLength ( hWndControl )

   DEFAULT aSelRange          TO { 0, -1 }   // select all text
   DEFAULT nLeft              TO 20          // Left   page margin in millimeters
   DEFAULT nTop               TO 20          // Top    page margin in millimeters
   DEFAULT nRight             TO 20          // Right  page margin in millimeters
   DEFAULT nBottom            TO 20          // Bottom page margin in millimeters
   DEFAULT PrintPageCodeBlock TO {|| NIL}

   nPageWidth  := OpenPrinterGetPageWidth()    // in millimeters
   nPageHeight := OpenPrinterGetPageHeight()   // in millimeters

   nRight  := nPageWidth  - nRight
   nBottom := nPageHeight - nBottom

   // Convert millimeters in twips ( 1 inch = 25.4 mm = 1440 twips )
   nLeft   := nLeft   * 1440 / 25.4
   nTop    := nTop    * 1440 / 25.4
   nRight  := nRight  * 1440 / 25.4
   nBottom := nBottom * 1440 / 25.4

   IF aSelRange [2] == -1 .OR. aSelRange [2] > nTextLength
      aSelRange [2] := nTextLength
   ENDIF

   START PRINTDOC
      DO WHILE nNextChar < nTextLength
         START PRINTPAGE
            EVAL ( PrintPageCodeBlock )
            nNextChar := RichEditBox_FormatRange ( hWndControl, OpenPrinterGetPageDC(), nLeft, nTop, nRight, nBottom, aSelRange )
            aSelRange [1] := nNextChar
            DO EVENTS
         END PRINTPAGE
      ENDDO
   END PRINTDOC

   RETURN NIL

FUNCTION RichEditBox_LoadFile( hWndControl, cFile, lSelection, nType )

   LOCAL lSuccess

   IF ValType( lSelection ) <> "L"
      lSelection := .F.
   ENDIF

   IF ValType( nType ) <> "N"
      nType := RICHEDITFILE_RTF
   ENDIF

   lSuccess := RichEditBox_RTFLoadResourceFile( hWndControl, cFile, lSelection )

   IF lSuccess == .F.
      RichEditBox_StreamIn( hWndControl, cFile, lSelection, nType )
   ENDIF

   RETURN NIL

FUNCTION RichEditBox_SaveFile( hWndControl, cFile, lSelection, nType )

   IF ValType( lSelection ) <> "L"
      lSelection := .F.
   ENDIF

   IF ValType( nType ) <> "N"
      nType := RICHEDITFILE_RTF
   ENDIF

   RichEditBox_StreamOut( hWndControl, cFile, lSelection, nType )

   RETURN NIL

