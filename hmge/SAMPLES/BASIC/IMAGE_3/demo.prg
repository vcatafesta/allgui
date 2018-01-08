/*
* MINIGUI - Harbour Win32 GUI library Demo
* (c) 2017 Grigory Filatov <gfilatov@inbox.ru>
*/

#include <hmg.ch>

FUNCTION Main

   LOCAL cURL1 := "https://upload.wikimedia.org/wikipedia/commons/c/c8/Taj_Mahal_in_March_2004.jpg"
   LOCAL cURL2 := "http://cdn.history.com/sites/2/2015/04/hith-eiffel-tower-iStock_000016468972Large.jpg"

   DEFINE WINDOW win_1 ;
         main ;
         clientarea 800, 633 ;
         TITLE "JPEG Image From URL" ;
         BACKCOLOR { 204, 220, 240 } nosize

      ON KEY ESCAPE ACTION win_1.release()

      DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 100,16 FLAT

         BUTTON Button_1 ;
            CAPTION 'EiffelTower' ;
            ACTION ( Win_1.Image_1.Picture := cUrl2 ) ;
            TOOLTIP 'Load Eiffel Tower background'

         BUTTON Button_2 ;
            CAPTION 'TajMahal' ;
            ACTION ( Win_1.Image_1.Picture := cUrl1 ) ;
            TOOLTIP 'Load Taj Mahal background'

      END TOOLBAR

      DEFINE IMAGE image_1
         ROW 33
         COL 0
         WIDTH 800
         HEIGHT 600
         PICTURE cURL2
         STRETCH .T.
      END IMAGE

   END WINDOW

   win_1.minbutton := .F.
   win_1.maxbutton := .F.

   win_1.center
   win_1.activate

   RETURN NIL
