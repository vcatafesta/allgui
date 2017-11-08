/*
 * Ejemplo Browse n° 8
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo manejar campos no conocidos
 * al crear el control.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main

   LOCAL oForm, ;
         oBrw, ;
         myDbf := "Test1", ;
         myFields := { "Code1", "Name1"}

   DEFINE WINDOW Form_1 OBJ oForm ;
      AT 0,0 ;
      WIDTH 640 ;
      HEIGHT 480 ;
      TITLE 'Browse: manejar campos no conocidos' ;
      MAIN ;
      ON INIT AbrirTablas() ;
      ON RELEASE CerrarTablas()

      @ 10,10 BROWSE Browse_1 OBJ oBrw ;
         WIDTH oForm:ClientWidth - 20 ;
         HEIGHT oForm:ClientHeight - 20 ;
         SYNCHRONIZED ;
         EDIT INPLACE ;
         HEADERS { "Col1", "Col2"} ;
         WIDTHS { 100, 150 } ;
         WORKAREA (myDbf) ;
         FIELDS myFields ;
         VALID { {|| &( "memvar" + myDbf + myFields[1] ) > 0 }, {|| ! empty( &("memvar" + myDbf + myFields[2]) ) } }

     /* Al ejecutarse el valid, la clase crea una variable llamada
      * MemVarBaseCampo, donde Base es el alias del área de trabajo
      * y Campo es el nombre del ídem. Ejemplo: MemVarTest1Code1
      */

      ON KEY ESCAPE ACTION oForm:Release()
   END WINDOW

   oForm:Center()
   oForm:Activate()

RETURN NIL


FUNCTION AbrirTablas()

   LOCAL i

   DBCREATE( "Test1", ;
             { {"Code1", "N", 10, 0}, ;
               {"Name1", "C", 25, 0} } )

   USE Test1 NEW
   ZAP

   FOR i := 1 TO 100
      APPEND BLANK
      REPLACE Code1 WITH i
      REPLACE Name1 WITH 'Artículo '+ STR( i )
   NEXT i

   GO TOP

RETURN NIL


FUNCTION CerrarTablas()

  CLOSE DATABASES

  IF MsgYesNo( "¿ Borrar la tabla ?", "" )
     ERASE Test1.dbf
  ENDIF

RETURN NIL

/*
 * EOF
 */
