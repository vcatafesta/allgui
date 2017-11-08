/*
 * Ejemplo Listbox n° 4
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo definir un listbox con items
 * arrastrables y también el uso de diferentes métodos.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main

   LOCAL oList2

   DEFINE WINDOW Win1 ;
      AT 0,0 ;
      WIDTH 400 ;
      HEIGHT 400 ;
      TITLE 'ListBox con items arrastrables' ;
      MAIN

      DEFINE MAIN MENU
         POPUP "Acciones"
            ITEM "GetTopIndex del ListBox 1"    ACTION AutoMsgBox( oList1:TopIndex() )
            ITEM "SetTopIndex del ListBox 1"    ACTION oList1:TopIndex := Val( InputBox( "Cambiar ListBox 1 TopIndex") )
            ITEM "EnsureVisible del ListBox 1"  ACTION oList1:EnsureVisible( Val( InputBox( "EnsureVisible de u nItem del ListBox 1") ) )
            ITEM "DeleteAllItems del ListBox 2" ACTION oList2:DeleteAllItems()
            ITEM "GetColumnWidth del ListBox 2" ACTION AutoMsgBox( oList2:ColumnWidth() )
            ITEM "SetColumnWidth del ListBox 2" ACTION oList2:ColumnWidth := Val( InputBox( "Cambiar el ColumnWidth del ListBox 2") )
            ITEM "GetTopIndex del ListBox 2"    ACTION AutoMsgBox( oList2:TopIndex() )
         END POPUP
      END MENU

      @ 10,20 LISTBOX lst_1 OBJ oList1 ;         // no se requiere declarar oList1, se crea PRIVATE
         WIDTH 100 ;
         HEIGHT 200 ;
         ITEMS { '01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20' } ;
         DRAGITEMS ;
         TEXTHEIGHT 20

      DEFINE LISTBOX lst_2
         OBJECT      oList2         // se debe declarar oList2
         ROW         10
         COL         150
         WIDTH       100
         HEIGHT      200
         ITEMS       { '01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20' }
         MULTISELECT .T.          // esta cláusula se ignora porque DRAGITEMS tiene prioridad
         MULTICOLUMN .T.
         DRAGITEMS   .T.
         COLUMNWIDTH 50
      END LISTBOX

      ON KEY ESCAPE ACTION ThisWindow.Release()
   END WINDOW

   CENTER WINDOW Win1
   ACTIVATE WINDOW Win1

RETURN Nil

/*
 * EOF
 */
