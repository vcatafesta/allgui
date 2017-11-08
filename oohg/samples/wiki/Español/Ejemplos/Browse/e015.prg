/*
 * Ejemplo Browse n° 15
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo definir valores por defecto
 * para registros recién agregados, también muestra como
 * mostrar columnas computadas de solo lectura mientras
 * la ocurre la edición de una fila.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

REQUEST DBFCDX, DBFFPT

FUNCTION Main

   LOCAL oForm, oBrowse

   SET CENTURY ON
   SET DELETED ON
   SET BROWSESYNC ON

   DEFINE WINDOW Form_1 OBJ oForm ;
      AT 0,0 ;
      CLIENTAREA ;
      WIDTH 500 HEIGHT 380 ;
      MINWIDTH 500 MINHEIGHT 380 ;
      TITLE "Browse: valores por defecto en registros recién agregados" ;
      MAIN;
      ON INIT AbrirTablas( oBrowse ) ;
      ON RELEASE TareasFinales()

      @ 05,10 LABEL Label_1 OBJ oLbl ;
         VALUE "Use Alt-A para agregar un record y vea que sucede" ;
         AUTOSIZE

      @ 30,10 BROWSE Browse_1 OBJ oBrowse ;
         WIDTH oForm:ClientWidth - 20 ;
         HEIGHT oForm:ClientHeight - 40 ;
         ONHEADCLICK { { || ordSetFocus( "recno" ), oBrowse:Refresh() }, ;
                       { || ordSetFocus( "code" ), oBrowse:Refresh() }, ;
                       NIL, ;
                       NIL, ;
                       NIL, ;
                       NIL, ;
                       NIL } ;
         EDIT INPLACE ;
         APPEND ;
         DELETE ;
         HEADERS { 'Reg.', ;
                   'Código', ;
                   'Nombre', ;
                   'Apellido', ;
                   'Nacimiento', ;
                   'Casado', ;
                   'Biografía' } ;
         WIDTHS { 60, 150, 150, 150, 150, 150, 150 } ;
         WORKAREA Test ;
         FIELDS { { || Test->(RECNO()) }, ;
                  'Test->Code', ;
                  'Test->First', ;
                  'Test->Last', ;
                  'Test->Birth', ;
                  'Test->Married', ;
                  'Test->Bio' } ;
         COLUMNCONTROLS { NIL, ;
                          {'COMBOBOX',{'1','2','3'},{1,2,3},"NUMERIC"}, ;
                          NIL, ;
                          NIL, ;
                          NIL, ;
                          NIL, ;
                          {'MEMO', "Biografía", , 600, 600, .T., .T. } } ;
         READONLY { { || LlenarNroRegistro( oBrowse ) }, ;
                    .F., ;
                    .F., ;
                    .F., ;
                    .F., ;
                    .F., ;
                    .F. } ;
         FONT "Courier New" SIZE 10 ;
         JUSTIFY { BROWSE_JTFY_RIGHT, ;
                   BROWSE_JTFY_RIGHT, ;
                   BROWSE_JTFY_CENTER, ;
                   BROWSE_JTFY_CENTER, ;
                   BROWSE_JTFY_CENTER, ;
                   BROWSE_JTFY_CENTER, ;
                   BROWSE_JTFY_CENTER }

      ON KEY ESCAPE ACTION oForm:Release()
   END WINDOW

   oForm:Center()
   oForm:Activate()

RETURN NIL

//--------------------------------------------------------------------------//
FUNCTION LlenarNroRegistro( oBrw )

   // Cargar la celda del Grid con el numero del registro aún no agregado
   // Esto funciona por que la DBF está en EOF mientras se procesa Alt-A
   oBrw:Cell( oBrw:ItemCount, 1, Test->(RECNO()) )

   // Fuerza el repintado inmediato de la celda de edición
   oBrw:RefreshRow( oBrw:ItemCount )

   // Evitar la edición de la celda
RETURN .T.

//--------------------------------------------------------------------------//
FUNCTION AbrirTablas( oBrw )

   LOCAL i

   DBCREATE( "Test", ;
             { { "Code",    "Numeric",   10, 0 }, ;
               { "First",   "Character", 25, 0 }, ;
               { "Last",    "Character", 25, 0 }, ;
               { "Married", "Logical",    1, 0 }, ;
               { "Birth",   "Date",       8, 0 }, ;
               { "Bio",     "Memo",      10, 0 } }, ;
             "DBFCDX" )

   USE test VIA "DBFCDX"
   ZAP

   FOR i := 1 TO 100
      APPEND BLANK
      REPLACE Code    WITH ( i % 3 ) + 1
      REPLACE First   WITH 'First Name '+ STR( i )
      REPLACE Last    WITH 'Last Name '+ STR( i )
      REPLACE Married WITH .t.
      REPLACE Birth   WITH DATE() + i - 10000
   NEXT i

   INDEX ON code TAG code TO code
   INDEX ON RECNO() TAG recno TO code

   GO BOTTOM
	oBrw:SetValue( RECNO(), oBrw:CountPerPage )

RETURN Nil

//--------------------------------------------------------------------------//
FUNCTION TareasFinales()

  dbCloseAll()

  ERASE Test.dbf
  ERASE Test.fpt
  ERASE Code.cdx

RETURN NIL

/*
 * EOF
 */
