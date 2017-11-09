#include "minigui.ch"

FUNCTION Main

   LOCAL aItems := {}

   aeval( array(15), {|| aadd( aItems, { 0, '', '' } ) } )

   SET CELLNAVIGATIONMODE VERTICAL
   //   SET CELLNAVIGATION MODE HORIZONTAL

   DEFINE WINDOW win_1 at 0, 0 width 528 height 300 ;
         title 'Cell Navigation Downwards Demo' ;
         main nomaximize nosize

      DEFINE GRID grid_1
         row 10
         col 10
         width 501
         height 250
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

      on key escape action thiswindow.release()

   END WINDOW

   win_1.center
   win_1.activate

   RETURN NIL

