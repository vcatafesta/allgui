/*
 * Ejemplo Browse n° 10
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo vincular un control
 * Browse con otro control Browse.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"
#include "dbstruct.ch"

FUNCTION Main
   LOCAL oForm1, oBrw1

   REQUEST DBFCDX

   SET BROWSESYNC ON
   SET DATE BRITISH
   SET LANGUAGE TO SPANISH

   OpenTables()

   DEFINE WINDOW Form_1 ;
      OBJ oForm1 ;
      AT 0, 0 ;
      CLIENTAREA ;
      WIDTH 420 HEIGHT 420 ;
      TITLE 'Browse vinculado a otro Browse' ;
      MAIN ;
      ON INIT oBrw1:value := Code->(recno()) ;
      ON RELEASE CleanUp()

      @ 10, 10 BROWSE Browse_1 OBJ oBrw1 ;
         WIDTH 400 ;
         HEIGHT 180 ;
         HEADERS { 'Código', 'Nombre' } ;
         WIDTHS { 150, 150 } ;
         WORKAREA Code ;
         FIELDS { 'Code->code', 'Code->name' } ;
         ON CHANGE oBrw2:GoTop()

      @ 200, 10 BROWSE Browse_2 OBJ oBrw2 ;
         WIDTH 400 ;
         HEIGHT 180 ;
         HEADERS { 'Código', 'Nombre', 'Emitida' } ;
         WIDTHS { 150, 150, 150 } ;
         WORKAREA Data ;
         FIELDS { 'Data->code', 'Data->number', 'Data->issued' } ;

      @ 390, 10 LABEL lbl_Note ;
         WIDTH 400 ;
         HEIGHT 40 ;
         VALUE "Vea lo que sucede cuando se cambia el ítem seleccionado en el browse superior." ;
         FONTCOLOR RED

      ON KEY ESCAPE ACTION oForm1:Release()
   END WINDOW

   oForm1:Center()
   oForm1:Activate()

RETURN NIL

//--------------------------------------------------------------------------//
FUNCTION OpenTables()

   LOCAL aDbf1[ 2 ][ 4 ], aDbf2[ 3 ][ 4 ]

   // Crear la base de datos "Code"

   aDbf1[ 1 ][ DBS_NAME ] := "Code"
   aDbf1[ 1 ][ DBS_TYPE ] := "Numeric"
   aDbf1[ 1 ][ DBS_LEN ]  := 10
   aDbf1[ 1 ][ DBS_DEC ]  := 0

   aDbf1[ 2 ][ DBS_NAME ] := "Name"
   aDbf1[ 2 ][ DBS_TYPE ] := "Character"
   aDbf1[ 2 ][ DBS_LEN ]  := 25
   aDbf1[ 2 ][ DBS_DEC ]  := 0

   DBCREATE( "Code", aDbf1, "DBFCDX" )

   SELECT 0
   USE Code VIA "DBFCDX"
   ZAP

   APPEND BLANK
   REPLACE code WITH 123
   REPLACE Name WITH 'Homer'
   APPEND BLANK
   REPLACE code WITH 355
   REPLACE Name WITH 'Tom'
   APPEND BLANK
   REPLACE code WITH 76
   REPLACE Name WITH 'Mike'
   APPEND BLANK
   REPLACE code WITH 7
   REPLACE Name WITH 'Martha'

   GO TOP

   // Crear la base de datos "Data"

   aDbf2[ 1 ][ DBS_NAME ] := "Code"
   aDbf2[ 1 ][ DBS_TYPE ] := "Numeric"
   aDbf2[ 1 ][ DBS_LEN ]  := 10
   aDbf2[ 1 ][ DBS_DEC ]  := 0

   aDbf2[ 2 ][ DBS_NAME ] := "Number"
   aDbf2[ 2 ][ DBS_TYPE ] := "Numeric"
   aDbf2[ 2 ][ DBS_LEN ]  := 6
   aDbf2[ 2 ][ DBS_DEC ]  := 0

   aDbf2[ 3 ][ DBS_NAME ] := "Issued"
   aDbf2[ 3 ][ DBS_TYPE ] := "Date"
   aDbf2[ 3 ][ DBS_LEN ]  := 8
   aDbf2[ 3 ][ DBS_DEC ]  := 0

   DBCREATE( "Data", aDbf2, "DBFCDX" )

   SELECT 0
   USE Data VIA "DBFCDX"
   ZAP

   APPEND BLANK
   REPLACE code   WITH 355
   REPLACE number WITH 9334
   REPLACE issued WITH CTOD( "09/12/1967" )
   APPEND BLANK
   REPLACE code   WITH 123
   REPLACE number WITH 8765
   REPLACE issued WITH CTOD( "14/03/1961" )
   APPEND BLANK
   REPLACE code   WITH 7
   REPLACE number WITH 565
   REPLACE issued WITH CTOD( "27/08/1968" )
   APPEND BLANK
   REPLACE code   WITH 123
   REPLACE number WITH 5433
   REPLACE issued WITH CTOD( "05/02/1963" )
   APPEND BLANK
   REPLACE code   WITH 7
   REPLACE number WITH 54322
   REPLACE issued WITH CTOD( "31/10/1969" )
   APPEND BLANK
   REPLACE code   WITH 355
   REPLACE number WITH 76865
   REPLACE issued WITH CTOD( "19/09/1966" )
   APPEND BLANK
   REPLACE code   WITH 76
   REPLACE number WITH 53377
   REPLACE issued WITH CTOD( "05/02/1963" )
   APPEND BLANK
   REPLACE code   WITH 7
   REPLACE number WITH 5654
   REPLACE issued WITH CTOD( "07/04/1965" )
   APPEND BLANK
   REPLACE code   WITH 123
   REPLACE number WITH 7687
   REPLACE issued WITH CTOD( "22/06/1962" )
   APPEND BLANK
   REPLACE code   WITH 76
   REPLACE number WITH 53377
   REPLACE issued WITH CTOD( "05/02/1963" )

   SET FILTER TO Data->code == Code->code

   GO TOP

RETURN NIL

//--------------------------------------------------------------------------//
FUNCTION CleanUp()

  DBCLOSEALL()

  ERASE Code.dbf
  ERASE Data.dbf

RETURN NIL

/*
 * EOF
 */
