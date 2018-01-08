/* Sudoku Game
original by Rathi

edited by Alex Gustow
(try to use "auto-zoom technique")
*/

#include "minigui.ch"

STATIC aPuzzles, aSudoku, aOriginal

FUNCTION Main

   LOCAL bColor
   LOCAL nRandom
   LOCAL nGuess
   LOCAL nArrLen
   LOCAL cTime := time()
   LOCAL cTitle := "HMG Sudoku"

   // GAL - coefficients for "auto-zooming"
   LOCAL gkoefh := 1, ;
      gkoefv := 1
   LOCAL gw         // for grid columns width
   LOCAL nRatio := GetDesktopWidth()/GetDesktopHeight()

   IF nRatio == 4/3
      gkoefh := GetDesktopWidth()/1024
      gkoefv := GetDesktopHeight()/768
   ELSEIF nRatio == 1.6
      gkoefv := GetDesktopHeight()/850
   ENDIF
   gw := 50*gkoefh

   aPuzzles := ImportFromTxt("sudoku.csv")
   nArrLen  := len(aPuzzles)
   aSudoku  := { { 0, 0, 0, 2, 0, 3, 8, 0, 1 }, ;
      { 0, 0, 0, 7, 0, 6, 0, 5, 2 }, ;
      { 2, 0, 0, 0, 0, 0, 0, 7, 9 }, ;
      { 0, 2, 0, 1, 5, 7, 9, 3, 4 }, ;
      { 0, 0, 3, 0, 0, 0, 1, 0, 0 }, ;
      { 9, 1, 7, 3, 8, 4, 0, 2, 0 }, ;
      { 1, 8, 0, 0, 0, 0, 0, 0, 6 }, ;
      { 7, 3, 0, 6, 0, 1, 0, 0, 0 }, ;
      { 6, 0, 5, 8, 0, 9, 0, 0, 0 }  }
   aOriginal := {}

   // GAL
   IF file("Help.chm")
      SET helpfile to 'Help.chm'
   ENDIF

   IF nArrLen > 0
      nRandom := val("0."+substr(cTime,8,1)+substr(cTime,5,1)+substr(cTime,8,2))
      nGuess := int(nRandom * (nArrLen+1))
      IF nGuess == 0
         nGuess := 1
      ENDIF
      aSudoku := aclone(aPuzzles[nGuess])
      cTitle := "HMG Sudoku"+" Game no: "+hb_ntos(nGuess)+" of "+hb_ntos(nArrLen)
   ENDIF

   bColor := { || SudokuBackColor() }

   aOriginal := aclone(aSudoku)

   // GAL
   DEFINE WINDOW Sudoku ;
         at 0,0 ;
         WIDTH 486*gkoefh - iif(isthemed(),0,GetBorderWidth()) ;
         HEIGHT 550*gkoefv - iif(isthemed(),0,GetTitleHeight()) ;
         MAIN ;
         TITLE cTitle ;
         NOMAXIMIZE ;    /* GAL */
         NOSIZE          /* GAL */

      DEFINE GRID Square
         ROW 10
         COL 10
         WIDTH 460*gkoefh - iif(isthemed(),0,GetBorderWidth())
         HEIGHT 445*gkoefv - iif(isthemed(),0,GetTitleHeight()+GetBorderHeight())
         showheaders .f.
         WIDTHS  {gw, gw, gw, gw, gw, gw, gw, gw, gw}
         justify {2, 2, 2, 2, 2, 2, 2, 2, 2}
         CELLNAVIGATION .T.
         allowedit .T.
         COLUMNCONTROLS { {"TEXTBOX", "CHARACTER", "9"}, ;
            {"TEXTBOX", "CHARACTER", "9"}, ;
            {"TEXTBOX", "CHARACTER", "9"}, ;
            {"TEXTBOX", "CHARACTER", "9"}, ;
            {"TEXTBOX", "CHARACTER", "9"}, ;
            {"TEXTBOX", "CHARACTER", "9"}, ;
            {"TEXTBOX", "CHARACTER", "9"}, ;
            {"TEXTBOX", "CHARACTER", "9"}, ;
            {"TEXTBOX", "CHARACTER", "9"} }
         FONTNAME "Arial"
         fontsize 30*gkoefh
         dynamicbackcolor { bColor, bColor, bColor, ;
            bColor, bColor, bColor, ;
            bColor, bColor, bColor }
         COLUMNWHEN { { || entergrid() }, { || entergrid() }, ;
            { || entergrid() }, { || entergrid() }, ;
            { || entergrid() }, { || entergrid() }, ;
            { || entergrid() }, { || entergrid() }, ;
            { || entergrid() } }
         columnvalid { { || checkgrid() }, { || checkgrid() }, ;
            { || checkgrid() }, { || checkgrid() }, ;
            { || checkgrid() }, { || checkgrid() }, ;
            { || checkgrid() }, { || checkgrid() }, ;
            { || checkgrid() } }
         onchange CheckPossibleValues()
      END GRID

      DEFINE LABEL valid
         ROW 460*gkoefv - iif(isthemed(),0,GetTitleHeight())
         COL 10
         WIDTH 370*gkoefh
         HEIGHT 30*gkoefv
         FONTNAME "Arial"
         fontsize 18*gkoefv
      END LABEL

      // GAL
      IF file("help.chm")
         DEFINE STATUSBAR
            statusitem 'F1 - Help' action DISPLAY HELP MAIN
         END STATUSBAR

         on key F1 action DISPLAY HELP MAIN
      ENDIF

      DEFINE BUTTON Next
         ROW 460*gkoefv - iif(isthemed(),0,GetTitleHeight())
         COL 400*gkoefh - iif(isthemed(),0,GetBorderWidth())
         WIDTH 70*gkoefh
         CAPTION "Next"
         ACTION NextGame()
      END BUTTON

   END WINDOW

   on key ESCAPE of Sudoku action Sudoku.Release()

   RefreshSudokuGrid()

   Sudoku.Center()
   Sudoku.Activate()

   RETURN NIL

FUNCTION SudokuBackColor()

   LOCAL rowindex := this.cellrowindex
   LOCAL colindex := this.cellcolindex

   DO CASE

   CASE rowindex <= 3 // first row
      DO CASE
      CASE colindex <= 3 // first col

         RETURN {200,100,100}
      CASE colindex > 3 .and. colindex <= 6 // second col

         RETURN {100,200,100}
      CASE colindex > 6 // third col

         RETURN {100,100,200}
      ENDCASE

   CASE rowindex > 3 .and. rowindex <= 6  // second row
      DO CASE
      CASE colindex <= 3 // first col

         RETURN {100,200,100}
      CASE colindex > 3 .and. colindex <= 6 // second col

         RETURN {200,200,100}
      CASE colindex > 6 // third col

         RETURN {100,200,100}
      ENDCASE

   CASE rowindex > 6 // third row
      DO CASE
      CASE colindex <= 3 // first col

         RETURN {100,100,200}
      CASE colindex > 3 .and. colindex <= 6 // second col

         RETURN {100,200,100}
      CASE colindex > 6 // third col

         RETURN {200,100,100}
      ENDCASE

   ENDCASE

   RETURN NIL

FUNCTION RefreshSudokuGrid()

   LOCAL aLine := {}
   LOCAL aValue := sudoku.square.value
   LOCAL i
   LOCAL j

   sudoku.square.DeleteAllItems()

   IF len(aSudoku) == 9
      FOR i := 1 to len(aSudoku)
         asize(aLine,0)
         FOR j := 1 to len(aSudoku[i])
            IF aSudoku[i,j] > 0
               aadd(aLine, str(aSudoku[i,j],1,0))
            ELSE
               aadd(aLine,'')
            ENDIF
         NEXT j
         sudoku.square.AddItem(aLine)
      NEXT i
   ENDIF

   sudoku.square.value := aValue

   RETURN NIL

FUNCTION EnterGrid()

   LOCAL aValue := sudoku.square.value

   IF len(aValue) > 0
      IF aOriginal[ aValue[1], aValue[2] ] > 0

         RETURN .F.
      ELSE

         RETURN .T.
      ENDIF
   ENDIF

   RETURN .F.

FUNCTION CheckGrid()

   LOCAL nRow := this.cellrowindex
   LOCAL nCol := this.cellcolindex
   LOCAL nValue := val(alltrim(this.cellvalue))
   LOCAL i
   LOCAL j
   LOCAL nRowStart := int((nRow-1)/3) * 3 + 1
   LOCAL nRowEnd := nRowstart + 2
   LOCAL nColStart := int((nCol-1)/3) * 3 + 1
   LOCAL nColEnd := nColstart + 2

   IF nValue == 0
      this.cellvalue := ''
      sudoku.valid.value := ''
      aSudoku[nRow,nCol] := 0

      RETURN .T.
   ENDIF

   IF nValue == aSudoku[nRow,nCol]

      RETURN .T.
   ENDIF

   FOR i := 1 to 9
      IF aSudoku[nRow,i] == nValue // row checking

         RETURN .F.
      ENDIF
      IF aSudoku[i,nCol] == nValue // col checking

         RETURN .F.
      ENDIF
   NEXT i

   FOR i := nRowStart to nRowEnd
      FOR j := nColStart to nColEnd
         IF aSudoku[i,j] == nValue

            RETURN .F.
         ENDIF
      NEXT j
   NEXT i

   sudoku.valid.value := ''

   aSudoku[nRow,nCol] := nValue

   CheckCompletion()

   RETURN .T.

FUNCTION CheckCompletion()

   LOCAL i
   LOCAL j

   FOR i := 1 to len(aSudoku)
      FOR j := 1 to len(aSudoku[i])
         IF aSudoku[i,j] == 0

            RETURN NIL
         ENDIF
      NEXT j
   NEXT i

   MsgInfo("Congrats! You won!","Finish")

   RETURN NIL

FUNCTION CheckPossibleValues()

   LOCAL aValue := sudoku.square.value
   LOCAL aAllowed := {}
   LOCAL cAllowed := ""
   LOCAL nRowStart := int((aValue[1]-1)/3) * 3 + 1
   LOCAL nRowEnd := nRowstart + 2
   LOCAL nColStart := int((aValue[2]-1)/3) * 3 + 1
   LOCAL nColEnd := nColstart + 2
   LOCAL lAllowed
   LOCAL i
   LOCAL j
   LOCAL k

   IF aValue[1] > 0 .and. aValue[2] > 0

      IF aOriginal[aValue[1],aValue[2]] > 0

         sudoku.valid.value := ""

      ELSE

         FOR i := 1 to 9

            lAllowed := .T.
            FOR j := 1 to 9
               IF aSudoku[aValue[1],j] == i
                  lAllowed := .F.
               ENDIF
               IF aSudoku[j,aValue[2]] == i
                  lAllowed := .F.
               ENDIF
            NEXT j

            FOR j := nRowStart to nRowEnd
               FOR k := nColStart to nColEnd
                  IF aSudoku[j,k] == i
                     lAllowed := .F.
                  ENDIF
               NEXT k
            NEXT j

            IF lAllowed
               aadd(aAllowed,i)
            ENDIF

         NEXT i

         IF len(aAllowed) > 0
            FOR i := 1 to len(aAllowed)
               IF i == 1
                  cAllowed := cAllowed + alltrim(str(aAllowed[i]))
               ELSE
                  cAllowed := cAllowed + ", "+ alltrim(str(aAllowed[i]))
               ENDIF
            NEXT i
            sudoku.valid.value := "Possible Numbers: "+cAllowed
         ELSE
            sudoku.valid.value := "Possible Numbers: Nil"
         ENDIF

      ENDIF

   ENDIF

   RETURN NIL

FUNCTION ImportFromTxt( cFilename )

   LOCAL aLines := {}
   LOCAL handle := fopen(cFilename,0)
   LOCAL size1
   LOCAL sample
   LOCAL lineno
   LOCAL eof1
   LOCAL linestr := ""
   LOCAL c := ""
   LOCAL x
   LOCAL finished
   LOCAL m
   LOCAL aPuzzles := {}
   LOCAL aPuzzle := {}
   LOCAL aRow := {}
   LOCAL i
   LOCAL j
   LOCAL k

   IF handle == -1

      RETURN aPuzzles
   ENDIF

   size1 := fseek(handle,0,2)

   IF size1 > 65000
      sample := 65000
   ELSE
      sample := size1
   ENDIF

   fseek(handle,0)
   lineno := 1
   aadd(aLines,"")
   c := space(sample)
   eof1 := .F.
   linestr := ""

   DO WHILE .not. eof1
      x := fread(handle,@c,sample)

      IF x < 1

         eof1 := .T.
         aLines[lineno] := linestr

      ELSE

         finished := .F.

         DO WHILE .not. finished

            m := at(chr(13),c)

            IF m > 0

               IF m == 1

                  linestr := ""
                  lineno += 1
                  aadd(aLines,"")
                  IF asc(substr(c,m+1,1)) == 10
                     c := substr(c,m+2,len(c))
                  ELSE
                     c := substr(c,m+1,len(c))
                  ENDIF

               ELSE

                  IF len(alltrim(linestr)) > 0
                     linestr += substr(c,1,m-1)
                  ELSE
                     linestr := substr(c,1,m-1)
                  ENDIF

                  IF asc(substr(c,m+1,1)) == 10
                     c := substr(c,m+2,len(c))
                  ELSE
                     c := substr(c,m+1,len(c))
                  ENDIF

                  aLines[lineno] := linestr
                  linestr := ""
                  lineno += 1
                  aadd(aLines,"")

               ENDIF

            ELSE

               linestr := c
               finished := .T.

            ENDIF

         ENDDO

         c := space(sample)

      ENDIF

   ENDDO

   fclose(handle)

   FOR i := 1 to len(aLines)
      x := 1
      asize(aPuzzle,0)

      FOR j := 1 to 9
         asize(aRow,0)
         FOR k := 1 to 9
            aadd(aRow,val(alltrim(substr(aLines[i],x,1))))
            x += 2
         NEXT k
         IF len(aRow) == 9
            aadd(aPuzzle,aclone(aRow))
         ENDIF
      NEXT j

      IF len(aPuzzle) == 9
         aadd(aPuzzles,aclone(aPuzzle))
      ENDIF

   NEXT i

   RETURN aPuzzles

FUNCTION NextGame()

   LOCAL cTime := time()
   LOCAL nRandom
   LOCAL nGuess
   LOCAL nArrLen := len(aPuzzles)

   IF nArrLen > 0
      nRandom := val("0."+substr(cTime,8,1)+substr(cTime,5,1)+substr(cTime,8,2))
      nGuess := int(nRandom * (nArrLen+1))
      IF nGuess == 0
         nGuess := 1
      ENDIF
      aSudoku := aclone(aPuzzles[nGuess])
      aOriginal := aclone(aSudoku)
      sudoku.title := "HMG Sudoku"+" Game no: "+hb_ntos(nGuess)+" of "+hb_ntos(nArrLen)
   ENDIF

   RefreshSudokuGrid()

   RETURN NIL
