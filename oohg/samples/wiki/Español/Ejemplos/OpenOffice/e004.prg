/*
* Ejemplo OpenOffice n� 4
* Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
* Licenciado bajo The Code Project Open License (CPOL) 1.02
* Ver <http://www.codeproject.com/info/cpol10.aspx>
* Este ejemplo muestra c�mo copiar y mover hojas de un
* libro de OpenOffice Calc.
* Vis�tenos en https://github.com/fyurisich/OOHG_Samples o en
* http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
*/

#include 'oohg.ch'

FUNCTION Main()

   LOCAL i, aRows[ 15, 5 ], oForm, oGrid

   SET DATE BRITISH
   SET CENTURY ON
   SET NAVIGATION EXTENDED

   DEFINE WINDOW Form_1 OBJ oForm ;
         AT 0,0 ;
         WIDTH 600 ;
         HEIGHT 480 ;
         TITLE "Move y Copiar Hojas en un Libro de OpenOffice Calc" ;
         MAIN

      DEFINE STATUSBAR
         STATUSITEM 'El Poder de OOHG !!!'
      END STATUSBAR

      FOR i := 1 TO 15
         aRows[ i ] := { Str(HB_RandomInt( 99 ), 2), ;
            HB_RandomInt( 100 ), ;
            Date() + Random( HB_RandomInt() ), ;
            'Refer ' + Str( HB_RandomInt( 10 ), 2 ), ;
            HB_RandomInt( 10000 ) }
      NEXT i

      @ 20,20 GRID Grid_1 obj oGrid ;
         WIDTH 520 ;
         HEIGHT 330 ;
         HEADERS { 'CODIGO', 'NUMERO', 'FECHA', 'REFERENCIA', 'MONTO' } ;
         WIDTHS {60, 80, 100, 120, 140} ;
         ITEMS aRows ;
         COLUMNCONTROLS { { 'TEXTBOX', 'CHARACTER', '99' } , ;
         { 'TEXTBOX', 'NUMERIC', '999999' } , ;
         { 'TEXTBOX', 'DATE' }, ;
         { 'TEXTBOX', 'CHARACTER' }, ;
         { 'TEXTBOX', 'NUMERIC', ' 999,999,999.99' } } ;
         FONT 'COURIER NEW' SIZE 10

      @ 370,20 BUTTON btn_Export ;
         CAPTION 'Procesar' ;
         WIDTH 140 ;
         ACTION MiProceso( oGrid )

      ON KEY ESCAPE ACTION Form_1.Release()
   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

   RETURN NIL

FUNCTION MiProceso( oGrid )

   LOCAL cFile, cBefore, oSerM, oDesk, oPropVals, oBook, oSheet1, oSheet2
   LOCAL oSheet3, oCell, uValue, nLin, nRow, nCol, bErrBlck2, x, bErrBlck1

   cFile := HB_DirBase() + "PRUEBA.ODS"

   cBefore := oForm:StatusBar:Item( 1 )
   oForm:StatusBar:Item( 1, 'Creando ' + cFile + ' ...' )

   // abrir el Service Manager
#ifndef __XHARBOUR__
   IF( oSerM := win_oleCreateObject( 'com.sun.star.ServiceManager' ) ) == NIL
   MsgStop( 'Error: OpenOffice no est� disponible. [' + win_oleErrorText()+ ']' )

   RETURN NIL
ENDIF
#else
oSerM := TOleAuto():New( 'com.sun.star.ServiceManager' )
IF Ole2TxtError() != 'S_OK'
   MsgStop( 'Error: OpenOffice no est� disponible.' )

   RETURN NIL
ENDIF
#endif

// capturar todos los errores
bErrBlck1 := ErrorBlock( { | x | break( x ) } )

BEGIN SEQUENCE
   // abrir el Desktop Service
   IF (oDesk := oSerM:CreateInstance("com.sun.star.frame.Desktop")) == NIL
      MsgStop( 'Error: OpenOffice Desktop no est� disponible.' )
      BREAK
   ENDIF

   // definir propiedades para un nuevo libro
   oPropVals := oSerM:Bridge_GetStruct("com.sun.star.beans.PropertyValue")
   oPropVals:Name := "Hidden"
   oPropVals:Value := .T.

   // abrir nuevo libro
   IF (oBook := oDesk:LoadComponentFromURL("private:factory/scalc", "_blank", 0, {oPropVals})) == NIL
      MsgStop( 'Error: OpenOffice Calc no est� disponible.' )
      BREAK
   ENDIF

   // remover todas las hojas excepto la primera
   DO WHILE oBook:Sheets:GetCount() > 1
      oSheet1 := oBook:Sheets:GetByIndex( oBook:Sheets:GetCount() - 1)
      oBook:Sheets:RemoveByName( oSheet1:Name )
   ENDDO

   // definir a la primera hoja como corriente
   oSheet1 := oBook:Sheets:GetByIndex(0)
   oBook:GetCurrentController:SetActiveSheet(oSheet1)

   // cambiar el nombre de la hoja y el nombre y el tama�o de la fuente por defecto
   oSheet1:Name := "Hoja1"
   oSheet1:CharFontName := 'Arial'
   oSheet1:CharHeight := 10

   // asignar el t�tulo
   oCell := oSheet1:GetCellByPosition( 0, 0 )
   oCell:SetString( 'Exportado desde OOHG !!!' )
   oCell:CharWeight := 150

   // exportar los cabezales de columna usando letra negrita
   nLin := 4
   FOR nCol := 1 TO Len( oGrid:aHeaders )
      oCell := oSheet1:GetCellByPosition( nCol - 1, nLin - 1 )
      oCell:SetString( oGrid:aHeaders[ nCol ] )
      oCell:CharWeight := 150
   NEXT
   nLin += 2

   // exportar las filas
   FOR nRow := 1 to oGrid:ItemCount
      FOR nCol := 1 to Len( oGrid:aHeaders )
         oCell := oSheet1:GetCellByPosition( nCol - 1, nLin - 1 )
         uValue := oGrid:Cell( nRow, nCol )
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
   oSheet1:GetColumns():SetPropertyValue( "OptimalWidth", .T. )

   // copiar una hoja a una nueva colocada antes
   oBook:Sheets:CopyByName(oSheet1:Name, "Hoja2", 0)
   oSheet2 := oBook:Sheets:GetByName("Hoja2")
   oBook:GetCurrentController:SetActiveSheet(oSheet2)

   // copy una hoja a una nueva colocada al final
   oBook:Sheets:CopyByName(oSheet1:Name, "Hoja3", 0)
   oBook:Sheets:MoveByName("Hoja3", 2)

   // El orden final de las hojas es: Hoja2, Hoja1, Hoja3

   bErrBlck2 := ErrorBlock( { | x | break( x ) } )

   BEGIN SEQUENCE
      // grabar
      oBook:StoreToURL( OO_ConvertToURL( cFile ), {} )
      oBook:Close( 1 )

      MsgInfo( cFile + ' fue creado.' )
   RECOVER USING x
      // si oBook:StoreToURL() falla, mostrar el error
      MsgStop( x:Description, "Error de OpenOffice" )
      MsgStop( cFile + ' no fue creado !!!' )
   END SEQUENCE

   ErrorBlock( bErrBlck2 )

RECOVER USING x
   MsgStop( x:Description, "Error de OpenOffice " )
END SEQUENCE

ErrorBlock( bErrBlck1 )

// cleanup
oCell   := NIL
oSheet1 := NIL
oSheet2 := NIL
oSheet3 := NIL
oBook   := Nil
oDesk   := Nil
oSerM   := Nil

Form_1.StatusBar.Item( 1 ) := cBefore

RETURN NIL

/*
* EOF
*/
