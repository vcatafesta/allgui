/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
* http://harbourminigui.googlepages.com/
* Windows MDI demo & tests by Janusz Pora
* (C)2005-2007 Janusz Pora <januszpora@onet.eu>
* HMG 1.0 Experimental Build 32
* 2006/07/01 Revised by Pierpaolo Martinello <pier.martinello[at]alice.it>
* Added Maximize, Restore for Mdi Child Window
*/

#include "minigui.ch"

// add By Pier 2006/07/01 Start
#define WM_MDIMAXIMIZE 0x0225
#define WM_MDIRESTORE 0x0223
// add By Pier 2006/07/01 Stop

STATIC nWidth
STATIC nHeight
MEMVAR nChild

FUNCTION Main

   PUBLIC nChild := 0

   nWidth := GetDesktopWidth() * 0.78125
   nHeight := GetDesktopHeight() * 0.78125

   SET InteractiveClose Query Main

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH nWidth ;
         HEIGHT nHeight ;
         TITLE 'MDI demo ' ;
         MAIN MDI;
         FONT 'System' SIZE 12 ;
         BACKCOLOR BLUE

      DEFINE MAIN MENU

         POPUP 'File'
            ITEM 'New' ACTION NewMDIClient()
            SEPARATOR
            ITEM 'Exit' ACTION Form_1.Release
         END POPUP

         POPUP 'Child Windows'
            POPUP '&Tiled'
               ITEM '&Horizontal ' ACTION WinChildTile(.f.)
               ITEM '&Vertical ' ACTION WinChildTile(.t.)
            END POPUP
            ITEM '&Cascade' ACTION WinChildCascade()
            ITEM 'Arrange &Icons' ACTION WinChildIcons()
            SEPARATOR
            ITEM 'Maximize' Action WinChildMaximize()
            ITEM 'Restore' Action WinChildRestore()
            SEPARATOR
            ITEM 'Close &All' ACTION WinChildCloseAll()
            ITEM '&Restore All' ACTION WinChildRestoreAll()
         END POPUP

         POPUP 'Help'
            ITEM 'HMG Version' ACTION MsgInfo(MiniGuiVersion())
            ITEM 'About' ACTION MsgInfo(padc("MiniGUI MDI Demo", Len(MiniguiVersion()))+CRLF+ ;
               "Contributed by Janusz Pora <januszpora@onet.eu>"+CRLF+ ;
               "and Pierpaolo Martinello <pier.martinello[at]alice.it>"+CRLF+CRLF+ ;
               MiniguiVersion(),"A COOL Feature ;)")
         END POPUP

      END MENU

      DEFINE STATUSBAR FONT 'MS Sans Serif' SIZE 9
         STATUSITEM "in MAIN MDI F2 {msginfo()}  F5 {Onclick Btn_new} "  WIDTH 250
         STATUSITEM "in CHILD MDI F3 {msginfo()} F4  {OK button}"  WIDTH 250
         CLOCK
         DATE
      END STATUSBAR

      DEFINE SPLITBOX

         DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 17,17 FLAT

            BUTTON Btn_New ;
               TOOLTIP 'Create a New Child Window' ;
               PICTURE 'NEW.BMP' ;
               ACTION NewMDIClient()

            BUTTON Btn_Close ;
               TOOLTIP 'Close Active Child Window' ;
               PICTURE 'CLOSE.BMP' ;
               ACTION CloseMdi()

         END TOOLBAR

      END SPLITBOX

      Form_1.Btn_Close.Enabled := .f.
      ON KEY F2 ACTION MsgInfo("F2 pressed in MAIN MDI")
      ON KEY F5 ACTION DOMETHOD( _HMG_MainClientMDIName, "Btn_New", "OnClick" ) //JP

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

FUNCTION CreateMDIClient(Buffer,title)

   IF Valtype(Buffer) == 'U'
      Buffer := ""
   ENDIF
   IF Valtype(Title) == 'U'
      Title := "No Title "+ltrim(str(nchild+1)) // add By Pier 2006/07/01
   ENDIF

   DEFINE WINDOW ChildMdi ;
         TITLE title ;
         MDICHILD ;
         ON RELEASE ReleaseMdiChild() ;
         ON INTERACTIVECLOSE MsgYesNo("Are you sure ?", "Close this window")

      @ 0 ,0 EDITBOX EditMdi ;
         WIDTH 200 ;
         HEIGHT 200 ;
         VALUE Buffer;
         TOOLTIP "Hello Tooltip" ;
         ON CHANGE SetChange()

      @ 0, 250 BUTTON Button_1 ;
         CAPTION "OK" ;
         ACTION MsgInfo("You pressed Button OK") ;
         WIDTH 50 ;
         Height 50 ;
         ToolTip "OK Button"

      ON KEY F3 ACTION MsgInfo("F3 pressed in CHILD MDI")
      ON KEY F4 ACTION DOMETHOD( MyGetMDIHandle(), "Button_1", "OnClick" ) //JP

   END WINDOW

   nChild++

   Form_1.Btn_Close.Enabled := .t.

   RETURN NIL

FUNCTION CloseMdi()

   CLOSE ACTIVE MDICHILD
   Form_1.Btn_Close.Enabled := nChild > 0

   RETURN NIL

FUNCTION setchange()

   setproperty(MyGetMdiHandle(),"EditMdi","VALUE","new set")

   RETURN NIL

FUNCTION ReleaseMdiChild()

   LOCAL ChildHandle, cFile, lModif

   nChild--
   Form_1.Btn_Close.Enabled := nChild > 0

   RETURN .f.

   // add By Pier 2006/07/01 Start

FUNCTION WinChildMaximize()

   LOCAL ChildHandle

   ChildHandle := GetActiveMdiHandle()
   IF aScan ( _HMG_aFormHandles , ChildHandle ) > 0
      SendMessage(_HMG_MainClientMDIHandle,WM_MDIMAXIMIZE,ChildHandle,0)
   ENDIF

   RETURN NIL

FUNCTION WinChildRestore()

   LOCAL ChildHandle, i

   ChildHandle := GetActiveMdiHandle()
   IF aScan ( _HMG_aFormHandles , ChildHandle ) > 0
      SendMessage(_HMG_MainClientMDIHandle,WM_MDIRESTORE,ChildHandle,0)
   ENDIF

   RETURN NIL
   // add By Pier 2006/07/01 Stop

FUNCTION WinChildTile(lVert)

   IF lVert
      TILE MDICHILDS VERTICAL
   ELSE
      TILE MDICHILDS HORIZONTAL
   ENDIF

   RETURN NIL

FUNCTION WinChildCascade()

   CASCADE MDICHILDS

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

   //JP MDI

FUNCTION MyGetMDIHandle()

   RETURN thiswindow.name

