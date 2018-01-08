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

FUNCTION _DefineEditbox ( ControlName, ParentForm, x, y, w, h, value, ;
      fontname, fontsize, tooltip, MaxLength, gotfocus, ;
      change, lostfocus, readonly, break, HelpId, ;
      invisible, notabstop , bold, italic, underline, strikeout , field , backcolor , fontcolor , novscroll , nohscroll , DISABLEDBACKCOLOR , DISABLEDFORECOLOR  )
   LOCAL i  , cParentForm , mVar , ContainerHandle := 0 , k := 0
   LOCAL ControlHandle
   LOCAL FontHandle
   LOCAL WorkArea
   LOCAL cParentTabName

   DEFAULT w         TO 120
   DEFAULT h         TO 240
   DEFAULT value     TO ""
   DEFAULT change    TO ""
   DEFAULT lostfocus TO ""
   DEFAULT gotfocus  TO ""
   DEFAULT MaxLength TO 0  //64000
   DEFAULT invisible TO FALSE
   DEFAULT notabstop TO FALSE

   IF ValType ( Field ) != 'U'
      IF  HB_UAT ( '>', Field ) == 0
         MsgHMGError ("Control: " + ControlName + " Of " + ParentForm + " : You must specify a fully qualified field name. Program Terminated" )
      ELSE
         WORKAREA := HB_ULEFT ( Field , HB_UAT ( '>', Field ) - 2 )
         IF Select (WorkArea) != 0
            VALUE := &(Field)
         ENDIF
      ENDIF
   ENDIF

   IF _HMG_SYSDATA [ 264 ] = .T.
      ParentForm := _HMG_SYSDATA [ 223 ]
      IF .Not. Empty (_HMG_SYSDATA [ 224 ]) .And. ValType(FontName) == "U"
         FONTNAME := _HMG_SYSDATA [ 224 ]
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
         cParentTabName := _HMG_SYSDATA [ 225 ]
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

   IF valtype(x) == "U" .or. valtype(y) == "U"

      IF _HMG_SYSDATA [ 216 ] == 'TOOLBAR'
         Break := .T.
      ENDIF

      _HMG_SYSDATA [ 216 ]   := 'EDIT'

      i := GetFormIndex ( cParentForm )

      IF i > 0

         ControlHandle := InitEditBox ( ParentForm , 0, x, y, w, h, '', 0 , MaxLength , readonly, invisible, notabstop , novscroll , nohscroll )
         IF valtype(fontname) != "U" .and. valtype(fontsize) != "U"
            FontHandle := _SetFont (ControlHandle,FontName,FontSize,bold,italic,underline,strikeout)
         ELSE
            FontHandle := _SetFont (ControlHandle,_HMG_SYSDATA [ 342 ],_HMG_SYSDATA [ 343 ],bold,italic,underline,strikeout)
         ENDIF

         AddSplitBoxItem ( Controlhandle , _HMG_SYSDATA [ 87 ] [i] , w , break , , , , _HMG_SYSDATA [ 258 ] )
         Containerhandle := _HMG_SYSDATA [ 87 ] [i]

         IF Valtype (Value) == 'C' ;
               .or.;
               Valtype (Value) == 'M'

            IF .Not. Empty (Value)
               SetWindowText ( ControlHandle , value )
            ENDIF

         ENDIF

      ENDIF

   ELSE

      ControlHandle := InitEditBox ( ParentForm, 0, x, y, w, h, '', 0 , MaxLength , readonly, invisible, notabstop , novscroll , nohscroll )
      IF valtype(fontname) != "U" .and. valtype(fontsize) != "U"
         FontHandle := _SetFont (ControlHandle,FontName,FontSize,bold,italic,underline,strikeout)
      ELSE
         FontHandle := _SetFont (ControlHandle,_HMG_SYSDATA [ 342 ],_HMG_SYSDATA [ 343 ],bold,italic,underline,strikeout)
      ENDIF

      IF Valtype (Value) == 'C' ;
            .or.;
            Valtype (Value) == 'M'

         IF .Not. Empty (Value)
            SetWindowText ( ControlHandle , value )
         ENDIF

      ENDIF

   ENDIF

   IF _HMG_SYSDATA [ 265 ] = .T.
      aAdd ( _HMG_SYSDATA [ 142 ] , Controlhandle )
   ENDIF

   IF valtype(tooltip) != "U"
      SetToolTip ( ControlHandle , tooltip , GetFormToolTipHandle (cParentForm) )
   ENDIF

   k := _GetControlFree()

   PUBLIC &mVar. := k

   _HMG_SYSDATA [1] [k] := "EDIT"
   _HMG_SYSDATA [2]  [k] :=  ControlName
   _HMG_SYSDATA [3]  [k] :=  ControlHandle
   _HMG_SYSDATA [4]  [k] :=  ParentForm
   _HMG_SYSDATA [  5 ]  [k] :=  0
   _HMG_SYSDATA [  6 ]  [k] :=  ""
   _HMG_SYSDATA [  7 ]  [k] :=  Field
   _HMG_SYSDATA [  8 ]  [k] :=  Nil
   _HMG_SYSDATA [  9 ]  [k] :=  ""
   _HMG_SYSDATA [ 10 ]  [k] :=  lostfocus
   _HMG_SYSDATA [ 11 ] [k] :=   gotfocus
   _HMG_SYSDATA [ 12 ]  [k] :=  change
   _HMG_SYSDATA [ 13 ]  [k] :=  .F.
   _HMG_SYSDATA [ 14 ]  [k] :=  backcolor
   _HMG_SYSDATA [ 15 ]  [k] :=  fontcolor
   _HMG_SYSDATA [ 16 ]  [k] :=  ""
   _HMG_SYSDATA [ 17 ]  [k] :=  {}
   _HMG_SYSDATA [ 18 ]  [k] :=  y
   _HMG_SYSDATA [ 19 ]   [k] := x
   _HMG_SYSDATA [ 20 ]   [k] := w
   _HMG_SYSDATA [ 21 ]   [k] := h
   _HMG_SYSDATA [ 22 ]   [k] := 0
   _HMG_SYSDATA [ 23 ]  [k] :=  iif ( _HMG_SYSDATA [ 183 ] > 0 ,_HMG_SYSDATA [ 333 ] [_HMG_SYSDATA [ 183 ]] , -1 )
   _HMG_SYSDATA [ 24 ]  [k] :=  iif ( _HMG_SYSDATA [ 183 ] > 0 ,_HMG_SYSDATA [ 334 ] [_HMG_SYSDATA [ 183 ]] , -1 )
   _HMG_SYSDATA [ 25 ]  [k] :=  ""
   _HMG_SYSDATA [ 26 ]  [k] :=  ContainerHandle
   _HMG_SYSDATA [ 27 ]  [k] :=  fontname
   _HMG_SYSDATA [ 28 ]  [k] :=  fontsize
   _HMG_SYSDATA [ 29 ]  [k] :=  {bold,italic,underline,strikeout}
   _HMG_SYSDATA [ 30 ]   [k] :=  tooltip
   _HMG_SYSDATA [ 31 ]  [k] :=   cParentTabName
   _HMG_SYSDATA [ 32 ]  [k] :=   0
   _HMG_SYSDATA [ 33 ]  [k] :=   ''
   _HMG_SYSDATA [ 34 ]  [k] :=   if(invisible,FALSE,TRUE)
   _HMG_SYSDATA [ 35 ]   [k] :=  HelpId
   _HMG_SYSDATA [ 36 ]  [k] :=   FontHandle
   _HMG_SYSDATA [ 37 ]  [k] :=   0
   _HMG_SYSDATA [ 38 ]  [k] :=   .T.
   _HMG_SYSDATA [ 39 ] [k] := 0
   _HMG_SYSDATA [ 40 ] [k] := { NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL }

   _HMG_SYSDATA [ 40 ] [k] [  9 ] := DISABLEDBACKCOLOR
   _HMG_SYSDATA [ 40 ] [k] [ 10 ] := DISABLEDFORECOLOR
   _HMG_SYSDATA [ 40 ] [k] [ 11 ] := readonly

   IF valtype ( Field ) != 'U'
      aAdd ( _HMG_SYSDATA [ 89 ]   [ GetFormIndex ( cParentForm ) ] , k )
   ENDIF

   RETURN NIL

PROCEDURE _DataEditBoxRefresh (i)

   LOCAL Field

   Field      := _HMG_SYSDATA [  7 ] [i]

   _SetValue ( '' , '' , &Field , i )

   RETURN

PROCEDURE _DataEditBoxSave ( ControlName , ParentForm)

   LOCAL Field , i

   i := GetControlIndex ( ControlName , ParentForm)

   Field := _HMG_SYSDATA [  7 ] [i]

   REPLACE &Field WITH _GetValue ( Controlname , ParentForm )

   RETURN
