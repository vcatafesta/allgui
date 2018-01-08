/*
*   HMG MySql Access Sample.
*   Code Contributed by ;
*      Mitja Podgornik      <yamamoto@rocketmail.com>
*/

#include "hmg.ch"

PROCEDURE Main()

   PRIVATE oServer:= Nil
   PRIVATE cHostName:= "localhost"
   PRIVATE cUser:= "root"
   PRIVATE cPassWord:= ""
   PRIVATE cDataBase:= "NAMEBOOK"
   PRIVATE lLogin:= .F.

   DEFINE WINDOW Form_1 ;
         AT 5,5 ;
         WIDTH 640 ;
         HEIGHT 480 ;
         TITLE "Harbour + HMG + MySql" ;
         MAIN ;
         NOSIZE ;
         NOMINIMIZE ;
         ON INIT My_SQL_Login() ;
         ON RELEASE My_SQL_Logout()

      DEFINE STATUSBAR
         STATUSITEM " "
      END STATUSBAR

      DEFINE MAIN MENU
         POPUP "Action"
            ITEM "&Connetct to MySql server, create Database 'NAMEBOOK' and table 'NAMES', insert records from 'Names.dbf'" ACTION Prepare_data()
            SEPARATOR
            ITEM "&View/Edit data from MySql" ACTION Grid_edit()
         END POPUP
      END MENU

   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

   RETURN NIL

FUNCTION Grid_edit()

   DEFINE WINDOW Grid_Names ;
         AT 5,5 ;
         WIDTH 440 HEIGHT 460 ;
         TITLE "Names" ;
         NOSYSMENU ;
         FONT "Arial" SIZE 09

      @ 10,10 GRID Grid_1 ;
         WIDTH  415 ;
         HEIGHT 329 ;
         HEADERS {"Code", "Name"} ;
         WIDTHS  {60, 335} ;
         VALUE 1 ;
         ON DBLCLICK Get_Fields(2)

      @ 357,11 LABEL  Label_Search_Generic ;
         VALUE "Search " ;
         WIDTH 70 ;
         HEIGHT 20

      @ 353,85 TEXTBOX cSearch ;
         WIDTH 326 ;
         MAXLENGTH 40 ;
         UPPERCASE  ;
         ON ENTER iif( !Empty(Grid_Names.cSearch.Value), Grid_fill(), Grid_Names.cSearch.SetFocus )

      @ 397,11 BUTTON Bt_New ;
         CAPTION '&New' ;
         ACTION Get_Fields(1)

      @ 397,111 BUTTON Bt_Edit ;
         CAPTION '&Edit' ;
         ACTION Get_Fields(2)

      @ 397,211 BUTTON Bt_Delete ;
         CAPTION '&Delete' ;
         ACTION Delete_Record()

      @ 397,311 BUTTON Bt_exit ;
         CAPTION '&Exit' ;
         ACTION Grid_exit()

   END WINDOW

   Grid_Names.cSearch.Value:= "A"
   Grid_Names.cSearch.SetFocus

   My_SQL_Connect()
   My_SQL_Database_Connect( "NAMEBOOK" )

   Grid_fill()

   CENTER WINDOW Grid_Names
   ACTIVATE WINDOW Grid_Names

   RETURN NIL

FUNCTION Grid_fill()

   LOCAL cSearch:= ' "'+Upper(AllTrim(Grid_Names.cSearch.Value ))+'%" '
   LOCAL nCounter:= 0
   LOCAL oRow:= {}
   LOCAL i:= 0
   LOCAL oQuery:= ""
   LOCAL GridMax:= iif(len(cSearch)== 0,  30, 1000000)

   DELETE ITEM ALL FROM Grid_1 Of Grid_Names

   oQuery := oServer:Query( "Select Code, Name From NAMES WHERE NAME LIKE "+cSearch+" Order By Name" )
   IF oQuery:NetErr()
      MsgInfo("SQL SELECT error: " + oQuery:Error())
      RELEASE WINDOW ALL
      QUIT
   ENDIF

   FOR i := 1 To oQuery:LastRec()
      nCounter++
      IF nCounter ==  GridMax
         EXIT
      ENDIF
      oRow := oQuery:GetRow(i)
      ADD ITEM {  Str(oRow:fieldGet(1), 8), oRow:fieldGet(2) } TO Grid_1 Of Grid_Names
      oQuery:Skip(1)
   NEXT

   oQuery:Destroy()

   Grid_Names.cSearch.SetFocus

   RETURN NIL

FUNCTION Grid_exit()

   Grid_Names.Release

   RETURN NIL

FUNCTION  Get_Fields( status )

   LOCAL pCode:= AllTrim(GetColValue("Grid_1", "Grid_Names", 1 ))
   LOCAL cCode:= ""
   LOCAL cName:= ""
   LOCAL cEMail:= ""
   LOCAL oQuery
   LOCAL oRow:= {}

   IF status == 2
      oQuery:= oServer:Query( "Select * From NAMES WHERE CODE = " + AllTrim(pCode))
      IF oQuery:NetErr()
         MsgInfo("SQL SELECT error: " + oQuery:Error())

         RETURN NIL
      ENDIF
      oRow:= oQuery:GetRow(1)
      cCode:=Alltrim(Str(oRow:fieldGet(1)))
      cName:= AllTrim(oRow:fieldGet(2))
      cEMail:= AllTrim(oRow:fieldGet(3))
      oQuery:Destroy()
   ENDIF

   DEFINE WINDOW Form_4 ;
         AT 0,0 ;
         WIDTH 485 HEIGHT 240 ;
         TITLE iif( status==1 , "Add new record" , "Edit record" )  ;
         NOMAXIMIZE ;
         FONT "Arial" SIZE 09

      @ 20,30 LABEL Label_Code ;
         VALUE "Code" ;
         WIDTH 150 ;
         HEIGHT 35 ;
         BOLD

      @ 55, 30 LABEL Label_Name ;
         VALUE "Name" ;
         WIDTH 120 ;
         HEIGHT 35 ;
         BOLD

      @ 90,30 LABEL Label_eMail ;
         VALUE "e-Mail" ;
         WIDTH 120 ;
         HEIGHT 35 ;
         BOLD

      @ 24,100 TEXTBOX p_Code ;
         VALUE cCode ;
         WIDTH 50 ;
         HEIGHT 25 ;
         ON ENTER iif( !Empty(Form_4.p_Code.Value), Form_4.p_Name.SetFocus, Form_4.p_Code.SetFocus ) ;
         RIGHTALIGN

      @ 59,100 TEXTBOX  p_Name ;
         HEIGHT 25 ;
         VALUE cName ;
         WIDTH 350 ;
         ON ENTER iif( !Empty(Form_4.p_Name.Value),  Form_4.p_eMail.SetFocus, Form_4.p_Name.SetFocus )

      @ 94,100 TEXTBOX  p_eMail ;
         HEIGHT 25 ;
         VALUE cEMail ;
         WIDTH 350 ;
         ON ENTER Form_4.Bt_Confirm.SetFocus

      @ 165,100 BUTTON Bt_Confirm ;
         CAPTION '&Confirm' ;
         ACTION Set_Record( status )

      @ 165,300 BUTTON Bt_Cancel ;
         CAPTION '&Cancel' ;
         ACTION Form_4.Release

   END WINDOW

   Form_4.p_Code.Enabled:= .F.

   CENTER WINDOW Form_4
   ACTIVATE WINDOW Form_4

   RETURN NIL

FUNCTION GetColValue( xObj, xForm, nCol)

   LOCAL nPos:= GetProperty(xForm, xObj, 'Value')
   LOCAL aRet:= GetProperty(xForm, xObj, 'Item', nPos)

   RETURN aRet[nCol]

FUNCTION Set_Record( status )

   LOCAL gCode:= AllTrim(GetColValue("Grid_1", "Grid_Names", 1 ))
   LOCAL cCode:= AllTrim(Form_4.p_Code.Value)
   LOCAL cName:= AllTrim(Form_4.p_Name.Value)
   LOCAL cEMail:= AllTrim(Form_4.p_EMail.Value)
   LOCAL cQuery
   LOCAL oQuery

   IF status == 1
      cQuery := "INSERT INTO NAMES (Name, eMail)  VALUES ( '"+AllTrim(cName)+"' , '"+cEmail+ "' ) "
   ELSE
      cQuery := "UPDATE NAMES SET  Name = '"+cName+"' , eMail = '"+cEMail+"'  WHERE CODE = " + AllTrim(gCode)
   ENDIF

   oQuery:=oServer:Query( cQuery )
   IF oQuery:NetErr()
      MsgInfo("SQL UPDATE/INSERT error: " + oQuery:Error())

      RETURN NIL
   ENDIF

   oQuery:Destroy()

   MsgInfo( iif(status== 1, "Record added", "Record updated") )

   Form_4.Release

   Grid_Names.cSearch.Value:=Left(cName, 1)

   Grid_Names.cSearch.SetFocus

   Grid_fill()

   RETURN NIL

FUNCTION Delete_Record()

   LOCAL gCode:= AllTrim(GetColValue("Grid_1", "Grid_Names", 1 ))
   LOCAL gName:= AllTrim(GetColValue("Grid_1", "Grid_Names", 2 ))
   LOCAL cQuery
   LOCAL oQuery

   IF MsgYesNo( "Delete record: "+ gName+ "??" )
      cQuery:= "DELETE FROM NAMES  WHERE CODE = " + AllTrim(gCode)
      oQuery:=oServer:Query( cQuery )
      IF oQuery:NetErr()
         MsgInfo("SQL DELETE error: " + oQuery:Error())

         RETURN NIL
      ENDIF
      oQuery:Destroy()
      MsgInfo("Record deleted!")
      Grid_fill()
   ENDIF

   RETURN NIL

FUNCTION  My_SQL_Login()

   DEFINE WINDOW Form_0 ;
         AT 0,0 ;
         WIDTH 280 HEIGHT 200 ;
         TITLE 'Login MySql' ;
         NOSYSMENU ;
         FONT "Arial" SIZE 09

      @ 24,30 LABEL Label_HostName ;
         VALUE "HostName/IP" ;
         WIDTH 150 ;
         HEIGHT 35 ;
         BOLD

      @ 59,30 LABEL Label_User ;
         VALUE "User" ;
         WIDTH 120 ;
         HEIGHT 35 ;
         BOLD

      @ 94,30 LABEL Label_Password ;
         VALUE "Password" ;
         WIDTH 120 ;
         HEIGHT 35 ;
         BOLD

      @ 20,120 TEXTBOX p_HostName ;
         HEIGHT 25 ;
         VALUE cHostName ;
         WIDTH 120 ;
         ON ENTER iif( !Empty(Form_0.p_HostName.Value),  Form_0.p_User.SetFocus, Form_0.p_HostName.SetFocus )

      @ 55,120 TEXTBOX  p_User ;
         HEIGHT 25 ;
         VALUE cUser ;
         WIDTH 120 ;
         ON ENTER iif( !Empty(Form_0.p_User.Value), Form_0.p_Password.SetFocus, Form_0.p_user.SetFocus  )

      @ 90,120 TEXTBOX  p_password ;
         VALUE cPassWord ;
         PASSWORD ;
         ON ENTER Form_0.Bt_Login.SetFocus

      @ 130,30 BUTTON Bt_Login ;
         CAPTION '&Login' ;
         ACTION SQL_Connect()

      @ 130,143 BUTTON Bt_Logoff ;
         CAPTION '&Cancel' ;
         ACTION Form_1.Release

   END WINDOW

   CENTER WINDOW Form_0
   ACTIVATE WINDOW Form_0

   RETURN NIL

FUNCTION SQL_Connect()

   cHostName:= AllTrim(  Form_0.p_HostName.Value )
   cUser:= AllTrim( Form_0.p_User.Value )
   cPassWord:= AllTrim( Form_0.p_password.Value )

   oServer := TMySQLServer():New(cHostName, cUser, cPassWord )
   IF oServer:NetErr()
      MsGInfo("Error connecting to SQL server: " + oServer:Error() )
      RELEASE WINDOW ALL
      QUIT
   ENDIF

   MsgInfo("Connection to MySql server completed!")

   lLogin := .T.

   Form_0.Release

   RETURN NIL

FUNCTION Prepare_data()

   My_SQL_Connect()
   My_SQL_Database_Create( "NAMEBOOK" )
   My_SQL_Database_Connect( "NAMEBOOK" )
   My_SQL_Table_Create( "NAMES" )
   My_SQL_Table_Insert( "NAMES" )
   My_SQL_Logout()

   RETURN NIL

FUNCTION  My_SQL_Connect()

   IF oServer != Nil

      RETURN NIL
   ENDIF
   oServer := TMySQLServer():New(cHostName, cUser, cPassWord )
   IF oServer:NetErr()
      MsGInfo("Error connecting to SQL server: " + oServer:Error() )
      RELEASE WINDOW ALL
      QUIT
   ENDIF

   RETURN NIL

FUNCTION  My_SQL_Database_Create( cDatabase )

   LOCAL i:= 0
   LOCAL aDatabaseList:= {}

   cDatabase:=Lower(cDatabase)

   IF oServer == Nil
      MsgInfo("Not connected to SQL server!")

      RETURN NIL
   ENDIF

   aDatabaseList:= oServer:ListDBs()
   IF oServer:NetErr()
      MsGInfo("Error verifying database list: " + oServer:Error())
      RELEASE WINDOW ALL
      QUIT
   ENDIF

   IF AScan( aDatabaseList, Lower(cDatabase) ) != 0
      MsgINFO( "Database allready exists!")

      RETURN NIL
   ENDIF

   oServer:CreateDatabase( cDatabase )
   IF oServer:NetErr()
      MsGInfo("Error creating database: " + oServer:Error() )
      RELEASE WINDOW ALL
      QUIT
   ENDIF

   RETURN NIL

FUNCTION My_SQL_Database_Connect( cDatabase )

   LOCAL i:= 0
   LOCAL aDatabaseList:= {}

   cDatabase:= Lower(cDatabase)
   IF oServer == Nil
      MsgInfo("Not connected to SQL server!")

      RETURN NIL
   ENDIF

   aDatabaseList:= oServer:ListDBs()
   IF oServer:NetErr()
      MsGInfo("Error verifying database list: " + oServer:Error())
      RELEASE WINDOW ALL
      QUIT
   ENDIF

   IF AScan( aDatabaseList, Lower(cDatabase) ) == 0
      MsgINFO( "Database "+cDatabase+" doesn't exist!")

      RETURN NIL
   ENDIF

   oServer:SelectDB( cDatabase )
   IF oServer:NetErr()
      MsGInfo("Error connecting to database "+cDatabase+": "+oServer:Error() )
      RELEASE WINDOW ALL
      QUIT
   ENDIF

   RETURN NIL

FUNCTION My_SQL_Table_Create( cTable )

   LOCAL i:= 0
   LOCAL aTableList:= {}
   LOCAL aStruc:= {}
   LOCAL cQuery

   IF oServer == Nil
      MsgInfo("Not connected to SQL Server...")

      RETURN NIL
   ENDIF

   aTableList:= oServer:ListTables()
   IF oServer:NetErr()
      MsGInfo("Error getting table list: " + oServer:Error() )
      RELEASE WINDOW ALL
      QUIT
   ENDIF

   IF AScan( aTableList, Lower(cTable) ) != 0
      MsgINFO( "Table "+cTable+" allready exists!")

      RETURN NIL
   ENDIF

   cQuery:= "CREATE TABLE "+ cTable+" ( Code SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT ,  Name  VarChar(40) ,  eMail  VarChar(40) , PRIMARY KEY (Code) ) "
   oQuery := oServer:Query( cQuery )
   IF oServer:NetErr()
      MsGInfo("Error creating table "+cTable+": "+oServer:Error() )
      RELEASE WINDOW ALL
      QUIT
   ENDIF

   oQuery:Destroy()

   RETURN NIL

FUNCTION My_SQL_Table_Insert( cTable )

   LOCAL cQuery:= ""
   LOCAL NrReg:= 0

   IF ! MsgYesNo( "Import data from NAMES.DBF to table Names(MySql) ?" )

      RETURN NIL
   ENDIF

   Form_1.StatusBar.Item(1):= "Exporting from Names.DBF to Names(MySql) ..."

   IF !File( "NAMES.DBF" )
      MsgBox( "File Names.dbf doesn't exist!" )

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

   Form_1.StatusBar.Item(1):= " "
   MsgInfo( AllTrim(Str(NrReg))+" records added to table "+cTable)

   RETURN NIL

FUNCTION My_SQL_Logout()

   IF oServer != Nil
      oServer:Destroy()
      oServer := Nil
   ENDIF

   RETURN NIL
