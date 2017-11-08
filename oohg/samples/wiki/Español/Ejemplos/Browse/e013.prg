/*
 * Ejemplo Browse n° 13
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo agregar una columna con
 * imágenes a un Browse preexistente (aplica también
 * a Grid y XBrowse).
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

   AbrirTablas()

   DEFINE WINDOW Form_1 ;
      OBJ oForm1 ;
      AT 0, 0 ;
      CLIENTAREA ;
      WIDTH 640 HEIGHT 480 ;
      TITLE 'Agregar columna "IMAGLIST" a un Browse' ;
      MAIN ;
      ON RELEASE CerrarTablas()

      @ 10, 10 BROWSE Browse_1 OBJ oBrw1 ;
         WIDTH 620 ;
         HEIGHT 180 ;
         HEADERS { 'Col.1', 'Col.2', 'Col.3', "Imagen" } ;
         WIDTHS { 50, 150, 150, 50 } ;
         WORKAREA Data ;
         FIELDS { 'code', 'number', 'issued', 'image' } ;
         COLUMNCONTROLS { NIL, NIL, NIL, {'IMAGELIST'} } ;
         IMAGE { 'MINIGUI_EDIT_CANCEL', ;
                 'MINIGUI_EDIT_COPY', ;
                 'MINIGUI_EDIT_OK' } ;
         EDIT INPLACE

      @ 220, 10 BUTTON btn_Add ;
         CAPTION "Agregar columna" ;
         ACTION AddColumn( oBrw1 )

      ON KEY ESCAPE ACTION oForm1:Release()
   END WINDOW

   oForm1:Center()
   oForm1:Activate()

RETURN NIL

//--------------------------------------------------------------------------//
FUNCTION AbrirTablas

   LOCAL aDbf1[ 4 ][ 4 ]

   aDbf1[ 1 ][ DBS_NAME ] := "code"
   aDbf1[ 1 ][ DBS_TYPE ] := "Numeric"
   aDbf1[ 1 ][ DBS_LEN ]  := 10
   aDbf1[ 1 ][ DBS_DEC ]  := 0

   aDbf1[ 2 ][ DBS_NAME ] := "number"
   aDbf1[ 2 ][ DBS_TYPE ] := "Numeric"
   aDbf1[ 2 ][ DBS_LEN ]  := 6
   aDbf1[ 2 ][ DBS_DEC ]  := 0

   aDbf1[ 3 ][ DBS_NAME ] := "issued"
   aDbf1[ 3 ][ DBS_TYPE ] := "Date"
   aDbf1[ 3 ][ DBS_LEN ]  := 8
   aDbf1[ 3 ][ DBS_DEC ]  := 0

   aDbf1[ 4 ][ DBS_NAME ] := "image"
   aDbf1[ 4 ][ DBS_TYPE ] := "Numeric"
   aDbf1[ 4 ][ DBS_LEN ]  := 1
   aDbf1[ 4 ][ DBS_DEC ]  := 0

   DBCREATE( "Data", aDbf1, "DBFCDX" )

   SELECT 0
   USE Data VIA "DBFCDX"
   ZAP

   APPEND BLANK
   REPLACE code   WITH 355
   REPLACE number WITH 9334
   REPLACE issued WITH CTOD( "09/12/1967" )
   REPLACE image  WITH 0
   APPEND BLANK
   REPLACE code   WITH 123
   REPLACE number WITH 8765
   REPLACE issued WITH CTOD( "14/03/1961" )
   REPLACE image  WITH 1
   APPEND BLANK
   REPLACE code   WITH 7
   REPLACE number WITH 565
   REPLACE issued WITH CTOD( "27/08/1968" )
   REPLACE image  WITH 2
   APPEND BLANK
   REPLACE code   WITH 123
   REPLACE number WITH 5433
   REPLACE issued WITH CTOD( "05/02/1963" )
   REPLACE image  WITH 2
   APPEND BLANK
   REPLACE code   WITH 7
   REPLACE number WITH 54322
   REPLACE issued WITH CTOD( "31/10/1969" )
   REPLACE image  WITH 1
   APPEND BLANK
   REPLACE code   WITH 355
   REPLACE number WITH 76865
   REPLACE issued WITH CTOD( "19/09/1966" )
   REPLACE image  WITH 0
   APPEND BLANK
   REPLACE code   WITH 76
   REPLACE number WITH 53377
   REPLACE issued WITH CTOD( "05/02/1963" )
   REPLACE image  WITH 1
   APPEND BLANK
   REPLACE code   WITH 7
   REPLACE number WITH 5654
   REPLACE issued WITH CTOD( "07/04/1965" )
   REPLACE image  WITH 2
   APPEND BLANK
   REPLACE code   WITH 123
   REPLACE number WITH 7687
   REPLACE issued WITH CTOD( "22/06/1962" )
   REPLACE image  WITH 1
   APPEND BLANK
   REPLACE code   WITH 76
   REPLACE number WITH 53377
   REPLACE issued WITH CTOD( "05/02/1963" )
   REPLACE image  WITH 0

   GO TOP

RETURN NIL

//--------------------------------------------------------------------------//
FUNCTION CerrarTablas

  DBCLOSEALL()

  ERASE Data.dbf

RETURN NIL

//--------------------------------------------------------------------------//
FUNCTION AddColumn(oBrw1)

   oBrw1:ClearBitMaps()
   oBrw1:AddBitMap( { 'MINIGUI_EDIT_CANCEL', ;
                      'MINIGUI_EDIT_COPY', ;
                      'MINIGUI_EDIT_OK' } )

   // Vea los parametros en h_xbrowse.prg
   oBrw1:AddColumn( NIL, ;           // agregar en la última posición
                    "image", ;
                    "Imagen", ;
                    50, ;
                    NIL, ;
                    NIL, ;
                    NIL, ;
                    NIL, ;
                    NIL, ;
                    { 'IMAGELIST' } )

RETURN NIL

/*
 * EOF
 */
