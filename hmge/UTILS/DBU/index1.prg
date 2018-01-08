#include "minigui.ch"
#include "dbuvar.ch"

FUNCTION DBUcreaindex()

   PRIVATE _DBUfieldnames := {}

   _DBUstructarr := dbstruct()
   IF len(_DBUstructarr) == 0

      RETURN NIL
   ENDIF
   FOR _DBUi := 1 to len(_DBUstructarr)
      aadd(_DBUfieldnames,_DBUstructarr[_DBUi,1])
   NEXT _DBUi
   DEFINE WINDOW _DBUcreaindex at 0,0 width 300 height 500 title "Create Index" modal nosize nosysmenu
      DEFINE LABEL _DBUfieldslabel
         ROW 10
         COL 10
         WIDTH 280
         VALUE "Field Names List:"
         FONTBOLD .t.
      END LABEL
      DEFINE GRID _DBUfields
         ROW 40
         COL 10
         WIDTH 280
         HEIGHT 380
         WIDTHS {0,200}
         HEADERS {"","Field Names"}
         image {"wrong","right"}
         TOOLTIP "Double Click a field name to toggle between creating and not creating an index for that field."
         ONDBLCLICK _DBUindexfieldtoggle()
      END GRID
      DEFINE BUTTON _DBUsaveindex
         ROW 430
         COL 40
         CAPTION "Create"
         ACTION _DBUcreateindex()
      END BUTTON
      DEFINE BUTTON _DBUcancelindex
         ROW 430
         COL 160
         CAPTION "Cancel"
         ACTION _DBUcreaindex.release
      END BUTTON
   END WINDOW
   FOR _DBUi := 1 to len(_DBUfieldnames)
      _DBUcreaindex._DBUfields.additem({iif(_DBUi == 1,1,0),alltrim(_DBUfieldnames[_DBUi])})
   NEXT _DBUi
   _DBUcreaindex.center
   _DBUcreaindex.activate

   RETURN NIL

FUNCTION _DBUcreateindex()

   PRIVATE _DBUindexlist := {}
   PRIVATE _DBUcurrentitem := {}
   PRIVATE _DBUfieldname := ""
   PRIVATE _DBUindexfile := ""

   FOR _DBUi := 1 to _DBUcreaindex._DBUfields.itemcount
      _DBUcurrentitem := _DBUcreaindex._DBUfields.item(_DBUi)
      IF _DBUcurrentitem[1] == 1
         aadd(_DBUindexlist,_DBUcurrentitem[2])
      ENDIF
   NEXT _DBUi
   IF len(_DBUindexlist) == 0
      msginfo("You have to mark at least one field name to create index!","DBU Create Index")

      RETURN NIL
   ELSE
      IF msgyesno("Are you sure to create index for "+alltrim(str(len(_DBUindexlist)))+" field(s) you had selected?","DBU Create Index")
         FOR _DBUi := 1 to len(_DBUindexlist)
            _DBUfieldname := _DBUindexlist[_DBUi]
            _DBUindexfile := _DBUlastpath+alltrim(_DBUfieldname)
            aadd(_DBUindexfields,_DBUfieldname)
            aadd(_DBUindexfiles,_DBUindexfile)
            * (JK)
            _REINDEKS(_DBUindexfile,_DBUfieldname)
         NEXT _DBUi
         _DBUactiveindex := 1
         SET index to &_DBUindexfile
         msginfo("Index files created for "+alltrim(str(len(_DBUindexlist)))+" field(s) you had selected. The Current Active Index is "+indexkey(indexord()),"DBU Create Index")
         //      msginfo(_DBUindexfields[_DBUactiveindex],"DBU Current Active Index")
         DBUtogglemenu()
         _DBUcreaindex.release()
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION _DBUindexfieldtoggle()

   LOCAL lineno := _DBUcreaindex._DBUfields.value
   LOCAL _DBUcurrentitem

   IF lineno > 0
      _DBUcurrentitem := _DBUcreaindex._DBUfields.item(lineno)
      IF _DBUcurrentitem[1] == 0
         _DBUcurrentitem[1] := 1
      ELSE
         _DBUcurrentitem[1] := 0
      ENDIF
      _DBUcreaindex._DBUfields.item(lineno) := _DBUcurrentitem
   ENDIF

   RETURN NIL

FUNCTION DBUopenindex()

   //JK
   PRIVATE _DBUindexfile := ""
   PRIVATE _DBUopenfilenames := getfile({{"Harbour DataBase Index File(s)  (*.ntx)","*.ntx"}},"Choose the Index Files to Open",_DBUlastpath,.t.,.t.)

   IF len(_DBUopenfilenames) > 0
      FOR _DBUi := 1 to len(_DBUopenfilenames)
         _DBUindexfile:=_DBUopenfilenames[_DBUi]
         SET index to &_DBUindexfile
         aadd(_DBUindexfiles,_DBUopenfilenames[_DBUi])
         aadd(_DBUindexfields,indexkey(indexord()))
      NEXT _DBUi
      IF _DBUactiveindex == 0
         _DBUactiveindex := 1
         _DBUindexfile:=_DBUindexfiles[_DBUactiveindex]
         SET index to &_DBUindexfile
         msginfo("Index files Opened. The Current Active Index is "+indexkey(indexord()),"DBU Open Index")
      ELSE
         _DBUindexfile:=_DBUindexfiles[_DBUactiveindex]
         SET index to &_DBUindexfile  //JK
         msginfo("Index files Opened. The Current Active Index is "+indexkey(indexord())+" (Not changed.)","DBU Open Index")
      ENDIF
   ENDIF
   DBUtogglemenu()
   BrowseRefresh()
   RELEASE _DBUopenfilenames

   RETURN NIL

   * (JK)**************************************

FUNCTION DBUreindex()

   PRIVATE _CurDBUindexfile := ""

   IF len(_DBUindexfiles) == 0
      msginfo("No index files created/opened.","DBU Change Active Index")

      RETURN NIL
   ENDIF

   FOR _DBUi := 1 to len(_DBUindexfiles)
      _DBUindexfile:=_DBUindexfiles[_DBUi]
      _DBUfieldname:=_DBUindexfields[_DBUi]
      _REINDEKS(_DBUindexfile,_DBUfieldname)
   NEXT _DBUi
   _CurDBUindexfile:=_DBUindexfiles[_DBUactiveindex]
   SET index to &_CurDBUindexfile
   BrowseRefresh()
   msginfo("All index files have been (re)created.","DBU reindex")

   RETURN NIL

FUNCTION DBUcloseindex()

   IF len(_DBUindexfiles) == 0
      msginfo("No index files created/opened.","DBU Change Active Index")

      RETURN NIL
   ENDIF
   DEFINE WINDOW _DBUcloseindex at 0,0 width 300 height 400 title "DBU Close Index" modal nosize nosysmenu
      DEFINE LABEL _DBUcurrentlabel
         ROW 10
         COL 10
         VALUE "Choose the index file(s) to close"
         WIDTH 280
      END LABEL
      DEFINE LISTBOX _DBUcurrentindices
         ROW 40
         COL 10
         WIDTH 280
         HEIGHT 250
         ITEMS _DBUindexfields
         multiselect .t.
      END listbox
      DEFINE BUTTON _DBUcloseindexbutton
         ROW 320
         COL 10
         CAPTION "Close"
         ACTION DBUcloseindexdone()
      END BUTTON
   END WINDOW
   _DBUcloseindex.center
   _DBUcloseindex.activate

   RETURN NIL

FUNCTION DBUcloseindexdone()

   LOCAL activeindexfile
   LOCAL linenos := _DBUcloseindex._DBUcurrentindices.value

   IF len(linenos) == 0
      msginfo("No files selected for closing.","DBU close index")

      RETURN NIL
   ENDIF
   FOR _DBUi := len(linenos) to 1 step -1
      adel(_DBUindexfiles,linenos[_DBUi])
      adel(_DBUindexfields,linenos[_DBUi])
      asize(_DBUindexfiles,(len(_DBUindexfiles)-1))
      asize(_DBUindexfields,(len(_DBUindexfields)-1))
      IF linenos[_DBUi] == _DBUactiveindex
         _DBUactiveindex := 0
      ENDIF
      IF linenos[_DBUi] < _DBUactiveindex .and. _DBUactiveindex > 0
         _DBUactiveindex := _DBUactiveindex - 1
      ENDIF
   NEXT _DBUi
   IF _DBUactiveindex == 0
      IF len(_DBUindexfiles) > 0
         msginfo("You had selected to close the active index too. Hence the first open index is made active now.","DBU close index")
         _DBUactiveindex := 1
         activeindexfile := _DBUindexfiles[_DBUactiveindex]
         SET index to &activeindexfile
         msginfo("The Current Active Index is "+indexkey(indexord()),"DBU Close Index")
      ELSE
         SET index to
         msginfo("All index files had been closed. No index is active!","DBU close index")
      ENDIF
   ELSE
      activeindexfile := _DBUindexfiles[_DBUactiveindex]
      SET index to &activeindexfile
   ENDIF
   DBUtogglemenu()
   _DBUcloseindex.release
   BrowseRefresh()

   RETURN NIL

FUNCTION DBUchangeactiveindex()

   IF len(_DBUindexfiles) == 0
      msginfo("No index files created/opened.","DBU Change Active Index")

      RETURN NIL
   ENDIF
   IF len(_DBUindexfiles) == 1
      msginfo("Only one index file opened. You have to open more than one index file to change!","DBU Change Active Index")

      RETURN NIL
   ENDIF
   DEFINE WINDOW _DBUactiveindex at 0,0 width 300 height 400 title "DBU Active Index Change" modal nosize nosysmenu
      DEFINE LABEL _DBUcurrentlabel
         ROW 10
         COL 10
         VALUE "Change the field to make it active"
         WIDTH 280
      END LABEL
      DEFINE LISTBOX _DBUcurrentindices
         ROW 40
         COL 10
         WIDTH 280
         HEIGHT 250
         ITEMS _DBUindexfields
         VALUE _DBUactiveindex
      END listbox
      DEFINE BUTTON _DBUchangeactivedone
         ROW 320
         COL 10
         CAPTION "Done"
         ACTION DBUchangeactiveindexdone()
      END BUTTON
   END WINDOW
   _DBUactiveindex.center
   _DBUactiveindex.activate

   RETURN NIL

FUNCTION DBUchangeactiveindexdone()

   LOCAL lineno := _DBUactiveindex._DBUcurrentindices.value

   IF lineno > 0
      _DBUactiveindex := lineno
      _DBUindexfile:=_DBUindexfiles[_DBUactiveindex]
      SET index to &_DBUindexfile
      msginfo("The Current Active Index is "+indexkey(indexord()),"DBU Change Active Index")
      _DBUactiveindex.release
   ELSE
      msginfo("You have to select atleast one index file!","DBU change Active Index")

      RETURN NIL
   ENDIF
   DBUtogglemenu()
   BrowseRefresh()

   RETURN NIL

   * (JK) *******************************************************

FUNCTION _REINDEKS(cIdxNaz,cIdxWYR)

   LOCAL cNazIdx:=cIdxNaz

   DEFINE WINDOW Form_idx AT 274,282 ;
         WIDTH 298 HEIGHT 100 ;
         TITLE "Indexing in progress - don`t interrupt !!!!" ;
         ICON "Tool" ;
         MODAL  ;
         NOSIZE ;
         ON INIT _INDEKSUJ(cIdxWYR,cNazIdx) ;
         FONT 'Arial' SIZE 09
      @ 30,19 PROGRESSBAR ProgressBar_1 RANGE 0,100 WIDTH 252 HEIGHT 18
      @ 6,94 LABEL Label_001 VALUE "Completed " WIDTH 120 HEIGHT 24
      DEFINE STATUSBAR
         statusitem cNazIdx
      END STATUSBAR

   END WINDOW
   Form_idx.center
   Form_idx.ACTIVATE

   RETURN NIL

   ** (JK) *********************************

FUNCTION _INDEKSUJ(cWyrazenie,cNazIdx)

   INDEX ON &cWyrazenie TO &cNazIdx EVAL NtxProgress() EVERY LASTREC()/20
   Form_idx.Release

   RETURN NIL

   ** (JK) *************************

FUNCTION NtxProgress()

   LOCAL nComplete := INT((RECNO()/LASTREC()) * 100)
   LOCAL cComplete := LTRIM(STR(nComplete))

   Form_idx.Label_001.Value := "Completed "+ cComplete + "%"
   Form_idx.ProgressBar_1.Value := nComplete

   RETURN .t.
