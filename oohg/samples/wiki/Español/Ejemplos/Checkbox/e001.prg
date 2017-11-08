/*
 * Ejemplo Checkbox n° 1
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo definir un CheckBox del tipo
 * triestado alineado a la izquierda con fondo transparente
 * dentro de un control Tab.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 640 ;
      HEIGHT 480 ;
      TITLE 'ooHg - CheckBox con fondo transparente dentro de un Tab' ;
      MAIN

      DEFINE TAB Tab_1 ;
         AT 10,10 ;
         WIDTH 600 ;
         HEIGHT 400 ;
         VALUE 1

         PAGE 'Página &1'

            DEFINE CHECKBOX ChkBox
               ROW 70
               COL 10
               WIDTH 280
               VALUE .F.
               CAPTION 'CheckBox con Fondo Transparente'
               FONTCOLOR BLUE
               THREESTATE .T.
               LEFTALIGN .T.
            END CHECKBOX

         END PAGE

      END TAB

      ON KEY ESCAPE ACTION ThisWindow.Release()
   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN Nil

/*
 * EOF
 */
