#include "oohg.ch"

* Autor: Daniel Piperno (dpiperno@montevideo.com.uy)
* Descripci¢n: Incluyendo el programa MINIFRM.PRG en el proyecto, se
* podr n imprimir reportes con el comando REPORT FORM, utilizando los
* archivos FRM est ndar y todas las herramientas existentes.
* Se puede usar MINIPRINT o HBPRINTER, cambiando el #define correspondiente
* modificado por ciro vargas clemow para adaptarlo a la clase TPRINT

FUNCTION Main

   PUBLIC _OOHG_printlibrary:="MINIPRINT"

   REQUEST dbfntx,dbfdbt

   SET INTERACTIVECLOSE OFF
   DEFINE WINDOW Form_Main obj oWind ;
         AT 0,0 ;
         WIDTH 300 ;
         HEIGHT 300 ;
         TITLE 'DO report Form and Do report sample' ;
         MAIN

      DEFINE MAIN MENU
         POPUP 'Test '
            ITEM 'REPORT FORM TEST1 (normal)'     ACTION PrintNormal()
            ITEM 'REPORT FORM TEST2 (condensed)'  ACTION PrintCondensed()
            ITEM 'DO REPORT  TEST1 (normal)'     ACTION PrintNormal1()
            ITEM 'DO REPORT  TEST2 (condensed)'  ACTION PrintCondensed1()
            ITEM 'EXIT' ACTION {|| owind:release() }
         END POPUP
      END MENU

      @ 20,20 radiogroup RAdio_1 options {"Hbprinter","miniprint","excel","rtf","html","PDF"} value 2 autosize on change cambialib()

   END WINDOW

   USE TEST
   INDEX ON GROUP + Str(CODE,5) TO TEST

   CENTER WINDOW Form_Main
   ACTIVATE WINDOW Form_Main

   RETURN NIL

FUNCTION cambialib()

   nopcion:=owind:radio_1:value
   DO CASE
   CASE nopcion=1
      _OOHG_printlibrary:="HBPRINTER"
   CASE nopcion=3
      _OOHG_printlibrary:="EXCELPRINT"

   CASE nopcion=4
      _OOHG_printlibrary:="RTFPRINT"

   CASE nopcion=5
      _OOHG_printlibrary:="HTMLPRINT"
   CASE nopcion=6
      _OOHG_printlibrary:="PDFPRINT"
   OTHERWISE
      _OOHG_printlibrary:="MINIPRINT"
   ENDCASE

   RETURN NIL

   /////#include "MINIFRM.PRG"

FUNCTION PrintNormal()

   REPORTFORMWIN TEST1 HEADING "PRUEBA 1"

   RETURN NIL

FUNCTION PrintCondensed()

   REPORTFORMWIN TEST2 HEADING "PRUEBA 2"

   RETURN NIL

FUNCTION PrintNormal1()

   GO TOP

   DO REPORT  ;
      TITLE 'PRUEBA1|REPORTE DE PRUEBA'   ;
      HEADERS {' ',' ',' '} ,  {'CODE','FIRST','LAST'}  ;
      FIELDS {'code','first','last'}                    ;
      WIDTHS {10 , 30 , 19}                                  ;
      TOTALS {.T. , .F. , .F.}                               ;
      WORKAREA test                                      ;
      LPP 55                                             ;
      CPL 80                                             ;
      LMARGIN 0                                          ;
      PAPERSIZE DMPAPER_LETTER                           ;
      PREVIEW                                            ;
      SELECT                                             ;
      GROUPED BY 'GROUP'                                  ;
      HEADRGRP 'Group Field'

   RETURN NIL

FUNCTION PrintCondensed1()

   GO TOP

   do report form test4

   RETURN NIL

