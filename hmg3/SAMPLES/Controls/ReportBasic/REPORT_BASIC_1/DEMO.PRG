#include 'hmg.ch'

PROCEDURE main()

   SET LANGUAGE TO SPANISH

   DEFINE WINDOW pr_form ;
         at 0,0 ;
         WIDTH 100;
         HEIGHT 100 ;
         TITLE 'DO REPORT Test' ;
         main

      DEFINE MAIN MENU
         POPUP 'File'
            ITEM 'Do Report Test' ACTION printtest()
         END POPUP
      END MENU

   END WINDOW

   ACTIVATE WINDOW pr_form

   RETURN NIL

FUNCTION printtest()

   USE test
   INDEX ON first to lista
   SET DATE ANSI
   SET CENTURY ON

   DO REPORT ;
      TITLE      'INFORME DE ARTISTAS DE CINE | segundo titulo'         ;
      HEADERS      {'','','',''} , {'SIMPLE','APELLIDO','DOBLE','INGRESOS'}   ;
      FIELDS      {'code','last','BIO','incoming'}            ;
      WIDTHS      {10,20,25,14}                     ;
      TOTALS      {.F.,.F.,.F.,.T.}                  ;
      NFORMATS   {'','','','999,999,999.99'}               ;
      WORKAREA   Test                        ;
      LPP      50                        ;
      CPL      80                        ;
      LMARGIN      2                        ;
      PAPERSIZE   DMPAPER_A4                     ;
      PREVIEW                              ;
      SELECT                              ;
      MULTIPLE                           ;
      GROUPED BY   'first'                        ;
      HEADRGRP   'Name'

   RETURN NIL
