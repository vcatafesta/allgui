/*
* MINIGUI - Harbour Win32 GUI library Demo
*/

#include "minigui.ch"

FUNCTION Main

   DEFINE WINDOW Form_1 ;
         AT 0, 0 WIDTH 400 HEIGHT 300 ;
         MAIN ;
         TITLE "Edit Controls Cue Banner Demo"

      DEFINE TEXTBOX Text_1
         ROW    10
         COL    10
         WIDTH  200
         PLACEHOLDER " Enter your name here"
      END TEXTBOX

      DEFINE TEXTBOX Text_2
         ROW    40
         COL    10
         WIDTH  200
         PLACEHOLDER " Enter address here"
      END TEXTBOX

      DEFINE COMBOBOX Combo_1
         ROW    70
         COL    10
         WIDTH  200
         HEIGHT 100
         ITEMS {"Item 1","Item 2","Item 3"}
         PLACEHOLDER " Select an item"
         DISPLAYEDIT .T.
      END COMBOBOX

      DEFINE SPINNER Spinner_1
         ROW    100
         COL    10
         WIDTH  200
         HEIGHT 24
         RANGEMIN 1
         RANGEMAX 10
         PLACEHOLDER " Spinner CueBanner"
      END SPINNER

      DEFINE BUTTON btn_1
         row 10
         col 220
         height 24
         caption "Get CueBanner"
         action MsgInfo( Form_1.Text_1.CueBanner )
      END BUTTON

      DEFINE BUTTON btn_2
         row 40
         col 220
         height 24
         caption "Get CueBanner"
         action MsgInfo( GetProperty( "Form_1", "Text_2", "CueBanner" ) )
      END BUTTON

      DEFINE BUTTON btn_3
         row 70
         col 220
         height 24
         caption "Get CueBanner"
         action MsgInfo( Form_1.Combo_1.CueBanner )
      END BUTTON

      DEFINE BUTTON btn_4
         row 100
         col 220
         height 24
         caption "Get CueBanner"
         action MsgInfo( Form_1.Spinner_1.CueBanner )
      END BUTTON

   END WINDOW

   Form_1.Center()
   Form_1.Activate()

   RETURN NIL
