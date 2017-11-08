/*
 * Ejemplo Combobox n° 6
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo cargar un combobox a partir de una
 * dbf, utilizando las cláusulas ITEMSOURCE y VALUESOURCE.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"
#include "dbstruct.ch"

FUNCTION Main

   LOCAL oWnd

   REQUEST DBFCDX, DBFFPT

   OpenTables()

   DEFINE WINDOW MAIN OBJ oWnd ;
      TITLE "Combobox desde una DBF" ;
      WIDTH 350 ;
      HEIGHT 200

      @ 10,10 COMBOBOX Combo ;
         WIDTH 200 ;
         ITEMSOURCE 'test->last' ;
         VALUESOURCE 'test->code' ;
         VALUE 3 ;
         ON CHANGE oWnd:Label:Value := ;
                      "El valor del combo es: " + autotype(oWnd:Combo:Value)

      @ 60,10 LABEL Label ;
         VALUE "Seleccione un item en el combo para ver su valor !!!" ;
         AUTOSIZE

      ON KEY ESCAPE ACTION oWnd:Release()
   END WINDOW

   CENTER WINDOW MAIN
   ACTIVATE WINDOW MAIN

   CerrarTablas()

RETURN NIL

//--------------------------------------------------------------------------//
FUNCTION OpenTables()

   LOCAL aDbf[ 2, 4 ]

   aDbf[1][ DBS_NAME ] := "Code"
   aDbf[1][ DBS_TYPE ] := "Numeric"
   aDbf[1][ DBS_LEN ]  := 2
   aDbf[1][ DBS_DEC ]  := 0

   aDbf[2][ DBS_NAME ] := "Last"
   aDbf[2][ DBS_TYPE ] := "Character"
   aDbf[2][ DBS_LEN ]  := 25
   aDbf[2][ DBS_DEC ]  := 0

   DBCREATE("Test", aDbf, "DBFCDX")

   USE test VIA "DBFCDX"
   ZAP

   FOR i := 1 TO 30
      APPEND BLANK
      REPLACE Code WITH i * 3
      REPLACE Last WITH 'Apellido '+ LTRIM(STR(i))
   NEXT i

   INDEX ON Code TO code

RETURN NIL

//--------------------------------------------------------------------------//
FUNCTION CerrarTablas()
   LOCAL cIndexExt := INDEXEXT()

   CLOSE DATABASES
   ERASE ("Test" + cIndexExt)
   ERASE Test.dbf

RETURN NIL

/*
 * EOF
 */
