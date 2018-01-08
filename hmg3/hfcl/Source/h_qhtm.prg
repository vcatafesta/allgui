
#include "hmg.ch"

#define WS_BORDER           0x00800000
#define WM_SETREDRAW        0x0b

/******
*       Define QHTM control
*/

FUNCTION _DefineQhtm( ControlName, ParentForm, x, y, w, h, Value, fname, resname, fontname, fontsize, Change, lBorder, bold, italic, underline, strikeout)

   LOCAL mVar, k := 0, ControlHandle, FontHandle, nId

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
         x  := x + _HMG_SYSDATA [ 334 ] [_HMG_SYSDATA [ 183 ]]
         y  := y + _HMG_SYSDATA [ 333 ] [_HMG_SYSDATA [ 183 ]]
         ParentForm := _HMG_SYSDATA [ 332 ] [_HMG_SYSDATA [ 183 ]]
         cParentTabName := _HMG_SYSDATA [ 225 ]
      ENDIF
   ENDIF

   IF .Not. _IsWindowDefined (ParentForm)
      MsgHMGError(_HMG_SYSDATA [ 136 ][1]+ ParentForm + _HMG_SYSDATA [ 136 ][2])
   ENDIF

   IF _IsControlDefined (ControlName,ParentForm)
      MsgHMGError (_HMG_SYSDATA [ 136 ][4] + ControlName + _HMG_SYSDATA [ 136 ][5] + ParentForm + _HMG_SYSDATA [ 136 ][6])
   ENDIF

   mVar := '_' + ParentForm + '_' + ControlName

   cParentForm = ParentForm

   ParentForm = GetFormHandle (ParentForm)

   nId := _GetId()

   ControlHandle := CreateQHTM(ParentForm, nId, IIF (lBorder ==.T., WS_BORDER, 0), y, x, w, h)

   IF ValType(fontname) != "U" .and. ValType(fontsize) != "U"
      FontHandle := _SetFont (ControlHandle,FontName,FontSize,bold,italic,underline,strikeout)
   ELSE
      FontHandle := _SetFont (ControlHandle,_HMG_SYSDATA [ 342 ],_HMG_SYSDATA [ 343 ],bold,italic,underline,strikeout)
   ENDIF

   IF ( Valtype( Value ) == 'C' )
      SetWindowText( ControlHandle, Value )
   ELSEIF ( Valtype( fname ) == 'C' )
      QHTM_LoadFile( ControlHandle, fname )
   ELSEIF ( Valtype( resname ) == 'C' )
      QHTM_LoadRes( ControlHandle, resname )
   ENDIF

   QHTM_FormCallBack( ControlHandle )

   k := _GetControlFree()
   PUBLIC &mVar. := k

   _HMG_SYSDATA [  1 ]   [k] := 'QHTM'
   _HMG_SYSDATA [  2 ]   [k] := ControlName
   _HMG_SYSDATA [  3 ]   [k] := ControlHandle
   _HMG_SYSDATA [  4 ]   [k] := ParentForm
   _HMG_SYSDATA [  5 ]   [k] := nId
   _HMG_SYSDATA [  6 ]   [k] := ""
   _HMG_SYSDATA [  7 ]   [k] := {}
   _HMG_SYSDATA [  8 ]   [k] := Value
   _HMG_SYSDATA [  9 ]   [k] := ""
   _HMG_SYSDATA [ 10 ]   [k] := ""
   _HMG_SYSDATA [ 11 ]   [k] := ""
   _HMG_SYSDATA [ 12 ]   [k] := Change
   _HMG_SYSDATA [ 13 ]   [k] := .F.
   _HMG_SYSDATA [ 14 ]   [k] := NIL
   _HMG_SYSDATA [ 15 ]   [k] := NIL
   _HMG_SYSDATA [ 16 ]   [k] := ""
   _HMG_SYSDATA [ 17 ]   [k] := {}
   _HMG_SYSDATA [ 18 ]   [k] := x
   _HMG_SYSDATA [ 19 ]   [k] := y
   _HMG_SYSDATA [ 20 ]   [k] := w
   _HMG_SYSDATA [ 21 ]   [k] := h
   _HMG_SYSDATA [ 22 ]   [k] := 0
   _HMG_SYSDATA [ 23 ]   [k] := iif ( _HMG_SYSDATA [ 183 ] > 0 ,_HMG_SYSDATA [ 333 ] [_HMG_SYSDATA [ 183 ]] , -1 )
   _HMG_SYSDATA [ 24 ]   [k] := iif ( _HMG_SYSDATA [ 183 ] > 0 ,_HMG_SYSDATA [ 334 ] [_HMG_SYSDATA [ 183 ]] , -1 )
   _HMG_SYSDATA [ 25 ]   [k] := ''
   _HMG_SYSDATA [ 26 ]   [k] := 0
   _HMG_SYSDATA [ 27 ]   [k] := fontname
   _HMG_SYSDATA [ 28 ]   [k] := fontsize
   _HMG_SYSDATA [ 29 ]   [k] := {bold,italic,underline,strikeout}
   _HMG_SYSDATA [ 30 ]   [k] := ''
   _HMG_SYSDATA [ 31 ]   [k] := 0
   _HMG_SYSDATA [ 32 ]   [k] := 0
   _HMG_SYSDATA [ 33 ]   [k] := ''
   _HMG_SYSDATA [ 34 ]   [k] := .T.
   _HMG_SYSDATA [ 35 ]   [k] := 0
   _HMG_SYSDATA [ 36 ]   [k] := ''
   _HMG_SYSDATA [ 37 ]   [k] := 0
   _HMG_SYSDATA [ 38 ]   [k] := .T.
   _HMG_SYSDATA [ 39 ]   [k] := 0
   _HMG_SYSDATA [ 40 ]   [k] := ''

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

   CASE 0
      nPos := 0
      EXIT

   CASE 1

      IF HB_ISNUMERIC( nHandle )
         nPos := QHTM_GetScrollPos( nHandle )
      ENDIF
      EXIT

   CASE 2

      IF ( HB_ISNUMERIC( nHandle ) .and. HB_ISNUMERIC( nPos ) )
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

   IF HB_ISNUMERIC( nHandle )

      nHeight := GetWindowHeight( nHandle )
      aSize := QHTM_GetSize( nHandle )

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

      IF HB_ISNUMERIC( nPercent )
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

   IF Valtype(lEnable) == "U"
      lEnable := .T.
   ENDIF

   IF ( PCount() < 2 )

      RETURN
   ENDIF

   SendMessage( GetControlHandle( ControlName, ParentForm ), WM_SETREDRAW, Iif( lEnable, 1, 0 ), 0 )

   RETURN

FUNCTION QHTM_Zoom ( ControlName, ParentForm, nLevel )

   QHTM_SetZoomLevel(GetControlHandle( ControlName, ParentForm ), nLevel)

   RETURN NIL
