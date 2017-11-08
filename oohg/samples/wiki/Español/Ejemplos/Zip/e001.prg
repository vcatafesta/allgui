/*
 * Ejemplo Zip n° 1
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo crear un archivo ZIP de una
 * carpeta y sus subcarpetas. Note que la función HB_ZipFile()
 * no procesa automáticamente las subcarpetas en Harbour 3.0
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include 'oohg.ch'
#include 'directry.ch'

FUNCTION Main()

  SET LANGUAGE TO SPANISH

   DEFINE WINDOW FormPrincipal ;
      AT 114,218 ;
      WIDTH 580 ;
      HEIGHT 276 ;
      CLIENTAREA ;
      TITLE 'Como Zipear una Carpeta y sus Subcarpetas Usando la Librería MiniZip' ;
      MAIN

      @ 20,20 BUTTON btn_1 ;
         CAPTION 'Elegir carpeta' ;
         ACTION ZipearCarpeta()

      @ 60,20 PROGRESSBAR prg_1 ;
         SMOOTH ;
         WIDTH 540

      @ 100,20 LABEL lbl_1 ;
         VALUE "" ;
         WIDTH 540

      ON KEY ESCAPE ACTION FormPrincipal.Release
   END WINDOW

   FormPrincipal.Center
   FormPrincipal.Activate

RETURN NIL

FUNCTION ZipearCarpeta

   LOCAL cCarpeta, hZip, aArchivos, i

   IF EMPTY( cCarpeta := GetFolder( 'Carpeta a Ziperar', 'C:\' ) )
      RETURN NIL
   ENDIF

   IF FILE( 'ziptest.zip' )
      ERASE ziptest.zip
   ENDIF

   hZip := HB_ZipOpen( 'ziptest.zip' )
   IF EMPTY( hZip )
      MsgExclamation( "No se pudo crear ziptest.zip !!!" )
      RETURN NIL
   ENDIF

   aArchivos := {}

   ProcesarArchivos( cCarpeta, aArchivos )

   IF LEN( aArchivos ) > 0
      FormPrincipal.prg_1.RangeMax := LEN( aArchivos )

      FOR i := 1 TO LEN( aArchivos )
         EVAL( {|cArchivo, nPos| ActualizarProgreso( nPos, cArchivo ) }, aArchivos[ i ], i )

         HB_ZipStoreFile( hZip, ;
                          aArchivos[ i ], ;
                          substr( aArchivos[ i ], LEN( cCarpeta ) + 2 ) )
      NEXT

      HB_ZipClose( hZip )

      MsgInfo( 'Se creó el archivo ziptest.zip !!!')
   ELSE
      MsgExclamation( "No se encontraron archivos !!!" )
   ENDIF

RETURN NIL

FUNCTION ProcesarArchivos( cCarpeta, aArchivos )

   LOCAL aDir, aDatosArchivo

   aDir := DIRECTORY( cCarpeta + '\*.*', "D" )

   FOR EACH aDatosArchivo IN aDir
      IF aDatosArchivo[ F_NAME ] == "."
         // ignore
      ELSEIF aDatosArchivo[ F_NAME ] == ".."
         // ignore
      ELSEIF 'D' $ aDatosArchivo[ F_ATTR ]
         ProcesarArchivos( cCarpeta + '\' + aDatosArchivo[ F_NAME ], aArchivos )
      ELSE
         AADD( aArchivos, cCarpeta + '\' + aDatosArchivo[ F_NAME ] )
      ENDIF
   NEXT

RETURN NIL

FUNCTION ActualizarProgreso( nPos, cArchivo )

   FormPrincipal.prg_1.Value := nPos
   FormPrincipal.lbl_1.Value := cArchivo

RETURN NIL

/*
 * EOF
 */
