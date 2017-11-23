#include 'oohg.ch'

FUNCTION Main()

   LOAD WINDOW fp
   CENTER WINDOW fp
   ACTIVATE WINDOW fp

   RETURN NIL

FUNCTION rep()

   SET language to english
   wempresa:="hollywood"
   USE test
   DO REPORT FORM repdemo
   CLOSE data

   RETURN

FUNCTION toolbar()

   /*
   load window tbarsamp
   center window tbarsamp
   activate window tbarsamp
   */

   RETURN NIL

FUNCTION abre()

   USE test

   RETURN NIL

FUNCTION cierra()

   CLOSE data

   RETURN NIL

   #include 'prgspi.prg'
   #include 'p2.prg'
