/*
* $Id: netiot03.prg 16163 2011-01-31 14:49:20Z vszakats $
*/

/*
* Harbour Project source code:
*    demonstration/test code for alternative RDD IO API, RPC and
*    asynchronous data streams in NETIO
* Copyright 2010 Przemyslaw Czerpak <druzus / at / priv.onet.pl>
* www - http://harbour-project.org
*/

/* net:127.0.0.1:2941:topsecret:data/_tst_ */

#define DBSERVER  "127.0.0.1"
#define DBPORT    2941
#define DBPASSWD  "topsecret"
#define DBDIR     "data"
#define DBFILE    "_tst_"

#define DBNAME    "net:" + DBSERVER + ":" + hb_ntos( DBPORT ) + ":" + ;
   DBPASSWD + ":" + DBDIR + "/" + DBFILE

REQUEST DBFCDX

REQUEST HB_DIREXISTS
REQUEST HB_DIRCREATE
REQUEST HB_DATETIME

proc main()

   LOCAL pSockSrv, lExists, nStream1, nStream2, nSec, xData

   SET exclusive off
   rddSetDefault( "DBFCDX" )

   pSockSrv := netio_mtserver( DBPORT,,, /* RPC */ .T., DBPASSWD )
   IF empty( pSockSrv )
      ? "Cannot start NETIO server !!!"
      WAIT "Press any key to exit..."
      QUIT
   ENDIF

   ? "NETIO server activated."
   hb_idleSleep( 0.1 )
   WAIT

   ?
   ? "NETIO_CONNECT():", netio_connect( DBSERVER, DBPORT, , DBPASSWD )
   ?

   netio_procexec( "QOut", "PROCEXEC", "P2", "P3", "P4" )
   netio_funcexec( "QOut", "FUNCEXEC", "P2", "P3", "P4" )
   ? "SERVER TIME:", netio_funcexec( "hb_dateTime" )
   ?
   WAIT

   nStream1 := NETIO_OPENITEMSTREAM( "reg_stream" )
   ? "NETIO_OPENITEMSTREAM:", nStream1
   nStream2 := NETIO_OPENDATASTREAM( "reg_charstream" )
   ? "NETIO_OPENDATASTREAM:", nStream2

   hb_idleSleep( 3 )
   ? "NETIO_GETDATA 1:", hb_valToExp( NETIO_GETDATA( nStream1 ) )
   ? "NETIO_GETDATA 2:", hb_valToExp( NETIO_GETDATA( nStream2 ) )
   nSec := seconds() + 3
   WHILE seconds() < nSec
      xData := NETIO_GETDATA( nStream1 )
      IF !empty( xData )
         ? hb_valToExp( xData )
      ENDIF
      xData := NETIO_GETDATA( nStream2 )
      IF !empty( xData )
         ?? "", hb_valToExp( xData )
      ENDIF
   ENDDO
   WAIT
   ? "NETIO_GETDATA 1:", hb_valToExp( NETIO_GETDATA( nStream1 ) )
   ? "NETIO_GETDATA 2:", hb_valToExp( NETIO_GETDATA( nStream2 ) )
   WAIT

   lExists := netio_funcexec( "HB_DirExists", "./data" )
   ? "Directory './data'", iif( !lExists, "not exists", "exists" )
   IF !lExists
      ? "Creating directory './data' ->", ;
         iif( netio_funcexec( "hb_DirCreate", "./data" ) == -1, "error", "OK" )
   ENDIF

   createdb( DBNAME )
   testdb( DBNAME )
   WAIT

   ?
   ? "table exists:", dbExists( DBNAME )
   WAIT

   ?
   ? "delete table with indexes:", dbDrop( DBNAME )
   ? "table exists:", dbExists( DBNAME )
   WAIT

   ? "NETIO_GETDATA 1:", hb_valToExp( NETIO_GETDATA( nStream1 ) )
   ? "NETIO_GETDATA 2:", hb_valToExp( NETIO_GETDATA( nStream2 ) )
   ? "NETIO_DISCONNECT():", netio_disconnect( DBSERVER, DBPORT )
   ? "NETIO_CLOSESTREAM 1:", NETIO_CLOSESTREAM( nStream1 )
   ? "NETIO_CLOSESTREAM 2:", NETIO_CLOSESTREAM( nStream2 )
   hb_idleSleep( 2 )
   ?
   ? "stopping the server..."
   netio_serverstop( pSockSrv, .t. )

   RETURN

   proc createdb( cName )

      LOCAL n

      dbCreate( cName, {{"F1", "C", 20, 0},;
         {"F2", "M",  4, 0},;
         {"F3", "N", 10, 2},;
         {"F4", "T",  8, 0}} )
      ? "create neterr:", neterr(), hb_osError()
      USE (cName)
      ? "use neterr:", neterr(), hb_osError()
      WHILE lastrec() < 100
         dbAppend()
         n := recno() - 1
         field->F1 := chr( n % 26 + asc( "A" ) ) + " " + time()
         field->F2 := field->F1
         field->F3 := n / 100
         field->F4 := hb_dateTime()
      ENDDO
      INDEX ON field->F1 tag T1
      INDEX ON field->F3 tag T3
      INDEX ON field->F4 tag T4
      CLOSE
      ?

      RETURN

      proc testdb( cName )

         LOCAL i, j

         USE (cName)
         ? "used:", used()
         ? "nterr:", neterr()
         ? "alias:", alias()
         ? "lastrec:", lastrec()
         ? "ordCount:", ordCount()
         FOR i:=1 to ordCount()
            ordSetFocus( i )
            ? i, "name:", ordName(), "key:", ordKey(), "keycount:", ordKeyCount()
         NEXT
         ordSetFocus( 1 )
         dbgotop()
         WHILE !eof()
            IF ! field->F1 == field->F2
               ? "error at record:", recno()
               ? "  ! '" + field->F1 + "' == '" + field->F2 + "'"
            ENDIF
            dbSkip()
         ENDDO
         WAIT
         i := row()
         j := col()
         dbgotop()
         browse()
         setpos( i, j )
         CLOSE

         RETURN

         func reg_stream( pConnSock, nStream )
            ? PROCNAME(), nStream
            hb_threadDetach( hb_threadStart( @rpc_timer(), pConnSock, nStream ) )

            RETURN nStream

            func reg_charstream( pConnSock, nStream )
               ? PROCNAME(), nStream
               hb_threadDetach( hb_threadStart( @rpc_charstream(), pConnSock, nStream ) )

               RETURN nStream

               STATIC func rpc_timer( pConnSock, nStream )

                  WHILE .t.
                     IF !netio_srvSendItem( pConnSock, nStream, time() )
                        ? "CLOSED STREAM:", nStream
                        EXIT
                     ENDIF
                     hb_idleSleep( 1 )
                  ENDDO

                  RETURN NIL

                  STATIC func rpc_charstream( pConnSock, nStream )

                     LOCAL n := 0

                     WHILE .t.
                        IF !netio_srvSendData( pConnSock, nStream, chr( 65 + n ) )
                           ? "CLOSED STREAM:", nStream
                           EXIT
                        ENDIF
                        n := int( ( n + 1 ) % 26 )
                        hb_idleSleep( 0.1 )
                     ENDDO

                     RETURN NIL
