#include "hmg.ch"

FUNCTION main()

   DEFINE WINDOW form_1 ;
         AT 114,218 ;
         WIDTH 334 ;
         HEIGHT 276 ;
         TITLE 'UNZIP TEST' ;
         MAIN

      DEFINE MAIN MENU

         DEFINE POPUP "Test"
            MENUITEM 'UnZip File' ACTION UnPackZip()
         END POPUP

      END MENU

      @ 80,120 PROGRESSBAR Progress_1 RANGE 0,10 SMOOTH

      @ 120,120 LABEL label_1 VALUE ''

   END WINDOW

   form_1.center
   form_1.activate

   RETURN NIL

FUNCTION UnPackZip()

   UNCOMPRESS 'ZipTest.Zip' ;
      BLOCK {|cFile,nPos| ProgressUpdate( nPos , cFile ) }

   RETURN NIL

FUNCTION ProgressUpdate(nPos , cFile )

   Form_1.Progress_1.Value := nPos
   Form_1.Label_1.Value := cFile

   RETURN NIL

