#include "minigui.ch"
#include "dbuvar.ch"

FUNCTION DBUcreanew

   _DBUstructarr := {}
   _DBUdbfsaved := .f.
   DEFINE WINDOW _DBUcreadbf at 0,0 width 600 height 500 title "Create a New DataBase Table (.dbf)" modal nosize nosysmenu
      DEFINE FRAME _DBUcurfield
         row 10
         col 10
         width 550
         height 150
         caption "Field"
      END FRAME
      DEFINE LABEL _DBUnamelabel
         row 40
         col 40
         width 150
         backcolor _DBUreddish
         value "Name"
      END LABEL
      DEFINE LABEL _DBUtypelabel
         row 40
         col 195
         backcolor _DBUreddish
         width 100
         value "Type"
      END LABEL
      DEFINE LABEL _DBUsizelabel
         row 40
         col 300
         backcolor _DBUreddish
         width 100
         value "Size"
      END LABEL
      DEFINE LABEL _DBUdecimallabel
         row 40
         col 405
         backcolor _DBUreddish
         width 100
         value "Decimals"
      END LABEL
      DEFINE TEXTBOX _DBUfieldname
         row 70
         col 40
         width 150
         backcolor _DBUreddish
         uppercase .t.
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
         *      on change DBUtypelostfocus()
      END COMBOBOX
      DEFINE TEXTBOX _DBUfieldsize
         row 70
         col 300
         backcolor _DBUreddish
         value 10
         numeric .t.
         width 100
         on lostfocus DBUsizelostfocus()
         rightalign .t.
      END TEXTBOX
      DEFINE TEXTBOX _DBUfielddecimals
         row 70
         col 405
         backcolor _DBUreddish
         value 0
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
         backcolor _DBUyellowish
         width 450
         on dblclick DBUlineselected()
         height 120
      END GRID
      DEFINE BUTTON _DBUsavestruct
         row 400
         col 200
         caption "Create"
         action DBUsavestructure()
      END BUTTON
      DEFINE BUTTON _DBUexitnew
         row 400
         col 400
         caption "Exit"
         action DBUexitcreatenew()
      END BUTTON
   END WINDOW
   CENTER WINDOW _DBUcreadbf
   ACTIVATE WINDOW _DBUcreadbf

   RETURN NIL

FUNCTION DBUexitcreatenew

   IF len(_DBUstructarr) == 0 .or. _DBUdbfsaved
      DBUtogglemenu()
      RELEASE WINDOW _DBUcreadbf
   ELSE
      IF msgyesno("Are you sure to abort creating this dbf?","DBU")
         DBUtogglemenu()
         RELEASE WINDOW _DBUcreadbf
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION DBUaddstruct

   IF _DBUcreadbf._DBUaddline.caption == "Add"
      IF .not. DBUnamecheck()

         RETURN NIL
      ENDIF
      IF _DBUcreadbf._DBUfieldsize.value == 0
         msgexclamation("Field size can not be zero!","DBU")
         _DBUcreadbf._DBUfieldsize.setfocus()

         RETURN NIL
      ENDIF
      DBUtypelostfocus()
      DBUsizelostfocus()
      DBUdeclostfocus()
      IF _DBUcreadbf._DBUfieldtype.value == 2 .and. _DBUcreadbf._DBUfielddecimals.value >= _DBUcreadbf._DBUfieldsize.value
         msgexclamation("You can not have decimal points more than the size!","DBU")
         _DBUcreadbf._DBUfielddecimals.setfocus()

         RETURN NIL
      ENDIF
      IF len(_DBUstructarr) > 0
         FOR _DBUi := 1 to len(_DBUstructarr)
            IF upper(alltrim(_DBUcreadbf._DBUfieldname.value)) == upper(alltrim(_DBUstructarr[_DBUi,1]))
               msgexclamation("Duplicate field names are not allowed!","DBU")
               _DBUcreadbf._DBUfieldname.setfocus()

               RETURN NIL
            ENDIF
         NEXT _DBUi
      ENDIF
      DO CASE
      CASE _DBUcreadbf._DBUfieldtype.value == 1
         aadd(_DBUstructarr,{alltrim(_DBUcreadbf._DBUfieldname.value),"C",_DBUcreadbf._DBUfieldsize.value,0})
      CASE _DBUcreadbf._DBUfieldtype.value == 2
         aadd(_DBUstructarr,{alltrim(_DBUcreadbf._DBUfieldname.value),"N",_DBUcreadbf._DBUfieldsize.value,_DBUcreadbf._DBUfielddecimals.value})
      CASE _DBUcreadbf._DBUfieldtype.value == 3
         aadd(_DBUstructarr,{alltrim(_DBUcreadbf._DBUfieldname.value),"D",8,0})
      CASE _DBUcreadbf._DBUfieldtype.value == 4
         aadd(_DBUstructarr,{alltrim(_DBUcreadbf._DBUfieldname.value),"L",1,0})
      CASE _DBUcreadbf._DBUfieldtype.value == 5
         aadd(_DBUstructarr,{alltrim(_DBUcreadbf._DBUfieldname.value),"M",10,0})
      ENDCASE
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
      _DBUcreadbf._DBUfieldname.value := ""
      _DBUcreadbf._DBUfieldtype.value := 1
      _DBUcreadbf._DBUfieldsize.value := 10
      _DBUcreadbf._DBUfielddecimals.value := 0
      _DBUcreadbf._DBUfieldname.setfocus()
   ELSE
      _DBUcurline := _DBUcreadbf._DBUstruct.value
      IF _DBUcurline > 0
         IF .not. DBUnamecheck()

            RETURN NIL
         ENDIF
         IF _DBUcreadbf._DBUfieldsize.value == 0
            msgexclamation("Field size can not be zero!","DBU")
            _DBUcreadbf._DBUfieldsize.setfocus()

            RETURN NIL
         ENDIF
         DBUtypelostfocus()
         DBUsizelostfocus()
         DBUdeclostfocus()
         IF _DBUcreadbf._DBUfieldtype.value == 2 .and. _DBUcreadbf._DBUfielddecimals.value >= _DBUcreadbf._DBUfieldsize.value
            msgexclamation("You can not have decimal points more than the size!","DBU")
            _DBUcreadbf._DBUfielddecimals.setfocus()

            RETURN NIL
         ENDIF
         IF len(_DBUstructarr) > 0
            FOR _DBUi := 1 to len(_DBUstructarr)
               IF upper(alltrim(_DBUcreadbf._DBUfieldname.value)) == upper(alltrim(_DBUstructarr[_DBUi,1])) .and. _DBUi <> _DBUcurline
                  msgexclamation("Duplicate field names are not allowed!","DBU")
                  _DBUcreadbf._DBUfieldname.setfocus()

                  RETURN NIL
               ENDIF
            NEXT _DBUi
         ENDIF
         DO CASE
         CASE _DBUcreadbf._DBUfieldtype.value == 1
            _DBUstructarr[_DBUcurline] := {alltrim(_DBUcreadbf._DBUfieldname.value),"C",_DBUcreadbf._DBUfieldsize.value,0}
         CASE _DBUcreadbf._DBUfieldtype.value == 2
            _DBUstructarr[_DBUcurline] := {alltrim(_DBUcreadbf._DBUfieldname.value),"N",_DBUcreadbf._DBUfieldsize.value,_DBUcreadbf._DBUfielddecimals.value}
         CASE _DBUcreadbf._DBUfieldtype.value == 3
            _DBUstructarr[_DBUcurline] := {alltrim(_DBUcreadbf._DBUfieldname.value),"D",8,0}
         CASE _DBUcreadbf._DBUfieldtype.value == 4
            _DBUstructarr[_DBUcurline] := {alltrim(_DBUcreadbf._DBUfieldname.value),"L",1,0}
         CASE _DBUcreadbf._DBUfieldtype.value == 5
            _DBUstructarr[_DBUcurline] := {alltrim(_DBUcreadbf._DBUfieldname.value),"M",10,0}
         ENDCASE
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
            _DBUcreadbf._DBUstruct.value := _DBUcurline
         ENDIF
         _DBUcreadbf._DBUaddline.caption := "Add"
         _DBUcreadbf._DBUinsline.enabled := .t.
         _DBUcreadbf._DBUdelline.enabled := .t.
         _DBUcreadbf._DBUfieldname.value := ""
         _DBUcreadbf._DBUfieldtype.value := 1
         _DBUcreadbf._DBUfieldsize.value := 10
         _DBUcreadbf._DBUfielddecimals.value := 0
         _DBUcreadbf._DBUfieldname.setfocus()
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION DBUinsstruct

   IF len(_DBUstructarr) == 0
      DBUaddstruct()

      RETURN NIL
   ENDIF
   IF _DBUcreadbf._DBUstruct.value == 0
      DBUaddstruct()

      RETURN NIL
   ENDIF
   IF .not. DBUnamecheck()

      RETURN NIL
   ENDIF
   IF _DBUcreadbf._DBUfieldsize.value == 0
      msgexclamation("Field size can not be zero!","DBU")
      _DBUcreadbf._DBUfieldsize.setfocus()

      RETURN NIL
   ENDIF
   DBUtypelostfocus()
   DBUsizelostfocus()
   DBUdeclostfocus()
   IF _DBUcreadbf._DBUfieldtype.value == 2 .and. _DBUcreadbf._DBUfielddecimals.value >= _DBUcreadbf._DBUfieldsize.value
      msgexclamation("You can not have decimal points more than the size!","DBU")
      _DBUcreadbf._DBUfielddecimals.setfocus()

      RETURN NIL
   ENDIF
   IF len(_DBUstructarr) > 0
      FOR _DBUi := 1 to len(_DBUstructarr)
         IF upper(alltrim(_DBUcreadbf._DBUfieldname.value)) == upper(alltrim(_DBUstructarr[_DBUi,1]))
            msgexclamation("Duplicate field names are not allowed!","DBU")
            _DBUcreadbf._DBUfieldname.setfocus()

            RETURN NIL
         ENDIF
      NEXT _DBUi
   ENDIF
   _DBUpos := _DBUcreadbf._DBUstruct.value
   asize(_DBUstructarr,len(_DBUstructarr)+1)
   _DBUstructarr := ains(_DBUstructarr,_DBUpos)
   DO CASE
   CASE _DBUcreadbf._DBUfieldtype.value == 1
      _DBUstructarr[_DBUpos] := {alltrim(_DBUcreadbf._DBUfieldname.value),"C",_DBUcreadbf._DBUfieldsize.value,0}
   CASE _DBUcreadbf._DBUfieldtype.value == 2
      _DBUstructarr[_DBUpos] := {alltrim(_DBUcreadbf._DBUfieldname.value),"N",_DBUcreadbf._DBUfieldsize.value,_DBUcreadbf._DBUfielddecimals.value}
   CASE _DBUcreadbf._DBUfieldtype.value == 3
      _DBUstructarr[_DBUpos] := {alltrim(_DBUcreadbf._DBUfieldname.value),"D",8,0}
   CASE _DBUcreadbf._DBUfieldtype.value == 4
      _DBUstructarr[_DBUpos] := {alltrim(_DBUcreadbf._DBUfieldname.value),"L",1,0}
   CASE _DBUcreadbf._DBUfieldtype.value == 5
      _DBUstructarr[_DBUpos] := {alltrim(_DBUcreadbf._DBUfieldname.value),"M",10,0}
   ENDCASE
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
      _DBUcreadbf._DBUstruct.value := _DBUpos
   ENDIF
   _DBUcreadbf._DBUfieldname.value := ""
   _DBUcreadbf._DBUfieldtype.value := 1
   _DBUcreadbf._DBUfieldsize.value := 10
   _DBUcreadbf._DBUfielddecimals.value := 0
   _DBUcreadbf._DBUfieldname.setfocus()

   RETURN NIL

FUNCTION DBUdelstruct

   _DBUcurline := _DBUcreadbf._DBUstruct.value
   IF _DBUcurline > 0
      _DBUstructarr := adel(_DBUstructarr,_DBUcurline)
      _DBUstructarr := asize(_DBUstructarr,len(_DBUstructarr) - 1)
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
      IF len(_DBUstructarr) > 1
         IF len(_DBUstructarr) == 1
            _DBUcreadbf._DBUstruct.value := 1
         ELSE
            _DBUcreadbf._DBUstruct.value := iif(_DBUcurline == 1,1,_DBUcurline - 1)
         ENDIF
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION DBUnamecheck

   LOCAL _DBUname := alltrim(_DBUcreadbf._DBUfieldname.value)
   LOCAL _DBUlegalchars := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ_1234567890'
   LOCAL _DBUi

   IF len(_DBUname) == 0
      msgexclamation("Field Name can not be empty!","DBU")
      _DBUcreadbf._DBUfieldname.setfocus()

      RETURN .f.
   ENDIF
   IF val(substr(_DBUname,1,1)) > 0 .or. substr(_DBUname,1,1) == "_"
      msgexclamation("First letter of the field name can not be a numeric character or special character!","DBU")
      _DBUcreadbf._DBUfieldname.setfocus()

      RETURN .f.
   ELSE
      FOR _DBUi := 1 to len(_DBUname)
         IF at(upper(substr(_DBUname,_DBUi,1)),_DBUlegalchars) == 0
            msgexclamation("Field name contains illegal characters. Allowed characters are alphabets, numbers and the special character '_'.","DBU")
            _DBUcreadbf._DBUfieldname.setfocus()

            RETURN .f.
         ENDIF
      NEXT _DBUi
   ENDIF

   RETURN .t.

FUNCTION DBUtypelostfocus

   DO CASE
   CASE _DBUcreadbf._DBUfieldtype.value == 3
      _DBUcreadbf._DBUfieldsize.value := 8
      _DBUcreadbf._DBUfielddecimals.value := 0
   CASE _DBUcreadbf._DBUfieldtype.value == 4
      _DBUcreadbf._DBUfieldsize.value := 1
      _DBUcreadbf._DBUfielddecimals.value := 0
   CASE _DBUcreadbf._DBUfieldtype.value == 5
      _DBUcreadbf._DBUfieldsize.value := 10
      _DBUcreadbf._DBUfielddecimals.value := 0
   ENDCASE

   RETURN NIL

FUNCTION DBUsizelostfocus

   DBUtypelostfocus()
   IF _DBUcreadbf._DBUfieldtype.value == 1
      _DBUcreadbf._DBUfielddecimals.value := 0
   ENDIF

   RETURN NIL

FUNCTION DBUdeclostfocus

   DBUtypelostfocus()
   DBUsizelostfocus()
   IF _DBUcreadbf._DBUfieldtype.value <> 2
      _DBUcreadbf._DBUfielddecimals.value := 0
   ENDIF

   RETURN NIL

FUNCTION DBUlineselected

   _DBUcurline := _DBUcreadbf._DBUstruct.value
   IF _DBUcurline > 0
      _DBUcreadbf._DBUfieldname.value := _DBUstructarr[_DBUcurline,1]
      DO CASE
      CASE _DBUstructarr[_DBUcurline,2] == "C"
         _DBUcreadbf._DBUfieldtype.value := 1
      CASE _DBUstructarr[_DBUcurline,2] == "N"
         _DBUcreadbf._DBUfieldtype.value := 2
      CASE _DBUstructarr[_DBUcurline,2] == "D"
         _DBUcreadbf._DBUfieldtype.value := 3
      CASE _DBUstructarr[_DBUcurline,2] == "L"
         _DBUcreadbf._DBUfieldtype.value := 4
      CASE _DBUstructarr[_DBUcurline,2] == "M"
         _DBUcreadbf._DBUfieldtype.value := 5
      END CASE
      _DBUcreadbf._DBUfieldsize.value := _DBUstructarr[_DBUcurline,3]
      _DBUcreadbf._DBUfielddecimals.value := _DBUstructarr[_DBUcurline,4]
      _DBUcreadbf._DBUinsline.enabled := .f.
      _DBUcreadbf._DBUdelline.enabled := .f.
      _DBUcreadbf._DBUaddline.caption := "Modify"
      _DBUcreadbf._DBUfieldname.setfocus()
   ENDIF

   RETURN NIL

FUNCTION DBUsavestructure

   _DBUfname1 := ""
   IF len(_DBUstructarr) > 0
      _DBUfname1 := alltrim(putfile({{"Harbour Database File","*.dbf"}},"Enter a filename"))
      IF len(_DBUfname1) > 0
         IF msgyesno("Are you sure to create this database file?","DBU")
            dbcreate(_DBUfname1,_DBUstructarr)
            msginfo("File has been created successfully","DBU")
            IF .not. used()
               USE &_DBUfname1
               _DBUfname := _DBUfname1
               _DBUdbfopened := .t.
               DBUtogglemenu()
               RELEASE WINDOW _DBUcreadbf
            ELSE
               RELEASE WINDOW _DBUcreadbf
            ENDIF
         ENDIF
      ENDIF
   ENDIF

   RETURN NIL
