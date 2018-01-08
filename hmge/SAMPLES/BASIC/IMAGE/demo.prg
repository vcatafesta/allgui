/*
* MINIGUI - Harbour Win32 GUI library Demo
* (c) 2016 Grigory Filatov <gfilatov@inbox.ru>
*/

#include <hmg.ch>

FUNCTION Main

   DEFINE WINDOW win_1 ;
         MAIN ;
         clientarea 300, 300 ;
         TITLE "JPEG Image From Resource" ;
         BACKCOLOR TEAL nosize

      ON KEY ESCAPE ACTION win_1.release()

      DEFINE IMAGE image_1
         ROW 50
         COL 75
         WIDTH 150
         HEIGHT 200
         PICTURE 'OLGA'
         STRETCH .T.
      END IMAGE

   END WINDOW

   draw panel in window win_1 ;
      at win_1.image_1.Row - 2, win_1.image_1.Col - 2 ;
      to win_1.image_1.Row + win_1.image_1.height + 1, win_1.image_1.Col + win_1.image_1.width + 1

   win_1.minbutton := .F.
   win_1.maxbutton := .F.

   win_1.center
   win_1.activate

   RETURN NIL
