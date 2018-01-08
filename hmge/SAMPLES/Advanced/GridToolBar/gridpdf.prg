#include "hmg.ch"
#include "hmg_hpdf.ch"

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
MEMVAR aColWidths
MEMVAR aprinternames
MEMVAR defaultprinter
MEMVAR lVertLines
MEMVAR lHorLines
MEMVAR nTopMargin
MEMVAR nBottomMargin
MEMVAR nLeftMargin
MEMVAR nRightMargin
MEMVAR cPDFFileName
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
MEMVAR aData
MEMVAR lArrayMode
MEMVAR nCustomPaperWidth
MEMVAR nCustomPaperHeight

DECLARE window pdfgrid

FUNCTION _gridpdf(cGrid,cWindow,cPDFFile, fontsize,orientation,aHeaders,fontname1,showwindow1,mheaders,summation,aArrayData,aArrayHeaders,aArrayJustify,aColumnWidths,nPaperSize,nPaperWidth,nPaperHeight,lVerticalLines,lHorizontalLines,nLeft,nTop,nRight,nBottom)

   LOCAL count1 := 0
   LOCAL count2 := 0
   LOCAL maxcol1 := 0
   LOCAL i := 0
   LOCAL nDecimals := Set( _SET_DECIMALS)
   LOCAL aec := ""
   LOCAL aitems := {}
   LOCAL aDataHeaders
   PRIVATE msgarr := {}
   PRIVATE fontname := ""
   PRIVATE fontsizesstr := {}
   PRIVATE headerarr := {}
   PRIVATE curpagesize := 0
   PRIVATE sizes := {}
   PRIVATE headersizes := {}
   PRIVATE selectedprinter := ""
   PRIVATE columnarr := {}
   PRIVATE fontnumber := 0
   PRIVATE windowname := ""
   PRIVATE lines := 0
   PRIVATE cPrintdata := {}
   PRIVATE linedata := {}
   PRIVATE gridname := ""
   PRIVATE ajustifiy := {}
   PRIVATE psuccess := .f.
   PRIVATE showwindow := .f.
   PRIVATE aColWidths := {}
   PRIVATE aprinternames := aprinters()
   PRIVATE defaultprinter := GetDefaultPrinter()
   PRIVATE lVertLines := .f.
   PRIVATE lHorLines := .f.
   PRIVATE nTopMargin := 0.0
   PRIVATE nBottomMargin := 0.0
   PRIVATE nLeftMargin := 0.0
   PRIVATE nRightMargin := 0.0
   PRIVATE cPDFFileName := ''
   PRIVATE papernames := {;
      "Letter 8 1/2 x 11 in",;
      "Letter Small 8 1/2 x 11 in",;
      "Tabloid 11 x 17 in",;
      "Ledger 17 x 11 in",;
      "Legal 8 1/2 x 14 in",;
      "Statement 5 1/2 x 8 1/2 in",;
      "Executive 7 1/4 x 10 1/2 in",;
      "A3 297 x 420 mm",;
      "A4 210 x 297 mm",;
      "A4 Small 210 x 297 mm",;
      "A5 148 x 210 mm",;
      "B4 (JIS) 250 x 354",;
      "B5 (JIS) 182 x 257 mm",;
      "Folio 8 1/2 x 13 in",;
      "Quarto 215 x 275 mm",;
      "10x14 in",;
      "11x17 in",;
      "Note 8 1/2 x 11 in",;
      "Envelope #9 3 7/8 x 8 7/8",;
      "Envelope #10 4 1/8 x 9 1/2",;
      "Envelope #11 4 1/2 x 10 3/8",;
      "Envelope #12 4 \276 x 11",;
      "Envelope #14 5 x 11 1/2",;
      "C size sheet",;
      "D size sheet",;
      "E size sheet",;
      "Envelope DL 110 x 220mm",;
      "Envelope C5 162 x 229 mm",;
      "Envelope C3  324 x 458 mm",;
      "Envelope C4  229 x 324 mm",;
      "Envelope C6  114 x 162 mm",;
      "Envelope C65 114 x 229 mm",;
      "Envelope B4  250 x 353 mm",;
      "Envelope B5  176 x 250 mm",;
      "Envelope B6  176 x 125 mm",;
      "Envelope 110 x 230 mm",;
      "Envelope Monarch 3.875 x 7.5 in",;
      "6 3/4 Envelope 3 5/8 x 6 1/2 in",;
      "US Std Fanfold 14 7/8 x 11 in",;
      "German Std Fanfold 8 1/2 x 12 in",;
      "German Legal Fanfold 8 1/2 x 13 in",;
      "B4 (ISO) 250 x 353 mm",;
      "Japanese Postcard 100 x 148 mm",;
      "9 x 11 in",;
      "10 x 11 in",;
      "15 x 11 in",;
      "Envelope Invite 220 x 220 mm",;
      "RESERVED--DO NOT USE",;
      "RESERVED--DO NOT USE",;
      "Letter Extra 9 \275 x 12 in",;
      "Legal Extra 9 \275 x 15 in",;
      "Tabloid Extra 11.69 x 18 in",;
      "A4 Extra 9.27 x 12.69 in",;
      "Letter Transverse 8 \275 x 11 in",;
      "A4 Transverse 210 x 297 mm",;
      "Letter Extra Transverse 9\275 x 12 in",;
      "SuperA/SuperA/A4 227 x 356 mm",;
      "SuperB/SuperB/A3 305 x 487 mm",;
      "Letter Plus 8.5 x 12.69 in",;
      "A4 Plus 210 x 330 mm",;
      "A5 Transverse 148 x 210 mm",;
      "B5 (JIS) Transverse 182 x 257 mm",;
      "A3 Extra 322 x 445 mm",;
      "A5 Extra 174 x 235 mm",;
      "B5 (ISO) Extra 201 x 276 mm",;
      "A2 420 x 594 mm",;
      "A3 Transverse 297 x 420 mm",;
      "A3 Extra Transverse 322 x 445 mm",;
      "Japanese Double Postcard 200 x 148 mm",;
      "A6 105 x 148 mm",;
      "Japanese Envelope Kaku #2",;
      "Japanese Envelope Kaku #3",;
      "Japanese Envelope Chou #3",;
      "Japanese Envelope Chou #4",;
      "Letter Rotated 11 x 8 1/2 11 in",;
      "A3 Rotated 420 x 297 mm",;
      "A4 Rotated 297 x 210 mm",;
      "A5 Rotated 210 x 148 mm",;
      "B4 (JIS) Rotated 364 x 257 mm",;
      "B5 (JIS) Rotated 257 x 182 mm",;
      "Japanese Postcard Rotated 148 x 100 mm",;
      "Double Japanese Postcard Rotated 148 x 200 mm",;
      "A6 Rotated 148 x 105 mm",;
      "Japanese Envelope Kaku #2 Rotated",;
      "Japanese Envelope Kaku #3 Rotated",;
      "Japanese Envelope Chou #3 Rotated",;
      "Japanese Envelope Chou #4 Rotated",;
      "B6 (JIS) 128 x 182 mm",;
      "B6 (JIS) Rotated 182 x 128 mm",;
      "12 x 11 in",;
      "Japanese Envelope You #4",;
      "Japanese Envelope You #4 Rotated",;
      "PRC 16K 146 x 215 mm",;
      "PRC 32K 97 x 151 mm",;
      "PRC 32K(Big) 97 x 151 mm",;
      "PRC Envelope #1 102 x 165 mm",;
      "PRC Envelope #2 102 x 176 mm",;
      "PRC Envelope #3 125 x 176 mm",;
      "PRC Envelope #4 110 x 208 mm",;
      "PRC Envelope #5 110 x 220 mm",;
      "PRC Envelope #6 120 x 230 mm",;
      "PRC Envelope #7 160 x 230 mm",;
      "PRC Envelope #8 120 x 309 mm",;
      "PRC Envelope #9 229 x 324 mm",;
      "PRC Envelope #10 324 x 458 mm",;
      "PRC 16K Rotated",;
      "PRC 32K Rotated",;
      "PRC 32K(Big) Rotated",;
      "PRC Envelope #1 Rotated 165 x 102 mm",;
      "PRC Envelope #2 Rotated 176 x 102 mm",;
      "PRC Envelope #3 Rotated 176 x 125 mm",;
      "PRC Envelope #4 Rotated 208 x 110 mm",;
      "PRC Envelope #5 Rotated 220 x 110 mm",;
      "PRC Envelope #6 Rotated 230 x 120 mm",;
      "PRC Envelope #7 Rotated 230 x 160 mm",;
      "PRC Envelope #8 Rotated 309 x 120 mm",;
      "PRC Envelope #9 Rotated 324 x 229 mm",;
      "PRC Envelope #10 Rotated 458 x 324 mm",;
      "User Defined",;
      }
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
   PRIVATE aData := {}
   PRIVATE lArrayMode := .f.
   PRIVATE nCustomPaperWidth := 0.0
   PRIVATE nCustomPaperHeight := 0.0

   DEFAULT cWindow := ""
   DEFAULT cGrid := ""
   DEFAULT fontsize := 10
   DEFAULT orientation := "P"
   DEFAULT fontname1 := "Helvetica"
   DEFAULT aheaders := {"","",""}
   DEFAULT ShowWindow1 := .f.
   DEFAULT mheaders := {}
   DEFAULT summation := {}
   DEFAULT aArrayData := {}
   DEFAULT aArrayHeaders := {}
   DEFAULT aArrayJustify := {}
   DEFAULT aColumnWidths := {}
   DEFAULT nPaperSize := 0
   DEFAULT nPaperWidth := 0.0
   DEFAULT nPaperHeight := 0.0
   DEFAULT nTop := 20.0
   DEFAULT nBottom := 20.0
   DEFAULT nLeft := 20.0
   DEFAULT nRight := 20.0
   DEFAULT lVerticalLines := .t.
   DEFAULT lHorizontalLines := .t.
   DEFAULT cPDFFile := ''

   windowname := cWindow
   gridname := cGrid
   showwindow := showwindow1
   aData := aclone(aArrayData)
   aDataHeaders := aclone(aArrayHeaders)
   aColWidths := aclone(aColumnWidths)
   nCustomPaperWidth := nPaperWidth
   nCustomPaperHeight := nPaperHeight
   lVertLines := lVerticalLines
   lHorLines := lHorizontalLines
   nTopMargin := nTop
   nBottomMargin := nBottom
   nLeftMargin := nLeft
   nRightMargin := nRight
   cPDFFileName := iif( len( alltrim( cPDFFile ) ) == 0, cWindow + '_' + cGrid + '.pdf', cPDFFile )

   DO CASE
   CASE nPaperSize == 0
      curpagesize := 1
   CASE nPaperSize == 256 // custom
      curpagesize := 119 //len(papernames)
   OTHERWISE
      curpagesize := nPaperSize
   ENDCASE
   pdfinit_messages()

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
   IF len(aData) > 0 // array
      lines := len(aData)
      lArrayMode := .t.
   ELSE // grid
      lines := getproperty(windowname,gridname,"itemcount")
      lArrayMode := .f.
   ENDIF

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
   IF lArrayMode
      linedata := aData[1]
   ELSE
      linedata := getproperty(windowname,gridname,"item",1)
   ENDIF
   asize(sizes,0)
   FOR count1 := 1 to len(linedata)
      aadd(sizes,0)
      aadd(headersizes,0)
      IF lArrayMode
         aadd(headerarr,aDataHeaders[count1])
      ELSE
         aadd(headerarr,getproperty(windowname,gridname,"header",count1))
      ENDIF
      aadd(totalarr,0.0)
   NEXT count1

   IF lArrayMode
      aJustify := aclone(aArrayJustify)
   ELSE
      i := GetControlIndex ( gridname , windowname )

      aJustify := _HMG_aControlMiscData1 [i] [3]

      aEditcontrols := _HMG_aControlMiscData1 [i] [13]
   ENDIF

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
         IF lArrayMode
            linedata := aData[count1]
         ELSE
            linedata := getproperty(windowname,gridname,"item",count1)
         ENDIF
         FOR count2 := 1 to len(linedata)
            IF sumarr[count2,1]
               DO CASE
               CASE ValType(linedata[count2]) == "N"
                  IF .not. lArrayMode
                     xres := _HMG_PARSEGRIDCONTROLS ( AEDITCONTROLS , count2 )
                     AEC := XRES [1]
                     AITEMS := XRES [5]
                     IF AEC == 'COMBOBOX'
                        cPrintdata := aitems[linedata[count2]]
                     ELSE
                        cPrintdata := LTrim( Str( linedata[count2] ) )
                     ENDIF
                  ELSE
                     cPrintdata := LTrim( Str( linedata[count2] ) )
                  ENDIF
               CASE ValType(linedata[count2]) == "D"
                  cPrintdata := dtoc( linedata[count2])
               CASE ValType(linedata[count2]) == "L"
                  IF .not. lArrayMode
                     xres := _HMG_PARSEGRIDCONTROLS ( AEDITCONTROLS , count2 )
                     AEC := XRES [1]
                     AITEMS := XRES [8]
                     IF AEC == 'CHECKBOX'
                        cPrintdata := iif(linedata[count2],aitems[1],aitems[2])
                     ELSE
                        cPrintdata := iif(linedata[count2],"T","F")
                     ENDIF
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

   DEFINE WINDOW pdfgrid at 0,0 width 700 height 440 title msgarr[4] modal noshow nosize nosysmenu on init initpdfgrid()
      DEFINE TAB tab1 at 10,10 width 285 height 335
         DEFINE PAGE msgarr[5]
            DEFINE GRID columns
               ROW 30
               COL 10
               WIDTH 270
               HEIGHT 300
               WIDTHS {130,60,60}
               justify {0,1,0}
               HEADERS {msgarr[6],msgarr[7],msgarr[57]}
               allowedit .t.
               COLUMNCONTROLS {{"TEXTBOX","CHARACTER"},{"TEXTBOX","NUMERIC","9999.99"},{"COMBOBOX",{msgarr[59],msgarr[60]}}}
               COLUMNWHEN {{||.f.},{||iif(pdfgrid.spread.value,.f.,.t.)},{||.t.}}
               columnvalid {{||.t.},{||pdfcolumnsizeverify()},{||pdfcolumnselected()}}
               ON LOSTFOCUS refreshpdfgrid()
            END GRID
            /*
            DEFINE button editdetails
            Row 30
            Col 265
            width 16
            height 16
            tooltip msgarr[9]
            picture "edit"
            tabstop .f.
            action editcoldetails()
            END button
            */
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
               ON CHANGE pdfgridpreview()
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
               ON CHANGE pdfgridpreview()
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
               ON CHANGE pdfgridpreview()
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
               ON CHANGE pdfgridpreview()
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
               ON CHANGE pdffontsizechanged()
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
               ON CHANGE pdfgridpreview()
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
               ON CHANGE pdfgridpreview()
            END COMBOBOX
            DEFINE LABEL separatorlab
               ROW 250
               COL 10
               WIDTH 100
               VALUE msgarr[25]
            END LABEL
            DEFINE CHECKBOX collines
               ROW 245
               COL 110
               WIDTH 60
               ON CHANGE pdfgridpreview()
               CAPTION msgarr[26]
            END CHECKBOX
            DEFINE CHECKBOX rowlines
               ROW 245
               COL 180
               WIDTH 60
               ON CHANGE pdfgridpreview()
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
               ON CHANGE pdfgridpreview()
               CAPTION msgarr[29]
            END CHECKBOX
            DEFINE LABEL spacelab
               ROW 310
               COL 10
               WIDTH 100
               VALUE msgarr[54]
            END LABEL
            DEFINE CHECKBOX spread
               ROW 305
               COL 110
               WIDTH 60
               ON CHANGE pdfspreadchanged()
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
               ON CHANGE pdfpapersizechanged()
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
               ON CHANGE pdfpapersizechanged()
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
               ON CHANGE pdfpagesizechanged()
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
               ON CHANGE pdfpagesizechanged()
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
               ON CHANGE pdfgridpreview()
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
               ON CHANGE pdfpapersizechanged()
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
               ON CHANGE pdfpapersizechanged()
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
               ON CHANGE pdfgridpreview()
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
               WIDTHS {40,40,100}
               allowedit .t.
               COLUMNCONTROLS {{"TEXTBOX","NUMERIC","999"},{"TEXTBOX","NUMERIC","999"},{"TEXTBOX","CHARACTER"}}
               columnvalid {{||.t.},{||.t.},{||.t.}}
               ON LOSTFOCUS pdfmergeheaderschanged()
            END GRID
            DEFINE BUTTON add
               ROW 30
               COL 260
               WIDTH 20
               HEIGHT 20
               CAPTION "+"
               FONTBOLD .t.
               fontsize 16
               //               picture "additem"
               ACTION pdfaddmergeheadrow()
            END BUTTON
            DEFINE BUTTON del
               ROW 55
               COL 260
               WIDTH 20
               HEIGHT 20
               CAPTION "-"
               FONTBOLD .t.
               fontsize 16
               //               picture "delitem"
               ACTION pdfdelmergeheadrow()
            END BUTTON

         END PAGE
      END TAB
      DEFINE BUTTON browseprint1
         ROW 350
         COL 160
         CAPTION msgarr[43]
         ACTION printpdfstart()
         WIDTH 80
      END BUTTON
      DEFINE BUTTON browseprintcancel
         ROW 350
         COL 260
         CAPTION msgarr[44]
         ACTION pdfgrid.release
         WIDTH 80
      END BUTTON
      DEFINE BUTTON browseprintreset
         ROW 350
         COL 360
         CAPTION msgarr[66]
         ACTION resetpdfgridform()
         WIDTH 80
      END BUTTON
      DEFINE STATUSBAR
         statusitem msgarr[45] width 200
         statusitem msgarr[10] + "mm "+msgarr[11]+"mm" width 300
      END STATUSBAR
   END WINDOW
   IF nPaperSize == 256 // custom
      pdfgrid.width.value := nCustomPaperWidth
      pdfgrid.height.value := nCustomPaperHeight
   ENDIF
   pdfgrid.spread.value := .f.
   pdfgrid.selectfontsize.value := fontnumber
   pdfgrid.pagesizes.value := curpagesize
   pdfgrid.top.value := nTopMargin
   pdfgrid.right.value := nRightMargin
   pdfgrid.bottom.value := nBottomMargin
   pdfgrid.left.value := nLeftMargin
   pdfgrid.collines.value := lVertLines
   pdfgrid.rowlines.value := lHorLines
   pdfgrid.header1.value := header1
   pdfgrid.header2.value := header2
   pdfgrid.header3.value := header3
   pdfgrid.wordwrap.value := 2
   pdfgrid.pageno.value := 2
   pdfgrid.vertical.value := .t.
   pdfgrid.paperorientation.value := IIf(orientation == "P",2,1)

   FOR count1 := 1 to len(mergehead)
      IF mergehead[count1,2] >= mergehead[count1,1] .and. iif(count1 > 1,mergehead[count1,1] > mergehead[count1-1,2],.t.)
         pdfgrid.merge.additem({mergehead[count1,1],mergehead[count1,2],mergehead[count1,3]})
      ENDIF
   NEXT count1
   IF pdfgrid.merge.itemcount > 0
      pdfgrid.merge.value := 1
   ENDIF

   FOR count1 := 1 to len(columnarr)
      pdfgrid.columns.additem({columnarr[count1,2],columnarr[count1,3],1})
   NEXT count1
   pdfcalculatecolumnsizes()
   pdfprintcoltally()
   IF pdfgrid.columns.itemcount > 0
      pdfgrid.columns.value := 1
   ENDIF
   pdfgridpreview()
   pdfgrid.center
   pdfgrid.activate()

   RETURN NIL

FUNCTION refreshpdfgrid

   pdfprintcoltally()
   pdfgridpreview()

   RETURN NIL

FUNCTION pdfspreadchanged

   pdfcalculatecolumnsizes()
   refreshpdfgrid()

   RETURN NIL

FUNCTION initpdfgrid

   IF .not. showwindow
      IF pdfgrid.browseprint1.enabled
         pdfgrid.hide
         printpdfstart()
      ELSE
         pdfgridinit()
         //      pdfgrid.show
      ENDIF
   ELSE
      pdfgridinit()
      //   pdfgrid.show
   ENDIF

   RETURN NIL

FUNCTION pdfprintcoltally

   LOCAL col := 0
   LOCAL count1 := 0
   LOCAL count2 := 0
   LOCAL totcol := 0.0

   IF .not. iscontroldefined(browseprintcancel,pdfgrid)

      RETURN NIL
   ENDIF
   IF pdfgrid.spread.value
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
   pdfgrid.statusbar.item(2) := msgarr[10]+" "+alltrim(str(curcol1,12,2))+" "+msgarr[11]+" "+alltrim(str(maxcol2,12,2))

   IF maxcol2 >= curcol1
      pdfgrid.browseprint1.enabled := .t.
      pdfgrid.statusbar.item(1) := msgarr[45]
   ELSE
      pdfgrid.statusbar.item(1) := msgarr[46]
      pdfgrid.browseprint1.enabled := .f.

      RETURN NIL
   ENDIF
   FOR count1 := 1 to len(columnarr)
      pdfgrid.columns.item(count1) := {columnarr[count1,2],columnarr[count1,3],columnarr[count1,1]}
   NEXT count1

   RETURN NIL

FUNCTION pdffontsizechanged

   pdfcalculatecolumnsizes()
   refreshpdfgrid()

   RETURN NIL

FUNCTION pdfcalculatecolumnsizes

   LOCAL fontsize1 := 0
   LOCAL cPrintdata := ""
   LOCAL count1 := 0
   LOCAL count2 := 0
   LOCAL nDecimals := Set( _SET_DECIMALS)
   LOCAL aec := ""
   LOCAL aitems := {}

   IF .not. iscontroldefine(browseprintcancel,pdfgrid)

      RETURN NIL
   ENDIF
   IF len(aColWidths) > 0
      IF lArrayMode
         linedata := aData[1]
      ELSE
         linedata := getproperty(windowname,gridname,"item",1)
      ENDIF
      IF len(linedata) <> len(aColWidths)

         RETURN NIL // Error!
      ENDIF
      asize(sizes,0)
      FOR count1 := 1 to len(linedata)
         aadd(sizes,aColWidths[count1])
         IF aColWidths[count1] == 0
            columnarr[count1,1] := 2
         ELSE
            columnarr[count1,1] := 1
         ENDIF
         columnarr[count1,3] := aColWidths[count1]
      NEXT count1
   ELSE
      fontsize1 := val(alltrim(pdfgrid.selectfontsize.item(pdfgrid.selectfontsize.value)))
      IF fontsize1 > 0
         IF lArrayMode
            linedata := aData[1]
         ELSE
            linedata := getproperty(windowname,gridname,"item",1)
         ENDIF
         asize(sizes,0)
         asize(headersizes,0)
         FOR count1 := 1 to len(linedata)
            aadd(sizes,0)
            aadd(headersizes,0)
         NEXT count1
         FOR count1 := 1 to lines
            IF lArrayMode
               linedata := aData[count1]
            ELSE
               linedata := getproperty(windowname,gridname,"item",count1)
            ENDIF
            FOR count2 := 1 to len(linedata)
               DO CASE
               CASE ValType(linedata[count2]) == "N"
                  IF .not. lArrayMode
                     xres := _HMG_PARSEGRIDCONTROLS ( AEDITCONTROLS , count2 )
                     AEC := XRES [1]
                     AITEMS := XRES [5]
                     IF AEC == 'COMBOBOX'
                        cPrintdata := aitems[linedata[count2]]
                     ELSE
                        cPrintdata := LTrim( Str( linedata[count2] ) )
                     ENDIF
                  ELSE
                     cPrintdata := LTrim( Str( linedata[count2] ) )
                  ENDIF
               CASE ValType(linedata[count2]) == "D"
                  cPrintdata := dtoc( linedata[count2])
               CASE ValType(linedata[count2]) == "L"
                  IF .not. lArrayMode
                     xres := _HMG_PARSEGRIDCONTROLS ( AEDITCONTROLS , count2 )
                     AEC := XRES [1]
                     AITEMS := XRES [8]
                     IF AEC == 'CHECKBOX'
                        cPrintdata := iif(linedata[count2],aitems[1],aitems[2])
                     ELSE
                        cPrintdata := iif(linedata[count2],"T","F")
                     ENDIF
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
   ENDIF

   RETURN NIL

FUNCTION printpdfstart

   LOCAL row := 0
   LOCAL col := 0
   LOCAL lh := 0 // line height
   LOCAL pageno := 0
   LOCAL printdata := {}
   LOCAL justifyarr := {}
   LOCAL maxrow1 := 0
   LOCAL maxcol1 := curcol1
   LOCAL maxlines := 0
   LOCAL totrows := 0
   LOCAL leftspace := 0
   LOCAL rightspace := 0
   LOCAL firstrow := 0
   LOCAL size1 := 0
   LOCAL data1 := ""
   LOCAL paperwidth := pdfgrid.width.value
   LOCAL paperheight := pdfgrid.height.value
   LOCAL totcols := 0
   LOCAL papersize := 0
   LOCAL sizesarr := {}
   LOCAL totcol := 0
   LOCAL colcount := 0
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
   LOCAL nDecimals := Set( _SET_DECIMALS)
   LOCAL aec := ""
   LOCAL aitems := {}
   LOCAL gridprintdata := array(20)
   LOCAL printername := ""
   LOCAL nPrintGap := 0.5
   LOCAL startcol
   LOCAL endcol
   LOCAL headdata
   LOCAL printpdfstart
   LOCAL printend
   LOCAL colreqd
   LOCAL size
   LOCAL lastrow

   WAIT window 'Please wait while exporting to PDF' nowait

   IF lArrayMode
      totrows := len(aData)
   ELSE
      totrows := getproperty(windowname,gridname,"itemcount")
   ENDIF

   IF pdfgrid.printers.value > 0
      printername := AllTrim(pdfgrid.printers.item(pdfgrid.printers.value))
   ELSE
      msgstop(msgarr[47],msgarr[3])

      RETURN NIL
   ENDIF

   DO CASE
   CASE pdfgrid.pagesizes.value == pdfgrid.pagesizes.itemcount // custom
      papersize := PRINTER_PAPER_USER
   OTHERWISE
      papersize := pdfgrid.pagesizes.value
   ENDCASE

   IF pdfgrid.pagesizes.value == pdfgrid.pagesizes.itemcount // custom

      SELECT PRINTER cPDFFileName TO psuccess ORIENTATION IIf(pdfgrid.paperorientation.value == 1,PRINTER_ORIENT_LANDSCAPE,PRINTER_ORIENT_PORTRAIT);
         PAPERSIZE papersize;
         PAPERLENGTH iif(pdfgrid.paperorientation.value == 1,pdfgrid.width.value,pdfgrid.height.value);
         PAPERWIDTH iif(pdfgrid.paperorientation.value == 1,pdfgrid.height.value,pdfgrid.width.value) PREVIEW
   ELSE
      SELECT PRINTER cPDFFileName TO psuccess ORIENTATION IIf(pdfgrid.paperorientation.value == 1,PRINTER_ORIENT_LANDSCAPE,PRINTER_ORIENT_PORTRAIT);
         PAPERSIZE papersize PREVIEW
   ENDIF
   IF .not. psuccess
      msgstop(msgarr[48],msgarr[3])

      RETURN NIL
   ENDIF

   size1 := val(alltrim(pdfgrid.selectfontsize.item(pdfgrid.selectfontsize.value)))

   // Save Config
   IF .not. lArrayMode
      BEGIN INI FILE "reports.cfg"
         // columns
         gridprintdata[1] := {}
         FOR count1 := 1 to pdfgrid.columns.itemcount
            aadd(gridprintdata[1],pdfgrid.columns.item(count1))
         NEXT count1
         // headers
         gridprintdata[2] := {}
         aadd(gridprintdata[2],pdfgrid.header1.value)
         aadd(gridprintdata[2],pdfgrid.header2.value)
         aadd(gridprintdata[2],pdfgrid.header3.value)
         // footer
         gridprintdata[3] := pdfgrid.footer1.value
         //fontsize
         gridprintdata[4] := pdfgrid.selectfontsize.value
         // wordwrap
         gridprintdata[5] := pdfgrid.wordwrap.value
         // pagination
         gridprintdata[6] := pdfgrid.pageno.value
         // collines
         gridprintdata[7] := pdfgrid.collines.value
         // rowlines
         gridprintdata[8] := pdfgrid.rowlines.value
         // vertical center
         gridprintdata[9] := pdfgrid.vertical.value
         // space spread
         gridprintdata[10] := pdfgrid.spread.value
         // orientation
         gridprintdata[11] := pdfgrid.paperorientation.value
         // printers
         gridprintdata[12] := pdfgrid.printers.value
         // pagesize
         gridprintdata[13] := pdfgrid.pagesizes.value
         // paper width
         gridprintdata[14] := pdfgrid.width.value
         // paper height
         gridprintdata[15] := pdfgrid.height.value
         // margin top
         gridprintdata[16] := pdfgrid.top.value
         // margin right
         gridprintdata[17] := pdfgrid.right.value
         // margin left
         gridprintdata[18] := pdfgrid.left.value
         // margin bottom
         gridprintdata[19] := pdfgrid.bottom.value
         // merge headers data
         gridprintdata[20] := {}
         FOR count1 := 1 to pdfgrid.merge.itemcount
            aadd(gridprintdata[20],pdfgrid.merge.item(count1))
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
   ENDIF

   START PRINTDOC
      ROW := pdfgrid.top.value
      maxrow1 := pdfgrid.height.value - pdfgrid.bottom.value
      IF pdfgrid.vertical.value
         COL := (pdfgrid.width.value - curcol1)/2
      ELSE
         COL := pdfgrid.left.value
      ENDIF
      lh := Int((size1/72 * 25.4)) + 1 // line height
      START PRINTPAGE
         pageno := 1
         IF pdfgrid.pageno.value == 2
            @ Row,(col+maxcol1 - printlen(msgarr[49]+alltrim(str(pageno,10,0)),size1,fontname) - 5) print msgarr[49]+alltrim(str(pageno,10,0)) font fontname size size1
            ROW := row + lh
         ENDIF
         IF Len(AllTrim(pdfgrid.header1.value)) > 0
            @ Row+(lh/2),col+Int(maxcol1/2) print AllTrim(pdfgrid.header1.value) font fontname size size1+2 center
            ROW := row + lh + lh
         ENDIF
         IF Len(AllTrim(pdfgrid.header2.value)) > 0
            @ Row+(lh/2),col+Int(maxcol1/2) print AllTrim(pdfgrid.header2.value) font fontname size size1+2 center
            ROW := row + lh + lh
         ENDIF
         IF Len(AllTrim(pdfgrid.header3.value)) > 0
            @ Row+(lh/2),col+Int(maxcol1/2) print AllTrim(pdfgrid.header3.value) font fontname size size1+2 center
            ROW := row + lh + lh
         ENDIF

         IF len(mergehead) > 0
            @ Row - lh + nPrintGap ,Col-1  print line TO Row - lh + nPrintGap,col+maxcol1-1 penwidth 0.25
            FOR count1 := 1 to len(mergehead)
               startcol := mergehead[count1,1]
               endcol := mergehead[count1,2]
               headdata := mergehead[count1,3]
               printpdfstart := 0
               printend := 0
               FOR count2 := 1 to endcol
                  IF count2 < startcol
                     IF columnarr[count2,1] == 1
                        printpdfstart := printpdfstart + columnarr[count2,3] + 2
                     ENDIF
                  ENDIF
                  IF columnarr[count2,1] == 1
                     printend := printend + columnarr[count2,3] + 2
                  ENDIF
               NEXT count2
               IF printend > printpdfstart
                  IF printLen(AllTrim(headdata),size1,fontname) > (printend - printpdfstart)
                     count3 := len(headdata)
                     DO WHILE printlen(substr(headdata,1,count3),size1,fontname) > (printend - printpdfstart)
                        count3 := count3 - 1
                     ENDDO
                  ENDIF
                  @ Row,col+printpdfstart+int((printend-printpdfstart)/2) print headdata font fontname size size1 center
                  @ Row+ nPrintGap,col-1+printpdfstart print line TO Row+ nPrintGap ,col-1+printend penwidth 0.25
               ENDIF
            NEXT count1
            @ row-lh+ nPrintGap,col-1 print line to row+ nPrintGap,col-1 penwidth 0.25
            @ row-lh+ nPrintGap,col-1+maxcol1 print line to row+ nPrintGap,col-1+maxcol1 penwidth 0.25
            IF pdfgrid.collines.value
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
                        @ row-lh+ nPrintGap,col+totcol+(colcount * 2)-1 print line TO row+ nPrintGap,col+totcol+(colcount * 2)-1 penwidth 0.25
                     ENDIF
                  ENDIF
               NEXT count2
            ENDIF
            ROW := row + lh
         ELSE
            @ Row - lh + nPrintGap,Col-1  print line TO Row - lh + nPrintGap,col+maxcol1-1 penwidth 0.25
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
         pdfprintline(row,col,printdata,justifyarr,sizesarr,fontname,size1)
         ROW := row + lh
         @ Row-lh+ nPrintGap,Col-1 print line TO Row-lh+ nPrintGap,col+maxcol1-1 penwidth 0.25
         FOR count1 := 1 TO totrows
            IF lArrayMode
               linedata := aData[count1]
            ELSE
               linedata := getproperty(windowname,gridname,"item",count1)
            ENDIF
            ASize(printdata,0)
            asize(nextline,0)
            FOR count2 := 1 TO Len(columnarr)
               IF columnarr[count2,1] == 1
                  size := columnarr[count2,3]
                  DO CASE
                  CASE ValType(linedata[count2]) == "N"
                     IF .not. lArrayMode
                        xres := _HMG_PARSEGRIDCONTROLS ( AEDITCONTROLS , count2 )
                        AEC := XRES [1]
                        AITEMS := XRES [5]
                        IF AEC == 'COMBOBOX'
                           cPrintdata := aitems[linedata[count2]]
                        ELSE
                           cPrintdata := LTrim( Str( linedata[count2] ) )
                        ENDIF
                     ELSE
                        cPrintdata := LTrim( Str( linedata[count2] ) )
                     ENDIF
                  CASE ValType(linedata[count2]) == "D"
                     cPrintdata := dtoc( linedata[count2])
                  CASE ValType(linedata[count2]) == "L"
                     IF .not. lArrayMode
                        xres := _HMG_PARSEGRIDCONTROLS ( AEDITCONTROLS , count2 )
                        AEC := XRES [1]
                        AITEMS := XRES [8]
                        IF AEC == 'CHECKBOX'
                           cPrintdata := iif(linedata[count2],aitems[1],aitems[2])
                        ELSE
                           cPrintdata := iif(linedata[count2],"T","F")
                        ENDIF
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
                     IF pdfgrid.wordwrap.value == 2 // truncate
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
               ELSE
                  aadd(nextline,0)
               ENDIF
            NEXT count2
            pdfprintline(row,col,printdata,justifyarr,sizesarr,fontname,size1,lh)
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
               pdfprintline(row,col,printdata,justifyarr,sizesarr,fontname,size1,lh)
               ROW := Row + lh
               dataprintover := .t.
               FOR count2 := 1 to len(nextline)
                  IF nextline[count2] > 0
                     dataprintover := .f.
                  ENDIF
               NEXT count2
            ENDDO

            IF Row+iif(len(sumarr)>0,(3*lh),lh)+iif(len(alltrim(pdfgrid.footer1.value))>0,lh,0) >= maxrow1 // 2 lines for total & 1 line for footer
               @ Row-lh+ nPrintGap,Col-1 print line TO Row-lh+ nPrintGap,col+maxcol1-1  penwidth 0.25
               IF len(sumarr) > 0
                  ROW := row + lh
                  @ Row-lh+ nPrintGap,Col-1 print line TO Row-lh+ nPrintGap,col+maxcol1-1  penwidth 0.25
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
                  pdfprintline(row,col,printdata,justifyarr,sizesarr,fontname,size1,lh)
                  ROW := Row + lh
                  @ Row-lh+ nPrintGap,Col-1 print line TO Row-lh+ nPrintGap,col+maxcol1-1  penwidth 0.25
               ELSE
                  @ Row-lh+ nPrintGap,Col-1 print line TO Row-lh+ nPrintGap,col+maxcol1-1  penwidth 0.25
               ENDIF
               lastrow := Row
               totcol := 0
               @ firstrow-lh+ nPrintGap,Col-1 print line TO lastrow-lh+ nPrintGap,Col-1  penwidth 0.25
               IF pdfgrid.collines.value
                  colcount := 0
                  FOR count2 := 1 to len(columnarr)
                     IF columnarr[count2,1] == 1
                        totcol := totcol + columnarr[count2,3]
                        colcount := colcount + 1
                        @ firstrow-lh+ nPrintGap,col+totcol+(colcount * 2)-1 print line TO lastrow-lh+ nPrintGap,col+totcol+(colcount * 2)-1 penwidth 0.25
                     ENDIF
                  NEXT count2
               ENDIF
               @ firstrow-lh+ nPrintGap,col+maxcol1-1 print line TO lastrow-lh+ nPrintGap,col+maxcol1-1 penwidth 0.25
               IF Len(AllTrim(pdfgrid.footer1.value)) > 0
                  @ Row+(lh/2),col+Int(maxcol1/2) print AllTrim(pdfgrid.footer1.value) font fontname size size1+2 center
                  ROW := row + lh + lh
               ENDIF
               IF pdfgrid.pageno.value == 3
                  ROW := Row + lh
                  @ Row,(col+maxcol1 - printlen(msgarr[49]+alltrim(str(pageno,10,0)),size1,fontname) - 5) print msgarr[49]+alltrim(str(pageno,10,0)) font fontname size size1
               ENDIF
            END PRINTPAGE
            pageno := pageno + 1
            ROW := pdfgrid.top.value
            START PRINTPAGE
               IF pdfgrid.pageno.value == 2
                  @ Row,(col+maxcol1 - printlen(msgarr[49]+alltrim(str(pageno,10,0)),size1,fontname) - 5) print msgarr[49]+alltrim(str(pageno,10,0)) font fontname size size1
                  ROW := row + lh
               ENDIF
               IF Len(AllTrim(pdfgrid.header1.value)) > 0
                  @ Row+(lh/2),col+Int(maxcol1/2) print AllTrim(pdfgrid.header1.value) font fontname size size1+2 center
                  ROW := row + lh + lh
               ENDIF
               IF Len(AllTrim(pdfgrid.header2.value)) > 0
                  @ Row+(lh/2),col+Int(maxcol1/2) print AllTrim(pdfgrid.header2.value) font fontname size size1+2 center
                  ROW := row + lh + lh
               ENDIF
               IF Len(AllTrim(pdfgrid.header3.value)) > 0
                  @ Row+(lh/2),col+Int(maxcol1/2) print AllTrim(pdfgrid.header3.value) font fontname size size1+2 center
                  ROW := row + lh + lh
               ENDIF
               IF len(mergehead) > 0
                  @ Row -lh+ nPrintGap,Col-1  print line TO Row-lh+ nPrintGap ,col+maxcol1-1 penwidth 0.25
                  FOR count4 := 1 to len(mergehead)
                     startcol := mergehead[count4,1]
                     endcol := mergehead[count4,2]
                     headdata := mergehead[count4,3]
                     printpdfstart := 0
                     printend := 0
                     FOR count5 := 1 to endcol
                        IF count5 < startcol
                           IF columnarr[count5,1] == 1
                              printpdfstart := printpdfstart + columnarr[count5,3] + 2
                           ENDIF
                        ENDIF
                        IF columnarr[count5,1] == 1
                           printend := printend + columnarr[count5,3] + 2
                        ENDIF
                     NEXT count5
                     IF printend > printpdfstart
                        IF printLen(AllTrim(headdata),size1,fontname) > (printend - printpdfstart)
                           count6 := len(headdata)
                           DO WHILE printlen(substr(headdata,1,count6),size1,fontname) > (printend - printpdfstart)
                              count6 := count6 - 1
                           ENDDO
                        ENDIF
                        @ Row,col+printpdfstart+int((printend-printpdfstart)/2) print headdata font fontname size size1 center
                        @ Row+ nPrintGap,col-1+printpdfstart print line TO Row + nPrintGap,col-1+printend penwidth 0.25
                     ENDIF
                  NEXT count4
                  @ row-lh+ nPrintGap,col-1 print line to row+ nPrintGap,col-1 penwidth 0.25
                  @ row-lh+ nPrintGap,col-1+maxcol1 print line to row+ nPrintGap,col-1+maxcol1 penwidth 0.25
                  totcol := 0
                  IF pdfgrid.collines.value
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
                              @ row-lh+ nPrintGap,col+totcol+(colcount * 2)-1 print line TO row+ nPrintGap,col+totcol+(colcount * 2)-1 penwidth 0.25
                           ENDIF
                        ENDIF
                     NEXT count5
                  ENDIF
                  ROW := row + lh
               ELSE
                  @ Row - lh+ nPrintGap ,Col-1  print line TO Row -lh+ nPrintGap,col+maxcol1-1 penwidth 0.25
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
               pdfprintline(row,col,printdata,justifyarr,sizesarr,fontname,size1)
               ROW := row + lh
               @ Row-lh+ nPrintGap,Col-1 print line TO Row-lh+ nPrintGap,col+maxcol1-1 penwidth 0.25
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
                  pdfprintline(row,col,printdata,justifyarr,sizesarr,fontname,size1,lh)
                  ROW := Row + lh
                  @ Row-lh+ nPrintGap,Col-1 print line TO Row-lh+ nPrintGap,col+maxcol1-1  penwidth 0.25
                  ROW := Row + lh
                  @ Row-lh+ nPrintGap,Col-1 print line TO Row-lh+ nPrintGap,col+maxcol1-1  penwidth 0.25
               ENDIF
            ELSE
               IF pdfgrid.rowlines.value
                  @ Row-lh+ nPrintGap,Col-1 print line TO Row-lh+ nPrintGap,col+maxcol1-1 penwidth 0.25
               ENDIF
            ENDIF
         NEXT count1
         @ Row-lh+ nPrintGap,Col-1 print line TO Row-lh+ nPrintGap,col+maxcol1-1 penwidth 0.25
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
            pdfprintline(row,col,printdata,justifyarr,sizesarr,fontname,size1,lh)
            ROW := Row + lh
            @ Row-lh+ nPrintGap,Col-1 print line TO Row-lh+ nPrintGap,col+maxcol1-1  penwidth 0.25
         ENDIF
         lastrow := Row
         totcol := 0
         colcount := 0
         @ firstrow-lh+ nPrintGap,Col-1 print line TO lastrow-lh+ nPrintGap,Col-1 penwidth 0.25
         IF pdfgrid.collines.value
            FOR count1 := 1 to len(columnarr)
               IF columnarr[count1,1] == 1
                  totcol := totcol + columnarr[count1,3]
                  colcount := colcount + 1
                  @ firstrow-lh+ nPrintGap,col+totcol+(colcount * 2)-1 print line TO lastrow-lh+ nPrintGap,col+totcol+(colcount * 2)-1 penwidth 0.25
               ENDIF
            NEXT count2
         ENDIF
         @ firstrow-lh+ nPrintGap,col+maxcol1-1 print line TO lastrow-lh+ nPrintGap,col+maxcol1-1 penwidth 0.25

         IF Len(AllTrim(pdfgrid.footer1.value)) > 0
            @ Row+(lh/2),col+Int(maxcol1/2) print AllTrim(pdfgrid.footer1.value) font fontname size size1+2 center
            ROW := row + lh + lh
         ENDIF
         IF pdfgrid.pageno.value == 3
            ROW := Row + lh
            @ Row,(col+maxcol1 - printlen(msgarr[49]+alltrim(str(pageno,10,0)),size1,fontname) - 5) print msgarr[49]+alltrim(str(pageno,10,0)) font fontname size size1
         ENDIF
      END PRINTPAGE
   END PRINTDOC
   WAIT clear
   IF iswindowactive(pdfgrid)
      pdfgrid.release
   ENDIF

   RETURN NIL

FUNCTION pdfgridtoggle

   LOCAL lineno := pdfgrid.columns.value

   IF this.cellvalue == 1
      columnarr[lineno,1] := 1
   ELSE
      IF this.cellvalue == 2
         columnarr[lineno,1] := 2
      ENDIF
   ENDIF
   refreshpdfgrid()

   RETURN .t.

FUNCTION pdfeditcoldetails

   LOCAL lineno := pdfgrid.columns.value
   LOCAL columnsize := 0

   IF lineno > 0
      pdfgrid.size.value := columnarr[lineno,3]
      IF ajustify[lineno] == 0 .or. ajustify[lineno] == 2

         RETURN .t.
      ELSE

         RETURN .f.
         //      msginfo(msgarr[52])
      ENDIF
   ENDIF

   RETURN .f.

FUNCTION pdfprintline(row,col,aitems,ajustify,sizesarr,fontname,size1)

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

FUNCTION pdfprintLen( cString,fontsize,fontname)

   LOCAL oTempDoc := nil
   LOCAL oTempPage := nil
   LOCAL oFont := nil
   LOCAL nLength := 0

   oTempDoc := HPDF_New()
   oTempPage := HPDF_AddPage( oTempDoc )
   HPDF_Page_SetWidth( oTempPage, 576 )
   HPDF_Page_SetHeight( oTempPage, 792 )
   oFont := HPDF_GetFont( oTempDoc, fontname, NIL )
   IF oFont <> nil
      HPDF_Page_SetFontAndSize( oTempPage, oFont, FontSize )
      nLength := _HMG_HPDF_Pixel2MM( HPDF_Page_TextWidth( oTempPage, cString ) )
   ENDIF
   HPDF_Free( oTempDoc )

   RETURN nLength

FUNCTION pdfpagesizechanged

   IF iscontroldefined(browseprintcancel,pdfgrid)
      maxcol2 := pdfgrid.width.value - pdfgrid.left.value - pdfgrid.right.value
      pdfgrid.statusbar.item(2) := msgarr[10]+" "+alltrim(str(curcol1,12,2))+" "+msgarr[11]+" "+alltrim(str(maxcol2,12,2))
      refreshpdfgrid()
   ENDIF

   RETURN NIL

FUNCTION pdfpapersizechanged

   LOCAL printername := ""
   LOCAL papersize := 0
   LOCAL vo := 0.0
   LOCAL ho := 0.0

   IF .not. iscontroldefine(browseprintcancel,pdfgrid)

      RETURN NIL
   ENDIF

   IF pdfgrid.printers.value > 0
      printername := AllTrim(pdfgrid.printers.item(pdfgrid.printers.value))
   ELSE
      msgstop(msgarr[47],msgarr[3])

      RETURN NIL
   ENDIF

   DO CASE
   CASE pdfgrid.pagesizes.value == pdfgrid.pagesizes.itemcount // custom
      papersize := PRINTER_PAPER_USER
   OTHERWISE
      papersize := pdfgrid.pagesizes.value
   ENDCASE

   IF pdfgrid.pagesizes.value == pdfgrid.pagesizes.itemcount // custom
      SELECT PRINTER printername TO psuccess ORIENTATION IIf(pdfgrid.paperorientation.value == 1,PRINTER_ORIENT_LANDSCAPE,PRINTER_ORIENT_PORTRAIT);
         PAPERSIZE papersize;
         PAPERLENGTH iif(pdfgrid.paperorientation.value == 1,pdfgrid.width.value,pdfgrid.height.value);
         PAPERWIDTH iif(pdfgrid.paperorientation.value == 1,pdfgrid.height.value,pdfgrid.width.value);
         COPIES 1
   ELSE
      SELECT PRINTER printername TO psuccess ORIENTATION IIf(pdfgrid.paperorientation.value == 1,PRINTER_ORIENT_LANDSCAPE,PRINTER_ORIENT_PORTRAIT);
         PAPERSIZE papersize;
         COPIES 1
   ENDIF
   IF .not. psuccess
      msgstop(msgarr[48],msgarr[3])

      RETURN NIL
   ENDIF

   IF papersize <> 256 // not custom
      HO := GETPRINTABLEAREAHORIZONTALOFFSET()
      VO := GETPRINTABLEAREAVERTICALOFFSET()

      pdfgrid.width.value := GETPRINTABLEAREAWIDTH() + ( HO * 2 )
      pdfgrid.height.value := GETPRINTABLEAREAHEIGHT() + ( VO * 2 )
   ENDIF

   IF pdfgrid.pagesizes.value > 0
      /*
      if pdfgrid.paperorientation.value == 2 //portrait
      pdfgrid.width.value := papersizes[pdfgrid.pagesizes.value,1]
      pdfgrid.height.value := papersizes[pdfgrid.pagesizes.value,2]
      else // landscape
      pdfgrid.width.value := papersizes[pdfgrid.pagesizes.value,2]
      pdfgrid.height.value := papersizes[pdfgrid.pagesizes.value,1]
      endif
      */
      maxcol2 := pdfgrid.width.value - pdfgrid.left.value - pdfgrid.right.value
      pdfgrid.statusbar.item(2) := msgarr[10]+" "+alltrim(str(curcol1,12,2))+" "+msgarr[11]+" "+alltrim(str(maxcol2,12,2))
   ENDIF
   IF pdfgrid.pagesizes.value == pdfgrid.pagesizes.itemcount // custom
      pdfgrid.width.readonly := .f.
      pdfgrid.height.readonly := .f.
   ELSE
      pdfgrid.width.readonly := .t.
      pdfgrid.height.readonly := .t.
   ENDIF
   refreshpdfgrid()

   RETURN NIL

FUNCTION pdfgridpreview

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
   LOCAL totrows := 0
   LOCAL firstrow := 0
   LOCAL size1 := 0
   LOCAL data1 := ""
   LOCAL sizesarr := {}
   LOCAL totcol := 0
   LOCAL maxrow1 := 0
   LOCAL maxcol1 := 0.0
   LOCAL pl := 0
   LOCAL colcount := 0
   LOCAL nextline := {}
   LOCAL count1 := 0
   LOCAL count2 := 0
   LOCAL count3 := 0
   LOCAL count4 := 0
   LOCAL count5 := 0
   LOCAL count6 := 0
   LOCAL count7 := 0
   LOCAL cPrintdata := ""
   LOCAL nDecimals := Set( _SET_DECIMALS)
   LOCAL aec := ""
   LOCAL aitems := {}
   LOCAL startcol
   LOCAL endcol
   LOCAL headdata
   LOCAL printpdfstart
   LOCAL printend
   LOCAL colreqd
   LOCAL size
   LOCAL dataprintover
   LOCAL lastrow

   IF lArrayMode
      totrows := len(aData)
   ELSE
      totrows := getproperty(windowname,gridname,"itemcount")
   ENDIF

   IF .not. iscontroldefine(browseprintcancel,pdfgrid)

      RETURN NIL
   ENDIF

   WIDTH := pdfgrid.width.value
   HEIGHT := pdfgrid.height.value
   maxcol1 := curcol1

   IF maxwidth >= width .and. maxheight >= height
      resize := 1 // resize not required
   ELSE
      resize := min(maxwidth/width,maxheight/height)
   ENDIF

   curx := startx + (maxheight - (height * resize))/2 + 10
   cury := starty + (maxwidth - (width * resize))/2 + 10
   ERASE WINDOW pdfgrid
   DRAW RECTANGLE IN WINDOW pdfgrid AT curx,cury   TO curx + (height * resize),cury + (width * resize) FILLCOLOR {255,255,255}

   size1 := val(alltrim(pdfgrid.selectfontsize.item(pdfgrid.selectfontsize.value)))

   maxrow1 := curx + ((pdfgrid.height.value - pdfgrid.bottom.value) * resize)
   curx := curx+ (pdfgrid.top.value * resize)
   maxcol1 := (maxcol1) * resize
   IF pdfgrid.vertical.value
      cury := cury + ((pdfgrid.width.value - curcol1)/2 * resize)
   ELSE
      cury := cury + (pdfgrid.left.value * resize)
   ENDIF

   lh := (Int((size1/72 * 25.4)) + 1) * resize // line height
   pageno := 1
   IF pdfgrid.pageno.value == 2
      pl := printlen(msgarr[49]+alltrim(str(pageno,10,0)),size1,fontname)*resize
      DRAW LINE in window pdfgrid at curx,cury+maxcol1 - pl to curx,cury+maxcol1
      curx := curx + lh
   ENDIF
   IF Len(AllTrim(pdfgrid.header1.value)) > 0
      pl := printlen(AllTrim(pdfgrid.header1.value),size1,fontname) * resize
      DRAW LINE in window pdfgrid at curx+(lh/2),cury + ((maxcol1 - pl)/2) to curx+(lh/2),cury + ((maxcol1 - pl)/2) + pl
      curx := curx + lh + lh
   ENDIF
   IF Len(AllTrim(pdfgrid.header2.value)) > 0
      pl := printlen(AllTrim(pdfgrid.header2.value),size1,fontname) * resize
      DRAW LINE in window pdfgrid at curx+(lh/2),cury + ((maxcol1 - pl)/2) to curx+(lh/2),cury + ((maxcol1 - pl)/2) + pl
      curx := curx + lh + lh
   ENDIF
   IF Len(AllTrim(pdfgrid.header3.value)) > 0
      pl := printlen(AllTrim(pdfgrid.header3.value),size1,fontname) * resize
      DRAW LINE in window pdfgrid at curx+(lh/2),cury + ((maxcol1 - pl)/2) to curx+(lh/2),cury + ((maxcol1 - pl)/2) + pl
      curx := curx + lh + lh
   ENDIF

   IF len(mergehead) > 0
      DRAW LINE in window pdfgrid at curx,cury to curx,cury+maxcol1-(1*resize)
      FOR count1 := 1 to len(mergehead)
         startcol := mergehead[count1,1]
         endcol := mergehead[count1,2]
         headdata := mergehead[count1,3]
         printpdfstart := 0
         printend := 0
         FOR count2 := 1 to endcol
            IF count2 < startcol
               IF columnarr[count2,1] == 1
                  printpdfstart := printpdfstart + columnarr[count2,3] + 2
               ENDIF
            ENDIF
            IF columnarr[count2,1] == 1
               printend := printend + columnarr[count2,3] + 2
            ENDIF
         NEXT count2
         IF printend > printpdfstart
            IF printLen(AllTrim(headdata),size1,fontname) > (printend - printpdfstart)
               count3 := len(headdata)
               DO WHILE printlen(substr(headdata,1,count3),size1,fontname) > (printend - printpdfstart)
                  count3 := count3 - 1
               ENDDO
            ENDIF
            pl := printlen(AllTrim(headdata),size1,fontname)
            DRAW LINE in window pdfgrid at curx+(lh/2),cury + (printpdfstart * resize) + ((((printend-printpdfstart) - pl)/2)*resize) to curx+(lh/2),cury + (printpdfstart * resize) + ((((printend-printpdfstart) - pl)/2)*resize)+(pl*resize)
            DRAW LINE in window pdfgrid at curx+lh,cury+(printpdfstart*resize) TO curx+lh,cury+(printend*resize)
         ENDIF
      NEXT count1
      DRAW LINE in window pdfgrid at curx,cury to curx+lh,cury
      DRAW LINE in window pdfgrid at curx,cury+maxcol1-(1*resize) to curx+lh,cury+maxcol1-(1*resize)
      IF pdfgrid.collines.value
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
                  DRAW LINE in window pdfgrid at curx,cury-1+((totcol+(colcount * 2)) * resize) to curx+lh,cury-1+((totcol+(colcount * 2)) * resize)
               ENDIF
            ENDIF
         NEXT count2
      ENDIF
      curx := curx + lh
   ELSE
      DRAW LINE in window pdfgrid at curx,cury to curx,cury+maxcol1-(1*resize)
   ENDIF

   firstrow := curx
   //draw line in window pdfgrid at curx,cury to curx,cury+maxcol1-(1*resize)
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
   pdfprintpreviewline(curx+(lh/2),cury,printdata,justifyarr,sizesarr,fontname,size1,resize)
   curx := curx + lh
   DRAW LINE in window pdfgrid at curx,cury to curx,cury+maxcol1-(1*resize)
   FOR count1 := 1 TO totrows
      IF lArrayMode
         linedata := aData[count1]
      ELSE
         linedata := getproperty(windowname,gridname,"item",count1)
      ENDIF
      ASize(printdata,0)
      asize(nextline,0)
      FOR count2 := 1 TO Len(columnarr)
         IF columnarr[count2,1] == 1
            size := columnarr[count2,3]
            DO CASE
            CASE ValType(linedata[count2]) == "N"
               IF .not. lArrayMode
                  xres := _HMG_PARSEGRIDCONTROLS ( AEDITCONTROLS , count2 )
                  AEC := XRES [1]
                  AITEMS := XRES [5]
                  IF AEC == 'COMBOBOX'
                     cPrintdata := aitems[linedata[count2]]
                  ELSE
                     cPrintdata := LTrim( Str( linedata[count2] ) )
                  ENDIF
               ELSE
                  cPrintdata := LTrim( Str( linedata[count2] ) )
               ENDIF
            CASE ValType(linedata[count2]) == "D"
               cPrintdata := dtoc( linedata[count2])
            CASE ValType(linedata[count2]) == "L"
               IF .not. lArrayMode
                  xres := _HMG_PARSEGRIDCONTROLS ( AEDITCONTROLS , count2 )
                  AEC := XRES [1]
                  AITEMS := XRES [8]
                  IF AEC == 'CHECKBOX'
                     cPrintdata := iif(linedata[count2],aitems[1],aitems[2])
                  ELSE
                     cPrintdata := iif(linedata[count2],"T","F")
                  ENDIF
               ENDIF
            OTHERWISE
               cPrintdata := linedata[count2]
            ENDCASE
            data1 := cPrintdata
            IF printLen(AllTrim(data1),size1,fontname) <= size
               aadd(printdata,alltrim(data1))
               aadd(nextline,0)
            ELSE
               IF pdfgrid.wordwrap.value == 2
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
         ELSE
            aadd(nextline,0)
         ENDIF
      NEXT count2
      pdfprintpreviewline(curx+(lh/2),cury,printdata,justifyarr,sizesarr,fontname,size1,resize)
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
         pdfprintpreviewline(curx+(lh/2),cury,printdata,justifyarr,sizesarr,fontname,size1,resize)
         curx := curx + lh
         dataprintover := .t.
         FOR count2 := 1 to len(nextline)
            IF nextline[count2] > 0
               dataprintover := .f.
            ENDIF
         NEXT count2
      ENDDO

      IF curx+lh >= maxrow1
         DRAW LINE in window pdfgrid at curx,cury to curx,cury+maxcol1-(1*resize)
         lastrow := curx
         totcol := 0
         DRAW LINE in window pdfgrid at firstrow,cury to lastrow,cury
         IF pdfgrid.collines.value
            colcount := 0
            FOR count2 := 1 to len(columnarr)
               IF columnarr[count2,1] == 1
                  colcount := colcount + 1
                  totcol := totcol + columnarr[count2,3]
                  DRAW LINE in window pdfgrid at firstrow,cury+(totcol+(colcount * 2)-1) * resize to lastrow,cury+(totcol+(colcount * 2)-1) * resize
               ENDIF
            NEXT count2
         ENDIF
         DRAW LINE in window pdfgrid at firstrow,cury+maxcol1-(1*resize) to lastrow,cury+maxcol1-(1*resize)
         IF Len(AllTrim(pdfgrid.footer1.value)) > 0
            pl := printlen(AllTrim(pdfgrid.footer1.value),size1,fontname) * resize
            DRAW LINE in window pdfgrid at curx+(lh/2),cury + ((maxcol1 - pl)/2) to curx+(lh/2),cury + ((maxcol1 - pl)/2) + pl
            curx := curx + lh + lh
         ENDIF
         IF pdfgrid.pageno.value == 3
            pl := printlen(msgarr[49]+alltrim(str(pageno,10,0)),size1,fontname)*resize
            DRAW LINE in window pdfgrid at curx,cury+maxcol1 - pl to curx,cury+maxcol1
            curx := curx + lh
         ENDIF
         count1 := totrows
      ELSE
         IF pdfgrid.rowlines.value
            DRAW LINE in window pdfgrid at curx,cury to curx,cury+maxcol1-(1*resize)
         ENDIF
      ENDIF
   NEXT count1
   DRAW LINE in window pdfgrid at curx,cury to curx,cury+maxcol1-(1*resize)
   lastrow := curx
   totcol := 0
   colcount := 0
   DRAW LINE in window pdfgrid at firstrow,cury to lastrow,cury
   IF pdfgrid.collines.value
      FOR count1 := 1 to len(columnarr)
         IF columnarr[count1,1] == 1
            totcol := totcol + columnarr[count1,3]
            colcount := colcount + 1
            DRAW LINE in window pdfgrid at firstrow,cury+(totcol+(colcount * 2)-1) * resize to lastrow,cury+(totcol+(colcount * 2)-1) * resize
         ENDIF
      NEXT count1
   ENDIF
   DRAW LINE in window pdfgrid at firstrow,cury+maxcol1-(1*resize) to lastrow,cury+maxcol1-(1*resize)
   IF Len(AllTrim(pdfgrid.footer1.value)) > 0
      pl := printlen(AllTrim(pdfgrid.footer1.value),size1,fontname) * resize
      DRAW LINE in window pdfgrid at curx+(lh/2),cury + ((maxcol1 - pl)/2) to curx+(lh/2),cury + ((maxcol1 - pl)/2) + pl
      curx := curx + lh + lh
   ENDIF
   IF pdfgrid.pageno.value == 3
      pl := printlen(msgarr[49]+alltrim(str(pageno,10,0)),size1,fontname)*resize
      DRAW LINE in window pdfgrid at curx,cury+maxcol1 - pl to curx,cury+maxcol1
      curx := curx + lh
   ENDIF

   RETURN NIL

FUNCTION pdfprintpreviewline(row,col,aitems,ajustify,sizesarr,fontname,size1,resize)

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
         DRAW LINE in window pdfgrid at row,tempcol to row,tempcol+pl
      CASE njustify == 1 //right
         DRAW LINE in window pdfgrid at row,tempcol+((sizesarr[count1] + 2) * resize)-pl to row,tempcol+((sizesarr[count1] + 2) * resize)
      CASE njustify == 2 //center not implemented
         DRAW LINE in window pdfgrid at row,tempcol to row,tempcol+pl
      END CASE
      tempcol := tempcol + ((sizesarr[count1] + 2) * resize)
   NEXT count1

   RETURN NIL

FUNCTION pdfcolumnsizeverify

   LOCAL lineno := pdfgrid.columns.value

   IF .not. iscontroldefine(browseprintcancel,pdfgrid)

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

FUNCTION pdfcolumnselected

   LOCAL lineno := pdfgrid.columns.value

   IF .not. iscontroldefine(browseprintcancel,pdfgrid)

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

FUNCTION pdfcolumnsumchanged

   /*
   local lineno := pdfgrid.columns.value

   if .not. iscontroldefine(browseprintcancel,pdfgrid)

   return nil
   endif
   IF lineno > 0
   columnarr[lineno,4] := this.cellvalue
   endif
   */

   RETURN .t.

FUNCTION pdfcolumntypeverify

   /*
   LOCAL lineno := pdfgrid.columns.value

   IF lineno > 0
   if ajustify[lineno] == 0 .or. ajustify[lineno] == 2

   return .f.
   else

   return .t.
   endif
   ENDIF
   */

   RETURN .f.

FUNCTION pdfmergeheaderschanged

   LOCAL count1 := 0
   LOCAL linedetails := {}

   asize(mergehead,0)
   FOR count1 := 1 to pdfgrid.merge.itemcount
      linedetails := pdfgrid.merge.item(count1)
      IF linedetails[2] >= linedetails[1] .and. iif((count1 > 1 .and. len(mergehead) > 0),linedetails[1] > mergehead[count1-1,2],.t.)
         aadd(mergehead,{linedetails[1],linedetails[2],linedetails[3]})
      ELSE
         msgstop(msgarr[65]+alltrim(str(count1)))
      ENDIF
   NEXT count1
   pdfgridpreview()

   RETURN NIL

FUNCTION pdfaddmergeheadrow

   LOCAL from1 := 1
   LOCAL to1 := 1

   IF len(mergehead) > 0
      IF mergehead[len(mergehead),2] < len(columnarr)
         from1 := mergehead[len(mergehead),2] + 1
         to1 := from1
         pdfgrid.merge.additem({from1,to1,""})
         pdfmergeheaderschanged()
      ENDIF
   ELSE
      pdfgrid.merge.additem({from1,to1,""})
      pdfmergeheaderschanged()
   ENDIF

   RETURN NIL

FUNCTION pdfdelmergeheadrow

   LOCAL lineno := pdfgrid.merge.value

   IF lineno > 0
      pdfgrid.merge.deleteitem(lineno)
      IF lineno > 1
         pdfgrid.merge.value := lineno - 1
      ELSE
         IF pdfgrid.merge.itemcount > 0
            pdfgrid.merge.value := 1
         ENDIF
      ENDIF
      pdfmergeheaderschanged()
   ENDIF

   RETURN NIL

FUNCTION pdfstripcomma(string,decimalsymbol,commasymbol)

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

FUNCTION pdfgridinit

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
   IF .not. file("reports.cfg") .or. len(aColWidths) > 0

      RETURN NIL
   ENDIF
   BEGIN INI FILE "reports.cfg"
      IF lArrayMode

         RETURN NIL
      ENDIF
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
         pdfgrid.columns.deleteallitems()
         asize(columnarr,0)
         FOR count1 := 1 to len(gridprintdata[1])
            linedata := gridprintdata[1,count1]
            aadd(columnarr,{int(linedata[3]),linedata[1],linedata[2],ajustify[count1]})
            pdfgrid.columns.additem({linedata[1],linedata[2],int(linedata[3])})
         NEXT count1
         IF pdfgrid.columns.itemcount > 0
            pdfgrid.columns.value := 1
         ENDIF
         // headers
         pdfgrid.header1.value := iif(len(alltrim(header1)) == 0,gridprintdata[2,1],header1)
         pdfgrid.header2.value := iif(len(alltrim(header2)) == 0,gridprintdata[2,2],header2)
         pdfgrid.header3.value := iif(len(alltrim(header3)) == 0,gridprintdata[2,3],header3)
         // footer
         pdfgrid.footer1.value := gridprintdata[3]
         //fontsize
         pdfgrid.selectfontsize.value := int(gridprintdata[4])
         // wordwrap
         pdfgrid.wordwrap.value := int(gridprintdata[5])
         // pagination
         pdfgrid.pageno.value := int(gridprintdata[6])
         // collines
         pdfgrid.collines.value := gridprintdata[7]
         // rowlines
         pdfgrid.rowlines.value := gridprintdata[8]
         // vertical center
         pdfgrid.vertical.value := gridprintdata[9]
         // space spread
         pdfgrid.spread.value := gridprintdata[10]
         // orientation
         pdfgrid.paperorientation.value := gridprintdata[11]
         // printers
         pdfgrid.printers.value := int(gridprintdata[12])
         // pagesize
         pdfgrid.pagesizes.value := gridprintdata[13]
         // paper width
         pdfgrid.width.value := gridprintdata[14]
         // paper height
         pdfgrid.height.value := gridprintdata[15]
         // margin top
         pdfgrid.top.value := gridprintdata[16]
         // margin right
         pdfgrid.right.value := gridprintdata[17]
         // margin left
         pdfgrid.left.value := gridprintdata[18]
         // margin bottom
         pdfgrid.bottom.value := gridprintdata[19]
         // merge headers data
         pdfgrid.merge.deleteallitems()
         FOR count1 := 1 to len(gridprintdata[20])
            linedata := gridprintdata[20,count1]
            pdfgrid.merge.additem({int(linedata[1]),int(linedata[2]),linedata[3]})
         NEXT count1
         IF pdfgrid.merge.itemcount > 0
            pdfgrid.merge.value := 1
         ENDIF
         pdfprintcoltally()
         pdfgridpreview()
      ENDIF
   END INI

   RETURN NIL

FUNCTION resetpdfgridform

   LOCAL count1
   LOCAL controlname := ""

   IF msgyesno(msgarr[67])
      IF .not. file("reports.cfg")

         RETURN NIL
      ENDIF
      BEGIN INI FILE "reports.cfg"
         IF lArrayMode

            RETURN NIL
         ENDIF
         GET controlname section windowname+"_"+gridname entry "controlname" default ""
         IF upper(alltrim(controlname)) == upper(alltrim(windowname+"_"+gridname))
            del section windowname+"_"+gridname
         ENDIF
      END INI
      pdfgrid.merge.deleteallitems()
      pdfgrid.spread.value := .f.
      pdfgrid.collines.value := .t.
      pdfgrid.rowlines.value := .t.
      pdfgrid.wordwrap.value := 2
      pdfgrid.pageno.value := 2
      pdfgrid.vertical.value := .t.
      FOR count1 := 1 to len(mergehead)
         IF mergehead[count1,2] >= mergehead[count1,1] .and. iif(count1 > 1,mergehead[count1,1] > mergehead[count1-1,2],.t.)
            pdfgrid.merge.additem({mergehead[count1,1],mergehead[count1,2],mergehead[count1,3]})
         ENDIF
      NEXT count1
      IF pdfgrid.merge.itemcount > 0
         pdfgrid.merge.value := 1
      ENDIF
      pdfcalculatecolumnsizes()
      pdfpapersizechanged()
   ENDIF

   RETURN NIL

FUNCTION pdfinit_messages

   LOCAL cLang := Set ( _SET_LANGUAGE )

   IF _HMG_SYSDATA [ 211 ] == 'FI'      // FINNISH
      cLang := 'FI'
   ELSEIF _HMG_SYSDATA [ 211 ] == 'NL'   // DUTCH
      cLang := 'NL'
   ENDIF

   DO CASE

   CASE cLang == "TRWIN" .OR. cLang == "TR"
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
         "Sayfa No. ",;
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
   CASE cLang ==  "CS" .OR. cLang == "CSWIN"
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
   CASE cLang == "HR852"
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
   CASE cLang == "EN"
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
   CASE cLang == "DEWIN" .OR. cLang == "DE"
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
   CASE cLang == "PLWIN"  .OR. cLang == "PL852"  .OR. cLang == "PLISO"  .OR. cLang == ""  .OR. cLang == "PLMAZ"
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
   CASE cLang == "pt.PT850"
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
   CASE cLang == "RUWIN"  .OR. cLang == "RU866" .OR. cLang == "RUKOI8"
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
   CASE cLang == "ES"  .OR. cLang == "ESWIN"
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
   CASE cLang == "SLWIN" .OR. cLang == "SLISO" .OR. cLang == "SL852" .OR. cLang == "" .OR. cLang == "SL437"
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
   OTHERWISE
      // DEFAULT (ENGLISH)
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

   RETURN NIL
