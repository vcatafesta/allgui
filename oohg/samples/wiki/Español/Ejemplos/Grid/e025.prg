/*
 * Ejemplo Grid n° 25
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo asignar valores por defecto a
 * las celdas de un nuevo item utilizando el evento ON INSERT.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main
   LOCAL aRows[ 10, 3 ]

   SET DATE BRITISH
   SET EPOCH TO 1960

   DEFINE WINDOW Form_1 OBJ oForm ;
      AT 0, 0 ;
      WIDTH 640 ;
      HEIGHT 540 ;
      TITLE 'Valores por defecto en control Grid' ;
      MAIN ;
      ON SIZE oGrid:Width := oForm:ClientWidth - 20

      DEFINE STATUSBAR
         STATUSITEM "Use Alt-A para agregar un nuevo item y vea que pasa"
      END STATUSBAR

      aRows[ 01 ] := { 'Simpson',   'Homer',  '555-5555', '14/03/61', '125' }
      aRows[ 02 ] := { 'Mulder',    'Fox',    '324-6432', '14/12/65', '125' }
      aRows[ 03 ] := { 'Smart',     'Max',    '432-5892', '14/11/60', '125' }
      aRows[ 04 ] := { 'Grillo',    'Pepe',   '894-2332', '14/03/64', '125' }
      aRows[ 05 ] := { 'Kirk',      'James',  '346-9873', '14/10/67', '125' }
      aRows[ 06 ] := { 'Barriga',   'Carlos', '394-9654', '14/06/69', '125' }
      aRows[ 07 ] := { 'Flanders',  'Ned',    '435-3211', '14/05/63', '125' }
      aRows[ 08 ] := { 'Smith',     'John',   '123-1234', '14/02/68', '125' }
      aRows[ 09 ] := { 'Pedemonti', 'Flavio', '000-0000', '14/07/66', '125' }
      aRows[ 10 ] := { 'Gomez',     'Juan',   '583-4832', '14/09/63', '125' }

      @ 10,10 GRID Grid_1 OBJ oGrid;
         WIDTH oForm:ClientWidth - 20 ;
         HEIGHT 330 ;
         HEADERS { 'Apellido', 'Nombre', 'Teléfono', 'Fecha', 'Datos' } ;
         WIDTHS { 140, 140, 140, 100, 60 } ;
         ITEMS aRows ;
         VALUE 3 ;
         APPEND ;
         EDIT INPLACE;
         FULLMOVE ;
         DELETE ;
         ENABLEALTA ;
         ON INSERT { |nItem| ValoresPorDefecto( nItem ) }

      ON KEY ESCAPE ACTION Form_1.Release()
   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN

FUNCTION ValoresPorDefecto( nItem )

   oGrid:Item( nItem, ;
               {"Smith", "John", "234-4567", "14/03/61", "250"}, ;
               {WHITE, WHITE, WHITE, WHITE, WHITE}, ;
               {BLUE, BLUE, BLUE, BLUE, BLUE} )

RETURN NIL

/*
 * EOF
 */
