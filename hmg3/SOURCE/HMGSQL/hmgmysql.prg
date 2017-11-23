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

FUNCTION connect2db(host,user,password,dbname)

   LOCAL dbo := tmysqlserver():new(AllTrim(host),AllTrim(user),AllTrim(password))

   IF dbo:NetErr()
      msginfo(dbo:ERROR())

      RETURN NIL
   ENDIF
   dbo:selectdb(dbname)
   IF dbo:NetErr()
      msginfo(dbo:ERROR())

      RETURN NIL
   ENDIF
   //msginfo("Successfully Connected to the MySQL Server")

   RETURN dbo

FUNCTION sql(dbo1,qstr)

   LOCAL table := nil
   LOCAL currow := nil
   LOCAL tablearr := {}
   LOCAL rowarr := {}
   LOCAL curdateformat := set(_SET_DATEFORMAT)
   LOCAL i := 0
   LOCAL j := 0
   LOCAL aTinyIntFields := {}
   LOCAL firstrow  // ADD

   SET DATE ANSI
   table := dbo1:query(qstr)
   IF table:neterr()
      msgstop(table:error())
      table:destroy()
      set(_SET_DATEFORMAT,curdateformat)

      RETURN tablearr
   ELSE
      IF table:lastrec() > 0
         asize( aTinyIntFields, 0 )
         firstrow := table:getrow( 1 )
         FOR j := 1 to HMG_LEN( table:aFieldStruct )
            IF table:aFieldStruct[ j, 4 ] == 1 // tiny integer
               aadd( aTinyIntFields, j )
            ENDIF
         NEXT j
         asize(tablearr,0)
         FOR i := 1 to table:lastrec()
            asize(rowarr,0)
            currow := table:getrow(i)
            FOR j := 1 to table:fcount()
               aadd(rowarr,currow:fieldget(j))
            NEXT j
            FOR j := 1 to HMG_LEN( aTinyIntFields )
               IF rowarr[ aTinyIntFields[ j ] ] > 0
                  rowarr[ aTinyIntFields[ j ] ] := .t.
               ELSE
                  rowarr[ aTinyIntFields[ j ] ] := .f.
               ENDIF
            NEXT j
            aadd(tablearr,aclone(rowarr))
         NEXT i
      ENDIF
      table:destroy()
      set(_SET_DATEFORMAT,curdateformat)

      RETURN tablearr
   ENDIF

   RETURN tablearr

FUNCTION miscsql(dbo,qstr)

   LOCAL curdateformat := set( _SET_DATEFORMAT)
   LOCAL table // ADD

   SET DATE ANSI
   table := dbo:query(qstr)
   set( _SET_DATEFORMAT,curdateformat)
   IF table:NetErr()
      msgstop(table:ERROR())
      table:destroy()

      RETURN  .f.
   ENDIF
   table:destroy()

   RETURN .t.

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
      cValue := AllTrim(Str(iif(Value == .F., 0, 1)))
   OTHERWISE
      cValue := "''"       // NOTE: Here we lose values we cannot convert
   ENDCASE

   RETURN cValue
