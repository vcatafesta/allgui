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

#define BM_GETCHECK     240   // ok
#define BST_UNCHECKED   0     // ok
#define BST_CHECKED     1     // ok
#define BM_SETCHECK     241   // ok

#include "hmg.ch"
#include "common.ch"

FUNCTION _DefineRadioGroup ( ControlName, ParentForm, x, y, aOptions, Value, ;
      fontname, fontsize, tooltip, change, width, ;
      spacing, HelpId, invisible, notabstop , bold, italic, underline, strikeout , backcolor , fontcolor , transparent , aReadOnly , horizontal )
   LOCAL i , cParentForm , mVar , BackRow , k := 0
   LOCAL aHandles    [ 0 ]
   LOCAL ControlHandle
   LOCAL FontHandle
   LOCAL cParentTabName := ''
   LOCAL cParentWindowName := ''
   LOCAL Z
   LOCAL BackCol

   // mSGiNFO ('Creating Radio ' + if ( horizontal ,'.T.' , '.F.' )  )

   DEFAULT Width     TO 120
   DEFAULT change    TO ""
   DEFAULT invisible TO FALSE
   DEFAULT notabstop TO FALSE

   IF horizontal
      DEFAULT Spacing To 125
   ELSE
      DEFAULT Spacing To 25
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
         cParentTabName := _HMG_SYSDATA [ 225 ]
         cParentWindowName := ParentForm
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

   BackRow := y
   BackCol := x

   IF horizontal

      ControlHandle := InitRadioGroup ( ParentForm, aOptions[1], 0, x, y , '' , 0 , Spacing, invisible, notabstop )

   ELSE

      ControlHandle := InitRadioGroup ( ParentForm, aOptions[1], 0, x, y , '' , 0 , width, invisible, notabstop )

   ENDIF

   IF valtype(fontname) != "U" .and. valtype(fontsize) != "U"
      FontHandle := _SetFont (ControlHandle,FontName,FontSize,bold,italic,underline,strikeout)
   ELSE
      FontHandle := _SetFont (ControlHandle,_HMG_SYSDATA [ 342 ],_HMG_SYSDATA [ 343 ],bold,italic,underline,strikeout)
   ENDIF

   IF valtype(tooltip) != "U"
      SetToolTip ( ControlHandle , tooltip , GetFormToolTipHandle (cParentForm) )
   ENDIF

   aAdd ( aHandles , ControlHandle )

   FOR i = 2 to HMG_LEN (aOptions)

      IF horizontal
         x = x + Spacing
      ELSE
         y = y + Spacing
      ENDIF

      IF horizontal

         ControlHandle := InitRadioButton ( ParentForm, aOptions[i], 0, x, y , '' , 0 , Spacing, invisible )

      ELSE

         ControlHandle := InitRadioButton ( ParentForm, aOptions[i], 0, x, y , '' , 0 , width, invisible )

      ENDIF

      IF valtype(fontname) != "U" .and. valtype(fontsize) != "U"
         FontHandle := _SetFont (ControlHandle,FontName,FontSize,bold,italic,underline,strikeout)
      ELSE
         FontHandle := _SetFont (ControlHandle,_HMG_SYSDATA [ 342 ],_HMG_SYSDATA [ 343 ],bold,italic,underline,strikeout)
      ENDIF

      IF valtype(tooltip) != "U"
         SetToolTip ( ControlHandle , tooltip , GetFormToolTipHandle (cParentForm) )
      ENDIF

      aAdd ( aHandles , ControlHandle )

   NEXT i

   IF _HMG_SYSDATA [ 265 ] = .T.
      aAdd ( _HMG_SYSDATA [ 142 ] , aHandles )
   ENDIF

   k := _GetControlFree()

   PUBLIC &mVar. := k

   _HMG_SYSDATA [1] [k] := "RADIOGROUP"
   _HMG_SYSDATA [2]  [k] :=  ControlName
   _HMG_SYSDATA [3]  [k] :=  aHandles
   _HMG_SYSDATA [4] [k] :=   ParentForm
   _HMG_SYSDATA [  5 ]  [k] :=  aReadOnly
   _HMG_SYSDATA [  6 ]  [k] :=  ""
   _HMG_SYSDATA [  7 ]  [k] :=  {}
   _HMG_SYSDATA [  8 ]  [k] :=  horizontal // (Nil)
   _HMG_SYSDATA [  9 ]  [k] :=  transparent
   _HMG_SYSDATA [ 10 ]  [k] :=  ""
   _HMG_SYSDATA [ 11 ]  [k] :=  ""
   _HMG_SYSDATA [ 12 ]  [k] :=  change
   _HMG_SYSDATA [ 13 ]  [k] :=  .F.
   _HMG_SYSDATA [ 14 ]  [k] :=   backcolor
   _HMG_SYSDATA [ 15 ]  [k] :=  fontcolor
   _HMG_SYSDATA [ 16 ]  [k] :=  _HMG_SYSDATA [ 266 ]
   _HMG_SYSDATA [ 17 ]  [k] :=  {}
   _HMG_SYSDATA [ 18 ]  [k] :=  BackRow
   _HMG_SYSDATA [ 19 ]  [k] :=  BackCol
   _HMG_SYSDATA [ 20 ]  [k] :=  if ( horizontal , Spacing * HMG_LEN (aOptions) , Width )
   _HMG_SYSDATA [ 21 ]  [k] :=  if ( horizontal , 28 , Spacing * HMG_LEN (aOptions) )
   _HMG_SYSDATA [ 22 ]  [k] :=  Spacing
   _HMG_SYSDATA [ 23 ]  [k] :=  iif ( _HMG_SYSDATA [ 183 ] > 0 ,_HMG_SYSDATA [ 333 ] [_HMG_SYSDATA [ 183 ]] , -1 )
   _HMG_SYSDATA [ 24 ]  [k] :=  iif ( _HMG_SYSDATA [ 183 ] > 0 ,_HMG_SYSDATA [ 334 ] [_HMG_SYSDATA [ 183 ]] , -1 )
   _HMG_SYSDATA [ 25 ]  [k] :=  .Not. NoTabStop
   _HMG_SYSDATA [ 26 ]  [k] :=  0
   _HMG_SYSDATA [ 27 ]  [k] :=  fontname
   _HMG_SYSDATA [ 28 ]  [k] :=  fontsize
   _HMG_SYSDATA [ 29 ]  [k] :=  {bold,italic,underline,strikeout}
   _HMG_SYSDATA [ 30 ]  [k] :=   tooltip
   _HMG_SYSDATA [ 31 ]  [k] :=  cParentTabName
   _HMG_SYSDATA [ 32 ]  [k] :=  cParentWindowName
   _HMG_SYSDATA [ 33 ]  [k] :=   aOptions
   _HMG_SYSDATA [ 34 ]  [k] :=   if(invisible,FALSE,TRUE)
   _HMG_SYSDATA [ 35 ]  [k] :=   HelpId
   _HMG_SYSDATA [ 36 ]  [k] :=   FontHandle
   _HMG_SYSDATA [ 37 ]  [k] :=   0
   _HMG_SYSDATA [ 38 ]  [k] :=   .T.
   _HMG_SYSDATA [ 39 ] [k] := 0
   _HMG_SYSDATA [ 40 ] [k] := { NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL }

   IF valtype (Value) <> 'U'
      SendMessage( aHandles [value] , BM_SETCHECK  , BST_CHECKED , 0 )
      IF notabstop .and. IsTabStop(aHandles [value])
         SetTabStop(aHandles [value],.f.)
      ENDIF
   ENDIF

   IF VALTYPE ( aReadOnly ) = 'A'

      IF HMG_LEN ( aReadOnly ) == HMG_LEN ( aOptions )

         FOR Z := 1 TO HMG_LEN ( aReadOnly )

            IF VALTYPE ( aReadOnly [Z] ) == 'L'

               IF aReadOnly [Z] == .T.

                  DisableWindow ( aHandles [Z] )

               ELSE

                  EnableWindow ( aHandles [Z] )

               ENDIF

            ENDIF

         NEXT Z

      ENDIF

   ENDIF

   RETURN NIL

PROCEDURE _SetRadioGroupReadOnly ( ControlName , ParentForm , aReadOnly )

   LOCAL Z , I , aHandles , aOptions , lError

   lError := .F.

   I := GetControlIndex ( ControlName , ParentForm )

   aHandles := _HMG_SYSDATA [3] [I]

   aOptions := _HMG_SYSDATA [ 33 ] [I]

   IF VALTYPE ( aReadOnly ) = 'A'

      IF HMG_LEN ( aReadOnly ) == HMG_LEN ( aOptions )

         FOR Z := 1 TO HMG_LEN ( aReadOnly )

            IF VALTYPE ( aReadOnly [Z] ) == 'L'

               IF aReadOnly [Z] == .T.

                  DisableWindow ( aHandles [Z] )

               ELSE

                  EnableWindow ( aHandles [Z] )

               ENDIF

            ELSE

               lError := .T.
               EXIT

            ENDIF

         NEXT Z

      ELSE

         lError := .T.

      ENDIF

   ELSE

      lError := .T.

   ENDIF

   IF .Not. lError

      _HMG_SYSDATA [ 5 ] [I] := aReadOnly

   ENDIF

   RETURN

FUNCTION _GetRadioGroupReadOnly ( ControlName , ParentForm )

   LOCAL RetVal , I

   I := GetControlIndex ( ControlName , ParentForm )

   RetVal := _HMG_SYSDATA [ 5 ] [I]

   RETURN RetVal

