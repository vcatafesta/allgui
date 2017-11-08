/*
 * Ejemplo Grid n° 02
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Basado en un ejemplo de la distribución de OOHG creada por
 * Ciro Vargas C. <cvc@oohg.org>
 *
 * Este ejemplo muestra cómo crear un Grid con capacidades de
 * navegación por celda. Por defecto, la navegación está
 * restringida a la fila seleccionada, pero puede habilitarse
 * la navegación extendida agregando la cláusula FULLMOVE en
 * el momento de su definición o cambiando la propiedad
 * FULLMOVE durante la ejecución. Este ejemplo también
 * demuestra los métodos: Left, Right, Up, Down, PageDown,
 * PageUp, GoTop, GoBottom, AddItem, AppendItem, EditCell,
 * AddColumn, DeleteColumn, ColumnHide and, ColumnShow.
 * Este tipo de Grid está implementado por medio de la subclase
 * TGridByCell de la clase TGrid class, por lo que se pueden
 * utilizar casi todos los métodos de la clase padre. Tenga en
 * cuenta que el Value de la clase TGridByCell es un array con
 * dos ítems numéricos {Fila,Columna} en lugar de un número
 * como en la clase TGrid, por lo que si planea convertir uno
 * de sus viejos grids a la nueva clase, debe encargarse de
 * este cambio.
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
      AT 0, 0 ;
      WIDTH 600 ;
      HEIGHT 500 ;
      TITLE 'Grid con Navegación por Celda' ;
      MAIN

      DEFINE STATUSBAR
         STATUSITEM 'El Poder de OOHG !!!'
      END STATUSBAR

      FOR k := 1 TO 15
          aRows[ k ] := { Str(HB_RandomInt( 99 ), 2), ;
                          HB_RandomInt( 100 ), ;
                          Date() + Random( HB_RandomInt() ), ;
                          'Refer ' + Str( HB_RandomInt( 10 ), 2 ), ;
                          HB_RandomInt( 10000 ) }
      NEXT k

      @ 20, 20 GRID Grid_1 obj oGrid ;
         WIDTH 520 ;
         HEIGHT 330 ;
         HEADERS { 'CÓDIGO', 'NUMERO', 'FECHA', 'REFERENCIA', 'IMPORTE' } ;
         WIDTHS { 60, 80, 100, 120, 140 } ;
         ITEMS aRows ;
         COLUMNCONTROLS { { 'TEXTBOX', 'CHARACTER', '99' } , ;
                          { 'TEXTBOX', 'NUMERIC', '999999' } , ;
                          { 'TEXTBOX', 'DATE' }, ;
                          { 'TEXTBOX', 'CHARACTER' }, ;
                          { 'TEXTBOX', 'NUMERIC', ' 999,999,999.99' } } ;
         FONT 'COURIER NEW' SIZE 10 ;
         EDIT ;
         WHEN { .T., { |nCol, aItem| aItem[ nCol ] > 50 }, .T., .T., .T. } ;
         READONLY { .F., .F., .F., .F., .T. } ;
         VALID { { |uValue| ! empty( uValue ) }, ;
                 { |uValue| uValue >= 0}, ;
                 { |uValue| uValue > date() }, ;
                 { |uValue| ! empty( uValue ) }, ;
                 NIL } ;
         NAVIGATEBYCELL ;
         SELECTEDCOLORS { BLACK, YELLOW, ;
                          YELLOW, BROWN, ;
                          BLUE, GREEN, ;
                          GREEN, PINK } ;
         FONTCOLOR PURPLE ;
         BACKCOLOR ORANGE ;
         DYNAMICFORECOLOR { WHITE, NIL, NIL, NIL, NIL } ;
         DYNAMICBACKCOLOR { BLACK, NIL, NIL, NIL, NIL } ;
         ON CHANGE { || Form_1.StatusBar.Item( 1 ) := ;
                        'Value cambió a ' + Autotype( oGrid:Value ) } ;
         VALUE { 5, 4 }

      DEFINE CONTEXT MENU CONTROL Grid_1
         MENUITEM 'Ir a la fila 4 col 2' ;
            ACTION {|| oGrid:Value := { 4, 2 } }
         SEPARATOR
         MENUITEM 'Izquierda' ;
            ACTION {|| oGrid:Left() }
         MENUITEM 'Derecha' ;
            ACTION {|| oGrid:setfocus(), oGrid:Right()}
         MENUITEM 'Arriba' ;
            ACTION {|| oGrid:setfocus(), oGrid:Up() }
         MENUITEM 'Abajo' ;
            ACTION {|| oGrid:setfocus(), oGrid:Down()}
         MENUITEM 'Página arriba' ;
            ACTION {|| oGrid:setfocus(), oGrid:PageUp() }
         MENUITEM 'Página abajo' ;
            ACTION {|| oGrid:setfocus(), oGrid:PageDown()}
         MENUITEM 'Comienzo' ;
            ACTION {|| oGrid:setfocus(), oGrid:GoTop() }
         MENUITEM 'Fin' ;
            ACTION {|| oGrid:setfocus(), oGrid:GoBottom() }
         SEPARATOR
         MENUITEM 'Añadir Item (AddItem)' ;
            ACTION {|| oGrid:AddItem( { '11', 123456, date(), ;
                                        'Added by AddItem', 123.99 } ) }
         MENUITEM 'Agregar Item (AppendItem)' ;
            ACTION {|| oGrid:AppendItem() }
         MENUITEM 'Borrar Item' ;
            ACTION {|| oGrid:DeleteItem( oGrid:Value[ 1 ] ) }
         SEPARATOR
         MENUITEM 'Editar fila 2 col 3' ;
            ACTION {|| oGrid:EditCell( 2, 3 ) }
         SEPARATOR
         MENUITEM 'Agregar Columna 3' NAME mnu_AddCol ;
            ACTION {|| oGrid:AddColumn( 3, "PERSONA", 100, GRID_JTFY_CENTER, ;
                                        NIL, NIL, .T., NIL, { 'TEXTBOX', ;
                                        'CHARACTER' }, NIL, NIL, NIL, .T., ;
                                        NIL, NIL ), ;
                       Form_1.mnu_DelCol.Enabled := .T., ;
                       Form_1.mnu_AddCol.Enabled := .F. }
         MENUITEM 'Borrar Columna 3' NAME mnu_DelCol DISABLED ;
            ACTION {|| oGrid:DeleteColumn( 3, .T. ), ;
                       Form_1.mnu_AddCol.Enabled := .T., ;
                       Form_1.mnu_DelCol.Enabled := .F. }
         MENUITEM 'Ocultar Columna 2' NAME mnu_Hide ;
            ACTION {|| oGrid:ColumnHide( 2 ), ;
                       Form_1.mnu_Show.Enabled := .T., ;
                       Form_1.mnu_Hide.Enabled := .F. }
         MENUITEM 'Mostrar Columna 2' NAME mnu_Show DISABLED ;
            ACTION {|| oGrid:ColumnShow( 2 ), ;
                       Form_1.mnu_Hide.Enabled := .T., ;
                       Form_1.mnu_Show.Enabled := .F. }
      END MENU

      @ 370, 20 CHECKBOX chk_Append ;
         CAPTION 'Modo Append' ;
         ON CHANGE oGrid:Append := ! oGrid:Append

      @ 410, 20 LABEL lbl_Try ;
         VALUE 'Prueba el Menú Contextual !!!' ;
         AUTOSIZE

      @ 370, 220 CHECKBOX chk_FullMode ;
         CAPTION 'FullMove' ;
         ON CHANGE oGrid:FullMove := ! oGrid:FullMove

      @ 410, 220 LABEL lbl_Enter ;
         VALUE 'Usa Enter o DobleClic para iniciar la edición.' ;
         AUTOSIZE

      ON KEY ESCAPE ACTION Form_1.Release()
   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN NIL

/*
 * EOF
 */
