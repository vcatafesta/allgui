/*
Characters Guessing Game (Brainstorming)

Multi-Language supported, Simply add a new file named 'Lang-???.ini' for your language.

(c) Bootwan  July 11, 2010.
E-mail: bootwan@yahoo.com.tw
*/

#include "minigui.ch"

STATIC cLngCode := "Eng"
STATIC cIniFile := ""
STATIC cLngFile := ""
STATIC cPattern := "0123456789"
STATIC nLength  := 4
STATIC cAnswer  := ""
STATIC nStartSecs := 0

PROCEDURE Main

   LOCAL cForm, cGrid, cTitle, nLeft, nTop, nCol
   LOCAL cExeFile, cFilePath, cFileBase
   LOCAL cFontName, nFontSize, cValue
   LOCAL cSection, cType, aHeaders, nWidth, n
   LOCAL ni, aLanguages, cControl, cLngName

   cExeFile  := Application.ExeName
   cFilePath := FilePath(cExeFile)
   cFileBase := FileBase(cExeFile)
   cIniFile  := cFilePath + "\" + cFileBase + ".ini"
   cSection  := "Application"
   cLngCode  := FetchIni(cSection, "Language", "Eng", cIniFile)
   cLngFile  := cFilePath + "\Lang-" + cLngCode + ".ini"

   cPattern  := FetchIni(cSection, "Pattern", cPattern, cIniFile)
   cPattern  := ExamineCharacters(cPattern)
   nLength   := FetchIni(cSection, "Length",  nLength, cIniFile)
   nLength   := IIF(nLength > LEN(cPattern) .or. nLength < 3, 4, nLength)

   cTitle    := FetchIni(cSection, "Title", "Characters Guessing Game", cLngFile)
   nTop      := FetchIni(cSection, "Top",  0, cIniFile)
   nLeft     := FetchIni(cSection, "Left", 0, cIniFile)
   cFontName := FetchIni(cSection, "FontName", "Fixedsys", cIniFile)
   nFontSize := FetchIni(cSection, "FontSize", 12, cIniFile)

   /* SET MENUSTYLE STANDARD  // EXTENDED */

   cForm    := "frmGuessing"
   cGrid    := "grdAttempts"
   DEFINE WINDOW &cForm AT nTop, nLeft WIDTH 300 HEIGHT 360 ;
         TITLE cTitle MAIN NOSIZE NOMAXIMIZE  ;
         ON RELEASE { || Form_Release(ThisWindow.Name) }

      ON KEY ESCAPE ACTION { || ThisWindow.Release() }

      cValue := "Game begins with your first guess"
      cValue := GetLngText("Application", "Guess", cValue, cLngFile, "Label")
      @ 10,10 LABEL lblGuess VALUE cValue AUTOSIZE
      @ 40,10 TEXTBOX tbxGuess VALUE "" WIDTH 160 UPPERCASE ;
         FONT cFontName SIZE nFontSize ;
         ON ENTER { || Validation(cForm, cGrid) }
      nCol := GetProperty(cForm, "Width") - GetBorderWidth() - 112
      @ 38,nCol BUTTON btnGuess CAPTION GetLngText("Application", "Guess", "&Guess", cLngFile, "Button") WIDTH 100 ;
         ACTION { || Validation(cForm, cGrid) }

      aHeaders := GetGridHeaders()
      nWidth   := GetProperty(cForm, "Width") - GetBorderWidth() * 2 - 20
      @ 70,10 GRID &cGrid WIDTH nWidth HEIGHT 200 ;
         FONT cFontName SIZE nFontSize ;
         HEADERS aHeaders ;
         WIDTHS { 120, 76, 66 } ;
         JUSTIFY { GRID_JTFY_LEFT, GRID_JTFY_LEFT, GRID_JTFY_RIGHT }

      cType    := "MenuItem"
      cSection := "Application"
      DEFINE MAIN MENU
         POPUP GetLngText(cSection, "Game", "&Game", cLngFile, cType) NAME mnuGame
            MENUITEM GetLngText(cSection, "GameNew", "&New Game", cLngFile, cType) NAME mnuGameNew ;
               ACTION { || Game_New(cForm, cGrid) }
            SEPARATOR
            MENUITEM GetLngText(cSection, "GameQuit", "&Quit", cLngFile, cType) NAME mnuGameQuit ;
               ACTION { || ThisWindow.Release() }
         END POPUP
         POPUP GetLngText(cSection, "Option", "&Option", cLngFile, cType) NAME mnuOption
            MENUITEM GetLngText(cSection, "OptSetting", "&Setting", cLngFile, cType) NAME mnuOptSetting ;
               ACTION { || Game_Setting() }
            POPUP GetLngText(cSection, "OptLanguage", "&Language", cLngFile, cType) NAME mnuOptLanguage
               aLanguages := GetLanguages()
               FOR ni = 1 to LEN(aLanguages)
                  cControl := "mnuLang_" + aLanguages[ni,1]
                  cLngName := aLanguages[ni,2]
                  MENUITEM cLngName NAME &cControl ACTION { || LanguageChanged(cForm, cGrid, This.Name) }
                  IF cLngCode == aLanguages[ni,1]
                     SetProperty(cForm, cControl, "Checked", .T.)
                  ENDIF
               NEXT ni
            END POPUP
         END POPUP
         POPUP GetLngText(cSection, "Help", "&Help", cLngFile, cType) NAME mnuHelp
            MENUITEM GetLngText(cSection, "HelpGuide", "&Guide", cLngFile, cType) NAME mnuHelpGuide ;
               ACTION { || Help_Guide() }
            MENUITEM GetLngText(cSection, "HelpAbout", "&About", cLngFile, cType) NAME mnuHelpAbout ;
               ACTION { || Help_About() }
         END POPUP
      END MENU

      @ 280, 10 LABEL lblWasted VALUE GetLngText(cSection, "Wasted", "Seconds wasted:", cLngFile, "Label") AUTOSIZE
      @ 280,190 LABEL lblSeconds VALUE "0.00" WIDTH 92 RIGHTALIGN

      DEFINE TIMER tmrWaste INTERVAL 100 ACTION { || n := (SECONDS() - nStartSecs),    ;
         SetProperty(cForm, "lblSeconds", "Value", LTRIM(Str(n)))    }

   END WINDOW

   Game_New(cForm, cGrid)
   IF nTop <= 0 .and. nLeft <= 0
      CENTER WINDOW &cForm
   ENDIF

   ACTIVATE WINDOW &cForm

   RETURN

STATIC FUNCTION Form_Release(cForm)

   LOCAL cSection

   SetProperty(cForm, "tmrWaste", "Enabled", .F.)
   cSection := "Application"
   WriteIni(cSection, "Top", GetProperty(cForm, "Row"), cIniFile)
   WriteIni(cSection, "Left", GetProperty(cForm, "Col"), cIniFile)
   WriteIni(cSection, "Language", cLngCode, cIniFile)

   RETURN NIL

STATIC FUNCTION Game_New (cForm, cGrid)

   cAnswer := GenerateNewAnswer()
   DoMethod(cForm, cGrid, "DeleteAllItems")
   SetProperty(cForm, "tmrWaste", "Enabled", .F.)
   SetProperty(cForm, "lblSeconds", "Value", "0.00")
   SetProperty(cForm, "tbxGuess", "Value", "")
   DoMethod(cForm, "tbxGuess", "SetFocus")

   RETURN NIL

STATIC PROCEDURE Game_Setting

   LOCAL cForm, cTitle, cSection

   cForm    := "frmSetting"
   cTitle   := GetLngText(cForm, "Title", "Game Setting", cLngFile)
   cSection := "Application"
   DEFINE WINDOW &cForm AT 0,0 WIDTH 290 HEIGHT 180 ;
         TITLE cTitle MODAL NOSIZE
      @ 10,10 LABEL lblPattern VALUE GetLngText(cForm, "Pattern", "Valid characters for guessing:", cLngFile, "Label") AUTOSIZE
      @ 30,10 TEXTBOX tbxPattern VALUE cPattern WIDTH 260 UPPERCASE
      @ 70,10 LABEL lblLength  VALUE GetLngText(cForm, "Length",  "Answer length:",  cLngFile, "Label") AUTOSIZE
      @ 70,200 TEXTBOX tbxLength VALUE LTRIM(Str(nLength)) WIDTH 70 RIGHTALIGN
      @ 110,40 BUTTON btnOk CAPTION GetLngText(cForm, "Ok", "&Ok", cLngFile, "Button") ;
         ACTION { || cPattern := ExamineCharacters(GetProperty(cForm, "tbxPattern", "Value")), ;
         WriteIni(cSection, "Pattern", cPattern, cIniFile), ;
         nLength := VAL(GetProperty(cForm, "tbxLength", "Value")), ;
         nLength := IIF(nLength < 3 .or. nLength > LEN(cPattern), 4, nLength), ;
         WriteIni(cSection, "Length", nLength, cIniFile), ;
         ThisWindow.Release() }
      @ 110, 150 BUTTON btnCancel CAPTION GetLngText(cForm, "Cancel", "&Cancel", cLngFile, "Button") ;
         ACTION { || ThisWindow.Release() }
   END WINDOW
   CENTER WINDOW &cForm
   ACTIVATE WINDOW &cForm

   RETURN

STATIC FUNCTION GenerateNewAnswer

   LOCAL cString, nPos, cValids

   cString := ""
   cValids := cPattern
   DO WHILE LEN(cString) < nLength .and. LEN(cValids) > 0
      nPos    := RANDOM(LEN(cValids))
      cString += Substr(cValids, nPos, 1)
      cValids := STUFF(cValids, nPos, 1, "")
   ENDDO

   RETURN(cString)

STATIC FUNCTION ExamineCharacters(cString)

   LOCAL cValids, ni, cChar

   cValids := ""
   cString := UPPER(cString)
   FOR ni = 1 to LEN(cString)
      cChar := Substr(cString, ni, 1)
      IF AT(cChar, cValids) == 0
         cValids += cChar
      ENDIF
   NEXT ni

   RETURN(cValids)

STATIC FUNCTION Validation(cForm, cGrid)

   LOCAL cValue, cChar, ni, na, nb, cResult, nCount, aValues
   LOCAL nWasteSecs := VAL(GetProperty(cForm, "lblSeconds", "Value"))
   LOCAL cPrompt, cTitle

   cValue := ExamineCharacters(GetProperty(cForm, "tbxGuess", "Value"))
   IF LEN(cValue) <> nLength
      cTitle  := GetLngText("GuessInput", "Title", "Error Input", cLngFile)
      cPrompt := "The answer length is %1 unique characters.\n"
      cPrompt += "Availables: %2\n"
      cPrompt := GetLngText("GuessInput", "Prompt", cPrompt, cLngFile)
      aValues := { LTRIM(Str(nLength)), cPattern }
      cPrompt := ReplaceValues(cPrompt, aValues)
      MsgExclamation(cPrompt, cTitle)
   ELSE
      na     := 0
      nb     := 0
      FOR ni = 1 to LEN(cValue)
         cChar := Substr(cValue, ni, 1)
         IF Substr(cAnswer, ni, 1) == cChar
            na += 1
         ELSEIF AT(cChar, cAnswer) > 0
            nb += 1
         ENDIF
      NEXT ni
      cResult := LTRIM(Str(na)) + "A" + LTRIM(Str(nb)) + "B"
      nCount  := GetProperty(cForm, cGrid, "ItemCount") + 1
      aValues := { cValue, cResult, LTRIM(Str(nCount)) }
      DoMethod(cForm, cGrid, "AddItem", aValues)
      SetProperty(cForm, cGrid, "Value", nCount)

      IF na == nLength
         SetProperty(cForm, "tmrWaste", "Enabled", .F.)
         cTitle  := GetLngText("Validation", "Title", "Congratulation", cLngFile)
         cPrompt := "The correct answer is %1\n%2 seconds wasted.\n"
         cPrompt += "Do you want to play again?"
         cPrompt := GetLngText("Validation", "Prompt", cPrompt, cLngFile)
         aValues := { cAnswer, LTRIM(Str(nWasteSecs)) }
         cPrompt := ReplaceValues(cPrompt, aValues)
         IF MsgYesNo(cPrompt, cTitle)
            Game_New(cForm, cGrid)
         ELSE
            DoMethod(cForm, "Release")
         ENDIF
      ELSE
         IF nCount == 1
            nStartSecs := SECONDS()
            SetProperty(cForm, "tmrWaste", "Enabled", .T.)
         ENDIF
         SetProperty(cForm, "tbxGuess", "Value", "")
         DoMethod(cForm, "tbxGuess", "SetFocus")
      ENDIF
   ENDIF

   RETURN NIL

STATIC PROCEDURE LanguageChanged(cForm, cGrid, cMenuItem)

   LOCAL cCode, cFilePath, cSection, h, c, i, ct, cn, cValue
   LOCAL aHeaders

   cCode := Substr(cMenuItem, 9)
   IF cCode <> cLngCode
      cLngCode  := cCode
      cFilePath := FilePath(EXENAME())
      cLngFile  := cFilePath + "\Lang-" + cLngCode + ".ini"

      cSection  := "Application"

      cValue := GetLngText(cSection, "Title", "", cLngFile)
      IF LEN(cValue) > 0
         SetProperty(cForm, "Title", cValue)
      ENDIF

      h := GetFormHandle(cForm)
      c := LEN( _HMG_aControlHandles )
      FOR i = 1 to c
         IF _HMG_aControlParentHandles[i] ==  h
            IF VALTYPE( _HMG_aControlHandles[i] ) == "N"
               ct := _HMG_aControlType[i]
               cn := _HMG_aControlNames[i]
               DO CASE
               CASE ct == "MENU" .or. ct == "POPUP"
                  IF UPPER(LEFT(cn,8)) == UPPER("mnuLang_")
                     SetProperty(cForm, cn, "Checked", (cn == cMenuItem))
                  ELSE
                     cValue := GetLngText(cSection, Substr(cn,4), "", cLngFile, "MenuItem")
                     IF LEN(cValue) > 0
                        /* For MiniGUI Extended and SET MENUSTYLE EXTENDED */
                        // _SetMenuItemCaption(cn, cForm, cValue)
                     ENDIF
                  ENDIF
               CASE ct == "LABEL"
                  cValue := GetLngText(cSection, Substr(cn,4), "", cLngFile, "Label")
                  IF LEN(cValue) > 0
                     SetProperty(cForm, cn, "Value", cValue)
                  ENDIF
               CASE ct == "BUTTON"
                  cValue := GetLngText(cSection, Substr(cn,4), "", cLngFile, "Button")
                  IF LEN(cValue) > 0
                     SetProperty(cForm, cn, "Caption", cValue)
                  ENDIF
               ENDCASE
            ENDIF
         ENDIF
      NEXT i

      aHeaders := GetGridHeaders()
      FOR i = 1 to LEN(aHeaders)
         SetProperty(cForm, cGrid, "Header", i, aHeaders[i])
      NEXT i
   ENDIF

   RETURN

STATIC FUNCTION GetLanguages()

   LOCAL aLanguages := {}, aFiles, ni, cLngCode, cLngName
   LOCAL cFilePath, cFileName, cFileBase

   cFilePath := FilePath(EXENAME())
   aFiles    := DIRECTORY(cFilePath + "\Lang-*.ini")
   FOR ni = 1 to LEN(aFiles)
      cFileName := aFiles[ni, 1]
      cFileBase := FileBase(cFileName)
      cLngCode  := Substr(cFileBase, 6)
      cLngName  := FetchIni("Language", "Name", cLngCode, cFilePath + "\" + cFileName)
      AADD(aLanguages, { cLngCode, cLngName } )
   NEXT ni
   ASORT(aLanguages,,, { | x, y | x[2] < y[2] })

   RETURN(aLanguages)

STATIC FUNCTION GetGridHeaders()

   LOCAL cType, cSection, aHeaders := {}

   cType    := "Column"
   cSection := "Application"
   AADD(aHeaders, GetLngText(cSection, "Guessed", "Guessed", cLngFile, cType))
   AADD(aHeaders, GetLngText(cSection, "Conform", "Conform", cLngFile, cType))
   AADD(aHeaders, GetLngText(cSection, "Tries",   "Tries",   cLngFile, cType))

   RETURN(aHeaders)

STATIC PROCEDURE Help_Guide()

   LOCAL cTitle, cPrompt

   cTitle  := GetLngText("HelpGuide", "Title", "Rules of game", cLngFile)
   cPrompt := GetSectionText("HelpGuide", "Prompt", cLngFile)
   IF LEN(cPrompt) = 0
      cPrompt := "You can set the characters allowed in Pattern (0-9 & A-Z), and the answer length." + HB_OSNewLine()
      cPrompt += "The answer is different combinations of characters of Pattern." + HB_OSNewLine()
      cPrompt += "A means the number of characters that locations are consistent with the answer." + HB_OSNewLine()
      cPrompt += "B means the number of characters that locations are incorrect with the answer."
   ENDIF
   MsgInfo(cPrompt, cTitle)

   RETURN

STATIC PROCEDURE Help_About()

   LOCAL cTitle, cPrompt

   cTitle  := GetLngText("HelpAbout", "Title", "About this game", cLngFile)
   cPrompt := GetSectionText("HelpAbout", "Prompt", cLngFile)
   IF LEN(cPrompt) = 0
      cPrompt := "Author: bootwan" + HB_OSNewLine()
      cPrompt += "e-mail: bootwan@yahoo.com.tw"
   ENDIF
   MsgInfo(cPrompt, cTitle)

   RETURN

STATIC FUNCTION FilePath( cFile )

   LOCAL nPos, cFilePath

   cFilePath := ""
   IF ( nPos := RAT( "\", cFile )) <> 0
      cFilePath := LEFT( cFile, nPos - 1)
   ENDIF

   RETURN( cFilePath )

STATIC FUNCTION FileBase( cFile )

   LOCAL nPos, cFileBase

   IF (nPos := RAT("\", cFile)) > 0
      cFileBase := Substr(cFile, nPos + 1)
   ELSEIF (nPos := AT(":", cFile)) > 0
      cFileBase := Substr(cFile, nPos + 1)
   ELSE
      cFileBase := cFile
   ENDIF
   IF ( nPos := AT(".", cFileBase)) > 0
      cFileBase := Substr( cFileBase, 1, nPos - 1 )
   ENDIF

   RETURN( cFileBase )

STATIC FUNCTION GetLngText(cSection, cKey, cDefault, cFileName, cType)

   LOCAL cText, cValue, cKeyId

   cType  := IIF(cType == NIL, "", cType)
   cKeyId := cType + IIF(LEN(cType) > 0, ".", "") + cKey
   cValue := GetPrivateProfileString(cSection, cKeyId, "", cFileName)
   IF LEN(cValue) == 0
      IF LEN(cType) > 0
         cSection := "Common." + cType
         cValue   := GetPrivateProfileString(cSection, cKey, "", cFileName)
      ENDIF
   ENDIF
   cText := IIF(LEN(cValue) > 0, cValue, cDefault)

   RETURN(cText)

STATIC FUNCTION ReplaceValues(cString, aValues)

   LOCAL ni, nPos, cTag, aTags := {}

   ni := 0
   DO WHILE ni < LEN(aValues)
      ni   += 1
      cTag := "%" + LTRIM(Str(ni))
      nPos := AT(cTag, cString)
      IF nPos > 0
         cString := STUFF(cString, nPos, LEN(cTag), aValues[ni])
      ENDIF
   ENDDO
   AADD(aTags, { "\n", HB_OsNewLine() })
   AADD(aTags, { "\t", Chr(9) } )
   ni := 0
   DO WHILE ni < LEN(aTags)
      ni      += 1
      cString := STRTRAN(cString, aTags[ni,1], aTags[ni,2])
   ENDDO

   RETURN(cString)

STATIC FUNCTION FetchIni(cSection, cKey, uValue, cFileName)

   LOCAL cValue, vt

   vt     := VALTYPE(uValue)
   cValue := HB_VALTOSTR(uValue)
   cValue := GetPrivateProfileString(cSection, cKey, cValue, cFileName)
   DO CASE
   CASE vt == "N"
      uValue := VAL(cValue)
   CASE vt == "D"
      uValue := CTOD(uValue)
   OTHERWISE
      uValue := cValue
   ENDCASE

   RETURN(uValue)

STATIC PROCEDURE WriteIni(cSection, cKey, uValue, cFileName)

   LOCAL cValue, vt

   vt := VALTYPE(uValue)
   DO CASE
   CASE vt == "N"
      cValue := LTRIM(Str(uValue))
   CASE vt == "D"
      cValue := DTOC(uValue)
   OTHERWISE
      cValue := Chr(34) + uValue + Chr(34)
   ENDCASE
   WritePrivateProfileString(cSection, cKey, cValue, cFileName)

   RETURN

STATIC FUNCTION GetSectionText(cSection, cKey, cFileName)

   LOCAL cString, cBuffer, nPos, ni, nj, cVar, cValue, cResult

   cResult := ""
   cBuffer := _GetPrivateProfileSection(cSection, cFileName)
   nPos    := AT(Chr(0), cBuffer)
   DO WHILE nPos > 0 .and. LEN(cBuffer) > 0
      cString := LEFT(cBuffer, nPos - 1)
      ni      := AT("=", cString)
      IF ni > 0
         cVar := TRIM(LEFT(cString, ni - 1))
         IF UPPER(cVar) == UPPER(cKey)
            cValue := ALLTRIM(Substr(cString, ni + 1))
            IF LEFT(cValue, 1) == Chr(34)
               nj     := AT(Chr(34), Substr(cValue, 2))
               cValue := IIF(nj > 0, Substr(cValue, 2, nj - 1), cValue)
            ENDIF
            cResult += cValue + HB_OSNewLine()
         ENDIF
      ENDIF
      cBuffer := Substr(cBuffer, nPos + 1)
      nPos    := AT(Chr(0), cBuffer)
   ENDDO

   RETURN(cResult)
