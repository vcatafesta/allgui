/*
MINIGUI - Harbour Win32 GUI library Demo

Copyright 2002-10 Roberto Lopez <harbourminigui@gmail.com>
http://harbourminigui.googlepages.com

Author: S.Rathinagiri <srgiri@dataone.in>

Revised by Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

MEMVAR _aItems, _nSelected, lAnyWhereSearch

FUNCTION Main

   LOCAL aCountries := HB_ATOKENS( MEMOREAD( "Countries.lst" ), CRLF )

   SET font to _GetSysFont() , 10

   DEFINE WINDOW sample at 0,0 width 640 height 480 title "HMG Achoice Demo" main
      DEFINE LABEL label1
         ROW 10
         COL 20
         WIDTH 100
         VALUE "Name"
      END LABEL
      DEFINE TEXTBOX textbox1
         ROW 10
         COL 110
         WIDTH 180
         ON ENTER sample.textbox2.setfocus
      END TEXTBOX
      DEFINE LABEL label2
         ROW 40
         COL 20
         WIDTH 100
         VALUE "Country"
      END LABEL
      define btntextbox textbox2
      ROW 40
      COL 110
      WIDTH 180
      ACTION iif(empty(doachoice(aCountries)),nil,sample.textbox3.setfocus)
      ongotfocus sample.label4.visible:=.t.
      onlostfocus sample.label4.visible:=.f.
      ON ENTER iif(empty(sample.textbox2.value),doachoice(aCountries),sample.textbox3.setfocus)
   END btntextbox
   DEFINE LABEL label3
      ROW 70
      COL 20
      WIDTH 100
      VALUE "City"
   END LABEL
   DEFINE TEXTBOX textbox3
      ROW 70
      COL 110
      WIDTH 180
      ON ENTER sample.textbox1.setfocus
   END TEXTBOX
   DEFINE LABEL label4
      ROW 100
      COL 110
      WIDTH 140
      VALUE "F2 - select country"
      FONTBOLD .t.
      visible .f.
   END LABEL
   on key F2 action iif(thiswindow.focusedcontrol=='textbox2',doachoice(aCountries),nil)
END WINDOW
sample.center
sample.activate

RETURN NIL

FUNCTION doachoice(aItems)

   LOCAL nTop := 10
   LOCAL nLeft := 300
   LOCAL nDefault := 1
   LOCAL nSelected
   LOCAL control:=thiswindow.focusedcontrol
   LOCAL value:=getproperty(thiswindow.name,control,'value')

   IF len(alltrim(value)) > 0
      nDefault := ascan(aItems,value)
   ENDIF

   nSelected := HMG_AChoice( nTop, nLeft, , , aItems, nDefault )

   setproperty(thiswindow.name,control,'value',iif(nSelected > 0,aItems[nSelected],''))

   RETURN nSelected

FUNCTION HMG_Achoice(nTop,nLeft,nBottom,nRight,aList,nDefault,lAnyWhere)

   LOCAL nRow := thiswindow.row + GetTitleHeight()
   LOCAL nCol := thiswindow.col
   LOCAL nWindowWidth := thiswindow.width
   LOCAL nWindowHeight := thiswindow.height
   LOCAL nWidth
   LOCAL nHeight

   PRIVATE _aItems := aclone(aList)
   PRIVATE _nSelected := 0
   PRIVATE lAnyWhereSearch

   DEFAULT lAnyWhere := .f.
   DEFAULT nDefault := 0
   DEFAULT nBottom := thiswindow.height - GetTitleHeight() - 10
   DEFAULT nRight := thiswindow.width - 2*GetBorderWidth() - 10
   lAnyWhereSearch := lAnyWhere
   nWidth := iif(nRight < nWindowWidth,  nRight - nLeft,nWindowWidth - nLeft - 2*GetBorderWidth() - 10)
   nHeight := iif(nBottom < nWindowHeight, nBottom - nTop,nWindowHeight - nTop - GetTitleHeight() - 10)
   IF iswindowdefined(_HMG_aChoice)
      RELEASE WINDOW _HMG_aChoice
   ENDIF

   DEFINE WINDOW _HMG_aChoice AT nRow+nTop, nCol+nLeft ;
         WIDTH  nWidth  ;
         HEIGHT nHeight ;
         TITLE '' ;
         MODAL ;
         NOCAPTION ;
         NOSIZE

      DEFINE TEXTBOX _edit
         ROW 5
         COL 5
         WIDTH nWidth - 2*GetBorderWidth()
         ON CHANGE     _aChoiceTextChanged( lAnyWhere )
         ON ENTER      _aChoiceSelected()
         ON GOTFOCUS   _achoicelistchanged()
      END TEXTBOX
      DEFINE LISTBOX _list
         ROW 30
         COL 5
         WIDTH nWidth - 2*GetBorderWidth()
         HEIGHT nHeight - 50
         items aList
         ON CHANGE _achoicelistchanged()
         on dblclick _aChoiceSelected()
      END listbox
   END WINDOW

   ON KEY UP     OF _HMG_achoice ACTION _aChoiceDoUpKey()
   ON KEY DOWN   OF _HMG_achoice ACTION _aChoiceDoDownKey()
   ON KEY PRIOR  OF _HMG_achoice ACTION _aChoicePgUpKey()
   ON KEY NEXT   OF _HMG_achoice ACTION _aChoicePgDownKey()
   ON KEY ESCAPE OF _HMG_achoice ACTION _aChoiceDoEscKey()

   IF len(_aItems) > 0
      IF nDefault > 0
         _HMG_aChoice._list.value := nDefault
         _HMG_aChoice._edit.value := _aItems[nDefault]
      ENDIF
   ENDIF
   _HMG_Achoice.activate

   RETURN _nSelected

   STATIC PROC _aChoiceTextChanged( lAnyWhere )
      LOCAL cCurValue := _HMG_aChoice._edit.value
      LOCAL nItemNo
      LOCAL lFound := .f.

      FOR nItemNo := 1 to len(_aitems)
         IF lAnyWhere
            IF at(upper(cCurValue),upper(_aItems[nItemNo])) > 0
               _HMG_aChoice._list.value := nItemNo
               lFound := .t.
               EXIT
            ENDIF
         ELSE
            IF upper(left(_aitems[nItemNo],len(cCurValue))) == upper(cCurValue)
               _HMG_aChoice._list.value := nItemNo
               lFound := .t.
               EXIT
            ENDIF
         ENDIF
      NEXT nItemNo
      IF .not. lFound
         _HMG_aChoice._list.value := 0
      ENDIF

      RETURN

FUNCTION _aChoiceselected

   IF _HMG_aChoice._List.value > 0
      _nSelected := _HMG_aChoice._list.value
   ELSE
      _nSelected := 0
   ENDIF
   RELEASE WINDOW _HMG_aChoice

   RETURN NIL

FUNCTION _aChoiceDoUpKey()

   IF _HMG_aChoice._List.value > 1
      _HMG_aChoice._List.value := _HMG_aChoice._List.value - 1
      _HMG_aChoice._edit.value := _HMG_aChoice._List.item(_HMG_aChoice._List.value)
      textboxeditsetsel("_HMG_aChoice","_Edit",0,-1)
   ENDIF

   RETURN NIL

FUNCTION _aChoiceDoDownKey()

   IF _HMG_aChoice._List.value < _HMG_aChoice._List.ItemCount
      _HMG_aChoice._List.value := _HMG_aChoice._List.value + 1
      _HMG_aChoice._edit.value := _HMG_aChoice._List.item(_HMG_aChoice._List.value)
      textboxeditsetsel("_HMG_aChoice","_Edit",0,-1)
   ENDIF

   RETURN NIL

FUNCTION _aChoicePgUpKey()

   IF _HMG_aChoice._List.value > 1
      IF _HMG_aChoice._List.value - 23 < 1
         _HMG_aChoice._List.value := 1
      ELSE
         _HMG_aChoice._List.value := _HMG_aChoice._List.value - 23
      ENDIF
      _HMG_aChoice._edit.value := _HMG_aChoice._List.item(_HMG_aChoice._List.value)
      textboxeditsetsel("_HMG_aChoice","_Edit",0,-1)
   ENDIF

   RETURN NIL

FUNCTION _aChoicePgDownKey()

   IF _HMG_aChoice._List.value < _HMG_aChoice._List.ItemCount
      IF _HMG_aChoice._List.value + 23 > _HMG_aChoice._List.ItemCount
         _HMG_aChoice._List.value := _HMG_aChoice._List.ItemCount
      ELSE
         _HMG_aChoice._List.value := _HMG_aChoice._List.value + 23
      ENDIF
      _HMG_aChoice._edit.value := _HMG_aChoice._List.item(_HMG_aChoice._List.value)
      textboxeditsetsel("_HMG_aChoice","_Edit",0,-1)
   ENDIF

   RETURN NIL

FUNCTION _aChoiceDoEscKey()

   _nSelected := 0
   RELEASE WINDOW _HMG_aChoice

   RETURN NIL

FUNCTION _achoicelistchanged

   IF upper(this.name) == "_EDIT" .and. upper(thiswindow.name) == "_HMG_ACHOICE" .and. .not. lAnyWhereSearch
      _HMG_aChoice._edit.value := _HMG_aChoice._List.item(_HMG_aChoice._List.value)
      textboxeditsetsel("_HMG_aChoice","_Edit",0,-1)
   ENDIF

   RETURN NIL

#define EM_SETSEL      177

FUNCTION textboxeditsetsel(cParent,cControl,nStart,nEnd)

   LOCAL i := GetControlIndex ( cControl, cParent )

   IF i == 0

      RETURN NIL
   ENDIF

   SendMessage( _HMG_aControlhandles [i], EM_SETSEL, nStart, nEnd )

   RETURN NIL
