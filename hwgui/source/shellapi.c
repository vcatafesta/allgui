/*
 * $Id: shellapi.c 2012 2013-03-07 09:03:56Z alkresin $
 *
 * HWGUI - Harbour Win32 GUI library source code:
 * Shell API wrappers
 *
 * Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://kresin.belgorod.su
*/

#include "hwingui.h"
#include <shlobj.h>

#include <shellapi.h>

#include "hbapi.h"
#include "hbapiitm.h"

#define  ID_NOTIFYICON   1
#define  WM_NOTIFYICON   WM_USER+1000
#define  WM_TASKBAR      WM_USER+1043

#ifndef BIF_USENEWUI
#ifndef BIF_NEWDIALOGSTYLE
#define BIF_NEWDIALOGSTYLE     0x0040   // Use the new dialog layout with the ability to resize
#endif
#define BIF_USENEWUI           (BIF_NEWDIALOGSTYLE | BIF_EDITBOX)
#endif
#ifndef BIF_EDITBOX
#define BIF_EDITBOX            0x0010   // Add an editbox to the dialog
#endif

#define NOTIFYICON_VERSION_4 4

#define NIF_SHOWTIP 0x00000080
#define NIF_GUID    0x00000020

static int ( CALLBACK BrowseCallbackProc ) (  HWND hwnd,  UINT uMsg,  LPARAM lParam,  LPARAM lpData )
{
// If the BFFM_INITIALIZED message is received
// set the path to the start path.
lParam = TRUE;
switch ( uMsg )
{
   case BFFM_INITIALIZED:
      {
         if ( lpData  != (LPARAM)NULL )
         {
            SendMessage( hwnd, BFFM_SETSELECTION, lParam, lpData );
         }
      }
   }
   return 0; // The function should always return 0.
}

/*
 *  SelectFolder( cTitle )
 */

HB_FUNC( HWG_SELECTFOLDER )
{
   BROWSEINFO bi;
   TCHAR lpBuffer[ MAX_PATH ];
   LPCTSTR lpResult = NULL;
   LPITEMIDLIST pidlBrowse;     // PIDL selected by user
   void * hTitle;
   void * hFolderName;
   LPCTSTR lpFolderName;

   lpFolderName = HB_PARSTR( 2, &hFolderName, NULL ) ;
   bi.hwndOwner = GetActiveWindow();
   bi.pidlRoot = NULL ;
   bi.pszDisplayName = lpBuffer;
   bi.lpszTitle = HB_PARSTRDEF( 1, &hTitle, NULL );
   bi.ulFlags = BIF_USENEWUI | BIF_NEWDIALOGSTYLE;
   bi.lpfn = BrowseCallbackProc ; // = NULL;
   bi.lParam = lpFolderName ? ( LPARAM ) lpFolderName : 0 ;
   bi.iImage = 0;

   // Browse for a folder and return its PIDL.
   pidlBrowse = SHBrowseForFolder( &bi );
   if( pidlBrowse != NULL )
   {
      if( SHGetPathFromIDList( pidlBrowse, lpBuffer ) )
         lpResult = lpBuffer;
      CoTaskMemFree( pidlBrowse );
   }
   HB_RETSTR( lpResult );
   hb_strfree( hTitle );
   hb_strfree( hFolderName );
}

/*
 *  ShellNotifyIcon( lAdd, hWnd, hIcon, cTooltip )
 */

HB_FUNC( HWG_SHELLNOTIFYICON )
{
   NOTIFYICONDATA tnid;

   memset( ( void * ) &tnid, 0, sizeof( NOTIFYICONDATA ) );

   tnid.cbSize = sizeof( NOTIFYICONDATA );
   tnid.hWnd = ( HWND ) HB_PARHANDLE( 2 );
   tnid.uID = ID_NOTIFYICON;
   //tnid.uFlags = NIF_ICON | NIF_INFO | NIF_MESSAGE | NIF_TIP;
   tnid.uFlags = NIF_ICON | NIF_INFO | NIF_TIP | NIF_MESSAGE;
   tnid.uCallbackMessage = WM_NOTIFYICON;
   tnid.dwInfoFlags = (DWORD) hb_parnl(7);
   tnid.hIcon = ( HICON ) HB_PARHANDLE( 3 );
   tnid.uVersion = NOTIFYICON_VERSION_4;

   tnid.szInfo[0] = 0;

   //tnid.uTimeout = 2000;

   HB_ITEMCOPYSTR( hb_param( 4, HB_IT_ANY ), tnid.szTip, HB_SIZEOFARRAY( tnid.szTip ) );

   //lstrcpy( tnid.szTip, TEXT((LPSTR) hb_parc(4)) );
   lstrcpy( tnid.szInfo, TEXT((LPSTR) hb_parc(5)) );
   lstrcpy( tnid.szInfoTitle, TEXT((LPSTR) hb_parc(6)) );

   Shell_NotifyIcon( NIM_MODIFY, &tnid );

   //Shell_NotifyIcon( NIM_SETVERSION, &tnid );

   if( ( BOOL ) hb_parl( 1 ) )
      Shell_NotifyIcon( NIM_ADD, &tnid );
   else
      Shell_NotifyIcon( NIM_DELETE, &tnid );

}

/*
  *  ShellModifyIcon( hWnd, hIcon, cTooltip )
  */

HB_FUNC( HWG_SHELLMODIFYICON )
{
   NOTIFYICONDATA tnid;

   memset( ( void * ) &tnid, 0, sizeof( NOTIFYICONDATA ) );

   tnid.cbSize = sizeof( NOTIFYICONDATA );
   tnid.hWnd = ( HWND ) HB_PARHANDLE( 1 );
   tnid.uID = ID_NOTIFYICON;

   if( HB_ISNUM( 2 ) || HB_ISPOINTER( 2 ) )
   {
      tnid.uFlags |= NIF_ICON;
      tnid.hIcon = ( HICON ) HB_PARHANDLE( 2 );
   }
   if( HB_ITEMCOPYSTR( hb_param( 3, HB_IT_ANY ),
                       tnid.szTip, HB_SIZEOFARRAY( tnid.szTip ) ) > 0 )
   {
      tnid.uFlags |= NIF_INFO;
      tnid.uFlags |= NIF_TIP;
   }

   tnid.dwInfoFlags = (DWORD) hb_parnl(6);

   if( HB_ITEMCOPYSTR( hb_param( 4, HB_IT_ANY ),
                       tnid.szInfo, HB_SIZEOFARRAY( tnid.szInfo ) ) > 0 )
   {
      lstrcpy( tnid.szInfo, TEXT((LPSTR) hb_parc(4)) );
      lstrcpy( tnid.szInfoTitle, TEXT((LPSTR) hb_parc(5)) );
   }

   Shell_NotifyIcon( NIM_MODIFY, &tnid );
}

/*
 * ShellExecute( cFile, cOperation, cParams, cDir, nFlag )
 */
HB_FUNC( HWG_SHELLEXECUTE )
{
#if defined( HB_OS_WIN_CE )
   hb_retni( -1 );
#else
   void * hOperation;
   void * hFile;
   void * hParameters;
   void * hDirectory;
   LPCTSTR lpDirectory;

   lpDirectory = HB_PARSTR( 4, &hDirectory , NULL );
   if( lpDirectory == NULL )
      lpDirectory = TEXT( "C:\\" );

   hb_retnl( ( LONG ) ShellExecute( GetActiveWindow(),
                  HB_PARSTRDEF( 2, &hOperation, NULL ),
                  HB_PARSTR( 1, &hFile, NULL ),
                  HB_PARSTR( 3, &hParameters, NULL ),
                  lpDirectory,
                  HB_ISNUM( 5 ) ? hb_parni( 5 ) : SW_SHOWNORMAL ) );

   hb_strfree( hOperation );
   hb_strfree( hFile );
   hb_strfree( hParameters );
   hb_strfree( hDirectory );
#endif
}
