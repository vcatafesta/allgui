/*
* MiniGUI ToolBar Demo
*/

#include "minigui.ch"

FUNCTION Main

   USE MTIEMPO

   LOAD WINDOW Report
   ACTIVATE WINDOW Report

   RETURN NIL

PROCEDURE TestReport

   GO TOP
   DO REPORT FORM RepDemo

   RETURN
