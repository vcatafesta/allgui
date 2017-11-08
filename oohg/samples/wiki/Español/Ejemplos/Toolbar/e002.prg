/*
 * Ejemplo Barras de Herramientas (ToolBar) n° 2
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo se puede colocar un control
 * Toolbar dentro de una ventana con dimensiones virtuales
 * de forma que los controles no se le superpongan.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION MAIN

   DEFINE WINDOW Win ;
      OBJ oWin ;
      AT 0,0 ;
      WIDTH 640 ;
      HEIGHT 480 ;
      TITLE "Toolbar en una ventana con dimensiones virtuales" ;
      MAIN

      DEFINE TOOLBAR Tool OBJ oTool BUTTONSIZE 70,20 FLAT BORDER
         BUTTON But1 CAPTION "&Salir" ACTION oWin:Release()
      END TOOLBAR

      DEFINE WINDOW Int ;
         OBJ oInt ;
         AT oTool:Height, 0 ;
         WIDTH oWin:ClientWidth ;
         HEIGHT oWin:ClientHeight - oTool:Height ;
         INTERNAL ;
         VIRTUAL HEIGHT 1000 ;
         VIRTUAL WIDTH 1000

         @ 100,20 TEXTBOX Text1 ;
            WIDTH 100 ;
            HEIGHT 25

         @ 300,20 TEXTBOX Text2 ;
            WIDTH 100 ;
            HEIGHT 25

         @ 500,20 TEXTBOX Text3 ;
            WIDTH 100 ;
            HEIGHT 25

         @ 700,20 TEXTBOX Text4 ;
            WIDTH 100 ;
            HEIGHT 25

         @ 900,20 TEXTBOX Text5 ;
            WIDTH 100 ;
            HEIGHT 25
      END WINDOW
   END WINDOW

   // Esto reduce el parpadeo
   oInt:VScrollBar:nLineSkip := 50

   oWin:Center()
   oWin:Activate()

RETURN NIL

/*
 * EOF
 */
