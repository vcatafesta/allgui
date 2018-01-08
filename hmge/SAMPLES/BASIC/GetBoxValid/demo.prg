/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2002-07 Roberto Lopez <harbourminigui@gmail.com>
* GETBOX Valid in Tab demo
* (C) 2007 Jack Daniels <jd10jd10@yahoo.com>
*/

#include "minigui.ch"

FUNCTION main

   SET NAVIGATION EXTENDED

   DEFINE WINDOW form_1 ;
         at 0,0 width 500 height 350 ;
         TITLE "Getbox Valid demo by Jack Daniels" ;
         main ;
         on interactiveclose CheckValids()

      DEFINE TAB tab_1 at 10,10 width 400 height 250
         page "First Tab"
            // GetBox_1 with wrong initial value
            @  50,40 getbox getbox_1 value 60 valid CheckValids()
         END PAGE
         page "Second Tab"
            // TextBox_1 with wrong initial value
            @  50,40 textbox textbox_1 value space(10) on lostfocus CheckValids()
            @ 100,40 textbox textbox_2 on gotfocus CheckValids()
            @ 150,40 textbox textbox_3 on gotfocus CheckValids()
         END PAGE
      END TAB

      DEFINE STATUSBAR keyboard
      END STATUSBAR

   END WINDOW

   form_1.center
   form_1.activate

   RETURN NIL

FUNCTION CheckValids()

   LOCAL retval := .F.

   DO CASE
   CASE form_1.getbox_1.value < 101
      form_1.tab_1.value := 1
      form_1.tab_1.setfocus
      form_1.statusbar.item(1) := "GetBox 1 value must be > 100"
      form_1.getbox_1.setfocus
   CASE empty(form_1.textbox_1.value)
      form_1.tab_1.value := 2
      form_1.tab_1.setfocus
      form_1.statusbar.item(1) := "TextBox 1 value is wrong"
      form_1.textbox_1.setfocus
   OTHERWISE
      retval := .T.
      form_1.statusbar.item(1) := form_1.title
   ENDCASE

   RETURN retval
