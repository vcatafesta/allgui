/*
 * Ejemplo Grid n° 16
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo numerar automáticamente las
 * filas de un Grid a medida que se agregan ítems.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include 'oohg.ch'

FUNCTION Main()

   LOCAL oForm, oGrid

   DEFINE WINDOW Form_1 OBJ oForm ;
      AT 0, 0 ;
      WIDTH 640 ;
      HEIGHT 320 ;
      TITLE 'Autonumerar los ítems de un Grid al agregarlos' ;
      MAIN

      @ 20, 20 GRID Grid_1 OBJ oGrid ;
         WIDTH oForm:ClientWidth - 40 ;
         HEIGHT oForm:ClientHeight - 84 ;
         HEADERS { 'LINEA','CÓDIGO','NOMBRE','VALOR' } ;
         READONLY { .T. , .F. , .F. , .F. } ;
         WIDTHS { 65, 115, 300,100 } ;
         COLUMNCONTROLS { { 'TEXTBOX', 'NUMERIC', '9999' }, ;
                          { 'TEXTBOX', 'CHARACTER' }, ;
                          { 'TEXTBOX', 'CHARACTER' }, ;
                          { 'TEXTBOX', 'NUMERIC', '@E 99,999,999.99'} } ;
         ITEMS {} ;
         APPEND ;
         ON APPEND AlAgregarItem( oGrid ) ;
         DELETE ;
         EDIT INPLACE

      oGrid:Cargo := 0

      @ oForm:ClientHeight - 44, oForm:ClientWidth - 120 BUTTON Button_1 ;
         CAPTION 'Agregar Item' ;
         WIDTH 100 ;
         HEIGHT 24 ;
         ACTION AgregarItem( oGrid )

      ON KEY ESCAPE ACTION Form_1.Release
   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN NIL

FUNCTION AlAgregarItem( oGrid )

   WITH OBJECT oGrid
      IF :Cell( :Value, 1 ) == 0
         :Cell( :Value, 1, ++ :Cargo )
      ENDIF
   END WITH

RETURN NIL

FUNCTION AgregarItem( oGrid )

   WITH OBJECT oGrid
      :SetFocus()
      :AppendItem()
   END WITH

RETURN NIL

/*
 * EOF
 */
