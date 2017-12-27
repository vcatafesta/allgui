/*
* MiniGUI Activex Demo
*/

#include "minigui.ch"

FUNCTION Main

   SET AUTOADJUST ON NOBUTTONS

   LOAD WINDOW Demo
   ACTIVATE WINDOW Demo

   RETURN NIL

PROCEDURE demo_button_1_action

   Demo.Activex_1.Object:Navigate("http://hmgextended.com")

   RETURN
