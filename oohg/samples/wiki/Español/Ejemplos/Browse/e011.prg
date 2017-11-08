/*
 * Ejemplo Browse n° 11
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo utilizar las cláusulas
 * BEFORECOLMOVE, AFTERCOLMOVE, BEFORECOLSIZE, AFTERCOLSIZE y
 * BEFOREAUTOFIT, y el método ColumnOrder de los controles
 * Grid, Browse y XBrowse.
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

   AbrirTabla()

   DEFINE WINDOW Form_1 OBJ oForm ;
      AT 0, 0 ;
      CLIENTAREA ;
      WIDTH 420 HEIGHT 420 ;
      TITLE 'Cabezales en Grid/XBrowse/Browse' ;
      MAIN ;
      ON RELEASE Limpiar()

      @ 10, 10 BROWSE Browse_1 OBJ oBrw ;
         WIDTH 400 ;
         HEIGHT 180 ;
         HEADERS {'Col.1', 'Col.2', 'Col.3'} ;
         WIDTHS {50, 150, 150} ;
         WORKAREA Data ;
         FIELDS {'code', 'number', 'issued'} ;
         BEFORECOLMOVE {|nCol| AntesDeMover( nCol )} ;
         AFTERCOLMOVE {|nCol, nPosicion| DespuesDeMover( nCol, nPosicion )} ;
         BEFORECOLSIZE {|nCol| AntesDeCambiar( nCol )} ;
         AFTERCOLSIZE {|nCol, nTam| DespuesDeCambiar( nCol, nTam )} ;
         BEFOREAUTOFIT {|nCol| AntesDeAutoAjuste( nCol )}

      @ 220, 10 BUTTON btn_GetOrden OBJ oBtn1 ;
         WIDTH 190 ;
         CAPTION "Mostrar orden de columnas" ;
         ACTION oLbl:Value := "Orden de columnas: " + ;
                              AUTOTYPE( oBrw:ColumnOrder )

      @ 220, 220 BUTTON btn_SetOrden OBJ oBtn2 ;
         WIDTH 190 ;
         CAPTION "Cambiar orden de columnas" ;
         ACTION ( oBrw:ColumnOrder := {3, 1, 2}, ;
                  oLbl:Value := "Orden de columnas: " + ;
                                AUTOTYPE( oBrw:ColumnOrder ) )

      @ 260, 10 LABEL lbl_Orden OBJ oLbl ;
         WIDTH 400 ;
         VALUE ""

      @ 300, 10 LABEL lbl_Nota ;
         WIDTH 400 ;
         HEIGHT 100 ;
         VALUE "Mueva o cambie el tamaño de un cabezal, o haga " + ;
               "dobleclic en un separador. No se permite mover " + ;
               "la columna 1, ni se permite modificar su tamaño " + ;
               "(ya sea por arrastre o utilizando el ajuste " + ;
               "automático). El tamaño mínimo de las columnas" + ;
               "2 y 3 debe ser 50." ;
         FONTCOLOR RED

      ON KEY ESCAPE ACTION oForm:Release()
   END WINDOW

   oForm:Center()
   oForm:Activate()

RETURN NIL

//--------------------------------------------------------------------------//
FUNCTION AbrirTabla()

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
FUNCTION Limpiar()

  DBCLOSEALL()

  ERASE Data.dbf

RETURN NIL

//--------------------------------------------------------------------------//
FUNCTION AntesDeMover( nCol )

   IF nCol == 1
      MSGBOX("No se permite mover la columna 1 !!!")
      RETURN .F.
   ENDIF

RETURN .T.

//--------------------------------------------------------------------------//
FUNCTION DespuesDeMover( nCol, nPosicion )

   AUTOMSGBOX( "La columna " + LTRIM(STR(nCol)) + ;
               " será movida a la posición " + LTRIM(STR(nPosicion)) )

   oLbl:Value := "Haga clic en el botón para ver el orden de las columnas."

RETURN .T.

//--------------------------------------------------------------------------//
FUNCTION AntesDeCambiar( nCol )

   IF nCol == 1
     // No se permite modificar el tamaño de la columna 1
     RETURN .F.
   ENDIF

RETURN .T.

//--------------------------------------------------------------------------//
FUNCTION DespuesDeCambiar( nCol, nTam )

   IF nTam < 50
      // El tamaño mínimo de las columnas debe ser 50
      RETURN 50
   ENDIF

RETURN nTam

//--------------------------------------------------------------------------//
FUNCTION AntesDeAutoAjuste( nCol )

   IF nCol == 1
     // No se permite el tamaño automático de la columna 1
     RETURN .F.
   ENDIF

RETURN .T.

/*
 * EOF
 */
