/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2002 Roberto Lopez <roblez@ciudad.com.ar>
* http://www.geocities.com/harbour_minigui/
*/

#include "oohg.ch"

FUNCTION Main

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH 640 HEIGHT 480 ;
         TITLE "Month Calendar Control Demo" ;
         ICON "DEMO.ICO" ;
         MAIN ;
         FONT "Arial" SIZE 10

      @ 10,10 MONTHCALENDAR Month_1 ;
         VALUE date() ;
         TOOLTIP "Month Calendar Control NoToday" ;
         NOTODAY ;
         ON CHANGE {||msginfo("Month_1 Change")}

      @ 10,300 BUTTON Button_1 ;
         CAPTION "SET DATE" ;
         ACTION Form_1.Month_1.Value := date()

      @ 50,300 BUTTON Button_2 ;
         CAPTION "GET DATE" ;
         ACTION MsgInfo ( GetDate ( Form_1.Month_1.Value ) )

      @ 210,10 MONTHCALENDAR Month_2 ;
         VALUE CTOD("01/01/2001") ;
         FONT "Courier" SIZE 12 ;
         TOOLTIP "Month Calendar Control NoTodayCircle WeekNumbers" ;
         NOTODAYCIRCLE ;
         WEEKNUMBERS ;
         ON CHANGE {||msginfo("Month_2 Change")}

      @ 210,300 BUTTON Button_3 ;
         CAPTION "SET DATE" ;
         ACTION Form_1.Month_2.Value := ctod("01/01/2001")

      @ 250,300 BUTTON Button_4 ;
         CAPTION "GET DATE" ;
         ACTION MsgInfo ( GetDate ( Form_1.Month_2.Value ) )

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

   RETURN NIL

STATIC FUNCTION GetDate ( dDate )

   LOCAL nDay := Day(dDate)
   LOCAL nMonth := Month(dDate)
   LOCAL nYear := Year(dDate)
   LOCAL cRet := ""

   cRet += "Day: "+StrZero(nDay,2)
   cRet += space(2)
   cRet += "Month: "+StrZero(nMonth,2)
   cRet += space(2)
   cRet += "Year: "+StrZero(nYear,4)

   RETURN cRet
