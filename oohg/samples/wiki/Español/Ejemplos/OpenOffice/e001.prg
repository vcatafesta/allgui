/*
 * Ejemplo OpenOffice n° 1
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo crear un libro de OpenOffice 
 * Calc usando datos de un control Grid, sin la intervención
 * del usuario.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include 'oohg.ch'

FUNCTION Main()

   LOCAL i, aRows[ 15, 5 ], oGrid

   SET DATE BRITISH
   SET CENTURY ON
   SET NAVIGATION EXTENDED

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 600 ;
      HEIGHT 480 ;
      TITLE "Exporta los datos de un Grid a un libro de OpenOffice Calc" ;
      MAIN

      DEFINE STATUSBAR
         STATUSITEM 'El poder de OOHG !!!'
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
         HEADERS { 'Código', 'Número', 'Fecha', 'Referencia', 'Cantidad' } ;
         WIDTHS {60, 80, 100, 120, 140} ;
         ITEMS aRows ;
         COLUMNCONTROLS { { 'TEXTBOX', 'CHARACTER', '99' } , ;
                          { 'TEXTBOX', 'NUMERIC', '999999' } , ;
                          { 'TEXTBOX', 'DATE' }, ;
                          { 'TEXTBOX', 'CHARACTER' }, ;
                          { 'TEXTBOX', 'NUMERIC', ' 999,999,999.99' } } ;
         FONT 'COURIER NEW' SIZE 10

      @ 370,20 BUTTON btn_Export ;
         CAPTION 'Exportar a OpenOffice' ;
         WIDTH 140 ;
         ACTION ToOpenOffice( oGrid )

      ON KEY ESCAPE ACTION Form_1.Release()
   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN NIL

FUNCTION ToOpenOffice( oGrid )

   LOCAL cBefore, oSerM, oDesk, oPropVals, oBook, oSheet, oCell, uValue, nLin, nRow, nCol, bErrBlck2, x, bErrBlck1

   cBefore := Form_1.StatusBar.Item( 1 )
   Form_1.StatusBar.Item( 1 ) := 'Creando TEST.ODS en la carpeta del ejecutable ...'

   // abrir el service manager
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
      // abrir el desktop service
      IF (oDesk := oSerM:CreateInstance("com.sun.star.frame.Desktop")) == NIL
         MsgStop( 'Error: el Desktop de OpenOffice no está disponible.' )
         BREAK
      ENDIF

      // definir propiedades para un nuevo libro
      oPropVals := oSerM:Bridge_GetStruct("com.sun.star.beans.PropertyValue")
      oPropVals:Name := "Hidden"
      oPropVals:Value := .T.

      // abrir nuevo libro
      IF (oBook := oDesk:LoadComponentFromURL("private:factory/scalc", "_blank", 0, {oPropVals})) == NIL
         MsgStop( 'Error: OpenOffice Calc no está disponible.' )
         BREAK
      ENDIF

      // definir a la primera hoja como corriente
      oSheet := oBook:Sheets:GetByIndex(0)
      oBook:getCurrentController:SetActiveSheet(oSheet)

      // cambiar el nombre de la hoja y el nombre y el tamaño de la fuente por defecto
      oSheet:Name := "Datos"
      oSheet:CharFontName := 'Arial'
      oSheet:CharHeight := 10

      // asignar el título
      oCell := oSheet:GetCellByPosition( 0, 0 )
      oCell:SetString( 'Exportada desde OOHG !!!' )
      oCell:CharWeight := 150

      // exportar los cabezales de columna usando letra negrita
      nLin := 4
      FOR nCol := 1 TO Len( oGrid:aHeaders )
         oCell := oSheet:GetCellByPosition( nCol - 1, nLin - 1 )
         oCell:SetString( oGrid:aHeaders[ nCol ] )
         oCell:CharWeight := 150
      NEXT
      nLin += 2

      // exportar las filas
      FOR nRow := 1 to oGrid:ItemCount
         FOR nCol := 1 to Len( oGrid:aHeaders )
            oCell := oSheet:GetCellByPosition( nCol - 1, nLin - 1 )
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
      oSheet:GetColumns():SetPropertyValue( "OptimalWidth", .T. )

      bErrBlck2 := ErrorBlock( { | x | break( x ) } )
      BEGIN SEQUENCE
         // guardar
         oBook:StoreToURL( OO_ConvertToURL( HB_DirBase() + 'TEST.ODS' ), {} )
         oBook:Close( 1 )

         MsgInfo( HB_DirBase() + 'TEST.ODS fue creada.' )
      RECOVER USING x
         // si oBook:StoreToURL() falla, mostrar el error
         MsgStop( x:Description, "Error de OpenOffice" )
         MsgStop( HB_DirBase() + 'TEST.ODS no fue creada !!!' )
      END SEQUENCE

      ErrorBlock( bErrBlck2 )
   RECOVER USING x
      MsgStop( x:Description, "Error de OpenOffice" )
   END SEQUENCE

   ErrorBlock( bErrBlck1 )

   // limpieza de referencias a OpenOffice
   oCell  := NIL
   oSheet := NIL
   oBook  := Nil
   oDesk  := Nil
   oSerM  := Nil

   Form_1.StatusBar.Item( 1 ) := cBefore

RETURN NIL

/*
 * EOF
 */
