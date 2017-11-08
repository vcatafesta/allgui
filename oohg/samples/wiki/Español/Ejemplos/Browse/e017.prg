/*
 * Ejemplo Browse n° 17
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo impedir la edición de ciertos
 * registros.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main

   LOCAL oForm

   DEFINE WINDOW Form_1 OBJ oForm ;
      AT 0,0 ;
      WIDTH 640 ;
      HEIGHT 480 ;
      TITLE 'Browse: impedir la edición de ciertos registros' ;
      MAIN ;
      ON INIT AbrirDBF() ;
      ON RELEASE CerrarDBF()

      @ 10,10 BROWSE Browse_1 ;
         WIDTH oForm:ClientWidth - 20 ;
         HEIGHT oForm:ClientHeight - 20 ;
         EDIT INPLACE ;
         HEADERS { "Código", "Nombre"} ;
         WIDTHS { 100, 150 } ;
         WORKAREA Test ;
         FIELDS { "Codigo", "Nombre"} ;
         WHEN { {|| Test->Codigo % 3 == 0 }, {|| Test->Codigo % 3 == 0 } }

      ON KEY ESCAPE ACTION oForm:Release()
   END WINDOW

   oForm:Center()
   oForm:Activate()

RETURN NIL


FUNCTION AbrirDBF()

   LOCAL i

   DBCREATE( "Test", ;
             { {"Codigo", "N", 10, 0}, ;
               {"Nombre", "C", 25, 0} } )

   USE Test NEW
   ZAP

   FOR i := 1 TO 100
      APPEND BLANK
      REPLACE Codigo WITH i
      IF i % 3 == 0
         REPLACE Nombre WITH 'Edición permitida !!!'
      ELSE
         REPLACE Nombre WITH 'Edición no permitida.'
      ENDIF
   NEXT i

   GO TOP

RETURN NIL


FUNCTION CerrarDBF()

  CLOSE DATABASES

  ERASE Test.dbf

RETURN NIL

/*
 * EOF
 */
