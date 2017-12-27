/*
HMG Checkbox Demo
(c) 2010 Roberto Lopez
*/

#include "minigui.ch"

FUNCTION Main

   SET Font To "Tahoma", 9

   DEFINE WINDOW Win1         ;
         Row   10         ;
         Col   10         ;
         Width   400         ;
         Height   300         ;
         Title   'HMG Checkbox Demo'   ;
         WindowType MAIN

      DEFINE LABEL Label1
         Row 10
         Col 10
         Width 300
         Value 'This is for status!'
         BackColor {200,200,200}
         Alignment Center
         Alignment VCenter
      END LABEL

      DEFINE CHECKBOX Check1
         Row      40
         Col      10
         Value      .F.
         Caption      'Simple CheckBox'
         Width      120
         OnChange MsgInfo( "CheckBox 1 Value is Changed!" )
      END CHECKBOX

      DEFINE CHECKBOX Check2
         Row      70
         Col      10
         Width      280
         Value      .F.
         FontName   "Arial"
         FontSize   12
         FontBold   .t.
         FontItalic   .t.
         FontUnderline   .t.
         FontStrikeOut   .t.
         Caption      'CheckBox with Font Properties'
         OnChange MsgInfo( "CheckBox 2 Value is Changed!" )
      END CHECKBOX

      DEFINE CHECKBOX Check3
         Row      120
         Col      10
         Width      250
         Value      .F.
         Caption      'CheckBox with OnGot/LostFocus Events'
         OnGotFocus { || Win1.Label1.Value := "CheckBox GotFocus!" }
         OnLostFocus { || Win1.Label1.Value := "CheckBox LostFocus!" }
      END CHECKBOX

      DEFINE BUTTON Button1
         Row   150
         Col   40
         Width   140
         Height   28
         Caption 'Change Event Block!'
         OnClick Win1.Check1.OnChange := { || MsgInfo( "Event Block of 'On Change' event of Checkbox 1 is Changed dynamically!" ) }
      END BUTTON

      DEFINE BUTTON Button2
         Row   180
         Col   40
         Width   140
         Height   28
         Caption 'Win1.Check1.Value'
         OnClick MsgInfo( Win1.Check1.value )
      END BUTTON

   END WINDOW

   CENTER WINDOW Win1
   ACTIVATE WINDOW Win1

   RETURN NIL
