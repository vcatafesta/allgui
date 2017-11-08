/*
 * Ejemplo Image n° 8
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo pintar una imagen utilizando
 * los controles IMAGE y PICTURE. Dado que estos controles
 * usan diferentes métodos para pintar, es posible que una
 * imagen no sea pintada en la misma forma. En tal caso,
 * por favor envíeme un pequeño ejemplo y trataré de
 * solucionar el problema.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 *
 * El archivo oohg.gif puede descargarse desde:
 * https://github.com/fyurisich/OOHG_Samples/tree/master/Español/Ejemplos/Image
 */

#include "oohg.ch"

FUNCTION Main

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 640 ;
      HEIGHT 480 ;
      TITLE 'Case de Prueba Image vs Picture' ;
      MAIN ;
      BACKCOLOR CYAN

      @ 0,300 IMAGE Img_1 ;
         WIDTH 200;
         HEIGHT 150;
         PICTURE 'oohg.gif' ;
         ON CLICK MsgBox( "Soy un control IMAGE !!!")

      @ 0,0 PICTURE Img_2 ;
         WIDTH 200;
         HEIGHT 150;
         PICTURE 'oohg.gif' ;
         ON CLICK MsgBox( "Soy un control PICTURE !!!")

      /*
       * Note que IMAGE usa IMAGESIZE por defecto y
       * PICTURE usa STRETCH por defecto.
       */

      ON KEY ESCAPE ACTION Form_1.Release()
   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN NIL

/*
 * EOF
 */
