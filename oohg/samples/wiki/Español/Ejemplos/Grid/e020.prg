/*
 * Ejemplo Grid n° 20
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo poner una imagen en una
 * columna utilizando el control de columna IMAGELIST.
 * Este control utiliza el valor del item (un número
 * a partir del cero) para mostrar una imagen de las
 * indicadas por la cláusula IMAGE.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include 'oohg.ch'

FUNCTION Main()
   LOCAL k, aFilas[ 40, 5 ]

   SET DATE BRITISH
   SET CENTURY ON

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 658 ;
      HEIGHT 460 ;
      TITLE 'Grid con ColumnControl IMAGELIST' ;
      MAIN

      DEFINE STATUSBAR
         STATUSITEM 'El poder de OOHG !!!'
      END STATUSBAR

      FOR k :=1 TO LEN( aRows )
          aFilas[k] := { HB_RANDOMINT( 100 ), ;
                        DATE() + RANDOM( HB_RANDOMINT() ), ;
                        'Refer ' + STR( HB_RANDOMINT( 10 ), 2 ), ;
                        HB_RANDOMINT( 10000 ), ;
                        k % 3 }
      NEXT k

      @ 10,10 GRID Grid_1 OBJ oGrid ;
         WIDTH 620 ;
         HEIGHT 330 ;
         HEADERS { 'Número', ;
                   'Fecha', ;
                   'Referencia', ;
                   'Cantidad', ;
                   'Estado' } ;
         WIDTHS { 100, ;
                  100, ;
                  120, ;
                  140, ;
                  100 } ;
         ITEMS aFilas ;
         IMAGE { 'MINIGUI_EDIT_CANCEL', ;
                 'MINIGUI_EDIT_COPY', ;
                 'MINIGUI_EDIT_OK' } ;
         COLUMNCONTROLS { { 'TEXTBOX', 'NUMERIC', '999999'} , ;
                          { 'TEXTBOX', 'DATE'}, ;
                          { 'TEXTBOX', 'CHARACTER'}, ;
                          { 'TEXTBOX', 'NUMERIC', '999,999,999.99' }, ;
                          { 'IMAGELIST' } } ;
         JUSTIFY { GRID_JTFY_RIGHT, ;
                   GRID_JTFY_CENTER, ;
                   GRID_JTFY_LEFT, ;
                   GRID_JTFY_RIGHT, ;
                   GRID_JTFY_LEFT } ;
         READONLY { .F., .F., .F., .F., .T. } ;
         EDIT INPLACE

      ON KEY ESCAPE ACTION Form_1.Release()
   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN NIL

/*
 * EOF
 */
