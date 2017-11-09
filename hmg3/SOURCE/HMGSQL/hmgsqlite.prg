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

FUNCTION connect2db(dbname,lCreate)

   LOCAL dbo1 := sqlite3_open(dbname,lCreate)

   IF Empty( dbo1 )
      msginfo("Database could not be connected!")

      RETURN NIL
   ENDIF

   RETURN dbo1

FUNCTION sql( dbo1, qstr )

   LOCAL table := {}
   LOCAL currow := nil
   LOCAL tablearr := {}
   LOCAL rowarr := {}
   LOCAL typesarr := {}
   LOCAL current := ""
   LOCAL i := 0
   LOCAL j := 0
   LOCAL type1 := ""
   LOCAL stmt := nil
   LOCAL cDate

   IF empty(dbo1)
      msgstop("Database Connection Error!")

      RETURN tablearr
   ENDIF
   table := sqlite3_get_table(dbo1,qstr)
   IF sqlite3_errcode(dbo1) > 0 // error
      msgstop(sqlite3_errmsg(dbo1)+" Query is : "+qstr)

      RETURN NIL
   ENDIF
   stmt := sqlite3_prepare(dbo1,qstr)
   IF ! Empty( stmt )
      FOR i := 1 to sqlite3_column_count( stmt )
         type1 := HMG_UPPER(alltrim(sqlite3_column_decltype( stmt,i)))
         DO CASE
         CASE type1 == "INTEGER" .or. type1 == "REAL" .or. type1 == "FLOAT" .or. type1 == "DOUBLE"
            aadd(typesarr,"N")
         CASE type1 == "DATE" .or. type1 == "DATETIME"
            aadd(typesarr,"D")
         CASE type1 == "BOOL"
            aadd(typesarr,"L")
         OTHERWISE
            aadd(typesarr,"C")
         ENDCASE
      NEXT i
   ENDIF
   SQLITE3_FINALIZE( stmt )
   stmt := nil
   IF HMG_LEN(table) > 1
      asize(tablearr,0)
      FOR i := 2 to HMG_LEN(table)
         rowarr := table[i]
         FOR j := 1 to HMG_LEN(rowarr)
            DO CASE
            CASE typesarr[j] == "D"
               cDate := HB_USUBSTR(rowarr[j],1,4)+HB_USUBSTR(rowarr[j],6,2)+HB_USUBSTR(rowarr[j],9,2)
               rowarr[j] := stod(cDate)
            CASE typesarr[j] == "N"
               rowarr[j] := val(rowarr[j])
            CASE typesarr[j] == "L"
               IF val(rowarr[j]) == 1
                  rowarr[j] := .t.
               ELSE
                  rowarr[j] := .f.
               ENDIF
            ENDCASE
         NEXT j
         aadd(tablearr,aclone(rowarr))
      NEXT i
   ENDIF

   RETURN tablearr

FUNCTION miscsql(dbo1,qstr)

   IF empty(dbo1)
      msgstop("Database Connection Error!")

      RETURN .f.
   ENDIF
   sqlite3_exec(dbo1,qstr)
   IF sqlite3_errcode(dbo1) > 0 // error
      msgstop(sqlite3_errmsg(dbo1)+" Query is : "+qstr)

      RETURN .f.
   ENDIF

   RETURN .t.

FUNCTION C2SQL(Value)

   LOCAL cValue := ""
   LOCAL cdate := ""

   IF ( valtype(value) == "C" .or. valtype( value ) == "M" ) .and. HMG_LEN(alltrim(value)) > 0
      value := HB_UTF8STRTRAN(value, "'", "''" )
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
      cValue := AllTrim(Str(iif(Value == .F., 0, 1)))
   OTHERWISE
      cValue := "''"       // NOTE: Here we lose values we cannot convert
   ENDCASE

   RETURN cValue
