#include "minigui.ch"
#include "dbuvar.ch"

FUNCTION DBUmodistruct

   IF len(alltrim(_DBUfname)) == 0 .or. .not. used()

      RETURN NIL
   ELSEIF IsWindowDefined( _DBUBrowse ) .or. IsWindowDefined( _DBUedit ) // (P.D. 21-06-2005)
      msgStop( 'Structure change not allowed' + HB_OSNewLine() + ;
         'while browsing or editing records!',;
         'DBU Modify structure' )

      RETURN NIL
   ENDIF
   _DBUoriginalarr := dbstruct()
   _DBUstructarr := dbstruct()
   _DBUdbfsaved := .f.
   DEFINE WINDOW _DBUcreadbf at 0,0 width 600 height 500 title "Modify DataBase Table" modal nosize nosysmenu
      DEFINE FRAME _DBUcurfield
         row 10
         col 10
         width 550
         height 150
         //      backcolor _DBUgreenish
         caption "Field"
      END FRAME
      DEFINE LABEL _DBUnamelabel
         row 40
         col 40
         width 150
         backcolor _DBUgreenish
         value "Name"
      END LABEL
      DEFINE LABEL _DBUtypelabel
         row 40
         col 195
         width 100
         backcolor _DBUgreenish
         value "Type"
      END LABEL
      DEFINE LABEL _DBUsizelabel
         row 40
         col 300
         width 100
         backcolor _DBUgreenish
         value "Size"
      END LABEL
      DEFINE LABEL _DBUdecimallabel
         row 40
         col 405
         backcolor _DBUgreenish
         width 100
         value "Decimals"
      END LABEL
      DEFINE TEXTBOX _DBUfieldname
         row 70
         col 40
         width 150
         uppercase .t.
         backcolor _DBUgreenish
         maxlength 10
         value ""
      END TEXTBOX
      DEFINE COMBOBOX _DBUfieldtype
         row 70
         col 195
         items {"Character","Numeric","Date","Logical","Memo"}
         width 100
         value 1
         on lostfocus DBUtypelostfocus()
         on enter DBUtypelostfocus()
         *      on change typelostfocus()
      END COMBOBOX
      DEFINE TEXTBOX _DBUfieldsize
         row 70
         col 300
         backcolor _DBUgreenish
         value 10
         numeric .t.
         width 100
         on lostfocus DBUsizelostfocus()
         rightalign .t.
      END TEXTBOX
      DEFINE TEXTBOX _DBUfielddecimals
         row 70
         col 405
         value 0
         backcolor _DBUgreenish
         numeric .t.
         width 100
         on lostfocus DBUdeclostfocus()
         rightalign .t.
      END TEXTBOX
      DEFINE BUTTON _DBUaddline
         row 120
         col 75
         caption "Add"
         width 100
         action DBUaddstruct()
      END BUTTON
      DEFINE BUTTON _DBUinsline
         row 120
         col 225
         caption "Insert"
         width 100
         action DBUinsstruct()
      END BUTTON
      DEFINE BUTTON _DBUdelline
         row 120
         col 400
         caption "Delete"
         width 100
         action DBUdelstruct()
      END BUTTON
      DEFINE FRAME _DBUstructframe
         row 190
         col 10
         caption "Structure of DBF"
         width 500
         height 180
      END FRAME
      DEFINE GRID _DBUstruct
         row 220
         col 40
         headers {"Name","Type","Size","Decimals"}
         justify {0,0,1,1}
         widths {150,100,100,75}
         width 450
         backcolor _DBUyellowish
         items _DBUstructarr
         on dblclick DBUlineselected()
         height 120
      END GRID
      DEFINE BUTTON _DBUsavestruct
         row 400
         col 200
         caption "Modify"
         action DBUmodistructure()
      END BUTTON
      DEFINE BUTTON _DBUexitnew
         row 400
         col 400
         caption "Exit"
         action DBUexitmodidbf()
      END BUTTON
   END WINDOW
   CENTER WINDOW _DBUcreadbf
   _DBUcreadbf._DBUstruct.deleteallitems()
   FOR _DBUi := 1 to len(_DBUstructarr)
      DO CASE
      CASE _DBUstructarr[_DBUi,2] == "C"
         _DBUtype1 := "Character"
      CASE _DBUstructarr[_DBUi,2] == "N"
         _DBUtype1 := "Numeric"
      CASE _DBUstructarr[_DBUi,2] == "D"
         _DBUtype1 := "Date"
      CASE _DBUstructarr[_DBUi,2] == "L"
         _DBUtype1 := "Logical"
      CASE _DBUstructarr[_DBUi,2] == "M"
         _DBUtype1 := "Memo"
      END CASE
      _DBUcreadbf._DBUstruct.additem({_DBUstructarr[_DBUi,1],;
         _DBUtype1,;
         str(_DBUstructarr[_DBUi,3],8,0),;
         str(_DBUstructarr[_DBUi,4],3,0)})
   NEXT _DBUi
   IF len(_DBUstructarr) > 0
      _DBUcreadbf._DBUstruct.value := len(_DBUstructarr)
   ENDIF
   ACTIVATE WINDOW _DBUcreadbf

   RETURN NIL

FUNCTION DBUmodistructure

   LOCAL ldeleted

   IF .not. msgyesno("Caution: If you had modified either the field name or the field type, the data for that fields can not be saved in the modified dbf. However, a backup file (.bak) will be created. Are you sure to modify the structure?","DBU")

      RETURN NIL
   ENDIF
   _DBUmodarr := {}
   FOR _DBUi := 1 to len(_DBUstructarr)
      IF _DBUi <= len(_DBUoriginalarr)
         _DBUline := ascan(_DBUoriginalarr,{|_DBUx|upper(alltrim(_DBUx[1])) == upper(alltrim(_DBUstructarr[_DBUi,1]))})
         IF _DBUline > 0
            IF _DBUoriginalarr[_DBUline,2] == _DBUstructarr[_DBUi,2]
               aadd(_DBUmodarr,_DBUi)
            ENDIF
         ENDIF
      ENDIF
   NEXT _DBUi
   _DBUfname1 := "DBUtemp"
   IF len(_DBUstructarr) > 0
      _DBUfname1 := "DBUtemp"
      IF len(_DBUfname1) > 0
         dbcreate(_DBUfname1,_DBUstructarr)
         CLOSE all
         SELECT b
         USE &_DBUfname
         SELECT c
         USE &_DBUfname1
         SELECT b
         GO TOP
         IF len(_DBUmodarr) > 0
            DO WHILE .not. eof()
               ldeleted := deleted()
               SELECT c
               APPEND BLANK
               FOR _DBUi := 1 to len(_DBUmodarr)
                  _DBUfieldname := _DBUstructarr[_DBUmodarr[_DBUi],1]
                  REPLACE c->&_DBUfieldname with b->&_DBUfieldname
               NEXT _DBUi
               IF ldeleted
                  DELETE
               ENDIF
               SELECT b
               SKIP
            ENDDO
         ENDIF
         SELECT b
         CLOSE
         SELECT c
         CLOSE
         IF at(".",_DBUfname) == 0
            _DBUbackname := alltrim(_DBUfname)+".dbf"
            IF file(_DBUbackname)
               IF file(alltrim(_DBUfname)+".bak")
                  ferase(alltrim(_DBUfname)+".bak")
               ENDIF
               frename(_DBUbackname,alltrim(_DBUfname)+".bak")
               frename('DBUtemp.dbf',alltrim(_DBUfname)+".dbf")
            ENDIF
         ELSE
            _DBUnewname := substr(alltrim(_DBUfname),1,at(".",_DBUfname)-1)+".bak"
            IF file(_DBUfname)
               IF file(_DBUnewname)
                  ferase(_DBUnewname)
               ENDIF
               frename(_DBUfname,_DBUnewname)
               frename('DBUtemp.dbf',alltrim(_DBUfname))
            ENDIF
         ENDIF
         CLOSE all
         USE &_DBUfname
         DBUtogglemenu()
         RELEASE WINDOW _DBUcreadbf
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION DBUexitmodidbf

   IF len(_DBUstructarr) == 0 .or. _DBUdbfsaved
      DBUtogglemenu()
      RELEASE WINDOW _DBUcreadbf
   ELSE
      IF msgyesno("Are you sure to abort Modifying this dbf?","DBU")
         DBUtogglemenu()
         RELEASE WINDOW _DBUcreadbf
      ENDIF
   ENDIF

   RETURN NIL

