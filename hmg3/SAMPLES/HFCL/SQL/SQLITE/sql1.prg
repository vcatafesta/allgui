# include "hmg.ch"

FUNCTION connect2db(dbname,lCreate)

   dbo := sqlite3_open(dbname,lCreate)
   IF Empty( dbo )
      msginfo("Database could not be connected!")

      RETURN .f.
   ENDIF

   RETURN .t.

FUNCTION sql(dbo1,qstr)

   LOCAL table := {}
   LOCAL currow := nil
   LOCAL tablearr := {}
   LOCAL rowarr := {}
   LOCAL datetypearr := {}
   LOCAL numtypearr := {}
   LOCAL typesarr := {}
   LOCAL current := ""
   LOCAL i := 0
   LOCAL j := 0
   LOCAL type1 := ""

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
         type1 := sqlite3_column_decltype( stmt,i)
         DO CASE
         CASE type1 == "INTEGER" .or. type1 == "REAL" .or. type1 == "FLOAT"
            aadd(typesarr,"N")
         CASE type1 == "DATE"
            aadd(typesarr,"D")
         OTHERWISE
            aadd(typesarr,"C")
         ENDCASE
      NEXT i
   ENDIF
   sqlite3_reset( stmt )
   IF len(table) > 1
      asize(tablearr,0)
      rowarr := table[2]
      FOR i := 2 to len(table)
         rowarr := table[i]
         FOR j := 1 to len(rowarr)
            DO CASE
            CASE typesarr[j] == "D"
               cDate := substr(rowarr[j],1,4)+substr(rowarr[j],6,2)+substr(rowarr[j],9,2)
               rowarr[j] := stod(cDate)
            CASE typesarr[j] == "N"
               rowarr[j] := val(rowarr[j])
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
   LOCAL cFormatoDaData := set(4)

   DO CASE
   CASE Valtype(Value) == "N"
      cValue := AllTrim(Str(Value))

   CASE Valtype(Value) == "D"
      IF !Empty(Value)
         cdate := dtos(value)
         cValue := "'"+substr(cDate,1,4)+"-"+substr(cDate,5,2)+"-"+substr(cDate,7,2)+"'"
      ELSE
         cValue := "''"
      ENDIF

   CASE Valtype(Value) $ "CM"
      IF Empty( Value)
         cValue="''"
      ELSE
         cValue := "'" + value+ "'"
      ENDIF

   CASE Valtype(Value) == "L"
      cValue := AllTrim(Str(iif(Value == .F., 0, 1)))

   OTHERWISE
      cValue := "''"       // NOTE: Here we lose values we cannot convert

   ENDCASE

   RETURN cValue
