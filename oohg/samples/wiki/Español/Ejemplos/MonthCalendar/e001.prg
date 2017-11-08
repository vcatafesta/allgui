/*
 * Ejemplo MonthCalendar # 1
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Vea <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo es un caso de prueba para el control MonthCalendar.
 *
 * Note que al cambiar la vista actual en un control MULTISELECT,
 * de MCMV_MONTH a otro tipo, genera un cambio en el valor del
 * control. El valor previo se pierde y se fija un nuevo rango:
 * para MCMV_YEAR se seleccionan los últimos días del mes,
 * para MCMV_DECADE se seleccionan los últimos días del año, y
 * para MCMV_CENTURY se seleccionan los últimos días de la década.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"
#include "i_windefs.ch"

PROCEDURE Main

   LOCAL i := 0, v

   SET DATE BRITISH

   DEFINE WINDOW Win_1 OBJ oWin ;
      AT 0, 0 ;
      WIDTH 1000 ;
      HEIGHT 500 ;
      TITLE "Control MonthCalendar" ;
      MAIN ;
      ON INIT Ajustar()

      DEFINE MAIN MENU
         POPUP "Acciones"
            ITEM "Setear Cantidad Máxima de Días" ACTION SetearMSC()
            ITEM "Obtener Cantidad Máxima de Días" ACTION ObtenerMSC()
            SEPARATOR
            ITEM "Obtener Vista Actual #1" ACTION AutoMsgBox( oMC1:CurrentView() )
            ITEM "Setear Vista Actual #1" ACTION oMC1:CurrentView( Val( InputBox( 'Nueva Vista 0-3' ) ) )
            ITEM "Obtener Vista Actual #2" ACTION AutoMsgBox( oMC2:CurrentView() )
            ITEM "Setear Vista Actual #2" ACTION oMC2:CurrentView( Val( InputBox( 'Nueva Vista 0-3' ) ) )
            SEPARATOR
            ITEM "Duplicar ancho #1" ACTION ( oMC1:Width *= 2, Ajustar() )
            ITEM "Duplicar alto #1" ACTION ( oMC2:Height *= 2, Ajustar() )
            SEPARATOR
            ITEM "Tamaño #1" ACTION AutoMsgBox( { oMC1:Width, oMC1:Height } )
            ITEM "Tamaño #2" ACTION AutoMsgBox( { oMC2:Width, oMC2:Height } )
            SEPARATOR
            ITEM "Setear Font #1 Arial 8" ACTION oMC1:SetFont( "Arial", 8 )
            ITEM "Setear Font #2 Times New 14" ACTION oMC2:SetFont( "Times New", 14 )
            SEPARATOR
            ITEM "Rango de meses #1" ACTION AutoMsgBox( oMC1:MonthRange() )
            ITEM "Rango de meses #2" ACTION AutoMsgBox( oMC2:MonthRange() )
            SEPARATOR
            ITEM "Día anterior en negrita" ACTION oMC1:AddBoldDay( oMC1:Value - 1 )
            ITEM "Día siguiente en negrita" ACTION oMC1:AddBoldDay( oMC1:Value + 1 )
            ITEM "Remover negrita" ACTION ( oMC1:DelBoldDay( oMC1:Value - 1 ), oMC1:DelBoldDay( oMC1:Value + 1 ) )
         END POPUP
      END MENU

      DEFINE STATUSBAR
         STATUSITEM "El Poder de OOHG - Oprima Esc para Salir"
      END STATUSBAR

      @ 10, 10 BUTTON btn_1 ;
         CAPTION "Clic" ;
         TOOLTIP "Haz clic para probar el evento LostFocus" ;
         ACTION AutoMsgBox( "MaxSelCount = " + LTrim( Str( oMC2:MaxSelCount() ) ) )

      @ 50, 10 MONTHCALENDAR mcl_1 OBJ oMC1 ;
         TOOLTIP "Haz clic para probar el evento GotFocus" ;
         ON GOTFOCUS oLst:AddItem( "GotFocus MC1" ) ;
         ON LOSTFOCUS oLst:AddItem( "LostFocus MC1" ) ;
         ON CHANGE ( oLst:AddItem( "Value MC1 " + DToC( oMC1:Value ) ), oLst:Value := oLst:ItemCount )

      @ 240, 10 MONTHCALENDAR mcl_2 OBJ oMC2 ;
         MULTISELECT ;
         TOOLTIP "Haz clic para probar el evento GotFocus" ;
         ON GOTFOCUS oLst:AddItem( "GotFocus MC2" ) ;
         ON LOSTFOCUS oLst:AddItem( "LostFocus MC2" ) ;
         ON CHANGE ( v := oMC2:Value, oLst:AddItem( "Value MC2 { " + DToC( v[1] ) + ", " + DToC( v[2] ) + " }" ), oLst:Value := oLst:ItemCount )

      @ 10, 720 LISTBOX lst_3 OBJ oLst ;
         WIDTH 250 ;
         HEIGHT 400

      ON KEY ESCAPE ACTION Win_1.Release()
   END WINDOW

   CENTER WINDOW Win_1
   ACTIVATE WINDOW Win_1

RETURN

PROCEDURE SetearMSC
   AutoMsgBox( "MaxSelCount = " + LTrim( Str( oMC2:MaxSelCount( Val( InputBox( 'Nuevo MaxSelCount' ) ) ) ) ) )
RETURN

PROCEDURE ObtenerMSC
   AutoMsgBox( "MaxSelCount = " + LTrim( Str( oMC2:MaxSelCount() ) ) )
RETURN

PROCEDURE Ajustar
   oWin:ClientWidth := Max( oMC1:Col + oMC1:Width, oMC2:Col + oMC2:Width ) + 20 + oLst:Width + 20
   oLst:Col := oWin:ClientWidth - 20 - oLst:Width
RETURN

/*
 * EOF
 */
