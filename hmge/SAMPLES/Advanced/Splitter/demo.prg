/*
* Harbour MiniGUI (H)orizontal Splitter Demo
* Copyright 2017 P.Chornyj <myorg63@mail.ru>
*/
ANNOUNCE RDDSYS

#include "minigui.ch"
#include "i_winuser.ch"

#include "demo.ch"

#xtranslate RECTWIDTH ( <aRect> ) => ( <aRect>\[3\] - <aRect>\[1\] )
#xtranslate RECTHEIGHT( <aRect> ) => ( <aRect>\[4\] - <aRect>\[2\] )

PROCEDURE main()

   LOCAL aRect := { 0, 0, 0, 0 }
   LOCAL w, h, nBorder, nYPos

   SET events func to App_OnEvents

   DEFINE WINDOW  Form_1 ;
         clientarea  400, 200 ;
         title       'HSplitter demo' ;
         windowtype  MAIN ;
         on release  HSplitter_Release( Form_1.Handle )

      GetClientRect( This.Handle, @aRect )
      w := RECTWIDTH ( aRect )
      h := RECTHEIGHT( aRect )

      nYPos   := Int( 0.5 * h  )
      nBorder := 4

      @ 0, 0 editbox EditBox_1 ;
         width    w ;
         height   nYPos ;
         value    LOREMIPSUM_L ;
         tooltip  'EditBox_1' ;
         nohscroll

      @ nYPos + nBorder, 0 editbox EditBox_2 ;
         width    w ;
         height   h - ( nYPos + nBorder ) ;
         value    LOREMIPSUM_R ;
         tooltip  'EditBox_2' ;
         nohscroll
   END WINDOW

   // Add Horizontal Splitter to Form_1
   HSplitter_Init( Form_1.Handle, { Form_1.EditBox_1.Handle, Form_1.EditBox_2.Handle }, nYPos, nBorder )

   Form_1.Cursor := IDC_SIZENS

   Form_1.Center()
   Form_1.Activate()

   RETURN

   // FUNCTION App_OnEvents( hwnd, msg, wParam, lParam )
   #translate $_ => ( hwnd, msg, wParam, lParam )

FUNCTION App_OnEvents$_

   LOCAL nRes

   SWITCH msg
   CASE WM_LBUTTONDOWN
      nRes := HSplitter_OnLButtonDown$_
      EXIT

   CASE WM_LBUTTONUP
      nRes := HSplitter_OnLButtonUp$_
      EXIT

   CASE WM_MOUSEMOVE
      nRes := HSplitter_OnMouseMove$_
      EXIT

   CASE WM_SIZE
      nRes := HSplitter_OnSize$_
      EXIT
   OTHERWISE
      nRes := Events$_
   end

   RETURN nRes

