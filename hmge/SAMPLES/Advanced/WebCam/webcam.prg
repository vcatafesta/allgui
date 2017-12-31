/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2011 Grigory Filatov <gfilatov@inbox.ru>
*/

#include <minigui.ch>

#define WS_CHILD     0x40000000
#define WS_VISIBLE   0x10000000

STATIC CamSource     // used to identify the video source
STATIC hWnd          // used as a window handle

PROCEDURE Main()

   LOAD WINDOW webcam

   ON KEY ESCAPE OF webcam ACTION ThisWindow.Release

   CENTER WINDOW webcam

   ACTIVATE WINDOW webcam

   RETURN

PROCEDURE OnFormLoad()

   cameraSource()

   webcam.Button_5.Enabled := .F.
   webcam.Button_4.Enabled := .F.
   webcam.Button_1.Enabled := .F.
   webcam.Button_2.Enabled := .F.
   webcam.Button_3.Enabled := .F.

   RETURN

PROCEDURE OnFormUnLoad()

   IF !Empty(hWnd)
      capDriverDisconnect(hWnd)
      DestroyWindow(hWnd)
   ENDIF
   IF File("C:\CAPTURE.AVI")
      Ferase("C:\CAPTURE.AVI")
   ENDIF

   RETURN

PROCEDURE StartClick()

   IF ! CamSource == NIL
      webcam.Label_0.Visible := .F.

      previewCamera()

      webcam.Button_1.Enabled := .T.
      webcam.Button_4.Enabled := .F.
      webcam.Button_2.Enabled := .T.
      webcam.Button_5.Enabled := .T.
   ENDIF

   RETURN

PROCEDURE cameraSource()

   LOCAL i
   LOCAL cDriverName := Space(128)
   LOCAL cDriverVersion := Space(128)

   FOR i := 0 To 9
      IF capGetDriverDescription(i, @cDriverName, 128, @cDriverVersion, 128)
         webcam.Combo_1.AddItem(cDriverName)
      ENDIF
   NEXT

   IF webcam.Combo_1.ItemCount <> 0
      webcam.Combo_1.Value := 1
      CamSource := webcam.Combo_1.Value - 1
   ELSE
      webcam.Label_0.Visible := .F.
      webcam.Combo_1.AddItem("No capture devices found")
      webcam.Combo_1.Value := 1
   ENDIF

   RETURN

PROCEDURE previewCamera()

   LOCAL i := 0
   LOCAL nMaxAttempt := 10
   LOCAL lConnect

   webcam.Image_1.Visible := .F.

   hWnd := capCreateCaptureWindow("WebCam", hb_bitOr(WS_CHILD, WS_VISIBLE), ;
      webcam.Image_1.Col, webcam.Image_1.Row, webcam.Image_1.Width, webcam.Image_1.Height, ;
      GetFormHandle("webcam"), 1)

   REPEAT
   lConnect := capDriverConnect(hWnd, CamSource)
   UNTIL !lConnect .Or. ++i > nMaxAttempt

   IF lConnect
      // set the preview scale
      capPreviewScale(hWnd, .T.)
      // set the preview rate (ms)
      capPreviewRate(hWnd, 30)
      // start previewing the image
      capPreview(hWnd, .T.)
   ELSE
      // error connecting to video source
      DestroyWindow(hWnd)
      hWnd := 0
   ENDIF

   RETURN

PROCEDURE stopPreviewCamera()

   capDriverDisconnect(hWnd)
   DestroyWindow(hWnd)

   webcam.Image_1.Visible := .T.

   RETURN

PROCEDURE Button1_Click()  // stop preview

   stopPreviewCamera()

   webcam.Button_5.Enabled := .F.
   webcam.Button_4.Enabled := .T.
   webcam.Button_1.Enabled := .F.

   RETURN

PROCEDURE Button2_Click()  // recording

   webcam.Button_3.Enabled := .T.
   webcam.Button_2.Enabled := .F.

   capCaptureSequence(hWnd)

   RETURN

PROCEDURE Button3_Click()  // stop recording and ask to save video

   LOCAL cSaveName

   IF MsgYesNo("Do you want to save your recording video?", "Recording Video")
      cSaveName := Putfile( {{"Avi files (*.avi)","*.avi"}}, "Save Video As", "C:\", .f., "RecordedVideo" )
      IF !Empty(cSaveName)
         capFileSaveAs(hWnd, cSaveName)
      ENDIF
   ENDIF

   webcam.Button_2.Enabled := .T.
   webcam.Button_3.Enabled := .F.

   RETURN

PROCEDURE Button4_Click()  // preview

   CamSource := webcam.Combo_1.Value - 1

   previewCamera()

   webcam.Button_5.Enabled := .T.
   webcam.Button_4.Enabled := .F.
   webcam.Button_1.Enabled := .T.

   RETURN

PROCEDURE Button5_Click()  // save image

   LOCAL cSaveName

   IF MsgYesNo("Do you want to save current picture?", "Save Image")
      cSaveName := Putfile( {{"Bmp files (*.bmp)","*.bmp"}}, "Save Image As", "C:\", .f., "Image" )
      IF !Empty(cSaveName)
         capFileSaveDIB(hWnd, cSaveName)
      ENDIF
   ENDIF

   RETURN

#pragma BEGINDUMP

#include <hbapi.h>
#include <windows.h>
#include <vfw.h>

#if defined( __BORLANDC__ )
#pragma warn -use /* unused var */
#endif

HB_FUNC( CAPGETDRIVERDESCRIPTION )
{
 TCHAR lpszName[128];
 int iName = hb_parni(3);
 TCHAR lpszVer[128];
 int iVer = hb_parni(5);
 BOOL bRet;

 bRet = capGetDriverDescription( (WORD) hb_parnl(1), lpszName, iName, lpszVer, iVer );

 hb_storc( lpszName, 2 );
 hb_storc( lpszVer, 4 );

 hb_retl( bRet );
}

HB_FUNC( CAPCREATECAPTUREWINDOW )
{
 hb_retnl( (LONG) capCreateCaptureWindow( (LPCSTR) hb_parc(1),
                                          (DWORD) hb_parnl(2),
                                          hb_parni(3), hb_parni(4),
                                          hb_parni(5), hb_parni(6),
                                          (HWND) hb_parnl(7),
                                          hb_parni(8) ) );
}

HB_FUNC( CAPDRIVERCONNECT )
{
 hb_retl( capDriverConnect( (HWND) hb_parnl(1), hb_parni(2) ) );
}

HB_FUNC( CAPDRIVERDISCONNECT )
{
 hb_retl( capDriverDisconnect( (HWND) hb_parnl(1) ) );
}

HB_FUNC( CAPPREVIEWRATE )
{
 hb_retl( capPreviewRate( (HWND) hb_parnl(1), (WORD) hb_parnl(2) ) );
}

HB_FUNC( CAPPREVIEWSCALE )
{
 hb_retl( capPreviewScale( (HWND) hb_parnl(1), hb_parl(2) ) );
}

HB_FUNC( CAPPREVIEW )
{
 hb_retl( capPreview( (HWND) hb_parnl(1), hb_parl(2) ) );
}

HB_FUNC( CAPCAPTURESEQUENCE )
{
 hb_retl( capCaptureSequence( (HWND) hb_parnl(1) ) );
}

HB_FUNC( CAPFILESAVEAS )
{
 hb_retl( capFileSaveAs( (HWND) hb_parnl(1), hb_parc(2) ) );
}

HB_FUNC( CAPFILESAVEDIB )
{
 hb_retl( capFileSaveDIB( (HWND) hb_parnl(1), hb_parc(2) ) );
}

#pragma ENDDUMP
