#include "minigui.ch"
#include "dbuvar.ch"

#define CR_LF HB_OSNewLine()

FUNCTION DBUedit1

   PRIVATE _DBUFieldName:=""

   asize(_DBUcontrolarr,0)
   _DBUstructarr := dbstruct()
   IF len(_DBUstructarr) == 0

      RETURN NIL
   ENDIF

   _DBUbuttonfirstrow := _DBUwindowheight - 80
   _DBUmaxrow := _DBUbuttonfirstrow - 100
   _DBUbuttonrow := _DBUbuttonfirstrow
   _DBUbuttoncol := 10
   _DBUbuttoncount := 1
   _DBUhspace := 5
   _DBUvspace := 25
   _DBUmaxcol := _DBUwindowwidth - 20
   _DBUrow := 40
   _DBUcol := 20
   _DBUpages := 1

   FOR _DBUi := 1 to len(_DBUstructarr)
      _DBUfieldnamesize := len(alltrim(_DBUstructarr[_DBUi,1]))
      _DBUfieldsize := _DBUstructarr[_DBUi,3]
      _DBUspecifysize := .f.
      DO CASE
      CASE _DBUstructarr[_DBUi,2] == "C" .or. _DBUstructarr[_DBUi,2] == "N"
         _DBUsize := min(max(_DBUfieldnamesize+4,_DBUfieldsize) * 10,_DBUmaxcol-50)
         _DBUspecifysize := .t.
      CASE _DBUstructarr[_DBUi,2] == "D"
         _DBUsize := 120
      CASE _DBUstructarr[_DBUi,2] == "L"
         _DBUsize := (_DBUfieldnamesize*10)+30
      CASE _DBUstructarr[_DBUi,2] == "M"
         _DBUsize := _DBUmaxcol
      ENDCASE
      IF _DBUcol + _DBUsize + _DBUhspace >= _DBUmaxcol
         _DBUrow := _DBUrow + _DBUvspace + _DBUvspace
         _DBUcol := 20
      ENDIF
      IF _DBUrow + _DBUvspace + _DBUvspace >= _DBUmaxrow
         _DBUpages := _DBUpages + 1
         _DBUrow := 40
         _DBUcol := 20
      ENDIF
      aadd(_DBUcontrolarr,{_DBUrow,_DBUcol,alltrim(_DBUstructarr[_DBUi,1]),_DBUsize,"H",iif(_DBUspecifysize,_DBUfieldsize,0),,_DBUpages})
      aadd(_DBUcontrolarr,{_DBUrow+20,_DBUcol,alltrim(_DBUstructarr[_DBUi,1]),_DBUsize,_DBUstructarr[_DBUi,2],_DBUfieldsize,_DBUstructarr[_DBUi,4],_DBUpages})
      _DBUcol := _DBUcol + _DBUhspace + _DBUsize
   NEXT _DBUi
   DEFINE WINDOW _DBUedit at 0,0 width _DBUwindowwidth height _DBUwindowheight title "DBU Edit Window" modal nosize nosysmenu
      DEFINE SPLITBOX
         DEFINE TOOLBAR _DBUedittoolbar buttonsize 48,35 flat // righttext
            button _DBUfirst     caption "First"     picture "first"     action DBUeditfirstclick()
            button _DBUprevious  caption "Previous"  picture "previous"  action DBUeditpreviousclick()
            button _DBUnext      caption "Next"      picture "next"      action DBUeditnextclick()
            button _DBUlast      caption "Last"      picture "last"      action DBUeditlastclick()
         END toolbar
         DEFINE TOOLBAR _DBUedittoolbar1 buttonsize 48,35 flat // righttext
            button _DBUnewrec    caption "New"       picture "new"       action DBUeditnewrecclick()
            button _DBUsave      caption "Save"      picture "Save"      action DBUeditsaveclick()
            button _DBUdelrec    caption "Delete"    picture "delete"    action DBUeditdelrecclick()
            button _DBUrecall    caption "Recall"    picture "recall"    action DBUeditrecallclick()
            button _DBUprint     caption "Print"     picture "print"     action DBUeditprint()
            button _DBUclose     caption "Exit"      picture "exit"      action _DBUedit.release
         END toolbar
      END SPLITBOX
      DEFINE TAB _DBUrecord at 70,10 width _DBUwindowwidth - 20 height _DBUbuttonfirstrow - 90
         FOR _DBUi := 1 to _DBUpages
            DEFINE PAGE "Page "+alltrim(str(_DBUi,3,0))
               FOR _DBUj := 1 to len(_DBUcontrolarr)
                  IF _DBUcontrolarr[_DBUj,8] == _DBUi
                     _DBUfieldname := alltrim(alias())+"->"+_DBUcontrolarr[_DBUj,3]
                     _DBUControlName:=_DBUcontrolarr[_DBUj,3]
                     DO CASE
                     CASE _DBUcontrolarr[_DBUj,5] == "H" // Header
                        _DBUheader1 := _DBUcontrolarr[_DBUj,3]+"label"
                        DEFINE LABEL &_DBUheader1
                           ROW _DBUcontrolarr[_DBUj,1]
                           COL _DBUcontrolarr[_DBUj,2]
                           VALUE _DBUcontrolarr[_DBUj,3]+iif(_DBUcontrolarr[_DBUj,6] > 0,":"+alltrim(str(_DBUcontrolarr[_DBUj,6],6,0)),"")
                           WIDTH _DBUcontrolarr[_DBUj,4]
                           FONTBOLD .t.
                           //                           backcolor _DBUyellowish
                           FONTCOLOR {0,0,255}
                        END LABEL
                     CASE _DBUcontrolarr[_DBUj,5] == "C" // Character

                        DEFINE TEXTBOX &_DBUControlName
                           ROW _DBUcontrolarr[_DBUj,1]
                           COL _DBUcontrolarr[_DBUj,2]
                           TOOLTIP "Enter the value for the field "+alltrim(_DBUcontrolarr[_DBUj,3])+". Type of the field is Character. Maximum Length is "+alltrim(str(_DBUcontrolarr[_DBUj,6],6,0))+"."
                           WIDTH _DBUcontrolarr[_DBUj,4]
                           field &_DBUFieldName

                           BACKCOLOR _DBUyellowish
                           FONTCOLOR {0,0,255}
                           FONTBOLD .t.
                           MAXLENGTH _DBUcontrolarr[_DBUj,6]
                        END TEXTBOX

                     CASE _DBUcontrolarr[_DBUj,5] == "N" // Numeric

                        DEFINE TEXTBOX &_DBUControlName
                           ROW _DBUcontrolarr[_DBUj,1]
                           COL _DBUcontrolarr[_DBUj,2]
                           WIDTH _DBUcontrolarr[_DBUj,4]
                           MAXLENGTH _DBUcontrolarr[_DBUj,6]
                           TOOLTIP "Enter the value for the field "+alltrim(_DBUcontrolarr[_DBUj,3])+". Type of the field is Numeric. Maximum Length is "+alltrim(str(_DBUcontrolarr[_DBUj,6],6,0))+", with decimals "+alltrim(str(_DBUcontrolarr[_DBUj,7],3,0))+"."
                           BACKCOLOR _DBUyellowish
                           FONTCOLOR {255,0,0}
                           NUMERIC .t.
                           FONTBOLD .t.
                           field &_DBUFieldName

                           RIGHTALIGN .t.
                           IF _DBUcontrolarr[_DBUj,7] > 0
                              INPUTMASK replicate("9",_DBUcontrolarr[_DBUj,6] - _DBUcontrolarr[_DBUj,7] - 1)+"."+replicate("9",_DBUcontrolarr[_DBUj,7])
                           ENDIF
                        END TEXTBOX
                     CASE _DBUcontrolarr[_DBUj,5] == "D" // Date
                        DEFINE DATEPICKER &_DBUControlName
                           ROW _DBUcontrolarr[_DBUj,1]
                           COL _DBUcontrolarr[_DBUj,2]
                           TOOLTIP "Enter the date value for the field "+alltrim(_DBUcontrolarr[_DBUj,3])+"."
                           field &_DBUFieldName

                           FONTBOLD .t.
                           WIDTH _DBUcontrolarr[_DBUj,4]
                           SHOWNONE .t.
                        END datepicker
                     CASE _DBUcontrolarr[_DBUj,5] == "L" // Logical
                        DEFINE CHECKBOX &_DBUControlName
                           ROW _DBUcontrolarr[_DBUj,1]
                           COL _DBUcontrolarr[_DBUj,2]
                           TOOLTIP "Select True of False for this Logical Field "+alltrim(_DBUcontrolarr[_DBUj,3])+"."
                           field &_DBUFieldName

                           FONTBOLD .t.
                           BACKCOLOR _DBUyellowish
                           //                              fontcolor {0,255,0}
                           WIDTH _DBUcontrolarr[_DBUj,4]
                           CAPTION _DBUcontrolarr[_DBUj,3]
                        END CHECKBOX
                     CASE _DBUcontrolarr[_DBUj,5] == "M" // Memo
                        DEFINE TEXTBOX &_DBUControlName
                           ROW _DBUcontrolarr[_DBUj,1]
                           COL _DBUcontrolarr[_DBUj,2]
                           TOOLTIP "Enter the value for the field "+alltrim(_DBUcontrolarr[_DBUj,3])+". Type of the field is Memo."
                           FONTBOLD .t.
                           FONTCOLOR {255,0,0}
                           BACKCOLOR _DBUyellowish
                           field &_DBUFieldName

                           WIDTH _DBUcontrolarr[_DBUj,4]
                        END TEXTBOX
                     ENDCASE
                  ENDIF
               NEXT _DBUj
            END PAGE
         NEXT _DBUi
      END TAB
      DEFINE BUTTON _DBUeditgotobutton
         ROW _DBUbuttonfirstrow - 10
         COL 10
         CAPTION "Goto"
         WIDTH 50
         ACTION DBUeditgotoclick()
      END BUTTON
      DEFINE TEXTBOX _DBUeditgoto
         ROW _DBUbuttonfirstrow - 10
         COL 70
         WIDTH 100
         BACKCOLOR _DBUyellowish
         NUMERIC .t.
         RIGHTALIGN .t.
         VALUE recno()
         ON ENTER DBUeditgotoclick()
      END TEXTBOX
      IF _DBUfiltered
         DEFINE LABEL _DBUfilterconditionlabel
            ROW _DBUbuttonfirstrow - 5
            COL 200
            VALUE "Filter Condition :"
            //         backcolor _DBUyellowish
            WIDTH 150
            FONTBOLD .t.
         END LABEL
         DEFINE TEXTBOX _DBUfiltercondition
            ROW _DBUbuttonfirstrow - 10
            COL 360
            //         fontcolor {255,0,0}
            WIDTH _DBUwindowwidth - 400
            BACKCOLOR _DBUyellowish
            FONTBOLD .t.
            VALUE _DBUcondition
            READONLY .t.
         END TEXTBOX
      ENDIF
      DEFINE STATUSBAR
         statusitem "Edit "+_DBUfname
         statusitem "" width 200
         statusitem "" width 60
         statusitem "" width 60
         statusitem "" width 60
      END STATUSBAR

      * (JK)
      ON KEY ESCAPE OF _DBUedit action _DBUedit.release

   END WINDOW
   IF _DBUfiltered
      _DBUedit._DBUeditgoto.enabled := .f.
   ENDIF
   _DBUcurrec := recno()
   COUNT for deleted() to _DBUtotdeleted
   dbgoto(_DBUcurrec)
   DBUeditrefreshdbf()
   _DBUedit.center
   _DBUedit.activate

   RETURN NIL

FUNCTION DBUeditfirstclick

   GO TOP
   DBUeditrefreshdbf()

   RETURN NIL

FUNCTION DBUeditpreviousclick

   IF .not. bof()
      SKIP -1
      DBUeditrefreshdbf()
   ENDIF

   RETURN NIL

FUNCTION DBUeditnextclick

   IF .not. eof()
      SKIP
      IF eof()
         SKIP -1
      ENDIF
      DBUeditrefreshdbf()
   ENDIF

   RETURN NIL

FUNCTION DBUeditlastclick

   go bottom
   DBUeditrefreshdbf()

   RETURN NIL

FUNCTION DBUeditnewrecclick

   IF msgyesno("A new record will be appended to the dbf."+CR_LF+;
         "You can edit the record and it will be saved only after you click 'Save'."+CR_LF+;
         "Are you sure to append a blank record?","DBU")
      APPEND BLANK
      DBUeditrefreshdbf()
   ENDIF

   RETURN NIL

FUNCTION DBUeditsaveclick()

   PRIVATE _DBUcontrolName:=""

   FOR _DBUi := 1 to len(_DBUcontrolarr)
      IF _DBUControlarr[_DBUi,5] <> "H"
         _DBUcontrolName:=_DBUcontrolarr[_DBUi,3]
         DoMethod('_DBUedit', _DBUcontrolName, 'Save')
      ENDIF
   NEXT _DBUi
   RELEASE _DBUcontrolName
   DBUeditrefreshdbf()

   RETURN NIL

FUNCTION DBUeditdelrecclick

   IF .not. eof()
      DELETE
      _DBUtotdeleted := _DBUtotdeleted + 1
      DBUeditrefreshdbf()
   ENDIF

   RETURN NIL

FUNCTION DBUeditrecallclick

   IF deleted()
      RECALL
      _DBUtotdeleted := _DBUtotdeleted - 1
      DBUeditrefreshdbf()
   ENDIF

   RETURN NIL

FUNCTION DBUeditgotoclick

   IF _DBUedit._DBUeditgoto.value > 0
      IF _DBUedit._DBUeditgoto.value <= reccount()
         dbgoto(_DBUedit._DBUeditgoto.value)
         DBUeditrefreshdbf()
      ELSE
         msginfo("You had entered a record number greater than the dbf size!","DBU")
         _DBUedit._DBUeditgoto.value := reccount()
         _DBUedit._DBUeditgoto.setfocus()

         RETURN NIL
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION DBUeditrefreshdbf

   FOR _DBUi := 1 to len(_DBUcontrolarr)
      IF _DBUControlarr[_DBUi,5] <> "H"
         DoMethod('_DBUedit', _DBUcontrolarr[_DBUi,3], 'Refresh')
      ENDIF
   NEXT _DBUi
   _DBUedit._DBUeditgoto.value := recno()
   _DBUedit.statusbar.item(2) := iif(eof(),"0",alltrim(str(recno(),10,0)))+" / "+alltrim(str(reccount(),10,0))+" record(s) ("+alltrim(str(_DBUtotdeleted,5,0))+" deleted)"
   _DBUedit.statusbar.item(3) := iif(deleted()," Del","")
   _DBUedit.statusbar.item(4) := iif(_DBUfiltered,"Filtered","")
   _DBUedit.statusbar.item(5) := iif(_DBUindexed,"Indexed","")

   RETURN NIL
