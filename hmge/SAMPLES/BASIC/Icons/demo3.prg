/*
* Author: P.Chornyj <myorg63@mail.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"
#include "i_winuser.ch"

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
         clientarea 3*w, 2*h + 2*GetMenuBarHeight() ;
         title 'Draw the bitmap or icon image using the Windows DrawState' ;
         main ;
         nomaximize nosize ;
         on paint Form_Main_OnPaint( Form_Main.Handle, hIcon, w, h );
         on release ;
         ( ;
         DestroyIcon( hIcon ) ;
         )

      DEFINE MAIN MENU
         DEFINE POPUP "&File"
            MENUITEM "E&xit" action ThisWindow.Release
         END POPUP
      END MENU
   END WINDOW

   on key Escape of Form_Main action ThisWindow.Release

   Form_Main.Center()
   Form_Main.Activate()

   RETURN

FUNCTION Form_Main_OnPaint( hWnd, hIcon, w, h )

   LOCAL y  := h + GetMenuBarHeight()
   LOCAL x1 := 0
   LOCAL x2 := w + 1
   LOCAL x3 := 2*w + 1
   LOCAL nColor

   DrawState( hWnd, Nil,    Nil, hIcon, Nil, x1, 0, w, h, hb_BitOr( DST_ICON, DSS_DISABLED ), .f. )
   //DrawIconEx( hWnd, x2, 0, hIcon, w, h, GetSysColor( COLOR_BTNFACE ), .f. )
   DrawState( hWnd, Nil,    Nil, hIcon, Nil, x2, 0, w, h, hb_BitOr( DST_ICON, DSS_NORMAL ), .f. )
   DrawState( hWnd, LGREEN, Nil, hIcon, Nil, x3, 0, w, h, hb_BitOr( DST_ICON, DSS_UNION ), .f. )

   DrawState( hWnd, RED,    Nil, hIcon, Nil, x1, y, w, h, hb_BitOr( DST_ICON, DSS_MONO ), .f. )
   DrawState( hWnd, GREEN,  Nil, hIcon, Nil, x2, y, w, h, hb_BitOr( DST_ICON, DSS_MONO ), .f. )
   DrawState( hWnd, BLUE,   Nil, hIcon, Nil, x3, y, w, h, hb_BitOr( DST_ICON, DSS_MONO ), .f. )

   nColor = SetBackColor( hWnd, RGB( 250, 0, 0 ) )
   // nColor = SetBackColor( hWnd, 250, 0, 0 )
   // nColor = SetBackColor( hWnd, { 250, 0, 0 } )

   IF w > 128
      DrawState( hWnd, Nil,    Nil, "der Achtungsapplaus", Nil, 0*w + w/4, h, 0, 0, hb_BitOr( DST_TEXT, DSS_DISABLED ), .f. )
      DrawState( hWnd, Nil,    Nil, "der Achtungsapplaus", Nil, 1*w + w/4, h, 0, 0, hb_BitOr( DST_TEXT, DSS_NORMAL ), .f. )
      DrawState( hWnd, LGREEN, Nil, "der Achtungsapplaus", Nil, 2*w + w/4, h, 0, 0, hb_BitOr( DST_TEXT, DSS_UNION ), .f. )
   ENDIF

   SetBackColor( hWnd, nColor )
   // SetBackColor( hWnd, GetRed( nColor ), GetGreen( nColor ), GetBlue( nColor ) )
   // SetBackColor( hWnd, { GetRed( nColor ), GetGreen( nColor ), GetBlue( nColor ) } )

   RETURN NIL
