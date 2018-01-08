#include "minigui.ch"
#include "dbuvar.ch"

#define CR_LF HB_OSNewLine()
#define DBU_VERSION "Summer '05 - Autumn '07"

REQUEST DBFCDX, DBFFPT

#ifdef __XHARBOUR__
#xtranslate hb_pvalue([<x,...>]) => pvalue(<x>)
#endif

MEMVAR _dbase,_opmode

FUNCTION MAIN()

   LOCAL aColors

   PARAMETERS _dbase,_opmode

   PUBLIC _DBUdbfopened := .f.
   PUBLIC _DBUfname := ""
   PUBLIC _DBUindexed := .f.
   PUBLIC _DBUfiltered := .f.
   PUBLIC _DBUcondition := ""
   PUBLIC _DBUmaxrow := 0
   PUBLIC _DBUcontrolarr := {} // {row,col,name,width,type,size,decimals,page}
   PUBLIC _DBUeditmode := .t.
   PUBLIC _DBUindexfieldname := ""
   PUBLIC _DBUbuttonsdefined := .f.
   PUBLIC _DBUscrwidth := Min(880,getdesktopwidth())
   PUBLIC _DBUscrheight := Min(600,getdesktopheight())

   PUBLIC _DBUwindowwidth  := _DBUscrwidth  - 50
   PUBLIC _DBUwindowheight := _DBUscrheight - 50

   PUBLIC _DBUtotdeleted := 0
   PUBLIC _DBUlastpath := ""
   PUBLIC _DBUlastfname := ""
   PUBLIC _DBUcurrentprinter := ""
   PUBLIC _DBUpath := GetStartupFolder()+"\" // diskname()+":\"+curdir()+"\"
   PUBLIC _DBUparentfname := ""
   PUBLIC _DBUchildfname := ""
   PUBLIC _DBUparentstructarr := {}
   PUBLIC _DBUchildstructarr := {}
   PUBLIC _DBUreddish := {255,200,200}
   PUBLIC _DBUgreenish := {200,255,200}
   PUBLIC _DBUblueish := {200,200,255}
   PUBLIC _DBUyellowish := {255,255,200}
   PUBLIC _DBUblack := {0,0,0}
   PUBLIC _DBUindexfields := {}
   PUBLIC _DBUindexfiles := {}
   PUBLIC _DBUactiveindex := 0

   SET DATE TO    BRITISH
   SET CENTURY    ON
   SET EPOCH TO   1960
   SET DELETED    OFF
   SET EXCLUSIVE  ON

   SET MENUSTYLE  EXTENDED
   SET NAVIGATION EXTENDED
   SET BROWSESYNC ON
   SET INTERACTIVECLOSE QUERY MAIN

   SET HELPFILE TO 'DBU.chm'

   * (JK) check if some param is passed

   * (JK) first param - dbase file to be open

   IF pcount()>0
      _dbase:=HB_PVALUE(1)
      IF file(_dbase+".dbf")==.t.
         _dbase+=".dbf"
      ELSEIF file(_dbase)==.f.
         _dbase:=""
      ENDIF
   ELSE
      _dbase:=""
   ENDIF

   * (JK) 2nd param - open mode  (B - as browse, E as EDIT)

   IF pcount()>1 .and. ( _opmode := upper(strtran(hb_PValue(2),"/","")) )$'BE'
      IF _opmode=='B'
         _opmode:=2
      ELSE
         _opmode:=1
      ENDIF
   ELSE
      _opmode:=2
   ENDIF

   IF file(_DBUpath+"dbu.ini")
      BEGIN INI FILE _DBUpath+"\dbu.ini"
         GET _DBUlastpath section "DBUlastpath" entry "path"
         GET _DBUlastfname section "DBUlastpath" entry "file"
      END INI
   ENDIF

   * (JK) clause ON INIT added
   DEFINE WINDOW _DBU at 0,0 ;
         WIDTH _DBUscrwidth height _DBUscrheight ;
         TITLE "Harbour Minigui DataBase Utility" ;
         ICON "dbuicon" ;
         MAIN ;
         ON INIT {|| iif(len(_dbase)>0, DBUopendbf(_dbase,_opmode),)} ;
         ON RELEASE DBUclosedbfs() ;
         on maximize DBUwinSize()  ;
         on size DBUwinSize()      ;
         FONT 'Arial' size 8       ;
         noshow

      DEFINE STATUSBAR
         statusitem "Empty" action DBUopendbf()
         statusitem "" width 350
         statusitem "" width 60
         statusitem "" width 60
         statusitem "" width 60
      END STATUSBAR

      aColors := GetMenuColors()

      aColors[ MNUCLR_MENUBARBACKGROUND1 ] := GetSysColor(15)
      aColors[ MNUCLR_MENUBARBACKGROUND2 ] := GetSysColor(15)

      SetMenuColors( aColors )

      SetMenuBitmapHeight( BmpSize( "MENUOPEN" )[ 1 ] )

      DEFINE MAIN MENU

         POPUP "&File"
            item " Create &New DBF" + Space(16) + 'Ctrl+N' ;
               ACTION DBUcreanew()                 image 'MENUNEW'
            SEPARATOR
            item " &Open DBF file"  + Space(16) + 'Ctrl+O' ;
               ACTION DBUopendbf()                 image 'MENUOPEN'
            item " &Close DBF"  ;
               ACTION DBUclosedbf() name _DBUitem1 image 'MENUCLOSE'
            SEPARATOR
            item " Modiy Structure" + Space(16) + 'Ctrl+T' ;
               ACTION DBUmodistruct() name _DBUitem7 image 'MENUSTRU'
            SEPARATOR
            item " E&xit" + Space(16) + 'Ctrl+X'           ;
               ACTION _DBU.release()               image 'MENUEXIT'
            IF len(alltrim(_DBUlastfname)) > 0
               SEPARATOR
               item _DBUlastfname ;
                  ACTION DBUopenlastdbf()
            ENDIF
         END POPUP

         POPUP "&View"
            item " Browse Mode" + Space(16)+'Ctrl+B' ;
               ACTION DBUbrowse1()  name _DBUitem9   image 'MENUBROW'
            SEPARATOR
            item " Edit Mode" + Space(16)+'Ctrl+E' ;
               ACTION DBUedit1()      name _DBUitem8 image 'MENUEDIT'
         END POPUP

         POPUP "&Index"
            item " Open index" ;
               ACTION DBUopenindex() name _DBUitem3
            item " Change Active" ;
               ACTION DBUchangeactiveindex() name _DBUitem4
            SEPARATOR
            item " Create new index" ;
               ACTION DBUcreaindex() name _DBUitem2  image 'MENUINDEX'
            item " Reindex" ;
               ACTION DBUreindex() name _DBUitem5    image 'MENUREIND'
            SEPARATOR
            item " Close index" ;
               ACTION DBUcloseindex() name _DBUitem6 image 'MENUCLOIN'
         END POPUP

         POPUP "&Edit"
            item " &Replace" + Space(16) + 'Ctrl+R' ;
               ACTION DBUreplace() name _DBUitem13   image 'MENUREPL'
            item " Reca&ll"  + Space(16) + 'Ctrl+L' ;
               ACTION DBUrecallrec() name _DBUitem10 image 'MENURECA'
            item " Pack"  + Space(16)+'Ctrl+K' ;
               ACTION DBUpackdbf() name _DBUitem11   image 'MENUPACK'
            SEPARATOR
            item " Zap" + Space(16) + 'Ctrl+Z' ;
               ACTION DBUzapdbf() name _DBUitem12    image 'MENUZAP'
         END POPUP

         POPUP "&Utilities"

            item " Export OEM dbf to &Ansi" + Space(16) + 'Ctrl+A' ;
               ACTION DBU_OEM2ANSI(.T.) name _DBUitem14 image 'MenuAnsi'
            SEPARATOR
            item " Export Ansi dbf to OE&M" + Space(16) + 'Ctrl+M' ;
               ACTION DBU_OEM2ANSI(.F.) name _DBUitem15 image 'MenuOem'

         END POPUP

         POPUP "&Help"
            item ' &Help ' + Space(16) + 'F1' ;
               ACTION HELP() image 'MENUHELP'
            SEPARATOR
            item " About" ;
               ACTION DBUaboutclick() image 'MENUQUEST'
            item ' Version' ;
               ACTION MsgInfo ("Dbu version: " + DBU_VERSION      + CR_LF + ;
               "GUI Library : " + MiniGuiVersion() + CR_LF + ;
               "Compiler     : " + Version(), 'Versions') image 'MENUVER'
         END POPUP

      END MENU

      * (JK) & added to make use with ALT-key shortcut

      ON KEY CONTROL+N ACTION DBUcreanew()
      ON KEY CONTROL+O ACTION DBUopendbf()
      ON KEY CONTROL+T ACTION DBUmodistruct()
      ON KEY CONTROL+X ACTION _DBU.release()

      ON KEY CONTROL+B ACTION DBUbrowse1()
      ON KEY CONTROL+E ACTION DBUedit1()

      ON KEY CONTROL+R ACTION DBUreplace()
      ON KEY CONTROL+L ACTION DBUrecallrec()
      ON KEY CONTROL+K ACTION DBUpackdbf()
      ON KEY CONTROL+Z ACTION DBUzapdbf()

      ON KEY CONTROL+A ACTION DBU_OEM2ANSI(.T.)
      ON KEY CONTROL+M ACTION DBU_OEM2ANSI(.F.)
      ON KEY F1        ACTION HELP()

      DEFINE SPLITBOX
         DEFINE TOOLBAR _DBUMainTool buttonsize 48,35 flat // righttext
            button _DBUnewfile caption "New" picture "newfile" action DBUcreanew()
            button _DBUopenfile caption "Open" picture "open" action DBUopendbf()
            button _DBUclosefile caption "Close" picture "close" action DBUclosedbf()
            button _DBUmodify    caption "Modify" picture "modify" action DBUmodistruct()
            button _DBUprintstruct caption "Print" picture "print" action DBUprintstruct()
         END toolbar
         DEFINE TOOLBAR _DBUMainTool2 buttonsize 48,35 flat // righttext
            button _DBUEditMode caption "Edit" picture "editmode" action DBUedit1()
            button _DBUbrowsemode caption "Browse" picture "browse" action DBUbrowse1()
         END toolbar
         DEFINE TOOLBAR _DBUMainTool3 buttonsize 48,35 flat // righttext
            button _DBUindexfile caption "Index" picture "index" action DBUcreaindex() dropdown
            button _DBUfilterfile caption "Filter" picture "filter" action DBUfilterclick() check
            //      button _DBUfilterclear caption "Clear Filter" picture "cfilter" action DBUfilterclear() separator
            button _DBURepl caption "Replace" picture "replace" action DBUreplace() separator
            button _DBUpack caption "Pack" picture "pack" action DBUpackdbf()
            button _DBUzap caption "Zap" picture "zap" action DBUzapdbf()
            button _DBUrecallall caption "Rec(all)" picture "recall" action DBUrecallrec()
         END toolbar
         DEFINE TOOLBAR _DBUMainTool4 buttonsize 48,35 flat // righttext
            button _DBUabout caption "About" picture "about" action DBUaboutclick()
            button _DBUexit  caption "Exit"  picture "exit" action _DBU.release
         END toolbar
      END SPLITBOX
      define dropdown menu button _DBUindexfile
         item "Create" action DBUcreaindex() name _DBUitem2a
         item "Open" action DBUopenindex() name _DBUitem3a
         item "Change Active" action DBUchangeactiveindex() name _DBUitem4a
         item "Reindex" action DBUreindex() name _DBUitem5a
         item "Close" action DBUcloseindex() name _DBUitem6a
      END MENU

      DEFINE LABEL _DBUmaillabel
         ROW _DBUscrheight - 115
         COL _DBUscrwidth - 290
         VALUE "E-mail me"
         WIDTH 80
      END LABEL

      define hyperlink _DBUemailid
         ROW _DBUscrheight - 115
         COL _DBUscrwidth - 200
         VALUE "srgiri@dataone.in"
         address "srgiri@dataone.in"
         TOOLTIP "Contact me at the above address"
         AUTOSIZE .t.
         handcursor .t.
         FONTNAME "Arial"
         FONTSIZE 9
      END hyperlink

      DEFINE CONTEXT menu of _DBU
         MENUITEM "Create" action DBUcreanew()
         MENUITEM "Open" action DBUopendbf()
         MENUITEM "Close" action DBUclosedbf() name _DBUcontextclose
         SEPARATOR
         MENUITEM "Edit" action DBUedit1() name _DBUcontextedit
         MENUITEM "Browse" action DBUbrowse1() name _DBUcontextbrowse
      END MENU

   END WINDOW

   DEFINE WINDOW DBUsplashwindow at 0,0 ;
         WIDTH 400+2*GetBorderWidth()-2 ;
         HEIGHT 400+2*GetBorderHeight()-2 ;
         topmost nocaption ;
         ON INIT DBUsplash() on release _DBU.restore()

      DEFINE IMAGE _DBUlogo
         ROW 0
         COL 0
         PICTURE "splash"
         WIDTH 400
         HEIGHT 400
      END IMAGE

   END WINDOW

   DBUtogglemenu()

   CENTER WINDOW DBUsplashwindow
   CENTER WINDOW _DBU
   ACTIVATE WINDOW DBUsplashwindow, _DBU

   RETURN NIL

FUNCTION Help()

   _Execute( _HMG_MainHandle, "open", GetStartupFolder() + "\Dbu.Chm" )

   RETURN NIL

FUNCTION DBUsplash(ilsec)

   LOCAL itime

   IF empty(ilsec)
      ilsec:=2
   ENDIF
   itime := seconds()
   DO WHILE seconds() - itime < ilsec
      DO Events
   ENDDO

   DBUsplashwindow.release

   RETURN NIL

   * (JK) main window resizing function

   *=============================

FUNCTION DBUwinSize()

   *=============================
   LOCAL _DBUscrheight := _DBU.Height,_DBUscrwidth := _DBU.Width

   _DBU._DBUemailid.Row   := _DBUscrheight - 115
   _DBU._DBUemailid.Col   := _DBUscrwidth - 200
   _DBU._DBUmaillabel.Row := _DBUscrheight - 115
   _DBU._DBUmaillabel.Col := _DBUscrwidth - 290

   RETURN NIL

   * (JK) params added _DBfile to be open, edMODE - edit mode

FUNCTION DBUopendbf( _DBfile, edMODE )

   LOCAL _editMode

   IF EMPTY(edMODE) .or. edMODE==NIL
      _editMode:=2
   ELSE
      _editMode:=edMODE
   ENDIF

   IF EMPTY(_DBfile) .or. _DBfile==NIL .or. !file(_DBfile)
      _DBUfname1 := getfile({{"xBase File  (*.dbf)","*.dbf"}},"Select a dbf to open",_DBUlastpath,.f.)
   ELSE
      _DBUfname1 := _DBfile
   ENDIF

   _DBUfname1 := alltrim(_DBUfname1)

   IF len(_DBUfname1) > 0
      IF used()
         IF msgyesno("Are you sure to close the dbf opened already?","DBU")
            CLOSE all
            IF MG_USE("&_DBUfname1","_myDbase",.T.,5,.T.)
               _DBUfname := _DBUfname1
               _DBUdbfopened := .t.
               _DBUlastpath := substr(_DBUfname1,1,rat("\",_DBUfname1))
               _DBUindexed := .f.
               _DBUfiltered := .f.
               DBUtogglemenu()
               * (JK) select browse mode
               IF _editMode==1
                  DBUedit1()
               ELSE
                  DBUbrowse1()
               ENDIF
            ENDIF
         ENDIF
      ELSE
         IF MG_USE("&_DBUfname1","_myDbase",.T.,5,.T.)
            _DBUfname := _DBUfname1
            _DBUdbfopened := .t.
            _DBUlastpath := substr(_DBUfname1,1,rat("\",_DBUfname1))
            DBUtogglemenu()
            * (JK) select browse mode
            IF _editMode==1
               DBUedit1()
            ELSE
               DBUbrowse1()
            ENDIF
         ENDIF
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION DBUopenlastdbf()

   * (JK) changed USE to MG_USE()

   _DBUfname1 := alltrim(_DBUlastfname)
   IF len(_DBUfname1) > 0
      IF used()
         IF msgyesno("Are you sure to close the dbf opened already?","DBU")
            CLOSE all
            IF MG_USE("&_DBUfname1","_myDbase",.T.,5,.T.)
               _DBUfname := _DBUfname1
               _DBUdbfopened := .t.
               _DBUlastpath := substr(_DBUfname1,1,rat("\",_DBUfname1))
               DBUtogglemenu()
               IF _opMode==1
                  DBUedit1()
               ELSE
                  DBUbrowse1()
               ENDIF
            ENDIF
         ENDIF
      ELSE
         IF MG_USE("&_DBUfname1","_myDbase",.T.,5,.T.)
            _DBUfname := _DBUfname1
            _DBUdbfopened := .t.
            _DBUlastpath := substr(_DBUfname1,1,rat("\",_DBUfname1))
            DBUtogglemenu()
            IF _opMode==1
               DBUedit1()
            ELSE
               DBUbrowse1()
            ENDIF
         ENDIF
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION DBUclosedbf( lAsk )

   LOCAL lGo := .T.

   DEFAULT lAsk TO .T.

   IF Used()
      IF lAsk
         lGo := msgyesno("Are you sure to close the dbf?","DBU")
      ENDIF
      IF lGo
         DBUfilterclear()
         DBCloseAll()

         _DBUcondition := ""
         _DBUindexed := .f.
         _DBUfiltered := .f.
         _DBUlastfname := _DBUfname
         _DBUfname := ""
         _DBUdbfopened := .f.
         _DBUactiveindex := 0
         asize(_DBUindexfiles,0)
         asize(_DBUindexfields,0)

         IF IsWindowDefined( _DBUBrowse )
            RELEASE WINDOW _DBUBrowse
         ENDIF

         DBUtogglemenu()
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION DBUrecallrec()

   IF msgyesno("This will recall all the records marked for deletion." + CR_LF + ;
         "If you want to recall a particular record, try using edit mode." + CR_LF + ;
         "Are you sure to recall all?", "DBU")
      IF used()
         _DBUcurrec := recno()
         RECALL all
         dbgoto(_DBUcurrec)
         _DBUtotdeleted := 0
         BrowseRefresh()
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION DBUpackdbf()

   IF msgyesno("All records marked for deletion will be removed physically" + CR_LF + ;
         "from the dbf." + CR_LF + ;
         "Are you sure to pack the dbf?","DBU")
      IF used()
         PACK
         _DBUtotdeleted := 0
         BrowseRefresh()
         DBUtogglemenu()
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION DBUzapdbf

   IF msgyesno("Are you sure to zap this dbf?" + CR_LF + ;
         "You can not undo this change.","DBU")
      ZAP
      BrowseRefresh()
      DBUtogglemenu()
   ENDIF

   RETURN NIL

FUNCTION DBUtogglemenu

   IF .not. _DBUdbfopened
      _DBU.statusbar.item(1) := "Empty"
      _DBU.statusbar.item(2) := ""
      _DBU._DBUcontextclose.enabled := .f.
      _DBU._DBUcontextedit.enabled := .f.
      _DBU._DBUcontextbrowse.enabled := .f.
      _DBU._DBUitem1.enabled := .f.
      _DBU._DBUitem2.enabled := .f.
      _DBU._DBUitem3.enabled := .f.
      _DBU._DBUitem4.enabled := .f.
      _DBU._DBUitem5.enabled := .f.
      _DBU._DBUitem6.enabled := .f.
      _DBU._DBUitem7.enabled := .f.
      _DBU._DBUitem8.enabled := .f.
      _DBU._DBUitem9.enabled := .f.
      _DBU._DBUitem10.enabled := .f.
      _DBU._DBUitem11.enabled := .f.
      _DBU._DBUitem12.enabled := .f.
      _DBU._DBUitem13.enabled := .f.

      _DBU._DBUclosefile.enabled := .f.
      _DBU._DBUeditmode.enabled := .f.
      _DBU._DBUmodify.enabled := .f.
      _DBU._DBUbrowsemode.enabled := .f.
      _DBU._DBUpack.enabled := .f.
      _DBU._DBUzap.enabled := .f.
      _DBU._DBUrecallall.enabled := .f.
      _DBU._DBUprintstruct.enabled := .f.
      _DBU._DBUindexfile.enabled := .f.
      _DBU._DBUfilterfile.enabled := .F.
      _DBU._DBURepl.enabled := .F.

      //   _DBU._DBUfilterclear.enabled := .f.
      //   dbu.item8.enabled := .f.
   ELSE
      _DBU.statusbar.item(1) := _DBUfname+" (Fields : "+alltrim(str(fcount(),5,0))+") (Records : "+alltrim(str(reccount(),10,0))+")"
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
      _DBU._DBUitem8.enabled := .t.
      _DBU._DBUitem9.enabled := .t.
      _DBU._DBUitem10.enabled := .t.
      _DBU._DBUitem11.enabled := .t.
      _DBU._DBUitem12.enabled := .t.
      _DBU._DBUitem13.enabled := .t.
      _DBU._DBUitem14.enabled := .T.
      _DBU._DBUitem15.enabled := .T.
      _DBU._DBUclosefile.enabled := .t.
      _DBU._DBUeditmode.enabled := .t.
      _DBU._DBUmodify.enabled := .t.
      _DBU._DBUbrowsemode.enabled := .T.
      _DBU._DBURepl.enabled := .T.
      _DBU._DBUpack.enabled := .t.
      _DBU._DBUzap.enabled := .t.
      _DBU._DBUrecallall.enabled := .t.
      _DBU._DBUprintstruct.enabled := .t.
      _DBU._DBUindexfile.enabled := .t.
      _DBU._DBUfilterfile.enabled := .t.
      IF len(_DBUindexfiles) == 0
         _DBU._DBUitem4.enabled := .f.
         _DBU._DBUitem5.enabled := .f.
         _DBU._DBUitem6.enabled := .f.
         _DBU._DBUitem4a.enabled := .f.
         _DBU._DBUitem5a.enabled := .f.
         _DBU._DBUitem6a.enabled := .f.
      ELSE
         IF len(_DBUindexfiles) > 1
            _DBU._DBUitem4.enabled := .t.
            _DBU._DBUitem4a.enabled := .t.
         ELSE
            _DBU._DBUitem4.enabled := .f.
            _DBU._DBUitem4a.enabled := .f.
         ENDIF
         _DBU._DBUitem5.enabled := .t.
         _DBU._DBUitem6.enabled := .t.
         _DBU._DBUitem5a.enabled := .t.
         _DBU._DBUitem6a.enabled := .t.
      ENDIF
      IF _DBUactiveindex > 0
         _DBU.statusbar.item(2) := "Active Index File:"+_DBUindexfiles[_DBUactiveindex]+". Field :"+alltrim(indexkey(indexord()))
      ELSE
         _DBU.statusbar.item(2) := "Active Index File: NIL"
      ENDIF
      /*
      if _DBUfiltered
      _DBU._DBUfilterclear.enabled := .t.
      else
      _DBU._DBUfilterclear.enabled := .f.
      endif

      dbu.item8.enabled := .t.
      */
   ENDIF

   RETURN NIL

FUNCTION DBUclosedbfs()

   CLOSE all
   _DBUlastfname := _DBUfname
   BEGIN INI FILE _DBUpath+"dbu.ini"
      SET SECTION "DBUlastpath" entry "path" to _DBUlastpath
      IF len(alltrim(_DBUlastfname)) > 0
         SET SECTION "DBUlastpath" entry "file" to _DBUlastfname
      ENDIF
   END INI

   RETURN NIL

FUNCTION DBUaboutclick()

   DEFINE WINDOW _DBUaboutwindow AT 0, 0 WIDTH 368 HEIGHT 523 ;
         TITLE "About" ICON 'dbu' ;
         CHILD ;
         NOSIZE NOSYSMENU ;
         ON MOUSECLICK ThisWindow.Release

      DEFINE IMAGE Image_1
         ROW    2
         COL    2
         WIDTH  358
         HEIGHT 358
         PICTURE "splash"
         HELPID Nil
         VISIBLE .T.
         STRETCH .T.
         ACTION ThisWindow.Release
      END IMAGE

      DEFINE BUTTON Button_1
         ROW    460
         COL    260
         WIDTH  98
         HEIGHT 26
         CAPTION "Ok"
         ACTION ThisWindow.Release
         FONTNAME "Arial"
         FONTSIZE 9
         TOOLTIP ""
         FONTBOLD .F.
         FONTITALIC .F.
         FONTUNDERLINE .F.
         FONTSTRIKEOUT .F.
         ONGOTFOCUS Nil
         ONLOSTFOCUS Nil
         HELPID Nil
         FLAT .T.
         TABSTOP .T.
         VISIBLE .T.
         TRANSPARENT .F.
         PICTURE Nil
         DEFAULT .T.
      END BUTTON

      DEFINE LABEL Label_1
         ROW    388
         COL    10
         WIDTH  340
         HEIGHT 72
         VALUE "Developed in : " + SubStr(MiniGUIVersion(), 1, 32) + CR_LF + CR_LF + "Compiler: " + Version()
         FONTNAME "Tahoma"
         FONTSIZE 10
         TOOLTIP ""
         FONTBOLD .T.
         FONTITALIC .F.
         FONTUNDERLINE .F.
         FONTSTRIKEOUT .F.
         HELPID Nil
         VISIBLE .T.
         TRANSPARENT .F.
         ACTION ThisWindow.Release
         AUTOSIZE .f.
         BACKCOLOR Nil
         FONTCOLOR Nil
      END LABEL

      ON KEY ESCAPE ACTION ThisWindow.Release

   END WINDOW

   CENTER WINDOW _DBUaboutwindow
   ACTIVATE WINDOW _DBUaboutwindow

   RETURN NIL

   // Filter Section
   *====================================

FUNCTION DBUsetfilter

   *====================================
   IF .not. used()

      RETURN NIL
   ENDIF
   _DBUstructarr := dbstruct()
   _DBUfieldsarr := {}
   FOR _DBUi := 1 to len(_DBUstructarr)
      aadd(_DBUfieldsarr,{_DBUstructarr[_DBUi,1]})
   NEXT _DBUi
   _DBUdbffunctions := {{"RecNo()"},{"Deleted()"},{"Date()"},{"CToD()"},{"Day()"},{"Month()"},{"Year()"}, ;
      {"AllTrim()"},{"Upper()"},{"Lower()"},{"Val()"},{"Str()"},{"Int()"},{"Max()"},{"Min()"}}
   DEFINE WINDOW _DBUfilterbox at 0,0 width 650 height 420 title "Filter Condition" modal nosize nosysmenu
      DEFINE EDITBOX _DBUfiltercondition
         ROW 30
         COL 30
         WIDTH 600
         HEIGHT 100
         BACKCOLOR _DBUreddish
         VALUE _DBUcondition
      END editbox
      DEFINE GRID _DBUfieldnames
         ROW 160
         COL 30
         VALUE 1
         BACKCOLOR _DBUyellowish
         HEADERS {"Field Name"}
         WIDTHS {176}
         ITEMS _DBUfieldsarr
         ON DBLCLICK _DBUfilterbox._DBUfiltercondition.value := alltrim(alltrim(_DBUfilterbox._DBUfiltercondition.value)+" "+alltrim(_DBUfieldsarr[_DBUfilterbox._DBUfieldnames.value,1]))
         WIDTH 200
         HEIGHT 152
      END GRID
      DEFINE BUTTON _DBUlessthan
         ROW 200
         COL 250
         WIDTH 25
         CAPTION "<"
         ACTION _DBUfilterbox._DBUfiltercondition.value := alltrim(_DBUfilterbox._DBUfiltercondition.value)+" <"
      END BUTTON
      DEFINE BUTTON _DBUgreaterthan
         ROW 200
         COL 285
         WIDTH 25
         CAPTION ">"
         ACTION _DBUfilterbox._DBUfiltercondition.value := alltrim(_DBUfilterbox._DBUfiltercondition.value)+" >"
      END BUTTON
      DEFINE BUTTON _DBUequal
         ROW 200
         COL 320
         WIDTH 25
         CAPTION "=="
         ACTION _DBUfilterbox._DBUfiltercondition.value := alltrim(_DBUfilterbox._DBUfiltercondition.value)+" =="
      END BUTTON
      DEFINE BUTTON _DBUnotequal
         ROW 200
         COL 355
         WIDTH 25
         CAPTION "<>"
         ACTION _DBUfilterbox._DBUfiltercondition.value := alltrim(_DBUfilterbox._DBUfiltercondition.value)+" <>"
      END BUTTON
      DEFINE BUTTON _DBUand
         ROW 240
         COL 250
         WIDTH 40
         CAPTION "and"
         ACTION _DBUfilterbox._DBUfiltercondition.value := alltrim(_DBUfilterbox._DBUfiltercondition.value)+" .and."
      END BUTTON
      DEFINE BUTTON _DBUor
         ROW 240
         COL 300
         WIDTH 40
         CAPTION "or"
         ACTION _DBUfilterbox._DBUfiltercondition.value := alltrim(_DBUfilterbox._DBUfiltercondition.value)+" .or."
      END BUTTON
      DEFINE BUTTON _DBUnot
         ROW 240
         COL 350
         WIDTH 40
         CAPTION "not"
         ACTION _DBUfilterbox._DBUfiltercondition.value := alltrim(_DBUfilterbox._DBUfiltercondition.value)+" .not."
      END BUTTON
      DEFINE GRID _DBUfunctions
         ROW 160
         COL 400
         VALUE 1
         HEADERS {"Functions"}
         WIDTHS {176}
         BACKCOLOR _DBUgreenish
         ITEMS _DBUdbffunctions
         ON DBLCLICK _DBUfilterbox._DBUfiltercondition.value := alltrim(_DBUfilterbox._DBUfiltercondition.value)+" "+alltrim(_DBUdbffunctions[_DBUfilterbox._DBUfunctions.value,1])
         WIDTH 200
         HEIGHT 152
      END GRID
      DEFINE BUTTON _DBUsetfilter
         ROW 340
         COL 150
         CAPTION "Set Filter"
         WIDTH 100
         ACTION DBUfilterset()
      END BUTTON
      DEFINE BUTTON _DBUclearfilter
         ROW 340
         COL 400
         CAPTION "Clear Filter"
         WIDTH 100
         ACTION (DBUfilterclear(),_DBUfilterbox.release)
      END BUTTON
   END WINDOW
   CENTER WINDOW _DBUfilterbox
   ACTIVATE WINDOW _DBUfilterbox

   RETURN NIL

   *====================================

FUNCTION DBUfilterset()

   *====================================
   _DBUcondition1 := alltrim(_DBUfilterbox._DBUfiltercondition.value)
   IF len(_DBUcondition1) == 0
      DBUfilterclear()
      RELEASE WINDOW _DBUfilterbox
   ELSE
      IF Type("&_DBUcondition1") # "U"
         _DBUcondition := _DBUcondition1
         dbsetfilter({||&_DBUcondition},_DBUcondition)
         GO TOP
         IF eof()
            msgalert("No Records Matching Your Query!","Warning")
            SET filter to
            _DBUfiltered := .f.
            _DBUcondition := ""
         ELSE
            _DBUfiltered := .t.
         ENDIF
         DBUtogglemenu()
         RELEASE WINDOW _DBUfilterbox
         BrowseRefresh()
      ELSE
         msgalert("Wrong Query Condition!","Warning")
      ENDIF
   ENDIF

   RETURN NIL

   *====================================

FUNCTION DBUfilterclear()

   *====================================
   _DBUcondition := ""
   _DBUfiltered := .f.
   SET filter to
   BrowseRefresh()
   _DBU._DBUfilterfile.value := .f.
   DBUtogglemenu()

   RETURN NIL

FUNCTION DBUsetindex()

   _DBUfieldnames := {}
   _DBUstructarr := dbstruct()
   aadd(_DBUfieldnames,"<None>")
   FOR _DBUi := 1 to len(_DBUstructarr)
      aadd(_DBUfieldnames,alltrim(_DBUstructarr[_DBUi,1]))
   NEXT _DBUi
   _DBUinputwindowresult := {}
   IF .not. _DBUindexed
      _DBUinputwindowinitial := 1
   ELSE
      IF len(alltrim(_DBUindexfieldname)) > 0
         _DBUinputwindowinitial := ascan(_DBUstructarr,{|x|upper(alltrim(x[1])) == upper(alltrim(_DBUindexfieldname))}) + 1
      ENDIF
   ENDIF
   _DBUinputwindowresult := inputwindow("Select an Index Field",{"Index On","Ascending"},{_DBUinputwindowinitial,.t.},{_DBUfieldnames,nil})
   IF len(_DBUinputwindowresult) > 0 .and. (_DBUinputwindowresult[1] <> nil .or. _DBUinputwindowresult[2] <> nil)
      IF _DBUinputwindowresult[1] > 0
         IF _DBUinputwindowresult[1] == 1
            SET index to
            _DBUindexed := .f.
         ELSE
            _DBUindexfieldname := alltrim(_DBUfieldnames[_DBUinputwindowresult[1]])
            IF _DBUinputwindowresult[2]
               INDEX ON &_DBUindexfieldname to tmpindex
            ELSE
               INDEX ON &_DBUindexfieldname to tmpindex descending
            ENDIF
            _DBUindexed := .t.
            GO TOP
         ENDIF
      ELSE
         SET index to
         _DBUindexed := .f.
      ENDIF
      BrowseRefresh()
   ENDIF

   RETURN NIL

FUNCTION DBUfilterclick()

   IF _DBU._DBUfilterfile.value
      DBUsetfilter()
   ELSE
      DBUfilterclear()
   ENDIF

   RETURN NIL

FUNCTION DBUreplace

   LOCAL _DBUfieldnamesarr := {}

   IF .not. used()

      RETURN NIL
   ENDIF
   _DBUstructarr := dbstruct()
   FOR _DBUi := 1 to len(_DBUstructarr)
      aadd(_DBUfieldnamesarr,_DBUstructarr[_DBUi,1])
   NEXT _DBUi
   // Window redesigned 21-06-05 - (Pete D)
   DEFINE WINDOW _DBUreplace at 0,0 width 452 height 378 title "Replace Field Values" modal nosysmenu nosize

      DEFINE LISTBOX _DBUFields
         ROW    30
         COL    290
         WIDTH  140
         HEIGHT 200
         ITEMS _DBUfieldnamesarr
         VALUE 0
         FONTNAME "Arial"
         FONTSIZE 9
         TOOLTIP ""
         ONCHANGE _DBUreplace.Repl_Field.Value := alltrim(_DBUreplace._DBUfields.item(_DBUreplace._DBUfields.value))
         ONGOTFOCUS Nil
         ONLOSTFOCUS Nil
         FONTBOLD .F.
         FONTITALIC .F.
         FONTUNDERLINE .F.
         FONTSTRIKEOUT .F.
         BACKCOLOR NIL
         FONTCOLOR NIL
         ONDBLCLICK Nil
         HELPID Nil
         TABSTOP .T.
         VISIBLE .T.
         SORT .F.
         MULTISELECT .F.
      END LISTBOX

      DEFINE FRAME _DBUoptionframe
         ROW    10
         COL    10
         WIDTH  270
         HEIGHT 130
         FONTNAME "Arial"
         FONTSIZE 9
         FONTBOLD .F.
         FONTITALIC .F.
         FONTUNDERLINE .F.
         FONTSTRIKEOUT .F.
         CAPTION "Replace scope"
         BACKCOLOR NIL
         FONTCOLOR NIL
         OPAQUE .T.
      END FRAME

      DEFINE TEXTBOX _DBUnextrecords
         ROW    76
         COL    170
         WIDTH  100
         HEIGHT 24
         FONTNAME "Arial"
         FONTSIZE 9
         TOOLTIP ""
         ONCHANGE Nil
         ONGOTFOCUS Nil
         ONLOSTFOCUS Nil
         FONTBOLD .F.
         FONTITALIC .F.
         FONTUNDERLINE .F.
         FONTSTRIKEOUT .F.
         ONENTER Nil
         HELPID Nil
         TABSTOP .T.
         VISIBLE .T.
         READONLY .F.
         RIGHTALIGN .t.
         BACKCOLOR NIL
         FONTCOLOR NIL
         INPUTMASK "99999999"
         FORMAT Nil
         NUMERIC .T.
         VALUE 0
      END TEXTBOX

      DEFINE LABEL _DBUrecordslabel
         ROW    62
         COL    170
         WIDTH  29
         HEIGHT 12
         VALUE "Recs"
         FONTNAME "Arial"
         FONTSIZE 9
         TOOLTIP ""
         FONTBOLD .F.
         FONTITALIC .F.
         FONTUNDERLINE .F.
         FONTSTRIKEOUT .F.
         HELPID Nil
         VISIBLE .T.
         TRANSPARENT .F.
         ACTION Nil
         AUTOSIZE .F.
         BACKCOLOR NIL
         FONTCOLOR NIL
      END LABEL

      DEFINE LABEL _DBUfieldslabel
         ROW    10
         COL    290
         WIDTH  120
         HEIGHT 16
         VALUE "Available Fields"
         FONTNAME "Arial"
         FONTSIZE 9
         TOOLTIP ""
         FONTBOLD .F.
         FONTITALIC .F.
         FONTUNDERLINE .F.
         FONTSTRIKEOUT .F.
         HELPID Nil
         VISIBLE .T.
         TRANSPARENT .F.
         ACTION Nil
         AUTOSIZE .F.
         BACKCOLOR NIL
         FONTCOLOR NIL
      END LABEL

      DEFINE LABEL _DBUwithlabel
         ROW    210
         COL    20
         WIDTH  40
         HEIGHT 16
         VALUE "With"
         FONTNAME "Arial"
         FONTSIZE 9
         TOOLTIP ""
         FONTBOLD .F.
         FONTITALIC .F.
         FONTUNDERLINE .F.
         FONTSTRIKEOUT .F.
         HELPID Nil
         VISIBLE .T.
         TRANSPARENT .F.
         ACTION Nil
         AUTOSIZE .F.
         BACKCOLOR NIL
         FONTCOLOR NIL
      END LABEL

      DEFINE TEXTBOX _DBUvalue
         ROW    230
         COL    20
         WIDTH  250
         HEIGHT 24
         FONTNAME "Arial"
         FONTSIZE 9
         TOOLTIP "You have to enter a 'FUNCTION' returning with a valid value for the VALTYPE() of the field selected except for Character type Fields. For Example, for date fields ctod(),for numeric fields val() for logical fields iif(.t.,.t.,.f.). The value of this textbox will be passed with the macro (&) operator."
         ONCHANGE Nil
         ONGOTFOCUS Nil
         ONLOSTFOCUS Nil
         FONTBOLD .F.
         FONTITALIC .F.
         FONTUNDERLINE .F.
         FONTSTRIKEOUT .F.
         ONENTER Nil
         HELPID Nil
         TABSTOP .T.
         VISIBLE .T.
         READONLY .F.
         RIGHTALIGN .F.
         BACKCOLOR NIL
         FONTCOLOR NIL
         INPUTMASK Nil
         FORMAT Nil
         VALUE ""
      END TEXTBOX

      DEFINE CHECKBOX _DBUforcheck
         ROW    260
         COL    20
         WIDTH  40
         HEIGHT 20
         CAPTION "For"
         VALUE .F.
         FONTNAME "Arial"
         FONTSIZE 9
         TOOLTIP ""
         ONCHANGE iif(iscontroldefined(_DBUfor,_DBUreplace),iif(_DBUreplace._DBUforcheck.value,_DBUreplace._DBUfor.enabled := .t.,_DBUreplace._DBUfor.enabled := .f.),)
         ONGOTFOCUS Nil
         ONLOSTFOCUS Nil
         FONTBOLD .F.
         FONTITALIC .F.
         FONTUNDERLINE .F.
         FONTSTRIKEOUT .F.
         BACKCOLOR NIL
         FONTCOLOR NIL
         HELPID Nil
         TABSTOP .T.
         VISIBLE .T.
         TRANSPARENT .F.
      END CHECKBOX

      DEFINE TEXTBOX _DBUfor
         ROW    290
         COL    20
         WIDTH  250
         HEIGHT 24
         FONTNAME "Arial"
         FONTSIZE 9
         TOOLTIP "You have to enter a Valid Condition here."
         ONCHANGE iif(iscontroldefined(_DBUfor,_DBUreplace),iif(_DBUreplace._DBUforcheck.value,_DBUreplace._DBUfor.enabled := .t.,_DBUreplace._DBUfor.enabled := .f.),)
         ONGOTFOCUS Nil
         ONLOSTFOCUS Nil
         FONTBOLD .F.
         FONTITALIC .F.
         FONTUNDERLINE .F.
         FONTSTRIKEOUT .F.
         ONENTER Nil
         HELPID Nil
         TABSTOP .T.
         VISIBLE .T.
         READONLY .F.
         RIGHTALIGN .F.
         BACKCOLOR NIL
         FONTCOLOR NIL
         INPUTMASK Nil
         FORMAT Nil
         VALUE ""
      END TEXTBOX

      DEFINE BUTTON _DBUexecute
         ROW    250
         COL    290
         WIDTH  140
         HEIGHT 30
         CAPTION "Replace"
         ACTION DBUexecutereplace()
         FONTNAME "Arial"
         FONTSIZE 9
         TOOLTIP ""
         FONTBOLD .F.
         FONTITALIC .F.
         FONTUNDERLINE .F.
         FONTSTRIKEOUT .F.
         ONGOTFOCUS Nil
         ONLOSTFOCUS Nil
         HELPID Nil
         FLAT .F.
         TABSTOP .T.
         VISIBLE .T.
         TRANSPARENT .F.
         PICTURE Nil
      END BUTTON

      DEFINE BUTTON _DBUreplaceclose
         ROW    300
         COL    290
         WIDTH  140
         HEIGHT 30
         CAPTION "Close"
         ACTION _DBUreplace.release
         FONTNAME "Arial"
         FONTSIZE 9
         TOOLTIP ""
         FONTBOLD .F.
         FONTITALIC .F.
         FONTUNDERLINE .F.
         FONTSTRIKEOUT .F.
         ONGOTFOCUS Nil
         ONLOSTFOCUS Nil
         HELPID Nil
         FLAT .F.
         TABSTOP .T.
         VISIBLE .T.
         TRANSPARENT .F.
         PICTURE Nil
      END BUTTON

      DEFINE RADIOGROUP _DBUoptions
         ROW    30
         COL    40
         WIDTH  130
         HEIGHT 100
         OPTIONS {"Current Record Only","All Records","Next","Rest from Current"}
         VALUE 1
         FONTNAME "Arial"
         FONTSIZE 9
         TOOLTIP ""
         ONCHANGE iif(iscontroldefined(_DBUnextrecords,_DBUreplace),iif(_DBUreplace._DBUoptions.value == 3,_DBUreplace._DBUnextrecords.enabled := .t.,_DBUreplace._DBUnextrecords.enabled := .f.),)
         FONTBOLD .F.
         FONTITALIC .F.
         FONTUNDERLINE .F.
         FONTSTRIKEOUT .F.
         HELPID Nil
         TABSTOP .T.
         VISIBLE .T.
         TRANSPARENT .F.
         SPACING 25
         BACKCOLOR NIL
         FONTCOLOR NIL
      END RADIOGROUP

      DEFINE TEXTBOX Repl_Field
         ROW    180
         COL    20
         WIDTH  250
         HEIGHT 24
         FONTNAME "Arial"
         FONTSIZE 9
         TOOLTIP ""
         ONCHANGE Nil
         ONGOTFOCUS Nil
         ONLOSTFOCUS Nil
         FONTBOLD .F.
         FONTITALIC .F.
         FONTUNDERLINE .F.
         FONTSTRIKEOUT .F.
         ONENTER Nil
         HELPID Nil
         TABSTOP .T.
         VISIBLE .T.
         READONLY .F.
         RIGHTALIGN .F.
         BACKCOLOR NIL
         FONTCOLOR NIL
         INPUTMASK Nil
         FORMAT Nil
         VALUE ""
      END TEXTBOX

      DEFINE LABEL Label_1
         ROW    160
         COL    20
         WIDTH  120
         HEIGHT 16
         VALUE "Field"
         FONTNAME "Arial"
         FONTSIZE 9
         TOOLTIP ""
         FONTBOLD .F.
         FONTITALIC .F.
         FONTUNDERLINE .F.
         FONTSTRIKEOUT .F.
         HELPID Nil
         VISIBLE .T.
         TRANSPARENT .F.
         ACTION Nil
         AUTOSIZE .F.
         BACKCOLOR NIL
         FONTCOLOR NIL
      END LABEL

      DEFINE FRAME Frame_1
         ROW    150
         COL    10
         WIDTH  270
         HEIGHT 180
         FONTNAME "Arial"
         FONTSIZE 9
         FONTBOLD .F.
         FONTITALIC .F.
         FONTUNDERLINE .F.
         FONTSTRIKEOUT .F.
         CAPTION NIL
         BACKCOLOR NIL
         FONTCOLOR NIL
         OPAQUE .T.
      END FRAME

   END WINDOW

   _DBUreplace._DBUfor.enabled := .f.
   _DBUreplace._DBUnextrecords.enabled := .f.
   _DBUreplace.center
   _DBUreplace.activate

   RETURN NIL

FUNCTION DBUexecutereplace

   //JK
   PRIVATE _DBUfieldname := alltrim(_DBUreplace._DBUfields.item(_DBUreplace._DBUfields.value))
   PRIVATE _DBUvalue := alltrim(_DBUreplace._DBUvalue.value)

   IF len(alltrim(_DBUvalue)) == 0
      msgalert("You have to enter the value to be replaced.","DBU Replace")
      _DBUreplace._DBUvalue.setfocus()

      RETURN NIL
   ENDIF
   DO CASE
   CASE _DBUreplace._DBUoptions.value == 1
      IF _DBUreplace._DBUforcheck.value
         _DBUforcondition := alltrim(_DBUreplace._DBUfor.value)
         REPLACE &_DBUfieldname with &_DBUvalue for &_DBUforcondition
      ELSE
         REPLACE &_DBUfieldname with &_DBUvalue
      ENDIF
   CASE _DBUreplace._DBUoptions.value == 2
      IF _DBUreplace._DBUforcheck.value
         _DBUforcondition := alltrim(_DBUreplace._DBUfor.value)
         REPLACE all &_DBUfieldname with &_DBUvalue for &_DBUforcondition
      ELSE
         REPLACE all &_DBUfieldname with &_DBUvalue
      ENDIF
   CASE _DBUreplace._DBUoptions.value == 3
      IF _DBUreplace._DBUnextrecords.value <= 0
         msgalert("You have to enter the number of records to replace!","DBU Replace")
         _DBUreplace._DBUnextrecords.setfocus

         RETURN NIL
      ELSE
         IF _DBUreplace._DBUforcheck.value
            _DBUforcondition := alltrim(_DBUreplace._DBUfor.value)
            REPLACE next _DBUreplace._DBUnextrecords.value &_DBUfieldname with &_DBUvalue for &_DBUforcondition
         ELSE
            REPLACE next _DBUreplace._DBUnextrecords.value &_DBUfieldname with &_DBUvalue
         ENDIF
      ENDIF
   CASE _DBUreplace._DBUoptions.value == 4
      IF _DBUreplace._DBUforcheck.value
         _DBUforcondition := alltrim(_DBUreplace._DBUfor.value)
         REPLACE rest &_DBUfieldname with &_DBUvalue for &_DBUforcondition
      ELSE
         REPLACE rest &_DBUfieldname with &_DBUvalue
      ENDIF
   ENDCASE
   IF _DBUactiveindex > 0
      msginfo("Records had been replaced!. You have to reindex.","DBU Replace")

   ELSE
      msginfo("Records had been replaced!","DBU Replace")

   ENDIF

   _DBUreplace.release
   BrowseRefresh()

   RETURN NIL

   /*
   * DBU_OEM2ANSI()
   * Export legacy Oem Dbf files to ANSI character set and vice versa
   * param: lANSI, logic. If .t. convert to ANSI if .f. converts to OEM
   * To Do: i. add possibility to detect automaticaly
   *           the appropriate conversion type
   *       ii. memo field conversion
   *      iii. add progress bar
   *****************************************************/

FUNCTION DBU_OEM2ANSI( lANSI )

   LOCAL nI, nFields, aStruct, cOldDbf, xField, lOk
   LOCAL cNewDBF, cTitle

   DEFAULT lANSI TO .T.

   cTitle := IF(lANSI, "ANSI", "OEM")

   DBUclosedbf( .F. ) // close all databases without confirmation

   cOldDbf := getfile( { {"xBase File (*.dbf)", "*.dbf"} }, ;
      "Select a DBF to export", _DBUlastpath, .F. )
   IF Empty(cOldDbf)

      RETURN NIL
   ELSEIF ! MG_USE( cOldDbf, "OldDbf", .T., 5, .T. )
      msgStop( "Failed to open file " + cOldDbf + CR_LF + 'Operation aborted..' )

      RETURN NIL
   ELSEIF ! msgOkCancel("Please confirm file export operation." + CR_LF + ;
         "(your original file will remain intact)", cTitle+" export")
      DBUclosedbf( .F. )

      RETURN NIL
   ELSE
      cOldDbf := cFileNoPath(cOldDbf)
      WHILE .T.
         cNewDBF := Left(cOldDbf, At(".",cOldDBf)-1)+"_"+cTitle
         cNewDBF := InputBox("Enter a valid filename (without extension)", cTitle+" export", ;
            cNewDbf,,,.f.)

         IF Empty(cNewDbf)
            IF ! MSGRetryCancel("Blank filename not allowed!", cTitle+" export")
               DBUclosedbf( .F. )

               RETURN NIL
            ENDIF
            LOOP
         ELSE
            IF At(".",cNewDBf) > 0
               cNewDBF := Left(cNewDbf, At(".",cNewDBf)-1)
            ENDIF
            IF File( cNewDbf+".dbf" )
               IF ! msgYesNo("File name already exist." + CR_LF + ;
                     "Overwrite?", cTitle+" export")
                  LOOP
               ENDIF
            ENDIF
         ENDIF
         EXIT
      END
   ENDIF

   aStruct := DBStruct()
   nFields := FCount()
   DBCreate((cNewDBF), aStruct)
   IF ! File( cNewDBF+".dbf" )
      msgStop( "Failed to create new file " + cNewDbf + CR_LF + 'Operation aborted..', cTitle + " export" )

      RETURN NIL
   ENDIF
   IF ! MG_USE(cNewDbf, 'NewDbf', .T., 5, .T. )
      msgStop( "Failed to open file " + cNewDbf + CR_LF + 'Operation aborted..', cTitle + " export" )

      RETURN NIL
   ENDIF
   SELECT OldDbf

   WHILE ! OldDbf->(Eof())
      NewDBF->(DBAppend())
      FOR nI := 1 TO nFields
         xField := FieldGet(nI)
         IF ValType( xField ) == "C"
            xField := IF( lANSI, HB_OEMTOANSI( xField ), HB_ANSITOOEM(xField) )
         ENDIF
         NewDBF->( FieldPut(nI, xField) )
      NEXT nI
      OldDbf->( DBSkip() )
   END

   lOk := ( OldDbf->(lastrec()) == NewDbf->(lastrec()) )

   DBUclosedbf( .F. ) // close all databases without confirmation

   IF lOk
      IF msgYesNo( "The File has been succesfuly exported!" + CR_LF + ;
            + CR_LF + "Browse new file " + cNewDbf + " ?", cTitle+" export" )
         DBUopendbf((cNewDbf+".dbf"),2)
      ENDIF
   ELSE
      msgStop("Failed to export file!", cTitle+" export" )
   ENDIF

   RETURN NIL

FUNCTION BrowseRefresh()

   IF IsWindowDefined( _DBUBrowse )
      domethod( '_DBUBrowse', 'Hide' )
      domethod( '_DBUBrowse','_DBUrecord', 'Refresh' )
      domethod( '_DBUBrowse','Show' )
   ENDIF

   RETURN NIL

   * (JK)

FUNCTION MG_USE(cDbfName, cAlias, lUseExclusive, nTries, lAsk, cdPage)

   LOCAL nTriesOrig, lReturn:=.f.

   cdPage := IF(Empty(cdPage), 'EN', cdPage)

   IF file(cDbfName)==.f. .and. file(cDbfName+".dbf")==.f.
      MsgStop('No access to database file',cDbfName)

      RETURN lReturn
   ENDIF

   nTriesOrig := nTries
   DO WHILE nTries > 0
      dbUseArea(.t.,NIL,cDbfName,cAlias,!lUseExclusive,.f.,cdPage)
      IF !NetErr() .and. Used()
         lReturn := .t.
         EXIT
      ENDIF
      inkey(.5)
      nTries--
      IF nTries==0 .and. lAsk==.t.
         IF MsgRetryCancel("Database is occupied by another user","No access")
            nTries := nTriesOrig
         ENDIF
      ENDIF
   ENDDO

   RETURN lReturn
