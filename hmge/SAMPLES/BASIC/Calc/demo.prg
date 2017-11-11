#include "minigui.ch"

SET Proc To Calc.prg

FUNCTION Main

   LOAD WINDOW Demo As Main

   ON KEY F2 OF Main ACTION RunCalc()

   Main.Center
   Main.Activate

   RETURN NIL

FUNCTION RunCalc()

   Main.Text_1.Value := ShowCalc(Main.Text_1.Value)
   Main.Text_2.Value := System.ClipBoard

   RETURN NIL

