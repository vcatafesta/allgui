/*
 * Ejemplo Grid n° 13
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo utilizar varias cláusulas y 
 * métodos relacionados con los cabezales de columna de los
 * controles Grid, XBrowse y Browse.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"
#include "dbstruct.ch"

FUNCTION Main

   PUBLIC oForm, oBrw

   REQUEST DBFCDX

   SET BROWSESYNC ON
   SET DATE BRITISH
   SET LANGUAGE TO SPANISH

   OpenTable()

   DEFINE WINDOW Form_1 OBJ oForm ;
      AT 0, 0 ;
      CLIENTAREA ;
      WIDTH 420 HEIGHT 420 ;
      TITLE 'Cabezales de Columnas en Grid/XBrowse/Browse' ;
      MAIN ;
      ON RELEASE CleanUp()

      @ 10, 10 BROWSE Browse_1 OBJ oBrw ;
         WIDTH 400 ;
         HEIGHT 180 ;
         HEADERS {'Col.1', 'Col.2', 'Col.3'} ;
         WIDTHS {50, 150, 150} ;
         WORKAREA Data ;
         FIELDS {'code', 'number', 'issued'} ;
         BEFORECOLMOVE {|nCol| BeforeColMove( nCol )} ;
         AFTERCOLMOVE {|nCol, nPos| AfterColMove( nCol, nPos )} ;
         BEFORECOLSIZE {|nCol| BeforeColSize( nCol )} ;
         AFTERCOLSIZE {|nCol, nSize| AfterColSize( nCol, nSize )} ;
         BEFOREAUTOFIT {|nCol| BeforeAutoFit( nCol )}

      @ 220, 10 BUTTON btn_GetOrder OBJ oBtn1 ;
         WIDTH 190 ;
         CAPTION "Mostrar orden de columnas" ;
         ACTION oLbl:Value := "Orden de columnas: " + ;
                              AUTOTYPE( oBrw:ColumnOrder )

      @ 220, 220 BUTTON btn_SetOrder OBJ oBtn2 ;
         WIDTH 190 ;
         CAPTION "Cambiar orden de columnas" ;
         ACTION ( oBrw:ColumnOrder := {3, 1, 2}, ;
                  oLbl:Value := "Orden de columnas: " + ;
                                AUTOTYPE( oBrw:ColumnOrder ) )

      @ 260, 10 LABEL lbl_Order OBJ oLbl ;
         WIDTH 400 ;
         VALUE ""

      @ 300, 10 LABEL lbl_Note ;
         WIDTH 400 ;
         HEIGHT 55 ;
         VALUE "Mover o cambiar el tamaño del cabezal, o hacer doble clic " + ;
               "en un divisor de columna. No se permite mover la columna 1, " + ;
               "ni cambiar su tamaño (ya sea por arrastre o con autofit). " + ;
               "El tamaño mínimo de las columnas 2 y 3 debe ser 50." ;
         FONTCOLOR RED

      @ 360, 220 BUTTON btn_Widths OBJ oBtn3 ;
         WIDTH 190 ;
         CAPTION "Mostrar el ancho de las columnas" ;
         ACTION ( AUTOMSGBOX( oBrw:aWidths ) )

      ON KEY ESCAPE ACTION oForm:Release()
   END WINDOW

   oForm:Center()
   oForm:Activate()

RETURN NIL

//--------------------------------------------------------------------------//
FUNCTION OpenTable()

   LOCAL aDbf1[ 3 ][ 4 ]

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

   DBCREATE( "Data", aDbf1, "DBFCDX" )

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

   GO TOP

RETURN NIL

//--------------------------------------------------------------------------//
FUNCTION CleanUp()

  DBCLOSEALL()

  ERASE Data.dbf

RETURN NIL

//--------------------------------------------------------------------------//
FUNCTION BeforeColMove( nCol )

   IF nCol == 1
      MSGBOX("No se permite mover la columna 1 !!!")
      RETURN .F.
   ENDIF

RETURN .T.

//--------------------------------------------------------------------------//
FUNCTION AfterColMove( nCol, nPosicion )

   AUTOMSGBOX( "La columna " + LTRIM(STR(nCol)) + ;
               " se moverá a la posición " + LTRIM(STR(nPosicion)) )

   oLbl:Value := "Haga clic en el botón para ver el orden de las columnas."

RETURN .T.

//--------------------------------------------------------------------------//
FUNCTION BeforeColSize( nCol )

   IF nCol == 1
     // No se permite cambiar el ancho de la columnas 1
     RETURN .F.
   ENDIF

RETURN .T.

//--------------------------------------------------------------------------//
FUNCTION AfterColSize( nCol, nSize )

   IF nSize < 50
      // El ancho mínimo de la columna debe ser 50
      RETURN 50
   ENDIF

RETURN nSize

//--------------------------------------------------------------------------//
FUNCTION BeforeAutoFit( nCol )

   IF nCol == 1
     // No se permite hacer autofit de la columna 1
     RETURN .F.
   ENDIF

RETURN .T.

/*
 * EOF
 */
