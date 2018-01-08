/*
* MINIGUI - Harbour Win32 GUI library Demo
*/

#include "minigui.ch"

FUNCTION Main

   LOCAL nWidth := 340 + GetBorderWidth() - iif(IsSeven(), 2, 0)
   LOCAL nHeight := 127 + GetTitleHeight() + GetBorderHeight() - iif(IsSeven(), 2, 0)

   DEFINE WINDOW cue ;
         AT 0,0 ;
         WIDTH nWidth ;
         HEIGHT nHeight ;
         TITLE "TextBox CueBanner Demo" ;
         MAIN ;
         NOMAXIMIZE NOSIZE ;
         FONT "Tahoma" SIZE 8

      DEFINE LABEL lbl_1
         ROW 10
         COL 10
         VALUE "Name:"
         autosize .t.
      END LABEL
      DEFINE TEXTBOX name
         ROW 26
         COL 10
         WIDTH 318
         HEIGHT 21
         cuebanner "Enter your full name here"
      END TEXTBOX
      DEFINE FRAME frm_1
         ROW 54
         COL 10
         WIDTH 318
         HEIGHT 64
         CAPTION "Cue banner"
      END FRAME
      DEFINE LABEL lbl_2
         ROW 70
         COL 22
         VALUE "Cue text:"
         autosize .t.
      END LABEL
      DEFINE TEXTBOX text
         ROW 86
         COL 22
         WIDTH 167
         HEIGHT 21
      END TEXTBOX
      DEFINE BUTTON btn_1
         ROW 86
         COL 198
         WIDTH 58
         HEIGHT 21
         CAPTION "Set"
         ACTION btnSet_click()
      END BUTTON
      DEFINE BUTTON btn_2
         ROW 86
         COL 262
         WIDTH 56
         HEIGHT 21
         CAPTION "Clear"
         ACTION cue.name.cuebanner := " "
      END BUTTON

   END WINDOW

   cue.text.setfocus()

   cue.center
   cue.activate

   RETURN NIL

FUNCTION btnSet_click()

   LOCAL ctext := alltrim( cue.text.value )

   IF empty(ctext)
      MsgAlert("Please specify the cue text.", "Text CueBanner demo")
   ELSE
      cue.name.cuebanner := ctext
   ENDIF

   RETURN NIL
