/*
* MINIGUI - Harbour Win32 GUI library
* Copyright 2002-2008 Roberto Lopez <harbourminigui@gmail.com>
* http://harbourminigui.googlepages.com/
*/

#include "minigui.ch"

FUNCTION Main()

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH 200 ;
         HEIGHT 200 ;
         MAIN ;
         TITLE 'CheckButton Test'

      DEFINE MAIN MENU
         POPUP 'Test'
            ITEM 'Disable button 1' ACTION Form_1.Button_1.Enabled := .f.
            ITEM 'Enable button 1'  ACTION Form_1.Button_1.Enabled := .t.
            SEPARATOR
            ITEM 'Disable button 2' ACTION Form_1.Button_2.Enabled := .f.
            ITEM 'Enable button 2'  ACTION Form_1.Button_2.Enabled := .t.
         END POPUP
      END MENU

      @ 20,70 CHECKBUTTON Button_1 CAPTION "Button 1" WIDTH 60 HEIGHT 50 ;
         VALUE .T. ON CHANGE toggle(1)
      @ 70,70 CHECKBUTTON Button_2 CAPTION "Button 2" WIDTH 60 HEIGHT 50 ;
         ON CHANGE toggle(2)

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

   RETURN NIL

FUNCTION Toggle(n)

   IF n == 1
      Form_1.Button_2.Value := !Form_1.Button_2.Value
   ELSE
      Form_1.Button_1.Value := !Form_1.Button_1.Value
   ENDIF

   RETURN NIL
