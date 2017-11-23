/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2013 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

#command DEFINE WINDOW <w> ;
   [ AT <row>,<col> ] ;
   [ WIDTH <wi> ] ;
   [ HEIGHT <h> ] ;
   PICTURE <image> ;
   SPLASH ;
   [ DELAY <delay> ] ;
   [ ON RELEASE <ReleaseProcedure> ] ;
   => ;
   _DefineSplashWindow( <"w">, <row>, <col>, <wi>, <h>, <image>, <delay>, <{ReleaseProcedure}> )

/*
*/

FUNCTION Main

   DEFINE WINDOW Form_Main ;
         AT 0,0 ;
         WIDTH 640 HEIGHT 480 ;
         TITLE 'Main Window' ;
         MAIN ;
         NOSHOW

   END WINDOW

   DEFINE WINDOW Form_Splash ;
         PICTURE 'splash.gif' ;
         SPLASH ;
         DELAY 6 ;
         ON RELEASE Form_Main.Show

   END WINDOW

   CENTER WINDOW Form_Main

   ACTIVATE WINDOW ALL

   RETURN NIL

   /*
   */

PROCEDURE _DefineSplashWindow( name, row, col, width, height, cImage, nTime, Release )

   LOCAL aImgSize := GetImageSize( cImage ), RegionHandle
   LOCAL cSaveBmp := System.TempFolder + "\temp.bmp"

   DEFAULT row := 0, col := 0, width := aImgSize [1], height := aImgSize [2], nTime := 2

   DEFINE WINDOW &name ;
         AT row, col ;
         WIDTH width HEIGHT height ;
         CHILD TOPMOST ;
         NOSIZE NOMAXIMIZE NOMINIMIZE NOSYSMENU NOCAPTION ;
         ON INIT _SplashDelay( name, nTime ) ;
         ON RELEASE ( DeleteObject( RegionHandle ), Eval( Release ) )

      @ 0,0 IMAGE Image_1 ;
         PICTURE cImage ;
         WIDTH width ;
         HEIGHT height

   END WINDOW

   IF ! BT_BitmapSaveFile( _HMG_aControlBrushHandle [ GetControlIndex( "Image_1", name ) ], cSaveBmp )
      MsgInfo( "Saving is failure!", "Error" )
   ELSE
      SetProperty( name, "Image_1", "Picture", cSaveBmp )

      SET REGION OF &name BITMAP &cSaveBmp TRANSPARENT COLOR RGB(252, 253, 252) TO RegionHandle

      FErase( cSaveBmp )
   ENDIF

   IF EMPTY(row) .AND. EMPTY(col)
      CENTER WINDOW &name
   ENDIF

   SHOW WINDOW &name

   RETURN

   /*
   */

PROCEDURE _SplashDelay( name, nTime )

   LOCAL iTime := Seconds()

   DO WHILE Seconds() - iTime < nTime
      Do Events
   ENDDO

   DoMethod( name, 'Release' )

   RETURN

   /*
   */

STATIC FUNCTION GetImageSize( cImagePath )

   LOCAL aRetArr

   IF UPPER( RIGHT( cImagePath, 4 ) ) == ".BMP"

      aRetArr := BmpSize( cImagePath )

   ELSE

      aRetArr := hb_GetImageSize( cImagePath )

   ENDIF

   RETURN aRetArr
