/*
*$Id: hcombo.prg 2012 2013-03-07 09:03:56Z alkresin $
* HWGUI - Harbour Linux (GTK) GUI library source code:
* HComboBox class
* Copyright 2004 Alexander S.Kresin <alex@belacy.belgorod.su>
* www - http://kresin.belgorod.su
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"

#define CB_ERR              (-1)
#ifndef CBN_SELCHANGE
#define CBN_SELCHANGE       1
#define CBN_DBLCLK          2
#define CBN_SETFOCUS        3
#define CBN_KILLFOCUS       4
#define CBN_EDITCHANGE      5
#define CBN_EDITUPDATE      6
#define CBN_DROPDOWN        7
#define CBN_CLOSEUP         8
#define CBN_SELENDOK        9
#define CBN_SELENDCANCEL    10
#endif

CLASS HComboBox INHERIT HControl

CLASS VAR winclass   INIT "COMBOBOX"

   DATA  aItems
   DATA  bSetGet
   DATA  value    INIT 1
   DATA  bChangeSel
   DATA  lText    INIT .F.
   DATA  lEdit    INIT .F.
   DATA  hEdit

   METHOD New( oWndParent,nId,vari,bSetGet,nStyle,nLeft,nTop,nWidth,nHeight, ;
      aItems,oFont,bInit,bSize,bPaint,bChange,cToolt,lEdit,lText,bGFocus,tcolor,bcolor )

   METHOD Activate()

   METHOD onEvent( msg, wParam, lParam )

   METHOD Init( aCombo, nCurrent )

   METHOD Refresh()

   METHOD Setitem( nPos )

   METHOD End()

   ENDCLASS

METHOD New( oWndParent,nId,vari,bSetGet,nStyle,nLeft,nTop,nWidth,nHeight,aItems,oFont, ;
      bInit,bSize,bPaint,bChange,cToolt,lEdit,lText,bGFocus,tcolor,bcolor ) CLASS HComboBox

   IF lEdit == Nil; lEdit := .f.; endif
   IF lText == Nil; lText := .f.; endif

   nStyle := Hwg_BitOr( Iif( nStyle==Nil,0,nStyle ),Iif( lEdit,CBS_DROPDOWN,CBS_DROPDOWNLIST )+WS_TABSTOP )
   ::Super:New( oWndParent,nId,nStyle,nLeft,nTop,nWidth,nHeight,oFont,bInit, bSize,bPaint,ctoolt,tcolor,bcolor )

   ::lEdit := lEdit
   ::lText := lText

   IF lEdit
      ::lText := .t.
   ENDIF

   IF ::lText
      ::value := Iif( vari==Nil .OR. Valtype(vari)!="C","",vari )
   ELSE
      ::value := Iif( vari==Nil .OR. Valtype(vari)!="N",1,vari )
   ENDIF

   ::bSetGet := bSetGet
   ::aItems  := aItems

   ::Activate()
   /*
   IF bSetGet != Nil
   ::bChangeSel := bChange
   ::bGetFocus  := bGFocus
   ::oParent:AddEvent( CBN_SETFOCUS,::id,{|o,id|__When(o:FindControl(id))} )
   ::oParent:AddEvent( CBN_SELCHANGE,::id,{|o,id|__Valid(o:FindControl(id))} )
   ELSEIF bChange != Nil
   ::oParent:AddEvent( CBN_SELCHANGE,::id,bChange )
   ENDIF

   IF bGFocus != Nil .AND. bSetGet == Nil
   ::oParent:AddEvent( CBN_SETFOCUS,::id,{|o,id|__When(o:FindControl(id))} )
   ENDIF
   */
   ::bGetFocus := bGFocus
   ::bLostFocus := bChange

   hwg_SetEvent( ::hEdit,"focus_in_event",EN_SETFOCUS,0,0 )
   hwg_SetEvent( ::hEdit,"focus_out_event",EN_KILLFOCUS,0,0 )

   RETURN Self

METHOD Activate CLASS HComboBox

   IF !Empty(::oParent:handle )
      ::handle := hwg_Createcombo( ::oParent:handle, ::id, ;
         ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight )
      ::hEdit := hwg_ComboGetEdit( ::handle )
      ::Init()
      hwg_Setwindowobject( ::hEdit,Self )
   ENDIF

   RETURN NIL

METHOD onEvent( msg, wParam, lParam ) CLASS HComboBox

   IF msg == EN_SETFOCUS
      IF ::bSetGet == Nil
         IF ::bGetFocus != Nil
            Eval( ::bGetFocus, hwg_Edit_GetText( ::hEdit ), Self )
         ENDIF
      ELSE
         __When( Self )
      ENDIF
   ELSEIF msg == EN_KILLFOCUS
      IF ::bSetGet == Nil
         IF ::bLostFocus != Nil
            Eval( ::bLostFocus, hwg_Edit_GetText( ::hEdit ), Self )
         ENDIF
      ELSE
         __Valid( Self )
      ENDIF

   ENDIF

   RETURN 0

METHOD Init() CLASS HComboBox

   LOCAL i

   IF !::lInit
      ::Super:Init()
      IF ::aItems != Nil
         hwg_ComboSetArray( ::handle, ::aItems )
         IF ::value == Nil
            IF ::lText
               ::value := ::aItems[1]
            ELSE
               ::value := 1
            ENDIF
         ENDIF
         IF ::lText
            hwg_edit_Settext( ::hEdit, ::value )
         ELSE
            hwg_edit_Settext( ::hEdit, ::aItems[::value] )
         ENDIF
      ENDIF
   ENDIF

   RETURN NIL

METHOD Refresh() CLASS HComboBox

   LOCAL vari, i

   IF ::bSetGet != Nil
      vari := Eval( ::bSetGet,,Self )
      IF ::lText
         ::value := Iif( vari==Nil .OR. Valtype(vari)!="C","",vari )
      ELSE
         ::value := Iif( vari==Nil .OR. Valtype(vari)!="N",1,vari )
      ENDIF
   ENDIF

   hwg_ComboSetArray( ::handle, ::aItems )

   IF ::lText
      hwg_edit_Settext( ::hEdit, ::value )
   ELSE
      hwg_edit_Settext( ::hEdit, ::aItems[::value] )
   ENDIF

   RETURN NIL

METHOD SetItem( nPos ) CLASS HComboBox

   IF ::lText
      ::value := ::aItems[nPos]
   ELSE
      ::value := nPos
   ENDIF

   hwg_edit_Settext( ::hEdit, ::aItems[nPos] )

   IF ::bSetGet != Nil
      Eval( ::bSetGet, ::value, self )
   ENDIF

   IF ::bChangeSel != Nil
      Eval( ::bChangeSel, ::value, Self )
   ENDIF

   RETURN NIL

METHOD End() CLASS HComboBox

   hwg_ReleaseObject( ::hEdit )
   ::Super:End()

   RETURN NIL

STATIC FUNCTION __Valid( oCtrl )

   LOCAL vari := hwg_edit_Gettext( oCtrl:hEdit )

   IF oCtrl:lText
      oCtrl:value := vari
   ELSE
      oCtrl:value := Ascan( oCtrl:aItems,vari )
   ENDIF

   IF oCtrl:bSetGet != Nil
      Eval( oCtrl:bSetGet, oCtrl:value, oCtrl )
   ENDIF
   IF oCtrl:bChangeSel != Nil
      Eval( oCtrl:bChangeSel, oCtrl:value, oCtrl )
   ENDIF

   RETURN .T.

STATIC FUNCTION __When( oCtrl )

   LOCAL res

   // oCtrl:Refresh()

   IF oCtrl:bGetFocus != Nil
      res := Eval( oCtrl:bGetFocus, Eval( oCtrl:bSetGet,, oCtrl ), oCtrl )
      IF !res
         hwg_GetSkip( oCtrl:oParent,oCtrl:handle,1 )
      ENDIF

      RETURN res
   ENDIF

   RETURN .T.
