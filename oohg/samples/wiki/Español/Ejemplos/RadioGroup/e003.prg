/*
* Ejemplo RadioGroup n° 3
* Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
* Licenciado bajo The Code Project Open License (CPOL) 1.02
* Ver <http://www.codeproject.com/info/cpol10.aspx>
* Este ejemplo muestra cómo utilizar un control RadioGroup
* con la cláusula AUTOSIZE.
* Visítenos en https://github.com/fyurisich/OOHG_Samples o en
* http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
*/

#include "oohg.ch"

FUNCTION Main

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH 588 ;
         HEIGHT 480 ;
         TITLE 'RadioGroup - Autosize' ;
         MAIN ;
         ON INIT MostrarAnchos()

      @ 10,20 LABEL lbl_1 VALUE "THEMED"

      @ 40,20 RADIOGROUP rdg_1 OBJ oRdg1 ;
         OPTIONS { 'Uno', 'Dos', 'Tres', 'Cuatro' } ;
         AUTOSIZE ;
         SPACING 24 ;
         THEMED

      @ 140,20 LABEL lbl_2 OBJ oLbl2 ;
         VALUE "anchos: " ;
         AUTOSIZE

      @ 10,300 LABEL lbl_3 VALUE "NOTHEME"

      @ 40,300 RADIOGROUP rdg_2 OBJ oRdg2 ;
         OPTIONS { 'Uno', 'Dos', 'Tres', 'Cuatro' } ;
         AUTOSIZE ;
         SPACING 24 ;
         NOTHEME

      @ 140,300 LABEL lbl_4 OBJ oLbl4 ;
         VALUE "anchos: " ;
         AUTOSIZE

      DRAW LINE IN WINDOW Form_1 AT 180,20 TO 180,( Form_1.ClientWidth - 20 ) ;
         PENCOLOR RED PENWIDTH 3

      @ 210,20 LABEL lbl_5 VALUE "THEMED"

      @ 240,20 RADIOGROUP rdg_3 OBJ oRdg3 ;
         OPTIONS { 'Uno', 'Dos', 'Tres', 'Cuatro' } ;
         AUTOSIZE ;
         SPACING 24 ;
         THEMED ;
         LEFTALIGN

      @ 340,20 LABEL lbl_6 OBJ oLbl6 ;
         VALUE "anchos: " ;
         AUTOSIZE

      @ 210,300 LABEL lbl_7 VALUE "NOTHEME"

      @ 240,300 RADIOGROUP rdg_4 OBJ oRdg4 ;
         OPTIONS { 'Uno', 'Dos', 'Tres', 'Cuatro' } ;
         AUTOSIZE ;
         SPACING 24 ;
         NOTHEME ;
         LEFTALIGN            // not supported by Windows

      @ 340,300 LABEL lbl_8 OBJ oLbl8 ;
         VALUE "anchos: " ;
         AUTOSIZE

      @ 400,20 BUTTON btn_1 ;
         CAPTION "Cambiar ítem" ;
         ACTION CambiarItem()

      ON KEY ESCAPE ACTION ThisWindow.Release()
   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

   RETURN NIL

FUNCTION CambiarItem()

   STATIC lLong := .F.

   lLong := ! lLong

   IF lLong
      oRdg1:Caption( 1, "El nuevo texto del item 1 es largo" )
      oRdg2:Caption( 1, "El nuevo texto del item 1 es largo" )
      oRdg3:Caption( 1, "El nuevo texto del item 1 es largo" )
      oRdg4:Caption( 1, "El nuevo texto del item 1 es largo" )
   ELSE
      oRdg1:Caption( 1, "Uno" )
      oRdg2:Caption( 1, "Uno" )
      oRdg3:Caption( 1, "Uno" )
      oRdg4:Caption( 1, "Uno" )
   ENDIF

   MostrarAnchos()

   RETURN NIL

FUNCTION MostrarAnchos()

   oLbl2:Value := "anchos: " + ;
      LTRIM( STR( oRdg1:aOptions[1]:Width ) ) + ;
      " " + ;
      LTRIM( STR( oRdg1:aOptions[2]:Width ) ) + ;
      " " + ;
      LTRIM( STR( oRdg1:aOptions[3]:Width ) ) + ;
      " " + ;
      LTRIM( STR( oRdg1:aOptions[4]:Width ) )

   oLbl4:Value := "anchos: " + ;
      LTRIM( STR( oRdg2:aOptions[1]:Width ) ) + ;
      " " + ;
      LTRIM( STR( oRdg2:aOptions[2]:Width ) ) + ;
      " " + ;
      LTRIM( STR( oRdg2:aOptions[3]:Width ) ) + ;
      " " + ;
      LTRIM( STR( oRdg2:aOptions[4]:Width ) )

   oLbl6:Value := "anchos: " + ;
      LTRIM( STR( oRdg3:aOptions[1]:Width ) ) + ;
      " " + ;
      LTRIM( STR( oRdg3:aOptions[2]:Width ) ) + ;
      " " + ;
      LTRIM( STR( oRdg3:aOptions[3]:Width ) ) + ;
      " " + ;
      LTRIM( STR( oRdg3:aOptions[4]:Width ) )

   oLbl8:Value := "anchos: " + ;
      LTRIM( STR( oRdg4:aOptions[1]:Width ) ) + ;
      " " + ;
      LTRIM( STR( oRdg4:aOptions[2]:Width ) ) + ;
      " " + ;
      LTRIM( STR( oRdg4:aOptions[3]:Width ) ) + ;
      " " + ;
      LTRIM( STR( oRdg4:aOptions[4]:Width ) )

   RETURN NIL

   /*
   * EOF
   */
