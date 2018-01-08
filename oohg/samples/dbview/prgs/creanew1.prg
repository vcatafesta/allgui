/*
* $Id: creanew1.prg $
*/
/*
* MINIGUI - Harbour Win32 GUI library
* Copyright 2002-2012 Roberto Lopez <harbourminigui@gmail.com>
* http://harbourminigui.googlepages.com/
* Program to view DBF files using standard Browse control
* Miguel Angel Juárez A. - 2009-2012 MigSoft <mig2soft/at/yahoo.com>
* Includes the code of Grigory Filatov <gfilatov@inbox.ru>
* and Rathinagiri <srathinagiri@gmail.com>
*/

#include "oohg.ch"
#include "dbuvar.ch"

FUNCTION DBUcreanew(cBase)

   _DBUstructarr := {}
   _DBUdbfsaved := .f.

   _dbufname := cBase

   DEFINE WINDOW _DBUcreadbf AT 295 , 312 WIDTH 549 HEIGHT 266 title PROGRAM+VERSION+"- Create a New DataBase Table (.dbf)" MODAL nosize nosysmenu

      DEFINE TEXTBOX _DBUfieldname
         ROW    40
         COL    30
         WIDTH  120
         HEIGHT 24
      END TEXTBOX

      DEFINE COMBOBOX _DBUfieldtype
         ROW    40
         COL    160
         WIDTH  120
         HEIGHT 100
         ITEMS {"Character","Numeric","Date","Logical","Memo"}
         VALUE 1
         ON LOSTFOCUS DBUtypelostfocus()
         ON ENTER DBUtypelostfocus()
      END COMBOBOX

      DEFINE LABEL _DBUnamelabel
         ROW    20
         COL    30
         WIDTH  80
         HEIGHT 20
         VALUE "Field"
      END LABEL

      DEFINE LABEL _DBUtypelabel
         ROW    20
         COL    160
         WIDTH  80
         HEIGHT 20
         VALUE "Type"
      END LABEL

      DEFINE LABEL _DBUsizelabel
         ROW    20
         COL    290
         WIDTH  60
         HEIGHT 20
         VALUE "Size"
      END LABEL

      DEFINE LABEL _DBUdecimallabel
         ROW    20
         COL    360
         WIDTH  60
         HEIGHT 16
         VALUE "Digits"
      END LABEL

      DEFINE SPINNER _DBUfieldsize
         ROW    40
         COL    290
         WIDTH  60
         HEIGHT 24
         RANGEMIN 1
         RANGEMAX 100
         VALUE 10
         ON LOSTFOCUS DBUsizelostfocus()
      END SPINNER

      DEFINE SPINNER _DBUfielddecimals
         ROW    40
         COL    360
         WIDTH  60
         HEIGHT 24
         RANGEMIN 0
         RANGEMAX 99
         ON LOSTFOCUS DBUdeclostfocus()
      END SPINNER

      DEFINE BUTTON _DBUaddline
         ROW    40
         COL    430
         WIDTH  80
         HEIGHT 28
         CAPTION "Add"
         ACTION DBUaddstruct()
      END BUTTON

      DEFINE BUTTON _DBUinsline
         ROW    70
         COL    430
         WIDTH  80
         HEIGHT 28
         CAPTION "Insert"
         ACTION DBUinsstruct()
      END BUTTON

      DEFINE BUTTON _DBUdelline
         ROW    100
         COL    430
         WIDTH  80
         HEIGHT 28
         CAPTION "Delete"
         ACTION DBUdelstruct()
      END BUTTON

      DEFINE GRID _DBUstruct
         ROW    80
         COL    30
         WIDTH  390
         HEIGHT 120
         WIDTHS {145,80,70,70}
         HEADERS {"Name","Type","Size","Decimals"}
         JUSTIFY {0,0,1,1}
         ITEMS _DBUstructarr
         on dblclick DBUlineselected()
      END GRID

      DEFINE BUTTON _DBUsavestruct
         ROW    140
         COL    430
         WIDTH  80
         HEIGHT 28
         CAPTION "Create"
         ACTION DBUsavestructure()
      END BUTTON

      DEFINE BUTTON _DBUexitnew
         ROW    170
         COL    430
         WIDTH  80
         HEIGHT 28
         CAPTION "Exit"
         ACTION DBUexitcreatenew()
      END BUTTON

   END WINDOW

   CENTER WINDOW _DBUcreadbf
   ACTIVATE WINDOW _DBUcreadbf

   RETURN NIL

FUNCTION DBUexitcreatenew

   IF len(_DBUstructarr) == 0 .or. _DBUdbfsaved
      //   DBUtogglemenu()
      RELEASE WINDOW _DBUcreadbf
   ELSE
      IF msgyesno("Are you sure to abort creating this dbf?",PROGRAM)
         //      DBUtogglemenu()
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
         msgexclamation("Field size can not be zero!",PROGRAM)
         _DBUcreadbf._DBUfieldsize.setfocus()

         RETURN NIL
      ENDIF
      DBUtypelostfocus()
      DBUsizelostfocus()
      DBUdeclostfocus()
      IF _DBUcreadbf._DBUfieldtype.value == 2 .and. _DBUcreadbf._DBUfielddecimals.value >= _DBUcreadbf._DBUfieldsize.value
         msgexclamation("You can not have decimal points more than the size!",PROGRAM)
         _DBUcreadbf._DBUfielddecimals.setfocus()

         RETURN NIL
      ENDIF
      IF len(_DBUstructarr) > 0
         FOR _DBUi := 1 to len(_DBUstructarr)
            IF upper(alltrim(_DBUcreadbf._DBUfieldname.value)) == upper(alltrim(_DBUstructarr[_DBUi,1]))
               msgexclamation("Duplicate field names are not allowed!",PROGRAM)
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
            msgexclamation("Field size can not be zero!",PROGRAM)
            _DBUcreadbf._DBUfieldsize.setfocus()

            RETURN NIL
         ENDIF
         DBUtypelostfocus()
         DBUsizelostfocus()
         DBUdeclostfocus()
         IF _DBUcreadbf._DBUfieldtype.value == 2 .and. _DBUcreadbf._DBUfielddecimals.value >= _DBUcreadbf._DBUfieldsize.value
            msgexclamation("You can not have decimal points more than the size!",PROGRAM)
            _DBUcreadbf._DBUfielddecimals.setfocus()

            RETURN NIL
         ENDIF
         IF len(_DBUstructarr) > 0
            FOR _DBUi := 1 to len(_DBUstructarr)
               IF upper(alltrim(_DBUcreadbf._DBUfieldname.value)) == upper(alltrim(_DBUstructarr[_DBUi,1])) .and. _DBUi <> _DBUcurline
                  msgexclamation("Duplicate field names are not allowed!",PROGRAM)
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
      msgexclamation("Field size can not be zero!",PROGRAM)
      _DBUcreadbf._DBUfieldsize.setfocus()

      RETURN NIL
   ENDIF
   DBUtypelostfocus()
   DBUsizelostfocus()
   DBUdeclostfocus()
   IF _DBUcreadbf._DBUfieldtype.value == 2 .and. _DBUcreadbf._DBUfielddecimals.value >= _DBUcreadbf._DBUfieldsize.value
      msgexclamation("You can not have decimal points more than the size!",PROGRAM)
      _DBUcreadbf._DBUfielddecimals.setfocus()

      RETURN NIL
   ENDIF
   IF len(_DBUstructarr) > 0
      FOR _DBUi := 1 to len(_DBUstructarr)
         IF upper(alltrim(_DBUcreadbf._DBUfieldname.value)) == upper(alltrim(_DBUstructarr[_DBUi,1]))
            msgexclamation("Duplicate field names are not allowed!",PROGRAM)
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
   PUBLIC _DBUi := 0

   IF len(_DBUname) == 0
      msgexclamation("Field Name can not be empty!",PROGRAM)
      _DBUcreadbf._DBUfieldname.setfocus()
      RETURN .f.
   ENDIF
   IF val(substr(_DBUname,1,1)) > 0 .or. substr(_DBUname,1,1) == "_"
      msgexclamation("First letter of the field name can not be a numeric character or special character!",PROGRAM)
      _DBUcreadbf._DBUfieldname.setfocus()
      RETURN .f.
   ELSE
      FOR _DBUi := 1 to len(_DBUname)
         IF at(upper(substr(_DBUname,_DBUi,1)),_DBUlegalchars) == 0
            msgexclamation("Field name contains illegal characters. Allowed characters are alphabets, numbers and the special character '_'.",PROGRAM)
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
         IF msgyesno("Are you sure to create this database file?",PROGRAM)
            dbcreate(_DBUfname1,_DBUstructarr)
            msginfo("File has been created successfully",PROGRAM)
            *         if .not. used()
            *              use &_DBUfname1
            *            _DBUfname := _DBUfname1
            *            _DBUdbfopened := .t.
            //                 DBUtogglemenu()
            RELEASE WINDOW _DBUcreadbf
            *         else
            *                 release window _DBUcreadbf
            *         endif
         ENDIF
      ENDIF
   ENDIF

   RETURN NIL
