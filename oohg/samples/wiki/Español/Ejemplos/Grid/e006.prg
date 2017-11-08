/*
 * Ejemplo Grid n° 06
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Basado en un ejemplo de la distribución de OOHG creada por
 * Ciro Vargas C. <cvc@oohg.org>
 *
 * Este ejemplo muestra cómo incluir una columna con imágenes
 * que pueden ser 'editadas' (se pueden remplazar por cualquier
 * imagen de la lista de imágenes asociada al Grid).
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
      TITLE 'Grid con Imágenes Editable' ;
      MAIN ;
      ON INIT oGrid:ColumnBetterAutoFit(1)

      DEFINE STATUSBAR
         STATUSITEM 'El Poder de OOHG !!!'
      END STATUSBAR

      FOR k := 1 TO 15
          aRows[k] := { k % 3, ;
                        Str(HB_RANDOMINT( 99 ), 2), ;
                        HB_RANDOMINT( 100 ), ;
                        Date() + Random( HB_RANDOMINT() ), ;
                        'Refer ' + Str( HB_RANDOMINT( 10 ), 2 ), ;
                        HB_RANDOMINT( 10000 ) }
      NEXT k

      @ 10,10 GRID Grid_1 obj oGrid ;
         WIDTH 520 ;
         HEIGHT 330 ;
         HEADERS {"", 'CÓDIGO', 'NUMERO', 'FECHA', 'REFERENCIA', 'IMPORTE'} ;
         WIDTHS {1, 60, 80, 100, 120, 100} ;
         ITEMS aRows ;
         IMAGE { 'MINIGUI_EDIT_CANCEL', ;
                 'MINIGUI_EDIT_COPY', ;
                 'MINIGUI_EDIT_OK' } ;
         COLUMNCONTROLS { NIL, ;
                          { 'TEXTBOX', 'CHARACTER', '99'} , ;
                          { 'TEXTBOX', 'NUMERIC', '999999'} , ;
                          { 'TEXTBOX', 'DATE'}, ;
                          { 'TEXTBOX', 'CHARACTER'}, ;
                          { 'TEXTBOX', 'NUMERIC', '999,999,999.99' } } ;
         FONT 'COURIER NEW' SIZE 10 ;
         EDIT INPLACE

      ON KEY ESCAPE ACTION Form_1.Release()
   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN NIL

/*
 * EOF
 */
