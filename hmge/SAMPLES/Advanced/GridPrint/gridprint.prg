#include "minigui.ch"
#include "miniprint.ch"

MEMVAR msgarr
MEMVAR fontname
MEMVAR fontsizesstr
MEMVAR headerarr
MEMVAR curpagesize
MEMVAR sizes
MEMVAR headersizes
MEMVAR selectedprinter
MEMVAR columnarr
MEMVAR fontnumber
MEMVAR windowname
MEMVAR lines
MEMVAR linedata
MEMVAR cPrintdata
MEMVAR gridname
MEMVAR ajustifiy
MEMVAR aJustify
MEMVAR psuccess
MEMVAR showwindow
MEMVAR aprinternames
MEMVAR defaultprinter
MEMVAR papernames
MEMVAR papersizes
MEMVAR printerno
MEMVAR header1
MEMVAR header2
MEMVAR header3
MEMVAR aEditcontrols
MEMVAR xres
MEMVAR maxcol2
MEMVAR curcol1
MEMVAR mergehead
MEMVAR _asum
MEMVAR sumarr
MEMVAR totalarr
MEMVAR spread

INIT PROCEDURE _InitPrintGrid

   InstallMethodHandler ( 'Print' , 'MyGridPrint' )

   RETURN

PROCEDURE MyGridPrint (  cWindowName , cControlName , MethodName )

   MethodName := Nil

   IF GetControlType ( cControlName , cWindowName ) == 'GRID'

      _gridprint( cControlName , cWindowName)

      _HMG_UserComponentProcess := .T.

   ELSE

      _HMG_UserComponentProcess := .F.

   ENDIF

   RETURN

   DECLARE window printgrid

FUNCTION _gridprint(cGrid,cWindow,fontsize,orientation,aHeaders,fontname1,showwindow1,mheaders,summation)

   LOCAL count1 := 0
   LOCAL count2 := 0
   LOCAL maxcol1 := 0
   LOCAL i := 0
   LOCAL aec
   LOCAL aitems
   PRIVATE msgarr
   PRIVATE fontname := ""
   PRIVATE fontsizesstr := {}
   PRIVATE headerarr := {}
   PRIVATE curpagesize := 1
   PRIVATE sizes := {}
   PRIVATE headersizes := {}
   PRIVATE selectedprinter := ""
   PRIVATE columnarr := {}
   PRIVATE fontnumber := 0
   PRIVATE windowname := cWindow
   PRIVATE lines := 0
   PRIVATE cPrintdata := {}
   PRIVATE linedata := {}
   PRIVATE gridname := cGrid
   PRIVATE ajustifiy := {}
   PRIVATE psuccess := .f.
   PRIVATE showwindow := .f.
   PRIVATE aprinternames := aprinters()
   PRIVATE defaultprinter := GetDefaultPrinter()
   PRIVATE papernames := {"Letter","Legal","Executive","A3","A4","Custom"}
   PRIVATE papersizes := {{216,279},{216,355.6},{184.1,266.7},{297,420},{210,297},{216,279}}
   PRIVATE printerno := 0
   PRIVATE header1 := ""
   PRIVATE header2 := ""
   PRIVATE header3 := ""
   PRIVATE aEditcontrols := {}
   PRIVATE xres := {}
   PRIVATE maxcol2 := 0.0
   PRIVATE curcol1 := 0.0
   PRIVATE _asum := {}
   PRIVATE mergehead := {}
   PRIVATE sumarr := {}
   PRIVATE totalarr := {}
   PRIVATE spread := .f.

   DEFAULT fontsize := 12
   DEFAULT orientation := "P"
   DEFAULT fontname1 := "Arial"
   DEFAULT aheaders := {"","",""}
   DEFAULT ShowWindow1 := .f.
   DEFAULT mheaders := {}
   DEFAULT summation := {}

   showwindow := showwindow1

   msgarr := _initprintgridmessages()

   DO CASE
   CASE len(aheaders) == 3
      header1 := aheaders[1]
      header2 := aheaders[2]
      header3 := aheaders[3]
   CASE len(aheaders) == 2
      header1 := aheaders[1]
      header2 := aheaders[2]
   CASE len(aheaders) == 1
      header1 := aheaders[1]
   ENDCASE
   IF len(mheaders) > 0 .and. valtype(mheaders) == "A"
      mergehead := mheaders
   ENDIF
   IF len(summation) > 0 .and. valtype(summation) == "A"
      sumarr := summation

   ENDIF

   FONTNAME := fontname1
   lines := getproperty(windowname,gridname,"itemcount")
   IF lines == 0
      msginfo(msgarr[1])

      RETURN NIL
   ENDIF

   IF Len(aprinternames) == 0
      msgstop(msgarr[2],msgarr[3])

      RETURN NIL
   ENDIF
   fontsizesstr := {"8","9","10","11","12","14","16","18","20","22","24","26","28","36","48","72"}
   FOR count1 := 1 TO Len(fontsizesstr)
      IF Val(fontsizesstr[count1]) == fontsize
         fontnumber := count1
      ENDIF
   NEXT count1
   IF fontnumber == 0
      fontnumber := 1
   ENDIF
   linedata := getproperty(windowname,gridname,"item",1)
   asize(sizes,0)
   FOR count1 := 1 to len(linedata)
      aadd(sizes,0)
      aadd(headersizes,0)
      aadd(headerarr,getproperty(windowname,gridname,"header",count1))
      aadd(totalarr,0.0)
   NEXT count1

   i := GetControlIndex ( gridname , windowname )

   aJustify := _HMG_aControlMiscData1 [i] [3]

   aEditcontrols := _HMG_aControlMiscData1 [i] [13]

   FOR count1 := 1 TO Len(headerarr)
      AAdd(columnarr,{1,headerarr[count1],sizes[count1],ajustify[count1]})
   NEXT count1
   FOR count1 := 1 TO Len(aprinternames)
      IF Upper(AllTrim(aprinternames[count1])) == Upper(AllTrim(defaultprinter))
         printerno := count1
         EXIT
      ENDIF
   NEXT count1
   IF printerno == 0
      printerno := 1
   ENDIF

   IF len(sumarr) > 0
      FOR i := 1 to len(sumarr)
         aadd(_asum,0.0)
      NEXT i
      FOR count1 := 1 to lines
         linedata := getproperty(windowname,gridname,"item",count1)
         FOR count2 := 1 to len(linedata)
            IF sumarr[count2,1]
               DO CASE
               CASE ValType(linedata[count2]) == "N"
                  xres := _PARSEGRIDCONTROLS ( AEDITCONTROLS , count2 )
                  AEC := XRES [1]
                  AITEMS := XRES [5]
                  IF AEC == 'COMBOBOX'
                     cPrintdata := aitems[linedata[count2]]
                  ELSE
                     cPrintdata := LTrim( Str( linedata[count2] ) )
                  ENDIF
               CASE ValType(linedata[count2]) == "D"
                  cPrintdata := dtoc( linedata[count2])
               CASE ValType(linedata[count2]) == "L"
                  xres := _PARSEGRIDCONTROLS ( AEDITCONTROLS , count2 )
                  AEC := XRES [1]
                  AITEMS := XRES [8]
                  IF AEC == 'CHECKBOX'
                     cPrintdata := iif(linedata[count2],aitems[1],aitems[2])
                  ELSE
                     cPrintdata := iif(linedata[count2],"T","F")
                  ENDIF
               OTHERWISE
                  cPrintdata := linedata[count2]
               ENDCASE
               _asum[count2] := _asum[count2] + val(stripcomma(cPrintdata,".",","))
            ENDIF
         NEXT count2
      NEXT count1
   ENDIF

   DEFINE WINDOW printgrid at 0,0 width 700 height 440 title msgarr[4] modal nosize nosysmenu on init initprintgrid()
      DEFINE TAB tab1 at 10,10 width 285 height 335
         DEFINE PAGE msgarr[5]
            DEFINE GRID columns
               ROW 30
               COL 10
               WIDTH 270
               HEIGHT 300
               WIDTHS {110,80,60}
               justify {0,1,0}
               HEADERS {msgarr[6],msgarr[7],msgarr[57]}
               allowedit .t.
               COLUMNCONTROLS {{"TEXTBOX","CHARACTER"},{"TEXTBOX","NUMERIC","9999.99"},{"COMBOBOX",{msgarr[59],msgarr[60]}}}
               COLUMNWHEN {{||.f.},{||iif(printgrid.spread.value,.f.,.t.)},{||.t.}}
               columnvalid {{||.t.},{||columnsizeverify()},{||columnselected()}}
               ON LOSTFOCUS refreshprintgrid()
            END GRID
         END PAGE
         DEFINE PAGE msgarr[16]
            DEFINE LABEL header1label
               ROW 30
               COL 10
               WIDTH 100
               VALUE msgarr[12]
            END LABEL
            DEFINE TEXTBOX header1
               ROW 30
               COL 110
               WIDTH 165
               ON CHANGE printgridpreview()
            END TEXTBOX
            DEFINE LABEL header2label
               ROW 70
               COL 10
               WIDTH 100
               VALUE msgarr[13]
            END LABEL
            DEFINE TEXTBOX header2
               ROW 70
               COL 110
               ON CHANGE printgridpreview()
               WIDTH 165
            END TEXTBOX
            DEFINE LABEL header3label
               ROW 100
               COL 10
               WIDTH 100
               VALUE msgarr[14]
            END LABEL
            DEFINE TEXTBOX Header3
               ROW 100
               COL 110
               ON CHANGE printgridpreview()
               WIDTH 165
            END TEXTBOX
            DEFINE LABEL footer1label
               ROW 130
               COL 10
               WIDTH 100
               VALUE msgarr[15]
            END LABEL
            DEFINE TEXTBOX Footer1
               ROW 130
               COL 110
               WIDTH 165
               ON CHANGE printgridpreview()
            END TEXTBOX
            DEFINE LABEL selectfontsizelabel
               ROW 160
               COL 10
               VALUE msgarr[17]
               WIDTH 100
            END LABEL
            DEFINE COMBOBOX selectfontsize
               ROW 160
               COL 110
               WIDTH 50
               items fontsizesstr
               ON CHANGE fontsizechanged()
            END COMBOBOX
            DEFINE LABEL multilinelabel
               ROW 190
               COL 10
               VALUE msgarr[18]
               WIDTH 100
            END LABEL
            DEFINE COMBOBOX wordwrap
               ROW 190
               COL 110
               WIDTH 90
               items {msgarr[19],msgarr[20]}
               ON CHANGE printgridpreview()
            END COMBOBOX
            DEFINE LABEL pagination
               ROW 220
               COL 10
               VALUE msgarr[21]
               WIDTH 100
            END LABEL
            DEFINE COMBOBOX pageno
               ROW 220
               COL 110
               WIDTH 90
               items {msgarr[22],msgarr[23],msgarr[24]}
               ON CHANGE printgridpreview()
            END COMBOBOX
            DEFINE LABEL separatorlab
               ROW 255
               COL 10
               WIDTH 100
               VALUE msgarr[25]
            END LABEL
            DEFINE CHECKBOX collines
               ROW 250
               COL 110
               WIDTH 70
               ON CHANGE printgridpreview()
               CAPTION msgarr[26]
            END CHECKBOX
            DEFINE CHECKBOX rowlines
               ROW 250
               COL 180
               WIDTH 50
               ON CHANGE printgridpreview()
               CAPTION msgarr[27]
            END CHECKBOX
            DEFINE LABEL centerlab
               ROW 280
               COL 10
               WIDTH 100
               VALUE msgarr[28]
            END LABEL
            DEFINE CHECKBOX vertical
               ROW 275
               COL 110
               WIDTH 60
               ON CHANGE printgridpreview()
               CAPTION msgarr[29]
            END CHECKBOX
            DEFINE LABEL spacelab
               ROW 305
               COL 10
               WIDTH 100
               HEIGHT 20
               VALUE msgarr[54]
            END LABEL
            DEFINE CHECKBOX spread
               ROW 305
               COL 110
               WIDTH 60
               HEIGHT 20
               ON CHANGE spreadchanged()
               CAPTION msgarr[55]
            END CHECKBOX
         END PAGE
         DEFINE PAGE msgarr[30]
            DEFINE LABEL orientationlabel
               ROW 30
               COL 10
               VALUE msgarr[31]
               WIDTH 100
            END LABEL
            DEFINE COMBOBOX paperorientation
               ROW 30
               COL 110
               WIDTH 90
               items {msgarr[32],msgarr[33]}
               ON CHANGE papersizechanged()
            END COMBOBOX
            DEFINE LABEL printerslabel
               ROW 60
               COL 10
               WIDTH 100
               VALUE msgarr[34]
            END LABEL
            DEFINE COMBOBOX printers
               ROW 60
               COL 110
               WIDTH 165
               items aprinternames
               VALUE printerno
            END COMBOBOX
            DEFINE LABEL sizelabel
               ROW 90
               COL 10
               WIDTH 100
               VALUE msgarr[35]
            END LABEL
            DEFINE COMBOBOX pagesizes
               ROW 90
               COL 110
               WIDTH 165
               items papernames
               ON CHANGE papersizechanged()
            END COMBOBOX
            DEFINE LABEL widthlabel
               ROW 120
               COL 10
               VALUE msgarr[36]
               WIDTH 100
            END LABEL
            DEFINE TEXTBOX width
               ROW 120
               COL 110
               WIDTH 60
               INPUTMASK "999.99"
               ON CHANGE pagesizechanged()
               NUMERIC .t.
               RIGHTALIGN .t.
            END TEXTBOX
            DEFINE LABEL widthmm
               ROW 120
               COL 170
               VALUE "mm"
               WIDTH 25
            END LABEL
            DEFINE LABEL heightlabel
               ROW 150
               COL 10
               VALUE msgarr[37]
               WIDTH 100
            END LABEL
            DEFINE TEXTBOX height
               ROW 150
               COL 110
               WIDTH 60
               INPUTMASK "999.99"
               ON CHANGE pagesizechanged()
               NUMERIC .t.
               RIGHTALIGN .t.
            END TEXTBOX
            DEFINE LABEL heightmm
               ROW 150
               COL 170
               VALUE "mm"
               WIDTH 25
            END LABEL
            DEFINE FRAME margins
               ROW 180
               COL 5
               WIDTH 185
               HEIGHT 80
               CAPTION msgarr[38]
            END FRAME
            DEFINE LABEL toplabel
               ROW 200
               COL 10
               WIDTH 35
               VALUE msgarr[39]
            END LABEL
            DEFINE TEXTBOX top
               ROW 200
               COL 45
               WIDTH 50
               INPUTMASK "99.99"
               NUMERIC .t.
               ON CHANGE printgridpreview()
               RIGHTALIGN .t.
            END TEXTBOX
            DEFINE LABEL rightlabel
               ROW 200
               COL 100
               WIDTH 35
               VALUE msgarr[40]
            END LABEL
            DEFINE TEXTBOX right
               ROW 200
               COL 135
               WIDTH 50
               INPUTMASK "99.99"
               ON CHANGE papersizechanged()
               NUMERIC .t.
               RIGHTALIGN .t.
            END TEXTBOX
            DEFINE LABEL leftlabel
               ROW 230
               COL 10
               WIDTH 35
               VALUE msgarr[41]
            END LABEL
            DEFINE TEXTBOX left
               ROW 230
               COL 45
               WIDTH 50
               INPUTMASK "99.99"
               ON CHANGE papersizechanged()
               NUMERIC .t.
               RIGHTALIGN .t.
            END TEXTBOX
            DEFINE LABEL bottomlabel
               ROW 230
               COL 100
               WIDTH 35
               VALUE msgarr[42]
            END LABEL
            DEFINE TEXTBOX bottom
               ROW 230
               COL 135
               WIDTH 50
               INPUTMASK "99.99"
               NUMERIC .t.
               ON CHANGE printgridpreview()
               RIGHTALIGN .t.
            END TEXTBOX
         END PAGE
         DEFINE PAGE msgarr[61]
            DEFINE GRID merge
               ROW 30
               COL 10
               WIDTH 240
               HEIGHT 240
               HEADERS {msgarr[62],msgarr[63],msgarr[64]}
               WIDTHS {50,50,100}
               allowedit .t.
               COLUMNCONTROLS {{"TEXTBOX","NUMERIC","999"},{"TEXTBOX","NUMERIC","999"},{"TEXTBOX","CHARACTER"}}
               columnvalid {{||.t.},{||.t.},{||.t.}}
               ON LOSTFOCUS mergeheaderschanged()
            END GRID
            DEFINE BUTTON add
               ROW 30
               COL 260
               WIDTH 20
               HEIGHT 20
               CAPTION "+"
               FONTBOLD .t.
               fontsize 16
               ACTION addmergeheadrow()
            END BUTTON
            DEFINE BUTTON del
               ROW 55
               COL 260
               WIDTH 20
               HEIGHT 20
               CAPTION "-"
               FONTBOLD .t.
               fontsize 16
               ACTION delmergeheadrow()
            END BUTTON

         END PAGE
      END TAB
      DEFINE BUTTON browseprint1
         ROW 350
         COL 160
         CAPTION msgarr[43]
         ACTION printstart()
         WIDTH 80
      END BUTTON
      DEFINE BUTTON browseprintcancel
         ROW 350
         COL 260
         CAPTION msgarr[44]
         ACTION printgrid.release
         WIDTH 80
      END BUTTON
      DEFINE BUTTON browseprintreset
         ROW 350
         COL 360
         CAPTION msgarr[66]
         ACTION resetprintgridform()
         WIDTH 80
      END BUTTON
      DEFINE STATUSBAR
         statusitem msgarr[45] width 200
         statusitem msgarr[10] + "mm "+msgarr[11]+"mm" width 300
      END STATUSBAR
   END WINDOW
   printgrid.selectfontsize.value := fontnumber
   printgrid.spread.value := .t.
   printgrid.pagesizes.value := curpagesize
   printgrid.top.value := 20.0
   printgrid.right.value := 20.0
   printgrid.bottom.value := 20.0
   printgrid.left.value := 20.0
   printgrid.collines.value := .t.
   printgrid.rowlines.value := .t.
   printgrid.header1.value := header1
   printgrid.header2.value := header2
   printgrid.header3.value := header3
   printgrid.wordwrap.value := 2
   printgrid.pageno.value := 2
   printgrid.vertical.value := .t.
   printgrid.paperorientation.value := IIf(orientation == "P",2,1)

   FOR count1 := 1 to len(mergehead)
      IF mergehead[count1,2] >= mergehead[count1,1] .and. iif(count1 > 1,mergehead[count1,1] > mergehead[count1-1,2],.t.)
         printgrid.merge.additem({mergehead[count1,1],mergehead[count1,2],mergehead[count1,3]})
      ENDIF
   NEXT count1
   IF printgrid.merge.itemcount > 0
      printgrid.merge.value := 1
   ENDIF

   IF printgrid.pagesizes.value > 0
      IF printgrid.paperorientation.value == 2 //portrait
         printgrid.width.value := papersizes[printgrid.pagesizes.value,1]
         printgrid.height.value := papersizes[printgrid.pagesizes.value,2]
      ELSE // landscape
         printgrid.width.value := papersizes[printgrid.pagesizes.value,2]
         printgrid.height.value := papersizes[printgrid.pagesizes.value,1]
      ENDIF
      maxcol2 := printgrid.width.value - printgrid.left.value - printgrid.right.value
      printgrid.statusbar.item(2) := msgarr[10]+" "+alltrim(str(curcol1,12,2))+" "+msgarr[11]+" "+alltrim(str(maxcol2,12,2))
   ENDIF
   IF printgrid.pagesizes.value == printgrid.pagesizes.itemcount // custom
      printgrid.width.readonly := .f.
      printgrid.height.readonly := .f.
   ELSE
      printgrid.width.readonly := .t.
      printgrid.height.readonly := .t.
   ENDIF

   FOR count1 := 1 to len(columnarr)
      printgrid.columns.additem({columnarr[count1,2],columnarr[count1,3],1})
   NEXT count1
   calculatecolumnsizes()
   printcoltally()
   IF printgrid.columns.itemcount > 0
      printgrid.columns.value := 1
   ENDIF
   printgridpreview()
   printgrid.center
   printgrid.activate()

   RETURN NIL

FUNCTION refreshprintgrid

   printcoltally()
   printgridpreview()

   RETURN NIL

FUNCTION spreadchanged

   calculatecolumnsizes()
   refreshprintgrid()

   RETURN NIL

FUNCTION initprintgrid

   IF .not. showwindow
      IF printgrid.browseprint1.enabled
         printstart()
      ELSE
         printgridinit()
      ENDIF
   ELSE
      printgridinit()
   ENDIF

   RETURN NIL

FUNCTION printcoltally

   LOCAL col := 0
   LOCAL count1 := 0
   LOCAL count2 := 0
   LOCAL totcol := 0.0

   IF .not. iscontroldefined(browseprintcancel,printgrid)

      RETURN NIL
   ENDIF
   IF printgrid.spread.value
      FOR count1 := 1 to Len(columnarr)
         IF columnarr[count1,1] == 1
            COL := col + max(sizes[count1],headersizes[count1]) + 2 // 2 mm for column separation
            count2 := count2 + 1
         ENDIF
      NEXT count1
      IF col < maxcol2
         totcol := col - (count2 * 2)
         FOR count1 := 1 to len(columnarr)
            IF columnarr[count1,1] == 1
               columnarr[count1,3] := (maxcol2 - (count2 *2) - 5) * max(sizes[count1],headersizes[count1]) / totcol
            ENDIF
         NEXT count1
         COL := maxcol2 - 5
      ENDIF
   ELSE
      FOR count1 := 1 to Len(columnarr)
         IF columnarr[count1,1] == 1
            COL := col + columnarr[count1,3] + 2 // 2 mm for column separation
            count2 := count2 + 1
         ENDIF
      NEXT count1
   ENDIF
   curcol1 := col
   printgrid.statusbar.item(2) := msgarr[10]+" "+alltrim(str(curcol1,12,2))+" "+msgarr[11]+" "+alltrim(str(maxcol2,12,2))

   IF maxcol2 >= curcol1
      printgrid.browseprint1.enabled := .t.
      printgrid.statusbar.item(1) := msgarr[45]
   ELSE
      printgrid.statusbar.item(1) := msgarr[46]
      printgrid.browseprint1.enabled := .f.

      RETURN NIL
   ENDIF
   FOR count1 := 1 to len(columnarr)
      printgrid.columns.item(count1) := {columnarr[count1,2],columnarr[count1,3],columnarr[count1,1]}
   NEXT count1

   RETURN NIL

FUNCTION fontsizechanged

   calculatecolumnsizes()
   refreshprintgrid()

   RETURN NIL

FUNCTION calculatecolumnsizes

   LOCAL fontsize1 := 0
   LOCAL cPrintdata := ""
   LOCAL count1 := 0
   LOCAL count2 := 0
   LOCAL aec := ""
   LOCAL aitems := {}

   IF .not. iscontroldefined(browseprintcancel,printgrid)

      RETURN NIL
   ENDIF
   fontsize1 := val(alltrim(printgrid.selectfontsize.item(printgrid.selectfontsize.value)))
   IF fontsize1 > 0
      linedata := getproperty(windowname,gridname,"item",1)
      asize(sizes,0)
      asize(headersizes,0)
      FOR count1 := 1 to len(linedata)
         aadd(sizes,0)
         aadd(headersizes,0)
      NEXT count1
      FOR count1 := 1 to lines
         linedata := getproperty(windowname,gridname,"item",count1)
         FOR count2 := 1 to len(linedata)
            DO CASE
            CASE ValType(linedata[count2]) == "N"
               xres := _PARSEGRIDCONTROLS ( AEDITCONTROLS , count2 )
               AEC := XRES [1]
               AITEMS := XRES [5]
               IF AEC == 'COMBOBOX'
                  cPrintdata := aitems[linedata[count2]]
               ELSE
                  cPrintdata := LTrim( Str( linedata[count2] ) )
               ENDIF
            CASE ValType(linedata[count2]) == "D"
               cPrintdata := dtoc( linedata[count2])
            CASE ValType(linedata[count2]) == "L"
               xres := _PARSEGRIDCONTROLS ( AEDITCONTROLS , count2 )
               AEC := XRES [1]
               AITEMS := XRES [8]
               IF AEC == 'CHECKBOX'
                  cPrintdata := iif(linedata[count2],aitems[1],aitems[2])
               ELSE
                  cPrintdata := iif(linedata[count2],"T","F")
               ENDIF
            OTHERWISE
               cPrintdata := linedata[count2]
            ENDCASE
            sizes[count2] := max(sizes[count2],printlen(alltrim(cPrintdata),fontsize1,fontname))
         NEXT count2
      NEXT count1
      FOR count1 := 1 to len(headerarr)
         headersizes[count1] := printlen(alltrim(headerarr[count1]),fontsize1,fontname)
      NEXT count1
      FOR count1 := 1 TO Len(columnarr)
         IF len(sumarr) > 0
            IF sumarr[count1,1]
               sizes[count1] := max(sizes[count1],printlen(alltrim(transform(_asum[count1],sumarr[count1,2])),fontsize1,fontname))
            ENDIF
         ENDIF
         columnarr[count1,3] := max(sizes[count1],headersizes[count1])
      NEXT count1
   ENDIF

   RETURN NIL

FUNCTION printstart

   LOCAL printername, size, lastrow
   LOCAL startcol, endcol
   LOCAL headdata
   LOCAL printstart, printend
   LOCAL row := 0
   LOCAL col := 0
   LOCAL lh := 0 // line height
   LOCAL pageno := 0
   LOCAL printdata := {}
   LOCAL justifyarr := {}
   LOCAL maxrow1 := 0
   LOCAL maxcol1 := curcol1
   LOCAL maxlines := 0
   LOCAL totrows := getproperty(windowname,gridname,"itemcount")
   LOCAL leftspace := 0
   LOCAL rightspace := 0
   LOCAL firstrow := 0
   LOCAL size1 := 0
   LOCAL data1 := ""
   LOCAL paperwidth := printgrid.width.value
   LOCAL paperheight := printgrid.height.value
   LOCAL totcols := 0
   LOCAL papersize := 0
   LOCAL sizesarr := {}
   LOCAL totcol := 0
   LOCAL colcount := 0
   LOCAL colreqd
   LOCAL nextline := {}
   LOCAL nextcount := 0
   LOCAL count1 := 0
   LOCAL count2 := 0
   LOCAL count3 := 0
   LOCAL count4 := 0
   LOCAL count5 := 0
   LOCAL count6 := 0
   LOCAL count7 := 0
   LOCAL dataprintover := .t.
   LOCAL cPrintdata := ""
   LOCAL aec := ""
   LOCAL aitems := {}
   LOCAL gridprintdata := array(20)

   IF printgrid.printers.value > 0
      printername := AllTrim(printgrid.printers.item(printgrid.printers.value))
   ELSE
      msgstop(msgarr[47],msgarr[3])

      RETURN NIL
   ENDIF

   DO CASE
   CASE printgrid.pagesizes.value == 1 //letter
      papersize := PRINTER_PAPER_LETTER
   CASE printgrid.pagesizes.value == 2 //legal
      papersize := PRINTER_PAPER_LEGAL
   CASE printgrid.pagesizes.value == 3 //executive
      papersize := PRINTER_PAPER_EXECUTIVE
   CASE printgrid.pagesizes.value == 4 //A3
      papersize := PRINTER_PAPER_A3
   CASE printgrid.pagesizes.value == 5 //A4
      papersize := PRINTER_PAPER_A4
   CASE printgrid.pagesizes.value == 6 //Custom
      papersize := PRINTER_PAPER_USER
   ENDCASE

   IF printgrid.pagesizes.value == 6 // custom
      SELECT PRINTER printername TO psuccess ORIENTATION IIf(printgrid.paperorientation.value == 1,PRINTER_ORIENT_LANDSCAPE,PRINTER_ORIENT_PORTRAIT);
         PAPERSIZE papersize;
         PAPERLENGTH iif(printgrid.paperorientation.value == 1,printgrid.width.value,printgrid.height.value);
         PAPERWIDTH iif(printgrid.paperorientation.value == 1,printgrid.height.value,printgrid.width.value);
         COPIES 1;
         PREVIEW
   ELSE
      SELECT PRINTER printername TO psuccess ORIENTATION IIf(printgrid.paperorientation.value == 1,PRINTER_ORIENT_LANDSCAPE,PRINTER_ORIENT_PORTRAIT);
         PAPERSIZE papersize;
         COPIES 1;
         PREVIEW
   ENDIF
   IF .not. psuccess
      msgstop(msgarr[48],msgarr[3])

      RETURN NIL
   ENDIF

   size1 := val(alltrim(printgrid.selectfontsize.item(printgrid.selectfontsize.value)))

   // Save Config

   BEGIN INI FILE "reports.cfg"
      // columns
      gridprintdata[1] := {}
      FOR count1 := 1 to printgrid.columns.itemcount
         aadd(gridprintdata[1],printgrid.columns.item(count1))
      NEXT count1
      // headers
      gridprintdata[2] := {}
      aadd(gridprintdata[2],printgrid.header1.value)
      aadd(gridprintdata[2],printgrid.header2.value)
      aadd(gridprintdata[2],printgrid.header3.value)
      // footer
      gridprintdata[3] := printgrid.footer1.value
      //fontsize
      gridprintdata[4] := printgrid.selectfontsize.value
      // wordwrap
      gridprintdata[5] := printgrid.wordwrap.value
      // pagination
      gridprintdata[6] := printgrid.pageno.value
      // collines
      gridprintdata[7] := printgrid.collines.value
      // rowlines
      gridprintdata[8] := printgrid.rowlines.value
      // vertical center
      gridprintdata[9] := printgrid.vertical.value
      // space spread
      gridprintdata[10] := printgrid.spread.value
      // orientation
      gridprintdata[11] := printgrid.paperorientation.value
      // printers
      gridprintdata[12] := printgrid.printers.value
      // pagesize
      gridprintdata[13] := printgrid.pagesizes.value
      // paper width
      gridprintdata[14] := printgrid.width.value
      // paper height
      gridprintdata[15] := printgrid.height.value
      // margin top
      gridprintdata[16] := printgrid.top.value
      // margin right
      gridprintdata[17] := printgrid.right.value
      // margin left
      gridprintdata[18] := printgrid.left.value
      // margin bottom
      gridprintdata[19] := printgrid.bottom.value
      // merge headers data
      gridprintdata[20] := {}
      FOR count1 := 1 to printgrid.merge.itemcount
         aadd(gridprintdata[20],printgrid.merge.item(count1))
      NEXT count1
      SET SECTION windowname+"_"+gridname entry "controlname" to windowname+"_"+gridname
      SET SECTION windowname+"_"+gridname entry "gridprintdata1" to gridprintdata[1]
      SET SECTION windowname+"_"+gridname entry "gridprintdata2" to gridprintdata[2]
      SET SECTION windowname+"_"+gridname entry "gridprintdata3" to gridprintdata[3]
      SET SECTION windowname+"_"+gridname entry "gridprintdata4" to gridprintdata[4]
      SET SECTION windowname+"_"+gridname entry "gridprintdata5" to gridprintdata[5]
      SET SECTION windowname+"_"+gridname entry "gridprintdata6" to gridprintdata[6]
      SET SECTION windowname+"_"+gridname entry "gridprintdata7" to gridprintdata[7]
      SET SECTION windowname+"_"+gridname entry "gridprintdata8" to gridprintdata[8]
      SET SECTION windowname+"_"+gridname entry "gridprintdata9" to gridprintdata[9]
      SET SECTION windowname+"_"+gridname entry "gridprintdata10" to gridprintdata[10]
      SET SECTION windowname+"_"+gridname entry "gridprintdata11" to gridprintdata[11]
      SET SECTION windowname+"_"+gridname entry "gridprintdata12" to gridprintdata[12]
      SET SECTION windowname+"_"+gridname entry "gridprintdata13" to gridprintdata[13]
      SET SECTION windowname+"_"+gridname entry "gridprintdata14" to gridprintdata[14]
      SET SECTION windowname+"_"+gridname entry "gridprintdata15" to gridprintdata[15]
      SET SECTION windowname+"_"+gridname entry "gridprintdata16" to gridprintdata[16]
      SET SECTION windowname+"_"+gridname entry "gridprintdata17" to gridprintdata[17]
      SET SECTION windowname+"_"+gridname entry "gridprintdata18" to gridprintdata[18]
      SET SECTION windowname+"_"+gridname entry "gridprintdata19" to gridprintdata[19]
      SET SECTION windowname+"_"+gridname entry "gridprintdata20" to gridprintdata[20]
   END INI

   START PRINTDOC
      ROW := printgrid.top.value
      maxrow1 := printgrid.height.value - printgrid.bottom.value
      IF printgrid.vertical.value
         COL := (printgrid.width.value - curcol1)/2
      ELSE
         COL := printgrid.left.value
      ENDIF
      lh := Int((size1/72 * 25.4)) + 1 // line height
      START PRINTPAGE
         pageno := 1
         IF printgrid.pageno.value == 2
            @ Row,(col+maxcol1 - printlen(msgarr[49]+alltrim(str(pageno,10,0)),size1,fontname) - 5) print msgarr[49]+alltrim(str(pageno,10,0)) font fontname size size1
            ROW := row + lh
         ENDIF
         IF Len(AllTrim(printgrid.header1.value)) > 0
            @ Row+(lh/2),col+Int(maxcol1/2) print AllTrim(printgrid.header1.value) font fontname size size1+2 center
            ROW := row + lh + lh
         ENDIF
         IF Len(AllTrim(printgrid.header2.value)) > 0
            @ Row+(lh/2),col+Int(maxcol1/2) print AllTrim(printgrid.header2.value) font fontname size size1+2 center
            ROW := row + lh + lh
         ENDIF
         IF Len(AllTrim(printgrid.header3.value)) > 0
            @ Row+(lh/2),col+Int(maxcol1/2) print AllTrim(printgrid.header3.value) font fontname size size1+2 center
            ROW := row + lh + lh
         ENDIF

         IF len(mergehead) > 0
            @ Row ,Col-1  print line TO Row ,col+maxcol1-1 penwidth 0.25
            FOR count1 := 1 to len(mergehead)
               startcol := mergehead[count1,1]
               endcol := mergehead[count1,2]
               headdata := mergehead[count1,3]
               printstart := 0
               printend := 0
               FOR count2 := 1 to endcol
                  IF count2 < startcol
                     IF columnarr[count2,1] == 1
                        printstart := printstart + columnarr[count2,3] + 2
                     ENDIF
                  ENDIF
                  IF columnarr[count2,1] == 1
                     printend := printend + columnarr[count2,3] + 2
                  ENDIF
               NEXT count2
               IF printend > printstart
                  IF printLen(AllTrim(headdata),size1,fontname) > (printend - printstart)
                     count3 := len(headdata)
                     DO WHILE printlen(substr(headdata,1,count3),size1,fontname) > (printend - printstart)
                        count3 := count3 - 1
                     ENDDO
                  ENDIF
                  @ Row,col+printstart+int((printend-printstart)/2) print headdata font fontname size size1 center
                  @ Row+lh,col-1+printstart print line TO Row+lh ,col-1+printend penwidth 0.25
               ENDIF
            NEXT count1
            @ row,col-1 print line to row+lh,col-1 penwidth 0.25
            @ row,col-1+maxcol1 print line to row+lh,col-1+maxcol1 penwidth 0.25
            IF printgrid.collines.value
               colcount := 0
               FOR count2 := 1 to len(columnarr)
                  IF columnarr[count2,1] == 1
                     totcol := totcol + columnarr[count2,3]
                     colcount := colcount + 1
                     colreqd := .t.
                     FOR count3 := 1 to len(mergehead)
                        startcol := mergehead[count3,1]
                        endcol := mergehead[count3,2]
                        IF count2 >= startcol
                           IF count2 < endcol
                              IF columnarr[endcol,1] == 1
                                 colreqd := .f.
                              ELSE
                                 FOR count7 := count2+1 to endcol
                                    IF columnarr[count7,1] == 1
                                       colreqd := .f.
                                    ENDIF
                                 NEXT count7
                              ENDIF
                           ELSE
                              colreqd := .t.
                           ENDIF
                        ENDIF
                     NEXT count3
                     IF colreqd
                        @ row,col+totcol+(colcount * 2)-1 print line TO row+lh,col+totcol+(colcount * 2)-1 penwidth 0.25
                     ENDIF
                  ENDIF
               NEXT count2
            ENDIF
            ROW := row + lh
         ELSE
            @ Row ,Col-1  print line TO Row ,col+maxcol1-1 penwidth 0.25
         ENDIF

         firstrow := Row

         ASize(printdata,0)
         ASize(justifyarr,0)
         asize(sizesarr,0)
         FOR count1 := 1 TO Len(columnarr)
            IF columnarr[count1,1] == 1
               size := columnarr[count1,3]
               data1 := columnarr[count1,2]
               IF printLen(AllTrim(data1),size1,fontname) <= size
                  AAdd(printdata,alltrim(data1))
               ELSE // header size bigger than column! to be truncated.
                  count2 := len(data1)
                  DO WHILE printlen(substr(data1,1,count2),size1,fontname) > size
                     count2 := count2 - 1
                  ENDDO
                  AAdd(printdata,substr(data1,1,count2))
               ENDIF
               AAdd(justifyarr,columnarr[count1,4])
               aadd(sizesarr,columnarr[count1,3])
            ENDIF
         NEXT count1
         printline(row,col,printdata,justifyarr,sizesarr,fontname,size1)
         ROW := row + lh
         @ Row,Col-1 print line TO Row,col+maxcol1-1 penwidth 0.25
         FOR count1 := 1 TO totrows
            linedata := getproperty(windowname,gridname,"item",count1)
            ASize(printdata,0)
            asize(nextline,0)
            FOR count2 := 1 TO Len(columnarr)
               IF columnarr[count2,1] == 1
                  size := columnarr[count2,3]
                  DO CASE
                  CASE ValType(linedata[count2]) == "N"
                     xres := _PARSEGRIDCONTROLS ( AEDITCONTROLS , count2 )
                     AEC := XRES [1]
                     AITEMS := XRES [5]
                     IF AEC == 'COMBOBOX'
                        cPrintdata := aitems[linedata[count2]]
                     ELSE
                        cPrintdata := LTrim( Str( linedata[count2] ) )
                     ENDIF
                  CASE ValType(linedata[count2]) == "D"
                     cPrintdata := dtoc( linedata[count2])
                  CASE ValType(linedata[count2]) == "L"
                     xres := _PARSEGRIDCONTROLS ( AEDITCONTROLS , count2 )
                     AEC := XRES [1]
                     AITEMS := XRES [8]
                     IF AEC == 'CHECKBOX'
                        cPrintdata := iif(linedata[count2],aitems[1],aitems[2])
                     ELSE
                        cPrintdata := iif(linedata[count2],"T","F")
                     ENDIF
                  OTHERWISE
                     cPrintdata := linedata[count2]
                  ENDCASE
                  IF len(sumarr) > 0
                     IF sumarr[count2,1]
                        cPrintdata := transform(val(stripcomma(cPrintdata,".",",")),sumarr[count2,2])
                     ENDIF
                  ENDIF
                  data1 := cPrintdata
                  IF len(sumarr) > 0
                     IF sumarr[count2,1]
                        totalarr[count2] := totalarr[count2] + val(stripcomma(cPrintdata,".",","))
                     ENDIF
                  ENDIF
                  IF printLen(AllTrim(data1),size1,fontname) <= size
                     aadd(printdata,alltrim(data1))
                     aadd(nextline,0)
                  ELSE  // truncate or wordwrap!
                     IF printgrid.wordwrap.value == 2 // truncate
                        count3 := len(data1)
                        DO WHILE printlen(substr(data1,1,count3),size1,fontname) > size
                           count3 := count3 - 1
                        ENDDO
                        AAdd(printdata,substr(data1,1,count3))
                        aadd(nextline,0)
                     ELSE // wordwrap
                        count3 := len(data1)
                        DO WHILE printlen(substr(data1,1,count3),size1,fontname) > size
                           count3 := count3 - 1
                        ENDDO
                        data1 := substr(data1,1,count3)
                        IF rat(" ",data1) > 0
                           count3 := rat(" ",data1)
                        ENDIF
                        AAdd(printdata,substr(data1,1,count3))
                        aadd(nextline,count3)
                     ENDIF
                  ENDIF
               ENDIF
            NEXT count2
            printline(row,col,printdata,justifyarr,sizesarr,fontname,size1,lh)
            ROW := Row + lh
            dataprintover := .t.
            FOR count2 := 1 to len(nextline)
               IF nextline[count2] > 0
                  dataprintover := .f.
               ENDIF
            NEXT count2
            DO WHILE .not. dataprintover
               ASize(printdata,0)
               FOR count2 := 1 to len(columnarr)
                  IF columnarr[count2,1] == 1
                     size := columnarr[count2,3]
                     data1 := linedata[count2]
                     IF nextline[count2] > 0 //there is some next line
                        data1 := substr(data1,nextline[count2]+1,len(data1))
                        IF printLen(AllTrim(data1),size1,fontname) <= size
                           aadd(printdata,alltrim(data1))
                           nextline[count2] := 0
                        ELSE // there are further lines!
                           count3 := len(data1)
                           DO WHILE printlen(substr(data1,1,count3),size1,fontname) > size
                              count3 := count3 - 1
                           ENDDO
                           data1 := substr(data1,1,count3)
                           IF rat(" ",data1) > 0
                              count3 := rat(" ",data1)
                           ENDIF
                           AAdd(printdata,substr(data1,1,count3))
                           nextline[count2] := nextline[count2]+count3
                        ENDIF
                     ELSE
                        AAdd(printdata,"")
                        nextline[count2] := 0
                     ENDIF
                  ENDIF
               NEXT count2
               printline(row,col,printdata,justifyarr,sizesarr,fontname,size1,lh)
               ROW := Row + lh
               dataprintover := .t.
               FOR count2 := 1 to len(nextline)
                  IF nextline[count2] > 0
                     dataprintover := .f.
                  ENDIF
               NEXT count2
            ENDDO

            IF Row+iif(len(sumarr)>0,(3*lh),lh)+iif(len(alltrim(printgrid.footer1.value))>0,lh,0) >= maxrow1 // 2 lines for total & 1 line for footer
               @ Row,Col-1 print line TO Row,col+maxcol1-1  penwidth 0.25
               IF len(sumarr) > 0
                  ROW := row + lh
                  @ Row,Col-1 print line TO Row,col+maxcol1-1  penwidth 0.25
                  ASize(printdata,0)
                  FOR count5 := 1 TO Len(columnarr)
                     IF columnarr[count5,1] == 1
                        size := columnarr[count5,3]
                        IF sumarr[count5,1]
                           cPrintdata := alltrim(transform(totalarr[count5],sumarr[count5,2]))
                        ELSE
                           cPrintdata := ""
                        ENDIF
                        aadd(printdata,alltrim(cPrintdata))
                     ENDIF
                  NEXT count5
                  printline(row,col,printdata,justifyarr,sizesarr,fontname,size1,lh)
                  ROW := Row + lh
                  @ Row,Col-1 print line TO Row,col+maxcol1-1  penwidth 0.25
               ELSE
                  @ Row,Col-1 print line TO Row,col+maxcol1-1  penwidth 0.25
               ENDIF
               lastrow := Row
               totcol := 0
               @ firstrow,Col-1 print line TO lastrow,Col-1  penwidth 0.25
               IF printgrid.collines.value
                  colcount := 0
                  FOR count2 := 1 to len(columnarr)
                     IF columnarr[count2,1] == 1
                        totcol := totcol + columnarr[count2,3]
                        colcount := colcount + 1
                        @ firstrow,col+totcol+(colcount * 2)-1 print line TO lastrow,col+totcol+(colcount * 2)-1 penwidth 0.25
                     ENDIF
                  NEXT count2
               ENDIF
               @ firstrow,col+maxcol1-1 print line TO lastrow,col+maxcol1-1 penwidth 0.25
               IF Len(AllTrim(printgrid.footer1.value)) > 0
                  @ Row+(lh/2),col+Int(maxcol1/2) print AllTrim(printgrid.footer1.value) font fontname size size1+2 center
                  ROW := row + lh + lh
               ENDIF
               IF printgrid.pageno.value == 3
                  ROW := Row + lh
                  @ Row,(col+maxcol1 - printlen(msgarr[49]+alltrim(str(pageno,10,0)),size1,fontname) - 5) print msgarr[49]+alltrim(str(pageno,10,0)) font fontname size size1
               ENDIF
            END PRINTPAGE
            pageno := pageno + 1
            ROW := printgrid.top.value
            START PRINTPAGE
               IF printgrid.pageno.value == 2
                  @ Row,(col+maxcol1 - printlen(msgarr[49]+alltrim(str(pageno,10,0)),size1,fontname) - 5) print msgarr[49]+alltrim(str(pageno,10,0)) font fontname size size1
                  ROW := row + lh
               ENDIF
               IF Len(AllTrim(printgrid.header1.value)) > 0
                  @ Row+(lh/2),col+Int(maxcol1/2) print AllTrim(printgrid.header1.value) font fontname size size1+2 center
                  ROW := row + lh + lh
               ENDIF
               IF Len(AllTrim(printgrid.header2.value)) > 0
                  @ Row+(lh/2),col+Int(maxcol1/2) print AllTrim(printgrid.header2.value) font fontname size size1+2 center
                  ROW := row + lh + lh
               ENDIF
               IF Len(AllTrim(printgrid.header3.value)) > 0
                  @ Row+(lh/2),col+Int(maxcol1/2) print AllTrim(printgrid.header3.value) font fontname size size1+2 center
                  ROW := row + lh + lh
               ENDIF
               IF len(mergehead) > 0
                  @ Row ,Col-1  print line TO Row ,col+maxcol1-1 penwidth 0.25
                  FOR count4 := 1 to len(mergehead)
                     startcol := mergehead[count4,1]
                     endcol := mergehead[count4,2]
                     headdata := mergehead[count4,3]
                     printstart := 0
                     printend := 0
                     FOR count5 := 1 to endcol
                        IF count5 < startcol
                           IF columnarr[count5,1] == 1
                              printstart := printstart + columnarr[count5,3] + 2
                           ENDIF
                        ENDIF
                        IF columnarr[count5,1] == 1
                           printend := printend + columnarr[count5,3] + 2
                        ENDIF
                     NEXT count5
                     IF printend > printstart
                        IF printLen(AllTrim(headdata),size1,fontname) > (printend - printstart)
                           count6 := len(headdata)
                           DO WHILE printlen(substr(headdata,1,count6),size1,fontname) > (printend - printstart)
                              count6 := count6 - 1
                           ENDDO
                        ENDIF
                        @ Row,col+printstart+int((printend-printstart)/2) print headdata font fontname size size1 center
                        @ Row+lh,col-1+printstart print line TO Row+lh ,col-1+printend penwidth 0.25
                     ENDIF
                  NEXT count4
                  @ row,col-1 print line to row+lh,col-1 penwidth 0.25
                  @ row,col-1+maxcol1 print line to row+lh,col-1+maxcol1 penwidth 0.25
                  totcol := 0
                  IF printgrid.collines.value
                     colcount := 0
                     FOR count5 := 1 to len(columnarr)
                        IF columnarr[count5,1] == 1
                           totcol := totcol + columnarr[count5,3]
                           colcount := colcount + 1
                           colreqd := .t.
                           FOR count6 := 1 to len(mergehead)
                              startcol := mergehead[count6,1]
                              endcol := mergehead[count6,2]
                              IF count5 >= startcol
                                 IF count5 < endcol
                                    IF columnarr[endcol,1] == 1
                                       colreqd := .f.
                                    ELSE
                                       FOR count7 := (count5) + 1 to endcol
                                          IF columnarr[count7,1] == 1
                                             colreqd := .f.
                                          ENDIF
                                       NEXT count7
                                    ENDIF
                                 ELSE
                                    colreqd := .t.
                                 ENDIF
                              ENDIF
                           NEXT count6
                           IF colreqd
                              @ row,col+totcol+(colcount * 2)-1 print line TO row+lh,col+totcol+(colcount * 2)-1 penwidth 0.25
                           ENDIF
                        ENDIF
                     NEXT count5
                  ENDIF
                  ROW := row + lh
               ELSE
                  @ Row ,Col-1  print line TO Row ,col+maxcol1-1 penwidth 0.25
               ENDIF
               firstrow := Row
               ASize(printdata,0)
               ASize(justifyarr,0)
               asize(sizesarr,0)
               FOR count2 := 1 TO Len(columnarr)
                  IF columnarr[count2,1] == 1
                     size := columnarr[count2,3]
                     data1 := columnarr[count2,2]
                     IF printLen(AllTrim(data1),size1,fontname) <= size
                        AAdd(printdata,alltrim(data1))
                     ELSE // header size bigger than column! truncated as of now.
                        count3 := len(data1)
                        DO WHILE printlen(substr(data1,1,count3),size1,fontname) > size
                           count3 := count3 - 1
                        ENDDO
                        AAdd(printdata,substr(data1,1,count3))
                     ENDIF
                     AAdd(justifyarr,columnarr[count2,4])
                     aadd(sizesarr,columnarr[count2,3])
                  ENDIF
               NEXT count2
               printline(row,col,printdata,justifyarr,sizesarr,fontname,size1)
               ROW := row + lh
               @ Row,Col-1 print line TO Row,col+maxcol1-1 penwidth 0.25
               IF len(sumarr) > 0
                  ASize(printdata,0)
                  FOR count5 := 1 TO Len(columnarr)
                     IF columnarr[count5,1] == 1
                        size := columnarr[count5,3]
                        IF sumarr[count5,1]
                           cPrintdata := alltrim(transform(totalarr[count5],sumarr[count5,2]))
                        ELSE
                           cPrintdata := ""
                        ENDIF
                        aadd(printdata,alltrim(cPrintdata))
                     ENDIF
                  NEXT count5
                  printline(row,col,printdata,justifyarr,sizesarr,fontname,size1,lh)
                  ROW := Row + lh
                  @ Row,Col-1 print line TO Row,col+maxcol1-1  penwidth 0.25
                  ROW := Row + lh
                  @ Row,Col-1 print line TO Row,col+maxcol1-1  penwidth 0.25
               ENDIF
            ELSE
               IF printgrid.rowlines.value
                  @ Row,Col-1 print line TO Row,col+maxcol1-1 penwidth 0.25
               ENDIF
            ENDIF
         NEXT count1
         @ Row,Col-1 print line TO Row,col+maxcol1-1 penwidth 0.25
         IF len(sumarr) > 0
            ASize(printdata,0)
            FOR count5 := 1 TO Len(columnarr)
               IF columnarr[count5,1] == 1
                  size := columnarr[count5,3]
                  IF sumarr[count5,1]
                     cPrintdata := alltrim(transform(totalarr[count5],sumarr[count5,2]))
                  ELSE
                     cPrintdata := ""
                  ENDIF
                  aadd(printdata,alltrim(cPrintdata))
               ENDIF
            NEXT count5
            printline(row,col,printdata,justifyarr,sizesarr,fontname,size1,lh)
            ROW := Row + lh
            @ Row,Col-1 print line TO Row,col+maxcol1-1  penwidth 0.25
         ENDIF
         lastrow := Row
         totcol := 0
         colcount := 0
         @ firstrow,Col-1 print line TO lastrow,Col-1 penwidth 0.25
         IF printgrid.collines.value
            FOR count1 := 1 to len(columnarr)
               IF columnarr[count1,1] == 1
                  totcol := totcol + columnarr[count1,3]
                  colcount := colcount + 1
                  @ firstrow,col+totcol+(colcount * 2)-1 print line TO lastrow,col+totcol+(colcount * 2)-1 penwidth 0.25
               ENDIF
            NEXT count2
         ENDIF
         @ firstrow,col+maxcol1-1 print line TO lastrow,col+maxcol1-1 penwidth 0.25

         IF Len(AllTrim(printgrid.footer1.value)) > 0
            @ Row+(lh/2),col+Int(maxcol1/2) print AllTrim(printgrid.footer1.value) font fontname size size1+2 center
            ROW := row + lh + lh
         ENDIF
         IF printgrid.pageno.value == 3
            ROW := Row + lh
            @ Row,(col+maxcol1 - printlen(msgarr[49]+alltrim(str(pageno,10,0)),size1,fontname) - 5) print msgarr[49]+alltrim(str(pageno,10,0)) font fontname size size1
         ENDIF
      END PRINTPAGE
   END PRINTDOC
   IF iswindowactive(printgrid)
      printgrid.release
   ENDIF

   RETURN NIL

FUNCTION printgridtoggle

   LOCAL lineno := printgrid.columns.value

   IF this.cellvalue == 1
      columnarr[lineno,1] := 1
   ELSE
      IF this.cellvalue == 2
         columnarr[lineno,1] := 2
      ENDIF
   ENDIF
   refreshprintgrid()

   RETURN .t.

FUNCTION editcoldetails

   LOCAL lineno := printgrid.columns.value
   LOCAL columnsize := 0

   IF lineno > 0
      printgrid.size.value := columnarr[lineno,3]
      IF ajustify[lineno] == 0 .or. ajustify[lineno] == 2

         RETURN .t.
      ELSE

         RETURN .f.
         //      msginfo(msgarr[52])
      ENDIF
   ENDIF

   RETURN .f.

FUNCTION printline(row,col,aitems,ajustify,sizesarr,fontname,size1)

   LOCAL tempcol := 0
   LOCAL count1 := 0
   LOCAL njustify

   IF len(aitems) <> len(ajustify)
      msginfo(msgarr[53])
   ENDIF
   tempcol := col
   FOR count1 := 1 to len(aitems)
      njustify := ajustify[count1]
      DO CASE
      CASE njustify == 0 //left
         @ Row,tempcol print aitems[count1] font fontname size size1
      CASE njustify == 1 //right
         @ Row,tempcol+sizesarr[count1] print aitems[count1] font fontname size size1 right
      CASE njustify == 2 // center
         @ Row,tempcol+(sizesarr[count1]/2) print aitems[count1] font fontname size size1 center
      END CASE
      tempcol := tempcol + sizesarr[count1] + 2
   NEXT count1

   RETURN NIL

FUNCTION printLen( cString,fontsize,fontname)

   RETURN round(gettextwidth(Nil,cString,fontname)*0.072/72*25.4*fontsize,2)

FUNCTION pagesizechanged

   IF iscontroldefined(browseprintcancel,printgrid)
      maxcol2 := printgrid.width.value - printgrid.left.value - printgrid.right.value
      printgrid.statusbar.item(2) := msgarr[10]+" "+alltrim(str(curcol1,12,2))+" "+msgarr[11]+" "+alltrim(str(maxcol2,12,2))
      refreshprintgrid()
   ENDIF

   RETURN NIL

FUNCTION papersizechanged

   IF .not. iscontroldefined(browseprintcancel,printgrid)

      RETURN NIL
   ENDIF
   IF printgrid.pagesizes.value > 0
      IF printgrid.paperorientation.value == 2 //portrait
         printgrid.width.value := papersizes[printgrid.pagesizes.value,1]
         printgrid.height.value := papersizes[printgrid.pagesizes.value,2]
      ELSE // landscape
         printgrid.width.value := papersizes[printgrid.pagesizes.value,2]
         printgrid.height.value := papersizes[printgrid.pagesizes.value,1]
      ENDIF
      maxcol2 := printgrid.width.value - printgrid.left.value - printgrid.right.value
      printgrid.statusbar.item(2) := msgarr[10]+" "+alltrim(str(curcol1,12,2))+" "+msgarr[11]+" "+alltrim(str(maxcol2,12,2))
   ENDIF
   IF printgrid.pagesizes.value == printgrid.pagesizes.itemcount // custom
      printgrid.width.readonly := .f.
      printgrid.height.readonly := .f.
   ELSE
      printgrid.width.readonly := .t.
      printgrid.height.readonly := .t.
   ENDIF
   refreshprintgrid()

   RETURN NIL

FUNCTION printgridpreview

   LOCAL startcol, endcol
   LOCAL headdata
   LOCAL printstart, printend
   LOCAL startx := 10
   LOCAL starty := 300
   LOCAL endx := 360
   LOCAL endy := 690
   LOCAL maxwidth := endy - starty - (10 * 2) // 10 for each side
   LOCAL maxheight := endx - startx - (10 * 2)
   LOCAL width := 0.0
   LOCAL height := 0.0
   LOCAL resize := 1
   LOCAL curx := 0
   LOCAL cury := 0
   LOCAL lh := 0 // line height
   LOCAL pageno := 0
   LOCAL printdata := {}
   LOCAL justifyarr := {}
   LOCAL totrows := getproperty(windowname,gridname,"itemcount")
   LOCAL firstrow := 0
   LOCAL lastrow := 0
   LOCAL size := 0
   LOCAL size1 := 0
   LOCAL data1 := ""
   LOCAL sizesarr := {}
   LOCAL totcol := 0
   LOCAL maxrow1 := 0
   LOCAL maxcol1 := 0.0
   LOCAL pl := 0
   LOCAL colcount := 0
   LOCAL colreqd
   LOCAL nextline := {}
   LOCAL count1 := 0
   LOCAL count2 := 0
   LOCAL count3 := 0
   LOCAL count4 := 0
   LOCAL count5 := 0
   LOCAL count6 := 0
   LOCAL count7 := 0
   LOCAL cPrintdata := ""
   LOCAL aec := ""
   LOCAL aitems := {}
   LOCAL dataprintover := .t.

   IF .not. iscontroldefined(browseprintcancel,printgrid)

      RETURN NIL
   ENDIF

   WIDTH := printgrid.width.value
   HEIGHT := printgrid.height.value
   maxcol1 := curcol1

   IF maxwidth >= width .and. maxheight >= height
      resize := 1 // resize not required
   ELSE
      resize := min(maxwidth/width,maxheight/height)
   ENDIF

   curx := startx + (maxheight - (height * resize))/2 + 10
   cury := starty + (maxwidth - (width * resize))/2 + 10
   ERASE WINDOW printgrid
   DRAW RECTANGLE IN WINDOW printgrid AT curx,cury   TO curx + (height * resize),cury + (width * resize) FILLCOLOR {255,255,255}

   size1 := val(alltrim(printgrid.selectfontsize.item(printgrid.selectfontsize.value)))

   maxrow1 := curx + ((printgrid.height.value - printgrid.bottom.value) * resize)
   curx := curx+ (printgrid.top.value * resize)
   maxcol1 := (maxcol1) * resize
   IF printgrid.vertical.value
      cury := cury + ((printgrid.width.value - curcol1)/2 * resize)
   ELSE
      cury := cury + (printgrid.left.value * resize)
   ENDIF

   lh := (Int((size1/72 * 25.4)) + 1) * resize // line height
   pageno := 1
   IF printgrid.pageno.value == 2
      pl := printlen(msgarr[49]+alltrim(str(pageno,10,0)),size1,fontname)*resize
      DRAW LINE in window printgrid at curx,cury+maxcol1 - pl to curx,cury+maxcol1
      curx := curx + lh
   ENDIF
   IF Len(AllTrim(printgrid.header1.value)) > 0
      pl := printlen(AllTrim(printgrid.header1.value),size1,fontname) * resize
      DRAW LINE in window printgrid at curx+(lh/2),cury + ((maxcol1 - pl)/2) to curx+(lh/2),cury + ((maxcol1 - pl)/2) + pl
      curx := curx + lh + lh
   ENDIF
   IF Len(AllTrim(printgrid.header2.value)) > 0
      pl := printlen(AllTrim(printgrid.header2.value),size1,fontname) * resize
      DRAW LINE in window printgrid at curx+(lh/2),cury + ((maxcol1 - pl)/2) to curx+(lh/2),cury + ((maxcol1 - pl)/2) + pl
      curx := curx + lh + lh
   ENDIF
   IF Len(AllTrim(printgrid.header3.value)) > 0
      pl := printlen(AllTrim(printgrid.header3.value),size1,fontname) * resize
      DRAW LINE in window printgrid at curx+(lh/2),cury + ((maxcol1 - pl)/2) to curx+(lh/2),cury + ((maxcol1 - pl)/2) + pl
      curx := curx + lh + lh
   ENDIF

   IF len(mergehead) > 0
      DRAW LINE in window printgrid at curx,cury to curx,cury+maxcol1-(1*resize)
      FOR count1 := 1 to len(mergehead)
         startcol := mergehead[count1,1]
         endcol := mergehead[count1,2]
         headdata := mergehead[count1,3]
         printstart := 0
         printend := 0
         FOR count2 := 1 to endcol
            IF count2 < startcol
               IF columnarr[count2,1] == 1
                  printstart := printstart + columnarr[count2,3] + 2
               ENDIF
            ENDIF
            IF columnarr[count2,1] == 1
               printend := printend + columnarr[count2,3] + 2
            ENDIF
         NEXT count2
         IF printend > printstart
            IF printLen(AllTrim(headdata),size1,fontname) > (printend - printstart)
               count3 := len(headdata)
               DO WHILE printlen(substr(headdata,1,count3),size1,fontname) > (printend - printstart)
                  count3 := count3 - 1
               ENDDO
            ENDIF
            pl := printlen(AllTrim(headdata),size1,fontname)
            DRAW LINE in window printgrid at curx+(lh/2),cury + (printstart * resize) + ((((printend-printstart) - pl)/2)*resize) to curx+(lh/2),cury + (printstart * resize) + ((((printend-printstart) - pl)/2)*resize)+(pl*resize)
            DRAW LINE in window printgrid at curx+lh,cury+(printstart*resize) TO curx+lh,cury+(printend*resize)
         ENDIF
      NEXT count1
      DRAW LINE in window printgrid at curx,cury to curx+lh,cury
      DRAW LINE in window printgrid at curx,cury+maxcol1-(1*resize) to curx+lh,cury+maxcol1-(1*resize)
      IF printgrid.collines.value
         colcount := 0
         FOR count2 := 1 to len(columnarr)
            IF columnarr[count2,1] == 1
               totcol := totcol + columnarr[count2,3]
               colcount := colcount + 1
               colreqd := .t.
               FOR count3 := 1 to len(mergehead)
                  startcol := mergehead[count3,1]
                  endcol := mergehead[count3,2]
                  IF count2 >= startcol
                     IF count2 < endcol
                        IF columnarr[endcol,1] == 1
                           colreqd := .f.
                        ELSE
                           FOR count7 := count2+1 to endcol
                              IF columnarr[count7,1] == 1
                                 colreqd := .f.
                              ENDIF
                           NEXT count7
                        ENDIF
                     ELSE
                        colreqd := .t.
                     ENDIF
                  ENDIF
               NEXT count3
               IF colreqd
                  DRAW LINE in window printgrid at curx,cury-1+((totcol+(colcount * 2)) * resize) to curx+lh,cury-1+((totcol+(colcount * 2)) * resize)
               ENDIF
            ENDIF
         NEXT count2
      ENDIF
      curx := curx + lh
   ELSE
      DRAW LINE in window printgrid at curx,cury to curx,cury+maxcol1-(1*resize)
   ENDIF

   firstrow := curx
   //draw line in window printgrid at curx,cury to curx,cury+maxcol1-(1*resize)
   ASize(printdata,0)
   ASize(justifyarr,0)
   asize(sizesarr,0)
   FOR count1 := 1 TO Len(columnarr)
      IF columnarr[count1,1] == 1
         size := columnarr[count1,3]
         data1 := columnarr[count1,2]
         IF printLen(AllTrim(data1),size1,fontname) <= size
            AAdd(printdata,alltrim(data1))
         ELSE // header size bigger than column! to be truncated.
            count2 := len(data1)
            DO WHILE printlen(substr(data1,1,count2),size1,fontname) > size
               count2 := count2 - 1
            ENDDO
            AAdd(printdata,substr(data1,1,count2))
         ENDIF
         AAdd(justifyarr,columnarr[count1,4])
         aadd(sizesarr,columnarr[count1,3])
      ENDIF
   NEXT count1
   printpreviewline(curx+(lh/2),cury,printdata,justifyarr,sizesarr,fontname,size1,resize)
   curx := curx + lh
   DRAW LINE in window printgrid at curx,cury to curx,cury+maxcol1-(1*resize)
   FOR count1 := 1 TO totrows
      linedata := getproperty(windowname,gridname,"item",count1)
      ASize(printdata,0)
      asize(nextline,0)
      FOR count2 := 1 TO Len(columnarr)
         IF columnarr[count2,1] == 1
            size := columnarr[count2,3]
            DO CASE
            CASE ValType(linedata[count2]) == "N"
               xres := _PARSEGRIDCONTROLS ( AEDITCONTROLS , count2 )
               AEC := XRES [1]
               AITEMS := XRES [5]
               IF AEC == 'COMBOBOX'
                  cPrintdata := aitems[linedata[count2]]
               ELSE
                  cPrintdata := LTrim( Str( linedata[count2] ) )
               ENDIF
            CASE ValType(linedata[count2]) == "D"
               cPrintdata := dtoc( linedata[count2])
            CASE ValType(linedata[count2]) == "L"
               xres := _PARSEGRIDCONTROLS ( AEDITCONTROLS , count2 )
               AEC := XRES [1]
               AITEMS := XRES [8]
               IF AEC == 'CHECKBOX'
                  cPrintdata := iif(linedata[count2],aitems[1],aitems[2])
               ELSE
                  cPrintdata := iif(linedata[count2],"T","F")
               ENDIF
            OTHERWISE
               cPrintdata := linedata[count2]
            ENDCASE
            data1 := cPrintdata
            IF printLen(AllTrim(data1),size1,fontname) <= size
               aadd(printdata,alltrim(data1))
               aadd(nextline,0)
            ELSE
               IF printgrid.wordwrap.value == 2
                  count3 := len(data1)
                  DO WHILE printlen(substr(data1,1,count3),size1,fontname) > size
                     count3 := count3 - 1
                  ENDDO
                  AAdd(printdata,substr(data1,1,count3))
                  aadd(nextline,0)
               ELSE
                  count3 := len(data1)
                  DO WHILE printlen(substr(data1,1,count3),size1,fontname) > size
                     count3 := count3 - 1
                  ENDDO
                  data1 := substr(data1,1,count3)
                  IF rat(" ",data1) > 0
                     count3 := rat(" ",data1)
                  ENDIF
                  AAdd(printdata,substr(data1,1,count3))
                  aadd(nextline,count3)
               ENDIF
            ENDIF
         ENDIF
      NEXT count2
      printpreviewline(curx+(lh/2),cury,printdata,justifyarr,sizesarr,fontname,size1,resize)
      curx := curx + lh
      dataprintover := .t.
      FOR count2 := 1 to len(nextline)
         IF nextline[count2] > 0
            dataprintover := .f.
         ENDIF
      NEXT count2
      DO WHILE .not. dataprintover
         ASize(printdata,0)
         FOR count2 := 1 to len(columnarr)
            IF columnarr[count2,1] == 1
               size := columnarr[count2,3]
               data1 := linedata[count2]
               IF nextline[count2] > 0 //there is some next line
                  data1 := substr(data1,nextline[count2]+1,len(data1))
                  IF printLen(AllTrim(data1),size1,fontname) <= size
                     aadd(printdata,alltrim(data1))
                     nextline[count2] := 0
                  ELSE // there are further lines!
                     count3 := len(data1)
                     DO WHILE printlen(substr(data1,1,count3),size1,fontname) > size
                        count3 := count3 - 1
                     ENDDO
                     data1 := substr(data1,1,count3)
                     IF rat(" ",data1) > 0
                        count3 := rat(" ",data1)
                     ENDIF
                     AAdd(printdata,substr(data1,1,count3))
                     nextline[count2] := nextline[count2]+count3
                  ENDIF
               ELSE
                  AAdd(printdata,"")
                  nextline[count2] := 0
               ENDIF
            ENDIF
         NEXT count2
         printpreviewline(curx+(lh/2),cury,printdata,justifyarr,sizesarr,fontname,size1,resize)
         curx := curx + lh
         dataprintover := .t.
         FOR count2 := 1 to len(nextline)
            IF nextline[count2] > 0
               dataprintover := .f.
            ENDIF
         NEXT count2
      ENDDO

      IF curx+lh >= maxrow1
         DRAW LINE in window printgrid at curx,cury to curx,cury+maxcol1-(1*resize)
         lastrow := curx
         totcol := 0
         DRAW LINE in window printgrid at firstrow,cury to lastrow,cury
         IF printgrid.collines.value
            colcount := 0
            FOR count2 := 1 to len(columnarr)
               IF columnarr[count2,1] == 1
                  colcount := colcount + 1
                  totcol := totcol + columnarr[count2,3]
                  DRAW LINE in window printgrid at firstrow,cury+(totcol+(colcount * 2)-1) * resize to lastrow,cury+(totcol+(colcount * 2)-1) * resize
               ENDIF
            NEXT count2
         ENDIF
         DRAW LINE in window printgrid at firstrow,cury+maxcol1-(1*resize) to lastrow,cury+maxcol1-(1*resize)
         IF Len(AllTrim(printgrid.footer1.value)) > 0
            pl := printlen(AllTrim(printgrid.footer1.value),size1,fontname) * resize
            DRAW LINE in window printgrid at curx+(lh/2),cury + ((maxcol1 - pl)/2) to curx+(lh/2),cury + ((maxcol1 - pl)/2) + pl
            curx := curx + lh + lh
         ENDIF
         IF printgrid.pageno.value == 3
            pl := printlen(msgarr[49]+alltrim(str(pageno,10,0)),size1,fontname)*resize
            DRAW LINE in window printgrid at curx,cury+maxcol1 - pl to curx,cury+maxcol1
            curx := curx + lh
         ENDIF
         count1 := totrows
      ELSE
         IF printgrid.rowlines.value
            DRAW LINE in window printgrid at curx,cury to curx,cury+maxcol1-(1*resize)
         ENDIF
      ENDIF
   NEXT count1
   DRAW LINE in window printgrid at curx,cury to curx,cury+maxcol1-(1*resize)
   lastrow := curx
   totcol := 0
   colcount := 0
   DRAW LINE in window printgrid at firstrow,cury to lastrow,cury
   IF printgrid.collines.value
      FOR count1 := 1 to len(columnarr)
         IF columnarr[count1,1] == 1
            totcol := totcol + columnarr[count1,3]
            colcount := colcount + 1
            DRAW LINE in window printgrid at firstrow,cury+(totcol+(colcount * 2)-1) * resize to lastrow,cury+(totcol+(colcount * 2)-1) * resize
         ENDIF
      NEXT count1
   ENDIF
   DRAW LINE in window printgrid at firstrow,cury+maxcol1-(1*resize) to lastrow,cury+maxcol1-(1*resize)
   IF Len(AllTrim(printgrid.footer1.value)) > 0
      pl := printlen(AllTrim(printgrid.footer1.value),size1,fontname) * resize
      DRAW LINE in window printgrid at curx+(lh/2),cury + ((maxcol1 - pl)/2) to curx+(lh/2),cury + ((maxcol1 - pl)/2) + pl
      curx := curx + lh + lh
   ENDIF
   IF printgrid.pageno.value == 3
      pl := printlen(msgarr[49]+alltrim(str(pageno,10,0)),size1,fontname)*resize
      DRAW LINE in window printgrid at curx,cury+maxcol1 - pl to curx,cury+maxcol1
      curx := curx + lh
   ENDIF

   RETURN NIL

FUNCTION printpreviewline(row,col,aitems,ajustify,sizesarr,fontname,size1,resize)

   LOCAL tempcol := 0
   LOCAL count1 := 0
   LOCAL pl := 0
   LOCAL njustify

   IF len(aitems) <> len(ajustify)
      msginfo(msgarr[53])
   ENDIF
   tempcol := col
   FOR count1 := 1 to len(aitems)
      njustify := ajustify[count1]
      pl := printlen(AllTrim(aitems[count1]),size1,fontname) * resize
      DO CASE
      CASE njustify == 0 //left
         DRAW LINE in window printgrid at row,tempcol to row,tempcol+pl
      CASE njustify == 1 //right
         DRAW LINE in window printgrid at row,tempcol+((sizesarr[count1] + 2) * resize)-pl to row,tempcol+((sizesarr[count1] + 2) * resize)
      CASE njustify == 2 //center not implemented
         DRAW LINE in window printgrid at row,tempcol to row,tempcol+pl
      END CASE
      tempcol := tempcol + ((sizesarr[count1] + 2) * resize)
   NEXT count1

   RETURN NIL

FUNCTION columnsizeverify

   LOCAL lineno := printgrid.columns.value

   IF .not. iscontroldefined(browseprintcancel,printgrid)

      RETURN NIL
   ENDIF
   IF lineno > 0
      IF this.cellvalue >= max(sizes[lineno],headersizes[lineno])
         columnarr[lineno,3] := this.cellvalue

         RETURN .t.
      ELSE
         IF ajustify[lineno] == 1

            RETURN .f.
         ELSE
            columnarr[lineno,3] := this.cellvalue

            RETURN .t.
         ENDIF
      ENDIF
   ENDIF

   RETURN .t.

FUNCTION columnselected

   LOCAL lineno := printgrid.columns.value

   IF .not. iscontroldefined(browseprintcancel,printgrid)

      RETURN NIL
   ENDIF
   IF lineno > 0
      IF this.cellvalue == 1
         columnarr[lineno,1] := 1
      ELSE
         columnarr[lineno,1] := 2
      ENDIF
   ENDIF

   RETURN .t.

   /*
   function columnsumchanged
   local lineno := printgrid.columns.value

   if .not. iscontroldefined(browseprintcancel,printgrid)

   return nil
   endif
   IF lineno > 0
   columnarr[lineno,4] := this.cellvalue
   endif

   return .t.

   function columntypeverify
   LOCAL lineno := printgrid.columns.value

   IF lineno > 0
   if ajustify[lineno] == 0 .or. ajustify[lineno] == 2

   return .f.
   else

   return .t.
   endif
   ENDIF

   return .f.
   */

FUNCTION mergeheaderschanged

   LOCAL count1 := 0
   LOCAL linedetails := {}

   asize(mergehead,0)
   FOR count1 := 1 to printgrid.merge.itemcount
      linedetails := printgrid.merge.item(count1)
      IF linedetails[2] >= linedetails[1] .and. iif((count1 > 1 .and. len(mergehead) > 0),linedetails[1] > mergehead[count1-1,2],.t.)
         aadd(mergehead,{linedetails[1],linedetails[2],linedetails[3]})
      ELSE
         msgstop(msgarr[65]+alltrim(str(count1)))
      ENDIF
   NEXT count1
   printgridpreview()

   RETURN NIL

FUNCTION addmergeheadrow

   LOCAL from1 := 1
   LOCAL to1 := 1

   IF len(mergehead) > 0
      IF mergehead[len(mergehead),2] < len(columnarr)
         from1 := mergehead[len(mergehead),2] + 1
         to1 := from1
         printgrid.merge.additem({from1,to1,""})
         mergeheaderschanged()
      ENDIF
   ELSE
      printgrid.merge.additem({from1,to1,""})
      mergeheaderschanged()
   ENDIF

   RETURN NIL

FUNCTION delmergeheadrow

   LOCAL lineno := printgrid.merge.value

   IF lineno > 0
      printgrid.merge.deleteitem(lineno)
      IF lineno > 1
         printgrid.merge.value := lineno - 1
      ELSE
         IF printgrid.merge.itemcount > 0
            printgrid.merge.value := 1
         ENDIF
      ENDIF
      mergeheaderschanged()
   ENDIF

   RETURN NIL

FUNCTION stripcomma(string,decimalsymbol,commasymbol)

   LOCAL xValue := ""
   LOCAL i := 0
   LOCAL char := ""

   DEFAULT decimalsymbol := "."
   DEFAULT commasymbol := ","
   string := alltrim(string)

   FOR i := len(string) to 1 step -1
      char := substr(string,i,1)
      IF ISDIGIT(char) .or. char == decimalsymbol
         xvalue := char+xvalue
      ENDIF
   NEXT i
   IF at("-",string) > 0 .or. at("DB",string) > 0 .or. (at("(",string) > 0 .and. at(")",string) > 0)
      xvalue := "-"+xvalue
   ENDIF

   RETURN xvalue

FUNCTION printgridinit

   LOCAL gridprintdata := array(20)
   LOCAL count1 := 0
   LOCAL controlname := ""
   LOCAL linedata := {}

   gridprintdata[1] := {}
   gridprintdata[2] := {}
   gridprintdata[3] := ""
   gridprintdata[4] := 0
   gridprintdata[5] := 0
   gridprintdata[6] := 0
   gridprintdata[7] := .f.
   gridprintdata[8] := .f.
   gridprintdata[9] := .f.
   gridprintdata[10] := .f.
   gridprintdata[11] := 0
   gridprintdata[12] := 0
   gridprintdata[13] := 0
   gridprintdata[14] := 0.0
   gridprintdata[15] := 0.0
   gridprintdata[16] := 0.0
   gridprintdata[17] := 0.0
   gridprintdata[18] := 0.0
   gridprintdata[19] := 0.0
   gridprintdata[20] := {}
   IF .not. file("reports.cfg")

      RETURN NIL
   ENDIF
   BEGIN INI FILE "reports.cfg"
      GET controlname section windowname+"_"+gridname entry "controlname" default ""
      IF upper(alltrim(controlname)) == upper(alltrim(windowname+"_"+gridname))
         GET gridprintdata[1] section windowname+"_"+gridname entry "gridprintdata1"
         GET gridprintdata[2] section windowname+"_"+gridname entry "gridprintdata2"
         GET gridprintdata[3] section windowname+"_"+gridname entry "gridprintdata3"
         GET gridprintdata[4] section windowname+"_"+gridname entry "gridprintdata4"
         GET gridprintdata[5] section windowname+"_"+gridname entry "gridprintdata5"
         GET gridprintdata[6] section windowname+"_"+gridname entry "gridprintdata6"
         GET gridprintdata[7] section windowname+"_"+gridname entry "gridprintdata7"
         GET gridprintdata[8] section windowname+"_"+gridname entry "gridprintdata8"
         GET gridprintdata[9] section windowname+"_"+gridname entry "gridprintdata9"
         GET gridprintdata[10] section windowname+"_"+gridname entry "gridprintdata10"
         GET gridprintdata[11] section windowname+"_"+gridname entry "gridprintdata11"
         GET gridprintdata[12] section windowname+"_"+gridname entry "gridprintdata12"
         GET gridprintdata[13] section windowname+"_"+gridname entry "gridprintdata13"
         GET gridprintdata[14] section windowname+"_"+gridname entry "gridprintdata14"
         GET gridprintdata[15] section windowname+"_"+gridname entry "gridprintdata15"
         GET gridprintdata[16] section windowname+"_"+gridname entry "gridprintdata16"
         GET gridprintdata[17] section windowname+"_"+gridname entry "gridprintdata17"
         GET gridprintdata[18] section windowname+"_"+gridname entry "gridprintdata18"
         GET gridprintdata[19] section windowname+"_"+gridname entry "gridprintdata19"
         GET gridprintdata[20] section windowname+"_"+gridname entry "gridprintdata20"
         // columns
         printgrid.columns.deleteallitems()
         asize(columnarr,0)
         FOR count1 := 1 to len(gridprintdata[1])
            linedata := gridprintdata[1,count1]
            aadd(columnarr,{int(linedata[3]),linedata[1],linedata[2],ajustify[count1]})
            printgrid.columns.additem({linedata[1],linedata[2],int(linedata[3])})
         NEXT count1
         IF printgrid.columns.itemcount > 0
            printgrid.columns.value := 1
         ENDIF
         // headers
         printgrid.header1.value := ifempty(header1,gridprintdata[2,1],header1)
         printgrid.header2.value := ifempty(header2,gridprintdata[2,2],header2)
         printgrid.header3.value := ifempty(header3,gridprintdata[2,3],header3)
         // footer
         printgrid.footer1.value := gridprintdata[3]
         //fontsize
         printgrid.selectfontsize.value := int(gridprintdata[4])
         // wordwrap
         printgrid.wordwrap.value := int(gridprintdata[5])
         // pagination
         printgrid.pageno.value := int(gridprintdata[6])
         // collines
         printgrid.collines.value := gridprintdata[7]
         // rowlines
         printgrid.rowlines.value := gridprintdata[8]
         // vertical center
         printgrid.vertical.value := gridprintdata[9]
         // space spread
         printgrid.spread.value := gridprintdata[10]
         // orientation
         printgrid.paperorientation.value := gridprintdata[11]
         // printers
         printgrid.printers.value := int(gridprintdata[12])
         // pagesize
         printgrid.pagesizes.value := gridprintdata[13]
         // paper width
         printgrid.width.value := gridprintdata[14]
         // paper height
         printgrid.height.value := gridprintdata[15]
         // margin top
         printgrid.top.value := gridprintdata[16]
         // margin right
         printgrid.right.value := gridprintdata[17]
         // margin left
         printgrid.left.value := gridprintdata[18]
         // margin bottom
         printgrid.bottom.value := gridprintdata[19]
         // merge headers data
         printgrid.merge.deleteallitems()
         FOR count1 := 1 to len(gridprintdata[20])
            linedata := gridprintdata[20,count1]
            printgrid.merge.additem({int(linedata[1]),int(linedata[2]),linedata[3]})
         NEXT count1
         IF printgrid.merge.itemcount > 0
            printgrid.merge.value := 1
         ENDIF
         printcoltally()
         printgridpreview()
      ENDIF
   END INI

   RETURN NIL

FUNCTION resetprintgridform

   LOCAL controlname := "", count1

   IF msgyesno(msgarr[67], "Confirmation")
      IF .not. file("reports.cfg")

         RETURN NIL
      ENDIF
      BEGIN INI FILE "reports.cfg"
         GET controlname section windowname+"_"+gridname entry "controlname" default ""
         IF upper(alltrim(controlname)) == upper(alltrim(windowname+"_"+gridname))
            del section windowname+"_"+gridname
         ENDIF
      END INI
      printgrid.merge.deleteallitems()
      printgrid.spread.value := .t.
      printgrid.collines.value := .t.
      printgrid.rowlines.value := .t.
      printgrid.wordwrap.value := 2
      printgrid.pageno.value := 2
      printgrid.vertical.value := .t.
      FOR count1 := 1 to len(mergehead)
         IF mergehead[count1,2] >= mergehead[count1,1] .and. iif(count1 > 1,mergehead[count1,1] > mergehead[count1-1,2],.t.)
            printgrid.merge.additem({mergehead[count1,1],mergehead[count1,2],mergehead[count1,3]})
         ENDIF
      NEXT count1
      IF printgrid.merge.itemcount > 0
         printgrid.merge.value := 1
      ENDIF
      IF printgrid.pagesizes.value > 0
         IF printgrid.paperorientation.value == 2 //portrait
            printgrid.width.value := papersizes[printgrid.pagesizes.value,1]
            printgrid.height.value := papersizes[printgrid.pagesizes.value,2]
         ELSE // landscape
            printgrid.width.value := papersizes[printgrid.pagesizes.value,2]
            printgrid.height.value := papersizes[printgrid.pagesizes.value,1]
         ENDIF
         maxcol2 := printgrid.width.value - printgrid.left.value - printgrid.right.value
         printgrid.statusbar.item(2) := msgarr[10]+" "+alltrim(str(curcol1,12,2))+" "+msgarr[11]+" "+alltrim(str(maxcol2,12,2))
      ENDIF
      IF printgrid.pagesizes.value == printgrid.pagesizes.itemcount // custom
         printgrid.width.readonly := .f.
         printgrid.height.readonly := .f.
      ELSE
         printgrid.width.readonly := .t.
         printgrid.height.readonly := .t.
      ENDIF
      printgrid.columns.deleteallitems()
      FOR count1 := 1 to len(columnarr)
         columnarr[count1,1] := 1
         printgrid.columns.additem({columnarr[count1,2],columnarr[count1,3],1})
      NEXT count1
      calculatecolumnsizes()
      printcoltally()
      IF printgrid.columns.itemcount > 0
         printgrid.columns.value := 1
      ENDIF
      printgridpreview()
   ENDIF

   RETURN NIL

FUNCTION _initprintgridmessages

   LOCAL cLang := Upper( Left( Set ( _SET_LANGUAGE ), 2 ) ), msgarr

   // LANGUAGE IS NOT SUPPORTED BY hb_langSelect() FUNCTION
   IF _HMG_LANG_ID == 'FI'      // FINNISH
      cLang := 'FI'
   ENDIF

   DO CASE

   CASE cLang == "TR"
      msgarr := {"Yazd?r?lacak bir s,ey yok",;
         "Kurulu yaz?c? yok!",;
         "Yazd?rma Sihirbaz?",;
         "Rapor Yaz?c?",;
         "Sütunlar",;
         "Sütun Ad?",;
         "Genis,lik (mm)",;
         "Yaz?c? seçimi için bir sütunu çift t?klay?n",;
         "Metin sütun genis,lig(ini deg(is,tir",;
         "Toplam Genis,lik :",;
         "d?s,?nda",;
         "Bas,l?k 1",;
         "Bas,l?k 2",;
         "Bas,l?k 3",;
         "Altl?k 1",;
         "Rapor Özellikleri",;
         "Font Boyutu",;
         "Uzun Sat?r",;
         "Sözcük kayd?r",;
         "Kes",;
         "Sayfalama",;
         "Kapal?",;
         "Üst",;
         "Alt",;
         "Izgara Sat?rlar?",;
         "Sütun",;
         "Sat?r",;
         "Sayfa Ortalama",;
         "Dikey",;
         "Sayfa/Yaz?c?",;
         "Bask? Yönü",;
         "Manzara",;
         "Portre",;
         "Yaz?c?: ",;
         "Sayfa Boyutu",;
         "Sayfa Genis,lig(i",;
         "Sayfa Yükseklig(i",;
         "Kenar Bos,luklar? (mm)",;
         "Üst",;
         "Sag(",;
         "Sol",;
         "Alt",;
         "Yazd?r",;
         "I.ptal",;
         "Yazd?rma Sihirbaz?na Hos,geldiniz",;
         "Sayfan?n alabileceg(inden fazla sütun seçtiniz!",;
         "Bir Yaz?c? Seçmelisiniz!",;
         "Yaz?c? seçilmedi! Yaz?c? var m? denetle.",;
         "Sayfa No. :",;
         "Boyut :",;
         "Tamam",;
         "Metin türü d?s,?nda Sütun Boyutu deg(is,tirilemez!",;
         "Yanas,t?rma sabitleri düzgün verilmedi.",;
         "Whitespace",; //54
         "Spread",; //55
         "Apply",; //56
         "Include",;//57
         "Sum",;//58
         "Yes",;//59
         "No",;//60
         "Merge Header",; //61
         "From",; //62
         "To",; //63
         "Header",; //64
         "There is an error in Merge Head definition in line no.",; //65
         "Reset Form",; //66
         "All the previous report configuration for this report will be lost! Are you sure to reset the form?",; // 67
         }
   CASE cLang ==  "CS"
      msgarr := {"Nothing to print",;    //1
         "No printers have been installed!",;  //2
         "Print Wizard",;  //3
         "Report Writer",; //4
         "Columns",; //5
         "Name of the Column",; //6
         "Width (mm)",; //7
         "Double Click a Column to toggle between selecting and not selecting for printing.",; //8
         "Edit Text Column Size",; //9
         "Total Width :",; //10
         "out of",;  //11
         "Header 1",;  //12
         "Header 2",; //13
         "Header 3",; //14
         "Footer 1",; //15
         "Report Properties",; //16
         "Font Size",; //17
         "Lengthy Line",; //18
         "Word Wrap",; //19
         "Truncate",; //20
         "Pagination",; //21
         "Off",; //22
         "Top",; //23
         "Bottom",; //24
         "Grid Lines",; //25
         "Column",; //26
         "Row",; //27
         "Page Center",; //28
         "Vertical",; //29
         "Page/Printer",; //30
         "Orientation",; //31
         "Landscape",; //32
         "Portrait",; //33
         "Printer: ",; //34
         "Page Size",; //35
         "Page Width",; //36
         "Page Height",; //37
         "Margins (mm)",; //38
         "Top",; //39
         "Right",; //40
         "Left",; //41
         "Bottom",; //42
         "Print",; //43
         "Cancel",; //44
         "Welcome to Print Wizard",; //45
         "You had selected more columns than to fit in a page!",; //46
         "You have to select a printer!",; //47
         "Printer could not be selected! Check Availability of Printer.",; //48
         "Page No. :",; //49
         "Size :",; //50
         "Done",; //51
         "Size of Columns other than text type can not be modified!",; //52
         "Justification constants not given properly.",; //53
         "Whitespace",; //54
         "Spread",; //55
         "Apply",; //56
         "Include",;//57
         "Sum",;//58
         "Yes",;//59
         "No",;//60
         "Merge Header",; //61
         "From",; //62
         "To",; //63
         "Header",; //64
         "There is an error in Merge Head definition in line no.",; //65
         "Reset Form",; //66
         "All the previous report configuration for this report will be lost! Are you sure to reset the form?",; // 67
         }
   CASE cLang == "HR"
      // CROATIAN
      msgarr := {"Nothing to print",;    //1
         "No printers have been installed!",;  //2
         "Print Wizard",;  //3
         "Report Writer",; //4
         "Columns",; //5
         "Name of the Column",; //6
         "Width (mm)",; //7
         "Double Click a Column to toggle between selecting and not selecting for printing.",; //8
         "Edit Text Column Size",; //9
         "Total Width :",; //10
         "out of",;  //11
         "Header 1",;  //12
         "Header 2",; //13
         "Header 3",; //14
         "Footer 1",; //15
         "Report Properties",; //16
         "Font Size",; //17
         "Lengthy Line",; //18
         "Word Wrap",; //19
         "Truncate",; //20
         "Pagination",; //21
         "Off",; //22
         "Top",; //23
         "Bottom",; //24
         "Grid Lines",; //25
         "Column",; //26
         "Row",; //27
         "Page Center",; //28
         "Vertical",; //29
         "Page/Printer",; //30
         "Orientation",; //31
         "Landscape",; //32
         "Portrait",; //33
         "Printer: ",; //34
         "Page Size",; //35
         "Page Width",; //36
         "Page Height",; //37
         "Margins (mm)",; //38
         "Top",; //39
         "Right",; //40
         "Left",; //41
         "Bottom",; //42
         "Print",; //43
         "Cancel",; //44
         "Welcome to Print Wizard",; //45
         "You had selected more columns than to fit in a page!",; //46
         "You have to select a printer!",; //47
         "Printer could not be selected! Check Availability of Printer.",; //48
         "Page No. :",; //49
         "Size :",; //50
         "Done",; //51
         "Size of Columns other than text type can not be modified!",; //52
         "Justification constants not given properly.",; //53
         "Whitespace",; //54
         "Spread",; //55
         "Apply",; //56
         "Include",;//57
         "Sum",;//58
         "Yes",;//59
         "No",;//60
         "Merge Header",; //61
         "From",; //62
         "To",; //63
         "Header",; //64
         "There is an error in Merge Head definition in line no.",; //65
         "Reset Form",; //66
         "All the previous report configuration for this report will be lost! Are you sure to reset the form?",; // 67
         }
   CASE cLang == "EU"
      // BASQUE
      msgarr := {"Nothing to print",;    //1
         "No printers have been installed!",;  //2
         "Print Wizard",;  //3
         "Report Writer",; //4
         "Columns",; //5
         "Name of the Column",; //6
         "Width (mm)",; //7
         "Double Click a Column to toggle between selecting and not selecting for printing.",; //8
         "Edit Text Column Size",; //9
         "Total Width :",; //10
         "out of",;  //11
         "Header 1",;  //12
         "Header 2",; //13
         "Header 3",; //14
         "Footer 1",; //15
         "Report Properties",; //16
         "Font Size",; //17
         "Lengthy Line",; //18
         "Word Wrap",; //19
         "Truncate",; //20
         "Pagination",; //21
         "Off",; //22
         "Top",; //23
         "Bottom",; //24
         "Grid Lines",; //25
         "Column",; //26
         "Row",; //27
         "Page Center",; //28
         "Vertical",; //29
         "Page/Printer",; //30
         "Orientation",; //31
         "Landscape",; //32
         "Portrait",; //33
         "Printer: ",; //34
         "Page Size",; //35
         "Page Width",; //36
         "Page Height",; //37
         "Margins (mm)",; //38
         "Top",; //39
         "Right",; //40
         "Left",; //41
         "Bottom",; //42
         "Print",; //43
         "Cancel",; //44
         "Welcome to Print Wizard",; //45
         "You had selected more columns than to fit in a page!",; //46
         "You have to select a printer!",; //47
         "Printer could not be selected! Check Availability of Printer.",; //48
         "Page No. :",; //49
         "Size :",; //50
         "Done",; //51
         "Size of Columns other than text type can not be modified!",; //52
         "Justification constants not given properly.",; //53
         "Whitespace",; //54
         "Spread",; //55
         "Apply",; //56
         "Include",;//57
         "Sum",;//58
         "Yes",;//59
         "No",;//60
         "Merge Header",; //61
         "From",; //62
         "To",; //63
         "Header",; //64
         "There is an error in Merge Head definition in line no.",; //65
         "Reset Form",; //66
         "All the previous report configuration for this report will be lost! Are you sure to reset the form?",; // 67
         }
      /*     case cLang == "EN"
      // ENGLISH
      msgarr := {"Nothing to print",;    //1
      "No printers have been installed!",;  //2
      "Print Wizard",;  //3
      "Report Writer",; //4
      "Columns",; //5
      "Name of the Column",; //6
      "Width (mm)",; //7
      "Double Click a Column to toggle between selecting and not selecting for printing.",; //8
      "Edit Text Column Size",; //9
      "Total Width :",; //10
      "out of",;  //11
      "Header 1",;  //12
      "Header 2",; //13
      "Header 3",; //14
      "Footer 1",; //15
      "Report Properties",; //16
      "Font Size",; //17
      "Lengthy Line",; //18
      "Word Wrap",; //19
      "Truncate",; //20
      "Pagination",; //21
      "Off",; //22
      "Top",; //23
      "Bottom",; //24
      "Grid Lines",; //25
      "Column",; //26
      "Row",; //27
      "Page Center",; //28
      "Vertical",; //29
      "Page/Printer",; //30
      "Orientation",; //31
      "Landscape",; //32
      "Portrait",; //33
      "Printer: ",; //34
      "Page Size",; //35
      "Page Width",; //36
      "Page Height",; //37
      "Margins (mm)",; //38
      "Top",; //39
      "Right",; //40
      "Left",; //41
      "Bottom",; //42
      "Print",; //43
      "Cancel",; //44
      "Welcome to Print Wizard",; //45
      "You had selected more columns than to fit in a page!",; //46
      "You have to select a printer!",; //47
      "Printer could not be selected! Check Availability of Printer.",; //48
      "Page No. :",; //49
      "Size :",; //50
      "Done",; //51
      "Size of Columns other than text type can not be modified!",; //52
      "Justification constants not given properly.",; //53
      "Whitespace",; //54
      "Spread",; //55
      "Apply",; //56
      "Include",;//57
      "Sum",;//58
      "Yes",;//59
      "No",;//60
      "Merge Header",; //61
      "From",; //62
      "To",; //63
      "Header",; //64
      "There is an error in Merge Head definition in line no.",; //65
      "Reset Form",; //66
      "All the previous report configuration for this report will be lost! Are you sure to reset the form?",; // 67
      } */
   CASE cLang == "FR"
      // FRENCH
      msgarr := {"Nothing to print",;    //1
         "No printers have been installed!",;  //2
         "Print Wizard",;  //3
         "Report Writer",; //4
         "Columns",; //5
         "Name of the Column",; //6
         "Width (mm)",; //7
         "Double Click a Column to toggle between selecting and not selecting for printing.",; //8
         "Edit Text Column Size",; //9
         "Total Width :",; //10
         "out of",;  //11
         "Header 1",;  //12
         "Header 2",; //13
         "Header 3",; //14
         "Footer 1",; //15
         "Report Properties",; //16
         "Font Size",; //17
         "Lengthy Line",; //18
         "Word Wrap",; //19
         "Truncate",; //20
         "Pagination",; //21
         "Off",; //22
         "Top",; //23
         "Bottom",; //24
         "Grid Lines",; //25
         "Column",; //26
         "Row",; //27
         "Page Center",; //28
         "Vertical",; //29
         "Page/Printer",; //30
         "Orientation",; //31
         "Landscape",; //32
         "Portrait",; //33
         "Printer: ",; //34
         "Page Size",; //35
         "Page Width",; //36
         "Page Height",; //37
         "Margins (mm)",; //38
         "Top",; //39
         "Right",; //40
         "Left",; //41
         "Bottom",; //42
         "Print",; //43
         "Cancel",; //44
         "Welcome to Print Wizard",; //45
         "You had selected more columns than to fit in a page!",; //46
         "You have to select a printer!",; //47
         "Printer could not be selected! Check Availability of Printer.",; //48
         "Page No. :",; //49
         "Size :",; //50
         "Done",; //51
         "Size of Columns other than text type can not be modified!",; //52
         "Justification constants not given properly.",; //53
         "Whitespace",; //54
         "Spread",; //55
         "Apply",; //56
         "Include",;//57
         "Sum",;//58
         "Yes",;//59
         "No",;//60
         "Merge Header",; //61
         "From",; //62
         "To",; //63
         "Header",; //64
         "There is an error in Merge Head definition in line no.",; //65
         "Reset Form",; //66
         "All the previous report configuration for this report will be lost! Are you sure to reset the form?",; // 67
         }
   CASE cLang == "DE"
      // GERMAN
      msgarr := {"Nothing to print",;    //1
         "No printers have been installed!",;  //2
         "Print Wizard",;  //3
         "Report Writer",; //4
         "Columns",; //5
         "Name of the Column",; //6
         "Width (mm)",; //7
         "Double Click a Column to toggle between selecting and not selecting for printing.",; //8
         "Edit Text Column Size",; //9
         "Total Width :",; //10
         "out of",;  //11
         "Header 1",;  //12
         "Header 2",; //13
         "Header 3",; //14
         "Footer 1",; //15
         "Report Properties",; //16
         "Font Size",; //17
         "Lengthy Line",; //18
         "Word Wrap",; //19
         "Truncate",; //20
         "Pagination",; //21
         "Off",; //22
         "Top",; //23
         "Bottom",; //24
         "Grid Lines",; //25
         "Column",; //26
         "Row",; //27
         "Page Center",; //28
         "Vertical",; //29
         "Page/Printer",; //30
         "Orientation",; //31
         "Landscape",; //32
         "Portrait",; //33
         "Printer: ",; //34
         "Page Size",; //35
         "Page Width",; //36
         "Page Height",; //37
         "Margins (mm)",; //38
         "Top",; //39
         "Right",; //40
         "Left",; //41
         "Bottom",; //42
         "Print",; //43
         "Cancel",; //44
         "Welcome to Print Wizard",; //45
         "You had selected more columns than to fit in a page!",; //46
         "You have to select a printer!",; //47
         "Printer could not be selected! Check Availability of Printer.",; //48
         "Page No. :",; //49
         "Size :",; //50
         "Done",; //51
         "Size of Columns other than text type can not be modified!",; //52
         "Justification constants not given properly.",; //53
         "Whitespace",; //54
         "Spread",; //55
         "Apply",; //56
         "Include",;//57
         "Sum",;//58
         "Yes",;//59
         "No",;//60
         "Merge Header",; //61
         "From",; //62
         "To",; //63
         "Header",; //64
         "There is an error in Merge Head definition in line no.",; //65
         "Reset Form",; //66
         "All the previous report configuration for this report will be lost! Are you sure to reset the form?",; // 67
         }
   CASE cLang == "IT"
      // ITALIAN
      msgarr := {"Nothing to print",;    //1
         "No printers have been installed!",;  //2
         "Print Wizard",;  //3
         "Report Writer",; //4
         "Columns",; //5
         "Name of the Column",; //6
         "Width (mm)",; //7
         "Double Click a Column to toggle between selecting and not selecting for printing.",; //8
         "Edit Text Column Size",; //9
         "Total Width :",; //10
         "out of",;  //11
         "Header 1",;  //12
         "Header 2",; //13
         "Header 3",; //14
         "Footer 1",; //15
         "Report Properties",; //16
         "Font Size",; //17
         "Lengthy Line",; //18
         "Word Wrap",; //19
         "Truncate",; //20
         "Pagination",; //21
         "Off",; //22
         "Top",; //23
         "Bottom",; //24
         "Grid Lines",; //25
         "Column",; //26
         "Row",; //27
         "Page Center",; //28
         "Vertical",; //29
         "Page/Printer",; //30
         "Orientation",; //31
         "Landscape",; //32
         "Portrait",; //33
         "Printer: ",; //34
         "Page Size",; //35
         "Page Width",; //36
         "Page Height",; //37
         "Margins (mm)",; //38
         "Top",; //39
         "Right",; //40
         "Left",; //41
         "Bottom",; //42
         "Print",; //43
         "Cancel",; //44
         "Welcome to Print Wizard",; //45
         "You had selected more columns than to fit in a page!",; //46
         "You have to select a printer!",; //47
         "Printer could not be selected! Check Availability of Printer.",; //48
         "Page No. :",; //49
         "Size :",; //50
         "Done",; //51
         "Size of Columns other than text type can not be modified!",; //52
         "Justification constants not given properly.",; //53
         "Whitespace",; //54
         "Spread",; //55
         "Apply",; //56
         "Include",;//57
         "Sum",;//58
         "Yes",;//59
         "No",;//60
         "Merge Header",; //61
         "From",; //62
         "To",; //63
         "Header",; //64
         "There is an error in Merge Head definition in line no.",; //65
         "Reset Form",; //66
         "All the previous report configuration for this report will be lost! Are you sure to reset the form?",; // 67
         }
   CASE cLang == "PL"
      // POLISH
      curpagesize := 5
      msgarr := {"Brak danych do druku!",;    //1
         "Brak zainstalowanych drukarek w systemie!",;  //2
         "Kreator wydruku",;  //3
         "Kreator zapisu",; //4
         "Kolumny",; //5
         "Nazwa kolumny",; //6
         "Szerokos'c' (mm)",; //7
         "Kliknij dwa razy na kolumnie, aby ja; zaznaczyc'/odznaczyc' do wydruku",; //8
         "Zmien' rozmiar kolumny tekstowej",; //9
         "Ca?kowitta szerokos'c':",; //10
         "z",;  //11
         "Nag?ówek 1",;  //12
         "Nag?ówek 2",; //13
         "Nag?ówek 3",; //14
         "Stopka 1",; //15
         "W?asnos'ci raportu",; //16
         "Rozmiar czcionki",; //17
         "D?ugie teksty",; //18
         "Zawijanie s?ów",; //19
         "Obcie;cie",; //20
         "Numeracja stron",; //21
         "Wy?a;czona",; //22
         "Góra",; //23
         "Dó?",; //24
         "Linie siatki",; //25
         "Kolumna",; //26
         "Wiersz",; //27
         "Centruj strone;",; //28
         "Pionowy",; //29
         "Strona/Drukarka",; //30
         "Orientacja",; //31
         "Pozioma",; //32
         "Pionowa",; //33
         "Drukarka: ",; //34
         "Rozmiar strony",; //35
         "Szerokos'c' strony",; //36
         "Wysokos'c' strony",; //37
         "Marginesy (mm)",; //38
         "Górny",; //39
         "Prawy",; //40
         "Lewy",; //41
         "Dolny",; //42
         "Drukuj",; //43
         "Anuluj",; //44
         "Witaj w Kreatorze Wydruku",; //45
         "Wybra?es' wie;cej kolumn, niz. moz.na zmies'cic' na stronie!",; //46
         "Musisz wybrac' drukarke;!",; //47
         "Nie moz.na wybrac' drukarki! Sprawdz' jej doste;pnos'c'.",; //48
         "Numer strony:",; //49
         "Rozmiar:",; //50
         "Wykonano",; //51
         "Nie moz.na zmieniac' rozmiau nietekstowych kolumn!",; //52
         "Justyfikacja okres'lona nieprawid?owo.",; //53
         "Puste przestrzenie",; //54
         "Rozszerz",; //55
         "Zastosuj",; //56
         "Do?a;cz",;//57
         "Suma",;//58
         "Tak",;//59
         "Nie",;//60
         "Do?a;cz nag?ówek",; //61
         "Od",; //62
         "Do",; //63
         "Nag?ówek",; //64
         "Pojawi? sie; b?a;d w definicji do?a;czanego nag?ówka w linii  nr ",; //65
         "Reset Form",; //66
         "All the previous report configuration for this report will be lost! Are you sure to reset the form?",; // 67
         }
   CASE cLang == "PT"
      // PORTUGUESE
      msgarr := {"Nothing to print",;    //1
         "No printers have been installed!",;  //2
         "Print Wizard",;  //3
         "Report Writer",; //4
         "Columns",; //5
         "Name of the Column",; //6
         "Width (mm)",; //7
         "Double Click a Column to toggle between selecting and not selecting for printing.",; //8
         "Edit Text Column Size",; //9
         "Total Width :",; //10
         "out of",;  //11
         "Header 1",;  //12
         "Header 2",; //13
         "Header 3",; //14
         "Footer 1",; //15
         "Report Properties",; //16
         "Font Size",; //17
         "Lengthy Line",; //18
         "Word Wrap",; //19
         "Truncate",; //20
         "Pagination",; //21
         "Off",; //22
         "Top",; //23
         "Bottom",; //24
         "Grid Lines",; //25
         "Column",; //26
         "Row",; //27
         "Page Center",; //28
         "Vertical",; //29
         "Page/Printer",; //30
         "Orientation",; //31
         "Landscape",; //32
         "Portrait",; //33
         "Printer: ",; //34
         "Page Size",; //35
         "Page Width",; //36
         "Page Height",; //37
         "Margins (mm)",; //38
         "Top",; //39
         "Right",; //40
         "Left",; //41
         "Bottom",; //42
         "Print",; //43
         "Cancel",; //44
         "Welcome to Print Wizard",; //45
         "You had selected more columns than to fit in a page!",; //46
         "You have to select a printer!",; //47
         "Printer could not be selected! Check Availability of Printer.",; //48
         "Page No. :",; //49
         "Size :",; //50
         "Done",; //51
         "Size of Columns other than text type can not be modified!",; //52
         "Justification constants not given properly.",; //53
         "Whitespace",; //54
         "Spread",; //55
         "Apply",; //56
         "Include",;//57
         "Sum",;//58
         "Yes",;//59
         "No",;//60
         "Merge Header",; //61
         "From",; //62
         "To",; //63
         "Header",; //64
         "There is an error in Merge Head definition in line no.",; //65
         "Reset Form",; //66
         "All the previous report configuration for this report will be lost! Are you sure to reset the form?",; // 67
         }
   CASE cLang == "RU"
      // RUSSIAN
      msgarr := {"Nothing to print",;    //1
         "No printers have been installed!",;  //2
         "Print Wizard",;  //3
         "Report Writer",; //4
         "Columns",; //5
         "Name of the Column",; //6
         "Width (mm)",; //7
         "Double Click a Column to toggle between selecting and not selecting for printing.",; //8
         "Edit Text Column Size",; //9
         "Total Width :",; //10
         "out of",;  //11
         "Header 1",;  //12
         "Header 2",; //13
         "Header 3",; //14
         "Footer 1",; //15
         "Report Properties",; //16
         "Font Size",; //17
         "Lengthy Line",; //18
         "Word Wrap",; //19
         "Truncate",; //20
         "Pagination",; //21
         "Off",; //22
         "Top",; //23
         "Bottom",; //24
         "Grid Lines",; //25
         "Column",; //26
         "Row",; //27
         "Page Center",; //28
         "Vertical",; //29
         "Page/Printer",; //30
         "Orientation",; //31
         "Landscape",; //32
         "Portrait",; //33
         "Printer: ",; //34
         "Page Size",; //35
         "Page Width",; //36
         "Page Height",; //37
         "Margins (mm)",; //38
         "Top",; //39
         "Right",; //40
         "Left",; //41
         "Bottom",; //42
         "Print",; //43
         "Cancel",; //44
         "Welcome to Print Wizard",; //45
         "You had selected more columns than to fit in a page!",; //46
         "You have to select a printer!",; //47
         "Printer could not be selected! Check Availability of Printer.",; //48
         "Page No. :",; //49
         "Size :",; //50
         "Done",; //51
         "Size of Columns other than text type can not be modified!",; //52
         "Justification constants not given properly.",; //53
         "Whitespace",; //54
         "Spread",; //55
         "Apply",; //56
         "Include",;//57
         "Sum",;//58
         "Yes",;//59
         "No",;//60
         "Merge Header",; //61
         "From",; //62
         "To",; //63
         "Header",; //64
         "There is an error in Merge Head definition in line no.",; //65
         "Reset Form",; //66
         "All the previous report configuration for this report will be lost! Are you sure to reset the form?",; // 67
         }
   CASE cLang == "ES"
      // SPANISH

      msgarr := {"Nada para imprimir",;
         "No hay impresoras instaladas!",;
         "Asistente de Impresión",;
         "Generador de Reportes",;
         "Columnas",;
         "Nombre de la columna",;
         "Ancho (mm)",;
         "Doble clic en una columna para seleccionar o deselecionarla para impresión",;
         "Editar tamaño del texto de columna",;
         "Ancho Total :",;
         "out of",;
         "Encabezado 1",;
         "Encabezado 2",;
         "Encabezado 3",;
         "Pie de Página 1",;
         "Propiedades del Reporte",;
         "Tamaño de Fuente",;
         "Línea larga",;
         "Ajuste de Línea",;
         "Truncar",;
         "Paginación",;
         "Apagado",;
         "Superior",;
         "Inferior",;
         "Líneas de Grilla",;
         "Columna",;
         "Fila",;
         "Centrado de Página",;
         "Vertical",;
         "Página/Impresora",;
         "Orientación",;
         "Horizontal",;
         "Vertical",;
         "Impresora: ",;
         "Tamaño de Página",;
         "Ancho de Página",;
         "Altura de Página",;
         "Márgenes (mm)",;
         "Superior",;
         "Derecho",;
         "Izquierdo",;
         "Inferior",;
         "Imprimir",;
         "Cancelar",;
         "Bienvenido al asistente de Impresión",;
         "Ha seleccionado más columnas de las que entran en una página!",;
         "You have to select a printer!",;
         "La impresora no puede ser seleccionada! Verifique la disponibilidad de la impresora.",;
         "Página Nro. :",;
         "Tamaño :",;
         "Hecho",;
         "EL tamaño de las columnas que no sean del tipo texto no pueden modificarse!",;
         "Constantes de justificación no dadas apropiadamente.",;
         "Whitespace",; //54
         "Spread",; //55
         "Apply",; //56
         "Include",;//57
         "Sum",;//58
         "Yes",;//59
         "No",;//60
         "Merge Header",; //61
         "From",; //62
         "To",; //63
         "Header",; //64
         "There is an error in Merge Head definition in line no.",; //65
         "Reset Form",; //66
         "All the previous report configuration for this report will be lost! Are you sure to reset the form?",; // 67
         }
   CASE cLang == "FI"
      // FINNISH
      msgarr := {"Nothing to print",;    //1
         "No printers have been installed!",;  //2
         "Print Wizard",;  //3
         "Report Writer",; //4
         "Columns",; //5
         "Name of the Column",; //6
         "Width (mm)",; //7
         "Double Click a Column to toggle between selecting and not selecting for printing.",; //8
         "Edit Text Column Size",; //9
         "Total Width :",; //10
         "out of",;  //11
         "Header 1",;  //12
         "Header 2",; //13
         "Header 3",; //14
         "Footer 1",; //15
         "Report Properties",; //16
         "Font Size",; //17
         "Lengthy Line",; //18
         "Word Wrap",; //19
         "Truncate",; //20
         "Pagination",; //21
         "Off",; //22
         "Top",; //23
         "Bottom",; //24
         "Grid Lines",; //25
         "Column",; //26
         "Row",; //27
         "Page Center",; //28
         "Vertical",; //29
         "Page/Printer",; //30
         "Orientation",; //31
         "Landscape",; //32
         "Portrait",; //33
         "Printer: ",; //34
         "Page Size",; //35
         "Page Width",; //36
         "Page Height",; //37
         "Margins (mm)",; //38
         "Top",; //39
         "Right",; //40
         "Left",; //41
         "Bottom",; //42
         "Print",; //43
         "Cancel",; //44
         "Welcome to Print Wizard",; //45
         "You had selected more columns than to fit in a page!",; //46
         "You have to select a printer!",; //47
         "Printer could not be selected! Check Availability of Printer.",; //48
         "Page No. :",; //49
         "Size :",; //50
         "Done",; //51
         "Size of Columns other than text type can not be modified!",; //52
         "Justification constants not given properly.",; //53
         "Whitespace",; //54
         "Spread",; //55
         "Apply",; //56
         "Include",;//57
         "Sum",;//58
         "Yes",;//59
         "No",;//60
         "Merge Header",; //61
         "From",; //62
         "To",; //63
         "Header",; //64
         "There is an error in Merge Head definition in line no.",; //65
         "Reset Form",; //66
         "All the previous report configuration for this report will be lost! Are you sure to reset the form?",; // 67
         }
   CASE cLang == "NL"
      // DUTCH
      msgarr := {"Nothing to print",;    //1
         "No printers have been installed!",;  //2
         "Print Wizard",;  //3
         "Report Writer",; //4
         "Columns",; //5
         "Name of the Column",; //6
         "Width (mm)",; //7
         "Double Click a Column to toggle between selecting and not selecting for printing.",; //8
         "Edit Text Column Size",; //9
         "Total Width :",; //10
         "out of",;  //11
         "Header 1",;  //12
         "Header 2",; //13
         "Header 3",; //14
         "Footer 1",; //15
         "Report Properties",; //16
         "Font Size",; //17
         "Lengthy Line",; //18
         "Word Wrap",; //19
         "Truncate",; //20
         "Pagination",; //21
         "Off",; //22
         "Top",; //23
         "Bottom",; //24
         "Grid Lines",; //25
         "Column",; //26
         "Row",; //27
         "Page Center",; //28
         "Vertical",; //29
         "Page/Printer",; //30
         "Orientation",; //31
         "Landscape",; //32
         "Portrait",; //33
         "Printer: ",; //34
         "Page Size",; //35
         "Page Width",; //36
         "Page Height",; //37
         "Margins (mm)",; //38
         "Top",; //39
         "Right",; //40
         "Left",; //41
         "Bottom",; //42
         "Print",; //43
         "Cancel",; //44
         "Welcome to Print Wizard",; //45
         "You had selected more columns than to fit in a page!",; //46
         "You have to select a printer!",; //47
         "Printer could not be selected! Check Availability of Printer.",; //48
         "Page No. :",; //49
         "Size :",; //50
         "Done",; //51
         "Size of Columns other than text type can not be modified!",; //52
         "Justification constants not given properly.",; //53
         "Whitespace",; //54
         "Spread",; //55
         "Apply",; //56
         "Include",;//57
         "Sum",;//58
         "Yes",;//59
         "No",;//60
         "Merge Header",; //61
         "From",; //62
         "To",; //63
         "Header",; //64
         "There is an error in Merge Head definition in line no.",; //65
         "Reset Form",; //66
         "All the previous report configuration for this report will be lost! Are you sure to reset the form?",; // 67
         }
   CASE cLang == "SL"
      // SLOVENIAN
      msgarr := {"Nothing to print",;    //1
         "No printers have been installed!",;  //2
         "Print Wizard",;  //3
         "Report Writer",; //4
         "Columns",; //5
         "Name of the Column",; //6
         "Width (mm)",; //7
         "Double Click a Column to toggle between selecting and not selecting for printing.",; //8
         "Edit Text Column Size",; //9
         "Total Width :",; //10
         "out of",;  //11
         "Header 1",;  //12
         "Header 2",; //13
         "Header 3",; //14
         "Footer 1",; //15
         "Report Properties",; //16
         "Font Size",; //17
         "Lengthy Line",; //18
         "Word Wrap",; //19
         "Truncate",; //20
         "Pagination",; //21
         "Off",; //22
         "Top",; //23
         "Bottom",; //24
         "Grid Lines",; //25
         "Column",; //26
         "Row",; //27
         "Page Center",; //28
         "Vertical",; //29
         "Page/Printer",; //30
         "Orientation",; //31
         "Landscape",; //32
         "Portrait",; //33
         "Printer: ",; //34
         "Page Size",; //35
         "Page Width",; //36
         "Page Height",; //37
         "Margins (mm)",; //38
         "Top",; //39
         "Right",; //40
         "Left",; //41
         "Bottom",; //42
         "Print",; //43
         "Cancel",; //44
         "Welcome to Print Wizard",; //45
         "You had selected more columns than to fit in a page!",; //46
         "You have to select a printer!",; //47
         "Printer could not be selected! Check Availability of Printer.",; //48
         "Page No. :",; //49
         "Size :",; //50
         "Done",; //51
         "Size of Columns other than text type can not be modified!",; //52
         "Justification constants not given properly.",; //53
         "Whitespace",; //54
         "Spread",; //55
         "Apply",; //56
         "Include",;//57
         "Sum",;//58
         "Yes",;//59
         "No",;//60
         "Merge Header",; //61
         "From",; //62
         "To",; //63
         "Header",; //64
         "There is an error in Merge Head definition in line no.",; //65
         "Reset Form",; //66
         "All the previous report configuration for this report will be lost! Are you sure to reset the form?",; // 67
         }
   OTHERWISE
      // DEFAULT (ENGLISH)
      msgarr := {"Nothing to print",;    //1
         "No printers have been installed!",;  //2
         "Print Wizard",;  //3
         "Report Writer",; //4
         "Columns",; //5
         "Column Name",; //6
         "Width (mm)",; //7
         "Double Click a Column to toggle between selecting and not selecting for printing.",; //8
         "Edit Text Column Size",; //9
         "Total Width :",; //10
         "out of",;  //11
         "Header 1",;  //12
         "Header 2",; //13
         "Header 3",; //14
         "Footer 1",; //15
         "Report Properties",; //16
         "Font Size",; //17
         "Lengthy Line",; //18
         "Word Wrap",; //19
         "Truncate",; //20
         "Pagination",; //21
         "Off",; //22
         "Top",; //23
         "Bottom",; //24
         "Grid Lines",; //25
         "Column",; //26
         "Row",; //27
         "Page Center",; //28
         "Vertical",; //29
         "Page/Printer",; //30
         "Orientation",; //31
         "Landscape",; //32
         "Portrait",; //33
         "Printer: ",; //34
         "Page Size",; //35
         "Page Width",; //36
         "Page Height",; //37
         "Margins (mm)",; //38
         "Top",; //39
         "Right",; //40
         "Left",; //41
         "Bottom",; //42
         "Print",; //43
         "Cancel",; //44
         "Welcome to Print Wizard",; //45
         "You had selected more columns than to fit in a page!",; //46
         "You have to select a printer!",; //47
         "Printer could not be selected! Check Availability of Printer.",; //48
         "Page No. ",; //49
         "Size :",; //50
         "Done",; //51
         "Size of Columns other than text type can not be modified!",; //52
         "Justification constants not given properly.",; //53
         "Whitespace",; //54
         "Spread",; //55
         "Apply",; //56
         "Include",;//57
         "Sum",;//58
         "Yes",;//59
         "No",;//60
         "Merge Header",; //61
         "From",; //62
         "To",; //63
         "Header",; //64
         "There is an error in Merge Head definition in line no.",; //65
         "Reset Form",; //66
         "All the previous report configuration for this report will be lost! Are you sure to reset the form?",; // 67
         }
   ENDCASE

   RETURN msgarr
