/*
* HMG Data-Bound Grid Demo
* (c) 2010 Roberto Lopez
*/

#include <hmg.ch>

FUNCTION Main

   SET CELLNAVIGATIONMODE EXCEL

   DEFINE WINDOW sample at 0, 0 width 320 height 200 title 'Sample Cell Navigation Downwards...' main
      DEFINE GRID grid_1
         ROW 10
         COL 10
         WIDTH 300
         HEIGHT 150
         WIDTHS { 100, 170 }
         HEADERS { 'Sl.No.', 'Name' }
         CELLNAVIGATION .t.
         COLUMNWHEN { {|| .t. }, {|| .t. } }
         COLUMNCONTROLS { { 'TEXTBOX', 'NUMERIC', '999' }, { 'TEXTBOX', 'CHARACTER' } }
         allowedit .t.
         items { { 0, '' }, { 0, '' }, { 0, '' }, { 0, '' }, { 0, '' }, { 0, '' }, { 0, '' }, { 0, '' }, { 0, '' } }
      END GRID
   END WINDOW
   sample.center
   sample.activate

   RETURN
