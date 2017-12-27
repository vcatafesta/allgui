/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
* http://harbourminigui.googlepages.com/
*/

#include "minigui.ch"

FUNCTION Main

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH 366 + GetBorderWidth() ;
         HEIGHT 300 + GetTitleHeight() + 2 * GetBorderHeight() ;
         TITLE "MiniGUI ProgressBar Demo" ;
         MAIN ;
         FONT "Arial" SIZE 10

      @ 000,031 PROGRESSBAR Progress_1 ;
         RANGE 0 , 100       ;
         WIDTH 300          ;
         HEIGHT 26          ;
         TOOLTIP "ProgressBar Horizontal" ;
         BACKCOLOR GREEN FORECOLOR RED

      @ 274,031 PROGRESSBAR Progress_2 ;
         RANGE 0 , 100       ;
         WIDTH 300          ;
         HEIGHT 26          ;
         TOOLTIP "ProgressBar Horizontal Smooth" ;
         SMOOTH BACKCOLOR RED FORECOLOR YELLOW

      @ 000,000 PROGRESSBAR Progress_3 ;
         RANGE 0 , 100       ;
         WIDTH 30          ;
         HEIGHT 300          ;
         TOOLTIP "ProgressBar Vertical" ;
         VERTICAL BACKCOLOR WHITE FORECOLOR BLUE

      @ 000,332 PROGRESSBAR Progress_4 ;
         RANGE 0 , 100       ;
         WIDTH 30          ;
         HEIGHT 300          ;
         TOOLTIP "ProgressBar Vertical Smooth" ;
         VERTICAL ;
         SMOOTH BACKCOLOR PURPLE FORECOLOR WHITE

      @ 120,155 TEXTBOX TextBox_1 ;
         VALUE " 50 %" ;
         WIDTH 60 ;
         MAXLENGTH 5

      @ 150,80 SLIDER Slider_1 ;
         RANGE 0 , 100 ;
         VALUE 50 ;
         WIDTH 200 ;
         HEIGHT 50 ;
         ON CHANGE {||Slider_Change()}

   END WINDOW

   Form_1.Progress_1.Value := 50
   Form_1.Progress_2.Value := 50
   Form_1.Progress_3.Value := 50
   Form_1.Progress_4.Value := 50

   Form_1.TextBox_1.Enabled := .f.

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

   RETURN NIL

FUNCTION Slider_Change

   LOCAL nValue := Form_1.Slider_1.Value

   Form_1.TextBox_1.Value := Str(nValue,3)+" %"

   Form_1.Progress_1.Value := nValue
   Form_1.Progress_2.Value := nValue
   Form_1.Progress_3.Value := nValue
   Form_1.Progress_4.Value := nValue

   RETURN NIL
