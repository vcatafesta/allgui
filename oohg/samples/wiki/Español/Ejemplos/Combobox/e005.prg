/*
 * Ejemplo Combobox n° 5
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo utilizar la cláusula VALUESOURCE.
 *
 * Basado en un ejemplo publicado en la lista de OOHG por
 * Vicente Guerra <vic@guerra.com.mx>
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main

   LOCAL oWnd, aItems, aValores

   aItems := { "qqq", "www", "eee" }
   aValores := { "QQ", "WW", "EE" }

   DEFINE WINDOW MAIN OBJ oWnd ;
      TITLE "Cláusula ValueSource en el ComboBox" ;
      WIDTH 350 ;
      HEIGHT 200

      @ 10,10 COMBOBOX Combo ;
         WIDTH 100 ;
         HEIGHT 100 ;
         ITEMS aItems ;
         VALUESOURCE (aValores) ;     // Los paréntesis son necesarios !!!
         ON CHANGE oWnd:Label:Value := ;
                      "El valor del combo es: " + oWnd:Combo:Value

      @ 60,10 LABEL Label ;
         VALUE "Seleccione un item en el combo para ver su valor !!!" ;
         AUTOSIZE

      ON KEY ESCAPE ACTION oWnd:Release()
   END WINDOW

   CENTER WINDOW MAIN
   ACTIVATE WINDOW MAIN

RETURN NIL

/*
 * EOF
 */
