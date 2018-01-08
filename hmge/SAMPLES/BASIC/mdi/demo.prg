/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
* http://harbourminigui.googlepages.com/
* Windows MDI demo & tests by Janusz Pora
* (C)2005 Janusz Pora <januszpora@onet.eu>
* HMG 1.0 Experimental Build 8-12
* 2006/07/01 Revised by Pierpaolo Martinello <pier.martinello[at]alice.it>
* Added Maximize, Restore for Mdi Child Window
*/

#include "minigui.ch"

// add By Pier 2006/07/01 Start
#define WM_MDIMAXIMIZE                  0x0225
#define WM_MDIRESTORE                   0x0223
// add By Pier 2006/07/01 Stop

STATIC nWidth
STATIC nHeight

MEMVAR nChild

FUNCTION Main

   PUBLIC nChild := 0

   nWidth  := GetDesktopWidth() * 0.78125
   nHeight := GetDesktopHeight() * 0.78125

   SET InteractiveClose Query Main

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH nWidth ;
         HEIGHT nHeight ;
         TITLE 'MDI demo ' ;
         MAIN ;
         MDI ;
         FONT 'System' SIZE 12

      DEFINE MAIN MENU

         POPUP 'File'
            ITEM 'New'          ACTION NewMDIClient()
            ITEM 'Open'         ACTION OpenMDIClient()
            ITEM 'Save'         ACTION SaveMdi()
            ITEM 'Save As...'   ACTION SaveMdi("")
            SEPARATOR
            ITEM 'Exit'         ACTION Form_1.Release
         END POPUP

         POPUP 'Child Windows'
            POPUP '&Tiled'
               ITEM '&Horizontal '  ACTION WinChildTile(.f.)
               ITEM '&Vertical '    ACTION WinChildTile(.t.)
            END POPUP
            ITEM '&Cascade'          ACTION WinChildCascade()
            ITEM 'Arrange &Icons'    ACTION WinChildIcons()
            SEPARATOR
            ITEM 'Maximize'          Action WinChildMaximize()
            ITEM 'Restore'           Action WinChildRestore()
            SEPARATOR
            ITEM 'Close &All'        ACTION WinChildCloseAll()
            ITEM '&Restore All'      ACTION WinChildRestoreAll()
         END POPUP

         POPUP 'Help'
            ITEM 'HMG Version'       ACTION MsgInfo (MiniGuiVersion())
            ITEM 'About'             ACTION  MsgInfo (padc("MiniGUI MDI Demo", Len(MiniguiVersion()))+CRLF+ ;
               "Contributed by Janusz Pora <januszpora@onet.eu>"+CRLF+ ;
               "and Pierpaolo Martinello <pier.martinello[at]alice.it>"+CRLF+CRLF+ ;
               MiniguiVersion(),"A COOL Feature ;)")
         END POPUP

      END MENU

      DEFINE STATUSBAR FONT 'MS Sans Serif' SIZE 9
         STATUSITEM "HMG Power Ready!"
         CLOCK
         DATE
      END STATUSBAR

      DEFINE SPLITBOX

         DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 17,17 FLAT

            BUTTON Btn_New ;
               TOOLTIP 'Create a New Child Window' ;
               PICTURE 'NEW.BMP' ;
               ACTION NewMDIClient()

            BUTTON Btn_Open ;
               TOOLTIP 'Open a File' ;
               PICTURE 'OPEN.BMP' ;
               ACTION OpenMDIClient()

            BUTTON Btn_Close ;
               TOOLTIP 'Close Active Child Window' ;
               PICTURE 'CLOSE.BMP' ;
               ACTION CloseMdi()

            BUTTON Btn_Save ;
               TOOLTIP 'Save To File' ;
               PICTURE 'SAVE.BMP' ;
               ACTION SaveMdi()

         END TOOLBAR

      END SPLITBOX

      Form_1.Btn_Save.Enabled  := .f.
      Form_1.Btn_Close.Enabled := .f.

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

   RETURN NIL

FUNCTION NewMDIClient()

   CreateMDIClient()

   RETURN NIL

FUNCTION OpenMDIClient()

   LOCAL c_File := GetFile({{'Text File','*.txt'}, {'All File','*.*'}}, 'Get File')

   IF empty(c_File)

      RETURN NIL
   ENDIF
   IF ! File( c_File )
      MSGSTOP("File I/O error, cannot proceed")

      RETURN NIL
   ENDIF

   CreateMDIClient(MemoRead(c_File), c_File)

   RETURN NIL

FUNCTION SaveMdi(cFile)

   LOCAL ChildHandle, ChildName, cVar

   IF nChild > 0
      ChildHandle := GetActiveMdiHandle()
      GET WINDOWPROPERTY "PROP_FORMNAME" VALUE ChildName
      IF valtype(cFile) == 'U'
         GET WINDOWPROPERTY "PROP_CFILE" VALUE cFile
      ENDIF
      cVar := GetProperty ( ChildName , "EditMdi" , "Value" )
      IF 'No Title' $ cFile .or. Empty(cFile)
         cFile := Putfile ( { {'Text Files','*.txt'} , {'All Files','*.*'} } , 'Save File' )
         IF !empty(cFile)
            Memowrit( cFile , cVar )
         ELSE

            Return(.f.)
         ENDIF
      ELSE
         Memowrit( cFile , cVar )
      ENDIF
      SET WINDOWPROPERTY "PROP_MODIFIED" VALUE .f.
      Form_1.Btn_Save.Enabled  := .f.
   ENDIF

   Return(.t.)

FUNCTION CreateMDIClient(Buffer,title)

   IF Valtype(Buffer) == 'U'
      Buffer := ""
   ENDIF
   IF Valtype(Title) == 'U'
      TITLE := "No Title "+ltrim(str(nchild+1)) // add By Pier 2006/07/01
   ENDIF

   DEFINE WINDOW ChildMdi ;
         TITLE title ;
         MDICHILD ;
         ON INIT ResizeEdit() ;
         ON RELEASE ReleaseMdiChild() ;
         ON SIZE ResizeEdit() ;
         ON MAXIMIZE ResizeEdit() ;
         ON MINIMIZE ResizeEdit() ;
         ON MOUSECLICK SetEditFocus()

      @ 0 ,0 EDITBOX EditMdi ;
         WIDTH 200 ;
         HEIGHT 200 ;
         VALUE Buffer ;
         ON CHANGE SetChange()

   END WINDOW

   nChild++

   Form_1.Btn_Close.Enabled := .t.
   Form_1.Btn_Save.Enabled  := .f.

   RETURN NIL

FUNCTION SetChange()

   SET WINDOWPROPERTY "PROP_MODIFIED" VALUE .t.
   Form_1.Btn_Save.Enabled  := .t.

   RETURN NIL

FUNCTION CloseMdi()

   CLOSE ACTIVE MDICHILD
   Form_1.Btn_Close.Enabled := nChild > 0
   Form_1.Btn_Save.Enabled  := nChild > 0

   RETURN NIL

FUNCTION ReleaseMdiChild()

   LOCAL ChildHandle, cFile, lModif

   GET WINDOWPROPERTY "PROP_MODIFIED" VALUE lModif
   IF lModif
      GET WINDOWPROPERTY "PROP_CFILE" VALUE cFile
      IF MsgYesNo ('Save changes?', cFile)
         SaveMdi(cFile)
      ENDIF
   ENDIF
   nChild--
   Form_1.Btn_Close.Enabled := nChild > 0
   Form_1.Btn_Save.Enabled  := nChild > 0

   RETURN .f.

FUNCTION ResizeChildEdit(ChildName)

   LOCAL hwndCln, actpos:={0,0,0,0}
   LOCAL i, w, h

   i := aScan ( _HMG_aFormNames , ChildName)
   IF i > 0
      hwndCln := _HMG_aFormHandles  [i]
      GetClientRect(hwndCln,actpos)
      w := actpos[3]-actpos[1]
      h := actpos[4]-actpos[2]
      _SetControlHeight( "EditMdi", ChildName, h)
      _SetControlWidth( "EditMdi", ChildName,w)
   ENDIF

   RETURN NIL

FUNCTION ResizeAllChildEdit()

   LOCAL nFrm, ChildName, n

   nFrm := len(_HMG_aFormHandles)
   FOR n:=1 to nFrm
      IF _HMG_aFormType  [n] ==  'Y'
         ChildName := _HMG_aFormNames  [n]
         ResizeChildEdit(ChildName)
      ENDIF
   NEXT

   RETURN NIL

FUNCTION ResizeEdit()

   LOCAL ChildHandle, i, ChildName

   ChildHandle := GetActiveMdiHandle()
   i := aScan ( _HMG_aFormHandles , ChildHandle )
   IF i > 0
      ChildName := _HMG_aFormNames  [i]
      ResizeChildEdit(ChildName)
   ENDIF

   RETURN NIL

   // add By Pier 2006/07/01 Start

FUNCTION WinChildMaximize()

   LOCAL ChildHandle

   ChildHandle := GetActiveMdiHandle()
   IF aScan ( _HMG_aFormHandles , ChildHandle ) > 0
      Sendmessage(_HMG_MainClientMDIHandle,WM_MDIMAXIMIZE,ChildHandle,0)
   ENDIF

   RETURN NIL

FUNCTION WinChildRestore()

   LOCAL ChildHandle, i

   ChildHandle := GetActiveMdiHandle()
   IF aScan ( _HMG_aFormHandles , ChildHandle ) > 0
      Sendmessage(_HMG_MainClientMDIHandle,WM_MDIRESTORE,ChildHandle,0)
   ENDIF

   RETURN NIL

   // add By Pier 2006/07/01 Stop

FUNCTION SetEditFocus()

   LOCAL ChildHandle, lModif, ChildName
   LOCAL i

   ChildHandle := GetActiveMdiHandle()
   GET WINDOWPROPERTY "PROP_MODIFIED" VALUE lModif
   i := aScan ( _HMG_aFormHandles , ChildHandle )
   IF i > 0
      ChildName := _HMG_aFormNames  [i]
      _SetFocus ( "EditMdi", ChildName)
   ENDIF

   Form_1.Btn_Save.Enabled  := lModif

   RETURN NIL

FUNCTION WinChildTile(lVert)

   IF lVert
      TILE MDICHILDS VERTICAL
   ELSE
      TILE MDICHILDS HORIZONTAL
   ENDIF
   ResizeAllChildEdit()

   RETURN NIL

FUNCTION WinChildCascade()

   CASCADE MDICHILDS
   ResizeAllChildEdit()

   RETURN NIL

FUNCTION WinChildIcons()

   ARRANGE MDICHILD ICONS

   RETURN NIL

FUNCTION WinChildCloseAll()

   CLOSE MDICHILDS ALL

   RETURN NIL

FUNCTION WinChildRestoreAll()

   RESTORE MDICHILDS ALL

   RETURN NIL
