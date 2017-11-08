/*
 * Ejemplo Browse n° 9
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Basado en un ejemplo de la distribución de OOHG mantenida
 * por Ciro Vargas Clemow <cvc@oohg.org>
 *
 * Este ejemplo muestra cómo pintar con colores alternados
 * las filas de un control Browse indexado.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"
#include "dbstruct.ch"

FUNCTION Main

   LOCAL Form_1, Browse_1

   REQUEST DBFCDX, DBFFPT

   SET CENTURY ON
   SET DELETED ON
   SET BROWSESYNC ON
   SET LANGUAGE TO SPANISH

   DEFINE WINDOW Form_1 OBJ oForm ;
      AT 0,0 ;
      CLIENTAREA ;
      WIDTH 500 HEIGHT 380 ;
      MINWIDTH 500 MINHEIGHT 380 ;
      TITLE 'Pintar en forma alternada un Browse "Indexado"' ;
      MAIN ;
      NOMAXIMIZE ;
      ON INIT AbrirTablas() ;
      ON RELEASE dbCloseAll()

      @ 10,10 BROWSE Browse_1 OBJ oBrowse ;
         WIDTH oForm:ClientWidth - 20 ;
         HEIGHT oForm:ClientHeight - 20 ;
         HEADERS { 'Código', 'N° de Reg.' } ;
         WIDTHS { 150, 150 } ;
         WORKAREA test ;
         FIELDS { 'Test->Code', 'Test->Recno' } ;
         FONT "Courier New" SIZE 10 ;
         JUSTIFY { BROWSE_JTFY_RIGHT, BROWSE_JTFY_RIGHT } ;
         DELETE ;
         LOCK ;
         EDIT INPLACE FULLMOVE ;
         APPEND ;
         FORCEREFRESH ;
         DYNAMICBACKCOLOR {|| IF( ORDKEYNO() % 2 == 0, WHITE, ORANGE ) }

      oBrowse:ColumnWidth(2, oBrowse:ClientWidth() - oBrowse:ColumnWidth(1) )

      ON KEY ESCAPE ACTION Form_1.Release
   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN NIL

//--------------------------------------------------------------------------//
FUNCTION AbrirTablas()

   LOCAL aDbf[2][4]

   aDbf[1][ DBS_NAME ] := "Code"
   aDbf[1][ DBS_TYPE ] := "Numeric"
   aDbf[1][ DBS_LEN ]  := 10
   aDbf[1][ DBS_DEC ]  := 0

   aDbf[2][ DBS_NAME ] := "Recno"
   aDbf[2][ DBS_TYPE ] := "Numeric"
   aDbf[2][ DBS_LEN ]  := 10
   aDbf[2][ DBS_DEC ]  := 0

   DBCREATE("Test", aDbf, "DBFCDX")

   USE test VIA "DBFCDX"
   ZAP

   FOR i:= 1 TO 100
      APPEND BLANK
      REPLACE Code  WITH HB_RandomInt( 1000 )
      REPLACE Recno WITH RECNO()
   NEXT i

   INDEX ON code TO code

   GO TOP

   Form_1.Browse_1.Value := RECNO()

RETURN NIL

/*
 * EOF
 */
