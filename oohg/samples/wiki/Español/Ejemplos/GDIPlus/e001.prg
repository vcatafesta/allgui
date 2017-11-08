/*
 * Ejemplo GDIPlus n° 1
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo utilizar la librería GDI+ para
 * cargar y guardar imágenes bmp, jpeg, gif, tiff y png.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 *
 * Las imágenes utilizadas en este ejemplo pueden descargarse desde:
 * https://github.com/fyurisich/OOHG_Samples/tree/master/Español/Ejemplos/GDIPlus
 */

#include "oohg.ch"

#define HBITMAP_ANCHO     1
#define HBITMAP_ALTO      2
#define HBITMAP_BITSPIXEL 3

MEMVAR cPicture, cType, aSize, aMimeType, oImage, oForm, i

PROCEDURE Main()
   PUBLIC cPicture, cType, aSize, aMimeType, oImage, oForm, i

   SetOneArrayItemPerLine( .T. )

   IF ! gPlusInit()
      MsgStop( "Error al iniciar GDI+", "Error" )
      RETURN
   ENDIF

   aMimeType := gPlusGetEncoders()
   /*
    * Tipos por defecto:
    * image/bmp
    * image/jpeg
    * image/gif
    * image/tiff
    * image/png
    */

   DEFINE WINDOW Form_Main OBJ oForm ;
      AT 0,0 ;
      WIDTH 640 ;
      HEIGHT 480 ;
      TITLE 'GDI+: Guardar un Bitmap en un Archivo' ;
      MAIN ;
      NOMAXIMIZE ;
      NOSIZE ;
      ON RELEASE IIF( gPlusDeInit(), ;
                      NIL, ;
                      MsgExclamation( "Error al descargar GDI+", "Error" ) )

      DEFINE MAIN MENU
         DEFINE POPUP "&Archivo"
            FOR i := 1 TO Len( aMimeType )
               IF "jpeg" $ aMimeType[i]
                  MENUITEM 'Guardar como JPEG' NAME mnu_JPEG DISABLED ;
                     ACTION GuardarComo( oImage:HBitMap, ;
                                         "new.jpeg", ;
                                         aSize[HBITMAP_ANCHO], ;
                                         aSize[HBITMAP_ALTO], ;
                                         "image/jpeg", ;
                                         100 )
               ENDIF
               IF "gif" $ aMimeType[i]
                  MENUITEM 'Guardar como GIF' NAME mnu_GIF DISABLED ;
                     ACTION GuardarComo( oImage:HBitMap, ;
                                         "new.gif", ;
                                         aSize[HBITMAP_ANCHO], ;
                                         aSize[HBITMAP_ALTO], ;
                                         "image/gif", ;
                                         100 )
               ENDIF
               IF "tiff" $ aMimeType[i]
                  MENUITEM 'Guardar como TIFF' NAME mnu_TIFF DISABLED ;
                     ACTION GuardarComo( oImage:HBitMap, ;
                                         "new.tiff", ;
                                         aSize[HBITMAP_ANCHO], ;
                                         aSize[HBITMAP_ALTO], ;
                                         "image/tiff", ;
                                         100 )
               ENDIF
               IF "png" $ aMimeType[i]
                  MENUITEM 'Guardar como PNG' NAME mnu_PNG DISABLED ;
                     ACTION GuardarComo( oImage:HBitMap, ;
                                         "new.png", ;
                                         aSize[HBITMAP_ANCHO], ;
                                         aSize[HBITMAP_ALTO], ;
                                         "image/png", ;
                                         100 )
               ENDIF
               IF "bmp" $ aMimeType[i]
                  MENUITEM 'Guardar como BMP' NAME mnu_BMP DISABLED ;
                     ACTION GuardarComo( oImage:HBitMap, ;
                                         "new.bmp", ;
                                         aSize[HBITMAP_ANCHO], ;
                                         aSize[HBITMAP_ALTO], ;
                                         "image/bmp", ;
                                         100 )
               ENDIF
            NEXT
            SEPARATOR
            MENUITEM "&Salir" ACTION ThisWindow.Release
         END POPUP
         DEFINE POPUP "&?"
            MENUITEM 'Obtener la cantidad de codificadores' ;
               ACTION MsgInfo( "Cantidad de codificadores: " + ;
                                  LTrim( Str( gPlusGetEncodersNum() ) ), ;
                               "Información" )
            SEPARATOR
            MENUITEM "Image Info" NAME mnu_INFO DISABLED ;
               ACTION AutoMsgInfo( { "Nombre: " + hb_OSNewLine() + ;
                                        cPicture, ;
                                     "Ancho: " + hb_OSNewLine() + ;
                                        LTrim( Str( aSize[HBITMAP_ANCHO] ) ), ;
                                     "Alto: " + hb_OSNewLine() + ;
                                        LTrim( Str( aSize[HBITMAP_ALTO] ) ), ;
                                     "Bits por Pixel: " + hb_OSNewLine() + ;
                                        LTrim( Str( aSize[HBITMAP_BITSPIXEL] ) ) }, ;
                                   "Información de la Imagen" )
            MENUITEM 'Información de "rainbow.jpg"' ;
               ACTION ObtenerInfo( GetStartupFolder() + "\rainbow.jpg" )
            MENUITEM 'Información de "fondo.jpg"' ;
               ACTION ObtenerInfo( GetStartupFolder() + "\fondo.jpg" )
            MENUITEM 'Información de "ohh.png"' ;
               ACTION ObtenerInfo( GetStartupFolder() + "\ohh.png" )
         END POPUP
      END MENU

      @ 05, 20 LABEL lbl_Type ;
         VALUE "Tipo:" ;
         WIDTH 50 ;
         HEIGHT 24

      @ 05, 70 COMBOBOX cmb_Type ;
         WIDTH 150 ;
         ITEMS {'bmp','jpeg','gif','tiff','png','emf'} ;
         VALUE 0 ;
         ON CHANGE CargarImagen( Form_Main.cmb_Type.Value )

      @ 05, 240 LABEL lbl_Image ;
         VALUE "Imagen cargada: <ninguna>" ;
         WIDTH 350 ;
         HEIGHT 24

      @ 40, 20 IMAGE Image_1 OBJ oImage ;
         IMAGESIZE

      ON KEY ESCAPE ACTION ThisWindow.Release
   END WINDOW

   CENTER WINDOW Form_Main
   ACTIVATE WINDOW Form_Main
RETURN

FUNCTION CargarImagen( i )
   cType          := {'bmp','jpeg','gif','tiff','png','emf'}[i]
   cPicture       := "demo." + cType
   aSize          := _OOHG_SizeOfBitmapFromFile( cPicture )
   oImage:Picture := cPicture

   oForm:lbl_Image:Value  := "Imagen cargada: " + cPicture
   oForm:mnu_BMP:Enabled  := ( i # 1 )
   oForm:mnu_JPEG:Enabled := ( i # 2 )
   oForm:mnu_GIF:Enabled  := ( i # 3 )
   oForm:mnu_TIFF:Enabled := ( i # 4 )
   oForm:mnu_PNG:Enabled  := ( i # 5 )
   oForm:mnu_INFO:Enabled := .T.
RETURN NIL

FUNCTION ObtenerInfo( cFile )
   LOCAL nImage, nWidth, nHeight

   nImage  := gPlusLoadImageFromFile( cFile )
   nWidth  := gPlusGetImageWidth( nImage )
   nHeight := gPlusGetImageHeight( nImage )

   AutoMsgInfo( { "Nombre: " + hb_OSNewLine() + cFile, ;
                  "Ancho: "  + hb_OSNewLine() + LTrim( Str( nWidth ) ), ;
                  "Alto: " + hb_OSNewLine() + LTrim( Str( nHeight ) ) }, ;
                "Información de la Imagen" )
RETURN NIL

FUNCTION GuardarComo( hBitMap, cFile, nWidth, nHeight, cMimeType, nQuality )
   LOCAL lRet := gPlusSaveHBitmapToFile( hBitMap, ;
                                         cFile, ;
                                         nWidth, ;
                                         nHeight, ;
                                         cMimeType, ;
                                         nQuality, ;
                                         24 )
RETURN MsgInfo( IIF( lRet, "Guardado como " + cFile, "Error" ), "Resultado" )

/*
 * EOF
 */
