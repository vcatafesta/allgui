/*
 * Ejemplo Combobox n° 3
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra coo cambiar un item en un control
 * Combobox con la claúsula SORT.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 400 ;
      HEIGHT 200 ;
      TITLE 'ooHG - ComboBox con SORT' ;
      MAIN

      @ 10,10 COMBOBOX cmb_1 ;
         OBJ oCombo ;
         ITEMS { "B" , "A" , "C"  } ;
         VALUE 3 ;
         SORT

      @ 50, 10 BUTTON boton ;
         CAPTION "Cambiar" ;
         ACTION {|| AutoMsgBox(oCombo:value), ;
                    oCombo:Item(2, "Z"), ;
                    AutoMsgBox(oCombo:value) }

      ON KEY ESCAPE ACTION ThisWindow.Release()
   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN NIL

/*
 * EOF
 */
