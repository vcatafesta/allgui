/*
 * Ejemplo Excel n° 2
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo abrir un libro Excel en modo
 * "solo lectura".
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include 'oohg.ch'

FUNCTION Main()

   LOCAL i, aRows[ 15, 5 ]

   SET DATE BRITISH
   SET CENTURY ON
   SET NAVIGATION EXTENDED

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 600 ;
      HEIGHT 480 ;
      TITLE 'Abrir Excel en modo lectura' ;
      MAIN

      DEFINE STATUSBAR
         STATUSITEM 'El Poder de OOHG !!!'
      END STATUSBAR

      @ 370,20 BUTTON btn_Abrir ;
         CAPTION 'Abrir Excel' ;
         WIDTH 140 ;
         ACTION Abrir()

      ON KEY ESCAPE ACTION Form_1.Release()
   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN NIL

FUNCTION Abrir

   LOCAL w_arch, oExcel

   IF Empty(w_arch := GetFile({ {'*.xls','*.xls'} }, 'Abrir Excel', 'C:\', .f., .f.))
      RETURN NIL
   ENDIF

   #ifndef __XHARBOUR__
      IF( oExcel := win_oleCreateObject( 'Excel.Application' ) ) == NIL
         MsgStop( 'Error: Excel no está disponible. [' + win_oleErrorText()+ ']' )
         RETURN NIL
      ENDIF
   #else
      oExcel := TOleAuto():New( 'Excel.Application' )
      IF Ole2TxtError() != 'S_OK'
         MsgStop( 'Error: Excel no está disponible.' )
         RETURN NIL
      ENDIF
   #endif

   oExcel:WorkBooks:Open(w_arch, NIL, .T.)
   oExcel:Visible := .t.

RETURN NIL

/*
 * EOF
 */
