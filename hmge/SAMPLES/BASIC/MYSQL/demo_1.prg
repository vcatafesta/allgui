/*
*   MiniGUI Basic MySql Access Sample.
*   Roberto Lopez <harbourminigui@gmail.com>
*   Based Upon Code Contributed by
*   Humberto Fornazier   <hfornazier@brfree.com.br>
*   Mitja Podgornik      <yamamoto@rocketmail.com>
*/

#include "minigui.ch"

#define MsgInfo( c ) MsgInfo( c, , , .f. )
#define MsgStop( c ) MsgInfo( c, "Error", , .f. )

MEMVAR oServer
MEMVAR cSearch

FUNCTION Main

   PUBLIC oServer   := Nil

   DEFINE WINDOW Win_1 ;
         AT 0,0 ;
         WIDTH 400 ;
         HEIGHT 400 ;
         TITLE 'MySql Basic Sample' ;
         MAIN ;
         ON INIT Connect() ;
         ON RELEASE Disconnect()

      DEFINE MAIN MENU

         DEFINE POPUP 'File'
            MENUITEM 'Prepare Data'      ACTION Prepare_Data()
            SEPARATOR
            ITEM "Exit"         ACTION ThisWindow.Release()
         END POPUP

         DEFINE POPUP 'Query'
            MENUITEM 'Open Query Window'   ACTION ShowQuery()
         END POPUP

      END MENU

   END WINDOW

   Win_1.Center

   ACTIVATE WINDOW Win_1

   RETURN NIL

PROCEDURE Connect

   /*

   Class TMySQLServer:

   - Manages access to a MySQL server and returns an oServer object
   to which you'll send all your queries.

   - Administra el acceso a un servidor MySql y retorna un objeto
   oServer al cual se le enviaran los comandos SQL.

   Method New(cServer, cUser, cPassword):

   - Opens connection to a server, returns a server object.

   - Abre una conexion a un servidor, retorna un objeto servidor.

   Method NetErr():

   - Returns .T. if something went wrong

   - Retorna .T. en caso de error.

   Method Error():

   - Returns textual description of last error.

   - Retorna la descripcion del ultimo error.

   Method SelectDB(cDBName):

   - Which data base I will use for subsequent queries.

   - Selecciona la base de datos que se usara en los siguientes
   consultas.

   */

   // Connect

   oServer := TMySQLServer():New("localhost", "root", "")

   // Check For Error

   IF oServer:NetErr()
      MsgStop(oServer:Error())
      Win_1.Title := 'MySql Basic Sample - Not Connected'
   ELSE

      MsgInfo("Connected")
      Win_1.Title := 'MySql Basic Sample - Connected'

   ENDIF

   RETURN

PROCEDURE Disconnect()

   /*..............................................................................

   Class TMySQLServer - Method Destroy():

   - Closes connection to server.

   - Cierra la conexion con un servidor.

   ..............................................................................*/

   oServer:Destroy()
   Win_1.Title := 'MySql Basic Sample - Not Connected'

   RETURN

PROCEDURE ShowQuery ()

   PRIVATE cSearch := ''

   // Select DataBase - Seleccionar Base de Datos

   oServer:SelectDB( "NAMEBOOK" )

   // Check For Error - Verificar Errores

   IF oServer:NetErr()
      MsgStop( oServer:Error() )
   ENDIF

   DEFINE WINDOW ShowQuery ;
         At 0,0 ;
         Width 640 ;
         Height 480 ;
         Title 'Show Query' ;
         Modal ;
         NoSize

      DEFINE MAIN MENU
         DEFINE POPUP 'Operations'
            MENUITEM 'New Query' Action ( cSearch := AllTrim ( InputBox ( "Enter Search String" , "Query By Name") ) , DoQuery ( cSearch ) )
            MENUITEM 'Append Row' Action AppendRow()
            MENUITEM 'Edit Row' Action EditRow()
            MENUITEM 'Delete Row' Action DeleteRow()
            SEPARATOR
            MENUITEM 'Refresh' Action DoQuery ( cSearch )
         END POPUP
      END MENU

      DEFINE GRID Grid_1
         Row 0
         Col 0
         Width 631
         Height 430
         Headers {'Code','Name'}
         Widths {250,250}
      END GRID

   END WINDOW

   ShowQuery.Center

   ShowQuery.Activate

   RETURN

FUNCTION DoQuery( cSearch )

   /*..............................................................................

   Class TMySQLServer - Method Query(cQuery):

   - Gets a textual query and returns a TMySQLQuery or TMySQLTable
   object.

   - Obtiene una consulta y retorna un objeto TMySQLQuery o
   TMySQLTable

   Class TMySQLQuery:

   - A standard query to an oServer with joins. Every query has a
   GetRow() method which on every call returns a TMySQLRow object
   which, in turn, contains requested fields.
   Query objects convert MySQL answers (which is an array of
   strings) to clipper level types.
   At present time N (with decimals), L, D, and C clipper types
   are supported.

   - Una consulta estandar a un objeto oServer con joins. Cada
   consulta tiene un metodo GetRow(), el cual en cada llamada,
   retorna un objeto TMySQLRow, el que contiene los campos
   requeridos.
   Los objetos Query convierten las respuestas MySql (la cual es
   un array de cadenas) a tipos Clipper.
   Actualmente los tipos N (con decimales), L, D, and C son
   soportados.

   Class TMySQLQuery - Method LastRec() :

   - Number of rows available on answer.

   - Numero de filas disponibles en la respuesta.

   Class TMySQLQuery - Method Skip() :

   - Same as clipper ones.

   - Identico al de Clipper.

   Class TMySQLQuery - Method Destroy():

   - Destroys specified query object.

   - Destruye el objeto Query especificado.

   Class TMySQLQuery - Method GetRow(nRow):

   - Return Row n of answer.

   - Retorna ¤a fila n de una respuesta.

   Class TMySQLRow:

   - Every row returned by a SELECT is converted to a TMySQLRow
   object. This object handles fields and has methods to access
   fields given a field name or position.

   - Cada fila retornada por un SELECT es convertida a un
   objeto TMySQLRow- Este objeto maneja campos y tiene metodos
   para accederlos dado un nombre de campo o una posicion.

   Class TMySQLRow - Method FieldGet(cnField):

   - Same as clipper ones, but FieldGet() and FieldPut() accept a
   string as field identifier, not only a number.

   - Identico al de Clipper, excepto que acepta una cadena de
   caracteres como identificador de campo (no solo un numero).

   ..............................................................................*/

   LOCAL oQuery
   LOCAL oRow
   LOCAL i
   LOCAL aQuery := {}

   cSearch := '"' + cSearch + "%" + '"'

   oQuery := oServer:Query( "Select Code, Name From Names Where Name Like " + cSearch + " Order By Name" )

   IF oQuery:NetErr()
      MsgStop ( oQuery:Error() )

      RETURN ( aQuery )
   ENDIF

   ShowQuery.Grid_1.DeleteAllItems()

   FOR i := 1 To oQuery:LastRec()

      oRow := oQuery:GetRow(i)

      ShowQuery.Grid_1.AddItem ( { Str(oRow:fieldGet(1), 8) , oRow:fieldGet(2) } )

      oQuery:Skip(1)

   NEXT

   oQuery:Destroy()

   RETURN ( aQuery )

PROCEDURE DeleteRow()

   LOCAL oQuery
   LOCAL aGridRow
   LOCAL i
   LOCAL cCode

   i := ShowQuery.Grid_1.Value

   IF i == 0

      RETURN
   ENDIF

   IF MsgYesNo("Are You Sure?", "Delete record")

      aGridRow   := ShowQuery.Grid_1.Item (i)
      cCode      := aGridRow [1]

      oQuery := oServer:Query( "DELETE FROM NAMES WHERE CODE = " + cCode )

      IF oQuery:NetErr()
         MsgStop ( oQuery:Error() )

         RETURN
      ENDIF

      oQuery:Destroy()

      DoQuery ( cSearch )

   ENDIF

   RETURN

PROCEDURE EditRow()

   LOCAL oQuery
   LOCAL oRow
   LOCAL aGridRow
   LOCAL i
   LOCAL aResults
   LOCAL cCode
   LOCAL cName
   LOCAL cEMail

   i := ShowQuery.Grid_1.Value

   IF i == 0

      RETURN
   ENDIF

   aGridRow   := ShowQuery.Grid_1.Item (i)
   cCode      := aGridRow [1]

   oQuery:= oServer:Query( "Select * From NAMES WHERE CODE = " + AllTrim(cCode))

   IF oQuery:NetErr()
      MsgStop(oQuery:Error())

      RETURN
   ELSE

      oRow   := oQuery:GetRow(1)
      cCode   := Alltrim(Str(oRow:fieldGet(1)))
      cName   := AllTrim(oRow:fieldGet(2))
      cEMail   := AllTrim(oRow:fieldGet(3))
      oQuery:Destroy()

      aResults := InputWindow   (;
         'Edit Row'         , ;
         { 'Name:' , 'Email:' }, ;
         { cName , cEmail }   , ;
         { 40 , 40 }         ;
         )

      IF aResults [1] != Nil

         cName   := AllTrim(aResults [1])
         cEMail   := AllTrim(aResults [2])

         oQuery   := oServer:Query( "UPDATE NAMES SET  Name = '"+cName+"' , eMail = '"+cEMail+"' WHERE CODE = " + AllTrim(cCode) )

         IF oQuery:NetErr()
            MsgStop(oQuery:Error())
         ELSE
            DoQuery ( cSearch )
         ENDIF

      ENDIF

   ENDIF

   RETURN

PROCEDURE AppendRow()

   LOCAL oQuery
   LOCAL cQuery
   LOCAL aResults
   LOCAL cName
   LOCAL cEMail

   aResults := InputWindow ( ;
      'Append Row' , ;
      { 'Name:' , 'Email:' } , ;
      { '' , '' } , ;
      { 40 , 40 } ;
      )

   IF aResults [1] != Nil

      cName   := AllTrim(aResults [1])
      cEMail   := AllTrim(aResults [2])

      cQuery := "INSERT INTO NAMES (Name, eMail) VALUES ( '"+AllTrim(cName)+"' , '"+cEmail+ "' ) "

      oQuery   := oServer:Query( cQuery )

      IF oQuery:NetErr()
         MsgStop(oQuery:Error())
      ELSE
         DoQuery ( cName )
      ENDIF

   ENDIF

   RETURN

FUNCTION Prepare_data()

   My_SQL_Database_Create( "NAMEBOOK" )
   My_SQL_Database_Connect( "NAMEBOOK" )
   My_SQL_Table_Create( "NAMES" )
   My_SQL_Table_Insert( "NAMES" )

   RETURN NIL

FUNCTION  My_SQL_Database_Create( cDatabase )

   LOCAL aDatabaseList

   cDatabase:=Lower(cDatabase)

   IF oServer == Nil
      MsgInfo("Not connected to SQL server!")

      RETURN NIL
   ENDIF

   aDatabaseList:= oServer:ListDBs()

   IF oServer:NetErr()
      MsGInfo("Error verifying database list: " + oServer:Error())
      RELEASE WINDOW ALL
   ENDIF

   IF AScan( aDatabaseList, Lower(cDatabase) ) != 0
      MsgINFO( "Database allready exists!")

      RETURN NIL
   ENDIF

   oServer:CreateDatabase( cDatabase )

   IF oServer:NetErr()
      MsGInfo("Error creating database: " + oServer:Error() )
   ENDIF

   RETURN NIL

FUNCTION My_SQL_Database_Connect( cDatabase )

   /*..............................................................................

   Class TMySQLServer - Method ListDBs()

   - Returns an array with list of data bases available.

   - Retorna un array con la lista de bases de datos disponibles.

   Class TMySQLServer - ListTables()

   - Returns an array with list of available tables in current
   database.

   - Retorna un array con la lista de tablas disponibles en la
   base de datos actual.

   ..............................................................................*/

   LOCAL aDatabaseList

   cDatabase:= Lower(cDatabase)
   IF oServer == Nil
      MsgInfo("Not connected to SQL server!")

      RETURN NIL
   ENDIF

   aDatabaseList:= oServer:ListDBs()
   IF oServer:NetErr()
      MsGInfo("Error verifying database list: " + oServer:Error())
      RELEASE WINDOW ALL
   ENDIF

   IF AScan( aDatabaseList, Lower(cDatabase) ) == 0
      MsgINFO( "Database "+cDatabase+" doesn't exist!")

      RETURN NIL
   ENDIF

   oServer:SelectDB( cDatabase )
   IF oServer:NetErr()
      MsgStop("Error connecting to database "+cDatabase+": "+oServer:Error() )
   ENDIF

   RETURN NIL

FUNCTION My_SQL_Table_Create( cTable )

   LOCAL aTableList
   LOCAL cQuery
   LOCAL oQuery

   IF oServer == Nil
      MsgStop("Not connected to SQL Server...")

      RETURN NIL
   ENDIF

   aTableList:= oServer:ListTables()
   IF oServer:NetErr()
      MsgStop("Error getting table list: " + oServer:Error() )

      RETURN NIL
   ENDIF

   IF AScan( aTableList, Lower(cTable) ) != 0
      MsgStop( "Table "+cTable+" allready exists!")

      RETURN NIL
   ENDIF

   cQuery:= "CREATE TABLE "+ cTable+" ( Code SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT ,  Name  VarChar(40) ,  eMail  VarChar(40) , PRIMARY KEY (Code) ) "
   oQuery := oServer:Query( cQuery )
   IF oServer:NetErr()
      MsgStop("Error creating table "+cTable+": "+oServer:Error() )

      RETURN NIL
   ENDIF

   oQuery:Destroy()

   RETURN NIL

FUNCTION My_SQL_Table_Insert( cTable )

   LOCAL oQuery
   LOCAL cQuery
   LOCAL NrReg := 0

   IF ! MsgYesNo( "Import data from NAMES.DBF to table Names(MySql) ?", "Question", , , .f. )

      RETURN NIL
   ENDIF

   IF !File( "NAMES.DBF" )
      MsgStop( "File Names.dbf doesn't exist!" )

      RETURN NIL
   ENDIF

   USE Names Alias Names New
   GO TOP

   DO WHILE !Eof()

      cQuery := "INSERT INTO "+ cTable + " VALUES ( '"+Str(Names->Code,8)+"' , '"+ AllTrim(Names->Name)+"' , '"+Names->Email+ "' ) "
      oQuery := oServer:Query(  cQuery )
      IF oServer:NetErr()
         MsGInfo("Error executing Query "+cQuery+": "+oServer:Error() )
         EXIT
      ENDIF

      oQuery:Destroy()

      NrReg++

      SKIP

   ENDDO

   USE

   MsgInfo( AllTrim(Str(NrReg))+" records added to table "+cTable )

   RETURN NIL
