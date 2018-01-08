#include "minigui.ch"

FUNCTION Main

   LOCAL aItems := {}

   aeval( array(15), {|| aadd( aItems, { 0, '', '' } ) } )

   SET CELLNAVIGATIONMODE VERTICAL
   //   SET CELLNAVIGATION MODE HORIZONTAL

   DEFINE WINDOW win_1 at 0, 0 width 528 height 300 ;
         TITLE 'Cell Navigation Downwards Demo' ;
         main nomaximize nosize

      DEFINE GRID grid_1
         ROW 10
         COL 10
         WIDTH 501
         HEIGHT 250
         widths { 80, 200, 200 }
         headers { 'No.', 'Name', 'Description' }
         items aItems
         columncontrols { { 'TEXTBOX', 'NUMERIC', '999' }, { 'TEXTBOX', 'CHARACTER' }, { 'TEXTBOX', 'CHARACTER' } }
         justify { GRID_JTFY_RIGHT, GRID_JTFY_LEFT, GRID_JTFY_LEFT }
         columnwhen { {|| .t. }, {|| win_1.grid_1.cell( GetProperty("Win_1","Grid_1","Value")[1], 1 ) > 0 }, {|| .t. } }
         allowedit .t.
         cellnavigation .t.
         value {1, 1}
      END GRID

      ON KEY ESCAPE ACTION thiswindow.release()

   END WINDOW

   win_1.center
   win_1.activate

   RETURN NIL
