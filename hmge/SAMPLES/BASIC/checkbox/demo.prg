/*
HMG Checkbox Demo
(c) 2010 Roberto Lopez
*/

#include "minigui.ch"

FUNCTION Main

   SET Font To "Tahoma", 9

   DEFINE WINDOW Win1         ;
         ROW   10         ;
         COL   10         ;
         WIDTH   400         ;
         HEIGHT   300         ;
         TITLE   'HMG Checkbox Demo'   ;
         WindowType MAIN

      DEFINE LABEL Label1
         ROW 10
         COL 10
         WIDTH 300
         VALUE 'This is for status!'
         BACKCOLOR {200,200,200}
         ALIGNMENT Center
         ALIGNMENT VCenter
      END LABEL

      DEFINE CHECKBOX Check1
         ROW      40
         COL      10
         VALUE      .F.
         CAPTION      'Simple CheckBox'
         WIDTH      120
         OnChange MsgInfo( "CheckBox 1 Value is Changed!" )
      END CHECKBOX

      DEFINE CHECKBOX Check2
         ROW      70
         COL      10
         WIDTH      280
         VALUE      .F.
         FONTNAME   "Arial"
         FontSize   12
         FONTBOLD   .t.
         FONTITALIC   .t.
         FontUnderline   .t.
         FontStrikeOut   .t.
         CAPTION      'CheckBox with Font Properties'
         OnChange MsgInfo( "CheckBox 2 Value is Changed!" )
      END CHECKBOX

      DEFINE CHECKBOX Check3
         ROW      120
         COL      10
         WIDTH      250
         VALUE      .F.
         CAPTION      'CheckBox with OnGot/LostFocus Events'
         OnGotFocus { || Win1.Label1.Value := "CheckBox GotFocus!" }
         OnLostFocus { || Win1.Label1.Value := "CheckBox LostFocus!" }
      END CHECKBOX

      DEFINE BUTTON Button1
         ROW   150
         COL   40
         WIDTH   140
         HEIGHT   28
         CAPTION 'Change Event Block!'
         OnClick Win1.Check1.OnChange := { || MsgInfo( "Event Block of 'On Change' event of Checkbox 1 is Changed dynamically!" ) }
      END BUTTON

      DEFINE BUTTON Button2
         ROW   180
         COL   40
         WIDTH   140
         HEIGHT   28
         CAPTION 'Win1.Check1.Value'
         OnClick MsgInfo( Win1.Check1.value )
      END BUTTON

   END WINDOW

   CENTER WINDOW Win1
   ACTIVATE WINDOW Win1

   RETURN NIL
