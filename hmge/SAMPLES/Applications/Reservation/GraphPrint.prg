/*******************************************************************************
Filename         : GraphPrint.prg

Created         : 05 April 2012 (10:50:55)
Created by      : Pierpaolo Martinello

Last Updated      : 01/11/2014 16:36:34
Updated by      : Pierpaolo

Comments         : Freeware
*******************************************************************************/

#include "minigui.ch"
MEMVAR acolore, alng, arisorse

STATIC aSer, gtitle

FUNCTION MainGraph(cnt)

   LOCAL lChanged := .t.

   aser := {}
   aeval(cnt,{|x| aadd(aser,{x})})

   DEFINE WINDOW GraphTest ;
         At 0,0 ;
         WIDTH 640 ;
         HEIGHT 500 ;
         TITLE {"Use of statistical graphics resources.", "Grafici di statistica d'uso risorse."}[alng] ;
         ICON "Main" ;
         MODAL ;
         NOSIZE ;
         BACKCOLOR {255,255,255} on init DrawBarGraph(aser)

      DEFINE BUTTONEX Button_1
         ROW    430
         COL    40
         WIDTH  125
         HEIGHT 30
         CAPTION _HMG_aLangButton [6]
         PICTURE "hp_print"
         ICON NIL
         ACTION PrintGraph()
         FONTNAME 'Arial'
         TOOLTIP ''
      END BUTTONEX

      DEFINE BUTTONEX Button_2
         ROW    430
         COL    460
         WIDTH  125
         HEIGHT 30
         CAPTION _HMG_aABMLangButton[1] //'&Cancel/Exit'
         PICTURE "Minigui_EDIT_CANCEL"
         ICON NIL
         ACTION GraphTest.Release
         FONTNAME 'Arial'
         TOOLTIP ''
      END BUTTONEX

      _definehotkey("GraphTest",0,27,{||GraphTest.release})
   END WINDOW

   IF (alng = 1)
      gTitle := rtrim("Using resources from " + ;
         Dtoc(m->a_res[1])+" to "+Dtoc(m->a_res[2]))
      GraphTest.Title:= "Usage statistics resources. "
   ELSE
      gTitle := rtrim("Uso risorse dal " + ;
         trim(DtoW(m->a_res[1]))+" al "+Dtow(m->a_res[2]))
      GraphTest.Title:= "Statistica d'uso risorse. "
   ENDIF

   CENTER WINDOW GraphTest
   ACTIVATE WINDOW GraphTest

   RETURN NIL

PROCEDURE DrawBarGraph ( aSer )

   LOCAL nTop := 20, nLeft := 20, nBottom := 400, nRight := 610

   ERASE WINDOW GraphTest

   DRAW GRAPH                     ;
      IN WINDOW GraphTest            ;
      AT nTop , nLeft               ;
      TO nBottom, nRight            ;
      TITLE gTitle               ;
      TYPE BARS                  ;
      SERIES aSer                  ;
      YVALUES {{"Values in minutes"},{"Valori in minuti"}}[alng] ;
      DEPTH 10                  ;
      BARWIDTH 5                  ;
      BARSEPARATOR 30               ;
      HVALUES 5                  ;
      SERIENAMES aRisorse [alng]       ;
      COLORS aCOLORe                ;
      3DVIEW                      ;
      SHOWGRID                      ;
      SHOWXVALUES                   ;
      SHOWYVALUES                   ;
      SHOWLEGENDS ;
      NOBORDER ;
      DATAMASK "99,999,999"

   SetProperty( 'GraphTest', GetGraphTitleName( "GraphTest" ), 'Cargo', { nTop , nLeft , nRight - nLeft , nBottom - nTop } )

   RETURN

PROCEDURE PrintGraph()

   LOCAL aLocation := GetProperty( "GraphTest", GetGraphTitleName( "GraphTest" ), 'Cargo' )

   PrintWindow ( "GraphTest" , .t. , .t. , aLocation [1] , aLocation [2] , aLocation [3] , aLocation [4]  )
   GraphTest.setfocus

   RETURN

STATIC FUNCTION GetGraphTitleName( Parent )

   LOCAL cName, i := 1

   DO WHILE i < 10000
      cName := "Obj_Name_" + hb_ntos( i++ )
      IF _IsControlDefined ( cName, Parent )
         EXIT
      ENDIF
   ENDDO

   RETURN cName
