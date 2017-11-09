#include <minigui.ch>

//declare window sql

FUNCTION browseforsqlite

   LOCAL cFileName := ''
   LOCAL cDBName := ''
   LOCAL nSlash := 0
   LOCAL nDot := 0
   LOCAL aTable := {}
   LOCAL i

   sql.tables.deleteallitems()
   cFileName := GetFile ( { { 'SQLite Files', '*.sqlite' }, { 'All Files', '*.*' } }, 'Select an Existing SQLite File' )
   IF len( alltrim( cFileName ) ) > 0
      cDBName := cFileName
      nSlash := rat( '\', cDBName )
      IF nSlash > 0
         cDBName := substr( cDBName, nSlash + 1 )
      ENDIF
      nDot := at( '.', cDBName )
      IF nDot > 0
         cDBName := substr( cDBName, 1, nDot - 1 )
      ENDIF
      oDB1 := Connect2DB( cFileName, .f. )
      IF oDB1 == Nil
         msgstop( 'Not a valid SQLite file.', 'SQLite File Selection' )
         sql.sqlconnection1.value := "DB Not Connected"
         sql.sqlconnection1.fontcolor := { 255, 0, 0 }

         RETURN NIL
      ELSE
         sql.sqlconnection1.value := alltrim( cDBName ) + " is Connected!"
         sql.sqlconnection1.fontcolor := { 0, 98, 0 }
         aTable := sql( oDB1, "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name" )
         IF len( aTable ) == 0
            msgstop( 'No Tables in the DB', 'DBF<-->SQLite Exporter' )

            RETURN NIL
         ENDIF
         FOR i := 1 to len( aTable )
            sql.tables.additem( aTable[ i, 1 ] )
         NEXT i
         sql.tables.value := 1
      ENDIF
   ELSE
      msgstop( 'You have to select a SQLite File!', 'DBF<-->SQLite Exporter' )

      RETURN NIL
   ENDIF

   RETURN NIL

FUNCTION createnewdbf

   LOCAL cFileName := ''
   LOCAL cDBName := ''
   LOCAL nSlash := 0
   LOCAL nDot := 0

   cFileName := PutFile ( { { 'DBF Files', '*.dbf' }, { 'All Files', '*.*' } }, 'Save to DBF File' )
   IF len( alltrim( cFileName ) ) == 0
      msgstop( 'File name can not be empty!', 'DBF<-->SQLite Exporter' )

      RETURN NIL
   ENDIF
   IF at( '.', cFileName ) == 0
      cFileName := cFileName + '.dbf'
   ENDIF
   cDBName := cFileName
   cNewTable := cFileName
   nSlash := rat( '\', cDBName )
   IF nSlash > 0
      cDBName := substr( cDBName, nSlash + 1 )
   ENDIF
   nDot := at( '.', cDBName )
   IF nDot > 0
      cDBName := substr( cDBName, 1, nDot - 1 )
   ENDIF
   IF file ( cNewTable )
      IF .not. msgyesno( 'File already exists! Do you want to overwrite?', 'DBF<-->SQLite Exporter' )
         sql.newtablename.value := ''
         cNewTable := ''

         RETURN NIL
      ENDIF
   ENDIF
   sql.newtablename.value := 'Save Table to ' + cDBName

   RETURN NIL

FUNCTION export2dbf

   LOCAL aTable := {}
   LOCAL aTable1 := {}
   LOCAL cSQLTable := {}
   LOCAL aStruct := {}
   LOCAL cType := ''
   LOCAL cFieldName := ''
   LOCAL cFieldType := ''
   LOCAL nFieldLength := ''
   LOCAL nFieldDec := ''
   LOCAL nLength := 0
   LOCAL aRecord := {}
   LOCAL nTotalRows := 0
   LOCAL i, j

   IF len( alltrim( cNewTable ) ) == 0
      msgstop( 'You have to select a DBF to export', 'DBF<-->SQLite Exporter' )

      RETURN NIL
   ENDIF
   IF sql.tables.value > 0
      cSQLTable := sql.tables.item( sql.tables.value )
      aTable := sql( oDB1, 'PRAGMA table_info( ' + c2sql( cSQLTable ) + ')' )
      IF len( aTable ) == 0
         msgstop( 'This is an empty table!' )

         RETURN NIL
      ENDIF
      FOR i := 1 to len( aTable )
         cType := upper( alltrim( aTable[ i, 3 ] ) )
         cFieldName := alltrim( aTable[ i, 2 ] )
         DO CASE
         CASE cType == "INTEGER"
            cFieldType := 'N'
            nFieldLength := 8
            nFieldDec := 0
         CASE cType == "REAL" .or. cType == "FLOAT" .or. cType == "DOUBLE"
            cFieldType := 'N'
            nFieldLength := 14
            nFieldDec := 5
         CASE cType == "DATE" .or. cType == 'DATETIME'
            cFieldType := 'D'
            nFieldLength := 8
            nFieldDec := 0
         CASE cType == "BOOL"
            cFieldType := 'L'
            nFieldLength := 1
            nFieldDec := 0
         OTHERWISE
            cFieldType := 'C'
            nFieldDec := 0
            aTable1 := sql( oDB1, 'select max( length( ' + cFieldName + ' ) ) from ' + c2sql( cSQLTable ) )
            nLength := 0
            IF len( aTable1 ) > 0
               nLength := val( alltrim( aTable1[ 1, 1 ] ) )
            ENDIF
            DO CASE
            CASE nLength == 0
               nFieldLength := 10
            CASE nLength < 256
               nFieldLength := nLength
            OTHERWISE
               nFieldLength := 10
               cFieldType := 'M'
            ENDCASE
         ENDCASE
         aadd( aStruct, { cFieldName, cFieldType, nFieldLength, nFieldDec } )
      NEXT i
      IF len( aStruct ) > 0
         dbcreate( cNewTable, aStruct )
         USE &cNewTable
         IF .not. used()
            msgstop( 'DBF File Creation error!', 'DBF<-->SQLite Exporter' )

            RETURN NIL
         ENDIF
         aTable := sql( oDB1, 'select * from ' + c2sql( cSQLTable ) )
         sql.progress1.value := 0
         sql.progress1.visible := .t.
         sql.status1.value := ""
         sql.status1.visible := .t.
         nTotalRows := len( aTable )
         FOR i := 1 to nTotalRows
            sql.progress1.value := i / nTotalRows * 100
            sql.status1.value := alltrim( str( i ) ) + " of " + alltrim( str( nTotalRows ) ) + " Records processed."
            APPEND BLANK
            aRecord := aTable[ i ]
            FOR j := 1 to len( aRecord )
               cFieldName := Left( aStruct[ j, 1 ], 10 )
               REPLACE &cFieldName with aRecord[ j ]
            NEXT j
         NEXT i
         COMMIT
         sql.status1.value := ""
         sql.progress1.value := 0
         sql.progress1.visible := .f.
         sql.status1.visible := .f.
         msginfo("Successfully exported")
         CLOSE all
         sql.newtablename.value := ''
         cNewTable := ''
      ENDIF
   ELSE
      msgstop( 'You have to select a Table to export!', 'DBF<-->SQLite Exporter' )

      RETURN NIL
   ENDIF

   RETURN NIL

