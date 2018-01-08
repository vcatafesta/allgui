#include "minigui.ch"
#include "hbclass.ch"
#include "TSBrowse.ch"

#define GWL_WNDPROC        (-4)

#define LTGRAY_BRUSH       1
#define GRAY_BRUSH         2

#define GW_HWNDNEXT        2
#define GW_CHILD           5
#define CW_USEDEFAULT      32768

#define SC_NEXT        61504
#define SC_KEYMENU     61696   // 0xF100

#define DM_GETDEFID  WM_USER

#define CBN_SELCHANGE      1
#define CBN_CLOSEUP        8
#define CBN_KILLFOCUS      4
#define NM_KILLFOCUS       (-8)

MEMVAR _TSB_aControlhWnd, _TSB_aControlObjects, _TSB_aClientMDIhWnd

STATIC nId := 100

CLASS TControl

   DATA   bSetGet, bChange
   DATA   cCaption
   DATA   nLastRow, nLastCol
   DATA   nAlign AS NUMERIC  // New 1.9 Alignment
   DATA   nStatusItem INIT 1

   DATA   bLClicked                                  // TControl
   DATA   bLDblClick                                 // TControl
   DATA   bRClicked                                  // TControl
   DATA   bWhen                                      // TWindow
   DATA   cMsg                                       // TWindows

   DATA   bMoved, bLButtonUp, bKeyDown, bPainted
   DATA   bMButtonDown, bMButtonUp, bRButtonUp
   DATA   bResized, bValid, bKeyChar, bMMoved
   DATA   bGotFocus, bLostFocus, bDropFiles, bDdeInit, bDdeExecute

   DATA   lFocused      AS LOGICAL                   // TWindow
   DATA   lValidating   AS LOGICAL                   // TWindow
   DATA   lCaptured     AS LOGICAL                   // TControl
   DATA   lUpdate       AS LOGICAL                   // TControl
   DATA   lDesign       AS LOGICAL                   // TControl
   DATA   lVisible      AS LOGICAL                   // TControl
   DATA   lMouseDown    AS LOGICAL                   // TControl
   DATA   lKeepDefaultStatus AS LOGICAL INIT .F.     // TControl

   DATA   nTop                                       // TWindow
   DATA   nLeft                                      // TWindow
   DATA   nBottom                                    // TWindow
   DATA   nRight                                     // TWindow
   DATA   nStyle                                     // TWindow
   DATA   nId                                        // TWindow
   DATA   nClrText                                   // TWindow
   DATA   nClrPane                                   // TWindow
   DATA   nPaintCount                                // TWindow
   DATA   nLastKey                                   // TWindow
   DATA   nHelpId                                    // TWindow
   DATA   nChrHeight                                 // TWindow

   DATA   oWnd          AS OBJECT                    // TWindow
   DATA   oCursor                                    // TWindow
   DATA   hCursor                                    // JP
   DATA   oFont                                      // TWindow
   DATA   hFont                                      // New
   DATA   hBrush                                     // New
   DATA   hWnd , hCtlFocus /*, nOldProc*/            // TWindow
   DATA   cControlName                               // new
   DATA   cParentWnd                                 // new
   DATA   hDc                                        // TWindow
   DATA   cPS                                        // TWindow
   DATA   oVScroll                                   // TWindow
   DATA   oHScroll                                   // TWindow

   DATA   hWndParent                                 // New
   DATA   aControls  INIT {}                         // New
   DATA   oWndlAppendMode INIT .f.                   // New

   CLASSDATA aProperties INIT { "cTitle", "cVarName", "nClrText", ;
      "nClrPane", "nAlign", "nTop", "nLeft", ;
      "nWidth", "nHeight", "Cargo" }

   METHOD AddControl( hControl ) INLINE ;
      If( ::aControls == nil, ::aControls := {},), ;
      AAdd( ::aControls, hControl ), ::lValidating := .f.

   METHOD AddVars(hControl)

   METHOD Change() VIRTUAL

   METHOD Click() INLINE ::oWnd:AEvalWhen()

   METHOD Init( hDlg )

   METHOD Colors( hDC )

   METHOD CoorsUpdate()                //TWindow

   METHOD Create( cClsName )           //TWindow

   METHOD Default()

   METHOD DelVars(hControl)

   METHOD Display()              VIRTUAL

   METHOD DrawItem( nPStruct )   VIRTUAL

   METHOD End()

   METHOD EraseBkGnd( hDC )

   METHOD FillMeasure()          VIRTUAL

   METHOD ForWhen()

   METHOD GetDlgCode( nLastKey )

   METHOD GetCliRect()                 //TWindow

   METHOD GetRect()

   METHOD GetNewId() INLINE ++nId

   METHOD GotFocus( hCtlLost )

   METHOD GoNextCtrl( hCtrl )

   METHOD GoPrevCtrl( hCtrl )

   METHOD LostFocus(hWndGetFocus)

   METHOD nWidth() INLINE GetWindowWidth( ::hWnd )

   METHOD nHeight() INLINE GetWindowHeight( ::hWnd )

   METHOD HandleEvent( nMsg, nWParam, nLParam )

   METHOD KeyChar( nKey, nFlags )

   METHOD KeyDown( nKey, nFlags )

   METHOD KeyUp( nKey, nFlags ) VIRTUAL

   METHOD KillFocus( hCtlFocus )

   METHOD VarPut( uVal ) INLINE  If( ValType( ::bSetGet ) == "B", ;
      Eval( ::bSetGet, uVal ), )

   METHOD VarGet() INLINE If( ValType( ::bSetGet ) == "B", Eval( ::bSetGet ), )

   METHOD LButtonDown( nRow, nCol, nKeyFlags )

   METHOD LButtonUp( nRow, nCol, nKeyFlags )

   METHOD MouseMove( nRow, nCol, nKeyFlags )

   METHOD Paint() VIRTUAL

   METHOD SuperKeyDown( nKey, nFlags )

   //   METHOD nWidth( nNewWidth ) INLINE GetWindowWidth( ::hWnd, nNewWidth )

   MESSAGE BeginPaint METHOD _BeginPaint()

   METHOD EndPaint() INLINE ::nPaintCount--, ;
      EndPaint( ::hWnd, ::cPS ), ::cPS := nil, ::hDC := nil

METHOD Register( nClsStyle )            //TWindow

   MESSAGE SetFocus METHOD __SetFocus()   //TWindow

METHOD RButtonUp( nRow, nCol, nKeyFlags )    //TWindow

METHOD Capture() INLINE  SetCapture( ::hWnd ) //TWindow

METHOD GetDC() INLINE ;
      If( ::hDC == nil, ::hDC := GetDC( ::hWnd ),), ;
      If( ::nPaintCount == nil, ::nPaintCount := 1, ::nPaintCount++ ), ::hDC

METHOD ReleaseDC() INLINE  ::nPaintCount--, If( ::nPaintCount == 0, ;
      If( ReleaseDC( ::hWnd, ::hDC ), ::hDC := nil,), )

METHOD PostMsg( nMsg, nWParam, nLParam ) INLINE ;
      PostMessage( ::hWnd, nMsg, nWParam, nLParam )

METHOD lValid() INLINE If( ::bValid != nil, Eval( ::bValid ), .t. )

METHOD SetMsg( cText, lDefault )

METHOD lWhen() INLINE  If( ::bWhen != nil, Eval( ::bWhen ), .t. )

METHOD SetColor( nClrFore, nClrBack, hBrush )

METHOD EndCtrl() BLOCK ;   // It has to be Block
      { | Self, lEnd | If( lEnd := ::lValid(), ::PostMsg( WM_CLOSE ),), lEnd }

METHOD Hide() INLINE ShowWindow( ::hWnd, SW_HIDE )

METHOD Show() INLINE  ShowWindow( ::hWnd, SW_SHOWNA )

METHOD SendMsg( nMsg, nWParam, nLParam ) INLINE SendMessage( ::hWnd, nMsg, nWParam, nLParam )

METHOD Move( nTop, nLeft, nWidth, nHeight, lRepaint )

METHOD ReSize( nSizeType, nWidth, nHeight )

METHOD Command( nWParam, nLParam )

METHOD Notify( nWParam, nLParam )

METHOD Refresh( lErase ) INLINE InvalidateRect( ::hWnd, ;
      If( lErase == NIL .OR. !lErase, 0, 1 ) )

METHOD nGetChrHeight() INLINE ::hDC := GetDC( ::hWnd ), ;
      ::nChrHeight := _GetTextHeight( ::hWnd, ::hDC ) //Temp

METHOD GetText() INLINE GetWindowText( ::hWnd )   //TWindow

METHOD VScroll( nWParam, nLParam )                //TWindow

   ENDCLASS

METHOD Init( hDlg ) CLASS TControl

   LOCAL oRect

   DEFAULT ::lActive := .t., ::lCaptured := .f.

   if( ( ::hWnd := GetDialogItemHandle( hDlg, ::nId ) ) != 0 )    //JP
   oRect     := ::GetRect()

   ::nTop    := iif (::nTop    == nil, oRect:nTop,   ::nTop    )
   ::nLeft   := iif (::nLeft   == nil, oRect:nLeft,  ::nLeft   )
   ::nBottom := iif (::nBottom == nil, oRect:nBottom,::nBottom )
   ::nRight  := iif (::nRight  == nil, oRect:nRight, ::nRight  )

   ::Move (::nTop,::nLeft,::nRight - ::nLeft, ::nBottom - ::nTop)

   If( ::lActive, ::Enable(), ::Disable() )

   ::Link()

   IF ::oFont != nil
      ::SetFont( ::oFont )
   ELSE
      ::GetFont()
   ENDIF

ELSE
   MsgInfo("No Valid Control ID","Error")
ENDIF

RETURN NIL

METHOD AddVars( hControl ) CLASS TControl

   AADD( _TSB_aControlhWnd,    hControl )
   AADD( _TSB_aControlObjects, Self )
   AADD( _TSB_aClientMDIhWnd, IF( _HMG_BeginWindowMDIActive ,GetActiveMdiHandle(),0) )

   RETURN NIL

METHOD DelVars( hControl ) CLASS TControl

   LOCAL nAt := If( ! Empty( _TSB_aControlhWnd ), ;
      AScan( _TSB_aControlhWnd, { | hCtrl | hCtrl == Self:hWnd } ), 0 )

   HB_SYMBOL_UNUSED( hControl )

   IF nAt != 0
      ADel(   _TSB_aControlhWnd, nAt )
      ASize(  _TSB_aControlhWnd, Len(  _TSB_aControlhWnd ) - 1 )
      ADel(   _TSB_aControlObjects, nAt )
      ASize(  _TSB_aControlObjects, Len(   _TSB_aControlObjects ) - 1 )
      ADel(   _TSB_aClientMDIhWnd, nAt )
      ASize(  _TSB_aClientMDIhWnd, Len(   _TSB_aClientMDIhWnd ) - 1 )
   ENDIF

   RETURN NIL

METHOD _BeginPaint() CLASS TControl

   LOCAL cPS

   IF ::nPaintCount == nil
      ::nPaintCount := 1
   ELSE
      ::nPaintCount++
   ENDIF

   ::hDC = BeginPaint( ::hWnd, @cPS )
   ::cPS = cPS

   RETURN NIL

METHOD Colors( hDC ) CLASS TControl

   DEFAULT ::nClrText := GetTextColor( hDC ), ;
      ::nClrPane := GetBkColor( hDC ), ;
      ::hBrush   := CreateSolidBrush( GetRed( ::nClrPane ), GetGreen( ::nClrPane ), GetBlue( ::nClrPane ) )

   SetTextColor( hDC, ::nClrText )
   SetBkColor( hDC, ::nClrPane )

   RETURN ::hBrush

METHOD CoorsUpdate() CLASS TControl

   LOCAL aRect := {0,0,0,0}

   GetWindowRect( ::hWnd, aRect )
   /*
   ::nTop    = aRect[ 2 ]
   ::nLeft   = aRect[ 1 ]
   ::nBottom = aRect[ 4 ]
   ::nRight  = aRect[ 3 ]
   */

   RETURN NIL

METHOD Create( cClsName )  CLASS TControl

   LOCAL xStyle := 0

   DEFAULT cClsName := ::ClassName(), ::cCaption := "", ;
      ::nStyle := WS_OVERLAPPEDWINDOW, ;
      ::nTop   := 0, ::nLeft := 0, ::nBottom := 10, ::nRight := 10, ;
      ::nId    := 0

   IF ::hWnd != nil
      ::nStyle := nOr( ::nStyle, WS_CHILD )
   ENDIF

   IF ::hBrush == nil
      ::hBrush := CreateSolidBrush( GetRed( ::nClrPane ), GetGreen( ::nClrPane ), GetBlue( ::nClrPane ) )
   ENDIF

   IF GetClassInfo( GetInstance(), cClsName ) == nil
      IF _HMG_MainClientMDIHandle != 0
         ::lRegistered := Register_Class( cClsName, ::hBrush , _HMG_MainClientMDIHandle )
      ELSE
         ::lRegistered := Register_Class( cClsName, ::hBrush )
      ENDIF
   ELSE
      ::lRegistered := .t.
   ENDIF

   IF ::nBottom != CW_USEDEFAULT

      ::hWnd := _CreateWindowEx( xStyle, cClsName, ::cCaption, ::nStyle, ::nLeft, ::nTop, ;
         ::nRight - ::nLeft + 1, ::nBottom - ::nTop + 1, ;
         ::hWndParent, 0, GetInstance() , ::nId )

   ELSE

      ::hWnd := _CreateWindowEx( xStyle, cClsName, ::cCaption, ::nStyle, ::nLeft, ::nTop, ;
         ::nRight , ::nBottom , ;
         ::hWndParent, 0, GetInstance() , ::nId )
   ENDIF

   IF ::hWnd == 0
      MsgAlert( 'Window Create Error!', 'Alert' )
   ELSE
      ::AddVars( ::hWnd )
   ENDIF

   RETURN NIL

METHOD Default() CLASS TControl

   ::lCaptured := .f.

   RETURN NIL

METHOD End() CLASS TControl

   LOCAL ix
   LOCAL nAt := If( ! Empty( ::oWnd:aControls ), ;
      AScan( ::oWnd:aControls, { | hCtrl | hCtrl == Self:hWnd } ), 0 )

   IF nAt != 0
      ADel( ::oWnd:aControls, nAt )
      ASize( ::oWnd:aControls, Len( ::oWnd:aControls ) - 1 )
   ENDIF

   ::DelVars( Self:hWnd )

   IF "TGETBOX" $ Upper( Self:ClassName() )
      ix := GetControlIndex ( ::cControlName, ::oWnd:cParentWnd )
      IF ix > 0
         ReleaseControl ( _HMG_aControlHandles [ix] )
         _HMG_aControlDeleted [ix] := .T.
      ENDIF
   ENDIF
   IF "TBTNBOX" $ Upper( Self:ClassName() )
      IF ::hWndChild != nil
         PostMessage( ::hWndChild, WM_CLOSE )
      ENDIF
      ::PostMsg( WM_CLOSE )

      RETURN .T.
   ENDIF

   RETURN ::EndCtrl()

METHOD EraseBkGnd( hDC ) CLASS TControl

   LOCAL aRect

   IF IsIconic( ::hWnd )
      IF ::hWnd != nil
         aRect := ::GetCliRect( ::hWnd )
         FillRect(hDC, aRect[1], aRect[2], aRect[3], aRect[4], ::hBrush )

         RETURN 1
      ENDIF

      RETURN 0
   ENDIF

   IF ::hBrush != nil .and. ! Empty( ::hBrush )   //JP
      aRect := ::GetCliRect( ::hWnd )
      FillRect( hDC, aRect[1], aRect[2], aRect[3], aRect[4], ::hBrush )

      RETURN 1
   ENDIF

   RETURN 0   //nil JP

METHOD ForWhen() CLASS TControl

   ::oWnd:AEvalWhen()

   ::lCaptured := .f.

   // keyboard navigation
   IF ::oWnd:nLastKey == VK_UP .or. ::oWnd:nLastKey == VK_DOWN ;
         .or. ::oWnd:nLastKey == VK_RETURN .or. ::oWnd:nLastKey == VK_TAB
      IF _GetKeyState( VK_SHIFT )
         ::GoPrevCtrl( ::hWnd )
      ELSE
         ::GoNextCtrl( ::hWnd )
      ENDIF
   ELSE
      IF Empty( GetFocus() )
         SetFocus( ::hWnd )
      ENDIF
   ENDIF

   ::oWnd:nLastKey := 0

   RETURN NIL

METHOD GetCliRect() CLASS TControl

   LOCAL aRect := _GetClientRect( ::hWnd )

   RETURN aRect

METHOD GetDlgCode( nLastKey ) CLASS TControl

   IF .not. ::oWnd:lValidating
      IF nLastKey == VK_RETURN .or. nLastKey == VK_TAB
         ::oWnd:nLastKey := nLastKey

         // don't do a else here with :nLastKey = 0
         // or WHEN does not work properly, as we pass here twice before
         // evaluating the WHEN
      ENDIF
   ENDIF

   RETURN DLGC_WANTALLKEYS // It is the only way to have 100% control using Folders

METHOD GetRect() CLASS TControl

   LOCAL aRect := {0,0,0,0}

   GetWindowRect( ::hWnd ,aRect )

   RETURN aRect

METHOD GotFocus( hCtlLost )

   HB_SYMBOL_UNUSED( hCtlLost )
   ::lFocused := .t.
   ::SetMsg( ::cMsg )

   IF ::bGotFocus != nil

      RETURN Eval( ::bGotFocus )
   ENDIF

   RETURN NIL

METHOD GoNextCtrl( hCtrl ) CLASS TControl

   LOCAL hCtlNext

   hCtlNext := GetNextDlgTabITem ( GetActiveWindow() , GetFocus() , .f. )

   ::hCtlFocus = hCtlNext
   IF hCtlNext != hCtrl
      SetFocus( hCtlNext )
   ENDIF

   RETURN NIL

METHOD GoPrevCtrl( hCtrl ) CLASS TControl

   LOCAL hCtlPrev

   hCtlPrev := GetNextDlgTabITem ( GetActiveWindow() , GetFocus() , .t. )

   ::hCtlFocus = hCtlPrev
   IF hCtlPrev != hCtrl
      SetFocus( hCtlPrev )
   ENDIF

   RETURN NIL

METHOD KeyChar( nKey, nFlags ) CLASS TControl

   LOCAL bKeyAction := SetKey( nKey )

   DO CASE
   CASE nKey == VK_TAB .and. _GetKeyState( VK_SHIFT )
      ::GoPrevCtrl( ::hWnd )

      RETURN 0    // We don't want API default behavior

   CASE nKey == VK_TAB
      ::GoNextCtrl( ::hWnd )

      RETURN 0    // We don't want API default behavior
   ENDCASE

   IF bKeyAction != nil     // Clipper SET KEYs !!!

      RETURN Eval( bKeyAction, ProcName( 4 ), ProcLine( 4 ) )
   ENDIF

   IF ::bKeyChar != nil

      RETURN Eval( ::bKeyChar, nKey, nFlags )
   ENDIF

   RETURN 0

METHOD KeyDown( nKey, nFlags ) CLASS TControl

   LOCAL bKeyAction := SetKey( nKey )

   IF nKey == VK_TAB .and. ::hWnd != nil
      ::GoNextCtrl( ::hWnd )

      RETURN 0
   ENDIF

   IF bKeyAction != nil     // Clipper SET KEYs !!!
      Eval( bKeyAction, ProcName( 4 ), ProcLine( 4 ) )

      RETURN 0
   ENDIF

   IF nKey == VK_F1
      //JP      ::HelpTopic()

      RETURN 0
   ENDIF

   IF ::bKeyDown != nil

      RETURN Eval( ::bKeyDown, nKey, nFlags )
   ENDIF

   RETURN 0

METHOD KillFocus( hCtlFocus ) CLASS TControl

   HB_SYMBOL_UNUSED( hCtlFocus )

   RETURN ::LostFocus()

METHOD LButtonDown( nRow, nCol, nKeyFlags ) CLASS TControl

   ::lMouseDown := .t.
   ::nLastRow   := nRow
   ::nLastCol   := nCol

   IF ::bLClicked != nil

      RETURN Eval( ::bLClicked, nRow, nCol, nKeyFlags )
   ENDIF

   RETURN NIL

METHOD LButtonUp( nRow, nCol, nKeyFlags ) CLASS TControl

   IF ::bLButtonUp != nil

      RETURN Eval( ::bLButtonUp, nRow, nCol, nKeyFlags )
   ENDIF

   RETURN NIL

METHOD LostFocus( hWndGetFocus ) CLASS TControl

   ::lFocused := .f.
   ::SetMsg()
   IF ! Empty( ::bLostFocus )

      RETURN Eval( ::bLostFocus, hWndGetFocus )
   ENDIF

   RETURN NIL

METHOD MouseMove( nRow, nCol, nKeyFlags ) CLASS TControl

   IF ::oCursor != nil
      SetResCursor( ::oCursor:hCursor )
   ELSE
      CursorArrow()
   ENDIF

   IF ::lFocused
      ::SetMsg( ::cMsg, ::lKeepDefaultStatus )
   ENDIF

   IF ::bMMoved != nil

      RETURN Eval( ::bMMoved, nRow, nCol, nKeyFlags )
   ENDIF

   RETURN 0

METHOD Move( nTop, nLeft, nWidth, nHeight, lRepaint ) CLASS TControl

   MoveWindow( ::hWnd, nTop, nLeft, nWidth, nHeight, lRepaint )

   ::CoorsUpdate()

   RETURN NIL

METHOD RButtonUp( nRow, nCol, nKeyFlags ) CLASS TControl

   IF ::bRButtonUp != nil
      Eval( ::bRButtonUp, nRow, nCol, nKeyFlags )
   ENDIF

   RETURN NIL

METHOD Register( nClsStyle )  CLASS TControl

   LOCAL hUser, ClassName

   DEFAULT ::lRegistered := .f.

   IF ::lRegistered

      RETURN NIL
   ENDIF

   hUser := GetInstance()

   ClassName := ::cControlName

   DEFAULT nClsStyle  := nOr( CS_VREDRAW, CS_HREDRAW ), ;
      ::nClrPane := GetSysColor( COLOR_WINDOW ), ;
      ::hBrush   := CreateSolidBrush( GetRed( ::nClrPane ), GetGreen( ::nClrPane ), GetBlue( ::nClrPane ) )

   nClsStyle := nOr( nClsStyle, CS_GLOBALCLASS, CS_DBLCLKS )

   IF GetClassInfo( hUser, ClassName ) == nil
      ::lRegistered := Register_Class( ClassName, nClsStyle, "", , hUser, 0, ::hBrush )
   ELSE
      ::lRegistered := .t.
   ENDIF

   RETURN ::hBrush

METHOD ReSize( nSizeType, nWidth, nHeight ) CLASS TControl

   ::CoorsUpdate()
   IF ::bResized != nil
      Eval( ::bResized, nSizeType, nWidth, nHeight )
   ENDIF

   RETURN NIL

METHOD SetMsg( cText, lDefault ) CLASS TControl

   LOCAL cOldText, cParentWnd

   IF ::nStatusItem < 1

      RETURN NIL
   ENDIF

   DEFAULT lDefault := .F. , cText := ""

   cParentWnd := iif( _HMG_MainClientMDIHandle == 0, ::cParentWnd, _HMG_MainClientMDIName )

   IF _IsWindowActive ( cParentWnd )
      IF _IsControlDefined ( "StatusBar" , cParentWnd )
         IF !lDefault
            cOldText := GetItemBar( _HMG_ActiveStatusHandle , ::nStatusItem )
            IF !(AllTrim(cOldText) == AllTrim(cText))
               SetProperty( cParentWnd, "StatusBar", "Item", ::nStatusItem, cText )
            ENDIF
         ELSEIF valtype ( _HMG_DefaultStatusBarMessage ) == "C"
            SetProperty( cParentWnd, "StatusBar", "Item", ::nStatusItem, _HMG_DefaultStatusBarMessage )
         ENDIF
      ENDIF
   ENDIF

   RETURN NIL

METHOD SetColor( nClrFore, nClrBack, hBrush ) CLASS TControl

   ::nClrText = nClrFore
   ::nClrPane = nClrBack

   IF ::hBrush != nil
      DeleteObject( ::hBrush )  // Alen Uzelac 13.09.2012
   ENDIF

   IF hBrush != nil
      ::hBrush := hBrush
   ELSE
      ::hBrush := CreateSolidBrush( GetRed( nClrBack ), GetGreen( nClrBack ), GetBlue( nClrBack ) )
   ENDIF

   RETURN NIL

   //==========From TWindow ===============================

METHOD SuperKeyDown( nKey, nFlags ) CLASS TControl

   LOCAL bKeyAction := SetKey( nKey )

   IF bKeyAction != nil     // Clipper SET KEYs !!!
      Eval( bKeyAction, ProcName( 4 ), ProcLine( 4 ) )

      RETURN 0
   ENDIF

   IF nKey == VK_F1
      //      ::HelpTopic()

      RETURN 0
   ENDIF

   IF ::bKeyDown != nil

      RETURN Eval( ::bKeyDown, nKey, nFlags )
   ENDIF

   RETURN NIL

METHOD __SetFocus() CLASS TControl

   IF ::lWhen()
      SetFocus( ::hWnd )
      ::oWnd:hCtlFocus := ::hWnd
   ENDIF

   RETURN NIL

METHOD VScroll( nWParam, nLParam ) CLASS TControl

   LOCAL nScrHandle := HiWord( nLParam )

   IF nScrHandle == 0                   // Window ScrollBar
      IF ::oVScroll != nil
         DO CASE
         CASE nWParam == SB_LINEUP
            ::oVScroll:GoUp()

         CASE nWParam == SB_LINEDOWN
            ::oVScroll:GoDown()

         CASE nWParam == SB_PAGEUP
            ::oVScroll:PageUp()

         CASE nWParam == SB_PAGEDOWN
            ::oVScroll:PageDown()

         CASE nWParam == SB_THUMBPOSITION
            ::oVScroll:ThumbPos( LoWord( nLParam ) )

         CASE nWParam == SB_THUMBTRACK
            ::oVScroll:ThumbTrack( LoWord( nLParam ) )

         CASE nWParam == SB_ENDSCROLL

            RETURN 0
         ENDCASE
      ENDIF
   ELSE                                 // Control ScrollBar
      DO CASE
      CASE nWParam == SB_LINEUP
         SendMessage( nScrHandle, FM_SCROLLUP )

      CASE nWParam == SB_LINEDOWN
         SendMessage( nScrHandle, FM_SCROLLDOWN )

      CASE nWParam == SB_PAGEUP
         SendMessage( nScrHandle, FM_SCROLLPGUP )

      CASE nWParam == SB_PAGEDOWN
         SendMessage( nScrHandle, FM_SCROLLPGDN )

      CASE nWParam == SB_THUMBPOSITION
         SendMessage( nScrHandle, FM_THUMBPOS, LoWord( nLParam ) )

      CASE nWParam == SB_THUMBTRACK
         SendMessage( nScrHandle, FM_THUMBTRACK, LoWord( nLParam ) )
      ENDCASE
   ENDIF

   RETURN 0

METHOD HandleEvent( nMsg, nWParam, nLParam ) CLASS TControl

   DO CASE

   CASE nMsg == WM_CLOSE

      RETURN 0

   CASE nMsg == WM_COMMAND

      RETURN ::Command( nWParam, nLParam )

   CASE nMsg == WM_NOTIFY

      RETURN ::Notify( nWParam, nLParam )

   CASE nMsg == WM_PAINT
      ::BeginPaint()
      ::Paint()
      ::EndPaint()
      SysRefresh()
   CASE nMsg == WM_DESTROY

      RETURN ::Destroy()

   CASE nMsg == WM_DRAWITEM

      RETURN ::DrawItem( nWParam, nLParam )

   CASE nMsg == WM_ERASEBKGND

      RETURN ::EraseBkGnd( nWParam )

   CASE nMsg == WM_HSCROLL

      RETURN ::HScroll( nWParam, nLParam )

   CASE nMsg == WM_KEYDOWN

      RETURN ::KeyDown( nWParam, nLParam )

   CASE nMsg == WM_CHAR

      RETURN ::KeyChar( nWParam, nLParam )

   CASE nMsg == WM_GETDLGCODE

      RETURN ::GetDlgCode( nWParam )

   CASE nMsg == WM_KILLFOCUS

      RETURN ::LostFocus( nWParam ) // LostFocus(), not KillFocus()!!!

   CASE nMsg == WM_LBUTTONDOWN

      RETURN ::LButtonDown( HiWord( nLParam ), LoWord( nLParam ), ;
         nWParam )
   CASE nMsg == WM_LBUTTONUP

      RETURN ::LButtonUp( HiWord( nLParam ), LoWord( nLParam ), ;
         nWParam )
   CASE nMsg == WM_MOUSEMOVE

      RETURN ::MouseMove( HiWord( nLParam ), LoWord( nLParam ), ;
         nWParam )

   CASE nMsg == WM_RBUTTONDOWN

      RETURN ::RButtonDown( HiWord( nLParam ), LoWord( nLParam ), ;
         nWParam )
   CASE nMsg == WM_RBUTTONUP

      RETURN ::RButtonUp( HiWord( nLParam ), LoWord( nLParam ), ;
         nWParam )
   CASE nMsg == WM_SETFOCUS

      RETURN ::GotFocus( nWParam )

   CASE nMsg == WM_VSCROLL

      RETURN ::VScroll( nWParam, nLParam )

   CASE nMsg == WM_SIZE

      RETURN ::ReSize( nWParam, LoWord( nLParam ), HiWord( nLParam ) )

   CASE nMsg == WM_TIMER

      RETURN ::Timer( nWParam, nLParam )

   CASE nMsg == WM_ASYNCSELECT

      RETURN ::AsyncSelect( nWParam, nLParam )

   ENDCASE

   RETURN 0

METHOD Command( nWParam, nLParam ) CLASS TControl

   LOCAL nNotifyCode, hWndCtl

   nNotifyCode := HiWord( nWParam )
   //   nID         = LoWord( nWParam )
   hWndCtl     := nLParam

   DO CASE
   CASE hWndCtl == 0

      * TGet Enter ......................................
      IF HiWord(nWParam) == 0 .and. LoWord(nWParam) == 1
         ::KeyDown( VK_RETURN, 0 )
      ENDIF
      * TGet Escape .....................................
      IF HiWord(nwParam) == 0 .and. LoWord(nwParam) == 2
         ::KeyDown( VK_ESCAPE, 0 )
      ENDIF

   CASE hWndCtl != 0

      DO CASE
      CASE nNotifyCode == CBN_KILLFOCUS
         ::LostFocus()
      CASE nNotifyCode == NM_KILLFOCUS
         ::LostFocus()
      CASE nNotifyCode == EN_KILLFOCUS
         ::LostFocus()
         //       case nNotifyCode == EN_UPDATE
         //         ::KeyDown( VK_RETURN, 0 )
      ENDCASE

   ENDCASE

   RETURN NIL

METHOD Notify( nWParam, nLParam ) CLASS TControl

   HB_SYMBOL_UNUSED( nWParam )

   //   nNotifyCode := GetNotifyCode (nLParam )
   //   hWndCtl     := GetHwndFrom ( nLParam)

   IF GetNotifyCode( nLParam ) == NM_KILLFOCUS
      ::LostFocus()
   ENDIF

   RETURN NIL
