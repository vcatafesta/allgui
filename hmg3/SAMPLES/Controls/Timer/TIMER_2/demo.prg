
#include "hmg.ch"

FUNCTION Main

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH 400 ;
         HEIGHT 400 ;
         TITLE 'Timer Test' ;
         MAIN

      DEFINE TIMER Timer_1 ;
         INTERVAL 10000 ;
         ACTION TimerTest()

   END WINDOW

   ACTIVATE WINDOW Form_1

   RETURN

PROCEDURE TimerTest()

   *   If time() == "11:00:00"
   *      RELEASE WINDOW MAIN
   *   EndIf

   Form_1.Timer_1.Enabled := .F.
   MsgInfo ('Hey')
   Form_1.Timer_1.Enabled := .T.

   RETURN
