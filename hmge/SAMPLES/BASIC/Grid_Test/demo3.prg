#include "minigui.ch"

PROCEDURE Main

   LOCAL nId

   DEFINE WINDOW m at 0,0 width 600 height 400 title 'Grid Demo' main

      DEFINE GRID g
         ROW 10
         COL 10
         WIDTH 472
         HEIGHT 200
         headers {"Name","City","Amount"}
         widths {200,150,100}
         allowedit .t.
         COLUMNCONTROLS { { 'TEXTBOX','CHARACTER' } , { 'COMBOBOX',{ 'CHENNAI','DELHI','KOLKATTA' } } , { 'TEXTBOX','NUMERIC',"999999.99" } }
         items { {"Person 1", 1, 1000} , {"Person 2", 3, 2000} }
         justify {0,0,1}
      END GRID

      DEFINE BUTTON b1
         ROW 230
         COL 10
         WIDTH 240
         caption "Add a new item in inplaced combobox"
         action AddGridEditComboItem( "g", "m", 2, Upper( InputBox("Enter a new city", "Add city", "MUMBAI") ) )
      END BUTTON

      DEFINE BUTTON b2
         ROW 260
         COL 10
         WIDTH 240
         caption "Add a new item in grid"
         action ( nId := m.g.ItemCount, m.g.AddItem( {"Person "+hb_ntos(++nId), Random(3), nId*1000} ) )
      END BUTTON

      ON KEY ESCAPE ACTION thiswindow.release()

   END WINDOW
   m.center
   m.activate

   RETURN

FUNCTION AddGridEditComboItem ( cGridName, cWindowName, nColIndex, cNewItem )

   LOCAL i := GetControlIndex ( cGridName, cWindowName )
   LOCAL aEditcontrols := _HMG_aControlMiscData1 [i] [13]

   IF ascan(aEditControls [nColIndex] [2], cNewItem) == 0
      aAdd ( aEditControls [nColIndex] [2], cNewItem )
   ENDIF
   _HMG_aControlMiscData1 [i] [13] := aEditControls

   RETURN NIL
