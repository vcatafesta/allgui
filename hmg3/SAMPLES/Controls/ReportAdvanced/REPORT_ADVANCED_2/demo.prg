#include "hmg.ch"

FUNCTION Main

   DEFINE WINDOW Win_1 ;
         ROW 0 ;
         COL 0 ;
         WIDTH 400 ;
         HEIGHT 400 ;
         TITLE 'Hello World!' ;
         MAIN

      DEFINE MAIN MENU
         POPUP 'File'
            ITEM 'Test'   ACTION Test()
         END POPUP
      END MENU

   END WINDOW

   Win_1.Center

   Win_1.Activate

   RETURN

FUNCTION Test

   USE Test

   LOAD REPORT Test

   EXECUTE REPORT Test PREVIEW SELECTPRINTER

   USE

   RETURN
