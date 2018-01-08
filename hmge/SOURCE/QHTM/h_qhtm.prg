/*----------------------------------------------------------------------------
MINIGUI - Harbour Win32 GUI library source code

Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
http://harbourminigui.googlepages.com/

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
contained in this release of Harbour Minigui.

The exception is that, if you link the Harbour Minigui library with other
files to produce an executable, this does not by itself cause the resulting
executable to be covered by the GNU General Public License.
Your use of that executable is in no way restricted on account of linking the
Harbour-Minigui library code into it.

Parts of this project are based upon:

"Harbour GUI framework for Win32"
Copyright 2001 Alexander S.Kresin <alex@belacy.ru>
Copyright 2001 Antonio Linares <alinares@fivetech.com>
www - http://www.harbour-project.org

"Harbour Project"
Copyright 1999-2016, http://harbour-project.org/

---------------------------------------------------------------------------*/

#include "minigui.ch"
#include "i_QHTM.ch"

#define WS_BORDER           0x00800000
#define WM_SETREDRAW        0x0b

/******
*       _DefineQhtm( ControlName, ParentForm, x, y, w, h, Value, fname, resname, ;
*                    fontname, fontsize, Change, lBorder, nId )
*       Define QHTM control
*/

FUNCTION _DefineQhtm( ControlName, ParentForm, x, y, w, h, Value, fname, resname, ;
      fontname, fontsize, Change, lBorder, nId )
   LOCAL mVar, k := 0, ControlHandle, ParentFormHandle
   LOCAL FontHandle, bold, italic, underline, strikeout

   IF ( FontHandle := GetFontHandle( FontName ) ) <> 0
      GetFontParamByRef( FontHandle, @FontName, @FontSize, @bold, @italic, @underline, @strikeout )
   ENDIF

   IF _HMG_BeginWindowActive

      ParentForm := _HMG_ActiveFormName

      IF !Empty( ParentForm ) .and. ValType( FontName ) == "U"
         FONTNAME := _HMG_ActiveFontName
      ENDIF

      IF !Empty( ParentForm ) .and. ValType( FontSize ) == "U"
         FontSize := _HMG_ActiveFontSize
      ENDIF

   ENDIF

   IF !_IsWindowDefined( ParentForm )
      MsgMiniGuiError( "Window: " + ParentForm + " is not defined." )
   ENDIF

   IF _IsControlDefined( ControlName, ParentForm )
      MsgMiniGuiError( "Control: " + ControlName + " Of " + ParentForm + " Already defined." )
   ENDIF

   hb_default( @nId, _GetId() )

   mVar := '_' + ParentForm + '_' + ControlName

   ParentFormHandle := GetFormHandle( ParentForm )

   ControlHandle := CreateQHTM( ParentFormHandle, nId, Iif( lBorder, WS_BORDER, 0 ), y, x, w, h )

   IF ( FontHandle <> 0 )
      _SetFontHandle( ControlHandle, FontHandle )
   ELSE
      __defaultNIL( @FontName, _HMG_DefaultFontName )
      __defaultNIL( @FontSize, _HMG_DefaultFontSize )

      FontHandle := _SetFont( ControlHandle, FontName, FontSize, bold, italic, underline, strikeout )
   ENDIF

   IF ( Valtype( Value ) == 'C' )
      SetWindowText( ControlHandle, Value )   // define from a variable
   ELSEIF ( Valtype( fname ) == 'C' )
      QHTM_LoadFile( ControlHandle, fname )   // loading from a file
   ELSEIF ( Valtype( resname ) == 'C' )
      QHTM_LoadRes( ControlHandle, resname )  // loading from a resource
   ENDIF

   QHTM_FormCallBack( ControlHandle )         // set a handling procedure of the web-form

   k := _GetControlFree()

   PUBLIC &mVar. := k

   _HMG_aControlType [k] :=  "QHTM"
   _HMG_aControlNames [k] :=  ControlName
   _HMG_aControlHandles [k] :=  ControlHandle
   _HMG_aControlParenthandles [k] :=  ParentFormHandle
   _HMG_aControlIds [k] :=   nId
   _HMG_aControlProcedures  [k] :=  ""
   _HMG_aControlPageMap  [k] :=  {}
   _HMG_aControlValue  [k] :=  Value
   _HMG_aControlInputMask  [k] :=  ""
   _HMG_aControllostFocusProcedure  [k] :=  ""
   _HMG_aControlGotFocusProcedure  [k] :=  ""
   _HMG_aControlChangeProcedure  [k] :=  Change
   _HMG_aControlDeleted  [k] :=  .F.
   _HMG_aControlBkColor   [k] := Nil
   _HMG_aControlFontColor   [k] := Nil
   _HMG_aControlDblClick   [k] := ""
   _HMG_aControlHeadClick   [k] := {}
   _HMG_aControlRow  [k] :=  x
   _HMG_aControlCol  [k] :=  y
   _HMG_aControlWidth   [k] := w
   _HMG_aControlHeight  [k] := h
   _HMG_aControlSpacing  [k] :=  0
   _HMG_aControlContainerRow  [k] :=  iif ( _HMG_FrameLevel > 0 ,_HMG_ActiveFrameRow [_HMG_FrameLevel] , -1 )
   _HMG_aControlContainerCol  [k] :=  iif ( _HMG_FrameLevel > 0 ,_HMG_ActiveFrameCol [_HMG_FrameLevel] , -1 )
   _HMG_aControlPicture  [k] :=  ''
   _HMG_aControlContainerHandle  [k] :=  0
   _HMG_aControlFontName  [k] :=  fontname
   _HMG_aControlFontSize  [k] :=  fontsize
   _HMG_aControlFontAttributes  [k] :=  {bold,italic,underline,strikeout}
   _HMG_aControlToolTip   [k] :=  ''
   _HMG_aControlRangeMin  [k] :=  0
   _HMG_aControlRangeMax  [k] :=  0
   _HMG_aControlCaption  [k] :=  ''
   _HMG_aControlVisible  [k] :=  .t.
   _HMG_aControlHelpId  [k] :=  0
   _HMG_aControlFontHandle  [k] :=  FontHandle
   _HMG_aControlBrushHandle  [k] :=  0
   _HMG_aControlEnabled  [k] :=  .T.
   _HMG_aControlMiscData1 [k] := 0
   _HMG_aControlMiscData2 [k] := ''

   RETURN NIL

   /******
   *       QHTM_LoadFromVal( ControlName, ParentForm, cValue )
   *       Load web-page from variable
   */

PROCEDURE QHTM_LoadFromVal( ControlName, ParentForm, cValue )

   LOCAL nHandle := GetControlHandle( ControlName, ParentForm )

   IF ( nHandle > 0 )
      SetWindowText( nHandle, cValue )
   ENDIF

   RETURN

   /******
   *       QHTM_LoadFromFile( ControlName, ParentForm, cFile )
   *       Load web-page from file
   */

PROCEDURE QHTM_LoadFromFile( ControlName, ParentForm, cFile )

   LOCAL nHandle := GetControlHandle( ControlName, ParentForm )

   IF ( nHandle > 0 )
      QHTM_LoadFile( nHandle, cFile )
   ENDIF

   RETURN

   /******
   *       QHTM_LoadFromRes( ControlName, ParentForm, cResName )
   *       Load web-page from resource
   */

PROCEDURE QHTM_LoadFromRes( ControlName, ParentForm, cResName )

   LOCAL nHandle := GetControlHandle( ControlName, ParentForm )

   IF ( nHandle > 0 )
      QHTM_LoadRes( nHandle, cResName )
   ENDIF

   RETURN

   /******
   *       QHTM_GetLink( lParam )
   *       Receive QHTM link
   */

FUNCTION QHTM_GetLink( lParam )

   LOCAL cLink := QHTM_GetNotify( lParam )

   QHTM_SetReturnValue( lParam, .F. )

   RETURN cLink

   /******
   *       QHTM_ScrollPos( nHandle, nPos )
   *       nHandle - descriptor of QHTM
   *       nPos - old/new position of scrollbar
   *       Get/Set position of scrollbar QHTM
   */

FUNCTION QHTM_ScrollPos( nHandle, nPos )

   LOCAL nParamCount := PCount()

   SWITCH nParamCount

   CASE 0  // no params
      nPos := 0
      EXIT

   CASE 1
      IF IsNumber( nHandle )
         nPos := QHTM_GetScrollPos( nHandle )
      ENDIF
      EXIT

   CASE 2
      IF ( IsNumber( nHandle ) .and. IsNumber( nPos ) )
         QHTM_SetScrollPos( nHandle, nPos )
      ELSE
         nPos := 0
      ENDIF

   END SWITCH

   RETURN nPos

   /******
   *       QHTM_ScrollPercent( nHandle, nPercent )
   *       nHandle  - descriptor of QHTM
   *       nPercent - old/new position of scrollbar (in percentage)
   *       Get/Set position of scrollbar QHTM
   */

FUNCTION QHTM_ScrollPercent( nHandle, nPercent )

   LOCAL nParamCount := PCount(), ;
      nHeight                , ;
      aSize                  , ;
      nPos

   IF IsNumber( nHandle )

      nHeight := GetWindowHeight( nHandle )
      aSize := QHTM_GetSize( nHandle )

      // an amendment on a height of the QHTM

      IF ( aSize[ 2 ] > nHeight )
         aSize[ 2 ] -= nHeight
      ENDIF

   ENDIF

   SWITCH nParamCount

   CASE 0
      nPercent := 0
      EXIT

   CASE 1
      nPos  := QHTM_GetScrollPos( nHandle )
      nPercent := Min( Round( ( ( nPos / aSize[ 2 ] ) * 100 ), 2 ), 100.00 )
      EXIT

   CASE 2
      IF IsNumber( nPercent )
         nPos := Round( ( nPercent * aSize[ 2 ] * 0.01 ), 0 )
         QHTM_SetScrollPos( nHandle, nPos )
      ELSE
         nPercent := 0
      ENDIF

   END SWITCH

   RETURN nPercent

   /******
   *       QHTM_EnableUpdate( ControlName, ParentForm, lEnable )
   *       Enable/disable redraw of control
   */

PROCEDURE QHTM_EnableUpdate( ControlName, ParentForm, lEnable )

   IF ( PCount() < 2 )

      RETURN
   ENDIF

   hb_default( @lEnable, .T. )

   SendMessage( GetControlHandle( ControlName, ParentForm ), WM_SETREDRAW, iif( lEnable, 1, 0 ), 0 )

   RETURN
