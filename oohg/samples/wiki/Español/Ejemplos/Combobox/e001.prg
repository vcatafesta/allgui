/*
 * Ejemplo Combobox n° 1
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo utilizar las cláusulas
 * ITEMSOURCE, ITEMIMAGENUMBER e IMAGESOURCE para cargar
 * ítems e imágenes en un combobox usando información
 * de una base de datos. También muestra cómo cambiar
 * las imágenes luego de la creación del control.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 *
 * Las imágenes utilizadas en este ejemplo pueden descargarse desde:
 * https://github.com/fyurisich/OOHG_Samples/tree/master/Español/Ejemplos/Combobox
 */

#include "oohg.ch"
#include "dbstruct.ch"

FUNCTION Main()

   LOCAL oCmb_1

   CrearDBF()

   DEFINE WINDOW Form1 ;
      AT 0,0 ;
      WIDTH 428 ;
      HEIGHT 300 ;
      TITLE "COMBOBOX con Imágenes" ;
      MAIN

      @ 20,20 COMBOBOX cmb_1 ;
         OBJ oCmb_1 ;
         HEIGHT 200 ;
         WIDTH 185 ;
         ITEMSOURCE "test->item" ;
         ITEMIMAGENUMBER {|| test->(RECNO()) - 1} ;
         IMAGESOURCE {|| test->image} ;
         FIT ;
         TEXTHEIGHT 40 ;
         VALUE 1

      @ 20,300 BUTTON btn_1 ;
         CAPTION "Cambiar Imágenes" ;
         WIDTH 100 ;
         HEIGHT 28 ;
         ACTION {|| oCmb_1:ImageSource := {|| test->image2}, ;
                    oCmb_1:Refresh() }

      ON KEY ESCAPE ACTION ThisWindow.Release()
   END WINDOW

   CENTER WINDOW Form1
   ACTIVATE WINDOW Form1

   DBCLOSEALL()

RETURN NIL

FUNCTION CrearDBF()

   LOCAL aDbf[3][4]

   aDbf[1][ DBS_NAME ] := "Item"
   aDbf[1][ DBS_TYPE ] := "Character"
   aDbf[1][ DBS_LEN ]  := 20
   aDbf[1][ DBS_DEC ]  := 0

   aDbf[2][ DBS_NAME ] := "Image"
   aDbf[2][ DBS_TYPE ] := "Character"
   aDbf[2][ DBS_LEN ]  := 12
   aDbf[2][ DBS_DEC ]  := 0

   aDbf[3][ DBS_NAME ] := "Image2"
   aDbf[3][ DBS_TYPE ] := "Character"
   aDbf[3][ DBS_LEN ]  := 12
   aDbf[3][ DBS_DEC ]  := 0

	REQUEST DBFCDX

   DBCREATE("Test", aDbf, "DBFCDX")

	USE test Via "DBFCDX"
	ZAP

	APPEND BLANK
	REPLACE Item   WITH "Item 1"
	REPLACE Image  WITH "globe.bmp"
	REPLACE Image2 WITH "albaran.bmp"

	APPEND BLANK
	REPLACE Item   WITH "Item 2"
	REPLACE Image  WITH "albaran.bmp"
	REPLACE Image2 WITH "info.bmp"

	APPEND BLANK
	REPLACE Item   WITH "Item 3"
	REPLACE Image  WITH "info.bmp"
	REPLACE Image2 WITH "globe.bmp"

RETURN NIL

/*
 * EOF
 */
