/*
 * Ejemplo Misceláneo n° 1
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo remover el estilo visual de un
 * form o control en tiempo de ejecución.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION MAIN

   DEFINE WINDOW Win_1 ;
      OBJ oWin1 ;
      AT 0,0 ;
      WIDTH 640 ;
      HEIGHT 480 ;
      TITLE "Remover Estilo Visual" ;
      MAIN

      DEFINE SPLITBOX
         DEFINE TOOLBAR tbr_1 OBJ oTool1 BUTTONSIZE 70,20 BORDER
            BUTTON But11 CAPTION "&Salir" ACTION oWin:Release()
            BUTTON But12 CAPTION "&Uno" DROPDOWN
            BUTTON But13 CAPTION "&Dos" WHOLEDROPDOWN
         END TOOLBAR
         DEFINE TOOLBAR tbr_2 OBJ oTool2 BUTTONSIZE 70,20 BORDER FLAT
            BUTTON But21 CAPTION "&Salir" ACTION oWin:Release()
            BUTTON But22 CAPTION "&Uno" DROPDOWN
            BUTTON But23 CAPTION "&Dos" WHOLEDROPDOWN
         END TOOLBAR
      END SPLITBOX

      @ 140, 10 BUTTON btn_1 OBJ oBut1 ;
      WIDTH 200 ;
      CAPTION "Remover Tema" ;
      ACTION { oTool1:DisableVisualStyle(), ;
               oTool2:DisableVisualStyle(), ;
               oBut1:DisableVisualStyle(), ;
               oWin1:DisableVisualStyle(), ;
               oWin1:Redraw() }
   END WINDOW

   oWin1:Center()
   oWin1:Activate()

RETURN NIL

/*
 * EOF
 */
