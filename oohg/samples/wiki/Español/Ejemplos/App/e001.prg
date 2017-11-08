/*
 * Ejemplo Application n° 1
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo utilizar la clase Application.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

MEMVAR oApp, oBtn2, oBtn3, oLbl12, oLbl13

FUNCTION Main( ... )
   PUBLIC oApp, oBtn2, oBtn3, oLbl12, oLbl13

   SET LANGUAGE TO SPANISH

   oApp := TApplication()

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      CLIENTAREA WIDTH 640 HEIGHT 480 ;
      TITLE "Ejemplo de Uso de la Clase Application" ;
      MAIN ;
      HELPBUTTON

      @ 10, 10 LABEL lbl_1 ;
         AUTOSIZE ;
         VALUE "Nombre del ejecutable: " + oApp:ExeName

      @ 40, 10 LABEL lbl_2 ;
         AUTOSIZE ;
         VALUE "Disco: " + oApp:Drive

      @ 70, 10 LABEL lbl_3 ;
         AUTOSIZE ;
         VALUE "Carpeta: " + oApp:Path

      @ 100, 10 LABEL lbl_4 ;
         AUTOSIZE ;
         VALUE "Nombre: " + oApp:Name

      @ 130, 10 LABEL lbl_5 ;
         AUTOSIZE ;
         VALUE "Cantidad de argumentos: " + LTRIM( STR( oApp:ArgC ) )

      @ 160, 10 LABEL lbl_6 ;
         AUTOSIZE ;
         VALUE AutoType( { "Lista de argumentos: ", oApp:Args } )

      @ 190, 10 LABEL lbl_7 ;
         AUTOSIZE ;
         VALUE "Formulario Main: " + oApp:MainName

      @ 220, 10 LABEL lbl_8 ;
         AUTOSIZE ;
         VALUE "BackColor: " + ColorAStr( oApp:BackColor )

      @ 250, 10 LABEL lbl_9 ;
         AUTOSIZE ;
         VALUE "Fila, Columna: " + LTRIM( STR( oApp:Row ) ) + ", " + LTRIM( STR( oApp:Col ) )

      @ 280, 10 LABEL lbl_10 ;
         AUTOSIZE ;
         VALUE "Ancho, Alto: " + LTRIM( STR( oApp:Width ) ) + ", " + LTRIM( STR( oApp:Height ) )

      @ 310, 10 LABEL lbl_11 ;
         AUTOSIZE ;
         VALUE "Título: " + oApp:Title

      @ 340, 10 LABEL lbl_12 ;
         OBJ oLbl12 ;
         AUTOSIZE ;
         VALUE "Topmost: " + IF( oApp:Topmost, ".T.", ".F." )

      @ 370, 10 LABEL lbl_13 ;
         OBJ oLbl13 ;
         AUTOSIZE ;
         VALUE "Botón Help: " + IF( oApp:HelpButton, ".T.", ".F." )

      @ 400, 10 BUTTON btn_1 ;
         CAPTION "Cursor Mano" ;
         ACTION oApp:Cursor := IDC_HAND

      @ 400, 120 BUTTON btn_2 ;
         OBJ oBtn2 ;
         CAPTION "Ocultar Help" ;
         ACTION CambiarBotonHelp()

      @ 400, 230 BUTTON btn_3 ;
         OBJ oBtn3 ;
         CAPTION "Topmost" ;
         ACTION CambiarTopmost()

      ON KEY ESCAPE ACTION Form_1.Release
   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN NIL

STATIC FUNCTION ColorAStr( nColor )
  LOCAL cRet

  IF HB_IsNil( nColor )
     cRet := "NIL (COLOR_BTNFACE)"
  ELSE
     cRet := "{ " + ;
             LTRIM( STR( GetRed( nColor ) ) ) + ;
             ", " + ;
             LTRIM( STR( GetGreen( nColor ) ) ) + ;
             ", " + ;
             LTRIM( STR( GetBlue( nColor ) ) ) + ;
             " }"
  ENDIF

RETURN cRet

STATIC FUNCTION CambiarTopmost()

   IF oApp:Topmost
      oApp:Topmost := .F.
      oBtn3:Caption := "Topmost"
      oLbl12:Value := "Topmost: " + ".F."
   ELSE
      oApp:Topmost := .T.
      oBtn3:Caption := "No Topmost"
      oLbl12:Value := "Topmost: " + ".T."
   ENDIF

RETURN Nil

STATIC FUNCTION CambiarBotonHelp()

   IF oApp:HelpButton
      oApp:HelpButton := .F.
      oBtn2:Caption := "Mostrar Help"
      oLbl13:Value := "Botón Help: " + ".F."
   ELSE
      oApp:HelpButton := .T.
      oBtn2:Caption := "Ocultar Help"
      oLbl13:Value := "Botón Help: " + ".T."
   ENDIF

RETURN Nil

/*
 * EOF
 */
