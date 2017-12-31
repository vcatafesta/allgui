/*
* Harbour MiniGUI Accelerators Demo
* (c) 2017 P.Ch.
*/

#include "minigui.ch"
#include "i_winuser.ch"

#include "demo.ch"

MEMVAR hMenu, hAccel

FUNCTION Main()

   SET EVENTS FUNCTION TO App_OnEvents

   DEFINE WINDOW Win_1 ;
         CLIENTAREA 400, 400 ;
         TITLE 'Accelerators Demo' ;
         MAIN ;
         ON INIT Win1_OnInit( ThisWindow.Handle ) ;
         ON RELEASE DestroyMenu( hMenu )

   END WINDOW

   Win_1.Center
   Win_1.Activate

   RETURN 0

STATIC PROCEDURE Win1_OnInit( hWnd )

   PUBLIC hMenu  := LoadMenu( Nil, 'MainMenu' )
   PUBLIC hAccel := LoadAccelerators( Nil, 'FontAccel' )

   IF ! Empty( hMenu )
      SetMenu( hWnd, hMenu )
   ENDIF

#if 0  // normal behavior
   IF ! Empty( hAccel )
      SetAcceleratorTable( hWnd, hAccel )
   ENDIF
#else  // test behavior
   TestSomeFuncs( hAccel, hWnd )
#endif

   RETURN

FUNCTION App_OnEvents( hWnd, nMsg, wParam, lParam )

   LOCAL nResult

   SWITCH nMsg
   CASE WM_COMMAND
      SWITCH LoWord( wParam )
      CASE IDM_REGULAR
      CASE IDM_BOLD
      CASE IDM_ITALIC
      CASE IDM_ULINE
         MsgInfo( "IDM_:" + hb_NtoS( LoWord( wParam ) ), ;
            "From a " + iif( 0 == HiWord( wParam ), 'Menu', 'Accelerator' ) )
         nResult := 0
         EXIT
      OTHERWISE
         nResult := Events( hWnd, nMsg, wParam, lParam )
      END
      EXIT
   OTHERWISE
      nResult := Events( hWnd, nMsg, wParam, lParam )
   END SWITCH

   RETURN nResult

STATIC PROCEDURE TestSomeFuncs( hAccel, hWnd )

   LOCAL  aAccel
   LOCAL  hAccel2, pAccel := 0
   LOCAL  nLen, cmd

   nLen := CopyAcceleratorTable( hAccel, @pAccel )

   // stage 1
   IF nLen > 0 .and. ! Empty( pAccel )
      hAccel2 := CreateAcceleratorTable( pAccel, nLen )

      IF ! Empty( hAccel2 ) .and. Empty( pAccel )
         IF DestroyAcceleratorTable( hAccel )
            hAccel := hAccel2
         ENDIF
      ENDIF
   ENDIF

   // stage 2
   IF ! Empty( hAccel )
      aAccel := AcceleratorTable2Array( hAccel )

      IF ! Empty( aAccel )
         hAccel2 := Array2AcceleratorTable( aAccel )

         IF ! Empty( hAccel2 )
            IF DestroyAcceleratorTable( hAccel )
               hAccel := hAccel2
            ENDIF
         ENDIF
      ENDIF
   ENDIF

   SetAcceleratorTable( hWnd, hAccel )

   IF ( nLen := Len( aAccel ) ) > 0
      ShowVirtKey( aAccel[nLen] )

      cmd  := aAccel[nLen][3]
      PostMessage( hWnd, WM_COMMAND, MAKELONG( cmd, 1 ), 0 )
   ENDIF

   RETURN

#define FALT        0x10
#define FCONTROL    0x08
#define FNOINVERT   0x02
#define FSHIFT      0x04
#define FVIRTKEY    1

STATIC PROCEDURE ShowVirtKey( aAccel )

   LOCAL cAlt
   LOCAL cControl
   LOCAL cShift
   LOCAL cMsg     := ''
   LOCAL nVirtKey := aAccel[1]

   IF hb_bitAnd( nVirtKey, FALT ) != 0
      cAlt := "ALT"
      cMsg := cAlt
   ENDIF

   IF hb_bitAnd( nVirtKey, FCONTROL ) != 0
      cControl := "CTRL"
      cMsg     += Iif( Empty( cMsg ), cControl, '+' + cControl )
   ENDIF

   IF hb_bitAnd( nVirtKey, FSHIFT ) != 0
      cShift := "SHIFT"
      cMsg   += Iif( Empty( cMsg ), cShift, '+' + cShift )
   ENDIF

   IF hb_bitAnd( nVirtKey, FVIRTKEY ) != 0
      cMsg += Iif( Empty( cMsg ), hb_UChar( aAccel[2] ), '+' + hb_UChar( aAccel[2] ) )
   ENDIF

   MsgInfo( "KEYSTROKE:" + cMsg + CRLF + "IDM_:" + hb_NtoS( aAccel[3]), "Simulating a keystroke" )

   RETURN
