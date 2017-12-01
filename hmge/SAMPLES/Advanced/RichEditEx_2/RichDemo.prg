/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2002-2005 Roberto Lopez <harbourminigui@gmail.com>
* http://harbourminigui.googlepages.com/
* Copyright 2003-2009 Janusz Pora <JanuszPora@onet.eu>
*/

#include "minigui.ch"
#include "winprint.ch"

MEMVAR cFileIni, aListFont, aSizeFont, aRatioZoom
MEMVAR aNumZoom, nEditWidth, nPageWidth, nPageHeight, nPageSize, nPageOrient
MEMVAR lmPage, rmPage, tmPage, bmPage, nRatio, nDevCaps, nRtfRatio
MEMVAR cFile, cTitle, REver, nWidth, nHeight, ActivePage, CountPage
MEMVAR lFind, aFileEdit, aUndo, cUndo_Id, lUndo
MEMVAR InstallPath, cHelp, MainForm
MEMVAR rEdit, wEdit, hEdit, hLin, lLin, wDev, nTypTab, rTab, wTab, hTab
MEMVAR hEd, InsertActive, CapsLockActive, NumLockActive, PosNum, PosIns
MEMVAR PosCaps, emumUndo, ActiveEdit, ActiveSlider, ActiveChkBtn

DECLARE WINDOW Form_Splash

FUNCTION Main

   PUBLIC cFileIni     := "RichEdit.ini"

   PUBLIC aListFont := { 'Arial','Courier','Ms Sans Serif','Ms Serif',;
      'Symbol','Times New Roman','WingDings','System',;
      'Impact','Comic Sans MS','Verdana'}

   PUBLIC aSizeFont    := {'8','9','10','11','12','14','16','18','20','22','24','26','28','36','48','72'}
   PUBLIC aRatioZoom   := {'500%','200%','150%','100%','75%','50%','25%','10%'}
   PUBLIC aNumZoom     := {{5,1},{2,1},{3,2},{0,0},{2,3},{1,2},{1,4},{1,10}}
   PUBLIC nEditWidth   := 165                     // in mm   // 720 points
   PUBLIC nPageWidth   := 210
   PUBLIC nPageHeight  := 297
   PUBLIC nPageSize    := DMPAPER_A4
   PUBLIC nPageOrient  := DMORIENT_PORTRAIT
   PUBLIC lmPage       := 10                       //left margin
   PUBLIC rmPage       := 20                       //right margin
   PUBLIC tmPage       := 10                       //top margin
   PUBLIC bmPage       := 20                       //bottom margin

   PUBLIC nRatio       := 1                        // Ratio: zoom
   PUBLIC nDevCaps     := 1                        // Ratio: pixel / cm
   PUBLIC nRtfRatio    := 1.335                    // Ratio: Window RTF / Window
   PUBLIC cFile        :=''
   PUBLIC cTitle       := 'Harbour MiniGUI RichEdit Demo'
   PUBLIC REver        := '1.7 Beta'
   PUBLIC nWidth       := 750
   PUBLIC nHeight      := 430
   PUBLIC ActivePage   := 0
   PUBLIC CountPage    := 0
   PUBLIC lFind        := .f.
   PUBLIC aFileEdit    := {}
   PUBLIC aUndo        := {}
   PUBLIC cUndo_Id     := 'It_DrDwn'
   PUBLIC lUndo        := .f.
   PUBLIC InstallPath  := "c:\"
   PUBLIC cHelp        := "RichEdit.chm"

   PUBLIC rEdit := 8
   PUBLIC wEdit := 737
   PUBLIC hEdit := 350

   PUBLIC hLin  := 22
   PUBLIC lLin  := .t.
   PUBLIC wDev  := 15
   PUBLIC nTypTab := 0
   PUBLIC rTab := 8
   PUBLIC wTab := 737
   PUBLIC hTab := 350

   PUBLIC hEd  := 0

   PUBLIC InsertActive   := .f.
   PUBLIC CapsLockActive := .f.
   PUBLIC NumLockActive  := .f.
   PUBLIC PosNum   := 6
   PUBLIC PosIns   := 5
   PUBLIC PosCaps  := 4

   PUBLIC emumUndo :={'Action is unknown',;
      'Typing operation',;
      'Delete operation',;
      'Drag and drop operation',;
      'Cut operation',;
      'Paste operation'}

   PUBLIC ActiveEdit  :='Edit_1'
   PUBLIC ActiveSlider:='Slider_1'
   PUBLIC ActiveChkBtn:='ChkBtn_1'
   PUBLIC MainForm    := 'Form_1'

   SET HELPFILE TO 'richedit.chm'

   DECLARE WINDOW Form_1

   nWidth  := Min(getdesktopwidth() * 0.8 , nWidth)
   nHeight := getdesktopheight() * 0.8
   cFile   := 'Test.rtf'

   InstallPath := DISKNAME()+':\'+Curdir()

   IF File(InstallPath+'\'+cHelp)
      SET HELPFILE TO InstallPath+'\'+cHelp
   ENDIF

   DEFINE WINDOW &MainForm ;
         AT 0,0 ;
         WIDTH nWidth+0 HEIGHT nHeight ;
         TITLE cTitle ;
         ICON 'AREDIT' ;
         MAIN ;
         ON INIT InitRichEdit() ;
         ON RELEASE WinEnd_Click(0) ;
         ON SIZE ReSizeRTF() ;
         ON MAXIMIZE ReSizeRTF() ;
         ON MINIMIZE ReSizeRTF() ;
         //        BACKCOLOR GRAY

      DEFINE STATUSBAR FONT 'Arial' SIZE 8
         STATUSITEM '[x] Harbour Power Ready - Rich Edit Demo !'
         STATUSITEM 'Line:   ' WIDTH 100 FLAT
         STATUSITEM 'Pos.:   ' WIDTH 100 FLAT
         KEYBOARD
         DATE
         CLOCK
      END STATUSBAR

      ON KEY F1 ACTION DISPLAY HELP MAIN
      ON KEY CONTROL+N ACTION New_File()
      ON KEY CONTROL+O ACTION Open_File()
      ON KEY CONTROL+S ACTION Save_File(0)

      DEFINE MAIN MENU
         POPUP '&File'
            ITEM '&New'+chr(9)+'Ctrl+N'      ACTION New_File() IMAGE "NEW"
            ITEM '&Open'+chr(9)+'Ctrl+O'     ACTION Open_File() IMAGE "Open"
            ITEM '&Close'                    ACTION Close_File(0) IMAGE "Close"
            ITEM '&Save'+chr(9)+'Ctrl+S'     ACTION Save_File(0) IMAGE "Save"
            ITEM 'Save &as ...'              ACTION Save_File(1)
            SEPARATOR
            ITEM 'Page Se&tup'               ACTION  PageSetupRTF_Click()
            ITEM '&Print'                    ACTION  PrintRTF_Click()  IMAGE 'Printer'
            SEPARATOR
            POPUP 'Recent Files'
               MRUITEM INI 'RichEdit.ini' SECTION "MRU" SIZE 5 ACTION  Open_File( cPrompt )
            END POPUP
            SEPARATOR
            ITEM 'E&xit'                     ACTION WinEnd_Click(1)
         END POPUP
         POPUP '&Edit'
            ITEM '&Undo'      ACTION Undo_Click() IMAGE 'undo'
            ITEM '&Redo'      ACTION Redo_Click() IMAGE 'undo'
            SEPARATOR
            ITEM '&Copy'      ACTION Copy_click()  IMAGE 'copy' NAME It_Copy
            ITEM 'C&ut'       ACTION Cut_Click()   IMAGE 'cut' NAME It_Cut
            ITEM '&Paste'     ACTION Paste_Click() IMAGE 'paste' NAME It_Paste
            ITEM '&Delete'    ACTION Clear_Click() IMAGE 'clear' NAME It_Clear
            SEPARATOR
            ITEM '&Select all'   ACTION SelectAll_Click()
            SEPARATOR
            ITEM '&Find'      ACTION Search_click(0)  NAME It_Find IMAGE 'find2'
            ITEM '&Replace'   ACTION Search_click(1)  NAME It_Repl IMAGE 'repeat'
         END POPUP
         POPUP '&Insert'
            ITEM '&Font'      ACTION SelFont(1) IMAGE "FONT"
            ITEM '&Paragraf'  ACTION Paragraph_click() IMAGE "PARAGRAF"
            SEPARATOR
            ITEM '&Image'     ACTION MsgInfo ("  Image insert Click  ","Not implemented yet!")
            ITEM '&Link'      ACTION MsgInfo ("  Link insert Click  ","Not implemented yet!")
         END POPUP
         POPUP '&Help'
            ITEM '&Help'+Chr(9)+'F1'   ACTION DISPLAY HELP MAIN IMAGE "HELP"
            ITEM 'About'               ACTION DefSplash(1)
         END POPUP
      END MENU

      DEFINE CONTEXT MENU
         ITEM '&Copy'      ACTION Copy_click() IMAGE 'copy' NAME ItC_Copy
         ITEM 'C&ut'       ACTION Cut_Click()   NAME ItC_Cut
         ITEM '&Paste'     ACTION Paste_Click() NAME ItC_Paste
         SEPARATOR
         ITEM '&Select all'   ACTION SelectAll_Click()
         SEPARATOR
         ITEM '&Find'      ACTION Search_click(0) NAME ItC_Find
         ITEM '&Replace'   ACTION Search_click(1) NAME ItC_Repl
      END MENU

      DEFINE SPLITBOX

         DEFINE TOOLBAREX ToolBar_1 BUTTONSIZE 23,23 FLAT //RIGHTTEXT

         BUTTON Btn_New ;
            TOOLTIP 'New File' ;
            PICTURE 'NEW' ;
            ACTION New_File()

         BUTTON Btn_Open ;
            TOOLTIP 'Open File' ;
            PICTURE 'OPEN' ;
            ACTION Open_File()

         BUTTON Btn_Close ;
            TOOLTIP 'Close' ;
            PICTURE 'CLOSE' ;
            ACTION Close_File()

         BUTTON Btn_Save ;
            TOOLTIP 'Save' ;
            PICTURE 'SAVE' ;
            ACTION Save_File(0)

         BUTTON Btn_SaveAll ;
            TOOLTIP 'Save all Files' ;
            PICTURE 'SAVEALL' ;
            ACTION Save_AllFile();
            SEPARATOR

         BUTTON Btn_Print ;
            TOOLTIP 'Print' ;
            PICTURE 'Printer' ;
            ACTION   PrintRTF_Click(1)

         BUTTON Btn_Prev ;
            TOOLTIP 'Preview' ;
            PICTURE 'Preview' ;
            ACTION   PrintRTF_Click(0)
      END TOOLBAR

      COMBOBOX Combo_3 ;
         ITEMS aRatioZoom;
         VALUE 4 ;
         HEIGHT 200;
         FONT 'Tahoma' SIZE 9 ;
         WIDTH 80;
         TOOLTIP 'Zoom Ratio';
         ON CHANGE SetZoom_Click();

      DEFINE TOOLBAREX ToolBar_2 BUTTONSIZE 23,23 FONT 'ARIAL' SIZE 8  FLAT //RIGHTTEXT MIXEDBUTTONS

      BUTTON Btn_Copy ;
         TOOLTIP 'Copy' ;
         PICTURE 'copy' ;
         ACTION Copy_click()

      BUTTON Btn_Paste ;
         TOOLTIP 'Paste' ;
         PICTURE 'Paste' ;
         ACTION Paste_Click()

      BUTTON Btn_Cut ;
         TOOLTIP 'Cut' ;
         PICTURE 'cut' ;
         ACTION Cut_Click();

      BUTTON Btn_Clear ;
         TOOLTIP 'Clear' ;
         PICTURE 'Clear' ;
         ACTION Clear_Click();
         SEPARATOR

      BUTTON Btn_Undo ;
         TOOLTIP 'Undo' ;
         PICTURE 'undo' ;
         ACTION Undo_Click();
         DROPDOWN

      DEFINE DROPDOWN MENU BUTTON Btn_Undo
         ITEM emumUndo[1]   ACTION {|| Nil } NAME It_DrDwn
         SEPARATOR
         ITEM '&Clear Undo'      ACTION ClearUndo_Click() NAME ItU_Clear
      END MENU

      BUTTON Btn_Redo ;
         TOOLTIP 'Redo' ;
         PICTURE 'redo' ;
         ACTION Redo_Click();
         SEPARATOR

      BUTTON Btn_Find ;
         TOOLTIP 'Find' ;
         PICTURE 'find2' ;
         ACTION Search_click(0)

      BUTTON Btn_Repl ;
         TOOLTIP 'Replace' ;
         PICTURE 'repeat' ;
         ACTION  Search_click(1)

   END TOOLBAR

   COMBOBOX Combo_1 ;
      ITEMS aListFont;
      VALUE 2 ;
      WIDTH 170;
      HEIGHT 200;
      FONT 'Tahoma' SIZE 9 ;
      TOOLTIP 'Font Name';
      ON CHANGE SetName_Click();
      SORT;
      BREAK

   COMBOBOX Combo_2 ;
      ITEMS aSizeFont ;
      VALUE 3 ;
      WIDTH 40;
      TOOLTIP 'Font Size' ;
      ON CHANGE SetSize_Click()

   DEFINE TOOLBAREX ToolBar_3 BUTTONSIZE 23,23 SIZE 8  FLAT //RIGHTTEXT //MIXEDBUTTONS

   BUTTON Btn_Bold ;
      TOOLTIP 'Bold' ;
      PICTURE 'bold' ;
      ACTION SetBold_click();
      CHECK

   BUTTON Btn_Italic ;
      TOOLTIP 'Italic' ;
      PICTURE 'Italic' ;
      ACTION SetItalic_Click();
      CHECK

   BUTTON Btn_Under ;
      TOOLTIP 'Underline' ;
      PICTURE 'under' ;
      ACTION SetUnderLine_Click();
      CHECK

   BUTTON Btn_Strike ;
      TOOLTIP 'StrikeOut' ;
      PICTURE 'strike' ;
      ACTION SetStrikeOut_Click();
      CHECK  SEPARATOR

   BUTTON Btn_Left ;
      TOOLTIP 'Left Tekst' ;
      PICTURE 'left' ;
      ACTION  SetLeft_Click();
      CHECK GROUP

   BUTTON Btn_Center ;
      TOOLTIP 'Center Tekst' ;
      PICTURE 'center' ;
      ACTION  SetCenter_Click();
      CHECK GROUP

   BUTTON Btn_Right ;
      TOOLTIP 'Right Text' ;
      PICTURE 'Right' ;
      ACTION SetRight_Click() ;
      CHECK GROUP

   BUTTON Btn_Justify ;
      TOOLTIP 'Justify Text' ;
      PICTURE 'Justify' ;
      ACTION SetJustify_Click() ;
      CHECK GROUP       SEPARATOR

   BUTTON Btn_Color ;
      TOOLTIP 'Font Color' ;
      PICTURE 'Color' ;
      ACTION SetColor_Click() ;
      SEPARATOR

   BUTTON Btn_Numb ;
      TOOLTIP 'Numbering' ;
      PICTURE 'Number' ;
      ACTION SetNumb_Click() ;
      CHECK

   BUTTON Btn_Offset1 ;
      TOOLTIP 'Offset in' ;
      PICTURE 'Offset1' ;
      ACTION SetOffset_Click(1)

   BUTTON Btn_Offset2 ;
      TOOLTIP 'Offset Out' ;
      PICTURE 'Offset2' ;
      ACTION SetOffset_Click(0)

END TOOLBAR

END SPLITBOX

DEFINE TAB Tab_1 ;
      AT 35,0 ;
      WIDTH nWidth HEIGHT nHeight-40 ;
      VALUE 1 ;
      TOOLTIP 'Tab Control';
      HOTTRACK;
      ON CHANGE TabChange()

   PAGE '&No File'

   END PAGE

END TAB

END WINDOW

DefSplash(0)

Form_1.Center
Form_Splash.Center

ACTIVATE WINDOW Form_Splash , Form_1

RETURN NIL

FUNCTION WinEnd_Click(mod)

   LOCAL cFile, n, nRet := 0

   FOR n := 1 to len(aFileEdit)
      ActivePage := n
      ActiveEdit := aFileEdit[ActivePage,2]
      IF _IsControlDefined (ActiveEdit,MainForm)
         hEd        := GetControlHandle (ActiveEdit,MainForm)
         cFile:=aFileEdit[ActivePage,3]
         IF ModifyRTF(hEd,0)
            Form_1.Tab_1.Value := ActivePage
            IF (nRet := MsgYesNoCancel ('Save changes?',cFile))== 1
               Save_File(0)
            ENDIF
            IF nRet == -1
               EXIT
            ENDIF
         ENDIF
         RELEASE CONTROL &ActiveEdit OF Form_1
      ENDIF
   NEXT
   IF nRet != -1
      SaveMRUFileList()
      IF mod ==1
         RELEASE WINDOW MAIN
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION SelectText()

   SelFont(2)
   Btn_Stat(1)
   SelParForm()

   RETURN NIL

FUNCTION UpdateText()

   SetMenuUndo()

   RETURN NIL

FUNCTION TabChange()

   LOCAL nEdit

   ActivePage := Form_1.Tab_1.Value
   ActiveEdit:= aFileEdit[ActivePage,2]
   nEdit := aFileEdit[ActivePage,1]
   ActiveSlider:= 'Slider_'+alltrim(str(nEdit))
   ActiveChkBtn:= 'ChkBtn_'+alltrim(str(nEdit))

   hEd   := GetControlHandle (ActiveEdit,MainForm)
   ReSizeRTF()
   Btn_Stat(1)
   GetZoom_Click()
   SetZoom_Click()
   RESetFocus()

   RETURN NIL

FUNCTION RESetFocus()

   IF len(aFileEdit)> 0
      _SetFocus ( ActiveSlider,MainForm )
      _SetFocus ( ActiveChkBtn,MainForm )
      _SetFocus ( ActiveEdit,MainForm )
   ENDIF

   RETURN NIL

   //PAGE SIZE

FUNCTION GetCtrlSize()

   LOCAL i, w, h, hrb:=27, hst:=37 ,hTit
   LOCAL hwnd,actpos:={0,0,0,0}

   hLin := if(lLin,26,0)

   hTit := getmenubarheight()
   hwnd := GetFormHandle(MainForm)
   GetWindowRect(hwnd,actpos)

   w := actpos[3]-actpos[1]
   h := actpos[4]-actpos[2]

   i := aScan ( _HMG_aFormHandles , hWnd )
   IF i > 0
      IF _HMG_aFormReBarHandle [i] > 0
         hrb = RebarHeight ( _HMG_aFormReBarHandle [i] )
      ENDIF
   ENDIF
   h := h - (hrb + hst)
   rEdit := hTit+ hLin +2
   wEdit := w - 13-wDev
   hEdit := h -  IF(IsXPThemeActive(), 78, 70) - hLin

   rTab := hrb + 6
   wTab := w - 5
   hTab := h - IF(IsXPThemeActive(), 48, 40)

   RETURN NIL

FUNCTION ReSizeRTF()

   GetCtrlSize()
   IF _IsControlDefined ('Tab_1',MainForm)
      Form_1.Tab_1.row := rTab
      Form_1.Tab_1.width := wTab
      Form_1.Tab_1.height := hTab
   ENDIF
   IF len(aFileEdit) > 0
      _SetControlRow( ActiveEdit, "Form_1", rEdit)
      _SetControlWidth( ActiveEdit, "Form_1",min(nEditWidth * nDevCaps * nRatio ,wEdit))
      _SetControlHeight( ActiveEdit, "Form_1", hEdit )
      Set_PageWidth(nEditWidth * nDevCaps * nRatio)
      IF lLin
         _SetControlRow( ActiveSlider, "Form_1", rEdit-hLin+2)
         _SetControlCol( ActiveSlider, "Form_1", wDev+lmPage * nRatio-3)
         _SetControlWidth( ActiveSlider, "Form_1",(nEditWidth * nDevCaps -(lmPage+rmPage)+6)* nRatio)
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION Set_PageWidth(nWidth)

   LOCAL aRc

   aRC := GetRect(hEd)
   SetRect( hEd, lmPage+1, aRc[2]+1, nWidth-(lmPage+rmPage)+1, aRc[4] )

   RETURN NIL

STATIC FUNCTION InitRichEdit()

   LOCAL hCombo, nItemCombo, n

   GetCtrlSize()
   aListFont:={}
   nDevCaps := GetDevCaps(0)/25.4
   hCombo := GetControlHandle ('Combo_1',MainForm)
   Form_1.Tab_1.row := rTab
   RE_GETFONTS(hCombo)
   nItemCombo:= COMBOBOXGETITEMCOUNT(hCombo)
   FOR n:=1 TO nItemCombo
      AAdd(aListFont,RTrim(COMBOGETSTRING(hCombo,n)))
   NEXT
   Btn_Stat(0)

   RETURN NIL

FUNCTION  NewEdit(cFile,typ)

   LOCAL n, cxFile, nEdit := 1, nPos

   cxFile := ALLTRIM(substr(cFile,Rat('\',cFile)+1))
   IF len(aFileEdit) == 0
      CountPage := 0
   ENDIF
   CountPage ++
   ActivePage  := CountPage
   nRatio      := 1
   aadd(aFileEdit, {0,'',cxFile,typ,cFile})
   FOR n:=1 to Len(aFileEdit)
      nPos := ascan(aFileEdit,{|x| x[1]==n})
      IF nPos == 0
         nEdit := n
         EXIT
      ENDIF
   NEXT
   ActiveEdit     := 'Edit_'  +alltrim(str(nEdit))
   ActiveSlider   := 'Slider_'+alltrim(str(nEdit))
   ActiveChkBtn   := 'ChkBtn_'+alltrim(str(nEdit))
   aFileEdit[CountPage,1] := nEdit
   aFileEdit[CountPage,2] := ActiveEdit

   IF CountPage > 1
      _AddTabPage ( 'Tab_1', MainForm , ActivePage , cxFile )
   ELSE
      Form_1.Tab_1.Caption(ActivePage):=cxFile
   ENDIF
   GetCtrlSize()

   @ rEdit+rTab,3+wDev RICHEDITBOX &ActiveEdit ;
      OF Form_1;
      WIDTH wEdit;
      HEIGHT hEdit ;
      VALUE '' ;
      MAXLENGTH 510000;
      ON CHANGE UpdateText();
      ON SELECT SelectText();
      NOHSCROLL

   _AddTabControl ( 'Tab_1' , ActiveEdit , MainForm , ActivePage , 48 , 2+wDev )

   IF lLin
      @ rTab+rEdit-hLin+2 ,0+wDev SLIDER &ActiveSlider;
         OF Form_1;
         RANGE 0 , (nEditWidth * nDevCaps -(lmPage+rmPage))/nRtfRatio;
         VALUE 1;
         WIDTH nEditWidth * nDevCaps -(lmPage+rmPage)+6 ;
         HEIGHT hLin-2 ;
         ON CHANGE GetLin(1);
         NOTABSTOP

      _AddTabControl ( 'Tab_1' , ActiveSlider , MainForm , ActivePage , 22 , lmPage-3+wDev )
      ModifySlider(MainForm, ActiveSlider , nEditWidth * nDevCaps -(lmPage+rmPage))

      @ rTab+rEdit-hLin+2 ,0  BUTTON &ActiveChkBtn;
         OF Form_1;
         PICTURE 'TAB0';
         ACTION  SetTypTab();
         WIDTH 14  HEIGHT 16;
         NOTABSTOP

      _AddTabControl ( 'Tab_1' , ActiveChkBtn , MainForm , ActivePage , 26 , 3 )
   ENDIF

   Form_1.Title := cTitle+' ('+cxFile+')'
   hEd   := GetControlHandle (ActiveEdit,MainForm)
   IF len(aFileEdit) == 1
      SetSelRange( hEd )
      AutoUrlDetect(hEd , .t.)
      SelFont(2)
   ENDIF
   Set_PageWidth(nEditWidth * nDevCaps)
   GetZoom_Click()

   RETURN NIL

STATIC FUNCTION SetTypTab()

   nTypTab++
   IF nTypTab > 3
      nTypTab := 0
   ENDIF
   SWITCH nTypTab
   CASE 0
      _SetPicture ( ActiveChkBtn, MainForm, 'TAB0' )
   CASE 1
      _SetPicture ( ActiveChkBtn, MainForm, 'TAB1' )
   CASE 2
      _SetPicture ( ActiveChkBtn, MainForm, 'TAB2' )
   CASE 3
      _SetPicture ( ActiveChkBtn, MainForm, 'TAB3' )
   END SWITCH
   RESetFocus()

   RETURN NIL

FUNCTION Save_AllFile()

   LOCAL ActPage, n, nRet

   ActPage := ActivePage
   FOR n := 1 to len(aFileEdit)
      ActivePage := n
      ActiveEdit := aFileEdit[ActivePage,2]
      hEd        := GetControlHandle (ActiveEdit,MainForm)
      cFile:=aFileEdit[ActivePage,3]
      IF ModifyRTF(hEd,0)
         Form_1.Tab_1.Value := ActivePage
         IF (nRet := MsgYesNoCancel ('Save changes?',cFile))== 1
            Save_File(0)
         ENDIF
         IF nRet == -1
            EXIT
         ENDIF
      ENDIF
   NEXT
   ActivePage := ActPage
   ActiveEdit := aFileEdit[ActivePage,2]
   hEd        := GetControlHandle (ActiveEdit,MainForm)

   RETURN NIL

FUNCTION Save_File(met)

   LOCAL c_File, cxFile, typ := 1

   c_File:= aFileEdit[ActivePage,3]

   IF aFileEdit[ActivePage,4] == 0
      met := 1
   ENDIF
   IF met == 1
      c_File := PutFile ( {{'Rich text File','*.rtf'},{'Text File','*.txt'}} , 'Get File' )
   ENDIF
   IF !empty(c_File)
      cxFile :=ALLTRIM(substr(c_File,Rat('\',c_File)+1))
      Form_1.Tab_1.Caption(ActivePage):=cxFile

      IF UPPER(ALLTRIM(substr(c_File,Rat('.',c_File)+1))) == 'RTF'
         typ := 2
      ENDIF
      IF UPPER(ALLTRIM(substr(c_File,Rat('.',c_File)+1))) == 'PRG'
         typ := 1
      ENDIF

      StreamOut( hEd, c_File, typ)
      ModifyRTF(hEd, 1)
      ReSizeRTF()
   ENDIF
   RESetFocus()

   RETURN NIL

FUNCTION New_File()

   LOCAL cBuffer:=''

   NewEdit('NoName',0)
   Form_1.Tab_1.Value:=ActivePage
   _Setvalue ( ActiveEdit, MainForm, cBuffer )
   SetTextMode(hEd, 2)
   ModifyRTF(hEd,1)
   Btn_Stat(1)

   RETURN NIL

FUNCTION Open_file(cFile)

   LOCAL typ := 1, c_File

   IF empty(cFile)
      c_File := GetFile({{'Rich text File','*.rtf'},{'Text File','*.txt'},{'All File','*.*'}},'Get File')
   ELSE
      c_File:=cFile
   ENDIF
   IF empty(c_File)

      RETURN NIL
   ENDIF

   NewEdit(c_File,1)

   AddMruItem(c_file, "Open_File(c_file)")

   Form_1.Tab_1.Value:=ActivePage
   IF UPPER(ALLTRIM(substr(c_File,Rat('.',c_File)+1))) == 'RTF'
      typ := 2
   ENDIF
   StreamIn( hEd, c_File, typ)

   GetLin(0)
   ModifyRTF(hEd,1)
   Btn_Stat(1)
   ReSizeRTF()
   RESetFocus()

   RETURN NIL

FUNCTION Close_File()

   LOCAL cFile, nEdit, nRet

   cFile:=aFileEdit[ActivePage,3]
   IF ModifyRTF( hEd,0 )
      IF (nRet := MsgYesNoCancel ('Save changes?',cFile))== 1
         Save_File(0)
      ELSEIF nRet == -1

         RETURN NIL
      ENDIF
   ENDIF

   AddMruItem(aFileEdit[ActivePage,5], "Open_File( aFileEdit[ActivePage,5])")

   _ReleaseControl(ActiveEdit, MainForm)

   IF lLin
      _ReleaseControl(ActiveChkBtn, MainForm)
      _ReleaseControl(ActiveSlider, MainForm)
   ENDIF

   IF CountPage > 1
      _DeleteTabPage ( 'Tab_1', MainForm , ActivePage )
      CountPage --
      aDel(aFileEdit,ActivePage)
      aSize(aFileEdit,CountPage)
      ActivePage --
      IF ActivePage == 0
         ActivePage := 1
      ENDIF
      ActiveEdit := aFileEdit[ActivePage,2]
      nEdit := aFileEdit[ActivePage,1]
      ActiveSlider:= 'Slider_'+alltrim(str(nEdit))
      ActiveChkBtn:= 'ChkBtn_'+alltrim(str(nEdit))
      hEd   := GetControlHandle (ActiveEdit,MainForm)
   ELSE
      aFileEdit := {}
      Form_1.Tab_1.Caption(ActivePage):='No File'
      Form_1.Title := cTitle
      ActivePage:= 1
      CountPage := 1
      ActiveEdit :=''
      ActiveSlider:= ''
      ActiveChkBtn:= ''
      hEd := 0
   ENDIF
   Btn_Stat(1)

   RETURN NIL

FUNCTION SelCharRTF ()

   LOCAL Sel , aF, nPos, ret

   Sel   := RangeSelRTF(hEd)
   aF    := GetFontRTF(hEd, 1 ) //Sel )
   nPos  := Form_1.Combo_1.Value
   IF nPos > 0
      aF[1] := aListFont[nPos]
   ENDIF
   nPos := Form_1.Combo_2.Value
   IF nPos > 0
      aF[2] := val(aSizeFont[nPos])
   ENDIF
   aF[3] := Form_1.Btn_Bold.Value
   aF[4] := Form_1.Btn_Italic.Value
   aF[6] := Form_1.Btn_Under.Value
   aF[7] := Form_1.Btn_Strike.Value

   ret := SetFontRTF(hEd, Sel, aF[1], aF[2], aF[3], aF[4], aF[5], aF[6], aF[7])

   RETURN ret

FUNCTION SetName_Click()

   LOCAL nPos, cName

   nPos := Form_1.Combo_1.Value
   IF nPos > 0 .and. hEd != 0
      cName := aListFont[nPos]
      IF !_SetFontNameRTF (MainForm , ActiveEdit , cName)
         MsgInfo('No changed Font!')
      ENDIF
   ENDIF
   RESetFocus()

   RETURN NIL

FUNCTION SetSize_Click()

   LOCAL nPos, nSize

   nPos := Form_1.Combo_2.Value
   IF nPos > 0 .and. hEd != 0
      nSize := val(aSizeFont[nPos])
      IF !_SetFontSizeRTF ( MainForm , ActiveEdit , nSize)
         MsgInfo('No changed Size!')
      ENDIF
   ENDIF
   RESetFocus()

   RETURN NIL

FUNCTION SetBold_Click()

   LOCAL lBold

   lBold := Form_1.Btn_Bold.Value
   IF hEd != 0
      _SetFontBoldRTF ( MainForm , ActiveEdit , lBold)
   ENDIF

   RETURN NIL

FUNCTION SetItalic_Click()

   LOCAL lItalic

   lItalic := Form_1.Btn_Italic.Value
   IF hEd != 0
      _SetFontItalicRTF ( MainForm , ActiveEdit , lItalic)
   ENDIF

   RETURN NIL

FUNCTION SetUnderLine_Click()

   LOCAL lUnderLine

   lUnderLine := Form_1.Btn_Under.Value
   IF hEd != 0
      _SetFontUnderLineRTF ( MainForm , ActiveEdit , lUnderLine)
   ENDIF

   RETURN NIL

FUNCTION SetStrikeOut_Click()

   LOCAL lStrike

   lStrike := Form_1.Btn_Strike.Value
   IF hEd != 0
      _SetFontStrikeOutRTF ( MainForm , ActiveEdit , lStrike)
   ENDIF

   RETURN NIL

FUNCTION SetLeft_Click()

   LOCAL lLeft

   lLeft := Form_1.Btn_Left.Value
   IF hEd != 0
      _SetFormatLeftRTF ( MainForm , ActiveEdit , lLeft)
   ENDIF

   RETURN NIL

FUNCTION SetCenter_Click()

   LOCAL lCenter

   lCenter := Form_1.Btn_Center.Value
   IF hEd != 0
      _SetFormatCenterRTF ( MainForm , ActiveEdit , lCenter)
   ENDIF

   RETURN NIL

FUNCTION SetRight_Click()

   LOCAL lRight

   lRight := Form_1.Btn_Right.Value
   IF hEd != 0
      _SetFormatRightRTF ( MainForm , ActiveEdit , lRight)
   ENDIF

   RETURN NIL

FUNCTION SetJustify_Click()

   LOCAL lJustify

   lJustify := Form_1.Btn_Justify.Value
   IF hEd != 0
      _SetFormatJustifyRTF ( MainForm , ActiveEdit , lJustify)
   ENDIF

   RETURN NIL

FUNCTION Copy_Click()

   CopyRTF(hEd)

   RETURN NIL

FUNCTION Paste_Click()

   PasteRTF(hEd)

   RETURN NIL

FUNCTION Cut_Click()

   CutRTF(hEd)

   RETURN NIL

FUNCTION Clear_Click()

   ClearRTF(hEd)

   RETURN NIL

FUNCTION Btn_Stat(met)

   LOCAL H,lSel

   IF len(aFileEdit) == 0 .or. met == 0
      H:=0
      lSel :=.f.
   ELSE
      H    := hEd
      lSel := if(RangeSelRTF( hEd ) > 0, .t., .f.)
   ENDIF
   Form_1.Btn_Undo.Enabled  := CanUndo(H)
   Form_1.Btn_Redo.Enabled  := CanRedo(H)
   Form_1.Btn_Copy.Enabled  := lSel
   Form_1.ItC_Copy.Enabled  := lSel
   Form_1.It_Copy.Enabled   := lSel
   Form_1.Btn_Cut.Enabled   := lSel
   Form_1.ItC_Cut.Enabled   := lSel
   Form_1.It_Cut.Enabled    := lSel
   Form_1.Btn_Clear.Enabled := lSel
   Form_1.It_Clear.Enabled  := lSel

   Form_1.Btn_Paste.Enabled := CanPaste(H)
   Form_1.ItC_Paste.Enabled := CanPaste(H)
   Form_1.It_Paste.Enabled  := CanPaste(H)
   Form_1.Btn_Save.Enabled  := ModifyRTF(H)
   Form_1.Btn_SaveAll.Enabled  := ModifyRTF(H)
   Form_1.Btn_Close.Enabled := if(len(aFileEdit)>0,.t.,.f.)
   Form_1.Btn_Print.Enabled := if(len(aFileEdit)>0,.t.,.f.)
   Form_1.Btn_Prev.Enabled := if(len(aFileEdit)>0,.t.,.f.)
   Form_1.Btn_Find.Enabled := if(len(aFileEdit)>0,.t.,.f.)
   Form_1.Itc_Find.Enabled := if(len(aFileEdit)>0,.t.,.f.)
   Form_1.Btn_Repl.Enabled := if(len(aFileEdit)>0,.t.,.f.)
   Form_1.Itc_Repl.Enabled := if(len(aFileEdit)>0,.t.,.f.)
   Form_1.Btn_Save.Enabled  := ModifyRTF(H)

   Pos_line(H)

   RETURN NIL

FUNCTION SelFont(typ)

   LOCAL Sel, aFont,Tmp

   IF hEd != 0
      Sel := RangeSelRTF(hEd)
      aFont := GetFontRTF(hEd,1 )
      IF typ==1
         IF ! Empty ( aFont [1] )
            Tmp := aFont[5]
            aFont [5] := { GetRed(Tmp) , GetGreen(Tmp) , GetBlue(Tmp) }
         ELSE
            aFont [5] := { Nil , Nil , Nil }
         ENDIF

         aFont := GetFont (aFont[1], aFont[2], aFont[3], aFont[4], aFont[5], aFont[6], aFont[7])
         IF ! Empty ( aFont [1] )
            tmp   := aFont[5]
            aFont[5] := RGB ( tmp[1] , tmp[2] , tmp[3] )

            SetFontRTF(hEd, Sel, aFont[1], aFont[2], aFont[3], aFont[4], aFont[5], aFont[6], aFont[7])
         ENDIF
      ENDIF

      IF typ >= 1
         SetBtnFont(aFont)
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION SelParForm()

   LOCAL aParForm

   aParForm := GetParForm( hEd )
   Form_1.Btn_Left.Value   := aParForm[1]
   Form_1.Btn_Center.Value := aParForm[2]
   Form_1.Btn_Right.Value  := aParForm[3]
   Form_1.Btn_Justify.Value:= aParForm[9]
   Form_1.Btn_Numb.Value   := aParForm[5]
   IF lLin
      GetLin(0)
   ENDIF

   RETURN NIL

FUNCTION SetBtnFont(aFont)

   LOCAL poz

   IF (poz := ASCAN( aListFont, aFont[1])) > 0
      Form_1.Combo_1.Value := poz
   ENDIF
   IF (poz := ASCAN( aSizeFont, alltrim(str(aFont[2])))) > 0
      Form_1.Combo_2.Value := poz
   ENDIF

   Form_1.Btn_Bold.Value   := aFont[3]
   Form_1.Btn_Italic.Value := aFont[4]
   Form_1.Btn_Under.Value  := aFont[6]
   Form_1.Btn_Strike.Value := aFont[7]

   RETURN NIL

FUNCTION Search_click(repl)

   LOCAL wr:=0, ww:=0, cTitle:='Find'

   IF !IsWindowActive (Form_2)
      IF repl==1
         wr := 30
         ww := 100
         cTitle := 'Replace'
      ENDIF
      DEFINE WINDOW  Form_2 ;
            AT 255,201 ;
            WIDTH 370 + ww ;
            HEIGHT 150 +wr ;
            TITLE cTitle ;
            TOPMOST;
            NOMINIMIZE;
            NOMAXIMIZE;
            NOSIZE;
            ON INIT Init_Find(repl)

         @ 8,100 TEXTBOX text_1 ;
            HEIGHT 23 ;
            WIDTH 250 ;
            Font 'Arial' ;
            size   9;
            MAXLENGTH  230 ;
            ON CHANGE Chng_btn(repl)

         @ 10,10 LABEL lab_1 ;
            VALUE 'Find What:';
            WIDTH 80 ;
            HEIGHT 23 ;
            FONT 'Arial' ;
            SIZE  9

         IF repl == 1
            @ 38,100 TEXTBOX text_2 ;
               HEIGHT 23 ;
               WIDTH 250 ;
               Font 'Arial' ;
               size   9;
               MAXLENGTH  230 ;
               ON CHANGE Chng_btn(repl)

            @ 40,10 LABEL lab_2 ;
               VALUE 'Replace With:';
               WIDTH 80 ;
               HEIGHT 23 ;
               FONT 'Arial' ;
               SIZE  9
         ENDIF

         @ 35+wr,10 CHECKBOX checkbox_1 ;
            CAPTION 'Match Case' ;
            WIDTH 130 ;
            HEIGHT 23;
            VALUE .F. ;
            FONT 'Arial' ;
            SIZE 9

         @ 55+wr,10 CHECKBOX checkbox_2 ;
            CAPTION 'Whole word' ;
            WIDTH 130 ;
            HEIGHT 23;
            VALUE .F. ;
            FONT 'Arial' ;
            SIZE 9

         @ 75+wr,10 CHECKBOX checkbox_3 ;
            CAPTION 'Select matching text' ;
            WIDTH 130 ;
            HEIGHT 23;
            VALUE .T. ;
            FONT 'Arial' ;
            SIZE 9

         IF repl==0

            @ 35+wr, 160 FRAME Panel_1 CAPTION 'Direction' WIDTH 100 HEIGHT 65

            @ 48+wr,170 RADIOGROUP radiogrp_1 ;
               OPTIONS {'Up','Down'} ;
               VALUE 2 ;
               WIDTH  70 ;
               FONT 'Arial' ;
               SIZE 9 ;
               SPACING 22
         ENDIF

         @ 40 ,270+ww BUTTON Btn_Find;
            CAPTION 'Find Next';
            ACTION FindNext_Click(0) ;
            WIDTH 80 HEIGHT 25;
            FONT 'Arial' SIZE 9

         IF repl==1
            @ 10 ,270+ww BUTTON Btn_Repl;
               CAPTION '&Replace';
               ACTION FindNext_Click(1) ;
               WIDTH 80 HEIGHT 25;
               FONT 'Arial' SIZE 9

            @ 70 ,270+ww BUTTON Btn_ReplAll;
               CAPTION 'Replace &All';
               ACTION FindNext_Click(2) ;
               WIDTH 80 HEIGHT 25;
               FONT 'Arial' SIZE 9
         ENDIF

         @ 70+wr ,270+ww BUTTON Btn_Cancel;
            CAPTION 'Cancel';
            ACTION Release_Find_Click(repl) ;
            WIDTH 80 HEIGHT 25;
            FONT 'Arial' SIZE 9

      END WINDOW

      ACTIVATE WINDOW Form_2

   ENDIF

   RETURN 1

FUNCTION Release_Find_Click(repl)

   Form_2.Release
   IF repl == 1
      Form_1.ItC_Repl.Enabled := .t.
   ELSE
      Form_1.ItC_Find.Enabled := .t.
   ENDIF
   lFind := .f.
   RESetFocus()

   RETURN NIL

FUNCTION Init_Find(repl)

   LOCAL nSel, cSel

   IF (nSel:= RangeSelRTF(hEd)) > 0
      cSel := space(nSel+1)
      cSel := GetSelText(hEd , cSel)
      IF !empty(cSel)
         Form_2.text_1.Value := cSel
      ENDIF
   ENDIF
   Form_2.Btn_Find.Enabled := !empty(Form_2.text_1.Value)
   IF repl == 1
      Form_2.Btn_Repl.Enabled := !empty(Form_2.text_2.Value)
      Form_1.ItC_Repl.Enabled := .f.
   ELSE
      Form_1.ItC_Find.Enabled := .f.
   ENDIF
   lFind := .f.

   RETURN NIL

FUNCTION Chng_btn(repl)

   Form_2.Btn_Find.Enabled := !empty(Form_2.text_1.Value)
   IF repl == 1
      Form_2.Btn_Repl.Enabled := !empty(Form_2.text_2.Value)
   ENDIF
   lFind := .f.

   RETURN NIL

FUNCTION FindNext_click(repl)

   LOCAL Text, ret, direction := .t., wholeword, mcase, seltxt
   LOCAL ReplTxt := ''

   TEXT := Form_2.text_1.Value
   mcase     := Form_2.checkbox_1.value
   wholeword := Form_2.checkbox_2.value
   seltxt    := Form_2.checkbox_3.value
   IF _IsControlDefined ('radiogrp_1','Form_2')
      direction := (Form_2.radiogrp_1.value == 2)
   ENDIF
   IF repl != 0
      ReplTxt   := Form_2.text_2.Value
   ENDIF
   IF !lFind
      ret := FindChr( hEd, Text, direction, wholeword, mcase, seltxt )
      lFind := if(ret[3] < 0, .f.,.t.)
   ENDIF
   WHILE .t.
      IF !lFind
         MsgInfo('No match found')
         EXIT
      ELSE
         IF repl != 0
            ReplaceSel( hEd , ReplTxt, .t.)
            ret := FindChr( hEd, Text, direction, wholeword, mcase, seltxt )
            lFind := if(ret[3] < 0, .f.,.t.)
            IF repl==1
               EXIT
            ENDIF
         ELSE
            lFind := .f.
            EXIT
         ENDIF
         RESetFocus()
      ENDIF
   ENDDO

   RETURN ret

FUNCTION Pos_line(H)

   LOCAL  Poz

   IF Len(aFileEdit) > 0
      Poz := Linepos(H)
   ELSE
      Poz:={0,0}
   ENDIF
   Form_1.StatusBar.Item(2) := 'Line:'+alltrim(str(poz[1]+1))
   Form_1.StatusBar.Item(3) := 'Pos.:'+alltrim(str(poz[2]+1))

   RETURN NIL

FUNCTION SelectAll_Click()

   SetSelRange(hEd, 0, -1)

   RETURN NIL

FUNCTION PrintRTF_Click(met)

   LOCAL hbprn, cpMin, cpMax, LenMax, i, ret, wx, hx, prev

   prev := if(met==1,.f.,.t.)  //met = 0 -> preview
   hbprn:=hbprinter():new()
   hbprn:selectprinter("",prev)

   IF hbprn:error != 0
      IF met == 0

         RETURN NIL
      ELSE
         MSGSTOP ('Print Cancelled!')

         RETURN NIL
      ENDIF
   ENDIF

   // The best way to get the most similiar printout on various printers
   // is to use SET UNITS MM, remembering to use margins large enough for
   // all printers.
   hbprn:setunits(1) // mm

   hbprn:startdoc()
   cpMin  := 0
   cpMax  := -1
   LenMax := GetLenText( hEd )
   ret    := 0
   i      := 1
   wx     := (nPageWidth -lmPage - rmPage) * 56.7
   hx     := nPageHeight * 56.7

   SET PRINT MARGINS TOP tmPage LEFT lmPage  // Set printing margines

   hbprn:SetDevMode(DM_ORIENTATION,nPageOrient)
   hbprn:SetDevMode(DM_PAPERSIZE,nPageSize)

   IF hbprn:nwhattoprint < 2
      hbprn:nToPage := 0
   ENDIF

   DO WHILE ret < LenMax .and. ret != -1
      IF  i >= hbprn:nFromPage .and. ( i <= hbprn:nToPage .or. hbprn:nToPage == 0 )
         hbprn:startpage()
         ret := PrintRTF(hEd, hbprn:hDC, wx, hx, cpMin, cpMax, .t.)
         hbprn:endpage()
      ELSE
         ret := PrintRTF(hEd, hbprn:hDC, wx, hx, cpMin, cpMax, .f.)
      ENDIF
      i++
      cpMin := ret
   ENDDO

   hbprn:enddoc()
   hbprn:end()

   RETURN NIL

FUNCTION Paragraph_click()

   IF !IsWindowActive (Form_3)

      DEFINE WINDOW  Form_3 ;
            AT 255,201 ;
            WIDTH 370 ;
            HEIGHT 150 ;
            TITLE 'Paragraph formatting ' ;
            TOPMOST;
            NOMINIMIZE;
            NOMAXIMIZE;
            NOSIZE;
            ON INIT Init_Parag()

         @ 5, 10 FRAME Panel_Parag_1 CAPTION 'Aligment' WIDTH 70 HEIGHT 100

         @ 25,15 RADIOGROUP radioParag_1 ;
            OPTIONS {'Left','Center','Right'};
            VALUE 1;
            WIDTH  60 ;
            FONT 'Arial' ;
            SIZE 9 ;
            SPACING 20

         @ 5, 85 FRAME Panel_Parag_2 CAPTION 'Indentation' WIDTH 150 HEIGHT 100

         @ 25,95 LABEL lab_parag_1 ;
            VALUE 'Start Indent';
            WIDTH 80 ;
            HEIGHT 23 ;
            FONT 'Arial' ;
            SIZE  9

         @ 25 ,170 SPINNER Spin_Parag_1;
            RANGE 0 , 1200 ;
            VALUE 0 ;
            WIDTH 60;
            HEIGHT 20;
            INCREMENT 4

         @ 50,95 LABEL lab_parag_3 ;
            VALUE 'Offset';
            WIDTH 80 ;
            HEIGHT 23 ;
            FONT 'Arial' ;
            SIZE  9

         @ 50 ,170 SPINNER Spin_Parag_3;
            RANGE -1200 , 1200 ;
            VALUE 0 ;
            WIDTH 60;
            HEIGHT 20;
            ON CHANGE RangeOffset();
            INCREMENT 4

         @ 75,95 LABEL lab_parag_2 ;
            VALUE 'Right Indent';
            WIDTH 80 ;
            HEIGHT 23 ;
            FONT 'Arial' ;
            SIZE  9

         @ 75 ,170 SPINNER Spin_Parag_2;
            RANGE 0 , 1200 ;
            VALUE 0 ;
            WIDTH 60;
            HEIGHT 20;
            INCREMENT 4

         //      @ 5, 240 FRAME Panel_Parag_3 CAPTION 'Tab' WIDTH 120 HEIGHT 50

         @ 20,245 LABEL lab_parag_4 ;
            VALUE 'Numbering';
            WIDTH 70 ;
            HEIGHT 23 ;
            FONT 'Arial' ;
            SIZE  9

         @ 15 ,325  CHECKBUTTON ChkBtn;
            PICTURE 'Number';
            WIDTH 23;
            HEIGHT 23;

         @ 60 ,270 BUTTON Btn_ParagOK;
            CAPTION 'OK';
            ACTION SetParag_Click() ;
            WIDTH 80 HEIGHT 25;
            FONT 'Arial' SIZE 9

         @ 90 ,270 BUTTON Btn_ParagCancel;
            CAPTION 'Cancel';
            ACTION Release_Parag_Click() ;
            WIDTH 80 HEIGHT 25;
            FONT 'Arial' SIZE 9

      END WINDOW

      ACTIVATE WINDOW Form_3

   ENDIF

   RETURN 1

FUNCTION Release_Parag_Click()

   Form_3.Release
   RESetFocus()

   RETURN NIL

FUNCTION Init_Parag()

   LOCAL aParForm

   aParForm := GetParForm( hEd )
   IF aParForm[1]
      Form_3.radioParag_1.Value   := 1
   ELSEIF aParForm[2]
      Form_3.radioParag_1.Value   := 2
   ELSE
      Form_3.radioParag_1.Value   := 3
   ENDIF
   Form_3.Spin_Parag_1.Value := aParForm[6]/20
   Form_3.Spin_Parag_2.Value := aParForm[7]/20
   Form_3.Spin_Parag_3.Value := aParForm[8]/20
   Form_3.ChkBtn.Value := aParForm[5]

   RETURN NIL

FUNCTION RangeOffset()

   IF IsWindowActive (Form_3)
      IF Form_3.Spin_Parag_2.Value + Form_3.Spin_Parag_1.Value < 0
         Form_3.Spin_Parag_2.Value := 0
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION SetParag_Click()

   LOCAL aForm, lLeft, lCenter, lRight, nTab, nNumber, StartId, RightId, Offset

   aForm := GetParForm( hEd )
   lLeft   := .f.
   lCenter := .f.
   lRight  := .f.

   IF Form_3.radioParag_1.Value == 1
      lLeft :=.t.
   ELSEIF Form_3.radioParag_1.Value ==2
      lCenter :=.t.
   ELSE
      lRight := .t.
   ENDIF
   nTab    := aForm[4]
   nNumber := Form_3.ChkBtn.Value
   StartId := Form_3.Spin_Parag_1.Value * 20
   RightId := Form_3.Spin_Parag_2.Value * 20
   Offset  := Form_3.Spin_Parag_3.Value * 20

   IF !SetParForm( hEd , lLeft, lCenter, lRight, nTab , nNumber, StartId, RightId, Offset)
      MsgInfo('Problem of set paragraph!', 'Error')
   ENDIF
   Form_3.Release
   RESetFocus()
   SelParForm()

   RETURN NIL

FUNCTION SetNumb_Click()

   LOCAL aForm, lLeft, lCenter, lRight, nTab, nNumber, StartId, RightId, Offset
   LOCAL nOffs := 0

   IF Form_1.Btn_Numb.Value
      nOffs := 16 * 20
   ENDIF
   aForm := GetParForm( hEd )
   lLeft   := aForm[1]
   lCenter := aForm[2]
   lRight  := aForm[3]
   nTab    := aForm[4]
   nNumber := Form_1.Btn_Numb.Value
   StartId := nOffs
   RightId := aForm[7]
   Offset  := nOffs

   IF !SetParForm( hEd , lLeft, lCenter, lRight, nTab , nNumber, StartId, RightId, Offset)
      MsgInfo('Problem of set number!', 'Error')
   ENDIF
   RESetFocus()

   RETURN NIL

FUNCTION SetOffset_Click(met)

   LOCAL aForm, lLeft, lCenter, lRight, nTab, nNumber, StartId, RightId, Offset
   LOCAL nDim := 1, nOffs:=32 * 20

   IF met == 0
      nDim := -1
   ENDIF
   aForm   := GetParForm( hEd )
   lLeft   := aForm[1]
   lCenter := aForm[2]
   lRight  := aForm[3]
   nTab    := aForm[4]
   nNumber := aForm[5]
   StartId := aForm[6] + nOffs * nDim
   RightId := aForm[7]
   Offset  := aForm[8]
   IF StartId < 0
      StartId := 0
   ENDIF
   IF !SetParForm( hEd , lLeft, lCenter, lRight, nTab , nNumber, StartId, RightId, Offset)
      MsgInfo('Problem of set Offset!', 'Error')
   ENDIF
   RESetFocus()

   RETURN NIL

FUNCTION SetColor_Click()

   LOCAL sel, aFont,tmp

   IF hEd != 0
      Sel   := RangeSelRTF(hEd)
      aFont := GetFontRTF(hEd, 1 )
      IF ! Empty ( aFont [1] )
         Tmp      := aFont[5]
         aFont[5] := { GetRed(Tmp) , GetGreen(Tmp) , GetBlue(Tmp) }
      ELSE
         aFont [5] := { Nil , Nil , Nil }
      ENDIF

      Tmp := aFont[5]
      tmp := { GetRed(Tmp) , GetGreen(Tmp) , GetBlue(Tmp) }

      tmp := GetColor (tmp)
      IF tmp [1] != NIL .and. tmp [2] != NIL .and.tmp [3] != NIL
         aFont [5] := RGB ( tmp[1] , tmp[2] , tmp[3] )
      ENDIF
      SetFontRTF(hEd, Sel, aFont[1], aFont[2], aFont[3], aFont[4], aFont[5], aFont[6], aFont[7])
   ENDIF

   RETURN NIL

FUNCTION SetMenuUndo()

   LOCAL nUndo

   nUndo := GetUndoName(hEd)
   //    if nUndo != 0
   IF lUndo
      AddMenuUndo( nUndo, 0  )
   ELSE
      AddMenuUndo( nUndo, 1  )
   ENDIF
   //    endif

   RETURN NIL

FUNCTION SetZoom_Click()

   LOCAL nPos

   nPos := Form_1.Combo_3.Value
   IF nPos > 0 .and. hEd != 0
      SetZoom( hEd, aNumZoom[ nPos,1 ] , aNumZoom[ nPos,2 ] )
      IF aNumZoom[ nPos,1 ] == 0
         nRatio := 1
      ELSE
         nRatio := aNumZoom[ nPos,1 ] / aNumZoom[ nPos,2 ]
      ENDIF
      _SetControlWidth( ActiveEdit, "Form_1",nEditWidth * nDevCaps * nRatio )
      Set_PageWidth(nEditWidth * nDevCaps * nRatio)
      ReSizeRTF()
      RESetFocus()
   ENDIF

   RETURN NIL

FUNCTION GetZoom_Click()

   LOCAL aZoom,n

   aZoom := GetZoom( hEd )
   FOR n:= 1 to len(aNumZoom)
      IF aZoom[1] == aNumZoom[ n, 1] .and. aZoom[2] == aNumZoom[ n, 2]
         Form_1.Combo_3.Value := n
         EXIT
      ENDIF
   NEXT

   RETURN NIL

FUNCTION GetLin(met)

   LOCAL aTabs, n, wSlid, aForm, old_Id, CurPos
   LOCAL lLeft, lCenter, lRight, nTab, nNumber, StartPos, RightPos, OffsetPos

   IF lLin
      wSlid    := (nEditWidth * nDevCaps -lmPage-rmPage)/nRtfRatio
      aForm    := GetParForm( hEd )
      lLeft    := aForm[1]
      lCenter  := aForm[2]
      lRight   := aForm[3]
      nTab     := aForm[4]
      nNumber  := aForm[5]
      StartPos := aForm[6]
      RightPos := aForm[7]
      OffsetPos:= aForm[8]
      aTabs    := GetParTabs(hEd)
      IF met == 1
         old_id    := StartPos
         StartPos  := _GetPosSlider ( ActiveSlider , MainForm )*20
         OffsetPos := (OffsetPos -(StartPos-old_Id))
         IF StartPos == old_id
            CurPos:= (GetCursorCol() - _GetControlCol (ActiveSlider,MainForm)- 7 -GetCurWin(MainForm))/nRtfRatio/nRatio
            DO CASE
            CASE nTypTab == 1
               aadd(aTabs, CurPos)
               nTab := len(aTabs)
               SetParTabs( hEd, aTabs )
            CASE nTypTab == 2
               _SetSelStart ( ActiveSlider , MainForm ,CurPos)
               OffsetPos := CurPos*20 - StartPos
            CASE nTypTab == 3
               _SetSelEnd ( ActiveSlider , MainForm  , CurPos )
               RightPos := (wSlid - CurPos)*20
            ENDCASE

         ENDIF
         IF !SetParForm( hEd , lLeft, lCenter, lRight, nTab , nNumber, StartPos, RightPos, OffsetPos)
            MsgInfo('Error')
         ENDIF

      ENDIF
      _ClearTics (  ActiveSlider , MainForm )
      FOR n:=1 to len(aTabs)
         _SetTic ( ActiveSlider , MainForm, aTabs[n] )
      NEXT
      _SetPosSlider ( ActiveSlider , MainForm , StartPos / 20  )
      _SetSelStart ( ActiveSlider , MainForm , StartPos / 20 + OffsetPos / 20 )
      _SetSelEnd ( ActiveSlider , MainForm  , wSlid - RightPos / 20 )
   ENDIF

   RETURN NIL

FUNCTION GetCurWin(form)

   LOCAL hwnd, aRec:={0,0,0,0}

   hwnd := GetFormHandle(form)
   GetWindowRect(hwnd, aRec)

   RETURN aRec[1]+4

FUNCTION PageSetupRTF_Click()

   LOCAL hwnd, aPage

   hwnd := GetFormHandle(MainForm)

   aPage :=PageSetupRTF(hwnd,lmPage,rmPage,tmPage,bmPage,nPageWidth,nPageHeight,nPageSize,nPageOrient)
   IF aPage[1] != 0
      lmPage      :=aPage[2]
      rmPage      :=aPage[3]
      tmPage      :=aPage[4]
      bmPage      :=aPage[5]
      nPageWidth  :=aPage[6]
      nPageHeight :=aPage[7]
      nPageSize   :=aPage[8]
      nPageOrient :=aPage[9]
      nEditWidth  := nPageWidth - lmPage - rmPage
      ReSizeRTF()
   ENDIF

   RETURN NIL

FUNCTION ModifySlider(ParentForm, ControlName, nTics)

   _SetThumbLength ( ControlName, ParentForm , 12 )
   _SetPageSize (ControlName, ParentForm , 0)
   _ClearTics ( ControlName, ParentForm   )
   _SetTic ( ControlName, ParentForm , nTics )

   RETURN NIL

FUNCTION syg(typ)

   IF typ ==1   // typing
      TONE( 4000, 1 )
   ELSE     // select
      TONE(  300, 1 )
   ENDIF

   RETURN NIL

FUNCTION  DefSplash(met)

   DEFINE WINDOW Form_Splash ;
         AT 0,0 ;
         WIDTH 250 + if(IsVista().or.IsSeven(),GetBorderWidth(),0) ;
         HEIGHT 114 - if(IsVista().or.IsSeven(),0,8) ;
         TITLE '';
         TOPMOST NOCAPTION ;
         ON INIT SplashDelay(met)

      @ 10 ,10 IMAGE Icon_1;
         PICTURE "RICHED" ;
         WIDTH 50 HEIGHT 50

      @ 5 ,5 FRAME Frame_1;
         WIDTH 235  HEIGHT 90

      @ 10,70 LABEL Label_1 ;
         WIDTH 180 HEIGHT 20 ;
         VALUE 'RichEdit Ver.'+REver  ;
         FONT 'Arial' SIZE 11 BOLD //CENTERALIGN

      @ 35,70 LABEL Label_2 ;
         WIDTH 180 HEIGHT 20 ;
         VALUE '(c) 2003-2009 Janusz Pora' ;
         FONT 'Arial' SIZE 9 FONTCOLOR BLUE //CENTERALIGN

      @ 60,70 LABEL Label_3 ;
         WIDTH 180 HEIGHT 20 ;
         VALUE 'HMG Harbour MiniGui' ;
         FONT 'Arial' SIZE 9 //CENTERALIGN

      IF met == 1
         @ 65,15  BUTTON Btn_splash ;
            CAPTION 'OK' ;
            ACTION  {|| Form_Splash.Release };
            WIDTH 40 HEIGHT 20 ;
            FONT 'Arial' SIZE 9 BOLD DEFAULT

         ON KEY ESCAPE ACTION Form_Splash.Btn_splash.OnClick
      ENDIF

   END WINDOW
   IF met == 1
      Form_Splash.Center
      ACTIVATE WINDOW Form_Splash
   ENDIF

   RETURN NIL

PROCEDURE SplashDelay(met)

   LOCAL iTime

   IF met == 1

      RETURN
   ENDIF
   iTime := Seconds()
   DO WHILE Seconds() - iTime < 2
      Do Events
   ENDDO
   Form_Splash.Release

   RETURN

#include "l_richEditBox.prg"

#include "h_sliderEx.prg"
#include "Re_Undo.prg"
