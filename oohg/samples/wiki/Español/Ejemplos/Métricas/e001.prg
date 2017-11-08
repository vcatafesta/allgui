/*
 * Ejemplo Métricas de Windows n° 1
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo obtener el separador decimal actual.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

Function Main

   MsgInfo( "El separador decimal es " + GetDecimalSeparator(), "Información" )

Return Nil

#pragma BEGINDUMP

#include "hbapi.h"
#include "hbvm.h"
#include "hbstack.h"
#include <windows.h>

/*
Las constantes aceptadas están definidas en winnls.h
Ver https://msdn.microsoft.com/en-us/library/windows/desktop/dd464799(v=vs.85).aspx
*/

HB_FUNC ( GETDECIMALSEPARATOR )
{
   LPTSTR cText;

   cText = ( LPTSTR ) hb_xgrab( 128 );

//   GetLocaleInfo( GetSystemDefaultLCID(), LOCALE_SDECIMAL, cText, 128 );
   GetLocaleInfo( LOCALE_USER_DEFAULT, LOCALE_SDECIMAL, cText, 128 );

   hb_retc( cText );
   hb_xfree( cText );
}

#pragma ENDDUMP

/*
 * EOF
 */
