#include "minigui.ch"
#include "winprint.ch"
#include "dbuvar.ch"

FUNCTION DBUeditprint

   LOCAL _t, _l, _b, _r

   SET CENTURY ON
   IF .not. used()

      RETURN NIL
   ENDIF
   INIT printsys
   SELECT by dialog preview
   _t := (GetDesktopHeight() - 699) / 2
   _l := (GetDesktopWidth() - 499) / 2
   _b := GetDesktopHeight() - _t
   _r := GetDesktopWidth() - _l
   SET preview rect _t, _l, _b, _r
   DEFINE FONT "f0" name "Courier New" size 12
   SELECT font "f0"
   start doc
   SET page orientation DMORIENT_PORTRAIT paperSize DMPAPER_A4 font "f0"
   start page
   _DBUmaxrow1 := hbprnmaxrow - 3
   _DBUmaxcol1 := hbprnmaxcol - 5
   _DBUrow := 3
   _DBUcol := 5
   @ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
   @ _DBUrow,_DBUcol say "File Name               : "+cFileNoPath(alltrim(_DBUfname)) to print
   _DBUrow := _DBUrow + 1
   @ _DBUrow,_DBUcol say "Total Number of Records : "+alltrim(str(reccount(),10,0)) to print
   _DBUrow := _DBUrow + 1
   @ _DBUrow,_DBUcol say "Current Record Number   : "+alltrim(str(recno(),10,0)) to print
   _DBUrow := _DBUrow + 1
   @ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
   _DBUstructarr := dbstruct()
   _DBUfieldnamearr := {}
   FOR _DBUi := 1 to len(_DBUstructarr)
      aadd(_DBUfieldnamearr,alltrim(_DBUstructarr[_DBUi,1]))
   NEXT _DBUi
   _DBUlongest := bigelem(_DBUfieldnamearr)
   FOR _DBUi := 1 to len(_DBUfieldnamearr)
      DO CASE
      CASE _DBUstructarr[_DBUi,2] == "C"
         @ _DBUrow,_DBUcol say _DBUfieldnamearr[_DBUi] + space(_DBUlongest - len(alltrim(_DBUfieldnamearr[_DBUi])))+" : "+alltrim(&(_DBUfieldnamearr[_DBUi])) to print
      CASE _DBUstructarr[_DBUi,2] == "D"
         @ _DBUrow,_DBUcol say _DBUfieldnamearr[_DBUi] + space(_DBUlongest - len(alltrim(_DBUfieldnamearr[_DBUi])))+" : "+dtoc(&(_DBUfieldnamearr[_DBUi])) to print
      CASE _DBUstructarr[_DBUi,2] == "L"
         @ _DBUrow,_DBUcol say _DBUfieldnamearr[_DBUi] + space(_DBUlongest - len(alltrim(_DBUfieldnamearr[_DBUi])))+" : "+iif(&(_DBUfieldnamearr[_DBUi]),"True","False") to print
      CASE _DBUstructarr[_DBUi,2] == "N"
         @ _DBurow,_DBUcol say _DBUfieldnamearr[_DBUi] + space(_DBUlongest - len(alltrim(_DBUfieldnamearr[_DBUi])))+" : "+alltrim(str(&(_DBUfieldnamearr[_DBUi]),_DBUstructarr[_DBUi,3],_DBUstructarr[_DBUi,4])) to print
      CASE _DBUstructarr[_DBUi,2] == "M"
         @ _DBUrow,_DBUcol say _DBUfieldnamearr[_DBUi] + space(_DBUlongest - len(alltrim(_DBUfieldnamearr[_DBUi])))+" : "+"Memo" to print
      END CASE
      _DBUrow := _DBUrow + 1
      IF _DBUrow >= _DBUmaxrow
         @ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
      END PAGE
      start page
      _DBUrow := 3
   ENDIF
NEXT _DBUi
@ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
END PAGE
END doc
RELEASE printsys

RETURN NIL

FUNCTION DBUbrowseprint

   IF .not. used()

      RETURN NIL
   ENDIF
   INIT printsys
   GET printers to _DBUavailableprinters
   GET default printer to _DBUcurrentprinter
   SELECT default
   start doc
   DEFINE FONT "f0" name "Courier New" size 12
   SET page orientation DMORIENT_PORTRAIT paperSize DMPAPER_A4 font "f0"
   _DBUmaxportraitcol := hbprnmaxcol - 4
   SET page orientation DMORIENT_LANDSCAPE paperSize DMPAPER_A4 font "f0"
   _DBUmaxlandscapecol := hbprnmaxcol - 4
END doc
RELEASE printsys
_DBUfontsizesstr := {"8","9","10","11","12","14","16","18","20","22","24","26","28","36","48","72"}
_DBUmaxcol1 := _DBUmaxlandscapecol
_DBUstructarr := dbstruct()
_DBUfieldnamearr := {}
_DBUfieldsizearr := {}
FOR _DBUi := 1 to len(_DBUstructarr)
   aadd(_DBUfieldnamearr,alltrim(_DBUstructarr[_DBUi,1]))
   IF _DBUstructarr[_DBUi,2] <> "M"
      aadd(_DBUfieldsizearr,iif(len(alltrim(_DBUstructarr[_DBUi,1])) > _DBUstructarr[_DBUi,3],len(alltrim(_DBUstructarr[_DBUi,1])),_DBUstructarr[_DBUi,3]))
   ELSE
      aadd(_DBUfieldsizearr,len(alltrim(_DBUstructarr[_DBUi,1])))
   ENDIF
NEXT _DBUi
DEFINE WINDOW _DBUprintfields at 0,0 width 800 height 540 title "Select Print Fields" modal nosize nosysmenu
   DEFINE LABEL _DBUtotfieldslab
      ROW 30
      COL 30
      VALUE "Fields in the dbf"
      WIDTH 200
      FONTBOLD .t.
   END LABEL
   DEFINE LISTBOX _DBUfields
      ROW 60
      COL 30
      WIDTH 200
      HEIGHT 400
      ITEMS _DBUfieldnamearr
      multiselect .t.
   END listbox
   DEFINE BUTTON _DBUfieldadd
      ROW 100
      COL 260
      CAPTION "Add"
      WIDTH 100
      ACTION DBUprintfieldsadd()
   END BUTTON
   DEFINE BUTTON _DBUfieldremove
      ROW 140
      COL 260
      CAPTION "Remove"
      WIDTH 100
      ACTION DBUprintfieldremove()
   END BUTTON
   DEFINE BUTTON _DBUfieldaddall
      ROW 180
      COL 260
      CAPTION "Add All"
      WIDTH 100
      ACTION DBUprintfieldaddall()
   END BUTTON
   DEFINE BUTTON _DBUfieldremoveall
      ROW 220
      COL 260
      CAPTION "Remove All"
      WIDTH 100
      ACTION (_DBUprintfields._DBUselectedfields.deleteallitems,DBUprintcoltally())
   END BUTTON
   DEFINE LABEL _DBUselectedfieldslabel
      ROW 30
      COL 390
      WIDTH 200
      VALUE "Selected Fields"
      FONTBOLD .t.
   END LABEL
   DEFINE LISTBOX _DBUselectedfields
      ROW 60
      COL 390
      WIDTH 200
      HEIGHT 400
      multiselect .t.
   END listbox
   DEFINE LABEL _DBUorientationlabel
      ROW 30
      COL 600
      VALUE "Orientation"
      WIDTH 150
      FONTBOLD .t.
   END LABEL
   DEFINE RADIOGROUP _DBUpaperorientation
      ROW 60
      COL 600
      WIDTH 150
      HEIGHT 100
      options {"Landscape","Portrait"}
      ON CHANGE DBUorientationchange()
      VALUE 1
   END radiogroup
   DEFINE LABEL _DBUselectprinterlabel
      ROW 170
      COL 600
      VALUE "Select Printer"
      WIDTH 150
      FONTBOLD .t.
   END LABEL
   DEFINE LISTBOX _DBUprinters
      ROW 200
      COL 600
      WIDTH 150
      HEIGHT 100
      ITEMS _DBUavailableprinters
      VALUE ascan(_DBUavailableprinters,_DBUcurrentprinter)
   END listbox
   DEFINE LABEL _DBUselectfontsizelabel
      ROW 310
      COL 600
      VALUE "Font Size"
      WIDTH 150
      FONTBOLD .t.
   END LABEL
   DEFINE LISTBOX _DBUselectfontsize
      ROW 340
      COL 600
      WIDTH 150
      HEIGHT 100
      ITEMS _DBUfontsizesstr
      ON CHANGE DBUfontsizechanged()
      VALUE 5
   END listbox
   DEFINE BUTTON _DBUbrowseprint1
      ROW 260
      COL 260
      CAPTION "Print"
      ACTION DBUprintstart()
      WIDTH 100
   END BUTTON
   DEFINE BUTTON _DBUbrowseprintcancel
      ROW 300
      COL 260
      CAPTION "Cancel"
      ACTION _DBUprintfields.release
      WIDTH 100
   END BUTTON
   DEFINE LABEL _DBUmaxcollabel
      ROW 470
      COL 30
      WIDTH 200
      VALUE "Maximum Print Columns:"
      FONTBOLD .t.
   END LABEL
   DEFINE TEXTBOX _DBUmaximumcol
      ROW 470
      COL 240
      WIDTH 50
      readonly .t.
      VALUE _DBUmaxcol1
      NUMERIC .t.
      RIGHTALIGN .t.
   END TEXTBOX
   DEFINE LABEL _DBUcurrentcollabel
      ROW 470
      COL 300
      WIDTH 200
      VALUE "Current Print Columns:"
      FONTBOLD .t.
   END LABEL
   DEFINE TEXTBOX _DBUcurrentcol
      ROW 470
      COL 510
      WIDTH 50
      readonly .t.
      VALUE 2
      NUMERIC .t.
      RIGHTALIGN .t.
   END TEXTBOX
END WINDOW
DBUprintcoltally()
_DBUprintfields.center
_DBUprintfields.activate

RETURN NIL

FUNCTION DBUprintfieldsadd

   LOCAL _DBUselfields1 := _DBUprintfields._DBUfields.value

   IF len(_DBUselfields1) == 0

      RETURN NIL
   ENDIF
   FOR _DBUi := 1 to len(_DBUselfields1)
      _DBUfieldfound := .f.
      FOR _DBUj := 1 to _DBUprintfields._DBUselectedfields.itemcount
         IF upper(alltrim(_DBUprintfields._DBUselectedfields.item(_DBUj))) == upper(alltrim(_DBUprintfields._DBUfields.item(_DBUselfields1[_DBUi])))
            _DBUfieldfound := .t.
         ENDIF
      NEXT _DBUj
      IF .not. _DBUfieldfound
         _DBUprintfields._DBUselectedfields.additem(_DBUprintfields._DBUfields.item(_DBUselfields1[_DBUi]))
      ENDIF
   NEXT _DBUi
   DBUprintcoltally()

   RETURN NIL

FUNCTION DBUprintfieldremove

   LOCAL _DBUselfields1 := _DBUprintfields._DBUselectedfields.value

   IF len(_DBUselfields1) == 0
      DBUprintcoltally()

      RETURN NIL
   ENDIF
   FOR _DBUi := len(_DBUselfields1) to 1 step -1
      _DBUprintfields._DBUselectedfields.deleteitem(_DBUselfields1[_DBUi])
   NEXT _DBUi
   DBUprintcoltally()

   RETURN NIL

FUNCTION DBUprintfieldaddall

   _DBUprintfields._DBUselectedfields.deleteallitems
   FOR _DBUi := 1 to _DBUprintfields._DBUfields.itemcount
      _DBUprintfields._DBUselectedfields.additem(_DBUprintfields._DBUfields.item(_DBUi))
   NEXT _DBUi
   DBUprintcoltally()

   RETURN NIL

FUNCTION DBUprintcoltally

   _DBUstructarr := dbstruct()
   _DBUcol := 2
   FOR _DBUi := 1 to _DBUprintfields._DBUselectedfields.itemcount
      _DBUpos := ascan(_DBUstructarr,{|x|upper(alltrim(x[1])) == upper(alltrim(_DBUprintfields._DBUselectedfields.item(_DBUi)))})
      IF _DBUpos > 0
         _DBUcol := _DBUcol + 2 + iif(_DBUstructarr[_DBUpos,2] <> "M",max(len(alltrim(_DBUstructarr[_DBUpos,1])),_DBUstructarr[_DBUpos,3]),max(len(alltrim(_DBUstructarr[_DBUpos,1])),6))
      ENDIF
   NEXT _DBUi
   _DBUprintfields._DBUcurrentcol.value := _DBUcol
   IF _DBUprintfields._DBUselectedfields.itemcount > 0
      IF _DBUprintfields._DBUmaximumcol.value >= _DBUprintfields._DBUcurrentcol.value
         _DBUprintfields._DBUbrowseprint1.enabled := .t.
      ELSE
         msgalert("You had selected more fields than to fit in a the page!","Warning")
         _DBUprintfields._DBUbrowseprint1.enabled := .f.

         RETURN NIL
      ENDIF
   ELSE
      _DBUprintfields._DBUbrowseprint1.enabled := .f.
   ENDIF

   RETURN NIL

FUNCTION DBUorientationchange

   IF _DBUprintfields._DBUpaperorientation.value == 1
      _DBUprintfields._DBUmaximumcol.value := _DBUmaxlandscapecol
   ELSE
      _DBUprintfields._DBUmaximumcol.value := _DBUmaxportraitcol
   ENDIF
   DBUprintcoltally()

   RETURN NIL

FUNCTION DBUfontsizechanged

   INIT printsys
   SELECT default
   start doc
   DEFINE FONT "f0" name "Courier New" size val(alltrim(_DBUprintfields._DBUselectfontsize.item(_DBUprintfields._DBUselectfontsize.value)))
   SET page orientation DMORIENT_PORTRAIT paperSize DMPAPER_A4 font "f0"
   _DBUmaxportraitcol := hbprnmaxcol - 4
   SET page orientation DMORIENT_LANDSCAPE paperSize DMPAPER_A4 font "f0"
   _DBUmaxlandscapecol := hbprnmaxcol - 4
END doc
RELEASE printsys
DBUorientationchange()

RETURN NIL

FUNCTION DBUprintstart

   LOCAL _t, _l, _b, _r

   SET CENTURY ON
   _DBUstructarr := dbstruct()
   _DBUselectedstructarr := {}
   FOR _DBUi := 1 to _DBUprintfields._DBUselectedfields.itemcount
      _DBUpos := ascan(_DBUstructarr,{|x|upper(alltrim(x[1])) == upper(alltrim(_DBUprintfields._DBUselectedfields.item(_DBUi)))})
      aadd(_DBUselectedstructarr,_DBUstructarr[_DBUpos])
   NEXT _DBUi
   _DBUrow := 3
   _DBUcol := 2
   _DBUmaxcol1 := _DBUCol
   _DBUheadingarr := {}
   _DBUjustifyarr := {}
   _DBUlinesrefarr := {}
   FOR _DBUi := 1 to len(_DBUselectedstructarr)
      _DBUlongest := iif(_DBUselectedstructarr[_DBUi,2] <> "M",max(len(alltrim(_DBUselectedstructarr[_DBUi,1])),_DBUselectedstructarr[_DBUi,3]),max(len(alltrim(_DBUselectedstructarr[_DBUi,1])),6))
      DO CASE
      CASE _DBUselectedstructarr[_DBUi,2] == "N"
         aadd(_DBUjustifyarr,1)
         aadd(_DBUheadingarr,space(_DBUlongest - len(alltrim(_DBUselectedstructarr[_DBUi,1])))+alltrim(_DBUselectedstructarr[_DBUi,1])+"  ")
         _DBUmaxcol1 := _DBUmaxcol1 + _DBUlongest + 2
      CASE _DBUselectedstructarr[_DBUi,2] == "C"
         aadd(_DBUjustifyarr,0)
         aadd(_DBUheadingarr,alltrim(_DBUselectedstructarr[_DBUi,1])+space(_DBUlongest - len(alltrim(_DBUselectedstructarr[_DBUi,1])))+"  ")
         _DBUmaxcol1 := _DBUmaxcol1 + _DBUlongest + 2
      CASE _DBUselectedstructarr[_DBUi,2] == "L"
         aadd(_DBUjustifyarr,0)
         aadd(_DBUheadingarr,alltrim(_DBUselectedstructarr[_DBUi,1])+space(_DBUlongest - len(alltrim(_DBUselectedstructarr[_DBUi,1])))+"  ")
         _DBUmaxcol1 := _DBUmaxcol1 + _DBUlongest + 2
      CASE _DBUselectedstructarr[_DBUi,2] == "D"
         IF _DBUlongest < 10
            _DBUlongest := 10
         ENDIF
         aadd(_DBUjustifyarr,0)
         aadd(_DBUheadingarr,alltrim(_DBUselectedstructarr[_DBUi,1])+space(_DBUlongest - len(alltrim(_DBUselectedstructarr[_DBUi,1])))+"  ")
         _DBUmaxcol1 := _DBUmaxcol1 + _DBUlongest + 2
      CASE _DBUselectedstructarr[_DBUi,2] == "M"
         aadd(_DBUjustifyarr,0)
         aadd(_DBUheadingarr,alltrim(_DBUselectedstructarr[_DBUi,1])+space(_DBUlongest - 6)+"  ")
         _DBUmaxcol1 := _DBUmaxcol1 + _DBUlongest + 2
      ENDCASE
      aadd(_DBUlinesrefarr,_DBUmaxcol1 - iif(_DBUi == len(_DBUselectedstructarr),0,1))
   NEXT _DBUi
   INIT printsys
   SELECT printer alltrim(_DBUprintfields._DBUprinters.item(_DBUprintfields._DBUprinters.value)) preview
   _t := (GetDesktopHeight() - 599) / 2
   _l := (GetDesktopWidth() - 799) / 2
   _b := GetDesktopHeight() - _t
   _r := GetDesktopWidth() - _l
   SET preview rect _t, _l, _b, _r
   enable thumbnails
   DEFINE FONT "f0" name "Courier New" size val(alltrim(_DBUprintfields._DBUselectfontsize.item(_DBUprintfields._DBUselectfontsize.value)))
   SELECT font "f0"
   IF _DBUprintfields._DBUpaperorientation.value == 1
      SET page orientation DMORIENT_LANDSCAPE paperSize DMPAPER_A4 font "f0"
   ELSE
      SET page orientation DMORIENT_PORTRAIT paperSize DMPAPER_A4 font "f0"
   ENDIF
   start doc
   //_DBUmaxcol1 := hbprnmaxcol - 10
   _DBUmaxrow1 := hbprnmaxrow - 6
   start page
   _DBUpageno := 1
   @ _DBUrow,_DBUmaxcol1 - 20 say "Page No. : "+alltrim(str(_DBUpageno,10,0)) to print
   _DBUrow := _DBUrow + 1
   @ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
   @ _DBUrow,_DBUcol say "File Name               : "+cFileNoPath(alltrim(_DBUfname)) to print
   _DBUrow := _DBUrow + 1
   @ _DBUrow,_DBUcol say "Total Number of Records : "+alltrim(str(reccount(),10,0)) to print
   _DBUrow := _DBUrow + 1
   _DBUfirstrow := _DBUrow
   @ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
   DBUprintline(_DBUrow,_DBUcol,_DBUheadingarr,_DBUjustifyarr,"f0")
   _DBUrow := _DBUrow + 1
   @ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
   _DBUcurrentrecordarr := {}
   _DBUcurrec := recno()
   GO TOP
   DO WHILE .not. eof()
      asize(_DBUcurrentrecordarr,0)
      FOR _DBUi := 1 to len(_DBUselectedstructarr)
         _DBUlongest := iif(_DBUselectedstructarr[_DBUi,2] <> "M",max(len(alltrim(_DBUselectedstructarr[_DBUi,1])),_DBUselectedstructarr[_DBUi,3]),max(len(alltrim(_DBUselectedstructarr[_DBUi,1])),6))
         DO CASE
         CASE _DBUselectedstructarr[_DBUi,2] == "C"
            aadd(_DBUcurrentrecordarr,&(_DBUselectedstructarr[_DBUi,1])+space(_DBUlongest - _DBUselectedstructarr[_DBUi,3])+"  ")
         CASE _DBUselectedstructarr[_DBUi,2] == "N"
            aadd(_DBUcurrentrecordarr,space(_DBUlongest - _DBUselectedstructarr[_DBUi,3])+str(&(_DBUselectedstructarr[_DBUi,1]),_DBUselectedstructarr[_DBUi,3],_DBUselectedstructarr[_DBUi,4])+"  ")
         CASE _DBUselectedstructarr[_DBUi,2] == "L"
            aadd(_DBUcurrentrecordarr,iif(&(_DBUselectedstructarr[_DBUi,1]),"T","F")+space(_DBUlongest - _DBUselectedstructarr[_DBUi,3])+"  ")
         CASE _DBUselectedstructarr[_DBUi,2] == "D"
            IF _DBUlongest < 10
               _DBUlongest := 10
            ENDIF
            aadd(_DBUcurrentrecordarr,dtoc(&(_DBUselectedstructarr[_DBUi,1]))+space(_DBUlongest - (_DBUselectedstructarr[_DBUi,3]+2))+"  ")
         CASE _DBUselectedstructarr[_DBUi,2] == "M"
            aadd(_DBUcurrentrecordarr,"<Memo>"+space(_DBUlongest - 6)+"  ")
         END CASE
      NEXT _DBUi
      DBUprintline(_DBUrow,_DBUcol,_DBUcurrentrecordarr,_DBUjustifyarr,"f0")
      _DBUrow := _DBUrow + 1
      IF _DBUrow >= _DBUmaxrow1
         @ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
         _DBUlastrow := _DBUrow
         @ _DBUfirstrow,_DBUcol,_DBUlastrow,_DBUcol line
         FOR _DBUi := 1 to len(_DBUlinesrefarr)
            @ _DBUfirstrow,_DBUlinesrefarr[_DBUi],_DBUlastrow,_DBUlinesrefarr[_DBUi] line
         NEXT _DBUi
         _DBUpageno := _DBUpageno + 1
         _DBUrow := 3
      END PAGE
      start page
      @ _DBUrow,_DBUmaxcol1 - 20 say "Page No. : "+alltrim(str(_DBUpageno,10,0)) to print
      _DBUrow := _DBUrow + 1
      @ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
      @ _DBUrow,_DBUcol say "File Name               : "+cFileNoPath(alltrim(_DBUfname)) to print
      _DBUrow := _DBUrow + 1
      @ _DBUrow,_DBUcol say "Total Number of Records : "+alltrim(str(reccount(),10,0)) to print
      _DBUrow := _DBUrow + 1
      _DBUfirstrow := _DBUrow
      @ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
      DBUprintline(_DBUrow,_DBUcol,_DBUheadingarr,_DBUjustifyarr,"f0")
      _DBUrow := _DBUrow + 1
      @ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
   ENDIF
   SKIP
ENDDO
dbgoto(_DBUcurrec)
@ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
_DBUlastrow := _DBUrow
@ _DBUfirstrow,_DBUcol,_DBUlastrow,_DBUcol line
FOR _DBUi := 1 to len(_DBUlinesrefarr)
   @ _DBUfirstrow,_DBUlinesrefarr[_DBUi],_DBUlastrow,_DBUlinesrefarr[_DBUi] line
NEXT _DBUi
END PAGE
END doc
RELEASE printsys
_DBUprintfields.release

RETURN NIL

FUNCTION DBUprintstruct

   LOCAL _t, _l, _b, _r

   IF .not. used()

      RETURN NIL
   ENDIF
   INIT printsys
   SELECT by dialog preview
   _t := (GetDesktopHeight() - 699) / 2
   _l := (GetDesktopWidth() - 499) / 2
   _b := GetDesktopHeight() - _t
   _r := GetDesktopWidth() - _l
   SET preview rect _t, _l, _b, _r
   DEFINE FONT "f0" name "Courier New" size 12
   SELECT font "f0"
   start doc
   SET page orientation DMORIENT_PORTRAIT paperSize DMPAPER_A4 font "f0"
   start page
   _DBUmaxrow1 := hbprnmaxrow - 3
   _DBUmaxcol1 := 40
   _DBUrow := 3
   _DBUcol := 2
   @ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
   @ _DBUrow,_DBUcol say "File Name               : "+cFileNoPath(alltrim(_DBUfname)) to print
   _DBUrow := _DBUrow + 1
   @ _DBUrow,_DBUcol say "Total Number of Records : "+alltrim(str(reccount(),10,0)) to print
   _DBUrow := _DBUrow + 1

   _DBUheadingarr := {"Field Name  ","Type       ","Size   ","Decimals  "}
   _DBUjustifyarr := {0,0,1,1}
   _DBUlinesrefarr := {13,24,31,40}
   _DBUstructarr := dbstruct()
   @ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
   _DBUfirstrow := _DBUrow
   DBUprintline(_DBUrow,_DBUcol,_DBUheadingarr,_DBUjustifyarr,"f0")
   _DBUrow := _DBUrow + 1
   @ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
   _DBUtype1 := ""
   FOR _DBUi := 1 to len(_DBUstructarr)
      DO CASE
      CASE _DBUstructarr[_DBUi,2] == "C"
         _DBUtype1 := "Character"
      CASE _DBUstructarr[_DBUi,2] == "N"
         _DBUtype1 := "Numeric  "
      CASE _DBUstructarr[_DBUi,2] == "L"
         _DBUtype1 := "Logical  "
      CASE _DBUstructarr[_DBUi,2] == "D"
         _DBUtype1 := "Date     "
      CASE _DBUstructarr[_DBUi,2] == "M"
         _DBUtype1 := "Memo     "
      ENDCASE
      DBUprintline(_DBUrow,_DBUcol,{_DBUStructarr[_DBUi,1]+space(10 - len(alltrim(_DBUstructarr[_DBUi,1])))+"  ",;
         _DBUtype1+"  ",;
         str(_DBUstructarr[_DBUi,3],5,0)+"  ",;
         str(_DBUstructarr[_DBUi,4],5,0)+"  "},_DBUjustifyarr,"f0")
      _DBUrow := _DBUrow + 1
      IF _DBUrow >= _DBUmaxrow1
         @ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
         _DBUlastrow := _DBUrow
         @ _DBUfirstrow,_DBUcol,_DBUlastrow,_DBUcol line
         FOR _DBUj := 1 to len(_DBUlinesrefarr)
            @ _DBUfirstrow,_DBUlinesrefarr[_DBUj],_DBUlastrow,_DBUlinesrefarr[_DBUj] line
         NEXT _DBUj
         _DBUpageno := _DBUpageno + 1
         _DBUrow := 3
      END PAGE
      start page
      @ _DBUrow,_DBUmaxcol1 - 20 say "Page No. : "+alltrim(str(_DBUpageno,10,0)) to print
      _DBUrow := _DBUrow + 1
      @ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
      @ _DBUrow,_DBUcol say "File Name               : "+cFileNoPath(alltrim(_DBUfname)) to print
      _DBUrow := _DBUrow + 1
      @ _DBUrow,_DBUcol say "Total Number of Records : "+alltrim(str(reccount(),10,0)) to print
      _DBUrow := _DBUrow + 1
      _DBUfirstrow := _DBUrow
      @ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
      DBUprintline(_DBUrow,_DBUcol,_DBUheadingarr,_DBUjustifyarr,"f0")
      _DBUrow := _DBUrow + 1
      @ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
   ENDIF
NEXT _DBUi
@ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
_DBUlastrow := _DBUrow
@ _DBUfirstrow,_DBUcol,_DBUlastrow,_DBUcol line
FOR _DBUi := 1 to len(_DBUlinesrefarr)
   @ _DBUfirstrow,_DBUlinesrefarr[_DBUi],_DBUlastrow,_DBUlinesrefarr[_DBUi] line
NEXT _DBUi
END PAGE
END doc
RELEASE printsys

RETURN NIL

/*
===============================================================
| FUNCTION BIGELEM()
===============================================================
|
|  Short:
|  ------
|  BIGELEM() Returns length of longest string in an array
|
|  Returns:
|  --------
|  <nLength> => Length of longest string in an array
|
|  Syntax:
|  -------
|  BIGELEM(aTarget)
|
|  Description:
|  ------------
|  Determines the length of the longest string element
|  in <aTarget> Array may have mixed types
|
|  Examples:
|  ---------
|   ?BIGELEM(  {"1","22","333"}  )  => returns 3
|
|  Notes:
|  -------
|  This was a C function in previous SuperLibs
|
|  Source:
|  -------
|  S_BIGEL.PRG
|
===============================================================*/

FUNCTION BIGELEM(aArray)

   LOCAL nLongest := 0
   LOCAL nIterator

   FOR nIterator = 1 to len(aArray)
      IF valtype(aArray[nIterator])=="C"
         nLongest := max(nLongest,len(aArray[nIterator]))
      ENDIF
   NEXT

   RETURN nLongest

FUNCTION DBUprintline(row,col,aitems,ajustify,currentfont)

   LOCAL tempcol := 0
   LOCAL i
   LOCAL oldstyle
   LOCAL njustify

   IF len(aitems) <> len(ajustify)
      msgalert("Justification constants not given properly.","Warning")
   ENDIF
   tempcol := col
   GET text align to oldstyle
   FOR i := 1 to len(aitems)
      njustify := ajustify[i]
      DO CASE
      CASE njustify == 0
         SET text align left
      CASE njustify == 1
         SET text align right
      CASE njustify == 2
         SET text align center
      END CASE
      @ row,iif(njustify == 1,tempcol + len(aitems[i]),tempcol) say aitems[i] font currentfont to print
      tempcol := tempcol + len(aitems[i])
   NEXT i
   SET text align oldstyle

   RETURN NIL
