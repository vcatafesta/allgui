#include "minigui.ch"
#include "dbuvar.ch"

FUNCTION DBUbrowse1()

   LOCAL _DBUname1
   LOCAL _DBUstructarr
   LOCAL _DBUanames := {}
   LOCAL _DBUasizes := {}
   LOCAL _DBUajustify := {}

   LOCAL nWBrowseWidth, nWBrowseHeight

   IF .not. used()
      msginfo("No database is in use.","DBU")

      RETURN NIL
   ENDIF

   IF IsWindowDefined( _DBUBrowse )
      RELEASE WINDOW _DBUBrowse
      do events
   ENDIF

   _DBUstructarr := dbstruct()

   FOR _DBUi := 1 to len(_DBUstructarr)

      aadd(_DBUanames,_DBUstructarr[_DBUi,1])

      _DBUsize := len(alltrim(_DBUstructarr[_DBUi,1]))*15

      _DBUsize1 := _DBUstructarr[_DBUi,3] * 15

      aadd(_DBUasizes, iif(_DBUsize < _DBUsize1,_DBUsize1,_DBUsize))

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

   _DBUname1 := dbf()

   IF len(alltrim(_DBUname1)) == 0
      _DBUname1 := substr(_DBUfname,rat("\",_DBUfname),at(".",_DBUfname) - 1)
      IF len(alltrim(_DBUname1))==0

         RETURN NIL
      ENDIF
   ENDIF

   _DBUbuttonfirstrow := _DBUwindowheight - 200

   _DBUmaxrow := _DBUbuttonfirstrow - 100

   _DBUbuttoncol := 5

   _DBUbuttoncount := 1

   nWBrowseWidth := _DBUscrwidth
   nWBrowseHeight := _DBUwindowheight - IF(IsXPThemeActive(), 70, 80)

   DEFINE WINDOW _DBUBrowse at 0,0 ;
         WIDTH nWBrowseWidth height nWBrowseHeight title "DBU Browse " + _DBUfname;
         CHILD NOMINIMIZE NOMAXIMIZE NOSIZE NOSYSMENU

      DEFINE SPLITBOX
         DEFINE TOOLBAR _DBUedittoolbar buttonsize 48,35 flat // righttext
            button _DBUfirst     caption "First"     picture "first"     action DBUBRowsefirstclick()
            button _DBUprevious  caption "Previous"  picture "previous"  action DBUBrowsepreviousclick()
            button _DBUnext      caption "Next"      picture "next"      action DBUBrowsenextclick()
            button _DBUlast      caption "Last"      picture "last"      action DBUBrowselastclick()
         END toolbar
         DEFINE TOOLBAR _DBUedittoolbar1 buttonsize 48,35 flat // righttext
            button _DBUEditRec   caption "Edit"      picture "editmode"  action DBUbrowse2edit()
            button _DBUdelrec    caption "Delete"    picture "delete"    action DBUBrowsedelrecclick()
            button _DBUrecall    caption "Recall"    picture "recall"    action DBUBrowserecallclick()
            button _DBUprint     caption "Print"     picture "print"     action DBUbrowseprint()
            button _DBUclose     caption "Exit"      picture "exit"      action _DBUBrowse.release
         END toolbar
      END SPLITBOX

      DEFINE BROWSE _DBUrecord
         parent _DBUbrowse
         ROW 60
         COL 3
         WIDTH nWBrowseWidth - 10
         HEIGHT nWBrowseHeight - IF(IsXPThemeActive(), 160, 150 )
         HEADERS _DBUanames
         WIDTHS _DBUasizes
         WORKAREA &_DBUname1
         BACKCOLOR _DBUgreenish
         FIELDS _DBUanames
         VALUE recno()
         FONTNAME "Arial"
         fontsize 9
         TOOLTIP 'Double click to edit field contents'
         allowappend .t.
         allowedit .t.
         allowdelete .t.
         lock .t.
         inplaceedit .t.
         ON CHANGE DBUbrowsechanged()
      END browse

      DEFINE BUTTON _DBUbrowsegotobutton
         ROW nWBrowseHeight - IF(IsXPThemeActive(), 90, 80)
         COL 10
         CAPTION "Goto"
         WIDTH 50
         ACTION DBUbrowsegotoclick()
      END BUTTON

      DEFINE TEXTBOX _DBUbrowsegoto
         ROW nWBrowseHeight - IF(IsXPThemeActive(), 90, 80)
         COL 70
         WIDTH 100
         BACKCOLOR _DBUgreenish
         NUMERIC .t.
         RIGHTALIGN .t.
         VALUE recno()
         ON ENTER DBUbrowsegotoclick()
      END TEXTBOX

      IF _DBUfiltered
         DEFINE LABEL _DBUfilterconditionlabel
            ROW nWBrowseHeight - IF(IsXPThemeActive(), 85, 75)
            COL 200
            VALUE "Filter Condition :"
            WIDTH 150
            FONTBOLD .T.
            // backcolor _DBUgreenish
            // fontcolor {255,0,0}
         END LABEL

         DEFINE TEXTBOX _DBUfiltercondition
            ROW nWBrowseHeight - IF(IsXPThemeActive(), 90, 80)
            COL 360
            WIDTH _DBUwindowwidth - 400
            VALUE _DBUcondition
            readonly .T.
            FONTBOLD .T.
            BACKCOLOR _DBUgreenish
            // fontcolor {255,0,0}
         END TEXTBOX
      ENDIF

      DEFINE STATUSBAR
         statusitem "Browse Window of "+_DBUfname
         statusitem "" width 200
         statusitem "" width 60
         statusitem "" width 60
         statusitem "" width 60
      END STATUSBAR

      * (JK)
      ON KEY ESCAPE OF _DBUBrowse action _DBUBrowse.release
   END WINDOW

   IF _DBUfiltered
      _DBUbrowse._DBUbrowsegoto.enabled := .f.
   ENDIF

   _DBUcurrec := recno()
   COUNT for deleted() to _DBUtotdeleted
   dbgoto(_DBUcurrec)
   _DBUBrowse._DBUrecord.refresh()
   _DBUBrowse._DBUrecord.setfocus
   _DBUBrowse.center
   _DBUBrowse.row := _DBUbuttonfirstrow - 32
   _DBUBrowse.activate

   RETURN NIL

FUNCTION DBUBrowsefirstclick

   IF reccount() > 0
      GO TOP
      _DBUbrowse._DBUrecord.value := recno()
      DBUBrowserefreshdbf()
   ENDIF

   RETURN NIL

FUNCTION DBUBrowsepreviousclick

   IF .not. bof()
      SKIP -1
      _DBUbrowse._DBUrecord.value := recno()
      DBUBrowserefreshdbf()
   ENDIF

   RETURN NIL

FUNCTION DBUBrowsenextclick

   IF .not. eof()
      SKIP
      IF eof()
         SKIP -1
      ENDIF
      _DBUbrowse._DBUrecord.value := recno()
      DBUBrowserefreshdbf()
   ENDIF

   RETURN NIL

FUNCTION DBUBrowselastclick

   go bottom
   _DBUbrowse._DBUrecord.value := recno()
   DBUBrowserefreshdbf()

   RETURN NIL

FUNCTION DBUBrowsedelrecclick

   IF .not. eof()
      DELETE
      _DBUtotdeleted := _DBUtotdeleted + 1
      DBUBrowserefreshdbf()
   ENDIF

   RETURN NIL

FUNCTION DBUBrowserecallclick

   IF deleted()
      RECALL
      _DBUtotdeleted := _DBUtotdeleted - 1
      DBUBrowserefreshdbf()
   ENDIF

   RETURN NIL

FUNCTION DBUBrowsegotoclick

   IF _DBUBrowse._DBUbrowsegoto.value > 0
      IF _DBUBrowse._DBUbrowsegoto.value <= reccount()
         dbgoto(_DBUBrowse._DBUbrowsegoto.value)
         _DBUbrowse._DBUrecord.value := recno()
         DBUBrowserefreshdbf()

         RETURN NIL
      ELSE
         msginfo("You had entered a record number greater than the dbf size!","DBU")
         go bottom
         _DBUbrowse._DBUrecord.value := recno()
         DBUbrowserefreshdbf()
         _DBUBrowse._DBUbrowsegoto.setfocus()

         RETURN NIL
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION DBUbrowsechanged

   dbgoto(_DBUbrowse._DBUrecord.value)
   DBUbrowserefreshdbf()

   RETURN NIL

FUNCTION DBUBrowserefreshdbf

   _DBUBrowse._DBUbrowsegoto.value := recno()
   _DBUBrowse.statusbar.item(2) := iif(eof(),"0",alltrim(str(recno(),10,0)))+" / "+alltrim(str(reccount(),10,0))+" record(s) ("+alltrim(str(_DBUtotdeleted,5,0))+" deleted)"
   _DBUBrowse.statusbar.item(3) := iif(deleted()," Del","")
   _DBUBrowse.statusbar.item(4) := iif(_DBUfiltered,"Filtered","")
   _DBUBrowse.statusbar.item(5) := iif(_DBUindexed,"Indexed","")

   RETURN NIL

FUNCTION DBUbrowse2edit

   _DBUBrowse._DBUrecord.refresh
   _DBUbrowse.release
   DBUedit1()

   RETURN NIL
