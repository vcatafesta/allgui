/*
 * Ejemplo ComboBox n° 8
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo obtener el Value y el Caption
 * del ítem seleccionado en un ComboBox con las cláusulas
 * ITEMSOURCE y VALUESOURCE.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main

   LOCAL oWnd, oCombo1, oCombo2, oValue1, oItem1, oValue2, oItem2

   AbrirTablas()

   DEFINE WINDOW MAIN OBJ oWnd ;
      TITLE "Item y Value Seleccionados en un ComboBox" ;
      WIDTH 370 ;
      HEIGHT 400 ;
      ON RELEASE CerrarTablas()

      @ 10,10 COMBOBOX Combo1 OBJ oCombo1 ;
         WIDTH 200 ;
         DISPLAYEDIT ;
         ITEMSOURCE 'Prueba->Nombre' ;
         VALUESOURCE 'Prueba->Codigo' ;
         ON CHANGE ( oValue1:value := "El Value (Codigo) es: " + ;
                                      AutoType(oCombo1:Value), ;
                     oItem1:value := "El Item (nombre) es: " + ;
                                     oCombo1:ItemBySource(oCombo1:Value) )
/*
 * Se puede remplazar ItemBySource(oCombo1:Value) con
 * Item(ASCAN(oCombo1:aValues, oCombo1:Value)).
 */

      @ 13,220 LABEL Dummy1 VALUE "CON VALUESOURCE" AUTOSIZE

      @ 60,10 LABEL Label11 OBJ oValue1 ;
         VALUE "Seleccione un ítem para ver su value (codigo)" ;
         AUTOSIZE

      @ 80,10 LABEL Label12 OBJ oItem1 ;
         VALUE "Seleccione un ítem para ver su caption (nombre)" ;
         AUTOSIZE

      @ 210,10 COMBOBOX Combo2 OBJ oCombo2 ;
         WIDTH 200 ;
         DISPLAYEDIT ;
         ITEMSOURCE 'Prueba->Nombre' ;
         ON CHANGE ( oValue2:value := "El Value (recno) es: " + ;
                                      AutoType(oCombo2:Value), ;
                     oItem2:value := "El Item (nombre) es: " + ;
                                     oCombo2:ItemBySource(oCombo2:Value) )
/*
 * Se puede remplazar ItemBySource(oCombo2:Value) con Item(oCombo2:Value).
 */

      @ 213,220 LABEL Dummy2 VALUE "SIN" AUTOSIZE

      @ 260,10 LABEL Label21 OBJ oValue2 ;
         VALUE "Seleccione un ítem para ver su value (recno)" ;
         AUTOSIZE

      @ 280,10 LABEL Label22 OBJ oItem2 ;
         VALUE "Seleccione un ítem para ver su caption (nombre)" ;
         AUTOSIZE

      ON KEY ESCAPE ACTION oWnd:Release()
   END WINDOW

   CENTER WINDOW MAIN
   ACTIVATE WINDOW MAIN

RETURN NIL

FUNCTION AbrirTablas()

   LOCAL aDbf[ 2, 4 ], i

   aDbf[1] := { "Codigo", "N", 3, 0 }
   aDbf[2] := { "Nombre", "C", 25, 0 }

   DBCREATE( "Prueba", aDbf )

   USE Prueba

   FOR i := 1 TO 50
      APPEND BLANK
      REPLACE Codigo WITH i * 3
      REPLACE Nombre WITH 'Nombre '+ STR(i)
   NEXT i

   INDEX ON Codigo TO codigo

RETURN NIL

FUNCTION CerrarTablas()

   CLOSE DATABASES
   ERASE ("codigo" + INDEXEXT())
   ERASE Prueba.dbf

RETURN NIL

/*
 * EOF
 */
