/*
 * Ejemplo Grid n° 11
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo ordenar los items de un grid
 * de acuerdo a un cierto criterio.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include 'oohg.ch'

FUNCTION Main()
   LOCAL i, aRows[ 15, 5 ], oGrid1

   SET DATE BRITISH
   SET CENTURY ON
   SET NAVIGATION EXTENDED

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 600 ;
      HEIGHT 480 ;
      TITLE "Ordenar los Items de un Grid" ;
      MAIN

      FOR i := 1 TO 15
          aRows[ i ] := { Str(HB_RandomInt( 99 ), 2), ;
                          HB_RandomInt( 100 ), ;
                          Date() + Random( HB_RandomInt() ), ;
                          'Refer ' + Str( HB_RandomInt( 10 ), 2 ), ;
                          HB_RandomInt( 10000 ) }
      NEXT i

      @ 20,20 GRID Grid_1 obj oGrid1 ;
         WIDTH 520 ;
         HEIGHT 330 ;
         HEADERS { 'CÓDIGO', 'NUMERO', 'FECHA', 'REFERENCIA', 'IMPORTE' } ;
         WIDTHS {60, 80, 100, 120, 140} ;
         ITEMS aRows ;
         COLUMNCONTROLS { { 'TEXTBOX', 'CHARACTER', '99' } , ;
                          { 'TEXTBOX', 'NUMERIC', '999999' } , ;
                          { 'TEXTBOX', 'DATE' }, ;
                          { 'TEXTBOX', 'CHARACTER' }, ;
                          { 'TEXTBOX', 'NUMERIC', ' 999,999,999.99' } } ;
         FONT 'COURIER NEW' SIZE 10

      @ 370,20 BUTTON btn_Sort ;
         CAPTION 'Ordenar' ;
         WIDTH 140 ;
         ACTION oGrid1:SortItems( { |o, i1, i2| Ordenar( o, i1, i2) } )

      ON KEY ESCAPE ACTION Form_1.Release()
   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN NIL

FUNCTION Ordenar( o, i1, i2 )
   LOCAL lPrecede

   lPrecede := ( o:Cell( i1, 1 ) + StrZero( o:Cell( i1, 2 ), 6, 0 ) ;
                 <= ;
                 o:Cell( i2, 1 ) + StrZero( o:Cell( i2, 2 ), 6, 0 ) )

RETURN IIF( lPrecede, -1, 1 )

/*
 * EOF
 */
