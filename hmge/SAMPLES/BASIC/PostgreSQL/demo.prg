/*

Postgress console sample for Harbour/MiniGUI
2011-05-06 by Mitja Podgornik

Console version only: compile with: /PG /C /NX

*/

#include "common.ch"

STATIC oServer

FUNCTION main( cHost, cBase, cUser, cPass, cPort )

   LOCAL oQuery, cQuery, oRow, i

   SET CENTURY ON
   SET DATE german

   IF pcount() < 4
      ? "Use: test <Host> <Database> <User> <Password> [port]"

      RETURN -1
   ENDIF

   oServer := TPQServer():New( cHost, cBase, cUser, cPass, iif(cPort==nil, 5432, val(cPort)) )
   IF oServer:NetErr()
      ? oServer:ErrorMsg()

      RETURN -2
   ENDIF

   oServer:SetVerbosity(2)

   IF oServer:TableExists( "simple2" )

      ? oQuery := oServer:Execute( "DROP TABLE simple2" )
      IF oQuery:neterr()
         oServer:Destroy()

         RETURN -3
      ENDIF

      oQuery:Destroy()

   ENDIF

   ? "Creating table: "+cBase+"."+"simple2 ..."

   cQuery := "CREATE TABLE simple2 ("
   cQuery += " id integer not null, "
   cQuery += " name Char(40), "
   cQuery += " age Integer, "
   cQuery += " weight Float4, "
   cQuery += " budget Numeric(12,2), "
   cQuery += " birth Date ) "

   oQuery := oServer:Query( cQuery )
   IF oQuery:neterr()
      ? oQuery:ErrorMsg()
      oServer:Destroy()

      RETURN -3
   ENDIF

   oQuery:Destroy()

   ? "Inserting with declared transaction control ..."

   oServer:StartTransaction()

   FOR i:=1 to 10

      cQuery := "INSERT INTO simple2 (id, name, age, weight, budget, birth) "+ ;
         "VALUES ( " + ntrim(i) + ", 'Jon Doe', "+ntrim(i*2)+", "+ntrim(12.34*i, 2)+", "+ntrim(123.56*i, 2)+", '"+d2pg(date()+i)+"')"

      oQuery := oServer:Query( cQuery )
      IF oQuery:neterr()
         ? oQuery:errorMsg()
         oServer:Destroy()

         RETURN -3
      ENDIF

      oQuery:destroy()

   NEXT

   oServer:Commit()

   ? "Retreiving data ..."

   oQuery := oServer:Query( "SELECT id, name, age, weight, budget, birth FROM simple2" )
   IF oQuery:neterr()
      ? oQuery:errorMsg()
      oServer:Destroy()

      RETURN -3
   ENDIF

   IF oQuery:Lastrec() > 0

      FOR i:=1 to oQuery:Lastrec()

         oRow := oQuery:getrow(i)

         ? ntrim(oRow:Fieldget(1))   +","+ ;
            alltrim(oRow:Fieldget(2)) +","+ ;
            ntrim(oRow:Fieldget(3))   +","+ ;
            ntrim(oRow:Fieldget(4),2) +","+ ;
            ntrim(oRow:Fieldget(5),2) +","+ ;
            dtoc(oRow:Fieldget(6))

      NEXT

   ENDIF

   oQuery:Destroy()

   ? "Closing..."
   oServer:Destroy()

   RETURN 0

FUNCTION d2pg(dDate)

   RETURN strzero(year(dDate),4)+"-"+strzero(month(dDate),2)+"-"+strzero(day(dDate),2)

FUNCTION ntrim(nVal, nDec)

   RETURN iif(nVal==0, "0", alltrim(str(nVal, 20, iif(nDec==nil, 0, nDec))))
