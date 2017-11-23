/*----------------------------------------------------------------------------
HMG_SQL_Bridge - HMG -> SQL Bridges for MySQL,PostgreSQL and SQLite

Copyright 2010 S. Rathinagiri <srgiri@dataone.in>

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this software; see the file COPYING. If not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA (or
visit the web site http://www.gnu.org/).

As a special exception, you have permission for additional uses of the text
contained in this release of HMG_SQL_Bridge.

The exception is that, if you link the HMG_SQL_Bridge library with other
files to produce an executable, this does not by itself cause the resulting
executable to be covered by the GNU General Public License.
Your use of that executable is in no way restricted on account of linking the
HMG_SQL_Bridge library code into it.

Parts of this project (especially hbmysql, hbpgsql and hbsqlit3 library contributions) are based upon:

"Harbour Project"
Copyright 1999-2008, http://www.harbour-project.org/

"HMG - Harbour Windows GUI"
Copyright 2002-2010 Roberto Lopez <mail.box.hmg@gmail.com>,http://sites.google.com/site/hmgweb/

"HBMYSQL"  - Luiz Rafael Culik - <culik@sl.conex.net>
"HBPGSQL"  - Rodrigo Moreno rodrigo_moreno@yahoo.com
"HBSQLIT3" - P.Chornyj <myorg63@mail.ru>

---------------------------------------------------------------------------*/
#include <hmg.ch>
#include "postgres.ch"

FUNCTION connect2db(cHost,cUser,cPass,cDb,nPort)

   LOCAL dbo1 := nil

   DEFAULT nPort := 5432
   dbo1 := PQConnect(cDb, cHost, cUser, cPass, nPort)
   IF PQStatus(dbo1) != CONNECTION_OK
      msginfo("Database could not be connected!")

      RETURN NIL
   ENDIF

   RETURN dbo1

FUNCTION sql(dbo1,qstr)

   LOCAL aTable := {}
   LOCAL tablearr := {}
   LOCAL rowarr := {}
   LOCAL i := 0
   LOCAL j := 0
   LOCAL oRes := nil
   LOCAL aMetaData := {}
   LOCAL cDate := ""

   IF empty(dbo1)
      msgstop("Database Connection Error!")

      RETURN tablearr
   ENDIF
   oRes := PQexec(dbo1,qstr)
   IF oRes == nil
      msgstop("Error in execution!")

      RETURN .f.
   ELSE
      IF PQresultStatus(oRes) == PGRES_TUPLES_OK
         aMetaData := PQmetadata(oRes)
         aTable := PQRESULT2ARRAY(oRes)
         FOR i := 1 to HMG_LEN(aTable)
            asize(rowarr,0)
            FOR j := 1 to HMG_LEN(aTable[i])
               DO CASE
               CASE HMG_UPPER(aMetaData[j,2]) == "BIGINT".or. ;
                     HMG_UPPER(aMetaData[j,2]) == "DOUBLE PRECISION".or. ;
                     HMG_UPPER(aMetaData[j,2]) == "INTEGER".or. ;
                     HMG_UPPER(aMetaData[j,2]) == "NUMERIC".or. ;
                     HMG_UPPER(aMetaData[j,2]) == "DECIMAL".or. ;
                     HMG_UPPER(aMetaData[j,2]) == "REAL".or. ;
                     HMG_UPPER(aMetaData[j,2]) == "SMALLINT"
                  aadd(rowarr,val(alltrim(aTable[i,j])))
               CASE HMG_UPPER(aMetaData[j,2]) == "CHAR".or. ;
                     HMG_UPPER(aMetaData[j,2]) == "CHARACTER VARYING".or. ;
                     HMG_UPPER(aMetaData[j,2]) == "CHARACTER".or. ;
                     HMG_UPPER(aMetaData[j,2]) == "VARCHAR"
                  aadd(rowarr,aTable[i,j])
               CASE HMG_UPPER(aMetaData[j,2]) == "BOOLEAN"
                  aadd(rowarr,iif(aTable[i,j]=="t",.t.,.f.))
               CASE HMG_UPPER(aMetaData[j,2]) == "DATE"
                  cDate := HB_USUBSTR(aTable[i,j],1,4)+HB_USUBSTR(aTable[i,j],6,2)+HB_USUBSTR(aTable[i,j],9,2)
                  aadd(rowarr,stod(cDate))
               OTHERWISE //bit, bit varying,interval
                  aadd(rowarr,aTable[i,j])
               ENDCASE
            NEXT j
            aadd(tablearr,rowarr)
         NEXT i
      ENDIF
      PQclear(oRes)
   ENDIF

   RETURN aclone(tablearr)

FUNCTION miscsql(dbo1,qstr)

   LOCAL oRes := nil

   IF empty(dbo1)
      msgstop("Database Connection Error!")

      RETURN .f.
   ENDIF
   oRes := PQexec(dbo1,qstr)
   IF oRes == nil
      msgstop("Error in execution!")

      RETURN .f.
   ELSE
      IF PQResultStatus(oRes) != PGRES_COMMAND_OK
         msgstop("Query Execution Error!")
         PQclear(oRes)

         RETURN .f.
      ENDIF
      PQclear(oRes)
   ENDIF

   RETURN .t.

FUNCTION closedb(dbo)

   PQClose(dbo)

   RETURN NIL

FUNCTION C2SQL(Value)

   LOCAL cValue := ""
   LOCAL cdate := ""

   IF valtype(value) == "C" .and. HMG_LEN(alltrim(value)) > 0
      value := HB_UTF8STRTRAN(value,"'","''")
   ENDIF
   DO CASE
   CASE Valtype(Value) == "N"
      cValue := AllTrim(Str(Value))
   CASE Valtype(Value) == "D"
      IF !Empty(Value)
         cdate := dtos(value)
         cValue := "'"+HB_USUBSTR(cDate,1,4)+"-"+HB_USUBSTR(cDate,5,2)+"-"+HB_USUBSTR(cDate,7,2)+"'"
      ELSE
         cValue := "''"
      ENDIF
   CASE Valtype(Value) $ "CM"
      IF Empty( Value)
         cValue="''"
      ELSE
         cValue := "'" + value + "'"
      ENDIF
   CASE Valtype(Value) == "L"
      cValue := AllTrim(Str(iif(Value == .F., '0', '1')))
   OTHERWISE
      cValue := "''"       // NOTE: Here we lose values we cannot convert
   ENDCASE

   RETURN cValue
