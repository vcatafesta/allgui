/*
* Ejemplo Http n� 1
* Author: Fernando Yurisich <fernando.yurisich@gmail.com>
* Licenciado bajo The Code Project Open License (CPOL) 1.02
* Ver <http://www.codeproject.com/info/cpol10.aspx>
* Este ejemplo muestra c�mo obtener el texto y los cabezales
* de una cierta p�gina de un sitio web utilizando el protocolo
* http. Este ejemplo est� disponible tambi�n en la carpeta
* samples/http del CVS de OOHG.
* Vis�tenos en https://github.com/fyurisich/OOHG_Samples o en
* http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
*/

#include "oohg.ch"
#include "i_socket.ch"
#include "h_http.prg"

PROCEDURE Main

#ifdef __XHARBOUR__
   EMPTY( _OOHG_ALLVARS )
#endif

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH 400 ;
         HEIGHT 200 ;
         TITLE 'Ejemplo de HTTP GET' ;
         MAIN

      DEFINE MAIN MENU
         POPUP 'Prueba con memvar'
            ITEM 'Obtener cabezales y texto'  ACTION PruebaHttpMem( 1 )
            ITEM 'Obtener solo los cabezales' ACTION PruebaHttpMem( 2 )
            ITEM 'Obtener solo el texto'      ACTION PruebaHttpMem( 3 )
         END POPUP
         POPUP 'Prueba con referencia'
            ITEM 'Obtener cabezales y texto'  ACTION PruebaHttpRef( 1 )
            ITEM 'Obtener solo los cabezales' ACTION PruebaHttpRef( 2 )
            ITEM 'Obtener solo el texto'      ACTION PruebaHttpRef( 3 )
         END POPUP
      END MENU

      ON KEY ESCAPE ACTION Form_1.Release()
   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

   RETURN

PROCEDURE PruebaHttpMem( nOpcion )

   LOCAL cRespuesta
   MEMVAR oConex

   // Crea una variable p�blica que contiene el objeto de la conexi�n

   OPEN CONNECTION oConex SERVER 'www.itlnet.net' PORT 80 HTTP

   IF oConex == Nil
      AUTOMSGBOX( "No hay conexi�n !!!" )
   ELSE
      DO CASE
      CASE nOpcion == 1
         GET URL '/programming/program/Reference/c53g01c/menu.html' TO cRespuesta CONNECTION oConex
      CASE nOpcion == 2
         GET URL '/programming/program/Reference/c53g01c/menu.html' TO cRespuesta CONNECTION oConex HEADERS
      OTHERWISE
         GET URL '/programming/program/Reference/c53g01c/menu.html' TO cRespuesta CONNECTION oConex NOHEADERS
      ENDCASE

      CLOSE CONNECTION oConex
      RELEASE oConex

      AUTOMSGBOX( cRespuesta )
   ENDIF

   RETURN

PROCEDURE PruebaHttpRef( nOpcion )

   LOCAL cRespuesta, oConex

   // El objeto de la conexi�n es guardado en un variable preexistente.

   OPEN CONNECTION OBJ oConex SERVER 'harbour.github.io' PORT 80 HTTP

   IF oConex == Nil
      AUTOMSGBOX( "No hay conexi�n !!!" )
   ELSE
      DO CASE
      CASE nOpcion == 1
         GET URL '/index.html' TO cRespuesta CONNECTION oConex
      CASE nOpcion == 2
         GET URL '/index.html' TO cRespuesta CONNECTION oConex HEADERS
      OTHERWISE
         GET URL '/index.html' TO cRespuesta CONNECTION oConex NOHEADERS
      ENDCASE

      CLOSE CONNECTION oConex

      AUTOMSGBOX( cRespuesta )
   ENDIF

   RETURN

   /*
   * EOF
   */

   Este es el contenido del archivo i_socket.ch

   ?#xcommand OPEN CONNECTION [<obj: OBJ>] <con> SERVER <server> PORT <port> HTTP ;
      => ;
      httpconnect( iif( <.obj.>, @<con>, <(con)>), <server>, <port> )

#xcommand CLOSE CONNECTION <con> ;
      => ;
      <con>:Close()

#xcommand GET URL <url> TO <response> CONNECTION <con> [ <data: NOHEADERS, HEADERS> ];
      => ;
      <response> := httpgeturl( <con>, <url>, iif( upper( #<data> ) == "HEADERS", .F., iif( upper( #<data> ) == "NOHEADERS", NIL, .T. ) ) )

   Este es el contenido del archivo h_http.prg

FUNCTION httpconnect( Connection, Server, Port )

   LOCAL oUrl

   IF ! Upper( Left( Server, 7 ) ) == "HTTP://"
      Server := "http://" + Server
   ENDIF

   oUrl := tURL():New( Server + ":" + Ltrim( Str( Port ) ) )

   IF HB_IsString( Connection )
      PUBLIC &Connection

      IF Empty( oUrl )
         &Connection := Nil
      ELSE
         &Connection := TIpClientHttp():New( oUrl )

         IF ! (&Connection):Open()
            &Connection := Nil
         ENDIF
      ENDIF
   ELSE
      IF Empty( oUrl )
         Connection := Nil
      ELSE
         Connection := TIpClientHttp():New( oUrl )

         IF ! Connection:Open()
            Connection := Nil
         ENDIF
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION httpgeturl( Connection, cPage, uRet )

   LOCAL cUrl, cResponse, cHeader, i, cRet

   cUrl := "http://"
   IF ! Empty( Connection:oUrl:cUserid )
      cUrl += Connection:oUrl:cUserid
      IF ! Empty( Connection:oUrl:cPassword )
         cUrl += ":" + Connection:oUrl:cPassword
      ENDIF
      cUrl += "@"
   ENDIF
   IF ! Empty( Connection:oUrl:cServer )
      cUrl += Connection:oUrl:cServer
      IF Connection:oUrl:nPort > 0
         cUrl += ":" + hb_ntos( Connection:oUrl:nPort )
      ENDIF
   ENDIF
   cUrl += cPage

   IF Connection:Open( cUrl )
      cResponse := Connection:Read()
      IF ! hb_IsString( cResponse )
         cResponse := "<No se recibi� DATA>"
      ENDIF

      IF hb_IsLogical( uRet )
         cHeader := Connection:cReply
         IF ! hb_IsString( cHeader )
            cHeader := "<No se recibi� HEADER>"
         ENDIF
         cHeader += hb_OsNewLine()

         FOR i := 1 to Len( Connection:hHeaders )
#ifdef __XHARBOUR__
            cHeader += hGetKeyAt( Connection:hHeaders, i ) + ": " + hGetValueAt( Connection:hHeaders, i ) + hb_OsNewLine()
#else
            cHeader += hb_HKeyAt( Connection:hHeaders, i ) + ": " + hb_HValueAt( Connection:hHeaders, i ) + hb_OsNewLine()
#endif
         NEXT
         cHeader += hb_OsNewLine()

         IF uRet                       // retorna DATA y HEADERS
            cRet := cHeader + cResponse
         ELSE                          // retorna solo HEADERS
            cRet := cHeader
         ENDIF
      ELSE                             // retorna solo DATA
         cRet := cResponse
      ENDIF
   ELSE
      cRet := "<Error al abrir URL>"
   ENDIF

   RETURN cRet

   /*
   * EOF
   */
