/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2002-03 Roberto Lopez <harbourminigui@gmail.com>
* http://harbourminigui.googlepages.com/
*/

ANNOUNCE RDDSYS

#include "minigui.ch"
#include "i_winuser.ch"

PROCEDURE Main()

   SET EVENTS FUNC TO App_OnEvents

   DEFINE WINDOW Form_1 ;
         TITLE 'Demo for Gradient Background' ;
         MAIN ;
         NOMAXIMIZE NOSIZE ;
         ICON 'MAIN'

   END WINDOW

   ON KEY ESCAPE OF Form_1 ACTION ThisWindow.Release()

   ACTIVATE WINDOW Form_1

   RETURN

FUNCTION App_OnEvents( hWnd, nMsg, wParam, lParam )

   LOCAL nResult

   SWITCH nMsg
   CASE WM_ERASEBKGND
      nResult := FillBlue( hWnd )
      EXIT
   CASE WM_PAINT
      nResult := App_OnPaint( hWnd )
      EXIT
   OTHERWISE
      nResult := Events( hWnd, nMsg, wParam, lParam )
   end

   RETURN nResult

FUNCTION App_OnPaint( hWnd )

   LOCAL aRect := { 0, 0, 0, 0 }
   LOCAL hDC, pPS
   LOCAL cRect := ""

   hDC := BeginPaint( hWnd, @pPS )

   DRAW TEXT IN hDC AT 10, 14 ;
      VALUE "Program Setup" ;
      FONT "Verdana" SIZE 24 BOLD ITALIC ;
      FONTCOLOR WHITE TRANSPARENT ;
      ONCE

   DRAW TEXT IN hDC AT Form_1.Height - 54, Form_1.Width - 270 ;
      VALUE "Copyright (c) 2003-2017 by Grigory Filatov" ;
      FONT "Tahoma" SIZE 10 ITALIC ;
      FONTCOLOR WHITE TRANSPARENT ;
      ONCE

   EndPaint( hWnd, pPS )

   RETURN 0

FUNCTION FillBlue( hWnd )

   LOCAL hDC := GetDC( hWnd )
   LOCAL aRect := { 0, 0, 0, 0 }
   LOCAL cx, cy, nSteps, nI, blue := 200
   LOCAL brush

   GetClientRect( hWnd, @aRect )

   cx := aRect[2]
   cy := aRect[4]
   nSteps = (cy - cx) / 5
   aRect[4] := 0

   FOR nI := 0 to nSteps
      aRect[4] += 5

      brush := CreateSolidBrush( 0, 0, blue-- ) ; FillRect( hdc, aRect, brush )
      DeleteObject( brush )

      aRect[2] += 5
   NEXT

   ReleaseDC( hWnd, hDC );

   RETURN 1

