/*

MySqlCli - MySQLClient written in Harbour/HMG

(c) 2004 Cristobal Molla <cemese@terra.es>
(c) 2005 Mitja Podgornik <yamamoto@rocketmail.com>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

This application use code from:
-    Harbour (c) The Harbour project team (www.harbour-project.org)
-    HMG Harbour Minigui (c) Roberto Lopez (sourceforge.net/projects/harbourminigui)

March 2005: version 2.0 by Mitja Podgornik

! rewritten in english
! optimized for new Harbour tmysql changes
+ added export/import to/from Dbf
+ dynamic grid fill (only first 1000 records in old version)
+ cosmetic modifications

*/

#include "minigui.ch"

#define PROGRAM "MySqlCli"
#define BSL chr(92)
#define CRLF chr(13)+chr(10)

MEMVAR lConnected
MEMVAR oServer
MEMVAR cServer
MEMVAR cUser
MEMVAR cPaswd

MEMVAR aDatabases
MEMVAR aTables
MEMVAR lTableSelect
MEMVAR lBaseSelect
MEMVAR cBase
MEMVAR cTable

MEMVAR nScope
MEMVAR nFrom

PROCEDURE Main()

   PUBLIC lConnected:= .F.
   PUBLIC oServer:= NIL
   PUBLIC cServer:= "localhost"
   PUBLIC cUser:= "root"
   PUBLIC cPaswd:= ""

   PUBLIC aDatabases:={}
   PUBLIC aTables:={}
   PUBLIC lTableSelect:=.f.
   PUBLIC lBaseSelect:=.f.
   PUBLIC cBase:=""
   PUBLIC cTable:=""

   PUBLIC nScope:=500   // max records for select scope (limit)
   PUBLIC nFrom:=0      // starting pointer for select scope - Don't touch!

   SET DATE german
   SET CENTURY ON
   SET MULTIPLE OFF WARNING

   IF file("MySqlCli.ini")
      BEGIN INI FILE "MySqlCli.ini"
         GET cServer   SECTION "Login" ENTRY "server"
         GET cUser     SECTION "Login" ENTRY "user"
      END INI
   ELSE
      BEGIN INI FILE "MySqlCli.ini"
         SET SECTION "Login" ENTRY "server" TO cServer
         SET SECTION "Login" ENTRY "user"   TO cUser
      END INI
   ENDIF

   DEFINE WINDOW       F_Main              ;
         at          0, 0                ;
         WIDTH       800                 ;
         HEIGHT      600                 ;
         TITLE       PROGRAM             ;
         ICON        "A_ICO_MAIN"        ;
         MAIN                            ;
         NOMAXIMIZE                      ;
         NOSIZE                          ;
         ON INIT     {|| UpdateMain() }  ;
         ON RELEASE Disconnect()

      DEFINE MAIN MENU
         DEFINE POPUP " &File "
            MENUITEM "  &Connect  "                ;
               ACTION { || Connect() }        ;
               name mnuConnect
            MENUITEM "  &Disconnect  "             ;
               ACTION { || Disconnect() }     ;
               name mnuDisconnect
            SEPARATOR
            MENUITEM "  &Export to DBF  "             ;
               ACTION { || SQL2Dbf() }     ;
               name mnusql2dbf
            MENUITEM "  &Import from DBF  "           ;
               ACTION { || Dbf2Sql(.t.) }     ;
               name mnudbf2sql
            SEPARATOR
            MENUITEM "  &Exit  "                   ;
               ACTION F_Main.Release     ;
               name mnuEnd
         END POPUP

         DEFINE POPUP " &Help "
            MENUITEM "About" ;
               ACTION ShellAbout( "", PROGRAM+" v.2.0" + CRLF + "Cristobal Molla, Mitja Podgornik" )
         END POPUP

      END MENU

      DEFINE SPLITBOX
         DEFINE TOOLBAR Tbar_1 ;
               buttonsize 40, 32       ;
               flat                    ;
               righttext

            button tbbConnect                              ;
               CAPTION "Connect"                      ;
               PICTURE "BMP_32_CONNECT"               ;
               ACTION {|| Connect() }

            button tbbDisconnect                           ;
               CAPTION "Disconnect"                   ;
               PICTURE "BMP_32_DISCONNECT"            ;
               ACTION {|| Disconnect() }

            button tbbsql2dbf                              ;
               CAPTION "Export to DBF"                ;
               PICTURE "BMP_32_BASE"                  ;
               ACTION {|| SQL2Dbf() }

            button tbbdbf2sql                              ;
               CAPTION "Import from DBF"              ;
               PICTURE "BMP_32_TABLE"                 ;
               ACTION {|| Dbf2Sql(.t.) }

         END toolbar
      END SPLITBOX

      DEFINE STATUSBAR
         statusitem ""
         statusitem "" width 200
         statusitem ""  icon "ICO_LEDOFF"      width 035
      END STATUSBAR

      DEFINE TREE          TREE_1                     ;
            at           60,10                      ;
            WIDTH        200                        ;
            HEIGHT       460                        ;
            ON CHANGE    {|| TreeChange() }         ;
            nodeimages   { "BMP_16_SERVER" }        ;
            itemimages   { "BMP_16_ITEMOFF", "BMP_16_ITEMON" } ;
            itemids

      END tree

      DEFINE TAB        tabInfo       ;
            at        60, 220       ;
            WIDTH     565           ;
            HEIGHT    460           ;
            VALUE     1

         page "&Structure"
            @ 30, 15 frame  frmTable                ;
               CAPTION "Structure"             ;
               WIDTH   535                     ;
               HEIGHT  415                     ;
               bold

            @ 50, 30 grid        GRD_Table                   ;
               WIDTH        505                        ;
               HEIGHT       380                        ;
               HEADERS      { "Name", "Type",      ;
               "Null", "Key",       ;
               "Default value",     ;
               "Extra" }                ;
               WIDTHS       { 125, 125, 50, 50, 125, 150 } ;
               ON GOTFOCUS  {|| setControl( .T. ) }    ;
               ON LOSTFOCUS {|| setControl( .F. ) }
         END PAGE

         page "&Data"
            @ 30, 15 frame  frmData ;
               CAPTION "Data" ;
               WIDTH   535 ;
               HEIGHT  415 ;
               bold

            @ 50, 30 grid        GRD_Data                   ;
               WIDTH        505                        ;
               HEIGHT       380                        ;
               HEADERS      { "" }                     ;
               WIDTHS       { 100 }                    ;
               ITEMS        { { "" } }                 ;
               VALUE        1                          ;
               ON GOTFOCUS  {|| setControl( .T. ) }    ;
               ON CHANGE {|| AddData(F_Main.GRD_Data.Value), setmessage("Record: "+ntrim(F_Main.GRD_Data.value), 2 ) }    ;
               ON LOSTFOCUS {|| setControl( .F. ) }

         END PAGE
      END TAB
   END WINDOW

   setmessage()
   F_main.tabInfo.Enabled:=.f.
   CENTER WINDOW F_Main
   ACTIVATE WINDOW F_Main

   RETURN

FUNCTION Connect()

   LOCAL nRow, nCol

   IF lConnected

      RETURN NIL
   ENDIF

   nRow:= getProperty( "F_Main", "Row" ) + 200
   nCol:= getProperty( "F_Main", "Col" ) + 230

   DEFINE WINDOW F_Connect ;
         at nRow, nCol ;
         WIDTH  315 ;
         HEIGHT 205 ;
         TITLE  " Connect to MySQL server" ;
         modal ;
         NOSIZE ;
         NOSYSMENU

      @ 10, 10 frame  frm_Data ;
         CAPTION "" ;
         WIDTH   285 ;
         HEIGHT  120 ;
         bold

      @ 34, 20 label lblServer ;
         VALUE "Server" ;
         WIDTH 50 ;
         HEIGHT 21

      @ 64, 20 label lblUser ;
         VALUE "User" ;
         WIDTH 50 ;
         HEIGHT 21

      @ 94, 20 label lblPaswd ;
         VALUE "Password" ;
         WIDTH 55 ;
         HEIGHT 21

      @ 30, 85 textbox txtServer ;
         HEIGHT 21 ;
         VALUE cServer ;
         WIDTH 200 ;
         ON GOTFOCUS {|| setControl( .T. ) }  ;
         ON LOSTFOCUS {|| setControl( .F. ) } ;
         MAXLENGTH 60

      @ 60, 85 textbox txtUser ;
         HEIGHT 21 ;
         VALUE cUser ;
         WIDTH 100 ;
         ON GOTFOCUS {|| setControl( .T. ) }  ;
         ON LOSTFOCUS {|| setControl( .F. ) } ;
         MAXLENGTH 40

      @ 90, 85 textbox txtPaswd ;
         HEIGHT 21 ;
         VALUE cPaswd ;
         WIDTH 100 ;
         password ;
         ON GOTFOCUS {|| setControl( .T. ) } ;
         ON LOSTFOCUS {|| setControl( .F. ) } ;
         MAXLENGTH 40

      @ 140, 225 button btnConnect ;
         CAPTION "&Connect" ;
         ACTION {|| Login() } ;
         WIDTH   70 ;
         HEIGHT  25

   END WINDOW

   ACTIVATE WINDOW F_Connect

   RETURN NIL

FUNCTION Login()

   cServer:=AllTrim(F_Connect.txtServer.Value)
   cUser:=AllTrim(F_Connect.txtUser.Value)
   cPaswd:=AllTrim(F_Connect.txtPaswd.Value)

   IF !Empty( cServer ) .AND. !Empty( cUser )
      setMessage( "Connecting to MySQL server...", 1 )
      oServer:= TMySQLServer():New(cServer, cUser, cPaswd)
      IF !( oServer:NetErr() )
         lConnected := .T.
         F_main.tabInfo.Enabled:=.t.
         UpdateTree()
      ENDIF
      setMessage()
      UpdateMain()
      BEGIN INI FILE "MySqlCli.ini"
         SET SECTION "Login" ENTRY "server" TO cServer
         SET SECTION "Login" ENTRY "user"   TO cUser
      END INI
   ENDIF
   F_connect.release

   RETURN NIL

FUNCTION Disconnect()

   IF lConnected
      oServer:Destroy()
      lConnected := .F.
      F_main.tabinfo.value:=1
      UpdateTree()
      UpdateMain()
      setMessage()
   ENDIF
   F_main.tabInfo.Enabled:=.f.
   lBaseSelect:=.f.
   lTableSelect:=.f.
   F_Main.GRD_Table.DeleteAllItems
   F_Main.GRD_Data.DeleteAllItems

   RETURN NIL

PROCEDURE UpdateTree()

   /*
   Node number format: SBBTT
   where:
   S     node Server         1 - 9
   BB    node DataBases     01 - 99
   TT    item Tables        01 - 99
   */

   LOCAL i                 AS NUMERIC
   LOCAL j                 AS NUMERIC
   LOCAL nNodeBase         AS NUMERIC
   LOCAL nNodeTable        AS NUMERIC

   IF lConnected

      F_Main.TREE_1.DeleteAllItems
      F_Main.TREE_1.AddItem( oServer:cUser + "@" + cServer, 0, 1 )

      aDatabases:= oServer:ListDBs()
      IF oServer:NetErr()
         MsGExclamation("Error verifying database list: " + oServer:Error())

         RETURN
      ENDIF

      FOR i := 1 TO Len( aDatabases )
         nNodeBase := Val( "1" + PadL( i, 2, "0" ) )
         F_Main.TREE_1.AddItem( aDatabases[i], 1, nNodeBase )

         oServer:SelectDb( aDatabases[i] )
         IF oServer:NetErr()
            MsGExclamation("Error connecting to database: " + oServer:Error())

            RETURN
         ENDIF

         aTables:=oServer:ListTables()
         IF oServer:NetErr()
            MsGExclamation("Error verifying tables list: " + oServer:Error())

            RETURN
         ENDIF

         FOR j := 1 TO Len( aTables )
            nNodeTable := Val( nTrim(nNodeBase) + PadL(j, 2, "0") )
            F_Main.TREE_1.AddItem( aTables[j], nNodeBase, nNodeTable )
         NEXT

      NEXT

      F_Main.TREE_1.Expand( 1 )
   ELSE
      doMethod( "F_Main", "TREE_1", "DeleteAllItems" )
   ENDIF

   cBase:=""
   cTable:=""
   lBaseSelect:=.f.
   lTableSelect:=.f.

   RETURN

PROCEDURE UpdateTable()

   LOCAL oQuery         AS OBJECT
   LOCAL i              AS NUMERIC
   LOCAL aFile          AS ARRAY

   F_Main.GRD_Table.DeleteAllItems

   IF lConnected
      setMessage( "SQL Query: DESCRIBE " + Upper( cTable ) + "...", 1)
      oQuery := oServer:Query( "describe " + cTable )
      IF !(oQuery:Neterr())
         oQuery:Gotop()
         F_Main.GRD_Data.DisableUpdate
         FOR i := 1 TO oQuery:LastRec()
            oQuery:GetRow(i)
            aFile := oQuery:aRow
            IF !Empty( aFile[1] )
               F_Main.GRD_Table.addItem( aFile )
            ENDIF
         NEXT
         F_Main.GRD_Data.EnableUpdate
      ENDIF
      oQuery:Destroy()
      setMessage()
   ENDIF

   RETURN

PROCEDURE UpdateData()

   LOCAL oQuery            AS OBJECT
   LOCAL i                 AS NUMERIC
   LOCAL nColumns          AS NUMERIC
   LOCAL aFields           AS ARRAY
   LOCAL aWidths           AS ARRAY
   LOCAL aTypes            AS ARRAY
   LOCAL aLine             AS ARRAY

   nColumns := Len( getProperty( "F_Main", "GRD_Data", "Item", 1 ) )

   setMessage( "SQL Query: SELECT * FROM " + Upper( cTable), 1)
   oQuery := oServer:Query( "select * from " + cTable + " limit "+ntrim(nFrom)+","+ntrim(nScope) )
   IF !(oQuery:Neterr())
      aFields := ARRAY( oQuery:FCount() )
      aWidths := ARRAY( oQuery:FCount() )
      aTypes  := ARRAY( oQuery:FCount() )
      FOR i := 1 TO oQuery:FCount()
         aFields[i]:= oQuery:FieldName(i)
         aTypes[i]:= oQuery:FieldType(i)
         aWidths[i] := iif( oQuery:FieldLen(i) > Len(oQuery:FieldName(i)), ;
            oQuery:FieldLen(i)*14,  Len(oQuery:FieldName(i))*14 )
         aWidths[i] := iif( aWidths[i] > 250, 250, aWidths[i] )
      NEXT
   ELSE

      RETURN
   ENDIF

   DO WHILE nColumns != 0
      F_Main.GRD_Data.DeleteColumn( nColumns )
      nColumns--
   ENDDO

   FOR i := 1 TO oQuery:FCount()
      F_Main.GRD_Data.AddColumn( i, aFields[i], aWidths[i], iif(aTypes[i]=="C", 0, 1) )
   NEXT

   oQuery:GoTop()

   SET DATE ANSI
   F_Main.GRD_Data.DisableUpdate

   FOR i := 1 TO oQuery:LastRec()
      IF (i%100)==0
         do events
         setmessage("Record: "+ntrim(i), 2)
      ENDIF

      oQuery:GetRow(i)

      aLine := oQuery:aRow
      IF !Empty( aLine[1] )
         F_Main.GRD_Data.addItem( ItemChar(aLine, aTypes) )
      ENDIF
   NEXT

   F_Main.GRD_Data.EnableUpdate
   SET DATE german

   oQuery:Destroy()
   setMessage()

   RETURN

FUNCTION ItemChar(aLine, aType)

   LOCAL aRet:={}, i:=0, l:=0

   aRet:=array( len(aLine) )
   l:=len(aRet)
   FOR i:=1 to l
      DO CASE
      CASE aType[i]=="N"
         aRet[i]:=ntrim(aLine[i])
      CASE aType[i]=="D"
         aRet[i]:=dtoc(aLine[i])
      CASE aType[i]=="L"
         aRet[i]:=iif(aLine[i], ".T.", ".F.")
      OTHERWISE
         aRet[i]:=aLine[i]
      ENDCASE
   NEXT

   RETURN aRet

PROCEDURE UpdateMain()

   IF lConnected
      setProperty( "F_Main", "TREE_1", "Enabled", .T. )
      setProperty( "F_Main", "tabInfo", "Enabled", .T. )
      setProperty( "F_Main", "tbbConnect", "Enabled", .F. )
      setProperty( "F_Main", "tbbDisconnect", "Enabled", .T. )
      setProperty( "F_Main", "tbbSQL2Dbf", "Enabled", .T. )
      setProperty( "F_Main", "tbbDbf2SQL", "Enabled", .T. )
      setProperty( "F_Main", "StatusBar", "Icon", 3, "ICO_LEDON" )
      setProperty( "F_Main", "mnuConnect", "Enabled", .F. )
      setProperty( "F_Main", "mnuDisconnect", "Enabled", .T. )
      setProperty( "F_Main", "mnusql2dbf", "Enabled", .T. )
      setProperty( "F_Main", "mnudbf2sql", "Enabled", .T. )
   ELSE
      setProperty( "F_Main", "TREE_1", "Enabled", .F. )
      setProperty( "F_Main", "tabInfo", "Enabled", .F. )
      setProperty( "F_Main", "tbbConnect", "Enabled", .T. )
      setProperty( "F_Main", "tbbDisconnect", "Enabled", .F. )
      setProperty( "F_Main", "tbbSQL2Dbf", "Enabled", .F. )
      setProperty( "F_Main", "tbbDbf2Sql", "Enabled", .F. )
      setProperty( "F_Main", "StatusBar", "Icon", 3, "ICO_LEDOFF" )
      setProperty( "F_Main", "mnuConnect", "Enabled", .T. )
      setProperty( "F_Main", "mnuDisconnect", "Enabled", .F. )
      setProperty( "F_Main", "mnusql2dbf", "Enabled", .F. )
      setProperty( "F_Main", "mnudbf2sql", "Enabled", .F. )
   ENDIF

   RETURN

PROCEDURE TreeChange()

   LOCAL aRecords  AS ARRAY
   LOCAL nItem     AS NUMERIC
   LOCAL oQuery    AS OBJECT

   lTableSelect:=.f.
   lBaseSelect:=.f.
   nItem := getProperty( "F_Main", "TREE_1", "Value" )

   DO CASE
   CASE nItem >= 1 .AND. nItem <= 9
      setMessage( "Databases: " + nTrim(Len(aDatabases)), 1)

   CASE nItem >= 100 .AND. nItem <= 999
      cBase := getProperty( "F_Main", "TREE_1", "Item", nItem )
      oServer:SelectDb( cBase )
      aTables:=oServer:ListTables()
      setMessage( "Tables in database " + Upper( cBase ) + ": " + nTrim(Len(aTables)), 1)
      lBaseSelect:=.t.

   CASE nItem >= 10000 .AND. nItem <= 99999
      cTable := getProperty( "F_Main", "TREE_1", "Item", nItem )
      nItem := Val( SubStr( nTrim(nItem), 1, 3 ) )
      cBase := getProperty( "F_Main", "TREE_1", "Item", nItem )
      oServer:SelectDB( cBase )
      aTables:=oServer:ListTables()
      lBaseSelect:=.t.
      lTableSelect:=.t.

      nFrom:=0

      UpdateTable()
      UpdateData()

      oQuery := oServer:Query( "select count(*) from " + cTable )
      IF !(oQuery:Neterr())
         oQuery:Gotop()
         aRecords := oQuery:aRow()
         setMessage( "Records in table " + Upper( cTable ) + ": " + nTrim(aRecords[1]) ,1)
         oQuery:Destroy()
      ELSE

         RETURN
      ENDIF
   ENDCASE

   RETURN

FUNCTION setControl( lValue )

   IF ValType( lValue ) != "L"
      lValue := .F.
   ENDIF

   IF lValue
      setProperty( thisWindow.Name, this.Name, "BackColor", { 255, 255, 200 } )
   ELSE
      setProperty( thisWindow.Name, this.Name, "BackColor", { 255, 255, 255 } )
   ENDIF

   RETURN NIL

FUNCTION setMessage( cMessage, nItem )

   IF cMessage==Nil
      setProperty( "F_Main", "StatusBar", "Item", 1, " " )
      setProperty( "F_Main", "StatusBar", "Item", 2, " " )
   ELSE
      setProperty( "F_Main", "StatusBar", "Item", nItem, " "+cMessage )
   ENDIF

   RETURN NIL

FUNCTION SQL2Dbf()

   LOCAL nRow              AS NUMERIC
   LOCAL nCol              AS NUMERIC

   LOCAL cFileName:=cTable
   LOCAL cMap:=""

   IF !lTableSelect
      msginfo("No table selected...", PROGRAM)

      RETURN NIL
   ENDIF

   nRow:= getProperty( "F_Main", "Row" ) + 200
   nCol:= getProperty( "F_Main", "Col" ) + 230

   DEFINE WINDOW    F_2Dbf ;
         at        nRow, nCol ;
         WIDTH     360 ;
         HEIGHT    220 ;
         TITLE     " Export to DBF" ;
         modal ;
         NOSIZE

      @ 10, 10 frame  frm_2Dbf ;
         CAPTION "" ;
         WIDTH   335 ;
         HEIGHT  100 ;
         bold

      @ 34, 20 label lblFile ;
         VALUE "Table name:" ;
         WIDTH 70 ;
         HEIGHT 21

      @ 30, 100 textbox txtFile ;
         HEIGHT 21 ;
         VALUE cFileName ;
         WIDTH 200 ;
         ON GOTFOCUS {|| setControl( .T. ) }  ;
         ON LOSTFOCUS {|| setControl( .F. ) } ;
         MAXLENGTH 60

      @ 64, 20 label lblMap ;
         VALUE "Folder:" ;
         WIDTH 70 ;
         HEIGHT 21

      @ 60, 100 textbox txtMap ;
         HEIGHT 21 ;
         VALUE BSL+lower(curdir())+BSL ;
         WIDTH 200 ;
         ON GOTFOCUS {|| setControl( .T. ) } ;
         ON LOSTFOCUS {|| setControl( .F. ) }

      @ 60, 305 button btnFolder ;
         CAPTION "..." ;
         ACTION  {|| (F_2Dbf.txtMap.Value:=GetFolder( "Select folder:" )), F_2Dbf.txtMap.SetFocus } ;
         WIDTH 30 ;
         HEIGHT 21

      @ 120, 275 button btn2Dbf ;
         CAPTION "&Export" ;
         ACTION  {|| copy2dbf(F_2Dbf.txtMap.Value, F_2Dbf.txtFile.Value), F_2Dbf.Release } ;
         WIDTH   70 ;
         HEIGHT  25

      @ 155, 275 button btn2DbfCancel ;
         CAPTION "&Cancel" ;
         ACTION  {|| F_2Dbf.Release } ;
         WIDTH   70 ;
         HEIGHT  25

   END WINDOW

   ACTIVATE WINDOW F_2Dbf

   RETURN NIL

FUNCTION copy2dbf(cFolder, cFile)

   LOCAL cMap:=alltrim(cFolder)
   LOCAL cFilename:=alltrim(cFile)

   LOCAL oQuery, oRow      AS OBJECT
   LOCAL i, j              AS NUMERIC
   LOCAL aStruct           AS ARRAY
   LOCAL aOKType           AS ARRAY
   LOCAL cField:=""

   IF lConnected

      IF right(cMap,1)!=BSL .and. !empty(cMap)
         cMap+=BSL
      ENDIF
      cFileName:=cMap+cFileName
      IF !("."$cFileName)
         cFileName:=cFileName+".dbf"
      ENDIF

      IF file(cFileName)
         IF !msgyesno("File " +cFileName+" allready exists! Overwrite?", PROGRAM)

            RETURN NIL
         ENDIF
      ENDIF

      IF (i:=fcreate(cFileName))>0
         fclose(i)
      ELSE
         msgexclamation("Incorrect Table name...", PROGRAM)

         RETURN NIL
      ENDIF

      setMessage( "Exporting table "+cTable+" in "+cFileName+"...", 1)
      oQuery := oServer:Query( "select * from " + cTable )
      IF !(oQuery:Neterr())

         aStruct := ARRAY( oQuery:FCount() )
         aOKType  := ARRAY( oQuery:FCount() )

         SET DATE ANSI

         FOR i := 1 TO oQuery:FCount()
            IF (oQuery:FieldType(i))$"CNDLM"
               aOKType[i]:=.t.
               aStruct[i]:={ oQuery:FieldName(i), ;
                  oQuery:FieldType(i), ;
                  oQuery:FieldLen(i),  ;
                  oQuery:FieldDec(i)   }
            ELSE
               aOKType[i]:=.f.
               aStruct[i]:={ oQuery:FieldName(i), "C", 1, 0 }
            ENDIF
         NEXT

         SET DATE german

         dbcreate(cFileName, aStruct)

         USE &cFileName alias dbf_ex new

         oQuery:GoTop()
         FOR i:=1 TO oQuery:LastRec()
            IF (i%100)==0
               do events
               setmessage("Record: "+ntrim(i), 2)
            ENDIF
            oRow:=oQuery:GetRow(i)
            APPEND BLANK

            FOR j:=1 TO len(aStruct)
               cField:=rtrim(left(aStruct[j][1],10))
               IF aOKType[j]
                  dbf_ex->&cField:=oRow:FieldGet(j)
               ELSE
                  dbf_ex->&cField:="?"
               ENDIF
            NEXT
         NEXT

         USE
         oQuery:Destroy()
         setMessage(" Table: "+cFileName, 1)
         setmessage("Records: "+ntrim(i-1), 2)
         msginfo("Export finished!", PROGRAM)
      ELSE
         msgexclamation("Error exporting file...", PROGRAM)
      ENDIF
      setMessage()
   ELSE
      msgexclamation("Not connected...", PROGRAM)
   ENDIF

   RETURN NIL

FUNCTION AddData(nPos)

   LOCAL oQuery            AS OBJECT
   LOCAL i                 AS NUMERIC
   LOCAL aTypes            AS ARRAY
   LOCAL aLine             AS ARRAY

   IF lConnected .and. lTableSelect .and. nPos==F_Main.GRD_Data.Itemcount

      nFrom:=nFrom+nScope

      setMessage( "SQL Query: SELECT * FROM " + Upper( cTable), 1)
      oQuery := oServer:Query( "select * from " + cTable + " limit "+ntrim(nFrom)+","+ntrim(nScope) )
      if(oQuery:Neterr())
      aTypes  := ARRAY( oQuery:FCount() )
      FOR i:= 1 TO oQuery:FCount()
         aTypes[i]:= oQuery:FieldType(i)
      NEXT
   ELSE
      nFrom:=0

      RETURN NIL
   ENDIF

   oQuery:GoTop()

   SET DATE ANSI
   F_Main.GRD_Data.DisableUpdate

   FOR i := 1 TO oQuery:LastRec()
      IF (i%100)==0
         setmessage("Record: "+ntrim(i), 2)
      ENDIF

      oQuery:GetRow(i)

      aLine := oQuery:aRow
      IF !Empty( aLine[1] )
         F_Main.GRD_Data.addItem( ItemChar(aLine, aTypes) )
      ENDIF
   NEXT

   F_Main.GRD_Data.EnableUpdate
   SET DATE german

   oQuery:Destroy()
   setMessage()

   F_Main.GRD_Data.Value:=nPos

ENDIF

RETURN NIL

FUNCTION wgwin( s )

   // 437
   s:=strtran(s,"^",chr(200))
   s:=strtran(s,"~",chr(232))
   s:=strtran(s,"[",chr(138))
   s:=strtran(s,"{",chr(154))
   s:=strtran(s,"@",chr(142))
   s:=strtran(s,"`",chr(158))

   // 852 �
   s:=strtran(s,chr(208),chr(240))
   // 437 �
   s:=strtran(s,"|",chr(240))
   // 437 �
   s:=strtran(s,BSL,chr(208))

   // 852 �
   s:=strtran(s,chr(230),chr(138))
   // 437 �
   s:=strtran(s,"}",chr(230))
   // 852 �
   s:=strtran(s,chr(134),chr(230))

   // 852 �
   s:=strtran(s,chr(143),chr(198))
   // 437 �
   s:=strtran(s,"]",chr(198))

   // 852
   s:=strtran(s,chr(172),chr(200))
   s:=strtran(s,chr(159),chr(232))
   s:=strtran(s,chr(231),chr(154))
   s:=strtran(s,chr(166),chr(142))
   s:=strtran(s,chr(167),chr(158))
   s:=strtran(s,chr(209),chr(208))

   // 8859-2
   s:=strtran(s,chr(169),chr(138))
   s:=strtran(s,chr(185),chr(154))
   s:=strtran(s,chr(174),chr(142))
   s:=strtran(s,chr(190),chr(158))

   // navednica (MySql) z dvojnim narekovajem
   s:=strtran(s,"'",'"')

   RETURN s

FUNCTION dbf2sql(lCreateTable )

   LOCAL l, f
   LOCAL fh, cInsert, cQuery, i, cFileName, aDbfFiles, aDbfStruct, lError:=.f., cRec
   LOCAL xField, cField
   LOCAL nRef:=0, nWrite:=500

   IF !lBaseSelect
      msginfo("No dababase selected...", PROGRAM)

      RETURN NIL
   ENDIF

   IF lConnected

      aDbfFiles:=getfile({{"*.dbf", "*.DBF"}}, "Select files to copy", "", .T., .F. )

      IF len(aDbfFiles)==0

         RETURN NIL
      ENDIF

      FOR f:=1 to len(aDbfFiles)

         IF !empty(alias())
            dbffile->(dbCloseArea())
         ENDIF

         l:=len(aDbfFiles[f])
         FOR i:=1 to l-1
            IF substr(aDbfFiles[f],l-i,1)==BSL
               EXIT
            ENDIF
         NEXT

         cFileName:=strtran(lower(right(aDbfFiles[f],i)),".dbf","")

         IF Ascan(aTables, cFileName) > 0
            IF !msgyesno("Table " +cFileName+" allready exists! Overwrite?", PROGRAM)
               lError:=.t.
               EXIT
            ENDIF
         ENDIF

         dbUseArea(.T.,, aDbfFiles[f], "dbffile",, .T.)
         aDbfStruct := dbffile->(dbStruct())

         IF lCreateTable
            IF Ascan(aTables, cFileName) > 0
               oServer:DeleteTable(cFileName)
               IF oServer:NetErr()
                  lError:=.t.
                  MsgExclamation(oServer:Error(), "-1")
                  EXIT
               ENDIF
            ENDIF

            oServer:CreateTable(cFileName, aDbfStruct)
            IF oServer:NetErr()
               lError:=.t.
               MsgExclamation(oServer:Error(), "0")
               EXIT
            ENDIF
         ENDIF

         cRec:="/"+alltrim(str(dbffile->(lastrec())))
         fh:=fcreate("dump.sql")

         IF fh<0
            lError:=.t.
            msgexclamation("Handle create?")
            EXIT
         ENDIF

         cInsert:="INSERT INTO "+cFileName+" VALUES "+CRLF
         fwrite(fh, cInsert)

         DO WHILE !dbffile->(eof())

            cQuery:="("

            FOR i:= 1 to dbffile->(FCount())
               xField:=nil
               xField:=dbffile->(fieldget(i))
               DO CASE
               CASE valtype(xField)=="D"
                  cField:="'"+d2c(xField)+"'"
               CASE valtype(xField)=="C"
                  cField:=alltrim(xField)
                  cField:=wgwin(cField)
                  cField:="'"+cField+"'"
               CASE valtype(xField)=="M"
                  cField:=memotran(alltrim(xField),"", "")
                  cField:=wgwin(cField)
                  cField:="'"+cField+"'"
               CASE valtype(xField)=="N"
                  cField:=SQLTrim(xField,aDbfStruct[i, 4])
               CASE valtype(xField)=="L"
                  cField:=l2c(xField)
               ENDCASE
               cQuery:=cQuery+cField+","

            NEXT
            // remove last ","
            cQuery:=left(cQuery,len(cQuery)-1)+")"

            fwrite(fh, cQuery)

            nRef++

            dbffile->(dbSkip())

            // write after each nWrite records!
            IF nRef==nWrite
               do events
               setmessage(cBase+"."+cFileName+": "+ltrim(Str(dbffile->(RecNo())))+cRec, 1)
               nRef:=0
               IF !MySQL_Dump(fh)
                  lError:=.t.
                  EXIT
               ENDIF
               fclose(fh)
               ERASE dump.sql
               fh:=fcreate("Dump.sql")
               IF fh<1
                  MsgExclamation("Handle create?")
                  lError:=.t.
                  EXIT
               ENDIF
               fwrite(fh, cInsert)
            ELSE
               IF !eof()
                  fwrite(fh, ", "+CRLF)
               ENDIF
            ENDIF

         ENDDO

         IF nRef>0
            do events
            setmessage(cBase+"."+cFileName+": "+ltrim(Str(dbffile->(RecNo())))+cRec, 1)
            MySql_Dump(fh)
         ENDIF

         dbffile->(dbCloseArea())

         fclose(fh)
         ERASE dump.sql

      NEXT

      IF !empty(alias())
         dbffile->(dbCloseArea())
      ENDIF

      IF !lError
         UpdateTree()
         MsgInfo("Transfer completed.", PROGRAM)
      ENDIF

      setmessage()

   ENDIF

   do events

   RETURN NIL

FUNCTION MySql_Dump(_fh)

   LOCAL flen, oQuery, lret := .T.

   //eof, bof
   fLen:=fseek(_fh,0,2)
   fseek(_fh,0)
   oQuery := oServer:Query( freadstr(_fh, flen) )
   IF oServer:NetErr()
      MsGInfo( oServer:Error() )
      lret := .f.
   ELSE
      oQuery:Destroy()
   ENDIF

   RETURN lret

FUNCTION d2c( _date )

   LOCAL cret := '0000-00-00'

   IF !empty(_date)
      cret := str(year(_date),4)+"-"+strzero(month(_date),2)+"-"+strzero(day(_date),2)
   ENDIF

   RETURN cret

FUNCTION SQLtrim( _value, _dec )

   LOCAL cret := "0"

   IF _dec==nil
      _dec:=0
   ENDIF

   IF _value<>0
      cret := alltrim(str(_value, 30, if(_dec==nil, 0, _dec)))
   ENDIF

   RETURN cret

FUNCTION l2c( _bool )

   RETURN iif(_bool, "1", "0")

FUNCTION ntrim( nValue )

   RETURN alltrim(str(nValue))
