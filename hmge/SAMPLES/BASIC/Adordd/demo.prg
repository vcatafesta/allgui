/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2002-2007 Roberto Lopez <harbourminigui@gmail.com>
* http://harbourminigui.googlepages.com/
* Based on ADORDD sample included in Harbour distribution
*/

#include "adordd.ch"
#include "minigui.ch"

FUNCTION Main()

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH 640 HEIGHT 480 ;
         TITLE 'MiniGUI AdoRDD Demo' ;
         MAIN NOMAXIMIZE ;
         ON INIT OpenTable() ;
         ON RELEASE CloseTable()

      @ 10,10 BROWSE Browse_1   ;
         WIDTH 610   ;
         HEIGHT 390   ;
         HEADERS { 'First' , 'Last' , 'Birth' , 'Age' } ;
         WIDTHS { 150 , 150 , 100 , 100 } ;
         WORKAREA Table1 ;
         FIELDS { 'Table1->First' , 'Table1->Last' , 'Table1->Birth' , 'Table1->Age' } ;
         JUSTIFY { 0 , 0 , 2 , 1 }

      @ 410,10 BUTTON Button_1 ;
         CAPTION 'Append' ACTION AppendRec()

   END WINDOW

   CENTER WINDOW Form_1

   Form_1.Browse_1.SetFocus

   ACTIVATE WINDOW Form_1

   RETURN NIL

PROCEDURE OpenTable

   LOCAL cDatabase, cTable, cAlias

   IF !IsWinNT() .AND. !CheckODBC()
      MsgStop( 'This Program Runs In Win2000/XP Only!', 'Stop' )
      ReleaseAllWindows()
   ENDIF

   cDatabase := "test2.mdb"
   cTable := "table1"
   cAlias := "table1"

   IF !ADOTableExists( cDatabase, cTable, cAlias )
      CreateTable()
   ENDIF

   USE (cDatabase) VIA "ADORDD" TABLE (cTable) ALIAS (cAlias)

   IF EMPTY( (cAlias)->( LastRec() ) )

      APPEND BLANK
      (cAlias)->First   := "Homer"
      (cAlias)->Last    := "Simpson"
      (cAlias)->Birth   := date() - 45 * 365
      (cAlias)->Age     := 45

      APPEND BLANK
      (cAlias)->First   := "Lara"
      (cAlias)->Last    := "Kroft"
      (cAlias)->Birth   := date() - 32 * 365
      (cAlias)->Age     := 32

   ENDIF

   GO TOP

   RETURN

PROCEDURE CloseTable

   USE

   RETURN

PROCEDURE CreateTable

   DbCreate( "test2.mdb;table1", { { "FIRST",   "C", 10, 0 }, ;
      { "LAST",    "C", 10, 0 }, ;
      { "BIRTH",   "D",  8, 0 }, ;
      { "AGE",     "N",  8, 0 } }, "ADORDD" )

   RETURN

PROCEDURE AppendRec()

   select( "table1" )

   APPEND BLANK
   table1->First   := "Mulder"
   table1->Last    := "Fox"
   table1->Birth   := date() - 54 * 365
   table1->Age     := 54

   Form_1.Browse_1.Value := Recno()
   Form_1.Browse_1.Refresh

   RETURN

FUNCTION ADOTableExists( cDatabase, cTable, cAlias )

   IF !hb_FileExists( cDatabase )

      RETURN .f.
   ENDIF

   IF select( cAlias ) > 0

      RETURN .t.
   ENDIF

   USE (cDatabase) VIA "ADORDD" TABLE (cTable) ALIAS (cAlias)
   IF select( cAlias ) == 0

      RETURN .f.
   ENDIF
   USE

   RETURN .t.

STATIC FUNCTION CheckODBC()

   LOCAL oReg, cKey := ""

   OPEN REGISTRY oReg KEY HKEY_LOCAL_MACHINE ;
      SECTION "Software\Microsoft\DataAccess"

   GET VALUE cKey NAME "Version" OF oReg

   CLOSE REGISTRY oReg

   RETURN !Empty(cKey)
