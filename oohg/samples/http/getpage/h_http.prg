/*
* $Id: h_http.prg $
*/
/*
* ooHG source code:
* HTTP class call
* Copyright 2005-2017 Vicente Guerra <vicente@guerra.com.mx>
* https://oohg.github.io/
* Portions of this project are based upon Harbour MiniGUI library.
* Copyright 2002-2005 Roberto Lopez <roblez@ciudad.com.ar>
* This program is free software; you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation; either version 2, or (at your option)
* any later version.
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
* You should have received a copy of the GNU General Public License
* along with this software; see the file LICENSE.txt. If not, write to
* the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1335,USA (or download from http://www.gnu.org/licenses/).
* As a special exception, the ooHG Project gives permission for
* additional uses of the text contained in its release of ooHG.
* The exception is that, if you link the ooHG libraries with other
* files to produce an executable, this does not by itself cause the
* resulting executable to be covered by the GNU General Public License.
* Your use of that executable is in no way restricted on account of
* linking the ooHG library code into it.
* This exception does not however invalidate any other reasons why
* the executable file might be covered by the GNU General Public License.
* This exception applies only to the code released by the ooHG
* Project under the name ooHG. If you copy code from other
* ooHG Project or Free Software Foundation releases into a copy of
* ooHG, as the General Public License permits, the exception does
* not apply to the code that you add in this way. To avoid misleading
* anyone as to the status of such modified files, you must delete
* this exception notice from them.
* If you write modifications of your own for ooHG, it is your choice
* whether to permit this exception to apply to your modifications.
* If you do not wish that, delete this exception notice.
*/
/*----------------------------------------------------------------------------
MINIGUI - Harbour Win32 GUI library source code

Copyright 2002-2005 Roberto Lopez <roblez@ciudad.com.ar>
http://www.geocities.com/harbour_minigui/

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this software; see the file LICENSE.txt. If not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA (or
visit the web site http://www.gnu.org/).

As a special exception, you have permission for additional uses of the text
contained in this release of Harbour Minigui.

The exception is that, if you link the Harbour Minigui library with other
files to produce an executable, this does not by itself cause the resulting
executable to be covered by the GNU General Public License.
Your use of that executable is in no way restricted on account of linking the
Harbour-Minigui library code into it.

Parts of this project are based upon:

"Harbour GUI framework for Win32"
Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
Copyright 2001 Antonio Linares <alinares@fivetech.com>
www - http://www.harbour-project.org

"Harbour Project"
Copyright 1999-2003, https://harbour.github.io/
---------------------------------------------------------------------------*/

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
         cResponse := "<No data returned>"
      ENDIF

      IF hb_IsLogical( uRet )
         cHeader := Connection:cReply
         IF ! hb_IsString( cHeader )
            cHeader := "<No header returned>"
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

         IF uRet                       // return DATA and HEADERS
            cRet := cHeader + cResponse
         ELSE                          // return HEADERS only
            cRet := cHeader
         ENDIF
      ELSE                             // return DATA only
         cRet := cResponse
      ENDIF
   ELSE
      cRet := "<Error opening URL>"
   ENDIF

   RETURN cRet
