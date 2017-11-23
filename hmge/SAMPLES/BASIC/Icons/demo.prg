/*
* Author: P.Chornyj <myorg63@mail.ru>
* A Quick & Easy guide to Microsoft Windows Icon Size
* https://www.creativefreedom.co.uk/icon-designers-blog/windows-7-icon-sizes/
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

PROCEDURE main()

   LOCAL cIcon := 'IconVista.ico', hIcon
   LOCAL aInfo, w, h

   IF IsVistaOrLater()
      hIcon := LoadIconByName( cIcon, 256, 256 )
   ELSEIF IsWinXPorLater()
      hIcon := LoadIconByName( cIcon, 128, 128 )
   ENDIF

   IF Empty( hIcon )
      QUIT
   ENDIF

   aInfo := GetIconSize( hIcon )
   w := aInfo[ 1 ]
   h := aInfo[ 2 ]

   DEFINE WINDOW Form_Main ;
         clientarea w, h + GetMenuBarHeight() ;
         title 'Icons Demo' ;
         main ;
         nomaximize nosize ;
         on release ;
         ( ;
         DestroyIcon( hIcon ) ;
         )

      DEFINE MAIN MENU
         DEFINE POPUP "&File"
            menuitem "E&xit" action ThisWindow.Release
         end popup
      end menu
   END WINDOW

   draw icon in window Form_Main at 0, 0 hicon hIcon width w height h

   on key Escape of Form_Main action ThisWindow.Release

   Form_Main.Center()
   Form_Main.Activate()

   RETURN
