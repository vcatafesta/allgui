/*
 * Ejemplo Browse # 18
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo derivar el flujo del programa a
 * otro control mientras estamos en el evento ON EDITCELL de
 * un Browse.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"
#include "dbstruct.ch"

Function Main

   LOCAL oForm, oBrowse

   REQUEST DBFCDX, DBFFPT

   SET CENTURY ON
   SET DELETED ON
   SET BROWSESYNC ON

   AbrirTablas()

   DEFINE WINDOW Form_1 OBJ oForm ;
      AT 0,0 ;
      CLIENTAREA ;
      WIDTH 500 HEIGHT 380 ;
      MINWIDTH 500 MINHEIGHT 380 ;
      TITLE 'ooHG Demo - Cómo derivar el flujo del programa dentro de un Browse' ;
      MAIN NOMAXIMIZE ;
      ON RELEASE Limpiar() ;
      ON SIZE ( oBrowse:Width  := oForm:ClientWidth - 40, ;
                oBrowse:Height := oForm:ClientHeight - 40 )

      @ 20,20 BROWSE Browse_1 OBJ oBrowse ;
         WIDTH oForm:ClientWidth - 40 ;
         HEIGHT oForm:ClientHeight - 40 ;
         HEADERS { 'Código', ;
                   'Nombre', ;
                   'Apellido', ;
                   'Nacido', ;
                   'Casado', ;
                   'Biografía' } ;
         WIDTHS { 150 , 150 , 150 , 150 , 150 , 150 } ;
         WORKAREA test ;
         FIELDS { 'Test->Code', ;
                  'Test->First', ;
                  'Test->Last', ;
                  'Test->Birth', ;
                  'Test->Married', ;
                  'Test->Bio' } ;
         FONT "Courier New" SIZE 10 ;
         JUSTIFY { BROWSE_JTFY_RIGHT, ;
                   BROWSE_JTFY_CENTER, ;
                   BROWSE_JTFY_CENTER, ;
                   BROWSE_JTFY_CENTER, ;
                   BROWSE_JTFY_CENTER, ;
                   BROWSE_JTFY_CENTER} ;
         EDIT INPLACE ;
         ON EDITCELL MiFuncion()

      ON KEY ESCAPE ACTION Form_1.Release
   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

RETURN Nil

//----------------------------------------------------------------------------
FUNCTION AbrirTablas()

   LOCAL aDbf[6][4]

   aDbf[1][ DBS_NAME ] := "Code"
   aDbf[1][ DBS_TYPE ] := "Numeric"
   aDbf[1][ DBS_LEN ]  := 10
   aDbf[1][ DBS_DEC ]  := 0

   aDbf[2][ DBS_NAME ] := "First"
   aDbf[2][ DBS_TYPE ] := "Character"
   aDbf[2][ DBS_LEN ]  := 25
   aDbf[2][ DBS_DEC ]  := 0

   aDbf[3][ DBS_NAME ] := "Last"
   aDbf[3][ DBS_TYPE ] := "Character"
   aDbf[3][ DBS_LEN ]  := 25
   aDbf[3][ DBS_DEC ]  := 0

   aDbf[4][ DBS_NAME ] := "Married"
   aDbf[4][ DBS_TYPE ] := "Logical"
   aDbf[4][ DBS_LEN ]  := 1
   aDbf[4][ DBS_DEC ]  := 0

   aDbf[5][ DBS_NAME ] := "Birth"
   aDbf[5][ DBS_TYPE ] := "Date"
   aDbf[5][ DBS_LEN ]  := 8
   aDbf[5][ DBS_DEC ]  := 0

   aDbf[6][ DBS_NAME ] := "Bio"
   aDbf[6][ DBS_TYPE ] := "Memo"
   aDbf[6][ DBS_LEN ]  := 10
   aDbf[6][ DBS_DEC ]  := 0

   DBCREATE("Test", aDbf, "DBFCDX")

   USE test VIA "DBFCDX"
   ZAP

   FOR i:= 1 TO 100
      APPEND BLANK
      REPLACE code    WITH i * 10000
      REPLACE First   WITH 'Nombre '+ STR(i)
      REPLACE Last    WITH 'Apellido '+ STR(i)
      REPLACE Married WITH .t.
      REPLACE birth   WITH DATE() + i - 10000
   NEXT i

   INDEX ON code TO code

   GO TOP

RETURN Nil

//----------------------------------------------------------------------------
FUNCTION MiFuncion()

   IF This.CellColIndex == 2
      DEFINE WINDOW Form_2 ;
         AT 0,0 ;
         CLIENTAREA ;
         WIDTH 380 HEIGHT 380 ;
         TITLE 'Seleccione un ítem con dobleclic' ;
         NOSIZE NOMAXIMIZE ;
         MODAL

         @ 20,20 LISTBOX lst_1 ;
            WIDTH 340 ;
            ITEMS {'uno', 'dos', 'tres' } ;
            ON DBLCLICK Form_2.Release

         ON KEY ESCAPE ACTION Form_2.Release
      END WINDOW

      CENTER WINDOW Form_2

      ACTIVATE WINDOW Form_2
   ENDIF

RETURN Nil

//--------------------------------------------------------------------------//
FUNCTION Limpiar()

  dbCloseAll()

  ERASE Test.dbf
  ERASE Test.fpt
  ERASE Code.cdx

RETURN NIL

/*
 * EOF
 */
