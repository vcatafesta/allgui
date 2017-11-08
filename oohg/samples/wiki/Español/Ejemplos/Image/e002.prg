/*
 * Ejemplo Image n° 2
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo guardar/cargar una imagen en/de
 * un campo BLOB y cómo mostrarla usango un control IMAGE.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"
#include "blob.ch"

FUNCTION Main

   LOCAL aEstruc  := { {"CODIGO", "N", 3, 0}, {"IMAGEN", "M", 10, 0} }
   LOCAL cEntrada := "input.ico"
   LOCAL cSalida  := "output.ico"
   LOCAL oForm

   REQUEST DBFCDX, DBFFPT
   RDDSETDEFAULT( "DBFCDX")

   DBCREATE( "IMAGENES", aEstruc )

   USE IMAGENES NEW
   APPEND BLANK
   REPLACE codigo with 1

   // Importar
   IF ! BLOBIMPORT( FIELDPOS( "IMAGEN" ), cEntrada )
      ? "Error importando !!!"
      RETURN NIL
   ENDIF

   // Exportar
   FERASE( cSalida )
   IF ! BLOBEXPORT( FIELDPOS( "IMAGEN" ), cSalida, BLOB_EXPORT_OVERWRITE )
      ? "Error exportando !!!"
   ENDIF

   // Mostrar
   DEFINE WINDOW Form_1 ;
      OBJ oForm ;
      AT 0,0 ;
      WIDTH 588 ;
      HEIGHT 480 ;
      TITLE 'Mostrar una imagen desde un campo BLOB' ;
      MAIN ;
      ON RELEASE IIF( MsgYesNo( "¿Borrar archivos auxiliares?" ), ;
                      Limpiar( cSalida ), ;
                      NIL )

      @ 10, 10 IMAGE Img_1 ;
         IMAGESIZE ;
         BUFFER BLOBGET( FIELDPOS( "IMAGEN" ) )

      ON KEY ESCAPE ACTION oForm:Release()
   END WINDOW

   oForm:Center()
   oForm:Activate()

   CLOSE DATABASES

RETURN NIL

PROCEDURE Limpiar( cSalida )
   CLOSE DATABASES
   FERASE( "IMAGENES.DBF" )
   FERASE( "IMAGENES.FPT" )
   FERASE( cSalida )
RETURN

/*
 * EOF
 */
