/*
 * Ejemplo Form n° 2
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo cambiar el orden de tabulación
 * de los controles de un formulario.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main

   DEFINE WINDOW Form_1 ;
      OBJ oForm1 ;
      AT 0,0 ;
      WIDTH 588 ;
      HEIGHT 480 ;
      TITLE 'Cambiar el Orden de Tabulación' ;
      MAIN

      DEFINE STATUSBAR OBJ oStat
      END STATUSBAR

/*
   Los índices de tabulación se inician en 1.
   Los nuevos controles son situados al final del orden de tabulación.
   Cuando un control es borrado, el índice de los controles
   subsiguientes en el orden de tabulación se decrementa en 1 para
   evitar huecos en el orden.

   Cada control tiene su propio índice, incluyendo a los controles
   invisible y los controles con la propiedad "notabstop".

   Note que el índice de tabulación del primer control definido por el
   usuario no es 1.
   Esto se debe a que OOHG crea algunos controles antes de crear los
   controles del usuario.

   Los índices de tabulación son automáticamte renumerados cada vez
   que el índice de un control es cambiado, de forma que el orden de
   tabulación se inicie en 1 y que no existan huecos.
*/

      @  10,  10 TEXTBOX txt_01 OBJ oTxt01 WIDTH 100 NUMERIC
      oTxt01:Value := oTxt01:TabIndex
      @  40,  10 TEXTBOX txt_02 OBJ oTxt02 WIDTH 100 NUMERIC
      oTxt02:Value := oTxt02:TabIndex
      @  70,  10 TEXTBOX txt_03 OBJ oTxt03 WIDTH 100 NUMERIC
      oTxt03:Value := oTxt03:TabIndex
      @ 100,  10 TEXTBOX txt_04 OBJ oTxt04 WIDTH 100 NUMERIC
      oTxt04:Value := oTxt04:TabIndex
      @ 130,  10 TEXTBOX txt_05 OBJ oTxt05 WIDTH 100 NUMERIC
      oTxt05:Value := oTxt05:TabIndex
      @ 160,  10 TEXTBOX txt_06 OBJ oTxt06 WIDTH 100 NUMERIC
      oTxt06:Value := oTxt06:TabIndex
      @ 190,  10 TEXTBOX txt_07 OBJ oTxt07 WIDTH 100 NUMERIC
      oTxt07:Value := oTxt07:TabIndex
      @ 220,  10 TEXTBOX txt_08 OBJ oTxt08 WIDTH 100 NUMERIC
      oTxt08:Value := oTxt08:TabIndex
      @ 250,  10 TEXTBOX txt_09 OBJ oTxt09 WIDTH 100 NUMERIC
      oTxt09:Value := oTxt09:TabIndex
      @ 280,  10 TEXTBOX txt_10 OBJ oTxt10 WIDTH 100 NUMERIC
      oTxt10:Value := oTxt10:TabIndex

      @  10, 130 TEXTBOX txt_11 OBJ oTxt11 WIDTH 100 NUMERIC
      oTxt11:Value := oTxt11:TabIndex
      @  40, 130 TEXTBOX txt_12 OBJ oTxt12 WIDTH 100 NUMERIC
      oTxt12:Value := oTxt12:TabIndex
      @  70, 130 TEXTBOX txt_13 OBJ oTxt13 WIDTH 100 NUMERIC
      oTxt13:Value := oTxt13:TabIndex
      @ 100, 130 TEXTBOX txt_14 OBJ oTxt14 WIDTH 100 NUMERIC
      oTxt14:Value := oTxt14:TabIndex
      @ 130, 130 TEXTBOX txt_15 OBJ oTxt15 WIDTH 100 NUMERIC
      oTxt15:Value := oTxt15:TabIndex
      @ 160, 130 TEXTBOX txt_16 OBJ oTxt16 WIDTH 100 NUMERIC
      oTxt16:Value := oTxt16:TabIndex
      @ 190, 130 TEXTBOX txt_17 OBJ oTxt17 WIDTH 100 NUMERIC
      oTxt17:Value := oTxt17:TabIndex
      @ 220, 130 TEXTBOX txt_18 OBJ oTxt18 WIDTH 100 NUMERIC
      oTxt18:Value := oTxt18:TabIndex
      @ 250, 130 TEXTBOX txt_19 OBJ oTxt19 WIDTH 100 NUMERIC
      oTxt19:Value := oTxt19:TabIndex
      @ 280, 130 TEXTBOX txt_20 OBJ oTxt20 WIDTH 100 NUMERIC
      oTxt20:Value := oTxt20:TabIndex

      @  10, 250 LABEL lbl_01 OBJ oLbl01 ;
         WIDTH 300 HEIGHT 300 ;
         VALUE "El orden de tabulación es: primera columna de arriba " + ;
               "hacia abajo, luego la segunda columna de arriba hacia abajo" ;
         FONTCOLOR RED

      @ 320, 130 BUTTON btn_01 ;
         OBJ oBut01 CAPTION "Cambiar" ACTION Cambiar()

      ON KEY ESCAPE ACTION oForm1:Release()
   END WINDOW

   oForm1:Center()
   oForm1:Activate()

RETURN NIL

FUNCTION Cambiar
   LOCAL i, j
   STATIC lFlip := .T.

/*
 * El orden utilizado para cambiar el índice de los controles es relevante.
 *
 * Suponga que tiene 5 controles en el siguiente orden de tabulación:
 *    o1, o2, o3, o4 y o5.
 *
 * Si se hace o4:TabIndex := 2, el orden de tabulación se cambia a:
 *    o1, o4, o2, o3 y o5.
 * Si se hace o2:TabIndex := 4, el orden de tabulación se cambia a:
 *    o1, o3, o4, o2 y o5.
 *
 * Si desea cambiar el orden de tabulación a: o5, o4, o3, o2, o1
 * La siguiente secuencia no funcionará:
 *    o1:TabIndex := 5
 *    o2:TabIndex := 4
 *    o4:TabIndex := 2
 *    o5:TabIndex := 1
 * debido a que
 *    la sentencia 1 cambia el orden a: o2, o3, o4, o5, o1
 *    la sentencia 2 cambia el orden a: o3, o4, o5, o2, o1
 *    la sentencia 3 cambia el orden a: o3, o4, o5, o2, o1
 *    la sentencia 4 cambia el orden a: o5, o3, o4, o2, o1
 * Pero si funcionará la siguiente:
 *    o1:TabIndex := 5
 *    o5:TabIndex := 1
 *    o2:TabIndex := 4
 *    o4:TabIndex := 2
 * debido a que
 *    la sentencia 1 cambia el orden a: o2, o3, o4, o5, o1
 *    la sentencia 2 cambia el orden a: o5, o2, o3, o4, o1
 *    la sentencia 3 cambia el orden a: o5, o3, o4, o2, o1
 *    la sentencia 4 cambia el orden a: o5, o4, o3, o2, o1
 */

   If lFlip
      oLbl01:Value := "El orden de tabulación es: primera fila de " + ;
                      "izquierda a derecha, luego la segunda fila " + ;
                      "de izquierda a derecha, y así hasta la " + ;
                      "última fila."

      j := oTxt01:TabIndex
      For i := 1 to 10
         &( "oTxt" + strzero(i,      2, 0) ):TabIndex := j
         &( "oTxt" + strzero(i + 10, 2, 0) ):TabIndex := j + 1
         j += 2
      Next i
   Else
      oLbl01:Value := "El orden de tabulación es: primera columna de " + ;
                      "arriba hacia abajo, luego la segunda columna de " + ;
                      "arriba hacia abajo"

      j := oTxt01:TabIndex
      For i := 1 to 20
         &( "oTxt" + strzero(i, 2, 0) ):TabIndex := j + i - 1
      Next i
   EndIf

   For i := 1 to 20
      With Object &( "oTxt" + strzero(i, 2, 0) )
         :Value := :TabIndex
      End Width
   Next i

   lFlip := ! lFlip

   oTxt01:SetFocus()

RETURN NIL

/*
 * EOF
 */
