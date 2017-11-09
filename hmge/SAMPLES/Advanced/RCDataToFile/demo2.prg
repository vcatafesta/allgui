/*
* Author: P.Chornyj <myorg63@mail.ru>
*/

ANNOUNCE RDDSYS
REQUEST HB_MEMIO

PROCEDURE main()

   LOCAL cMemFile  := "mem:image1"
   LOCAL cDiskFile := "image1.png"
   LOCAL nResult, aXY, x, y, cMsg

   DELETE file cDiskFile
   // nResult := RCDataToFile( "IMAGE1", cDiskFile, "PNG" )
   nResult := RCDataToFile( "IMAGE1", cMemFile, "PNG" )

   IF nResult > 0
      /* Now we can do something, f.e save to disk file */
      hb_vfCopyFile( cMemFile, cDiskFile )

      IF hb_FileExists( cDiskFile )
         aXY  := hb_GetImageSize( cDiskFile )

         cMsg := ( "IMAGE1 saved successfully as" + Chr(13) + Chr(10) )
         cMsg += ( cDiskFile + ": " + hb_NtoS( aXY[1] ) + " x " + hb_NtoS( aXY[2] ) + " Pixels" )

         MsgInfo( cMsg, "Congratulations!" )
      ENDIF
   ELSE
      MsgInfo( "Code: " + hb_NtoS( nResult ), "Error" )
   ENDIF

   hb_vfErase( cMemFile )

   RETURN

