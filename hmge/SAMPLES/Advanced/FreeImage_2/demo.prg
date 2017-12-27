/*
* MINIGUI - Harbour Win32 GUI library Demo
* Static FreeImage usage
* (c) 2012 Vladimir Chumachenko <ChVolodymyr@yandex.ru>
* Revised by Grigory Filatov <gfilatov@inbox.ru>
*/

#include "FreeImage.ch"
#include "MiniGUI.ch"

// ������� ������ ����������� ����� ������������� �������

// ���������� ������� ����������� �� �����

#define FI_TOP               30
#define FI_LEFT              30
#define FI_BOTTOM           455
#define FI_RIGHT            380

#define FI_WIDTH            ( FI_RIGHT - FI_LEFT )
#define FI_HEIGHT           ( FI_BOTTOM - FI_TOP )

// ���������� ������� ����������� �� �������

#define RES_TOP             FI_TOP
#define RES_LEFT            ( FI_RIGHT + 50 )
#define RES_BOTTOM          FI_BOTTOM
#define RES_RIGHT           780

#define RES_WIDTH           ( RES_RIGHT - RES_LEFT )
#define RES_HEIGHT          ( RES_BOTTOM - RES_TOP )

// ����� �������� (������������ ������������ Demo.rc), ���� ����� ����������
// ���� � ��������� �� � ��������� ��������.

#define PNG_BIRD            'BIRD'
#define PNG_SEA             'SEA'
#define JPG_TOWN            'TOWN'
#define JPG_WATERFALL       'WATERFALL'

// ��� �����, ��� �������

STATIC cFileImg
STATIC cResImg

/******
*       ����� ������� �� ����� � �������
*/

PROCEDURE Main

   FI_Initialise()

   SET font to 'Tahoma', 9

   DEFINE WINDOW wMain                 ;
         At 0, 0                      ;
         Width 810                    ;
         Height 525                   ;
         Title 'FreeImage Demo'       ;
         NoMaximize                   ;
         NoSize                       ;
         Icon 'MAINICON'              ;
         Main                         ;
         BackColor WHITE              ;
         On Init ( OpenImgFile( GetStartupFolder() + "\Res\Bird.png" ), OpenImgRes( PNG_BIRD, 'PNG' ) ) ;
         On Release FI_DeInitialise() ;
         On Paint { || ShowFile(), ShowRes() }

      DEFINE MAIN MENU

         DEFINE POPUP '&File'
            MenuItem '&Open'       Action OpenImgFile()
            Separator
            MenuItem 'E&xit Alt+X' Action ReleaseAllWindows()
         End Popup

         // !!! ��� ������ ���� ������� � ������ ���������������� �������

         DEFINE POPUP '&Resourse'
            MenuItem 'Bird      (png)' Action OpenImgRes( PNG_BIRD     , 'PNG' )
            MenuItem 'Sea       (png)' Action OpenImgRes( PNG_SEA      , 'PNG' )
            MenuItem 'Town      (jpg)' Action OpenImgRes( JPG_TOWN     , 'JPG' )
            MenuItem 'Waterfall (jpg)' Action OpenImgRes( JPG_WATERFALL, 'JPG' )
         End Popup

      End menu

      @ ( FI_TOP - 25 ), ( FI_LEFT - 25 ) Frame frmFile             ;
         Caption 'File'            ;
         Width ( FI_WIDTH   + 45 ) ;
         Height ( FI_HEIGHT + 45 ) ;
         BackColor WHITE

      @ ( RES_TOP - 25 ), ( RES_LEFT - 25 ) Frame frmResource          ;
         Caption 'Resource'         ;
         Width ( RES_WIDTH   + 45 ) ;
         Height ( RES_HEIGHT + 45 ) ;
         BackColor WHITE

   END WINDOW

   On Key Alt+X of wMain Action ReleaseAllWindows()

   CENTER WINDOW wMain
   ACTIVATE WINDOW wMain

   RETURN

   ****** End of Main ******

   /******
   *       OpenImgFile()
   *       ����� ����� ��� ��������
   */

STATIC PROCEDURE OpenImgFile( cFile )

   IF Empty( cFile )
      cFile := GetFile( { { 'Image files (*.bmp;*.jpg;*.jpeg;*.gif;*.png;*.psd;*.tif;*.ico)', ;
         '*.bmp;*.jpg;*.jpeg;*.gif;*.png;*.psd;*.tif;*.ico'                ;
         }                                                                   ;
         }, 'Select image', GetCurrentFolder(), .F., .T. )
   ENDIF

   IF !Empty( cFile )
      cFileImg := cFile
      wMain.frmFile.Caption := cFileNoPath( cFile )
      ShowFile()
   ENDIF

   RETURN

   ****** End of OpenImgFile ******

   /******
   *       ShowFile()
   *       ����� ����������� �� �����
   */

STATIC PROCEDURE ShowFile

   STATIC nHandleFileImg
   LOCAL nTop         := FI_TOP   , ;
      nLeft        := FI_LEFT  , ;
      nBottom      := FI_BOTTOM, ;
      nRight       := FI_RIGHT , ;
      pps                      , ;
      hDC                      , ;
      nWidth                   , ;
      nHeight                  , ;
      nKoeff                   , ;
      nHandleClone

   IF !( nHandleFileImg == nil )
      FI_Unload( nHandleFileImg )
      nHandleFileImg := nil
   ENDIF

   IF IsNil( cFileImg )

      RETURN
   ELSE
      nHandleFileImg := FI_Load( FI_GetFileType( cFileImg ), cFileImg, 0 )  // �������� �������
   ENDIF

   InvalidateRect( Application.Handle, 1, FI_LEFT, FI_TOP, FI_RIGHT, FI_BOTTOM )

   nWidth  := FI_GetWidth( nHandleFileImg )
   nHeight := FI_GetHeight( nHandleFileImg )

   IF ( ( nHeight > FI_HEIGHT ) .or. ( nWidth > FI_WIDTH )  )

      IF ( ( nHeight - FI_HEIGHT ) > ( nWidth - FI_WIDTH ) )
         nKoeff := ( FI_HEIGHT / nHeight )
      ELSE
         nKoeff := ( FI_WIDTH / nWidth )
      ENDIF

      nHeight := Round( ( nHeight * nKoeff ), 0 )
      nWidth  := Round( ( nWidth  * nKoeff ), 0 )

      nHandleClone := FI_Clone( nHandleFileImg )
      FI_Unload( nHandleFileImg )

      nHandleFileImg := FI_Rescale( nHandleClone, nWidth, nHeight, FILTER_BICUBIC )
      FI_Unload( nHandleClone )

   ENDIF

   IF ( nWidth < FI_WIDTH )
      nLeft  += Int( ( FI_WIDTH - nWidth ) / 2 )
      nRight := ( nLeft + nWidth )
   ENDIF

   IF ( nHeight < FI_HEIGHT )
      nTop    += Int( ( FI_HEIGHT - nHeight ) / 2 )
      nBottom := ( nTop + nHeight )
   ENDIF

   hDC := BeginPaint( Application.Handle, @pps )

   FI_WinDraw( nHandleFileImg, hDC, nTop, nLeft, nBottom, nRight )

   EndPaint( Application.Handle, pps )
   ReleaseDC( Application.Handle, hDC )

   RETURN

   ****** End of ShowFile ******

   /******
   *       OpenImgRes( cRes, cType )
   *       �������� ������� �� �������
   */

STATIC PROCEDURE OpenImgRes( cRes, cType )

   LOCAL cData := Win_LoadResource( cRes, cType )

   IF !Empty( cData )
      cResImg := cData
      wMain.frmResource.Caption := ( cRes + ' (' + cType + ')' )
      ShowRes()
   ELSE
      MsgExclamation( cRes + ' not found.', 'Error' )
   ENDIF

   RETURN

   ****** End of OpenImgRes ******

   /******
   *       ShowRes()
   *       ����� ������� �� ���������� (�������, ������������ � ������)
   */

STATIC PROCEDURE ShowRes

   STATIC nHandleResImg
   LOCAL nTop         := RES_TOP   , ;
      nLeft        := RES_LEFT  , ;
      nBottom      := RES_BOTTOM, ;
      nRight       := RES_RIGHT , ;
      pps                       , ;
      hDC                       , ;
      nWidth                    , ;
      nHeight                   , ;
      nKoeff                    , ;
      nHandleClone

   IF !( nHandleResImg == nil )
      FI_Unload( nHandleResImg )
      nHandleResImg := nil
   ENDIF

   IF Empty( cResImg )

      RETURN
   ELSE
      nHandleResImg := FI_LoadFromMemory( FI_GetFileTypeFromMemory( cResImg, Len( cResImg ) ), cResImg, 0 )
   ENDIF

   InvalidateRect( Application.Handle, 1, RES_LEFT, RES_TOP, RES_RIGHT, RES_BOTTOM )

   nWidth  := FI_GetWidth( nHandleResImg )
   nHeight := FI_GetHeight( nHandleResImg )

   IF ( ( nHeight > RES_HEIGHT ) .or. ( nWidth > RES_WIDTH )  )

      IF ( ( nHeight - RES_HEIGHT ) > ( nWidth - RES_WIDTH ) )
         nKoeff := ( RES_HEIGHT / nHeight )
      ELSE
         nKoeff := ( RES_WIDTH / nWidth )
      ENDIF

      nHeight := Round( ( nHeight * nKoeff ), 0 )
      nWidth  := Round( ( nWidth  * nKoeff ), 0 )

      nHandleClone := FI_Clone( nHandleResImg )
      FI_Unload( nHandleResImg )

      nHandleResImg := FI_Rescale( nHandleClone, nWidth, nHeight, FILTER_BICUBIC )
      FI_Unload( nHandleClone )

   ENDIF

   IF ( nWidth < FI_WIDTH )
      nLeft  += Int( ( FI_WIDTH - nWidth ) / 2 )
      nRight := ( nLeft + nWidth )
   ENDIF

   IF ( nHeight < FI_HEIGHT )
      nTop    += Int( ( FI_HEIGHT - nHeight ) / 2 )
      nBottom := ( nTop + nHeight )
   ENDIF

   hDC := BeginPaint( Application.Handle, @pps )

   FI_WinDraw( nHandleResImg, hDC, nTop, nLeft, nBottom, nRight )

   EndPaint( Application.Handle, pps )
   ReleaseDC( Application.Handle, hDC )

   RETURN

   ****** End of ShowRes ******
