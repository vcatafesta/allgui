/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2016 SergKis - http://clipper.borda.ru
* Design and color were made by Verchenko Andrey <verchenkoag@gmail.com>
*/

#include "minigui.ch"
#include "tsbrowse.ch"

FUNCTION TBrw_Create( ControlName, ParentForm, nRow, nCol, nWidth, nHeight, uAlias, lCell, FontName, FontSize, Backcolor )

   LOCAL oBrw, nHgt := 0, nWdt := 0, hWnd, aRect := {0,0,0,0}
   LOCAL aImages := NIL, aHeaders := NIL, aWidths := NIL, bFields := NIL, Value := 1
   LOCAL tooltip := NIL, change := NIL, bDblclick := NIL, aHeadClick := NIL, gotfocus := NIL, lostfocus := NIL
   LOCAL Delete := .F., lNogrid := .F., aJust := NIL, HelpId := NIL
   LOCAL bold := .F., italic := .F., underline := .F., strikeout := .F.
   LOCAL break := .F., fontcolor := NIL
   LOCAL lock := .F., nStyle := NIL, appendable := .F., readonly := NIL
   LOCAL valid := NIL, validmessages := NIL, aColors := NIL, uWhen := NIL, nId := NIL, aFlds := NIL, cMsg := NIL
   LOCAL lRePaint := .T., lEnum := .F., lAutoSearch := .F., uUserSearch := NIL
   LOCAL lAutoFilter := .F., uUserFilter := NIL, aPicture := NIL, lTransparent := .F.
   LOCAL uSelector := NIL, lAutoCol := .F., aColSel := NIL, lEditable := .F.

   DEFAULT nRow       := 0,                    ;
      nCol       := 0,                    ;
      nWidth     := 0,                    ;
      nHeight    := 0,                    ;
      lCell      := .T.,                  ;
      backcolor  := NIL,                  ;
      ParentForm := _HMG_ThisFormName,    ;
      FontName   := _HMG_DefaultFontName, ;
      FontSize   := _HMG_DefaultFontSize

   hWnd := GetFormHandle(ParentForm)

   GetClientRect(hWnd, aRect)

   IF nWidth  < 0                                         // ������ ����������
      nWdt   := nWidth
      nWidth := 0
   ENDIF

   IF nWidth == 0                                         // ��������� ������
      nWidth := aRect[3]
   ENDIF

   IF nHeight < 0                                         // ������ ����������
      nHgt    := nHeight
      nHeight := 0
   ENDIF

   IF nHeight == 0                                        // ��������� ������
      nHeight := aRect[4] - nRow
   ENDIF

   IF nHgt < 0; nHeight += nHgt                           // ��������� ������
   ENDIF

   IF nWdt < 0; nWidth  += nWdt                           // ��������� ������
   ENDIF

   oBrw := _DefineTBrowse( ControlName,   ;
      ParentForm,    ;
      nCol,          ;
      nRow,          ;
      nWidth,        ;
      nHeight,       ;
      aHeaders,      ;
      aWidths,       ;
      bFields,       ;
      value,         ;
      fontname,      ;
      fontsize,      ;
      tooltip,       ;
      change,        ;
      bDblclick,     ;
      aHeadClick,    ;
      gotfocus,      ;
      lostfocus,     ;
      uAlias,        ;
      Delete,        ;
      lNogrid,       ;
      aImages,       ;
      aJust,         ;
      HelpId,        ;
      bold,          ;
      italic,        ;
      underline,     ;
      strikeout,     ;
      break,         ;
      backcolor,     ;
      fontcolor,     ;
      lock,          ;
      lCell,         ;
      nStyle,        ;
      appendable,    ;
      readonly,      ;
      valid,         ;
      validmessages, ;
      aColors,       ;
      uWhen,         ;
      nId,           ;
      aFlds,         ;
      cMsg,          ;
      lRePaint,      ;
      lEnum,         ;
      lAutoSearch,   ;
      uUserSearch,   ;
      lAutoFilter,   ;
      uUserFilter,   ;
      aPicture,      ;
      lTransparent,  ;
      uSelector,     ;
      lEditable,     ;
      lAutoCol,      ;
      aColSel )

   oBrw:nClrLine    := COLOR_GRID
   oBrw:nWheelLines := 1
   oBrw:lNoHScroll  := .T.
   oBrw:lNoMoveCols := .T.
   oBrw:lNoLiteBar  := .F.
   oBrw:lNoResetPos := .F.
   oBrw:lPickerMode := .F.              // usual date format
   oBrw:nFireKey    := VK_F4            // set key VK_F4, default is VK_F2

   RETURN oBrw

FUNCTION TBrw_Show( oBrw, nDelta )

   _EndTBrowse()

   IF hb_IsObject(oBrw)
      TBrw_NoHoles( oBrw, nDelta )
      oBrw:nHeightHead -= 1
   ENDIF

   RETURN NIL

FUNCTION TBrw_Obj( cTbrw, cForm )

   LOCAL oBrw, i

   DEFAULT cForm := _HMG_ThisFormName

   IF ( i := GetControlIndex(cTBrw, cForm) ) > 0
      oBrw:= _HMG_aControlIds [ i ]
   ENDIF

   RETURN oBrw

FUNCTION TBrw_NoHoles( oBrw, nDelta, lSet )

   LOCAL nI, nK, nHeight, nHole

   DEFAULT nDelta := 1, lSet := .T.

   nHole := oBrw:nHeight - oBrw:nHeightHead - oBrw:nHeightSuper - ;
      oBrw:nHeightFoot - oBrw:nHeightSpecHd - ;
      If( oBrw:lNoHScroll, 0, GetHScrollBarHeight() )

   nHole   -= ( Int( nHole / oBrw:nHeightCell ) * oBrw:nHeightCell )
   nHole   -= nDelta
   nHeight := nHole

   IF lSet

      nI := If( oBrw:nHeightSuper  > 0, 1, 0 ) + ;
         If( oBrw:nHeightHead   > 0, 1, 0 ) + ;
         If( oBrw:nHeightSpecHd > 0, 1, 0 ) + ;
         If( oBrw:nHeightFoot   > 0, 1, 0 )

      IF nI > 0                          // ���� ���������

         nK := int( nHole / nI )         // �� nI - ��������� �������� �����

         IF oBrw:nHeightFoot   > 0
            oBrw:nHeightFoot   += nK
            nHole              -= nK
         ENDIF
         IF oBrw:nHeightSuper  > 0
            oBrw:nHeightSuper  += nK
            nHole              -= nK
         ENDIF
         IF oBrw:nHeightSpecHd > 0
            oBrw:nHeightSpecHd += nK
            nHole              -= nK
         ENDIF
         IF oBrw:nHeightHead   > 0
            oBrw:nHeightHead   += nHole
         ENDIF

      ELSE             // ��� ����������, ����� ��������� ������ tsb �� ������ nHole

         SetProperty(oBrw:cParentWnd, oBrw:cControlName, "Height", ;
            GetProperty(oBrw:cParentWnd, oBrw:cControlName, "Height") - nHole)

      ENDIF

      oBrw:Display()

   ENDIF

   RETURN nHeight
