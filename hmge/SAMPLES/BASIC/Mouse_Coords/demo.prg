/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
* http://harbourminigui.googlepages.com/
* MOUSEMOVE demo
* (C) 2006 Jacek Kubica <kubica@wssk.wroc.pl>
*/

#include "MiniGUI.ch"

PROCEDURE main()

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH 348 ;
         HEIGHT 176 ;
         MAIN ;
         TITLE "Mouse Test" ;
         ON MOUSEMOVE DisplayCoords()

   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

   RETURN

PROCEDURE DisplayCoords()

   LOCAL aCoords:={}

   aCoords := GETCURSORPOS()
   Form_1.Title:= "Pos y: "+ PADL(aCoords[1]-Form_1.Row-GetTitleHeight()-GetBorderHeight(), 4) + ;
      " Pos x: "+ PADL(aCoords[2]-Form_1.Col-GetBorderWidth(), 4)

   RETURN
