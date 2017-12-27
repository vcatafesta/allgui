/*
* Harbour MiniGUI Demo
* (c) 2002-2009 Roberto Lopez <harbourminigui@gmail.com>
*/

#include "minigui.ch"

FUNCTION Main

   DEFINE WINDOW Win1 ;
         AT 0,0 ;
         WIDTH 400 ;
         HEIGHT 400 ;
         TITLE 'DRAGITEMS LISTBOX' ;
         MAIN

      @ 10,10 LISTBOX LIST1 ;
         WIDTH 100 HEIGHT 200 ;
         ITEMS { '01','02','03','04','05','06','07','08','09','10' } ;
         DRAGITEMS

   END WINDOW

   CENTER WINDOW Win1

   ACTIVATE WINDOW Win1

   RETURN NIL
