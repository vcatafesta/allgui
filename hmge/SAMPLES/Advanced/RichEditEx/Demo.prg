/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2002-2005 Roberto Lopez <harbourminigui@gmail.com>
* http://harbourminigui.googlepages.com/
* Copyright 2003-2005 Janusz Pora <januszpora@onet.eu>
*/

#include "minigui.ch"
#include "winprint.ch"

#define KON_LIN   chr(13)+chr(10)

#define CC_FULLOPEN   2
#define CC_PREVENTFULLOPEN   4
#define CC_RGBINIT   1
#define CC_SHOWHELP   8
#define CC_SOLIDCOLOR   128
#define CC_ANYCOLOR      256  //      0x00000100

MEMVAR ActiveEdit

STATIC cFileIni     := "RichEdit.ini"

STATIC aListFont    := {}
STATIC aSizeFont    := {'8','9','10','11','12','14','16','18','20','22','24','26','28','36','48','72'}
STATIC aRatioZoom   := {'500%','200%','150%','100%','75%','50%','25%','10%'}
STATIC aNumZoom     := {{5,1},{2,1},{3,2},{0,0},{2,3},{1,2},{1,4},{1,10}}
STATIC nEditWidth   := 165                     // in mm   // 720 points
STATIC nPageWidth   := 210
STATIC nPageHeight  := 297
STATIC nPageSize    := DMPAPER_A4
STATIC nPageOrient  := DMORIENT_PORTRAIT
STATIC lmPage       := 10                       //left margin
STATIC rmPage       := 20                       //right margin
STATIC tmPage       := 10                       //top margin
STATIC bmPage       := 20                       //bottom margin

STATIC nRatio       := 1                        // Ratio: zoom
STATIC nDevCaps     := 1                        // Ratio: pixel / cm
STATIC nRtfRatio    := 1.335                    // Ratio: Window RTF / Window
STATIC cTitle       := 'Harbour MiniGUI RichEdit Demo'
STATIC nWidth       := 750
STATIC nHeight      := 430
STATIC lFind        := .f.
STATIC aFileEdit    := {}
STATIC InstallPath  := ""
STATIC cHelp        := "RichEdit.chm"

STATIC rEdit := 8
STATIC wEdit := 737
STATIC hEdit := 350
STATIC hEd   := 0

FUNCTION Main

   PUBLIC ActiveEdit:='Edit_1'

   nWidth  := GetDesktopWidth() * 0.78125
   nHeight := GetDesktopHeight() * 0.78125

   SET CENTURY ON
   SET DATE German

   SET InteractiveClose Query Main

   Read_Font()
   InstallPath := cFilePath( HB_ArgV(0) )

   IF FILE(InstallPath + "\" + cHelp)
      SET HELPFILE TO cHelp
   ENDIF

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH nWidth HEIGHT nHeight ;
         TITLE cTitle ;
         ICON 'AREDIT' ;
         MAIN ;
         ON INIT ( InitRichEdit(), New_File() ) ;
         ON RELEASE WinEnd_Click(0) ;
         ON SIZE ReSizeRTF() ;
         ON MAXIMIZE ReSizeRTF() ;
         ON MINIMIZE ReSizeRTF()

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
            ITEM '&New'+Chr(9)+'Ctrl+N'          ACTION New_File() IMAGE "NEW"
            ITEM '&Open'+Chr(9)+'Ctrl+O'   ACTION Open_File() IMAGE "Open"
            ITEM '&Close'            ACTION Close_File(0) IMAGE "Close"
            ITEM '&Save'+Chr(9)+'Ctrl+S'   ACTION Save_File(0) IMAGE "Save"
            ITEM 'Save &as ...'         ACTION Save_File(1)
            SEPARATOR
            ITEM 'Page Se&tup'         ACTION  PageSetupRTF_Click()
            ITEM '&Print'            ACTION  PrintRTF_Click()  IMAGE 'Printer'
            SEPARATOR
            ITEM 'E&xit'            ACTION WinEnd_Click(1)
         END POPUP
         POPUP '&Edit'
            ITEM '&Undo'            ACTION Undo_Click() IMAGE 'undo'
            ITEM '&Redo'            ACTION Redo_Click() IMAGE 'redo'
            SEPARATOR
            ITEM '&Copy'               ACTION Copy_click()  IMAGE 'copy' NAME It_Copy
            ITEM 'C&ut'                ACTION Cut_Click()   IMAGE 'cut' NAME It_Cut
            ITEM '&Paste'            ACTION Paste_Click() IMAGE 'paste' NAME It_Paste
            ITEM '&Delete'         ACTION Clear_Click() IMAGE 'clear' NAME It_Clear
            SEPARATOR
            ITEM '&Select all'         ACTION SelectAll_Click()
            SEPARATOR
            ITEM '&Find'            ACTION Search_click(0)  NAME It_Find IMAGE 'find2'
            ITEM '&Replace'         ACTION Search_click(1)  NAME It_Repl IMAGE 'repeat'
         END POPUP
         POPUP '&Insert'
            ITEM '&Font'            ACTION SelFont(1) IMAGE "FONT"
            ITEM '&Paragraph'         ACTION Paragraph_click() IMAGE "PARAGRAF"
         END POPUP
         POPUP '&Help'
            ITEM '&Help'+Chr(9)+'F1'      ACTION DISPLAY HELP MAIN IMAGE "HELP"
            ITEM 'About'            ACTION  MsgInfo (padc("MiniGUI RichEdit Demo", Len(MiniguiVersion()))+KON_LIN+ ;
               "Contributed by Janusz Pora <januszpora@onet.eu>"+KON_LIN+KON_LIN+ ;
               MiniguiVersion(),"A COOL Feature ;)")
         END POPUP
      END MENU

      DEFINE CONTEXT MENU
         ITEM '&Copy'         ACTION Copy_click()   IMAGE 'copy' NAME ItC_Copy
         ITEM 'C&ut'          ACTION Cut_Click()   IMAGE 'cut' NAME ItC_Cut
         ITEM '&Paste'      ACTION Paste_Click()   IMAGE 'paste' NAME ItC_Paste
         SEPARATOR
         ITEM '&Select all'   ACTION SelectAll_Click()
         SEPARATOR
         ITEM '&Find'      ACTION Search_click(0) NAME ItC_Find IMAGE 'find2'
         ITEM '&Replace'   ACTION Search_click(1) NAME ItC_Repl IMAGE 'repeat'
      END MENU

      DEFINE SPLITBOX

         DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 17,17 FLAT

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
               ACTION Save_File(0) ;
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
            ITEMS aRatioZoom ;
            VALUE 4 ;
            HEIGHT 200 ;
            FONT 'Tahoma' SIZE 9 ;
            WIDTH 80 ;
            TOOLTIP 'Zoom Ratio' ;
            ON CHANGE SetZoom_Click() ;

         DEFINE TOOLBAR ToolBar_2 BUTTONSIZE 17,17 FONT 'ARIAL' SIZE 8 FLAT

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
               ACTION Cut_Click() ;

            BUTTON Btn_Clear ;
               TOOLTIP 'Clear' ;
               PICTURE 'Clear' ;
               ACTION Clear_Click() ;
               SEPARATOR

            BUTTON Btn_Undo ;
               TOOLTIP 'Undo' ;
               PICTURE 'undo' ;
               ACTION Undo_Click() ;

            BUTTON Btn_Redo ;
               TOOLTIP 'Redo' ;
               PICTURE 'redo' ;
               ACTION Redo_Click() ;
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
            ITEMS aListFont ;
            VALUE 2 ;
            HEIGHT 200 ;
            FONT 'Tahoma' SIZE 9 ;
            TOOLTIP 'Font Name' ;
            ON CHANGE SetName_Click() ;
            BREAK

         COMBOBOX Combo_2 ;
            ITEMS aSizeFont ;
            VALUE 3 ;
            WIDTH 40 ;
            TOOLTIP 'Font Size' ;
            ON CHANGE SetSize_Click()

         DEFINE TOOLBAR ToolBar_3 BUTTONSIZE 17,17 SIZE 8 FLAT

            BUTTON Btn_Bold ;
               TOOLTIP 'Bold' ;
               PICTURE 'bold' ;
               ACTION SetBold_click() ;
               CHECK

            BUTTON Btn_Italic ;
               TOOLTIP 'Italic' ;
               PICTURE 'Italic' ;
               ACTION SetItalic_Click() ;
               CHECK

            BUTTON Btn_Under ;
               TOOLTIP 'Underline' ;
               PICTURE 'under' ;
               ACTION SetUnderLine_Click() ;
               CHECK

            BUTTON Btn_Strike ;
               TOOLTIP 'StrikeOut' ;
               PICTURE 'strike' ;
               ACTION SetStrikeOut_Click() ;
               CHECK SEPARATOR

            BUTTON Btn_Left ;
               TOOLTIP 'Left Tekst' ;
               PICTURE 'left' ;
               ACTION  SetLeft_Click() ;
               CHECK GROUP

            BUTTON Btn_Center ;
               TOOLTIP 'Center Tekst' ;
               PICTURE 'center' ;
               ACTION  SetCenter_Click() ;
               CHECK GROUP

            BUTTON Btn_Right ;
               TOOLTIP 'Right Text' ;
               PICTURE 'Right' ;
               ACTION SetRight_Click() ;
               CHECK GROUP SEPARATOR

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
               ACTION SetOffset_Click(0) ;
               SEPARATOR

         END TOOLBAR

      END SPLITBOX

      @ 56+rEdit,3 RICHEDITBOX &ActiveEdit ;
         WIDTH wEdit ;
         HEIGHT hEdit ;
         VALUE '' ;
         MAXLENGTH 510000 ;
         ON CHANGE UpdateText() ;
         ON SELECT SelectText() ;
         NOHSCROLL

   END WINDOW

   IF nWidth >= 800
      Form_1.Center
   ELSE
      Form_1.Maximize
   ENDIF

   ACTIVATE WINDOW Form_1

   RETURN NIL

FUNCTION WinEnd_Click(mod)

   LOCAL cFile

   IF _IsControlDefined (ActiveEdit, 'Form_1')
      hEd := GetControlHandle (ActiveEdit, 'Form_1')
      IF len(aFileEdit) > 0
         cFile := aFileEdit[1]
         IF ModifyRTF( hEd, 0 )
            IF MsgYesNo ('Save changes?', cFile)
               Save_File(0)
            ENDIF
         ENDIF
      ENDIF
      RELEASE CONTROL &ActiveEdit OF Form_1
   ENDIF
   IF mod ==1
      RELEASE WINDOW MAIN
   ENDIF

   RETURN NIL

FUNCTION SelectText()

   SelFont(2)
   Btn_Stat(1)
   SelParForm()

   RETURN NIL

FUNCTION UpdateText()

   // SetMenuUndo()

   RETURN NIL

FUNCTION SetEditFocus()

   //    _SetFocus ( ActiveEdit,'Form_1' )

   RETURN NIL

FUNCTION GetCtrlSize()

   LOCAL w, h, i, hrb:=27, hst:=37
   LOCAL hwnd, actpos:={0,0,0,0}

   hwnd := GetFormHandle('Form_1')
   GetWindowRect(hwnd,actpos)

   w := actpos[3]-actpos[1]
   h := actpos[4]-actpos[2]

   i := aScan ( _HMG_aFormHandles , hWnd )
   IF i > 0
      IF _HMG_aFormReBarHandle [i] > 0
         hrb = RebarHeight ( _HMG_aFormReBarHandle [i] )
      ENDIF
   ENDIF
   rEdit := hrb + 8
   wEdit := w - 13
   hEdit := h - hrb - hst - IF(IsXPThemeActive(), IF(IsSeven(), 56, 48), 40)

   RETURN NIL

FUNCTION ReSizeRTF()

   GetCtrlSize()
   _SetControlRow( ActiveEdit, "Form_1", rEdit)
   _SetControlWidth( ActiveEdit, "Form_1",min(nEditWidth * nDevCaps * nRatio, wEdit))
   _SetControlHeight( ActiveEdit, "Form_1", hEdit )
   Set_PageWidth(nEditWidth * nDevCaps * nRatio)

   RETURN NIL

FUNCTION Set_PageWidth(nWidth)

   LOCAL aRc

   aRC = GetRect(hEd)
   SetRect( hEd, lmPage+1 , aRc[2]+1 , nWidth-(lmPage+rmPage)+1, aRc[4])

   RETURN NIL

FUNCTION InitRichEdit()

   nDevCaps := GetDevCaps(0)/25.4
   ReSizeRTF()
   Btn_Stat(0)

   RETURN NIL

FUNCTION Read_font()

   LOCAL cList, nPos

   aListFont:={}
   cList = rr_getfonts()
   DO WHILE ( nPos := AT( ',', cList )) != 0
      AADD( aListFont, SUBSTR( cList, 1, nPos - 1 ))
      cList := SUBSTR( cList, nPos + 1 )
   ENDDO
   AADD( aListFont, cList )
   ASORT(aListFont)

   RETURN NIL

FUNCTION NewEdit(cFile, typ)

   LOCAL cxFile, lNew :=.t.

   cxFile := ALLTRIM(substr(cFile,Rat('\',cFile)+1))
   nRatio := 1
   aFileEdit := {cxFile, typ, cFile}

   ActiveEdit:= 'Edit_1'

   GetCtrlSize()

   Form_1.Title := cTitle+' ('+cxFile+')'
   hEd := GetControlHandle (ActiveEdit,'Form_1')
   IF lNew
      lNew:=.f.
      SetSelRange( hEd )
      AutoUrlDetect(hEd , .t.)
      SelFont(2)
   ENDIF
   Set_PageWidth(nEditWidth * nDevCaps)
   GetZoom_Click()

   RETURN NIL

FUNCTION Save_File(met)

   LOCAL c_File, cxFile, typ := 1

   c_File := aFileEdit[1]

   IF aFileEdit[2] == 0
      met := 1
   ENDIF
   IF met == 1
      c_File := PutFile ( {{'Rich text File','*.rtf'},{'Text File','*.txt'}} , 'Get File' )
   ENDIF
   IF !empty(c_File)
      cxFile := UPPER(ALLTRIM(substr(c_File,Rat('.',c_File)+1)))

      IF cxFile == 'RTF'
         typ := 2
      ELSEIF cxFile == 'PRG'
         typ := 1
      ENDIF

      StreamOut( hEd, c_File, typ)
      ModifyRTF(hEd, 1)
      ReSizeRTF()
   ENDIF
   SetEditFocus()

   RETURN NIL

FUNCTION New_File()

   LOCAL cBuffer:=''

   NewEdit('NoName',0)
   _Setvalue ( ActiveEdit, 'Form_1', cBuffer )
   SetTextMode(hEd, 2)
   ModifyRTF(hEd,1)
   Btn_Stat(1)

   RETURN NIL

FUNCTION Open_file(cFile)

   LOCAL typ := 1, c_File

   IF empty(cFile)
      c_File := GetFile({{'Rich text File','*.rtf'},{'Text File','*.txt'},{'All File','*.*'}},'Get File')
   ELSE
      c_File := cFile
   ENDIF
   IF empty(c_File)

      RETURN NIL
   ENDIF

   NewEdit(c_File,1)

   IF UPPER(ALLTRIM(substr(c_File,Rat('.',c_File)+1))) == 'RTF'
      typ := 2
   ENDIF
   StreamIn( hEd, c_File, typ )

   ReSizeRTF()
   ModifyRTF(hEd,1)
   Btn_Stat(1)

   RETURN NIL

PROCEDURE Close_File()

   LOCAL cFile, cBuffer:=''

   cFile:=aFileEdit[1]
   IF ModifyRTF( hEd, 0 )
      IF MsgYesNo ('Save changes?', cFile)
         Save_File(0)
      ENDIF
   ENDIF

   aFileEdit := {}
   _Setvalue ( ActiveEdit, 'Form_1', cBuffer )
   Form_1.Title := cTitle

   Btn_Stat(1)

   RETURN

FUNCTION SelCharRTF()

   LOCAL Sel, aF, nPos, ret

   Sel   := RangeSelRTF(hEd)
   aF    := GetFontRTF( hEd, 1 )
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
      IF !_SetFontNameRTF ('Form_1' , ActiveEdit , cName)
         MsgInfo('No changed Font!')
      ENDIF
   ENDIF
   SetEditFocus()

   RETURN NIL

FUNCTION SetSize_Click()

   LOCAL nPos, nSize

   nPos := Form_1.Combo_2.Value
   IF nPos > 0 .and. hEd != 0
      nSize := val(aSizeFont[nPos])
      IF !_SetFontSizeRTF ( 'Form_1' , ActiveEdit , nSize)
         MsgInfo('No changed Size!')
      ENDIF
   ENDIF
   SetEditFocus()

   RETURN NIL

FUNCTION SetBold_Click()

   LOCAL lBold

   lBold := Form_1.Btn_Bold.Value
   IF hEd != 0
      _SetFontBoldRTF ( 'Form_1' , ActiveEdit , lBold)
   ENDIF

   RETURN NIL

FUNCTION SetItalic_Click()

   LOCAL lItalic

   lItalic := Form_1.Btn_Italic.Value
   IF hEd != 0
      _SetFontItalicRTF ( 'Form_1' , ActiveEdit , lItalic)
   ENDIF

   RETURN NIL

FUNCTION SetUnderLine_Click()

   LOCAL lUnderLine

   lUnderLine := Form_1.Btn_Under.Value
   IF hEd != 0
      _SetFontUnderLineRTF ( 'Form_1' , ActiveEdit , lUnderLine)
   ENDIF

   RETURN NIL

FUNCTION SetStrikeOut_Click()

   LOCAL lStrike

   lStrike := Form_1.Btn_Strike.Value
   IF hEd != 0
      _SetFontStrikeOutRTF ( 'Form_1' , ActiveEdit , lStrike)
   ENDIF

   RETURN NIL

FUNCTION SetLeft_Click()

   LOCAL lLeft

   lLeft := Form_1.Btn_Left.Value
   IF hEd != 0
      _SetFormatLeftRTF ( 'Form_1' , ActiveEdit , lLeft)
   ENDIF

   RETURN NIL

FUNCTION SetCenter_Click()

   LOCAL lCenter

   lCenter := Form_1.Btn_Center.Value
   IF hEd != 0
      _SetFormatCenterRTF ( 'Form_1' , ActiveEdit , lCenter)
   ENDIF

   RETURN NIL

FUNCTION SetRight_Click()

   LOCAL lRight

   lRight := Form_1.Btn_Right.Value
   IF hEd != 0
      _SetFormatRightRTF ( 'Form_1' , ActiveEdit , lRight)
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

   LOCAL H, lSel

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

   LOCAL Tmp, Sel, aFont

   IF hEd != 0
      Sel := RangeSelRTF(hEd)
      aFont := GetFontRTF( hEd, 1 )
      IF typ==1
         IF ! Empty ( aFont [1] )
            Tmp := aFont[5]
            aFont [5] := { GetRed(Tmp) , GetGreen(Tmp) , GetBlue(Tmp) }
         ELSE
            aFont [5] := { Nil , Nil , Nil }
         ENDIF

         aFont := GetFont(aFont[1], aFont[2], aFont[3], aFont[4], aFont[5], aFont[6], aFont[7])

         IF ! Empty ( aFont [1] )
            tmp := aFont[5]
            aFont[5] := RGB( tmp[1] , tmp[2] , tmp[3] )

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
   Form_1.Btn_Numb.Value   := aParForm[5]

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

   /*
   Function SetWordWrap_Click()
   Local lViewMode

   lViewMode := if(Form_1.Btn_Wrap.Value,1,0)
   SetOptions ( hEd , lViewMode)

   Return NIL
   */

FUNCTION Search_click(repl)

   LOCAL wr:=0, ww:=0, cTitle:='Find'

   IF !IsWIndowActive (Form_2)
      IF repl==1
         wr := 30
         ww := 100
         ctitle := 'Replace'
      ENDIF

      DEFINE WINDOW  Form_2 ;
            AT 255,201 ;
            WIDTH 370 + ww ;
            HEIGHT 150 +wr ;
            TITLE cTitle ;
            TOPMOST ;
            NOMINIMIZE ;
            NOMAXIMIZE ;
            NOSIZE ;
            ON INIT Init_Find(repl)

         @ 8,100 TEXTBOX text_1 ;
            HEIGHT 23 ;
            WIDTH 250 ;
            FONT 'Arial' ;
            size   9 ;
            MAXLENGTH  230 ;
            ON CHANGE Chng_btn(repl)

         @ 10,10 LABEL lab_1 ;
            VALUE 'Find What:' ;
            WIDTH 80 ;
            HEIGHT 23 ;
            FONT 'Arial' ;
            SIZE  9

         IF repl == 1
            @ 38,100 TEXTBOX text_2 ;
               HEIGHT 23 ;
               WIDTH 250 ;
               FONT 'Arial' ;
               size   9 ;
               MAXLENGTH  230 ;
               ON CHANGE Chng_btn(repl)

            @ 40,10 LABEL lab_2 ;
               VALUE 'Replace With:' ;
               WIDTH 80 ;
               HEIGHT 23 ;
               FONT 'Arial' ;
               SIZE  9
         ENDIF

         @ 35+wr,10 CHECKBOX checkbox_1 ;
            CAPTION 'Match Case' ;
            WIDTH 130 ;
            HEIGHT 23 ;
            VALUE .F. ;
            FONT 'Arial' ;
            SIZE 9

         @ 55+wr,10 CHECKBOX checkbox_2 ;
            CAPTION 'Whole word' ;
            WIDTH 130 ;
            HEIGHT 23 ;
            VALUE .F. ;
            FONT 'Arial' ;
            SIZE 9

         @ 75+wr,10 CHECKBOX checkbox_3 ;
            CAPTION 'Select matching text' ;
            WIDTH 130 ;
            HEIGHT 23 ;
            VALUE .T. ;
            FONT 'Arial' ;
            SIZE 9

         IF repl==0

            @ 35+wr, 160 FRAME Panel_1 CAPTION 'Direction' WIDTH 100 HEIGHT 65

            @ 50+wr,170 RADIOGROUP radiogrp_1 ;
               OPTIONS {'Up','Down'} ;
               VALUE 2 ;
               WIDTH  70 ;
               FONT 'Arial' ;
               SIZE 9 ;
               SPACING 20
         ENDIF

         @ 40 ,270+ww BUTTON Btn_Find ;
            CAPTION 'Find Next' ;
            ACTION FindNext_Click(0) ;
            WIDTH 80 HEIGHT 25 ;
            FONT 'Arial' SIZE 9

         IF repl==1
            @ 10 ,270+ww BUTTON Btn_Repl ;
               CAPTION '&Replace' ;
               ACTION FindNext_Click(1) ;
               WIDTH 80 HEIGHT 25 ;
               FONT 'Arial' SIZE 9

            @ 70 ,270+ww BUTTON Btn_ReplAll ;
               CAPTION 'Replace &All' ;
               ACTION FindNext_Click(2) ;
               WIDTH 80 HEIGHT 25 ;
               FONT 'Arial' SIZE 9
         ENDIF

         @ 70+wr ,270+ww BUTTON Btn_Cancel ;
            CAPTION 'Cancel' ;
            ACTION Release_Find_Click(repl) ;
            WIDTH 80 HEIGHT 25 ;
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
   SetEditFocus()

   RETURN NIL

FUNCTION Init_Find(repl)

   LOCAL nSel, cSel

   IF (nSel:=RangeSelRTF(hEd)) > 0
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
            ReplaceSel( hEd , ReplTxt)

            ret := FindChr( hEd, Text, direction, wholeword, mcase, seltxt )
            lFind := if(ret[3] < 0, .f.,.t.)
            IF repl==1
               EXIT
            ENDIF
         ELSE
            lFind := .f.
            EXIT
         ENDIF
         SetEditFocus()
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

PROCEDURE PrintRTF_Click(met)

   LOCAL  hbprn, cpMin, cpMax, LenMax, i, ret, wx, hx, prev

   //met = 0 -> prewiew
   prev := if(met==1,.f.,.t.)
   hbprn:=hbprinter():new()
   hbprn:selectprinter("",prev)

   IF hbprn:error != 0
      IF met == 0

         RETURN
      ELSE
         MSGSTOP ('Print Cancelled!')

         RETURN
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
      IF i >= hbprn:nFromPage .and. ( i <= hbprn:nToPage .or. hbprn:nToPage == 0 )
         hbprn:startpage()
         ret:= PrintRTF(hEd, hbprn:hDC, wx, hx, cpMin, cpMax, .t.)
         hbprn:endpage()
      ELSE
         ret:= PrintRTF(hEd, hbprn:hDC, wx, hx, cpMin, cpMax, .f.)
      ENDIF
      i++
      cpMin :=ret
   ENDDO

   hbprn:enddoc()
   hbprn:end()

   RETURN

FUNCTION Paragraph_click()

   IF !IsWIndowActive (Form_3)

      DEFINE WINDOW  Form_3 ;
            AT 255,201 ;
            WIDTH 370 ;
            HEIGHT 150 ;
            TITLE 'Paragraph formatting ' ;
            TOPMOST ;
            NOMINIMIZE ;
            NOMAXIMIZE ;
            NOSIZE ;
            ON INIT Init_Parag()

         @ 5, 10 FRAME Panel_Parag_1 CAPTION 'Aligment' WIDTH 70 HEIGHT 100

         @ 25,15 RADIOGROUP radioParag_1 ;
            OPTIONS {'Left','Center','Right'} ;
            VALUE 1 ;
            WIDTH  60 ;
            FONT 'Arial' ;
            SIZE 9 ;
            SPACING 20

         @ 5, 85 FRAME Panel_Parag_2 CAPTION 'Indentation' WIDTH 150 HEIGHT 100

         @ 25,95 LABEL lab_parag_1 ;
            VALUE 'Start Indent' ;
            WIDTH 80 ;
            HEIGHT 23 ;
            FONT 'Arial' ;
            SIZE  9

         @ 25 ,170 SPINNER Spin_Parag_1 ;
            RANGE 0 , 1200 ;
            VALUE 0 ;
            WIDTH 60 ;
            HEIGHT 20 ;
            INCREMENT 4

         @ 50,95 LABEL lab_parag_3 ;
            VALUE 'Offset' ;
            WIDTH 80 ;
            HEIGHT 23 ;
            FONT 'Arial' ;
            SIZE  9

         @ 50 ,170 SPINNER Spin_Parag_3 ;
            RANGE -1200 , 1200 ;
            VALUE 0 ;
            WIDTH 60 ;
            HEIGHT 20 ;
            ON CHANGE RangeOffset() ;
            INCREMENT 4

         @ 75,95 LABEL lab_parag_2 ;
            VALUE 'Right Indent' ;
            WIDTH 80 ;
            HEIGHT 23 ;
            FONT 'Arial' ;
            SIZE  9

         @ 75 ,170 SPINNER Spin_Parag_2 ;
            RANGE 0 , 1200 ;
            VALUE 0 ;
            WIDTH 60 ;
            HEIGHT 20 ;
            INCREMENT 4

         //      @ 5, 240 FRAME Panel_Parag_3 CAPTION 'Tab' WIDTH 120 HEIGHT 50

         @ 20,245 LABEL lab_parag_4 ;
            VALUE 'Numbering' ;
            WIDTH 70 ;
            HEIGHT 23 ;
            FONT 'Arial' ;
            SIZE  9

         @ 15 ,325  CHECKBUTTON ChkBtn ;
            PICTURE 'Number' ;
            WIDTH 23 ;
            HEIGHT 23 ;

         @ 60 ,270 BUTTON Btn_ParagOK ;
            CAPTION 'OK' ;
            ACTION SetParag_Click() ;
            WIDTH 80 HEIGHT 25 ;
            FONT 'Arial' SIZE 9

         @ 90 ,270 BUTTON Btn_ParagCancel ;
            CAPTION 'Cancel' ;
            ACTION Release_Parag_Click() ;
            WIDTH 80 HEIGHT 25 ;
            FONT 'Arial' SIZE 9

      END WINDOW

      ACTIVATE WINDOW Form_3

   ENDIF

   RETURN 1

FUNCTION Release_Parag_Click()

   Form_3.Release
   SetEditFocus()

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

   IF IsWIndowActive (Form_3)
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
   SetEditFocus()
   SelParForm()

   RETURN NIL

FUNCTION SetNumb_Click()

   LOCAL  aForm, lLeft, lCenter, lRight, nTab, nNumber, StartId, RightId, Offset
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
   SetEditFocus()

   RETURN NIL

FUNCTION SetOffset_Click(met)

   LOCAL  aForm, lLeft, lCenter, lRight, nTab, nNumber, StartId, RightId, Offset
   LOCAL nDim := 1, nOffs:=32 * 20

   IF met == 0
      nDim  := -1
   ENDIF
   aForm := GetParForm( hEd )
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
   SetEditFocus()

   RETURN NIL

FUNCTION SetColor_Click()

   LOCAL sel, aFont, tmp

   IF hEd != 0
      Sel := RangeSelRTF(hEd)
      aFont := GetFontRTF( hEd, 1 )
      Tmp := aFont[5]
      tmp := { GetRed(Tmp) , GetGreen(Tmp) , GetBlue(Tmp) }

      tmp := GetColor ( tmp )
      IF tmp [1] != NIL .and. tmp [2] != NIL .and.tmp [3] != NIL
         aFont [5] := RGB ( tmp[1] , tmp[2] , tmp[3] )
      ENDIF
      SetFontRTF(hEd, Sel, aFont[1], aFont[2], aFont[3], aFont[4], aFont[5], aFont[6], aFont[7])
   ENDIF

   RETURN NIL

FUNCTION Undo_Click()

   UndoRTF(hEd)

   RETURN NIL

FUNCTION Redo_Click()

   RedoRTF(hEd)

   RETURN NIL

FUNCTION SetZoom_Click()

   LOCAL nPos, nRatio

   nPos  := Form_1.Combo_3.Value
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
      SetEditFocus()
   ENDIF

   RETURN NIL

FUNCTION GetZoom_Click()

   LOCAL aZoom, n

   aZoom :=GetZoom( hEd )
   FOR n:= 1 to len(aNumZoom)
      IF aZoom[1] == aNumZoom[ n, 1] .and. aZoom[2] == aNumZoom[ n, 2]
         Form_1.Combo_3.Value := n
         EXIT
      ENDIF
   NEXT

   RETURN NIL

FUNCTION GetCurWin(form)

   LOCAL hwnd,aRec:={0,0,0,0}

   hwnd := GetFormHandle(form)
   GetWindowRect(hwnd,aRec)

   RETURN aRec[1]+4

FUNCTION PageSetupRTF_Click()

   LOCAL hwnd, aPage

   hwnd := GetFormHandle('Form_1')

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

#pragma BEGINDUMP

#define _WIN32_IE      0x0500
#define _WIN32_WINNT   0x0400
#include <shlobj.h>

#include <windows.h>
#include <commctrl.h>
#include <richedit.h>
#include "hbapi.h"
#include "hbvm.h"
#include "hbstack.h"
#include "hbapiitm.h"
#include "winreg.h"
#include "tchar.h"
#include "Winuser.h"
#include <wingdi.h>
#include <setupapi.h>

static HGLOBAL cbuffer;
static int ilefontow;
static int aktfont;

#pragma argsused
int CALLBACK effxp(ENUMLOGFONTEX *lpelfe, NEWTEXTMETRICEX *lpntme, int FontType, LPARAM lParam)
{
    if ((LONG)lParam==1)
    {
        ilefontow++;
    }
    else
    {
        strcat(cbuffer,(LPSTR) lpelfe->elfLogFont.lfFaceName);
        if (++aktfont<ilefontow)
            strcat(cbuffer,",");
    }

    return 1;
}

HB_FUNC( RR_GETFONTS )
{
   LOGFONT lf;
   HDC hDC = GetDC(NULL);

   lf.lfCharSet=ANSI_CHARSET;
   lf.lfPitchAndFamily=0;
   strcpy(lf.lfFaceName,"\0");
   ilefontow=0;

   EnumFontFamiliesEx(hDC,&lf,(FONTENUMPROC)effxp,1,0);
   cbuffer = ( char * ) GlobalAlloc(GPTR, ilefontow*127);
   aktfont=0;

   EnumFontFamiliesEx(hDC,&lf,(FONTENUMPROC)effxp,0,0);
   DeleteDC(hDC);
   hb_retc(cbuffer);
   GlobalFree(cbuffer);
}

HB_FUNC ( REBARHEIGHT )
{
   LRESULT lResult ;
   lResult =  SendMessage( (HWND) hb_parnl (1),(UINT) RB_GETBARHEIGHT, 0, 0 );
   hb_retnl( (UINT)lResult );
}

HB_FUNC ( GETDEVCAPS ) // GetDevCaps ( hwnd )
{
   INT      ix;
   HDC      hdc;
   HWND     hwnd;

   hwnd = (HWND) hb_parnl(1);

   hdc  = GetDC( hwnd );

   ix   = GetDeviceCaps( hdc, LOGPIXELSX );

   ReleaseDC( hwnd, hdc );

   hb_retni( (UINT) ix );
}

HB_FUNC ( MENUITEM_SETBITMAPS )
{

   HWND himage1;
   HWND himage2;

   himage1 = (HWND) LoadImage( GetModuleHandle(NULL), hb_parc(3), IMAGE_BITMAP, 13, 13, LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );
   if ( himage1 == NULL )
   {
      himage1 = (HWND) LoadImage( 0, hb_parc(3), IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE | LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );
   }

   himage2 = (HWND) LoadImage( GetModuleHandle(NULL), hb_parc(4), IMAGE_BITMAP, 13, 13, LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );
   if ( himage2 == NULL )
   {
      himage2 = (HWND) LoadImage( 0, hb_parc(4), IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE | LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );
   }

   SetMenuItemBitmaps( (HMENU) hb_parnl(1) , hb_parni(2), MF_BYCOMMAND , (HBITMAP) himage1 , (HBITMAP) himage2 ) ;

}

#pragma ENDDUMP

#include "l_richeditbox.prg"
