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
         ROW 10
         COL 10
         WIDTH 300
         HEIGHT 150
         VIRTUAL .t.
         ON QUERYDATA this.querydata := aArray[this.queryrowindex,this.querycolindex]
         ITEMCOUNT HMG_LEN(aArray)
         HEADERS {"Head1","Head2","Head3"}
         WIDTHS {100,100,70}
      END GRID
      DEFINE BUTTON print
         ROW 160
         COL 10
         WIDTH 80
         CAPTION "Print"
         ACTION printarray()
      END BUTTON
   END WINDOW
   sample.center
   sample.activate

   RETURN

FUNCTION printarray

   PRINT array aArray headers {"Heading 1","Heading 2"} ARRAYHEADERS {"Head1","Head2","Head3"} ARRAYJUSTIFY {0,0,0}

   RETURN NIL
