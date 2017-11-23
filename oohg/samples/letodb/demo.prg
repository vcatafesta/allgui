/*
* To build, use:
*  SET THR_LIB=-lrddleto
*  COMPILE demo
*/

#include "oohg.ch"

FUNCTION Main

   LOCAL cTable, arr
   LOCAL i, n1, n2

   REQUEST LETO
   RDDSETDEFAULT( "LETO" )

   SET language to spanish

   cTable := "//192.168.0.10:2812/ciro.dbf"

   arr := { { "FirstName", "C", 20, 0 }, ;
      { "LastName", "C", 20, 0 }, ;
      { "Age", "N", 3, 0 }, ;
      { "Date", "D", 8, 0 }, ;
      { "Rate", "N", 6, 2 }, ;
      { "Student", "L", 1, 0 } }

   dbCreate( cTable, arr )
   USE (cTable) alias letoex

   FOR i := 1 to 100
      APPEND BLANK
      n1 := hb_RandomInt( 80 )
      n2 := hb_RandomInt( 50 )
      REPLACE Age with n1, Date with Date() - 365*n2 + n1, Rate with 56.5 - n1/2
      REPLACE FirstName with "A"+Chr(64+n2)+Padl(i,10,'0'), LastName with "B"+Chr(70+n2)+Padl(i,12,'0'), Student with ( (field->Age % 2) == 1 )
   NEXT

   GO TOP

   edit workarea letoex

   RETURN NIL
