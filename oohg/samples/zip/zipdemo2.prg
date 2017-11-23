/*
* Importante: Enlazar librería hbmzip
*/

#include "oohg.ch"

FUNCTION main()

   DEFINE WINDOW form_1 ;
         AT 114,218 ;
         WIDTH 334 ;
         HEIGHT 276 ;
         TITLE 'ZIP TEST' ;
         MAIN

      DEFINE MAIN MENU
         DEFINE POPUP "Test"
            MENUITEM 'Create Zip' ACTION CreateZip()
            MENUITEM 'UnZip File' ACTION UnPackZip()
         END POPUP

      END MENU

      @ 80,120 PROGRESSBAR Progress_1 RANGE 0,10 SMOOTH

      @ 120,120 LABEL label_1 VALUE ''

   END WINDOW

   form_1.center
   form_1.activate

   RETURN NIL

FUNCTION CreateZip()

   LOCAL aDir:=Directory("*.txt")
   LOCAL afiles:={}
   LOCAL x
   LOCAL nLen

   FOR x:=1 to len(aDir)
      aadd(afiles,adir[x,1])
   NEXT

   COMPRESSFILES("ziptest.zip", afiles, {|cFile,nPos| ProgressUpdate( nPos,cFile ) } , .T. )

   RETURN NIL

FUNCTION ProgressUpdate(nPos , cFile )

   Form_1.Progress_1.Value := nPos
   Form_1.Label_1.Value := cFile

   RETURN NIL

FUNCTION UnPackZip()

   UNCOMPRESSFILES( "ziptest.zip", {|cFile,nPos| ProgressUpdate( nPos,cFile ) } )

   RETURN NIL

PROCEDURE COMPRESSFILES ( cFileName , aDir , bBlock , lOvr )

   * Based upon HBMZIP Harbour contribution library samples.
   LOCAL hZip , i , cPassword

   IF valtype (lOvr) == 'L'
      IF lOvr == .t.
         IF file (cFileName)
            DELETE file (cFileName)
         ENDIF
      ENDIF
   ENDIF

   hZip := HB_ZIPOPEN( cFileName )
   IF ! EMPTY( hZip )
      FOR i := 1 To Len (aDir)
         IF valtype (bBlock) == 'B'
            Eval ( bBlock , aDir [i] , i )
         ENDIF
         HB_ZipStoreFile( hZip, aDir [ i ], aDir [ i ] , cPassword )
      NEXT
   ENDIF

   HB_ZIPCLOSE( hZip )

   RETURN

PROCEDURE UNCOMPRESSFILES ( cFileName , bBlock )

   * Based upon HBMZIP Harbour contribution library samples.
   LOCAL i := 0 , hUnzip , nErr, cFile, dDate, cTime, nSize, nCompSize , f

   hUnzip := HB_UNZIPOPEN( cFileName )

   nErr := HB_UNZIPFILEFIRST( hUnzip )

   DO WHILE nErr == 0

      HB_UnzipFileInfo( hUnzip, @cFile, @dDate, @cTime,,,, @nSize, @nCompSize )

      i++
      IF valtype (bBlock) = 'B'
         Eval ( bBlock , cFile , i )
      ENDIF

      HB_UnzipExtractCurrentFile( hUnzip, NIL, NIL )

      nErr := HB_UNZIPFILENEXT( hUnzip )

   ENDDO

   HB_UNZIPCLOSE( hUnzip )

   RETURN
