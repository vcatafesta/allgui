/*
* MiniGUI Execute File Demo
*/

#include "minigui.ch"

STATIC lContinue

FUNCTION Main

   DEFINE WINDOW Win_1 ;
         AT 0,0 ;
         WIDTH 400 ;
         HEIGHT 400 ;
         TITLE 'Execute File Demo' ;
         MAIN

      DEFINE BUTTON B1
         ROW 10
         COL 10
         CAPTION 'Execute'
         ACTION ExecTest()
      END BUTTON

      DEFINE BUTTON B2
         ROW 45
         COL 10
         CAPTION 'Execute Wait'
         ACTION ExecTest2()
      END BUTTON

   END WINDOW

   ACTIVATE WINDOW Win_1

   RETURN NIL

PROCEDURE ExecTest()

   lContinue := .F.

   EXECUTE FILE "NOTEPAD.EXE"

   RETURN

PROCEDURE ExecTest2()

   lContinue := .T.

   EXECUTE FILE "NOTEPAD.EXE" WAIT WHILE DoWhile() INTERVAL 500

   RETURN

FUNCTION DoWhile

   DO EVENTS

   RETURN lContinue

