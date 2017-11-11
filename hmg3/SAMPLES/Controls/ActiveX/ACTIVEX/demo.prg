/*
* HMG Activex Demo
*/

#include "hmg.ch"

FUNCTION Main

   LOAD WINDOW Demo
   ACTIVATE WINDOW Demo

   RETURN

PROCEDURE demo_button_1_action

   Demo.Activex_1.Object:Navigate("http://www.hmgforum.com/")

   RETURN

