/*
* MiniGUI Window BackColor Demo
* (c) 2005 Grigory Filatov
*/

#include "minigui.ch"

STATIC nColor := 1, ;
   aColors := { { 255 , 255 , 0 }, { 255 , 128 , 192 }, { 255 , 0 , 0 }, ;
   { 255 , 0 , 255 }, { 255 , 128 , 64 }, { 0 , 255 , 0 }, { 128 , 0 , 128 }, ;
   { 255 , 255 , 255 }, { 128 , 128 , 128}, { 0 , 0 , 255 }, { 192 , 192 , 192 } }

PROCEDURE Main

   SET MULTIPLE OFF

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH 640 ;
         HEIGHT 480 ;
         TITLE 'Set Window BackColor Demo (Contributed by Grigory Filatov)' ;
         MAIN ;
         BACKCOLOR WHITE

      DEFINE TIMER Timer_1 INTERVAL 2000 ACTION SetBackColor()

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

   RETURN

PROCEDURE SetBackColor()

   nColor++

   IF nColor > Len(aColors)
      nColor := 1
   ENDIF

   ThisWindow.BackColor := aColors[nColor]

   RETURN
