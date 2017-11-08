/*
 * Ejemplo Form n° 10
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo setear el value del control que
 * tiene el foco en un formulario desde un formulario diferente.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main

   DEFINE WINDOW FormMain ;
      AT 0, 0 ;
      WIDTH 640 ;
      HEIGHT 480 ;
      TITLE "Setear el control con el foco" ;
      MAIN ;
      NOMAXIMIZE ;
      NOSIZE

      @ 20, 20 BUTTON btn1 ;
         CAPTION "Haz clic"

      @ 50, 20 TEXTBOX txt1 ;
         NUMERIC ;
         PICTURE "999,999.99" ;
         VALUE 0

      @ 80, 20 TEXTBOX txt2 ;
         NUMERIC ;
         PICTURE "999,999.99" ;
         VALUE 0

      @ 110, 20 LABEL lbl1 ;
         VALUE 'Haz clic en cualquier control y pulsa F5' ;
         AUTOSIZE

      ON KEY ESCAPE ACTION ThisWindow.Release()
      ON KEY F5 ACTION AbrirSegundo( GetControlObjectByHandle( GetFocus() ) )
   END WINDOW

   ACTIVATE WINDOW FormMain

RETURN NIL

FUNCTION AbrirSegundo( oCtrl )

   LOCAL lSetear := .F.

   IF ! ( oCtrl:Type == "NUMTEXT" .OR. ( oCtrl:Type == "TEXTPICTURE" .AND. oCtrl:DataType == "N" ) )
      RETURN NIL
   ENDIF

   DEFINE WINDOW SegundoForm ;
      AT 100, 400 ;
      WIDTH 640 ;
      HEIGHT 220 ;
      TITLE "Segundo Formulario" ;
      NOMAXIMIZE ;
      NOSIZE ;
      ON RELEASE IIF( lSetear, oCtrl:Value := oNuevoValor:Value, NIL )

      @ 20, 20 TEXTBOX txt3 OBJ oNuevoValor ;
         NUMERIC ;
         PICTURE "999,999.99" ;
         VALUE 0

      @ 50, 20 LABEL lbl2 ;
         HEIGHT 40 ;
         VALUE 'Ingrese un nuevo valor para [' + oCtrl:Name + '] y haga clic en Guardar, Pulse ESC o haga clic en la X para Desistir' ;
         AUTOSIZE

      @ 100, 20 BUTTON btn2 ;
         CAPTION "Guardar" ;
         ACTION ( lSetear := .T., ThisWindow.Release() )

      ON KEY ESCAPE ACTION ThisWindow.Release()
   END WINDOW

   ACTIVATE WINDOW SegundoForm

RETURN NIL

/*
 * EOF
 */
