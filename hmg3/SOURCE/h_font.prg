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

#include 'hmg.ch'

FUNCTION RedrawLabel (i)   // by Giancarlo, Febraury 2015

   IF _HMG_SYSDATA [ 1 ] [i]  ==  "LABEL"
      IF ValType ( _HMG_SYSDATA [ 9 ] [i] ) == 'L'
         IF _HMG_SYSDATA [ 9 ] [i] == .T.
            RedrawWindowControlRect( _HMG_SYSDATA [4] [i] , _HMG_SYSDATA [ 18 ][i] , _HMG_SYSDATA [ 19 ][i] , _HMG_SYSDATA [ 18 ][i] + _HMG_SYSDATA [ 21 ][i] , _HMG_SYSDATA [ 19 ][i] + _HMG_SYSDATA [ 20 ] [i] )
         ENDIF
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION _GetFontName ( ControlName, ParentForm )

   LOCAL i

   i := GetControlIndex ( ControlName, ParentForm )

   RETURN   ( _HMG_SYSDATA [ 27 ] [i] )

FUNCTION _GetFontSize ( ControlName, ParentForm )

   LOCAL i

   i := GetControlIndex ( ControlName, ParentForm )

   RETURN   ( _HMG_SYSDATA [ 28 ] [i] )

FUNCTION _GetFontBold ( ControlName, ParentForm )

   LOCAL i

   i := GetControlIndex ( ControlName, ParentForm )

   RETURN   ( _HMG_SYSDATA [ 29 ] [i] [1] )

FUNCTION _GetFontItalic ( ControlName, ParentForm )

   LOCAL i

   i := GetControlIndex ( ControlName, ParentForm )

   RETURN   ( _HMG_SYSDATA [ 29 ] [i] [2] )

FUNCTION _GetFontUnderline ( ControlName, ParentForm )

   LOCAL i

   i := GetControlIndex ( ControlName, ParentForm )

   RETURN   ( _HMG_SYSDATA [ 29 ] [i] [3] )

FUNCTION _GetFontStrikeOut ( ControlName, ParentForm )

   LOCAL i

   i := GetControlIndex ( ControlName, ParentForm )

   RETURN   ( _HMG_SYSDATA [ 29 ] [i] [4] )

FUNCTION _SetFontName ( ControlName, ParentForm , Value )

   LOCAL i , h , s, ab , ai , au , as , x

   //H = GetControlHandle( ControlName , ParentForm )
   //T = GetControlType (ControlName,ParentForm)

   i := GetControlIndex ( ControlName, ParentForm )
   DELETEObject ( _HMG_SYSDATA [ 36 ] [i] )
   h := _HMG_SYSDATA [3] [i]
   s := _HMG_SYSDATA [ 28 ] [i]
   ab := _HMG_SYSDATA [ 29 ] [i] [1]
   ai := _HMG_SYSDATA [ 29 ] [i] [2]
   au := _HMG_SYSDATA [ 29 ] [i] [3]
   as := _HMG_SYSDATA [ 29 ] [i] [4]
   _HMG_SYSDATA [ 27 ] [i] := Value
   DO CASE
   CASE _HMG_SYSDATA [1] [i] == "SPINNER"
      SetFontNameSize ( h [1] , Value , s , ab , ai , au , as )

   CASE _HMG_SYSDATA [1] [i] == "RADIOGROUP"

      FOR x := 1 To HMG_LEN (h)
         SetFontNameSize ( h [x] , Value , s , ab , ai , au , as )
      NEXT x

   OTHERWISE
      SetFontNameSize ( h , Value , s , ab , ai , au , as )
   ENDCASE

   RedrawLabel (i)

   RETURN NIL

FUNCTION _SetFontSize ( ControlName, ParentForm , Value  )

   LOCAL i , h , n , ab , ai , au , as , x

   i := GetControlIndex ( ControlName, ParentForm )
   DELETEObject ( _HMG_SYSDATA [ 36 ] [i] )
   h := _HMG_SYSDATA [3] [i]
   n := _HMG_SYSDATA [ 27 ] [i]
   ab := _HMG_SYSDATA [ 29 ] [i] [1]
   ai := _HMG_SYSDATA [ 29 ] [i] [2]
   au := _HMG_SYSDATA [ 29 ] [i] [3]
   as := _HMG_SYSDATA [ 29 ] [i] [4]
   _HMG_SYSDATA [ 28 ] [i] := Value
   DO CASE
   CASE _HMG_SYSDATA [1] [i] == "SPINNER"
      SetFontNameSize ( h [1], n , Value , ab , ai , au , as )

   CASE _HMG_SYSDATA [1] [i] == "RADIOGROUP"

      FOR x := 1 To HMG_LEN (h)
         SetFontNameSize ( h [x], n , Value , ab , ai , au , as )
      NEXT x

   OTHERWISE
      SetFontNameSize ( h , n , Value , ab , ai , au , as )
   ENDCASE

   RedrawLabel (i)

   RETURN NIL

FUNCTION _SetFontBold ( ControlName, ParentForm , Value  )

   LOCAL i , h , n , s , ai , au , as , x

   i := GetControlIndex ( ControlName, ParentForm )
   DELETEObject ( _HMG_SYSDATA [ 36 ] [i] )
   h := _HMG_SYSDATA [3] [i]
   n := _HMG_SYSDATA [ 27 ] [i]
   s := _HMG_SYSDATA [ 28 ] [i]
   ai := _HMG_SYSDATA [ 29 ] [i] [2]
   au := _HMG_SYSDATA [ 29 ] [i] [3]
   as := _HMG_SYSDATA [ 29 ] [i] [4]
   _HMG_SYSDATA [ 29 ] [i] [1] := Value
   DO CASE
   CASE _HMG_SYSDATA [1] [i] == "SPINNER"

      SetFontNameSize ( h [1], n , s , Value , ai , au , as )

   CASE _HMG_SYSDATA [1] [i] == "RADIOGROUP"

      FOR x := 1 To HMG_LEN (h)

         SetFontNameSize ( h [x], n , s , Value , ai , au , as )

      NEXT x

   OTHERWISE
      SetFontNameSize ( h , n , s , Value , ai , au , as )
   ENDCASE

   RedrawLabel (i)

   RETURN NIL

FUNCTION _SetFontItalic ( ControlName, ParentForm , Value  )

   LOCAL i , h , n , s , ab , au , as , x

   i := GetControlIndex ( ControlName, ParentForm )
   DELETEObject ( _HMG_SYSDATA [ 36 ] [i] )
   h := _HMG_SYSDATA [3] [i]
   n := _HMG_SYSDATA [ 27 ] [i]
   s := _HMG_SYSDATA [ 28 ] [i]
   ab := _HMG_SYSDATA [ 29 ] [i] [1]
   au := _HMG_SYSDATA [ 29 ] [i] [3]
   as := _HMG_SYSDATA [ 29 ] [i] [4]
   _HMG_SYSDATA [ 29 ] [i] [2] := Value
   DO CASE
   CASE _HMG_SYSDATA [1] [i] == "SPINNER"

      SetFontNameSize ( h [1], n , s , ab , Value , au , as )

   CASE _HMG_SYSDATA [1] [i] == "RADIOGROUP"

      FOR x := 1 To HMG_LEN (h)

         SetFontNameSize ( h [x], n , s , ab , Value , au , as )

      NEXT x

   OTHERWISE
      SetFontNameSize ( h , n , s , ab , Value , au , as )
   ENDCASE

   RedrawLabel (i)

   RETURN NIL

FUNCTION _SetFontUnderline ( ControlName, ParentForm , Value  )

   LOCAL i , h , n , s , ab , ai , as , x

   i := GetControlIndex ( ControlName, ParentForm )
   DELETEObject ( _HMG_SYSDATA [ 36 ] [i] )
   h := _HMG_SYSDATA [3] [i]
   n := _HMG_SYSDATA [ 27 ] [i]
   s := _HMG_SYSDATA [ 28 ] [i]
   ab := _HMG_SYSDATA [ 29 ] [i] [1]
   ai := _HMG_SYSDATA [ 29 ] [i] [2]
   as := _HMG_SYSDATA [ 29 ] [i] [4]
   _HMG_SYSDATA [ 29 ] [i] [3] := Value
   DO CASE
   CASE _HMG_SYSDATA [1] [i] == "SPINNER"
      SetFontNameSize ( h [1], n , s , ab , ai , Value , as )

   CASE _HMG_SYSDATA [1] [i] == "RADIOGROUP"

      FOR x := 1 To HMG_LEN (h)

         SetFontNameSize ( h [x], n , s , ab , ai , Value , as )

      NEXT x

   OTHERWISE
      SetFontNameSize ( h , n , s , ab , ai , Value , as )
   ENDCASE

   RedrawLabel (i)

   RETURN NIL

FUNCTION _SetFontStrikeOut ( ControlName, ParentForm , Value  )

   LOCAL i , h , n , s , ab , ai , au , x

   i := GetControlIndex ( ControlName, ParentForm )
   DELETEObject ( _HMG_SYSDATA [ 36 ] [i] )
   h := _HMG_SYSDATA [3] [i]
   n := _HMG_SYSDATA [ 27 ] [i]
   s := _HMG_SYSDATA [ 28 ] [i]
   ab := _HMG_SYSDATA [ 29 ] [i] [1]
   ai := _HMG_SYSDATA [ 29 ] [i] [2]
   au := _HMG_SYSDATA [ 29 ] [i] [3]
   _HMG_SYSDATA [ 29 ] [i] [4] := Value
   DO CASE
   CASE _HMG_SYSDATA [1] [i] == "SPINNER"
      SetFontNameSize ( h [1], n , s , ab , ai , au , Value )

   CASE _HMG_SYSDATA [1] [i] == "RADIOGROUP"

      FOR x := 1 To HMG_LEN (h)

         SetFontNameSize ( h [x], n , s , ab , ai , au , Value )

      NEXT x

   OTHERWISE
      SetFontNameSize ( h , n , s , ab , ai , au , Value )
   ENDCASE

   RedrawLabel (i)

   RETURN NIL

   * by Dr. Claudio Soto (July 2014)

FUNCTION GetControlFont ( ControlName, ParentForm )

   LOCAL i := GetControlIndex ( ControlName, ParentForm )
   LOCAL aFontData := {}

   AADD ( aFontData , _HMG_SYSDATA [ 27 ] [i] )         //   FontName
   AADD ( aFontData , _HMG_SYSDATA [ 28 ] [i] )         //   FontSize
   AADD ( aFontData , _HMG_SYSDATA [ 29 ] [i] [ 1 ] )   //   Bold
   AADD ( aFontData , _HMG_SYSDATA [ 29 ] [i] [ 2 ] )   //   Italic
   AADD ( aFontData , _HMG_SYSDATA [ 29 ] [i] [ 3 ] )   //   Underline
   AADD ( aFontData , _HMG_SYSDATA [ 29 ] [i] [ 4 ] )   //   Strikeout

   RETURN aFontData

FUNCTION GetControlFontByIndex ( i )

   LOCAL aFontData := {}

   AADD ( aFontData , _HMG_SYSDATA [ 27 ] [i] )         //   FontName
   AADD ( aFontData , _HMG_SYSDATA [ 28 ] [i] )         //   FontSize
   AADD ( aFontData , _HMG_SYSDATA [ 29 ] [i] [ 1 ] )   //   Bold
   AADD ( aFontData , _HMG_SYSDATA [ 29 ] [i] [ 2 ] )   //   Italic
   AADD ( aFontData , _HMG_SYSDATA [ 29 ] [i] [ 3 ] )   //   Underline
   AADD ( aFontData , _HMG_SYSDATA [ 29 ] [i] [ 4 ] )   //   Strikeout

   RETURN aFontData

FUNCTION GetControlFontHandle ( ControlName, ParentForm )

   LOCAL i := GetControlIndex ( ControlName, ParentForm )

   RETURN _HMG_SYSDATA [ 36 ] [i]

FUNCTION GetControlFontHandleByIndex ( i )

   RETURN _HMG_SYSDATA [ 36 ] [i]

FUNCTION SetControlFont ( ControlName, ParentForm , aFont )

   LOCAL i := GetControlIndex (ControlName, ParentForm)
   LOCAL ControlHandle := GetControlHandle (ControlName, ParentForm)
   LOCAL hFont := _SetFont (ControlHandle, aFont[1], aFont[2], aFont[3], aFont[4], aFont[5], aFont[6])

   DELETEObject (_HMG_SYSDATA [ 36 ] [i])
   _HMG_SYSDATA [ 36 ] [i] := hFont
   RedrawLabel (i)

   RETURN hFont

FUNCTION SetControlFontByIndex ( i , aFont )

   LOCAL ControlHandle := _HMG_SYSDATA [ 3 ] [i]
   LOCAL hFont := _SetFont (ControlHandle, aFont[1], aFont[2], aFont[3], aFont[4], aFont[5], aFont[6])

   DELETEObject (_HMG_SYSDATA [ 36 ] [i])
   _HMG_SYSDATA [ 36 ] [i] := hFont
   RedrawLabel (i)

   RETURN hFont

FUNCTION ChangeControlFontSize ( ControlName, ParentForm , nSize )

   LOCAL i             := GetControlIndex  (ControlName, ParentForm)
   LOCAL ControlHandle := ControlHandle := _HMG_SYSDATA [ 3 ] [i]
   LOCAL aFont         := GetControlFontByIndex ( i )
   LOCAL hFont

   IF ValType (nSize) == "N" .AND. nSize > 0
      aFont[2] := nSize
   ENDIF
   hFont := _SetFont (ControlHandle, aFont[1], aFont[2], aFont[3], aFont[4], aFont[5], aFont[6])
   DELETEObject (_HMG_SYSDATA [ 36 ] [i])
   _HMG_SYSDATA [ 36 ] [i] := hFont
   RedrawLabel (i)

   RETURN hFont
