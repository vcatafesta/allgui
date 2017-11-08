/*
 * Ejemplo Grid n° 19
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo desplegar un menú cuando el
 * usuario hace click con el botón derecho del ratón sobre
 * el cabezal de un control Grid, Browse o XBrowse.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

PROCEDURE MAIN

   DEFINE WINDOW MAIN ;
      CLIENTAREA ;
      TITLE "Clic Derecho sobre los Cabezales" ;
      WIDTH 400 HEIGHT 400

      @ 10, 10 GRID Grid ;
         WIDTH 300 HEIGHT 300 ;
         OBJ oGrid ;
         HEADERS { "Uno", "Dos", "Tres" } ;
         WIDTHS  { 50, 50, 50 } ;
         ITEMS { { "1111111111", "1", "1" }, ;
                 { "2", "2", "2222222222" },  ;
                 { "3", "3333333333", "3" }, ;
                 { "4444", "4444", "4444" } } ;
         VALUE 1 ;
         ONHEADRCLICK {|nColumna| VerMenu( nColumna ) }

      @ 370, 10 LABEL label ;
         WIDTH 400 HEIGHT 30 ;
         FONTCOLOR RED ;
         VALUE "Vea lo que sucede cuando hace clic derecho en un cabezal de columna."

      ON KEY ESCAPE ACTION MAIN.RELEASE()
   END WINDOW

   CENTER WINDOW MAIN
   ACTIVATE WINDOW MAIN
RETURN

FUNCTION VerMenu( nColumn )

   LOCAL oMenu

   DEFINE MENU DYNAMIC OF MAIN OBJ oMenu
      ITEM 'RClick en Columna ' + ltrim(str(nColumn)) ACTION NIL
   END MENU

   oMenu:Activate()

/*
 * Valores de retorno:
 *
 *    .F. previene que el grid haga scroll a la izquierda hasta que la
 *    primera columna quede visible.
 *
 *   otros valores: el grid hace scroll a la izquierda hasta que la
 *   primera columna queda visible (acción por defecto).
 */

RETURN .F.

/*
 * EOF
 */
