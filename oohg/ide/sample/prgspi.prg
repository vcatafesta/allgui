/*
*         IDE: HMI+
*     Project: C:\ANALISIS\vd1\install\ciro.pmg
*        Item: prgspi.prg
* Description:
*      Author:
*        Date: 2003.07.01
*/

#include 'minigui.ch'

FUNCTION prgspi()

   LOCAL i

   DECLARE window fp
   FOR i:=1 to 65000 step 15
      fp.progressbar_101.value := i
   NEXT i

   RETURN NIL

