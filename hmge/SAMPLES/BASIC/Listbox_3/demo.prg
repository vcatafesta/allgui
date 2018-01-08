/*
HMG ListBox Demo
(c) 2010 Roberto Lopez
*/

#include "minigui.ch"

FUNCTION Main

   DEFINE WINDOW Win1;
         at 10,10;
         WIDTH 400;
         HEIGHT 400;
         TITLE "HMG ListBox Demo";
         WindowType MAIN ;
         ON INIT loadlist(3, .f., .f.)

      DEFINE LABEL Label1
         ROW 10
         COL 10
         VALUE 'This is for status!'
         AUTOSIZE .t.
      END LABEL

      DEFINE BUTTON Button1
         ROW 240
         COL 10
         CAPTION "Add Item"
         ONCLICK {|| Win1.List1.Additem("Added Item "+hb_ntos(Win1.List1.Itemcount + 1)), ;
            Win1.List1.Value := iif(islistmultiselect('List1','Win1'), {Win1.List1.Itemcount}, Win1.List1.Itemcount)}
      END BUTTON

      DEFINE BUTTON Button2
         ROW 240
         COL 110
         CAPTION "Delete Item"
         ONCLICK {|| Win1.List1.Deleteitem(1)}
      END BUTTON

      DEFINE BUTTON Button3
         ROW 240
         COL 210
         CAPTION "Set Value"
         WIDTH 120
         ONCLICK Win1.List1.Value := iif(islistmultiselect('List1','Win1'), {1,3,5}, 2)
      END BUTTON

      DEFINE BUTTON Button4
         ROW 270
         COL 10
         CAPTION "Get Value"
         ONCLICK ShowValues()
      END BUTTON

      DEFINE BUTTON Button5
         ROW 270
         COL 110
         CAPTION "Get ItemCount"
         ONCLICK {|| MsgInfo(str(Win1.List1.ItemCount))}
      END BUTTON

      DEFINE BUTTON Button6
         ROW 270
         COL 210
         WIDTH 120
         CAPTION "Delete All Items"
         ONCLICK {|| Win1.List1.DeleteAllItems()}
      END BUTTON

      DEFINE BUTTON Button7
         ROW 300
         COL 10
         CAPTION "Set Items"
         ONCLICK {|| SetItems({"Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"})}
      END BUTTON

      DEFINE BUTTON Button8
         ROW 300
         COL 110
         CAPTION "Sort Items"
         ONCLICK {|| loadlist( win1.list1.value, islistmultiselect('List1','Win1'), .t.)}
      END BUTTON

      DEFINE BUTTON Button9
         ROW 300
         COL 210
         WIDTH 120
         CAPTION "Toggle Multiselect"
         ONCLICK {|| loadlist( if(isarray(win1.list1.value),1,{1}), !islistmultiselect('List1','Win1'), .f.)}
      END BUTTON

   END WINDOW

   Win1.Center()
   Win1.Activate()

   RETURN NIL

FUNCTION loadlist(value,lmultiselect,lsort)

   LOCAL aItems := {"Item 1","Item 2","Item 3","Item 4","Item 5"}
   LOCAL i

   IF iscontroldefined(List1,Win1)
      IF Win1.List1.ItemCount >= 0
         aItems := {}
         FOR i := 1 to Win1.List1.ItemCount
            aAdd(aItems, Win1.List1.Item(i))
         NEXT i
      ENDIF
      win1.list1.release
      do events
   ENDIF

   DEFINE LISTBOX List1
      ROW 40
      COL 10
      Parent Win1
      ITEMS {}
      ONCHANGE {|| Win1.Label1.Value := iif(isarray(win1.list1.value),"MultiSelect List","Current Value is "+hb_ntos(win1.list1.value))}
      onDblClick {|| MsgInfo("Double Click Action!")}
      multiselect lmultiselect
      SORT lsort
   END ListBox

   win1.list1.SetArray(aItems)
   win1.list1.value := Value

   RETURN NIL

FUNCTION setitems(aNewItems)

   win1.list1.SetArray(aNewItems)

   RETURN NIL

FUNCTION islistmultiselect(control,form)

   RETURN ( "MULTI" $ getcontroltype(control,form) )

FUNCTION showvalues

   LOCAL aValue, i
   LOCAL cStr := ''

   IF islistmultiselect('List1','Win1')
      aValue := win1.list1.value
      cStr := 'Selected Lines are :'
      FOR i := 1 to len(aValue)
         cStr += str(aValue[i])
         IF i < len(aValue)
            cStr += ','
         ENDIF
      NEXT i
      msginfo(cStr,"MultiSelect List")
   ELSE
      msginfo("Selected Line is : "+hb_ntos(win1.list1.value))
   ENDIF

   RETURN NIL
