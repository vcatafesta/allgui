/*
HMG RadioGroup Demo
(c) 2010 Roberto Lopez <mail.box.hmg@gmail.com>
*/

#include "minigui.ch"

FUNCTION Main

   DEFINE WINDOW Win1         ;
         Row   10         ;
         Col   10         ;
         Width   400         ;
         Height   400         ;
         Title   'HMG RadioGroup Demo'   ;
         WindowType MAIN         ;
         On Init   Win1.Center()

      DEFINE MAIN MENU
         DEFINE POPUP "&Properties"
            MenuItem "Change value" action Win1.RadioGroup2.Value := 3
            MenuItem "Get Value" action Msginfo(Win1.RadioGroup2.Value)
            Separator
            MenuItem "Change options" action SetRadioOptions('RadioGroup2','Win1',{"New Item 1","New Item 2","New Item 3","New Item 4"})
            MenuItem "Change Spacing" action ChangeSpacing('RadioGroup2','Win1',32)
            MenuItem "Set horizontal orientation" action sethorizontal('RadioGroup2','Win1')
         End popup
      End Menu

      @ 40,10 RadioGroup RadioGroup1;
         Options {"New 1","New 2","New 3"};
         Width   60;
         Spacing 20;
         Value   2;
         Horizontal;
         Tooltip   'Horizontal Radiogroup';
         on change MsgInfo("OOP Radiogroup 1 Value Changed!")

      @ 110, 10 RadioGroup Radiogroup2;
         Options {"Option 1","Option 2","Option 3","Option 4"} ;
         Width 240;
         Tooltip   'Vertical Radiogroup' ;
         on change {||MsgInfo("OOP Radiogroup 2 Value Changed!")}

   END WINDOW

   ACTIVATE WINDOW Win1

   RETURN NIL

PROCEDURE SetRadioOptions(control,form,aoptions)

   LOCAL i:=getcontrolindex(control,form), n
   LOCAL noptions:=len(_HMG_aControlCaption [i])

   IF len(aoptions) >= noptions
      FOR n := 1 to noptions
         Win1.Radiogroup2.Caption(n) := aoptions[n]
      NEXT n
   ENDIF

   RETURN

PROCEDURE ChangeSpacing(control,form,nspace)

   LOCAL i:=getcontrolindex(control,form)
   LOCAL Row:=_HMG_aControlRow [i]
   LOCAL Col:=_HMG_aControlCol [i]
   LOCAL Width:=_HMG_aControlWidth [i]
   LOCAL Height:=_HMG_aControlHeight [i]

   _HMG_aControlSpacing [i] := nspace

   _SetControlSizePos ( Control, Form, row, col, width, height )

   domethod(Form, Control, 'hide')
   domethod(Form, Control, 'show')

   RETURN

PROCEDURE sethorizontal(control,form)

   LOCAL i:=getcontrolindex(control,form)
   LOCAL aoptions:=_HMG_aControlCaption [i]
   LOCAL nvalue:=_HMG_aControlValue [i]

   domethod(Form, Control, 'release')
   do events

   @ 110, 10 RadioGroup Radiogroup2 of &form ;
      Options aoptions ;
      Horizontal;
      Width 80;
      Spacing 12;
      Value nvalue;
      Tooltip   'Horizontal Radiogroup' ;
      on change {||MsgInfo("OOP Radiogroup 2 Value Changed!")}

   RETURN

