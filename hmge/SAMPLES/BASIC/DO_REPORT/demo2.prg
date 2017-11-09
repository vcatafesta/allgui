/*
* DO REPORT DEMO
* (c) 2016 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

FUNCTION Main

   USE country alias test
   INDEX ON padr(field->CONTINENT,20)+padr(field->NAME,28) to test

   DEFINE WINDOW Win1         ;
         Row   10         ;
         Col   10         ;
         Width   400         ;
         Height   400         ;
         Title   'Do Report Demo'   ;
         MAIN            ;
         On Init   Win1.Center()

      @ 40 , 40 Button Button1   ;
         Caption 'Create Report'   ;
         Width   120      ;
         On Click ButtonClick()   ;
         DEFAULT

   END WINDOW

   ACTIVATE WINDOW Win1

   RETURN NIL

PROCEDURE ButtonClick()

   DbGoTop()

   do report ;
      title  'COUNTRIES SUMMARY'                                   ;
      headers  {} , { padc('Name',28), padc('Capital',15),         ;
      padc('Area',11), padc('Population',14) }     ;
      fields   {'Name', 'Capital', 'Area', 'Population'}           ;
      widths   {28,15,11,14}                                       ;
      totals   {.F.,.F.,.T.,.T.}                                   ;
      nformats {'','','999 999 999','99 999 999 999'}              ;
      workarea Test                                                ;
      lpp      55                                                  ;
      cpl      77                                                  ;
      lmargin  4                                                   ;
      tmargin  4                                                   ;
      papersize DMPAPER_A4                                         ;
      preview                                                      ;
      SELECT                                                       ;
      multiple                                                     ;
      grouped by 'CONTINENT'                                       ;
      headrgrp padc('Continent',23)                                ;
      nodatetimestamp

   RETURN

