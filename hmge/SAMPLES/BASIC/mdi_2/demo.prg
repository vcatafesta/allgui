/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
* http://harbourminigui.googlepages.com/

* Windows Browse MDI demo & tests by Janusz Pora
* (C)2005 Janusz Pora <januszpora@onet.eu>
* HMG 1.0 Experimental Build 12
*/

#include "minigui.ch"

#define CLR_DEFAULT   0xff000000

STATIC nWidth
STATIC nHeight

MEMVAR lModif
MEMVAR nChild
MEMVAR nAlias

FUNCTION Main

   REQUEST DBFCDX

   SET CENTURY ON
   SET DELETED ON

   SET BROWSESYNC ON

   PUBLIC lModif := .f.
   PUBLIC nChild := 0
   PUBLIC nAlias := 0

   nWidth  := GetDesktopWidth() * 0.78125
   nHeight := GetDesktopHeight() * 0.78125

   SET InteractiveClose Query Main

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH nWidth ;
         HEIGHT nHeight ;
         TITLE 'Browse MDI demo ' ;
         MAIN ;
         MDI ;
         FONT 'System' SIZE 10

      DEFINE MAIN MENU

         POPUP 'File'
            ITEM 'Open'      ACTION OpenMDIClient()
            ITEM 'Close'      ACTION CloseMdi()
            SEPARATOR
            ITEM 'Exit'      ACTION Form_1.Release
         END POPUP

         POPUP 'Child Windows'
            POPUP '&Tiled'
               ITEM '&Horizontal '   ACTION WinChildTile(.f.)
               ITEM '&Vertical '   ACTION WinChildTile(.t.)
            END POPUP
            ITEM '&Cascade'      ACTION WinChildCascade()
            ITEM 'Arrange &Icons'    ACTION WinChildIcons()
            SEPARATOR
            ITEM 'Close &All'   ACTION WinChildCloseAll()
            ITEM '&Restore All'   ACTION WinChildRestoreAll()
         END POPUP

         POPUP 'Help'
            ITEM 'HMG Version'   ACTION MsgInfo ( MiniGuiVersion() )
            ITEM 'About'      ACTION  MsgInfo ( padc( "MiniGUI MDI Demo", Len(MiniguiVersion()) )+CRLF+ ;
               "Contributed by Janusz Pora <januszpora@onet.eu>"+CRLF+CRLF+ ;
               MiniguiVersion(),"A COOL Feature ;)" )
         END POPUP

      END MENU

      DEFINE STATUSBAR FONT 'MS Sans Serif' SIZE 9
         STATUSITEM "HMG Power Ready!"
         STATUSITEM "" WIDTH 150
         CLOCK
         DATE
      END STATUSBAR

      DEFINE IMAGELIST imagelst_1 ;
         OF Form_1 ;
         BUTTONSIZE 16 , 16  ;
         IMAGE {'BtnLst.bmp'} ;
         COLORMASK CLR_DEFAULT ;
         IMAGECOUNT 6 MASK

      DEFINE SPLITBOX

         DEFINE TOOLBAREX ToolBar_1 BUTTONSIZE 20,20 IMAGELIST 'imagelst_1' FLAT

         BUTTON Btn_Open ;
            PICTUREINDEX 1 ;
            TOOLTIP 'Open a File' ;
            ACTION OpenMDIClient()

         BUTTON Btn_Close ;
            PICTUREINDEX 2 ;
            TOOLTIP 'Close Active Child Window' ;
            ACTION CloseMdi()

      END TOOLBAR

   END SPLITBOX

   Form_1.Btn_Close.Enabled := .f.

END WINDOW

CENTER WINDOW Form_1

ACTIVATE WINDOW Form_1

RETURN NIL

FUNCTION OpenMDIClient()

   LOCAL c_File := GetFile({{'dBase File','*.dbf'}}, 'Get File')

   IF empty(c_File)

      RETURN NIL
   ENDIF
   IF ! File( c_File )
      MSGSTOP("File I/O error, cannot proceed")

      RETURN NIL
   ENDIF

   CreateMDIClient(c_File)

   RETURN NIL

FUNCTION CreateMDIClient(cFile)

   LOCAL a_fields , a_width, cxFile

   IF Valtype(cFile) == 'U'
      cFile := "No_Title"
   ENDIF

   nAlias++
   cxFile :=ALLTRIM(substr(cFile,Rat('\',cFile)+1))
   cxFile :=substr(cxFile,1,len(cxFile)-4)+"_"+ltrim(str(nAlias))
   a_fields := {}
   a_width  := {}

   OpenTables(cFile, cxFile, a_fields, a_width)

   nChild++

   DEFINE WINDOW ChildMdi ;
         TITLE "Child " + ltrim(str(nChild)) + ": " + cFile ;
         MDICHILD ;
         ON INIT ( ResizeEdit(), SetColumnsWidth() ) ;
         ON RELEASE ( CloseTables(), ReleaseMdiChild() ) ;
         ON SIZE ResizeEdit() ;
         ON MAXIMIZE ResizeEdit() ;
         ON MINIMIZE ResizeEdit() ;
         ON MOUSECLICK SetEditFocus()

      @ 0,0 BROWSE BrwMdi                        ;
         WIDTH 200                                ;
         HEIGHT 200                              ;
         HEADERS a_fields ;
         WIDTHS a_width ;
         WORKAREA &cxFile ;
         FIELDS a_fields ;
         TOOLTIP 'Browse Test' ;
         DELETE ;
         LOCK ;
         EDIT

      SET WINDOWPROPERTY "PROP_DBF" VALUE cxFile

   END WINDOW

   lModif := .f.
   Form_1.Btn_Close.Enabled := .t.

   RETURN NIL

PROCEDURE OpenTables(cFile, cAlias, a_fields, a_width)

   LOCAL n

   USE &cFile Via "DBFCDX" Alias (cAlias) SHARED NEW
   GO TOP

   FOR n:=1 to fcount()
      aadd( a_fields , fieldname( n ) )
      aadd( a_width  , fieldsize( n ) )
   NEXT

   RETURN

PROCEDURE CloseTables()

   USE

   RETURN

PROCEDURE SetChange()

   IF !lModif
      lModif := .t.
      SET WINDOWPROPERTY "PROP_MODIFIED" VALUE lModif
   ENDIF

   RETURN

PROCEDURE CloseMdi()

   CLOSE ACTIVE MDICHILD
   Form_1.Btn_Close.Enabled := nChild > 0

   RETURN

PROCEDURE ReleaseMdiChild()

   LOCAL cFile

   GET WINDOWPROPERTY "PROP_MODIFIED" VALUE lModif
   GET WINDOWPROPERTY "PROP_CFILE" VALUE cFile

   nChild--
   Form_1.Btn_Close.Enabled := nChild > 0

   RETURN

PROCEDURE SetColumnsWidth()

   LOCAL ChildHandle, ChildName
   LOCAL i

   ChildHandle := GetActiveMdiHandle()
   i := aScan ( _HMG_aFormHandles , ChildHandle )
   IF i > 0
      ChildName := _HMG_aFormNames  [i]
      _EnableListViewUpdate( "BrwMdi", ChildName, .f. )
      _SetColumnsWidthAutoH( "BrwMdi", ChildName )
      _EnableListViewUpdate( "BrwMdi", ChildName, .t. )
   ENDIF

   RETURN

PROCEDURE ResizeChildEdit(ChildName)

   LOCAL hwndCln, actpos:={0,0,0,0}
   LOCAL i, w, h

   i := aScan ( _HMG_aFormNames , ChildName )
   IF i > 0
      hwndCln := _HMG_aFormHandles  [i]
      GetClientRect(hwndCln, actpos)
      w := actpos[3]-actpos[1]
      h := actpos[4]-actpos[2]
      _SetControlHeight( "BrwMdi", ChildName, h)
      _SetControlWidth( "BrwMdi", ChildName, w)
   ENDIF

   RETURN

PROCEDURE ResizeAllChildEdit()

   LOCAL nfrm, ChildName, n

   nFrm := len(_HMG_aFormHandles)
   FOR n:=1 to nFrm
      IF _HMG_aFormType [n] == 'Y'
         ChildName := _HMG_aFormNames [n]
         ResizeChildEdit(ChildName)
      ENDIF
   NEXT

   RETURN

PROCEDURE ResizeEdit()

   LOCAL ChildHandle, ChildName
   LOCAL i

   ChildHandle := GetActiveMdiHandle()
   i := aScan ( _HMG_aFormHandles , ChildHandle )
   IF i > 0
      ChildName := _HMG_aFormNames [i]
      ResizeChildEdit(ChildName)
   ENDIF

   RETURN

PROCEDURE SetEditFocus()

   LOCAL ChildHandle, ChildName, cxFile
   LOCAL i

   GET WINDOWPROPERTY "PROP_MODIFIED" VALUE lModif

   ChildHandle := GetActiveMdiHandle()
   i := aScan ( _HMG_aFormHandles , ChildHandle )
   IF i > 0
      ChildName := _HMG_aFormNames [i]
      _SetFocus ( "BrwMdi", ChildName )
      DoMethod ( ChildName, "BrwMdi", "Refresh" )
   ENDIF

   GET WINDOWPROPERTY "PROP_DBF" VALUE cxFile
   IF Select(cxFile) > 0
      Select(cxFile)
   ENDIF

   RETURN

PROCEDURE WinChildTile(lVert)

   IF lVert
      TILE MDICHILDS VERTICAL
   ELSE
      TILE MDICHILDS HORIZONTAL
   ENDIF
   ResizeAllChildEdit()

   RETURN

PROCEDURE WinChildCascade()

   CASCADE MDICHILDS
   ResizeAllChildEdit()

   RETURN

PROCEDURE WinChildIcons()

   ARRANGE MDICHILD ICONS

   RETURN

PROCEDURE WinChildCloseAll()

   CLOSE MDICHILDS ALL
   CLOSE ALL
   nAlias := 0

   RETURN

PROCEDURE WinChildRestoreAll()

   RESTORE MDICHILDS ALL

   RETURN
