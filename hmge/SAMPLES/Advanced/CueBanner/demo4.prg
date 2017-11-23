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
         TITLE "BtnTextBox CueBanner Demo" ;
         MAIN ;
         NOMAXIMIZE NOSIZE ;
         FONT "Tahoma" SIZE 8

      DEFINE LABEL lbl_1
         row 10
         col 10
         value "Name:"
         autosize .t.
      END LABEL
      define btntextbox name
      row 26
      col 10
      width 318
      height 21
      cuebanner "Enter your full name here"
      action msgbox('Click!')
   end btntextbox
   DEFINE FRAME frm_1
      row 54
      col 10
      width 318
      height 64
      caption "Cue banner"
   END FRAME
   DEFINE LABEL lbl_2
      row 70
      col 22
      value "Cue text:"
      autosize .t.
   END LABEL
   DEFINE TEXTBOX text
      row 86
      col 22
      width 167
      height 21
   END TEXTBOX
   DEFINE BUTTON btn_1
      row 86
      col 198
      width 58
      height 21
      caption "Set"
      action btnSet_click()
   END BUTTON
   DEFINE BUTTON btn_2
      row 86
      col 262
      width 56
      height 21
      caption "Clear"
      action cue.name.cuebanner := " "
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
