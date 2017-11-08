/*
 * Ejemplo OpenOffice n° 3
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo crear un libro de OpenOffice
 * Calc a partir de un array, cómo crear una DBF a partir
 * de un libro y cómo manejar los errores que ocurran
 * durante las operaciones.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include 'oohg.ch'

FUNCTION Main

   LOCAL oForm

   SET DATE BRITISH
   SET CENTURY ON

   DEFINE WINDOW Form_1 ;
      OBJ oForm ;
      AT 0,0 ;
      WIDTH 500 ;
      HEIGHT 280 ;
      TITLE "Copiar un libro de OpenOffice Calc a una Dbf" ;
      MAIN

      DEFINE STATUSBAR
         STATUSITEM 'El poder de OOHG !!!'
      END STATUSBAR

      @ 20,20 BUTTON btn_Execute ;
         CAPTION 'Ejecutar' ;
         WIDTH 140 ;
         ACTION MiProceso( oForm )

      ON KEY ESCAPE ACTION Form_1.Release()
   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN NIL

FUNCTION MiProceso( oForm )

   LOCAL cBefore, oSerM, oDesk, oBook, oPropVals, oSheet, bErrBlck2, x, bErrBlck1
   LOCAL nLin, nCol, cFile, oCell, nRow, uValue
   LOCAL aHeaders := { 'CODIGO', 'NUMERO', 'FECHA', 'REFERENCIA', 'MONTO' }
   LOCAL aData    := { { "AB1", 12, Date(), "Ref. 12", 128.10 }, ;
                       { "AB5", 34, Date(), "Ref. 34", 578.43 }, ;
                       { "XC3", 87, Date(), "Ref. 87", 879.60 }, ;
                       { "MN6", 65, Date(), "Ref. 65", 322.33 }, ;
                       { "OO9", 90, Date(), "Ref. 90", 765.77 } }

   cFile := HB_DirBase() + "PRUEBA.ODS"

   cBefore := oForm:StatusBar:Item( 1 )
   oForm:StatusBar:Item( 1, 'Creando ' + cFile + ' ...' )

   ERASE (cFile)

   // abrir el Service Manager
   #ifndef __XHARBOUR__
      IF( oSerM := win_oleCreateObject( 'com.sun.star.ServiceManager' ) ) == NIL
         MsgStop( 'Error: OpenOffice no está disponible. [' + win_oleErrorText()+ ']' )
         RETURN NIL
      ENDIF
   #else
      oSerM := TOleAuto():New( 'com.sun.star.ServiceManager' )
      IF Ole2TxtError() != 'S_OK'
         MsgStop( 'Error: OpenOffice no está disponible.' )
         RETURN NIL
      ENDIF
   #endif

   // capturar todos los errores
   bErrBlck1 := ErrorBlock( { | x | break( x ) } )

   BEGIN SEQUENCE
      // abrir el Desktop Service
      IF (oDesk := oSerM:CreateInstance("com.sun.star.frame.Desktop")) == NIL
         MsgStop( 'Error: OpenOffice Desktop no está disponible.' )
         BREAK
      ENDIF

      // definir las propiedades del libro
      oPropVals := oSerM:Bridge_GetStruct("com.sun.star.beans.PropertyValue")
      oPropVals:Name := "Hidden"
      oPropVals:Value := .T.

      // abrir el libro
      IF (oBook := oDesk:LoadComponentFromURL("private:factory/scalc", "_blank", 0, {oPropVals})) == NIL
         MsgStop( 'Error: OpenOffice Calc no está disponible.' )
         BREAK
      ENDIF

      // definir que la primera hoja será la corriente
      oSheet := oBook:Sheets:GetByIndex(0)
      oBook:getCurrentController:SetActiveSheet(oSheet)

      // cambiar el nombre de la hoja y la fuente por defecto
      oSheet:Name := "Data"
      oSheet:CharFontName := 'Arial'
      oSheet:CharHeight := 10

      // poner el título
      oCell := oSheet:GetCellByPosition( 0, 0 )
      oCell:SetString( 'Exportado desde OOHG !!!' )
      oCell:CharWeight := 150

      // poner los cabezales con letra negrita
      nLin := 4
      FOR nCol := 1 TO 5
         oCell := oSheet:GetCellByPosition( nCol - 1, nLin - 1 )
         oCell:SetString( aHeaders[ nCol ] )
         oCell:CharWeight := 150
      NEXT
      nLin += 2

      // poner las filas
      FOR nRow := 1 to 5
         FOR nCol := 1 to 5
            oCell := oSheet:GetCellByPosition( nCol - 1, nLin - 1 )
            uValue := aData[ nRow, nCol ]
            DO CASE
            CASE uValue == NIL
            CASE ValType( uValue ) == "C"
               IF Left( uValue, 1 ) == "'"
                  uValue := "'" + uValue
               ENDIF
               oCell:SetString( uValue )
            CASE ValType( uValue ) == "N"
               oCell:SetValue( uValue )
            CASE ValType( uValue ) == "L"
               oCell:SetValue( uValue )
               oCell:SetPropertyValue("NumberFormat", 99 )
            CASE ValType( uValue ) == "D"
               oCell:SetValue( uValue )
               oCell:SetPropertyValue( "NumberFormat", 36 )
            CASE ValType( uValue ) == "T"
               oCell:SetString( uValue )
            OTHERWISE
               oCell:SetFormula( uValue )
            ENDCASE
         NEXT
         nRow ++
         nLin ++
      NEXT

      // autoajustar el ancho de las columnas
      oSheet:GetColumns():SetPropertyValue( "OptimalWidth", .T. )

      bErrBlck2 := ErrorBlock( { | x | break( x ) } )
      BEGIN SEQUENCE
         // grabar el libro
         oBook:StoreToURL( OO_ConvertToURL( cFile ), {} )
         oBook:Close( 1 )

         IF MsgYesNo( cFile + ' fue creada.' + HB_OsNewLine() + "Crear la Dbf?" )
            ConvertToDbf( oForm, cFile )
         ENDIF
      RECOVER USING x
         // si oBook:StoreToURL() falla, mostrar el error
         MsgStop( x:Description, "Error de OpenOffice" )
         MsgStop( cFile + ' no fue creada !!!' )
      END SEQUENCE

      ErrorBlock( bErrBlck2 )
   RECOVER USING x
      MsgStop( x:Description, "Error de OpenOffice" )
   END SEQUENCE

   ErrorBlock( bErrBlck1 )

   // eliminar referencias a OpenOffice
   oCell  := NIL
   oSheet := NIL
   oBook  := Nil
   oDesk  := Nil
   oSerM  := Nil

   Form_1.StatusBar.Item( 1 ) := cBefore

RETURN NIL

FUNCTION ConvertToDbf( oForm, cFile )

   LOCAL cBefore, oSerM, oDesk, oPropVal1, oPropVal2, oBook, oSheet, bErrBlck1, oCellCursor
   LOCAL i, nRows, nCols, nLin, aFields, cDbf

   cBefore := oForm:StatusBar:Item( 1 )
   oForm:StatusBar:Item( 1, 'Abriendo ' + cFile + ' ...' )

   cDbf := HB_DirBase() + "PRUEBA.DBF"

   #ifndef __XHARBOUR__
      IF( oSerM := win_oleCreateObject( 'com.sun.star.ServiceManager' ) ) == NIL
         MsgStop( 'Error: OpenOffice no está disponible. [' + win_oleErrorText()+ ']' )
         RETURN NIL
      ENDIF
   #else
      oSerM := TOleAuto():New( 'com.sun.star.ServiceManager' )
      IF Ole2TxtError() != 'S_OK'
         MsgStop( 'Error: OpenOffice no está disponible.' )
         RETURN NIL
      ENDIF
   #endif

   bErrBlck1 := ErrorBlock( { | x | break( x ) } )

   BEGIN SEQUENCE
      IF (oDesk := oSerM:CreateInstance("com.sun.star.frame.Desktop")) == NIL
         MsgStop( 'Error: OpenOffice Desktop no está disponible.' )
         BREAK
      ENDIF

      oPropVal1 := oSerM:Bridge_GetStruct("com.sun.star.beans.PropertyValue")
      oPropVal1:Name := "Hidden"
      oPropVal1:Value := .T.
      oPropVal2 := oSerM:Bridge_GetStruct("com.sun.star.beans.PropertyValue")
      oPropVal2:Name := "ReadOnly"
      oPropVal2:Value := .T.

      IF (oBook := oDesk:LoadComponentFromURL(OO_ConvertToURL( cFile ), "_blank", 0, {oPropVal1, oPropVal2})) == NIL
         MsgStop( 'Error: OpenOffice Calc no está disponible.' )
         BREAK
      ENDIF

      oSheet := oBook:Sheets:GetByIndex(0)
      oBook:getCurrentController:SetActiveSheet(oSheet)

      oCellCursor := oSheet:CreateCursor()

      /*
      oCellCursor:GotoStartOfUsedArea( .F. )
      nFirstRow := oCellCursor:GetRangeAddress():StartRow
      nFirstCol := oCellCursor:GetRangeAddress():StartColumn
      oCellCursor:GotoEndOfUsedArea( .T. )
      nLastRow := oCellCursor:GetRangeAddress():EndRow
      nLastCol := oCellCursor:GetRangeAddress():EndColumn
      */

      oCellCursor:GotoEndOfUsedArea( .T. )
      nRows = oCellCursor:GetRangeAddress:EndRow - 4
      nCols := oCellCursor:GetRangeAddress:EndColumn + 1

      oForm:StatusBar:Item( 1, 'Procesando ' + Ltrim( Str( nRows ) ) + ' filas con ' + Ltrim( Str( nCols ) ) + ' columnas ...' )

      aFields := Array( nCols )
      aFields[ 1 ] := { oSheet:GetCellByPosition( 0, 3 ):GetFormula, "CHARACTER", 3, 0 }
      aFields[ 2 ] := { oSheet:GetCellByPosition( 1, 3 ):GetFormula, "NUMERIC", 2, 0 }
      aFields[ 3 ] := { oSheet:GetCellByPosition( 2, 3 ):GetFormula, "DATE", 8, 0 }
      aFields[ 4 ] := { oSheet:GetCellByPosition( 3, 3 ):GetFormula, "CHARACTER", 20, 0 }
      aFields[ 5 ] := { oSheet:GetCellByPosition( 4, 3 ):GetFormula, "NUMERIC", 6, 2 }

      ERASE (cDbf)

      DBCREATE( cDbf, aFields )

      oForm:StatusBar:Item( 1, cDbf + ' creada ...' )

      USE (cDbf) ALIAS prueba

      nLin := 6
      FOR i := 1 TO nRows
         prueba->( dbappend() )

         REPLACE prueba->codigo     with oSheet:GetCellByPosition( 0, nLin - 1 ):GetFormula
         REPLACE prueba->numero     with oSheet:GetCellByPosition( 1, nLin - 1 ):Value
         REPLACE prueba->fecha      with ( oSheet:GetCellByPosition( 2, nLin - 1 ):GetValue  + d"1899/12/30" )
         REPLACE prueba->referencia with oSheet:GetCellByPosition(3, nLin - 1 ):GetFormula
         REPLACE prueba->monto      with oSheet:GetCellByPosition( 4, nLin - 1 ):Value

         nLin ++
      NEXT

      CLOSE DATABASES
      COMMIT

      oForm:StatusBar:Item( 1, cDbf + ', ' + Ltrim( Str( RecCount() ) ) + ' registros agregados ...' )

      MsgInfo( cDbf + ' fue creada.' )
   RECOVER
      CLOSE DATABASES
      COMMIT

      MsgStop( 'Error de OpenOffice durante la lectura.' )
   END SEQUENCE

   ErrorBlock( bErrBlck1 )

   oSerM := NIL
   oDesk := NIL

   oForm:StatusBar:Item( 1, cBefore )

RETURN NIL

/*
 * EOF
 */
