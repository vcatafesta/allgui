/*
 * Ejemplo Textbox n° 1
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestro cómo autocompletar un TextBox con
 * la cláusula DATE, utilizando la cláusula DEFAULTYEAR.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main

   LOCAL oWnd

   SET CENTURY ON
   SET DATE BRITISH
   SET NAVIGATION EXTENDED

   DEFINE WINDOW Win_1 OBJ oWnd ;
      AT 0,0 ;
      WIDTH 600 ;
      HEIGHT 400 ;
      TITLE 'OOHG - Control Textbox con Autocompletado de Fechas'

      ON KEY ESCAPE ACTION oWnd:Release()

      @ 20,20 LABEL lbl_Date ;
         VALUE "Con cláusula DEFAULTYEAR:" ;
         AUTOSIZE

      @ 20,200 TEXTBOX txt_Date ;
         WIDTH 100 ;
         HEIGHT 24 ;
         DATE ;
         DEFAULTYEAR Year(Date())

      @ 120,20 LABEL lbl_Value ;
         VALUE "Sin cláusula DEFAULTYEAR:" ;
         AUTOSIZE

      @ 120,200 TEXTBOX txt_Value ;
         WIDTH 100 ;
         HEIGHT 24 ;
         DATE

      @ 200, 20 LABEL lbl_Note ;
         VALUE "Vea lo que pasa si ingresa una fecha parcial y sale del TextBox con la tecla TAB." ;
         AUTOSIZE

   END WINDOW

   oWnd:Center()
   oWnd:Activate()

RETURN Nil

/*
 * EOF
 */
