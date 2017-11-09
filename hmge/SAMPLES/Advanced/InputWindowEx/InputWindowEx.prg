/*
* MINIGUI - Harbour Win32 GUI library
* InputWindowEx function
* Copyright 2008 Jozef Rudnicki <j_rudnicki@wp.pl>
*/

#include "minigui.ch"
#define F_LWIDTH  1 // label width
#define F_CTYPE   2 // control type
#define F_CWIDTH  3 // control width
#define F_CHEIGHT 4 // control height
#define F_VALUE   5 // control value ( combobox, textbox numeric, editbox )
#define MAX_F     5

FUNCTION InputWindowEx( cTitle , aLabels , aValues , aFormats ,;
      nRow , nCol, lCenterWindow, aButOKCancelCaptions, bCode )
   LOCAL i, imax, nControlRow, cLabel, cControl, xFormat
   LOCAL nWidth, nHeight, nWinWidth, nWinHeight, nRowHeight:=28  //30

   MEMVAR aResult
   PRIVATE aResult:={}

   lCenterWindow := if( nRow = NIL .and. nCol = NIL, .t., .f. )
   DEFAULT nRow to 0
   DEFAULT nCol to 0
   DEFAULT aButOKCancelCaptions to {}

   IF Len( aButOKCancelCaptions ) = 0
      IF Set ( _SET_LANGUAGE ) == 'ES'
         AAdd( aButOKCancelCaptions, 'Aceptar' )
         AAdd( aButOKCancelCaptions, 'Cancelar' )
      ELSE
         AAdd( aButOKCancelCaptions, '&Ok' )
         AAdd( aButOKCancelCaptions, '&Cancel' )
      ENDIF
   ENDIF

   nWinWidth := 250
   nWinHeight := 0
   imax := Len ( aLabels )
   ASize(aResult,imax)
   FOR i:=1 TO imax
      IF valType ( aFormats[i] ) == 'A' .and. valType(aFormats[i,1])<>'C'
         // InputWindowEx new syntax defaults
         ASize(aFormats[i],MAX_F)
         DEFAULT aFormats[i,F_LWIDTH]  to  90  // default nLabelWidth
         DEFAULT aFormats[i,F_CWIDTH]  to 140  // default nControlWidth
         IF aFormats[i,F_CHEIGHT]==nil         // default nControlHeight
            aFormats[i,F_CHEIGHT]:=nRowHeight
            IF empty(aFormats[i,F_CTYPE])       // label -> empty string or nil
            ELSEIF aFormats[i,F_CTYPE]='EB'
               aFormats[i,F_CHEIGHT]:=3*nRowHeight
            ENDIF
         ENDIF
      ELSE
         // InputWindow syntax convertion
         xFormat:=aFormats[i]
         DO CASE
         CASE aValues[i] == nil                        // Label only
            aFormats[i]:={90,'',140,nRowHeight}
         CASE valType ( aValues[i] ) == 'L'
            aFormats[i]:={90,'CH',140,nRowHeight}       // CheckBox
         CASE valType ( aValues[i] ) == 'D'
            aFormats[i]:={90,'DP',140,nRowHeight}       // DatePicker
         CASE valType ( aValues[i] ) == 'N'
            IF valType ( xFormat ) == 'C'
               aFormats[i]:={90,'TN',140,nRowHeight}     // TextBox Numeric
            ELSEIF valType ( xFormat ) == 'A'
               aFormats[i]:={90,'CB',140,nRowHeight}     // ComboBox
            ENDIF
         CASE valType ( aValues[i] ) == 'C'
            aFormats[i]:={90,'TX',140,nRowHeight}       // TextBox
            IF valType ( xFormat ) == 'N'
               IF xFormat > 32
                  aFormats[i]:={90,'EB',140,3*nRowHeight} // EditBox
               ENDIF
            ENDIF
         CASE valType ( aValues[i] ) == 'M'
            aFormats[i]:={90,'EB',140,3*nRowHeight}     // EditBox
         ENDCASE
         ASize(aFormats[i],MAX_F)
         aFormats[i,F_VALUE]:=xFormat
      ENDIF
      nWinWidth:=max( aFormats[i,F_LWIDTH]+aFormats[i,F_CWIDTH], nWinWidth )
      nWinHeight+=aFormats[i,F_CHEIGHT]
   NEXT i

   nWinHeight += 3*nRowHeight  // place for ok/cancel buttons
   nWinWidth  += 30
   IF nRow + nWinHeight > GetDeskTopHeight()
      nRow := GetDeskTopHeight() - nWinHeight
   ENDIF

   DEFINE WINDOW _InputWindow ;
         AT nRow, nCol ;
         WIDTH nWinWidth ;
         HEIGHT nWinHeight ;
         TITLE cTitle ;
         MODAL NOSIZE NOSYSMENU

      nControlRow := 10
      FOR i:=1 TO imax
         cLabel   := 'Label_' + alltrim(str(i,2,0))
         cControl := 'Control_' + alltrim(str(i,2,0))

         @ nControlRow + 2, 10 LABEL &cLabel OF _InputWindow ;
            VALUE aLabels[i] WIDTH aFormats[i,F_LWIDTH]
         DO CASE
         CASE aValues[i] == nil
            IF valType(aFormats[i,F_VALUE])='C'
               IF 'BOLD'$aFormats[i,F_VALUE]
                  SetProperty('_InputWindow',cLabel,'FONTBOLD',.t.)
               ENDIF
               IF 'ITALIC'$aFormats[i,F_VALUE]
                  SetProperty('_InputWindow',cLabel,'FONTITALIC',.t.)
               ENDIF
               IF 'UNDERLINE'$aFormats[i,F_VALUE]
                  SetProperty('_InputWindow',cLabel,'FONTUNDERLINE',.t.)
               ENDIF
               IF 'STRIKEOUT'$aFormats[i,F_VALUE]
                  SetProperty('_InputWindow',cLabel,'FONTSTRIKEOUT',.t.)
               ENDIF
            ENDIF
            SetProperty('_InputWindow',cLabel,'WIDTH',aFormats[i,F_LWIDTH]+aFormats[i,F_CWIDTH])
         CASE aFormats[i,F_CTYPE] = 'CH'
            @ nControlRow, 10+aFormats[i,F_LWIDTH] CHECKBOX &cControl OF _InputWindow ;
               CAPTION '' VALUE aValues[i]
         CASE aFormats[i,F_CTYPE] = 'DP'
            @ nControlRow, 10+aFormats[i,F_LWIDTH] DATEPICKER &cControl OF _InputWindow ;
               VALUE aValues[i] WIDTH aFormats[i,F_CWIDTH]
         CASE aFormats[i,F_CTYPE] = 'CB'
            @ nControlRow, 10+aFormats[i,F_LWIDTH] COMBOBOX &cControl OF _InputWindow ;
               ITEMS aFormats[i,F_VALUE] ;
               VALUE aValues[i] WIDTH aFormats[i,F_CWIDTH] ;
               FONT 'Arial' SIZE 10
         CASE aFormats[i,F_CTYPE] = 'TN'
            IF at( '.' , aFormats[i,F_VALUE] ) > 0
               @ nControlRow, 10+aFormats[i,F_LWIDTH] TEXTBOX &cControl OF _InputWindow ;
                  VALUE aValues[i] WIDTH aFormats[i,F_CWIDTH] ;
                  FONT 'Arial' SIZE 10 ;
                  NUMERIC INPUTMASK aFormats[i,F_VALUE]
            ELSE
               @ nControlRow, 10+aFormats[i,F_LWIDTH] TEXTBOX &cControl OF _InputWindow ;
                  VALUE aValues[i] WIDTH aFormats[i,F_CWIDTH] ;
                  FONT 'Arial' SIZE 10 ;
                  MAXLENGTH Len(aFormats[i,F_VALUE]) NUMERIC
            ENDIF
         CASE aFormats[i,F_CTYPE] = 'TX'
            @ nControlRow, 10+aFormats[i,F_LWIDTH] TEXTBOX &cControl OF _InputWindow ;
               VALUE aValues[i] WIDTH aFormats[i,F_CWIDTH] ;
               FONT 'Arial' SIZE 10 ;
               MAXLENGTH aFormats[i,F_VALUE]
         CASE aFormats[i,F_CTYPE] = 'EB'
            IF aFormats[i,F_CHEIGHT]>nRowHeight
               SetProperty('_InputWindow',cLabel,'HEIGHT',aFormats[i,F_CHEIGHT])
               @ nControlRow, 10+aFormats[i,F_LWIDTH] EDITBOX &cControl OF _InputWindow ;
                  WIDTH aFormats[i,F_CWIDTH] ;
                  HEIGHT aFormats[i,F_CHEIGHT] ;
                  VALUE aValues[i] ;
                  FONT 'Arial' SIZE 10
            ELSE
               @ nControlRow, 10+aFormats[i,F_LWIDTH] EDITBOX &cControl OF _InputWindow ;
                  WIDTH aFormats[i,F_CWIDTH] ;
                  HEIGHT aFormats[i,F_CHEIGHT] ;
                  VALUE aValues[i] ;
                  FONT 'Arial' SIZE 10 ;
                  MAXLENGTH aFormats[i,F_VALUE]
            ENDIF
         ENDCASE
         nControlRow := nControlRow + aFormats[i,F_CHEIGHT]
      NEXT i
      i:=(nWinHeight-nControlRow-2*nRowHeight)/2
      @ nControlRow+i, nWinWidth - 260 BUTTON BUTTON_1 OF _InputWindow ;
         CAPTION aButOKCancelCaptions[1] ;
         ACTION xInputWindowOk()
      @ nControlRow+i, nWinWidth - 130 BUTTON BUTTON_2 OF _InputWindow ;
         CAPTION aButOKCancelCaptions[2] ;
         ACTION xInputWindowCancel()
      IF valType(bCode)='B'
         Eval(bCode)
      ENDIF
   END WINDOW

   IF lCenterWindow
      CENTER WINDOW _InputWindow
   ENDIF
   ACTIVATE WINDOW _InputWindow

   RETURN ( aResult )

STATIC FUNCTION xInputWindowOk()

   LOCAL i , cControlName
   MEMVAR aResult

   FOR i := 1 to len (aResult)
      cControlName := 'Control_' + Alltrim ( Str ( i , 0 ) )
      IF _IsControlDefined(cControlName,'_InputWindow')
         aResult[i] := _GetValue ( cControlName , '_InputWindow' )
      ELSE
         aResult[i] := nil
      ENDIF
   NEXT i
   RELEASE WINDOW _InputWindow

   RETURN NIL

STATIC FUNCTION xInputWindowCancel()

   LOCAL i
   MEMVAR aResult

   FOR i := 1 to len (aResult)
      aResult[i] := nil
   NEXT i
   RELEASE WINDOW _InputWindow

   RETURN NIL

