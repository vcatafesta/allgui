/*
 * Ejemplo Excel nÝ 4
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Basado en un ejemplo de la distribución de OOHG creada
 * por Ciro Vargas C. <cvc@oohg.org>
 * Partes del código en la función ToExcel están
 * licenciadas bajo la licencia de OOHG.
 *
 * Este ejemplo muestra cómo crear un libro Excel, sin
 * interacción del usuario, utlizando datos de un control Grid.
 * También muestra cómo copiar y mover hojas dentro de un libro.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include 'oohg.ch'

FUNCTION Main()

   LOCAL i, aRows[ 15, 5 ]

   SET DATE BRITISH
   SET CENTURY ON
   SET NAVIGATION EXTENDED

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 600 ;
      HEIGHT 480 ;
      TITLE 'Exportar Datos de un Grid a un Libro Excel' ;
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
         HEADERS { 'CÓDIGO', 'NUMERO', 'FECHA', 'REFERENCIA', 'IMPORTE' } ;
         WIDTHS { 60, 80, 100, 120, 140 } ;
         ITEMS aRows ;
         COLUMNCONTROLS { { 'TEXTBOX', 'CHARACTER', '99' } , ;
                          { 'TEXTBOX', 'NUMERIC', '999999' } , ;
                          { 'TEXTBOX', 'DATE' }, ;
                          { 'TEXTBOX', 'CHARACTER' }, ;
                          { 'TEXTBOX', 'NUMERIC', ' 999,999,999.99' } } ;
         FONT 'COURIER NEW' SIZE 10

      @ 370,20 BUTTON btn_Export ;
         CAPTION 'Exportar a Excel' ;
         WIDTH 140 ;
         ACTION ToExcel( oGrid )

      ON KEY ESCAPE ACTION Form_1.Release()
   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN NIL

FUNCTION ToExcel( oGrid )

   LOCAL cBefore, oExcel, oSheet1, oSheet2, oSheet3, nLin, nRow, nCol

   cBefore := Form_1.StatusBar.Item( 1 )
   Form_1.StatusBar.Item( 1 ) := 'Creando PRUEBA.XLS en la carpeta base ...'

#ifndef __XHARBOUR__
   IF( oExcel := win_oleCreateObject( 'Excel.Application' ) ) == NIL
      MsgStop( 'Error: Excel no está disponible [' + win_oleErrorText()+ ']' )
      RETURN NIL
   ENDIF
#else
   oExcel := TOleAuto():New( 'Excel.Application' )
   IF Ole2TxtError() != 'S_OK'
      MsgStop( 'Error: Excel no está disponible.' )
      RETURN NIL
   ENDIF
#endif

   // Crear nuevo libro

   oExcel:WorkBooks:Add()
   oSheet1 := oExcel:ActiveSheet()
   oSheet1:Name := "Sheet1"

   // Ingresar algunos datos y darles formato

   oSheet1:Cells:Font:Name := 'Arial'
   oSheet1:Cells:Font:Size := 10

   oSheet1:Cells( 1, 1 ):Value := Upper( 'Exported from OOHG !!!' )
   oSheet1:Cells( 1, 1 ):Font:Bold := .T.

   nLin := 4
   FOR nCol := 1 TO Len( oGrid:aHeaders )
      oSheet1:Cells( nLin, nCol ):Value := Upper( oGrid:aHeaders[ nCol ] )
      oSheet1:Cells( nLin, nCol ):Font:Bold := .T.
   NEXT
   nLin += 2

   FOR nRow := 1 to oGrid:ItemCount
      FOR nCol := 1 to Len( oGrid:aHeaders )
         oSheet1:Cells( nLin, nCol ):Value := oGrid:Cell( nRow, nCol )
      NEXT
      nLin ++
   NEXT

   FOR nCol := 1 TO Len( oGrid:aHeaders )
      oSheet1:Columns( nCol ):AutoFit()
   NEXT

   // Copiar antes

   oSheet1:Copy( oSheet1 )
   oSheet2 := oExcel:ActiveSheet()
   oSheet2:Name := "Sheet2"

   // Copiar después

   oSheet1:Copy( oSheet1 )
   oSheet3 := oExcel:ActiveSheet()
   oSheet3:Name := "Sheet3"
   oSheet1:Move( oSheet3 )

   // Orden final: Sheet2, Sheet1, Sheet3

   // Guardar

   ERASE TEST.XLS

   oSheet1:SaveAs( HB_DirBase() + 'PRUEBA.XLS' )
   oExcel:WorkBooks:Close()
   oExcel:Quit()

   oSheet1 := NIL
   oExcel := NIL

   MsgInfo( HB_DirBase() + 'PRUEBA.XLS fue creado' + HB_OsNewLine() + ;
            'y EXCEL.EXE fue descargado de la memoria.' )

   Form_1.StatusBar.Item( 1 ) := cBefore

RETURN NIL

/*
 * EOF
 */
