#include "minigui.ch"

FUNCTION Main()

   SET EXCLUSIVE OFF

   REQUEST DBFCDX , DBFFPT

   DEFINE WINDOW Win_1         ;
         AT        0,0          ;
         WIDTH     640          ;
         HEIGHT    480          ;
         TITLE     "EDIT Command Demo"    ;
         MAIN             ;
         ON INIT OpenTable()       ;
         ON RELEASE Closetable()    ;
         BACKCOLOR GRAY

      DEFINE MAIN MENU OF Win_1
         POPUP "&File"
            ITEM "&Simple Edit test"   ACTION EDIT WORKAREA CLIENTES
            SEPARATOR
            ITEM "E&xit"               ACTION Win_1.Release
         END POPUP
      END MENU

   END WINDOW

   MAXIMIZE WINDOW Win_1
   ACTIVATE WINDOW Win_1

   RETURN NIL

   /*-----------------------------------------------------------------------------*/

PROCEDURE OpenTable()

   USE CLIENTES VIA "DBFCDX" INDEX CLIENTES NEW

   RETURN

   /*-----------------------------------------------------------------------------*/

PROCEDURE CloseTable()

   CLOSE CLIENTES

   RETURN
