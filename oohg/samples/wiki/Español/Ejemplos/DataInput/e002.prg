/*
 * Data Input Sample n° 2
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo definir un formulario de ingreso
 * de datos utilizando la cláusula VALID, y cómo implementar
 * el reseteo de los campos del formulario ignorando las
 * validaciones definidas.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main

   DEFINE WINDOW Form_1 ;
      AT 80,80 ;
      WIDTH 508 ;
      HEIGHT 138 ;
      MAIN ;
      TITLE "ooHG - Resetear campos de ingreso con cláusula VALID"

      @ 30, 190 BUTTON btn_1 ;
         CAPTION 'Iniciar Ingreso' ;
         WIDTH  120 ;
         ACTION DataInput() ;
         CANCEL

      ON KEY ESCAPE ACTION Form_1.Release
   END WINDOW

   Form_1.Activate

RETURN NIL

FUNCTION DataInput()

   LOCAL oForm2, oTxt2, oTxt3

   DEFINE WINDOW Form_2 ;
      OBJ oForm2 ;
      AT 0,0 ;
      WIDTH 300 ;
      HEIGHT 200 ;
      TITLE "Ingreso de Datos"

      @ 13, 10 LABEL lbl_1 ;
         VALUE "Nombre" ;
         WIDTH 60 ;
         HEIGHT 24

      @ 10, 70 TEXTBOX txt_1 ;
         OBJ oTxt1 ;
         WIDTH 140 ;
         HEIGHT 24 ;
         MAXLENGTH 10 ;
         VALUE "<nombre>"

      @ 43, 10 LABEL lbl_2 ;
         VALUE "Valor" ;
         WIDTH 60 ;
         HEIGHT 24

      @ 40, 70 TEXTBOX txt_2 ;
         OBJ oTxt2 ;
         NUMERIC ;
         INPUTMASK "999.9" ;
         VALID {|| oTxt2:value > 0} ;
         WIDTH 60 ;
         HEIGHT 24 ;
         VALUE 3

      @ 73, 10 LABEL lbl_3 ;
         VALUE "Notas" ;
         WIDTH 60 ;
         HEIGHT 24

      @ 70, 70 TEXTBOX txt_3 ;
         OBJ oTxt3 ;
         WIDTH 140 ;
         HEIGHT 24 ;
         MAXLENGTH 100 ;
         VALUE "<notas>"

      @ 120, 100 BUTTON btn_1 ;
         CAPTION 'Cancel' ;
         WIDTH  100 ;
         ACTION {|| oTxt1:value := "<nombre>", ;
                    oTxt2:value := 3, ;
                    oTxt3:value := "<notas>", ;
                    oTxt1:setfocus()} ;
         CANCEL

      ON KEY ESCAPE ACTION oForm2:Release()
   END WINDOW

   oForm2:Center()
   oForm2:Activate()

RETURN NIL

/*
 * EOF
 */
