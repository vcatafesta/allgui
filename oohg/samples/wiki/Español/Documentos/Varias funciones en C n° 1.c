/*
 * Varias Funciones en C n° 1
 * Compiladas por: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
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
   keybd_event( VK_ESCAPE, // código de tecla virtual
                0,         // código de hardware (scan code)
                0,         // opciones
                0          // información adicional
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
   HB_STORNI( ncm.iBorderWidth , -1, 1 );          // Ancho del borde arrastrable, en pixels.
   HB_STORNI( ncm.iScrollWidth , -1, 2 );          // Ancho de una barra de scroll vertical estándar, en pixels.
   HB_STORNI( ncm.iScrollHeight , -1, 3 );         // Alto de una barra de scroll vertical estándar, en pixels.
   HB_STORNI( ncm.iCaptionWidth , -1, 4 );         // Ancho de los botones del título, en pixels.
   HB_STORNI( ncm.iCaptionHeight , -1, 5 );        // Alto de los botones del título, en pixels.
   HB_STORNI( ncm.iSmCaptionWidth , -1, 6 );       // Ancho de los botones pequeños del título, en pixels.
   HB_STORNI( ncm.iSmCaptionHeight , -1, 7 );      // Alto de los botones del título, en pixels.
   HB_STORNI( ncm.iMenuWidth , -1, 8 );            // Ancho de los botones de la barra de menúes, en pixels.
   HB_STORNI( ncm.iMenuHeight , -1, 9 );           // Alto de los botones de la barra de menúes, en pixels.

}

//----------------------------------------------------------------------------//
HB_FUNC( SEND_SELECTALL )
// seleccionar todo - ctrl-a
{
  keybd_event( VK_CONTROL, MapVirtualKey( VK_CONTROL, 0 ), 0, 0 );
  keybd_event( VK_A, MapVirtualKey( VK_A, 0 ), 0, 0 );
  keybd_event( VK_A, MapVirtualKey( VK_A, 0 ), KEYEVENTF_KEYUP, 0 );
  keybd_event( VK_CONTROL, MapVirtualKey( VK_CONTROL, 0 ), KEYEVENTF_KEYUP, 0 );
}

//----------------------------------------------------------------------------//
HB_FUNC( SEND_COPY )
// copiar - ctrl-c
{
  keybd_event( VK_CONTROL, MapVirtualKey( VK_CONTROL, 0 ), 0, 0 );
  keybd_event( VK_C, MapVirtualKey( VK_C, 0 ), 0, 0 );
  keybd_event( VK_C, MapVirtualKey( VK_C, 0 ), KEYEVENTF_KEYUP, 0 );
  keybd_event( VK_CONTROL, MapVirtualKey( VK_CONTROL, 0 ), KEYEVENTF_KEYUP, 0 );
}

//----------------------------------------------------------------------------//
HB_FUNC( SEND_PASTE )
// pegar - ctrl-v
{
  keybd_event( VK_CONTROL, MapVirtualKey( VK_CONTROL, 0 ), 0, 0 );
  keybd_event( VK_V, MapVirtualKey( VK_V, 0 ), 0, 0 );
  keybd_event( VK_V, MapVirtualKey( VK_V, 0 ), KEYEVENTF_KEYUP, 0 );
  keybd_event( VK_CONTROL, MapVirtualKey( VK_CONTROL, 0 ), KEYEVENTF_KEYUP, 0 );
}

//----------------------------------------------------------------------------//
HB_FUNC( SEND_CUT )
// cortar - ctrl-x
{
  keybd_event( VK_CONTROL, MapVirtualKey( VK_CONTROL, 0 ), 0, 0 );
  keybd_event( VK_X, MapVirtualKey( VK_X, 0 ), 0, 0 );
  keybd_event( VK_X, MapVirtualKey( VK_X, 0 ), KEYEVENTF_KEYUP, 0 );
  keybd_event( VK_CONTROL, MapVirtualKey( VK_CONTROL, 0 ), KEYEVENTF_KEYUP, 0 );
}

//----------------------------------------------------------------------------//
HB_FUNC( COPYCLIPBOARD )
// CopyClipboard( cText ) guarda cText en el portapapeles de Windows
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
  lptstrCopy[ nLen ] = (TCHAR) 0;                  // carácter NULL
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
//  Retorna la fila donde comienza la parte libre del escritorio
{
   RECT rect;
   int t;

   SystemParametersInfo( SPI_GETWORKAREA, 1, &rect, 0 );
   t = rect.top;

   hb_retni( t );
}

//----------------------------------------------------------------------------//
HB_FUNC( GETDESKTOPREALLEFT )
//  Retorna la columna donde comienza la parte libre del escritorio
{
   RECT rect;
   int l;

   SystemParametersInfo( SPI_GETWORKAREA, 1, &rect, 0 );
   l = rect.left;

   hb_retni( l );
}

//----------------------------------------------------------------------------//
HB_FUNC( GETDESKTOPREALWIDTH )
//  Retorna el ancho de la parte libre del escritorio
{
   RECT rect;
   int w;

   SystemParametersInfo( SPI_GETWORKAREA, 1, &rect, 0 );
   w = rect.right - rect.left;

   hb_retni( w );
}

//----------------------------------------------------------------------------//
HB_FUNC( GETDESKTOPREALHEIGHT )
//  Retorna el alto de la parte libre del escritorio
{
   RECT rect;
   int h;

   SystemParametersInfo( SPI_GETWORKAREA, 1, &rect, 0 );
   h = rect.bottom - rect.top;

   hb_retni( h );
}

#pragma ENDDUMP

/*
 * EOF
 */
