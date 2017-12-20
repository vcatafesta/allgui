/*
* MiniGUI ControlPos demo
* by Adam Lubszczyk
* mailto:adam_l@poczta.onet.pl
*/

#include "minigui.ch"

SET procedure to "_controlpos3_.prg"

MEMVAR _ControlPosFirst_
MEMVAR _ControlPosProperty_
MEMVAR _ControlPosSizeRect_
MEMVAR _ControlPos_Save_Option_

FUNCTION Main

   LOAD WINDOW test
   LOAD WINDOW dialog AS form_2

   controlposSTART()

   ACTIVATE WINDOW test,form_2

   RETURN NIL
