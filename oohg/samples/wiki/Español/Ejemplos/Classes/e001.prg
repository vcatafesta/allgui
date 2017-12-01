/*
* Ejemplo Clases n� 1
* Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
* Licenciado bajo The Code Project Open License (CPOL) 1.02
* Ver <http://www.codeproject.com/info/cpol10.aspx>
* Basado en un ejemplo de la distribuci�n de OOHG
* mantenida por Ciro Vargas C. <cvc@oohg.org>
* Este ejemplo muestra c�mo construir una subclase del Grid
* para interceptar y procesar un grupo de teclas.
* Vis�tenos en https://github.com/fyurisich/OOHG_Samples o en
* http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
*/

#include "oohg.ch"
#include "hbclass.ch"
#include "i_windefs.ch"

FUNCTION Main

   SET LANGUAGE TO SPANISH

   PUBLIC aFilas[ 20, 3 ]

   DEFINE WINDOW Form_1 OBJ oForm ;
         AT 0, 0 ;
         WIDTH 500 ;
         HEIGHT 420 ;
         TITLE 'Procesar teclas en un Grid usando una subclase' ;
         MAIN

      aFilas[ 01 ] := {'Simpson',   'Homer',     '555-5555'}
      aFilas[ 02 ] := {'Mulder',    'Fox',       '324-6432'}
      aFilas[ 03 ] := {'Smart',     'Max',       '432-5892'}
      aFilas[ 04 ] := {'Grillo',    'Pepe',      '894-2332'}
      aFilas[ 05 ] := {'Kirk',      'James',     '346-9873'}
      aFilas[ 06 ] := {'Barriga',   'Carlos',    '394-9654'}
      aFilas[ 07 ] := {'Flanders',  'Ned',       '435-3211'}
      aFilas[ 08 ] := {'Smith',     'John',      '123-1234'}
      aFilas[ 09 ] := {'Pedemonti', 'Flavio',    '000-0000'}
      aFilas[ 10 ] := {'Gomez',     'Juan',      '583-4832'}
      aFilas[ 11 ] := {'Fernandez', 'Raul',      '321-4332'}
      aFilas[ 12 ] := {'Borges',    'Javier',    '326-9430'}
      aFilas[ 13 ] := {'Alvarez',   'Alberto',   '543-7898'}
      aFilas[ 14 ] := {'Gonzalez',  'Ambo',      '437-8473'}
      aFilas[ 15 ] := {'Batistuta', 'Gol',       '485-2843'}
      aFilas[ 16 ] := {'Vinazzi',   'Amigo',     '394-5983'}
      aFilas[ 17 ] := {'Pedemonti', 'Flavio',    '534-7984'}
      aFilas[ 18 ] := {'Samarbide', 'Armando',   '854-7873'}
      aFilas[ 19 ] := {'Pradon',    'Alejandra', '???-????'}
      aFilas[ 20 ] := {'Reyes',     'Monica',    '432-5836'}

      @ 10, 10 GRID Grid_2 OBJ oGrid ;
         SUBCLASS MiGrid ;
         WIDTH oForm:ClientWidth - 20 ;
         HEIGHT 230 ;
         HEADERS {'Apellido', 'Nombre', 'Tel�fono'} ;
         WIDTHS {130, 130, 130} ;
         ITEMS aFilas ;
         VALUE 1

      // Deshabilitar b�squeda autom�tica
      oGrid:SearchCol := oGrid:ColumnCount + 1

      ON KEY ESCAPE ACTION Form_1.Release()
   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

   RETURN NIL

CLASS MiGrid FROM TGrid

   METHOD Events_Notify

   ENDCLASS

METHOD Events_Notify( wParam, lParam ) CLASS MiGrid

   LOCAL nNotify := GetNotifyCode( lParam )
   LOCAL nvkey, c, i

   IF nNotify == LVN_KEYDOWN
      // Obtener c�digo de tecla virtual, vea i_keybd.ch
      nvKey := GetGridvKey( lParam )

      IF nvkey >= VK_A .AND. nvkey <= VK_Z
         // Obtener car�cter
         c := Upper( Chr( GetGridvKeyAsChar( lParam ) ) )

         // Buscar la primera fila que contenga el car�cter
         i := ASCAN( aFilas, { |aItem| c $ Upper( aItem[1] ) } )

         IF i > 0
            // Seleccionar el �tem en el grid
            ::Value := i
         ENDIF

         // Evitar la ejecuci�n de la acci�n por defecto

         RETURN 1
      ENDIF
   ENDIF

   // Ejecutar la acci�n por defecto de la clase TGrid

   RETURN ::Super:Events_Notify( wParam, lParam )

   /*
   * EOF
   */
