#include <hmg.ch>

FUNCTION Main

   LOCAL aItems := { ;
      { 1, 'Row1, Column1', 'Row1, Column2' }, ;
      { 1, 'Row2, Column1', 'Row2, Column2' }, ;
      { 1, 'Row3, Column1', 'Row3, Column2' }, ;
      { 1, 'Row4, Column1', 'Row4, Column2' }, ;
      { 1, 'Row5, Column1', 'Row5, Column2' }, ;
      { 1, 'Row6, Column1', 'Row6, Column2' }, ;
      { 1, 'Row7, Column1', 'Row7, Column2' }, ;
      { 1, 'Row8, Column1', 'Row8, Column2' }, ;
      { 1, 'Row9, Column1', 'Row9, Column2' }  ;
      }

   DEFINE WINDOW main at 0, 0 width 640 height 480 title 'Grid Row Height demo' main

      DEFINE GRID grid_1
         row 10
         col 10
         width 545
         height 200
         headers { '', 'Column1', 'Column2'  }
         widths { 0, 200, 200 }
         justify { 2, 0, 0 }
         image { 'redbullet.bmp', 'whitebullet.bmp', 'greenbullet.bmp' }
         items aItems
      END GRID

      DEFINE GRID grid_2
         row 230
         col 10
         width 545
         height 200
         headers { '', 'Column1', 'Column2'  }
         widths { 0, 200, 200 }
         justify { 2, 0, 0 }
         image { 'redbullet1.bmp', 'whitebullet1.bmp', 'greenbullet1.bmp' }
         items aItems
      END GRID

      ON KEY ESCAPE ACTION thiswindow.release
   END WINDOW
   main.center
   main.activate

   RETURN NIL
