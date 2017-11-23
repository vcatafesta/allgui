/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2002-2008 Roberto Lopez <harbourminigui@gmail.com>
* http://harbourminigui.googlepages.com/
*/

* Value property selects a record by its number (RecNo())
* Value property returns selected record number (recNo())
* Browse control does not change the active work area
* Browse control does not change the record pointer in any area
* (nor change selection when it changes)
* You can programatically refresh it using refresh method.
* Variables called <MemVar>.<WorkAreaName>.<FieldName> are created for
* validation in browse editing window. You can use it in VALID array.
* Using APPEND clause you can add records to table associated with WORKAREA
* clause. The hotkey to add records is Alt+A.
* Append Clause Can't Be Used With Fields Not Belonging To Browse WorkArea
* Using DELETE clause allows to mark selected record for deletion pressing <Del> key

* Enjoy !

#include "minigui.ch"
#include "Dbstruct.ch"

MEMVAR memvartestcode
MEMVAR memvartestfirst
MEMVAR memvartestlast
MEMVAR memvartestbirth

FUNCTION Main

   SET CENTURY ON
   SET DELETED ON

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH 640 HEIGHT 480 ;
         TITLE 'MiniGUI Browse Demo' ;
         MAIN NOMAXIMIZE ;
         ON INIT OpenTables() ;
         ON RELEASE CloseTables()

      DEFINE MAIN MENU
         POPUP 'File'
            ITEM 'Set Browse Value' ACTION Form_1.Browse_1.Value := 10
            ITEM 'Get Browse Value' ACTION MsgInfo ( Form_1.Browse_1.Value )
            ITEM 'Refresh Browse'   ACTION Form_1.Browse_1.Refresh()
            SEPARATOR
            ITEM 'Exit'             ACTION Form_1.Release()
         END POPUP
         POPUP 'Help'
            ITEM 'About'      ACTION MsgInfo ( "MiniGUI Browse Demo", "About" )
         END POPUP
      END MENU

      DEFINE STATUSBAR
         STATUSITEM 'HMG Power Ready'
         STATUSITEM '<Enter> / Double Click To Edit' WIDTH 200
         STATUSITEM 'Alt+A: Append' WIDTH 110
         STATUSITEM '<Del>: Delete Record' WIDTH 150
      END STATUSBAR

      DEFINE BROWSE Browse_1
         ROW 10
         COL 10
         WIDTH 610
         HEIGHT 390 - GetBorderHeight()
         HEADERS { 'Code' , 'First Name' , 'Last Name', 'Birth Date', 'Married' , 'Biography' }
         WIDTHS { 150 , 150 , 150 , 150 , 150 , 150 }
         WORKAREA Test
         FIELDS { 'Test->Code' , 'Test->First' , 'Test->Last' , 'Test->Birth' , 'Test->Married' , 'Test->Bio' }
         VALUE 1
         LOCK .T.
         ALLOWEDIT .T.
         ALLOWAPPEND .T.
         ALLOWDELETE .T.
         VALID { { || MemVar.Test.Code <= 1000 } , { || ! Empty(MemVar.Test.First) } , ;
            { || ! Empty(MemVar.Test.Last) } , { || Year(MemVar.Test.Birth) >= 1950 } , , }
         VALIDMESSAGES { 'Code Range: 0-1000', 'First Name Cannot Be Empty', 'Last Name Cannot Be Empty', ;
            { |uVal| MsgStop( 'Please verify your input value:' + CRLF + DtoC( uVal) ) }, , }
         READONLY { .F. , .F. , .F. , .F. , .F. , .T. }
      END BROWSE

   END WINDOW

   CENTER WINDOW Form_1

   Form_1.Browse_1.SetFocus()

   ACTIVATE WINDOW Form_1

   RETURN NIL

PROCEDURE OpenTables()

   IF !file("test.dbf")
      CreateTable()
   ENDIF

   USE Test Shared
   INDEX ON field->code to code temporary

   RETURN

PROCEDURE CloseTables()

   USE

   RETURN

PROCEDURE CreateTable

   LOCAL aDbf[6][4], i

   aDbf[1][ DBS_NAME ] := "Code"
   aDbf[1][ DBS_TYPE ] := "Numeric"
   aDbf[1][ DBS_LEN ]  := 10
   aDbf[1][ DBS_DEC ]  := 0
   aDbf[2][ DBS_NAME ] := "First"
   aDbf[2][ DBS_TYPE ] := "Character"
   aDbf[2][ DBS_LEN ]  := 25
   aDbf[2][ DBS_DEC ]  := 0
   aDbf[3][ DBS_NAME ] := "Last"
   aDbf[3][ DBS_TYPE ] := "Character"
   aDbf[3][ DBS_LEN ]  := 25
   aDbf[3][ DBS_DEC ]  := 0
   aDbf[4][ DBS_NAME ] := "Married"
   aDbf[4][ DBS_TYPE ] := "Logical"
   aDbf[4][ DBS_LEN ]  := 1
   aDbf[4][ DBS_DEC ]  := 0
   aDbf[5][ DBS_NAME ] := "Birth"
   aDbf[5][ DBS_TYPE ] := "Date"
   aDbf[5][ DBS_LEN ]  := 8
   aDbf[5][ DBS_DEC ]  := 0
   aDbf[6][ DBS_NAME ] := "Bio"
   aDbf[6][ DBS_TYPE ] := "Memo"
   aDbf[6][ DBS_LEN ]  := 10
   aDbf[6][ DBS_DEC ]  := 0

   DBCREATE("Test", aDbf)

   USE Test

   FOR i:= 1 To 100
      APPEND BLANK
      REPLACE code with i
      REPLACE First With 'First Name '+ Ltrim(Str(i))
      REPLACE Last With 'Last Name '+ Ltrim(Str(i))
      REPLACE Married With ( i/2 == int(i/2) )
      REPLACE birth with date()-Max(10000, Random(20000))+Random(LastRec())
   NEXT i

   USE

   RETURN
