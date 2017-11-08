/*
 * Ejemplo Statusbar n° 3
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo ubicar un control Progressbar
 * "dentro" de un control Statusbar.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include 'oohg.ch'

PROCEDURE MAIN

   DEFINE WINDOW Main ;
      TITLE "Progressbar dentro de una Statusbar"

      @ 10, 10 BUTTON btn_1 ;
         CAPTION "Animar" ;
         ACTION AnimarProgressBar()

      DEFINE STATUSBAR OBJ oStat
         @ 4, 2 PROGRESSBAR pgb_status ;
           RANGE 0, 100 ;
           WIDTH oStat:ClientWidth - 4 ;
           HEIGHT oStat:ClientHeight - 6 ;
           SMOOTH
      END STATUSBAR

      ON KEY ESCAPE ACTION Main.Release
   END WINDOW

   Main.Activate

RETURN

PROCEDURE AnimarProgressBar

   Main.pgb_status.Value := 0
   DO WHILE Main.pgb_status.Value < 100
      Main.pgb_status.Value += 5
      HB_IdleSleep(.5)
   ENDDO

RETURN

/*
 * EOF
 */
