/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
* http://harbourminigui.googlepages.com/
* Copyright 2006 MigSoft <fugaz_cl@yahoo.es>
*/

#include <hmg.ch>

#xtranslate PRINT GRAPH [ OF ] <windowname> ;
   [ <lpreview : PREVIEW> ] ;
   [ <ldialog : DIALOG> ] ;
   =>;
   printgraph ( <"windowname"> , <.lpreview.> , <.ldialog.> )

STATIC aSer, aClr, aSern, aYVal, cTit

FUNCTION Main

   SET Navigation extended

   LOAD WINDOW Grafico
   CENTER WINDOW Grafico
   ACTIVATE WINDOW Grafico

   RETURN NIL

PROCEDURE Presenta(nTipo)

   DO CASE
   CASE nTipo = 0         //  Histogram

      aSer:= {{Grafico.Text_5.value,Grafico.Text_9.value,Grafico.Text_13.value}, ;
         {Grafico.Text_6.value,Grafico.Text_10.value,Grafico.Text_14.value},;
         {Grafico.Text_7.value,Grafico.Text_11.value,Grafico.Text_15.value},;
         {Grafico.Text_8.value,Grafico.Text_12.value,Grafico.Text_16.value} }

      aClr:= {Grafico.Label_5.Fontcolor,Grafico.Label_6.Fontcolor, ;
         Grafico.Label_7.Fontcolor,Grafico.Label_8.Fontcolor}

      aSern:={Grafico.Text_1.value,Grafico.Text_2.value, ;
         Grafico.Text_3.value,Grafico.Text_4.value }

      aYVal:={Grafico.Text_17.value,Grafico.Text_18.value,Grafico.Text_19.value }

      cTit:= Grafico.Text_20.value

      SET Font To "Arial", 14
      LOAD WINDOW Veamos
      On Key Escape Of Veamos Action Veamos.Release
      CENTER WINDOW Veamos
      ACTIVATE WINDOW Veamos

   CASE nTipo = 1       //  Pie 1

      cTit:= Grafico.Text_1.value
      aSer:= {Grafico.Text_5.value,Grafico.Text_9.value,Grafico.Text_13.value}

   CASE nTipo = 2       //  Pie 2

      cTit:= Grafico.Text_2.value
      aSer:= {Grafico.Text_6.value,Grafico.Text_10.value,Grafico.Text_14.value}

   CASE nTipo = 3       //  Pie 3

      cTit:= Grafico.Text_3.value
      aSer:= {Grafico.Text_7.value,Grafico.Text_11.value,Grafico.Text_15.value}

   CASE nTipo = 4       //  Pie 4

      cTit:= Grafico.Text_4.value
      aSer:= {Grafico.Text_8.value,Grafico.Text_12.value,Grafico.Text_16.value}

   CASE nTipo = 5       //  Pie 5

      cTit:= Grafico.Text_17.value
      aSer:= {Grafico.Text_5.value,Grafico.Text_6.value,;
         Grafico.Text_7.value,Grafico.Text_8.value }

   CASE nTipo = 6       //  Pie 6

      cTit:= Grafico.Text_18.value
      aSer:= {Grafico.Text_9.value ,Grafico.Text_10.value,;
         Grafico.Text_11.value,Grafico.Text_12.value }

   CASE nTipo = 7       //  Pie 7

      cTit:= Grafico.Text_19.value
      aSer:= {Grafico.Text_13.value,Grafico.Text_14.value,;
         Grafico.Text_15.value,Grafico.Text_16.value }

   ENDCASE

   IF nTipo > 0 .and. nTipo < 8
      IF nTipo < 5
         aYVal:={Grafico.Text_17.value,Grafico.Text_18.value,Grafico.Text_19.value}
         aClr:= {Grafico.Label_3.Fontcolor,Grafico.Label_4.Fontcolor, ;
            Grafico.Label_11.Fontcolor }
      ELSE
         aYVal:={Grafico.Text_1.value,Grafico.Text_2.value,;
            Grafico.Text_3.value,Grafico.Text_4.value }
         aClr:= {Grafico.Label_5.Fontcolor,Grafico.Label_6.Fontcolor,;
            Grafico.Label_7.Fontcolor,Grafico.Label_8.Fontcolor }
      ENDIF
      SET Font To "Arial", 12
      LOAD WINDOW Veamos2
      CENTER WINDOW Veamos2
      ACTIVATE WINDOW Veamos2
   ENDIF

   RETURN

PROCEDURE elGrafico()

   LOCAL nTop := 20, nLeft := 20, nBottom := 400, nRight := 610

   ERASE WINDOW Veamos

   DRAW GRAPH                     ;
      IN WINDOW Veamos                                        ;
      AT nTop, nLeft                  ;
      TO nBottom, nRight               ;
      TITLE cTit                                              ;
      TYPE BARS                  ;
      SERIES aSer                                             ;
      YVALUES aYval                                           ;
      DEPTH 15                  ;
      BARWIDTH 15                  ;
      HVALUES 5                  ;
      SERIENAMES aSern                                        ;
      COLORS aClr                                             ;
      3DVIEW                      ;
      SHOWGRID                                 ;
      SHOWXVALUES                              ;
      SHOWYVALUES                              ;
      SHOWLEGENDS                   ;
      NOBORDER DATAMASK "9999"

   App.Cargo := { nTop , nLeft , nRight - nLeft , nBottom - nTop }

   RETURN

PROCEDURE PieGraph()

   ERASE Window Veamos2

   DRAW GRAPH IN WINDOW Veamos2 AT 20,20 TO 400,610   ;
      TITLE cTit TYPE PIE            ;
      SERIES aSer               ;
      DEPTH 15               ;
      SERIENAMES aYVal            ;
      COLORS aClr               ;
      3DVIEW                  ;
      SHOWXVALUES               ;
      SHOWLEGENDS               ;
      NOBORDER

   RETURN

FUNCTION printgraph ( cWindowName , lPreview , lDialog )

   LOCAL aLocation

   IF .Not. _IsWindowDefined ( cWindowName )
      MsgMiniGUIError ("Window: "+ cWindowName + " is not defined.")
   ENDIF

   IF ValType ( App.Cargo ) <> 'A' .And. Len ( App.Cargo ) <> 4
      MsgMiniGUIError ("Window: "+ cWindowName + " have not a graph.")
   ENDIF

   IF ValType ( lPreview ) == 'U'
      lPreview := .F.
   ENDIF

   IF ValType ( lDialog ) == 'U'
      lDialog := .F.
   ENDIF

   aLocation := App.Cargo

   PrintWindow ( cWindowName , lPreview , lDialog , aLocation [1] , aLocation [2] , aLocation [3] , aLocation [4] )

   RETURN NIL

