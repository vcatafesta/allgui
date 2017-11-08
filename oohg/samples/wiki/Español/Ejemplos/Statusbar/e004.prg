/*
 * Ejemplo Statusbar n° 4
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo ubicar un control Progressbar
 * "dentro" de un StatusItem y cómo reubicarlo cuando cambia
 * el ancho del StatusItem.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include 'oohg.ch'

PROCEDURE MAIN

  PUBLIC oStat

   DEFINE WINDOW Main ;
      TITLE "Progressbar dentro de una Statusbar" ;
      WIDTH 640 ;
      HEIGHT 480 ;
      ON INIT CambiarStatusBar()

      @ 10, 10 BUTTON btn_1 ;
         CAPTION "Animar" ;
         ACTION AnimarProgressBar()

      @ 10, 120 BUTTON btn_2 ;
         CAPTION "Cambiar" ;
         ACTION CambiarStatusBar()

      DEFINE STATUSBAR OBJ oStat
         STATUSITEM "Poder ooHG !!!"
         STATUSITEM "" WIDTH 200
         STATUSITEM "Poder ooHG !!!" WIDTH 100

         @ 4, 102 PROGRESSBAR pgb_status ;
           RANGE 0, 100 ;
           WIDTH 192 ;
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

PROCEDURE CambiarStatusBar

   If oStat:ItemWidth( 2 ) > 150
      oStat:ItemWidth( 2, 100 )
   Else
      oStat:ItemWidth( 2, oStat:ClientWidth - 200 )
   EndIf
   Main.pgb_status.Col := oStat:ItemWidth( 1 ) + 4
   Main.pgb_status.Width := oStat:ItemWidth( 2 ) - 8

RETURN

/*
 * EOF
 */
