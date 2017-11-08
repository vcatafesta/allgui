/*
 * Ejemplo Client Adjust n° 2
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Basado en una contribución original de
 * Cayetano Gómez <cayetano.gomez@gmail.com>
 * publicada por primera vez en <oohg@yahoogroups.com>
 *
 * Este ejemplo muestra cómo colocar una Toolbar al pie de un
 * formulario que, además, tiene una Statusbar al pie.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include 'oohg.ch'

FUNCTION Main()

   DEFINE WINDOW ppal OBJ oWnd WIDTH 400 HEIGHT 300 ;
      TITLE "Statusbar y Toolbar en la parte inferior"

      DEFINE STATUSBAR OBJ oSb
         STATUSITEM "El poder de OOHG !!!"
         DATE
         CLOCK
      END STATUSBAR

      DEFINE INTERNAL inte OBJ oInt
         DEFINE TOOLBAR tool OBJ oTool BUTTONSIZE 25,25 BOTTOM BORDER
            BUTTON firs CAPTION '|<'
            BUTTON prev CAPTION '<<'
            BUTTON next CAPTION '>>'
            BUTTON last CAPTION '>|'
            BUTTON edit CAPTION '><'
         END TOOLBAR
      END INTERNAL

      oInt:Adjust := 'BOTTOM'
      oInt:Height := oTool:Height

      ON KEY ESCAPE ACTION ppal.Release
   END WINDOW

   CENTER WINDOW ppal
   ACTIVATE WINDOW ppal

RETURN NIL

/*
 * EOF
 */
