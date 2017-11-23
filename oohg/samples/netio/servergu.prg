/*
* $Id: netiotst.prg 12384 2009-09-01 07:48:44Z druzus $
*/

/*
* Harbour Project source code:
*    demonstration/test code for alternative RDD IO API which uses own
*    very simple TCP/IP file server.
* Copyright 2009 Przemyslaw Czerpak <druzus / at / priv.onet.pl>
* www - http://www.harbour-project.org
*/
#include "oohg.ch"
#define DBNAME    "net:127.0.0.1:2941:data/_tst_"

REQUEST DBFCDX

proc main()

   LOCAL pSockSrv

   SET exclusive off
   rddSetDefault( "DBFCDX" )

   hb_inetInit()
   pSockSrv := netio_mtserver()
   IF empty( pSockSrv )
      msgstop("Cannot start NETIO server !!!")
      QUIT
   ENDIF

   msginfo("NETIO server activated.")
   hb_idleSleep( 0.1 )
   ///   wait "aguanta"
   DO WHILE .t.
      inkey(0.9)
      processmessages()
   ENDDO

   RETURN
