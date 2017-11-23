/*
* HMG Virtual Grid Demo
* (c) 2003 Roberto lopez
*/

#include "hmg.ch"

FUNCTION Main

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH 450 ;
         HEIGHT 400 ;
         TITLE 'Hello World!' ;
         MAIN

      DEFINE MAIN MENU
         DEFINE POPUP 'File'
            MENUITEM 'Change ItemCount' ACTION Form_1.Grid_1.ItemCount := Val(InputBox('New Value','Change ItemCount'))
         END POPUP
      END MENU

      @ 10,10 GRID Grid_1 ;
         WIDTH 400 ;
         HEIGHT 330 ;
         HEADERS {'','Column 2','Column 3'} ;
         WIDTHS {0,140,140};
         VIRTUAL ;
         ITEMCOUNT 100000000 ;
         ON QUERYDATA QueryTest() MULTISELECT ;
         IMAGE {"br_no","br_ok"}

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

   RETURN

PROCEDURE QueryTest()

   IF This.QueryColIndex == 1
      IF Int ( This.QueryRowIndex / 2 ) == This.QueryRowIndex / 2
         This.QueryData := 0
      ELSE
         This.QueryData := 1
      ENDIF
   ELSE
      This.QueryData := Str ( This.QueryRowIndex ) + ',' + Str ( This.QueryColIndex )
   ENDIF

   RETURN
