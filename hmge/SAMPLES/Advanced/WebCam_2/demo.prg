/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2011-2017 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"
#include "hbgdip.ch"

*-----------------------------------------------------------------------------*
Procedure Main
*-----------------------------------------------------------------------------*

	IF StatusOk != GdiplusInitExt( _GDI_GRAPHICS )
		MsgStop( "Init GDI+ Error", "Error" )
		RETURN
	ENDIF

	_GdiplusInitLocal()

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 440 + GetBorderWidth() ;
		HEIGHT 300 + GetTitleHeight() + GetBorderHeight() ;
		TITLE 'WebCam Preview Demo' ;
		MAIN ;
		NOMAXIMIZE NOSIZE ;
		ON INIT ( ;
			CaptureImage() ;  // capture initialization
			) ;
		ON RELEASE ( ;
			CloseWebCam() ;
			)

		@ 20,60 WEBCAM WebCam_1 ;
			WIDTH 250 HEIGHT 210 ;
			RATE 20 ;
			START

		DEFINE IMAGE Image_1
			ROW	120
			COL	280
			WIDTH   150
			HEIGHT  110
			STRETCH .T.
		END IMAGE

		DEFINE BUTTON Button_1
			ROW	10
			COL	20
			WIDTH   120
			CAPTION 'Start WebCam'
			ACTION  CreateWebCam()
		END BUTTON

		DEFINE BUTTON Button_2
			ROW	10
			COL	150
			WIDTH   120
			CAPTION 'Stop WebCam'
			ACTION  CloseWebCam()
		END BUTTON

		DEFINE BUTTON Button_3
			ROW	80
			COL	315
			WIDTH   80
			CAPTION 'Capture'
			ACTION  CaptureImage()
		END BUTTON

		DEFINE LABEL Label_1
			ROW	59
			COL	19
			WIDTH   252
			HEIGHT  212
			BORDER  .T.
		END LABEL

		DEFINE LABEL Label_2
			ROW	119
			COL	279
			WIDTH   152
			HEIGHT  112
			BORDER  .T.
		END LABEL

		ON KEY ESCAPE ACTION ThisWindow.Release

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return

*-----------------------------------------------------------------------------*
Procedure CreateWebCam
*-----------------------------------------------------------------------------*

	If ! IsControlDefined( WebCam_1, Form_1 )

		@ 20,60 WEBCAM WebCam_1 OF Form_1 ;
			WIDTH 250 HEIGHT 210 ;
			RATE 20

		Form_1.WebCam_1.Start()

		Form_1.Button_3.Enabled := .T.

	EndIf

Return

*-----------------------------------------------------------------------------*
Procedure CloseWebCam
*-----------------------------------------------------------------------------*

	If IsControlDefined( WebCam_1, Form_1 )

		Form_1.WebCam_1.Release()

		Form_1.Button_3.Enabled := .F.

	EndIf

Return

*-----------------------------------------------------------------------------*
Procedure CaptureImage
*-----------------------------------------------------------------------------*
  Local hBitmap
  Local nWidth
  Local nHeight

  If cap_EditCopy( GetControlHandle ( 'WebCam_1', 'Form_1' ) )

     nWidth := GetProperty( "Form_1", "Image_1", "Width" )
     nHeight := GetProperty( "Form_1", "Image_1", "Height" )

     hBitmap := LoadFromClpbrd( GetFormHandle( 'Form_1' ), nWidth, nHeight )

     If !Empty( hBitmap )

        Form_1.Image_1.hBitmap := hBitmap

        System.Clipboard := ""

        gPlusSaveHBitmapToFile( hBitmap, "webcam.png", nWidth, nHeight, "image/png", 100 )

     EndIf

  Else

     MsgAlert( 'Capture is failure!', 'Error' )

  EndIf

Return

#define CF_BITMAP     2
*-----------------------------------------------------------------------------*
Static Function LoadFromClpbrd( hWnd, w, h )
*-----------------------------------------------------------------------------*
  Local hBmp

  If OpenClipboard( hWnd )

     hBmp := GetClipboardData( CF_BITMAP, w, h )

     CloseClipboard()

  EndIf

Return( hBmp )


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

HBITMAP StretchBitmap( HBITMAP hbmpSrc, int New_Width, int New_Height )
{
   HBITMAP hbmpOldSrc, hbmpOldDest, hbmpNew;
   HDC     hdcSrc, hdcDest;
   BITMAP  bmp;
   POINT   Point;

   hdcSrc = CreateCompatibleDC( NULL );
   hdcDest = CreateCompatibleDC( hdcSrc );

   GetObject( hbmpSrc, sizeof( BITMAP ), &bmp );

   hbmpOldSrc = (HBITMAP) SelectObject( hdcSrc, hbmpSrc );

   hbmpNew = CreateCompatibleBitmap( hdcSrc, New_Width, New_Height );

   hbmpOldDest = (HBITMAP) SelectObject( hdcDest, hbmpNew );

   GetBrushOrgEx( hdcDest, &Point );
   SetStretchBltMode( hdcDest, HALFTONE );
   SetBrushOrgEx( hdcDest, Point.x, Point.y, NULL );

   StretchBlt( hdcDest, 0, 0, New_Width, New_Height, hdcSrc, 0, 0, bmp.bmWidth, bmp.bmHeight, SRCCOPY );

   SelectObject( hdcDest, hbmpOldDest );
   SelectObject( hdcSrc, hbmpOldSrc );

   DeleteDC( hdcDest );
   DeleteDC( hdcSrc );

   return hbmpNew;
}

HB_FUNC( CLOSECLIPBOARD )
{
   hb_retl( CloseClipboard() );
}

HB_FUNC( OPENCLIPBOARD )
{
   hb_retl( OpenClipboard( ( HWND ) hb_parnl( 1 ) ) ) ;
}

HB_FUNC( GETCLIPBOARDDATA )
{
   WORD wType = hb_parni( 1 );
   HGLOBAL hMem;

   switch( wType )
   {
      case CF_TEXT:
           hMem = GetClipboardData( CF_TEXT );
           if( hMem )
           {
              hb_retc( ( char * ) GlobalLock( hMem ) );
              GlobalUnlock( hMem );
           }
           else
              hb_retc( "" );
           break;

      case CF_BITMAP:
           if( IsClipboardFormatAvailable( CF_BITMAP ) )
              hb_retnl( ( LONG ) StretchBitmap( ( HBITMAP ) GetClipboardData( CF_BITMAP ), hb_parni( 2 ), hb_parni( 3 ) ) );
           else
              hb_retnl( 0 );
   }
}

#pragma ENDDUMP

//////////////////////////////////////////////////////////////////////////////
#pragma BEGINDUMP
/*
 * This source file is part of the hbGdiPlus library source
 * Copyright 2007-2017 P.Chornyj <myorg63@mail.ru>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 */

#include <mgdefs.h>
#include "hbapiitm.h"
#ifndef __XHARBOUR__
# include "hbwinuni.h"
#else
typedef wchar_t HB_WCHAR;
#endif

typedef enum
{
   Ok                        = 0,
   GenericError              = 1,
   InvalidParameter          = 2,
   OutOfMemory               = 3,
   ObjectBusy                = 4,
   InsufficientBuffer        = 5,
   NotImplemented            = 6,
   Win32Error                = 7,
   WrongState                = 8,
   Aborted                   = 9,
   FileNotFound              = 10,
   ValueOverflow             = 11,
   AccessDenied              = 12,
   UnknownImageFormat        = 13,
   FontFamilyNotFound        = 14,
   FontStyleNotFound         = 15,
   NotTrueTypeFont           = 16,
   UnsupportedGdiplusVersion = 17,
   GdiplusNotInitialized     = 18,
   PropertyNotFound          = 19,
   PropertyNotSupported      = 20,
} GpStatus;

typedef struct
{
   CLSID Clsid;
   GUID  FormatID;
   const unsigned short * CodecName;
   const unsigned short * DllName;
   const unsigned short * FormatDescription;
   const unsigned short * FilenameExtension;
   const unsigned short * MimeType;
   ULONG Flags;
   ULONG Version;
   ULONG SigCount;
   ULONG SigSize;
   const unsigned char * SigPattern;
   const unsigned char * SigMask;
} ImageCodecInfo;

typedef struct
{
   GUID   Guid;
   ULONG  NumberOfValues;
   ULONG  Type;
   void * Value;
} ENCODER_PARAMETER;

typedef struct
{
   unsigned int      Count;
   ENCODER_PARAMETER Parameter[ 1 ];
} EncoderParameters;

#define WINGDIPAPI  __stdcall
#define GDIPCONST   const

typedef DWORD ARGB;
typedef void GpBitmap;
typedef void GpImage;
#ifndef IStream
typedef struct IStream IStream;
#endif
typedef GpStatus ( WINGDIPAPI * GetThumbnailImageAbort )( void * );

typedef GpStatus ( WINGDIPAPI * GdipCreateBitmapFromFile_ptr )( GDIPCONST HB_WCHAR *, GpBitmap ** );
typedef GpStatus ( WINGDIPAPI * GdipCreateHBITMAPFromBitmap_ptr )( GpBitmap *, HBITMAP *, ARGB );
typedef GpStatus ( WINGDIPAPI * GdipCreateBitmapFromResource_ptr )( HINSTANCE, GDIPCONST HB_WCHAR *, GpBitmap ** );
typedef GpStatus ( WINGDIPAPI * GdipCreateBitmapFromStream_ptr )( IStream *, GpBitmap ** );
typedef GpStatus ( WINGDIPAPI * GdipDisposeImage_ptr )( GpImage * );

#define EXTERN_FUNCPTR( name )          extern name##_ptr fn_##name
#define DECLARE_FUNCPTR( name )         name##_ptr fn_##name = NULL
#define ASSIGN_FUNCPTR( module, name )  fn_##name = ( name##_ptr )GetProcAddress( module, #name )
#define _EMPTY_PTR( module, name )      NULL == ( ASSIGN_FUNCPTR( module, name ) )

EXTERN_FUNCPTR( GdipCreateBitmapFromFile );
EXTERN_FUNCPTR( GdipCreateBitmapFromResource );
EXTERN_FUNCPTR( GdipCreateBitmapFromStream );
EXTERN_FUNCPTR( GdipCreateHBITMAPFromBitmap );
EXTERN_FUNCPTR( GdipDisposeImage );

typedef GpStatus ( WINGDIPAPI * GdipGetImageEncodersSize_ptr )( UINT * numEncoders, UINT * size );
typedef GpStatus ( WINGDIPAPI * GdipGetImageEncoders_ptr )( UINT numEncoders, UINT size, ImageCodecInfo * encoders );
typedef GpStatus ( WINGDIPAPI * GdipGetImageThumbnail_ptr )( GpImage * image, UINT thumbWidth, UINT thumbHeight, GpImage ** thumbImage, GetThumbnailImageAbort callback, VOID * callbackData );
typedef GpStatus ( WINGDIPAPI * GdipCreateBitmapFromHBITMAP_ptr )( HBITMAP hbm, HPALETTE hpal, GpBitmap ** bitmap );
typedef GpStatus ( WINGDIPAPI * GdipSaveImageToFile_ptr )( GpImage * image, GDIPCONST HB_WCHAR * filename, GDIPCONST CLSID * clsidEncoder, GDIPCONST EncoderParameters * encoderParams );

DECLARE_FUNCPTR( GdipGetImageEncodersSize );
DECLARE_FUNCPTR( GdipGetImageEncoders );
DECLARE_FUNCPTR( GdipGetImageThumbnail );
DECLARE_FUNCPTR( GdipCreateBitmapFromHBITMAP );
DECLARE_FUNCPTR( GdipSaveImageToFile );

BOOL SaveHBitmapToFile( void * HBitmap, const char * FileName, unsigned int Width, unsigned int Height, const char * MimeType, ULONG JpgQuality );

extern HMODULE  g_GpModule;
unsigned char * MimeTypeOld;

/*
 * GDI+ Local Init
 */
static GpStatus _LoadExt( void )
{
   if( NULL == g_GpModule )
      return FALSE;

   if( _EMPTY_PTR( g_GpModule, GdipGetImageEncodersSize ) )
      return NotImplemented;

   if( _EMPTY_PTR( g_GpModule, GdipGetImageEncoders ) )
      return NotImplemented;

   if( _EMPTY_PTR( g_GpModule, GdipCreateBitmapFromHBITMAP ) )
      return NotImplemented;

   if( _EMPTY_PTR( g_GpModule, GdipSaveImageToFile ) )
      return NotImplemented;

   if( _EMPTY_PTR( g_GpModule, GdipGetImageThumbnail ) )
      return NotImplemented;

   return TRUE;
}

HB_FUNC( _GDIPLUSINITLOCAL )
{
   hb_retl( Ok != _LoadExt() ? HB_TRUE : HB_FALSE );
}

/*
 * Get encoders
 */
HB_FUNC( GPLUSGETENCODERSNUM )
{
   UINT num  = 0;  // number of image encoders
   UINT size = 0;  // size of the image encoder array in bytes

   fn_GdipGetImageEncodersSize( &num, &size );

   hb_retni( num );
}

HB_FUNC( GPLUSGETENCODERSSIZE )
{
   UINT num  = 0;
   UINT size = 0;

   fn_GdipGetImageEncodersSize( &num, &size );

   hb_retni( size );
}

HB_FUNC( GPLUSGETENCODERSMIMETYPE )
{
   UINT num  = 0;
   UINT size = 0;
   UINT i;
   ImageCodecInfo * pImageCodecInfo;
   PHB_ITEM         pResult = hb_itemArrayNew( 0 );
   PHB_ITEM         pItem;
   char * RecvMimeType;

   fn_GdipGetImageEncodersSize( &num, &size );

   if( size == 0 )
   {
      hb_itemReturnRelease( pResult );
      return;
   }

   pImageCodecInfo = ( ImageCodecInfo * ) hb_xalloc( size );

   if( pImageCodecInfo == NULL )
   {
      hb_itemReturnRelease( pResult );
      return;
   }

   RecvMimeType = LocalAlloc( LPTR, size );

   if( RecvMimeType == NULL )
   {
      hb_xfree( pImageCodecInfo );
      hb_itemReturnRelease( pResult );
      return;
   }

   fn_GdipGetImageEncoders( num, size, pImageCodecInfo );

   pItem = hb_itemNew( NULL );

   for( i = 0; i < num; ++i )
   {
      WideCharToMultiByte( CP_ACP, 0, pImageCodecInfo[ i ].MimeType, -1, RecvMimeType, size, NULL, NULL );

      pItem = hb_itemPutC( NULL, RecvMimeType );

      hb_arrayAdd( pResult, pItem );
   }

   // free resource
   LocalFree( RecvMimeType );
   hb_xfree( pImageCodecInfo );

   hb_itemRelease( pItem );

   // return a result array
   hb_itemReturnRelease( pResult );
}

static BOOL GetEnCodecClsid( const char * MimeType, CLSID * Clsid )
{
   UINT num  = 0;
   UINT size = 0;
   ImageCodecInfo * pImageCodecInfo;
   UINT   CodecIndex;
   char * RecvMimeType;
   BOOL   bFounded = FALSE;

   hb_xmemset( Clsid, 0, sizeof( CLSID ) );

   if( ( MimeType == NULL ) || ( Clsid == NULL ) || ( g_GpModule == NULL ) )
      return FALSE;

   if( fn_GdipGetImageEncodersSize( &num, &size ) )
      return FALSE;

   if( ( pImageCodecInfo = hb_xalloc( size ) ) == NULL )
      return FALSE;

   hb_xmemset( pImageCodecInfo, 0, sizeof( ImageCodecInfo ) );

   if( fn_GdipGetImageEncoders( num, size, pImageCodecInfo ) || ( pImageCodecInfo == NULL ) )
   {
      hb_xfree( pImageCodecInfo );

      return FALSE;
   }

   if( ( RecvMimeType = LocalAlloc( LPTR, size ) ) == NULL )
   {
      hb_xfree( pImageCodecInfo );

      return FALSE;
   }

   for( CodecIndex = 0; CodecIndex < num; ++CodecIndex )
   {
      WideCharToMultiByte( CP_ACP, 0, pImageCodecInfo[ CodecIndex ].MimeType, -1, RecvMimeType, size, NULL, NULL );

      if( strcmp( MimeType, RecvMimeType ) == 0 )
      {
         bFounded = TRUE;
         break;
      }
   }

   if( bFounded )
      CopyMemory( Clsid, &pImageCodecInfo[ CodecIndex ].Clsid, sizeof( CLSID ) );

   hb_xfree( pImageCodecInfo );
   LocalFree( RecvMimeType );

   return bFounded ? TRUE : FALSE;
}

/*
 * Save bitmap to file
 */
HB_FUNC( GPLUSSAVEHBITMAPTOFILE )
{
   HBITMAP hbmp = ( HBITMAP ) hb_parnl( 1 );

   hb_retl( SaveHBitmapToFile( ( void * ) hbmp, hb_parc( 2 ), ( UINT ) hb_parnl( 3 ), ( UINT ) hb_parnl( 4 ), hb_parc( 5 ), ( ULONG ) hb_parnl( 6 ) ) );
}

BOOL SaveHBitmapToFile( void * HBitmap, const char * FileName, unsigned int Width, unsigned int Height, const char * MimeType, ULONG JpgQuality )
{
   void *            GBitmap;
   void *            GBitmapThumbnail;
   LPWSTR            WFileName;
   static CLSID      Clsid;
   EncoderParameters EncoderParameters;

   if( ( HBitmap == NULL ) || ( FileName == NULL ) || ( MimeType == NULL ) || ( g_GpModule == NULL ) )
   {
      MessageBox( NULL, "Wrong Param", "GPlus error", MB_OK | MB_ICONINFORMATION | MB_SYSTEMMODAL );

      return FALSE;
   }

   if( MimeTypeOld == NULL )
   {
      if( ! GetEnCodecClsid( MimeType, &Clsid ) )
      {
         MessageBox( NULL, "Wrong MimeType", "GPlus error", MB_OK | MB_ICONINFORMATION | MB_SYSTEMMODAL );

         return FALSE;
      }

      MimeTypeOld = LocalAlloc( LPTR, strlen( MimeType ) + 1 );

      if( MimeTypeOld == NULL )
      {
         MessageBox( NULL, "LocalAlloc Error", "GPlus error", MB_OK | MB_ICONINFORMATION | MB_SYSTEMMODAL );

         return FALSE;
      }

      strcpy( MimeTypeOld, MimeType );
   }
   else
   {
      if( strcmp( MimeTypeOld, MimeType ) != 0 )
      {
         LocalFree( MimeTypeOld );

         if( ! GetEnCodecClsid( MimeType, &Clsid ) )
         {
            MessageBox( NULL, "Wrong MimeType", "GPlus error", MB_OK | MB_ICONINFORMATION | MB_SYSTEMMODAL );

            return FALSE;
         }

         MimeTypeOld = LocalAlloc( LPTR, strlen( MimeType ) + 1 );

         if( MimeTypeOld == NULL )
         {
            MessageBox( NULL, "LocalAlloc Error", "GPlus error", MB_OK | MB_ICONINFORMATION | MB_SYSTEMMODAL );

            return FALSE;
         }
         strcpy( MimeTypeOld, MimeType );
      }
   }

   ZeroMemory( &EncoderParameters, sizeof( EncoderParameters ) );
   EncoderParameters.Count = 1;
   EncoderParameters.Parameter[ 0 ].Guid.Data1      = 0x1d5be4b5;
   EncoderParameters.Parameter[ 0 ].Guid.Data2      = 0xfa4a;
   EncoderParameters.Parameter[ 0 ].Guid.Data3      = 0x452d;
   EncoderParameters.Parameter[ 0 ].Guid.Data4[ 0 ] = 0x9c;
   EncoderParameters.Parameter[ 0 ].Guid.Data4[ 1 ] = 0xdd;
   EncoderParameters.Parameter[ 0 ].Guid.Data4[ 2 ] = 0x5d;
   EncoderParameters.Parameter[ 0 ].Guid.Data4[ 3 ] = 0xb3;
   EncoderParameters.Parameter[ 0 ].Guid.Data4[ 4 ] = 0x51;
   EncoderParameters.Parameter[ 0 ].Guid.Data4[ 5 ] = 0x05;
   EncoderParameters.Parameter[ 0 ].Guid.Data4[ 6 ] = 0xe7;
   EncoderParameters.Parameter[ 0 ].Guid.Data4[ 7 ] = 0xeb;
   EncoderParameters.Parameter[ 0 ].NumberOfValues  = 1;
   EncoderParameters.Parameter[ 0 ].Type  = 4;
   EncoderParameters.Parameter[ 0 ].Value = ( void * ) &JpgQuality;

   GBitmap = 0;

   if( fn_GdipCreateBitmapFromHBITMAP( HBitmap, NULL, &GBitmap ) )
   {
      MessageBox( NULL, "CreateBitmap Operation Error", "GPlus error", MB_OK | MB_ICONINFORMATION | MB_SYSTEMMODAL );

      return FALSE;
   }

   WFileName = LocalAlloc( LPTR, ( strlen( FileName ) * sizeof( WCHAR ) ) + 1 );

   if( WFileName == NULL )
   {
      MessageBox( NULL, "WFile LocalAlloc Error", "GPlus error", MB_OK | MB_ICONINFORMATION | MB_SYSTEMMODAL );

      return FALSE;
   }

   MultiByteToWideChar( CP_ACP, 0, FileName, -1, WFileName, ( strlen( FileName ) * sizeof( WCHAR ) ) - 1 );

   if( ( Width > 0 ) && ( Height > 0 ) )
   {
      GBitmapThumbnail = NULL;

      if( Ok != fn_GdipGetImageThumbnail( GBitmap, Width, Height, &GBitmapThumbnail, NULL, NULL ) )
      {
         fn_GdipDisposeImage( GBitmap );
         LocalFree( WFileName );
         MessageBox( NULL, "Thumbnail Operation Error", "GPlus error", MB_OK | MB_ICONINFORMATION | MB_SYSTEMMODAL );

         return FALSE;
      }

      fn_GdipDisposeImage( GBitmap );
      GBitmap = GBitmapThumbnail;
   }

   if( Ok != fn_GdipSaveImageToFile( GBitmap, WFileName, &Clsid, &EncoderParameters ) )
   {
      fn_GdipDisposeImage( GBitmap );
      LocalFree( WFileName );
      MessageBox( NULL, "Save Operation Error", "GPlus error", MB_OK | MB_ICONINFORMATION | MB_SYSTEMMODAL );

      return FALSE;
   }

   fn_GdipDisposeImage( GBitmap );
   LocalFree( WFileName );

   return TRUE;
}

#pragma ENDUMP