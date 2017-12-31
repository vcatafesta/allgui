/*
* Author: P.Chornyj <myorg63@mail.ru>
*/
ANNOUNCE RDDSYS

#include "minigui.ch"

PROCEDURE main()

   DEFINE WINDOW Form_Main ;
         at 0,0 ;
         width 320 height 240 ;
         title 'fn:BmpSize() Demo' ;
         main ;
         nomaximize nosize

      DEFINE MAIN MENU
         DEFINE POPUP "&File"
            MENUITEM '&Open' action( ;
               Form_Main.Image_1.Picture := ;
               GetFile( { {'Bmp Files', '*.bmp'} }, 'Open a File', GetCurrentFolder(), .f., .t. ) ;
               )
            SEPARATOR
            MENUITEM "E&xit" action ThisWindow.Release
         END POPUP
      END MENU

      @ 20, 20 image Image_1 ;
         picture 'DEMO' ;
         action Image_1_OnClick( Form_Main.Image_1.Picture ) ;
         adjust ;
         tooltip 'Click Me'

   END WINDOW

   Form_Main.Center()
   Form_Main.Activate()

   RETURN

STATIC PROCEDURE Image_1_OnClick( cName )

   LOCAL aPictInfo := BmpSize( cName )
   LOCAL cMsg

   cMsg := "Picture name:" + Chr(9) + cFileNoPath( cName ) + CRLF
   cMsg += "Image Width:"  + Chr(9) + hb_NtoS( aPictInfo[1] ) + CRLF
   cMsg += "Image Height:" + Chr(9) + hb_NtoS( aPictInfo[2] ) + CRLF
   cMsg += "BitsPerPixel:" + Chr(9) + hb_NtoS( aPictInfo[3] ) + CRLF

   cMsg += "Image has Alpha:" + Chr(9) + If( HasAlpha( cName ), 'TRUE', 'FALSE' )

   MsgInfo( cMsg, 'Bitmap Info' )

   RETURN
