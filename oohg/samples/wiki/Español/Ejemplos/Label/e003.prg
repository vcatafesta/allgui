/*
 * Ejemplo Label n° 3
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo crear un LABEL multilínea.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main

   DEFINE WINDOW Form OBJ oWin ;
      AT 0,0 ;
      WIDTH 330 HEIGHT 200 ;
      TITLE "Demo de Control LABEL Multilínea" ;
      MAIN

      @ 20,20 LABEL lbl OBJ oLbl ;
         VALUE "Este es un control label " + HB_OSNewLine() + ;
               "multilínea." + HB_OSNewLine() + ;
               "Yo soy la tercera línea !!!" ;
         WIDTH 200 ;
         HEIGHT 50

      ON KEY ESCAPE ACTION Form.Release
   END WINDOW

   CENTER WINDOW Form
   ACTIVATE WINDOW Form

RETURN NIL

/*
 * EOF
 */
