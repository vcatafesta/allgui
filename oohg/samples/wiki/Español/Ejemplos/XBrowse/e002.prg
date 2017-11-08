/*
 * Ejemplo XBrowse n° 2
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo usar SET AUTOADJUST ON.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include 'oohg.ch'

FUNCTION Main

   SET AUTOADJUST ON
   
   DEFINE WINDOW Form_1 ;
      AT 0, 0 ;
      CLIENTAREA ;
      WIDTH 640 ;
      HEIGHT 480 ;
      TITLE "OOHG - Ejemplo AutoAdjust" ;

      @ 20, 20 XBROWSE XBrowse_1 ;
         WIDTH 600 ;
         HEIGHT 400 ;
         HEADERS {'Col.1', 'Col.2'} ;
         WIDTHS { 200, 200 }

      @ 430, 20 LABEL Label_1 ;
         WIDTH 600 ;
         VALUE "Las columnas guardan su proporción " + ;
               "cuando el formulario cambia de tamaño." ;
         FONTCOLOR RED
   END WINDOW

   ACTIVATE WINDOW Form_1
RETURN NIL

/*
 * EOF
 */
