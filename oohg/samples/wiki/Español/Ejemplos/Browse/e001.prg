/*
 * Ejemplo Browse n° 1
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Basado en un ejemplo de la distribución de OOHG mantenida
 * por Ciro Vargas Clemow <cvc@oohg.org>
 *
 * Este ejemplo muestra cómo identificar la columna del
 * browse en la que el usuario acaba de hacer dobleclic.
 * También ilustra la forma de crear y agregar registros
 * a una dbf en tiempo de ejecución.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"
#include "dbstruct.ch"

FUNCTION Main

   LOCAL oForm, oBrowse

   REQUEST DBFCDX , DBFFPT

   SET CENTURY ON
   SET DELETED ON
   SET BROWSESYNC ON

   OpenTables()

   DEFINE WINDOW Form_1 OBJ oForm ;
      AT 0,0 ;
      CLIENTAREA ;
      WIDTH 500 HEIGHT 380 ;
      MINWIDTH 500 MINHEIGHT 380 ;
      TITLE 'ooHG Demo - Identificar la columna cliqueada en un Browse' ;
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
                   'Nacimiento', ;
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
         ON DBLCLICK MyFunction()

      ON KEY ESCAPE ACTION Form_1.Release
   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

RETURN Nil

//----------------------------------------------------------------------------
FUNCTION OpenTables()

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
      REPLACE First   WITH 'First Name '+ STR(i)
      REPLACE Last    WITH 'Last Name '+ STR(i)
      REPLACE Married WITH .t.
      REPLACE birth   WITH DATE() + i - 10000
   NEXT i

   INDEX ON code TO code

   GO TOP

RETURN Nil

//----------------------------------------------------------------------------
FUNCTION MyFunction

   AutoMsgBox( This.CellColIndex )

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
