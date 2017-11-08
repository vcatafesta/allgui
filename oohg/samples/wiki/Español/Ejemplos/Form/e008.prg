/*
 * Ejemplo Form n° 8
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Adaptado del "Transparency Sample By Grigory Filatov"
 * incluido en el paquete HMG Extended.
 *
 * Este ejemplo muestra cómo usar transparencia en un
 * formulario.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main

   LOCAL oForm1

   DEFINE WINDOW Form_1 ;
      OBJ oForm1 ;
      AT 0,0 ;
      WIDTH 400 ;
      HEIGHT 200 ;
      MAIN ;
      TITLE "OOHG - Formulario con transparencia" ;
      BACKCOLOR YELLOW ;
      ON INIT ( oForm1:Slider_1:Enabled := .f., ;
                MakeOpaque( oForm1 ), ;
                oForm1:TextBox_1:Enabled := .f., ;
                oForm1:Button_1:Enabled := .t., ;
                oForm1:Button_2:Enabled := .f. )

      ON KEY ESCAPE ACTION oForm1:Release()

      @ 10, 200 LABEL lbl_aviso ;
         VALUE "HAGA CLIC AQUI PARA VER EL FORMULARIO" ;
         WIDTH 190 ;
         HEIGHT 40 ;
         BORDER ;
         BACKCOLOR GREEN ;
         FONTCOLOR BLUE ;
         CENTER ;
         ON CLICK ( oForm1:Slider_1:Enabled := .f., ;
                     MakeOpaque( oForm1 ), ;
                     oForm1:TextBox_1:Enabled := .f., ;
                     oForm1:Button_1:Enabled := .t., ;
                     oForm1:Button_2:Enabled := .f. )

      @ 10, 10 BUTTON Button_1 ;
         OBJ oBut1 ;
         CAPTION 'Activar Transparencia' ;
         WIDTH   140 ;
         ACTION ( oForm1:Slider_1:Enabled := .t., ;
                  oForm1:TextBox_1:Enabled := .t., ;
                  oForm1:Button_1:Enabled := .f., ;
                  oForm1:Button_2:Enabled := .t., ;
                  oForm1:Slider_1:Value := 180 )
      oBut1:Transparent := .T.

      @ 40, 10 BUTTON Button_2 ;
         OBJ oBut2 ;
         CAPTION 'Desactivar Transparencia' ;
         WIDTH   140 ;
         ACTION ( oForm1:Slider_1:Enabled := .f., ;
                  MakeOpaque( oForm1 ), ;
                  oForm1:TextBox_1:Enabled := .f., ;
                  oForm1:Button_1:Enabled := .t., ;
                  oForm1:Button_2:Enabled := .f. )
      oBut2:Transparent := .T.

      @ 50, 200 BUTTON Button_3 ;
         OBJ oBut3 ;
         CAPTION "Fondo Invisible" ;
         WIDTH   140 ;
         ACTION {|| SetBackgroundInvisible( oBut1:hWnd, oForm1:BackColorCode ), ;
                    SetBackgroundInvisible( oBut2:hWnd, oForm1:BackColorCode ), ;
                    SetBackgroundInvisible( oBut3:hWnd, oForm1:BackColorCode ), ;
                    SetBackgroundInvisible( oForm1:hWnd, oForm1:BackColorCode ) }
      oBut3:Transparent := .T.

      DEFINE SLIDER Slider_1
         ROW 80
         COL 10
         VALUE 255
         WIDTH 310
         HEIGHT 50
         RANGEMIN 0
         RANGEMAX 255
         ON CHANGE Slider_Change( oForm1 )
      END SLIDER

      @ 140, 10 LABEL lbl_transparent ;
         VALUE "TRANSPARENTE" ;
         WIDTH 100 ;
         HEIGHT 24 ;
         TRANSPARENT ;
         BORDER

      @ 140, 10 LABEL lbl_Below ;
         VALUE "ESTE ES UN TEXTO LARGO EN EL FONDO DEL FORM" ;
         WIDTH 390 ;
         HEIGHT 24 ;
         CENTER

      @ 140, 220 LABEL lbl_opaque ;
         VALUE "OPAQUE" ;
         WIDTH 100 ;
         HEIGHT 24 ;
         RIGHTALIGN ;
         BORDER

      @ 85, 330 TEXTBOX TextBox_1 ;
         VALUE 255 ;
         INPUTMASK "999" ;
         WIDTH 50 ;
         HEIGHT 24 ;
         DISABLED ;
         ON CHANGE TextBox_Change( oForm1 )

   END WINDOW

   oForm1:Center()
   oForm1:Activate()

RETURN NIL

FUNCTION TextBox_Change (oWin)

  WITH OBJECT oWin
    :Slider_1:Value := :TextBox_1:Value

     IF .not. SetTransparency( :hWnd, :Slider_1:Value )
        MsgStop( "El sistema operativo no soporta transparencia !!!", "Error" )
     ENDIF
  END WITH

RETURN NIL

FUNCTION Slider_Change (oWin)

  WITH OBJECT oWin
     :TextBox_1:Value := :Slider_1:Value

     IF .not. SetTransparency( :hWnd, :Slider_1:Value )
        MsgStop( "El sistema operativo no soporta transparencia !!!", "Error" )
     ENDIF
  END WITH

RETURN NIL

FUNCTION MakeOpaque( oWin )

  WITH OBJECT oWin
    :Slider_1:Value := 255
    :TextBox_1:Value := 255

    RemoveTransparency( :hWnd )
  END WITH

RETURN NIL

#pragma BEGINDUMP

#define HB_OS_WIN_32_USED
#define _WIN32_WINNT 0x0500

#include <windows.h>
#include <winuser.h>
#include <commctrl.h>
#include "hbapi.h"
#include "oohg.h"

/*
 * La función SetLayeredWindowAttributes configura la clave de color para
 * la opacidad y la transparencia de la ventana.
 *
 * Parametros:
 * - hwnd    Handle de la ventana.
 * - crKey   Pointer a un COLORREF que especifica la clave de color para
 *           la transparencia.
 *
 * Cuando se hace que cierto color sea transparente:
 * - bAlpha  Valor alpha usado para describir la opacidad de la ventana.
 *           0 = Invisible, 255 = Totalmente visible
 * - dwFlags Especifica una acción a tomar. Este parámetro puede ser
 *           LWA_COLORKEY (cuando se hace que cierto color sea transparente)
 *           o LWA_ALPHA.
 */

typedef BOOL ( __stdcall *PFN_SETLAYEREDWINDOWATTRIBUTES ) ( HWND, COLORREF, BYTE, DWORD );

HB_FUNC( SETTRANSPARENCY )
{
   BOOL bRet = FALSE;
   PFN_SETLAYEREDWINDOWATTRIBUTES pfnSetLayeredWindowAttributes = NULL;
   HINSTANCE hLib = LoadLibrary( "user32.dll" );

   if( hLib != NULL )
   {
      pfnSetLayeredWindowAttributes = (PFN_SETLAYEREDWINDOWATTRIBUTES) GetProcAddress( hLib, "SetLayeredWindowAttributes" );

      if( pfnSetLayeredWindowAttributes != NULL )
      {
         SetWindowLong( HWNDparam( 1 ), GWL_EXSTYLE, GetWindowLong( HWNDparam( 1 ), GWL_EXSTYLE ) | WS_EX_LAYERED );

         bRet = (BOOL) pfnSetLayeredWindowAttributes( HWNDparam( 1 ), 0, hb_parni( 2 ), LWA_ALPHA );

         FreeLibrary( hLib );
      }
   }

   hb_retl( bRet );
}

HB_FUNC( SETBACKGROUNDINVISIBLE )
{
   BOOL bRet = FALSE;
   PFN_SETLAYEREDWINDOWATTRIBUTES pfnSetLayeredWindowAttributes = NULL;
   HINSTANCE hLib = LoadLibrary( "user32.dll" );

   if( hLib != NULL )
   {
      pfnSetLayeredWindowAttributes = (PFN_SETLAYEREDWINDOWATTRIBUTES) GetProcAddress( hLib, "SetLayeredWindowAttributes" );

      if( pfnSetLayeredWindowAttributes != NULL )
      {
         SetWindowLong( HWNDparam( 1 ), GWL_EXSTYLE, GetWindowLong( HWNDparam( 1 ), GWL_EXSTYLE ) | WS_EX_LAYERED );

         bRet = (BOOL) pfnSetLayeredWindowAttributes( HWNDparam( 1 ), hb_parni( 2 ), 0, LWA_COLORKEY );

         FreeLibrary( hLib );
      }
   }

   hb_retl( bRet );
}

HB_FUNC( REMOVETRANSPARENCY )
{
   SetWindowLong( HWNDparam( 1 ), GWL_EXSTYLE, GetWindowLong( HWNDparam( 1 ), GWL_EXSTYLE ) & ~WS_EX_LAYERED ) ;

   RedrawWindow( HWNDparam( 1 ), NULL, NULL, RDW_ERASE | RDW_INVALIDATE | RDW_ALLCHILDREN | RDW_ERASENOW | RDW_UPDATENOW );
}

#pragma ENDDUMP

/*
 * EOF
 */
