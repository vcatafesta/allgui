/*
*$Id: hcwindow.prg,v 1.5 2006/08/07 11:14:29 alkresin Exp $
* HWGUI - Harbour Win32 GUI library source code:
* HCustomWindow class
* Copyright 2004 Alexander S.Kresin <alex@belacy.belgorod.su>
* www - http://kresin.belgorod.su
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"

STATIC aCustomEvents := { ;
   { WM_NOTIFY,WM_PAINT,WM_CTLCOLORSTATIC,WM_CTLCOLOREDIT,WM_CTLCOLORBTN, ;
   WM_COMMAND,WM_DRAWITEM,WM_SIZE,WM_DESTROY }, ;
   { ;
   {|o,w,l|onNotify(o,w,l)},                        ;
   {|o,w|Iif(o:bPaint!=Nil,Eval(o:bPaint,o,w),-1)}, ;
   {|o,w,l|onCtlColor(o,w,l)},                      ;
   {|o,w,l|onCtlColor(o,w,l)},                      ;
   {|o,w,l|onCtlColor(o,w,l)},                      ;
   {|o,w,l|onCommand(o,w)},                         ;
   {|o,w,l|onDrawItem(o,w,l)},                      ;
   {|o,w,l|onSize(o,w,l)},                          ;
   {|o|onDestroy(o)}                                ;
   } ;
   }

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
   DATA HelpId   INIT 0

METHOD AddControl( oCtrl ) INLINE Aadd( ::aControls,oCtrl )

METHOD DelControl( oCtrl )

METHOD AddEvent( nEvent,nId,bAction,lNotify ) ;
      INLINE Aadd( Iif( lNotify==Nil.OR.!lNotify,::aEvents,::aNotify ),{nEvent,nId,bAction} )

METHOD FindControl( nId,nHandle )

METHOD Hide() INLINE (::lHide:=.T.,HideWindow(::handle))

METHOD Show() INLINE (::lHide:=.F.,ShowWindow(::handle))

METHOD Move( x1,y1,width,height )

METHOD onEvent( msg, wParam, lParam )

METHOD End()

ENDCLASS

METHOD FindControl( nId,nHandle ) CLASS HCustomWindow

   LOCAL i := Iif( nId!=Nil,Ascan( ::aControls,{|o|o:id==nId} ), ;
      Ascan( ::aControls,{|o|o:handle==nHandle} ) )

   RETURN Iif( i==0,Nil,::aControls[i] )

METHOD DelControl( oCtrl ) CLASS HCustomWindow

   LOCAL id := oCtrl:id, h
   LOCAL i := Ascan( ::aControls,{|o|o==oCtrl} )

   IF oCtrl:ClassName() == "HPANEL"
      DestroyPanel( oCtrl:handle )
   ELSE
      hwg_DestroyWindow( oCtrl:handle )
   ENDIF
   IF i != 0
      Adel( ::aControls,i )
      Asize( ::aControls,Len(::aControls)-1 )
   ENDIF
   h := 0
   FOR i := Len( ::aEvents ) TO 1 STEP -1
      IF ::aEvents[i,2] == id
         Adel( ::aEvents,i )
         h ++
      ENDIF
   NEXT
   IF h > 0
      Asize( ::aEvents,Len(::aEvents)-h )
   ENDIF
   h := 0
   FOR i := Len( ::aNotify ) TO 1 STEP -1
      IF ::aNotify[i,2] == id
         Adel( ::aNotify,i )
         h ++
      ENDIF
   NEXT
   IF h > 0
      Asize( ::aNotify,Len(::aNotify)-h )
   ENDIF

   RETURN NIL

METHOD Move( x1,y1,width,height )  CLASS HCustomWindow

   IF x1 != Nil
      ::nLeft := x1
   ENDIF
   IF y1 != Nil
      ::nTop  := y1
   ENDIF
   IF width != Nil
      ::nWidth := width
   ENDIF
   IF height != Nil
      ::nHeight := height
   ENDIF
   MoveWindow( ::handle,::nLeft,::nTop,::nWidth,::nHeight )

   RETURN NIL

METHOD onEvent( msg, wParam, lParam )  CLASS HCustomWindow

   LOCAL i

   // Writelog( "== "+::Classname()+Str(msg)+Iif(wParam!=Nil,Str(wParam),"Nil")+Iif(lParam!=Nil,Str(lParam),"Nil") )
   IF ( i := Ascan( aCustomEvents[1],msg ) ) != 0

      RETURN Eval( aCustomEvents[2,i], Self, wParam, lParam )
   ELSEIF ::bOther != Nil

      RETURN Eval( ::bOther, Self, msg, wParam, lParam )
   ENDIF

   RETURN 0

METHOD End()  CLASS HCustomWindow

   LOCAL aControls := ::aControls
   LOCAL i, nLen := Len( aControls )

   FOR i := 1 TO nLen
      aControls[i]:End()
   NEXT

   hwg_ReleaseObject( ::handle )

   RETURN NIL

STATIC FUNCTION onNotify( oWnd,wParam,lParam )

   LOCAL iItem, oCtrl := oWnd:FindControl( wParam ), nCode, res, handle, oItem

   IF oCtrl != Nil
      IF oCtrl:ClassName() == "HTAB"
         DO CASE
         CASE ( nCode := GetNotifyCode( lParam ) ) == TCN_SELCHANGE
            IF oCtrl != Nil .AND. oCtrl:bChange != Nil
               Eval( oCtrl:bChange, oCtrl, GetCurrentTab( oCtrl:handle ) )
            ENDIF
         CASE ( nCode := GetNotifyCode( lParam ) ) == TCN_CLICK
            IF oCtrl != Nil .AND. oCtrl:bAction != nil
               Eval( oCtrl:bAction, oCtrl, GetCurrentTab( oCtrl:handle ) )
            ENDIF
         CASE ( nCode := GetNotifyCode( lParam ) ) == TCN_SETFOCUS
            IF oCtrl != Nil .AND. oCtrl:bGetFocus != nil
               Eval( oCtrl:bGetFocus, oCtrl, GetCurrentTab( oCtrl:handle ) )
            ENDIF
         CASE ( nCode := GetNotifyCode( lParam ) ) == TCN_KILLFOCUS
            IF oCtrl != Nil .AND. oCtrl:bLostFocus != nil
               Eval( oCtrl:bLostFocus, oCtrl, GetCurrentTab( oCtrl:handle ))
            ENDIF
         ENDCASE
      ELSEIF oCtrl:ClassName() == "HQHTM"

         RETURN oCtrl:Notify( oWnd,lParam )
      ELSEIF oCtrl:ClassName() == "HTREE"

         RETURN TreeNotify( oCtrl,lParam )
      ELSEIF oCtrl:ClassName() == "HGRID"

         RETURN ListViewNotify( oCtrl,lParam )
      ELSE
         nCode := GetNotifyCode( lParam )
         // writelog("Code: "+str(nCode))
         IF nCode == EN_PROTECTED

            RETURN 1
         ELSEIF oWnd:aNotify != Nil .AND. ;
               ( iItem := Ascan( oWnd:aNotify, {|a|a[1]==nCode.and.a[2]==wParam} ) ) > 0
            IF ( res := Eval( oWnd:aNotify[ iItem,3 ],oWnd,wParam ) ) != Nil

               RETURN res
            ENDIF
         ENDIF
      ENDIF
   ENDIF

   RETURN 0

STATIC FUNCTION onDestroy( oWnd )

   oWnd:End()

   RETURN 0

STATIC FUNCTION onCtlColor( oWnd,wParam,lParam )

   LOCAL oCtrl  := oWnd:FindControl(,lParam)

   IF oCtrl != Nil
      IF oCtrl:tcolor != Nil
         SetTextColor( wParam, oCtrl:tcolor )
      ENDIF
      IF oCtrl:bcolor != Nil
         SetBkColor( wParam, oCtrl:bcolor )

         RETURN oCtrl:brush:handle
      ENDIF
   ENDIF

   RETURN -1

STATIC FUNCTION onDrawItem( oWnd,wParam,lParam )

   LOCAL oCtrl

   IF wParam != 0 .AND. ( oCtrl := oWnd:FindControl( wParam ) ) != Nil .AND. ;
         oCtrl:bPaint != Nil
      Eval( oCtrl:bPaint, oCtrl, lParam )

      RETURN 1
   ENDIF

   RETURN 0

STATIC FUNCTION onCommand( oWnd,wParam )

   LOCAL iItem, iParHigh := HiWord( wParam ), iParLow := LoWord( wParam )

   IF oWnd:aEvents != Nil .AND. ;
         ( iItem := Ascan( oWnd:aEvents, {|a|a[1]==iParHigh.and.a[2]==iParLow} ) ) > 0
      Eval( oWnd:aEvents[ iItem,3 ],oWnd,iParLow )
   ENDIF

   RETURN 1

STATIC FUNCTION onSize( oWnd,wParam,lParam )

   LOCAL aControls := oWnd:aControls, nControls := Len( aControls )
   LOCAL oItem, iCont

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

   RETURN 0

FUNCTION onTrackScroll( oWnd,wParam,lParam )

   LOCAL oCtrl := oWnd:FindControl( , lParam ), msg

   IF oCtrl != Nil
      msg := LoWord (wParam)
      IF msg == TB_ENDTRACK
         IF ISBLOCK( oCtrl:bChange )
            Eval( oCtrl:bChange,oCtrl )

            RETURN 0
         ENDIF
      ELSEIF msg == TB_THUMBTRACK .OR. msg == TB_PAGEUP .OR. msg == TB_PAGEDOWN
         IF ISBLOCK( oCtrl:bThumbDrag )
            Eval( oCtrl:bThumbDrag,oCtrl )

            RETURN 0
         ENDIF
      ENDIF
   ENDIF

   RETURN 0

