#include "minigui.ch"
#include "miniprint.ch"

MEMVAR msgarr
MEMVAR fontname
MEMVAR fontsizesstr
MEMVAR headerarr
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
MEMVAR aprinternames
MEMVAR defaultprinter
MEMVAR papernames
MEMVAR papersizes
MEMVAR printerno
MEMVAR header1
MEMVAR header2
MEMVAR header3
MEMVAR xres
MEMVAR maxcol2
MEMVAR curcol1

INIT PROCEDURE _InitPrintGrid

   InstallMethodHandler ( 'Print' , 'MyGridPrint' )

   RETURN

PROCEDURE MyGridPrint (  cWindowName , cControlName , MethodName )

   MethodName := Nil

   IF GetControlType ( cControlName , cWindowName ) == 'GRID'

      gridprint( cControlName , cWindowName  )

      _HMG_UserComponentProcess := .T.

   ELSE

      _HMG_UserComponentProcess := .F.

   ENDIF

   RETURN

   DECLARE window printgrid

FUNCTION gridprint(cGrid,cWindow,fontsize,orientation,aHeaders,fontname1,showwindow1)

   LOCAL count1 := 0
   LOCAL count2 := 0
   LOCAL maxcol1 := 0
   LOCAL i := 0
   PRIVATE msgarr := {"Nothing to print",;    //1
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
      }

   PRIVATE fontname := ""
   PRIVATE fontsizesstr := {}
   PRIVATE headerarr := {}
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
   PRIVATE aprinternames := aprinters()
   PRIVATE defaultprinter := GetDefaultPrinter()
   PRIVATE papernames := {"Letter","Legal","Executive","A3","A4","Custom"}
   PRIVATE papersizes := {{216,279},{216,355.6},{184.1,266.7},{297,420},{210,297},{216,279}}
   PRIVATE printerno := 0
   PRIVATE header1 := ""
   PRIVATE header2 := ""
   PRIVATE header3 := ""
   PRIVATE xres := {}
   PRIVATE maxcol2 := 0.0
   PRIVATE curcol1 := 0.0

   DEFAULT fontsize := 12
   DEFAULT orientation := "P"
   DEFAULT fontname1 := "Arial"
   DEFAULT aheaders := {"","",""}
   DEFAULT ShowWindow1 := .t.

   SWITCH len(aheaders)
   CASE 3
      header1 := aheaders[1]
      header2 := aheaders[2]
      header3 := aheaders[3]
      EXIT
   CASE 2
      header1 := aheaders[1]
      header2 := aheaders[2]
      EXIT
   CASE 1
      header1 := aheaders[1]
   END SWITCH

   fontname := fontname1
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
      aadd(headerarr,getproperty(windowname,gridname,"header",count1))
   NEXT count1

   i := GetControlIndex ( gridname , windowname )
   aJustify := _HMG_aControlMiscData1 [i] [3]

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

   DEFINE WINDOW printgrid at 0,0 width 700 height 440 title msgarr[4] modal nosize nosysmenu
      DEFINE TAB tab1 at 10,10 width 285 height 335
         DEFINE PAGE msgarr[5]
            DEFINE GRID columns
               ROW 30
               COL 10
               WIDTH 250
               HEIGHT 240
               widths {0,130,70}
               justify {0,0,1}
               headers {"",msgarr[6],msgarr[7]}
               image {'wrong','right'}
               tooltip msgarr[8]
               ondblclick printgridtoggle()
               onchange editcoldetails()
            END GRID
            DEFINE LABEL sizelabel1
               ROW 280
               COL 10
               value msgarr[50]
               WIDTH 40
            END LABEL
            DEFINE TEXTBOX size
               ROW 280
               COL 50
               WIDTH 60
               value 0.0
               numeric .t.
               rightalign .t.
               inputmask "999.99"
            END TEXTBOX
            DEFINE BUTTON done
               ROW 280
               COL 120
               WIDTH 50
               caption msgarr[56]
               action setprintgridcoldetails()
            END BUTTON
         END PAGE
         DEFINE PAGE msgarr[16]
            DEFINE LABEL header1label
               ROW 35
               COL 10
               WIDTH 100
               value msgarr[12]
            END LABEL
            DEFINE TEXTBOX header1
               ROW 30
               COL 110
               WIDTH 165
               Value header1
               on change printgridpreview()
            END TEXTBOX
            DEFINE LABEL header2label
               ROW 75
               COL 10
               WIDTH 100
               value msgarr[13]
            END LABEL
            DEFINE TEXTBOX header2
               ROW 70
               COL 110
               Value header2
               on change printgridpreview()
               WIDTH 165
            END TEXTBOX
            DEFINE LABEL header3label
               ROW 105
               COL 10
               WIDTH 100
               value msgarr[14]
            END LABEL
            DEFINE TEXTBOX Header3
               ROW 100
               COL 110
               Value header3
               on change printgridpreview()
               WIDTH 165
            END TEXTBOX
            DEFINE LABEL footer1label
               ROW 135
               COL 10
               WIDTH 100
               value msgarr[15]
            END LABEL
            DEFINE TEXTBOX Footer1
               ROW 130
               COL 110
               WIDTH 165
               on change printgridpreview()
            END TEXTBOX
            DEFINE LABEL selectfontsizelabel
               ROW 165
               COL 10
               value msgarr[17]
               WIDTH 100
            END LABEL
            DEFINE COMBOBOX selectfontsize
               ROW 160
               COL 110
               WIDTH 50
               items fontsizesstr
               on change fontsizechanged()
               value fontnumber
            END COMBOBOX
            DEFINE LABEL multilinelabel
               ROW 195
               COL 10
               value msgarr[18]
               WIDTH 100
            END LABEL
            DEFINE COMBOBOX wordwrap
               ROW 190
               COL 110
               WIDTH 90
               items {msgarr[19],msgarr[20]}
               on change printgridpreview()
               value 2
            END COMBOBOX
            DEFINE LABEL pagination
               ROW 225
               COL 10
               value msgarr[21]
               WIDTH 100
            END LABEL
            DEFINE COMBOBOX pageno
               ROW 220
               COL 110
               WIDTH 90
               items {msgarr[22],msgarr[23],msgarr[24]}
               on change printgridpreview()
               value 2
            END COMBOBOX
            DEFINE LABEL separatorlab
               ROW 255
               COL 10
               WIDTH 100
               value msgarr[25]
            END LABEL
            DEFINE CHECKBOX collines
               ROW 250
               COL 110
               WIDTH 70
               on change printgridpreview()
               caption msgarr[26]
               value .t.
            END CHECKBOX
            DEFINE CHECKBOX rowlines
               ROW 250
               COL 180
               WIDTH 50
               on change printgridpreview()
               caption msgarr[27]
               value .t.
            END CHECKBOX
            DEFINE LABEL centerlab
               ROW 280
               COL 10
               WIDTH 100
               value msgarr[28]
            END LABEL
            DEFINE CHECKBOX vertical
               ROW 275
               COL 110
               WIDTH 60
               on change printgridpreview()
               caption msgarr[29]
               value .t.
            END CHECKBOX
            DEFINE LABEL spacelab
               ROW 305
               COL 10
               WIDTH 100
               HEIGHT 20
               value msgarr[54]
            END LABEL
            DEFINE CHECKBOX spread
               ROW 305
               COL 110
               WIDTH 60
               HEIGHT 20
               on change fontsizechanged()
               caption msgarr[55]
               value .t.
            END CHECKBOX
         END PAGE
         DEFINE PAGE msgarr[30]
            DEFINE LABEL orientationlabel
               ROW 30
               COL 10
               Value msgarr[31]
               WIDTH 100
            END LABEL
            DEFINE COMBOBOX paperorientation
               ROW 30
               COL 110
               WIDTH 90
               items {msgarr[32],msgarr[33]}
               on change papersizechanged()
               value IIf(orientation == "P",2,1)
            END COMBOBOX
            DEFINE LABEL printerslabel
               ROW 60
               COL 10
               WIDTH 100
               value msgarr[34]
            END LABEL
            DEFINE COMBOBOX printers
               ROW 60
               COL 110
               WIDTH 165
               items aprinternames
               value printerno
            END COMBOBOX
            DEFINE LABEL sizelabel
               ROW 90
               COL 10
               WIDTH 100
               value msgarr[35]
            END LABEL
            DEFINE COMBOBOX pagesizes
               ROW 90
               COL 110
               WIDTH 165
               items papernames
               onchange papersizechanged()
            END COMBOBOX
            DEFINE LABEL widthlabel
               ROW 120
               COL 10
               value msgarr[36]
               WIDTH 100
            END LABEL
            DEFINE TEXTBOX width
               ROW 120
               COL 110
               WIDTH 60
               inputmask "999.99"
               on change printgridpreview()
               numeric .t.
               rightalign .t.
            END TEXTBOX
            DEFINE LABEL widthmm
               ROW 120
               COL 170
               value "mm"
               WIDTH 25
            END LABEL
            DEFINE LABEL heightlabel
               ROW 150
               COL 10
               value msgarr[37]
               WIDTH 100
            END LABEL
            DEFINE TEXTBOX height
               ROW 150
               COL 110
               WIDTH 60
               inputmask "999.99"
               on change printgridpreview()
               numeric .t.
               rightalign .t.
            END TEXTBOX
            DEFINE LABEL heightmm
               ROW 150
               COL 170
               value "mm"
               WIDTH 25
            END LABEL
            DEFINE FRAME margins
               ROW 180
               COL 5
               WIDTH 185
               HEIGHT 80
               caption msgarr[38]
            END FRAME
            DEFINE LABEL toplabel
               ROW 200
               COL 10
               WIDTH 35
               value msgarr[39]
            END LABEL
            DEFINE TEXTBOX top
               ROW 200
               COL 45
               WIDTH 50
               inputmask "99.99"
               numeric .t.
               on change printgridpreview()
               rightalign .t.
            END TEXTBOX
            DEFINE LABEL rightlabel
               ROW 200
               COL 100
               WIDTH 35
               value msgarr[40]
            END LABEL
            DEFINE TEXTBOX right
               ROW 200
               COL 135
               WIDTH 50
               inputmask "99.99"
               on change papersizechanged()
               numeric .t.
               rightalign .t.
            END TEXTBOX
            DEFINE LABEL leftlabel
               ROW 230
               COL 10
               WIDTH 35
               value msgarr[41]
            END LABEL
            DEFINE TEXTBOX left
               ROW 230
               COL 45
               WIDTH 50
               inputmask "99.99"
               on change papersizechanged()
               numeric .t.
               rightalign .t.
            END TEXTBOX
            DEFINE LABEL bottomlabel
               ROW 230
               COL 100
               WIDTH 35
               value msgarr[42]
            END LABEL
            DEFINE TEXTBOX bottom
               ROW 230
               COL 135
               WIDTH 50
               inputmask "99.99"
               numeric .t.
               on change printgridpreview()
               rightalign .t.
            END TEXTBOX
         END PAGE
      END TAB
      DEFINE BUTTON browseprint1
         ROW 350
         COL 160
         caption msgarr[43]
         action printstart()
         WIDTH 80
      END BUTTON
      DEFINE BUTTON browseprintcancel
         ROW 350
         COL 260
         caption msgarr[44]
         action printgrid.release
         WIDTH 80
      END BUTTON
      DEFINE STATUSBAR
         statusitem msgarr[45] width 200
         statusitem msgarr[10] + "mm "+msgarr[11]+"mm" width 300
      END STATUSBAR
   END WINDOW
   printgrid.pagesizes.value := 1
   printgrid.top.value := 20.0
   printgrid.right.value := 20.0
   printgrid.bottom.value := 20.0
   printgrid.left.value := 20.0
   papersizechanged()
   printgrid.center
   IF .not. showwindow1
      IF printgrid.browseprint1.enabled
         printstart()
      ELSE
         printgrid.activate
      ENDIF
   ELSE
      printgrid.activate
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
   FOR count1 := 1 to Len(columnarr)
      IF columnarr[count1,1] == 1
         COL := col + columnarr[count1,3] + 2 // 2 mm for column separation
         count2 := count2 + 1
      ENDIF
   NEXT count1
   IF col < maxcol2 .and. printgrid.spread.value
      totcol := col - (count2 * 2)
      FOR count1 := 1 to len(columnarr)
         IF columnarr[count1,1] == 1
            columnarr[count1,3] := (maxcol2 - (count2 *2) - 5) * columnarr[count1,3] / totcol
         ENDIF
      NEXT count1
      COL := maxcol2 - 5
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

   RETURN NIL

FUNCTION fontsizechanged

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
            sizes[count2] := max(sizes[count2],printlen(alltrim(linedata[count2]),fontsize1,fontname))
         NEXT count2
      NEXT count1
      FOR count1 := 1 to len(headerarr)
         headersizes[count1] := printlen(alltrim(headerarr[count1]),fontsize1,fontname)
      NEXT count1
      FOR count1 := 1 TO Len(columnarr)
         columnarr[count1,3] := max(sizes[count1],headersizes[count1])
      NEXT count1
   ENDIF
   printcoltally()
   refreshcolumnprintgrid()
   printgridpreview()

   RETURN NIL

FUNCTION printstart

   LOCAL printername, size, lastrow
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
   LOCAL nextline := {}
   LOCAL nextcount := 0
   LOCAL count1 := 0
   LOCAL count2 := 0
   LOCAL count3 := 0
   LOCAL count4 := 0
   LOCAL dataprintover := .t.
   LOCAL cPrintdata := ""
   LOCAL aec := ""
   LOCAL aitems := {}

   IF printgrid.printers.value > 0
      printername := AllTrim(printgrid.printers.item(printgrid.printers.value))
   ELSE
      msgstop(msgarr[47],msgarr[3])

      RETURN NIL
   ENDIF
   //private papernames := {"Letter","Legal","Executive","A3","A4","Custom"}

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
         PAPERLENGTH printgrid.height.value;
         PAPERWIDTH printgrid.width.value;
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

         firstrow := Row
         @ Row ,Col-1  print line TO Row ,col+maxcol1-1 penwidth 0.25
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
                  data1 := linedata[count2]
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

            IF Row+lh >= maxrow1
               @ Row,Col-1 print line TO Row,col+maxcol1-1  penwidth 0.25
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

               firstrow := Row
               @ Row ,Col-1  print line TO Row ,col+maxcol1-1 penwidth 0.25
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
            ELSE
               IF printgrid.rowlines.value
                  @ Row,Col-1 print line TO Row,col+maxcol1-1 penwidth 0.25
               ENDIF
            ENDIF
         NEXT count1
         @ Row,Col-1 print line TO Row,col+maxcol1-1 penwidth 0.25
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
   LOCAL linedetail := {}

   IF .not. iscontroldefined(browseprintcancel,printgrid)

      RETURN NIL
   ENDIF
   IF lineno > 0
      IF columnarr[lineno,1] == 1
         columnarr[lineno,1] := 0
      ELSE
         columnarr[lineno,1] := 1
      ENDIF
      printgrid.columns.value := lineno
   ENDIF
   fontsizechanged()

   RETURN NIL

FUNCTION refreshcolumnprintgrid

   LOCAL count1 := 0

   IF .not. iscontroldefined(browseprintcancel,printgrid)

      RETURN NIL
   ENDIF
   printgrid.columns.deleteallitems()
   FOR count1 := 1 TO Len(columnarr)
      printgrid.columns.additem({columnarr[count1,1],columnarr[count1,2],AllTrim(Str(columnarr[count1,3]))})
   NEXT count1
   IF printgrid.columns.itemcount > 0
      printgrid.columns.value := 1
   ENDIF

   RETURN NIL

FUNCTION editcoldetails

   LOCAL lineno := printgrid.columns.value
   LOCAL columnsize := 0

   IF lineno > 0
      printgrid.size.value := columnarr[lineno,3]
      IF ajustify[lineno] == 0 .or. ajustify[lineno] == 2
         printgrid.size.enabled := .t.
      ELSE
         printgrid.size.enabled := .f.
         //      msginfo(msgarr[52])
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION setprintgridcoldetails

   LOCAL lineno := printgrid.columns.value

   IF lineno > 0
      columnarr[lineno,3] := printgrid.size.value
   ENDIF
   printcoltally()
   refreshcolumnprintgrid()
   printgrid.columns.value := lineno
   printgridpreview()

   RETURN NIL

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
   fontsizechanged()

   RETURN NIL

FUNCTION printgridpreview

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
   LOCAL nextline := {}
   LOCAL count1 := 0
   LOCAL count2 := 0
   LOCAL count3 := 0
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

   firstrow := curx
   DRAW LINE in window printgrid at curx,cury to curx,cury+maxcol1-(1*resize)
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
            data1 := linedata[count2]
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
