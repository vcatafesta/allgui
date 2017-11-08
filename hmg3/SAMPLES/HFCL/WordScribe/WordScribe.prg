/**
 *
 * WordScribe
 *
 * Based on the Rich Edit demo.
 *
 * Copyright 2003-2009 by Janusz Pora <JanuszPora@onet.eu>
 *
 * Adapted and Enhanced for HMG by Dr. Claudio Soto, April 2014
 *
 * Enhanced for HMG by Kevin Carmody, April 2016
 *
*/

//***************************************************************************

#include "hmg.ch"
#include "hfcl.ch"

#define MIN_PARAINDENT   0 // in mm
#define MAX_PARAINDENT   150 // in mm
#define OFFSET_DLG       30

//***************************************************************************

MEMVAR _HMG_SYSDATA

STATIC cTitle           := 'WordScribe'
STATIC cVersion         := '2.2'
STATIC cCopyright       := 'Copyright © 2003–2009 Janusz Pora' // U+00A9 COPYRIGHT SIGN / U+2013 EN DASH
STATIC cByline2         := 'Enhanced by Dr. Claudio Soto, April 2014'
STATIC cByline3         := 'Enhanced by Kevin Carmody, April 2016'
STATIC cInfoAddr        := 'http://sites.google.com/site/hmgweb/'
STATIC cRegBase         := 'HKEY_CURRENT_USER\Software\WordScribe\'

STATIC nMainRow         := 0
STATIC nMainCol         := 0
STATIC nMainWidth       := 800
STATIC nMainHeight      := 600
STATIC lMainMax         := .N.

STATIC nShortRow        := 160
STATIC nShortCol        := 40
STATIC nShortWidth      := 635
STATIC nShortHeight     := 450
STATIC lShortMax        := .N.

STATIC aRecentBases     := {'', '', '', '', '', '', '', '', '', ''}
STATIC aRecentNames     := {'', '', '', '', '', '', '', '', '', ''}

STATIC cFind            := ''
STATIC cReplace         := ''
STATIC lDown            := .Y.
STATIC lMatchCase       := .N.
STATIC lWholeWord       := .N.

STATIC aZoomLabel       := {'500%','300%','200%','150%','100%','75%','50%','25%'}
STATIC nZoomValue       := 100

STATIC aFontList        := {}
STATIC cFontName        := 'Arial'

STATIC aFontSize        := {'8','9','10','11','12','14','16','18','20','22','24','26','28','36','48','72'}
STATIC nFontSize        := 12

STATIC aBackgroundColor := {255, 255, 255}
STATIC aFontColor       := {  0,   0,   0}
STATIC aFontBackColor   := {255, 255, 255}

STATIC aScriptLabel     := {'Normal', 'Subscript', 'Superscript'}
STATIC aScriptValue     := {RTF_NORMALSCRIPT, RTF_SUBSCRIPT, RTF_SUPERSCRIPT}
STATIC aAlignLabel      := {'Left', 'Center', 'Right', 'Justify'}
STATIC aAlignValue      := {RTF_LEFT, RTF_CENTER, RTF_RIGHT, RTF_JUSTIFY}
STATIC aSpaceLabel      := {'1.0', '1.5', '2.0', '2.5', '3.0'}
STATIC aSpaceValue      := { 1.0,   1.5,   2.0,   2.5,   3.0 }
STATIC aNumFormatLabel  := { ;
   'No bullets or numbering' , ; // RTF_NOBULLETNUMBER
   'Bullets'                 , ; // RTF_BULLET
   'Arabic numerals'         , ; // RTF_ARABICNUMBER
   'Lowercase letters'       , ; // RTF_LOWERCASELETTER
   'Lowercase Roman numerals', ; // RTF_UPPERCASELETTER
   'Uppercase letters'       , ; // RTF_LOWERCASEROMANNUMBER
   'Uppercase Roman numerals'  } // RTF_UPPERCASEROMANNUMBER
STATIC aNumStyleLabel  := { ;
   'Right parenthesis', ; // RTF_PAREN
   'Two parentheses'  , ; // RTF_PARENS
   'Period'           , ; // RTF_PERIOD
   'No punctuation'   , ; // RTF_PLAIN
   'Hidden number'      } // RTF_NONUMBER
  
STATIC cFileName        := ''
STATIC cFileFolder      := ''
STATIC cFileBase        := ''
STATIC cFileExt         := ''
STATIC lModified        := .N.
STATIC aReadFilter      := { ;
   {'Rich Text Format (*.rtf)', '*.rtf'}, ;
   {'Text Documents (*.txt)'  , '*.txt'}, ;
   {'All Documents (*.*)'     , '*.*'  }  }
STATIC nReadFilter      := 1
STATIC aWriteFilter     := { ;
   {'Rich Text Format (*.rtf)'                 , '*.rtf'}, ;
   {'ANSI Text Document (*.txt)'               , '*.txt'}, ;
   {'Unicode Text Document (*.txt)'            , '*.txt'}, ;
   {'Unicode Text Document, Big Endian (*.txt)', '*.txt'}, ;
   {'UTF-8 Text Document (*.txt)'              , '*.txt'}  }
STATIC nWriteFilter     := 1

//***************************************************************************

PROCEDURE Main(cInitFile)

   LOCAL aViewRect := {}
   LOCAL cDots     := '…' // U+2026 HORIZONTAL ELLIPSIS
   LOCAL cTab      := E"\t"

   DEFINE WINDOW wMain ;
      AT nMainRow, nMainCol ;
      WIDTH nMainWidth HEIGHT nMainHeight ;
      TITLE cTitle ;
      ICON 'MainIcon' ;
      ON INIT Refresh() ;
      ON SIZE MainSize(.N.) ;
      ON MAXIMIZE MainSize(.Y.) ;
      ON RELEASE MainExit(.N.) ;
      MAIN
  
      DEFINE STATUSBAR
         STATUSITEM ''          TOOLTIP 'Current file'
         STATUSITEM '' WIDTH 25 TOOLTIP 'Document modified'
         STATUSITEM '' WIDTH 40 TOOLTIP 'Caps lock on'
         STATUSITEM '' WIDTH 40 TOOLTIP 'Num lock on'
         STATUSITEM '' WIDTH 40 TOOLTIP 'Insert mode on'
         STATUSITEM '' WIDTH 25
      END STATUSBAR

      DEFINE TIMER tiStatus INTERVAL 200 ;
         ACTION {||
            wMain.STATUSBAR.ITEM(2) := IF(lModified         , '✽', '') // U+273D HEAVY TEARDROP-SPOKED ASTERISK
            wMain.STATUSBAR.ITEM(3) := IF(ISCAPSLOCKACTIVE(), 'CAP', '')
            wMain.STATUSBAR.ITEM(4) := IF(ISNUMLOCKACTIVE() , 'NUM', '')
            wMain.STATUSBAR.ITEM(5) := IF(ISINSERTACTIVE()  , 'INS', '')
            RETURN NIL
            }
  
      ON KEY CONTROL+N  ACTION NewFile()
      ON KEY CONTROL+O  ACTION OpenFile()
      ON KEY CONTROL+S  ACTION SaveFile()
      ON KEY CONTROL+P  ACTION Print()
      ON KEY CONTROL+B  ACTION Bold()
      ON KEY CONTROL+I  ACTION Italic()
      ON KEY CONTROL+U  ACTION Underline()
      ON KEY CONTROL+W  ACTION PasteUnformatted()
      ON KEY CONTROL+F  ACTION FindText()
      ON KEY CONTROL+H  ACTION ReplaceText()
      ON KEY F1         ACTION ShortCuts()

      DEFINE MAIN MENU 

         POPUP '&File'
            ITEM '&New'               + cTab + 'Ctrl+N'  ACTION NewFile()
            ITEM '&Open' + cDots      + cTab + 'Ctrl+O'  ACTION OpenFile()
            POPUP 'R&ecent' + cDots
               ITEM '&1. '  + aRecentBases[ 1] ACTION OpenFile(aRecentNames[ 1])
               ITEM '&2. '  + aRecentBases[ 2] ACTION OpenFile(aRecentNames[ 2])
               ITEM '&3. '  + aRecentBases[ 3] ACTION OpenFile(aRecentNames[ 3])
               ITEM '&4. '  + aRecentBases[ 4] ACTION OpenFile(aRecentNames[ 4])
               ITEM '&5. '  + aRecentBases[ 5] ACTION OpenFile(aRecentNames[ 5])
               ITEM '&6. '  + aRecentBases[ 6] ACTION OpenFile(aRecentNames[ 6])
               ITEM '&7. '  + aRecentBases[ 7] ACTION OpenFile(aRecentNames[ 7])
               ITEM '&8. '  + aRecentBases[ 8] ACTION OpenFile(aRecentNames[ 8])
               ITEM '&9. '  + aRecentBases[ 9] ACTION OpenFile(aRecentNames[ 9])
               ITEM '1&0. ' + aRecentBases[10] ACTION OpenFile(aRecentNames[10])
            END POPUP
            SEPARATOR
            ITEM '&Close'                                ACTION CloseFile()
            ITEM '&Save'              + cTab + 'Ctrl+S'  ACTION SaveFile()
            ITEM 'Save &as' + cDots                      ACTION SaveFileAs()
            SEPARATOR
            ITEM '&Print' + cDots     + cTab + 'Ctrl-P'  ACTION Print()
            ITEM 'Print pre&view'                        ACTION PrintPreview()
            SEPARATOR
            ITEM 'Associa&tions' + cDots                 ACTION Associations()
            SEPARATOR
            ITEM 'E&xit'                                 ACTION MainExit(.Y.)
         END POPUP

         POPUP '&Edit'
            ITEM '&Undo'              + cTab + 'Ctrl-Z'  ACTION Undo()
            ITEM '&Redo'              + cTab + 'Ctrl-Y'  ACTION Redo()
            ITEM 'C&lear undo buffer'                    ACTION ClearUndoBuffer()
            SEPARATOR
            ITEM '&Copy'              + cTab + 'Ctrl-C'  ACTION Copy()
            ITEM 'Cu&t'               + cTab + 'Ctrl-X'  ACTION Cut()
            ITEM '&Paste'             + cTab + 'Ctrl-V'  ACTION Paste()
            ITEM 'Pa&ste unformatted' + cTab + 'Ctrl-W'  ACTION PasteUnformatted()
            ITEM '&Delete'            + cTab + 'Delete'  ACTION Deleter()
            SEPARATOR
            ITEM 'Select &all'        + cTab + 'Ctrl-A'  ACTION SelectAll()
            SEPARATOR
            ITEM '&Find' + cDots      + cTab + 'Ctrl-F'  ACTION FindText()
            ITEM 'R&eplace' + cDots   + cTab + 'Ctrl-H'  ACTION ReplaceText()
         END POPUP

         POPUP 'F&ormat'
            ITEM '&Font' + cDots                         ACTION FontFormat()
            ITEM '&Text' + cDots                         ACTION TextFormat()
            ITEM '&Paragraph' + cDots                    ACTION ParagraphFormat()
         END POPUP

         POPUP '&View'
            ITEM '&Zoom' + cDots                         ACTION Zoom()
            ITEM 'Font &foreground color' + cDots        ACTION FontForeColor()
            ITEM 'Font &background color' + cDots        ACTION FontBackColor()
            ITEM '&Document background color' + cDots    ACTION BackgroundColor()
         END POPUP

         POPUP '&Help'
            ITEM '&Help topics'       + cTab + 'F1'      ACTION Shortcuts()
            SEPARATOR
            ITEM '&About'                                ACTION About()
         END POPUP

      END MENU

      DEFINE CONTEXT MENU  

         ITEM '&Copy'               ACTION Copy()
         ITEM 'C&ut'                ACTION Cut()
         ITEM '&Paste'              ACTION Paste()
         SEPARATOR
         ITEM 'Select &all'         ACTION SelectAll()
         SEPARATOR
         ITEM '&Find' + cDots       ACTION FindText()
         ITEM '&Replace' + cDots    ACTION ReplaceText()
         SEPARATOR
         ITEM 'F&ont' + cDots       ACTION FontFormat()
         ITEM 'Para&graph' + cDots  ACTION ParagraphFormat()

      END MENU

      DEFINE SPLITBOX

         DEFINE TOOLBAR tlFile BUTTONSIZE 23,23 FLAT

            BUTTON btNew ;
               TOOLTIP 'New file' ;
               PICTURE 'New' ;
               ACTION NewFile()

            BUTTON btOpen ;
               TOOLTIP 'Open file' ;
               PICTURE 'Open' ;
               ACTION OpenFile()

            BUTTON btClose ;
               TOOLTIP 'Close' ;
               PICTURE 'Close' ;
               ACTION CloseFile()

            BUTTON btSave ;
               TOOLTIP 'Save' ;
               PICTURE 'Save' ; 
               ACTION SaveFile() ;
               SEPARATOR

            BUTTON btPrint ;
               TOOLTIP 'Print' ;
               PICTURE 'Printer' ;
               ACTION   Print() ;
               SEPARATOR

            BUTTON btInfo ;
               TOOLTIP 'About WordScribe' ;
               PICTURE 'Info' ;
               ACTION  About()

         END TOOLBAR

         COMBOBOX coZoom ;
            ITEMS aZoomLabel ;
            VALUE 5 ;
            HEIGHT 200 ;
            WIDTH 80 ;
            TOOLTIP 'Zoom ratio' ;
            DISPLAYEDIT ;
            ON CHANGE ZoomSelect(.N.) ;
            ON DISPLAYCHANGE ZoomSelect(.Y.) ;
            ON ENTER (ZoomSelect(.Y.), wMain.ebDoc.SETFOCUS())

         DEFINE TOOLBAR tlEdit BUTTONSIZE 23,23 FONT 'ARIAL' SIZE 8  FLAT

            BUTTON btBackgroundColor ;
               TOOLTIP 'Set document background color' ;
               PICTURE 'BackgroundColor' ;
               SEPARATOR ;
               ACTION BackgroundColor()

            BUTTON btCopy ;
               TOOLTIP 'Copy' ;
               PICTURE 'Copy' ;
               ACTION Copy()

            BUTTON btPaste ;
               TOOLTIP 'Paste' ;
               PICTURE 'Paste' ;
               ACTION Paste()

            BUTTON btCut ;
               TOOLTIP 'Cut' ;
               PICTURE 'Cut' ;
               ACTION Cut()

            BUTTON btClear ;
               TOOLTIP 'Delete' ;
               PICTURE 'Delete' ;
               ACTION Deleter()
               SEPARATOR

            BUTTON btUndo ;
               TOOLTIP 'Undo' ;
               PICTURE 'Undo' ;
               ACTION Undo() ;
               DROPDOWN

            DEFINE DROPDOWN MENU BUTTON btUndo
               ITEM 'Clear undo buffer' ACTION ClearUndoBuffer()
            END MENU

            BUTTON btRedo ;
               TOOLTIP 'Redo' ;
               PICTURE 'Redo' ;
               ACTION Redo() ;
               SEPARATOR

            BUTTON btFind ;
               TOOLTIP 'Find' ;
               PICTURE 'Find' ;
               ACTION FindText()

            BUTTON btRepl ;
               TOOLTIP 'Replace' ;
               PICTURE 'Replace' ; 
               ACTION ReplaceText() ;
               SEPARATOR

         END TOOLBAR

         COMBOBOX coFontName ;
            ITEMS aFontList ;
            VALUE 1 ;
            WIDTH 170 ;
            HEIGHT 200 ;
            TOOLTIP 'Font name' ;
            DISPLAYEDIT ;
            ON CHANGE FontNameSelect(.N.) ;
            ON DISPLAYCHANGE FontNameSelect(.Y.) ;
            ON ENTER (FontNameSelect(.Y.), wMain.ebDoc.SETFOCUS()) ;
            BREAK

         COMBOBOX coFontSize ;
            ITEMS aFontSize ;
            VALUE 5 ;
            WIDTH 60 ;
            TOOLTIP 'Font size' ;
            DISPLAYEDIT ;
            ON CHANGE FontSizeSelect(.N.) ;
            ON DISPLAYCHANGE FontSizeSelect(.Y.) ;
            ON ENTER (FontSizeSelect(.Y.), wMain.ebDoc.SETFOCUS())

         DEFINE TOOLBAR tlText BUTTONSIZE 23,23 SIZE 8  FLAT 

            BUTTON btBold ;
               TOOLTIP 'Bold' ;
               PICTURE 'Bold' ;
               ACTION wMain.ebDoc.FONTBOLD := wMain.btBold.VALUE ;
               CHECK

            BUTTON btItalic ;
               TOOLTIP 'Italic' ;
               PICTURE 'Italic' ;
               ACTION wMain.ebDoc.FONTITALIC := wMain.btItalic.VALUE ;
               CHECK

            BUTTON btUnderline ;
               TOOLTIP 'Underline' ;
               PICTURE 'Under' ;
               ACTION wMain.ebDoc.FONTUNDERLINE := wMain.btUnderline.VALUE ;
               CHECK

            BUTTON btStrikeOut ;
               TOOLTIP 'Strikeout' ;
               PICTURE 'Strike' ;
               ACTION wMain.ebDoc.FONTSTRIKEOUT := wMain.btStrikeOut.VALUE ;
               CHECK ;    
               SEPARATOR

            BUTTON btSubScript ;
               TOOLTIP 'Subscript' ;
               PICTURE 'Subscript' ;
               ACTION  (wMain.ebDoc.FONTSCRIPT := IF(wMain.btSubScript.VALUE, RTF_SUBSCRIPT, RTF_NORMALSCRIPT), ; 
                         wMain.btSuperScript.VALUE := .N.) ;  
               CHECK

            BUTTON btSuperScript ;
               TOOLTIP 'Superscript' ;
               PICTURE 'Superscript' ;
               ACTION  (wMain.ebDoc.FONTSCRIPT := IF(wMain.btSuperScript.VALUE, RTF_SUPERSCRIPT, RTF_NORMALSCRIPT), ; 
                         wMain.btSubScript.VALUE := .N.) ; 
               CHECK ;
               SEPARATOR

            BUTTON btLink ;
               TOOLTIP 'Set link on selected text' ;
               PICTURE 'Link' ;
               ACTION  wMain.ebDoc.LINK := wMain.btLink.VALUE ;
               CHECK ;
               SEPARATOR

            BUTTON btFontColor ;
               TOOLTIP 'Set font foreground color' ;
               PICTURE 'FontColor' ; 
               ACTION FontForeColor()

            BUTTON btFontBackColor ;
               TOOLTIP 'Set font background color' ;
               PICTURE 'FontBackColor' ;
               SEPARATOR ;
               ACTION FontBackColor()

            BUTTON btLeft ;
               TOOLTIP 'Align left' ;
               PICTURE 'Left' ;
               ACTION (wMain.ebDoc.PARAALIGNMENT := RTF_LEFT, Refresh()) ;
               CHECK GROUP

            BUTTON btCenter ;
               TOOLTIP 'Center' ;
               PICTURE 'Center' ;
               ACTION (wMain.ebDoc.PARAALIGNMENT := RTF_CENTER, Refresh()) ;
               CHECK GROUP

            BUTTON btRight ;
               TOOLTIP 'Align right' ;
               PICTURE 'Right' ;
               ACTION (wMain.ebDoc.PARAALIGNMENT := RTF_RIGHT, Refresh()) ;
               CHECK GROUP

            BUTTON btJustify ;
               TOOLTIP 'Justify' ;
               PICTURE 'Justify' ;
               ACTION (wMain.ebDoc.PARAALIGNMENT := RTF_JUSTIFY, Refresh()) ;
               CHECK GROUP ;
               SEPARATOR 

            BUTTON btBulleted ;
               TOOLTIP 'Bulleted paragraphs' ;
               PICTURE 'Number' ;
               ACTION (wMain.ebDoc.PARANUMBERING := ;
                        IF(wMain.btBulleted.VALUE, RTF_BULLET, RTF_NOBULLETNUMBER), ;
                        Refresh()) ;
               CHECK

            BUTTON btOffset2 ;
               TOOLTIP 'Decrease indent' ;
               PICTURE 'Indent2' ;
               ACTION (wMain.ebDoc.PARAINDENT := MAX(MIN_PARAINDENT, wMain.ebDoc.PARAINDENT - 5))

            BUTTON btOffset1 ;
               TOOLTIP 'Increase indent' ;
               PICTURE 'Indent1' ;
               ACTION (wMain.ebDoc.PARAINDENT := MIN(MAX_PARAINDENT, wMain.ebDoc.PARAINDENT + 5))
      
            BUTTON btLineSpacing ;
               TOOLTIP 'Line spacing' ;
               PICTURE 'ParaLineSpacing' ;
               ACTION NIL ;
               WHOLEDROPDOWN ;
               SEPARATOR 

            DEFINE DROPDOWN MENU BUTTON btLineSpacing
               ITEM '1.0 ' ACTION wMain.ebDoc.PARALINESPACING := 1.0
               ITEM '1.5 ' ACTION wMain.ebDoc.PARALINESPACING := 1.5
               ITEM '2.0 ' ACTION wMain.ebDoc.PARALINESPACING := 2.0
               ITEM '2.5 ' ACTION wMain.ebDoc.PARALINESPACING := 2.5
               ITEM '3.0 ' ACTION wMain.ebDoc.PARALINESPACING := 3.0
               SEPARATOR
               ITEM 'Get paragraph line spacing' ;
                  ACTION MsgInfo('Paragraph line spacing: ' + HB_NTOS(wMain.ebDoc.PARALINESPACING))
            END MENU

            BUTTON btHelp ;
               TOOLTIP 'Help topics' ;
               PICTURE 'HelpPic' ;
               ACTION  Shortcuts()

         END TOOLBAR

      END SPLITBOX

      @ 70,10 RICHEDITBOX ebDoc ;
         WIDTH 773 ;
         HEIGHT 444 ;
         VALUE '' ;
         FONT cFontName SIZE nFontSize ;
         MAXLENGTH -1 ;
         NOHSCROLL ;
         ON CHANGE  EditKey() ;
         ON SELECT  Refresh() ;
         ON LINK    DoLink() ;
         ON VSCROLL (wMain.ebDoc.REFRESH)

      aViewRect := wMain.ebDoc.VIEWRECT
      aViewRect[1] += 10 // nLeft
      aViewRect[2] += 10 // nTop
      aViewRect[3] -= 10 // nRight
      aViewRect[4] -= 10 // nBottom
      wMain.ebDoc.VIEWRECT := aViewRect

      wMain.ebDoc.ZOOM            := nZoomValue
      wMain.ebDoc.BACKGROUNDCOLOR := aBackgroundColor
      wMain.ebDoc.SELECTALL()
      wMain.ebDoc.FONTCOLOR       := aFontColor
      wMain.ebDoc.FONTBACKCOLOR   := aFontBackColor
      wMain.ebDoc.UNSELECTALL()
      wMain.ebDoc.CARETPOS        := 0
      ClearUndoBuffer()

   END WINDOW

   IF lMainMax
      MAXIMIZE WINDOW wMain
   END
   MainSize(lMainMax)
   IF ! EMPTY(cInitFile)
      OpenFile(cInitFile)
   END
   ACTIVATE WINDOW wMain

   RETURN // Main

//***************************************************************************

INIT PROCEDURE MainInit

   LOCAL nPos

   cFileFolder := GETMYDOCUMENTSFOLDER()

   RegRead('wMain\Row'             , @nMainRow           )
   RegRead('wMain\Col'             , @nMainCol           )
   RegRead('wMain\Width'           , @nMainWidth         )
   RegRead('wMain\Height'          , @nMainHeight        )
   RegRead('wMain\Max'             , @lMainMax           )
   RegRead('wShort\Row'            , @nShortRow          )
   RegRead('wShort\Col'            , @nShortCol          )
   RegRead('wShort\Width'          , @nShortWidth        )
   RegRead('wShort\Height'         , @nShortHeight       )
   RegRead('wShort\Max'            , @lShortMax          )
   RegRead('ebDoc\Zoom'            , @nZoomValue         )
   RegRead('ebDoc\FontName'        , @cFontName          )
   RegRead('ebDoc\FontSize'        , @nFontSize          )
   RegRead('ebDoc\FontColor1'      , @aFontColor[1]      )
   RegRead('ebDoc\FontColor2'      , @aFontColor[2]      )
   RegRead('ebDoc\FontColor3'      , @aFontColor[3]      )
   RegRead('ebDoc\FontBackColor1'  , @aFontBackColor[1]  )
   RegRead('ebDoc\FontBackColor2'  , @aFontBackColor[2]  )
   RegRead('ebDoc\FontBackColor3'  , @aFontBackColor[3]  )
   RegRead('ebDoc\BackgroundColor1', @aBackgroundColor[1])
   RegRead('ebDoc\BackgroundColor2', @aBackgroundColor[2])
   RegRead('ebDoc\BackgroundColor3', @aBackgroundColor[3])
   RegRead('File\FileFolder'       , @cFileFolder        )
   RegRead('File\ReadFilter'       , @nReadFilter        )
   RegRead('File\WriteFilter'      , @nWriteFilter       )
   RegRead('Recent\File01Base'     , @aRecentBases[ 1]   )
   RegRead('Recent\File01Name'     , @aRecentNames[ 1]   )
   RegRead('Recent\File02Base'     , @aRecentBases[ 2]   )
   RegRead('Recent\File02Name'     , @aRecentNames[ 2]   )
   RegRead('Recent\File03Base'     , @aRecentBases[ 3]   )
   RegRead('Recent\File03Name'     , @aRecentNames[ 3]   )
   RegRead('Recent\File04Base'     , @aRecentBases[ 4]   )
   RegRead('Recent\File04Name'     , @aRecentNames[ 4]   )
   RegRead('Recent\File05Base'     , @aRecentBases[ 5]   )
   RegRead('Recent\File05Name'     , @aRecentNames[ 5]   )
   RegRead('Recent\File06Base'     , @aRecentBases[ 6]   )
   RegRead('Recent\File06Name'     , @aRecentNames[ 6]   )
   RegRead('Recent\File07Base'     , @aRecentBases[ 7]   )
   RegRead('Recent\File07Name'     , @aRecentNames[ 7]   )
   RegRead('Recent\File08Base'     , @aRecentBases[ 8]   )
   RegRead('Recent\File08Name'     , @aRecentNames[ 8]   )
   RegRead('Recent\File09Base'     , @aRecentBases[ 9]   )
   RegRead('Recent\File09Name'     , @aRecentNames[ 9]   )
   RegRead('Recent\File10Base'     , @aRecentBases[10]   )
   RegRead('Recent\File10Name'     , @aRecentNames[10]   )

   GETFONTLIST(NIL, NIL, NIL, NIL, NIL, NIL, @aFontList)
   nPos := ASCAN(aFontList, {|cRow| LOWER(cRow) == LOWER(cFontName)})
   IF EMPTY(nPos)
      cFontName := 'Arial'
   END

   RETURN // MainInit

//***************************************************************************

STATIC PROCEDURE RegRead(cKey, xVal)

   LOCAL xRead  := REGISTRYREAD(cRegBase + cKey)
   LOCAL cRType := VALTYPE(xRead)
   LOCAL cVType := VALTYPE(xVal)

   DO CASE
   CASE cVType == 'C' .AND. cRType == 'C'
      xVal := xRead
   CASE cVType == 'N' .AND. cRType == 'N'
      xVal := xRead
   CASE cVType == 'L' .AND. cRType == 'N'
      xVal := ! EMPTY(xRead)
   END

   RETURN // RegRead

//***************************************************************************

STATIC PROCEDURE MainExit(lSub)

   IF lModified .AND. MSGYESNO('Save changes?', cTitle)
      SaveFile()
   END

   IF ! lMainMax
      nMainRow    := wMain.ROW
      nMainCol    := wMain.COL
      nMainWidth  := wMain.WIDTH
      nMainHeight := wMain.HEIGHT
   END

   RegWrite('wMain\Row'             , nMainRow           )
   RegWrite('wMain\Col'             , nMainCol           )
   RegWrite('wMain\Width'           , nMainWidth         )
   RegWrite('wMain\Height'          , nMainHeight        )
   RegWrite('wMain\Max'             , lMainMax           )
   RegWrite('wShort\Row'            , nShortRow          )
   RegWrite('wShort\Col'            , nShortCol          )
   RegWrite('wShort\Width'          , nShortWidth        )
   RegWrite('wShort\Height'         , nShortHeight       )
   RegWrite('wShort\Max'            , lShortMax          )
   RegWrite('ebDoc\Zoom'            , nZoomValue         )
   RegWrite('ebDoc\FontName'        , cFontName          )
   RegWrite('ebDoc\FontSize'        , nFontSize          )
   RegWrite('ebDoc\FontColor1'      , aFontColor[1]      )
   RegWrite('ebDoc\FontColor2'      , aFontColor[2]      )
   RegWrite('ebDoc\FontColor3'      , aFontColor[3]      )
   RegWrite('ebDoc\FontBackColor1'  , aFontBackColor[1]  )
   RegWrite('ebDoc\FontBackColor2'  , aFontBackColor[2]  )
   RegWrite('ebDoc\FontBackColor3'  , aFontBackColor[3]  )
   RegWrite('ebDoc\BackgroundColor1', aBackgroundColor[1])
   RegWrite('ebDoc\BackgroundColor2', aBackgroundColor[2])
   RegWrite('ebDoc\BackgroundColor3', aBackgroundColor[3])
   RegWrite('File\FileFolder'       , @cFileFolder       )
   RegWrite('File\ReadFilter'       , nReadFilter        )
   RegWrite('File\WriteFilter'      , nWriteFilter       )
   RegWrite('Recent\File01Base'     , aRecentBases[ 1]   )
   RegWrite('Recent\File01Name'     , aRecentNames[ 1]   )
   RegWrite('Recent\File02Base'     , aRecentBases[ 2]   )
   RegWrite('Recent\File02Name'     , aRecentNames[ 2]   )
   RegWrite('Recent\File03Base'     , aRecentBases[ 3]   )
   RegWrite('Recent\File03Name'     , aRecentNames[ 3]   )
   RegWrite('Recent\File04Base'     , aRecentBases[ 4]   )
   RegWrite('Recent\File04Name'     , aRecentNames[ 4]   )
   RegWrite('Recent\File05Base'     , aRecentBases[ 5]   )
   RegWrite('Recent\File05Name'     , aRecentNames[ 5]   )
   RegWrite('Recent\File06Base'     , aRecentBases[ 6]   )
   RegWrite('Recent\File06Name'     , aRecentNames[ 6]   )
   RegWrite('Recent\File07Base'     , aRecentBases[ 7]   )
   RegWrite('Recent\File07Name'     , aRecentNames[ 7]   )
   RegWrite('Recent\File08Base'     , aRecentBases[ 8]   )
   RegWrite('Recent\File08Name'     , aRecentNames[ 8]   )
   RegWrite('Recent\File09Base'     , aRecentBases[ 9]   )
   RegWrite('Recent\File09Name'     , aRecentNames[ 9]   )
   RegWrite('Recent\File10Base'     , aRecentBases[10]   )
   RegWrite('Recent\File10Name'     , aRecentNames[10]   )

   IF lSub
      RELEASE WINDOW MAIN
   END

   RETURN // MainExit

//***************************************************************************

STATIC PROCEDURE RegWrite(cKey, xVal)

   LOCAL xWrite := 0
   LOCAL cVType := VALTYPE(xVal)

   DO CASE
   CASE cVType == 'C'
      xWrite := xVal
   CASE cVType == 'N'
      xWrite := xVal
   CASE cVType == 'L'
      xWrite := IF(xVal, 1, 0)
   END

   REGISTRYWRITE(cRegBase + cKey, xWrite)

   RETURN // RegWrite

//***************************************************************************

STATIC PROCEDURE MainSize(lSetMax)

   IF lSetMax != NIL
      lMainMax := lSetMax
   END
   IF ! lMainMax
      nMainRow    := wMain.ROW
      nMainCol    := wMain.COL
      nMainWidth  := wMain.WIDTH
      nMainHeight := wMain.HEIGHT
   END
   wMain.ebDoc.WIDTH := wMain.WIDTH - 27
   DO CASE
   CASE wMain.WIDTH < 630
      wMain.ebDoc.ROW    := 126
      wMain.ebDoc.HEIGHT := wMain.HEIGHT - 212
   CASE wMain.WIDTH < 740
      wMain.ebDoc.ROW    :=  98
      wMain.ebDoc.HEIGHT := wMain.HEIGHT - 184
   OTHERWISE
      wMain.ebDoc.ROW    :=  70
      wMain.ebDoc.HEIGHT := wMain.HEIGHT - 156
   END

   RETURN // MainSize

//***************************************************************************

STATIC PROCEDURE EditKey

   LOCAL cKey := HMG_GETLASTCHARACTEREX()
   LOCAL nKey := HB_UTF8ASC(cKey)

   IF nKey > 0
      wMain.btUndo.ENABLED := wMain.ebDoc.CANUNDO
      wMain.btRedo.ENABLED := wMain.ebDoc.CANREDO
      lModified := .Y.
   END

   RETURN // EditKey

//***************************************************************************

STATIC PROCEDURE Refresh

   STATIC lRun := .N.

   LOCAL nPos

   BEGIN SEQUENCE

      IF lRun
         BREAK // avoid re-entry
      ENDIF
      lRun := .Y.

      cFontName := wMain.ebDoc.FONTNAME
      nFontSize := wMain.ebDoc.FONTSIZE

      wMain.coZoom.DISPLAYVALUE     := STR(nZoomValue, 4) + '%'
      wMain.coFontName.DISPLAYVALUE := cFontName
      wMain.coFontSize.DISPLAYVALUE := STR(nFontSize, 4)

      wMain.btBold.VALUE            := wMain.ebDoc.FONTBOLD
      wMain.btItalic.VALUE          := wMain.ebDoc.FONTITALIC
      wMain.btUnderline.VALUE       := wMain.ebDoc.FONTUNDERLINE
      wMain.btStrikeOut.VALUE       := wMain.ebDoc.FONTSTRIKEOUT
      wMain.btSubScript.VALUE       := (wMain.ebDoc.FONTSCRIPT == RTF_SUBSCRIPT)
      wMain.btSuperScript.VALUE     := (wMain.ebDoc.FONTSCRIPT == RTF_SUPERSCRIPT)
      wMain.btLink.VALUE            := wMain.ebDoc.LINK

      wMain.btBulleted.VALUE        := (wMain.ebDoc.PARANUMBERING > RTF_NOBULLETNUMBER)

      wMain.btLeft.VALUE            := (wMain.ebDoc.PARAALIGNMENT == RTF_LEFT)
      wMain.btCenter.VALUE          := (wMain.ebDoc.PARAALIGNMENT == RTF_CENTER)
      wMain.btRight.VALUE           := (wMain.ebDoc.PARAALIGNMENT == RTF_RIGHT)
      wMain.btJustify.VALUE         := (wMain.ebDoc.PARAALIGNMENT == RTF_JUSTIFY)

      lRun := .N.

   END SEQUENCE

   RETURN // Refresh

//***************************************************************************

STATIC PROCEDURE DoLink

   LOCAL cLink := ALLTRIM(THISRICHEDITBOX.GETCLICKLINKTEXT)

   DO CASE
   CASE HMG_LOWER(HB_USUBSTR(cLink,1,7)) == 'http://' .OR. ;
      HMG_LOWER(HB_USUBSTR(cLink,1,8)) == 'https://' .OR. ;
      HMG_LOWER(HB_USUBSTR(cLink,1,4)) == 'www.' 
      SHELLEXECUTE(NIL, 'Open', cLink, NIL, NIL, SW_SHOWNORMAL)
   CASE '@' $ cLink .AND. '.' $ cLink .AND. .NOT.(' ' $ cLink)
      SHELLEXECUTE(NIL, 'Open', 'rundll32.exe', 'url.dll,FileProtocolHandler mailto:' + cLink, NIL, SW_SHOWNORMAL)
   OTHERWISE
      MSGINFO(cLink, 'On Link')
   END

   RETURN // DoLink

//***************************************************************************

STATIC PROCEDURE NewFileName(cNewName)

   LOCAL nPos

   cFileName := cNewName
   nPos      := RAT('\', cFileName)
   IF EMPTY(nPos)
      cFileFolder := GETMYDOCUMENTSFOLDER()
      cFileBase   := cFileName
      cFileName   := cFileFolder + '\' + cFileBase
   ELSE
      cFileFolder := LEFT(cFileName, nPos - 1)
      cFileBase   := SUBSTR(cFileName, nPos + 1)
   END
   nPos     := RAT('.', cFileBase)
   cFileExt := IF(nPos < 2, '', SUBSTR(cFileBase, nPos + 1))
   IF ! EMPTY(cNewName)
      nPos := ASCAN(aRecentNames, {|cRow| HMG_UPPER(cRow) == HMG_UPPER(cFileName)})
      IF ! EMPTY(nPos)
         ADEL(aRecentBases, nPos)
         ADEL(aRecentNames, nPos)
      END
      AINS(aRecentBases, 1)
      AINS(aRecentNames, 1)
      aRecentBases[1] := cFileBase
      aRecentNames[1] := cFileName
   END
   wMain.TITLE := IF(EMPTY(cFileBase), '', cFileBase + ' - ') + cTitle
   wMain.STATUSBAR.ITEM(1) := cFileName

   RETURN // NewFileName

//***************************************************************************

STATIC PROCEDURE NewFile

   IF ! lModified .OR. MSGYESNO('Clear the current file?', 'New')
     NewFileName('')
     wMain.ebDoc.VALUE := ''
     lModified := .N.
   END

   RETURN // NewFile

//***************************************************************************

STATIC PROCEDURE OpenFile(cAuxFileName)

   IF lModified .AND. MSGYESNO('Save changes?', 'Open')
     SaveFile()
   END

   IF EMPTY(cAuxFileName)
     cAuxFileName := GETFILE(aReadFilter, 'Open', cFileFolder, NIL, NIL, nReadFilter)
   END

   IF ! EMPTY(cAuxFileName)
     NewFileName(cAuxFileName)
     ReadFile()
     lModified := .N.
   END

   RETURN // OpenFile

//***************************************************************************

STATIC PROCEDURE ReadFile

   LOCAL nFormat        := GETRICHEDITFILETYPE(cFileName, .Y.)
   LOCAL nTxtReadFilter := IF(HMG_UPPER(cFileExt) == 'TXT', 2, 3)

   SWITCH nFormat
   CASE RICHEDITFILEEX_RTF
      nReadFilter  := 1
      nWriteFilter := 1
      EXIT
   CASE RICHEDITFILEEX_ANSI
      nReadFilter  := nTxtReadFilter
      nWriteFilter := 2
      EXIT
   CASE RICHEDITFILEEX_UTF16LE
      nReadFilter  := nTxtReadFilter
      nWriteFilter := 3
      EXIT
   CASE RICHEDITFILEEX_UTF16BE
      nReadFilter  := nTxtReadFilter
      nWriteFilter := 4
      EXIT
   CASE RICHEDITFILEEX_UTF8
      nReadFilter  := nTxtReadFilter
      nWriteFilter := 5
      EXIT
   END
   BEGIN SEQUENCE
      IF ! EX.wMain.ebDoc.LOADFILE(cFileName, .N., nFormat)
         BREAK
      END
      wMain.ebDoc.CLEARUNDOBUFFER()
      wMain.btUndo.ENABLED := .N.
      wMain.btRedo.ENABLED := .N.
   RECOVER
      MsgExclamation('Cannot open ' + cFileName, 'Open')
   END SEQUENCE

   RETURN // ReadFile

//***************************************************************************

STATIC PROCEDURE CloseFile

   IF MSGYESNO('Close the current file?', 'Close')
      NewFileName('')
      lModified := .N.
   END

   RETURN // CloseFile

//***************************************************************************

STATIC PROCEDURE SaveFile

   IF EMPTY(cFileName)
      SaveFileAs()
   ELSE
      WriteFile()
   END

   RETURN // SaveFile

//***************************************************************************

STATIC PROCEDURE SaveFileAs

   LOCAL lUnicode := EX.wMain.ebDoc.HASNONASCIICHARS
   LOCAL cAuxFileName

   IF lUnicode
      IF nWriteFilter == 2
         nWriteFilter := 3
      END
   ELSE
      IF nWriteFilter >= 3
         nWriteFilter := 2
      END
   END

   cAuxFileName := PUTFILE(aWriteFilter, 'Save As', cFileFolder, ;
      NIL, cFileName, @cFileExt, @nWriteFilter)

   IF ! EMPTY(cAuxFileName) .AND. (! lUnicode .OR. nWriteFilter != 2 .OR. ;
      MsgYesNo('This document contains Unicode characters, which will be lost if you save to an ANSI file.  Proceed?', cTitle))
      NewFileName(cAuxFileName)
      WriteFile()
   END

   RETURN // SaveFile

//***************************************************************************

STATIC PROCEDURE WriteFile

   LOCAL nFormat

   BEGIN SEQUENCE
      SWITCH nWriteFilter
      CASE 1
         nFormat := RICHEDITFILEEX_RTF
         EXIT
      CASE 2
         nFormat := RICHEDITFILEEX_ANSI
         EXIT
      CASE 3
         nFormat := RICHEDITFILEEX_UTF16LE
         EXIT
      CASE 4
         nFormat := RICHEDITFILEEX_UTF16BE
         EXIT
      CASE 5
         nFormat := RICHEDITFILEEX_UTF8
         EXIT
      END
      IF ! EX.wMain.ebDoc.SAVEFILE(cFileName, .N., nFormat)
         BREAK
      END
      lModified := .N.
   RECOVER
      MsgExclamation('Cannot save to ' + cFileName, 'Save')
   END SEQUENCE

   RETURN // WriteFile

//***************************************************************************

STATIC PROCEDURE Print

   LOCAL lPrint  := .N.
   LOCAL aSelect := {0, -1} // Select all text
   LOCAL nLeft   := 10 // Left   page margin in millimeters
   LOCAL nTop    := 15 // Top    page margin in millimeters
   LOCAL nRight  := 10 // Right  page margin in millimeters
   LOCAL nBottom := 15 // Bottom page margin in millimeters
   LOCAL bPage   := {|| NIL}

   SELECT PRINTER DIALOG TO lPrint

   IF lPrint
      wMain.ebDoc.RTFPRINT(aSelect, nLeft, nTop, nRight, nBottom, bPage)
   END

   RETURN // Print

//***************************************************************************

STATIC PROCEDURE PrintPreview

   LOCAL lPrint  := .N.
   LOCAL aSelect := {0, -1} // Select all text
   LOCAL nLeft   := 20 // Left   page margin in millimeters
   LOCAL nTop    := 20 // Top    page margin in millimeters
   LOCAL nRight  := 20 // Right  page margin in millimeters
   LOCAL nBottom := 20 // Bottom page margin in millimeters
   LOCAL nPage   := 1
   LOCAL nRow    := OPENPRINTERGETPAGEHEIGHT() - 10 // in millimeters
   LOCAL nCol    := OPENPRINTERGETPAGEWIDTH() / 2   // in millimeters
   LOCAL bPage   := {||@nRow, nCol PRINT 'Page ' + HB_NTOS(nPage++) CENTER}

   SELECT PRINTER DIALOG TO lPrint PREVIEW 

   IF lPrint
      wMain.ebDoc.RTFPRINT(aSelect, nLeft, nTop, nRight, nBottom, bPage)
   END

   RETURN // PrintPreview

//***************************************************************************

STATIC PROCEDURE Associations

   LOCAL lRtfAssoc, lTxtAssoc

   DEFINE WINDOW wAssoc ; 
      AT wMain.ROW + 160, wMain.COL + 40 ;
      WIDTH 440 ;
      HEIGHT 150 ; 
      TITLE 'File associations' ; 
      MODAL ;
      NOSIZE ;
      ON INIT AssocInit(@lRtfAssoc, @lTxtAssoc)

      @  10, 10 CHECKBOX ckRtfMenu ;
         CAPTION 'Include "Open with WordScribe" item on right click menu for RTF files' ;
         WIDTH 420 ;
         VALUE .N.

      @  40, 10 CHECKBOX ckTxtMenu ;
         CAPTION 'Include "Open with WordScribe" item on right click menu for TXT files' ;
         WIDTH 420 ;
         VALUE .N.

      @  80,135 BUTTON btOk ;
         CAPTION 'OK' ;  
         ACTION AssocSet(lRtfAssoc, lTxtAssoc) ;
         WIDTH 80 HEIGHT 25

      @  80,225 BUTTON btCancel ; 
         CAPTION 'Cancel' ;  
         ACTION wAssoc.Release ;
         WIDTH 80 HEIGHT 25

      ON KEY RETURN ACTION AssocSet(lRtfAssoc, lTxtAssoc)
      ON KEY ESCAPE ACTION wAssoc.RELEASE
      ON KEY F1     ACTION Shortcuts()

   END WINDOW 

   ACTIVATE WINDOW wAssoc

   RETURN // Associations

//***************************************************************************

STATIC PROCEDURE AssocInit(lRtfAssoc, lTxtAssoc)

   LOCAL cThisExe  := GETPROGRAMFILENAME()
   LOCAL cMenuItem := STRTRAN('Open with WordScribe', ' ', E"\xC2\xA0") // U+00A0 NO-BREAK SPACE
   LOCAL cClass, cRegExe

   BEGIN SEQUENCE
      cClass := REGISTRYREAD('HKCR\.rtf\')
      IF ! HB_ISSTRING(cClass)
         lRtfAssoc := .N.
         BREAK
      END
      cRegExe := REGISTRYREAD('HKCR\' + cClass + '\shell\' + cMenuItem + '\command\')
      IF HB_ISSTRING(cRegExe) .AND. HMG_UPPER(cThisExe) $ HMG_UPPER(cRegExe)
         lRtfAssoc := .Y.    
         BREAK
      END
      lRtfAssoc := .N.
   END SEQUENCE

   BEGIN SEQUENCE
      cClass := REGISTRYREAD('HKCR\.txt\')
      IF ! HB_ISSTRING(cClass)
         lTxtAssoc := .N.
         BREAK
      END
      cRegExe := REGISTRYREAD('HKCR\' + cClass + '\shell\' + cMenuItem + '\command\')
      IF HB_ISSTRING(cRegExe) .AND. HMG_UPPER(cThisExe) $ HMG_UPPER(cRegExe)
         lTxtAssoc := .Y.    
         BREAK
      END
      lTxtAssoc := .N.
   END SEQUENCE

   wAssoc.ckRtfMenu.VALUE := lRtfAssoc
   wAssoc.ckTxtMenu.VALUE := lTxtAssoc

   RETURN // AssocInit

//***************************************************************************

STATIC PROCEDURE AssocSet(lRtfAssoc, lTxtAssoc)

   LOCAL cMenuItem := STRTRAN('Open with WordScribe', ' ', E"\xC2\xA0") // U+00A0 NO-BREAK SPACE
   LOCAL cThisExe  := GETPROGRAMFILENAME()
   LOCAL cClass

   DO CASE
   CASE ! lRtfAssoc .AND. wAssoc.ckRtfMenu.VALUE
      cClass := REGISTRYREAD('HKCR\.rtf\')
      IF ! HB_ISSTRING(cClass)
         cClass := 'rtffile'
         REGISTRYWRITE('HKCR\.rtf\', cClass)
      END
      REGISTRYWRITE('HKCR\' + cClass + '\shell\' + cMenuItem + '\command\', ;
         '"' + cThisExe + '" "%1"')
   END

   IF ! lTxtAssoc .AND. wAssoc.ckTxtMenu.VALUE
      cClass := REGISTRYREAD('HKCR\.txt\')
      IF ! HB_ISSTRING(cClass)
         cClass := 'txtfile'
         REGISTRYWRITE('HKCR\.txt\', cClass)
      END
      REGISTRYWRITE('HKCR\' + cClass + '\shell\' + cMenuItem + '\command\', ;
         '"' + cThisExe + '" "%1"')
   END

   wAssoc.RELEASE

   RETURN // AssocSet

//***************************************************************************

STATIC PROCEDURE Bold

   wMain.ebDoc.FONTBOLD := ! (wMain.ebDoc.FONTBOLD)
   Refresh()

   RETURN // Bold

//***************************************************************************

STATIC PROCEDURE Italic

   wMain.ebDoc.FONTITALIC := ! (wMain.ebDoc.FONTITALIC)
   Refresh()

   RETURN // Italic

//***************************************************************************

STATIC PROCEDURE Underline

   wMain.ebDoc.FONTUNDERLINE := ! (wMain.ebDoc.FONTUNDERLINE)
   Refresh()

   RETURN // Underline

//***************************************************************************

STATIC PROCEDURE Undo

   wMain.ebDoc.UNDO()

   RETURN // Undo

//***************************************************************************

STATIC PROCEDURE Redo

   wMain.ebDoc.REDO()

   RETURN // Redo

//***************************************************************************

STATIC PROCEDURE ClearUndoBuffer

   wMain.ebDoc.CLEARUNDOBUFFER()
   wMain.btUndo.ENABLED := .N.
   wMain.btRedo.ENABLED := .N.

   RETURN // ClearUndoBuffer

//***************************************************************************

STATIC PROCEDURE Copy

   wMain.ebDoc.SELCOPY()

   RETURN // Copy

//***************************************************************************

STATIC PROCEDURE Cut

   wMain.ebDoc.SELCUT()

   RETURN // Cut

//***************************************************************************

STATIC PROCEDURE Paste

   wMain.ebDoc.SELPASTE()

   RETURN // Paste

//***************************************************************************

STATIC PROCEDURE PasteUnformatted

   LOCAL cStr   := GETCLIPBOARD()
   LOCAL nCaret := wMain.ebDoc.CARETPOS

   wMain.ebDoc.ADDTEXT(nCaret) := cStr
   wMain.ebDoc.CARETPOS := nCaret + HB_ULEN(cStr)

   RETURN // PasteUnformatted

//***************************************************************************

STATIC PROCEDURE Deleter

   wMain.ebDoc.SELCLEAR()

   RETURN // Deleter

//***************************************************************************

STATIC PROCEDURE SelectAll

   wMain.ebDoc.SELECTALL()

   RETURN // SelectAll

//***************************************************************************

STATIC PROCEDURE FindText

   cFind := wMain.ebDoc.GETSELECTTEXT

   FINDTEXTDIALOG ON ACTION DoFindReplace() ;
      FIND cFind CHECKDOWN lDown CHECKMATCHCASE lMatchCase ;
      CHECKWHOLEWORD lWholeWord

   RETURN // FindText

//***************************************************************************

STATIC PROCEDURE ReplaceText

   cFind := wMain.ebDoc.GETSELECTTEXT

   REPLACETEXTDIALOG ON ACTION DoFindReplace() ;
      FIND cFind REPLACE cReplace CHECKMATCHCASE lMatchCase ;
      CHECKWHOLEWORD lWholeWord

   RETURN // ReplaceText

//***************************************************************************

STATIC PROCEDURE DoFindReplace

   LOCAL lSelectFindText
   LOCAL aPosRange := {0,0}

   BEGIN SEQUENCE

      IF FindReplaceDlg.RETVALUE == FRDLG_CANCEL   // User Cancel or Close dialog
         BREAK
      END

      cFind           := FindReplaceDlg.FIND
      cReplace        := FindReplaceDlg.REPLACE
      lDown           := FindReplaceDlg.DOWN
      lMatchCase      := FindReplaceDlg.MATCHCASE
      lWholeWord      := FindReplaceDlg.WHOLEWORD
      lSelectFindText := .Y.

      SWITCH FindReplaceDlg.RetValue
      CASE FRDLG_FINDNEXT
         aPosRange := wMain.ebDoc.FINDTEXT(cFind, lDown, lMatchCase, lWholeWord, lSelectFindText)
         EXIT
      CASE FRDLG_REPLACE
         aPosRange := wMain.ebDoc.REPLACETEXT(cFind, cReplace, lMatchCase, lWholeWord, lSelectFindText)
         EXIT
      CASE FRDLG_REPLACEALL
         aPosRange := wMain.ebDoc.REPLACEALLTEXT(cFind, cReplace, lMatchCase, lWholeWord, lSelectFindText)
         EXIT
      END

      IF aPosRange[1] == -1
         MSGINFO('Cannot find the text:' + HB_OSNEWLINE() + cFind)
      ELSE
         MoveFindReplace(aPosRange[1])
      END

   END SEQUENCE

   RETURN // DoFindReplace

//***************************************************************************

STATIC PROCEDURE MoveFindReplace(nPos)

   LOCAL aCharPos := wMain.ebDoc.GETPOSCHAR(nPos)

   IF aCharPos[1] != -1 .AND. aCharPos[2] != -1
      DO CASE
      CASE (FindReplaceDlg.HEIGHT + OFFSET_DLG) < aCharPos[1]
         FindReplaceDlg.ROW := aCharPos[1] - (FindReplaceDlg.HEIGHT + OFFSET_DLG)
      CASE FindReplaceDlg.ROW < aCharPos[1] + OFFSET_DLG
         FindReplaceDlg.ROW := aCharPos[1] + OFFSET_DLG
      END
   END

   RETURN // MoveFindReplace

//***************************************************************************

STATIC PROCEDURE FontNameSelect(lDisplay)

   LOCAL cVal, nPos

   IF lDisplay
      cVal := HMG_UPPER(ALLTRIM(wMain.coFontName.DISPLAYVALUE))
      nPos := ASCAN(aFontList, {|cRow| HMG_UPPER(cRow) == cVal})
   ELSE
      nPos := wMain.coFontName.VALUE
   END
   IF ! EMPTY(nPos)
      wMain.ebDoc.FONTNAME := (cFontName := aFontList[nPos])
      Refresh()
   END

   RETURN // FontNameSelect

//***************************************************************************

STATIC PROCEDURE FontSizeSelect(lDisplay)

   LOCAL nPos := wMain.coFontSize.VALUE
   LOCAL nVal

   IF lDisplay .OR. EMPTY(nPos)
      nVal := INT(VAL(wMain.coFontSize.DISPLAYVALUE))
   ELSE
      nVal := VAL(aFontSize[nPos])
   END
   IF nVal >= 1 .AND. nVal <= 1636
      wMain.ebDoc.FONTSIZE := (nFontSize := nVal)
      Refresh()
   END

   RETURN // FontSizeSelect

//***************************************************************************

STATIC PROCEDURE FontFormat

   LOCAL aFont := GETFONT( ;
      wMain.ebDoc.FONTNAME     , ;
      wMain.ebDoc.FONTSIZE     , ;
      wMain.ebDoc.FONTBOLD     , ;
      wMain.ebDoc.FONTITALIC   , ;
      wMain.ebDoc.FONTCOLOR    , ;
      wMain.ebDoc.FONTUNDERLINE, ;
      wMain.ebDoc.FONTSTRIKEOUT  )

   LOCAL nPos

   IF ! EMPTY(aFont[1])
      wMain.ebDoc.FONTNAME          := cFontName := aFont[1]
      wMain.ebDoc.FONTSIZE          := nFontSize := aFont[2]
      wMain.ebDoc.FONTBOLD          := aFont[3]
      wMain.ebDoc.FONTITALIC        := aFont[4]
      wMain.ebDoc.FONTCOLOR         := aFontColor := aFont[5]
      wMain.ebDoc.FONTUNDERLINE     := aFont[6]
      wMain.ebDoc.FONTSTRIKEOUT     := aFont[7]
      wMain.coFontName.DISPLAYVALUE := cFontName
      wMain.coFontSize.DISPLAYVALUE := nFontSize
   END

   RETURN // FontFormat

//***************************************************************************

STATIC PROCEDURE TextFormat

   DEFINE WINDOW wText ; 
      AT wMain.ROW + 160, wMain.COL + 40 ;
      WIDTH 340 ;
      HEIGHT 160 ; 
      TITLE 'Text' ; 
      MODAL ;
      NOSIZE ;
      ON INIT TextInit()

      @  5, 10 FRAME frAlign ;
         CAPTION 'Alignment' ;
         WIDTH 100 ;
         HEIGHT 110

      @ 25, 15 RADIOGROUP rgScript ;
         OPTIONS aScriptLabel ;  
         VALUE 1 ;  
         WIDTH 90 ;
         SPACING 25 

      @  5,115 FRAME frIndent ;
         CAPTION 'Attributes' ;
         WIDTH 100 ;
         HEIGHT 110

      @ 25,125 CHECKBOX ckLink ;
         CAPTION 'Link' ;
         WIDTH 80 ;
         VALUE .N.

      @ 25,240 BUTTON btOk ;
         CAPTION 'OK' ;  
         ACTION TextSet() ;
         WIDTH 80 HEIGHT 25

      @ 55,240 BUTTON btCancel ; 
         CAPTION 'Cancel' ;  
         ACTION wText.Release ;
         WIDTH 80 HEIGHT 25

      ON KEY RETURN ACTION TextSet()
      ON KEY ESCAPE ACTION wText.RELEASE
      ON KEY F1     ACTION Shortcuts()

   END WINDOW 

   ACTIVATE WINDOW wText

   RETURN // TextFormat

//***************************************************************************

STATIC PROCEDURE TextInit

   wText.rgScript.VALUE := MAX(1, ASCAN(aScriptValue, wMain.ebDoc.FONTSCRIPT))
   wText.ckLink.VALUE   := wMain.ebDoc.LINK

   RETURN // TextInit

//***************************************************************************

STATIC PROCEDURE TextSet

   wMain.ebDoc.FONTSCRIPT := aScriptValue[wText.rgScript.VALUE]
   wMain.ebDoc.LINK       := wText.ckLink.VALUE
   wText.RELEASE

   RETURN // TextSet

//***************************************************************************

STATIC PROCEDURE ParagraphFormat

   LOCAL lNum
   LOCAL xNew, xOld

   DEFINE WINDOW wPar ; 
      AT wMain.ROW + 160, wMain.COL + 40 ;
      WIDTH 370 ;
      HEIGHT 440 ; 
      TITLE 'Paragraph' ; 
      MODAL ;
      NOSIZE ;
      ON INIT ParagraphInit()

      @   5, 10 FRAME frAlign ;
         CAPTION 'Alignment' ;
         WIDTH 70 ;
         HEIGHT 135

      @  25, 15 RADIOGROUP rgAlign ;
         OPTIONS aAlignLabel ;  
         VALUE 1 ;  
         WIDTH 60 ;
         SPACING 25 

      @   5, 85 FRAME frIndent ;
         CAPTION 'Spacing' ;
         WIDTH 175 ;
         HEIGHT 135

      @  30, 95 LABEL laLeftIndent ; 
         VALUE 'Left indent (mm)' ;
         WIDTH 90 ; 
         HEIGHT 23

      @  30,195 TEXTBOX tbLeftIndent ;
         WIDTH 40 ;  
         VALUE 1 ;
         NUMERIC INPUTMASK '999'

      @  60, 95 LABEL laLeftOffset ; 
         VALUE 'Left offset (mm)' ;
         WIDTH 90 ; 
         HEIGHT 23

      @  60,195 TEXTBOX tbLeftOffset ;
         WIDTH 40 ;  
         VALUE 1 ;
         NUMERIC INPUTMASK '999'

      @  90, 95 LABEL laLineSpace ; 
         VALUE 'Line spacing' ;
         WIDTH 80 ; 
         HEIGHT 23

      @  90,180 COMBOBOX coLineSpace ;
         ITEMS aSpaceLabel ;
         VALUE 2 ;
         WIDTH 60 ;
         HEIGHT 200 ;
         DISPLAYEDIT ;
         ON GOTFOCUS  (xOld := wPar.coLineSpace.DISPLAYVALUE) ;
         ON LOSTFOCUS (xNew := VAL(wPar.coLineSpace.DISPLAYVALUE), ;
                       IF(xNew >= 0.2 .AND. xNew < 100, ;
                       NIL, wPar.coLineSpace.DISPLAYVALUE := xOld))

      @ 145, 10 FRAME frNum ;
         CAPTION 'Bullets and numbering' ;
         WIDTH 340 ;
         HEIGHT 250

      @ 165, 15 RADIOGROUP rgNumFormat ;
         OPTIONS aNumFormatLabel ;  
         VALUE 1 ;  
         WIDTH 185 ;
         SPACING 25 ;
         ON CHANGE (lNum := (wPar.rgNumFormat.VALUE >= RTF_ARABICNUMBER), ;
                    wPar.rgNumStyle.ENABLED := lNum, ;
                    wPar.laNumStart.ENABLED := lNum, ;
                    wPar.tbNumStart.ENABLED := lNum  )

      @ 165,210 RADIOGROUP rgNumStyle ;
         OPTIONS aNumStyleLabel ;  
         VALUE 1 ;  
         WIDTH 185 ;
         SPACING 25 

      @ 360, 15 LABEL laNumStart ; 
         VALUE 'Starting number' ;
         WIDTH 140 ; 
         HEIGHT 23

      @ 360,110 TEXTBOX tbNumStart ;
         WIDTH 40 ;
         VALUE 1 ;
         NUMERIC INPUTMASK '999'

      @  25,270 BUTTON btOk ;
         CAPTION 'OK' ;  
         ACTION ParagraphSet() ;
         WIDTH 80 HEIGHT 25

      @  55,270 BUTTON btCancel ; 
         CAPTION 'Cancel' ;  
         ACTION wPar.Release ;
         WIDTH 80 HEIGHT 25

      ON KEY RETURN ACTION ParagraphSet()
      ON KEY ESCAPE ACTION wPar.RELEASE
      ON KEY F1     ACTION Shortcuts()

   END WINDOW 

   ACTIVATE WINDOW wPar

   RETURN // ParagraphFormat

//***************************************************************************

STATIC PROCEDURE ParagraphInit

   LOCAL nParAlign     := wMain.ebDoc.PARAALIGNMENT
   LOCAL nParIndent    := wMain.ebDoc.PARAINDENT
   LOCAL nParOffset    := wMain.ebDoc.PARAOFFSET
   LOCAL nParSpacing   := wMain.ebDoc.PARALINESPACING
   LOCAL nParNumFormat := wMain.ebDoc.PARANUMBERING
   LOCAL nParNumStyle  := wMain.ebDoc.PARANUMBERINGSTYLE
   LOCAL nParNumStart  := wMain.ebDoc.PARANUMBERINGSTART
   LOCAL lNum          := (nParNumFormat >= RTF_ARABICNUMBER)

   wPar.rgAlign.VALUE            := ASCAN(aAlignValue, nParAlign)
   wPar.tbLeftIndent.VALUE       := nParIndent
   wPar.tbLeftOffset.VALUE       := nParOffset
   wPar.coLineSpace.DISPLAYVALUE := STR(MIN(99, nParSpacing), 4, 1)
   wPar.rgNumFormat.VALUE        := nParNumFormat
   wPar.rgNumStyle.VALUE         := MAX(1, IF(lNum, nParNumStyle, RTF_PERIOD))
   wPar.tbNumStart.VALUE         := IF(lNum, nParNumStart, 1)
   wPar.rgNumStyle.ENABLED       := lNum
   wPar.laNumStart.ENABLED       := lNum
   wPar.tbNumStart.ENABLED       := lNum

   RETURN // ParagraphInit

//***************************************************************************

STATIC PROCEDURE ParagraphSet

   LOCAL nParAlign     := wPar.rgAlign.VALUE
   LOCAL nParIndent    := wPar.tbLeftIndent.VALUE
   LOCAL nParOffset    := wPar.tbLeftOffset.VALUE
   LOCAL nParSpacing   := VAL(wPar.coLineSpace.DISPLAYVALUE)
   LOCAL nParNumFormat := wPar.rgNumFormat.VALUE
   LOCAL nParNumStyle  := wPar.rgNumStyle.VALUE
   LOCAL nParNumStart  := wPar.tbNumStart.VALUE
   LOCAL lNum          := (nParNumFormat >= RTF_ARABICNUMBER)

   wPar.RELEASE
   wMain.ebDoc.PARAALIGNMENT      := aAlignValue[nParAlign]
   wMain.ebDoc.PARAINDENT         := nParIndent
   wMain.ebDoc.PARAOFFSET         := nParOffset
   wMain.ebDoc.PARALINESPACING    := nParSpacing
   wMain.ebDoc.PARANUMBERING      := nParNumFormat
   IF lNum
      wMain.ebDoc.PARANUMBERINGSTYLE := nParNumStyle
      wMain.ebDoc.PARANUMBERINGSTART := nParNumStart
   ELSE
      wMain.ebDoc.PARANUMBERINGSTYLE := RTF_NOBULLETNUMBER
      wMain.ebDoc.PARANUMBERINGSTART := 0
   END

   RETURN // ParagraphSet

//***************************************************************************

STATIC PROCEDURE Zoom

   LOCAL aZoomOpts := ACLONE(aZoomLabel)
   LOCAL nZoomOpts := LEN(aZoomOpts) + 1

   AADD(aZoomOpts, 'Custom')

   DEFINE WINDOW wZoom ; 
      AT wMain.ROW + 160, wMain.COL + 40 ;
      WIDTH 205 ;
      HEIGHT 340 ; 
      TITLE 'Zoom' ; 
      MODAL ;
      NOSIZE ;
      ON INIT ZoomInit(aZoomOpts, nZoomOpts)

      @   5, 10 FRAME frZoom ;
         CAPTION 'Zoom level' ;
         WIDTH 175 ;
         HEIGHT 255

      @  25, 15 RADIOGROUP rgZoom ;
         OPTIONS aZoomOpts ;  
         VALUE 1 ;  
         WIDTH 60 ;
         SPACING 25 ;
         ON CHANGE (wZoom.tbZoomCustom.ENABLED := (wZoom.rgZoom.VALUE == nZoomOpts))

      @ 225,100 TEXTBOX tbZoomCustom ;
         WIDTH 55 ;  
         VALUE 1 ;
         NUMERIC INPUTMASK '9999'

      @ 230,160 LABEL laZoomCustom ; 
         VALUE '%' ;
         WIDTH 10 ; 
         HEIGHT 23

      @ 270, 15 BUTTON btOk ;
         CAPTION 'OK' ;  
         ACTION ZoomSet(aZoomOpts, nZoomOpts) ;
         WIDTH 80 HEIGHT 25

      @ 270,105 BUTTON btCancel ; 
         CAPTION 'Cancel' ;  
         ACTION wZoom.Release ;
         WIDTH 80 HEIGHT 25

      ON KEY RETURN ACTION ZoomSet(aZoomOpts, nZoomOpts)
      ON KEY ESCAPE ACTION wZoom.RELEASE
      ON KEY F1     ACTION Shortcuts()

   END WINDOW 

   ACTIVATE WINDOW wZoom

   RETURN // Zoom

//***************************************************************************

STATIC PROCEDURE ZoomInit(aZoomOpts, nZoomOpts)

   LOCAL cZoomValue := LTRIM(STR(nZoomValue)) + '%'
   LOCAL nPos       := ASCAN(aZoomLabel, {|cRow| cRow == cZoomValue})

   IF EMPTY(nPos)
      wZoom.rgZoom.VALUE         := nZoomOpts
      wZoom.tbZoomCustom.ENABLED := .Y.
   ELSE
      wZoom.rgZoom.VALUE         := nPos
      wZoom.tbZoomCustom.ENABLED := .N.
   END
   wZoom.tbZoomCustom.VALUE := nZoomValue

   RETURN // ZoomInit

//***************************************************************************

STATIC PROCEDURE ZoomSet(aZoomOpts, nZoomOpts)

   LOCAL nPos := wZoom.rgZoom.VALUE
   LOCAL nVal

   IF nPos == nZoomOpts
      nVal := INT(wZoom.tbZoomCustom.VALUE)
   ELSE
      nVal := VAL(aZoomOpts[nPos])
   END
   wZoom.RELEASE
   IF nVal >= 2 .AND. nVal <= 6400
      wMain.ebDoc.ZOOM := (nZoomValue := nVal)
      Refresh()
   END

   RETURN // ZoomSet

//***************************************************************************

STATIC PROCEDURE ZoomSelect(lDisplay)

   LOCAL nPos := wMain.coZoom.VALUE
   LOCAL nVal

   IF lDisplay .OR. EMPTY(nPos)
      nVal := INT(VAL(wMain.coZoom.DISPLAYVALUE))
   ELSE
      nVal := VAL(aZoomLabel[nPos])
   END
   IF nVal >= 2 .AND. nVal <= 6400
      wMain.ebDoc.ZOOM := (nZoomValue := nVal)
   END
   Refresh()

   RETURN // ZoomSelect

//***************************************************************************

STATIC PROCEDURE FontForeColor

   LOCAL aGetColor := GETCOLOR(aFontColor, NIL, .N.)

   IF VALTYPE(aGetColor[1]) == 'N'
      wMain.ebDoc.FONTCOLOR := aFontColor := aGetColor
   END

   RETURN // FontForeColor

//***************************************************************************

STATIC PROCEDURE FontBackColor

   LOCAL aGetColor := GETCOLOR(aFontBackColor, NIL, .N.)

   IF VALTYPE(aGetColor[1]) == 'N'
      wMain.ebDoc.FONTBACKCOLOR := aFontBackColor := aGetColor
   END

   RETURN // FontBackColor

//***************************************************************************

STATIC PROCEDURE BackgroundColor

   LOCAL aGetColor := GetColor(aBackgroundColor, NIL, .N.)

   IF VALTYPE(aGetColor[1]) == 'N'
      wMain.ebDoc.BACKGROUNDCOLOR := (aBackgroundColor := aGetColor)
   END

   RETURN // BackgroundColor

//***************************************************************************

STATIC PROCEDURE Shortcuts

   DEFINE WINDOW wShort ;
      AT nShortRow, nShortCol ;
      WIDTH nShortWidth HEIGHT nShortHeight ;
      TITLE 'Shortcut Keys' ;
      ICON 'ShortcutsIcon' ;
      ON SIZE     ShortSize(.N.) ;
      ON MAXIMIZE ShortSize(.Y.) ;
      ON INIT     (EX.wShort.ebText.LOADFILE('Shortcuts', .N., RICHEDITFILEEX_RTF)) ;
      ON RELEASE  ShortExit()

      @ 10,10 RICHEDITBOX ebText ;
              WIDTH 610 ;
              HEIGHT 400 ;
              MAXLENGTH -1 ;
              NOHSCROLL ;
              READONLY ;
              BACKCOLOR YELLOW
      
      ON KEY RETURN ACTION wShort.RELEASE
      ON KEY ESCAPE ACTION wShort.RELEASE

   END WINDOW

   ShortSize(lShortMax)
   ACTIVATE WINDOW wShort

   RETURN // Shortcuts

//***************************************************************************

STATIC PROCEDURE ShortSize(lSetMax)

   IF lSetMax != NIL
      lShortMax := lSetMax
   END
   IF ! lShortMax
      nShortRow    := wShort.ROW
      nShortCol    := wShort.COL
      nShortWidth  := wShort.WIDTH
      nShortHeight := wShort.HEIGHT
   END
   wShort.ebText.WIDTH  := wShort.WIDTH  - 25
   wShort.ebText.HEIGHT := wShort.HEIGHT - 50

   RETURN // ShortSize

//***************************************************************************

STATIC PROCEDURE ShortExit()

   IF ! lShortMax
     nShortRow    := wShort.ROW
     nShortCol    := wShort.COL
     nShortWidth  := wShort.WIDTH
     nShortHeight := wShort.HEIGHT
   END

   RETURN // ShortExit

//***************************************************************************

STATIC PROCEDURE About

   DEFINE WINDOW wAbout ;
      AT 0,0 ;
      WIDTH 450 ;
      HEIGHT 225 ;
      TITLE 'About ' + cTitle ;
      MODAL ;
      NOSIZE

      @  10, 10 IMAGE imProduct ;
                PICTURE 'MainImage'

      @  10,160 LABEL laName ;
                VALUE   cTitle ;
                HEIGHT 35 ;
                WIDTH 280 ;
                FONT 'Arial' ;
                SIZE 24

      @  50,160 LABEL laVersion ;
                VALUE 'Version ' + cVersion ;
                WIDTH 280

      @  70,160 LABEL laCopyright ;
                VALUE cCopyright ;
                WIDTH 280

      @  90,160 LABEL laByline2 ;
                VALUE cByline2 ;
                WIDTH 280

      @ 110,160 LABEL laByline3 ;
                VALUE cByline3 ;
                WIDTH 280

      @ 130,160 HYPERLINK hyProduct ;
                VALUE   'Made with HMG' ;
                ADDRESS cInfoAddr ;
                WIDTH 280

      @ 155,195 BUTTON btOk ;
                CAPTION '&Ok' ;
                ACTION wAbout.RELEASE ;
                WIDTH 55 ;
                HEIGHT 25

      ON KEY RETURN ACTION wAbout.RELEASE
      ON KEY ESCAPE ACTION wAbout.RELEASE
      ON KEY F1     ACTION Shortcuts()

   END WINDOW

   wAbout.btOk.SETFOCUS
   CENTER WINDOW wAbout
   ACTIVATE WINDOW wAbout

   RETURN // About

//***************************************************************************

PROCEDURE MsgDbg(cStat, ...)

   LOCAL aVars := {...}
   LOCAL cName := ''
   LOCAL cType := ''
   LOCAL cVal  := ''
   LOCAL cVars := ''
   LOCAL nVar  := 0
   LOCAL nVars := LEN(aVars)
   LOCAL xVal  := NIL

   FOR nVar := 1 TO nVars STEP 2
      cName := aVars[nVar]
      xVal  := aVars[nVar + 1]
      cType := VALTYPE(xVal)
      // cVal := HB_VALTOEXP(xVal)
      SWITCH cType
      CASE 'C'
      CASE 'M'
         cVal := IF('"' $ xVal, "'" + xVal + "'", '"' + xVal + '"')
         EXIT
      CASE 'N'
         cVal := LTRIM(STR(xVal))
         EXIT
      CASE 'D'
         cVal := 'd"' + LEFT(HB_TSTOSTR(xVal, .Y.), 10) + '"'
         EXIT
      CASE 'T'
         cVal := 't"' + HB_TSTOSTR(xVal, .Y.) + '"'
         EXIT
      CASE 'L'
         cVal := '.' + TRANSFORM(xVal, 'Y') + '.'
         EXIT
      CASE 'A'
         cVal := 'ARRAY(' + LTRIM(STR(LEN(xVal))) + ')'
         EXIT
      CASE 'H'
         cVal := 'HASHN(' + LTRIM(STR(LEN(xVal))) + ')'
         EXIT
      CASE 'O'
         cVal := xVal:CLASSNAME + ' object'
         EXIT
      CASE 'B'
         cVal := '{|_| _}'
         EXIT
      CASE 'S'
         cVal := '@' + xVal:NAME + '()'
         EXIT
      CASE 'P'
         cVal := '<Pointer 0x' + NUMTOHEX( xVal ) + '>'
         EXIT
      CASE 'U'
         cVal := 'NIL'
         EXIT
      OTHERWISE
         cVal := 'Unknown type ' + cType
      END
      cVars += cName + ' = ' + cVal + CRLF
   NEXT

   IF ! MsgYesNo(cVars + CRLF + CRLF + 'Continue?', ;
      IF(EMPTY(cStat), 'Debug', cStat))
      wMain.RELEASE
   END

   RETURN // MsgDbg

//***************************************************************************

