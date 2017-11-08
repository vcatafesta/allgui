/*
 * Ejemplo Image # 1
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Basado en un ejemplo de la distribución de OOHG creado
 * por Ciro Vargas C. <cvc@oohg.org>
 *
 * Este ejemplo muestra cómo obtener el ancho y alto de
 * una imagen utilizando un control IMAGE.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 640 ;
      HEIGHT 480 ;
      TITLE 'Control Image' ;
      MAIN

      DEFINE STATUSBAR
         STATUSITEM "Use el menú para seleccionar una imagen y luego haga clic en ella !!!"
      END STATUSBAR

      DEFINE MAIN MENU
         POPUP 'Archivo'
            ITEM 'Seleccionar Imagen' ;
               ACTION Form_1.Image_1.Picture := ;
                      Getfile ( { {'Archivos jpg','*.jpg'}, ;
                                  {'Archivos gif','*.gif'}, ;
                                  {'Archivos ico','*.ico'} } , ;
                                'Seleccionar Imagen' )
            ITEM 'Borrar' ACTION Form_1.Image_1.Picture := ''
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
