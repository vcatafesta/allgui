/*
 * Ejemplo Browse n° 16
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo usar la cláusula DEFAULTVALUES
 * para cargar valores por defecto en cada campo de un
 * registro recién agregado.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main

   PUBLIC oBrowse

   SET CENTURY ON
   SET DATE BRITISH
   SET DELETED ON
   SET BROWSESYNC ON

   AbrirTablas()

   DEFINE WINDOW Form_1 OBJ oForm ;
      AT 0, 0 ;
      CLIENTAREA ;
      WIDTH 820 HEIGHT 480 ;
      MINWIDTH 500 MINHEIGHT 380 ;
      TITLE 'Browse con cláusula DEFAULTVALUES' ;
      MAIN ;
      ON INIT oBrowse:SetFocus() ;
      ON RELEASE TareasFinales()

      DEFINE STATUSBAR
        STATUSITEM "Use Alt-A para agregar un registro y vea que sucede"
      END STATUSBAR

      @ oForm:ClientHeight + oForm:Statusbar:ClientHeightUsed - 40, 10 LABEL Label_1 ;
         VALUE "Suma:"

      @ oForm:ClientHeight + oForm:Statusbar:ClientHeightUsed - 40, 70 TEXTBOX Text_1 ;
         OBJ oSuma WIDTH 100 NUMERIC READONLY

      @ 10, 10 BROWSE Browse_1 OBJ oBrowse ;
         WIDTH oForm:ClientWidth - 20 ;
         HEIGHT oForm:ClientHeight + oForm:Statusbar:ClientHeightUsed - 60 ;
         HEADERS { 'Código', ;
                   'Nombre', ;
                   'Apellido', ;
                   'Nacimiento', ;
                   'Marcar', ;
                   'Registro' } ;
         WIDTHS { 150, ;
                  150, ;
                  150, ;
                  150, ;
                  50, ;
                  80 } ;
         WORKAREA test ;
         FIELDS { 'Code', ;
                  'First', ;
                  'Last', ;
                  'Birth', ;
                  'check', ;
                  'recno()' } ;
         COLUMNCONTROLS { {'TEXTBOX', 'NUMERIC', '9999999999'}, ;
                          Nil, ;
                          Nil, ;
                          Nil, ;
                          {'IMAGELIST'}, ;
                          Nil } ;
         READONLY { .F., .F., .F., .F., .F., .T. } ;
         JUSTIFY { BROWSE_JTFY_RIGHT, ;
                   BROWSE_JTFY_LEFT, ;
                   BROWSE_JTFY_LEFT, ;
                   BROWSE_JTFY_RIGHT, ;
                   BROWSE_JTFY_LEFT, ;
                   BROWSE_JTFY_RIGHT } ;
         IMAGE { 'MINIGUI_EDIT_CANCEL', ;
                 'MINIGUI_EDIT_OK' } ;
         APPEND ;
         ENABLEALTA ;
         EDIT INPLACE ;
         ON EDITCELLEND ProcesarEdit() ;
         ON APPEND ProcesarAppend() ;
         ON EDITCELL Totalizar() ;
         DEFAULTVALUES { 10, "Nombre vacío", "Apellido vacío", date(), 1, Nil }

         /*
          * Estos valores son cargados en la fila de edición justo antes
          * del comienzo de la edición. Note que el nuevo registro se agrega
          * después de que finaliza la edición de la primera columna.
          */

      ON KEY ESCAPE ACTION Form_1.Release
   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN Nil

//--------------------------------------------------------------------------//
FUNCTION ProcesarEdit

   /*
    * ON EDITCELLEND es el primer evento que se dispara después del fin de la
    * edición. Se dispara para cada columna editada.
    * Ud. puede acceder a la información de la celda utilizando estas variables:
    * _OOHG_ThisItemRowIndex
    * _OOHG_ThisItemColIndex
    * _OOHG_ThisItemCellRow
    * _OOHG_ThisItemCellCol
    * _OOHG_ThisItemCellWidth
    * _OOHG_ThisItemCellHeight
    * _OOHG_ThisItemCellValue
    * Cualquier cambio en estas variables es ignorado.
    */
    AutoMsgBox( "ProcesarEdit" )

    IF oBrowse:lAppendMode
       /*
        * Para la primera columna editable: el nuevo registro aún no ha sido
        * agregado y el puntero de la base de datos está en el "registro
        * fantasma". En este momento Ud. puede hacer casi cualquier cosa.
        * Tenga cuidado de no desbloquear la base de datos si el control fue
        * definido con la cláusula LOCK.
        * Cualquier cambio en las celdas de la fila de edición será descartado.
        * Estos valores no son cargados en la fila de edición ni en el registro.
        */
       oBrowse:Cell( _OOHG_ThisItemRowIndex, _OOHG_ThisItemColIndex, 99 )
       oBrowse:Cell( _OOHG_ThisItemRowIndex, 3, "xxxxxxxxx" )
    ELSE
       /*
        * Para las restantes columnas editables: el nuevo registro ha sido
        * agregado y es el registro corriente en la base de datos. El valor
        * editado aún no ha sido guardado en el registro.
        * En este momento Ud. puede hacer casi cualquier cosa, incluso cambiar
        * el valor de cualquier campo dentro del registro.
        * Tenga cuidado de no desbloquear la base de datos si el control fue
        * definido con la cláusula LOCK.
        * Note que cualquier cambio que se haga en el puntero de la base de
        * datos será respetado y no se restaurará el registro original antes
        * de grabar.
        * Cualquier cambio en las celdas de la fila de edición será descartado.
        */
       IF _OOHG_ThisItemColIndex == 2
          // Este valor no es cargado en la fila de edición ni en el registro.
          oBrowse:Cell( _OOHG_ThisItemRowIndex, 3, "yyyyyyyyy" )
       ELSEIF _OOHG_ThisItemColIndex == 4
          // Esto si funciona
          Test->Last := "NEW DATA"
       ENDIF
    ENDIF

RETURN Nil

//--------------------------------------------------------------------------//
FUNCTION ProcesarAppend

   /*
    * Después que finaliza el evento ON EDITCELLEND para la primera columna
    * editable, el nuevo registro es agregado y el valor recién editado
    * así como los restantes valores por defecto son grabados en él.
    *
    * A continuación se dispara el evento ON APPEND.
    *
    * En este momento Ud. puede grabar cualquier valor en el registro.
    */
    AutoMsgBox( "ProcesarAppend" )
    Test->Birth := ctod("01/01/1901")

RETURN Nil

//--------------------------------------------------------------------------//
FUNCTION Totalizar
   LOCAL nRec, nSuma

    AutoMsgBox( "Totalizar" )
   /*
    * El evento ON EDITCELL se dispara luego que el valor recién editado es
    * grabado en el registro. Se dispara para cada columna editada.
    * Ud. puede acceder a la información de la celda utilizando estas variables:
    * _OOHG_ThisItemRowIndex
    * _OOHG_ThisItemColIndex
    * _OOHG_ThisItemCellRow
    * _OOHG_ThisItemCellCol
    * _OOHG_ThisItemCellWidth
    * _OOHG_ThisItemCellHeight
    * _OOHG_ThisItemCellValue
    * Cualquier cambio en estas variables es ignorado.
    */
   nRec := Test->(RecNo())
   nSuma := 0
   Test->( DBEVAL( {|| nSuma += Test->Code } ) )
   Test->( dbGoTo( nRec ) )
   oSuma:Value := nSuma
RETURN Nil

//--------------------------------------------------------------------------//
FUNCTION TareasFinales()

   dbCloseAll()
   ERASE test.dbf

RETURN Nil

//--------------------------------------------------------------------------//
FUNCTION AbrirTablas()

   DBCREATE( "Test", { { "Code",    "Numeric",   10, 0 }, ;
                       { "First",   "Character", 25, 0 }, ;
                       { "Last",    "Character", 25, 0 }, ;
                       { "Married", "Logical",    1, 0 }, ;
                       { "Birth",   "Date",       8, 0 }, ;
                       { "Check",   "Numeric",    1, 0 } } )

   USE test

   FOR i := 1 TO 5
      APPEND BLANK
      REPLACE Code    WITH HB_RandomInt(99) * 10000
      REPLACE First   WITH 'Nombre '+ STR(i)
      REPLACE Last    WITH 'Apellido '+ STR(i)
      REPLACE Married WITH .t.
      REPLACE Birth   WITH Date() + i - 10000
      REPLACE Check   WITH i % 2
   NEXT i

   GO TOP

RETURN Nil

/*
 * EOF
 */
