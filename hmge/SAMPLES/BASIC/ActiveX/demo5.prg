
/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2002-2008 Roberto Lopez <harbourminigui@gmail.com>
* http://harbourminigui.googlepages.com/
* Activex Sample: Inspired by Freewin Activex inplementation by
* Oscar Joel Lira Lira http://sourceforge.net/projects/freewin
*/

#include "minigui.ch"

FUNCTION Main()

   SET CENTURY ON
   SET DATE ANSI

   DEFINE WINDOW Win1 ;
         AT 0,0 ;
         WIDTH 640 ;
         HEIGHT 480 ;
         TITLE 'HMG ActiveX Support Demo' ;
         MAIN ;
         ON MAXIMIZE ( Win1.Calendar.Width := Win1.Width - 80, Win1.Calendar.Height := Win1.Height - 80 ) ;
         ON SIZE ( Win1.Calendar.Width := Win1.Width - 80, Win1.Calendar.Height := Win1.Height - 80 ) ;
         ON RELEASE Win1.Calendar.Release

      DEFINE MAIN MENU
         POPUP "Test"
            MENUITEM "Get Date Value" ACTION Test1()
            MENUITEM "Set Date Value" ACTION Test2()
         END POPUP
      END MENU

      DEFINE ACTIVEX Calendar
         ROW 10
         COL 40
         WIDTH 560
         HEIGHT 400
         PROGID "MSCAL.Calendar"
      END ACTIVEX

   END WINDOW

   CENTER WINDOW Win1

   ACTIVATE WINDOW Win1

   RETURN NIL

PROCEDURE Test1()

   LOCAL cDay := StrZero(Win1.Calendar.XObject:Day, 2)
   LOCAL cMonth := StrZero(Win1.Calendar.XObject:Month, 2)
   LOCAL cYear := Str(Win1.Calendar.XObject:Year, 4)

   MsgInfo( StoD( cYear + cMonth + cDay ), "Selected Date" )

   RETURN

PROCEDURE Test2()

   Win1.Calendar.XObject:Value := Date() + 7

   RETURN
