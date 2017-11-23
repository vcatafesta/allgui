/*
* $Id: dbucvc.prg,v 1.12 2017/08/25 18:20:41 fyurisich Exp $
*/
/*
* ooHG IDE+ form generator
* Copyright 2002-2017 Ciro Vargas Clemow <cvc@oohg.org>
* This program is free software; you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation; either version 2, or (at your option)
* any later version.
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
* You should have received a copy of the GNU General Public License
* along with this software. If not, visit the web site:
* <http://www.gnu.org/licenses/>
*/

#include "oohg.ch"

DECLARE WINDOW _dbubrowse
DECLARE WINDOW _dbu

STATIC _DBUdbfopened
STATIC _DBUfname

MEMVAR _DBUindexed, _DBUfiltered, _DBUcondition, _DBUcontrolarr, _DBUstructarr
MEMVAR _DBUdbfsaved, _DBUoriginalarr

FUNCTION DatabaseView1( myIde )

   LOCAL lDeleted

   _DBUdbfopened := .f.
   _DBUfname := ""
   SET INTERACTIVECLOSE ON
   lDeleted := SET( _SET_DELETED, .F. )
   DEFINE WINDOW _DBU at 0,0 width 800 height 600 title "ooHG IDE Plus - Data Manager" icon "IDE_DM" child backcolor myIde:asystemcolor on init DBUtogglemenu() on release DBUclosedbfs()
      DEFINE MAIN MENU
         POPUP "File"
            item "Create" action DBUcreanew()                          image "IDE_DM_MENUNEW"
            item "Open" action DBUopendbf()                            image "IDE_OPENDBF"
            item "Close" action DBUclosedbf() name _DBUitem1           image "IDE_DM_MENUCLOSE"
            item "Exit" action _DBU.release()                          image "IDE_EXIT"
         end popup
         POPUP "Edit"
            item "Structure" action DBUmodistruct() name _DBUitem2     image "IDE_DM_MENUSTRU"
            item "Edit Mode" action DBUeditworkarea() name _DBUitem3   image "IDE_DM_MENUEDIT"
            item "Browse" action DBUbrowse1() name _DBUitem4           image "IDE_DM_BROWSE"
         end popup
         POPUP "Delete"
            item "Recall" action DBUrecallrec() name _DBUitem5         image "IDE_DM_MENURECA"
            item "Pack" action DBUpackdbf() name _DBUitem6             image "IDE_DM_MENUPACK"
            item "Zap" action DBUzapdbf() name _DBUitem7               image "IDE_DM_MENUZAP"
         end popup
      end menu
      DEFINE STATUSBAR
         statusitem "DBU by S. Rathinagiri" width 150
         statusitem "Empty" width 400 action DBUopendbf()
         date width 100
         clock width 100
      END STATUSBAR
      DEFINE CONTEXT menu of _DBU
         menuitem "Create" action DBUcreanew()                         image "IDE_DM_MENUNEW"
         menuitem "Open" action DBUopendbf()                           image "IDE_OPEN"
         menuitem "Close" action DBUclosedbf() name _DBUcontextclose   image "IDE_DM_MENUCLOSE"
         separator
         menuitem "Edit" action DBUeditworkarea() name _DBUcontextedit image "IDE_DM_MENUEDIT"
         menuitem "Browse" action DBUbrowse1() name _DBUcontextbrowse  image "IDE_DM_BROWSE"
      end menu
      DEFINE LABEL labeldbu
         row 140
         col 60
         width 700
         height 300
         value "Based upon Rathinagiri's DBU." + hb_OsNewLine() + "Comments are welcome at srgiri@vsnl.com"
      END LABEL
   END WINDOW
   _dbu.labeldbu.fontname:="arial"
   _dbu.labeldbu.fontsize:=36
   CENTER WINDOW _DBU
   ACTIVATE WINDOW _DBU
   IF select( "_DBUalias" ) > 0
      _DBUalias->( dbCloseArea() )
   ENDIF
   SET INTERACTIVECLOSE OFF
   SET( _SET_DELETED, lDeleted )

   RETURN NIL

FUNCTION DBUcreanew

   creanew1()

   RETURN NIL

FUNCTION DBUopendbf

   LOCAL _DBUfname1

   _DBUfname1 := getfile({{"DataBase File","*.dbf"}},"Select a dbf to open")
   _DBUfname1 := alltrim(_DBUfname1)
   IF len(_DBUfname1) > 0
      IF select( "_DBUalias" ) > 0
         IF msgyesno( "Close currently opened dbf?", 'OOHG IDE+' )
            _DBUalias->( dbCloseArea() )
            USE &_DBUfname1 ALIAS _DBUalias NEW
            _DBUfname := _DBUfname1
            _DBUdbfopened := .t.
            DBUtogglemenu()
         ENDIF
      ELSE
         USE &_DBUfname1 ALIAS _DBUalias NEW
         _DBUfname := _DBUfname1
         _DBUdbfopened := .t.
         DBUtogglemenu()
         DBUeditworkarea()
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION DBUclosedbf

   IF select( "_DBUalias" ) > 0
      IF MsgYesNo( "Close the currently opened DBF?", 'OOHG IDE+' )
         _DBUalias->( dbCloseArea() )
         _DBUfname := ""
         _DBUdbfopened := .F.
         DBUtogglemenu()
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION DBUmodistruct

   LOCAL _DBUi, _DBUtype1

   IF ! select( "_DBUalias" ) > 0

      RETURN NIL
   ENDIF
   _DBUoriginalarr := _DBUalias->( dbstruct() )
   _DBUstructarr := _DBUalias->( dbstruct() )
   _DBUdbfsaved := .f.
   DEFINE WINDOW _DBUcreadbf at 0,0 width 600 height 500 title "Modify DataBase Table" modal nosize nosysmenu
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
         value "Name"
      END LABEL
      DEFINE LABEL _DBUtypelabel
         row 40
         col 195
         width 100
         value "Type"
      END LABEL
      DEFINE LABEL _DBUsizelabel
         row 40
         col 300
         width 100
         value "Size"
      END LABEL
      DEFINE LABEL _DBUdecimallabel
         row 40
         col 405
         width 75
         value "Decimals"
      END LABEL
      DEFINE TEXTBOX _DBUfieldname
         row 70
         col 40
         width 150
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
         //    on change typelostfocus()
      END COMBOBOX
      DEFINE TEXTBOX _DBUfieldsize
         row 70
         col 300
         value 10
         numeric .t.
         width 100
         on lostfocus DBUsizelostfocus()
         rightalign .t.
      END TEXTBOX
      DEFINE TEXTBOX _DBUfielddecimals
         row 70
         col 405
         width 75
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
         flat .T.
         action DBUaddstruct()
      END BUTTON
      DEFINE BUTTON _DBUinsline
         row 120
         col 225
         caption "Insert"
         width 100
         flat .T.
         action DBUinsstruct()
      END BUTTON
      DEFINE BUTTON _DBUdelline
         row 120
         col 400
         caption "Delete"
         width 100
         flat .T.
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
         items _DBUstructarr
         on dblclick DBUlineselected()
         height 120
      END GRID
      DEFINE BUTTON _DBUsavestruct
         row 400
         col 200
         caption "Modify"
         flat .T.
         action DBUmodistructure()
      END BUTTON
      DEFINE BUTTON _DBUexitnew
         row 400
         col 400
         caption "Exit"
         flat .T.
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
   DBUtogglemenu()

   RETURN NIL

FUNCTION DBUbrowse1

   LOCAL _DBUanames := {}
   LOCAL _DBUasizes := {}
   LOCAL _DBUajustify := {}
   LOCAL _DBUi, _DBUsize, _DBUsize1

   IF ! select( "_DBUalias" ) > 0
      msginfo( "No database is in use.", 'OOHG IDE+' )

      RETURN NIL
   ENDIF
   _DBUstructarr := _DBUalias->( dbstruct() )
   FOR _DBUi := 1 to len(_DBUstructarr)
      aadd(_DBUanames,_DBUstructarr[_DBUi,1])
      _DBUsize := len(alltrim(_DBUstructarr[_DBUi,1]))*15
      _DBUsize1 := _DBUstructarr[_DBUi,3] * 15
      aadd(_DBUasizes,iif(_DBUsize < _DBUsize1,_DBUsize1,_DBUsize))
      IF _DBUi == 1
         aadd(_DBUajustify,0)
      ELSE
         IF _DBUstructarr[_DBUi,2] == "N"
            aadd(_DBUajustify,1)
         ELSE
            aadd(_DBUajustify,0)
         ENDIF
      ENDIF
   NEXT _DBUi
   IF len(_DBUanames) == 0

      RETURN NIL
   ENDIF
   DEFINE WINDOW _DBUbrowse at 0,0 width 700 height 500 title "Browse Window ("+_DBUfname+")" child nomaximize nominimize on init {|| _dbubrowse.maximize}
      DEFINE BROWSE _DBUbrowse1
         row 25
         col 80
         width 600
         height 400
         headers _DBUanames
         widths _DBUasizes
         fields _DBUanames
         justify _DBUajustify
         allowappend .t.
         allowdelete .t.
         allowedit .t.
         workarea _DBUalias
         value 1
         inplaceedit .T.
         doublebuffer .t.
      end browse
      DEFINE LABEL label_bro
         row 450
         col 150
         value  "ALT-A (Add record) - Delete (Delete record) - DblClick (Modify record)"
         width 500
      END LABEL
   END WINDOW
   CENTER WINDOW _DBUbrowse
   ACTIVATE WINDOW _DBUbrowse
   DBUtogglemenu()
   _dbu.labeldbu.setfocus

   RETURN NIL

FUNCTION delrec

   IF select( "_DBUalias" ) > 0
      IF msgyesno( "Are you sure?", 'OOHG IDE+' )
         _DBUalias->( dbGoTo( _DBUbrowse._DBUbrowse1.value ) )
         IF _DBUalias->( rlock() )
            _DBUalias->( dbDelete() )
            _DBUalias->( dbUnlock() )
         ELSE
            msgstop("The record can't be locked.", 'OOHG IDE+' )
         ENDIF
         _DBUbrowse._DBUbrowse1.refresh
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION DBUeditworkarea()

   edit1()
   DBUtogglemenu()

   RETURN NIL

FUNCTION DBUrecallrec

   IF select( "_DBUalias" ) > 0
      IF MsgYesNo( "All deleted records will be recalled. If you want to recall a particular record, try using edit mode. Are you sure you want to recall all?", 'OOHG IDE+' )
         _DBUalias->( dbEval( {|| dbRecall()} ) )
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION DBUpackdbf

   IF select( "_DBUalias" ) > 0
      IF msgyesno( "All deleted records will be physically removed from the dbf. Are you sure you want to pack the dbf?", 'OOHG IDE+' )
         _DBUalias->( __dbPack() )
         DBUtogglemenu()
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION DBUzapdbf

   IF select( "_DBUalias" ) > 0
      IF msgyesno("Are you sure you want to zap this dbf? You can not undo.", 'OOHG IDE+' )
         _DBUalias->( __dbZap() )
         DBUtogglemenu()
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION DBUtogglemenu

   IF .not. _DBUdbfopened
      _DBU.statusbar.item(2) := "Empty"
      _DBU._DBUcontextclose.enabled := .f.
      _DBU._DBUcontextedit.enabled := .f.
      _DBU._DBUcontextbrowse.enabled := .f.
      _DBU._DBUitem1.enabled := .f.
      _DBU._DBUitem2.enabled := .f.
      // _DBU._DBUitem3.enabled := .f.
      _DBU._DBUitem4.enabled := .f.
      _DBU._DBUitem5.enabled := .f.
      _DBU._DBUitem6.enabled := .f.
      _DBU._DBUitem7.enabled := .f.
      // _DBU._DBUitem8.enabled := .f.
   ELSE
      _DBU.statusbar.item(2) := _DBUfname+" (Fields : "+alltrim(str(_DBUalias->(fcount()),5,0))+") (Records : "+alltrim(str(_DBUalias->(reccount()),10,0))+")"
      _DBU._DBUcontextclose.enabled := .t.
      _DBU._DBUcontextedit.enabled := .t.
      _DBU._DBUcontextbrowse.enabled := .t.
      _DBU._DBUitem1.enabled := .t.
      _DBU._DBUitem2.enabled := .t.
      _DBU._DBUitem3.enabled := .t.
      _DBU._DBUitem4.enabled := .t.
      _DBU._DBUitem5.enabled := .t.
      _DBU._DBUitem6.enabled := .t.
      _DBU._DBUitem7.enabled := .t.
      // _DBU._DBUitem8.enabled := .t.
   ENDIF

   RETURN NIL

FUNCTION DBUclosedbfs()

   IF select( "_DBUalias" ) > 0
      _DBUalias->( dbCloseArea() )
   ENDIF

   RETURN NIL

FUNCTION DBUmodistructure

   LOCAL _DBUfname1, _DBUi, _DBUnewname, _DBUbackname, _DBUmodarr, _DBUfieldname
   LOCAL _DBUline

   IF .not. msgyesno("Caution: If you have modified either the field name or the field type, the data for that fields can't be saved in the modified dbf. However, a backup file (.bak) will be created. Are you sure you want to modify the structure?", 'OOHG IDE+' )

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
   IF len(_DBUstructarr) > 0
      _DBUfname1 := "DBUtemp"
      IF len(_DBUfname1) > 0
         _DBUalias->( dbCloseArea() )
         dbcreate(_DBUfname1,_DBUstructarr)
         USE &_DBUfname NEW ALIAS _DBUalias
         USE &_DBUfname1 NEW ALIAS DBUtemp
         _DBUalias->( dbGoTop() )
         IF len(_DBUmodarr) > 0
            DO WHILE ! _DBUalias->( eof() )
               _DBUnew->( dbAppend() )
               FOR _DBUi := 1 to len(_DBUmodarr)
                  _DBUfieldname := _DBUstructarr[_DBUmodarr[_DBUi],1]
                  REPLACE _DBUnew->&_DBUfieldname with _DBUalias->&_DBUfieldname
               NEXT _DBUi
               COMMIT
               _DBUalias->( dbSkip() )
            ENDDO
         ENDIF
         _DBUalias->( dbCloseArea() )
         _DBUnew->( dbCloseArea() )
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
         USE &_DBUfname NEW ALIAS _DBUalias
         RELEASE WINDOW _DBUcreadbf
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION DBUexitmodidbf

   IF len(_DBUstructarr) == 0 .or. _DBUdbfsaved
      RELEASE WINDOW _DBUcreadbf
   ELSE
      IF msgyesno( "Are you sure you want to abort modifying this dbf?", 'OOHG IDE+' )
         RELEASE WINDOW _DBUcreadbf
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION creanew1

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
         value "Name"
      END LABEL
      DEFINE LABEL _DBUtypelabel
         row 40
         col 195
         width 100
         value "Type"
      END LABEL
      DEFINE LABEL _DBUsizelabel
         row 40
         col 300
         width 100
         value "Size"
      END LABEL
      DEFINE LABEL _DBUdecimallabel
         row 40
         col 405
         width 75
         value "Decimals"
      END LABEL
      DEFINE TEXTBOX _DBUfieldname
         row 70
         col 40
         width 150
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
         //      on change DBUtypelostfocus()
      END COMBOBOX
      DEFINE TEXTBOX _DBUfieldsize
         row 70
         col 300
         value 10
         numeric .t.
         width 100
         on lostfocus DBUsizelostfocus()
         rightalign .t.
      END TEXTBOX
      DEFINE TEXTBOX _DBUfielddecimals
         row 70
         col 405
         width 75
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
         flat .T.
         action DBUaddstruct()
      END BUTTON
      DEFINE BUTTON _DBUinsline
         row 120
         col 225
         caption "Insert"
         width 100
         flat .T.
         action DBUinsstruct()
      END BUTTON
      DEFINE BUTTON _DBUdelline
         row 120
         col 400
         caption "Delete"
         width 100
         flat .T.
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
         on dblclick DBUlineselected()
         height 120
      END GRID
      DEFINE BUTTON _DBUsavestruct
         row 400
         col 200
         caption "Create"
         flat .T.
         action DBUsavestructure()
      END BUTTON
      DEFINE BUTTON _DBUexitnew
         row 400
         col 400
         caption "Exit"
         flat .T.
         action DBUexitcreatenew()
      END BUTTON
   END WINDOW
   CENTER WINDOW _DBUcreadbf
   ACTIVATE WINDOW _DBUcreadbf

   RETURN NIL

FUNCTION DBUexitcreatenew

   IF len(_DBUstructarr) == 0 .or. _DBUdbfsaved
      RELEASE WINDOW _DBUcreadbf
   ELSE
      IF msgyesno( "Are you sure you want to abort creating this dbf?", 'OOHG IDE+')
         RELEASE WINDOW _DBUcreadbf
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION DBUaddstruct

   LOCAL _DBUi, _DBUcurline, _DBUtype1

   IF _DBUcreadbf._DBUaddline.caption == "Add"
      IF .not. DBUnamecheck()

         RETURN NIL
      ENDIF
      IF _DBUcreadbf._DBUfieldsize.value == 0
         msgexclamation( "Field size can't be zero.", 'OOHG IDE+')
         _DBUcreadbf._DBUfieldsize.setfocus()

         RETURN NIL
      ENDIF
      DBUtypelostfocus()
      DBUsizelostfocus()
      DBUdeclostfocus()
      IF _DBUcreadbf._DBUfieldtype.value == 2 .and. _DBUcreadbf._DBUfielddecimals.value >= _DBUcreadbf._DBUfieldsize.value
         msgexclamation("Number of decimals exceeds the defined field size.", 'OOHG IDE+')
         _DBUcreadbf._DBUfielddecimals.setfocus()

         RETURN NIL
      ENDIF
      IF len(_DBUstructarr) > 0
         FOR _DBUi := 1 to len(_DBUstructarr)
            IF upper(alltrim(_DBUcreadbf._DBUfieldname.value)) == upper(alltrim(_DBUstructarr[_DBUi,1]))
               msgexclamation("Duplicate field names are not allowed.", 'OOHG IDE+')
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
            msgexclamation("Field size can't be zero.", 'OOHG IDE+')
            _DBUcreadbf._DBUfieldsize.setfocus()

            RETURN NIL
         ENDIF
         DBUtypelostfocus()
         DBUsizelostfocus()
         DBUdeclostfocus()
         IF _DBUcreadbf._DBUfieldtype.value == 2 .and. _DBUcreadbf._DBUfielddecimals.value >= _DBUcreadbf._DBUfieldsize.value
            msgexclamation("Number of decimals exceeds the defined field size.", 'OOHG IDE+')
            _DBUcreadbf._DBUfielddecimals.setfocus()

            RETURN NIL
         ENDIF
         IF len(_DBUstructarr) > 0
            FOR _DBUi := 1 to len(_DBUstructarr)
               IF upper(alltrim(_DBUcreadbf._DBUfieldname.value)) == upper(alltrim(_DBUstructarr[_DBUi,1])) .and. _DBUi <> _DBUcurline
                  msgexclamation("Duplicate field names are not allowed.", 'OOHG IDE+')
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

   LOCAL _DBUi, _DBUpos, _DBUtype1

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
      msgexclamation("Field size can't be zero.", 'OOHG IDE+')
      _DBUcreadbf._DBUfieldsize.setfocus()

      RETURN NIL
   ENDIF
   DBUtypelostfocus()
   DBUsizelostfocus()
   DBUdeclostfocus()
   IF _DBUcreadbf._DBUfieldtype.value == 2 .and. _DBUcreadbf._DBUfielddecimals.value >= _DBUcreadbf._DBUfieldsize.value
      msgexclamation("Number of decimals exceeds the defined field size.", 'OOHG IDE+' )
      _DBUcreadbf._DBUfielddecimals.setfocus()

      RETURN NIL
   ENDIF
   IF len(_DBUstructarr) > 0
      FOR _DBUi := 1 to len(_DBUstructarr)
         IF upper(alltrim(_DBUcreadbf._DBUfieldname.value)) == upper(alltrim(_DBUstructarr[_DBUi,1]))
            msgexclamation("Duplicate field names are not allowed.", 'OOHG IDE+' )
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

   LOCAL _DBUi, _DBUcurline, _DBUtype1

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
      msgexclamation("Field name can't be empty.", 'OOHG IDE+' )
      _DBUcreadbf._DBUfieldname.setfocus()

      RETURN .f.
   ENDIF
   IF val(substr(_DBUname,1,1)) > 0 .or. substr(_DBUname,1,1) == "_"
      msgexclamation("First letter of the field name can't be a numeric character or special character.", 'OOHG IDE+' )
      _DBUcreadbf._DBUfieldname.setfocus()

      RETURN .f.
   ELSE
      FOR _DBUi := 1 to len(_DBUname)
         IF at(upper(substr(_DBUname,_DBUi,1)),_DBUlegalchars) == 0
            msgexclamation("Field name contains illegal characters. Allowed characters are letters, numbers and the special character '_'.", 'OOHG IDE+' )
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

   LOCAL _DBUcurline := _DBUcreadbf._DBUstruct.value

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

   LOCAL _DBUfname1

   IF len(_DBUstructarr) > 0
      _DBUfname1 := alltrim(putfile({{"Database File","*.dbf"}},"Enter a filename"))
      IF len(_DBUfname1) > 0
         IF msgyesno("Are you sure you want to create this database file?", 'OOHG IDE+' )
            dbcreate(_DBUfname1,_DBUstructarr)
            msginfo( "File has been created successfully.", 'OOHG IDE+' )
            IF ! select( "_DBUalias" ) > 0
               USE &_DBUfname1 NEW ALIAS _DBUalias
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

FUNCTION edit1()

   LOCAL lDeleted, _DBUi, _DBUfieldnames, _DBUJ, _DBUpages, _DBUheader1, _DBUcol
   LOCAL _DBUhspace, _DBUfieldsize, _DBUsize, _DBUrow, _DBUmaxrow, _DBUvspace
   LOCAL _DBUmaxcol, _DBUfieldnamesize, _DBUspecifysize

   _DBUstructarr := _DBUalias->( dbstruct() )
   _DBUcondition := ""
   _DBUfiltered := .f.
   IF len(_DBUstructarr) == 0

      RETURN NIL
   ENDIF
   lDeleted := SET( _SET_DELETED, .T. )
   _DBUindexed := .f.
   _DBUhspace := 5
   _DBUvspace := 30
   _DBUfieldnames := {}
   _DBUmaxrow := 350
   _DBUmaxcol := 700
   _DBUrow := 40
   _DBUcol := 20
   _DBUcontrolarr := {} // {row,col,name,width,type,size,decimals,page}
   _DBUpages := 1
   aadd(_DBUfieldnames,"<None>")
   FOR _DBUi := 1 to len(_DBUstructarr)
      _DBUfieldnamesize := len(alltrim(_DBUstructarr[_DBUi,1]))
      aadd(_DBUfieldnames,alltrim(_DBUstructarr[_DBUi,1]))
      _DBUfieldsize := _DBUstructarr[_DBUi,3]
      _DBUspecifysize := .f.
      DO CASE
      CASE _DBUstructarr[_DBUi,2] == "C" .or. _DBUstructarr[_DBUi,2] == "N"
         _DBUsize := iif(max(_DBUfieldnamesize+4,_DBUfieldsize) > 10,150,max(_DBUfieldnamesize+4,_DBUfieldsize)*10)
         _DBUspecifysize := .t.
      CASE _DBUstructarr[_DBUi,2] == "D"
         _DBUsize := iif(max(_DBUfieldnamesize,_DBUfieldsize) > 10,150,120)
      CASE _DBUstructarr[_DBUi,2] == "L"
         _DBUsize := (_DBUfieldnamesize*10)+30
      CASE _DBUstructarr[_DBUi,2] == "M"
         _DBUsize := 300
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

   DEFINE WINDOW _DBUeditdbf at 0,0 width 750 height 520 title "Edit DataBase Records of "+alltrim(_DBUfname) child nosize nosysmenu
      DEFINE TAB _DBUrecord at 10,10 width 725 height 360
         FOR _DBUi := 1 to _DBUpages
            DEFINE PAGE "Page "+alltrim(str(_DBUi,3,0))
               FOR _DBUj := 1 to len(_DBUcontrolarr)
                  IF _DBUcontrolarr[_DBUj,8] == _DBUi
                     DO CASE
                     CASE _DBUcontrolarr[_DBUj,5] == "H" // Header
                        _DBUheader1 := _DBUcontrolarr[_DBUj,3]+"label"
                        DEFINE LABEL &_DBUheader1
                           row _DBUcontrolarr[_DBUj,1]
                           col _DBUcontrolarr[_DBUj,2]
                           value _DBUcontrolarr[_DBUj,3]+iif(_DBUcontrolarr[_DBUj,6] > 0,":"+alltrim(str(_DBUcontrolarr[_DBUj,6],6,0)),"")
                           width _DBUcontrolarr[_DBUj,4]
                           fontcolor {0,0,255}
                        END LABEL
                     CASE _DBUcontrolarr[_DBUj,5] == "C" // Character
                        DEFINE TEXTBOX &( _DBUcontrolarr[_DBUj,3] )
                           row _DBUcontrolarr[_DBUj,1]
                           col _DBUcontrolarr[_DBUj,2]
                           tooltip "Enter the value for the field "+alltrim(_DBUcontrolarr[_DBUj,3])+". Type of the field is Character. Maximum Length is "+alltrim(str(_DBUcontrolarr[_DBUj,6],6,0))+"."
                           width _DBUcontrolarr[_DBUj,4]
                           maxlength _DBUcontrolarr[_DBUj,6]
                        END TEXTBOX
                     CASE _DBUcontrolarr[_DBUj,5] == "N" // Numeric
                        DEFINE TEXTBOX &( _DBUcontrolarr[_DBUj,3] )
                           row _DBUcontrolarr[_DBUj,1]
                           col _DBUcontrolarr[_DBUj,2]
                           width _DBUcontrolarr[_DBUj,4]
                           maxlength _DBUcontrolarr[_DBUj,6]
                           tooltip "Enter the value for the field "+alltrim(_DBUcontrolarr[_DBUj,3])+". Type of the field is Numeric. Maximum Length is "+alltrim(str(_DBUcontrolarr[_DBUj,6],6,0))+", with decimals "+alltrim(str(_DBUcontrolarr[_DBUj,7],3,0))+"."
                           numeric .t.
                           rightalign .t.
                           IF _DBUcontrolarr[_DBUj,7] > 0
                              inputmask replicate("9",_DBUcontrolarr[_DBUj,6] - _DBUcontrolarr[_DBUj,7] - 1)+"."+replicate("9",_DBUcontrolarr[_DBUj,7])
                           ENDIF
                        END TEXTBOX
                     CASE _DBUcontrolarr[_DBUj,5] == "D" // Date
                        DEFINE DATEPICKER &( _DBUcontrolarr[_DBUj,3] )
                           row _DBUcontrolarr[_DBUj,1]
                           col _DBUcontrolarr[_DBUj,2]
                           tooltip "Enter the date value for the field "+alltrim(_DBUcontrolarr[_DBUj,3])+"."
                           width _DBUcontrolarr[_DBUj,4]
                        end datepicker
                     CASE _DBUcontrolarr[_DBUj,5] == "L" // Logical
                        DEFINE CHECKBOX &( _DBUcontrolarr[_DBUj,3] )
                           row _DBUcontrolarr[_DBUj,1]
                           col _DBUcontrolarr[_DBUj,2]
                           tooltip "Select True of False for this Logical Field "+alltrim(_DBUcontrolarr[_DBUj,3])+"."
                           width _DBUcontrolarr[_DBUj,4]
                           caption _DBUcontrolarr[_DBUj,3]
                        END CHECKBOX
                     CASE _DBUcontrolarr[_DBUj,5] == "M" // Memo
                        DEFINE TEXTBOX &( _DBUcontrolarr[_DBUj,3] )
                           row _DBUcontrolarr[_DBUj,1]
                           col _DBUcontrolarr[_DBUj,2]
                           tooltip "Enter the value for the field "+alltrim(_DBUcontrolarr[_DBUj,3])+". Type of the field is Memo."
                           width _DBUcontrolarr[_DBUj,4]
                        END TEXTBOX
                     ENDCASE
                  ENDIF
               NEXT _DBUj
            END PAGE
         NEXT _DBUi
      END TAB
      DEFINE BUTTON _DBUfirst
         row 390
         col 10
         caption "|<"
         tooltip "Go to first record."
         width 40
         flat .T.
         action DBUfirstclick()
      END BUTTON
      DEFINE BUTTON _DBUprevious
         row 390
         col 70
         caption "<"
         tooltip "Go to previous record."
         width 40
         flat .T.
         action DBUpreviousclick()
      END BUTTON
      DEFINE BUTTON _DBUnext
         row 390
         col 130
         caption ">"
         tooltip "Go to next record."
         width 40
         flat .T.
         action DBUnextclick()
      END BUTTON
      DEFINE BUTTON _DBUlast
         row 390
         col 190
         caption ">|"
         tooltip "Go to last record."
         width 40
         flat .T.
         action DBUlastclick()
      END BUTTON
      DEFINE BUTTON _DBUnewrec
         row 390
         col 250
         caption "New"
         tooltip "Append blank record."
         width 50
         flat .T.
         action DBUnewrecclick()
      END BUTTON
      DEFINE BUTTON _DBUsave
         row 390
         col 320
         caption "Save"
         tooltip "Commit all changes to file."
         width 50
         flat .T.
         action DBUsaveclick()
      END BUTTON
      DEFINE BUTTON _DBUdelrec
         row 390
         col 390
         caption "Delete"
         tooltip "Mark current record as deleted."
         width 50
         flat .T.
         action DBUdelrecclick()
      END BUTTON
      DEFINE BUTTON _DBUrecall
         row 390
         col 450
         caption "Recall"
         tooltip "Recall deleted record."
         width 50
         flat .T.
         action DBUrecallclick()
      END BUTTON
      DEFINE BUTTON _DBUgoto
         row 390
         col 520
         caption "Goto"
         tooltip "Go to record number."
         width 50
         flat .T.
         action DBUgotoclick()
      END BUTTON
      IF _DBUalias->(reccount()) <= 65535
         DEFINE SLIDER _DBUrecgotoslider
            row 420
            col 10
            width 490
            tooltip "Select a record number and click 'Goto' to edit it."
            rangemin IIF( _DBUalias->( reccount() ) == 0, 0, 1 )
            rangemax _DBUalias->( reccount() )
            on change _DBUeditdbf._DBUrecgoto.value := _DBUeditdbf._DBUrecgotoslider.value
         end slider
      ENDIF
      DEFINE TEXTBOX _DBUrecgoto
         row 420
         col 520
         width 50
         numeric .t.
         rightalign .t.
         value iif(_DBUalias->(reccount()) == 0,0,_DBUalias->(recno()))
         on enter DBUgotoclick()
      END TEXTBOX
      DEFINE BUTTON _DBUsearch
         row 390
         col 590
         caption "Filter"
         tooltip "Filter the database file by a given condition."
         width 50
         flat .T.
         action DBUsearchclick()
      END BUTTON
      DEFINE COMBOBOX _DBUindexfield
         row 420
         col 600
         width 100
         items _DBUfieldnames
         value 1
         on change DBUindexchange()
         tooltip "Index file on a chosen field."
      END COMBOBOX
      DEFINE BUTTON _DBUcloseedit
         row 390
         col 660
         caption "Close"
         tooltip "Close edit window."
         width 50
         flat .T.
         action DBUcloseedit1()
      END BUTTON
      DEFINE STATUSBAR size 12
         statusitem ""
         statusitem ""
         statusitem "" width 80
         statusitem "" width 80
      END STATUSBAR
   END WINDOW
   CENTER WINDOW _DBUeditdbf
   DBUfirstclick()
   ACTIVATE WINDOW _DBUeditdbf
   SET( _SET_DELETED, lDeleted )

   RETURN NIL

FUNCTION DBUfirstclick

   _DBUalias->( dbGoTop() )
   DBUrefreshdbf()

   RETURN NIL

FUNCTION DBUpreviousclick

   IF _DBUalias->(recno()) > 1
      _DBUalias->( dbSkip( -1 ) )
      DBUrefreshdbf()
   ENDIF

   RETURN NIL

FUNCTION DBUnextclick

   IF .not. _DBUalias->(eof()) .and. _DBUalias->(recno()) <> _DBUalias->(reccount())
      _DBUalias->( dbSkip() )
      DBUrefreshdbf()
   ENDIF

   RETURN NIL

FUNCTION DBUlastclick

   _DBUalias->( dbGoBottom() )
   DBUrefreshdbf()

   RETURN NIL

FUNCTION DBUnewrecclick

   IF msgyesno("A new record will be appended to the dbf. You can edit the record and it will be saved only after you click 'Save'. Are you sure you want to append a blank record?", 'OOHG IDE+' )
      _DBUalias->( dbAppend() )
      IF _DBUalias->(reccount()) <= 65535
         _DBUeditdbf._DBUrecgotoslider.rangemax := _DBUalias->(reccount())
         IF _DBUeditdbf._DBUrecgotoslider.rangemin == 0
            _DBUeditdbf._DBUrecgotoslider.rangemin := 1
         ENDIF
      ENDIF
      DBUrefreshdbf()
      _DBUeditdbf.&( _DBUcontrolarr[2,3] ).setfocus()
   ENDIF

   RETURN NIL

FUNCTION DBUsaveclick

   LOCAL _DBUi, _DBUpos1

   IF .not. _DBUalias->(eof())
      FOR _DBUi := 1 to len(_DBUcontrolarr)
         IF _DBUcontrolarr[_DBUi,5] <> "H"
            IF _DBUcontrolarr[_DBUi,5] <> "L"
               _DBUpos1 := _DBUalias->( fieldpos(_DBUcontrolarr[_DBUi,3]) )
               IF _DBUpos1 > 0
                  _DBUalias->( fieldput(_DBUpos1,_DBUeditdbf.&( _DBUcontrolarr[_DBUi,3] ).value) )
               ENDIF
            ELSE
               _DBUpos1 := _DBUalias->( fieldpos(_DBUcontrolarr[_DBUi,3]) )
               IF _DBUpos1 > 0
                  IF _DBUalias->( fieldget(_DBUpos1) ) <> nil
                     _DBUalias->( fieldput(_DBUpos1,_DBUeditdbf.&( _DBUcontrolarr[_DBUi,3] ).value) )
                  ENDIF
               ENDIF
            ENDIF
         ENDIF
      NEXT _DBUi
      COMMIT
      DBUrefreshdbf()
   ELSE
      msginfo( "The record pointer is at EOF. You must click New to append a blank record and then click Save.", 'OOHG IDE+' )
   ENDIF

   RETURN NIL

FUNCTION DBUdelrecclick

   IF .not. _DBUalias->(eof())
      _DBUalias->( dbDelete() )
      DBUrefreshdbf()
   ENDIF

   RETURN NIL

FUNCTION DBUrecallclick

   IF _DBUalias->( Deleted() )
      _DBUalias->( dbRecall() )
      DBUrefreshdbf()
   ENDIF

   RETURN NIL

FUNCTION DBUgotoclick

   IF _DBUeditdbf._DBUrecgoto.value > 0
      IF _DBUeditdbf._DBUrecgoto.value <= _DBUalias->(reccount())
         _DBUalias->( dbgoto(_DBUeditdbf._DBUrecgoto.value) )
         DBUrefreshdbf()

         RETURN NIL
      ELSE
         msginfo( "You have entered a record number greater than the dbf's record count.", 'OOHG IDE+' )
         _DBUeditdbf._DBUrecgoto.value := _DBUalias->(reccount())
         _DBUeditdbf._DBUrecgoto.setfocus()

         RETURN NIL
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION DBUsearchclick

   LOCAL _DBUdbffunctions, _DBUfieldsarr, _DBUi

   _DBUstructarr := _DBUalias->( dbstruct() )
   _DBUfieldsarr := {}
   FOR _DBUi := 1 to len(_DBUstructarr)
      aadd(_DBUfieldsarr,{_DBUstructarr[_DBUi,1]})
   NEXT _DBUi
   _DBUdbffunctions := {{"ctod()"},{"recno()"},{"max()"},{"min()"},{"deleted()"},{"alltrim()"},{"upper()"},{"lower()"},{"int()"},{"max()"}}
   DEFINE WINDOW _DBUfilterbox at 0,0 width 650 height 400 title "Filter Box" modal nosize nosysmenu
      DEFINE EDITBOX _DBUfiltercondition
         row 30
         col 30
         width 400
         height 100
         value _DBUcondition
      end editbox
      DEFINE GRID _DBUfieldnames
         row 200
         col 30
         value 1
         headers {"Field Name"}
         widths {195}
         items _DBUfieldsarr
         on dblclick _DBUfilterbox._DBUfiltercondition.value := alltrim(_DBUfilterbox._DBUfiltercondition.value)+" "+alltrim(_DBUfieldsarr[_DBUfilterbox._DBUfieldnames.value,1])
         width 200
         height 100
      END GRID
      DEFINE BUTTON _DBUlessthan
         row 200
         col 250
         width 20
         caption "<"
         flat .T.
         action _DBUfilterbox._DBUfiltercondition.value := alltrim(_DBUfilterbox._DBUfiltercondition.value)+" <"
      END BUTTON
      DEFINE BUTTON _DBUgreaterthan
         row 200
         col 280
         width 20
         caption ">"
         flat .T.
         action _DBUfilterbox._DBUfiltercondition.value := alltrim(_DBUfilterbox._DBUfiltercondition.value)+" >"
      END BUTTON
      DEFINE BUTTON _DBUequal
         row 200
         col 310
         width 20
         caption "=="
         flat .T.
         action _DBUfilterbox._DBUfiltercondition.value := alltrim(_DBUfilterbox._DBUfiltercondition.value)+" =="
      END BUTTON
      DEFINE BUTTON _DBUnotequal
         row 200
         col 340
         width 20
         caption "<>"
         flat .T.
         action _DBUfilterbox._DBUfiltercondition.value := alltrim(_DBUfilterbox._DBUfiltercondition.value)+" <>"
      END BUTTON
      DEFINE BUTTON _DBUand
         row 240
         col 250
         width 40
         caption "and"
         flat .T.
         action _DBUfilterbox._DBUfiltercondition.value := alltrim(_DBUfilterbox._DBUfiltercondition.value)+" .and."
      END BUTTON
      DEFINE BUTTON _DBUor
         row 240
         col 300
         width 40
         caption "or"
         flat .T.
         action _DBUfilterbox._DBUfiltercondition.value := alltrim(_DBUfilterbox._DBUfiltercondition.value)+" .or."
      END BUTTON
      DEFINE BUTTON _DBUnot
         row 240
         col 350
         width 40
         caption "not"
         flat .T.
         action _DBUfilterbox._DBUfiltercondition.value := alltrim(_DBUfilterbox._DBUfiltercondition.value)+" .not."
      END BUTTON
      DEFINE GRID _DBUfunctions
         row 200
         col 400
         value 1
         headers {"Functions"}
         widths {195}
         items _DBUdbffunctions
         on dblclick _DBUfilterbox._DBUfiltercondition.value := alltrim(_DBUfilterbox._DBUfiltercondition.value)+" "+alltrim(_DBUdbffunctions[_DBUfilterbox._DBUfunctions.value,1])
         width 200
         height 100
      END GRID
      DEFINE BUTTON _DBUsetfilter
         row 340
         col 100
         caption "Set Filter"
         width 100
         flat .T.
         action DBUfilterset()
      END BUTTON
      DEFINE BUTTON _DBUclearfilter
         row 340
         col 250
         caption "Clear Filter"
         width 100
         flat .T.
         action DBUfilterclear()
      END BUTTON
   END WINDOW
   CENTER WINDOW _DBUfilterbox
   ACTIVATE WINDOW _DBUfilterbox

   RETURN NIL

FUNCTION DBUcloseedit1

   _DBUalias->( dbClearFilter(NIL) )
   RELEASE WINDOW _DBUeditdbf

   RETURN NIL

FUNCTION DBUrefreshdbf

   LOCAL _DBUtotdeleted, _DBUcurrec, _DBUi, _DBUpos1

   IF .not. _DBUalias->(eof())
      FOR _DBUi := 1 to len(_DBUcontrolarr)
         IF _DBUcontrolarr[_DBUi,5] <> "H"
            IF _DBUcontrolarr[_DBUi,5] <> "L"
               _DBUpos1 := _DBUalias->( fieldpos(_DBUcontrolarr[_DBUi,3]) )
               IF _DBUpos1 > 0
                  _DBUeditdbf.&( _DBUcontrolarr[_DBUi,3] ).value := iif(_DBUcontrolarr[_DBUi,5] == "C",alltrim(_DBUalias->( fieldget(_DBUpos1) )),_DBUalias->( fieldget(_DBUpos1) ))
               ENDIF
            ELSE
               _DBUpos1 := _DBUalias->( fieldpos(_DBUcontrolarr[_DBUi,3]) )
               IF _DBUpos1 > 0
                  IF _DBUalias->( fieldget(_DBUpos1) ) <> nil
                     _DBUeditdbf.&( _DBUcontrolarr[_DBUi,3] ).value := _DBUalias->( fieldget(_DBUpos1) )
                  ENDIF
               ENDIF
            ENDIF
         ENDIF
      NEXT _DBUi
   ELSE
      FOR _DBUi := 1 to len(_DBUcontrolarr)
         IF _DBUcontrolarr[_DBUi,5] <> "H"
            DO CASE
            CASE _DBUcontrolarr[_DBUi,5] == "C" .or. _DBUcontrolarr[_DBUi,5] == "M"
               _DBUeditdbf.&( _DBUcontrolarr[_DBUi,3] ).value := ""
            CASE _DBUcontrolarr[_DBUi,5] == "N"
               _DBUeditdbf.&( _DBUcontrolarr[_DBUi,3] ).value := 0
            CASE _DBUcontrolarr[_DBUi,5] == "D"
               _DBUeditdbf.&( _DBUcontrolarr[_DBUi,3] ).value := date()
            CASE _DBUcontrolarr[_DBUi,5] == "L"
               _DBUeditdbf.&( _DBUcontrolarr[_DBUi,3] ).value := .f.
            ENDCASE
         ENDIF
      NEXT _DBUi
   ENDIF
   _DBUcurrec := _DBUalias->(recno())
   _DBUtotdeleted := 0
   _DBUalias->( dbEval( {|| _DBUtotdeleted := _DBUtotdeleted + 1}, {|| _DBUalias->( Deleted() )} ) )
   _DBUalias->( dbGoto(_DBUcurrec) )
   _DBUeditdbf._DBUrecgoto.value := _DBUalias->(recno())
   IF iscontroldefined(_DBUeditdbf,_DBUrecgotoslider)
      _DBUeditdbf._DBUrecgotoslider.value := _DBUalias->(recno())
   ENDIF
   _DBUeditdbf.statusbar.item(1) := "Record Pointer is at "+iif(_DBUalias->(eof()),"0",alltrim(str(_DBUalias->(recno()),10,0)))+" of "+alltrim(str(_DBUalias->(reccount()),10,0))+" record(s). "+alltrim(str(_DBUtotdeleted,5,0))+" record(s) are marked for deletion."
   _DBUeditdbf.statusbar.item(2) := iif(_DBUalias->(deleted())," Del","")
   _DBUeditdbf.statusbar.item(3) := iif(_DBUfiltered,"Filtered","")
   _DBUeditdbf.statusbar.item(4) := iif(_DBUindexed,"Indexed","")

   RETURN NIL

FUNCTION DBUfilterset

   LOCAL _DBUcondition1

   _DBUcondition1 := alltrim(_DBUfilterbox._DBUfiltercondition.value)
   IF len(_DBUcondition1) == 0
      _DBUalias->( dbClearFilter(NIL) )
      _DBUfiltered := .f.
      RELEASE WINDOW _DBUfilterbox
      _DBUeditdbf._DBUgoto.enabled := .t.
      _DBUeditdbf._DBUrecgoto.enabled := .t.
      DBUfirstclick()
   ELSE
      _DBUalias->( dbsetfilter({||&_DBUcondition1},_DBUcondition1) )
      _DBUfiltered := .t.
      RELEASE WINDOW _DBUfilterbox
      _DBUcondition := _DBUcondition1
      _DBUeditdbf._DBUgoto.enabled := .f.
      _DBUeditdbf._DBUrecgoto.enabled := .f.
      DBUfirstclick()
   ENDIF

   RETURN NIL

FUNCTION DBUfilterclear

   _DBUcondition := ""
   _DBUfiltered := .f.
   _DBUalias->( dbClearFilter(NIL) )
   RELEASE WINDOW _DBUfilterbox
   _DBUeditdbf._DBUgoto.enabled := .t.
   _DBUeditdbf._DBUrecgoto.enabled := .t.
   DBUfirstclick()

   RETURN NIL

FUNCTION DBUindexchange

   LOCAL _DBUindexfieldname

   IF _DBUeditdbf._DBUindexfield.value > 0
      IF _DBUeditdbf._DBUindexfield.value == 1
         _DBUalias->(dbClearIndex())
         _DBUindexed := .f.
         DBUrefreshdbf()
      ELSE
         _DBUindexfieldname := _DBUeditdbf._DBUindexfield.item(_DBUeditdbf._DBUindexfield.value)
         _DBUalias->(dbCreateIndex( "tmpindex", _DBUindexfieldname, {|| &_DBUindexfieldname}, NIL))
         _DBUindexed := .t.
         _DBUalias->( dbGoTop() )
         DBUrefreshdbf()
      ENDIF
   ELSE
      _DBUalias->(dbClearIndex())
      _DBUindexed := .f.
   ENDIF

   RETURN NIL

   /*
   * EOF
   */
