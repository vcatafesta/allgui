/*
* MINIGUI - Harbour Win32 GUI library
* Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
* http://harbourminigui.googlepages.com/
* Copyright 2003 Alexander S.Kresin <alex@belacy.belgorod.su>
* http://kresin.belgorod.su/
* Copyright 2003-06 Grigory Filatov <gfilatov@inbox.ru>
*/
ANNOUNCE RDDSYS

#include "minigui.ch"
#include "hbclass.ch"

#define PROGRAM 'Atomic Time'
#define VERSION ' version 1.1'
#define COPYRIGHT ' Grigory Filatov, 2003-2006'

STATIC aIcon := { 'ATOMICTIME1', 'ATOMICTIME2' }, nIcon := 1, oldTime, cMessage := "", ;
   aServer := {}, nServer := 1, lAutoSync := .f., lAutoExit := .f., lRefused := .f.

MEMVAR _HMG_IsXPThemed, lEditChanged

DECLARE WINDOW Form_2

PROCEDURE Main( lStartUp )

   LOCAL lWinRun := .F.

   SET CENTURY ON

   SET MULTIPLE OFF

   oldTime := Time()

   IF !Empty(lStartUp) .AND. Upper(Substr(lStartUp, 2)) == "STARTUP" .OR. ;
         !Empty(GETREGVAR( NIL, "Software\Microsoft\Windows\CurrentVersion\Run", "AtomicTime" ))
      lWinRun := .T.
   ENDIF

   PUBLIC _HMG_IsXPThemed := IsXPThemeActive()

   DEFINE WINDOW Form_1          ;
         AT 0,0             ;
         WIDTH 0 HEIGHT 0          ;
         TITLE PROGRAM          ;
         MAIN NOSHOW          ;
         ON INIT GetConfig()       ;
         NOTIFYICON 'ATOMICTIME1'   ;
         NOTIFYTOOLTIP PROGRAM       ;
         ON NOTIFYCLICK SetOptions()   ;
         ON RELEASE SocketExit()

      DEFINE NOTIFY MENU
         ITEM 'Auto&Run'      ACTION ( lWinRun := !lWinRun, ;
            Form_1.Auto_Run.Checked := lWinRun, WinRun(lWinRun) ) ;
            NAME Auto_Run
         SEPARATOR
         ITEM '&Options...'   ACTION SetOptions() DEFAULT
         ITEM 'Correct &Now'   ACTION CorrectTime( GetHostByName( aServer[ nServer ] ) )
         ITEM 'A&bout...'   ACTION ShellAbout( "", PROGRAM + VERSION + CRLF + ;
            "Copyright " + Chr(169) + COPYRIGHT, LoadTrayIcon(GetInstance(), "ATOMICTIME1", 32, 32) )
         SEPARATOR
         ITEM 'E&xit'      ACTION ThisWindow.Release
      END MENU

      Form_1.Auto_Run.Checked := lWinRun

      DEFINE TIMER Timer_1 ;
         INTERVAL 250 ;
         ACTION UpdateNotify()

   END WINDOW

   ACTIVATE WINDOW Form_1

   RETURN

#define HALF_SIZE      173
#define FULL_SIZE      287

STATIC PROCEDURE SetOptions()

   LOCAL lHalf := .t., cCtrl

   PRIVATE lEditChanged := .f.

   IF !IsWindowDefined( Form_2 )

      IF IsControlDefined( Timer_2, Form_1 )
         Form_1.Timer_2.Release
      ENDIF

      DEFINE WINDOW Form_2               ;
            AT 0, 0                  ;
            WIDTH 285               ;
            HEIGHT FULL_SIZE + IF(_HMG_IsXPThemed, 8, 0)   ;
            TITLE PROGRAM               ;
            ICON 'ATOMICTIME1'            ;
            NOMAXIMIZE NOSIZE            ;
            TOPMOST                  ;
            ON INIT ( Form_2.Height := HALF_SIZE +      ;
            IF(_HMG_IsXPThemed, 8, 0),      ;
            Form_2.Button_2.SetFocus,      ;
            cCtrl := Form_2.FocusedControl )   ;
            FONT 'MS Sans Serif'            ;
            SIZE 9

         @ 2, 12 FRAME Frame_1 ;
            CAPTION 'System Time' ;
            WIDTH 258 ;
            HEIGHT 52 OPAQUE

         @ 21, 20 TEXTBOX Text_1 VALUE "" ;
            HEIGHT 20 WIDTH 242 ;
            ON GOTFOCUS Form_2.&(cCtrl).SetFocus

         @ 55, 12 FRAME Frame_2 ;
            CAPTION 'Connect Status' ;
            WIDTH 258 ;
            HEIGHT 52 OPAQUE

         @ 74, 20 TEXTBOX Text_2 VALUE padc( cMessage, 60 ) ;
            HEIGHT 20 WIDTH 242 ;
            ON GOTFOCUS Form_2.&(cCtrl).SetFocus

         @ 114, 12 BUTTON Button_1 ;
            CAPTION "A&bout" ;
            ACTION MsgAbout() ;
            WIDTH 72 HEIGHT 26 ;
            ON GOTFOCUS ( cCtrl := Form_2.FocusedControl )

         @ 114, 89 BUTTON Button_2 ;
            CAPTION "Correct &Now" ;
            ACTION CorrectTime( GetHostByName( aServer[ nServer ] ) ) ;
            WIDTH 72 HEIGHT 26 ;
            ON GOTFOCUS ( cCtrl := Form_2.FocusedControl )

         @ 114, 166 BUTTON Button_3 ;
            CAPTION "&Cancel" ;
            ACTION Form_2.Release ;
            WIDTH 72 HEIGHT 26

         @ 117, 246 BUTTON Button_4 ;
            CAPTION ">>" ;
            ACTION ( IF(lHalf, ;
            (Form_2.Height := FULL_SIZE + IF(_HMG_IsXPThemed, 8, 0), Form_2.Button_4.Caption := "<<"), ;
            (Form_2.Height := HALF_SIZE + IF(_HMG_IsXPThemed, 8, 0), Form_2.Button_4.Caption := ">>")), ;
            lHalf := !lHalf ) ;
            WIDTH 24 HEIGHT 20 ;
            ON GOTFOCUS ( cCtrl := Form_2.FocusedControl )

         @ 152, 1 FRAME Frame_3 WIDTH 278 HEIGHT 6 OPAQUE

         @ 154, 1 LABEL Dummy_11 VALUE " " WIDTH 280 HEIGHT 7

         @ 169, 12 LABEL Label_1 VALUE "Time server" AUTOSIZE

         @ 165, 84 COMBOBOX Combo_1            ;
            WIDTH 185 HEIGHT 140            ;
            ITEMS aServer               ;
            VALUE nServer               ;
            DISPLAYEDIT                  ;
            ON DISPLAYCHANGE ( lEditChanged := .t. )   ;
            ON CHANGE ( lEditChanged := .f.,      ;
            nServer := Form_2.Combo_1.Value,      ;
            SaveParameter("Options", "Server", nServer) ) ;
            ON GOTFOCUS ( cCtrl := "Combo_1" )

         @ 194, 84 BUTTON Button_5 ;
            CAPTION "&Add" ;
            ACTION IF(lEditChanged, AddServer(Form_2.Combo_1.DisplayValue), ) ;
            WIDTH 72 HEIGHT 21 ;
            ON GOTFOCUS ( cCtrl := Form_2.FocusedControl )

         @ 194, 160 BUTTON Button_6 ;
            CAPTION "&Delete" ;
            ACTION DelServer(Form_2.Combo_1.DisplayValue) ;
            WIDTH 72 HEIGHT 21 ;
            ON GOTFOCUS ( cCtrl := Form_2.FocusedControl )

         @ 220, 12 CHECKBOX Check_1            ;
            CAPTION '&Auto sync at program startup'   ;
            WIDTH 200                  ;
            HEIGHT 16                  ;
            VALUE lAutoSync               ;
            ON CHANGE ( lAutoSync := !lAutoSync,   ;
            SaveParameter("Options", "AutoSync", lAutoSync) ) ;
            ON GOTFOCUS ( cCtrl := Form_2.FocusedControl )

         @ 238, 12 CHECKBOX Check_2            ;
            CAPTION '&Exit after time has been synced';
            WIDTH 200                  ;
            HEIGHT 16                  ;
            VALUE lAutoExit               ;
            ON CHANGE ( lAutoExit := !lAutoExit,   ;
            SaveParameter("Options", "AutoExit", lAutoExit) ) ;
            ON GOTFOCUS ( cCtrl := Form_2.FocusedControl )

      END WINDOW

      CENTER WINDOW Form_2

      ACTIVATE WINDOW Form_2

   ELSE

      Form_2.Release

   ENDIF

   RETURN

STATIC PROCEDURE AddServer( cServer )

   LOCAL nItem := Ascan(aServer, cServer)

   lEditChanged := .F.

   IF EMPTY(nItem)
      Aadd(aServer, cServer)
      nServer := Len( aServer )
      Form_2.Combo_1.AddItem( cServer )
      Form_2.Combo_1.Value := nServer
      SaveServer( nServer )
   ENDIF

   RETURN

STATIC PROCEDURE DelServer( cServer )

   LOCAL nItem := Ascan(aServer, cServer)

   IF !EMPTY(nItem)
      IF MsgYesNo("Are you sure to delete this server?", "Confirm", .t.)
         ADel(aServer, nItem)
         Asize(aServer, Len( aServer ) - 1)
         Form_2.Combo_1.DeleteAllItems
         Aeval(aServer, {|e| Form_2.Combo_1.AddItem( e )})
         Form_2.Combo_1.Value := IF(nItem > 1, nItem - 1, 1)
         nServer := Form_2.Combo_1.Value
         SaveServer( 0 )
      ENDIF
   ENDIF

   RETURN

STATIC PROCEDURE SaveServer( n )

   LOCAL cCfgFile := ChangeFileExt( Application.ExeName, ".ini" )
   LOCAL i

   BEGIN INI FILE cCfgFile

      IF EMPTY(n)
         DEL SECTION "Servers"
         FOR i := 1 To Len( aServer )
            SET SECTION "Servers" ENTRY hb_ntos(i) TO aServer[i]
         NEXT
      ELSE
         SET SECTION "Servers" ENTRY hb_ntos(n) TO aServer[n]
      ENDIF

   END INI

   RETURN

STATIC PROCEDURE SaveParameter( cSection, cEntry, uValue )

   LOCAL cCfgFile := ChangeFileExt( Application.ExeName, ".ini" )

   BEGIN INI FILE cCfgFile
      SET SECTION cSection ENTRY cEntry TO uValue
   END INI

   RETURN

STATIC PROCEDURE CorrectTime( cServer )

   LOCAL oSock, cRet, nSec, t1, t2

   IF cServer # "0.0.0.0"

      oSock := TSocket():New()

      cMessage := "Connecting to " + cServer
      Form_1.NotifyTooltip := cMessage

      IF IsWindowDefined( Form_2 )
         Form_2.Text_2.Value := padc( cMessage, 60 )
      ENDIF

      oSock:SetCallBack( "SYSTEMIDLE" )

      IF oSock:Connect( cServer, 37 )

         lRefused := .F.

         cMessage := "Connected to " + cServer
         Form_1.NotifyTooltip := cMessage

         IF IsWindowDefined( Form_2 )
            Form_2.Text_2.Value := padc( cMessage, 60 )
            DO EVENTS
         ENDIF

         t1 := Seconds()

         oSock:SetReceiveTimeout( 10000 )

         cRet := oSock:ReceiveString()

         IF Empty( cRet )
            cMessage := "Refused to " + cServer
         ELSE
            nSec := SOCKET_STR2LONG( cRet )

            t2 := Seconds()

            SOCKET_SETTIME( nSec + Round( t2 - t1 + .1, 0 ) )

            cMessage := "Corrected for " + Ltrim(str(Round(Seconds() - t2, 1))) + " sec"

            Form_1.NotifyTooltip := cMessage
         ENDIF

         IF IsWindowDefined( Form_2 )
            Form_2.Text_2.Value := padc( cMessage, 60 )
         ENDIF

         oSock:Close()

      ELSE

         lRefused := .T.

         Form_1.NotifyIcon := "ATOMICTIME3"

         cMessage := "Refused to " + cServer
         Form_1.NotifyTooltip := cMessage
         IF IsWindowDefined( Form_2 )
            Form_2.Text_2.Value := padc( cMessage, 60 )
         ENDIF

         oSock:Close()

      ENDIF

   ELSE

      lRefused := .T.

      Form_1.NotifyIcon := "ATOMICTIME3"

      cMessage := "Couldn't resolve IP address"
      Form_1.NotifyTooltip := cMessage
      IF IsWindowDefined( Form_2 )
         Form_2.Text_2.Value := padc( cMessage, 60 )
      ENDIF

   ENDIF

   RETURN

PROCEDURE SystemIdle()

   DO EVENTS

   RETURN

STATIC PROCEDURE GetConfig()

   LOCAL cCfgFile := ChangeFileExt( Application.ExeName, ".ini" )
   LOCAL i, cServer := ""

   IF !File( cCfgFile )
      Aadd(aServer, "time.nist.gov")
      Aadd(aServer, "rackety.udel.edu")
      Aadd(aServer, "ntp.ise.canberra.edu.au")
      Aadd(aServer, "ntp.cs.mu.oz.au")
      Aadd(aServer, "ntp.mel.nml.csiro.au")
      Aadd(aServer, "ntp.nml.csiro.au")
      Aadd(aServer, "ntp.per.nml.csiro.au")
      Aadd(aServer, "tick.usask.ca")
      Aadd(aServer, "swisstime.ethz.ch")
      Aadd(aServer, "ntp0.fau.de")
      Aadd(aServer, "ntp1.fau.de")
      Aadd(aServer, "ntp2.fau.de")
      Aadd(aServer, "ntp3.fau.de")
      Aadd(aServer, "ntps1-0.cs.tu-berlin.de")
      Aadd(aServer, "ntps1-1.cs.tu-berlin.de")
      Aadd(aServer, "ntps1-1.rz.uni-osnabrueck.de")
      Aadd(aServer, "ntps1-1.uni-erlangen.de")
      Aadd(aServer, "ntps1-2.uni-erlangen.de")
      Aadd(aServer, "clock.cuhk.edu.hk")
      Aadd(aServer, "tempo.cstv.to.cnr.it")
      Aadd(aServer, "time.ien.it")
      Aadd(aServer, "clock.nc.fukuoka-u.ac.jp")
      Aadd(aServer, "clock.tl.fukuoka-u.ac.jp")
      Aadd(aServer, "cronos.cenam.mx")
      Aadd(aServer, "ntp0.nl.net")
      Aadd(aServer, "ntp1.nl.net")
      Aadd(aServer, "ntp2.nl.net")
      Aadd(aServer, "ntp.certum.pl")
      Aadd(aServer, "vega.cbk.poznan.pl")
      Aadd(aServer, "ntp1.sp.se")
      Aadd(aServer, "ntp2.sp.se")
      Aadd(aServer, "time1.stupi.se")
      Aadd(aServer, "time2.stupi.se")
      Aadd(aServer, "chronos.csr.net")
      Aadd(aServer, "clock.isc.org")
      Aadd(aServer, "clock.via.net")
      Aadd(aServer, "nist1.aol-ca.truetime.com")
      Aadd(aServer, "ntp-cup.external.hp.com")
      Aadd(aServer, "timekeeper.isi.edu")
      Aadd(aServer, "usno.pa-x.dec.com")
      Aadd(aServer, "navobs1.usnogps.navy.mil")
      Aadd(aServer, "navobs2.usnogps.navy.mil")
      Aadd(aServer, "tick.usno.navy.mil")
      Aadd(aServer, "tock.usno.navy.mil")
      Aadd(aServer, "ntp1.connectiv.com")
      Aadd(aServer, "bonehed.lcs.mit.edu")
      Aadd(aServer, "navobs1.wustl.edu")
      Aadd(aServer, "terrapin.csc.ncsu.edu")
      Aadd(aServer, "lerc-dns.lerc.nasa.gov")
      Aadd(aServer, "now.okstate.edu")
      Aadd(aServer, "otc1.psu.edu")
      Aadd(aServer, "wwv.otc.psu.edu")
      Aadd(aServer, "nist1.aol-va.truetime.com")

      BEGIN INI FILE cCfgFile
         SET SECTION "Options" ENTRY "AutoSync" TO lAutoSync
         SET SECTION "Options" ENTRY "AutoExit" TO lAutoExit
         SET SECTION "Options" ENTRY "Server" TO nServer
         FOR i := 1 To Len( aServer )
            SET SECTION "Servers" ENTRY Ltrim(Str(i)) TO aServer[i]
         NEXT
      END INI
   ELSE
      BEGIN INI FILE cCfgFile
         GET lAutoSync SECTION "Options" ENTRY "AutoSync" DEFAULT lAutoSync
         GET lAutoExit SECTION "Options" ENTRY "AutoExit" DEFAULT lAutoExit
         GET nServer SECTION "Options" ENTRY "Server" DEFAULT nServer
         FOR i := 1 To 99
            GET cServer SECTION "Servers" ENTRY Ltrim(Str(i))
            IF !EMPTY(cServer)
               Aadd(aServer, cServer)
            ELSE
               EXIT
            ENDIF
         NEXT
      END INI
      IF Len( aServer ) = 0
         Aadd(aServer, "time.nist.gov")
         Aadd(aServer, "rackety.udel.edu")
         Aadd(aServer, "ntps1-1.uni-erlangen.de")
      ENDIF
   ENDIF

   IF lAutoSync

      CorrectTime( GetHostByName( aServer[ nServer ] ) )

      IF lAutoExit .AND. !lRefused
         DEFINE TIMER Timer_2    ;
            OF Form_1         ;
            INTERVAL 10000    ;
            ACTION Form_1.Release
      ENDIF

   ENDIF

   RETURN

STATIC PROCEDURE UpdateNotify()

   LOCAL dDate := Date(), cTime := Time()

   IF IsWindowDefined( Form_2 ) .AND. oldTime # cTime
      oldTime := cTime
      Form_2.Text_1.Value := padc( cDow(dDate) + " " + cMonth(dDate) + " " + ;
         ltrim(str(Day(dDate))) + cDaySuffix(Day(dDate)) + " "  + ;
         str(Year(dDate)) + "   " + cTime, 55 )
   ENDIF

   IF !lRefused
      nIcon++
      nIcon := IF(nIcon > 2, 1, nIcon)
      Form_1.NotifyIcon := aIcon[ nIcon ]
   ENDIF

   RETURN

STATIC FUNCTION cDaySuffix( nDay )

   RETURN IF(nDay = 1, "st", IF(nDay = 2, "nd", IF(nDay = 3, "rd", "th")))

#define MsgInfo( c, t ) MsgInfo( c, t, , .f. )

STATIC FUNCTION MsgAbout()

   RETURN MsgInfo( padc(PROGRAM + VERSION, 42) + CRLF + ;
      "Copyright " + Chr(169) + COPYRIGHT + CRLF + CRLF + ;
      hb_compiler() + CRLF + ;
      version() + CRLF + ;
      Left(MiniGuiVersion(), 38) + CRLF + CRLF + ;
      padc("This program is Freeware!", 38) + CRLF + ;
      padc("Copying is allowed!", 42), "About" )

STATIC PROCEDURE WinRun( lMode )

   LOCAL cRunName := Upper( GetModuleFileName( GetInstance() ) ) + " /STARTUP", ;
      cRunKey  := "Software\Microsoft\Windows\CurrentVersion\Run", ;
      cRegKey  := GETREGVAR( NIL, cRunKey, "AtomicTime" )

   IF IsWinNT()
      EnablePermissions()
   ENDIF

   IF lMode
      IF Empty(cRegKey) .OR. cRegKey # cRunName
         SETREGVAR( NIL, cRunKey, "AtomicTime", cRunName )
      ENDIF
   ELSE
      DELREGVAR( NIL, cRunKey, "AtomicTime" )
   ENDIF

   RETURN

STATIC FUNCTION GETREGVAR(nKey, cRegKey, cSubKey, uValue)

   LOCAL oReg, cValue

   nKey := IF(nKey == NIL, HKEY_CURRENT_USER, nKey)
   uValue := IF(uValue == NIL, "", uValue)
   oReg := TReg32():Create(nKey, cRegKey)
   cValue := oReg:Get(cSubKey, uValue)
   oReg:Close()

   RETURN cValue

STATIC FUNCTION SETREGVAR(nKey, cRegKey, cSubKey, uValue)

   LOCAL oReg, cValue

   nKey := IF(nKey == NIL, HKEY_CURRENT_USER, nKey)
   uValue := IF(uValue == NIL, "", uValue)
   oReg := TReg32():Create(nKey, cRegKey)
   cValue := oReg:Set(cSubKey, uValue)
   oReg:Close()

   RETURN cValue

STATIC FUNCTION DELREGVAR(nKey, cRegKey, cSubKey)

   LOCAL oReg, nValue

   nKey := IF(nKey == NIL, HKEY_CURRENT_USER, nKey)
   oReg := TReg32():New(nKey, cRegKey)
   nValue := oReg:Delete(cSubKey)
   oReg:Close()

   RETURN nValue

   /*
   * TSocket Class
   * Copyright 2001-2003 Matteo Baccan <baccan@infomedia.it>
   */

   // This procedure are required for startup the windows socket interface
INIT PROCEDURE StartSocket
   SocketInit()

   RETURN

CLASS TSocket

   METHOD New()

   METHOD Connect( cAddress, nPort )
   METHOD Close()

   METHOD SendString( cString )
   METHOD ReceiveString()
   METHOD ReceiveLine()
   METHOD ReceiveChar()

   METHOD GetLocalName()    INLINE SocketLocalName()
   METHOD GetLocalAddress() INLINE SocketLocalAddress()

   METHOD Bind( cAddress, nPort )
   METHOD Listen( nClient )

   METHOD SetReceiveTimeout( nTime )
   METHOD SetSendTimeout( nTime )
   METHOD SetCallBack( cFuncName )

   VAR m_hSocket       HIDDEN
   VAR nSendTimeout    HIDDEN INIT -1
   VAR nReceiveTimeout HIDDEN INIT -1

   ENDCLASS

METHOD New() CLASS TSocket

   LOCAL cSok := Space(10)

   SocketNew( @cSok )
   ::m_hSocket := cSok

   RETURN Self

   // Connect to remore site

METHOD Connect( cAddress, nPort ) CLASS TSocket

   LOCAL cSok := ::m_hSocket
   LOCAL bRet

   bRet := SocketConnect( @cSok, cAddress, nPort, ::nSendTimeout )

   ::m_hSocket := cSok

   RETURN bRet

   // Close socket

METHOD Close() CLASS TSocket

   LOCAL cSok := ::m_hSocket
   LOCAL bRet

   bRet := SocketClose( @cSok )
   ::m_hSocket := cSok

   RETURN bRet

   // Send string to socket

METHOD SendString( cString ) CLASS TSocket

   RETURN SocketSend( ::m_hSocket, cString, ::nSendTimeout )

   // Receive string from socket

METHOD ReceiveString() CLASS TSocket

   LOCAL cRet := ""
   LOCAL cBuf := space(4096)
   LOCAL nRet

   DO WHILE .T.
      nRet := SocketReceive( ::m_hSocket, @cBuf, ::nReceiveTimeout )
      IF nRet<=0
         EXIT
      ENDIF
      cRet += Left( cBuf, nRet )
   ENDDO

   RETURN cRet

   // Receive char from socket

METHOD ReceiveChar() CLASS TSocket

   LOCAL cRet
   LOCAL cBuf := space(1)
   LOCAL nRet

   nRet := SocketReceive( ::m_hSocket, @cBuf, ::nReceiveTimeout )
   cRet := substr( cBuf, 1, nRet )

   RETURN cRet

   // Receive Line from socket

METHOD ReceiveLine() CLASS TSocket

   LOCAL cRet := ""
   LOCAL cBuf := space(1)
   LOCAL nRet

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
      IF nRet<=0
         EXIT
      ENDIF
      cRet += substr( cBuf, 1, nRet )
   ENDDO

   RETURN cRet

   // Bind all address

METHOD Bind( cAddress, nPort ) CLASS TSocket

   LOCAL cSok := space( len( ::m_hSocket ) )
   LOCAL bRet

   bRet := SocketBind( @cSok, cAddress, nPort )

   ::m_hSocket := cSok

   RETURN bRet

   // Listen for client

METHOD Listen( nClient ) CLASS TSocket

   LOCAL cSok := space( len( ::m_hSocket ) )
   LOCAL bRet, oRet

   DEFAULT nClient := 10

   bRet := SocketListen( ::m_hSocket, nClient, @cSok )

   IF bRet
      oRet := TSocket():new()
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

   // Set CallBack Function

METHOD SetCallBack( cFuncName ) CLASS TSocket

   LOCAL cSok := ::m_hSocket

   SocketSetCallback( @cSok, cFuncName )

   ::m_hSocket := cSok

   RETURN NIL

#pragma BEGINDUMP

/*
 * Harbour Project source code:
 * Socket C kernel
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

#include <windows.h>
#include "hbapi.h"
#include "hbapiitm.h"
#include "hbapierr.h"
#include "hbvm.h"

#ifdef __XHARBOUR__
#define HB_STORC( n, x, y ) hb_storc( n, x, y )
#else
#define HB_STORC( n, x, y ) hb_storvc( n, x, y )
#define ISCHAR( n )         HB_ISCHAR( n )
#define ISNIL( n )          HB_ISNIL( n )
#define ISNUM( n )          HB_ISNUM( n )
#endif

typedef struct _HB_SOCKET
{
   SOCKET Socket;
   char *cCallBack;
} HB_SOCKET;

static WSADATA WSAData;
static int     bInit = FALSE;
static BOOL    bCancel = FALSE;

int connectex( HB_SOCKET *s, const struct sockaddr *name, int namelen, long timeout )
{
    // As connect() but with timeout setting
    int   rc = 0;
    ULONG ulB = TRUE; // Set socket to non-blocking mode

    ioctlsocket( s->Socket, FIONBIO, &ulB );
    if( connect( s->Socket, name, namelen ) == SOCKET_ERROR )
    {
       if( WSAGetLastError() == WSAEWOULDBLOCK )
       {
           struct timeval Time;
           fd_set FdSet;

           // now wait for the specified time
           if( s->cCallBack )
           {
              PHB_SYMB pSymTest;

              pSymTest = hb_dynsymSymbol( hb_dynsymGet( s->cCallBack ) );

              while( !bCancel && !rc )
              {

                 hb_vmPushSymbol( pSymTest );
                 hb_vmPushNil();
                 hb_vmDo( 0 );

                 FD_ZERO(&FdSet);
                 FD_SET( s->Socket, &FdSet );
                 Time.tv_sec = Time.tv_usec = 0;
                 rc = select( 0, NULL, &FdSet, 0, &Time );
              }
              bCancel = 0;
           }
           else
           {
              FD_ZERO(&FdSet);
              FD_SET( s->Socket, &FdSet );
              Time.tv_sec  = timeout / 1000L;
              Time.tv_usec = (timeout % 1000) * 1000;
              rc = select(0, NULL, &FdSet, 0, &Time );
           }
       }
    }
    ulB = FALSE; // Restore socket to blocking mode
    ioctlsocket( s->Socket, FIONBIO, &ulB );

    return (rc > 0) ? 0 : SOCKET_ERROR;
}

// If startup fails no other functions are allowed
HB_FUNC( SOCKETINIT )
{
   #define HB_MKWORD( l, h )  ( ( WORD ) ( ( ( BYTE ) ( l ) ) | ( ( ( WORD ) ( ( BYTE ) ( h ) ) ) << 8 ) ) )

   if( WSAStartup( HB_MKWORD(1, 1), &WSAData ) == 0 )
      bInit = TRUE;
}

HB_FUNC( SOCKETEXIT )
{
   if( bInit ) WSACleanup();
}

HB_FUNC( SOCKETCONNECT )
{
   HB_SOCKET s;
   long timeout = (ISNIL(4))? -1 : hb_parnl( 4 );

   memcpy( (char*)&s, hb_parc(1), sizeof(s) );
   s.Socket    = INVALID_SOCKET;

   if( timeout < 0 )
      timeout = 10000;
   if( bInit && ISCHAR( 2 ) && ISNUM( 3 ) )
   {
      int nPort;
      SOCKADDR_IN sockDestinationAddr;
      const char * lpszAsciiDestination;

      lpszAsciiDestination = hb_parc(2);
      nPort = hb_parni(3);

      s.Socket = socket( AF_INET, SOCK_STREAM, 0 );
      if( s.Socket != INVALID_SOCKET )
      {

         /* Determine if the address is in dotted notation */
         ZeroMemory(&sockDestinationAddr, sizeof(sockDestinationAddr));
         sockDestinationAddr.sin_family      = AF_INET;
         sockDestinationAddr.sin_port        = htons((u_short)nPort);
         sockDestinationAddr.sin_addr.s_addr = inet_addr(lpszAsciiDestination);

         /* if the address is not dotted notation, then do a DNS lookup of it */
         if (sockDestinationAddr.sin_addr.s_addr == INADDR_NONE)
         {
            LPHOSTENT lphost;
            lphost = gethostbyname(lpszAsciiDestination);
            if (lphost != NULL)
               sockDestinationAddr.sin_addr.s_addr = ((LPIN_ADDR)lphost->h_addr)->s_addr;
            else
            {
               hb_retl( FALSE );

               return;
            }
         }

         hb_retl( connectex( &s,
                           (SOCKADDR*)&sockDestinationAddr,
                           sizeof(sockDestinationAddr), timeout ) != SOCKET_ERROR );
      }
      else
        {
         hb_retl( FALSE );
        }
   }
   else
     {
      hb_retl( FALSE );
     }

   /* Copy m_hSocket to caller method */
   hb_storclen( (char*)&s, sizeof(s), 1 );
}

HB_FUNC( SOCKETBIND )
{
   HB_SOCKET s;

   s.Socket = INVALID_SOCKET;
   if( bInit && ISCHAR( 2 ) && ISNUM( 3 ) )
   {
      int nPort;
      SOCKADDR_IN sockDestinationAddr;
      const char * lpszAsciiDestination;

      lpszAsciiDestination = hb_parc(2);
      nPort = hb_parni(3);

      s.Socket = socket( AF_INET, SOCK_STREAM, 0 );
      if( s.Socket != INVALID_SOCKET )
      {

         /* Determine if the address is in dotted notation */
         ZeroMemory(&sockDestinationAddr, sizeof(sockDestinationAddr));
         sockDestinationAddr.sin_family      = AF_INET;
         sockDestinationAddr.sin_port        = htons((u_short)nPort);
         sockDestinationAddr.sin_addr.s_addr = inet_addr(lpszAsciiDestination);

         /* if the address is not dotted notation, then do a DNS lookup of it */
         if (sockDestinationAddr.sin_addr.s_addr == INADDR_NONE)
         {
            LPHOSTENT lphost;
            lphost = gethostbyname(lpszAsciiDestination);
            if (lphost != NULL)
               sockDestinationAddr.sin_addr.s_addr = ((LPIN_ADDR)lphost->h_addr)->s_addr;
            else {
               hb_retl( FALSE );

               return;
            }
         }

         hb_retl( bind( s.Socket,
                           (SOCKADDR*)&sockDestinationAddr,
                           sizeof(sockDestinationAddr) ) != SOCKET_ERROR );
      }
      else
         hb_retl( FALSE );
   }
   else
      hb_retl( FALSE );

   /* Copy m_hSocket to caller method */
   hb_storclen( (char*)&s, sizeof(s), 1 );

}

HB_FUNC( SOCKETLISTEN )
{
   SOCKET m_hSocket  = INVALID_SOCKET;
   SOCKET sClient    = INVALID_SOCKET;
   SOCKADDR_IN remote_addr;

   /* Copy m_hSocket from caller method */
   strncpy( (char*)&m_hSocket, hb_parc(1), sizeof(m_hSocket) );

   if( bInit )
   {
      if( m_hSocket != INVALID_SOCKET )
      {
         int nRet = listen(m_hSocket, hb_parni(2) );        // Backlog 10
         if( nRet != SOCKET_ERROR )
         {

            int iAddrLen = sizeof(remote_addr);
            sClient = accept(m_hSocket, (struct sockaddr *) &remote_addr, &iAddrLen);

       // Error?
            if(sClient != SOCKET_ERROR)
            {
               hb_retl( TRUE );
            }
            else
               hb_retl( FALSE );
         }
         else
            hb_retl( FALSE );
      }
      else
         hb_retl( FALSE );
   }
   else
      hb_retl( FALSE );

   /* Copy m_hSocket to caller method */
   strncpy( (char*)hb_parc(3), (char*)&sClient, sizeof(sClient) );
}

HB_FUNC( SOCKETSEND )
{
   HB_SOCKET s;

   s.Socket = INVALID_SOCKET;

   /* Copy m_hSocket from caller method */
   memcpy( (char*)&s, hb_parc(1), sizeof(s) );

   if( bInit && ISCHAR( 2 ) )
   {
      if( s.Socket != INVALID_SOCKET )
         {
         const char *pszBuf = hb_parc(2);
         int nBuf = hb_parclen(2);
         if( ISNUM( 3 ) ){
            int sendtimeout = hb_parni(3);
            if( sendtimeout!=-1 )
               setsockopt( s.Socket, SOL_SOCKET, SO_SNDTIMEO, (char *)&sendtimeout, sizeof(sendtimeout));
         }
         hb_retl( send(s.Socket, pszBuf, nBuf, 0) != SOCKET_ERROR );
      }
      else
         hb_retl( FALSE );
   }
   else
      hb_retl( FALSE );
}

HB_FUNC( SOCKETRECEIVE )
{
   HB_SOCKET s;

   s.Socket = INVALID_SOCKET;

   /* Copy m_hSocket from caller method */
   memcpy( (char*)&s, hb_parc(1), sizeof(s) );

   if( bInit && ISCHAR( 2 ) )
   {
      if( s.Socket != INVALID_SOCKET )
         {
         char *pRead = (char*) hb_parc(2);
         int nLen = hb_parclen(2);
         if( ISNUM( 3 ) ){
            int recvtimeout = hb_parni(3);
            if( recvtimeout!=-1 )
               setsockopt(s.Socket, SOL_SOCKET, SO_RCVTIMEO, (char *)&recvtimeout, sizeof(recvtimeout));
         }
         hb_retnl( recv( s.Socket, pRead, nLen, 0 ) );
      }
      else
         hb_retnl( 0 );
   }
   else
      hb_retnl( 0 );
}

HB_FUNC( SOCKETCLOSE )
{
   HB_SOCKET s;

   /* Copy m_hSocket from caller method */
   memcpy( (char*)&s, hb_parc(1), sizeof(s) );

   if( bInit && s.Socket != INVALID_SOCKET )
   {
      hb_retl( SOCKET_ERROR != closesocket(s.Socket) );
   }
   else
      hb_retl( FALSE );

   s.Socket = INVALID_SOCKET;
   if( s.cCallBack )
      hb_xfree( s.cCallBack );
   s.cCallBack = NULL;

   /* Copy m_hSocket to caller method */
   hb_storclen( (char*)&s, sizeof(s), 1 );
}

HB_FUNC( SOCKETLOCALNAME )
{
   char ac[80];

   if( bInit && gethostname(ac, sizeof(ac)) != SOCKET_ERROR )
   {
      hb_retc( ac );
   }
   else
   {
      hb_retc( "" );
   }
}

HB_FUNC( SOCKETNEW )
{
   HB_SOCKET s;

   s.Socket    = INVALID_SOCKET;
   s.cCallBack = NULL;
   hb_storclen( (char*)&s, sizeof(s), 1 );
}

HB_FUNC( SOCKETSETCANCEL )
{
   bCancel = 1;
}

HB_FUNC( SOCKETSETCALLBACK )
{
   HB_SOCKET s;
   const char * cName = (ISNIL(2))? NULL : hb_parc(2);

   memcpy( (char*)&s, hb_parc(1), sizeof(s) );
   if( cName )
   {
      int nlen = strlen(cName);
      s.cCallBack = (char*) hb_xgrab( nlen+1 );
      memcpy( s.cCallBack,cName,nlen );
      s.cCallBack[nlen] = 0;
   }
   else
      s.cCallBack = NULL;
   hb_storclen( (char*)&s, sizeof(s), 1 );
}

HB_FUNC( SOCKETLOCALADDRESS )
{
   char ac[80];

   if( bInit && gethostname(ac, sizeof(ac)) != SOCKET_ERROR )
   {
      struct hostent *phe = gethostbyname(ac);
      if( phe != 0 )
      {
         int i=0;
         while( phe->h_addr_list[i]!=0 ) i++;

         hb_reta( i );

         for( i=0; phe->h_addr_list[i] != 0; ++i)
         {
            struct in_addr addr;
            memcpy(&addr, phe->h_addr_list[i], sizeof(struct in_addr));
            HB_STORC( inet_ntoa(addr), -1, i+1 );
         }
      }
      else
         hb_reta( 0 );
   }
   else
      hb_reta( 0 );
}

/*
 * EOF Socket C kernel
 */

HB_FUNC( ENABLEPERMISSIONS )

{
   LUID tmpLuid;
   TOKEN_PRIVILEGES tkp, tkpNewButIgnored;
   DWORD lBufferNeeded;
   HANDLE hdlTokenHandle;
   HANDLE hdlProcessHandle = GetCurrentProcess();

   OpenProcessToken(hdlProcessHandle, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, &hdlTokenHandle);

   LookupPrivilegeValue(NULL, "SeSystemEnvironmentPrivilege", &tmpLuid);

   tkp.PrivilegeCount            = 1;
   tkp.Privileges[0].Luid        = tmpLuid;
   tkp.Privileges[0].Attributes  = SE_PRIVILEGE_ENABLED;

   AdjustTokenPrivileges(hdlTokenHandle, FALSE, &tkp, sizeof(tkpNewButIgnored), &tkpNewButIgnored, &lBufferNeeded);
}

#define DATE_1970 2208988800

HB_FUNC ( SOCKET_STR2LONG )
{
   const char * cb = hb_parc ( 1 );
   LONG l = ( LONG ) htonl ( * ( DWORD * ) cb );
   hb_retnl ( l - DATE_1970 );
}

HB_FUNC ( SOCKET_SETTIME )
{
   long lnTime = hb_parnl ( 1 );
   FILETIME FileTime, LocalFileTime;
   SYSTEMTIME SystemTime;
   __int64 Time_Int64;

   Time_Int64 = Int32x32To64( lnTime, 10000000 ) + 116444736000000000;
   FileTime.dwLowDateTime = ( DWORD ) Time_Int64;
   FileTime.dwHighDateTime = Time_Int64 >> 32;
   FileTimeToLocalFileTime ( &FileTime, &LocalFileTime );
   FileTimeToSystemTime ( &LocalFileTime, &SystemTime );
   SetLocalTime ( &SystemTime );
}

HB_FUNC ( GETHOSTBYNAME )
{

   struct hostent * pHost;

   BYTE addr[ 20 ];

   strcpy( ( char * ) addr, "0.0.0.0" );

   pHost = gethostbyname( ( char * ) hb_parc( 1 ) ) ;

   if( pHost )
   {
      wsprintf( ( char * ) addr, "%i.%i.%i.%i",
               ( BYTE ) pHost->h_addr[ 0 ], ( BYTE ) pHost->h_addr[ 1 ],
               ( BYTE ) pHost->h_addr[ 2 ], ( BYTE ) pHost->h_addr[ 3 ] );
   }

   hb_retc( ( char * ) addr );
}

#pragma ENDDUMP
