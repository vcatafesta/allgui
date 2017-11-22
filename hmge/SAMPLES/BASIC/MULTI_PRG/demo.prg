/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2002-09 Roberto Lopez <harbourminigui@gmail.com>
* http://harbourminigui.googlepages.com/
*/

#include "minigui.ch"

#ifndef _HBMK_
SET Procedure To Other.Prg
#endif

FUNCTION Main

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH 640 HEIGHT 480 ;
         TITLE 'Harbour MiniGUI Demo' ;
         MAIN

   END WINDOW

   InOtherPrg()

   Form_1.Center

   Form_1.Activate

   RETURN NIL

STATIC PROCEDURE TEST

   RETURN

   EXIT PROCEDURE _AlwaysProcedure

   Application.Title := 'Press any key for close this window'
   WaitWindow('ALWAYS EXIT PROCEDURE')

   RETURN

