#include <hmg.ch>
# include "hfcl.ch"

FUNCTION Main

   PRIVATE aArray := {{"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"},;
      {"One","Two","Three"}}

   DEFINE WINDOW sample at 0,0 width 400 height 300 main
      DEFINE GRID grid1
         row 10
         col 10
         width 300
         height 150
         virtual .t.
         on querydata this.querydata := aArray[this.queryrowindex,this.querycolindex]
         itemcount HMG_LEN(aArray)
         headers {"Head1","Head2","Head3"}
         widths {100,100,70}
      END GRID
      DEFINE BUTTON print
         row 160
         col 10
         width 80
         caption "Print"
         action printarray()
      END BUTTON
   END WINDOW
   sample.center
   sample.activate

   RETURN

FUNCTION printarray

   PRINT array aArray headers {"Heading 1","Heading 2"} ARRAYHEADERS {"Head1","Head2","Head3"} ARRAYJUSTIFY {0,0,0}

   RETURN NIL

