/*
 * Ejemplo Form n° 3
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra el uso de SET AUTOADJUST ON para reajustar
 * automáticamente los controles de un formulario cada vez que se
 * modifica el tamaño del mismo.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include 'oohg.ch'

FUNCTION Main
   LOCAL oGrid

   SET AUTOADJUST ON
   
   DEFINE WINDOW Form_1 ;
      AT 0, 0 ;
      CLIENTAREA ;
      WIDTH 640 ;
      HEIGHT 480 ;
      TITLE "Ejemplo AutoAdjust" ;

      @ 20, 20 GRID Grid_1 ;
         OBJ oGrid ;
         WIDTH 600 ;
         HEIGHT 400 ;
         HEADERS {'Col.1', 'Col.2'} ;
         WIDTHS { 200, 200 }

      @ 430, 20 LABEL Label_1 ;
         WIDTH 600 ;
         VALUE "Las columnas mantienen sus proporciones " + ;
               "cada vez que cambia el tamaño del formulario." ;
         FONTCOLOR RED
   END WINDOW

   ACTIVATE WINDOW Form_1
RETURN NIL

/*
 * EOF
 */
