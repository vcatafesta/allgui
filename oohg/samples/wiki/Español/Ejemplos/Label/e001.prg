/*
 * Ejemplo Label n° 1
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo cambiar el cursor cuando el
 * mouse pasa sobre un LABEL, y cómo definir una acción
 * para que se ejecute al cliquear en el LABEL.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main

   DEFINE WINDOW Form OBJ oWin ;
      AT 0,0 ;
      WIDTH 330 HEIGHT 200 ;
      TITLE "OOHG - Cambiar el cursor y definir una acción" ;
      MAIN

      @ 20,20 LABEL lbl OBJ oLbl ;
         VALUE "Cuando el mouse pase sobre mi se verá un cursor tipo mano." ;
         WIDTH 200 ;
         HEIGHT 50 ;
         TOOLTIP "Cliquéame para disparar una acción !!!" ;
         ACTION {|| AutoMsgBox( "Acción ejecutada !!!" ) }

      /*
       * Los valores aceptables son:
       * a) cursores estándar, use las constantes definidas en i_controlmisc.ch
       * b) cursores desde el archivo de recursos, use el "nombre" asignado en el archivo RC
       * c) cursores desde el disco, use el "nombre del archivo"
       */
      oLbl:Cursor := IDC_HAND

      /*
       * La acción también puede especificarse usando:
       * oLbl:OnClick := {|| AutoMsgBox( "Acción ejecutada !!!" ) }
       * Form.lbl.OnClick := {|| AutoMsgBox("Acción ejecutada !!!")}
       *
       * Para ejecutar la acción desde el código, utilice:
       * Form.lbl.OnClick()
       * Eval( Form.lbl.OnClick )
       * Eval( oLbl:OnClick )
       * Form.lbl.Action()
       * Eval( Form.lbl.Action )
       * Eval( oLbl:Action )
       */

      ON KEY ESCAPE ACTION Form.Release
   END WINDOW

   CENTER WINDOW Form
   ACTIVATE WINDOW Form

RETURN NIL

/*
 * EOF
 */
