
/*
* Harbour MiniGUI ZeeGrid Demo
* (c) 2017, Petr Chornyj
*/

MEMVAR hG

#include "minigui.ch"
#include "i_winuser.ch"
#include "zeegrid.ch"

#define APP_ABOUT ( MiniGuiVersion() + CRLF + "ZeeGrid build " + hb_NtoS( zgm_QueryBuild( hG, .F. ) ) + " by David Hillard" )
#define ID_GRID   700

PROCEDURE Main()

   LOCAL hMod := zg_LoadDll()

   IF Empty( hMod )
      QUIT
   ENDIF

   PUBLIC hG

   SET DATE FORMAT     TO "dd.mm.yyyy"
   SET EVENTS FUNCTION TO App_OnEvents

   DEFINE WINDOW Win_1 CLIENTAREA 600, 600 TITLE 'ZeeGrid demo' ;
         ICON "MAIN.ICO" ;
         WINDOWTYPE MAIN ;
         ON RELEASE FreeLibrary( hMod )

      DEFINE MAIN MENU
         POPUP 'Info'
            ITEM 'About ..'   ACTION MsgInfo( APP_ABOUT )

            SEPARATOR

            ITEM 'Exit'       ACTION Win_1.Release
         END POPUP
      END MENU

   END WINDOW

   CENTER   WINDOW Win_1
   ACTIVATE WINDOW Win_1

   RETURN

FUNCTION App_OnEvents( hWnd, nMsg, wParam, lParam )

   LOCAL result := 0, i

   SWITCH nMsg
   CASE WM_CREATE
      zg_InitGrid( hWnd, @hG, ID_GRID, "ZeeGrid Dates",,,,, {|h| Grid_OnInit( h ) }  )
      EXIT

   CASE WM_COMMAND
      SWITCH HIWORD( wParam )
      CASE ZGN_GOTFOCUS
         IF LOWORD( wParam ) == ID_GRID

            i := zgm_GetCursorIndex( hG )
            IF i > 0
               zgm_gotoCell( hG, i )
            ELSE
               zgm_gotoCell( hG, zgm_GetCellIndex( hG, 1, 1 ) )
            ENDIF

         ENDIF
         EXIT

      OTHERWISE
         result := Events( hWnd, nMsg, wParam, lParam )
      END
      EXIT

   CASE WM_SIZE
      zg_Resize( hWnd, hG )
      EXIT

   OTHERWISE
      result := Events( hWnd, nMsg, wParam, lParam )
   END

   RETURN result

#translate ICELL( <row>, <col> ) => zgm_GetCellIndex( h, <row>, <col> )

PROCEDURE Grid_OnInit( h )

   LOCAL i

   // Create font hTitleFont
   DEFINE FONT hTitleFont FONTNAME "MS Sans Serif" SIZE 28 BOLD
   // Add hTitleFont to the font palette
   zgm_SetFont( h, 20, GetFontHandle( "hTitleFont" ) )
   // and set the zeegrid title font to hTitleFont
   zgm_SetCellFont( h, 0, 20 )

   // Append rows
   FOR i := 1 to 10
      zgm_AppendRow( h )
   NEXT i

   // ---
   zgm_SetCellType( h, ICEL( 1, 1 ), 4 )   // DATE
   zgm_SetCellEdit( h, ICEL( 1, 1 ), 4 )   // use DatePicker
   zgm_SetCellFColor( h, ICEL( 1, 1 ), 4 ) // RED

   zgm_SetColType( h, 4, 4 )               // DATE
   zgm_SetColEdit( h, 4, 4 )               // use DatePicker
   /*
   There are five valid values for the FORMAT attribute for date data, [0..4].
   For example, the date 'February 3, 1965' will be displayed as follows for the given formats:

   0 - '1965/02/03'
   1 - '02/03/1965'
   2 - '2/3/1965'
   3 - 'Feb 3, 1965'
   4 - 'February 3, 1965'
   */
   zgm_SetCellText  ( h, ICEL( 1, 3 ), "Format #0" )
   zgm_SetCellFormat( h, ICEL( 1, 4 ), 0 )
   /*
   zgm_SetCellCDate( hGrid, nCellIndex, cDate )

   where cDate - a string containing the text representation of a date.
   This text can be in many date formats (at least 5 formats).
   For example, the date 12/28/1958 could be represented in string form as
   '1958/12/28', '12/28/58', '12/28/1958', 'Dec 28, 1958', or 'December 28, 1958'

   Valid dates range from 1/1/1600 to 12/31/9999.

   ?! not tested carefully. Use zg_SetCellDate instead

   zg_SetCellDate( hGrid, nCellIndex, Date )
   */
   zgm_SetCellCDate( h, ICEL( 1, 4 ), hb_DToC( Date(), "mm/dd/yyyy") )

   FOR i := 1 to 5
      zgm_SetCellText  ( h, ICEL( i + 1, 3 ), "Format #" + hb_NtoS( i ) )
      zgm_SetCellFormat( h, ICEL( i + 1, 4 ), i )
      zg_SetCellDate   ( h, ICEL( i + 1, 4 ), Date() + i )
   NEXT i

   // Resize columns
   FOR i := 1 to zgm_GetCols( h )
      zgm_SetColWidth( h, i, 80 )
   NEXT i

   zgm_AutosizeColumn( h, 1 )
   zgm_AutosizeColumn( h, 4 )
   // Disable columns resizing & moving
   zgm_EnableColResizing( h, .F. )
   zgm_EnableColMove( h, .F. )

   RETURN
