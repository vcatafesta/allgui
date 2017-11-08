/*
 * Ejemplo RichEditBox n° 1
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo destacar la fila corriente en un
 * control RichEditBox, utilizando los métodos GetCurrentLine,
 * GetSelection, SetSelection, SetSelectionTextColor,
 * SetSelectionBackColor, GetLineIndex y GetLineLength y el
 * evento OnSelChange.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main

   LOCAL oWnd, oRch

   DEFINE WINDOW Win_1 OBJ oWnd ;
      AT 0,0 ;
      WIDTH 600 ;
      HEIGHT 400 ;
      TITLE 'OOHG - Destacar Línea en Control Richedit'

      ON KEY ESCAPE ACTION oWnd:Release()

      @ 20,20 RICHEDITBOX rch_edit ;
         OBJ oRch ;
         WIDTH 500 ;
         HEIGHT 250

      oRch:OnSelChange := {|| Destacar( oRch )}

   END WINDOW

   ownd:Center()
   ownd:Activate()

RETURN Nil

FUNCTION Destacar( oRch )

   LOCAL aPos, aColor, nCurrent
   STATIC nPrevious := -1

   // Previene el cambio del formato por defecto
   IF EMPTY( oRch:Value )
      RETURN Nil
   ENDIF

   // Si se cambia el color una segunda vez,
   // la línea será pintada con el color por defecto
   nCurrent := oRch:GetCurrentLine()
   IF nCurrent == nPrevious
      RETURN Nil
   ENDIF
   nPrevious := nCurrent

   // Guardar la selección actual
   aPos := oRch:GetSelection()

   // Seleccionar todo el texto
   oRch:SetSelection( 0, -1 )

   // Restaurar los colores por defecto
   // Si FontColor es Nil se asume COLOR_WINDOWTEXT
   // Si BackColor es Nil se asume COLOR_WINDOW
    oRch:SetSelectionTextColor( oRch:FontColor )
    oRch:SetSelectionBackColor( oRch:BackColor )

   // Seleccionar la línea corriente
   oRch:SetSelection( oRch:GetLineIndex( nCurrent ), oRch:GetLineIndex( nCurrent ) + oRch:GetLineLength( nCurrent ) )

   // Cambiar los colores
   oRch:SetSelectionTextColor( RGB( RED[ 1 ], RED[ 2 ], RED[ 3 ] ) )
   oRch:SetSelectionBackColor( RGB( GREEN[ 1 ], GREEN[ 2 ], GREEN[ 3 ] ) )

   // Restaurar la selección
   oRch:SetSelection( aPos[ 1 ], aPos[ 2 ] )

RETURN Nil

/*
 * EOF
 */
