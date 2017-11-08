/*
 * Ejemplo DatePicker n° 1
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra como:
 * a) definir controles DatePicker con estilos SHOWNONE,
 *    UPDOWN and RIGHTALIGN.
 * b) definir un rango para limitar la selección de fechas.
 * c) cambiar el rango utilizando el método SETRANGE.
 * d) verificar el estilo del control.
 * e) obtener la fecha seleccionada.
 * f) verificar si no hay fecha seleccionada.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"
#include "i_windefs.ch"

FUNCTION Main

  SET DATE BRITISH

	DEFINE WINDOW Form_1 OBJ Ventana ;
      AT 0,0 ;
      WIDTH 600 HEIGHT 400 ;
      TITLE "ooHG - Control DatePicker" ;
      MAIN ;
      FONT "Arial" SIZE 10

      @ 10,10 DATEPICKER Date_1 OBJ Date_1 ;
      VALUE CTOD("01/01/1752") ;
      TOOLTIP "Control DatePicker" ;
      RANGE CTOD("01/01/1752"), CTOD("31/12/9999")
      // fecha mínima y máxima

      @ 10,310 DATEPICKER Date_2 OBJ Date_2 ;
      VALUE CTOD("01/07/2011") ;
      TOOLTIP "Control DatePicker con ShowNone RightAlign" ;
      SHOWNONE ;
      RIGHTALIGN

      @ 230,10 DATEPICKER Date_3 OBJ Date_3 ;
      VALUE CTOD("01/01/2001") ;
      TOOLTIP "Control DatePicker con UpDown" ;
      UPDOWN

      @ 230,310 DATEPICKER Date_4 OBJ Date_4 ;
      VALUE CTOD("01/01/2001") ;
      TOOLTIP "Control DatePicker con ShowNone UpDown" ;
      SHOWNONE ;
      UPDOWN

      @ 10, 490 BUTTON btn_Set ;
      CAPTION "Cambiar Rango" ;
      ACTION Form_1.date_1.SETRANGE(DATE()-10, DATE()+10) ;
      WIDTH 100 ;
      HEIGHT 28

      @ 50, 490 BUTTON btn_1 ;
      CAPTION "Date_1" ;
      ACTION MSGBOX(IF(IsWindowStyle(Date_1:HWND, DTS_SHOWNONE), ;
                       "Date_1 tiene estilo SHOWNONE.", ;
                       "Date_1 no tiene estilo SHOWNONE.")) ;
      WIDTH 100 ;
      HEIGHT 28

      @ 90, 490 BUTTON btn_2 ;
      CAPTION "Date_2" ;
      ACTION MSGBOX(IF(IsWindowStyle(Date_2:HWND, DTS_SHOWNONE), ;
                       "Date_2 tiene estilo SHOWNONE.", ;
                       "Date_2 no tiene estilo SHOWNONE.")) ;
      WIDTH 100 ;
      HEIGHT 28

      @ 130, 490 BUTTON btn_3 ;
      CAPTION "Valor Date_3" ;
      ACTION automsgbox(Date_3:value) ;
      WIDTH 100 ;
      HEIGHT 28

      @ 170, 490 BUTTON btn_4 ;
      CAPTION "Valor Date_4" ;
      ACTION automsgbox(if(empty(Date_4:value), ;
                        "La fecha está vacía !!!", ;
                        dtoc(Date_4:value))) ;
      WIDTH 100 ;
      HEIGHT 28

      ON KEY ESCAPE ACTION Form_1.Release
	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

RETURN NIL

/*
 * EOF
 */
