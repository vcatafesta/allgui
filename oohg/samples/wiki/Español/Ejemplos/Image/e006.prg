/*
 * Ejemplo Image n° 6
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * See <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo usar la cláusula EXCLUDEAREA
 * de un control IMAGE para restringir el ON CLICK y el
 * TOOLTIP a un área específica del control. Tambien muestra
 * cómo definir dinámicamente el área excluida utilizando
 * la DATA aExcludeArea.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 *
 * El archivo img1.bmp puede descargarse desde:
 * https://github.com/fyurisich/OOHG_Samples/tree/master/Español/Ejemplos/Image
 */

#include 'oohg.ch'

FUNCTION Main
   LOCAL oImage1

   DEFINE WINDOW frm_Main OBJ oWin ;
      AT 0, 0 ;
      CLIENTAREA ;
      WIDTH 300 ;
      HEIGHT 160 ;
      TITLE 'Exclusión de Área en un Control IMAGE' ;
      MAIN

      DEFINE IMAGE img_Image1
         OBJECT oImage1             // Esta variable debe declararse
         ROW 20
         COL 20
         WIDTH 120
         HEIGHT 120
         PICTURE "img1.bmp"
         TOOLTIP "Solo visible sobre el área verde."
         ONCLICK AutoMsgBox( "Click en el área verde !!!" )
         EXCLUDEAREA { { 30, 30, 90, 90 } }  // izquierda, arriba, derecha, abajo
      END IMAGE

      @ 20, 180 LABEL lbl_1 ;
         VALUE "Mueva el mouse sobre la imagen y haga click en diferentes lugares. Use F5 para cambiar el área excluida." ;
         WIDTH 90 ;
         HEIGHT 120 ;
         FONTCOLOR RED

      ON KEY ESCAPE ACTION oWin:Release()
      ON KEY F5 ACTION CambiarArea( oImage1 )
	END WINDOW

   oWin:Center()
   oWin:Activate()

RETURN NIL

FUNCTION CambiarArea( oImage1 )
   STATIC lCambiar := .T.
/*
   El pixel ubicado en (derecha, abajo) no es parte del área excluida.
   Las coordenadas deben ser relativas a oImage1.
*/
   IF lCambiar
      oImage1:aExcludeArea := { {  0,  0, 120,  30 }, ;
                                { 90, 30, 120, 120 }, ;
                                {  0, 30,  30, 120 }, ;
                                { 30, 90,  90, 120 } }
      oImage1:Tooltip := "Solo visible sobre el área roja."
      oImage1:bOnClick := { || AutoMsgBox( "Click en el área roja !!!" ) }
   ELSE
      oImage1:aExcludeArea := { { 30, 30, 90, 90 } }
      oImage1:Tooltip := "Solo visible sobre el área verde."
      oImage1:bOnClick := { || AutoMsgBox( "Click en el área verde !!!" ) }
   ENDIF

   lCambiar := ! lCambiar
RETURN NIL

/*
 * EOF
 */
