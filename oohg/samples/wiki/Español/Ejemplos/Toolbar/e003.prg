/*
 * Ejemplo Toolbar n° 3
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo agregar y quitar botones de una
 * toolbar en tiempo de ejecución.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION MAIN

   PUBLIC oTool, oTBot

   DEFINE WINDOW Win ;
      OBJ oWin ;
      AT 0,0 ;
      WIDTH 640 ;
      HEIGHT 480 ;
      TITLE "Agregar y quitar botones de una toolbar en tiempo de ejecución" ;
      MAIN

      DEFINE TOOLBAR Tool OBJ oTool BUTTONSIZE 70,20 FLAT BORDER
         BUTTON Bot1 CAPTION "&Salir"   ACTION oWin:Release()
         BUTTON Bot2 CAPTION "&Agregar" ACTION AgregarBoton()
         BUTTON Bot3 CAPTION "&Quitar"  ACTION QuitarBoton()
      END TOOLBAR

   END WINDOW

   oWin:Center()
   oWin:Activate()

RETURN NIL


PROCEDURE AgregarBoton

   oTBot := oTool:AddButton( "Bot4", 0, 0, "Bot4", {|| MsgBox("Bot4")}, Nil, Nil, Nil, ;
                             "Botón agregado", Nil, Nil, .F., .F., .F.,  .F., ;
                             .F., .F., .F. )
/*
   oTBot := TToolButton():Define( "Bot4", 0, 0, "Bot4", {|| MsgBox("Bot4")}, Nil, Nil, Nil, ;
                                  "Botón agregado", Nil, Nil, .F., .F., .F.,  .F., ;
                                  .F., .F., .F., oTool )
*/

RETURN


PROCEDURE QuitarBoton

   oTool:DeleteButton( 4 )
/*
   oTBot:Release()
*/

RETURN

/*
 * EOF
 */
