/*
 * Ejemplo RichEditBox n° 2
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo limitar el número de caracteres
 * en las líneas de un control RichEditbox.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main

   DEFINE WINDOW MAIN ;
     TITLE "OOHG - Limitar Largo de Líneas en RichEditBox" ;
     OBJ oMain

     @ 20, 20 RICHEDITBOX rch_Edit ;
       OBJ oRich ;
       WIDTH oMain:ClientWidth - 40 ;
       HEIGHT oMain:ClientHeight - 40 ;
       ON CHANGE VerLargoMaximo( 20 )

    ON KEY ESCAPE ACTION oMain:Release()
   END WINDOW

   oMain:Activate()

RETURN Nil

FUNCTION VerLargoMaximo( nLenght )

   IF oRich:GetLineLength( oRich:GetCurrentLine() ) >= nLenght
     oRich:Value += CHR(13) + CHR(10)
     oRich:CaretPos( Len( oRich:Value ) )
   ENDIF

RETURN Nil

/*
 * EOF
 */
