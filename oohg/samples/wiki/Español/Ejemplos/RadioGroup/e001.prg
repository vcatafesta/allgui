/*
 * Ejemplo RadioGroup n° 1
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo definir un control RadioGroup
 * con diferentes tooltips para cada ítem.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main

   LOCAL oForm1

   DEFINE WINDOW Form_1 ;
      OBJ oForm1 ;
      AT 0,0 ;
      WIDTH 588 ;
      HEIGHT 480 ;
      TITLE 'OOHG - RadioGroup Tooltips' ;
      MAIN

      @ 20,20 RADIOGROUP rdg_1 ;
         OPTIONS { 'Uno', 'Dos', 'Tres', 'Cuatro' } ;
         TOOLTIP { 'Item 1', 'Item 2', 'Item 3', 'Item 4' } ;
         WIDTH 80 ;
         SPACING 24

      @ 20,120 RADIOGROUP rdg_2 ;
         OPTIONS { 'One', 'Two', 'Three', 'Four' } ;
         TOOLTIP 'ToolTip' ;
         WIDTH 80 ;
         SPACING 24

      @ 200,20 LABEL lbl_1 ;
         VALUE "Vea lo que sucede cuando pasa el mouse sobre los ítems." ;
         AUTOSIZE

      ON KEY ESCAPE ACTION oForm1:Release()
   END WINDOW

   oForm1:Center()
   oForm1:Activate()

RETURN NIL

/*
 * EOF
 */
