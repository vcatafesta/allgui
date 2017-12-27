/*
* Harbour Project source code:
* TSMTP class
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

#include "common.ch"
#include "hbclass.ch"
#include "set.ch"

/****** TSMTP/TSMTP
*  NAME
*    TSMTP
*  PURPOSE
*    Create a SMTP connection
*  METHODS
*    TSMTP:new
*    TSMTP:connect
*    TSMTP:login
*    TSMTP:loginMD5
*    TSMTP:close
*    TSMTP:cleardata
*    TSMTP:setfrom
*    TSMTP:setreplyto
*    TSMTP:setsubject
*    TSMTP:setpriority
*    TSMTP:addto
*    TSMTP:addcc
*    TSMTP:addbcc
*    TSMTP:setdata
*    TSMTP:AddAttach
*    TSMTP:send
*    TSMTP:GetLastError
*    TSMTP:SetSendTimeout
*  EXAMPLE
*  SEE ALSO
*    TDecode
*/
// RFC 821

CLASS TSMTP

   EXPORTED:
   METHOD New()

   METHOD Connect( cAddress, nPort, cHelo )
   METHOD Login( cUser, cPwd )
   METHOD LoginMD5( cUser, cPwd )
   METHOD Close()

   METHOD ClearData()
   METHOD SetFrom( cUser, cEmail )
   METHOD SetReplyTo( cReplyTo )
   METHOD SetSubject( cSubject )
   METHOD SetPriority( nPriority )

   METHOD AddTo( cUser, cEmail )
   METHOD AddCc( cUser, cEmail )
   METHOD AddBcc( cUser, cEmail )

   METHOD SetData( cMail, bHTML )

   METHOD AddAttach( cAttach )

   METHOD Send( bIgnoreTOError, bRequestReturnReceipt )
   METHOD GetLastError()

   METHOD SetSendTimeout( nMilliSec )

   HIDDEN:
   METHOD GetLines()

   CLASSDATA oSocket   HIDDEN
   CLASSDATA cFrom     HIDDEN
   CLASSDATA cReplyTo  HIDDEN
   CLASSDATA cEmail    HIDDEN
   CLASSDATA cSubject  HIDDEN
   CLASSDATA nPriority HIDDEN
   CLASSDATA aTo       HIDDEN
   CLASSDATA aCc       HIDDEN
   CLASSDATA aBcc      HIDDEN
   CLASSDATA cData     HIDDEN
   CLASSDATA bHTML     HIDDEN
   CLASSDATA aAttach   HIDDEN
   CLASSDATA cError    HIDDEN

   ENDCLASS

METHOD New() CLASS TSMTP

   ::oSocket := TSocket():New()
   //::oSocket:SetDebug( .T. )
   ::ClearData()

   RETURN Self

   // Connect to remore site

METHOD Connect( cAddress, nPort, cHelo ) CLASS TSMTP

   LOCAL bRet, cErr

   DEFAULT nPort TO 25
   DEFAULT cHelo TO ::oSocket:GetLocalName()

   bRet := ::oSocket:Connect(cAddress,nPort)

   // If connect read banner string
   IF bRet
      // Consume banner
      cErr := ::GetLines()
      IF LEFT(cErr,3)=="220"
         // Send extended hello first (RFC 2821)
         IF ::oSocket:SendString( "EHLO " +cHelo +CHR(13)+CHR(10) )
            cErr := ::GetLines()
            IF !(LEFT(cErr,3)=="250")
               // Send hello (RFC 821)
               IF ::oSocket:SendString( "HELO " +cHelo +CHR(13)+CHR(10) )
                  cErr := ::GetLines()
                  IF !(LEFT(cErr,3)=="250")
                     ::cError := cErr
                  ELSE
                     bRet := .T.
                  ENDIF
               ENDIF
            ELSE
               bRet := .T.
            ENDIF
         ENDIF
      ELSE
         ::cError := cErr
         bRet := .F.
      ENDIF
   ENDIF

   RETURN bRet

   // Receive lines (answer) from server

METHOD GetLines() CLASS TSMTP

   LOCAL cLines := ""
   LOCAL cLine

   WHILE ( len(cLine := ::oSocket:ReceiveLine())>0 )
      cLines += if( len(cLine)>0, cLine + CHR(13) + CHR(10), "" )
      IF substr(cLine,4,1)==" " .or. len(cLine)<=3 .or. substr(cLine,4,1)==CHR(10)
         EXIT
      ENDIF
   ENDDO

   RETURN cLines

   // Login to server

METHOD Login( cUser, cPwd ) CLASS TSMTP

   LOCAL cErr    := ""
   LOCAL bRet    := .F.
   LOCAL oDecode := TDecode():new()

   IF ::oSocket:SendString( "AUTH LOGIN" +CHR(13)+CHR(10) )
      // Consume banner
      cErr := ::GetLines()
      IF LEFT(cErr,3)=="334"
         IF ::oSocket:SendString( oDecode:Encode64( cUser ) +CHR(13)+CHR(10) )
            // Consume banner
            cErr := ::GetLines()
            IF LEFT(cErr,3)=="334"
               IF ::oSocket:SendString( oDecode:Encode64( cPwd ) +CHR(13)+CHR(10) )
                  // Consume banner
                  cErr := ::GetLines()
                  IF LEFT(cErr,3)=="235" .or. LEFT(cErr,3)=="335"
                     bRet := .T.
                  ENDIF
               ENDIF
            ENDIF
         ENDIF
      ENDIF
   ENDIF

   IF !bRet
      ::cError := cErr
   ENDIF

   RETURN bRet

   // Login to server

METHOD LoginMD5( cUser, cPwd ) CLASS TSMTP

   LOCAL cErr    := ""
   LOCAL bRet    := .F.
   LOCAL oDecode := TDecode():new()
   LOCAL cDigest, hMac

   IF ::oSocket:SendString( "AUTH CRAM-MD5" +CHR(13)+CHR(10) )
      // Consume banner
      cErr := ::GetLines()
      IF LEFT(cErr,3)=="334"
         cDigest := substr( cErr, 5 )
         hMac    := oDecode:hmac_md5( cUser, cPwd, cDigest )
         IF ::oSocket:SendString( hMac +CHR(13)+CHR(10) )
            // Consume banner
            cErr := ::GetLines()
            IF LEFT(cErr,3)=="235" .or. LEFT(cErr,3)=="335"
               bRet := .T.
            ENDIF
         ENDIF
      ENDIF
   ENDIF

   IF !bRet
      ::cError := cErr
   ENDIF

   RETURN bRet

   // Close socket

METHOD Close() CLASS TSMTP

   ::oSocket:SendString( "QUIT" +CHR(13)+CHR(10) )
   ::GetLines()

   RETURN ::oSocket:Close()

   // Clear data

METHOD ClearData() CLASS TSMTP

   ::cFrom     := ""
   ::cReplyTo  := ""
   ::cEmail    := ""
   ::nPriority := 3
   ::aTo       := {}
   ::aCc       := {}
   ::aBcc      := {}
   ::cData     := ""
   ::bHTML     := .f.
   ::aAttach   := {}
   ::cError    := ""

   RETURN NIL

   // Set From

METHOD SetFrom( cUser, cEmail )  CLASS TSMTP

   ::cFrom  := cUser
   ::cEmail := cEmail

   RETURN NIL

   // Set Reply-To

METHOD SetReplyTo( cReplyTo )  CLASS TSMTP

   ::cReplyTo := cReplyTo

   RETURN NIL

   // Set Subject

METHOD SetSubject( cSubject )  CLASS TSMTP

   ::cSubject := cSubject

   RETURN NIL

   // Set Priority

METHOD SetPriority( nPriority )  CLASS TSMTP

   ::nPriority := nPriority

   RETURN NIL

   // Add to

METHOD AddTo( cUser, cEmail ) CLASS TSMTP

   aadd( ::aTo, {cUser,cEmail} )

   RETURN NIL

   // Add cc

METHOD AddCc( cUser, cEmail ) CLASS TSMTP

   aadd( ::aCc, {cUser,cEmail} )

   RETURN NIL

   // Add Bcc

METHOD AddBcc( cUser, cEmail ) CLASS TSMTP

   aadd( ::aBcc, {cUser,cEmail} )

   RETURN NIL

   // Set data

METHOD SetData( cMail, bHTML ) CLASS TSMTP

   DEFAULT bHTML TO .f.
   ::cData := cMail
   ::bHTML := bHTML

   RETURN NIL

   // Add attach

METHOD AddAttach( cAttach ) CLASS TSMTP

   aadd( ::aAttach, cAttach )

   RETURN NIL

   // Get Error

METHOD GetLastError() CLASS TSMTP

   RETURN ::cError

   // Set Send timeout

METHOD SetSendTimeout( nMilliSec ) CLASS TSMTP

   ::oSocket:SetSendTimeout( nMilliSec )

   RETURN NIL

   // Send message

METHOD Send( bIgnoreTOError, bRequestReturnReceipt ) CLASS TSMTP

   LOCAL bRet := .f.
   LOCAL cHeader := ""
   LOCAL cErr
   LOCAL bMultipart := (LEN(::aAttach)>0)
   LOCAL cMultipart := "----=_NextPart_000_0052_01C2F554.33353C20"
   LOCAL oDecode := TDecode():new()
   LOCAL nPos, aEmails, bMail, dDate
   LOCAL cOldDateFormat, nOldEpoch, cOldLang

   DEFAULT bIgnoreTOError TO .F.
   DEFAULT bRequestReturnReceipt TO .F. // request a return receipt for your email

   ::cError := ""
   IF ::oSocket:SendString( "MAIL FROM: " +::cEmail +CHR(13)+CHR(10) )
      // Banner
      cErr := ::GetLines()
      // Check 250
      IF left(cErr,3)=="250" .or. left(cErr,3)=="550"

         aEmails := array(0)
         AEVAL( ::aTO,  {|aSub|AADD( aEmails, aSub[2] )} )
         AEVAL( ::aCC,  {|aSub|AADD( aEmails, aSub[2] )} )
         AEVAL( ::aBCC, {|aSub|AADD( aEmails, aSub[2] )} )

         bMail := .T.
         FOR nPos := 1 to len(aEmails)
            IF bMail
               ::oSocket:SendString( "RCPT TO: " +aEmails[nPos] +CHR(13)+CHR(10) )
               cErr := ::GetLines()
               IF !(LEFT(cErr,3)=="250") .and. !bIgnoreTOError
                  ::cError := cErr
                  bMail := .F.
               ENDIF
            ENDIF
         NEXT

         IF bMail
            // If all is OK I can prepare and send data
            IF ::oSocket:SendString( "DATA" +CHR(13)+CHR(10) )
               // Banner
               cErr := ::GetLines()
               // Check 354 or 554
               IF LEFT(cErr,3)=="354" .or. LEFT(cErr,3)=="554"
                  nOldEpoch := Set(_SET_EPOCH, 1980)
                  cOldDateFormat := Set( _SET_DATEFORMAT, "mm/dd/yyyy" )
                  dDate := Date()
                  cOldLang := Set( _SET_LANGUAGE, "EN" )
                  //Date: Sat, 14 Aug 2004 14:18:08 +0100
                  cHeader := "Date: " + left(cDoW(dDate), 3) + ", " + ltrim(trans(Day(dDate), "99 "));
                     + trans(cMonth(dDate), "AAA") + " " + trans(Year(dDate), "9999 ") + Time();
                     + " " + GETTIMEZONEDIFF() +CHR(13)+CHR(10)

                  Set( _SET_LANGUAGE, cOldLang )
                  Set( _SET_DATEFORMAT, cOldDateFormat )
                  Set( _SET_EPOCH, nOldEpoch )

                  cHeader += "From: "     +::cFrom +" " +::cEmail +CHR(13)+CHR(10)
                  cHeader += "Reply-To: " + iif( Empty(::cReplyTo), ::cFrom +" " +::cEmail, ::cReplyTo ) +CHR(13)+CHR(10)

                  cHeader += addAddress( ::aTO, "To: " )
                  cHeader += addAddress( ::aCC, "CC: " )
                  cHeader += addAddress( ::aBCC, "BCC: " )

                  cHeader += "Subject: "  +::cSubject +CHR(13)+CHR(10)

                  //## add properties to modify it
                  cHeader += "X-Mailer: Harbour TSMTP by Matteo Baccan" +CHR(13)+CHR(10)
                  cHeader += "X-Priority: " + trans(::nPriority, "9 ") + "(";
                     + if(::nPriority==1, "Highest", if(::nPriority==5, "Low", "Normal")) + ")" +CHR(13)+CHR(10)
                  IF bRequestReturnReceipt
                     cHeader += "Disposition-Notification-To: " +::cEmail +CHR(13)+CHR(10)
                  ENDIF

                  cHeader += "MIME-Version: 1.0" +CHR(13)+CHR(10)
                  IF bMultipart .or. ::bHTML
                     cHeader += "Content-Type: multipart/mixed;" +CHR(13)+CHR(10)
                     cHeader += [        boundary="] +cMultipart +["] +CHR(13)+CHR(10)

                     // Empty line
                     cHeader += "" +CHR(13)+CHR(10)
                     cHeader += "This is a multi-part message in MIME format." +CHR(13)+CHR(10)
                     cHeader += "" +CHR(13)+CHR(10)

                     // Message
                     cHeader += "--" +cMultipart +CHR(13)+CHR(10)
                     IF ::bHTML
                        cHeader += "Content-Type: text/html;" +CHR(13)+CHR(10)
                     ELSE
                        cHeader += "Content-Type: text/plain;" +CHR(13)+CHR(10)
                        cHeader += [        charset="iso-8859-1"] +CHR(13)+CHR(10)
                     ENDIF
                     cHeader += "Content-Transfer-Encoding: base64" +CHR(13)+CHR(10)
                     cHeader += "" +CHR(13)+CHR(10)
                     cHeader += oDecode:Encode64( ::cData ) +CHR(13)+CHR(10)
                     cHeader += "" +CHR(13)+CHR(10)

                     // Attach
                     FOR nPos := 1 to len(::aAttach)
                        cHeader += "--" +cMultipart +CHR(13)+CHR(10)
                        cHeader += "Content-Type: application/octet-stream;" +CHR(13)+CHR(10)
                        cHeader += [        name="] +cFileWithoutPath(::aAttach[nPos]) +["] +CHR(13)+CHR(10)
                        cHeader += "Content-Transfer-Encoding: base64" +CHR(13)+CHR(10)
                        cHeader += "Content-Disposition: attachment;" +CHR(13)+CHR(10)
                        cHeader += [        filename="] +cFileWithoutPath(::aAttach[nPos]) +["] +CHR(13)+CHR(10)
                        cHeader += "" +CHR(13)+CHR(10)
                        cHeader += oDecode:Encode64( memoread(::aAttach[nPos]), 57 ) +CHR(13)+CHR(10)
                        cHeader += "" +CHR(13)+CHR(10)
                     NEXT

                     // End of mail
                     cHeader += "--" +cMultipart +"--"
                  ELSE
                     cHeader += "Content-Type: text/plain; charset=us-ascii" +CHR(13)+CHR(10)
                     cHeader += "Content-Transfer-Encoding: 7bit" +CHR(13)+CHR(10)

                     // Empty line
                     cHeader += "" +CHR(13)+CHR(10)

                     // Data
                     cHeader += ::cData
                  ENDIF

                  // End of mail
                  cHeader += CHR(13)+CHR(10) +"." +CHR(13)+CHR(10)

                  IF ::oSocket:SendString( cHeader )
                     cErr := ::GetLines()
                     IF !(LEFT(cErr,3)=="250" .or. LEFT(cErr,3)=="550")
                        ::cError := cErr
                     ELSE
                        bRet := .t.
                     ENDIF
                  ENDIF
               ELSE
                  ::cError := cErr
               ENDIF
            ENDIF
         ENDIF
      ELSE
         ::cError := cErr
      ENDIF

   ENDIF

   RETURN bRet

   * ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

STATIC FUNCTION addAddress( aEmail, cTok )

   * ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL cRet := ""

   IF len( aEmail ) > 0
      cRet += cTok
      AEVAL( aEmail, {|aSub, nPos| cRet += if( nPos==1, "", ","+CHR(13)+CHR(10)+"   " ) + aSub[2]} )
      cRet += CHR(13)+CHR(10)
   ENDIF

   RETURN cRet

   * ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

FUNCTION GETTIMEZONEDIFF()

   * ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL cBias := "", cHour, cMin
   LOCAL nBias := GetTimeZoneBias() * (-1)

   IF nBias <= 0
      cBias := "-"
      nBias := nBias * (-1)
   ELSE
      cBias := "+"
   ENDIF

   IF nBias == 0
      cBias += "0000"
   ELSE
      cHour := PADL(INT(nBias / 60), 2, "0" )
      cMin  := PADL(INT(nBias % 60), 2, "0" )
      cBias += cHour+cMin
   ENDIF

   RETURN cBias

   * ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

STATIC FUNCTION cFileWithoutPath( cPathMask )

   * ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL n1 := RAt( "\", cPathMask ), n2 := RAt( "/", cPathMask ), n

   n := max( n1, n2 )

   RETURN If( n > 0 .and. n < Len( cPathMask ), ;
      Right( cPathMask, Len( cPathMask ) - n ), ;
      If( ( n := At( ":", cPathMask ) ) > 0, ;
      Right( cPathMask, Len( cPathMask ) - n ), cPathMask ) )

#pragma BEGINDUMP

#include <windows.h>

#include "hbapi.h"
#include "hbapiitm.h"
#include "hbapifs.h"

#if !defined( __XHARBOUR__ )
#ifndef HB_LEGACY_LEVEL
#define FHANDLE HB_FHANDLE
#endif
#endif

HB_FUNC( GETTIMEZONEBIAS )
{
      TIME_ZONE_INFORMATION tzInfo;
      DWORD retval = GetTimeZoneInformation( &tzInfo );

      if( retval == TIME_ZONE_ID_INVALID )
         hb_retnl( 0 );
      else
         hb_retnl( tzInfo.Bias + ( retval == TIME_ZONE_ID_STANDARD ? tzInfo.StandardBias : tzInfo.DaylightBias ) );
}

HB_FUNC_STATIC( MEMOREAD )
{
   PHB_ITEM pFileName = hb_param( 1, HB_IT_STRING );

   if( pFileName )
   {
      FHANDLE fhnd = hb_fsOpen( hb_itemGetCPtr( pFileName ), FO_READ | FO_SHARED | FO_PRIVATE );

      if( fhnd != FS_ERROR )
      {
         ULONG ulSize = hb_fsSeek( fhnd, 0, FS_END );

         if( ulSize != 0 )
         {
            BYTE * pbyBuffer;

            pbyBuffer = ( BYTE * ) hb_xgrab( ulSize + sizeof( char ) );

            hb_fsSeek( fhnd, 0, FS_SET );
            hb_fsReadLarge( fhnd, pbyBuffer, ulSize );

            hb_retclen_buffer( ( char * ) pbyBuffer, ulSize );
         }
         else
            hb_retc( NULL );

         hb_fsClose( fhnd );
      }
      else
         hb_retc( NULL );
   }
   else
      hb_retc( NULL );
}

#pragma ENDDUMP
