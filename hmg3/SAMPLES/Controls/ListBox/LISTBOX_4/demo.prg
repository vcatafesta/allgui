/*
* HMG Hello World Demo
* (c) 2002-2004 Roberto Lopez at <http://hmgforum.com>
* Enhanced by Pablo César on May 3rd, 2014
*/

#include "hmg.ch"

FUNCTION Main

   DEFINE WINDOW Win1 ;
         AT 240,320 ;
         WIDTH 400 ;
         HEIGHT 280 ;
         TITLE 'ListBox Multiselect looks like ComboBox' ;
         MAIN

      DEFINE LISTBOX LIST1
         ROW   10
         COL   10
         WIDTH   100
         HEIGHT   22
         VALUE 0
         ITEMS   { 'Item 01','Item 02','Item 03','Item 04','Item 05','Item 06','Item 07','Item 08','Item 09','Item 10' }
         DISPLAYEDIT .T.
         ONCHANGE ShowSelected(This.Value)
         ONGOTFOCUS  MoreHeight()
         ONLOSTFOCUS LessHeight()
         MULTISELECT .T.
         TABSTOP .F.
      END LISTBOX

      DEFINE BUTTON BUTTON1
         ROW   10
         COL   150
         CAPTION   'Delete Items 8,9,10'
         ACTION   DeleteTest()
         WIDTH   180
      END BUTTON

      DEFINE BUTTON BUTTON2
         ROW   50
         COL   150
         CAPTION   'Delete all Items and Add'
         ACTION   DelAddTest()
         WIDTH   180
      END BUTTON

      DEFINE BUTTON BUTTON3
         ROW   90
         COL   150
         CAPTION   'Show Items selected'
         ACTION   GetMultiValue(GetProperty("Win1","LIST1","Value"))
         WIDTH   180
      END BUTTON

      DEFINE STATUSBAR FONT "Courier New" SIZE 9
         STATUSITEM ""
      END STATUSBAR
   END WINDOW
   ACTIVATE WINDOW Win1

   RETURN NIL

FUNCTION MoreHeight()

   SetProperty("Win1","LIST1","HEIGHT",140)

   RETURN NIL

FUNCTION LessHeight()

   SetProperty("Win1","LIST1","HEIGHT",22);DoEvents()

   RETURN NIL

FUNCTION DeleteTest

   Win1.List1.DeleteItem(10)
   Win1.List1.DeleteItem(9)
   Win1.List1.DeleteItem(8)

   RETURN NIL

FUNCTION DelAddTest()

   LOCAL i, aNumbers := {'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten' }

   DoMethod ( "Win1", "List1", 'DeleteAllItems' )
   FOR i=1 To 10
      DoMethod ( "Win1", "List1", 'AddItem', aNumbers[i] )
   NEXT

   RETURN NIL

FUNCTION GetMultiValue(aValue)

   LOCAL i, cTxt := "", nLen := Len(aValue)

   FOR i := 1 to nLen
      cTxt := cTxt + PadR( AllTrim( hb_ValToStr( GetProperty( "Win1", "LIST1", "Item", aValue[i] ) ) ), 25 ) + CRLF
   NEXT i

   IF Len(aValue) == 0
      MsgInfo('No Selection')
   ELSE
      MsgInfo(cTxt,"Item"+If(nLen>1,"s","")+" selected")
   ENDIF

   RETURN NIL

FUNCTION ShowSelected(aValue)

   LOCAL nLen := Len(aValue)

   IF nLen > 0
      Setproperty("Win1","StatusBar","Item",1,PadC(AllTrim(Str(nLen))+" Item"+If(nLen>1,"s","")+" selected",58))
   ENDIF

   RETURN NIL

