#include <minigui.ch>
#include <dbstruct.ch>

SET Proc To hmgsqlite

MEMVAR oDB, oDB1
MEMVAR cTableName, cNewTable
MEMVAR lOpened

FUNCTION Main

   PUBLIC oDB := nil
   PUBLIC oDB1 := nil
   PRIVATE cTableName := ''
   PRIVATE cNewTable := ''
   PRIVATE lOpened := .f.

   SET NAVIGATION EXTENDED
   SET DATE ital
   SET CENTURY ON

   DEFINE WINDOW sql at 0, 0 width 370 height 290 main title "DBF<-->SQLite Exporter" nosize nomaximize
      DEFINE TAB dbtab at 10, 10 width 350 height 250
         DEFINE PAGE 'DBF -> SQLite'
            DEFINE FRAME dbfframe
               ROW 25
               COL 5
               WIDTH 160
               caption 'DBF to be converted'
               HEIGHT 110
            END FRAME
            DEFINE BUTTON browsedbf
               ROW 50
               COL 10
               WIDTH 150
               caption "Select a DBF File"
               action browsefordbf()
            END BUTTON
            DEFINE LABEL dbfname
               ROW 85
               COL 10
               WIDTH 150
               fontbold .t.
            END LABEL
            DEFINE LABEL dbfconnection
               ROW 110
               COL 10
               WIDTH 150
               value "DBF is not yet connected"
               fontbold .t.
               fontcolor {255,0,0}
            END LABEL
            DEFINE FRAME sqliteframe
               ROW 25
               COL 185
               WIDTH 160
               caption 'Create/Select SQLite DB'
               HEIGHT 110
            END FRAME
            DEFINE BUTTON createfile
               ROW 50
               COL 190
               WIDTH 150
               caption 'Create New...'
               action createadb()
            END BUTTON
            DEFINE BUTTON selectfile
               ROW 80
               COL 190
               WIDTH 150
               caption 'Select Existing...'
               action selectdb()
            END BUTTON
            DEFINE LABEL connection
               ROW 110
               COL 190
               WIDTH 150
               value "DB Not Yet Connected"
               fontbold .t.
               fontcolor {255,0,0}
            END LABEL
            DEFINE BUTTON export
               ROW 140
               COL 150
               WIDTH 50
               caption "Export"
               fontbold .t.
               action export2sql()
            END BUTTON
            define progressbar progress
               ROW 170
               COL 10
               WIDTH 330
            END progressbar
            DEFINE LABEL status
               ROW 200
               COL 10
               WIDTH 200
               value ""
            END LABEL
         END PAGE
         DEFINE PAGE 'SQLite -> DBF'
            DEFINE FRAME sqliteframe1
               ROW 25
               COL 5
               WIDTH 160
               caption 'SQLite to be converted'
               HEIGHT 110
            END FRAME
            DEFINE BUTTON browsesql1
               ROW 50
               COL 10
               WIDTH 150
               caption "Select a SQLite DB"
               action browseforsqlite()
            END BUTTON
            DEFINE LABEL tableslabel
               ROW 85
               COL 10
               WIDTH 50
               value 'Table'
            END LABEL
            DEFINE COMBOBOX tables
               ROW 80
               COL 60
               WIDTH 100
               SORT .t.
            END COMBOBOX
            DEFINE LABEL sqlconnection1
               ROW 110
               COL 10
               WIDTH 150
               value "DB is not yet connected"
               fontbold .t.
               fontcolor {255,0,0}
            END LABEL
            DEFINE FRAME dbfframe1
               ROW 25
               COL 185
               WIDTH 160
               caption 'Enter Table Name'
               HEIGHT 110
            END FRAME
            DEFINE BUTTON newtable
               ROW 50
               COL 190
               WIDTH 150
               action createnewdbf()
               caption 'Save to...'
            END BUTTON
            DEFINE LABEL newtablename
               ROW 85
               COL 190
               WIDTH 150
               value ''
               fontbold .t.
            END LABEL
            DEFINE BUTTON export1
               ROW 140
               COL 150
               WIDTH 50
               caption "Export"
               fontbold .t.
               action export2dbf()
            END BUTTON
            define progressbar progress1
               ROW 170
               COL 10
               WIDTH 330
            END progressbar
            DEFINE LABEL status1
               ROW 200
               COL 10
               WIDTH 200
               value ""
            END LABEL
         END PAGE
      END TAB
   END WINDOW
   on key ESCAPE of sql action sql.release()
   sql.progress.visible := .f.
   sql.status.visible := .f.
   sql.center
   sql.activate

   RETURN NIL

FUNCTION browsefordbf

   LOCAL fname := sql.dbfname.value
   LOCAL structarr := {}
   LOCAL i := 0
   LOCAL nDot := 0
   LOCAL nSlash := 0

   fname := GetFile( { { "DBF Files", "*.dbf" } }, "Select a dbf file" , , .f., .f. )
   sql.dbfname.value := alltrim(fname)
   IF len(alltrim(fname)) > 0
      cTableName := fname
      nSlash := rat( '\', cTableName )
      IF nSlash > 0
         cTableName := substr( cTableName, nSlash + 1 )
      ENDIF
      nDot := at( '.', cTableName )
      IF nDot > 0
         cTableName := substr( cTableName, 1, nDot - 1 )
      ENDIF
      IF file(fname)
         USE &fname
         IF used()
            lOpened := .t.
            sql.dbfconnection.value := alltrim( cTableName ) + ' is Connected'
            sql.dbfconnection.fontcolor := { 0, 98, 0 }
         ELSE
            lOpened := .f.
            sql.dbfconnection.value := 'DBF is not yet connected'
            sql.dbfconnection.fontcolor := { 255, 0, 0 }
         ENDIF
      ELSE
         lOpened := .f.
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION export2sql()

   LOCAL aStruct := {}, cSql, i, mFldNm, mFldtype, mFldLen, mFldDec, mSql
   LOCAL totrec, nrec, nvalues, count1

   IF oDB == nil
      msgstop( "No Connection to SQLite DB! Try to create a new SQLite DB or select an existing SQLite DB", 'DBF->SQLite Exporter' )

      RETURN NIL
   ENDIF

   DO WHILE .not. lOpened
      IF msgyesno("You had not selected a DBF table. Do you want to do now?")
         browsefordbf()
      ELSE

         RETURN NIL
      ENDIF
   ENDDO

   && for i := 1 to sql.tables.itemcount
   && if upper(alltrim(sql.tables.item(i))) == upper(alltrim(cTablename))
   && msgstop("Destination table already exists. Either you can give a new name or select an existing table from the list","DBF2MySQL")
   && sql.newtable.setfocus()
   && return nil
   && endif
   && next i

   aStruct = DbStruct()

   mSql := "CREATE TABLE IF NOT EXISTS "+cTablename+" ("

   FOR i := 1 to len(aStruct)
      mFldNm := aStruct[i, DBS_NAME]
      mFldType := aStruct[i, DBS_TYPE]
      mFldLen := aStruct[i, DBS_LEN]
      mFldDec := aStruct[i, DBS_DEC]

      IF i > 1
         mSql += ", "
      ENDIF
      mSql += alltrim(mFldnm)+" "

      DO CASE
      CASE mFldType = "C"
         mSql += "CHAR("+LTRIM(STR(mFldLen))+")"
      CASE mFldType = "D"
         mSql += "DATE"
      CASE mFldType = "T"
         mSql += "DATETIME"
      CASE mFldType = "N"
         IF mFldDec > 0
            mSql += "FLOAT"
         ELSE
            mSql += "INTEGER"
         ENDIF
      CASE mFldType = "F"
         mSql += "FLOAT"
      CASE mFldType = "I"
         mSql += "INTEGER"
      CASE mFldType = "B"
         mSql += "DOUBLE"
      CASE mFldType = "Y"
         mSql += "FLOAT"
      CASE mFldType = "L"
         mSql += "BOOL"
      CASE mFldType = "M"
         mSql += "TEXT"
      CASE mFldType = "G"
         mSql += "BLOB"
      OTHERWISE
         msginfo("Invalid Field Type: "+mFldType)

         RETURN NIL
      ENDCASE
   NEXT

   mSql += ")"

   //msginfo(mSql)

   IF !miscsql( oDB, mSql )
      msginfo( 'Table Creation Error!', 'DBF2SQLite' )

      RETURN NIL
   ENDIF

   sql.progress.value := 0
   sql.progress.visible := .t.
   sql.status.value := ""
   sql.status.visible := .t.
   totrec := reccount()
   nrec := 1
   GO TOP
   IF !miscsql( oDB, 'begin transaction' )

      RETURN NIL
   ENDIF
   DO WHILE !eof()
      sql.progress.value := nrec/totrec *100
      sql.status.value := alltrim(str(nrec))+" of "+alltrim(str(totrec))+" Records processed."

      mSql := "INSERT INTO "+cTablename+" VALUES "
      msql := msql + "("
      FOR i := 1 to len(aStruct)
         mFldNm := aStruct[i, DBS_NAME]
         IF i > 1
            mSql += ", "
         ENDIF
         mSql += c2sql(&mFldNm)
      NEXT
      mSql += ")"
      IF !miscsql( oDB, mSql)
         msgbox("Problem in Query: "+mSql)

         RETURN NIL
      ENDIF
      nrec := nrec + 1
      SKIP
   ENDDO
   IF !miscsql( oDB, 'end transaction' )

      RETURN NIL
   ENDIF
   sql.status.value := ""
   sql.progress.value := 0
   sql.progress.visible := .f.
   sql.status.visible := .f.
   msginfo("Successfully exported")
   CLOSE all
   lOpened := .f.
   sql.dbfname.value := ''
   sql.dbfconnection.value := "DBF is not yet Connected"
   sql.dbfconnection.fontcolor := { 255, 0, 0 }

   RETURN NIL

FUNCTION selectdb

   LOCAL cFileName := ''
   LOCAL cDBName := ''
   LOCAL nSlash := 0
   LOCAL nDot := 0

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
      oDB := Connect2DB( cFileName, .f. )
      IF oDB == Nil
         msgstop( 'Not a valid SQLite file.', 'SQLite File Selection' )
         sql.connection.value := "DB Not Connected"
         sql.connection.fontcolor := { 255, 0, 0 }

         RETURN NIL
      ELSE
         sql.connection.value := alltrim( cDBName ) + " is Connected!"
         sql.connection.fontcolor := { 0, 98, 0 }
      ENDIF
   ELSE
      msgstop( 'You have to select a SQLite File!', 'DBF2SQLite Exporter' )

      RETURN NIL
   ENDIF

   RETURN NIL

FUNCTION createadb

   LOCAL cFileName := ''
   LOCAL cDBName := ''
   LOCAL nSlash := 0
   LOCAL nDot := 0

   cFileName := PutFile ( { { 'SQLite Files', '*.sqlite' }, { 'All Files', '*.*' } }, 'Create a SQLite File' )
   IF len( alltrim( cFileName ) ) == 0
      msgstop( 'File name can not be empty!', 'DBF2SQLite Exporter' )

      RETURN NIL
   ENDIF
   IF at( '.', cFileName ) == 0
      cFileName := cFileName + '.sqlite'
   ENDIF
   cDBName := cFileName
   nSlash := rat( '\', cDBName )
   IF nSlash > 0
      cDBName := substr( cDBName, nSlash + 1 )
   ENDIF
   nDot := at( '.', cDBName )
   IF nDot > 0
      cDBName := substr( cDBName, 1, nDot - 1 )
   ENDIF
   oDB := Connect2DB( cFileName, .t. )
   IF oDB == Nil
      msgstop( 'Not a valid SQLite file.', 'SQLite File Selection' )
      sql.connection.value := "DB Not Connected"
      sql.connection.fontcolor := { 255, 0, 0 }

      RETURN NIL
   ELSE
      sql.connection.value := cDBName + " is Connected!"
      sql.connection.fontcolor := { 0, 98, 0 }
   ENDIF

   RETURN NIL

#include <sqlite2dbf.prg>
