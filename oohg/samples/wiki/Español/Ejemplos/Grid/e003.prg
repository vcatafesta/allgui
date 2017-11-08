/*
 * Ejemplo Grid n° 03
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Basado en un ejemplo de la distribución de OOHG creada por
 * Ciro Vargas C. <cvc@oohg.org>
 *
 * Este ejemplo muestra cómo cancelar la edición en un control
 * Grid con la cláusula InPlace utilizando un timer. Se basa
 * en el hecho de que la edición es realizada en una ventana
 * modal llamada _OOHG_GRIDWN.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include 'oohg.ch'

FUNCTION Main()

   LOCAL k, aRows[ 15, 5 ]

   SET DATE BRITISH
   SET CENTURY ON

   DEFINE WINDOW Form_1 OBJ oForm ;
      AT 0, 0 ;
      WIDTH 600 ;
      HEIGHT 500 ;
      TITLE 'GRID - Cancelar la Edición Utilizando un Timer' ;
      MAIN

      DEFINE STATUSBAR
         STATUSITEM 'El Poder de OOHG !!!'
      END STATUSBAR

      FOR k := 1 TO 15
          aRows[ k ] := { Str(HB_RandomInt( 99 ), 2), ;
                          HB_RandomInt( 100 ), ;
                          Date() + Random( HB_RandomInt() ), ;
                          'Refer ' + Str( HB_RandomInt( 10 ), 2 ), ;
                          HB_RandomInt( 10000 ) }
      NEXT k

      @ 20, 20 GRID Grid_1 obj oGrid ;
         WIDTH 520 ;
         HEIGHT 330 ;
         HEADERS { 'CÓDIGO', 'NÚMERO', 'FECHA', 'REFERENCIA', 'IMPORTE' } ;
         WIDTHS { 60, 80, 100, 120, 140 } ;
         ITEMS aRows ;
         COLUMNCONTROLS { { 'TEXTBOX', 'CHARACTER', '99' } , ;
                          { 'TEXTBOX', 'NUMERIC', '999999' } , ;
                          { 'TEXTBOX', 'DATE' }, ;
                          { 'TEXTBOX', 'CHARACTER' }, ;
                          { 'TEXTBOX', 'NUMERIC', ' 999,999,999.99' } } ;
         FONT 'COURIER NEW' SIZE 10 ;
         EDIT INPLACE ;
         VALUE 4

      DEFINE TIMER Timer1 INTERVAL 3000 ACTION CheckIdleTime()

      ON KEY ESCAPE ACTION Form_1.Release()
   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN NIL

FUNCTION CheckIdleTime

   LOCAL obj, ctr
   STATIC IdleTime := 0

   ctr := GetControlObjectByHandle( GetFocus() )
   obj := ctr:Parent

   IF obj:Name == "_OOHG_GRIDWN"
      IF EMPTY( ctr:Value ) .OR. ctr:Value == _OOHG_ThisItemCellValue
         IdleTime += 3000
         IF IdleTime > 6000
            IdleTime := 0
            obj:Release()
         ENDIF
      ELSE
         IdleTime := 0
      ENDIF
   ELSE
      IdleTime := 0
   ENDIF

RETURN NIL

/*
 * EOF
 */
