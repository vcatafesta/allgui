/*
* DO REPORT DEMO
* (c) 2016 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

FUNCTION Main

   USE country alias test
   INDEX ON padr(field->CONTINENT,20)+padr(field->NAME,28) to test

   DEFINE WINDOW Win1         ;
         ROW   10         ;
         COL   10         ;
         WIDTH   400         ;
         HEIGHT   400         ;
         TITLE   'Do Report Demo'   ;
         MAIN            ;
         ON INIT   Win1.Center()

      @ 40 , 40 Button Button1   ;
         CAPTION 'Create Report'   ;
         WIDTH   120      ;
         On Click ButtonClick()   ;
         DEFAULT

   END WINDOW

   ACTIVATE WINDOW Win1

   RETURN NIL

PROCEDURE ButtonClick()

   DbGoTop()

   do report ;
      TITLE  'COUNTRIES SUMMARY'                                   ;
      HEADERS  {} , { padc('Name',28), padc('Capital',15),         ;
      padc('Area',11), padc('Population',14) }     ;
      FIELDS   {'Name', 'Capital', 'Area', 'Population'}           ;
      WIDTHS   {28,15,11,14}                                       ;
      totals   {.F.,.F.,.T.,.T.}                                   ;
      nformats {'','','999 999 999','99 999 999 999'}              ;
      WORKAREA Test                                                ;
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
