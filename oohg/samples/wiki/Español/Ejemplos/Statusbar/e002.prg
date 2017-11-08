/*
 * Ejemplo Statusbar n° 2
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo ubicar un control StatusBar
 * en una ventana virtual.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION MAIN

   DEFINE WINDOW Win_1 OBJ oWin ;
      AT 0,0 ;
      WIDTH 600 ;
      HEIGHT 438 ;
      TITLE 'StatusBar en una Ventana Virtual' ;
      MAIN

      DEFINE STATUSBAR FONT 'Arial' SIZE 9
          STATUSITEM ""
          KEYBOARD
      END STATUSBAR

      // Note que oWin:StatusBar:ClientHeightUsed()
      // retorna un valor negativo.

      DEFINE WINDOW Int_1 OBJ oInt ;
         AT 0,0 ;
         WIDTH oWin:ClientWidth ;
         HEIGHT (oWin:ClientHeight + oWin:StatusBar:ClientHeightUsed()) ;
         INTERNAL ;
         VIRTUAL HEIGHT 900

         @ 200,20 GRID Grid_1 ;
            HEIGHT 300 ;
            WIDTH (oInt:ClientWidth - 40) ;
            HEADERS {NIL,'CÓDIGO','NOMBRE'} ;
            WIDTHS {25,80,370}
      END WINDOW

      ON KEY ESCAPE ACTION oWin:Release()
   END WINDOW

   oWin:Center()
   oWin:Activate()

RETURN NIL

/*
 * EOF
 */
