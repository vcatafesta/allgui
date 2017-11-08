/*
 * Ejemplo Métricas de Windows n° 2
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo obtener las fuentes del sistema
 * actuales y otras métricas.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

#define FUENTE_MENSAJES         1
#define FUENTE_TITULOS          2
#define FUENTE_TITULOS_PEQUENOS 3
#define FUENTE_MENUES           4
#define FUENTE_STATUSBAR        5

FUNCTION Main

   DEFINE WINDOW Form_1 ;
      AT 0, 0 ;
      WIDTH 640 ;
      HEIGHT 520 ;
      NOSIZE ;
      NOMAXIMIZE ;
      FONT "Arial" ;
      SIZE 12 ;
      TITLE "Fuentes del Sistema y Otras Métricas"

      @ 10, 10 LABEL label_01 ;
         VALUE "Fuente por defecto: " + GetDefaultFontName() + ;
               LTrim( Str( GetDefaultFontSize() ) ) + ;
               " (Alto: " + LTrim( Str( GetDefaultFontHeight() ) ) + ")"  + ;
               " - " + Str( GetScreenDPIX() ) ;
         AUTOSIZE
  
      aCaptionFont   := GetSystemFont( FUENTE_TITULOS )
      aSmCaptionFont := GetSystemFont( FUENTE_TITULOS_PEQUENOS )
      aMenuFont      := GetSystemFont( FUENTE_MENUES )
      aStatusFont    := GetSystemFont( FUENTE_STATUSBAR )
      aMessageFont   := GetSystemFont( FUENTE_MENSAJES )

      @ 40,  10 LABEL label_04 ;
         VALUE "NonClientMetrics" BOLD AUTOSIZE
      @ 70,  10 LABEL label_05 ;
         VALUE "Fuente Títulos: " + FontData(aCaptionFont) AUTOSIZE
      @ 100, 10 LABEL label_06 ;
         VALUE "Fuente T. Pequeños: " + FontData(aSmCaptionFont) AUTOSIZE
      @ 130, 10 LABEL label_07 ;
         VALUE "Fuente Menúes: " + FontData(aMenuFont) AUTOSIZE
      @ 160, 10 LABEL label_08 ;
         VALUE "Fuente Statusbar: " + FontData(aStatusFont) AUTOSIZE
      @ 190, 10 LABEL label_09 ;
         VALUE "Fuente Mensajes: " + FontData(aMessageFont) AUTOSIZE

      aOther := GetOtherMetrics()

      @ 220, 10 LABEL label_10 ;
         VALUE "Ancho de Bordes: " + LTrim( Str( aOther[1] ) ) AUTOSIZE
      @ 250, 10 LABEL label_11 ;
         VALUE "Ancho de Scroll: " + LTrim( Str( aOther[2] ) ) AUTOSIZE
      @ 280, 10 LABEL label_12 ;
         VALUE "Alto de Scroll: " + LTrim( Str( aOther[3] ) ) AUTOSIZE
      @ 310, 10 LABEL label_13 ;
         VALUE "Ancho de Títulos: " + LTrim( Str( aOther[4] ) ) AUTOSIZE
      @ 340, 10 LABEL label_14 ;
         VALUE "Alto de Títulos: " + LTrim( Str( aOther[5] ) ) AUTOSIZE
      @ 370, 10 LABEL label_15 ;
         VALUE "Ancho de T. Pequeños: " + LTrim( Str( aOther[6] ) ) AUTOSIZE
      @ 400, 10 LABEL label_16 ;
         VALUE "Alto de T. Pequeños: " + LTrim( Str( aOther[7] ) ) AUTOSIZE
      @ 430, 10 LABEL label_17 ;
         VALUE "Ancho de Menúes: " + LTrim( Str( aOther[8] ) ) AUTOSIZE
      @ 460, 10 LABEL label_18 ;
         VALUE "Alto de Menúes: " + LTrim( Str( aOther[9] ) ) AUTOSIZE

      ON KEY ESCAPE ACTION Form_1.Release
   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN NIL

FUNCTION FontData( aFont )
   
RETURN ( aFont[1] + " " + ;
         AllTrim( Str( aFont[2] ) ) + " " + ;
         IF( aFont[3], "Negrita ", "" ) + ;
         IF( aFont[4], "Itálica ", "" ) + ;
         IF( aFont[5], "Subrayada ", "" ) + ;
         IF( aFont[6], "Tachada ", "" ) + ;
         "Conjunto de caracteres: " + AllTrim( Str( aFont[7] ) ) )

//--------------------------------------------------------------------------
#pragma BEGINDUMP

#include <windows.h>
#include <commctrl.h>
#include "hbapi.h"
#include "oohg.h"

HB_FUNC( GETSCREENDPIX )
{
	HDC  hDC;
	int cyp;

	memset ( &cyp, 0, sizeof ( cyp ) ) ;
	memset ( &hDC, 0, sizeof ( hDC ) ) ;

	hDC = GetDC ( HWND_DESKTOP ) ;

	cyp = GetDeviceCaps ( hDC, LOGPIXELSY ) ;

	ReleaseDC ( HWND_DESKTOP, hDC ) ;

  hb_retni( cyp);
}

HB_FUNC( GETDEFAULTFONTNAME )
{
LOGFONT lf;
GetObject( ( HFONT ) GetStockObject( DEFAULT_GUI_FONT ) , sizeof( LOGFONT ), &lf );
hb_retc( lf.lfFaceName );
}

HB_FUNC( GETDEFAULTFONTHEIGHT )
{
LOGFONT lf;
GetObject( ( HFONT ) GetStockObject( DEFAULT_GUI_FONT ) , sizeof( LOGFONT ), &lf );
hb_retni( lf.lfHeight );
}

HB_FUNC( GETDEFAULTFONTSIZE )
{
LOGFONT lf;
long PointSize ;
GetObject( ( HFONT ) GetStockObject( DEFAULT_GUI_FONT ) , sizeof( LOGFONT ), &lf );
PointSize = -MulDiv ( lf.lfHeight , 72 , GetDeviceCaps(GetDC(GetActiveWindow()), LOGPIXELSY) ) ;
hb_retnl( PointSize );
}

HB_FUNC( GETSYSTEMFONT )
{
  NONCLIENTMETRICS ncm = {0};
	LONG PointSize;
	INT isBold;
  LOGFONT lf;
  
  ncm.cbSize = sizeof(ncm);

	if ( ! SystemParametersInfo(SPI_GETNONCLIENTMETRICS, sizeof(ncm), &ncm, 0) )
	{
		hb_reta( 7 );
		HB_STORC( "" , -1, 1 );
		HB_STORNL( (LONG) 0 , -1, 2 );
		HB_STORL( 0 , -1, 3 );
		HB_STORL( 0 , -1, 4 );
		HB_STORNL( 0 , -1, 5 );
		HB_STORL( 0 , -1, 6 );
		HB_STORL( 0 , -1, 7 );
		return;
	}

  switch( hb_parni(1) )
  {
    case 1:       
      lf = ncm.lfMessageFont;
      break;
    case 2:       
      lf = ncm.lfCaptionFont;
      break;
    case 3:       
      lf = ncm.lfSmCaptionFont;
      break;
    case 4:      
      lf = ncm.lfMenuFont;
      break;
    case 5:      
      lf = ncm.lfStatusFont;
      break;
   }
  
  PointSize  = - MulDiv ( lf.lfHeight , 72 , GetDeviceCaps(GetDC(GetActiveWindow()), LOGPIXELSY) );
  
  if (lf.lfWeight == 700)
	{
		isBold = 1;
	}
	else
	{
		isBold = 0;
	}
	
  hb_reta( 7 );
	HB_STORC( lf.lfFaceName , -1, 1 );
	HB_STORNL( (LONG) PointSize , -1, 2 );
	HB_STORL( isBold , -1, 3 );
	HB_STORL( lf.lfItalic , -1, 4 );
	HB_STORL( lf.lfUnderline , -1, 5 );
	HB_STORL( lf.lfStrikeOut , -1, 6 );
	HB_STORNI( lf.lfCharSet , -1, 7 );

}

HB_FUNC( GETOTHERMETRICS )
{
  NONCLIENTMETRICS ncm = {0};
  
  ncm.cbSize = sizeof(ncm);

	if ( ! SystemParametersInfo(SPI_GETNONCLIENTMETRICS, sizeof(ncm), &ncm, 0) )
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
	HB_STORNI( ncm.iBorderWidth , -1, 1 );
	HB_STORNI( ncm.iScrollWidth , -1, 2 );
	HB_STORNI( ncm.iScrollHeight , -1, 3 );
	HB_STORNI( ncm.iCaptionWidth , -1, 4 );
	HB_STORNI( ncm.iCaptionHeight , -1, 5 );
	HB_STORNI( ncm.iSmCaptionWidth , -1, 6 );
	HB_STORNI( ncm.iSmCaptionHeight , -1, 7 );
	HB_STORNI( ncm.iMenuWidth , -1, 8 );
	HB_STORNI( ncm.iMenuHeight , -1, 9 );

}
 
#pragma ENDDUMP

/*
 * EOF
 */
