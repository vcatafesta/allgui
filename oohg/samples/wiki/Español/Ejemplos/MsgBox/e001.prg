/*
 * Ejemplo Message Boxes n° 1
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo definir ventanas de mensajes
 * con diferentes modos. Ver función "Messagebox function"
 * en MSDN.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"
#include "i_windefs.ch"

FUNCTION Main

  SetMsgDefaultMode( MB_APPLMODAL )
  SetMsgDefaultMessage( "Mensaje por defecto." )
  SetMsgDefaultTitle( "Título por defecto" )

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 600 HEIGHT 280 ;
      TITLE 'ooHg - Modos de Ventanas de Mensajes' ;
      MAIN

      @ 10, 10 BUTTON btn_1 ;
         CAPTION "Usa el modo por defecto, el mensaje por defecto y el título por defecto." ;
         WIDTH 500 ;
         HEIGHT 28 ;
         ACTION MsgInfo()

      @ 50, 10 BUTTON btn_2 ;
         CAPTION "Usa el mensaje por defecto y el título por defecto, modo = MB_SYSTEMMODAL." ;
         WIDTH 500 ;
         HEIGHT 28 ;
         ACTION MsgStop( Nil, Nil, MB_SYSTEMMODAL )

      @ 90, 10 BUTTON btn_3 ;
         CAPTION "Usa el modo por defecto y el mensaje y el título definidos." ;
         WIDTH 500 ;
         HEIGHT 28 ;
         ACTION MsgExclamation( "No hay ícono en la barra de título !!!", ;
                                "MB_APPLMODAL" )

      @ 130, 10 BUTTON btn_4 ;
         CAPTION "Usa el modo, el mensaje y el título definidos." ;
         WIDTH 500 ;
         HEIGHT 28 ;
         ACTION MsgBox( "Este mensaje contiene un ícono del sistema.", ;
                        "MB_SYSTEMMODAL", MB_SYSTEMMODAL )

      @ 180, 10 LABEL lbl_1 ;
         VALUE "Haga clic en los botones para ver ventanas de mensajes con diferentes modos." ;
         WIDTH 500

      ON KEY ESCAPE ACTION Form_1.Release

   END WINDOW

   Form_1.Center

   Form_1.Activate

RETURN Nil

/*
 * EOF
 */
