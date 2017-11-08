/*
 * Ejemplo Grid n° 17
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo utilizar las cláusulas VIRTUAL
 * y ON QUERYDATA del control Grid, y cómo modificar el
 * color de fondo de los ítems después de la definición
 * del control.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include 'oohg.ch'

#define bColor { |nColu,nFila,aItem| If( Val( aItem[ 1 ] ) % 2 == 0, WHITE, RED ) }

FUNCTION Main()

   LOCAL k, oGrid, aRows[ 30, 2 ]

   SET DATE BRITISH
   SET CENTURY ON

   DEFINE WINDOW Form_1 ;
      AT 0, 0 ;
      WIDTH 600 ;
      HEIGHT 500 ;
      TITLE "Grid Virtual con DynamicBackColor" ;
      MAIN

      FOR k := 1 TO 30
          aRows[ k ] := { Str(HB_RandomInt( 99 ), 2, 0), ;
                          'Refer ' + Str( HB_RandomInt( 10 ), 2 ) }
      NEXT k

      @ 20, 20 GRID Grid_1 OBJ oGrid ;
         WIDTH 520 ;
         HEIGHT 330 ;
         HEADERS { 'CODIGO', 'REFERENCIA' } ;
         WIDTHS { 60, 140 } ;
         ITEMS aRows ;
         FONT 'COURIER NEW' SIZE 10 ;
         DYNAMICBACKCOLOR { bColor, bColor } ;
         VIRTUAL ;
         ON QUERYDATA DeterminarValor( oGrid, aRows )

      @ 360, 10 BUTTON Button_1 ;
         CAPTION "Cambiar" ACTION CambiarDatos( oGrid, aRows )

      ON KEY ESCAPE ACTION Form_1.Release()
   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN NIL

FUNCTION DeterminarValor( oGrid, aRows )

   _OOHG_ThisQueryData := aRows[ _OOHG_ThisQueryRowIndex, _OOHG_ThisQueryColIndex ]
   oGrid:SetItemColor( _OOHG_ThisQueryRowIndex, NIL, bColor, aRows[ _OOHG_ThisQueryRowIndex ], .F. )

RETURN NIL

FUNCTION CambiarDatos( oGrid, aRows )

  aRows[ oGrid:Value, 1 ] := Str( ( Val( aRows[ oGrid:Value, 1 ] ) + 1 ) % 100, 2, 0 )
  oGrid:Refresh()

RETURN NIL

/*
 * EOF
 */
