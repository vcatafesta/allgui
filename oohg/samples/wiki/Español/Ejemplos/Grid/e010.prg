/*
 * Ejemplo Grid n° 10
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Basado en un ejemplo de la distribución de OOHG mantenida por
 * Ciro Vargas C. <cvc@oohg.org>
 *
 * Este ejemplo muestra cómo dimensionar un Grid para que
 * muestre únicamente filas enteras.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"
#include "i_windefs.ch"

FUNCTION Main

   LOCAL aFilas[ 20 ]

   DEFINE WINDOW Form_1 OBJ oForm ;
      AT 0,0 ;
      WIDTH 640 ;
      HEIGHT 480 ;
      TITLE 'GRID - Mostrar Solo Filas Enteras' ;
      MAIN ;
      ON INIT oGrid:Height := EstableceAlturaParaFilasEnteras( 10 )

      aFilas[ 01 ] := {'Simpson, Homer'}
      aFilas[ 02 ] := {'Mulder, Fox'}
      aFilas[ 03 ] := {'Smart, Max'}
      aFilas[ 04 ] := {'Grillo, Pepe'}
      aFilas[ 05 ] := {'Kirk, James T.'}
      aFilas[ 06 ] := {'Barriga, Carlos'}
      aFilas[ 07 ] := {'Flanders, Ned'}
      aFilas[ 08 ] := {'Smith, John'}
      aFilas[ 09 ] := {'Pedemonti, Flavio'}
      aFilas[ 10 ] := {'Gomez, Juan'}
      aFilas[ 11 ] := {'Fernandez, Raul'}
      aFilas[ 12 ] := {'Borges, Javier'}
      aFilas[ 13 ] := {'Alvarez, Alberto'}
      aFilas[ 14 ] := {'Gonzalez, Ambo'}
      aFilas[ 15 ] := {'Batistuta, Gol'}
      aFilas[ 16 ] := {'Vinazzi, Amigo'}
      aFilas[ 17 ] := {'Pedemonti, Flavio'}
      aFilas[ 18 ] := {'Samarbide, Armando'}
      aFilas[ 19 ] := {'Pradon, Alejandra'}
      aFilas[ 20 ] := {'Reyes, Monica'}

      @ 10,10 GRID Grid_1 OBJ oGrid;
         WIDTH oForm:ClientWidth - 20 ;
         HEIGHT 100 ;
         HEADERS {'Datos'} ;
         WIDTHS {300} ;
         JUSTIFY {BROWSE_JTFY_LEFT} ;
         ITEMS aFilas ;
         VALUE 1

      ON KEY ESCAPE ACTION Form_1.Release()
   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN NIL

FUNCTION EstableceAlturaParaFilasEnteras( CantidadDeFilasEnteras )

   LOCAL AltoNecesario

   AltoNecesario := CantidadDeFilasEnteras * oGrid:ItemHeight() + ;
                    oGrid:HeaderHeight + ;
                    IF( IsWindowStyle( oGrid:hWnd, WS_HSCROLL ), ;
                        GetHScrollBarHeight(), 0 ) + ;
                    IF( IsWindowExStyle( oGrid:hWnd, WS_EX_CLIENTEDGE ), ;
                        GetEdgeHeight() * 2, 0 )

RETURN AltoNecesario

/*
 * EOF
 */
