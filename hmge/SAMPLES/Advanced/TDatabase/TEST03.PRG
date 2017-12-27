/*
* MINIGUI - Harbour Win32 GUI library Demo
* Program : Test03.prg
* Purpose : TData class test showing how to create an index of a database with a progress meter.
*/

#include "hmg.ch"

FUNCTION main

   LOCAL oDB

   SET WINDOW MAIN OFF

   // setup test.dbf
   dbcreate('test',{{'FLD1',"+",8,0}})
   USE test
   WHILE lastrec() < 100000
      APPEND BLANK
   end
   USE

   oDB:=tdata():new(,"test")
   IF oDB:use()
      oDB:createIndex("test",,"fld1",,,.t.,5)
   ENDIF
   oDB:close()

   RETURN NIL
