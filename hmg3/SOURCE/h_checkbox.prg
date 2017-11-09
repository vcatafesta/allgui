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

#define BM_GETCHECK      240   // ok
#define BST_UNCHECKED    0     // ok
#define BST_CHECKED      1     // ok
#define BM_SETCHECK      241   // ok
#include "hmg.ch"
#include "common.ch"

FUNCTION _DefineCheckBox ( ControlName, ParentForm, x, y, Caption, Value, ;
      fontname, fontsize, tooltip, changeprocedure, w, h,;
      lostfocus, gotfocus, HelpId, invisible, notabstop , bold, italic, underline, strikeout , field  , backcolor , fontcolor , transparent, OnEnter )
   LOCAL cParentForm , mVar , k := 0
   LOCAL ControlHandle
   LOCAL FontHandle
   LOCAL WorkArea
   LOCAL cParentTabName := ''
   LOCAL cParentWindowName := ''

   DEFAULT value           TO FALSE
   DEFAULT w               TO 100
   DEFAULT h               TO 28
   DEFAULT lostfocus       TO ""
   DEFAULT gotfocus        TO ""
   DEFAULT changeprocedure TO ""
   DEFAULT invisible       TO FALSE
   DEFAULT notabstop       TO FALSE

   IF ValType ( Field ) != 'U'
      IF  HB_UAT ( '>', Field ) == 0
         MsgHMGError ("Control: " + ControlName + " Of " + ParentForm + " : You must specify a fully qualified field name. Program Terminated" )
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
         ParentForm   := _HMG_SYSDATA [ 332 ] [_HMG_SYSDATA [ 183 ]]

         cParentTabName := _HMG_SYSDATA [ 225 ]
         cParentWindowName := ParentForm
      ENDIF
   ENDIF

   IF .Not. _IsWindowDefined (ParentForm)
      MsgHMGError("Window: "+ ParentForm + " is not defined. Program terminated" )
   ENDIF

   IF _IsControlDefined (ControlName,ParentForm)
      MsgHMGError ("Control: " + ControlName + " Of " + ParentForm + " Already defined. Program Terminated" )
   ENDIF

   mVar := '_' + ParentForm + '_' + ControlName

   cParentForm := ParentForm

   ParentForm = GetFormHandle (ParentForm)

   Controlhandle := InitCheckBox ( ParentForm, Caption, 0, x, y, '', 0 , w , h, invisible, notabstop )

   IF valtype(fontname) != "U" .and. valtype(fontsize) != "U"
      FontHandle := _SetFont (ControlHandle,FontName,FontSize,bold,italic,underline,strikeout)
   ELSE
      FontHandle := _SetFont (ControlHandle,_HMG_SYSDATA [ 342 ],_HMG_SYSDATA [ 343 ],bold,italic,underline,strikeout)
   ENDIF

   IF _HMG_SYSDATA [ 265 ] = .T.
      aAdd ( _HMG_SYSDATA [ 142 ] , Controlhandle )
   ENDIF

   IF valtype(tooltip) != "U"
      SetToolTip ( ControlHandle , tooltip , GetFormToolTipHandle (cParentForm) )
   ENDIF

   k := _GetControlFree()

   PUBLIC &mVar. := k

   _HMG_SYSDATA [1] [k] := "CHECKBOX"
   _HMG_SYSDATA [2] [k] :=   ControlName
   _HMG_SYSDATA [3] [k] :=   ControlHandle
   _HMG_SYSDATA [4] [k] :=   ParentForm
   _HMG_SYSDATA [  5 ] [k] :=   0
   _HMG_SYSDATA [  6 ] [k] :=   OnEnter
   _HMG_SYSDATA [  7 ] [k] :=   Field
   _HMG_SYSDATA [  8 ] [k] :=   Nil
   _HMG_SYSDATA [  9 ] [k] :=   transparent
   _HMG_SYSDATA [ 10 ] [k] :=   lostfocus
   _HMG_SYSDATA [ 11 ] [k] :=   gotfocus
   _HMG_SYSDATA [ 12 ] [k] :=   changeprocedure
   _HMG_SYSDATA [ 13 ] [k] :=   .F.
   _HMG_SYSDATA [ 14 ] [k] :=   backcolor
   _HMG_SYSDATA [ 15 ] [k] :=   fontcolor
   _HMG_SYSDATA [ 16 ] [k] :=   _HMG_SYSDATA [ 266 ]
   _HMG_SYSDATA [ 17 ] [k] :=   {}
   _HMG_SYSDATA [ 18 ]  [k] :=  y
   _HMG_SYSDATA [ 19 ] [k] :=   x
   _HMG_SYSDATA [ 20 ]  [k] :=  w
   _HMG_SYSDATA [ 21 ] [k] :=   h
   _HMG_SYSDATA [ 22 ]  [k] :=  0
   _HMG_SYSDATA [ 23 ]  [k] :=  iif ( _HMG_SYSDATA [ 183 ] > 0 ,_HMG_SYSDATA [ 333 ] [_HMG_SYSDATA [ 183 ]] , -1 )
   _HMG_SYSDATA [ 24 ]  [k] :=  iif ( _HMG_SYSDATA [ 183 ] > 0 ,_HMG_SYSDATA [ 334 ] [_HMG_SYSDATA [ 183 ]] , -1 )
   _HMG_SYSDATA [ 25 ]  [k] :=  ""
   _HMG_SYSDATA [ 26 ]  [k] :=  0
   _HMG_SYSDATA [ 27 ]  [k] :=  fontname
   _HMG_SYSDATA [ 28 ]  [k] :=  fontsize
   _HMG_SYSDATA [ 29 ]  [k] :=  {bold,italic,underline,strikeout}
   _HMG_SYSDATA [ 30 ]  [k] :=   tooltip
   _HMG_SYSDATA [ 31 ]  [k] :=  cParentTabName
   _HMG_SYSDATA [ 32 ]  [k] :=  cParentWindowName
   _HMG_SYSDATA [ 33 ]  [k] :=  Caption
   _HMG_SYSDATA [ 34 ]  [k] :=  if(invisible,FALSE,TRUE)
   _HMG_SYSDATA [ 35 ]  [k] :=  HelpId
   _HMG_SYSDATA [ 36 ]  [k] := FontHandle
   _HMG_SYSDATA [ 37 ] [k] :=  0
   _HMG_SYSDATA [ 38 ] [k] :=  .T.
   _HMG_SYSDATA [ 39 ] [k] := 0
   _HMG_SYSDATA [ 40 ] [k] := { NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL }

   IF value = .t.
      SendMessage( Controlhandle , BM_SETCHECK  , BST_CHECKED , 0 )
   ENDIF

   IF valtype ( Field ) != 'U'
      IF k > 0
         aAdd ( _HMG_SYSDATA [ 89 ]   [ GetFormIndex ( cParentForm ) ] , k )
      ELSE
         aAdd ( _HMG_SYSDATA [ 89 ]   [ GetFormIndex ( cParentForm ) ] , HMG_LEN (_HMG_SYSDATA [3]) )
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION _DefineCheckButton ( ControlName, ParentForm, x, y, Caption, Value, ;
      fontname, fontsize, tooltip, changeprocedure, ;
      w, h, lostfocus, gotfocus, HelpId, invisible, ;
      notabstop , bold, italic, underline, strikeout, OnEnter )
   LOCAL cParentForm , mVar , k
   LOCAL ControlHandle
   LOCAL FontHandle

   DEFAULT value           TO FALSE
   DEFAULT w               TO 100
   DEFAULT h               TO 28
   DEFAULT lostfocus       TO ""
   DEFAULT gotfocus        TO ""
   DEFAULT changeprocedure TO ""
   DEFAULT invisible       TO FALSE
   DEFAULT notabstop       TO FALSE

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
      MsgHMGError("Window: "+ ParentForm + " is not defined. Program terminated" )
   ENDIF

   IF _IsControlDefined (ControlName,ParentForm)
      MsgHMGError ("Control: " + ControlName + " Of " + ParentForm + " Already defined. Program Terminated" )
   ENDIF

   mVar := '_' + ParentForm + '_' + ControlName

   cParentForm := ParentForm

   ParentForm = GetFormHandle (ParentForm)

   Controlhandle := InitCheckButton ( ParentForm, Caption, 0, x, y, '', 0 , w , h, invisible, notabstop )

   IF valtype(fontname) != "U" .and. valtype(fontsize) != "U"
      FontHandle := _SetFont (ControlHandle,FontName,FontSize,bold,italic,underline,strikeout)
   ELSE
      FontHandle := _SetFont (ControlHandle,_HMG_SYSDATA [ 342 ],_HMG_SYSDATA [ 343 ],bold,italic,underline,strikeout)
   ENDIF

   IF _HMG_SYSDATA [ 265 ] = .T.
      aAdd ( _HMG_SYSDATA [ 142 ] , ControlHandle )
   ENDIF

   IF valtype(tooltip) != "U"
      SetToolTip ( ControlHandle , tooltip , GetFormToolTipHandle (cParentForm) )
   ENDIF

   k := _GetControlFree()

   PUBLIC &mVar. := k

   _HMG_SYSDATA [1] [k] := "CHECKBOX"
   _HMG_SYSDATA [2] [k] :=   ControlName
   _HMG_SYSDATA [3] [k] :=   ControlHandle
   _HMG_SYSDATA [4] [k] :=   ParentForm
   _HMG_SYSDATA [  5 ] [k] :=   0
   _HMG_SYSDATA [  6 ] [k] :=  OnEnter
   _HMG_SYSDATA [  7 ]  [k] :=  {}
   _HMG_SYSDATA [  8 ]  [k] :=  Nil
   _HMG_SYSDATA [  9 ]   [k] := ""
   _HMG_SYSDATA [ 10 ]  [k] :=  lostfocus
   _HMG_SYSDATA [ 11 ]  [k] :=  gotfocus
   _HMG_SYSDATA [ 12 ]  [k] :=  changeprocedure
   _HMG_SYSDATA [ 13 ]  [k] :=  .F.
   _HMG_SYSDATA [ 14 ]   [k] := Nil
   _HMG_SYSDATA [ 15 ]   [k] := Nil
   _HMG_SYSDATA [ 16 ]   [k] := ""
   _HMG_SYSDATA [ 17 ]  [k] :=  {}
   _HMG_SYSDATA [ 18 ]  [k] :=  y
   _HMG_SYSDATA [ 19 ]   [k] := x
   _HMG_SYSDATA [ 20 ]   [k] := w
   _HMG_SYSDATA [ 21 ]   [k] := h
   _HMG_SYSDATA [ 22 ]   [k] := 0
   _HMG_SYSDATA [ 23 ]   [k] := iif ( _HMG_SYSDATA [ 183 ] > 0 ,_HMG_SYSDATA [ 333 ] [_HMG_SYSDATA [ 183 ]] , -1 )
   _HMG_SYSDATA [ 24 ]  [k] :=  iif ( _HMG_SYSDATA [ 183 ] > 0 ,_HMG_SYSDATA [ 334 ] [_HMG_SYSDATA [ 183 ]] , -1 )
   _HMG_SYSDATA [ 25 ]  [k] :=  ""
   _HMG_SYSDATA [ 26 ]  [k] :=  0
   _HMG_SYSDATA [ 27 ]   [k] := fontname
   _HMG_SYSDATA [ 28 ]   [k] := fontsize
   _HMG_SYSDATA [ 29 ]   [k] := {bold,italic,underline,strikeout}
   _HMG_SYSDATA [ 30 ]  [k] :=   tooltip
   _HMG_SYSDATA [ 31 ]   [k] :=  0
   _HMG_SYSDATA [ 32 ]   [k] :=  0
   _HMG_SYSDATA [ 33 ]   [k] :=  Caption
   _HMG_SYSDATA [ 34 ]  [k] :=   if(invisible,FALSE,TRUE)
   _HMG_SYSDATA [ 35 ]  [k] :=   HelpId
   _HMG_SYSDATA [ 36 ]   [k] :=  FontHandle
   _HMG_SYSDATA [ 37 ]   [k] :=  0
   _HMG_SYSDATA [ 38 ]  [k] :=   .T.
   _HMG_SYSDATA [ 39 ] [k] := 0
   _HMG_SYSDATA [ 40 ] [k] := { NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL }

   IF value = .t.
      SendMessage( Controlhandle , BM_SETCHECK  , BST_CHECKED , 0 )
   ENDIF

   RETURN NIL

FUNCTION _DefineImageCheckButton ( ControlName, ParentForm, x, y, Picture, ;
      Value, fontname, fontsize, tooltip, ;
      changeprocedure, w, h, lostfocus, gotfocus,;
      HelpId, invisible, notabstop, notrans, OnEnter )
   LOCAL cParentForm , mVar , k := 0
   LOCAL ControlHandle
   LOCAL aRet

   DEFAULT value           TO FALSE
   DEFAULT w               TO 100
   DEFAULT h               TO 28
   DEFAULT lostfocus       TO ""
   DEFAULT gotfocus        TO ""
   DEFAULT changeprocedure TO ""
   DEFAULT invisible       TO FALSE
   DEFAULT notabstop       TO FALSE

   IF _HMG_SYSDATA [ 264 ] = .T.
      ParentForm := _HMG_SYSDATA [ 223 ]
   ENDIF
   IF _HMG_SYSDATA [ 183 ] > 0
      IF _HMG_SYSDATA [ 240 ] == .F.
         x    := x + _HMG_SYSDATA [ 334 ] [_HMG_SYSDATA [ 183 ]]
         y    := y + _HMG_SYSDATA [ 333 ] [_HMG_SYSDATA [ 183 ]]
         ParentForm := _HMG_SYSDATA [ 332 ] [_HMG_SYSDATA [ 183 ]]
      ENDIF
   ENDIF

   IF .Not. _IsWindowDefined (ParentForm)
      MsgHMGError("Window: "+ ParentForm + " is not defined. Program terminated" )
   ENDIF

   IF _IsControlDefined (ControlName,ParentForm)
      MsgHMGError ("Control: " + ControlName + " Of " + ParentForm + " Already defined. Program Terminated" )
   ENDIF

   mVar := '_' + ParentForm + '_' + ControlName

   cParentForm := ParentForm

   ParentForm = GetFormHandle (ParentForm)

   IF IsAppThemed ()
      aRet := InitImageCheckButton ( ParentForm, "", 0, x, y, '', 0, Picture, w, h, invisible, notabstop, .T., notrans )
      Controlhandle := aRet [1]
   ELSE
      aRet := InitImageCheckButton ( ParentForm, "", 0, x, y, '', 0, Picture, w, h, invisible, notabstop, .F., notrans )
      Controlhandle := aRet [1]
   ENDIF

   IF _HMG_SYSDATA [ 265 ] = .T.
      aAdd ( _HMG_SYSDATA [ 142 ] , ControlHandle )
   ENDIF

   IF valtype(tooltip) != "U"
      SetToolTip ( ControlHandle , tooltip , GetFormToolTipHandle (cParentForm) )
   ENDIF

   k := _GetControlFree()

   PUBLIC &mVar. := k

   _HMG_SYSDATA [  1 ]  [k] :=  "CHECKBOX"
   _HMG_SYSDATA [  2 ]  [k] :=  ControlName
   _HMG_SYSDATA [  3 ]  [k] :=  ControlHandle
   _HMG_SYSDATA [  4 ]  [k] :=  ParentForm
   _HMG_SYSDATA [  5 ]  [k] :=  0
   _HMG_SYSDATA [  6 ]  [k] :=  OnEnter
   _HMG_SYSDATA [  7 ]  [k] :=  {}
   _HMG_SYSDATA [  8 ]  [k] :=  Nil
   _HMG_SYSDATA [  9 ]  [k] :=  ""
   _HMG_SYSDATA [ 10 ]  [k] :=  lostfocus
   _HMG_SYSDATA [ 11 ]  [k] :=  gotfocus
   _HMG_SYSDATA [ 12 ]  [k] :=  changeprocedure
   _HMG_SYSDATA [ 13 ]  [k] :=  .F.
   _HMG_SYSDATA [ 14 ]  [k] :=  Nil
   _HMG_SYSDATA [ 15 ]  [k] :=  Nil
   _HMG_SYSDATA [ 16 ]  [k] :=  ""
   _HMG_SYSDATA [ 17 ]  [k] :=  {}
   _HMG_SYSDATA [ 18 ]  [k] :=  y
   _HMG_SYSDATA [ 19 ]  [k] :=  x
   _HMG_SYSDATA [ 20 ]  [k] :=  w
   _HMG_SYSDATA [ 21 ]  [k] :=  h
   _HMG_SYSDATA [ 22 ]  [k] :=  0
   _HMG_SYSDATA [ 23 ]  [k] :=  iif ( _HMG_SYSDATA [ 183 ] > 0 ,_HMG_SYSDATA [ 333 ] [_HMG_SYSDATA [ 183 ]] , -1 )
   _HMG_SYSDATA [ 24 ]  [k] :=  iif ( _HMG_SYSDATA [ 183 ] > 0 ,_HMG_SYSDATA [ 334 ] [_HMG_SYSDATA [ 183 ]] , -1 )
   _HMG_SYSDATA [ 25 ]  [k] :=  Picture
   _HMG_SYSDATA [ 26 ]  [k] :=  4 // BUTTON_IMAGELIST_ALIGN_CENTER
   _HMG_SYSDATA [ 27 ]  [k] :=  fontname
   _HMG_SYSDATA [ 28 ]  [k] :=  fontsize
   _HMG_SYSDATA [ 29 ]  [k] :=  {.f.,.f.,.f.,.f.}
   _HMG_SYSDATA [ 30 ]  [k] :=  tooltip
   _HMG_SYSDATA [ 31 ]  [k] :=  0
   _HMG_SYSDATA [ 32 ]  [k] :=  notrans // ADD
   _HMG_SYSDATA [ 33 ]  [k] :=  ''
   _HMG_SYSDATA [ 34 ]  [k] :=  if (invisible,FALSE,TRUE)
   _HMG_SYSDATA [ 35 ]  [k] :=  HelpId
   _HMG_SYSDATA [ 36 ]  [k] :=  0
   _HMG_SYSDATA [ 37 ]  [k] :=  aRet [2]
   _HMG_SYSDATA [ 38 ]  [k] :=  .T.
   _HMG_SYSDATA [ 39 ]  [k] :=  1
   _HMG_SYSDATA [ 40 ]  [k] :=  { NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL }

   IF value = .t.
      SendMessage( Controlhandle , BM_SETCHECK  , BST_CHECKED , 0 )
   ENDIF

   RETURN NIL

PROCEDURE _DataCheckBoxRefresh (i)

   LOCAL Field

   Field      := _HMG_SYSDATA [  7 ] [i]

   _SetValue ( '' , '' , &Field , i )

   RETURN

PROCEDURE _DataCheckBoxSave ( ControlName , ParentForm)

   LOCAL Field , i

   i := GetControlIndex ( ControlName , ParentForm)

   Field := _HMG_SYSDATA [  7 ] [i]

   REPLACE &Field WITH _GetValue ( Controlname , ParentForm )

   RETURN

