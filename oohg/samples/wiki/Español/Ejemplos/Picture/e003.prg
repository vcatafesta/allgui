/*
 * Ejemplo Picture n° 3
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo funciona la cláusula STRETCH.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include 'oohg.ch'

FUNCTION Main
   LOCAL oWin

   SetOneArrayItemPerLine( .T. )

   DEFINE WINDOW frm_Main OBJ oWin ;
      AT 86,94 ;
      CLIENTAREA ;
      WIDTH 640 ;
      HEIGHT 480 ;
      TITLE 'Picture con cláusula STRETCH' ;
      MAIN

      @ 20,20 PICTURE pct_Image1 OBJ oPict1 ;
         WIDTH 240 ;
         HEIGHT 180 ;
         STRETCH ;
         PICTURE "ROTA.JPG" // 155 x 341

      DRAW RECTANGLE IN WINDOW frm_Main ;
         AT 20, 20 ;
         TO 200, 260 ;
         FILLCOLOR YELLOW

      @ 250,20 PICTURE pct_Image2 OBJ oPict2 ;
         WIDTH 400 ;
         HEIGHT 200 ;
         STRETCH ;
         PICTURE "LOGO.JPG" // 341 x 155

      DRAW RECTANGLE IN WINDOW frm_Main ;
         AT 250, 20 ;
         TO 450, 420 ;
         FILLCOLOR YELLOW

/*
   STRETCH   = Las dimensiones de la imagen son aumentadas
               o reducidas (ambas en la misma proporción)
               hasta que el ancho y/o el alto igualen
               el ancho y/o el alto del control.

   IMAGESIZE = El control es redimensionado para igualar las
               dimensiones de la imagen.

   NORESIZE  = La imagen se muestra en su tamaño, incluso
               si sobrepasa las dimensiones del control.
               Las dimensiones del control no se modifican.

   NEITHER   = image is scaled to control's dimensions
               (image's proportion may be changed).
*/

      ON KEY ESCAPE ACTION oWin:Release()
      ON KEY F9 ACTION AutoMsgBox( { "Control 1", ;
                                     "Ancho y Alto", ;
                                     oImage1:Width, ;
                                     oImage1:Height, ;
                                     "Ancho y Alto de la Imagen Original", ;
                                     oImage1:OriginalSize(), ;
                                     "Ancho y Alto de la Imagen Mostrada", ;
                                     oImage1:CurrentSize(), ;
                                     "Control 2", ;
                                     "Ancho y Alto", ;
                                     oImage2:Width, ;
                                     oImage2:Height, ;
                                     "Ancho y Alto de la Imagen Original", ;
                                     oImage2:OriginalSize(), ;
                                     "Ancho y Alto de la Imagen Mostrada", ;
                                     oImage2:CurrentSize() } )
   END WINDOW

   oWin:Center()
   oWin:Activate()

RETURN NIL

/*
 * EOF
 */
