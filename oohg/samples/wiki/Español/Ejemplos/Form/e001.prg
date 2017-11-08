/*
 * Ejemplo Form n° 1
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo destacar un botón cuando el
 * mouse le pasa por encima.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include 'oohg.ch'

FUNCTION Main()

   LOCAL oMainForm
   PRIVATE oButton_3, oLbl_1

   DEFINE WINDOW MainForm ;
      OBJ oMainForm ;
      AT 0, 0 ;
      WIDTH 600 ;
      HEIGHT 200 ;
      TITLE "ooHG Demo - Eventos OnMouseMove del Control y del Formulario" ;
      MAIN ;
      ON MOUSEMOVE {|| OnMouseMoveWindow()}

      @ 10, 10 BUTTON Button_3 ;
         OBJ oButton_3 ;
         WIDTH 150 ;
         HEIGHT 30 ;
         CAPTION "&Salir" ;
         ACTION oMainForm:Release() ;
         FONT "Tahoma" SIZE 9 ;
         ON MOUSEMOVE {|| OnMouseMoveButton()}

      @ 10, 200 LABEL lbl_1 ;
         OBJ oLbl_1 ;
         WIDTH 200 ;
         VALUE "" ;
         TRANSPARENT

      @ 70, 10 LABEL lbl_2 ;
         WIDTH 200 ;
         HEIGHT 100 ;
         VALUE "Mueva el mouse por la ventana y vea lo " + ;
               "que ocurre cuando pasa sobre el botón."

      ON KEY ESCAPE ACTION oMainForm:Release()
   END WINDOW

   CENTER WINDOW MainForm
   ACTIVATE WINDOW MainForm

RETURN Nil

FUNCTION OnMouseMoveWindow

   oLbl_1:Value := "Formulario - Fila " + ;
                   LTRIM(STR(_OOHG_MouseRow)) + ;
                   " Columna " + LTRIM(STR(_OOHG_MouseCol))
   oButton_3:FontSize := 9

RETURN Nil

FUNCTION OnMouseMoveButton

   oLbl_1:Value := ""
   oButton_3:FontSize := 18

RETURN Nil

/*
 * EOF
 */
