/*
*   MiniSql Basic MySql Access Sample.
*   Roberto Lopez <harbourminigui@gmail.com>
*   To test this sample:
*   - You must link MySql libraries (Compile demo /m).
*      - 'libmysql.dll' must be in the same folder as the program.
*   - 'root' at 'localhost' with no password is assumed.
*   - 'NAMEBOOK' database and 'NAMES' existence is assumed
*     (you may create them using 'demo_1.prg' sample
*     at \minigui\samples\basic\mysql)
*/

#include "MiniGui.ch"
#include "sql.ch"

#define MsgInfo( c ) MsgInfo( c, , , .f. )
#define MsgStop( c ) MsgInfo( c, "Error", , .f. )

STATIC SqlResult, SqlAffectedRows

MEMVAR SqlTrace, cCode

PROCEDURE Main

   SET SQLTRACE OFF

   DEFINE WINDOW Win_1 ;
         AT 0,0 ;
         WIDTH 400 ;
         HEIGHT 400 ;
         TITLE 'MiniSql Basic Sample' ;
         MAIN

      DEFINE MAIN MENU

         DEFINE POPUP 'Query'
            MENUITEM 'Open Query Window'   ACTION ShowQuery()
            SEPARATOR
            ITEM "Exit"         ACTION ThisWindow.Release()
         END POPUP

      END MENU

   END WINDOW

   Win_1.Center

   ACTIVATE WINDOW Win_1

   RETURN

PROCEDURE ShowQuery()

   LOCAL nHandle
   LOCAL i

   * Connect

   nHandle := SqlConnect( 'localhost' , 'root' , '' )

   IF Empty( nHandle )
      MsgStop( "Can't Connect" )

      RETURN
   ENDIF

   * Select DataBase

   IF SqlSelectD( nHandle , 'NAMEBOOK' ) != 0
      MsgStop( "Can't Select Database" )

      RETURN
   ENDIF

   SELECT * FROM NAMES WHERE NAME LIKE "k%"

   IF Len( SqlResult ) == 0
      MsgStop ( "No Results!" )

      RETURN
   ENDIF

   DEFINE WINDOW ShowQuery ;
         At 0,0 ;
         WIDTH 640 ;
         HEIGHT 480 ;
         TITLE 'Show Query Name Like "k%"' ;
         Modal ;
         NOSIZE

      DEFINE MAIN MENU
         DEFINE POPUP 'Operations'
            MENUITEM 'Edit Row' Action EditRow( nHandle )
            MENUITEM 'Delete Row' Action DeleteRow( nHandle )
            SEPARATOR
            MENUITEM 'Refresh' Action UpdateGrid( nHandle )
         END POPUP
      END MENU

      DEFINE GRID Grid_1
         ROW 0
         COL 0
         WIDTH 630
         HEIGHT 430
         Headers {'Code','Name'}
         Widths {250,250}
      END GRID

   END WINDOW

   FOR i := 1 To Len ( SqlResult )
      ShowQuery.Grid_1.AddItem ( { SqlResult [i] [1] , SqlResult [i] [2] } )
   NEXT i

   ShowQuery.Center

   ShowQuery.Activate

   RETURN

PROCEDURE EditRow( nHandle )

   PRIVATE cCode := ShowQuery.Grid_1.Cell (1,1)

   LOCK TABLES NAMES WRITE

   UPDATE NAMES SET Name = "KELLY ROSA" WHERE CODE = "&cCode"

   IF SqlAffectedRows == 1
      MsgInfo ( "Update is successful!" )
      UpdateGrid( nHandle )
   ENDIF

   UNLOCK TABLES

   RETURN

PROCEDURE DeleteRow( nHandle )

   PRIVATE cCode := ShowQuery.Grid_1.Cell (1,1)

   LOCK TABLES NAMES WRITE

   DELETE FROM NAMES WHERE CODE = "&cCode"

   IF SqlAffectedRows == 1
      MsgInfo ( "Removal is successful!" )
      UpdateGrid( nHandle )
   ENDIF

   UNLOCK TABLES

   RETURN

PROCEDURE UpdateGrid( nHandle )

   LOCAL i

   SELECT * FROM NAMES WHERE NAME LIKE "k%"

   ShowQuery.Grid_1.DeleteAllItems()

   FOR i := 1 To Len ( SqlResult )
      ShowQuery.Grid_1.AddItem ( { SqlResult [i] [1] , SqlResult [i] [2] } )
   NEXT i

   RETURN

   * Adding MiniSql Code To The Program (It should be a library, I know :)
#include "minisql.prg"
