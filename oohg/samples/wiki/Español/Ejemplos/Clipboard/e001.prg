/*
 * Ejemplo Portapapeles (Clipboard) n° 1
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo copiar texto desde y hacia
 * un control TextBox.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main()

  DEFINE WINDOW Form_1 ;
     OBJ oForm ;
     AT 0, 0 ;
     WIDTH 400 ;
     HEIGHT 200 ;
     MAIN ;
     NOSIZE ;
     NOMAXIMIZE ;
     TITLE "ooHG Demo - cómo usar el PortaPapeles"

    @ 10,10 LABEL lbl_Content ;
      VALUE "Contenido:" ;
      WIDTH 60 ;
      HEIGHT 24

    @ 10,80 TEXTBOX txt_Content ;
      VALUE "" ;
      WIDTH 300 ;
      HEIGHT 24 ;
      READONLY ;
      NOTABSTOP

    @ 50,10 LABEL lbl_NewText ;
      VALUE "Nuevo texto:" ;
      WIDTH 60 ;
      HEIGHT 40

    @ 50,80 TEXTBOX txt_NewText ;
      VALUE "" ;
      WIDTH 300 ;
      HEIGHT 24 ;
      ON CHANGE oForm:btn_SetGet:Enabled := ! EMPTY(oForm:txt_NewText:Value)

    @ 100, 80 BUTTON btn_SetGet ;
       CAPTION "Poner+Obtener" ;
       ACTION (SetClipboardText(oForm:txt_NewText:Value), ;
               oForm:txt_Content:Value := GetClipboardText()) ;
       DISABLED

    @ 100, 200 BUTTON btn_Get ;
       CAPTION "Obtener" ;
       ACTION oForm:txt_Content:value := GetClipboardText()
  END WINDOW

  oForm:Center()
  ON KEY ESCAPE OF (oForm) ACTION oForm:Release()

  oForm:txt_NewText:SetFocus()
  oForm:Activate()

RETURN Nil

/*
 * EOF
 */
