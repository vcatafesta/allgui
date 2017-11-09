#include <hmg.ch>

SET proc to grid2csv
SET proc to sampledata

MEMVAR dbo
MEMVAR cWindowName
MEMVAR cGridName
MEMVAR aOperations
MEMVAR aOptions
MEMVAR aCols
MEMVAR aAvailcols
MEMVAR aSelRows
MEMVAR aSelCols
MEMVAR aSelData
MEMVAR aColors
MEMVAR aWidths
MEMVAR aFieldOptions

FUNCTION Main

   LOCAL aData := {}
   PUBLIC dbo := nil

   aData := initdata()
   DEFINE WINDOW s at 0,0 width 1024 height 768 title "Xtract Sample" main icon "cube"
      DEFINE GRID data
         row 10
         col 10
         width 1000
         height 600
         items aData
         headers {"REGION","PRODUCT","SALESMAN","QUANTITY","DISCOUNT"}
         widths {150,150,150,150,150}
         justify {0,0,0,1,1}
         COLUMNCONTROLS { {'TEXTBOX','CHARACTER'} , {'TEXTBOX','CHARACTER'} ,{'TEXTBOX','CHARACTER'},{'TEXTBOX','NUMERIC','999999'}  , {'TEXTBOX','NUMERIC','99'}}
      END GRID
      DEFINE BUTTON xtract
         row 620
         col 10
         width 80
         caption "Xtract"
         action dataxtract("s","data")
      END BUTTON
      DEFINE BUTTON csvexport
         row 620
         col 110
         width 80
         caption "Xport2CSV"
         action grid2csv("s","data",.t.)
      END BUTTON
      DEFINE BUTTON import
         row 620
         col 210
         width 80
         caption "DBF Import"
         action importfromdbf()
      END BUTTON
      DEFINE BUTTON close
         row 620
         col 310
         width 80
         caption "Close"
         action s.release()
      END BUTTON
   END WINDOW
   s.center
   s.activate

   RETURN NIL

FUNCTION dataxtract(cWindow,cGrid)

   LOCAL aTypes := {}
   LOCAL nItemCount := 0
   LOCAL aLineData := {}
   LOCAL i, j
   LOCAL aEditControls := {}
   LOCAL aJustify := {}
   LOCAL aItem := {}
   LOCAL aFilterValues := {}
   LOCAL aFieldValues := {}
   LOCAL nCount
   PRIVATE cWindowName := cWindow
   PRIVATE cGridName := cGrid
   PRIVATE aOperations := {"","SUM","MINIMUM","MAXIMUM","COUNT"}
   PRIVATE aOptions := {"","Row","Column","Data"}
   PRIVATE aCols := {}
   PRIVATE aAvailcols := {}
   PRIVATE aSelRows := {}
   PRIVATE aSelCols := {}
   PRIVATE aSelData := {}
   PRIVATE aColors := {{255,255,100},{255,100,255},{100,255,100}} // Row Color, Col Color and Data Color
   PRIVATE aWidths := {}
   PRIVATE aFieldOptions := {}

   nItemCount := getproperty(cWindow,cGrid,"itemcount")
   IF nItemCount == 0

      RETURN NIL
   ENDIF
   aLineData := getproperty(cWindow,cGrid,"item",1)
   FOR nCount := 1 to len(aLineData)
      aadd(aCols,{getproperty(cWindow,cGrid,"header",nCount),1,1})
      aadd(aAvailCols,getproperty(cWindow,cGrid,"header",nCount))
      aadd(aTypes,valtype(aLineData[nCount]))
   NEXT nCount
   i := GetControlIndex ( cGrid , cWindow )
   aJustify := _HMG_aControlMiscData1 [i] [3]

   WAIT WINDOW "Creating Data Environment - Please wait..." NOWAIT
   exporttosql("s","data")
   WAIT clear

   FOR i := 1 to len(aAvailCols)
      aadd(aWidths,120)
      asize(aFieldValues,0)
      aItem := sql(dbo,"select distinct "+alltrim(aAvailCols[i])+" from data order by "+aAvailCols[i])
      IF len(aItem) > 0
         FOR j := 1 to len(aItem)
            aadd(aFieldvalues,aItem[j,1])
         NEXT j
         asize(aFieldvalues,len(aFieldValues)+1)
         ains(aFieldValues,1)
         aFieldValues[1] := ''
         aadd(aFieldOptions,{'COMBOBOX',aclone(aFieldValues)})
      ELSE
         aadd(aFieldOptions,{'COMBOBOX',{}})
      ENDIF
   NEXT i

   asize(aFilterValues,len(aAvailCols))
   afill(aFilterValues,1)

   DEFINE WINDOW xtract at 0,0 width 790 height 630+iif(isappthemed(),8,0) icon "cube" title "Xtract Window" modal

      DEFINE TOOLBAR tool1 buttonsize 32,33
         button autocalc picture "cube2"  tooltip "Auto Calc On/Off (F2)" autosize check
         button calc picture "cube1" action createreport(.t.) tooltip "Refresh/Create Data Cube (F5)" autosize
         button print1 picture "print1" action cubeprint() tooltip "Print Data Cube (Ctrl+P)" autosize
         button close1 picture "close" action xtract.release() tooltip "Exit Data Cube (Esc)" autosize
      end toolbar

      DEFINE LABEL available
         row 45
         col 10
         width 200
         fontsize 14
         fontbold .t.
         value "Xtract Cube Construction"
      END LABEL

      DEFINE GRID cols
         row 75
         col 10
         width 300
         height 150
         widths {110,80,80}
         headers {"Field Name","Placement","Operation"}
         cellnavigation .t.
         columncontrols {{'TEXTBOX','CHARACTER'},{'COMBOBOX',aOptions},{'COMBOBOX',aOperations}}
         columnwhen {{||.f.},{||.t.},{||checkdata()}}
         columnvalid {{||.t.},{||checkoperation()},{||checkdataoperation()}}
         allowedit .t.
         on change updateoptions()
      END GRID
      DEFINE BUTTON up
         row 115
         col 315
         width 32
         height 36
         picture "up"
         action fieldup()
      END BUTTON
      DEFINE BUTTON down
         row 157
         col 315
         width 32
         height 36
         picture "down"
         action fielddown()
      END BUTTON

      DEFINE LABEL skeleton
         row 45
         col 350
         width 200
         fontsize 14
         fontbold .t.
         value "Data Cube Skeleton"
      END LABEL
      DEFINE GRID options
         row 75
         col 350
         height 150
         width 430
         showheaders .f.
         widths {120}
         cellnavigation .t.
         on change updateoptions()
      END GRID
      DEFINE LABEL filterlabel
         row 225
         col 10
         width 150
         fontbold .t.
         fontsize 14
         value "Filters"
      END LABEL
      DEFINE GRID filters
         row 250
         col 10
         width 770
         height 60
         headers aAvailCols
         widths aWidths
         cellnavigation .t.
         allowedit .t.
         columncontrols aFieldOptions
         on change createreport(xtract.tool1.autocalc.value)
      END GRID

      DEFINE LABEL datacube
         row 310
         col 10
         width 150
         fontbold .t.
         fontsize 14
         value "Data Cube"
      END LABEL

      DEFINE STATUSBAR
         statusitem "Welcome"
      END STATUSBAR
   END WINDOW

   on key F2 of xtract action iif(xtract.tool1.autocalc.value,xtract.tool1.autocalc.value := .f.,xtract.tool1.autocalc.value := .t.)
   on key F5 of xtract action createreport(.t.)
   on key ESCAPE of xtract action xtract.release()
   on key CONTROL+P of xtract action cubeprint()

   FOR i := 1 to len(aCols)
      xtract.cols.additem(aCols[i])
   NEXT i
   IF len(aCols) > 0
      xtract.cols.value := {1,2}
   ENDIF

   xtract.tool1.autocalc.value := .f.

   xtract.filters.additem(aFilterValues)
   xtract.center
   xtract.activate

   RETURN NIL

FUNCTION cubeprint

   IF .not. iscontroldefined(data,xtract)

      RETURN NIL
   ENDIF
   IF xtract.data.itemcount > 0
      gridprint("data","xtract")
   ENDIF

   RETURN NIL

FUNCTION checkdata

   LOCAL aValue := xtract.cols.value

   IF aValue[1] > 0
      IF xtract.cols.cell(aValue[1],2) == 4

         RETURN .t.
      ELSE

         RETURN .f.
      ENDIF
   ENDIF

   RETURN .f.

FUNCTION checkoperation

   LOCAL aValue := xtract.cols.value

   IF this.cellvalue == 4
      IF xtract.cols.cell(aValue[1],3) == 1
         xtract.cols.cell(aValue[1],3) := 2
      ENDIF
   ELSE
      xtract.cols.cell(aValue[1],3) := 1
   ENDIF

   RETURN .t.

FUNCTION checkdataoperation

   LOCAL aValue := xtract.cols.value

   IF this.cellvalue == 1
      IF xtract.cols.cell(aValue[1],2) == 4

         RETURN .f.
      ENDIF
   ENDIF

   RETURN .t.

FUNCTION fieldup

   LOCAL aValue := xtract.cols.value
   LOCAL aTemp := {}

   IF aValue[1] <= 1

      RETURN NIL
   ELSE
      aTemp := xtract.cols.item(aValue[1])
      xtract.cols.item(aValue[1]) := xtract.cols.item(aValue[1]-1)
      xtract.cols.item(aValue[1]-1) := aTemp
      xtract.cols.value := {aValue[1]-1,aValue[2]}
   ENDIF
   updateoptions()

   RETURN NIL

FUNCTION fielddown

   LOCAL aValue := xtract.cols.value
   LOCAL aTemp := {}

   IF aValue[1] == xtract.cols.itemcount

      RETURN NIL
   ELSE
      aTemp := xtract.cols.item(aValue[1])
      xtract.cols.item(aValue[1]) := xtract.cols.item(aValue[1]+1)
      xtract.cols.item(aValue[1]+1) := aTemp
      xtract.cols.value := {aValue[1]+1,aValue[2]}
   ENDIF
   updateoptions()

   RETURN NIL

FUNCTION updateoptions

   LOCAL nCols := 0
   LOCAL nRows := 0
   LOCAL nData := 0
   LOCAL nTotCols := 0
   LOCAL nTotRows := 0
   LOCAL aWidths := {}
   LOCAL aBackColors := {}
   LOCAL aItem := {}
   LOCAL i, j
   LOCAL nCurCol
   LOCAL aOldRows := {}
   LOCAL aOldCols := {}
   LOCAL aOldData := {}
   LOCAL bcolor := {|| iif(this.cellrowindex == 1,iif(this.cellcolindex == 1,{255,255,255},aColors[2]),iif(this.cellcolindex == 1,aColors[1],aColors[3]))}

   aOldRows := aclone(aSelRows)
   aOldCols := aclone(aSelCols)
   aOldData := aclone(aSelData)

   asize(aSelRows,0)
   asize(aSelCols,0)
   asize(aSelData,0)

   FOR i := 1 to xtract.cols.itemcount
      DO CASE
      CASE xtract.cols.cell(i,2) == 2 // selected for row
         aadd(aSelRows,xtract.cols.cell(i,1))
      CASE xtract.cols.cell(i,2) == 3 // selected for Column
         aadd(aSelCols,xtract.cols.cell(i,1))
      CASE xtract.cols.cell(i,2) == 4 // selected for data
         aadd(aSelData,{alltrim(xtract.cols.cell(i,1)),alltrim(aOperations[xtract.cols.cell(i,3)])})
      END CASE
   NEXT i

   nRows := len(aSelRows)
   nCols := len(aSelCols)
   nData := len(aSelData)

   IF iscontroldefined(options,xtract)
      xtract.options.release
   ENDIF

   nTotCols := nCols + 1 + iif(nCols == 0 .and. nData > 0,1,0)
   nTotRows := max(nRows,nData) + 1

   FOR i := 1 to nTotCols
      aadd(aWidths,120)
   NEXT i

   aadd(aItem,'')

   FOR i := 2 to nTotCols
      IF i-1 <= nCols
         aadd(aItem,aSelCols[i-1])
      ELSE
         aadd(aItem,'')
      ENDIF
   NEXT i

   FOR i := 1 to len(aWidths)
      aadd(aBackColors, bColor)
   NEXT i

   DEFINE GRID options
      parent xtract
      row 75
      col 350
      height 150
      width 430
      showheaders .f.
      widths aWidths
      DYNAMICbackcolor aBackColors
   END GRID

   xtract.options.additem(aItem)

   FOR i := 2 to nTotRows
      asize(aItem,0)
      nCurCol := 1
      IF i-1 <= nRows
         aadd(aItem,aSelRows[i-1])
      ELSE
         aadd(aItem,'')
      ENDIF
      IF nCols > 0 .or. nData > 0
         IF i-1 <= nData
            aadd(aItem,alltrim(aSelData[i-1,1])+"-"+alltrim(aSelData[i-1,2]))
         ELSE
            aadd(aItem,'')
         ENDIF
      ENDIF
      FOR j := 3 to nTotCols
         aadd(aItem,'')
      NEXT j
      xtract.options.additem(aItem)
   NEXT i
   IF len(aSelRows) > 0 .or. len(aSelCols) > 0 .or. len(aSelData) > 0
      IF .not. (comparearrays(aOldRows,aSelRows) .and. comparearrays(aOldCols,aSelCols) .and. comparearrays(aOldData,aSelData))
         createreport(xtract.tool1.autocalc.value)
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION createreport(lAutoCalc)

   LOCAL aRowIds := {}
   LOCAL aColIds := {}
   LOCAL aDataIds := {}
   LOCAL aRowData := {}
   LOCAL aColData := {}
   LOCAL aData := {}
   LOCAL aTable := {}
   LOCAL aColTable := {}
   LOCAL aResults := {}
   LOCAL aLine := {}
   LOCAL aCurRow := {}
   LOCAL aCurCol := {}
   LOCAL aCurData := {}
   LOCAL aReportGrid := {}
   LOCAL aColHead := {}
   LOCAL aHeads := {}
   LOCAL aFirstRow := {}
   LOCAL aFirstCol := {}
   LOCAL aFirstData := {}
   LOCAL aResultLine := {}
   LOCAL cQStr := ""
   LOCAL cRowStr := ""
   LOCAL cColStr := ""
   LOCAL cDataStr := ""
   LOCAL cFilterStr := ""
   LOCAL nRows := 0
   LOCAL nCols := 0
   LOCAL nData := 0
   LOCAL nTotRows := 0
   LOCAL nTotCols := 0
   LOCAL i, j, k, aHeaders, aJustify, aRowTotal, aGT
   LOCAL nCurRow, nCurrent, lDiff, nResRows, nResCols, nHeaders
   LOCAL aColTotal := {}
   LOCAL aRowRotal := {}
   LOCAL bcolor := {|| {255,255,255}}
   LOCAL aBackColors := {}
   LOCAL aFilterItems := {}

   IF .not. lAutoCalc

      RETURN NIL
   ENDIF

   IF len(aSelRows) == 0 .and. len(aSelCols) == 0 .and. len(aSelData) == 0

      RETURN NIL
   ENDIF

   WAIT window "Please wait while tabulating..." nowait

   aRowIds := aclone(aSelRows)
   aColIds := aclone(aSelCols)
   aDataIds := aclone(aSelData)

   /*
   for i := 1 to xtract.selrows.itemcount
   //   aadd(aRowIds,ascan(aCols,xtract.selrows.item(i)))
   aadd(aRowIds,xtract.selrows.item(i))
   next i

   for i := 1 to xtract.selcols.itemcount
   //   aadd(aColIds,ascan(aCols,xtract.selcols.item(i)))
   aadd(aColIds,xtract.selcols.item(i))
   next i

   for i := 1 to xtract.datacols.itemcount
   aLineData := xtract.datacols.item(i)
   //   aadd(aDataIds,{ascan(aCols,aLineData[1]),ascan(aOperations,aLineData[2])})
   aadd(aDataIds,{aLineData[1],aLineData[2]})
   next i
   */

   //nItemCount := getproperty(cWindowName,cGridName,"itemcount")

   nRows := len(aRowIds)
   nCols := len(aColIds)
   nData := len(aDataIds)

   FOR i := 1 to nRows
      cRowStr := cRowStr + aRowIds[i]
      IF i < nRows
         cRowStr := cRowStr + ","
      ENDIF
   NEXT i

   FOR i := 1 to nCols
      cColStr := cColStr + aColIds[i]
      IF i < nCols
         cColStr := cColStr + ","
      ENDIF
   NEXT i

   FOR i := 1 to nData
      DO CASE
      CASE aDataIds[i,2] == "SUM"
         cDataStr := cDataStr + "sum("+aDataIds[i,1]+")"
      CASE aDataIds[i,2] == "MINIMUM"
         cDataStr := cDataStr + "min(round("+aDataIds[i,1]+",5))"
      CASE aDataIds[i,2] == "MAXIMUM"
         cDataStr := cDataStr + "max(round("+aDataIds[i,1]+",5))"
      CASE aDataIds[i,2] == "COUNT"
         cDataStr := cDataStr + "count("+aDataIds[i,1]+")"
      ENDCASE
      IF i < nData
         cDataStr := cDataStr + ","
      ENDIF
   NEXT i

   //filters

   cFilterStr := ""
   FOR i := 1 to len(aAvailCols)
      IF xtract.filters.cell(1,i) > 1
         aFilterItems := aFieldOptions[i,2]
         IF len(alltrim(cFilterStr)) == 0
            cFilterStr := cFilterStr + alltrim(aAvailCols[i])+" = "+c2sql((aFilterItems[xtract.filters.cell(1,i)]))
         ELSE
            cFilterStr := cFilterStr + " and "+alltrim(aAvailCols[i])+" = "+c2sql((aFilterItems[xtract.filters.cell(1,i)]))
         ENDIF
      ENDIF
   NEXT i

   cQStr := "select "

   IF len(cRowStr) > 0
      cQStr := cQStr + cRowStr
      IF len(cColStr) > 0 .or. len(cDataStr) > 0
         cQStr := cQStr + ","
      ENDIF
   ENDIF

   IF len(cColStr) > 0
      cQStr := cQstr + cColStr
      IF len(cDataStr) > 0
         cQstr := cQStr + ","
      ENDIF
   ENDIF

   IF len(cDataStr) > 0
      cQStr := cQstr + cDataStr
   ENDIF

   cQStr := cQStr + " from data"

   IF len(alltrim(cFilterStr)) > 0  // filters
      cQstr := cQstr + " where "+cFilterStr
   ENDIF

   IF len(cRowStr) > 0 .or. len(cColStr) > 0
      cQStr := cQstr + " group by "

      IF len(cRowStr) > 0
         cQStr := cQStr + cRowStr
         IF len(cColStr) > 0
            cQStr := cQStr + ","
         ENDIF
      ENDIF

      IF len(cColStr) > 0
         cQStr := cQstr + cColStr
      ENDIF

      cQStr := cQStr + " order by "

      IF len(cRowStr) > 0
         cQStr := cQStr + cRowStr
         IF len(cColStr) > 0
            cQStr := cQStr + ","
         ENDIF
      ENDIF

      IF len(cColStr) > 0
         cQStr := cQstr + cColStr
      ENDIF
   ENDIF

   //cStart := time()

   aTable := sql(dbo,cQstr)

   //cTimeTaken := elaptime(cStart,time())
   //msginfo("Query took "+substr(cTimeTaken,1,2)+" Hours, "+substr(cTimeTaken,4,2)+" Minutes, "+substr(cTimeTaken,7,2)+" Seconds.")

   IF len(cColStr) > 0

      cQStr := "select " + cColStr +" from data "+iif(len(alltrim(cFilterStr)) > 0," where "+cFilterStr,"")+" group by "+cColStr+" order by "+cColStr
      aColTable := sql(dbo,cQstr)
   ENDIF

   asize(aResults,0)

   nTotRows := len(aTable) * iif(nData > 0,nData,1)
   nTotCols := nRows + iif(nData > 1,1,0)+len(aColTable)+iif(nCols == 0 .and. nData > 0,1,0)

   //aResults := array(nTotRows,nTotCols)
   nCurRow := 1

   IF nData <= 1
      aadd(aResults,array(nTotCols))
   ELSE
      FOR j := 1 to nData
         aadd(aResults,array(nTotCols))
      NEXT j
   ENDIF

   asize(aFirstRow,0)
   asize(aFirstCol,0)
   asize(aFirstData,0)

   aLine := aTable[1]
   FOR j := 1 to nRows
      aadd(aFirstRow,aLine[j])
   NEXT j

   FOR j := 1 to nCols
      aadd(aFirstCol,aLine[nRows+j])
   NEXT j

   FOR j := 1 to nData
      aadd(aFirstData,aLine[nRows+nCols+j])
   NEXT j

   FOR i := 1 to len(aFirstRow)
      aResults[nCurRow,i] := aFirstRow[i]
   NEXT i

   IF nCols > 0
      IF nCols == 1
         nCurrent := ascan(aColTable,{|x|x[1] == aFirstCol[1]})
      ELSE
         nCurrent := ascan(aColTable,{|x|comparearrays(x,aFirstCol)})
      ENDIF
      IF nData > 0
         IF nData == 1
            aResults[nCurRow,nRows+nCurrent] := aFirstData[1]
         ELSE
            aResults[nCurRow,nRows+1] := aDataIds[1,2]+"-"+aDataIds[1,1]
            aResults[nCurRow,nRows+1+nCurrent] := aFirstData[1]
            FOR j := 2 to nData
               aResults[nCurRow+j-1,nRows+1] := aDataIds[j,2]+"-"+aDataIds[j,1]
               aResults[nCurRow+j-1,nRows+1+nCurrent] := aFirstData[j]
            NEXT j
         ENDIF
      ENDIF
   ELSE
      IF nData > 0
         IF nData == 1
            aResults[nCurRow,nRows+1] := aFirstData[1]
         ELSE
            aResults[nCurRow,nRows+1] := aDataIds[1,2]+"-"+aDataIds[1,1]
            aResults[nCurRow,nRows+2] := aFirstData[1]
            FOR j := 2 to nData
               aResults[nCurRow+j-1,nRows+1] := aDataIds[j,2]+"-"+aDataIds[j,1]
               aResults[nCurRow+j-1,nRows+2] := aFirstData[j]
            NEXT j
         ENDIF
      ENDIF
   ENDIF

   FOR i := 2 to len(aTable)
      aLine := aTable[i]

      asize(aCurRow,0)
      asize(aCurCol,0)
      asize(aCurData,0)

      FOR j := 1 to nRows
         aadd(aCurRow,aLine[j])
      NEXT j

      FOR j := 1 to nCols
         aadd(aCurCol,aLine[nRows+j])
      NEXT j

      FOR j := 1 to nData
         aadd(aCurData,aLine[nRows+nCols+j])
      NEXT j

      IF comparearrays(aFirstRow,aCurRow) // Same Row different Column

         IF nCols > 0
            IF nCols == 1
               nCurrent := ascan(aColTable,{|x|x[1] == aCurCol[1]})
            ELSE
               nCurrent := ascan(aColTable,{|x|comparearrays(x,aCurCol)})
            ENDIF
            IF nData > 0
               IF nData == 1
                  aResults[nCurRow,nRows+nCurrent] := aCurData[1]
               ELSE
                  //            aResults[nCurRow,nRows+1] := aDataIds[1,2]+"-"+aDataIds[1,1]
                  aResults[nCurRow,nRows+1+nCurrent] := aCurData[1]
                  FOR j := 2 to nData
                     //               aResults[nCurRow+j-1,nRows+1] := aDataIds[j,2]+"-"+aDataIds[j,1]
                     aResults[nCurRow+j-1,nRows+1+nCurrent] := aCurData[j]
                  NEXT j
               ENDIF
            ENDIF
         ELSE
            IF nData > 0
               IF nData == 1
                  aResults[nCurRow,nRows+1] := aCurData[1]
               ELSE
                  //               aResults[nCurRow,nRows+1] := aDataIds[1,2]+"-"+aDataIds[1,1]
                  aResults[nCurRow,nRows+2] := aCurData[1]
                  FOR j := 2 to nData
                     //                  aResults[nCurRow+j-1,nRows+1] := aDataIds[j,2]+"-"+aDataIds[j,1]
                     aResults[nCurRow+j-1,nRows+2] := aCurData[j]
                  NEXT j
               ENDIF
            ENDIF
         ENDIF
      ELSE // new Row  of data
         IF nData <= 1
            nCurRow := nCurRow + 1
            aadd(aResults,array(nTotCols))
         ELSE
            nCurRow := nCurRow + nData
            FOR j := 1 to nData
               aadd(aResults,array(nTotCols))
            NEXT j
         ENDIF
         lDiff := .f.
         FOR j := 1 to len(aFirstRow)
            IF (.not. lDiff) .and. (aFirstRow[j] <> aCurRow[j])
               lDiff := .t.
            ENDIF
            IF lDiff
               aResults[nCurRow,j] := aCurRow[j]
            ENDIF
         NEXT j

         aFirstRow := aclone(aCurRow)
         aFirstCol := aclone(aCurCol)
         aFirstData := aclone(aCurData)

         IF nCols > 0
            IF nCols == 1
               nCurrent := ascan(aColTable,{|x|x[1] == aFirstCol[1]})
            ELSE
               nCurrent := ascan(aColTable,{|x|comparearrays(x,aFirstCol)})
            ENDIF
            IF nData > 0
               IF nData == 1
                  aResults[nCurRow,nRows+nCurrent] := aFirstData[1]
               ELSE
                  aResults[nCurRow,nRows+1] := aDataIds[1,2]+"-"+aDataIds[1,1]
                  aResults[nCurRow,nRows+1+nCurrent] := aFirstData[1]
                  FOR j := 2 to nData
                     aResults[nCurRow+j-1,nRows+1] := aDataIds[j,2]+"-"+aDataIds[j,1]
                     aResults[nCurRow+j-1,nRows+1+nCurrent] := aFirstData[j]
                  NEXT j
               ENDIF
            ENDIF
         ELSE
            IF nData > 0
               IF nData == 1
                  aResults[nCurRow,nRows+1] := aFirstData[1]
               ELSE
                  aResults[nCurRow,nRows+1] := aDataIds[1,2]+"-"+aDataIds[1,1]
                  aResults[nCurRow,nRows+2] := aFirstData[1]
                  FOR j := 2 to nData
                     aResults[nCurRow+j-1,nRows+1] := aDataIds[j,2]+"-"+aDataIds[j,1]
                     aResults[nCurRow+j-1,nRows+2] := aFirstData[j]
                  NEXT j
               ENDIF
            ENDIF
         ENDIF
      ENDIF
   NEXT i

   aColHead := {}
   nCurRow := 1
   IF nCols > 0
      aadd(aColHead,array(nCols))
      aFirstRow := aclone(aColTable[1])
      aColHead[nCurRow] := aclone(aColTable[1])

      FOR i := 2 to len(aColTable)
         aadd(aColHead,array(nCols))
         nCurRow := nCurRow + 1
         lDiff := .f.
         aCurRow := aclone(aColTable[i])

         FOR j := 1 to nCols
            IF (.not. lDiff) .and. (aFirstRow[j] <> aCurRow[j])
               lDiff := .t.
            ENDIF
            IF lDiff
               aColHead[nCurRow,j] := aCurRow[j]
            ENDIF
         NEXT j
         aFirstRow := aclone(aCurRow)
      NEXT i
   ENDIF

   aHeaders := {}

   IF nRows > 0 .or. nCols > 0
      aadd(aHeaders,array(nTotCols))
      FOR i := 1 to nRows
         aHeaders[1,i] := aRowIds[i]
      NEXT i
      FOR i := 1 to len(aColHead)
         aHeaders[1,nRows+iif(nData > 1,1,0)+i] := aColHead[i,1]
      NEXT i
      IF len(aColHead) > 0
         IF len(aColHead[1]) > 1
            FOR i := 2 to len(aColHead[1])
               aadd(aHeaders,array(nTotCols))
               FOR j := 1 to len(aColHead)
                  aHeaders[i,nRows+iif(nData > 1,1,0)+j] := aColHead[j,i]
               NEXT j
            NEXT i
         ENDIF
      ENDIF
   ENDIF

   //summation

   IF nData > 0
      aRowTotal := array(len(aResults))
      aColTotal := array(nData,len(aResults[1]))
      aGT := array(nData)

      nResRows := len(aResults)
      nResCols := len(aResults[1])

      FOR i := 1 to nResRows
         aRowTotal[i] := 0
      NEXT i
      FOR i := 1 to nData
         FOR j := nRows+iif(nData > 1,1,0)+1 to nResCols
            aColTotal[i,j] := 0
         NEXT j
      NEXT i
      FOR i := 1 to nData
         aGt[i] := 0
      NEXT i

      FOR i := 1 to nResRows step nData
         FOR j := nRows+iif(nData > 1,1,0)+1 to nResCols
            FOR k := 0 to nData - 1
               DO CASE
               CASE aDataIds[k+1,2] == "SUM" .or. aDataIds[k+1,2] == "COUNT"
                  aRowTotal[i+k] := aRowTotal[i+k] + iif(valtype(aResults[i+k,j]) == "C",val(alltrim(aResults[i+k,j])),if(valtype(aResults[i+k,j]) == "U",0,aResults[i+k,j]))
                  aColTotal[k+1,j] := aColTotal[k+1,j] + iif(valtype(aResults[i+k,j]) == "C",val(alltrim(aResults[i+k,j])),if(valtype(aResults[i+k,j]) == "U",0,aResults[i+k,j]))
                  aGT[k+1] := aGT[k+1] + iif(valtype(aResults[i+k,j]) == "C",val(alltrim(aResults[i+k,j])),if(valtype(aResults[i+k,j]) == "U",0,aResults[i+k,j]))
               CASE aDataIds[k+1,2] == "MINIMUM"
                  aRowTotal[i+k] := min(aRowTotal[i+k],iif(valtype(aResults[i+k,j]) == "C",val(alltrim(aResults[i+k,j])),iif(valtype(aResults[i+k,j])=="U",aRowTotal[i+k],aResults[i+k,j])))
                  aColTotal[k+1,j] := min(aColTotal[k+1,j],iif(valtype(aResults[i+k,j]) == "C",val(alltrim(aResults[i+k,j])),iif(valtype(aResults[i+k,j])=="U",aColTotal[k+1,j],aResults[i+k,j])))
                  aGT[k+1] := min(aGT[k+1],iif(valtype(aResults[i+k,j]) == "C",val(alltrim(aResults[i+k,j])),if(valtype(aResults[i+k,j]) == "U",aGT[k+1],aResults[i+k,j])))
               CASE aDataIds[k+1,2] == "MAXIMUM"
                  aRowTotal[i+k] := max(aRowTotal[i+k],iif(valtype(aResults[i+k,j]) == "C",val(alltrim(aResults[i+k,j])),iif(valtype(aResults[i+k,j])=="U",aRowTotal[i+k],aResults[i+k,j])))
                  aColTotal[k+1,j] := max(aColTotal[k+1,j],iif(valtype(aResults[i+k,j]) == "C",val(alltrim(aResults[i+k,j])),iif(valtype(aResults[i+k,j])=="U",aColTotal[k+1,j],aResults[i+k,j])))
                  aGT[k+1] := max(aGT[k+1],iif(valtype(aResults[i+k,j]) == "C",val(alltrim(aResults[i+k,j])),if(valtype(aResults[i+k,j]) == "U",aGT[k+1],aResults[i+k,j])))
               ENDCASE
            NEXT k
         NEXT j
      NEXT i

      IF nCols > 0
         FOR i := 1 to nResRows
            aadd(aResults[i],str(aRowTotal[i]))
         NEXT i

         FOR i := 1 to nData
            aadd(aColTotal[i],aGT[i])
         NEXT i

         aadd(aHeaders[1],"Total")
         FOR i := 2 to len(aHeaders)
            aadd(aHeaders[i],"")
         NEXT i
      ENDIF

      IF nData > 1 .or. nRows > 0 // there is room for "Total"
         aColTotal[1,1] := "Total"
      ENDIF

      FOR i := 1 to nData
         FOR j := 1 to len(aColTotal[i])
            IF valtype(aColTotal[i,j]) == "N"
               aColTotal[i,j] := alltrim(str(aColTotal[i,j]))
            ENDIF
         NEXT j
      NEXT i

      FOR i := 1 to nData
         aadd(aResults,aclone(aColTotal[i]))
      NEXT i

   ENDIF

   aReportGrid := {}

   nHeaders := len(aHeaders)
   IF nHeaders > 0
      FOR i := 1 to nHeaders
         aadd(aReportGrid,aclone(aHeaders[i]))
      NEXT i
   ENDIF

   nResRows := len(aResults)
   FOR i := 1 to nResRows
      aadd(aReportGrid,aclone(aResults[i]))
   NEXT i

   WAIT clear

   //aReportGrid := aClone(aResults)

   IF len(aReportGrid) > 0
      aHeaders := {}
      aWidths := {}
      aJustify := {}
      FOR i := 1  to len(aReportGrid[1])
         aadd(aHeaders,'')
         aadd(aWidths,100)
         IF i > 1 .and. i > nRows+iif(nData > 1,1,0)
            aadd(aJustify,1)
         ELSE
            aadd(aJustify,0)
         ENDIF
      NEXT i

      bcolor := {||iif(this.cellrowindex <= len(aSelCols),;
         iif(this.cellcolindex <= len(aSelRows),aColors[1],aColors[2]),iif(this.cellcolindex <= len(aSelRows),aColors[1],aColors[3]))}

      FOR i := 1 to len(aWidths)
         aadd(aBackColors,bcolor)
      NEXT i

      IF iscontroldefined(data,xtract)
         xtract.data.release()
      ENDIF

      DEFINE GRID data
         parent xtract
         row 335
         col 10
         width 770
         height 250
         widths aWidths
         headers aHeaders
         justify aJustify
         showheaders .f.
         items aReportGrid
         DYNAMICbackcolor aBackColors
         //      cellnavigation .t.
      END GRID
   ELSE
      IF iscontroldefined(data,xtract)
         xtract.data.deleteallitems()
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION comparearrays(x,y)

   LOCAL i,j := 0
   LOCAL lenx,leny := 0
   LOCAL xelement, yelement

   IF valtype(x) == "A" .and. valtype(y) == "A"
      lenx := len(x)
      leny := len(y)
      IF lenx <> leny

         RETURN .f.
      ENDIF
      FOR i := 1 to lenx
         xelement := x[i]
         yelement := y[i]
         IF valtype(xelement) <> valtype(yelement)

            RETURN .f.
         ELSE
            IF valtype(xelement) == "A"
               IF .not. comparearrays(xelement,yelement)

                  RETURN .f.
               ENDIF
            ELSE
               IF xelement <> yelement

                  RETURN .f.
               ENDIF
            ENDIF
         ENDIF
      NEXT i

      RETURN .t.
   ENDIF

   RETURN NIL

FUNCTION importfromdbf

   LOCAL cDbfFileName := ""
   LOCAL aStruct := {}
   LOCAL aFieldNames := {}
   LOCAL aFieldTypes := {}
   LOCAL aWidths := {}
   LOCAL aData := {}
   LOCAL aCurRow := {}
   LOCAL cCurFieldName := ""
   LOCAL aJustify := {}
   LOCAL i

   cDbfFileName := Getfile ( { {'All DBF Files','*.dbf'} } , 'Open DBF File' , 'c:\' , .f. , .t. )
   IF len(alltrim(cDbfFileName)) > 0
      SELECT a
      USE &cDbfFileName
      aStruct := dbstruct()
      FOR i := 1 to len(aStruct)
         aadd(aFieldNames,aStruct[i,1])
         aadd(aFieldTypes,aStruct[i,2])
         aadd(aWidths,aStruct[i,3]*10)
         aadd(aJustify,iif(i == 1 .or. aStruct[i,2] == "C" .or. aStruct[i,2] == "D" .or. aStruct[i,2] == "L",0,1))
      NEXT i
      GO TOP
      DO WHILE .not. eof()
         FOR i := 1 to len(aFieldNames)
            cCurFieldName := aFieldNames[i]
            DO CASE
            CASE aFieldTypes[i] == "C"
               aadd(aCurRow,a->&cCurFieldName)
            CASE aFieldTypes[i] == "N"
               aadd(aCurRow,str(a->&cCurFieldName))
            CASE aFieldTypes[i] == "D"
               aadd(aCurRow,dtoc(a->&cCurFieldName))
            CASE aFieldTypes[i] == "L"
               aadd(aCurRow,iif(a->&cCurFieldName,"True","False"))
            OTHERWISE
               aadd(aCurRow,a->&cCurFieldName)
            ENDCASE
         NEXT i
         aadd(aData,aclone(aCurRow))
         asize(aCurRow,0)
         SELECT a
         SKIP
      ENDDO
      CLOSE all
      IF iscontroldefined(data,s)
         s.data.release
      ENDIF
      DEFINE GRID data
         parent s
         row 10
         col 10
         width 1000
         height 600
         items aData
         headers aFieldNames
         widths aWidths
         justify aJustify
      END GRID
   ENDIF

   RETURN NIL

FUNCTION exporttosql(cWindow,cGrid)

   LOCAL aCols := {}
   LOCAL aTypes := {}
   LOCAL nItemCount := 0
   LOCAL aLineData := {}
   LOCAL nResult := 0
   LOCAL i, j, qstr
   LOCAL nRecCount
   LOCAL nAtaTime
   LOCAL cQstr, nCount

   nItemCount := getproperty(cWindow,cGrid,"itemcount")
   IF nItemCount == 0

      RETURN NIL
   ENDIF
   aLineData := getproperty(cWindow,cGrid,"item",1)
   FOR nCount := 1 to len(aLineData)
      aadd(aCols,getproperty(cWindow,cGrid,"header",nCount))
      aadd(aTypes,valtype(aLineData[nCount]))
   NEXT nCount

   connect2db("")

   qstr := "drop table if exists data;"
   IF .not. miscsql(dbo,qstr)

      RETURN NIL
   ENDIF

   qstr := "create table data ("
   FOR i := 1 to len(aCols)
      qstr := qstr + aCols[i]
      IF i < len(aCols)
         qstr := qstr + ","
      ENDIF
   NEXT i
   qstr := qstr + ");"

   IF .not. miscsql(dbo,qstr)

      RETURN NIL
   ENDIF
   nRecCount := 0
   nAtaTime := 100
   cQstr := "BEGIN TRANSACTION;"
   FOR i := 1 to nItemCount
      IF nRecCount >= nAtaTime
         cQstr := cQstr + "COMMIT;"
         IF .not. miscsql(dbo,cQstr)

            RETURN NIL
         ENDIF
         nRecCount := 0
         cQstr := ""
         cQstr := "BEGIN TRANSACTION;"
      ENDIF
      cQstr := cQstr + "insert into data values ("
      aLineData := getproperty(cWindow,cGrid,"item",i)
      FOR j := 1 to len(aLineData)
         cQstr := cQstr + c2sql(aLineData[j])
         IF j < len(aLineData)
            cQstr := cQstr + ","
         ENDIF
      NEXT j
      cQstr := cQstr + ");"
      nReccount := nRecCount + 1
   NEXT i
   IF nRecCount > 0
      cQstr := cQstr + "COMMIT;"
      IF .not. miscsql(dbo,cQstr)

         RETURN NIL
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION connect2db(dbname)

   dbo := sqlite3_open( dbname,.t.)
   IF Empty( dbo )
      msginfo("Database could not be connected!")

      RETURN NIL
   ENDIF

   //msginfo("Successfully Connected to the MySQL Server",appname)

   RETURN NIL

FUNCTION sql(dbo1,qstr)

   LOCAL table := {}
   LOCAL currow := nil
   LOCAL tablearr := {}
   LOCAL rowarr := {}
   LOCAL datetypearr := {}
   LOCAL numtypearr := {}
   LOCAL typesarr := {}
   LOCAL current := ""
   LOCAL i, j
   LOCAL stmt
   LOCAL type1 := ""

   table := sqlite3_get_table(dbo1,qstr)
   IF sqlite3_errcode(dbo1) > 0 // error
      msgstop(sqlite3_errmsg(dbo1)+" Query is : "+qstr)

      RETURN NIL
   ENDIF
   stmt := sqlite3_prepare(dbo1,qstr)
   IF ! Empty( stmt )
      FOR i := 1 to sqlite3_column_count( stmt )
         type1 := sqlite3_column_decltype( stmt,i)
         DO CASE
         CASE type1 == "TEXT"
            aadd(typesarr,"C")
         CASE type1 == "INTEGER" .or. type1 == "REAL"
            aadd(typesarr,"N")
         OTHERWISE
            aadd(typesarr,"C")
         ENDCASE
      NEXT i
   ENDIF
   sqlite3_reset( stmt )

   IF len(table) > 1
      asize(tablearr,0)
      rowarr := table[2]
      FOR i := 1 to len(rowarr)
         current := rowarr[i]
         /*      if typesarr[i] == "C" .and. len(alltrim(current)) == 10 .and. val(alltrim(substr(current,1,4))) > 0 .and. val(alltrim(substr(current,6,2))) > 0 .and. val(alltrim(substr(current,6,2))) <= 12 .and. val(alltrim(substr(current,9,2))) > 0 .and. val(alltrim(substr(current,9,2))) <= 31 .and. substr(alltrim(current),5,1) == "-" .and. substr(alltrim(current),8,1) == "-"
         aadd(datetypearr,.t.)
         else
         */
         aadd(datetypearr,.f.)
         /*      endif*/
      NEXT i
      FOR i := 2 to len(table)
         rowarr := table[i]
         FOR j := 1 to len(rowarr)
            IF datetypearr[j]
               rowarr[j] := CToD(SubStr(alltrim(rowarr[j]),9,2)+"-"+SubStr(alltrim(rowarr[j]),6,2)+"-"+SubStr(alltrim(rowarr[j]),1,4))
            ENDIF
            IF typesarr[j] == "N"
               rowarr[j] := val(rowarr[j])
            ENDIF
         NEXT j
         aadd(tablearr,aclone(rowarr))
      NEXT i
   ENDIF

   RETURN tablearr

FUNCTION miscsql(dbo1,qstr)

   IF empty(dbo1)
      msgstop("Database Connection Error!")

      RETURN .f.
   ENDIF
   sqlite3_exec(dbo1,qstr)
   IF sqlite3_errcode(dbo1) > 0 // error
      msgstop(sqlite3_errmsg(dbo1)+" Query is : "+qstr)

      RETURN .f.
   ENDIF

   RETURN .t.

FUNCTION C2SQL(Value)

   LOCAL cValue := ""
   LOCAL cdate := ""

   IF valtype(value) == "C" .and. len(alltrim(value)) > 0
      value := strtran(value,"'","''")
   ENDIF
   DO CASE
   CASE Valtype(Value) == "N"
      cValue := "'"+AllTrim(Str(Value))+"'"

   CASE Valtype(Value) == "D"
      IF !Empty(Value)
         cdate := dtos(value)
         cValue := "'"+substr(cDate,1,4)+"-"+substr(cDate,5,2)+"-"+substr(cDate,7,2)+"'"
      ELSE
         cValue := "''"
      ENDIF
   CASE Valtype(Value) $ "CM"
      IF Empty( Value)
         cValue="''"
      ELSE
         cValue := "'" + value + "'"
      ENDIF

   CASE Valtype(Value) == "L"
      cValue := AllTrim(Str(iif(Value == .F., 0, 1)))

   OTHERWISE
      cValue := "''"       // NOTE: Here we lose values we cannot convert

   ENDCASE

   RETURN cValue

