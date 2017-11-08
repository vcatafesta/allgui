/*
 * Ejemplo Checkbox n° 3
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo crear un checkbox "transparente"
 * sobre un control image.
 *
 * El archivo fondo.jpg puede descargarse desde:
 * https://github.com/fyurisich/OOHG_Samples/tree/master/Español/Ejemplos/Checkbox
 */

#include "oohg.ch"

FUNCTION Main()
   LOCAL oImg

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 450 ;
      HEIGHT 400 ;
      CLIENTAREA ;
      MAIN ;
      TITLE "oohg - Checkbox con fondo transparente"

      @ 00, 00 IMAGE img_1 ;
         PICTURE "fondo.jpg" ;
         WIDTH 450 HEIGHT 400 ;
         OBJ oImg

      DEFINE CHECKBOX ChkBox
         ROW 70
         COL 10
         WIDTH 280
         VALUE .F.
         CAPTION 'CheckBox con Fondo Transparente'
         FONTCOLOR BLUE
         THREESTATE .T.
         LEFTALIGN .T.
         BACKGROUND oImg
      END CHECKBOX

      ON KEY ESCAPE ACTION Form_1.Release
   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN NIL

/*
 * EOF
 */
