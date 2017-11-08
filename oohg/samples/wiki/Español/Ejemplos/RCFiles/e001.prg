/*
 * Ejemplo Archivos RC n° 1
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo incluir imagenes desde un archivo de
 * recursos, de forma que las mismas queden embebidas en el ejecutable
 * cuando el programa se compila.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 *
 * El archivo de recursos asociado puede descargarse desde:
 * https://github.com/fyurisich/OOHG_Samples/tree/master/Español/Ejemplos/RCFiles
 */

#include "oohg.ch"

PROCEDURE Main()

   DEFINE WINDOW Form_Main ;
      AT 0,0 ;
      CLIENTAREA ;
      WIDTH 364 ;
      HEIGHT 243 ;
      TITLE 'Caso de prueba para la carga de imagenes desde un archivo RC' ;
      MAIN ;
      ICON "APPICON"

      @ 1, 1 IMAGE Image_1 ;
         PICTURE "DEMO1" ;
         IMAGESIZE ;
         TOOLTIP "BITMAP"

      @ 1, 122 IMAGE Image_2 ;
         PICTURE "DEMO2" ;
         IMAGESIZE ;
         TOOLTIP "GIF"

      @ 1, 243 IMAGE Image_3 ;
         PICTURE "DEMO3" ;
         IMAGESIZE ;
         TOOLTIP "JPG"

      @ 121, 1 IMAGE Image_4 ;
         PICTURE "DEMO4" ;
         IMAGESIZE ;
         TOOLTIP "PNG"

      @ 121, 122 IMAGE Image_5 ;
         PICTURE "DEMO5" ;
         IMAGESIZE ;
         TOOLTIP "TIFF"

      @ 121, 243 IMAGE Image_6 ;
         PICTURE "DEMO6" ;
         IMAGESIZE ;
         TOOLTIP "ICON"

      ON KEY ESCAPE ACTION ThisWindow.Release
   END WINDOW

   CENTER WINDOW Form_Main
   ACTIVATE WINDOW Form_Main
RETURN

/*
 * EOF
 */
