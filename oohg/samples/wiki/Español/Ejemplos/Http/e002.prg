/*
 * Ejemplo HTTP Sample n° 2
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo actualizar automáticamente una
 * aplicación desde Internet. Para probarlo se necesita
 * "MyApp.prg".
 *
 * Este ejemplo fue probado con éxito usango una dirección
 * "http" para bajar el nuevo archivo. La prueba con una
 * dirección "https" no fue existosa. Por favor envíanos un
 * correo si tienes éxito.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 *
 * El archivo MyApp.prg puede descargarse desde:
 * https://github.com/fyurisich/OOHG_Samples/tree/master/Español/Ejemplos/Http
 */

#include "oohg.ch"

FUNCTION Main
   LOCAL cActualizado

   IF HayUnaNuevaVersion()
      IF DescargarNuevaVersion()
         RENAME ( "MyApp.exe" ) TO ( "OldApp_" + DTOS(DATE()) + "_" + STRTRAN(TIME(), ":", "_") + ".exe" )
         IF ! FILE( "MyApp.exe" )
            hb_UnzipFile( "NewApp.zip" )
            IF FILE( "NewApp.exe" )
               RENAME ( "NewApp.exe" ) TO ( "MyApp.exe" )
            ENDIF
            IF FILE( "MyApp.exe" )
               cActualizado := "T"
            ENDIF
         ENDIF
      ENDIF
   ENDIF
   IF File( "MyApp.exe")
      EXECUTE FILE "MyApp.exe" PARAMETERS cActualizado
   ELSE
      MsgStop( "Aplicación no encontrada !!!" )
   ENDIF
RETURN NIL

FUNCTION HayUnaNuevaVersion
RETURN .T.

FUNCTION DescargarNuevaVersion
   LOCAL cUrl := "http://..."
   LOCAL oUrl
   LOCAL oHTTP

   oUrl := TUrl():New( cUrl )
   oHTTP := TIpClientHTTP():New( oUrl )
   IF ( lRetVal := oHTTP:Open() )
      oHTTP:ReadToFile( "NewApp.zip" )
      oHTTP:Close()
   ENDIF
RETURN lRetVal

/*
 * EOF
 */
