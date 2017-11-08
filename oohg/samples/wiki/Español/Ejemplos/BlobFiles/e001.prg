/*
 * Ejemplo BLOB n° 1
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo guardar/leer una imagen en/desde
 * un campo BLOB y cómo mostrarla usando un control IMAGE.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 *
 * El archivo Input.ico puede descargarse desde:
 * https://github.com/fyurisich/OOHG_Samples/tree/master/Español/Ejemplos/BlobFiles
 */

#include "oohg.ch"
#include "blob.ch"

FUNCTION Main

   LOCAL aStruct := { {"CODE", "N", 3, 0}, {"IMAGE", "M", 10, 0} }
   LOCAL cInput  := "input.ico"
   LOCAL cOutput := "output.ico"
   LOCAL oForm
   LOCAL oImage

   REQUEST DBFCDX, DBFFPT
   RDDSETDEFAULT( "DBFCDX")

   DBCREATE( "IMAGES", aStruct )

   USE IMAGES NEW
   APPEND BLANK
   REPLACE code with 1

   // Importar
   IF ! BLOBIMPORT( FIELDPOS( "IMAGE" ), cInput )
      ? "Error al importar !!!"
      RETURN NIL
   ENDIF

   // Exportar
   FERASE( cOutput )
   IF ! BLOBEXPORT( FIELDPOS( "IMAGE" ), cOutput, BLOB_EXPORT_OVERWRITE )
      ? "Error al exportar !!!"
   ENDIF

   // Mostrar
   DEFINE WINDOW Form_1 ;
      OBJ oForm ;
      AT 0,0 ;
      WIDTH 588 ;
      HEIGHT 480 ;
      TITLE 'Mostrar una imagen guardada en un archivo BLOB' ;
      MAIN ;
      ON RELEASE ( DBCLOSEALL(), DBCOMMITALL() )

      @ 10, 10 IMAGE Img_1 ;
         OBJ oImage ;
         IMAGESIZE ;
         BUFFER BLOBGET( FIELDPOS( "IMAGE" ) )

      ON KEY ESCAPE ACTION oForm:Release()
   END WINDOW

   oForm:Center()
   oForm:Activate()

   CLOSE DATABASES

RETURN NIL

/*
 * EOF
 */
