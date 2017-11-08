/*
 * Ejemplo API de Windows n° 2
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo demuestra como mostrar nombres de archivos o
 * carpetas muy largos en forma compacta sustituyendo algunos
 * caracters por puntos suspensivos.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main

   AutoMsgBox( _GetCompactPath( "C:\OOHG_Samples\English\Samples\ClientAdjust\GetCompactPath", 32 ) )

RETURN Nil

/*
 * EOF
 */
