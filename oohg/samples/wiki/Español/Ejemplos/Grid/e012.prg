/*
 * Ejemplo Grid n° 12
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo cambiar el color de fondo de un
 * Grid cuando el control es habilitado o deshabilitado.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include 'oohg.ch'

FUNCTION Main()

   LOCAL k, aRows[ 15, 5 ], oGrid, oBotn

   SET DATE BRITISH
   SET CENTURY ON

   DEFINE WINDOW Form_1 ;
      AT 0, 0 ;
      WIDTH 600 ;
      HEIGHT 500 ;
      TITLE 'Cambiar el Color de Fondo del Grid' ;
      MAIN ;
      ON INIT CambiarEstado( oGrid, oBotn )

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
         HEADERS { 'CÓDIGO', 'NÚMERO', 'FECHA', 'REFERENCIA', 'IMPORTE' } ;
         WIDTHS { 60, 80, 100, 120, 140 } ;
         ITEMS aRows ;
         COLUMNCONTROLS { { 'TEXTBOX', 'CHARACTER', '99' } , ;
                          { 'TEXTBOX', 'NUMERIC', '999999' } , ;
                          { 'TEXTBOX', 'DATE' }, ;
                          { 'TEXTBOX', 'CHARACTER' }, ;
                          { 'TEXTBOX', 'NUMERIC', '999,999,999.99' } }

      @ 370, 20 BUTTON btn_Cambiar ;
         OBJ oBotn ;
         CAPTION "Deshabilitar" ;
         WIDTH 100 ;
         HEIGHT 28 ;
         ACTION CambiarEstado( oGrid, oBotn )

      ON KEY ESCAPE ACTION Form_1.Release()
   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN NIL

FUNCTION CambiarEstado( oGrid, oBotn )

  IF oGrid:Enabled
     oGrid:SetRangeColor( NIL, { YELLOW, YELLOW, YELLOW, YELLOW, YELLOW }, 1, 1, oGrid:ItemCount, Len( oGrid:aHeaders ) )
     oGrid:Refresh()
     oGrid:Enabled := .F.
     oBotn:Caption := "Habilitar"
  ELSE
     oGrid:SetRangeColor( NIL, { GREEN, GREEN, GREEN, GREEN, GREEN }, 1, 1, oGrid:ItemCount, Len( oGrid:aHeaders ) )
     oGrid:Refresh()
     oGrid:Enabled := .T.
     oBotn:Caption := "Deshabilitar"
  ENDIF

RETURN NIL

/*
 * EOF
 */
