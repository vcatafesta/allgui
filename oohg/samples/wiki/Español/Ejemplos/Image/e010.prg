/*
 * Ejemplo Image n° 10
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo utilizar un control IMAGE para
 * imprimir una imagen cargada desde el archivo de recursos.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 *
 * Los archivos oohg.jpg y s010.rc pueden descargarse desde:
 * https://github.com/fyurisich/OOHG_Samples/tree/master/Español/Ejemplos/Image
 */

#include "oohg.ch"

FUNCTION Main

   DEFINE WINDOW Form_1 ;
      OBJ oForm ;
      AT 0,0 ;
      WIDTH 640 ;
      HEIGHT 480 ;
      CLIENTAREA ;
      TITLE 'Imprimir una imagen desde el archivo RC' ;
      MAIN

      @ 20,20 IMAGE Image_1 ;
         OBJ oImage ;
         IMAGESIZE ;
         PICTURE "OOHG"

      @ 200, 100 BUTTON button_1 ;
         WIDTH 150 ;
         CAPTION "Imprimir HBPRINTER" ;
         ACTION PrintImage( "HBPRINTER" )

      @ 200, 260 BUTTON button_2 ;
         WIDTH 150 ;
         CAPTION "Imprimir MINIPRINT" ;
         ACTION PrintImage( "MINIPRINT" )

      ON KEY ESCAPE ACTION Form_1.Release()
   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN NIL


PROCEDURE PrintImage( cTLibrary )

   LOCAL oPrint := TPrint( cTLibrary )

   oPrint:Init()

   oPrint:SelPrinter( .T., .T., .t. )
   IF oPrint:lPrError
      oPrint:Release()
      RETURN
   ENDIF

   oImage:SaveAs( "s010.jpg", .F., "JPG", 100, 24 )

   oPrint:BeginDoc( "Ejemplo" )
   oPrint:BeginPage()
   oPrint:PrintImage( 21, 10, 30, 30, "s010.jpg", 100 )
   oPrint:EndPage()
   oPrint:EndDoc()

   oPrint:Release()

   ERASE s010.jpg

RETURN

/*
 * EOF
 */
