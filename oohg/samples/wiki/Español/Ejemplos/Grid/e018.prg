/*
 * Ejemplo Grid n° 18
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo cambiar la fuente de los
 * títulos de un control Grid, Browse o XBrowse.
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
      TITLE 'Cambiar la fuente de los títulos' ;
      MAIN ;
      ON INIT ( oGrid:SetFocus(), oGrid:AppendItem() )

      @ 20, 20 GRID Grid_1 OBJ oGrid ;
         WIDTH oForm:ClientWidth - 40 ;
         HEIGHT oForm:ClientHeight - 84 ;
         HEADERS { 'Línea', 'Código', 'Nombre', 'Valor' } ;
         ITEMS {} ;
         WIDTHS { 65, 115, 300,100 } ;
         COLUMNCONTROLS { { 'TEXTBOX', 'NUMERIC', '9999' }, ;
                          { 'TEXTBOX', 'CHARACTER' }, ;
                          { 'TEXTBOX', 'CHARACTER' }, ;
                          { 'TEXTBOX', 'NUMERIC', '@E 99,999,999.99'} } ;
         APPEND ;
         DELETE ;
         EDIT INPLACE ;
         FULLMOVE ;
         NAVIGATEBYCELL

/*
      HeaderSetFont( cFontName, nFontSize, lBold, lItalic, lUnderline, lStrikeout, lFontAngle, lFontwidth )
*/
      oGrid:HeaderSetFont( "VERDANA", 14, .T., .T. )

      @ oForm:ClientHeight - 44, oForm:ClientWidth - 120 BUTTON Button_1 ;
         CAPTION "Editar Una Celda" ;
         WIDTH 100 ;
         HEIGHT 24 ;
         ACTION ( oGrid:SetFocus(), oGrid:EditCell() )

      ON KEY ESCAPE ACTION oForm:Release()
      ON KEY F2 ACTION oGrid:EditCell()
   END WINDOW

   oForm:Center()
   oForm:Activate()

RETURN NIL

/*
 * EOF
 */
