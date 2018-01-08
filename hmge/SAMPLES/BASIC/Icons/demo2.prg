/*
* Author: P.Chornyj <myorg63@mail.ru>
* A Quick & Easy guide to Microsoft Windows Icon Size
* https://www.creativefreedom.co.uk/icon-designers-blog/windows-7-icon-sizes/
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define LOAD_LIBRARY_AS_DATAFILE   0x00000002

PROCEDURE main()

   LOCAL hLib
   LOCAL cIcon := 'ICONVISTA', hIconFromDll, hIcon
   LOCAL aInfo, w, h

   hLib := LoadLibraryEx( 'myicons.dll', 0, LOAD_LIBRARY_AS_DATAFILE )

   IF ! Empty( hLib )
      IF IsVistaOrLater()
         hIconFromDll := LoadIconByName( cIcon, 256, 256, hLib )
      ELSEIF IsWinXPorLater()
         hIconFromDll := LoadIconByName( cIcon, 128, 128, hLib )
      ENDIF

      IF ! Empty( hIconFromDll )
         hIcon := CopyIcon( hIconFromDll )
         DestroyIcon( hIconFromDll )
      ENDIF

      FreeLibrary( hLib )
   ENDIF

   IF Empty( hIcon )
      QUIT
   ENDIF

   aInfo := GetIconSize( hIcon )
   w := aInfo[ 1 ]
   h := aInfo[ 2 ]

   DEFINE WINDOW Form_Main ;
         clientarea w, h + GetMenuBarHeight() ;
         TITLE 'Icons Demo (use a Dll)' ;
         MAIN ;
         NOMAXIMIZE nosize ;
         ON RELEASE ;
         ( ;
         DestroyIcon( hIcon ) ;
         )

      DEFINE MAIN MENU
         DEFINE POPUP "&File"
            MENUITEM "E&xit" action ThisWindow.Release
         END POPUP
      END MENU
   END WINDOW

   draw icon in window Form_Main at 0, 0 hicon hIcon width w height h

   on key Escape of Form_Main action ThisWindow.Release

   Form_Main.Center()
   Form_Main.Activate()

   RETURN
