/*
 * Ejemplo Grid n° 04
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Basado en un ejemplo de la distribución de OOHG creada por
 * Ciro Vargas C. <cvc@oohg.org>
 *
 * Este ejemplo muestra cómo utilizar la cláusula CHECKBOXES
 * en un control GRID.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include 'oohg.ch'

FUNCTION Main()
   LOCAL k, aRows[ 15, 5 ]

   SET DATE BRITISH
   SET CENTURY ON

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 558 ;
      HEIGHT 460 ;
      TITLE 'Grid con Checkboxes' ;
      MAIN

      DEFINE STATUSBAR
         STATUSITEM 'El Poder de OOHG !!!'
      END STATUSBAR

      FOR k :=1 TO 15
          aRows[k] := { STR( HB_RANDOMINT( 99 ), 2), ;
                        HB_RANDOMINT( 100 ), ;
                        DATE() + RANDOM( HB_RANDOMINT() ), ;
                        'Refer ' + STR( HB_RANDOMINT( 10 ), 2 ), ;
                        HB_RANDOMINT( 10000 ) }
      NEXT k

      @ 10,10 GRID Grid_1 OBJ oGrid ;
         WIDTH 520 ;
         HEIGHT 330 ;
         HEADERS { 'CÓDIGO', 'NUMERO', 'FECHA', 'REFERENCIA', 'IMPORTE' } ;
         WIDTHS { 60, 80, 100, 120, 140 } ;
         ITEMS aRows ;
         COLUMNCONTROLS { { 'TEXTBOX', 'CHARACTER', '99'} , ;
                          { 'TEXTBOX', 'NUMERIC', '999999'} , ;
                          { 'TEXTBOX', 'DATE'}, ;
                          { 'TEXTBOX', 'CHARACTER'}, ;
                          { 'TEXTBOX', 'NUMERIC', '999,999,999.99' } } ;
         FONT 'COURIER NEW' SIZE 10 ;
         EDIT INPLACE ;
         CHECKBOXES ;
         ON CHECKCHANGE { |nItem| MsgBox( "Item " + ;
                                          LTRIM( STR( nItem ) ) + ;
                                          " checkbox changed !!!" ) }

      @ 360,10 LABEL lbl_1 ;
         VALUE 'Pruebe el menú contextual. Use el mouse o la ' + ;
               'barra espaciadora para tildar/destildar los ítems.' ;
         AUTOSIZE

      DEFINE CONTEXT MENU CONTROL Grid_1
         MENUITEM 'Tildar Item' ;
            ACTION { || oGrid:CheckItem( oGrid:Value, .T. ) }
         MENUITEM 'Destildar Item' ;
            ACTION { || oGrid:CheckItem( oGrid:Value, .F. ) }
         MENUITEM 'Estado de un Item' ;
            ACTION { || AutoMsgBox( IF( oGrid:CheckItem( oGrid:Value ), ;
                                        'Checked', 'Unchecked' ) ) }
         MENUITEM 'Tildar Todos los Ítems' ;
            ACTION { || CheckAllItems( oGrid ) }
         MENUITEM 'Destildar Todos los Ítems' ;
            ACTION { || UncheckAllItems( oGrid ) }
         MENUITEM 'Ítems Tildados' ;
            ACTION { || ItemsChecked( oGrid ) }
      END MENU

      ON KEY ESCAPE ACTION Form_1.Release()
   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN NIL

FUNCTION CheckAllItems( oGrid )
   LOCAL i

   FOR i := 1 TO oGrid:ItemCount
      oGrid:CheckItem( i, .T. )
   NEXT i

RETURN NIL

FUNCTION UncheckAllItems( oGrid )
   LOCAL i

   FOR i := 1 TO oGrid:ItemCount
      oGrid:CheckItem( i, .F. )
   NEXT i

RETURN NIL

FUNCTION ItemsChecked( oGrid )
   LOCAL i, aItems := {}

   FOR i := 1 TO oGrid:ItemCount
      IF oGrid:CheckItem( i )
         AADD( aItems, i )
      ENDIF
   NEXT i

   IF LEN( aItems ) > 0
      AutoMsgBox( aItems )
   ELSE
      AutoMsgBox( 'Ningún ítem está tildado !!!' )
   ENDIF

RETURN NIL

/*
 * EOF
 */
