/*
*         IDE: HMI+
*     Project: C:\ANALISIS\vd1\install\ciro.pmg
*        Item: Main.prg
* Description:
*      Author:
*        Date: 2004.12.01
*/

#include 'oohg.ch'

FUNCTION Main()

   SET CENTURY ON
   SET DATE ANSI
   msginfo("Welcome ooHG users.","The ooHG IDE+ world")
   p1()
   LOAD WINDOW fp
   CENTER WINDOW fp
   ACTIVATE WINDOW fp

   RETURN NIL

FUNCTION toolbar()

   /*
   load window tbarsamp
   center window tbarsamp
   activate window tbarsamp
   */

   RETURN NIL

FUNCTION rep()

   LOCAL wempresa

   SET language to english
   wempresa:="hollywood"
   USE test
   DO REPORT FORM repdemo
   CLOSE data

   RETURN NIL

FUNCTION abre()

   USE test

   RETURN NIL

FUNCTION cierra()

   CLOSE data

   RETURN NIL
