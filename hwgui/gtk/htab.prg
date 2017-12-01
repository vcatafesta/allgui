/*
*$Id: htab.prg 2012 2013-03-07 09:03:56Z alkresin $
* HWGUI - Harbour Linux (GTK) GUI library source code:
* HTab class
* Copyright 2005 Alexander S.Kresin <alex@belacy.belgorod.su>
* www - http://kresin.belgorod.su
*/

#include "hwgui.ch"
#include "hbclass.ch"

#ifndef TCM_SETCURSEL
#define TCM_SETCURSEL           4876     // (TCM_FIRST + 12)
#define TCM_SETCURFOCUS         4912     // (TCM_FIRST + 48)
#define TCM_GETCURFOCUS         4911     // (TCM_FIRST + 47)
#define TCM_GETITEMCOUNT        4868     // (TCM_FIRST + 4)
#define TCM_SETIMAGELIST        4867
#endif

CLASS HTab INHERIT HControl

CLASS VAR winclass   INIT "SysTabControl32"

   DATA  aTabs
   DATA  aPages  INIT {}
   DATA  bChange, bChange2
   DATA  oTemp
   DATA  bAction

   METHOD New( oWndParent,nId,nStyle,nLeft,nTop,nWidth,nHeight, ;
      oFont,bInit,bSize,bPaint,aTabs,bChange,aImages,lResour,nBC,;
      bClick, bGetFocus, bLostFocus )

   METHOD Activate()

   METHOD Init()

   METHOD SetTab( n )

   METHOD StartPage( cname )

   METHOD EndPage()

   METHOD ChangePage( nPage )

   METHOD HidePage( nPage )

   METHOD ShowPage( nPage )

   METHOD GetActivePage( nFirst,nEnd )

   HIDDEN:
   DATA  nActive  INIT 0         // Active Page

   ENDCLASS

METHOD New( oWndParent,nId,nStyle,nLeft,nTop,nWidth,nHeight, ;
      oFont,bInit,bSize,bPaint,aTabs,bChange,aImages,lResour,nBC,bClick, bGetFocus, bLostFocus  ) CLASS HTab
   LOCAL i, aBmpSize

   ::Super:New( oWndParent,nId,nStyle,nLeft,nTop,nWidth,nHeight,oFont,bInit, ;
      bSize,bPaint )

   ::title   := ""
   ::oFont   := Iif( oFont==Nil, ::oParent:oFont, oFont )
   ::aTabs   := Iif( aTabs==Nil,{},aTabs )
   ::bChange := bChange

   ::bChange2 := bChange

   ::bGetFocus :=IIf( bGetFocus==Nil, Nil, bGetFocus)
   ::bLostFocus:=IIf( bLostFocus==Nil, Nil, bLostFocus)
   ::bAction   :=IIf( bClick==Nil, Nil, bClick)

   ::Activate()

   RETURN Self

METHOD Activate CLASS HTab

   IF !Empty(::oParent:handle )
      ::handle := hwg_Createtabcontrol( ::oParent:handle, ::id, ;
         ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight )

      ::Init()
   ENDIF

   RETURN NIL

METHOD Init() CLASS HTab

   LOCAL i, h

   IF !::lInit
      ::Super:Init()
      FOR i := 1 TO Len( ::aTabs )
         h := hwg_Addtab( ::handle, ::aTabs[i] )
         Aadd( ::aPages, { 0,0,.F.,h } )
      NEXT

      hwg_Setwindowobject( ::handle,Self )

      FOR i := 2 TO Len( ::aPages )
         ::HidePage( i )
      NEXT
   ENDIF

   RETURN NIL

METHOD SetTab( n ) CLASS HTab

   hwg_Sendmessage( ::handle, TCM_SETCURFOCUS, n-1, 0 )

   RETURN NIL

METHOD StartPage( cname ) CLASS HTab

   LOCAL i := Iif( cName==Nil, Len(::aPages)+1, Ascan( ::aTabs,cname ) )
   LOCAL lNew := ( i == 0 )

   ::oTemp := ::oDefaultParent
   ::oDefaultParent := Self
   IF lNew
      Aadd( ::aTabs,cname )
      i := Len( ::aTabs )
   ENDIF
   DO WHILE Len( ::aPages ) < i
      Aadd( ::aPages, { Len( ::aControls ),0,lNew,0 } )
   ENDDO
   ::nActive := i
   ::aPages[ i,4 ] := hwg_Addtab( ::handle,::aTabs[i] )

   RETURN NIL

METHOD EndPage() CLASS HTab

   ::aPages[ ::nActive,2 ] := Len( ::aControls ) - ::aPages[ ::nActive,1 ]
   IF ::nActive > 1 .AND. ::handle != Nil .AND. !Empty( ::handle )
      ::HidePage( ::nActive )
   ENDIF
   ::nActive := 1

   ::oDefaultParent := ::oTemp
   ::oTemp := Nil

   ::bChange = {|o,n|o:ChangePage(n)}

   RETURN NIL

METHOD ChangePage( nPage ) CLASS HTab

   IF !Empty( ::aPages )

      ::HidePage( ::nActive )

      ::nActive := nPage

      ::ShowPage( ::nActive )

   ENDIF

   IF ::bChange2 != Nil
      Eval( ::bChange2,Self,nPage )
   ENDIF

   RETURN NIL

METHOD HidePage( nPage ) CLASS HTab

   LOCAL i, nFirst, nEnd

   nFirst := ::aPages[ nPage,1 ] + 1
   nEnd   := ::aPages[ nPage,1 ] + ::aPages[ nPage,2 ]
   FOR i := nFirst TO nEnd
      ::aControls[i]:Hide()
   NEXT

   RETURN NIL

METHOD ShowPage( nPage ) CLASS HTab

   LOCAL i, nFirst, nEnd

   nFirst := ::aPages[ nPage,1 ] + 1
   nEnd   := ::aPages[ nPage,1 ] + ::aPages[ nPage,2 ]
   FOR i := nFirst TO nEnd
      ::aControls[i]:Show()
   NEXT
   FOR i := nFirst TO nEnd
      IF __ObjHasMsg( ::aControls[i],"BSETGET" ) .AND. ::aControls[i]:bSetGet != Nil
         hwg_Setfocus( ::aControls[i]:handle )
         EXIT
      ENDIF
   NEXT

   RETURN NIL

METHOD GetActivePage( nFirst,nEnd ) CLASS HTab

   IF !Empty( ::aPages )
      nFirst := ::aPages[ ::nActive,1 ] + 1
      nEnd   := ::aPages[ ::nActive,1 ] + ::aPages[ ::nActive,2 ]
   ELSE
      nFirst := 1
      nEnd   := Len( ::aControls )
   ENDIF

   RETURN ::nActive
