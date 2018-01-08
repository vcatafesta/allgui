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

#define DBNAME    "net:127.0.0.1:2941:data/tests"
//// if you want test in other terminal then put the server address here.
REQUEST DBFCDX

proc main()

   LOCAL f

   SET exclusive off
   SET DELETED ON
   rddSetDefault( "DBFCDX" )

   hb_inetInit()

   f:=netio_connect()

   createdb( DBNAME )
   testdb( DBNAME )

   RETURN

PROCEDURE createdb( cName )

   LOCAL n

   dbCreate( cName, {{"F1", "C", 20, 0},;
      {"F2", "C",  4, 0},;
      {"F3", "N", 10, 2},;
      {"F4", "D",  8, 0}} )
   USE (cName)
   n:=0
   WHILE n<100
      APPEND BLANK
      n := recno() ////- 1
      REPLACE F1 with chr( 65 + hb_random( 25 )   ) + " " + time()
      REPLACE F2 with  field->F1
      REPLACE f3 with  n / 100
      REPLACE F4 with  date()
   ENDDO
   INDEX ON field->F1 tag T1
   INDEX ON field->F3 tag T3
   INDEX ON field->F4 tag T4
   CLOSE
   /// ?

   RETURN

   proc testdb( cName )
      LOCAL i, j

      USE (cName)
      FOR i:=1 to ordCount()
         ordSetFocus( i )
         ///      ? i, "name:", ordName(), "key:", ordKey(), "keycount:", ordKeyCount()
      NEXT
      ordSetFocus( 1 )
      dbgotop()
      WHILE !eof()
         IF ! field->F1 == field->F2
         ENDIF
         dbSkip()
      ENDDO
      i := row()
      j := col()
      dbgotop()
      browse_gui()
      edit extended workarea tests
      CLOSE
      RETURN

FUNCTION browse_gui ()

   DEFINE WINDOW form_1 at 0,0 width 640 height 480 main title "Netio Client Demo"

      @ 10,10  button button_1 caption "exit" action {|| form_1.release }
      @ 10,200 button button_2 caption "abm" action { || otroabm() }

      @ 50,10  browse browse_1 width 600 height 280 workarea tests edit append delete inplace lock headers {"f1","f2","f3","f4"} fields { "f1" ," f2" ,"f3" ," f4" }

   END WINDOW

   CENTER WINDOW form_1
   ACTIVATE WINDOW form_1

   RETURN NIL

FUNCTION otroabm()

   edit extended workarea tests

   RETURN NIL
