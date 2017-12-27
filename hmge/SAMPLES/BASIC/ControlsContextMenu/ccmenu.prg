/*
* MiniGUI ControlS Context Menu Extension
* by Adam Lubszczyk
* mailto:adam_l@poczta.onet.pl
*/

#include "minigui.ch"

PROCEDURE Main

   LOAD WINDOW CCMenu
   ACTIVATE WINDOW CCMenu

   RETURN

   // *****************************************

FUNCTION MenuText_1(lShow)

   IF lShow
      SET CONTEXT MENU CONTROL Text_1 OF ccmenu ON
   ELSE
      SET CONTEXT MENU CONTROL Text_1 OF ccmenu OFF
   ENDIF

   RETURN NIL

   // *******************************************

FUNCTION CheckCMenu

   IF ccmenu.check_1.value
      SET CONTEXTMENU CONTROL check_1 OF ccmenu ON
   ELSE
      SET CONTEXTMENU CONTROL check_1 OF ccmenu OFF
   ENDIF

   RETURN NIL
