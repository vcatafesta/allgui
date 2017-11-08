/*
 * Ejemplo Impresión n° 1
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo enumerar los tamaños de papel
 * disponibles en un driver de impresora.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 500 ;
      HEIGHT 300 ;
      TITLE 'Tamaños de Papel de una Impresora' ;
      MAIN

      DEFINE STATUSBAR
         STATUSITEM "Haga clic en el botón y seleccione una impresora."
      END STATUSBAR

      @ 20, 20 BUTTON But_1 ;
         CAPTION "Mostrar Datos" ;
         ACTION MostrarDatos()

      ON KEY ESCAPE ACTION Form_1.Release()
   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN NIL

FUNCTION MostrarDatos()
   LOCAL oPrint

   oPrint := TPrint( "HBPRINTER" )
   oPrint:Init()
   oPrint:SelPrinter()
   IF ! oPrint:LPrError
      AutoMsgBox( oPrint:oHBPrn:PaperNames, "Tamaños de Papel Disponibles" )
   ENDIF

   oPrint:Release()

RETURN NIL

/*
 * EOF
 */
