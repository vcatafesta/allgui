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

#include "common.ch"
#include "hmg.ch"

FUNCTION _StartStatusBar   (         ;
      cParent      , ;
      cFontName   , ;
      nFontSize   , ;
      lBold      , ;
      lItalic      , ;
      lUnderline   , ;
      lStrikeout   , ;
      lTop      ;
      )

   _HMG_SYSDATA [ 212 ]      := cParent
   _HMG_SYSDATA [ 213 ]      := cFontname
   _HMG_SYSDATA [ 165 ]      := nFontSize
   _HMG_SYSDATA [ 272 ]      := lBold
   _HMG_SYSDATA [ 273 ]      := lItalic
   _HMG_SYSDATA [ 274 ]      := lUnderline
   _HMG_SYSDATA [ 275 ]      := lStrikeout
   _HMG_SYSDATA [ 276 ]      := lTop
   _HMG_SYSDATA [ 143 ]      := {}
   _HMG_SYSDATA [ 144 ]      := {}
   _HMG_SYSDATA [ 145 ]      := {}
   _HMG_SYSDATA [ 146 ]      := {}
   _HMG_SYSDATA [ 147 ]      := {}
   _HMG_SYSDATA [ 148 ]      := {}

   RETURN NIL

FUNCTION _DefineStatusBarItem   (      ;
      cCaption   , ;
      nWidth      , ;
      cImage      , ;
      cStyle      , ;
      cTooltip   , ;
      uAction      ;
      )

   DEFAULT cStyle To ""

   aadd ( _HMG_SYSDATA [ 143 ]   , cCaption   )
   aadd ( _HMG_SYSDATA [ 144 ]   , nWidth   )
   aadd ( _HMG_SYSDATA [ 145 ]   , cImage   )
   aadd ( _HMG_SYSDATA [ 146 ]   ,  if ( HMG_UPPER(cStyle) == 'FLAT', 1 , if(HMG_UPPER(cStyle) == 'RAISED', 2 , 0 ) ) )
   aadd ( _HMG_SYSDATA [ 147 ]   , cTooltip   )
   aadd ( _HMG_SYSDATA [ 148 ]   , uAction   )

   RETURN HMG_LEN(_HMG_SYSDATA [ 143 ])

FUNCTION _EndStatusBar (   cParentForm   , ;
      acCaptions   , ;
      anWidths   , ;
      acImages   , ;
      abActions   , ;
      acToolTips   , ;
      anStyles   , ;
      cFontName   , ;
      nFontSize   , ;
      lFontBold   , ;
      lFontItalic   , ;
      lFontUnderLine   , ;
      lFontStrikeOut   , ;
      lTop      ;
      )

   LOCAL nParentHandle
   LOCAL nId
   LOCAL i
   LOCAL nTotWidth
   LOCAL nControlHandle
   LOCAL nFontHandle
   LOCAL k
   LOCAL mVar

   IF _HMG_SYSDATA [ 264 ] == TRUE
      cParentForm := _HMG_SYSDATA [ 223 ]
   ENDIF

   nParentHandle := GetFormHandle ( cParentForm )

   nId := _GetId()

   nTotWidth := 0

   FOR i := 2 To HMG_LEN (anWidths)
      IF ValType ( anWidths [i] ) <> 'N'
         anWidths [i] := 120
      ENDIF
      nTotWidth := nTotWidth + anWidths [i]
   NEXT i

   anWidths [1] := GetWIndowWidth ( nParentHandle ) - nTotWidth

   nControlhandle := InitStatusBar (   nParentHandle   , ;
      nId      , ;
      acCaptions   , ;
      anWidths   , ;
      acImages   , ;
      acToolTips   , ;
      anStyles   , ;
      lTop      ;
      )

   IF ValType(cFontName) != "U" .and. ValType(nFontSize) != "U"
      nFontHandle := _SetFont (nControlHandle,cFontName,nFontSize,lFontBold,lFontItalic,lFontUnderline,lFontStrikeout)
   ELSE
      nFontHandle := _SetFont (nControlHandle,_HMG_SYSDATA [ 342 ],_HMG_SYSDATA [ 343 ],lFontBold,lFontItalic,lFontUnderline,lFontStrikeout)
   ENDIF

   k := _GetControlFree()

   mVar := '_' + cParentForm + '_' + "StatusBar"

   PUBLIC &mVar. := k

   _HMG_SYSDATA [1]      [k]   := "STATUSBAR"
   _HMG_SYSDATA [2]      [k]   := "StatusBar"
   _HMG_SYSDATA [3]      [k]   := nControlhandle
   _HMG_SYSDATA [4]      [k]   := nParentHandle
   _HMG_SYSDATA [  5 ]      [k]   := nId
   _HMG_SYSDATA [  6 ]      [k]   := abActions
   _HMG_SYSDATA [  7 ]      [k]   := Nil
   _HMG_SYSDATA [  8 ]      [k]   := Nil
   _HMG_SYSDATA [  9 ]      [k]   := Nil
   _HMG_SYSDATA [ 10 ]      [k]   := Nil
   _HMG_SYSDATA [ 11 ]      [k]   := Nil
   _HMG_SYSDATA [ 12 ]      [k]   := Nil
   _HMG_SYSDATA [ 13 ]      [k]   := .F.
   _HMG_SYSDATA [ 14 ]      [k]   := Nil
   _HMG_SYSDATA [ 15 ]      [k]   := Nil
   _HMG_SYSDATA [ 16 ]      [k]   := Nil
   _HMG_SYSDATA [ 17 ]      [k]   := Nil
   _HMG_SYSDATA [ 18 ]      [k]   := Nil
   _HMG_SYSDATA [ 19 ]      [k]   := Nil
   _HMG_SYSDATA [ 20 ]      [k]   := anWidths
   _HMG_SYSDATA [ 21 ]      [k]   := Nil
   _HMG_SYSDATA [ 22 ]      [k]   := Nil
   _HMG_SYSDATA [ 23 ]      [k]   := -1
   _HMG_SYSDATA [ 24 ]      [k]   := -1
   _HMG_SYSDATA [ 25 ]      [k]   := Nil
   _HMG_SYSDATA [ 26 ]      [k]   := 0
   _HMG_SYSDATA [ 27 ]      [k]   := cFontName
   _HMG_SYSDATA [ 28 ]      [k]   := nFontSize
   _HMG_SYSDATA [ 29 ]      [k]   := { lFontBold , lFontItalic , lFontUnderLine , lFontStrikeOut }
   _HMG_SYSDATA [ 30 ]      [k]   := acToolTips
   _HMG_SYSDATA [ 31 ]      [k]   := 0
   _HMG_SYSDATA [ 32 ]      [k]   := 0
   _HMG_SYSDATA [ 33 ]      [k]   := acCaptions
   _HMG_SYSDATA [ 34 ]      [k]   := .T.
   _HMG_SYSDATA [ 35 ]      [k]   := 0
   _HMG_SYSDATA [ 36 ]      [k]   := nFontHandle
   _HMG_SYSDATA [ 37 ]      [k]   := 0
   _HMG_SYSDATA [ 38 ]      [k]   := .T.
   _HMG_SYSDATA [ 39 ]      [k]   := 0
   _HMG_SYSDATA [ 40 ] [k] := { NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL }

   RETURN nControlhandle

PROCEDURE SetStatusBarSize ( nParentHandle , nStatusHandle , anWidths )

   LOCAL i
   LOCAL nTotWidth := 0

   FOR i := 2 To HMG_LEN (anWidths)
      nTotWidth := nTotWidth + anWidths [i]
   NEXT i

   anWidths [1] := GetWindowWidth ( nParentHandle ) - nTotWidth

   InitStatusBarSize ( nStatusHandle , anWidths )

   RETURN

FUNCTION _SetStatusClock ( FormName , Width , ToolTip , action , nIntervalUpdate )

   LOCAL nrItem

   IF Empty (FormName)
      FormName := _HMG_SYSDATA [ 212 ]
   ENDIF

   IF ValType (Width) == 'U'
      Width := 70
   ENDIF
   IF ValType (ToolTip) == 'U'
      ToolTip := 'Clock'
   ENDIF
   IF ValType (Action) == 'U'
      Action := ''
   ENDIF
   IF ValType (nIntervalUpdate) == 'U'
      nIntervalUpdate := 1000
   ENDIF

   nrItem  := _DefineStatusBarItem   (      ;
      Time()   , ;
      Width      , ;
      , ;
      , ;
      ToolTip   , ;
      action   ;
      )

   _DefineTimer ( 'StatusTimer' , FormName , nIntervalUpdate, {|| _SetItem ( 'StatusBar' , FormName , nrItem  , Time() ) } )

   RETURN NIL

FUNCTION _SetStatusKeybrd ( FormName ,Width , ToolTip , action , nIntervalUpdate )

   LOCAL nrItem1 , nrItem2 , nrItem3

   IF Empty (FormName)
      FormName := _HMG_SYSDATA [ 212 ]
   ENDIF

   IF ValType (Width) == 'U'
      Width := 75
   ENDIF
   IF ValType (ToolTip) == 'U'
      ToolTip := ''
   ENDIF
   IF ValType (Action) == 'U'
      Action := ''
   ENDIF
   IF ValType (nIntervalUpdate) == 'U'
      nIntervalUpdate := 200
   ENDIF

   nrItem1 := _DefineStatusBarItem   (      ;
      "NumLock"   , ;
      Width + 20   , ;
      IF ( IsNumLockActive() , "zzz_led_on" , "zzz_led_off" )   , ;
         , ;
         ToolTip   , ;
         Action   ;
         )

      nrItem2 := _DefineStatusBarItem   (      ;
         "CapsLock"   , ;
         Width + 20   , ;
         IF ( IsCapsLockActive() , "zzz_led_on" , "zzz_led_off" )   , ;
            , ;
            ToolTip   , ;
            Action   ;
            )

         nrItem3 := _DefineStatusBarItem   (      ;
            "Insert"   , ;
            Width + 20   , ;
            IF ( IsInsertActive() , "zzz_led_on" , "zzz_led_off" )   , ;
               , ;
               ToolTip   , ;
               Action   ;
               )

            _DefineTimer ( 'StatusKeyBrd' , FormName , nIntervalUpdate , ;
               {|| _SetStatusIcon ( 'StatusBar' , FormName , nrItem1 , if ( IsNumLockActive(),  "zzz_led_on" , "zzz_led_off" ) ), ;
               _SetStatusIcon ( 'StatusBar' , FormName , nrItem2 , if ( IsCapsLockActive(), "zzz_led_on" , "zzz_led_off" ) ), ;
               _SetStatusIcon ( 'StatusBar' , FormName , nrItem3 , if ( IsInsertActive(),   "zzz_led_on" , "zzz_led_off" ) ) ;
               } )

            RETURN NIL

