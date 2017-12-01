/*
HMG InputWindow Demo
By Pablo César Arrascaeta
23rd, December 2014
*/

#include "hmg.ch"

DECLARE WINDOW _InputWindow

FUNCTION Main()

   LOCAL cSetLang:="EN"  // PL=Polish, PT=Portuguese, FR=French...

   SET NAVIGATION EXTENDED

   SET TOOLTIPSTYLE BALLOON
   InitMessages(cSetLang)

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH 740 HEIGHT 490 ;
         TITLE 'HMG InputWindow Demo' ;
         MAIN FONT 'Arial' SIZE 10 BACKCOLOR BLUE

      ON KEY ESCAPE ACTION ThisWindow.Release()

      @  50,25 BUTTON Button_1 CAPTION "InputWindow (Old version)"        WIDTH 200 ACTION Prepare_InputWindow(1)
      @  90,25 BUTTON Button_2 CAPTION "InputWindow (New version)"        WIDTH 200 ACTION Prepare_InputWindow(2)
   END WINDOW
   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

   RETURN NIL

FUNCTION Prepare_InputWindow(nOption)

   LOCAL cTitle, aLabels, aInitValues, aFormats, aToolTips, aHotKeys, nRow, nCol, aResults
   LOCAL nLabelWidth, lLabelBold, xControlWidth, lControlBold, bCode, aBackColor

   LOCAL aGridValues:= {{"Line 1a","Line 1b","Line 1c"},{"Line 2a","Line 2b","Line 2c"},{"Line 3a","Line 3b","Line 3c"}}
   LOCAL aGridHeaders:={"Header 1","Header 2","Header 3"}
   LOCAL aGridWidths:={80,80,80}

   PUBLIC nEventIdx                                                           // In case is need to CREATE EVENT

   cTitle      := 'InputWindow Test '+If(nOption=1,"(Old version)","(New version)")
   aLabels     := { 'Field 1 (TextBox for text)', 'Field 2 (CheckBox):', 'Field 3 (ComboBox)', ;
      'Field 4 (DatePicker)', 'Field 5 (Numeric masked TextBox)', ;
      'Field 6 (Numeric TextBox for integers)', 'Field 7 (EditBox)', ;
      'Field 8 (Grid)', 'Field 9 (PassWord)', HMG_PadC(' Field 10 (Label) ',35,"─") }
   aInitValues := { 'Init Text', .T., 0, Date(), 12.34, 0, 'Memo text', aGridValues, ;
      "", HMG_PadC(' Label as Control ',38,"─") }
   aFormats    := { 20, Nil, {'Option 1','Option 2'}, Nil, '99.99', 10, 50, {aGridHeaders, aGridWidths}, "PASSWORD", Nil }
   /*                         +------------------+----------------------+
   |   aInitValues    |      aFormats        |
   +-------------------------+------------------+----------------------+
   | Label                   |       ""         | Nil                  |
   | TextBox "C"             |       ""         | <= 32                |
   | TextBox "C" (PassWord)  |       ""         | "PASSWORD"           |
   | TextBox "N" (New)       |       9          | 9                    |
   | TextBox "N"(INPUTMASK)  |       9          | Ex: "99.99"          |
   | ComboBox                |       9          | {}                   |
   | CheckBox                |    .T. or .F.    |                      |
   | DatePicker              | CtoD() or Date() |                      |
   | EditBox                 |       ""         | > 32                 |
   | EditBox                 |  Dbf Memo field  |                      |
   | Grid                    |       {{}}       | {{headers},{Widths}} |
   +-------------------------+------------------+----------------------+ */

   /* From hereunder, it's with new features. */

   nRow           := (Form_1.Row)+(Form_1.Button_2.Row)+35                    // Optional
   nCol           := 0                                                        // Optional. Force to Center horizontally
   aBackColor     := {212,208,200}                                            // Optional
   aToolTips   := { "ToolTips 1","ToolTips 2","ToolTips 3", ;                 // Optional
      "ToolTips 4","ToolTips 5","ToolTips 6", ;
      "ToolTips 7", "ToolTips 8","ToolTips 9" }
   aHotKeys       := { { 0, VK_ESCAPE, {|| ThisWindow.Release() } }, ;        // Optional
      { 0, VK_UP, {|| InsertShiftTab() } }, ;
      { 0, VK_DOWN, {|| InsertTab() } } }

   /*         This must obey the same settings and sequences that are
   described in i_keybd.ch. For example ALT+A must be like this:
   { { MOD_ALT, VK_A, <{|| action } > } }
   Others codeblocks can be added, having many HotKeys             */

   nLabelWidth    := 260                                              // Optional. Forcing width sizes
   aLabelFColor   := {0,0,200}                                        // Optional
   lLabelBold     := .T.                                              // Optional
   nAlign         := 1                                                // Optional ( Left/Normal:=0 | Right:=1 | Center:=2 )

   IF nOption = 2
      xControlWidth  := {150,260,80,90,105,80,260,260,120,260}        // Optional
   ELSE
      xControlWidth  := 250                                           // Optional
   ENDIF
   /* Forcing width sizes. xControlWidth can be a fixed value of a
   variable or an array containing each width size of each control */

   lControlBold   := .T.                                              // Optional

   aStyles        := {{nLabelWidth,lLabelBold,aLabelFColor,nAlign},;  // Need to be declared Bidimensional {{},{}}
      {xControlWidth,lControlBold}}

   bCode          := {|| My_UDF()}                                    // Optional. Good to insert UDFs

   DO CASE
   CASE nOption=1
      aResults := InputWindow ( cTitle, aLabels, aInitValues, aFormats )
   CASE nOption=2
      aResults := InputWindow ( cTitle, aLabels, aInitValues, aFormats, nRow, nCol, aBackColor, aToolTips, aHotKeys, aStyles, bCode )
   ENDCASE

   IF aResults [1] == Nil
      MsgInfo ('Cancelled','InputWindow')
   ELSE
      My_MsgDebug(aLabels,aResults)
   ENDIF

   RETURN NIL

FUNCTION My_UDF()

   LOCAL i, imax:=CountLabels()

   // Set some properties manually (It's just an example)
   SetProperty('_InputWindow','Label_1','BackColor',GRAY)
   SetProperty('_InputWindow','Label_3','FontColor',GREEN)
   SetProperty('_InputWindow','Label_4','FontSize',12)
   SetProperty('_InputWindow','Label_2','FontItalic',.t.)
   SetProperty('_InputWindow','Control_7','BackColor',YELLOW)
   SetProperty('_InputWindow','Control_8','BackColor',{102,102,255})
   SetProperty('_InputWindow','Control_5','ReadOnly',.t.)

   SetProperty('_InputWindow','Control_9','PassWord',.t.)  // ??
   DoMethod('_InputWindow','Control_9','SetFocus')
   SetProperty('_InputWindow','Control_10','FontColor',RED)

   FOR i=1 To 3 // 3 Columns
      SetProperty( "_InputWindow","Control_8","HeaderDYNAMICFONT",i, {|| {"Verdana", 9, .T.} } )
      SetProperty( "_InputWindow","Control_8","ColumnDYNAMICFONT",i, {|| {"Courier New", 9, .T.} } )
      SetProperty( "_InputWindow","Control_8","HeaderDYNAMICFORECOLOR",i, {|| BLUE } )
      SetProperty( "_InputWindow","Control_8","HeaderDYNAMICBACKCOLOR",i, {|| {212,208,200} } )
      SetProperty( "_InputWindow","Control_8","ColumnDYNAMICBACKCOLOR",i, {|| {153,153,255} } )
   NEXT

   // Set for all fields at LostFocus + Enter + GotFocus (how we can do validations)
   FOR i:=1 to imax
      IF _IsControlDefined('Control_'+hb_ValToExp(i),'_InputWindow')
         SetMethodCode('_InputWindow','Control_'+hb_ValToExp(i),'LOSTFOCUS',{||xIfEmpty()})
         SetMethodCode('_InputWindow','Control_'+hb_ValToExp(i),'ENTER',{||InsertTab()})
         SetMethodCode('_InputWindow','Control_'+hb_ValToExp(i),'GOTFOCUS',{||SetFocusColor()})
      ENDIF
   NEXT

   RETURN NIL

STATIC FUNCTION CountLabels()

   LOCAL nIdx:=1

   DO WHILE _IsControlDefined('Label_'+hb_ValToExp(nIdx),'_InputWindow')
      nIdx++
   ENDDO
   nRet:=nIdx-1

   RETURN nRet

STATIC FUNCTION xIfEmpty()

   LOCAL aCheckBackColor, cMsg, nOpt
   LOCAL cControlName := This.Name
   LOCAL xValue := This.Value
   LOCAL cControlType:=GetControlType(cControlName,'_InputWindow')

   IF Empty(xValue)
      StopControlEventProcedure(cControlName, '_InputWindow', .T.)
      IF cControlType="COMBO"
         cMsg:="You need to choose an option !"
      ELSEIF cControlType="CHECKBOX"
         cMsg:="Option cannot be validated !"
         aCheckBackColor:=GetProperty("_InputWindow",cControlName,"BackColor")
      ELSE
         IF ValType(xValue)="N"
            cMsg:="Value must be greater than zero !"
         ELSE
            cMsg:="Value is required and can't be empty !"
         ENDIF
      ENDIF
      SetProperty('_InputWindow', cControlName, 'BackColor', RED)
      PlayBeep()
      nTypeButton = MB_ICONHAND + MB_RETRYCANCEL   // (i_MsgBox.ch)
      nOpt:=MessageBoxTimeout(cMsg, "Attention: Re-edit this field", nTypeButton, 3000)
      IF cControlType="CHECKBOX"
         SetProperty('_InputWindow', cControlName, 'BackColor', aCheckBackColor)
         SetProperty('_InputWindow', cControlName, 'Value', .T.)
      ELSE
         SetProperty('_InputWindow', cControlName, 'BackColor', WHITE)
      ENDIF
      IF nOpt == 2 //IDCANCEL   // (i_MsgBox.ch)
         IF (cControlType="TEXT" .or. cControlType="EDIT")
            DoMethod('_InputWindow', cControlName, 'SetFocus')
            InsertControlZ()                                        // UnDo Texts
         ENDIF
      ELSE
         DoMethod('_InputWindow', cControlName, 'SetFocus')
      ENDIF
      StopControlEventProcedure(cControlName, '_InputWindow', .F.)
   ENDIF

   RETURN NIL

FUNCTION SetFocusColor()

   LOCAL imax:=CountLabels()
   LOCAL i, cThisLabel

   FOR i=1 To imax
      SetProperty("_InputWindow",'Label_'+hb_ValToExp(i),"FontColor",{0,0,200})
      IF This.Name='Control_'+hb_ValToExp(i)
         cThisLabel:='Label_'+hb_ValToExp(i)
      ENDIF
   NEXT
   SetProperty("_InputWindow",cThisLabel,"FontColor",RED)

   RETURN NIL

STATIC FUNCTION SetMethodCode( cForm, cControl, cMethod, bCode )

   LOCAL nIndex:=GetControlIndex( cControl, cForm )
   LOCAL cControlType:=GetControlTypeByIndex (nIndex)

   DO CASE
   CASE nIndex=0
   CASE cControlType = "COMBO"
      DO CASE
      CASE cMethod='DISPLAYCHANGE'
         _HMG_SYSDATA [  6 ][nIndex] :=  bCode
      CASE cMethod='LISTDISPLAY'
         // _HMG_aControlInputMask [nIndex] := bCode
      CASE cMethod='LOSTFOCUS'
         _HMG_SYSDATA [ 10 ][nIndex] :=  bCode
      CASE cMethod='GOTFOCUS'
         _HMG_SYSDATA [ 11 ][nIndex] :=  bCode
      CASE cMethod='CHANGE'
         _HMG_SYSDATA [ 12 ][nIndex] :=  bCode
      CASE cMethod='ENTER'
         _HMG_SYSDATA [ 16 ][nIndex] :=  bCode
      CASE cMethod='LISTCLOSE'
         // _HMG_aControlPicture[nIndex] :=  bCode
      ENDCASE
   CASE cControlType = "TEXT" .or. cControlType = "NUMTEXT" .or. cControlType = "MASKEDTEXT"
      DO CASE
      CASE cMethod='LOSTFOCUS'
         _HMG_SYSDATA [ 10 ][nIndex] :=  bCode
         SetProperty(cForm, cControl, cMethod, bCode)
      CASE cMethod='GOTFOCUS'
         _HMG_SYSDATA [ 11 ][nIndex] :=  bCode
      CASE cMethod='CHANGE'
         _HMG_SYSDATA [ 12 ][nIndex] :=  bCode
      CASE cMethod='ENTER'
         _HMG_SYSDATA [ 16 ][nIndex] :=  bCode
      ENDCASE
   CASE cControlType = "EDIT"
      DO CASE
      CASE cMethod='LOSTFOCUS'
         _HMG_SYSDATA [ 10 ][nIndex] :=  bCode
      CASE cMethod='GOTFOCUS'
         _HMG_SYSDATA [ 11 ][nIndex] :=  bCode
      CASE cMethod='CHANGE'
         _HMG_SYSDATA [ 12 ][nIndex] :=  bCode
      ENDCASE
   CASE cControlType = "DATEPICK"
      DO CASE
      CASE cMethod='LOSTFOCUS'
         _HMG_SYSDATA [ 10 ][nIndex] :=  bCode
      CASE cMethod='GOTFOCUS'
         _HMG_SYSDATA [ 11 ][nIndex] :=  bCode
      CASE cMethod='CHANGE'
         _HMG_SYSDATA [ 12 ][nIndex] :=  bCode
      CASE cMethod='ENTER'
         _HMG_SYSDATA [ 6 ][nIndex] :=  bCode
      ENDCASE
   CASE cControlType = "CHECKBOX"
      DO CASE
      CASE cMethod='LOSTFOCUS'
         _HMG_SYSDATA [ 10 ][nIndex] :=  bCode
      CASE cMethod='GOTFOCUS'
         _HMG_SYSDATA [ 11 ][nIndex] :=  bCode
      CASE cMethod='CHANGE'
         _HMG_SYSDATA [ 12 ][nIndex] :=  bCode
      CASE cMethod='ENTER'
         _HMG_SYSDATA [ 6 ][nIndex] := bCode
      ENDCASE
   CASE cControlType = "GRID"
      DO CASE
      CASE cMethod='LOSTFOCUS'
         _HMG_SYSDATA [ 10 ][nIndex] :=  bCode
      CASE cMethod='GOTFOCUS'
         _HMG_SYSDATA [ 11 ][nIndex] :=  bCode
      CASE cMethod='CHANGE'
         _HMG_SYSDATA [ 12 ][nIndex] :=  bCode
      CASE cMethod='ENTER'
         _HMG_SYSDATA [ 16 ][nIndex] := .T.
      ENDCASE
   ENDCASE
   DO Events

   RETURN NIL

FUNCTION ResetAllKeys(aHotKeys)

   IF ValType(aHotKeys)='A'
      FOR i := 1 to HMG_Len ( aHotKeys )
         _ReleaseHotKey ( "_InputWindow" , aHotKeys[i,1] , aHotKeys[i,2] )
      NEXT
   ENDIF

   RETURN NIL

FUNCTION OnExit( aHotKeys )

   IF ValType(nEventIdx)="N"
      EventRemove ( nEventIdx )
   ENDIF
   ResetAllKeys( aHotKeys )

   RETURN .T.

FUNCTION My_MsgDebug(aLbls,aCtrls)

   LOCAL i, aMsg

   SET DATE FORMAT TO "dd/mm/yyyy"

   aMsg := {}
   FOR i = 1 To Len(aLbls)
      Aadd(aMsg,{AllTrim(Str(i))+". " ,aLbls[i],If(ValType(aCtrls[i])="D",DtoC(aCtrls[i]),hb_ValToExp(aCtrls[i]))})
   NEXT

   DEFINE WINDOW _MsgDebug AT 132 , 235 WIDTH 640 HEIGHT 350 ;
         TITLE "InputWindow results" MODAL

      ON KEY ESCAPE ACTION ThisWindow.Release()

      DEFINE GRID Grid_1
         ROW    20
         COL    10
         WIDTH  605
         HEIGHT 290
         ITEMS aMsg
         VALUE 1
         WIDTHS { 30, 280, 390 }
         HEADERS {''}
         FONTNAME "Arial"
         FONTSIZE 9
         SHOWHEADERS .F.
         CELLNAVIGATION .F.
         NOLINES .T.
      END GRID

   END WINDOW
   CENTER WINDOW _MsgDebug
   ACTIVATE WINDOW _MsgDebug

   RETURN NIL
