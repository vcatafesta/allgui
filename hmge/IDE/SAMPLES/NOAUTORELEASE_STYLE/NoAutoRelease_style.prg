/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2002-2004 Roberto Lopez <roblez@ciudad.com.ar>
* http://harbourminigui.googlepages.com/
*/

* NoAuoRelease Style Demo / ACTIVATE WINDOW ALL command

* Using this style speed up application execution, since the forms are
* loaded / created / activated only once (at program startup). Later you
* only must show or hide them as needed.

* Using ACTIVATE WINDOW ALL command, all defined windows will be activated
* simultaneously. NOAUTORELEASE and NOSHOW styles in non-main windows
* are forced. (NOAUTORELEASE style, makes that, when the user closes the windows
* interactively they are hide instead released from memory, then, there is
* no need to reload / redefine prior to show it again. NOSHOW style makes that
* the windows be not displayed at activation).

#include "minigui.ch"

* When you refer to a window using semi-oop syntax, prior to be loaded
* (or defined) you must declare it.

* In this case, 'Std_Form','Child_Form','Topmost_Form' and 'Modal_Form'
* are referred using semi-oop syntax from 'Main_Form', prior to be loaded
* (remember that main window must be the first to be loaded or defined).

DECLARE Window Std_Form
DECLARE Window Child_Form
DECLARE Window Topmost_Form
DECLARE Window Modal_Form

FUNCTION Main

   LOAD WINDOW Main_Form // Main window must be loaded first.

   LOAD WINDOW Std_Form
   LOAD WINDOW Child_Form
   LOAD WINDOW Topmost_Form
   LOAD WINDOW Modal_Form

   ACTIVATE WINDOW All

   RETURN NIL
