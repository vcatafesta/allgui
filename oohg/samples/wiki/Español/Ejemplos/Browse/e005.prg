/*
 * Ejemplo Browse n° 5
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Basado en un ejemplo de la distribución de OOHG mantenida
 * por Ciro Vargas Clemow <cvc@oohg.org>
 *
 * Este ejemplo muestra cómo vincular algunos controles
 * con un control Browse, de tal forma que cuando cambia
 * el value del Browse los values de los controles son
 * cambiados de manera acorde.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"
#include "dbstruct.ch"

FUNCTION Main
   LOCAL oForm1, oBrw1

   REQUEST DBFCDX, DBFFPT

   SET CENTURY ON
   SET DATE BRITISH
   SET DELETED ON
   SET BROWSESYNC ON
   SET LANGUAGE TO SPANISH

   AbrirTablas()

   DEFINE WINDOW Form_1 OBJ oForm1 ;
      AT 0,0 ;
      CLIENTAREA ;
      WIDTH 618 HEIGHT 380 ;
      TITLE 'Controles vinculados a un Browse' ;
      MAIN ;
      ON INIT oBrw1:value := Test->(recno()) ;
      ON INTERACTIVECLOSE VerificarSalida() ;
      ON RELEASE Limpieza()

      @ 10,10 BROWSE Browse_1 OBJ oBrw1 ;
         WIDTH 410 ;
         HEIGHT 340 ;
         HEADERS { 'Código', 'Nombre', 'Apellido', ;
                   'Nacido', 'Casado' , 'Biografía' } ;
         WIDTHS { 150 , 150 , 150 , 150 , 150 , 150 } ;
         WORKAREA Test ;
         FIELDS { 'Test->Code', 'Test->First', 'Test->Last', ;
                  'Test->Birth', 'Test->Married', 'Test->Bio' } ;
         FONT "Courier New" SIZE 10 ;
         JUSTIFY { BROWSE_JTFY_RIGHT,BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER, ;
                   BROWSE_JTFY_CENTER,BROWSE_JTFY_CENTER,BROWSE_JTFY_CENTER} ;
         COLUMNCONTROLS {NIL, NIL, NIL, NIL, {'LCOMBOBOX','Si','No'}, NIL} ;
         ON CHANGE (oTxtName:value := Test->First, ;
                    oCmbType:value := Test->Code, ;
                    oDtpDate:value := Test->Birth)

      @ 10,430 COMBOBOX cmb_Type OBJ oCmbType ;
         WIDTH 180 ;
         ITEMSOURCE Codes->Name ;
         VALUESOURCE Codes->Code

      @ 50,430 TEXTBOX txt_Name OBJ oTxtName ;
        WIDTH 180 ;
        HEIGHT 24 ;
        MAXLENGTH 25

      @ 90,430 DATEPICKER dtp_Date OBJ oDtpDate ;
        WIDTH 180

      @ 210,430 LABEL lbl_Note ;
        WIDTH 180 ;
        HEIGHT 50 ;
        VALUE "Vea lo que sucede cuando se cambia el item seleccionado en el Browse." ;
        FONTCOLOR RED

      ON KEY ESCAPE ACTION IF(VerificarSalida(), oForm1:Release(), NIL)
   END WINDOW

   oForm1:Center()
   oForm1:Activate()

RETURN Nil

//--------------------------------------------------------------------------//
FUNCTION AbrirTablas()

   LOCAL i, aDbf1[2][4], aDbf2[6][4]

   // Create codes database

   aDbf1[1][ DBS_NAME ] := "Code"
   aDbf1[1][ DBS_TYPE ] := "Numeric"
   aDbf1[1][ DBS_LEN ]  := 10
   aDbf1[1][ DBS_DEC ]  := 0

   aDbf1[2][ DBS_NAME ] := "Name"
   aDbf1[2][ DBS_TYPE ] := "Character"
   aDbf1[2][ DBS_LEN ]  := 25
   aDbf1[2][ DBS_DEC ]  := 0

   DBCREATE("Codes", aDbf1, "DBFCDX")

   SELECT 0
   USE codes VIA "DBFCDX"
   ZAP

   FOR i := 0 TO 4
      APPEND BLANK
      REPLACE code    WITH i
      REPLACE Name    WITH 'Nombre del código '+ LTRIM(STR(i))
   NEXT i

   INDEX ON code TAG code TO Codes

   // Create test database

   aDbf2[1][ DBS_NAME ] := "Code"
   aDbf2[1][ DBS_TYPE ] := "Numeric"
   aDbf2[1][ DBS_LEN ]  := 10
   aDbf2[1][ DBS_DEC ]  := 0

   aDbf2[2][ DBS_NAME ] := "First"
   aDbf2[2][ DBS_TYPE ] := "Character"
   aDbf2[2][ DBS_LEN ]  := 25
   aDbf2[2][ DBS_DEC ]  := 0

   aDbf2[3][ DBS_NAME ] := "Last"
   aDbf2[3][ DBS_TYPE ] := "Character"
   aDbf2[3][ DBS_LEN ]  := 25
   aDbf2[3][ DBS_DEC ]  := 0

   aDbf2[4][ DBS_NAME ] := "Married"
   aDbf2[4][ DBS_TYPE ] := "Logical"
   aDbf2[4][ DBS_LEN ]  := 1
   aDbf2[4][ DBS_DEC ]  := 0

   aDbf2[5][ DBS_NAME ] := "Birth"
   aDbf2[5][ DBS_TYPE ] := "Date"
   aDbf2[5][ DBS_LEN ]  := 8
   aDbf2[5][ DBS_DEC ]  := 0

   aDbf2[6][ DBS_NAME ] := "Bio"
   aDbf2[6][ DBS_TYPE ] := "Memo"
   aDbf2[6][ DBS_LEN ]  := 10
   aDbf2[6][ DBS_DEC ]  := 0

   DBCREATE("Test", aDbf2, "DBFCDX")

   SELECT 0
   USE test VIA "DBFCDX"
   ZAP

   FOR i := 1 TO 100
      APPEND BLANK
      REPLACE code    WITH i % 5
      REPLACE First   WITH 'Nombre '+ LTRIM(STR(i))
      REPLACE Last    WITH 'Apellido '+ LTRIM(STR(i))
      REPLACE Married WITH (i % 2 == 0)
      REPLACE birth   WITH DATE() + i - 10000
   NEXT i

   GO TOP

RETURN NIL

//--------------------------------------------------------------------------//
FUNCTION VerificarSalida()

RETURN MsgYesNo("¿ Está seguro de querer salir ?") ;

//--------------------------------------------------------------------------//
FUNCTION Limpieza()

  dbCloseAll()

  ERASE Test.dbf
  ERASE Codes.dbf
  ERASE Codes.cdx

RETURN NIL

/*
 * EOF
 */
