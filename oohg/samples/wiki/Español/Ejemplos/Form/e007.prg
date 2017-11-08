/*
 * Ejemplo Form n° 7
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplos muestra cómo crear un formulario con
 * fondo transparente.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"
#include "i_windefs.ch"

FUNCTION Main()

   DEFINE WINDOW Form_1 ;
      OBJ oForm1 ;
      AT 0,0 ;
      WIDTH 420 ;
      HEIGHT 200 ;
      CLIENTAREA ;
      MAIN ;
      TITLE "Formulario con fondo transparente" ;
      BACKCOLOR GRAY ;
      ON INIT SetLayeredWindowAttributes( oForm1:hWnd, RGB_VALUE( oForm1:BackColor ), 0, LWA_COLORKEY )

      @ 30,10 TEXTBOX txt_1 ;
         OBJ oTxt1 ;
         VALUE "El fondo del formulario es transparente !!!" ;
         WIDTH 400

      @ 60,10 RADIOGROUP rdg_1 ;
         OPTIONS { 'Uno', 'Dos', 'Tres', 'Cuatro' } ;
         WIDTH 80 ;
         SPACING 24

      ON KEY ESCAPE ACTION Form_1.Release
   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN NIL


FUNCTION RGB_VALUE( aColor )

RETURN RGB( aColor[ 1 ], aColor[ 2 ], aColor[ 3 ] )

/*
 * EOF
 */
