/*
 * Ejemplo Grid n° 24
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo comenzar la edición en la tercera
 * columna de una nueva línea de un Grid, usando las cláusulas
 * ON EDITCELL, WHEN y ON ABORTEDIT.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main
   LOCAL aRows[5, 5], k
   PUBLIC lEdit := .T.

   SET DATE ANSI
   SET CENTURY ON
   SET NAVIGATION EXTENDED

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      CLIENTAREA ;
      WIDTH 600 ;
      HEIGHT 550 ;
      TITLE 'Editar una nueva fila desde la columna 3' ;
      MAIN

      FOR k := 1 TO 5
          aRows[k] := { Str( HB_RandomInt(99), 2 ), ;
                        HB_RandomInt(100), ;
                        HB_RandomInt(100), ;
                        "Refer " + Str( HB_RandomInt(10), 2 ), ;
                        HB_RandomInt(10000) }
      NEXT k

      @ 40,10 GRID Grid_1 obj oGrid ;
         WIDTH 520 ;
         HEIGHT 330 ;
         HEADERS {'CODIGO', 'NUMERO', 'ITEM', 'REFERENCIA', 'IMPORTE'} ;
         WIDTHS {60, 80, 100, 120, 140} ;
         ITEMS aRows ;
         COLUMNCONTROLS { {'TEXTBOX', 'CHARACTER', "99"}, ;
                          {'TEXTBOX', "NUMERIC", '999999'}, ;
                          {'TEXTBOX', "NUMERIC", '999999'}, ;
                          {'TEXTBOX', "CHARACTER"}, ;
                          {'TEXTBOX', 'NUMERIC', '999,999,999.99'} } ;
         FONT "COURIER NEW" SIZE 10 ;
         VALUE 5 ;
         APPEND ;
         EDIT INPLACE ;
         FULLMOVE ;
         WHEN { {|| lEdit }, {|| lEdit }, .T., .T., .T. } ;
         ON EDITCELL CeldaEditada( oGrid ) ;
         ON ABORTEDIT lEdit := .T.

      ON KEY ESCAPE ACTION ThisWindow.Release
   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN NIL


FUNCTION CeldaEditada( oGrid )
   LOCAL i

   IF This.CellColIndex == 2 .AND. _OOHG_ThisItemCellValue >= 50
      /*
         Hago pensar al Grid que acaba de editar la última columna.
         Si estoy en la última fila, al finalizar esta función se
         agregará una nueva fila. Si no, continúa en la siguiente.
      */
      FOR i := 1 TO ( oGrid:ColumnCount - This.CellColIndex )
         oGrid:Right()
      NEXT i

      // Deshabilito la edición de las columnas 1 y 2
      lEdit := .F.
   ELSE
      lEdit := .T.
   ENDIF

RETURN NIL


/*
 * EOF
 */
