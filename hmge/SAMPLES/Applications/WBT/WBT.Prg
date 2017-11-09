** WBT - Web Button Tool
** A program to make a simple web buttons
** (r) Roberto Sanchez <jrsancheze@gmail.com>
** Honduras, Central America
#include <minigui.ch>

#define True                         .T.
#define False                        .F.

#define nInitColumn                  5
#define nInitRow                     5
#define nInitWidth                   110
#define nInitHeight                  35
#define cInitCaption1                "Sample"
#define cInitCaption2                ""
#define cInitCaption3                ""
#define cInitCaption4                ""
#define cInitFontName                "MS Sans serif"
#define nInitFontSize                9
#define lInitBold                    .F.
#define lInitItalic                  .F.
#define lInitUnderline               .F.
#define lInitStrikeOut               .F.
#define aInitColor                   {0,0,0}
#define lInitVertical                .F.
#define lInitLeftText                .F.
#define lInitUpperText               .F.
#define lInitAdjust                  .F.
#define cInitIcon                    Nil
#define aInitBackColor               {255,255,255}
#define lInitFlat                    .F.
#define lInitNoTransparent           .F.
#define lInitNoHotLight              .F.
#define lInitNoXPStyle               .F.

#define SampleColumnPosition         1
#define SampleRowPosition            2
#define SampleWidthPosition          3
#define SampleHeightPosition         4
#define SampleCaptionPosition1       5
#define SampleCaptionPosition2       6
#define SampleCaptionPosition3       7
#define SampleCaptionPosition4       8
#define SampleFontNamePosition       9
#define SampleFontSizePosition       10
#define SampleBoldPosition           11
#define SampleItalicPosition         12
#define SampleUnderlinePosition      13
#define SampleStrikeOutPosition      14
#define SampleColorPosition          15
#define SampleVerticalPosition       16
#define SampleLeftTextPosition       17
#define SampleUpperTextPosition      18
#define SampleAdjustPosition         19
#define SampleIconPosition           20
#define SampleBackColorPosition      21
#define SampleFlatPosition           22
#define SampleNoTransparentPosition  23
#define SampleNoHotLightPosition     24
#define SampleNoXPStylePosition      25

#define nInitCharSet                 0

#define FontNamePosition             1
#define FontSizePosition             2
#define FontBoldPosition             3
#define FontItalicPosition           4
#define FontColorPosition            5
#define FontUnderlinePosition        6
#define FontStrikeOutPosition        7
#define FontCharsetPosition          8

#define IconFolderPosition           1
#define SaveFolderPosition           2

MEMVAR aBackColor
MEMVAR cImageType
MEMVAR aFont
MEMVAR aSampleButton
MEMVAR aFolders

** Main Function

PROCEDURE Main()

   PUBLIC aBackColor    := aInitBackColor
   PUBLIC cImageType    := "ICO"
   PUBLIC aFont         := Array(8)
   PUBLIC aSampleButton := Array(25)
   PUBLIC aFolders      := {"C:\",GetMyDocumentsFolder()}

   fInitPublicArrays()
   SET Navigation Extended
   SET Language To English
   SET MULTIPLE OFF

   LOAD WINDOW Form_Wbt
   LOAD WINDOW Form_SampleButton
   fChildLocation()
   fCreateSampleButton()
   ACTIVATE WINDOW Form_SampleButton, Form_Wbt

   RETURN

   ** Function to Init public arrays

PROCEDURE fInitPublicArrays()

   aFont[FontNamePosition]                   := cInitFontName
   aFont[FontSizePosition]                   := nInitFontSize
   aFont[FontBoldPosition]                   := lInitBold
   aFont[FontItalicPosition]                 := lInitItalic
   aFont[FontColorPosition]                  := aInitColor
   aFont[FontUnderlinePosition]              := lInitUnderline
   aFont[FontStrikeOutPosition]              := lInitStrikeOut
   aFont[FontCharsetPosition]                := nInitCharSet

   aSampleButton[SampleColumnPosition]       := nInitColumn
   aSampleButton[SampleRowPosition]          := nInitRow
   aSampleButton[SampleWidthPosition]        := nInitWidth
   aSampleButton[SampleHeightPosition]       := nInitHeight
   aSampleButton[SampleCaptionPosition1]     := cInitCaption1
   aSampleButton[SampleCaptionPosition2]     := cInitCaption2
   aSampleButton[SampleCaptionPosition3]     := cInitCaption3
   aSampleButton[SampleCaptionPosition4]     := cInitCaption4
   aSampleButton[SampleFontNamePosition]     := cInitFontName
   aSampleButton[SampleFontSizePosition]     := nInitFontSize
   aSampleButton[SampleBoldPosition]         := lInitBold
   aSampleButton[SampleItalicPosition]       := lInitItalic
   aSampleButton[SampleUnderlinePosition]    := lInitUnderline
   aSampleButton[SampleStrikeOutPosition]    := lInitStrikeOut
   aSampleButton[SampleColorPosition]        := aInitColor
   aSampleButton[SampleVerticalPosition]     := lInitVertical
   aSampleButton[SampleLeftTextPosition]     := lInitLeftText
   aSampleButton[SampleUpperTextPosition]    := lInitUpperText
   aSampleButton[SampleAdjustPosition]       := lInitAdjust
   aSampleButton[SampleIconPosition]         := cInitIcon
   aSampleButton[SampleBackColorPosition]    := aInitBackColor
   aSampleButton[SampleFlatPosition]         := lInitFlat
   aSampleButton[SampleNoTransparentPosition]:= lInitNoTransparent
   aSampleButton[SampleNoHotLightPosition]   := lInitNoHotLight
   aSampleButton[SampleNoXPStylePosition]    := lInitNoXPStyle

   RETURN

   ** Function to update public arrays

PROCEDURE fUpdateSampleArrays()

   ** Sample Button Array
   aSampleButton[SampleColumnPosition]       := nInitColumn
   aSampleButton[SampleRowPosition]          := nInitRow
   aSampleButton[SampleWidthPosition]        := Form_Wbt.Spinner_Width.Value
   aSampleButton[SampleHeightPosition]       := Form_Wbt.Spinner_Height.Value
   aSampleButton[SampleCaptionPosition1]     := Form_Wbt.TXB_Caption1.Value
   aSampleButton[SampleCaptionPosition2]     := Form_Wbt.TXB_Caption2.Value
   aSampleButton[SampleCaptionPosition3]     := Form_Wbt.TXB_Caption3.Value
   aSampleButton[SampleCaptionPosition4]     := Form_Wbt.TXB_Caption4.Value
   aSampleButton[SampleFontNamePosition]     := aFont[FontNamePosition]
   aSampleButton[SampleFontSizePosition]     := aFont[FontSizePosition]
   aSampleButton[SampleBoldPosition]         := aFont[FontBoldPosition]
   aSampleButton[SampleItalicPosition]       := aFont[FontItalicPosition]
   aSampleButton[SampleUnderlinePosition]    := aFont[FontUnderlinePosition]
   aSampleButton[SampleStrikeOutPosition]    := aFont[FontStrikeOutPosition]
   aSampleButton[SampleColorPosition]        := aFont[FontColorPosition]
   aSampleButton[SampleVerticalPosition]     := Form_Wbt.Check_Vertical.Value
   aSampleButton[SampleLeftTextPosition]     := Form_Wbt.Check_LeftText.Value
   aSampleButton[SampleUpperTextPosition]    := Form_Wbt.Check_UpperText.Value
   aSampleButton[SampleAdjustPosition]       := Form_Wbt.Check_Adjust.Value
   aSampleButton[SampleIconPosition]         := Form_Wbt.TXB_IconFile.Value
   aSampleButton[SampleBackColorPosition]    := aBackColor
   aSampleButton[SampleFlatPosition]         := Form_Wbt.Check_Flat.Value
   aSampleButton[SampleNoTransparentPosition]:= Form_Wbt.Check_Transparent.Value
   aSampleButton[SampleNoHotLightPosition]   := Form_Wbt.Check_HotLight.Value
   aSampleButton[SampleNoXPStylePosition]    := Form_Wbt.Check_XPStyle.Value

   RETURN

   ** Function to update Form fields

PROCEDURE fUpdateFormFields()

   Form_Wbt.Setfocus
   Form_Wbt.Spinner_Width.Value      := aSampleButton[SampleWidthPosition]
   Form_Wbt.Spinner_Height.Value     := aSampleButton[SampleHeightPosition]
   Form_Wbt.TXB_IconFile.Value       := aSampleButton[SampleIconPosition]
   Form_Wbt.Check_Flat.Value         := aSampleButton[SampleFlatPosition]
   Form_Wbt.Check_Transparent.Value  := aSampleButton[SampleNoTransparentPosition]
   Form_Wbt.Check_HotLight.Value     := aSampleButton[SampleNoHotLightPosition]
   Form_Wbt.Check_XPStyle.Value      := aSampleButton[SampleNoXPStylePosition]
   Form_Wbt.Check_Adjust.Value       := aSampleButton[SampleAdjustPosition]

   Form_Wbt.TXB_Caption1.Value       := aSampleButton[SampleCaptionPosition1]
   Form_Wbt.TXB_Caption2.Value       := aSampleButton[SampleCaptionPosition2]
   Form_Wbt.TXB_Caption3.Value       := aSampleButton[SampleCaptionPosition3]
   Form_Wbt.TXB_Caption4.Value       := aSampleButton[SampleCaptionPosition4]
   Form_Wbt.TXB_FontValues.Value     := aFont[FontNamePosition]
   Form_Wbt.Check_Vertical.Value     := aSampleButton[SampleVerticalPosition]
   Form_Wbt.Check_LeftText.Value     := aSampleButton[SampleLeftTextPosition]
   Form_Wbt.Check_UpperText.Value    := aSampleButton[SampleUpperTextPosition]

   RETURN

   ** Function to exit application

PROCEDURE fExit()

   RELEASE WINDOW All

   RETURN

   ** Function to create Sample Button

PROCEDURE fCreateSampleButton()

   Form_SampleButton.Setfocus
   IF IsControlDefined(Button_Sample,Form_SampleButton)
      Form_SampleButton.Button_Sample.Release
   ENDIF

   fInitPublicArrays()

   DEFINE BUTTONEX Button_Sample
      PARENT        Form_SampleButton
      COL           aSampleButton[SampleColumnPosition]
      ROW           aSampleButton[SampleRowPosition]
      WIDTH         aSampleButton[SampleWidthPosition]
      HEIGHT        aSampleButton[SampleHeightPosition]
      CAPTION       aSampleButton[SampleCaptionPosition1]
      FONTNAME      aSampleButton[SampleFontNamePosition]
      FONTSIZE      aSampleButton[SampleFontSizePosition]
      FONTBOLD      aSampleButton[SampleBoldPosition]
      FONTITALIC    aSampleButton[SampleItalicPosition]
      FONTUNDERLINE aSampleButton[SampleUnderlinePosition]
      FONTSTRIKEOUT aSampleButton[SampleStrikeOutPosition]
      FONTCOLOR     aSampleButton[SampleColorPosition]
      VERTICAL      aSampleButton[SampleVerticalPosition]
      LEFTTEXT      aSampleButton[SampleLeftTextPosition]
      UPPERTEXT     aSampleButton[SampleUpperTextPosition]
      ADJUST        aSampleButton[SampleAdjustPosition]
      ICON          aSampleButton[SampleIconPosition]
      BACKCOLOR     aSampleButton[SampleBackColorPosition]
      FLAT          aSampleButton[SampleFlatPosition]
      NOTRANSPARENT aSampleButton[SampleNoTransparentPosition]
      NOHOTLIGHT    aSampleButton[SampleNoHotLightPosition]
      NOXPSTYLE     aSampleButton[SampleNoXPStylePosition]
   END BUTTONEX
   Form_Wbt.Setfocus
   fUpdateFormFields()

   RETURN

   ** Function to refresh screen

PROCEDURE fRefresh()

   LOCAL cSTRCaption:=""

   IF IsControlDefined(Button_Sample,Form_SampleButton)
      Form_SampleButton.Button_Sample.Release
   ENDIF

   fUpdateSampleArrays()
   Form_SampleButton.StatusBar.Visible:=False
   Form_SampleButton.Backcolor:={128,128,128}

   IF len(aSampleButton[SampleCaptionPosition1])>0
      cSTRCaption:=aSampleButton[SampleCaptionPosition1]
   ENDIF
   IF len(aSampleButton[SampleCaptionPosition2])>0
      cSTRCaption:=cSTRCaption+CRLF+aSampleButton[SampleCaptionPosition2]
   ENDIF
   IF len(aSampleButton[SampleCaptionPosition3])>0
      cSTRCaption:=cSTRCaption+CRLF+aSampleButton[SampleCaptionPosition3]
   ENDIF
   IF len(aSampleButton[SampleCaptionPosition4])>0
      cSTRCaption:=cSTRCaption+CRLF+aSampleButton[SampleCaptionPosition4]
   ENDIF

   IF cImageType="ICO"
      DEFINE BUTTONEX Button_Sample
         PARENT        Form_SampleButton
         COL           aSampleButton[SampleColumnPosition]
         ROW           aSampleButton[SampleRowPosition]
         WIDTH         aSampleButton[SampleWidthPosition]
         HEIGHT        aSampleButton[SampleHeightPosition]
         CAPTION       cSTRCaption
         FONTNAME      aSampleButton[SampleFontNamePosition]
         FONTSIZE      aSampleButton[SampleFontSizePosition]
         FONTBOLD      aSampleButton[SampleBoldPosition]
         FONTITALIC    aSampleButton[SampleItalicPosition]
         FONTUNDERLINE aSampleButton[SampleUnderlinePosition]
         FONTSTRIKEOUT aSampleButton[SampleStrikeOutPosition]
         FONTCOLOR     aSampleButton[SampleColorPosition]
         VERTICAL      aSampleButton[SampleVerticalPosition]
         LEFTTEXT      aSampleButton[SampleLeftTextPosition]
         UPPERTEXT     aSampleButton[SampleUpperTextPosition]
         ADJUST        aSampleButton[SampleAdjustPosition]
         ICON          aSampleButton[SampleIconPosition]
         BACKCOLOR     aSampleButton[SampleBackColorPosition]
         FLAT          aSampleButton[SampleFlatPosition]
         NOTRANSPARENT aSampleButton[SampleNoTransparentPosition]
         NOHOTLIGHT    aSampleButton[SampleNoHotLightPosition]
         NOXPSTYLE     aSampleButton[SampleNoXPStylePosition]
      END BUTTONEX
   ELSE
      DEFINE BUTTONEX Button_Sample
         PARENT        Form_SampleButton
         COL           aSampleButton[SampleColumnPosition]
         ROW           aSampleButton[SampleRowPosition]
         WIDTH         aSampleButton[SampleWidthPosition]
         HEIGHT        aSampleButton[SampleHeightPosition]
         CAPTION       cSTRCaption
         FONTNAME      aSampleButton[SampleFontNamePosition]
         FONTSIZE      aSampleButton[SampleFontSizePosition]
         FONTBOLD      aSampleButton[SampleBoldPosition]
         FONTITALIC    aSampleButton[SampleItalicPosition]
         FONTUNDERLINE aSampleButton[SampleUnderlinePosition]
         FONTSTRIKEOUT aSampleButton[SampleStrikeOutPosition]
         FONTCOLOR     aSampleButton[SampleColorPosition]
         VERTICAL      aSampleButton[SampleVerticalPosition]
         LEFTTEXT      aSampleButton[SampleLeftTextPosition]
         UPPERTEXT     aSampleButton[SampleUpperTextPosition]
         ADJUST        aSampleButton[SampleAdjustPosition]
         PICTURE       aSampleButton[SampleIconPosition]
         BACKCOLOR     aSampleButton[SampleBackColorPosition]
         FLAT          aSampleButton[SampleFlatPosition]
         NOTRANSPARENT aSampleButton[SampleNoTransparentPosition]
         NOHOTLIGHT    aSampleButton[SampleNoHotLightPosition]
         NOXPSTYLE     aSampleButton[SampleNoXPStylePosition]
      END BUTTONEX
   ENDIF

   Form_SampleButton.StatusBar.Visible:=True
   Form_Wbt.Spinner_Width.SetFocus

   RETURN

   ** Function to save Button

PROCEDURE fSave()

   LOCAL cFileName
   LOCAL acFilter      := {{"Bitmap","*.bmp"}}
   LOCAL cTitle        := "Save Button"
   LOCAL cIniFolder    := aFolders[SaveFolderPosition]
   LOCAL lNoChangeDir  := False
   LOCAL lSave         := True

   cFileName:=Upper(PutFile(acFilter, cTitle, cIniFolder, lNoChangeDir, "Button.BMP"))

   IF Empty(cFileName)
      MsgStop("Button image was not saved","Not saved")
   ELSE
      IF At(".",cFileName)=0
         cFileName:=cFileName+".BMP"
      ENDIF
      IF File(cFileName)
         PlayExclamation()
         IF MsgYesNo("File already exists. Do you want to replace with a new file?","File Exist")
            lSave:=True
         ELSE
            MsgStop("Button image was not saved","Not saved")
            lSave:=False
         ENDIF
      ENDIF
      IF lSave
         Form_SampleButton.Setfocus
         Form_SampleButton.Button_Sample.SaveAs(cFileName)
         MsgInfo("File was saved","Saved")
      ENDIF
      aFolders[SaveFolderPosition]:=GetCurrentFolder()
   ENDIF

   RETURN

   ** Function to select button icon

PROCEDURE fSelectIcon()

   LOCAL acFilter:={{"Windows icons (*.ico)","*.ico"},{"Windows bitmaps (*.bmp)","*.bmp"},{"All Pictures (*.ico;*.bmp)","*.ico;*.bmp"}}
   LOCAL cTitle:="Icon/Bitmap files"
   LOCAL cDefaultPath:=aFolders[IconFolderPosition]
   LOCAL lMultiSelect:=False
   LOCAL lNoChangeDir:=False

   aSampleButton[SampleIconPosition]:=GetFile(acFilter, cTitle, cDefaultPath, lMultiSelect, lNoChangeDir)
   Form_Wbt.TXB_IconFile.Value:=aSampleButton[SampleIconPosition]
   cImageType:=Upper(right(aSampleButton[SampleIconPosition],3))
   IF !Empty(aSampleButton[SampleIconPosition])
      aFolders[IconFolderPosition]:=GetCurrentFolder()
   ENDIF
   fRefresh()

   RETURN

   ** Function to select button back color

PROCEDURE fBackColor()

   LOCAL aBackColor_Old:=aBackColor

   aBackColor:=GetColor(aBackColor)

   IF Empty(aBackColor[1])
      aBackColor:= aBackColor_Old
   ELSEIF IsThemed()
      Form_Wbt.Check_XPStyle.Value:=True
   ENDIF
   fRefresh()

   RETURN

   ** Function to select font name

PROCEDURE fFontName()

   LOCAL aFont_Old          := Aclone(aFont)
   LOCAL cFontName_Old      := aFont[FontNamePosition]
   LOCAL nFontSize_Old      := aFont[FontSizePosition]
   LOCAL lFontBold_Old      := aFont[FontBoldPosition]
   LOCAL lFontItalic_Old    := aFont[FontItalicPosition]
   LOCAL aFontColor_Old     := aFont[FontColorPosition]
   LOCAL lFontUnderline_Old := aFont[FontUnderlinePosition]
   LOCAL lFontStrikeOut_Old := aFont[FontStrikeOutPosition]
   LOCAL nCharSet_Old       := aFont[FontCharsetPosition]

   aFont:= GetFont(cFontName_Old,nFontSize_Old,lFontBold_Old,lFontItalic_Old,aFontColor_Old,lFontUnderline_Old,lFontStrikeOut_Old,nCharSet_Old)

   IF !Empty(aFont[FontNamePosition])
      Form_Wbt.TXB_FontValues.Value   := aFont[FontNamePosition]
      fUpdateSampleArrays()
   ELSE
      Form_Wbt.TXB_FontValues.Value   := aFont_Old[FontNamePosition]
      Acopy(aFont_Old,aFont)
   ENDIF
   fRefresh()

   RETURN

   ** Function to put the location for the child form

PROCEDURE fChildLocation()

   LOCAL nColumn := Form_Wbt.Col
   LOCAL nRow    := Form_Wbt.Row
   LOCAL nHeight := Form_Wbt.Height

   Form_SampleButton.Col := nColumn
   Form_SampleButton.Row := nRow + nHeight + 1

   RETURN

   ** Function about

PROCEDURE fAbout()

   Load     Window Form_About
   Center   Window Form_About
   Form_About.Label_HBVersion.Value:=Version()
   Form_About.Label_MGVersion.Value:=MiniGuiVersion()
   ACTIVATE WINDOW Form_About

   RETURN

