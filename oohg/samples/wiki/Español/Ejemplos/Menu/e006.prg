/*
 * Ejemplo Menu n° 6
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra habilitar/deshabilitar un POPUP en
 * tiempo de ejecución.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main()

   DEFINE WINDOW Form_1 ;
      OBJ oForm_1 ;
      AT 0,0 ;
      WIDTH 600 ;
      HEIGHT 200 ;
      TITLE 'ooHG Demo - habilitar/deshabilitar un POPUP en tiempo de ejecución' ;
      MAIN ;
      ON INIT oHabilitar:Enabled := .F.

      DEFINE MAIN MENU
         POPUP 'MenuPopUp' OBJ oMenuPop
            ITEM 'Salir' ;
               ACTION oForm_1:Release()
         END POPUP
      END MENU

      @ 20, 20 BUTTON btn_Habilitar ;
         OBJ oHabilitar ;
         CAPTION "Habilitar" ;
         ACTION ( oMenuPop:Enabled := .T., ;
                  oHabilitar:Enabled := .F., ;
                  oDeshabilitar:Enabled := .T. )

      @ 60, 20 BUTTON btn_Deshabilitar ;
         OBJ oDeshabilitar ;
         CAPTION "Deshabilitar" ;
         ACTION ( oMenuPop:Enabled := .F., ;
                  oHabilitar:Enabled := .T., ;
                  oDeshabilitar:Enabled := .F. )

      ON KEY ESCAPE ACTION oForm_1:Release()

   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN Nil

/*
 * EOF
 */
