
* SQLITE Sample by Rathinagiri / MOL / Sudip / Grigory Filatov (HMG Forum)

#include "hmg.ch"

FUNCTION main

   LOCAL aTable := {}
   LOCAL aCurRow := {}
   PUBLIC dbo := nil
   PUBLIC cDBName := "sample.db3"

   SET CENTURY ON
   SET DATE ital

   IF .not. file(cDBName)
      create_populate()
   ELSE
      connect2db(cDBName)
   ENDIF

   DEFINE WINDOW sample at 0,0 width 800 height 500 main

      DEFINE GRID table
         row 10
         col 10
         width 780
         height 400
         widths {200,100,100,100,50,200}
         headers {"Text","Number","Floating","Date1","Logic","Text2"}
      END GRID

      DEFINE BUTTON P_ViewRecord
         row 450
         col 100
         width 140
         height 24
         caption "View record = Giri11"
         action ViewRecord()
      END BUTTON

      DEFINE BUTTON P_ChangeRecord
         row 450
         col 300
         width 140
         height 24
         caption "Popraw"
         action ChangeRecord()
      END BUTTON

   END WINDOW
   RefreshTable()
   sample.center
   sample.activate

   RETURN NIL

FUNCTION RefreshTable

   sample.table.DeleteAllItems()

   aTable := sql(dbo,"select * from new where date1 <= "+c2sql(ctod("15-04-2010")))
   FOR i := 1 to len(aTable)
      aCurRow := aTable[i]
      sample.table.additem({aCurRow[1],str(aCurRow[2]),str(aCurRow[3]),dtoc(aCurRow[4]),iif(aCurRow[5]==1,"True","False"),aCurRow[6]})
   NEXT i
   IF sample.table.itemcount > 0
      sample.table.value := 1
   ENDIF
   sample.table.Refresh

   RETURN NIL

FUNCTION create_populate()

   LOCAL cCreateSQL := "CREATE TABLE new (text VARCHAR(50), number INTEGER PRIMARY KEY AUTOINCREMENT, floating FLOAT, date1 DATE, logic INTEGER, text2  VARCHAR(40))"
   LOCAL cCreateIndex := "CREATE UNIQUE INDEX unique1 ON new (text,text2)"

   IF .not. connect2db(cDBName,.t.)

      RETURN NIL
   ENDIF

   IF .not. miscsql(dbo,cCreateSQL)

      RETURN NIL
   ENDIF

   IF .not. miscsql(dbo,cCreateIndex)

      RETURN NIL
   ENDIF

   FOR i := 1 to 100

      cQStr := "insert into new (text,floating,date1,logic,text2) values ("+;
         c2sql("Giri"+alltrim(str(i)))+","+;
         c2sql(123.45)+","+;
         iif(i <= 50,c2sql(date()),c2sql(ctod("18-09-2010")))+","+;
         c2sql(.t.)+","+;
         c2sql("India")+;
         ")"
      IF .not. miscsql(dbo,cQstr)

         RETURN NIL
      ENDIF

   NEXT i

   msginfo("Insert Queries Completed!")

   RETURN NIL

FUNCTION ViewRecord

   LOCAL aResult

   aResult := sql(dbo, 'Select text2 from new where text = "Giri11"') // for update')
   IF !empty(aResult)
      msgbox("Result is: " + aResult[1,1])
   ENDIF

   RETURN

FUNCTION ChangeRecord

   LOCAL aTemp := {space(40)}

   aTemp := InputWindow("Put your value for TEXT2", {"New value:"}, {space(40)}, {40})
   IF aTemp[1] != Nil // changed here
      cQstr := "update new set text2= '" +aTemp[1] +"' where text='Giri11'"
      IF !miscsql(dbo,cQstr)
         msginfo("Error during writing!")
      ELSE
         msgbox("TEXT2 saved OK")
         RefreshTable()
      ENDIF
   ENDIF

   RETURN
