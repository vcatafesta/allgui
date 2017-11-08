/*
 * Ejemplo Image n° 9
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo cambiar el tamaño de una imagen
 * usando un control IMAGE y el método SaveAs.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main

   LOCAL nImg := 1

   DEFINE WINDOW Form_1 ;
      OBJ oForm ;
      AT 0,0 ;
      WIDTH 640 ;
      HEIGHT 480 ;
      CLIENTAREA ;
      TITLE 'Cambiar el tamaño de una imagen' ;
      MAIN

      DEFINE MAIN MENU
         POPUP 'File'
            ITEM 'Seleccionar Imagen' ;
               ACTION Form_1.Image_1.Picture := ;
                      Getfile ( { {'Archivos bmp','*.bmp'}, ;
                                  {'Archivos gif','*.gif'}, ;
                                  {'Archivos jpg','*.jpg, *.jpeg'}, ;
                                  {'Archivos ico','*.ico'}, ;
                                  {'Archivos tiff','*.tif, *.tiff'}, ;
                                  {'Archivos png','*.pif'} } , ;
                                'Seleccionar Imagen' )
            SEPARATOR
            ITEM 'Guardar al tamaño del form como JPG 75%' ;
               ACTION ( oImage:Width := oForm:ClientWidth, ;
                        oImage:Height := oForm:ClientHeight, ;
                        oImage:SaveAs( "Nueva_" + LTrim( Str( nImg ) ) + ".jpg", .F., "JPG", 75, 24 ), ;
                        AutoMsgBox( "Nueva_" + LTrim( Str( nImg ) ) + ".jpg guardada !!!" ), ;
                        nImg ++ )

            ITEM 'Guardar al tamaño del form como JPG 100%' ;
               ACTION ( oImage:Width := oForm:ClientWidth, ;
                        oImage:Height := oForm:ClientHeight, ;
                        oImage:SaveAs( "Nueva_" + LTrim( Str( nImg ) ) + ".jpg", .F., "JPG", 100, 24 ), ;
                        AutoMsgBox( "Nueva_" + LTrim( Str( nImg ) ) + ".jpg guardada !!!" ), ;
                        nImg ++ )
            SEPARATOR
            ITEM 'Guardar a la mitad del tamaño del form como JPG 75%' ;
               ACTION ( oImage:Width := oForm:ClientWidth / 2, ;
                        oImage:Height := oForm:ClientHeight / 2, ;
                        oImage:SaveAs( "Nueva_" + LTrim( Str( nImg ) ) + ".jpg", .F., "JPG", 75, 24 ), ;
                        AutoMsgBox( "Nueva_" + LTrim( Str( nImg ) ) + ".jpg guardada !!!" ), ;
                        nImg ++ )

            ITEM 'Guardar a la mitad del tamaño del form como JPG 100%' ;
               ACTION ( oImage:Width := oForm:ClientWidth / 2, ;
                        oImage:Height := oForm:ClientHeight / 2, ;
                        oImage:SaveAs( "Nueva_" + LTrim( Str( nImg ) ) + ".jpg", .F., "JPG", 100, 24 ), ;
                        AutoMsgBox( "Nueva_" + LTrim( Str( nImg ) ) + ".jpg guardada !!!" ), ;
                        nImg ++ )
         END POPUP
      END MENU

      @ 00,00 IMAGE Image_1 ;
         OBJ oImage ;
         IMAGESIZE ;
         ACTION AutoMsgBox( "Alto: " + ;
                            AutoType( oImage:nHeight ) + ;
                            " Ancho: " + ;
                            AutoType( oImage:nWidth ) )

      ON KEY ESCAPE ACTION Form_1.Release()
   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

RETURN NIL

/*
 * EOF
 */
