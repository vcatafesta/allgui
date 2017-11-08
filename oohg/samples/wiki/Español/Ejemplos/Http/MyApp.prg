/*
 * Ejemplo HTTP Sample n° 2
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Guarde este archivo cómo "MyApp.prg".
 * Se necesita para probar el ejemplo.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki

 * Este archivo y el ejemplo asociado pueden descargarse desde:
 * https://github.com/fyurisich/OOHG_Samples/tree/master/Español/Ejemplos/Http
 */

#include "oohg.ch"

FUNCTION Main( cAct )

   IF ! hb_IsString( cAct )
      cAct := "N"
   ENDIF

   DEFINE WINDOW Win_1 ;
      AT 0,0 ;
      WIDTH 640 ;
      HEIGHT 480 ;
      TITLE 'Hola Mundo !!!' ;
      MAIN

      @ 10, 10 LABEL lbl_Act ;
         AUTOSIZE ;
         VALUE IF( cAct == "T", "La aplicación fue actualizada !!!", "La aplicación no fue actualizada !!!" )

      ON KEY ESCAPE ACTION Win_1.Release
   END WINDOW

   CENTER WINDOW Win_1
   ACTIVATE WINDOW Win_1

RETURN Nil

/*
 * EOF
 */
