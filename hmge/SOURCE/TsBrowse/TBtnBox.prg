#include "minigui.ch"
#include "hbclass.ch"
#include "TSBrowse.ch"

#define EN_CHANGE      768    // 0x0300
#define EN_UPDATE      1024   // 0x0400
#define ES_NUMBER      8192
#define NM_KILLFOCUS   (-8)

* ============================================================================
* CLASS TBtnBox  Driver for BtnBox  TSBrowse 7.0
* ============================================================================

CLASS TBtnBox FROM TControl

   CLASSDATA lRegistered AS LOGICAL

   DATA Atx, lAppend, bAction, nCell, lChanged
   DATA hWndChild

   METHOD New( nRow, nCol, bSetGet, oWnd, nWidth, nHeight, cPict, ;
      nClrFore, nClrBack, hFont, cControl, cWnd, cMsg, bChanged, bValid,;
      cResName, bAction, lSpinner, bUp, bDown, bMin, bMax, nBmpWidth, nCell )
   METHOD Default()
   METHOD HandleEvent( nMsg, nWParam, nLParam )
   METHOD GetDlgCode( nLastKey, nFlags )
   METHOD KeyChar( nKey, nFlags )
   METHOD KeyDown( nKey, nFlags )
   METHOD LostFocus( hCtlFocus )
   METHOD lValid()
   METHOD LButtonDown( nRow, nCol )
   METHOD GetVal()
   METHOD Command( nWParam, nLParam )

ENDCLASS

* ============================================================================
* METHOD TBtnBox:New() Version 7.0
* ============================================================================

METHOD New( nRow, nCol, bSetGet, oWnd, nWidth, nHeight, cPict, ;
      nClrFore, nClrBack, hFont, cControl, cWnd, cMsg, bChanged, bValid,;
      cResName, bAction, lSpinner, bUp, bDown, bMin, bMax, nBmpWidth, nCell ) CLASS TBtnBox

   LOCAL invisible := .F.
   LOCAL notabstop := .F.
   LOCAL ParentHandle
   LOCAL nMaxLenght := 255
   LOCAL nMin , nMax

   HB_SYMBOL_UNUSED( cPict )
   HB_SYMBOL_UNUSED( bChanged )
   HB_SYMBOL_UNUSED( bDown )

   DEFAULT nClrFore  := GetSysColor( COLOR_WINDOWTEXT ),;
      nClrBack  := GetSysColor( COLOR_WINDOW ),;
      nHeight   := 12,;
      bMin      := {|| 0 },;
      bMax      := {|| 32000 }

   ::nTop         := nRow
   ::nLeft        := nCol
   ::nBottom      := ::nTop + nHeight - 2
   ::nRight       := ::nLeft + nWidth - 2
   ::oWnd         := oWnd
   ParentHandle   := oWnd:hWnd

   IF _HMG_BeginWindowMDIActive
      ParentHandle := GetActiveMdiHandle()
      cWnd := _GetWindowProperty ( ParentHandle, "PROP_FORMNAME" )
   ENDIF

   ::nId          := ::GetNewId()
   ::nStyle       := nOR( ES_NUMBER , WS_CHILD )
   ::cControlName := cControl
   ::cParentWnd   := cWnd
   ::hWndParent   := oWnd:hWnd
   ::bSetGet      := bSetGet
   ::lCaptured    := .f.
   ::hFont        := hFont
   ::lFocused     := .F.
   ::lAppend      := .F.
   ::nLastKey     := 0
   ::lChanged     := .f.

   ::cMsg         := cMsg
   ::bChange      := .T.
   ::bValid       := bValid
   ::bAction      := bAction
   ::nCell        := nCell
   ::Atx          := 0

   ::SetColor( nClrFore, nClrBack )

   IF ! Empty( ParentHandle )
      IF lSpinner
         ::Create( "EDIT" )
         nMin := If( ValType( bMin ) == "B", Eval( bMin ), bMin )
         nMax := If( ValType( bMax ) == "B", Eval( bMax ), bMax )
         ::hWndChild := InitedSpinner( ::hWndParent, ::hWnd , nCol, nRow, 0, nHeight, nMin, nMax, Eval( ::bSetGet ) )
         SetIncrementSpinner( ::hWndChild, bUp )
      ELSE
         ::hWnd := InitBtnTextBox( ParentHandle, 0, nCol, nRow, nWidth, nHeight, '', 0, nMaxLenght, ;
            .f., .f., .f., .f.,.f., invisible, notabstop, cResName, nBmpWidth, "", .f. )[1]
      ENDIF

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
   * METHOD TBtnBox:Default() Version 7.0
   * ============================================================================

METHOD Default() CLASS TBtnBox

   LOCAL cValue

   cValue := Eval( ::bSetGet )
   IF Valtype( cValue ) != 'C'
      cValue := AllTrim( Str( cValue ) )
   ENDIF

   IF Len( cValue ) > 0
      SetWindowText( ::hWnd , cValue )
   ENDIF

   RETURN NIL

   * ============================================================================
   * METHOD TBtnBox:HandleEvent() Version 7.0
   * ============================================================================

METHOD HandleEvent( nMsg, nWParam, nLParam ) CLASS TBtnBox

   // just used for some testings
   IF nMsg == WM_NOTIFY
      IF HiWord( nWParam ) == NM_KILLFOCUS
         ::LostFocus()
      ENDIF
   ENDIF

   RETURN ::Super:HandleEvent( nMsg, nWParam, nLParam )

   * ============================================================================
   * METHOD TBtnBox:GetDlgCode() Version 7.0
   * ============================================================================

METHOD GetDlgCode( nLastKey, nFlags ) CLASS TBtnBox

   HB_SYMBOL_UNUSED( nFlags )
   ::nLastKey := nLastKey

   RETURN DLGC_WANTALLKEYS + DLGC_WANTCHARS

   * ============================================================================
   * METHOD TBtnBox:KeyChar() Version 7.0
   * ============================================================================

METHOD KeyChar( nKey, nFlags ) CLASS TBtnBox

   IF _GetKeyState( VK_CONTROL )
      nKey := If( Upper( Chr( nKey ) ) == "W" .or. nKey == VK_RETURN, VK_TAB, nKey )
   ENDIF

   IF nKey == VK_TAB .or. nKey == VK_ESCAPE

      RETURN 0
   ENDIF

   RETURN ::Super:KeyChar( nKey, nFlags )

   * ============================================================================
   * METHOD TBtnBox:KeyDown() Version 7.0
   * ============================================================================

METHOD KeyDown( nKey, nFlags ) CLASS TBtnBox

   ::nLastKey := nKey
   IF nKey == VK_TAB .or. nKey == VK_RETURN .or. nKey == VK_ESCAPE

      IF nKey != VK_ESCAPE
         IF ::bSetGet != Nil
            Eval( ::bSetGet, ::GetVal() )
         ENDIF
      ENDIF
      ::bLostFocus := Nil
      Eval( ::bKeyDown, nKey, nFlags, .T. )
   ENDIF

   RETURN 0

   * ============================================================================
   * METHOD TBtnBox:lValid() Version 7.0
   * ============================================================================

METHOD lValid() CLASS TBtnBox

   LOCAL lRet := .t.

   IF ValType( ::bValid ) == "B"
      lRet := Eval( ::bValid, ::GetVal() )
   ENDIF

   RETURN lRet

   * ============================================================================
   * METHOD TBtnBox:LostFocus() Version 7.0
   * ============================================================================

METHOD LostFocus( hCtlFocus ) CLASS TBtnBox

   DEFAULT ::lAppend := .F.

   IF ::nLastKey == Nil .and. ::lAppend
      ::SetFocus()
      ::nLastKey := 0

      RETURN 0
   ENDIF
   ::lFocused := .F.
   IF ::bLostFocus != Nil
      Eval( ::bLostFocus, ::nLastKey, hCtlFocus )
   ENDIF
   IF ::hWndChild != Nil
      ::SetFocus()
   ENDIF

   RETURN 0

   * ============================================================================
   * METHOD TBtnBox:LButtonDown() Version 7.0
   * ============================================================================

METHOD LButtonDown( nRow, nCol ) CLASS TBtnBox

   HB_SYMBOL_UNUSED( nRow )
   HB_SYMBOL_UNUSED( nCol )

   IF ::nLastKey != Nil .and. ::nLastKey == 9999
      ::nLastKey := 0
   ELSE
      ::nLastKey := 9999
   ENDIF

   RETURN 0

   * ============================================================================
   * METHOD TBtnBox:VarGet() Version 7.0
   * ============================================================================

METHOD GetVal() CLASS TBtnBox

   LOCAL retVal, cType

   cType := ValType( ::VarGet() )

   DO CASE
   CASE cType == 'C'
      retVal := GetWindowText( ::hWnd )
   CASE cType == 'N'
      retval := Int ( Val( GetWindowText(  ::hWnd ) ) )
   ENDCASE

   RETURN retVal

   * ============================================================================
   * METHOD TBtnBox:Command() Version 7.0
   * ============================================================================

METHOD Command( nWParam, nLParam ) CLASS TBtnBox

   LOCAL nNotifyCode, nID, hWndCtl

   nNotifyCode := HiWord( nWParam )
   nID         := LoWord( nWParam )
   hWndCtl     := nLParam

   DO CASE
   CASE hWndCtl == 0

      * Enter ........................................
      IF HiWord(nWParam) == 0 .And. LoWord(nWParam) == 1
         ::KeyDown( VK_RETURN, 0 )
      ENDIF

      * Escape .......................................
      IF HiWord(nwParam) == 0 .And. LoWord(nwParam) == 2
         ::KeyDown( VK_ESCAPE, 0 )
      ENDIF

   CASE hWndCtl != 0

      DO CASE
      CASE nNotifyCode == 512 .And. nID == 0 .And. ::bAction != Nil
         ::oWnd:lPostEdit := .T.
         Eval( ::bAction, Self, Eval( ::bSetGet ) )
         ::bLostFocus := { | nKey | ::oWnd:EditExit( ::nCell, nKey, ::VarGet(), ;
            ::bValid, .F. ) }
         ::nLastKey := VK_RETURN
         ::LostFocus()
         ::oWnd:lPostEdit := .F.
      CASE nNotifyCode == EN_CHANGE
         ::lChanged :=.T.
      CASE nNotifyCode == EN_KILLFOCUS
         ::LostFocus()
      CASE nNotifyCode == EN_UPDATE
         IF _GetKeyState( VK_ESCAPE )
            ::KeyDown( VK_ESCAPE, 0 )
         ENDIF
         IF _GetKeyState( VK_CONTROL )
            IF GetKeyState( VK_RETURN ) == -127 .Or. _GetKeyState( VK_RETURN )
               ::KeyDown( VK_RETURN, 0 )
            ENDIF
         ENDIF
      ENDCASE

   ENDCASE

   RETURN NIL
