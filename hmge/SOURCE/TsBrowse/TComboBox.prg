#include "minigui.ch"
#include "hbclass.ch"
#include "TSBrowse.ch"

#define CBS_NOINTEGRALHEIGHT  0x0400

#define COMBO_BASE      320

#define CB_SETEDITSEL    ( COMBO_BASE +  2 )
#define CB_SHOWDROPDOWN  ( COMBO_BASE + 15 )
#define CB_ERR              -1
#define CBN_CLOSEUP   8

* ============================================================================
* CLASS TComboBox  Driver for ComboBox  TSBrowse 7.0
* ============================================================================

CLASS TComboBox FROM TControl

   CLASSDATA lRegistered AS LOGICAL
   DATA   Atx, lAppend, nAt
   DATA   aItems AS ARRAY                     // Combo array
   DATA   bCloseUp                            // Block to be evaluated on Close Combo

   METHOD New( nRow, nCol, bSetGet, aGetData, nWidth, nHeight, oWnd, bChanged,;
      nClrFore, nClrBack, hFont, cMsg, cControl, cWnd )
   METHOD Default()
   METHOD GetDlgCode( nLastKey, nFlags )
   METHOD HandleEvent( nMsg, nWParam, nLParam )
   METHOD KeyDown( nKey, nFlags )
   METHOD KeyChar( nKey, nFlags )
   METHOD LButtonDown( nRow, nCol )
   METHOD LostFocus()

   ENDCLASS

   * ============================================================================
   * METHOD TComboBox:New() Version 7.0
   * ============================================================================

METHOD New( nRow, nCol, bSetGet, aGetData, nWidth, nHeight, oWnd, bChanged,;
      nClrFore, nClrBack, hFont, cMsg, cControl, cWnd ) CLASS TComboBox

   LOCAL invisible := .F.
   LOCAL sort      := .F.
   LOCAL displaychange := .F.
   LOCAL notabstop := .F.
   LOCAL ParentHandle

   DEFAULT nClrFore  := GetSysColor( COLOR_WINDOWTEXT ),;
      nClrBack  := GetSysColor( COLOR_WINDOW ),;
      nHeight   := 12   //If( oFont != nil, oFont:nHeight, 12 ),;

   ::nTop     = nRow
   ::nLeft    = nCol
   ::nBottom  = ::nTop + nHeight - 1
   ::nRight   = ::nLeft + nWidth - 1
   IF oWnd == Nil
      oWnd       := Self
      oWnd:hWnd  := GetFormHandle (cWnd)                    //JP
   ENDIF
   ::oWnd         := oWnd
   ParentHandle   := oWnd:hWnd
   IF _HMG_BeginWindowMDIActive
      ParentHandle:=  GetActiveMdiHandle()
      cWnd   := _GetWindowProperty ( ParentHandle, "PROP_FORMNAME" )
   ENDIF
   ::nId          := ::GetNewId()
   ::cControlName := cControl
   ::cParentWnd   := cWnd
   ::nStyle       := nOR( WS_CHILD, WS_VISIBLE,  WS_TABSTOP,;
      WS_VSCROLL, WS_BORDER , CBS_DROPDOWN, CBS_NOINTEGRALHEIGHT )

   ::bSetGet      := bSetGet
   ::aItems       := aGetData
   ::lCaptured    := .f.
   ::hFont        := hFont
   ::cMsg         := cMsg
   ::bChange      := bChanged
   ::lFocused     := .F.
   ::lAppend      := .F.
   ::nLastKey     := 0
   ::Atx          := 0

   ::SetColor( nClrFore, nClrBack )

   IF ! Empty( ParentHandle )

      ::hWnd := InitComboBox ( ParentHandle, 0, nCol, nRow, nWidth , '', 0 , nHeight, invisible, notabstop, sort , displaychange , _HMG_IsXP )

      ::AddVars( ::hWnd )
      ::Default()

      IF GetObjectType( hFont ) == OBJ_FONT
         _SetFontHandle( ::hWnd, hFont )
         ::hFont := hFont
      ENDIF

      oWnd:AddControl( ::hWnd )

   ENDIF

   RETURN Self

   * ============================================================================
   * METHOD TComboBox:Default() Version 7.0 Jul/15/2004
   * ============================================================================

METHOD Default() CLASS TComboBox

   LOCAL i

   FOR i = 1 to len (::aItems)
      ComboAddString (::hWnd, ::aItems[i] )
      IF i == Eval( ::bSetGet )
         ComboSetCurSel ( ::hWnd, i )
      ENDIF
   NEXT

   RETURN NIL

   * ============================================================================
   * METHOD TComboBox:GetDlgCode() Version 7.0 Jul/15/2004
   * ============================================================================

METHOD GetDlgCode( nLastKey, nFlags ) CLASS TComboBox

   HB_SYMBOL_UNUSED( nFlags )
   ::nLastKey := nLastKey

   RETURN DLGC_WANTALLKEYS

   * ============================================================================
   * METHOD TComboBox:HandleEvent() Version 7.0 Jul/15/2004
   * ============================================================================

METHOD HandleEvent( nMsg, nWParam, nLParam ) CLASS TComboBox

   // just used for some testings
   /* fDebug( "nMsg="+AllTrim(cValTochar(nMsg))+" nWParam="+;
   AllTrim(cValTochar(nWParam))+;
   " nLoWord="+AllTrim(cValTochar(nLoWord(nLParam)))+;
   " nHiWord="+AllTrim(cValTochar(nHiWord(nLParam)))+CRLF+;
   " ProcName="+ProcName(2)+Space(1)+LTrim(Str(ProcLine(2)))+space(1)+;
   ProcName(3)+Space(1)+LTrim(Str(Procline(3))) ) */

   IF HIWORD(nWParam) == CBN_CLOSEUP
      IF ::bCloseUp <> NiL
         If( ValType(::bCloseUp ) == "B", Eval(::bCloseUp, Self ), ::bCloseUp(Self) )

         RETURN 0
      ENDIF
   ENDIF

   RETURN ::Super:HandleEvent( nMsg, nWParam, nLParam )

   * ============================================================================
   * METHOD TComboBox:KeyDown() Version 7.0 Jul/15/2004
   * ============================================================================

METHOD KeyDown( nKey, nFlags ) CLASS TComboBox

   LOCAL nAt := ::SendMsg( CB_GETCURSEL )

   IF nAt != CB_ERR
      ::nAt = nAt + 1
   ENDIF

   ::nLastKey := nKey
   IF nKey == VK_TAB .or. nKey == VK_RETURN .or. nKey == VK_ESCAPE
      ::bLostFocus := Nil
      Eval( ::bKeyDown, nKey, nFlags, .T. )

      RETURN 0
   ELSE

      RETURN ::Super:KeyDown(nKey, nFlags)
   ENDIF

   RETURN NIL

   * ============================================================================
   * METHOD TComboBox:LostFocus() Version 7.0 Jul/15/2004
   * ============================================================================

METHOD LostFocus() CLASS TComboBox

   LOCAL nAt

   DEFAULT ::lAppend := .F.

   IF ::nLastKey == Nil .and. ::lAppend
      ::SetFocus()
      ::nLastKey := 0

      RETURN 0
   ENDIF

   nAt := ::SendMsg( CB_GETCURSEL )

   IF nAt != CB_ERR
      ::nAt = nAt + 1
      IF ValType( Eval( ::bSetGet ) ) == "N"
         Eval( ::bSetGet, nAt + 1 )
      ELSE
         Eval( ::bSetGet, ::aItems[ nAt + 1 ] )
      ENDIF
   ELSE
      Eval( ::bSetGet, GetWindowText( ::hWnd ) )
   ENDIF

   ::lFocused := .F.

   IF ::bLostFocus != Nil
      Eval( ::bLostFocus, ::nLastKey )
   ENDIF

   RETURN 0

   * ============================================================================
   * METHOD TComboBox:KeyChar() Version 7.0 Jul/15/2004
   * ============================================================================

METHOD KeyChar( nKey, nFlags ) CLASS TComboBox

   DO CASE
   CASE nKey == VK_TAB

      RETURN 0            // We don't want API default behavior

   CASE nKey == VK_ESCAPE

      RETURN 0

   CASE nKey == VK_RETURN

      RETURN 0

   OTHERWISE

      RETURN ::Super:Keychar( nKey, nFlags )
   ENDCASE

   RETURN 0

   * ============================================================================
   * METHOD TComboBox:LButtonDown() Version 7.0 Jul/15/2004
   * ============================================================================

METHOD LButtonDown( nRow, nCol ) CLASS TComboBox

   LOCAL nShow := 1

   HB_SYMBOL_UNUSED( nRow )
   HB_SYMBOL_UNUSED( nCol )

   IF ::nLastKey != Nil .and. ::nLastKey == 9999
      nShow := 0
      ::nLastKey := 0
   ELSE
      ::nLastKey := 9999
   ENDIF

   ::PostMsg( CB_SHOWDROPDOWN, nShow, 0 )

   RETURN 0
