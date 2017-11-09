/*
* MINIGUI - Harbour Win32 GUI library Demo
*/

#include "minigui.ch"

FUNCTION Main

   DEFINE WINDOW tabsample at 0,0 width 400 height 300 title 'Add control test' main

      DEFINE TAB tab1 at 10,10 width 370 height 200

         DEFINE PAGE 'Page1'

            DEFINE BUTTON b1
               row 30
               col 10
               caption 'Press here to add a control'
               width 180
               action addnewcontrols({'lbl1','text1'})
            END BUTTON

         END PAGE

         DEFINE PAGE 'Page2'

            DEFINE BUTTON b2
               row 30
               col 10
               caption 'Press here to add a control'
               width 180
               action addnewcontrol2('btn1')
            END BUTTON

         END PAGE

      END TAB

      on key escape action thiswindow.release()

   END WINDOW

   tabsample.center
   tabsample.activate

   RETURN NIL

FUNCTION addnewcontrols(actrl)

   LOCAL c1, c2

   c1 := actrl[1]
   c2 := actrl[2]

   IF iscontroldefined(&c1,tabsample)
      tabsample.&(c1).release
   ENDIF

   DEFINE LABEL &c1
      parent tabsample
      row 50
      col 10
      width 40
      value 'label'
   END LABEL

   IF iscontroldefined(&c2,tabsample)
      tabsample.&(c2).release
   ENDIF

   DEFINE TEXTBOX &c2
      parent tabsample
      row 50
      col 50
      width 100
   END TEXTBOX

   tabsample.tab1.addcontrol(c1,1,84,10)
   tabsample.tab1.addcontrol(c2,1,80,50)

   RETURN NIL

FUNCTION addnewcontrol2(ctrl)

   IF iscontroldefined(&ctrl,tabsample)
      tabsample.&(ctrl).release
   ENDIF

   DEFINE BUTTONex &ctrl
      parent tabsample
      row 10
      col 10
      width 180
      caption 'Click me'
      action MsgBox('Button action','Result')
   END BUTTONex

   tabsample.tab1.addcontrol(ctrl,2,80,10)

   RETURN NIL

