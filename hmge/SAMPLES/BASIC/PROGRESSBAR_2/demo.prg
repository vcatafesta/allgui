#include "minigui.ch"

FUNCTION main

   DEFINE WINDOW sample at 0,0 width 627 height 612 title "Custom Progressbar Demo" main ;
         on gotfocus checkgraph() on lostfocus checkgraph()
      DEFINE BUTTON pressme
         row 10
         col 10
         width 80
         caption "Press Me!"
         action (sample.t1.value := 2)
      END BUTTON
      DEFINE TAB t1 at 50,10 width 600 height 520 on change checkgraph()
         DEFINE PAGE "Page 1"
            DEFINE BUTTON b1
               row 40
               col 20
               caption "Test 1"
               action msginfo("Click 1")
            END BUTTON

            DEFINE BUTTON b2
               row 40
               col 140
               caption "Test 2"
               action msginfo("Click 2")
            END BUTTON
         END PAGE
         DEFINE PAGE "Page 2"

         END PAGE
      END TAB
   END WINDOW
   sample.center
   sample.activate

   RETURN NIL

FUNCTION docustomprogressbars

   IF sample.t1.value == 2
      custom_progress_bar("sample",100,100,300,25,{255,0,0},10,100)
      custom_progress_bar("sample",150,100,300,25,{255,255,0},40,100)
      custom_progress_bar("sample",200,100,300,25,{0,255,0},60,100)
      custom_progress_bar("sample",250,100,300,25,{0,0,255},80,100)

      custom_progress_bar("sample",300,150,25,250,{255,0,0},10,100)
      custom_progress_bar("sample",300,200,25,250,{255,255,0},40,100)
      custom_progress_bar("sample",300,250,25,250,{0,255,0},60,100)
      custom_progress_bar("sample",300,300,25,250,{0,0,255},80,100)
   ENDIF

   RETURN NIL

FUNCTION checkgraph

   IF sample.t1.value == 2
      do events
      docustomprogressbars()
   ELSE
      ERASE window sample
   ENDIF

   RETURN NIL

FUNCTION custom_progress_bar(cWindowName,nRow,nCol,nWidth,nHeight,aColor,nValue,nMax)

   LOCAL nStartRow, nStartCol, nFinishRow, nFinishCol := 0

   // borders
   DRAW RECTANGLE IN WINDOW &cWindowName AT nRow,nCol TO nRow+nHeight,nCol+nWidth PENCOLOR {128,128,128} FILLCOLOR {255,255,255}
   DRAW LINE IN WINDOW &cWindowName At nRow,nCol to nRow+nHeight,nCol PENCOLOR {64,64,64} PENWIDTH 1
   DRAW LINE IN WINDOW &cWindowName At nRow,nCol to nRow,nCol+nWidth PENCOLOR {64,64,64} PENWIDTH 1

   // progress bar
   IF nWidth > nHeight  // Horizontal Progress Bar
      nStartRow := nRow + 1
      nStartCol := nCol + 1
      nFinishRow := nRow + nHeight - 1
      nFinishCol := nCol + 1 + ((nWidth - 2) * nValue / nMax)
   ELSE  // Vertical Progress Bar
      nStartRow := nRow + nHeight - 1
      nStartCol := nCol + 1
      nFinishRow := nStartRow - ((nHeight - 2) * nValue / nMax)
      nFinishCol := nCol + nWidth - 1
   ENDIF
   DRAW RECTANGLE IN WINDOW &cWindowName AT nStartRow,nStartCol TO nFinishRow,nFinishCol PENCOLOR aColor FILLCOLOR aColor

   RETURN NIL
