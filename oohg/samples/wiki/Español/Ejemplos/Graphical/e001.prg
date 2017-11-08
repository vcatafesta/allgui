/*
 * Ejemplo Comandos Gráficos n° 1
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo crear un frame con marco
 * de color y color de fondo, utilizando el comando
 * DRAW ROUNDRECTANGLE.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"
#include "i_windefs.ch"

PROCEDURE MAIN

   LOCAL oWin

   DEFINE WINDOW Ventana ;
      OBJ oWin ;
      WIDTH 640 ;
      HEIGHT 480 ;
      NOSIZE ;
      NOMAXIMIZE ;
      TITLE "Como dibujar un frame"

      ON KEY ESCAPE ACTION oWin:Release()

      DRAW ROUNDRECTANGLE IN WINDOW Ventana AT 40,40 ;
                   TO 400,500 ;
                   ROUNDWIDTH 8 ;
                   ROUNDHEIGHT 8 ;
                   PENCOLOR BLUE ;
                   PENWIDTH 5 ;
                   FILLCOLOR YELLOW

/*
 * Si no especifica un BackColor para la Ventana, utilice:
                   FILLCOLOR { GetRed( GetSysColor( COLOR_3DFACE ) ), ;
                               GetGreen( GetSysColor( COLOR_3DFACE ) ), ;
                               GetBlue( GetSysColor( COLOR_3DFACE ) ) }
 * para que el interior del frame tenga el mismo color que el fondo
 * de la Ventana.
 *
 * Si especifica un BackColor, utilice dicho color como FILLCOLOR
 * para que el interior del frame tenga el mismo color que el fondo
 * de la Ventana.
 */

      @ 34,50 LABEL Title ;
         AUTOSIZE ;
         VALUE " Mi Frame " ;
         BACKCOLOR YELLOW
   END WINDOW

   oWin:Center()
   oWin:Activate()

RETURN

/*
 * EOF
 */
