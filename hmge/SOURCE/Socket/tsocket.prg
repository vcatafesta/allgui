/*
* Harbour Project source code:
* TSocket class
* Copyright 2001-2003 Matteo Baccan <baccan@infomedia.it>
* www - http://harbour-project.org
* This program is free software; you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation; either version 2, or (at your option)
* any later version.
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
* You should have received a copy of the GNU General Public License
* along with this software; see the file COPYING.  If not, write to
* the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
* Boston, MA 02111-1307 USA (or visit the web site http://www.gnu.org/).
* As a special exception, the Harbour Project gives permission for
* additional uses of the text contained in its release of Harbour.
* The exception is that, if you link the Harbour libraries with other
* files to produce an executable, this does not by itself cause the
* resulting executable to be covered by the GNU General Public License.
* Your use of that executable is in no way restricted on account of
* linking the Harbour library code into it.
* This exception does not however invalidate any other reasons why
* the executable file might be covered by the GNU General Public License.
* This exception applies only to the code released by the Harbour
* Project under the name Harbour.  If you copy code from other
* Harbour Project or Free Software Foundation releases into a copy of
* Harbour, as the General Public License permits, the exception does
* not apply to the code that you add in this way.  To avoid misleading
* anyone as to the status of such modified files, you must delete
* this exception notice from them.
* If you write modifications of your own for Harbour, it is your choice
* whether to permit this exception to apply to your modifications.
* If you do not wish that, delete this exception notice.
*/

#include "hbclass.ch"
#include "common.ch"

// These proocedures are required for startup the windows socket interface
INIT PROCEDURE StartSocket
   SocketInit()

   RETURN

EXIT PROCEDURE CleanupSocket
SocketExit()

RETURN

/****c* TSocket/TSocket
*  NAME
*    TSocket
*  PURPOSE
*    Create a SOCKET connection
*  METHODS
*    TSocket:new
*    TSocket:connect
*    TSocket:SendString
*    TSocket:ReceiveString
*    TSocket:ReceiveLine
*    TSocket:ReceiveChar
*    TSocket:GetLocalName
*    TSocket:GetLocalAddress
*    TSocket:Bind
*    TSocket:Listen
*    TSocket:SetReceiveTimeout
*    TSocket:SetSendTimeout
*    TSocket:SetDebug
*  EXAMPLE
*  SEE ALSO
*    TSmtp
*/

CLASS TSocket

   METHOD New()

   METHOD Connect( cAddress, nPort )
   METHOD Close()

   METHOD SendString( cString )
   METHOD ReceiveString()
   METHOD ReceiveLine()
   METHOD ReceiveChar( nBufLen )

   METHOD GetLocalName()    INLINE SocketLocalName()
   METHOD GetLocalAddress() INLINE SocketLocalAddress()

   METHOD Bind( cAddress, nPort )
   METHOD Listen( nClient )

   METHOD SetReceiveTimeout( nTime )
   METHOD SetSendTimeout( nTime )

   // Debug method
   METHOD SetDebug( bDebug )
   METHOD PrintDebugMessage( cMsg )
   // Debug method

   CLASSDATA m_hSocket       HIDDEN AS STRING INIT space(4)
   CLASSDATA nSendTimeout    HIDDEN INIT -1
   CLASSDATA nReceiveTimeout HIDDEN INIT -1

   // Debugger active for all classes
   CLASSDATA bDebug    HIDDEN INIT .F.

   ENDCLASS

METHOD New() CLASS TSocket

   RETURN SELF

   // Connect to remore site

METHOD Connect( cAddress, nPort ) CLASS TSocket

   LOCAL cSok := space( len( ::m_hSocket ) )
   LOCAL bRet

   ::PrintDebugMessage( "Connect to " +cAddress +" port " +str(nPort) )

   bRet := SocketConnect( @cSok, cAddress, nPort )

   ::m_hSocket := cSok

   RETURN bRet

   // Close socket

METHOD Close() CLASS TSocket

   LOCAL cSok := space( len( ::m_hSocket ) )
   LOCAL bRet

   ::PrintDebugMessage( "Close socket" )

   cSok := ::m_hSocket
   bRet := SocketClose( @cSok )
   ::m_hSocket := cSok

   RETURN bRet

   // Send string to socket

METHOD SendString( cString ) CLASS TSocket

   ::PrintDebugMessage( "Send string " +cString )

   RETURN SocketSend( ::m_hSocket, cString, ::nSendTimeout )

   // Receive string from socket

METHOD ReceiveString() CLASS TSocket

   LOCAL cRet := ""
   LOCAL cBuf := space(4096)
   LOCAL nRet

   ::PrintDebugMessage( "Receive string" )

   DO WHILE .T.
      nRet := SocketReceive( ::m_hSocket, @cBuf, ::nReceiveTimeout )
      IF nRet <= 0
         EXIT
      ENDIF
      cRet += substr( cBuf, 1, nRet )
   ENDDO

   ::PrintDebugMessage( "Received " +cRet )

   RETURN cRet

   // Receive char from socket

METHOD ReceiveChar( nBufLen ) CLASS TSocket

   LOCAL cRet, cBuf, nRet

   DEFAULT nBufLen TO 1
   cBuf := space(nBufLen)

   ::PrintDebugMessage( "Receive " + iif( nBufLen==1, "char", "custom string" ) )

   nRet := SocketReceive( ::m_hSocket, @cBuf, ::nReceiveTimeout )
   cRet := substr( cBuf, 1, nRet )

   ::PrintDebugMessage( "Received " +cRet )

   RETURN cRet

   // Receive Line from socket

METHOD ReceiveLine() CLASS TSocket

   LOCAL cRet := ""
   LOCAL cBuf := space(1)
   LOCAL nRet

   ::PrintDebugMessage( "Receive line" )

   DO WHILE .T.
      nRet := SocketReceive( ::m_hSocket, @cBuf, ::nReceiveTimeout )
      // If EOF, return
      IF nRet==1 .and. right(cBuf,1)==CHR(10)
         // If last char is CHR(13) remove it
         IF right(cRet,1)==CHR(13)
            cRet := substr( cRet, 1, len(cRet)-1 )
         ENDIF
         EXIT
      ENDIF
      IF nRet <= 0
         EXIT
      ENDIF
      cRet += substr( cBuf, 1, nRet )
   ENDDO

   ::PrintDebugMessage( "Received " +cRet )

   RETURN cRet

   // Bind all address

METHOD Bind( cAddress, nPort ) CLASS TSocket

   LOCAL cSok := space( len( ::m_hSocket ) )
   LOCAL bRet

   ::PrintDebugMessage( "Bind " +cAddress +" port " +str(nPort) )

   bRet := SocketBind( @cSok, cAddress, nPort )

   ::m_hSocket := cSok

   RETURN bRet

   // Listen for client

METHOD Listen( nClient ) CLASS TSocket

   LOCAL cSok := space( len( ::m_hSocket ) )
   LOCAL bRet
   LOCAL oRet

   DEFAULT nClient TO 10

   ::PrintDebugMessage( "Listen ..." )

   bRet := SocketListen( ::m_hSocket, nClient, @cSok )

   IF bRet
      oRet := TSocket():New()
      oRet:m_hSocket := cSok
   ENDIF

   RETURN oRet

   // Receive Timeout

METHOD SetReceiveTimeout( nTime ) CLASS TSocket

   ::nReceiveTimeout := nTime

   RETURN NIL

   // Send Timeout

METHOD SetSendTimeout( nTime ) CLASS TSocket

   ::nSendTimeout := nTime

   RETURN NIL

   // Set debug inside socket class

METHOD SetDebug( bDebug ) CLASS TSocket

   ::bDebug := bDebug

   RETURN NIL

   // Print error messages

METHOD PrintDebugMessage( cMsg ) CLASS TSocket

   IF ::bDebug
      ? "(" +::m_hSocket +") (" +cMsg +")"
   ENDIF

   RETURN NIL
