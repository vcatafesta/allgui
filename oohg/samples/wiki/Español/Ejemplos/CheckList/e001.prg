/*
 * Ejemplo CheckList n° 1
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo crear un control CheckList
 * y cómo utilizar sus métodos y eventos.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 500 ;
      HEIGHT 500 ;
      TITLE 'Ejemplo de Control CheckList' ;
      MAIN

      DEFINE STATUSBAR
         STATUSITEM ""
      END STATUSBAR

      @ 10,10 CHECKLIST ckl_1 obj oChkL1 ;
         WIDTH 300 ;
         HEIGHT 300 ;
         ITEMS { {'Rojo', 0}, {'Verde', 1}, {'Negro', 2}, {'Rosado', 1} } ;
         IMAGE { 'MINIGUI_EDIT_CANCEL', ;
                 'MINIGUI_EDIT_COPY', ;
                 'MINIGUI_EDIT_OK' } ;
         ON CHANGE { || Form_1.StatusBar.Item( 1 ) := ;
                        "Se cambió el checkbox del ítem " + ;
                        LTRIM( STR( oChkL1:LastChangedItem ) ) + ;
                        " !!!" }
/*
      DEFINE CHECKLIST ckl_1
         ROW 10
         COL 10
         WIDTH 300
         HEIGHT 300
         ITEMS { {'Rojo', 0}, {'Verde', 1}, {'Negro', 2}, {'Rosado', 1} }
         IMAGE { 'MINIGUI_EDIT_CANCEL', ;
                 'MINIGUI_EDIT_COPY', ;
                 'MINIGUI_EDIT_OK' }
         ON CHANGE { || Form_1.StatusBar.Item( 1 ) := ;
                        "Se cambió el checkbox del ítem " + ;
                        LTRIM( STR( oChkL1:LastChangedItem ) ) + ;
                        " !!!" }
      END CHECKLIST

      oChkL1 := GetControlObject('ckl_1','Form_1')
*/

/*
 * LastChangedItem:
 * Item responsable por el último evento OnChange.
 * Cero cuando el eventos fue disparado por los métodos Sort o DeleteItem.
 */

      DEFINE CONTEXT MENU CONTROL ckl_1
         MENUITEM 'Cambiar el Ítem Seleccionado' ;
            ACTION oChkL1:CheckItem( oChkL1:FirstSelectedItem, ;
                      ! oChkL1:CheckItem( oChkL1:FirstSelectedItem ) )
         SEPARATOR
         MENUITEM 'Tildar el Ítem 2' ;
            ACTION oChkL1:CheckItem( 2, .T. )
         MENUITEM 'Destildar el Ítem 2' ;
            ACTION oChkL1:CheckItem( 2, .F. )
         MENUITEM 'Estado del Ítem 2' ;
            ACTION AutoMsgBox( IF( oChkL1:CheckItem( 2 ), ;
                                   'Tildado', 'Destildado' ) )
         MENUITEM 'Tildar Todos los Ítems' ;
            ACTION CheckAllItems( oChkL1 )
         MENUITEM 'Destildar Todos los Ítems' ;
            ACTION UncheckAllItems( oChkL1 )
         SEPARATOR
         MENUITEM 'Cambiar el ancho' ;
            ACTION oChkL1:Width := If( oChkL1:Width > 50, 50, 300 )
         MENUITEM 'Cambiar el Value := {2,3}' ;
            ACTION oChkL1:Value := { 2, 3 }
         MENUITEM 'Hacer Visible el Último Ítem' ;
            ACTION oChkL1:ItemVisible( oChkL1:ItemCount )
         SEPARATOR
         MENUITEM 'Agregar un Ítem' ;
            ACTION oChkL1:AddItem( {'Blanco', 1}, .T. )
         MENUITEM 'Insertar un Ítem' ;
            ACTION oChkL1:InsertItem( 3, {'Gris', 2}, .T. )
         MENUITEM 'Cambiar el Ítem 2' ;
            ACTION oChkL1:Item( 2, {'Azul', 0}, .F. )
         MENUITEM 'Eliminar el Ítem 1' ;
            ACTION oChkL1:DeleteItem( 1 )
         MENUITEM 'Eliminar Todos los Ítems' ;
            ACTION oChkL1:DeleteAllItems()
         SEPARATOR
         MENUITEM 'Ordenar en Forma Ascendente' ;
            ACTION oChkL1:Sort( .F. )         // si se omite asume .F.
         MENUITEM 'Ordenar en Forma Descendente' ;
            ACTION oChkL1:Sort( .T. )
      END MENU

      @ 330,10 BUTTON btn_Value1 ;
         CAPTION "Mostrar Value" ;
         ACTION AutoMsgBox(oChkL1:Value)

      @ 10,340 CHECKLIST chk_2 obj oChkL2 ;
         WIDTH 140 ;
         HEIGHT 300 ;
         ITEMS { 'Duraznos', 'Bananas', 'Manzanas', 'Uvas' } ;
         JUSTIFY CHKL_JTFY_RIGHT ;
         SORT ;
         VALUE { 1,2 }

/*
      DEFINE CHECKLIST chk_2
         ROW 10
         COL 340
         WIDTH 140
         HEIGHT 300
         ITEMS { 'Duraznos', 'Bananas', 'Manzanas', 'Uvas' }
         JUSTIFY CHKL_JTFY_RIGHT
         SORT .T.
         VALUE { 1,2 }
      END CHECKLIST

      oChkL2 := GetControlObject('chk_2','Form_1')
*/

      DEFINE CONTEXT MENU CONTROL chk_2
         MENUITEM 'Cambiar el Ítem Seleccionado' ;
            ACTION oChkL2:CheckItem( oChkL2:FirstSelectedItem, ;
                      ! oChkL2:CheckItem( oChkL2:FirstSelectedItem ) )
         SEPARATOR
         MENUITEM 'Tildar el Ítem 2' ;
            ACTION oChkL2:CheckItem( 2, .T. )
         MENUITEM 'Destildar el Ítem 2' ;
            ACTION oChkL2:CheckItem( 2, .F. )
         MENUITEM 'Estado del Ítem 2' ;
            ACTION AutoMsgBox( IF( oChkL2:CheckItem( 2 ), ;
                                   'Tildado', 'Destildado' ) )
         MENUITEM 'Tildar Todos los Ítems' ;
            ACTION CheckAllItems( oChkL2 )
         MENUITEM 'Destildar Todos los Ítems' ;
            ACTION UncheckAllItems( oChkL2 )
         SEPARATOR
         MENUITEM 'Cambiar el Value := {2,3}' ;
            ACTION oChkL2:Value := { 2, 3 }
         MENUITEM 'Hacer Visible el Último Ítem' ;
            ACTION oChkL2:ItemVisible( oChkL2:ItemCount )
         SEPARATOR
         MENUITEM 'Agregar un Ítem' ;
            ACTION oChkL2:AddItem( "Naranjas", .F. )
         MENUITEM 'Insertar un Ítem' ;
            ACTION oChkL2:InsertItem( 3, 'Ciruelas', .F. )
         MENUITEM 'Cambiar el Ítem 2' ;
            ACTION oChkL2:Item( 2, 'Sandía', .T. )
         MENUITEM 'Eliminar el Ítem 1' ;
            ACTION oChkL2:DeleteItem( 1 )
         MENUITEM 'Eliminar Todos los Ítems' ;
            ACTION oChkL2:DeleteAllItems()
         SEPARATOR
         MENUITEM 'Ordenar en Forma Ascendente' ;
            ACTION oChkL2:Sort( .F. )         // si se omite asume .F.
         MENUITEM 'Ordenar en Forma Descendente' ;
            ACTION oChkL2:Sort( .T. )
      END MENU

      @ 330,340 BUTTON btn_Value2 ;
         CAPTION "Mostrar Value" ;
         ACTION AutoMsgBox( oChkL2:Value )

      @ 370,10 BUTTON btn_Clear ;
         CAPTION "Borrar StatusBar" ;
         ACTION Form_1.StatusBar.Item( 1 ) := ""

      ON KEY ESCAPE OF Form_1 ACTION Form_1.Release()
   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

Return Nil

FUNCTION CheckAllItems( oChkL )
   LOCAL i

   FOR i := 1 TO oChkL:ItemCount
      oChkL:CheckItem( i, .T. )
   NEXT i

Return Nil

FUNCTION UncheckAllItems( oChkL )
   LOCAL i

   FOR i := 1 TO oChkL:ItemCount
      oChkL:CheckItem( i, .F. )
   NEXT i

Return Nil

/*
 * EOF
 */
