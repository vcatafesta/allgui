/*
HMG ListBox Demo
(c) 2010 Roberto Lopez
*/

#include "minigui.ch"

FUNCTION Main

   DEFINE WINDOW Win1;
         at 10,10;
         Width 400;
         Height 400;
         Title "HMG ListBox Demo";
         WindowType MAIN ;
         On Init loadlist(3, .f., .f.)

      DEFINE LABEL Label1
         Row 10
         Col 10
         Value 'This is for status!'
         AutoSize .t.
      END LABEL

      DEFINE BUTTON Button1
         Row 240
         Col 10
         Caption "Add Item"
         OnClick {|| Win1.List1.Additem("Added Item "+hb_ntos(Win1.List1.Itemcount + 1)), ;
            Win1.List1.Value := iif(islistmultiselect('List1','Win1'), {Win1.List1.Itemcount}, Win1.List1.Itemcount)}
      END BUTTON

      DEFINE BUTTON Button2
         Row 240
         Col 110
         Caption "Delete Item"
         OnClick {|| Win1.List1.Deleteitem(1)}
      END BUTTON

      DEFINE BUTTON Button3
         Row 240
         Col 210
         Caption "Set Value"
         Width 120
         OnClick Win1.List1.Value := iif(islistmultiselect('List1','Win1'), {1,3,5}, 2)
      END BUTTON

      DEFINE BUTTON Button4
         Row 270
         Col 10
         Caption "Get Value"
         OnClick ShowValues()
      END BUTTON

      DEFINE BUTTON Button5
         Row 270
         Col 110
         Caption "Get ItemCount"
         OnClick {|| MsgInfo(str(Win1.List1.ItemCount))}
      END BUTTON

      DEFINE BUTTON Button6
         Row 270
         Col 210
         Width 120
         Caption "Delete All Items"
         OnClick {|| Win1.List1.DeleteAllItems()}
      END BUTTON

      DEFINE BUTTON Button7
         Row 300
         Col 10
         Caption "Set Items"
         OnClick {|| SetItems({"Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"})}
      END BUTTON

      DEFINE BUTTON Button8
         Row 300
         Col 110
         Caption "Sort Items"
         OnClick {|| loadlist( win1.list1.value, islistmultiselect('List1','Win1'), .t.)}
      END BUTTON

      DEFINE BUTTON Button9
         Row 300
         Col 210
         Width 120
         Caption "Toggle Multiselect"
         OnClick {|| loadlist( if(isarray(win1.list1.value),1,{1}), !islistmultiselect('List1','Win1'), .f.)}
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
      Row 40
      Col 10
      Parent Win1
      Items {}
      onChange {|| Win1.Label1.Value := iif(isarray(win1.list1.value),"MultiSelect List","Current Value is "+hb_ntos(win1.list1.value))}
      onDblClick {|| MsgInfo("Double Click Action!")}
      multiselect lmultiselect
      SORT lsort
   End ListBox

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
