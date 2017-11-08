/*
 * Ejemplo Browse n° 3
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Basado en un ejemplo de la distribución de OOHG mantenida
 * por Ciro Vargas Clemow <cvc@oohg.org>
 *
 * Este ejemplo muestra cómo habilitar las teclas F1 y F2
 * mientras el control está en modo edición, usando la
 * cláusula EDITKEYS.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"
#include "dbstruct.ch"

FUNCTION Main

   LOCAL oForm1, oBrowse1

   REQUEST DBFCDX, DBFFPT

   SET CENTURY ON
   SET DELETED ON
   SET BROWSESYNC ON

   DEFINE WINDOW Form_1 OBJ oForm1 ;
      AT 0,0 ;
      WIDTH 508 HEIGHT 380 ;
      TITLE 'Teclas Rápidas en Modo Edición' ;
      MAIN ;
      ON INIT OpenTables() ;
      ON RELEASE dbCloseAll()

      @ 10,10 BROWSE Browse_1 OBJ oBrowse1 ;
         WIDTH 480 ;
         HEIGHT 300 ;
         HEADERS { 'Código', ;
                   'Nombre', ;
                   'Apellido', ;
                   'Nacimiento', ;
                   'Casamiento', ;
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
         DELETE ;
         LOCK ;
         EDIT INPLACE ;
         FULLMOVE ;
         APPEND ;
         EDITKEYS { { "F1", {|| AutoMsgBox( "Control: " + oBrowse1:name + " - Columna: " + ltrim(str(This.CellColIndex))) } }, { "F2", {|| SetCellValue() } } }

      ON KEY ESCAPE ACTION Form_1.Release
   END WINDOW

   ACTIVATE WINDOW Form_1

RETURN Nil

//----------------------------------------------------------------------------//
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

   FOR i := 1 TO 100
      APPEND BLANK
      REPLACE code    WITH i * 10000
      REPLACE First   WITH 'Nombre '+ STR(i)
      REPLACE Last    WITH 'Apellido '+ STR(i)
      REPLACE Married WITH .T.
      REPLACE birth   WITH DATE() + i - 10000
   NEXT i

   INDEX ON code TO code

   GO BOTTOM

   Form_1.Browse_1.Value := RECNO()

RETURN Nil

//----------------------------------------------------------------------------//
FUNCTION SetCellValue

  LOCAL oCtrl

  oCtrl := GetControlObjectByHandle( GetFocus() )

  DO CASE
  CASE This.CellColIndex == 1
    oCtrl:Value := 12345
  CASE This.CellColIndex == 2
    oCtrl:Value := "NOMBRE"
  CASE This.CellColIndex == 3
    oCtrl:Value := "APELLIDO"
  CASE This.CellColIndex == 4
    oCtrl:Value := date()
  CASE This.CellColIndex == 5
    oCtrl:Value := 2
  CASE This.CellColIndex == 6
    oCtrl:Value := ""
  ENDCASE

  oCtrl:Setfocus()

RETURN Nil

/*
 * EOF
 */
