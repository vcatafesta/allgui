/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
* http://harbourminigui.googlepages.com/
*/

#include "hmg.ch"

MEMVAR cFile

FUNCTION Main

   PRIVATE cFile:="test.rtf"

   SET AUTOADJUST ON

   OpenTable()

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH 640 HEIGHT 480 ;
         TITLE 'Harbour MiniGUI RichEdit Demo - Based Upon a Contribution by Janusz Pora' ;
         MAIN ;
         ON INIT ReadField() ;
         ON RELEASE CloseTable()

      ON KEY CONTROL+N ACTION New_File()
      ON KEY CONTROL+O ACTION Open_File()
      ON KEY CONTROL+S ACTION Save_File(0)

      DEFINE MAIN MENU
         POPUP '&File'
            ITEM '&New'+chr(9)+'Ctrl+N'          ACTION New_File()
            ITEM '&Open'+chr(9)+'Ctrl+O'      ACTION Open_File()
            ITEM '&Save'+chr(9)+'Ctrl+S'      ACTION Save_File(0)
            ITEM 'Save &as ...'                   ACTION Save_File(1)
            SEPARATOR
            ITEM 'E&xit'      ACTION Form_1.Release
         END POPUP
      END MENU

      @ 20,10 LABEL Label_1 ;
         VALUE "This is Richedit control with FILE clause set" ;
         AUTOSIZE ;
         FONT "Arial" SIZE 10 BOLD

      @ 45,10 RICHEDITBOX Edit_1 ;
         WIDTH 610 ;
         HEIGHT 140 ;
         FILE cFile ;
         VALUE '' ;
         TOOLTIP 'RichEditBox';
         ON CHANGE Form_1.Btn_2.Enabled :=.t. ;
         NOHSCROLL

      @ 210,10 LABEL Label_2 ;
         VALUE "This is Richedit control with FIELD clause set" ;
         AUTOSIZE ;
         FONT "Arial" SIZE 10 BOLD

      @ 235 ,10  BROWSE Browse_1;
         WIDTH 300 ;
         HEIGHT 140 ;
         HEADERS { 'Code' , 'First Name' , 'Biography' } ;
         WIDTHS { 50 , 120 , 110 } ;
         WORKAREA Test ;
         FIELDS { 'Test->Code' , 'Test->First' , 'Test->Bio' } ;
         VALUE 1;
         ON CHANGE ChangeTest()

      @ 235,315 RICHEDITBOX Edit_2 ;
         WIDTH 295 ;
         HEIGHT 140 ;
         FIELD test->bio ;
         VALUE '' ;
         TOOLTIP 'RichEditBox';
         ON CHANGE Form_1.Btn_3.Enabled :=.t.

      @ 390,20 BUTTON Btn_1 ;
         CAPTION 'Open File' ;
         ACTION Open_File();
         WIDTH 80 ;
         HEIGHT 24 ;
         TOOLTIP 'Load Rich Text File'

      @ 390,120 BUTTON Btn_2 ;
         CAPTION 'Save File' ;
         ACTION Save_File(0);
         WIDTH 80 ;
         HEIGHT 24 ;
         TOOLTIP 'Save Rich Text File'

      @ 390,320 BUTTON Btn_3 ;
         CAPTION 'Save Field' ;
         ACTION SaveField();
         WIDTH 80 ;
         HEIGHT 24 ;
         TOOLTIP 'Save data from RichEditBox'

      @ 390,420 BUTTON Btn_4 ;
         CAPTION 'Exit' ;
         ACTION Form_1.Release;
         WIDTH 80 ;
         HEIGHT 24 ;
         TOOLTIP 'Exit form program'

      DEFINE CONTEXT MENU CONTROLS Edit_1, Edit_2
         MENUITEM "&Undo"   ACTION mnuEditUndo_Click() NAME mnuEditUndo
         SEPARATOR
         MENUITEM "Cu&t"      ACTION mnuEditCut_Click() NAME mnuEditCut
         MENUITEM "&Copy"   ACTION mnuEditCopy_Click() NAME mnuEditCopy
         MENUITEM "&Paste"   ACTION mnuEditPaste_Click() NAME mnuEditPaste
         MENUITEM "&Delete"   ACTION mnuEditDelete_Click() NAME mnuEditDelete
         SEPARATOR
         MENUITEM "Select &All"   ACTION mnuEditSelAll_Click() NAME mnuEditSelAll
      END MENU

      DEFINE TIMER mnuEditContext INTERVAL 100 ACTION EnableEditMenuItems()

   END WINDOW

   Form_1.Edit_1.AutoFont := .t.
   Form_1.Edit_2.AutoFont := .f.

   Form_1.Btn_2.Enabled :=.f.
   Form_1.Btn_3.Enabled :=.f.

   Form_1.Center

   Form_1.Activate

   RETURN NIL

FUNCTION New_File()

   LOCAL  cBuffer:=''

   _Setvalue ( 'Edit_1','Form_1', cBuffer )
   Form_1.Btn_2.Enabled :=.f.

   RETURN NIL

FUNCTION Read_file(c_File)

   LOCAL typ, cRichValue := ""

   IF ! File( c_File )
      MSGSTOP("File I/O error, cannot proceed")

      RETURN NIL
   ENDIF

   IF UPPER(ALLTRIM(substr(c_File,Rat('.',c_File)+1))) == 'RTF'
      typ := 2
   ELSE
      typ := 1
   ENDIF

   Form_1.Edit_1.RichValue := cRichValue

   _DataRichEditBoxOpen ( 'Edit_1','Form_1', c_File, typ )

   Form_1.Btn_2.Enabled :=.f.

   RETURN NIL

FUNCTION Open_File()

   cFile := GetFile( {{'Rich text File','*.rtf'},{'Text File','*.txt'}} , 'Get File' )

   IF !empty(cFile)
      Read_file(cFile)
   ENDIF

   RETURN NIL

FUNCTION Save_File(met)

   LOCAL c_File := cFile

   IF met == 1
      c_File := PutFile ( {{'Rich text File','*.rtf'},{'Text File','*.txt'}} , 'Get File' )
   ENDIF

   IF !empty(c_File)

      IF Upper(AllTrim(SubStr(c_File, Rat('.',c_File) + 1))) == 'RTF'
         MemoWrit( c_File, Form_1.Edit_1.RichValue )
      ELSE
         MemoWrit( c_File, Form_1.Edit_1.Value )
      ENDIF

      Form_1.Btn_2.Enabled :=.f.

   ENDIF

   RETURN NIL

FUNCTION OpenTable()

   USE test

   RETURN NIL

FUNCTION CloseTable()

   USE

   RETURN NIL

FUNCTION ReadField()

   DoMethod ( 'Form_1' , 'Edit_2', 'Refresh' )
   Form_1.Btn_3.Enabled :=.f.

   RETURN NIL

FUNCTION ChangeTest()

   LOCAL rec

   rec := Form_1.Browse_1.Value
   dbGoTo(rec)
   ReadField()

   RETURN NIL

FUNCTION SaveField()

   DoMethod ( 'Form_1' , 'Edit_2', 'Save' )
   Form_1.Btn_3.Enabled :=.f.

   RETURN NIL

   /*
   RichEdit with default Windows Context Popup Menu

   Standard popup items are:
   Undo - backs out all changes in the undo buffer.
   Cut - copies the selected text to the Clipboard in CF_TEXT format and then deletes the selection.
   Copy - copies the selected text in the edit control to the Clipboard in CF_TEXT format.
   Paste - pastes the contents of the Clipboard into edit control, replacing the current selection.
   Delete - removes the selected text from the edit control.
   Select All - selects all text in the edit control.
   */

   #define WM_PASTE      770
   #define WM_CUT        768
   #define WM_COPY       769
   #define WM_CLEAR      771

   #define EM_GETSEL     176
   #define EM_SETSEL     177
   #define EM_CANUNDO    198
   #define EM_UNDO       199

   #define WM_GETTEXTLENGTH        0x000E

FUNCTION EnableEditMenuItems()

   LOCAL hEdit, nStart, nEnd, TxtLen

   IF !Empty( _HMG_xControlsContextMenuID )

      hEdit := GetControlHandleByIndex( _HMG_xControlsContextMenuID )

      // Current selection range:
      nStart := LoWord( SendMessage( hEdit, EM_GETSEL, 0, 0 ) )
      nEnd := HiWord( SendMessage( hEdit, EM_GETSEL, 0, 0 ) )

      // Undo:
      Form_1.mnuEditUndo.Enabled := (SendMessage( hEdit, EM_CANUNDO, 0, 0 ) > 0)

      // Cut, Copy & Delete: enable if a selection, disable if no selection
      Form_1.mnuEditCut.Enabled := (nStart < nEnd)
      Form_1.mnuEditCopy.Enabled := (nStart < nEnd)
      Form_1.mnuEditDelete.Enabled := (nStart < nEnd)

      // Paste: enable of clipboard text, disable if not
      Form_1.mnuEditPaste.Enabled := (Len(System.Clipboard) > 0)

      // Select All: disable if everything's already selected, enable otherwise.
      TxtLen := SendMessage( hEdit, WM_GETTEXTLENGTH, 0, 0 )
      Form_1.mnuEditSelAll.Enabled := .Not. (nStart == 0 .And. nEnd == TxtLen)

   ENDIF

   RETURN NIL

FUNCTION mnuEditUndo_Click()     // Ctrl+Z

   LOCAL hEdit

   hEdit := GetControlHandleByIndex( _HMG_xControlsContextMenuID )
   SendMessage( hEdit , EM_UNDO , 0 , 0 )

   RETURN NIL

FUNCTION mnuEditCut_Click()     // Ctrl+X

   LOCAL hEdit

   hEdit := GetControlHandleByIndex( _HMG_xControlsContextMenuID )
   SendMessage( hEdit , WM_CUT , 0 , 0 )

   RETURN NIL

FUNCTION mnuEditCopy_Click()    // Ctrl+C

   LOCAL hEdit

   hEdit := GetControlHandleByIndex( _HMG_xControlsContextMenuID )
   SendMessage( hEdit , WM_COPY , 0 , 0 )

   RETURN NIL

FUNCTION mnuEditPaste_Click()   // Ctrl+V

   LOCAL hEdit

   hEdit := GetControlHandleByIndex( _HMG_xControlsContextMenuID )
   SendMessage( hEdit , WM_PASTE , 0 , 0 )

   RETURN NIL

FUNCTION mnuEditDelete_Click()  // Del

   LOCAL hEdit

   hEdit := GetControlHandleByIndex( _HMG_xControlsContextMenuID )
   SendMessage( hEdit , WM_CLEAR , 0 , 0 )

   RETURN NIL

FUNCTION mnuEditSelAll_Click()  // Ctrl+A

   LOCAL hEdit

   hEdit := GetControlHandleByIndex( _HMG_xControlsContextMenuID )
   SendMessage( hEdit , EM_SETSEL , 0 , -1 )

   RETURN NIL

