#include "minigui.ch"
#include "i_rptgen.ch"

SET Procedure To h_rptgen

PROCEDURE Main

   PUBLIC _HMG_RPTDATA := Array( 165 )

   SET CENTURY ON
   SET DATE ANSI

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

PROCEDURE Test

   USE Test

   LOAD REPORT Test

   EXECUTE REPORT Test PREVIEW SELECTPRINTER

   USE

   RETURN
