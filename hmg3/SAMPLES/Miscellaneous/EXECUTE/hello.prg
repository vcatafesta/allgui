/*
* HMG Hello World Demo
*/

#include "hmg.ch"

FUNCTION Main

   DEFINE WINDOW Win_1 ;
         AT 0,0 ;
         WIDTH 400 ;
         HEIGHT 400 ;
         TITLE 'Hello World!' ;
         MAIN

      DEFINE BUTTON B1
         ROW 10
         COL 10
         CAPTION 'Execute'
         ACTION ExecTest()
      END BUTTON

   END WINDOW

   ACTIVATE WINDOW Win_1

   RETURN

PROCEDURE ExecTest()

   EXECUTE FILE "NOTEPAD.EXE"

   RETURN NIL

