/*
 * Miscelaneous C Functions
 * Compiled by: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licensed under The Code Project Open License (CPOL) 1.02
 * See <http://www.codeproject.com/info/cpol10.aspx>
 */

#pragma BEGINDUMP

#include <windows.h>
#include <hbapi.h>
#include <commctrl.h>
#include <tchar.h>

#define VK_A      65
#define VK_C      67
#define VK_V      86
#define VK_X      88

#ifdef __XHARBOUR__
#define HB_STORL( n, x, y ) hb_storl( n, x, y )
#define HB_STORNI( n, x, y ) hb_storni( n, x, y )
#define HB_STORNL( n, x, y ) hb_stornl( n, x, y )
#else
#define HB_STORL( n, x, y ) hb_storvl( n, x, y )
#define HB_STORNI( n, x, y ) hb_storvni( n, x, y )
#define HB_STORNL( n, x, y ) hb_storvnl( n, x, y )
#endif

//----------------------------------------------------------------------------//
HB_FUNC( INSERTESC )
{
   keybd_event( VK_ESCAPE, // virtual-key code
                0,         // hardware scan code
                0,         // flags specifying various function options
                0          // additional data associated with keystroke
              );
}

//----------------------------------------------------------------------------//
HB_FUNC( GETSCREENDPI )
{
   HDC hDC;
   int iDPI;

   memset( &iDPI, 0, sizeof( iDPI ) );
   memset( &hDC, 0, sizeof( hDC ) );

   hDC = GetDC( HWND_DESKTOP );

   iDPI = GetDeviceCaps( hDC, LOGPIXELSX );

   ReleaseDC( HWND_DESKTOP, hDC );

   hb_retni( iDPI );
}

//----------------------------------------------------------------------------//
HB_FUNC( GETOTHERMETRICS )
{
   NONCLIENTMETRICS ncm = {0};

   ncm.cbSize = sizeof( ncm );

   if( ! SystemParametersInfo( SPI_GETNONCLIENTMETRICS, sizeof( ncm ), &ncm, 0 ) )
   {
      hb_reta( 9 );
      HB_STORNI( 0 , -1, 1 );
      HB_STORNI( 0 , -1, 2 );
      HB_STORNI( 0 , -1, 3 );
      HB_STORNI( 0 , -1, 4 );
      HB_STORNI( 0 , -1, 5 );
      HB_STORNI( 0 , -1, 6 );
      HB_STORNI( 0 , -1, 7 );
      HB_STORNI( 0 , -1, 8 );
      HB_STORNI( 0 , -1, 9 );
      return;
   }

   hb_reta( 9 );
   HB_STORNI( ncm.iBorderWidth , -1, 1 );          // The thickness of the sizing border, in pixels.
   HB_STORNI( ncm.iScrollWidth , -1, 2 );          // The width of a standard vertical scroll bar, in pixels.
   HB_STORNI( ncm.iScrollHeight , -1, 3 );         // The height of a standard horizontal scroll bar, in pixels.
   HB_STORNI( ncm.iCaptionWidth , -1, 4 );         // The width of caption buttons, in pixels.
   HB_STORNI( ncm.iCaptionHeight , -1, 5 );        // The height of caption buttons, in pixels.
   HB_STORNI( ncm.iSmCaptionWidth , -1, 6 );       // The width of small caption buttons, in pixels.
   HB_STORNI( ncm.iSmCaptionHeight , -1, 7 );      // The height of small captions, in pixels.
   HB_STORNI( ncm.iMenuWidth , -1, 8 );            // The width of menu-bar buttons, in pixels.
   HB_STORNI( ncm.iMenuHeight , -1, 9 );           // The height of a menu bar, in pixels.

}

//----------------------------------------------------------------------------//
HB_FUNC( SEND_SELECTALL )
// select all - ctrl-a
{
  keybd_event( VK_CONTROL, MapVirtualKey( VK_CONTROL, 0 ), 0, 0 );
  keybd_event( VK_A, MapVirtualKey( VK_A, 0 ), 0, 0 );
  keybd_event( VK_A, MapVirtualKey( VK_A, 0 ), KEYEVENTF_KEYUP, 0 );
  keybd_event( VK_CONTROL, MapVirtualKey( VK_CONTROL, 0 ), KEYEVENTF_KEYUP, 0 );
}

//----------------------------------------------------------------------------//
HB_FUNC( SEND_COPY )
// copy - ctrl-c
{
  keybd_event( VK_CONTROL, MapVirtualKey( VK_CONTROL, 0 ), 0, 0 );
  keybd_event( VK_C, MapVirtualKey( VK_C, 0 ), 0, 0 );
  keybd_event( VK_C, MapVirtualKey( VK_C, 0 ), KEYEVENTF_KEYUP, 0 );
  keybd_event( VK_CONTROL, MapVirtualKey( VK_CONTROL, 0 ), KEYEVENTF_KEYUP, 0 );
}

//----------------------------------------------------------------------------//
HB_FUNC( SEND_PASTE )
// paste - ctrl-v
{
  keybd_event( VK_CONTROL, MapVirtualKey( VK_CONTROL, 0 ), 0, 0 );
  keybd_event( VK_V, MapVirtualKey( VK_V, 0 ), 0, 0 );
  keybd_event( VK_V, MapVirtualKey( VK_V, 0 ), KEYEVENTF_KEYUP, 0 );
  keybd_event( VK_CONTROL, MapVirtualKey( VK_CONTROL, 0 ), KEYEVENTF_KEYUP, 0 );
}

//----------------------------------------------------------------------------//
HB_FUNC( SEND_CUT )
// cut - ctrl-x
{
  keybd_event( VK_CONTROL, MapVirtualKey( VK_CONTROL, 0 ), 0, 0 );
  keybd_event( VK_X, MapVirtualKey( VK_X, 0 ), 0, 0 );
  keybd_event( VK_X, MapVirtualKey( VK_X, 0 ), KEYEVENTF_KEYUP, 0 );
  keybd_event( VK_CONTROL, MapVirtualKey( VK_CONTROL, 0 ), KEYEVENTF_KEYUP, 0 );
}

//----------------------------------------------------------------------------//
HB_FUNC( COPYCLIPBOARD )
// CopyClipboard( cText ) stores cText in Windows clipboard
{
  HGLOBAL hglbCopy;
  char * lptstrCopy;

  const char * cStr = hb_parc( 1 );
  int nLen = strlen( cStr );

  if( ! OpenClipboard( GetActiveWindow() ) )
  {
    return;
  }

  EmptyClipboard();

  hglbCopy = GlobalAlloc( GMEM_DDESHARE, ( nLen + 1) * sizeof( TCHAR ) );
  if( hglbCopy == NULL )
  {
    CloseClipboard();
    return;
  }

  lptstrCopy = (char*) GlobalLock( hglbCopy );
  memcpy( lptstrCopy, cStr, nLen * sizeof( TCHAR ) );
  lptstrCopy[ nLen ] = (TCHAR) 0;                  // null character
  GlobalUnlock( hglbCopy );

  SetClipboardData( CF_TEXT, hglbCopy );
  CloseClipboard();
}

//----------------------------------------------------------------------------//
HB_FUNC( RETRIVETEXTFROMCLIPBOARD )
{
  if( ! OpenClipboard( GetActiveWindow() ) )
  {
    return;
  }

  hb_retc( GetClipboardData( CF_TEXT ) );
  CloseClipboard();
}

//----------------------------------------------------------------------------//
HB_FUNC( GETCLIPBOARDDATA )
{
  HANDLE hClipMem;
  LPSTR lpClip;

  hClipMem = GetClipboardData( (UINT) hb_parni( 1 ) );

  if( hClipMem )
  {
    lpClip = (LPSTR) GlobalLock( hClipMem );
    hb_retclen( lpClip , GlobalSize( hClipMem ) );
    GlobalUnlock( hClipMem );
  }
}

//----------------------------------------------------------------------------//
HB_FUNC( GETDESKTOPREALTOP )
//  Returns the row where the free part of the desktop starts
{
   RECT rect;
   int t;

   SystemParametersInfo( SPI_GETWORKAREA, 1, &rect, 0 );
   t = rect.top;

   hb_retni( t );
}

//----------------------------------------------------------------------------//
HB_FUNC( GETDESKTOPREALLEFT )
//  Returns the column where the free part of the desktop starts
{
   RECT rect;
   int l;

   SystemParametersInfo( SPI_GETWORKAREA, 1, &rect, 0 );
   l = rect.left;

   hb_retni( l );
}

/*
These functions are included in OOHG libraries

//----------------------------------------------------------------------------//
HB_FUNC( GETDESKTOPREALWIDTH )
//  Returns the width of the free part of the desktop
{
   RECT rect;
   int w;

   SystemParametersInfo( SPI_GETWORKAREA, 1, &rect, 0 );
   w = rect.right - rect.left;

   hb_retni( w );
}

//----------------------------------------------------------------------------//
HB_FUNC( GETDESKTOPREALHEIGHT )
//  Returns the height of the free part of the desktop
{
   RECT rect;
   int h;

   SystemParametersInfo( SPI_GETWORKAREA, 1, &rect, 0 );
   h = rect.bottom - rect.top;

   hb_retni( h );
}

#pragma ENDDUMP
*/

/*
 * EOF
 */
