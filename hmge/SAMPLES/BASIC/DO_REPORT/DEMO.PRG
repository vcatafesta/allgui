/*
* MINIGUI - Harbour Win32 GUI library Demo
* 2010-05-26 Edited by Alexey L. Gustow <gustow33 @ mail.ru> ("GAL")
* - translation to English (mainly in report definitions)
* - little reformatting
* - todo: translating memo's (Test->BIO) fields from Spanish to English
*/

#include "minigui.ch"

FUNCTION Main()

   SET LANGUAGE TO ENGLISH    // GAL (changed from SPANISH")

   SET CENTURY ON
   SET DATE ANSI

   USE test
   INDEX ON field->first to lista   // ".NTX" (by default)

   DEFINE WINDOW Pr_Form ;
         at 0,0 ;
         width 200 ;
         height 100 ;
         title 'DO REPORT Tests' ;
         main ;
         on release ( DbCloseArea(), FErase("lista.ntx") )

      DEFINE MAIN MENU
         POPUP 'File'
            item 'Do Report Test'  action PrintTest()
            item 'Do Report Test2' action PrintTest2()
            item 'Do Report Test3' action PrintTest3()
            item 'Do Report Test4' action PrintTest4()
            SEPARATOR
            item 'Exit'            action ThisWindow.Release
         END POPUP
      END MENU

   END WINDOW

   ACTIVATE WINDOW Pr_Form

   RETURN NIL

FUNCTION PrintTest()

   DbGoTop()    // in "Test.dbf"

   do report ;
      title  'REPORT OF CINEMA ARTISTS | second title'                        ;
      headers  {'','','',''} , { 'SIMPLE', 'LAST NAME', 'BIO', 'INCOME' }     ;
      fields   {'code','last','BIO','incoming'}                               ;
      widths   {10,20,26,14}                                                  ;
      totals   {.F.,.F.,.F.,.T.}                                              ;
      nformats {'','','','@E 99,999,999.99'}                                  ;
      workarea Test                                                           ;
      lpp      55                                                             ;
      cpl      77                                                             ;
      lmargin  3                                                              ;
      tmargin  3                                                              ;
      papersize DMPAPER_A4                                                    ;
      preview                                                                 ;
      SELECT                                                                  ;
      multiple                                                                ;
      grouped by 'first'                                                      ;
      headrgrp 'Name'                                                         ;
      nodatetimestamp

   RETURN NIL

FUNCTION PrintTest2()

   DbGoTop()
   DO REPORT FORM REPORT2

   RETURN NIL

FUNCTION PrintTest3()

   DbGoTop()
   DO REPORT FORM REPORT3

   RETURN NIL

FUNCTION PrintTest4()

   DbGoTop()
   DO REPORT FORM REPORT4

   RETURN NIL
