/*
 * Ejemplo Grid n° 26
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo cambiar los colores de la fila
 * seleccionada dependiendo del VALUE del control.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include 'oohg.ch'

FUNCTION Main()

   LOCAL k, oGrid, aRows[ 30, 2 ]
   PRIVATE bColor1 := { || if (  This.CellRowIndex/2 == Int(This.CellRowIndex/2), RED,   GREEN  )}
   PRIVATE bColor2 := { || if (  This.CellRowIndex/2 == Int(This.CellRowIndex/2), WHITE, YELLOW )}
   PRIVATE bColor3 := { || if (  oGrid:Value/2       == Int(oGrid:Value/2),       WHITE, YELLOW )}
   PRIVATE bColor4 := { || if (  oGrid:Value/2       == Int(oGrid:Value/2),       RED,   GREEN  )}
   PRIVATE bColor5 := { || if (  oGrid:Value/2       == Int(oGrid:Value/2),       WHITE, YELLOW )}
   PRIVATE bColor6 := { || if (  oGrid:Value/2       == Int(oGrid:Value/2),       GRAY,  GRAY   )}

   SET DATE BRITISH
   SET CENTURY ON

   DEFINE WINDOW Form_1 ;
      AT 0, 0 ;
      WIDTH 600 ;
      HEIGHT 500 ;
      TITLE "Cláusula SelectedColor" ;
      MAIN ;
      ON INIT oGrid:Value := 3

      FOR k := 1 TO 30
          aRows[ k ] := { Str(HB_RandomInt( 99 ), 2, 0), ;
                          'Refer ' + Str( HB_RandomInt( 10 ), 2 ) }
      NEXT k

      @ 20, 20 GRID Grid_1 OBJ oGrid ;
         WIDTH 520 ;
         HEIGHT 330 ;
         HEADERS { 'COD.', 'REFERENCIA' } ;
         WIDTHS { 60, 140 } ;
         ITEMS aRows ;
         FONT 'COURIER NEW' SIZE 10 ;
         DYNAMICFORECOLOR { bColor1, bColor1 } ;
         DYNAMICBACKCOLOR { bColor2, bColor2 } ;
         ON CHANGE oGrid:SetSelectedColors( { bColor3, bColor4, bColor5, bColor6 }, .T. )

/*
La cláusula SELECTEDCOLOR utiliza un array con 4 elementos para pintar el item seleccionado (el item apuntado por el VALUE del control):

item 1: color del texto cuando el control tiene el foco, el valor por defecto es COLOR_HIGHLIGHTTEXT.
item 2: color de fondo del texto cuando el control tiene el foco, el valor por defecto es COLOR_HIGHLIGHT.
item 3: color del texto cuando el control no tiene el foco, el valor por defecto es COLOR_WINDOWTEXT.
item 4: color de fondo del texto cuando el control no tiene el foco, el valor por defecto es COLOR_3DFACE.
*/

      @ 360, 10 BUTTON Button_1 ;
         CAPTION "Clic" ACTION Nil

      ON KEY ESCAPE ACTION Form_1.Release()
   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN NIL

/*
 * EOF
 */
