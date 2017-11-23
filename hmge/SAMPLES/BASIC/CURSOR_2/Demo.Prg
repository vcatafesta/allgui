/*
Mouse's Cursor Demo - Windows/HMG internal/RC/Animated and custom
Author: Pablo César Arrascaeta
Date: September 22nd, 2016
Version: 1.0
*/

#include <hmg.ch>

FUNCTION Main

   LOAD WINDOW Demo
   Demo.Center
   Demo.Activate

   RETURN NIL

FUNCTION SetCursorOnControls(xCursor)

   SetWindowCursor (ThisWindow.Handle, xCursor)
   SetWindowCursor (This.Handle, xCursor)    // All Controls associated with the class

   RETURN NIL
