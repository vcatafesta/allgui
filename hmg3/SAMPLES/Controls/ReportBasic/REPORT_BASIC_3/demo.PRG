#include 'hmg.ch'

FUNCTION main()

   DECLARE window form_1
   DEFINE WINDOW form_1 ;
         AT 0,0 ;
         WIDTH 400 ;
         HEIGHT 400 ;
         TITLE 'hola' ;
         MAIN

      @ 40,10 button b_2 caption 'Do External Report (.rpt)' action testrepo() WIDTH 150

   END WINDOW
   ACTIVATE WINDOW form_1

   RETURN

FUNCTION testrepo()

   wempresa:='sistemas c.v.c'
   USE mtiempo
   INDEX ON usuario to lista
   GO TOP
   DO REPORT FORM repdemo
   USE

   RETURN
