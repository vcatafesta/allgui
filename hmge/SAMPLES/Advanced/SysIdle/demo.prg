#include "hmg.ch"

STATIC n_Secs
STATIC n_Interval

FUNCTION Main

   n_Secs     := SECONDS()
   n_Interval := 60  // 60 seconds

   SET EVENTS FUNCTION TO MYEVENTS

   DEFINE WINDOW Win_1 ;
         AT 0,0 WIDTH 640 HEIGHT 480 ;
         TITLE "Inactivity Test" ;
         MAIN ;
         ON INIT Win_1.Text_1.SetFocus()

      @12, 10 LABEL Label_1 VALUE "Caption_1" WIDTH 80 RIGHTALIGN

      @10, 95 TEXTBOX Text_1 ;
         VALUE 10 ;
         NUMERIC

      @42, 10 LABEL Label_2 VALUE "Caption_2" WIDTH 80 RIGHTALIGN

      @40, 95 TEXTBOX Text_2 ;
         VALUE 20 ;
         NUMERIC

      @72, 10 LABEL Label_3 VALUE "Caption_3" WIDTH 80 RIGHTALIGN

      @70, 95 TEXTBOX Text_3 ;
         VALUE 30 ;
         NUMERIC

      DEFINE STATUSBAR FONT "Tahoma" SIZE 9 KEYBOARD
         STATUSITEM ""
      END STATUSBAR

   END WINDOW

   DEFINE TIMER Timer_1 OF Win_1 INTERVAL 1000 ACTION Aviso()

   Win_1.Center
   Win_1.Activate

   RETURN NIL

FUNCTION Aviso()

   LOCAL _nTotSecs := INT(SECONDS() - n_Secs)

   IF _nTotSecs > n_Interval
      Win_1.Timer_1.enabled := .F.
      MsgInfo("Message to user")
      Win_1.Timer_1.enabled := .T.
   ENDIF

   Win_1.StatusBar.Item(1) := "Idle time elapsed: "+hb_ntos(_nTotSecs)

   RETURN NIL

   #define WM_TIMER        275

FUNCTION MyEvents ( hWnd, nMsg, wParam, lParam )

   IF !Empty(nMsg) .and. nMsg != WM_TIMER
      n_Secs := SECONDS()
   ENDIF

   RETURN Events( hWnd, nMsg, wParam, lParam )

