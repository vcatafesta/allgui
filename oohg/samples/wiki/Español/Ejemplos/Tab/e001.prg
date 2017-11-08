/*
 * Ejemplo Tab n° 1
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo definir un CheckBox o un
 * RadioGroup con fondo transparente dentro de un control Tab.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 640 HEIGHT 480 ;
      TITLE 'CheckBox y RadioGroup con fondo transparente dentro de un Tab' ;
      MAIN

      DEFINE TAB Tab_1 ;
         AT 10,10 ;
         WIDTH 600 ;
         HEIGHT 400 ;
         VALUE 1

         PAGE 'Página &1'
            @ 40,20 RADIOGROUP rdg_1 ;
               OPTIONS { 'Uno', 'Dos', 'Tres', 'Cuatro' } ;
               WIDTH 80 ;
               SPACING 24 ;
               FONTCOLOR GREEN

            DEFINE CHECKBOX chk_1
               ROW 70
               COL 140
               WIDTH 160
               VALUE .F.
               CAPTION 'Texto Rojo a la Izquierda'
               THREESTATE .T.
               LEFTALIGN .T.
               FONTCOLOR RED
            END CHECKBOX
         END PAGE

      END TAB

      ON KEY ESCAPE ACTION Form_1.Release
   END WINDOW

   Form_1.Center
   Form_1.Activate

RETURN Nil

/*
 * EOF
 */
