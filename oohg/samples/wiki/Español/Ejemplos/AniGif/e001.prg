/*
 * Ejemplo AniGIF n° 1
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo utilizar un control ANIGIF.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 *
 * Los archivos gmap1.html y gmap2.html pueden descargarse desde:
 * https://github.com/fyurisich/OOHG_Samples/tree/master/Español/Ejemplos/AniGif
 */

#include "oohg.ch"

PROCEDURE Main()

   SetOneArrayItemPerLine( .T. )

   DEFINE WINDOW Form_Main ;
      AT 0, 0 ;
      WIDTH 320 ;
      HEIGHT 240 ;
      TITLE 'ANIGIF Demo' ;
      MAIN

      DEFINE MAIN MENU
         MENUITEM 'Iniciar' ACTION oAniGif:Play()
         MENUITEM 'Detener' ACTION oAniGif:Stop()
         MENUITEM 'Info'    ACTION MostrarInfo()
         MENUITEM 'Salir'   ACTION Form_Main.Release()
      END MENU

      // desde disco
      @ 20, 20 ANIGIF myGIF_1 ;
         OBJ oAniGif ;
         FILE "ani-free.gif" ;
         BORDER

      // desde archivo rc
      @ 20, 200 ANIGIF myGIF_2 ;
         FILE "MYGIF" ;
         BORDER

      ON KEY ESCAPE ACTION ThisWindow.Release()
   END WINDOW

   CENTER WINDOW Form_Main
   ACTIVATE WINDOW Form_Main

RETURN


PROCEDURE MostrarInfo

   oAniGif:Stop()
   AutoMsgBox( { "Nombre"  + Chr( 9 ) + ": " + oAniGif:FileName, ;
                 "Versión" + Chr( 9 ) + ": " + oAniGif:Version, ;
                 "Ancho"   + Chr( 9 ) + ": " + LTrim( Str( oAniGif:FrameWidth ) ), ;
                 "Alto"    + Chr( 9 ) + ": " + LTrim( Str( oAniGif:FrameHeight ) ), ;
                 "Cuadros" + Chr( 9 ) + ": " + LTrim( Str( oAniGif:FrameCount ) ) }, ;
               "GIF Info" )
   oAniGif:Play()

RETURN

/*
 * EOF
 */
