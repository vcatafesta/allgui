/*
*$Id: hwindow.prg 1615 2011-02-18 13:53:35Z mlacecilia $
* HWGUI - Harbour Win32 GUI library source code:
* Window class
* Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
* www - http://www.geocities.com/alkresin/
*/

#include "windows.ch"
#include "HBClass.ch"
#include "guilib.ch"

#define  FIRST_MDICHILD_ID     501
#define  MAX_MDICHILD_WINDOWS   18
#define  WM_NOTIFYICON         WM_USER+1000
#define  ID_NOTIFYICON           1

#define WM_MENUSELECT   287
#define MF_HILITE       128

CLASS HObject

   // DATA classname

   ENDCLASS

CLASS HCustomWindow INHERIT HObject

CLASS VAR oDefaultParent SHARED

   DATA handle  INIT 0
   DATA oParent
   DATA title
   DATA type
   DATA nTop, nLeft, nWidth, nHeight
   DATA tcolor, bcolor, brush
   DATA style
   DATA extStyle  INIT 0
   DATA lHide INIT .F.
   DATA oFont
   DATA aEvents   INIT {}
   DATA aNotify   INIT {}
   DATA aControls INIT {}
   DATA bInit
   DATA bDestroy
   DATA bSize
   DATA bPaint
   DATA bGetFocus
   DATA bLostFocus
   DATA bOther
   DATA cargo

   METHOD AddControl( oCtrl ) INLINE Aadd( ::aControls,oCtrl )

   METHOD DelControl( oCtrl )

   METHOD AddEvent( nEvent,nId,bAction,lNotify ) ;
      INLINE Aadd( Iif( lNotify==Nil.OR.!lNotify,::aEvents,::aNotify ),{nEvent,nId,bAction} )

   METHOD FindControl( nId,nHandle )

   METHOD Hide() INLINE (::lHide:=.T.,HideWindow(::handle))

   METHOD Show() INLINE (::lHide:=.F.,ShowWindow(::handle))

   METHOD Restore()  INLINE SendMessage(::handle,  WM_SYSCOMMAND, SC_RESTORE, 0)

   METHOD Maximize() INLINE SendMessage(::handle,  WM_SYSCOMMAND, SC_MAXIMIZE, 0)

   METHOD Minimize() INLINE SendMessage(::handle,  WM_SYSCOMMAND, SC_MINIMIZE, 0)

   ENDCLASS

METHOD FindControl( nId,nHandle ) CLASS HCustomWindow

   LOCAL i := Iif( nId!=Nil,Ascan( ::aControls,{|o|o:id==nId} ), ;
      Ascan( ::aControls,{|o|o:handle==nHandle} ) )

   RETURN Iif( i==0,Nil,::aControls[i] )

METHOD DelControl( oCtrl ) CLASS HCustomWindow

   LOCAL h := oCtrl:handle
   LOCAL i := Ascan( ::aControls,{|o|o:handle==h} )

   SendMessage( h,WM_CLOSE,0,0 )
   IF i != 0
      Adel( ::aControls,i )
      Asize( ::aControls,Len(::aControls)-1 )
   ENDIF

   RETURN NIL

CLASS HWindow INHERIT HCustomWindow

CLASS VAR aWindows   INIT {}

CLASS VAR szAppName  SHARED INIT "HwGUI_App"

   DATA menu, nMenuPos, oPopup, hAccel
   DATA oIcon, oBmp
   DATA oNotifyIcon, bNotify, oNotifyMenu
   DATA lClipper
   DATA lTray INIT .F.
   DATA aOffset
   DATA lMaximize INIT .F.

   METHOD New( lType,oIcon,clr,nStyle,x,y,width,height,cTitle,cMenu,nPos,oFont, ;
      bInit,bExit,bSize,bPaint,bGfocus,bLfocus,bOther,cAppName,oBmp, lMaximize )

   METHOD Activate( lShow )

   METHOD InitTray( oNotifyIcon, bNotify, oNotifyMenu )

   METHOD AddItem( oWnd )

   METHOD DelItem( oWnd )

   METHOD FindWindow( hWnd )

   METHOD GetMain()

   METHOD GetMdiActive()

   METHOD Close()   INLINE EndWindow()

   ENDCLASS

METHOD NEW( lType,oIcon,clr,nStyle,x,y,width,height,cTitle,cMenu,nPos,oFont, ;
      bInit,bExit,bSize, ;
      bPaint,bGfocus,bLfocus,bOther,cAppName,oBmp, lMaximize) CLASS HWindow
   LOCAL hParent
   LOCAL oWndClient

   // ::classname:= "HWINDOW"
   ::oDefaultParent := Self
   ::type     := lType
   ::title    := cTitle
   ::style    := Iif( nStyle==NIL,0,nStyle )
   ::nMenuPos := nPos
   ::oIcon    := oIcon
   ::oBmp     := oBmp
   ::nTop     := Iif( y==Nil,0,y )
   ::nLeft    := Iif( x==Nil,0,x )
   ::nWidth   := Iif( width==Nil,0,width )
   ::nHeight  := Iif( height==Nil,0,height )
   ::oFont    := oFont
   ::bInit    := bInit
   ::bDestroy := bExit
   ::bSize    := bSize
   ::bPaint   := bPaint
   ::bGetFocus  := bGFocus
   ::bLostFocus := bLFocus
   ::bOther     := bOther
   ::lMaximize  := lMaximize
   IF cAppName != Nil
      ::szAppName := cAppName
   ENDIF
   // ::lClipper   := Iif( lClipper==Nil,.F.,lClipper )
   ::aOffset := Array( 4 )
   Afill( ::aOffset,0 )

   ::AddItem( Self )
   IF lType == WND_MAIN

      ::handle := Hwg_InitMainWindow( ::szAppName,cTitle,cMenu,    ;
         Iif(oIcon!=Nil,oIcon:handle,Nil),Iif(oBmp!=Nil,-1,clr),::Style,::nLeft, ;
         ::nTop,::nWidth,::nHeight )

   ELSEIF lType == WND_MDI

      // Register MDI frame  class
      // Create   MDI frame  window -> aWindows[0]
      Hwg_InitMdiWindow( ::szAppName,cTitle,cMenu,  ;
         Iif(oIcon!=Nil,oIcon:handle,Nil),clr, ;
         nStyle,::nLeft,::nTop,::nWidth,::nHeight )
      ::handle = hwg_GetWindowHandle(1)

   ELSEIF lType == WND_CHILD // Janelas modeless que pertencem a MAIN - jamaj

      ::oParent := HWindow():GetMain()
      IF ISOBJECT( ::oParent )
         ::handle := Hwg_InitChildWindow( ::szAppName,cTitle,cMenu,    ;
            Iif(oIcon!=Nil,oIcon:handle,Nil),Iif(oBmp!=Nil,-1,clr),nStyle,::nLeft, ;
            ::nTop,::nWidth,::nHeight,::oParent:handle )
      ELSE
         MsgStop("Nao eh possivel criar CHILD sem primeiro criar MAIN")

         RETURN (NIL)
      ENDIF

   ELSEIF lType == WND_MDICHILD //
      ::szAppName := "MDICHILD" + Alltrim(Str(HWG_GETNUMWINDOWS()))
      // Registra a classe
      Hwg_InitMdiChildWindow(::szAppName ,cTitle,cMenu,  ;
         Iif(oIcon!=Nil,oIcon:handle,Nil),clr, ;
         nStyle,::nLeft,::nTop,::nWidth,::nHeight )

      // Cria a window
      ::handle := Hwg_CreateMdiChildWindow( Self )
      // Janela pai = janela cliente MDI
      oWndClient := HWindow():FindWindow(hwg_GetWindowHandle(2))
      ::oParent := oWndClient

   ENDIF

   RETURN Self
   // Alterado por jamaj - added WND_CHILD support

METHOD Activate( lShow ) CLASS HWindow

   LOCAL oWndClient
   LOCAL oWnd := SELF

   IF ::type == WND_MDICHILD

   ELSEIF ::type == WND_MDI
      Hwg_InitClientWindow( oWnd:nMenuPos,oWnd:nLeft,oWnd:nTop+60,oWnd:nWidth,oWnd:nHeight )

      oWndClient := HWindow():New( 0,,,oWnd:style,oWnd:title,,oWnd:nMenuPos,oWnd:bInit,oWnd:bDestroy,oWnd:bSize, ;
         oWnd:bPaint,oWnd:bGetFocus,oWnd:bLostFocus,oWnd:bOther )

      oWndClient:handle := hwg_GetWindowHandle(2)
      oWndClient:oParent:= HWindow():GetMain()

      Hwg_ActivateMdiWindow( ( lShow==Nil .OR. lShow ),::hAccel )
   ELSEIF ::type == WND_MAIN
      Hwg_ActivateMainWindow( ( lShow==Nil .OR. lShow ),::hAccel )
   ELSEIF ::type == WND_CHILD
      Hwg_ActivateChildWindow( ::handle )
   ELSE

   ENDIF

   RETURN NIL

METHOD InitTray( oNotifyIcon, bNotify, oNotifyMenu, cTooltip ) CLASS HWindow

   ::bNotify     := bNotify
   ::oNotifyMenu := oNotifyMenu
   ::oNotifyIcon := oNotifyIcon
   ShellNotifyIcon( .T., ::handle, oNotifyIcon:handle, cTooltip )
   ::lTray := .T.

   RETURN NIL

METHOD AddItem( oWnd ) CLASS HWindow

   Aadd( ::aWindows, oWnd )

   RETURN NIL

METHOD DelItem( oWnd ) CLASS HWindow

   LOCAL i, h := oWnd:handle

   IF ( i := Ascan( ::aWindows,{|o|o:handle==h} ) ) > 0
      Adel( ::aWindows,i )
      Asize( ::aWindows, Len(::aWindows)-1 )
   ENDIF

   RETURN NIL

METHOD FindWindow( hWnd ) CLASS HWindow

   LOCAL i := Ascan( ::aWindows, {|o|o:handle==hWnd} )

   RETURN Iif( i == 0, Nil, ::aWindows[i] )

METHOD GetMain CLASS HWindow

   RETURN Iif(Len(::aWindows)>0,              ;
      Iif(::aWindows[1]:type==WND_MAIN, ;
      ::aWindows[1],                  ;
      Iif(Len(::aWindows)>1,::aWindows[2],Nil)), Nil )

METHOD GetMdiActive() CLASS HWindow

   RETURN ::FindWindow ( SendMessage( ::GetMain():handle, WM_MDIGETACTIVE,0,0 ) )

FUNCTION DefWndProc( hWnd, msg, wParam, lParam )

   LOCAL i, iItem, nHandle, aControls, nControls, iCont, hWndC, aMenu
   LOCAL iParHigh, iParLow
   LOCAL oWnd, oBtn, oitem

   // WriteLog( "|Window: "+Str(hWnd,10)+"|"+Str(msg,6)+"|"+Str(wParam,10)+"|"+Str(lParam,10)  + "|" + PadR("DefWndProc -Inicio",40) + "|")
   IF ( oWnd := HWindow():FindWindow(hWnd) ) == Nil
      // MsgStop( "Message: wrong window handle "+Str( hWnd )+"/"+Str( msg ),"Error!" )
      IF msg == WM_CREATE
         IF Len( HWindow():aWindows ) != 0 .and. ;
               ( oWnd := HWindow():aWindows[ Len(HWindow():aWindows) ] ) != Nil .and. ;
               oWnd:handle == 0
            oWnd:handle := hWnd
            IF oWnd:bInit != Nil
               Eval( oWnd:bInit, oWnd )
            ENDIF
         ENDIF
      ENDIF

      RETURN -1
   ENDIF
   IF msg == WM_COMMAND
      //WriteLog( "|Window: "+Str(hWnd,10)+"|"+Str(msg,6)+"|"+Str(wParam,10)+"|"+Str(lParam,10)  + "|" + PadR("Main - COMMAND",40) + "|")
      IF wParam == SC_CLOSE
         IF Len(HWindow():aWindows)>2 .AND. ( nHandle := SendMessage( HWindow():aWindows[2]:handle, WM_MDIGETACTIVE,0,0 ) ) > 0
            SendMessage( HWindow():aWindows[2]:handle, WM_MDIDESTROY, nHandle, 0 )
         ENDIF
      ELSEIF wParam == SC_RESTORE
         IF Len(HWindow():aWindows) > 2 .AND. ( nHandle := SendMessage( HWindow():aWindows[2]:handle, WM_MDIGETACTIVE,0,0 ) ) > 0
            SendMessage( HWindow():aWindows[2]:handle, WM_MDIRESTORE, nHandle, 0 )
         ENDIF
      ELSEIF wParam == SC_MAXIMIZE
         IF Len(HWindow():aWindows) > 2 .AND. ( nHandle := SendMessage( HWindow():aWindows[2]:handle, WM_MDIGETACTIVE,0,0 ) ) > 0
            SendMessage( HWindow():aWindows[2]:handle, WM_MDIMAXIMIZE, nHandle, 0 )
         ENDIF
      ELSEIF wParam >= FIRST_MDICHILD_ID .AND. wparam < FIRST_MDICHILD_ID + MAX_MDICHILD_WINDOWS
         nHandle := HWindow():aWindows[wParam - FIRST_MDICHILD_ID + 3]:handle
         SendMessage( HWindow():aWindows[2]:handle, WM_MDIACTIVATE, nHandle, 0 )
      ENDIF
      iParHigh := HiWord( wParam )
      iParLow := LoWord( wParam )
      IF oWnd:aEvents != Nil .AND. ;
            ( iItem := Ascan( oWnd:aEvents, {|a|a[1]==iParHigh.and.a[2]==iParLow} ) ) > 0
         Eval( oWnd:aEvents[ iItem,3 ],oWnd,iParLow )
      ELSEIF Valtype( oWnd:menu ) == "A" .AND. ;
            ( aMenu := Hwg_FindMenuItem( oWnd:menu,iParLow,@iCont ) ) != Nil ;
            .AND. aMenu[ 1,iCont,1 ] != Nil
         Eval( aMenu[ 1,iCont,1 ] )
      ELSEIF oWnd:oPopup != Nil .AND. ;
            ( aMenu := Hwg_FindMenuItem( oWnd:oPopup:aMenu,wParam,@iCont ) ) != Nil ;
            .AND. aMenu[ 1,iCont,1 ] != Nil
         Eval( aMenu[ 1,iCont,1 ] )
      ELSEIF oWnd:oNotifyMenu != Nil .AND. ;
            ( aMenu := Hwg_FindMenuItem( oWnd:oNotifyMenu:aMenu,wParam,@iCont ) ) != Nil ;
            .AND. aMenu[ 1,iCont,1 ] != Nil
         Eval( aMenu[ 1,iCont,1 ] )
      ENDIF

      RETURN 0
   ELSEIF msg == WM_PAINT
      IF oWnd:bPaint != Nil

         RETURN Eval( oWnd:bPaint, oWnd )
      ENDIF
   ELSEIF msg == WM_MOVE
      aControls := GetWindowRect( hWnd )
      oWnd:nLeft := aControls[1]
      oWnd:nTop  := aControls[2]
   ELSEIF msg == WM_SIZE
      aControls := oWnd:aControls
      nControls := Len( aControls )
#ifdef __XHARBOUR__
      FOR EACH oItem in aControls
         IF oItem:bSize != Nil
            Eval( oItem:bSize, ;
               oItem, LoWord( lParam ), HiWord( lParam ) )
         ENDIF
      NEXT
#else
      FOR iCont := 1 TO nControls
         IF aControls[iCont]:bSize != Nil
            Eval( aControls[iCont]:bSize, ;
               aControls[iCont], LoWord( lParam ), HiWord( lParam ) )
         ENDIF
      NEXT
#endif
      aControls := GetWindowRect( hWnd )
      oWnd:nWidth  := aControls[3]-aControls[1]
      oWnd:nHeight := aControls[4]-aControls[2]
      IF ISBLOCK( oWnd:bSize )
         Eval( oWnd:bSize, oWnd, LoWord( lParam ), HiWord( lParam ) )
      ENDIF
      IF oWnd:type == WND_MDI .AND. Len(HWindow():aWindows) > 1
         // writelog( str(hWnd)+"--"+str(aControls[1])+str(aControls[2])+str(aControls[3])+str(aControls[4]) )
         aControls := GetClientRect( hWnd )
         // writelog( str(hWnd)+"=="+str(aControls[1])+str(aControls[2])+str(aControls[3])+str(aControls[4]) )
         MoveWindow( HWindow():aWindows[2]:handle, oWnd:aOffset[1], oWnd:aOffset[2],aControls[3]-oWnd:aOffset[1]-oWnd:aOffset[3],aControls[4]-oWnd:aOffset[2]-oWnd:aOffset[4] )
         // aControls := GetClientRect( HWindow():aWindows[2]:handle )
         // writelog( str(HWindow():aWindows[2]:handle)+"::"+str(aControls[1])+str(aControls[2])+str(aControls[3])+str(aControls[4]) )

         RETURN 0
      ENDIF
   ELSEIF msg == WM_CTLCOLORSTATIC .OR. msg == WM_CTLCOLOREDIT .OR. msg == WM_CTLCOLORBTN

      RETURN DlgCtlColor( oWnd,wParam,lParam )
   ELSEIF msg == WM_ERASEBKGND
      IF oWnd:oBmp != Nil
         SpreadBitmap( wParam,oWnd:handle,oWnd:oBmp:handle )

         RETURN 1
      ENDIF
   ELSEIF msg == WM_DRAWITEM

      IF ( oBtn := oWnd:FindControl(wParam) ) != Nil
         IF ISBLOCK( oBtn:bPaint )
            Eval( oBtn:bPaint, oBtn, lParam )
         ENDIF
      ENDIF
   ELSEIF msg == WM_NOTIFY
      //WriteLog( "|Window: "+Str(hWnd,10)+"|"+Str(msg,6)+"|"+Str(wParam,10)+"|"+Str(lParam,10)  + "|" + PadR("Main - Notify",40) + "|")

      RETURN DlgNotify( oWnd,wParam,lParam )
   ELSEIF msg == WM_ENTERIDLE
      DlgEnterIdle( oWnd, wParam, lParam )

   ELSEIF msg == WM_CLOSE
      ReleaseAllWindows(oWnd,hWnd)

   ELSEIF msg == WM_DESTROY
      //WriteLog( "|Window: "+Str(hWnd,10)+"|"+Str(msg,6)+"|"+Str(wParam,10)+"|"+Str(lParam,10)  + "|" + PadR("Main - DESTROY",40) + "|")
      aControls := oWnd:aControls
      nControls := Len( aControls )
#ifdef __XHARBOUR__
      FOR EACH oItem IN aControls
         IF __ObjHasMsg( oItem,"END" )
            oItem:End()
         ENDIF
      NEXT
#else
      FOR i := 1 TO nControls
         IF __ObjHasMsg( aControls[i],"END" )
            aControls[i]:End()
         ENDIF
      NEXT
#endif
      HWindow():DelItem( oWnd )
      PostQuitMessage (0)

      RETURN 0
   ELSEIF msg == WM_SYSCOMMAND
      IF wParam == SC_CLOSE
         IF ISBLOCK( oWnd:bDestroy )
            i := Eval( oWnd:bDestroy, oWnd )
            i := IIf(Valtype(i) == "L",i,.t.)
            IF !i

               RETURN 0
            ENDIF
         ENDIF
         IF oWnd:oNotifyIcon != Nil
            ShellNotifyIcon( .F., oWnd:handle, oWnd:oNotifyIcon:handle )
         ENDIF
         IF oWnd:hAccel != Nil
            DestroyAcceleratorTable( oWnd:hAccel )
         ENDIF
      ELSEIF wParam == SC_MINIMIZE
         IF oWnd:lTray
            oWnd:Hide()

            RETURN 0
         ENDIF
      ENDIF
   ELSEIF msg == WM_NOTIFYICON
      IF wParam == ID_NOTIFYICON
         IF lParam == WM_LBUTTONDOWN
            IF ISBLOCK( oWnd:bNotify )
               Eval( oWnd:bNotify )
            ENDIF
         ELSEIF lParam == WM_RBUTTONDOWN
            IF oWnd:oNotifyMenu != Nil
               i := hwg_GetCursorPos()
               oWnd:oNotifyMenu:Show( oWnd,i[1],i[2] )
            ENDIF
         ENDIF
      ENDIF
   ELSEIF msg == WM_MENUSELECT
      IF NumAnd( HiWord(wParam), MF_HILITE ) <> 0 // HIWORD(wParam) = FLAGS , function NUMAND of the LIBCT.LIB
         IF Valtype( oWnd:menu ) == "A"
            IF ( aMenu := Hwg_FindMenuItem( oWnd:menu, LoWord(wParam), @iCont ) ) != Nil
               IF aMenu[ 1,iCont,2 ][2] != Nil
                  WriteStatus( oWnd, 1, aMenu[ 1,iCont,2 ][2] ) // show message on StatusBar
               ELSE
                  WriteStatus( oWnd, 1, "" ) // clear message
               ENDIF
            ELSE
               WriteStatus( oWnd, 1, "" ) // clear message
            ENDIF
         ENDIF
      ENDIF

      RETURN 0
   ELSE
      IF msg == WM_MOUSEMOVE
         DlgMouseMove()
      ENDIF
      IF ISBLOCK( oWnd:bOther )
         Eval( oWnd:bOther, oWnd, msg, wParam, lParam )
      ENDIF
   ENDIF

   RETURN -1

FUNCTION DefChildWndProc( hWnd, msg, wParam, lParam )

   LOCAL i, iItem, nHandle, aControls, nControls, iCont, hWndC, aMenu
   LOCAL iParHigh, iParLow
   LOCAL oWnd, oBtn, oitem

   //WriteLog( "|Window: "+Str(hWnd,10)+"|"+Str(msg,6)+"|"+Str(wParam,10)+"|"+Str(lParam,10)  + "|" + PadR("DefChildWndProc -Inicio",40) + "|")
   IF ( oWnd := HWindow():FindWindow(hWnd) ) == Nil
      IF msg == WM_CREATE
         IF Len( HWindow():aWindows ) != 0 .and. ;
               ( oWnd := HWindow():aWindows[ Len(HWindow():aWindows) ] ) != Nil .and. ;
               oWnd:handle == 0
            oWnd:handle := hWnd
            IF oWnd:bInit != Nil
               Eval( oWnd:bInit, oWnd )
            ENDIF
         ENDIF
      ENDIF

      RETURN 0
   ENDIF
   IF msg == WM_COMMAND
      //WriteLog( "|Window: "+Str(hWnd,10)+"|"+Str(msg,6)+"|"+Str(wParam,10)+"|"+Str(lParam,10)  + "|" + PadR("Child - COMMAND",40) + "|")
      IF wParam == SC_CLOSE
         //WriteLog( "|Window: "+Str(hWnd,10)+"|"+Str(msg,6)+"|"+Str(wParam,10)+"|"+Str(lParam,10)  + "|" + PadR("Child - Close",40) + "|")
         IF Len(HWindow():aWindows)>2 .AND. ( nHandle := SendMessage( HWindow():aWindows[2]:handle, WM_MDIGETACTIVE,0,0 ) ) > 0
            SendMessage( HWindow():aWindows[2]:handle, WM_MDIDESTROY, nHandle, 0 )
         ENDIF
      ELSEIF wParam == SC_RESTORE
         IF Len(HWindow():aWindows) > 2 .AND. ( nHandle := SendMessage( HWindow():aWindows[2]:handle, WM_MDIGETACTIVE,0,0 ) ) > 0
            SendMessage( HWindow():aWindows[2]:handle, WM_MDIRESTORE, nHandle, 0 )
         ENDIF
      ELSEIF wParam == SC_MAXIMIZE
         IF Len(HWindow():aWindows) > 2 .AND. ( nHandle := SendMessage( HWindow():aWindows[2]:handle, WM_MDIGETACTIVE,0,0 ) ) > 0
            SendMessage( HWindow():aWindows[2]:handle, WM_MDIMAXIMIZE, nHandle, 0 )
         ENDIF
      ELSEIF wParam >= FIRST_MDICHILD_ID .AND. wparam < FIRST_MDICHILD_ID + MAX_MDICHILD_WINDOWS
         nHandle := HWindow():aWindows[wParam - FIRST_MDICHILD_ID + 3]:handle
         SendMessage( HWindow():aWindows[2]:handle, WM_MDIACTIVATE, nHandle, 0 )
      ENDIF
      iParHigh := HiWord( wParam )
      iParLow := LoWord( wParam )
      IF oWnd:aEvents != Nil .AND. ;
            ( iItem := Ascan( oWnd:aEvents, {|a|a[1]==iParHigh.and.a[2]==iParLow} ) ) > 0
         Eval( oWnd:aEvents[ iItem,3 ],oWnd,iParLow )
      ELSEIF Valtype( oWnd:menu ) == "A" .AND. ;
            ( aMenu := Hwg_FindMenuItem( oWnd:menu,iParLow,@iCont ) ) != Nil ;
            .AND. aMenu[ 1,iCont,1 ] != Nil
         Eval( aMenu[ 1,iCont,1 ] )
      ELSEIF oWnd:oPopup != Nil .AND. ;
            ( aMenu := Hwg_FindMenuItem( oWnd:oPopup:aMenu,wParam,@iCont ) ) != Nil ;
            .AND. aMenu[ 1,iCont,1 ] != Nil
         Eval( aMenu[ 1,iCont,1 ] )
      ELSEIF oWnd:oNotifyMenu != Nil .AND. ;
            ( aMenu := Hwg_FindMenuItem( oWnd:oNotifyMenu:aMenu,wParam,@iCont ) ) != Nil ;
            .AND. aMenu[ 1,iCont,1 ] != Nil
         Eval( aMenu[ 1,iCont,1 ] )
      ENDIF

      RETURN 1
   ELSEIF msg == WM_PAINT
      IF oWnd:bPaint != Nil
         //WriteLog( "|Window: "+Str(hWnd,10)+"|"+Str(msg,6)+"|"+Str(wParam,10)+"|"+Str(lParam,10)  + "|" + PadR("Main - DefWndProc -Fim",40) + "|")

         RETURN Eval( oWnd:bPaint, oWnd )
      ENDIF
   ELSEIF msg == WM_MOVE
      aControls := GetWindowRect( hWnd )
      oWnd:nLeft := aControls[1]
      oWnd:nTop  := aControls[2]
   ELSEIF msg == WM_SIZE
      aControls := oWnd:aControls
      nControls := Len( aControls )
#ifdef __XHARBOUR__
      FOR EACH oItem in aControls
         IF oItem:bSize != Nil
            Eval( oItem:bSize, ;
               oItem, LoWord( lParam ), HiWord( lParam ) )
         ENDIF
      NEXT
#else
      FOR iCont := 1 TO nControls
         IF aControls[iCont]:bSize != Nil
            Eval( aControls[iCont]:bSize, ;
               aControls[iCont], LoWord( lParam ), HiWord( lParam ) )
         ENDIF
      NEXT
#endif
      aControls := GetWindowRect( hWnd )
      oWnd:nWidth  := aControls[3]-aControls[1]
      oWnd:nHeight := aControls[4]-aControls[2]
      IF oWnd:bSize != Nil
         Eval( oWnd:bSize, oWnd, LoWord( lParam ), HiWord( lParam ) )
      ENDIF
      IF oWnd:type == WND_MDI .AND. Len(HWindow():aWindows) > 1
         // writelog( str(hWnd)+"--"+str(aControls[1])+str(aControls[2])+str(aControls[3])+str(aControls[4]) )
         aControls := GetClientRect( hWnd )
         // writelog( str(hWnd)+"=="+str(aControls[1])+str(aControls[2])+str(aControls[3])+str(aControls[4]) )
         MoveWindow( HWindow():aWindows[2]:handle, oWnd:aOffset[1], oWnd:aOffset[2],aControls[3]-oWnd:aOffset[1]-oWnd:aOffset[3],aControls[4]-oWnd:aOffset[2]-oWnd:aOffset[4] )
         // aControls := GetClientRect( HWindow():aWindows[2]:handle )
         // writelog( str(HWindow():aWindows[2]:handle)+"::"+str(aControls[1])+str(aControls[2])+str(aControls[3])+str(aControls[4]) )

         RETURN 1
      ENDIF
   ELSEIF msg == WM_CTLCOLORSTATIC .OR. msg == WM_CTLCOLOREDIT .OR. msg == WM_CTLCOLORBTN

      RETURN DlgCtlColor( oWnd,wParam,lParam )
   ELSEIF msg == WM_ERASEBKGND
      IF oWnd:oBmp != Nil
         SpreadBitmap( wParam,oWnd:handle,oWnd:oBmp:handle )

         RETURN 1
      ENDIF
   ELSEIF msg == WM_DRAWITEM
      IF ( oBtn := oWnd:FindControl(wParam) ) != Nil
         IF oBtn:bPaint != Nil
            Eval( oBtn:bPaint, oBtn, lParam )
         ENDIF
      ENDIF
   ELSEIF msg == WM_NOTIFY
      //WriteLog( "|Window: "+Str(hWnd,10)+"|"+Str(msg,6)+"|"+Str(wParam,10)+"|"+Str(lParam,10)  + "|" + PadR("Child - Notify",40) + "|")

      RETURN DlgNotify( oWnd,wParam,lParam )
   ELSEIF msg == WM_ENTERIDLE
      IF wParam == 0 .AND. ( oItem := Atail( HDialog():aModalDialogs ) ) != Nil ;
            .AND. oItem:handle == lParam .AND. !oItem:lActivated
         oItem:lActivated := .T.
         IF oItem:bActivate != Nil
            Eval( oItem:bActivate, oItem )
         ENDIF
      ENDIF
   ELSEIF msg == WM_DESTROY
      //WriteLog( "|Window: "+Str(hWnd,10)+"|"+Str(msg,6)+"|"+Str(wParam,10)+"|"+Str(lParam,10)  + "|" + PadR("Child - DESTROY",40) + "|")
      aControls := oWnd:aControls
      nControls := Len( aControls )
#ifdef __XHARBOUR__
      FOR EACH oItem IN aControls
         IF __ObjHasMsg( oItem,"END" )
            oItem:End()
         ENDIF
      NEXT
#else
      FOR i := 1 TO nControls
         IF __ObjHasMsg( aControls[i],"END" )
            aControls[i]:End()
         ENDIF
      NEXT
#endif
      HWindow():DelItem( oWnd )

      // Return 0  // Default

      PostQuitMessage (0)

      RETURN 1

   ELSEIF msg == WM_SYSCOMMAND
      //WriteLog( "|Window: "+Str(hWnd,10)+"|"+Str(msg,6)+"|"+Str(wParam,10)+"|"+Str(lParam,10)  + "|" + PadR("Child - SysCommand",40) + "|")
      IF wParam == SC_CLOSE
         //WriteLog( "|Window: "+Str(hWnd,10)+"|"+Str(msg,6)+"|"+Str(wParam,10)+"|"+Str(lParam,10)  + "|" + PadR("Child - SysCommand - Close",40) + "|")
         IF oWnd:bDestroy != Nil
            IF !Eval( oWnd:bDestroy, oWnd )

               RETURN 1
            ENDIF
            IF oWnd:oNotifyIcon != Nil
               ShellNotifyIcon( .F., oWnd:handle, oWnd:oNotifyIcon:handle )
            ENDIF
            IF oWnd:hAccel != Nil
               DestroyAcceleratorTable( oWnd:hAccel )
            ENDIF
         ENDIF
      ELSEIF wParam == SC_MINIMIZE
         IF oWnd:lTray
            oWnd:Hide()

            RETURN 1
         ENDIF
      ENDIF
   ELSEIF msg == WM_NOTIFYICON
      IF wParam == ID_NOTIFYICON
         IF lParam == WM_LBUTTONDOWN
            IF oWnd:bNotify != Nil
               Eval( oWnd:bNotify )
            ENDIF
         ELSEIF lParam == WM_RBUTTONDOWN
            IF oWnd:oNotifyMenu != Nil
               i := hwg_GetCursorPos()
               oWnd:oNotifyMenu:Show( oWnd,i[1],i[2] )
            ENDIF
         ENDIF
      ENDIF
   ELSE
      IF msg == WM_MOUSEMOVE
         DlgMouseMove()
      ENDIF
      IF oWnd:bOther != Nil
         Eval( oWnd:bOther, oWnd, msg, wParam, lParam )
      ENDIF
   ENDIF

   //WriteLog( "|Window: "+Str(hWnd,10)+"|"+Str(msg,6)+"|"+Str(wParam,10)+"|"+Str(lParam,10)  + "|" + PadR("Child - DefChildWndProc -Fim",40) + "|")

   RETURN 0

FUNCTION DefMdiChildProc( hWnd, msg, wParam, lParam )

   LOCAL i, iItem, nHandle, aControls, nControls, iCont
   LOCAL iParHigh, iParLow, oWnd, oBtn, oitem
   LOCAL nReturn
   LOCAL oWndBase   :=  HWindow():aWindows[1]
   LOCAL oWndClient :=  HWindow():aWindows[2]
   LOCAL hJanBase   :=  oWndBase:handle
   LOCAL hJanClient :=  oWndClient:handle
   LOCAL aMenu,hMenu,hSubMenu, nPosMenu

   // WriteLog( "|DefMDIChild  "+Str(hWnd,10)+"|"+Str(msg,6)+"|"+Str(wParam,10)+"|"+Str(lParam,10) )
   IF msg == WM_NCCREATE
      // WriteLog( "|DefMDIChild  "+Str(hWnd,10)+"|"+Str(msg,6)+"|"+Str(wParam,10)+"|"+Str(lParam,10) + " WM_CREATE" )
      // Procura objecto window com handle = 0
      oWnd := HWindow():FindWindow(0)

      IF ISOBJECT(oWnd)

         oWnd:handle := hWnd
         InitControls( oWnd )
      ELSE

         MsgStop("DefMDIChild wrong hWnd : " + Str(hWnd,10),"Create Error!")
         QUIT
         nReturn := 0

         RETURN (nReturn)
      ENDIF

   ENDIF

   IF ( oWnd := HWindow():FindWindow(hWnd) ) == Nil
      // MsgStop( "MDI child: wrong window handle "+Str( hWnd ) + "| " + Str(msg) ,"Error!" )
      // Deve entrar aqui apenas em WM_GETMINMAXINFO, que vem antes de WM_NCCREATE

      RETURN NIL
   ENDIF

   IF msg == WM_COMMAND
      IF wParam == SC_CLOSE
         IF Len(HWindow():aWindows) > 2 .AND. ( nHandle := SendMessage( HWindow():aWindows[2]:handle, WM_MDIGETACTIVE,0,0 ) ) > 0
            SendMessage( HWindow():aWindows[2]:handle, WM_MDIDESTROY, nHandle, 0 )
         ENDIF
      ENDIF
      iParHigh := HiWord( wParam )
      iParLow := LoWord( wParam )
      IF oWnd:aEvents != Nil .AND. ;
            ( iItem := Ascan( oWnd:aEvents, {|a|a[1]==iParHigh.and.a[2]==iParLow} ) ) > 0
         Eval( oWnd:aEvents[ iItem,3 ] )
      ENDIF
      nReturn := 1

      RETURN (nReturn)
   ELSEIF msg == WM_MOUSEMOVE
      oBtn := SetOwnBtnSelected()
      IF oBtn != Nil
         oBtn:state := OBTN_NORMAL
         InvalidateRect( oBtn:handle, 0 )
         PostMessage( oBtn:handle, WM_PAINT, 0, 0 )
         SetOwnBtnSelected( Nil )
      ENDIF
   ELSEIF msg == WM_PAINT

      IF ISOBJECT(oWnd) .and. ISBLOCK(oWnd:bPaint)

         // WriteLog( "|DefMDIChild Paint"+Str(hWnd,10)+"|"+Str(msg,6)+"|"+Str(wParam,10)+"|"+Str(lParam,10) )

         nReturn := Eval( oWnd:bPaint, oWnd )
         // Writelog("Saida: " + Valtype(nReturn) )
         // Return (nReturn)

      ENDIF

   ELSEIF msg == WM_SIZE
      IF ISOBJECT( oWnd )
         aControls := oWnd:aControls
         nControls := Len( aControls )
#ifdef __XHARBOUR__
         FOR EACH oItem in aControls
            IF oItem:bSize != Nil
               Eval( oItem:bSize, ;
                  oItem, LoWord( lParam ), HiWord( lParam ) )
            ENDIF
         NEXT
#else
         FOR iCont := 1 TO nControls
            IF aControls[iCont]:bSize != Nil
               Eval( aControls[iCont]:bSize, ;
                  aControls[iCont], LoWord( lParam ), HiWord( lParam ) )
            ENDIF
         NEXT
#endif
      ENDIF
   ELSEIF msg == WM_NCACTIVATE
      //WriteLog( "|DefMDIChild"+Str(hWnd,10)+"|"+Str(msg,6)+"|"+Str(wParam,10)+"|"+Str(lParam,10) )
      IF ISOBJECT(oWnd)
         IF wParam = 1 // Ativando
            // WriteLog("WM_NCACTIVATE" + " -> " + "Ativando" + " Wnd: " + Str(hWnd,10) )
            // Pega o menu atribuido
            aMenu := oWnd:menu
            //hMenu := aMenu[5]
            nPosMenu := 0
            //hSubMenu := GetSubMenu(hMenu, nPosMenu)

            // SendMessage( hJanClient, WM_MDISETMENU, hmenu, 0 )
            DrawMenuBar(hJanBase)

            IF  oWnd:bGetFocus != Nil
               Eval( oWnd:bGetFocus, oWnd )
            ENDIF
         ELSE   // Desativando
            // WriteLog("WM_NCACTIVATE" + " -> " + "Desativando" + " Wnd: " + Str(hWnd,10) )
            IF  oWnd:bLostFocus != Nil
               Eval( oWnd:bLostFocus, oWnd )
            ENDIF
         ENDIF
      ENDIF

      nReturn := 0

      RETURN (nReturn)

   ELSEIF msg == WM_MDIACTIVATE

      IF wParam == 1
         // WriteLog("WM_MDIACTIVATE" + " -> " + "Ativando" + " Wnd: " + Str(hWnd,10) )
         // Pega o menu atribuido
         aMenu := oWnd:menu
         hMenu := aMenu[5]

         SendMessage( hJanBase, WM_MDISETMENU, hMenu, 0 )
         DrawMenuBar(hJanBase)
      ENDIF

      nReturn := 0

      RETURN (nReturn)

   ELSEIF msg == WM_CTLCOLORSTATIC .OR. msg == WM_CTLCOLOREDIT .OR. msg == WM_CTLCOLORBTN

      RETURN DlgCtlColor( oWnd,wParam,lParam )
      /*
      if ( oBtn := oWnd:FindControl(,lParam) ) != Nil
      if oBtn:tcolor != Nil
      SetTextColor( wParam, oBtn:tcolor )
      endif
      if oBtn:bcolor != Nil
      SetBkColor( wParam, oBtn:bcolor )

      Return oBtn:brush:handle
      endif
      nReturn := 0

      Return (nReturn)
      endif
      */
   ELSEIF msg == WM_DRAWITEM
      IF ( oBtn := oWnd:FindControl(wParam) ) != Nil
         IF oBtn:bPaint != Nil
            Eval( oBtn:bPaint, oBtn, wParam, lParam )
         ENDIF
      ENDIF

   ELSEIF msg == WM_NCDESTROY
      IF ISOBJECT(oWnd)
         HWindow():DelItem( oWnd )
      ELSE
         MsgStop("oWnd nao e objeto! em NC_DESTROY!","DefMDIChildProc")
      ENDIF
   ELSEIF msg == WM_DESTROY
      IF ISOBJECT(oWnd)
         IF ISBLOCK(oWnd:bDestroy)
            Eval( oWnd:bDestroy, oWnd )
         ENDIF
         aControls := oWnd:aControls
         nControls := Len( aControls )
#ifdef __XHARBOUR__
         FOR EACH oItem in aControls
            IF __ObjHasMsg( oItem,"END" )
               oItem:End()
            ENDIF
         NEXT
#else
         FOR i := 1 TO nControls
            IF __ObjHasMsg( aControls[i],"END" )
               aControls[i]:End()
            ENDIF
         NEXT
#endif
         // HWindow():DelItem( oWnd )  -> alterado por jamaj
         // Temos que eliminar em NC_DESTROY
      ENDIF
      nReturn := 1

      RETURN (nReturn)
   ELSEIF msg == WM_CREATE
      IF ISBLOCK(oWnd:bInit)
         Eval( oWnd:bInit,oWnd )
      ENDIF
   ELSE
      IF ISOBJECT(oWnd) .and. ISBLOCK(oWnd:bOther)
         Eval( oWnd:bOther, oWnd, msg, wParam, lParam )
      ENDIF
   ENDIF
   nReturn := NIL

   RETURN (nReturn)

FUNCTION ReleaseAllWindows( oWnd, hWnd )

   LOCAL oItem, iCont, nCont

   //  Vamos mandar destruir as filhas
   // Destroi as CHILD's desta MAIN
#ifdef __XHARBOUR__
   FOR EACH oItem IN HWindow():aWindows
      IF oItem:oParent != Nil .AND. oItem:oParent:handle == hWnd
         SendMessage( oItem:handle,WM_CLOSE,0,0 )
      ENDIF
   NEXT
#else
   nCont := Len( HWindow():aWindows )

   FOR iCont := 1 TO nCont

      IF HWindow():aWindows[iCont]:oParent != Nil .AND. ;
            HWindow():aWindows[iCont]:oParent:handle == hWnd
         SendMessage( HWindow():aWindows[iCont]:handle,WM_CLOSE,0,0 )
      ENDIF

   NEXT
#endif

   IF HWindow():GetMain() == oWnd
      EXITProcess(0)
   ENDIF

   RETURN NIL

   // Processamento da janela frame (base) MDI

FUNCTION DefMDIWndProc( hWnd, msg, wParam, lParam )

   LOCAL i, iItem, nHandle, aControls, nControls, iCont, hWndC, aMenu
   LOCAL iParHigh, iParLow
   LOCAL oWnd, oBtn, oitem
   LOCAL xRet, nReturn
   LOCAL oWndClient

   // WriteLog( "|DefMDIWndProc"+Str(hWnd,10)+"|"+Str(msg,6)+"|"+Str(wParam,10)+"|"+Str(lParam,10) )
   IF msg == WM_NCCREATE
      // WriteLog( "|DefMDIWndProc"+Str(hWnd,10)+"|"+Str(msg,6)+"|"+Str(wParam,10)+"|"+Str(lParam,10) + " WM_CREATE" )
      // Procura objecto window com handle = 0
      oWnd := HWindow():FindWindow(0)

      IF ISOBJECT(oWnd)
         oWnd:handle := hWnd
      ELSE

         MsgStop("DefMDIWndProc wrong hWnd : " + Str(hWnd,10),"Create Error!")
         QUIT
         nReturn := 0

         RETURN (nReturn)

      ENDIF

   ENDIF

   IF ( oWnd := HWindow():FindWindow(hWnd) ) == Nil
      // MsgStop( "MDI wnd: wrong window handle "+Str( hWnd ) + "| " + Str(msg) ,"Error!" )
      // Deve entrar aqui apenas em WM_GETMINMAXINFO, que vem antes de WM_NCCREATE

      RETURN NIL
   ENDIF

   IF msg == WM_CREATE
      IF ISBLOCK(oWnd:bInit)
         Eval( oWnd:bInit, oWnd )
      ENDIF
   ELSEIF msg == WM_COMMAND
      //WriteLog( "|Window: "+Str(hWnd,10)+"|"+Str(msg,6)+"|"+Str(wParam,10)+"|"+Str(lParam,10)  + "|" + PadR("Main - COMMAND",40) + "|")
      IF wParam == SC_CLOSE
         //WriteLog( "|Window: "+Str(hWnd,10)+"|"+Str(msg,6)+"|"+Str(wParam,10)+"|"+Str(lParam,10)  + "|" + PadR("Main - Close",40) + "|")
         IF Len(HWindow():aWindows)>2 .AND. ( nHandle := SendMessage( HWindow():aWindows[2]:handle, WM_MDIGETACTIVE,0,0 ) ) > 0
            SendMessage( HWindow():aWindows[2]:handle, WM_MDIDESTROY, nHandle, 0 )
         ENDIF
      ELSEIF wParam == SC_RESTORE
         IF Len(HWindow():aWindows) > 2 .AND. ( nHandle := SendMessage( HWindow():aWindows[2]:handle, WM_MDIGETACTIVE,0,0 ) ) > 0
            SendMessage( HWindow():aWindows[2]:handle, WM_MDIRESTORE, nHandle, 0 )
         ENDIF
      ELSEIF wParam == SC_MAXIMIZE
         IF Len(HWindow():aWindows) > 2 .AND. ( nHandle := SendMessage( HWindow():aWindows[2]:handle, WM_MDIGETACTIVE,0,0 ) ) > 0
            SendMessage( HWindow():aWindows[2]:handle, WM_MDIMAXIMIZE, nHandle, 0 )
         ENDIF
      ELSEIF wParam >= FIRST_MDICHILD_ID .AND. wparam < FIRST_MDICHILD_ID + MAX_MDICHILD_WINDOWS
         nHandle := HWindow():aWindows[wParam - FIRST_MDICHILD_ID + 3]:handle
         SendMessage( HWindow():aWindows[2]:handle, WM_MDIACTIVATE, nHandle, 0 )
      ENDIF
      iParHigh := HiWord( wParam )
      iParLow := LoWord( wParam )
      IF oWnd:aEvents != Nil .AND. ;
            ( iItem := Ascan( oWnd:aEvents, {|a|a[1]==iParHigh.and.a[2]==iParLow} ) ) > 0
         Eval( oWnd:aEvents[ iItem,3 ],oWnd,iParLow )
      ELSEIF Valtype( oWnd:menu ) == "A" .AND. ;
            ( aMenu := Hwg_FindMenuItem( oWnd:menu,iParLow,@iCont ) ) != Nil ;
            .AND. aMenu[ 1,iCont,1 ] != Nil

         Eval( aMenu[ 1,iCont,1 ] )

      ELSEIF oWnd:oPopup != Nil .AND. ;
            ( aMenu := Hwg_FindMenuItem( oWnd:oPopup:aMenu,wParam,@iCont ) ) != Nil ;
            .AND. aMenu[ 1,iCont,1 ] != Nil

         Eval( aMenu[ 1,iCont,1 ] )
      ELSEIF oWnd:oNotifyMenu != Nil .AND. ;
            ( aMenu := Hwg_FindMenuItem( oWnd:oNotifyMenu:aMenu,wParam,@iCont ) ) != Nil ;
            .AND. aMenu[ 1,iCont,1 ] != Nil

         Eval( aMenu[ 1,iCont,1 ] )
      ENDIF

      RETURN 1
   ELSEIF msg == WM_PAINT
      IF oWnd:bPaint != Nil
         //WriteLog( "|Window: "+Str(hWnd,10)+"|"+Str(msg,6)+"|"+Str(wParam,10)+"|"+Str(lParam,10)  + "|" + PadR("DefWndProc -Inicio",40) + "|")

         RETURN Eval( oWnd:bPaint, oWnd )
      ENDIF
   ELSEIF msg == WM_MOVE
      aControls := GetWindowRect( hWnd )
      oWnd:nLeft := aControls[1]
      oWnd:nTop  := aControls[2]
   ELSEIF msg == WM_SIZE
      aControls := oWnd:aControls
      nControls := Len( aControls )
#ifdef __XHARBOUR__
      FOR EACH oItem in aControls
         IF oItem:bSize != Nil
            Eval( oItem:bSize, ;
               oItem, LoWord( lParam ), HiWord( lParam ) )
         ENDIF
      NEXT
#else
      FOR iCont := 1 TO nControls
         IF aControls[iCont]:bSize != Nil
            Eval( aControls[iCont]:bSize, ;
               aControls[iCont], LoWord( lParam ), HiWord( lParam ) )
         ENDIF
      NEXT
#endif
      aControls := GetWindowRect( hWnd )
      oWnd:nWidth  := aControls[3]-aControls[1]
      oWnd:nHeight := aControls[4]-aControls[2]
      IF oWnd:bSize != Nil
         Eval( oWnd:bSize, oWnd, LoWord( lParam ), HiWord( lParam ) )
      ENDIF
      IF oWnd:type == WND_MDI .AND. Len(HWindow():aWindows) > 1
         // writelog( str(hWnd)+"--"+str(aControls[1])+str(aControls[2])+str(aControls[3])+str(aControls[4]) )
         aControls := GetClientRect( hWnd )
         // writelog( str(hWnd)+"=="+str(aControls[1])+str(aControls[2])+str(aControls[3])+str(aControls[4]) )
         MoveWindow( HWindow():aWindows[2]:handle, oWnd:aOffset[1], oWnd:aOffset[2],aControls[3]-oWnd:aOffset[1]-oWnd:aOffset[3],aControls[4]-oWnd:aOffset[2]-oWnd:aOffset[4] )
         // aControls := GetClientRect( HWindow():aWindows[2]:handle )
         // writelog( str(HWindow():aWindows[2]:handle)+"::"+str(aControls[1])+str(aControls[2])+str(aControls[3])+str(aControls[4]) )

         RETURN 1
      ENDIF
   ELSEIF msg == WM_CTLCOLORSTATIC .OR. msg == WM_CTLCOLOREDIT .OR. msg == WM_CTLCOLORBTN

      RETURN DlgCtlColor( oWnd,wParam,lParam )
   ELSEIF msg == WM_ERASEBKGND
      IF oWnd:oBmp != Nil
         SpreadBitmap( wParam,oWnd:handle,oWnd:oBmp:handle )

         RETURN 1
      ENDIF
   ELSEIF msg == WM_DRAWITEM

      IF ( oBtn := oWnd:FindControl(wParam) ) != Nil
         IF oBtn:bPaint != Nil
            Eval( oBtn:bPaint, oBtn, lParam )
         ENDIF
      ENDIF
   ELSEIF msg == WM_NOTIFY
      //WriteLog( "|Window: "+Str(hWnd,10)+"|"+Str(msg,6)+"|"+Str(wParam,10)+"|"+Str(lParam,10)  + "|" + PadR("Main - Notify",40) + "|")

      RETURN DlgNotify( oWnd,wParam,lParam )
   ELSEIF msg == WM_ENTERIDLE
      IF wParam == 0 .AND. ( oItem := Atail( HDialog():aModalDialogs ) ) != Nil ;
            .AND. oItem:handle == lParam .AND. !oItem:lActivated
         oItem:lActivated := .T.
         IF oItem:bActivate != Nil
            Eval( oItem:bActivate, oItem )
         ENDIF
      ENDIF

   ELSEIF msg == WM_CLOSE
      ReleaseAllWindows(oWnd,hWnd)

   ELSEIF msg == WM_DESTROY
      //WriteLog( "|Window: "+Str(hWnd,10)+"|"+Str(msg,6)+"|"+Str(wParam,10)+"|"+Str(lParam,10)  + "|" + PadR("Main - DESTROY",40) + "|")
      aControls := oWnd:aControls
      nControls := Len( aControls )
#ifdef __XHARBOUR__
      FOR EACH oItem IN aControls
         IF __ObjHasMsg( oItem,"END" )
            oItem:End()
         ENDIF
      NEXT
#else
      FOR i := 1 TO nControls
         IF __ObjHasMsg( aControls[i],"END" )
            aControls[i]:End()
         ENDIF
      NEXT
#endif
      // HWindow():DelItem( oWnd )

      IF ISBLOCK(oWnd:bDestroy)
         Eval( oWnd:bDestroy, oWnd )
      ENDIF

      PostQuitMessage (0)

      // return 0

      RETURN 1

   ELSEIF msg == WM_NCDESTROY
      IF ISOBJECT(oWnd)
         HWindow():DelItem( oWnd )
      ELSE
         MsgStop("oWnd nao e objeto! em NC_DESTROY!","DefMDIWndProc")
      ENDIF

   ELSEIF msg == WM_SYSCOMMAND
      //WriteLog( "|Window: "+Str(hWnd,10)+"|"+Str(msg,6)+"|"+Str(wParam,10)+"|"+Str(lParam,10)  + "|" + PadR("Main - SysCommand",40) + "|")
      IF wParam == SC_CLOSE
         //WriteLog( "|Window: "+Str(hWnd,10)+"|"+Str(msg,6)+"|"+Str(wParam,10)+"|"+Str(lParam,10)  + "|" + PadR("Main - SysCommand - Close",40) + "|")
         IF oWnd:bDestroy != Nil
            xRet := Eval( oWnd:bDestroy, oWnd )
            xRet := IIf(Valtype(xRet) == "L",xRet,.t.)
            IF !xRet

               RETURN 1
            ENDIF
         ENDIF

         IF oWnd:oNotifyIcon != Nil
            ShellNotifyIcon( .F., oWnd:handle, oWnd:oNotifyIcon:handle )
         ENDIF
         IF oWnd:hAccel != Nil
            DestroyAcceleratorTable( oWnd:hAccel )
         ENDIF

         RETURN 0
      ELSEIF wParam == SC_MINIMIZE
         IF oWnd:lTray
            oWnd:Hide()

            RETURN 1
         ENDIF
      ENDIF
   ELSEIF msg == WM_NOTIFYICON
      IF wParam == ID_NOTIFYICON
         IF lParam == WM_LBUTTONDOWN
            IF oWnd:bNotify != Nil
               Eval( oWnd:bNotify )
            ENDIF
         ELSEIF lParam == WM_RBUTTONDOWN
            IF oWnd:oNotifyMenu != Nil
               i := hwg_GetCursorPos()
               oWnd:oNotifyMenu:Show( oWnd,i[1],i[2] )
            ENDIF
         ENDIF
      ENDIF
   ELSE
      IF ISOBJECT(oWnd)
         IF msg == WM_MOUSEMOVE
            DlgMouseMove()
         ENDIF
         IF ISBLOCK(oWnd:bOther)
            Eval( oWnd:bOther, oWnd, msg, wParam, lParam )
         ENDIF
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION GetChildWindowsNumber

   RETURN Len( HWindow():aWindows ) - 2
