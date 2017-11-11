/*
* $Id: htool.prg 2034 2013-04-23 08:49:16Z alkresin $
* HWGUI - Harbour Win32 GUI library source code:
* Copyright 2004 Luiz Rafael Culik Guimaraes <culikr@brtrubo.com>
* www - http://sites.uol.com.br/culikr/
*/

#include "windows.ch"
#include "inkey.ch"
#include "hbclass.ch"
#include "guilib.ch"
#include "common.ch"

#define TRANSPARENT 1

CLASS HToolBar INHERIT HControl

   DATA winclass INIT "ToolbarWindow32"
   DATA TEXT, id, nTop, nLeft, nwidth, nheight
CLASSDATA oSelected INIT Nil
   DATA State INIT 0
   DATA ExStyle
   DATA bClick, cTooltip

   DATA lPress INIT .F.
   DATA lFlat
   DATA nOrder
   DATA aItem init {}
   DATA Line

METHOD New( oWndParent,nId,nStyle,nLeft,nTop,nWidth,nHeight,cCaption,oFont,bInit, ;
      bSize,bPaint,ctooltip,tcolor,bcolor,lTransp ,aItem)

METHOD Activate()

METHOD INIT()

METHOD REFRESH()

METHOD AddButton(a,s,d,f,g,h)

METHOD onEvent( msg, wParam, lParam )

METHOD EnableAllButtons()

METHOD DisableAllButtons()

METHOD EnableButtons(n)

METHOD DisableButtons(n)

ENDCLASS

METHOD New( oWndParent,nId,nStyle,nLeft,nTop,nWidth,nHeight,cCaption,oFont,bInit, ;
      bSize,bPaint,ctooltip,tcolor,bcolor,lTransp ,aitem) CLASS hToolBar
   DEFAULT  aItem to {}
   ::Super:New( oWndParent,nId,nStyle,nLeft,nTop,nWidth,nHeight,oFont,bInit, ;
      bSize,bPaint,ctooltip,tcolor,bcolor )

   ::aitem := aItem

   ::Activate()

   RETURN Self

METHOD Activate CLASS hToolBar

   IF !empty(::oParent:handle )

      ::handle := hwg_Createtoolbar(::oParent:handle )
      hwg_Setwindowobject( ::handle,Self )
      ::Init()
   ENDIF

   RETURN NIL

METHOD INIT CLASS hToolBar

   LOCAL n,n1
   LOCAL aTemp
   LOCAL hIm
   LOCAL aButton :={}
   LOCAL aBmpSize
   LOCAL oImage
   LOCAL nPos
   LOCAL aItem

   IF !::lInit
      ::Super:Init()
      FOR n := 1 TO len( ::aItem )

         IF valtype( ::aItem[ n, 1 ] ) == "N"
            IF !empty( ::aItem[ n, 1 ] )
               AAdd( aButton, ::aItem[ n , 1 ])
            ENDIF
         ELSEIF  valtype( ::aItem[ n, 1 ] ) == "C"
            IF ".ico" $ lower(::aItem[ n, 1 ]) //if ".ico" in lower(::aItem[ n, 1 ])
               oImage:=hIcon():AddFile( ::aItem[ n, 1 ] )
            ELSE
               oImage:=hBitmap():AddFile( ::aItem[ n, 1 ] )
            ENDIF
            IF valtype(oImage) =="O"
               aadd(aButton,Oimage:handle)
               ::aItem[ n, 1 ] := Oimage:handle
            ENDIF
         ENDIF

      NEXT n

      IF len( ::aItem ) >0
         FOR EACH aItem in ::aItem

            IF aItem[4] == TBSTYLE_BUTTON

               aItem[11] := hwg_Createtoolbarbutton(::handle,aItem[1],aItem[6],.f.)
               #ifdef __XHARBOUR__
               aItem[2] := hb_enumindex()
               #else
               aItem[2] := aItem:__enumIndex()
               #endif
               hwg_Toolbar_setaction(aItem[11],aItem[7])
               IF !empty(aItem[8])
                  hwg_Addtooltip(::handle, aItem[11],aItem[8])
               ENDIF
            ELSEIF aitem[4] == TBSTYLE_SEP
               aItem[11] := hwg_Createtoolbarbutton(::handle,,,.t.)
               #ifdef __XHARBOUR__
               aItem[2] := hb_enumindex()
               #else
               aItem[2] := aItem:__enumIndex()
               #endif
            ENDIF
         NEXT
      ENDIF

   ENDIF

   RETURN NIL

METHOD AddButton(nBitIp,nId,bState,bStyle,cText,bClick,c,aMenu) CLASS hToolBar

   LOCAL hMenu := Nil

   DEFAULT nBitIp to -1
   DEFAULT bstate to TBSTATE_ENABLED
   DEFAULT bstyle to 0x0000
   DEFAULT c to ""
   DEFAULT ctext to ""
   AAdd( ::aItem ,{ nBitIp, nId, bState, bStyle, 0, cText, bClick, c, aMenu, hMenu ,0} )

   RETURN Self

METHOD onEvent( msg, wParam, lParam )  CLASS HToolbar

   LOCAL nPos

   IF msg == WM_LBUTTONUP
      nPos := ascan(::aItem,{|x| x[2] == wParam})
      IF nPos>0
         IF ::aItem[nPos,7] != Nil
            Eval( ::aItem[nPos,7] ,Self )
         ENDIF
      ENDIF
   ENDIF

   RETURN  NIL

METHOD REFRESH() class htoolbar

   IF ::lInit
      ::lInit := .f.
   ENDIF
   ::init()

   RETURN NIL

METHOD EnableAllButtons() class htoolbar

   LOCAL xItem

   FOR EACH xItem in ::aItem
      hwg_Enablewindow( xItem[ 11 ], .T. )
   NEXT

   RETURN Self

METHOD DisableAllButtons() class htoolbar

   LOCAL xItem

   FOR EACH xItem in ::aItem
      hwg_Enablewindow( xItem[ 11 ], .F. )
   NEXT

   RETURN Self

METHOD EnableButtons(n) class htoolbar

   hwg_Enablewindow( ::aItem[n, 11 ], .T. )

   RETURN Self

METHOD DisableButtons(n) class htoolbar

   hwg_Enablewindow( ::aItem[n, 11 ], .T. )

   RETURN Self

