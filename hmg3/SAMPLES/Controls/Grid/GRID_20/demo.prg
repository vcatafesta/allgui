/*
* HMG Grid Demo
* (c) 2005 Roberto Lopez
*/

#include "hmg.ch"

FUNCTION Main

   LOCAL aRows [20] [3]

   PRIVATE fColor := { || if ( This.CellRowIndex/2 == int(This.CellRowIndex/2) , { 0,0,255 } , { 0,255,0 } ) }

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH 640 ;
         HEIGHT 400 ;
         TITLE 'Mixed Data Type Grid Test' ;
         MAIN

      DEFINE MAIN MENU
         DEFINE POPUP 'File'
            MENUITEM 'Set Item'   ACTION SetItem()
            MENUITEM 'Get Item'   ACTION GetItem()
         END POPUP
      END MENU

      aRows [1]   := {113.12,date(),1,1 , .t. }
      aRows [2]   := {123.12,date(),2,2 , .f. }
      aRows [3]   := {133.12,date(),3,3, .t. }
      aRows [4]   := {143.12,date(),1,4, .f. }
      aRows [5]   := {153.12,date(),2,5, .t. }
      aRows [6]   := {163.12,date(),3,6, .f. }
      aRows [7]   := {173.12,date(),1,7, .t. }
      aRows [8]   := {183.12,date(),2,8, .f. }
      aRows [9]   := {193.12,date(),3,9, .t. }
      aRows [10]   := {113.12,date(),1,10, .f. }
      aRows [11]   := {123.12,date(),2,11, .t. }
      aRows [12]   := {133.12,date(),3,12, .f. }
      aRows [13]   := {143.12,date(),1,13, .t. }
      aRows [14]   := {153.12,date(),2,14, .f. }
      aRows [15]   := {163.12,date(),3,15, .t. }
      aRows [16]   := {173.12,date(),1,16, .f. }
      aRows [17]   := {183.12,date(),2,17, .t. }
      aRows [18]   := {193.12,date(),3,18, .f. }
      aRows [19]   := {113.12,date(),1,19, .t. }
      aRows [20]   := {123.12,date(),2,20, .f. }

      @ 10,10 GRID Grid_1 ;
         WIDTH 620 ;
         HEIGHT 330 ;
         HEADERS {'Column 1','Column 2','Column 3','Column 4','Column 5'} ;
         WIDTHS {140,140,140,140,140} ;
         ITEMS aRows ;
         EDIT ;
         COLUMNCONTROLS { {'TEXTBOX','NUMERIC','$ 999,999.99'} , {'DATEPICKER','DROPDOWN'} , {'COMBOBOX',{'One','Two','Three'}} , { 'SPINNER' , 1 , 20 } , { 'CHECKBOX' , 'Yes' , 'No' } } ;
         DYNAMICFORECOLOR { fColor , fColor, fColor, fColor, fColor } ;
         COLUMNVALID    { ;
         { || Test1() }   ,   ;
         { || Test2() }   ,   ;
         { || Test3() }   ,   ;
         { || Test4() }   ,   ;
         { || Test5() }      ;
         }

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

   RETURN

PROCEDURE SETITEM()

   Form_1.Grid_1.Item (2) := { 123.45 , date() , 2 , 10 , .T. }

   RETURN

PROCEDURE GETITEM()

   LOCAL a

   a := Form_1.Grid_1.Item (2)

   msginfo ( str ( a [1] )            , '1' )
   msginfo ( dtoc ( a [2] )         , '2' )
   msginfo ( str( a [3] )            , '3' )
   msginfo ( str ( a [4] )            , '4' )
   msginfo ( if ( a [5] == .t. , '.t.' , '.f.' )   , '5' )

   RETURN

PROCEDURE test1()

   IF This.CellValue == 0

      This.CellValue := 999

   ENDIF

   RETURN

PROCEDURE test2()

   IF Year (This.CellValue) <> 2009

      This.CellValue := Date()

   ENDIF

   RETURN

PROCEDURE test3()

   IF This.CellValue == 3

      This.CellValue := 1

   ENDIF

   RETURN

PROCEDURE test4()

   IF This.CellValue == 1

      This.CellValue := 9

   ENDIF

   RETURN

PROCEDURE test5()

   IF This.CellValue == .F.

      This.CellValue := .T.

   ENDIF

   RETURN
