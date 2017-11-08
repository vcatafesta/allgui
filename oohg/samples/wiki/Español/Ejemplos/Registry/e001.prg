/*
 * Ejemplo Registro de Windows n° 1
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo guardar la posición y el tamaño
 * de un formulario y cómo restaurarlos cuando el formulario
 * se inicializa.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main

   DEFINE WINDOW FormMain ;
      OBJ oForm ;
      TITLE 'Operaciones sobre el Registro de Windows' ;
      ON INIT CargarReg()

      @ 20, 20 BUTTON btn_Guardar ;
         CAPTION 'Guardar' ;
         ACTION GuardarReg()

      @ 100, 20 BUTTON btn_Borrar ;
         CAPTION 'Borrar' ;
         ACTION BorrarReg()

      ON KEY ESCAPE ACTION ThisWindow.Release
   END WINDOW

   CENTER WINDOW FormMain
   ACTIVATE WINDOW FormMain

RETURN NIL


#define hKey HKEY_CURRENT_USER
#define cKey 'Software\OOHG\EjemploRegistro\FormMain'


FUNCTION CargarReg
   LOCAL col, row, width, height

   IF IsRegistryKey( hKey, cKey )
      col := GetRegistryValue( hKey, cKey, 'col', 'N' )
      IF ! HB_IsNil( col )
         oForm:Col := col
      ENDIF
      row := GetRegistryValue( hKey, cKey, 'row', 'N' )
      IF ! HB_IsNil( row )
         oForm:Row := row
      ENDIF
      width := GetRegistryValue( hKey, cKey, 'width', 'N' )
      IF ! HB_IsNil( width )
         oForm:Width := width
      ENDIF
      height := GetRegistryValue( hKey, cKey, 'height', 'N' )
      IF ! HB_IsNil( height )
         oForm:Height := height
      ENDIF
   ENDIF

RETURN NIL


FUNCTION GuardarReg

   IF ! IsRegistryKey( hKey, cKey )
      IF ! CreateRegistryKey( hKey, cKey )
         RETURN NIL
      ENDIF
   ENDIF

   IF IsRegistryKey( hKey, cKey )
      SetRegistryValue( hKey, cKey, 'col', oForm:Col )
      SetRegistryValue( hKey, cKey, 'row', oForm:Row )
      SetRegistryValue( hKey, cKey, 'width', oForm:Width )
      SetRegistryValue( hKey, cKey, 'height', oForm:Height )
   ENDIF

RETURN NIL


FUNCTION BorrarReg

   DeleteRegistryVar( hKey, cKey, 'col' )
   DeleteRegistryVar( hKey, cKey, 'row' )
   DeleteRegistryVar( hKey, cKey, 'width' )
   DeleteRegistryVar( hKey, cKey, 'height' )
   DeleteRegistryKey( hKey, 'Software\OOHG\EjemploRegistro', 'FormMain' )
   DeleteRegistryKey( hKey, 'Software\OOHG', 'EjemploRegistro' )
   DeleteRegistryKey( hKey, 'Software', 'OOHG' )

RETURN NIL

/*
 * EOF
 */
