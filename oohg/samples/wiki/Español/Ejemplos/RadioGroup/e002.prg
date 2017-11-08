/*
 * Ejemplo RadioGroup n° 2
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo es un caso de prueba para las cláusulas THEMED,
 * NOTHEME, BACKCOLOR, BACKGROUND y TRANSPARENT del control
 * RadioGroup.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 *
 * El archivo fondo.bmp puede descargarse desde:
 * https://github.com/fyurisich/OOHG_Samples/tree/master/Español/Ejemplos/RadioGroup
 */

#include "oohg.ch"

FUNCTION Main

   LOCAL oForm1, nBack := 1

   DEFINE WINDOW Form_1 ;
      OBJ oForm1 ;
      AT 0,0 ;
      WIDTH 900 ;
      HEIGHT 600 ;
      CLIENTAREA ;
      TITLE 'RadioGroup - Caso de Prueba' ;
      BACKCOLOR PINK ;
      MAIN

      @ 10, 10 LABEL lbl_111 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "THEMED"
      @ 25, 10 LABEL lbl_112 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "BACKGROUND"
      @ 40, 10 LABEL lbl_113 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "BACKCOLOR"
      @ 55, 10 LABEL lbl_114 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "TRANSPARENT"

      @ 80, 10 FRAME frm_11 WIDTH 100 HEIGHT 110

      @ 90, 20 RADIOGROUP rdg_11 ;
         OBJ oR11 ;
         OPTIONS { 'Uno', 'Dos', 'Tres', 'Cuatro' } ;
         WIDTH 80 ;
         SPACING 24 ;
         THEMED ;
         BACKGROUND oForm1 ;
         BACKCOLOR RED ;
         TRANSPARENT
      oR11:aOptions[ 2 ]:BackColor := BLUE

      @ 10, 120 LABEL lbl_121 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "THEMED"
      @ 25, 120 LABEL lbl_122 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "BACKGROUND"
      @ 40, 120 LABEL lbl_123 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "BACKCOLOR"

      @ 80, 120 FRAME frm_12 WIDTH 100 HEIGHT 110

      @ 90, 130 RADIOGROUP rdg_12 ;
         OBJ oR12 ;
         OPTIONS { 'Uno', 'Dos', 'Tres', 'Cuatro' } ;
         WIDTH 80 ;
         SPACING 24 ;
         THEMED ;
         BACKGROUND oForm1 ;
         BACKCOLOR RED ;
         LEFTJUSTIFY
      oR12:aOptions[ 2 ]:BackColor := BLUE

      @ 10, 230 LABEL lbl_131 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "THEMED"
      @ 25, 230 LABEL lbl_132 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "BACKGROUND"
      @ 55, 230 LABEL lbl_134 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "TRANSPARENT"

      @ 80, 230 FRAME frm_13 WIDTH 100 HEIGHT 110

      @ 90, 240 RADIOGROUP rdg_13 ;
         OBJ oR13 ;
         OPTIONS { 'Uno', 'Dos', 'Tres', 'Cuatro' } ;
         WIDTH 80 ;
         SPACING 24 ;
         THEMED ;
         BACKGROUND oForm1 ;
         TRANSPARENT
      oR13:aOptions[ 2 ]:BackColor := BLUE

      @ 10, 340 LABEL lbl_141 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "THEMED"
      @ 40, 340 LABEL lbl_143 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "BACKCOLOR"
      @ 55, 340 LABEL lbl_144 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "TRANSPARENT"

      @ 80, 340 FRAME frm_14 WIDTH 100 HEIGHT 110

      @ 90, 350 RADIOGROUP rdg_14 ;
         OBJ oR14 ;
         OPTIONS { 'Uno', 'Dos', 'Tres', 'Cuatro' } ;
         WIDTH 80 ;
         SPACING 24 ;
         THEMED ;
         BACKCOLOR RED ;
         TRANSPARENT
      oR14:aOptions[ 2 ]:BackColor := BLUE

      @ 10, 450 LABEL lbl_151 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "NOTHEME"
      @ 25, 450 LABEL lbl_152 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "BACKGROUND"
      @ 40, 450 LABEL lbl_153 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "BACKCOLOR"
      @ 55, 450 LABEL lbl_154 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "TRANSPARENT"

      @ 80, 450 FRAME frm_15 WIDTH 100 HEIGHT 110

      @ 90, 460 RADIOGROUP rdg_15 ;
         OBJ oR15 ;
         OPTIONS { 'Uno', 'Dos', 'Tres', 'Cuatro' } ;
         WIDTH 80 ;
         SPACING 24 ;
         BACKGROUND oForm1 ;
         BACKCOLOR RED ;
         TRANSPARENT ;
         NOTHEME
      oR15:aOptions[ 2 ]:BackColor := BLUE

      @ 10, 560 LABEL lbl_161 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "THEMED"
      @ 25, 560 LABEL lbl_162 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "BACKGROUND"

      @ 80, 560 FRAME frm_16 WIDTH 100 HEIGHT 110

      @ 90, 570 RADIOGROUP rdg_16 ;
         OBJ oR16 ;
         OPTIONS { 'Uno', 'Dos', 'Tres', 'Cuatro' } ;
         WIDTH 80 ;
         SPACING 24 ;
         THEMED ;
         BACKGROUND oForm1
      oR16:aOptions[ 2 ]:BackColor := BLUE

      @ 10, 670 LABEL lbl_171 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "THEMED"
      @ 40, 670 LABEL lbl_173 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "BACKCOLOR"

      @ 80, 670 FRAME frm_17 WIDTH 100 HEIGHT 110

      @ 90, 680 RADIOGROUP rdg_17 ;
         OBJ oR17 ;
         OPTIONS { 'Uno', 'Dos', 'Tres', 'Cuatro' } ;
         WIDTH 80 ;
         SPACING 24 ;
         THEMED ;
         BACKCOLOR RED
      oR17:aOptions[ 2 ]:BackColor := BLUE

      @ 10, 780 LABEL lbl_181 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "NOTHEME"
      @ 25, 780 LABEL lbl_182 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "BACKGROUND"
      @ 40, 780 LABEL lbl_183 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "BACKCOLOR"

      @ 80, 780 FRAME frm_18 WIDTH 100 HEIGHT 110

      @ 90, 790 RADIOGROUP rdg_18 ;
         OBJ oR18 ;
         OPTIONS { 'Uno', 'Dos', 'Tres', 'Cuatro' } ;
         WIDTH 80 ;
         SPACING 24 ;
         BACKGROUND oForm1 ;
         BACKCOLOR RED ;
         NOTHEME
      oR18:aOptions[ 2 ]:BackColor := BLUE

      @ 210, 10 LABEL lbl_211 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "THEMED"
      @ 255, 10 LABEL lbl_214 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "TRANSPARENT"

      @ 280, 10 FRAME frm_21 WIDTH 100 HEIGHT 110

      @ 290, 20 RADIOGROUP rdg_21 ;
         OBJ oR21 ;
         OPTIONS { 'Uno', 'Dos', 'Tres', 'Cuatro' } ;
         WIDTH 80 ;
         SPACING 24 ;
         THEMED ;
         TRANSPARENT
      oR21:aOptions[ 2 ]:BackColor := BLUE

      @ 210, 120 LABEL lbl_221 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "NOTHEME"
      @ 225, 120 LABEL lbl_222 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "BACKGROUND"
      @ 255, 120 LABEL lbl_224 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "TRANSPARENT"

      @ 280, 120 FRAME frm_22 WIDTH 100 HEIGHT 110

      @ 290, 130 RADIOGROUP rdg_22 ;
         OBJ oR22 ;
         OPTIONS { 'Uno', 'Dos', 'Tres', 'Cuatro' } ;
         WIDTH 80 ;
         SPACING 24 ;
         BACKGROUND oForm1 ;
         TRANSPARENT ;
         NOTHEME
      oR22:aOptions[ 2 ]:BackColor := BLUE

      @ 210, 230 LABEL lbl_231 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "NOTHEME"
      @ 240, 230 LABEL lbl_233 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "BACKCOLOR"
      @ 255, 230 LABEL lbl_234 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "TRANSPARENT"

      @ 280, 230 FRAME frm_23 WIDTH 100 HEIGHT 110

      @ 290, 240 RADIOGROUP rdg_23 ;
         OBJ oR23 ;
         OPTIONS { 'Uno', 'Dos', 'Tres', 'Cuatro' } ;
         WIDTH 80 ;
         SPACING 24 ;
         BACKCOLOR RED ;
         TRANSPARENT ;
         NOTHEME
      oR23:aOptions[ 2 ]:BackColor := BLUE

      @ 210, 340 LABEL lbl_241 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "THEMED"

      @ 280, 340 FRAME frm_24 WIDTH 100 HEIGHT 110

      @ 290, 350 RADIOGROUP rdg_24 ;
         OBJ oR24 ;
         OPTIONS { 'Uno', 'Dos', 'Tres', 'Cuatro' } ;
         WIDTH 80 ;
         SPACING 24 ;
         THEMED              // BACKCOLOR se inicializa con el BACKCOLOR del form
      oR24:aOptions[ 2 ]:BackColor := BLUE

      @ 210, 450 LABEL lbl_251 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "NOTHEME"
      @ 225, 450 LABEL lbl_252 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "BACKGROUND"

      @ 280, 450 FRAME frm_25 WIDTH 100 HEIGHT 110

      @ 290, 460 RADIOGROUP rdg_25 ;
         OBJ oR25 ;
         OPTIONS { 'Uno', 'Dos', 'Tres', 'Cuatro' } ;
         WIDTH 80 ;
         SPACING 24 ;
         BACKGROUND oForm1 ;
         NOTHEME
      oR25:aOptions[ 2 ]:BackColor := BLUE

      @ 210, 560 LABEL lbl_261 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "NOTHEME"
      @ 255, 560 LABEL lbl_264 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "TRANSPARENT"

      @ 280, 560 FRAME frm_26 WIDTH 100 HEIGHT 110

      @ 290, 570 RADIOGROUP rdg_26 ;
         OBJ oR26 ;
         OPTIONS { 'Uno', 'Dos', 'Tres', 'Cuatro' } ;
         WIDTH 80 ;
         SPACING 24 ;
         TRANSPARENT ;
         NOTHEME ;
         LEFTALIGN
      oR26:aOptions[ 2 ]:BackColor := BLUE

      @ 210, 670 LABEL lbl_271 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "NOTHEME"
      @ 240, 670 LABEL lbl_273 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "BACKCOLOR"

      @ 280, 670 FRAME frm_27 WIDTH 100 HEIGHT 110

      @ 290, 680 RADIOGROUP rdg_27 ;
         OBJ oR27 ;
         OPTIONS { 'Uno', 'Dos', 'Tres', 'Cuatro' } ;
         WIDTH 80 ;
         SPACING 24 ;
         BACKCOLOR RED ;
         NOTHEME
      oR27:aOptions[ 2 ]:BackColor := BLUE

      @ 210, 780 LABEL lbl_281 WIDTH 100 HEIGHT 15 TRANSPARENT VALUE "NOTHEME"
      @ 280, 780 FRAME frm_28 WIDTH 100 HEIGHT 110

      @ 290, 790 RADIOGROUP rdg_28 ;
         OBJ oR28 ;
         OPTIONS { 'Uno', 'Dos', 'Tres', 'Cuatro' } ;
         WIDTH 80 ;
         SPACING 24 ;
         NOTHEME              // BACKCOLOR se inicializa con el BACKCOLOR del form
      oR28:aOptions[ 2 ]:BackColor := BLUE

      @ 410, 10 LABEL lbl_Notes WIDTH 500 HEIGHT 200 TRANSPARENT ;
         VALUE "BACKGROUND fuerza THEMED." + hb_OsNewLine() + ;
               "TRANSPARENT y BACKCOLOR son ignoradas cuando BACKGROUND está presente." + hb_OsNewLine() + ;
               "BACKCOLOR es ignorada cuando TRANSPARENT está presente." + hb_OsNewLine() + ;
               "TRANSPARENT pinta el fondo del control usando un NULL BRUSH." + hb_OsNewLine() + ;
               "THEMED pinta el conntrol usando funciones de Temas de Windows si un tema está habilitado y sino utiliza la rutina por defecto de Windows" + hb_OsNewLine() + ;
               "NOTHEME pinta el control utilizando la rutina por defecto de Windows" + hb_OsNewLine() + ;
               "Si no se especifica THEMED o NOTHEME se asume THEMED si la applicación tiene tema o NOTHEME en caso contrario" + hb_OsNewLine() + ;
               "BACKGROUND pinta el fondo del control usando un BRUSH derivado del área cliente de otro control."

      @ 500, 700 BUTTON btn_Change OBJ oBut CAPTION "Usar BackImage" WIDTH 170 ;
         ACTION { || Eval( If( nBack == 1, ;
                               { || oForm1:BackColor := NIL, oForm1:BackImage := "fondo.bmp", oBut:Caption := "Ni BackColor ni BackImage", nBack := 2 }, ;
                               If( nBack == 2, ;
                                   { || oForm1:BackColor := NIL, oForm1:BackImage := NIL, oBut:Caption := "Usar BackColor", nBack := 3 }, ;
                                   { || oForm1:BackColor := PINK, oForm1:BackImage := NIL, oBut:Caption := "Usar BackImage", nBack := 1 } ) ) ) }

      ON KEY ESCAPE ACTION oForm1:Release()
   END WINDOW

   oForm1:Center()
   oForm1:Activate()

RETURN NIL

/*
 * EOF
 */
