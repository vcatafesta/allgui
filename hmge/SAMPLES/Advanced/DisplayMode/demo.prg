/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2002-2007 Roberto Lopez <harbourminigui@gmail.com>
* http://harbourminigui.googlepages.com/
* Copyright 2004-2008 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

STATIC nMode, aSets := {}

PROCEDURE main()

   LOCAL aRet := DisplayDevMode(), aMode := {}, i, cStr

   FOR i := 1 to len( aRet ) step 3
      IF empty( aRet[i] )
         EXIT
      ENDIF
      cStr := Str( aRet[i], 4 ) + ' x ' + Str( aRet[i + 1], 4 ) + ' - ' + Str( aRet[i + 2], 2 ) + ' Colors'
      aadd( aSets, cStr )
      IF ascan( aMode, cStr ) == 0
         aadd( aMode, cStr )
      ENDIF
   NEXT

   asort( aMode )

   aRet := DisplayCurrentMode()

   nMode := ascan( aMode, Str( aRet[1], 4 ) + ' x ' + Str( aRet[2], 4 ) + ' - ' + Str( aRet[3], 2 ) )

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH 400 ;
         HEIGHT 350 + IF(IsXPThemeActive(), 8, 0) ;
         TITLE 'Changing Of Display Resolution' ;
         MAIN ;
         ICON 'MAIN' NOMAXIMIZE NOSIZE

      DEFINE LISTBOX List_1
         ROW   20
         COL   15
         WIDTH 360
         HEIGHT 260
         ITEMS aMode
         VALUE nMode
         TOOLTIP 'Available Resolutions'
      END LISTBOX

      DEFINE BUTTON Btn_1
         row 290
         col Form_1.Width - 344
         caption "OK"
         action ( ApplyChanges(), Form_1.Release() )
      END BUTTON

      DEFINE BUTTON Btn_2
         row 290
         col Form_1.Width - 234
         caption "Cancel"
         action Form_1.Release()
      END BUTTON

      DEFINE BUTTON Btn_3
         row 290
         col Form_1.Width - 124
         caption "Apply"
         action ApplyChanges()
      END BUTTON

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

   RETURN

PROCEDURE ApplyChanges()

   LOCAL nSet := Form_1.List_1.Value

   IF nMode # nSet
      nMode := nSet
      nSet := ascan( aSets, Form_1.List_1.Item( nMode ) )
      ChangeDisplayMode( nSet )
      CENTER WINDOW Form_1
   ENDIF

   RETURN

#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

#ifdef __XHARBOUR__
#define HB_STORNI( n, x, y ) hb_storni( n, x, y )
#else
#define HB_STORNI( n, x, y ) hb_storvni( n, x, y )
#endif

HB_FUNC( DISPLAYDEVMODE )
{
   int i = 0;
   int j = 1;
   DEVMODE  lpDevMode;

   hb_reta( 600 );

   while (EnumDisplaySettings(NULL, i++, &lpDevMode))
   {
      HB_STORNI( lpDevMode.dmPelsWidth,  -1, j++ );
      HB_STORNI( lpDevMode.dmPelsHeight, -1, j++ );
      HB_STORNI( lpDevMode.dmBitsPerPel, -1, j++ );
   }
}

HB_FUNC( DISPLAYCURRENTMODE )
{
   DEVMODE  lpDevMode;

   hb_reta( 3 );

   if (EnumDisplaySettings(NULL, ENUM_CURRENT_SETTINGS, &lpDevMode))
   {
      HB_STORNI( lpDevMode.dmPelsWidth,  -1, 1 );
      HB_STORNI( lpDevMode.dmPelsHeight, -1, 2 );
      HB_STORNI( lpDevMode.dmBitsPerPel, -1, 3 );
   }
}

HB_FUNC( CHANGEDISPLAYMODE )
{
   DEVMODE dm;
   dm.dmSize = sizeof(dm);

   EnumDisplaySettings(NULL, hb_parni(1)-1, &dm);
   dm.dmFields = DM_PELSWIDTH | DM_PELSHEIGHT | DM_BITSPERPEL | DM_DISPLAYFREQUENCY;

   if (ChangeDisplaySettings(&dm, CDS_UPDATEREGISTRY) != DISP_CHANGE_SUCCESSFUL)
      MessageBox(GetActiveWindow(), "Wrong Change Display Settings!", "Error", MB_OK | MB_ICONERROR);

   SendMessage(HWND_BROADCAST,
      WM_DISPLAYCHANGE,
      SPI_SETNONCLIENTMETRICS,
      0);
}

#pragma ENDDUMP

