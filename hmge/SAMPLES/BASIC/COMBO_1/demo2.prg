/*
* MiniGUI ComboBox Demo
*/

#include "minigui.ch"

MEMVAR aitems

FUNCTION Main

   PRIVATE aItems := { '1 | Uno' , '2 | Dos' , '3 | tres' }

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH 400 ;
         HEIGHT 200 ;
         TITLE 'ComboBox Demo' ;
         MAIN

      @ 10,10 COMBOBOX Control_1 ;
         WIDTH 130 ;
         ITEMS {} ;
         LOWERCASE ;
         FONT 'Courier New' SIZE 12

      DEFINE BUTTON Control_2
         ROW   10
         COL   150
         WIDTH   140
         CAPTION   'Update Combo'
         ACTION UpdateCombo( 'Control_1', 'Form_1' )
      END BUTTON

      DEFINE BUTTON Control_3
         ROW   40
         COL   150
         WIDTH   140
         CAPTION   'Update Combo 2'
         ACTION UpdateCombo2( 'Control_1', 'Form_1' )
      END BUTTON

   END WINDOW

   Form_1.Control_1.SetArray( aItems )
   Form_1.Control_1.Value := 1

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

   RETURN NIL

   // Private array

FUNCTION UpdateCombo( Control, Parent )

   aadd(aitems, '4 | quattro')
   aadd(aitems, '5 | cinque')
   aadd(aitems, '6 | senco')
   aadd(aitems, '7 | ses')
   IF len(aitems) > 7
      asize(aitems, 7)
   ENDIF

   DoMethod( Parent, Control, 'Refresh' )

   RETURN NIL

   // Local array

FUNCTION UpdateCombo2( Control, Parent )

   LOCAL aNewValues := { '1 | Uno' , '2 | Dos' , '3 | tres', '4 | quattro', '5 | cinque', '6 | senco', '7 | ses' }

   DoMethod( Parent, Control, 'SetArray', aNewValues )

   RETURN NIL

