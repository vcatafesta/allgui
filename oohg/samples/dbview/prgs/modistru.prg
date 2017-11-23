/*
* $Id: modistru.prg,v 1.2 2016/10/17 01:55:33 fyurisich Exp $
*/

/*
* MINIGUI - Harbour Win32 GUI library
* Copyright 2002-2012 Roberto Lopez <harbourminigui@gmail.com>
* http://harbourminigui.googlepages.com/
* Program to view DBF files using standard Browse control
* Miguel Angel Juárez A. - 2009-2012 MigSoft <mig2soft/at/yahoo.com>
* Includes the code of Grigory Filatov <gfilatov@inbox.ru>
* and Rathinagiri <srathinagiri@gmail.com>
*/

#include "oohg.ch"
#include "dbuvar.ch"

FUNCTION DBUmodistruct(cBase)

   DECLARE WINDOW oWndBase

   lModYes           := .F.
   _dbufname         := cBase

   IF !Empty(Alias())

      _DBUoriginalarr := dbstruct()
      _DBUstructarr   := dbstruct()
      _DBUdbfsaved    := .f.

      DEFINE WINDOW _DBUcreadbf AT 295 , 312 WIDTH 549 HEIGHT 266 title PROGRAM+VERSION+"- Modify DataBase Table" MODAL nosize nosysmenu

         DEFINE TEXTBOX _DBUfieldname
            ROW    40
            COL    30
            WIDTH  120
            HEIGHT 24
         END TEXTBOX

         DEFINE COMBOBOX _DBUfieldtype
            ROW    40
            COL    160
            WIDTH  120
            HEIGHT 100
            ITEMS {"Character","Numeric","Date","Logical","Memo"} //,"General","Integer","TimeStamp","Time","Image","Binary","Money","Double"}
            VALUE 1
            ON LOSTFOCUS DBUtypelostfocus()
            ON ENTER DBUtypelostfocus()
         END COMBOBOX

         DEFINE LABEL _DBUnamelabel
            ROW    20
            COL    30
            WIDTH  80
            HEIGHT 20
            VALUE "Field"
         END LABEL

         DEFINE LABEL _DBUtypelabel
            ROW    20
            COL    160
            WIDTH  80
            HEIGHT 20
            VALUE "Type"
         END LABEL

         DEFINE LABEL _DBUsizelabel
            ROW    20
            COL    290
            WIDTH  60
            HEIGHT 20
            VALUE "Size"
         END LABEL

         DEFINE LABEL _DBUdecimallabel
            ROW    20
            COL    360
            WIDTH  60
            HEIGHT 16
            VALUE "Digits"
         END LABEL

         DEFINE SPINNER _DBUfieldsize
            ROW    40
            COL    290
            WIDTH  60
            HEIGHT 24
            RANGEMIN 1
            RANGEMAX 100
            VALUE 10
            on lostfocus DBUsizelostfocus()
         END SPINNER

         DEFINE SPINNER _DBUfielddecimals
            ROW    40
            COL    360
            WIDTH  60
            HEIGHT 24
            RANGEMIN 0
            RANGEMAX 99
            on lostfocus DBUdeclostfocus()
         END SPINNER

         DEFINE BUTTON _DBUaddline
            ROW    40
            COL    430
            WIDTH  80
            HEIGHT 28
            CAPTION "Add"
            action DBUaddstruct()
         END BUTTON

         DEFINE BUTTON _DBUinsline
            ROW    70
            COL    430
            WIDTH  80
            HEIGHT 28
            CAPTION "Insert"
            action DBUinsstruct()
         END BUTTON

         DEFINE BUTTON _DBUdelline
            ROW    100
            COL    430
            WIDTH  80
            HEIGHT 28
            CAPTION "Delete"
            action DBUdelstruct()
         END BUTTON

         DEFINE GRID _DBUstruct
            ROW    80
            COL    30
            WIDTH  390
            HEIGHT 120
            WIDTHS {145,80,70,70}
            HEADERS {"Name","Type","Size","Decimals"}
            justify {0,0,1,1}
            items _DBUstructarr
            on dblclick DBUlineselected()
         END GRID

         DEFINE BUTTON _DBUsavestruct
            ROW    140
            COL    430
            WIDTH  80
            HEIGHT 28
            CAPTION "Save"
            action lModYes := Modi_Now(cBase) //DBUmodistructure()
         END BUTTON

         DEFINE BUTTON _DBUexitnew
            ROW    170
            COL    430
            WIDTH  80
            HEIGHT 28
            CAPTION "Cancel"
            action lModYes := DBUexitmodidbf()
         END BUTTON

      END WINDOW

      CENTER WINDOW _DBUcreadbf
      _DBUcreadbf._DBUstruct.deleteallitems()

      FOR _DBUi := 1 to len(_DBUstructarr)
         DO CASE
         CASE _DBUstructarr[_DBUi,2] == "C"
            _DBUtype1 := "Character"
         CASE _DBUstructarr[_DBUi,2] == "N"
            _DBUtype1 := "Numeric"
         CASE _DBUstructarr[_DBUi,2] == "B"
            _DBUtype1 := "Double"
         CASE _DBUstructarr[_DBUi,2] == "I"
            _DBUtype1 := "Integer"
         CASE _DBUstructarr[_DBUi,2] == "Y"
            _DBUtype1 := "Money"
         CASE _DBUstructarr[_DBUi,2] == "W"
            _DBUtype1 := "Binary"
         CASE _DBUstructarr[_DBUi,2] == "P"
            _DBUtype1 := "Image"
         CASE _DBUstructarr[_DBUi,2] == "G"
            _DBUtype1 := "General"
         CASE _DBUstructarr[_DBUi,2] == "@"
            _DBUtype1 := "TimeStamp"
         CASE _DBUstructarr[_DBUi,2] == "T"
            _DBUtype1 := "Time"
         CASE _DBUstructarr[_DBUi,2] == "D"
            _DBUtype1 := "Date"
         CASE _DBUstructarr[_DBUi,2] == "L"
            _DBUtype1 := "Logical"
         CASE _DBUstructarr[_DBUi,2] == "M"
            _DBUtype1 := "Memo"
         OTHERWISE
            _DBUtype1 := "Other"
         END CASE
         _DBUcreadbf._DBUstruct.additem({_DBUstructarr[_DBUi,1],;
            _DBUtype1,;
            str(_DBUstructarr[_DBUi,3],8,0),;
            str(_DBUstructarr[_DBUi,4],3,0)})
      NEXT _DBUi
      IF len(_DBUstructarr) > 0
         _DBUcreadbf._DBUstruct.value := len(_DBUstructarr)
      ENDIF

      ON KEY F5 OF _DBUcreadbf ACTION AutoMsgInfo( ( Alias() )->( Select() ), "Select()" )

      ACTIVATE WINDOW _DBUcreadbf
   ENDIF

   RETURN ( lModYes )

FUNCTION DBUmodistructure(cBase)

   IF !msgyesno( PadC("C A U T I O N",70)+ CRLF + CRLF +;
         PadC("If you had modified either the field name or the field type,",70) + CRLF +;
         PadC("the data for that fields can not be saved in the modified .DBF",70) + CRLF +;
         PadC("However, a backup file (.BAK) will be created.",70) + CRLF + CRLF +;
         PadC("Are you sure to modify the structure?",70), PROGRAM+VERSION )

      RETURN (.F.)
   ENDIF

   nPos      := ( ( Alias() )->( Select( oWndBase.Tab_1.caption( oWndBase.Tab_1.value ) ) ) )
   cAreaPos  := AllTrim( Str( ( ( Alias() )->( Select( oWndBase.Tab_1.caption( oWndBase.Tab_1.value ) ) ) ) ))
   cBrowse_n := "Browse_"+cAreaPos

   _DBUfname  := cBase
   cPathDBFm := cFilePath(aFiles[( Alias() )->( Select( oWndBase.Tab_1.caption( oWndBase.Tab_1.value ) ) )])

   _DBUfname1 := "DBTemp"

   CursorWait()

   _DBUmodarr := {}
   FOR _DBUi := 1 to len(_DBUstructarr)
      IF _DBUi <= len(_DBUoriginalarr)
         _DBUline := ascan(_DBUoriginalarr,{|_DBUx|upper(alltrim(_DBUx[1])) == upper(alltrim(_DBUstructarr[_DBUi,1]))})
         IF _DBUline > 0
            IF _DBUoriginalarr[_DBUline,2] == _DBUstructarr[_DBUi,2]
               aadd(_DBUmodarr,_DBUi)
            ENDIF
         ENDIF
      ENDIF
   NEXT _DBUi
   IF len(_DBUstructarr) > 0
      IF len(_DBUfname1) > 0
         dbcreate(cPathDBFm+_DBUfname1,_DBUstructarr)
         USE &(cPathDBFm+_DBUfname1) new
         SELECT &_DBUfname
         GO TOP
         IF len(_DBUmodarr) > 0
            DO WHILE .not. eof()
               SELECT &_DBUfname1
               APPEND BLANK
               FOR _DBUi := 1 to len(_DBUmodarr)
                  _DBUfieldname := _DBUstructarr[_DBUmodarr[_DBUi],1]
                  REPLACE &_DBUfname1->&_DBUfieldname with &_DBUfname->&_DBUfieldname
               NEXT _DBUi
               SELECT &_DBUfname
               SKIP
               App_Progress()
            ENDDO
         ENDIF
         SELECT &_DBUfname
         CLOSE &_DBUfname
         SELECT &_DBUfname1
         CLOSE &_DBUfname1

         IF at(".",cPathDBFm+_DBUfname) == 0
            _DBUbackname := alltrim(cPathDBFm+_DBUfname)+".dbf"
            IF file(_DBUbackname)
               IF file(alltrim(cPathDBFm+_DBUfname)+".bak")
                  ferase(alltrim(cPathDBFm+_DBUfname)+".bak")
               ENDIF
               frename(_DBUbackname,alltrim(cPathDBFm+_DBUfname)+".bak")
               frename(cPathDBFm+'DBTemp.dbf',alltrim(cPathDBFm+_DBUfname)+".dbf")
               IF file(cPathDBFm+'DBTemp.fpt')
                  frename(cPathDBFm+'DBTemp.fpt',alltrim(cPathDBFm+_DBUfname)+".fpt")
               ENDIF
            ENDIF
         ELSE
            _DBUnewname := substr(alltrim(cPathDBFm+_DBUfname),1,at(".",cPathDBFm+_DBUfname)-1)+".bak"
            IF file(cPathDBFm+_DBUfname)
               IF file(_DBUnewname)
                  ferase(_DBUnewname)
               ENDIF
               frename(cPathDBFm+_DBUfname,_DBUnewname)
               frename(cPathDBFm+'DBTemp.dbf',alltrim(cPathDBFm+_DBUfname))
            ENDIF
         ENDIF
         IF IsControlDefine( &(cBrowse_n), oWndBase )
            oTab := GetControlObject("Tab_1","oWndBase")
            oTab:DeletePage ( oTab:value, oTab:caption( oTab:value ) )
            IF DB_Open(cPathDBFm+_DBUfname)
               ArmMatrix()
               cAreaPos  := AllTrim( Str( ( ( Alias() )->( Select( oWndBase.Tab_1.caption( oWndBase.Tab_1.value ) ) ) ) ))
               cBrowse_n := "Browse_"+cAreaPos
               oWndBase.&(cBrowse_n).ColumnsAutoFitH
               oWndBase.&(cBrowse_n).SetFocus
            ENDIF
         ENDIF
         RELEASE WINDOW Form_idx
         RELEASE WINDOW _DBUcreadbf
      ENDIF
   ENDIF

   CursorArrow()

   RETURN (.T.)

FUNCTION DBUexitmodidbf

   IF len(_DBUstructarr) == 0 .or. _DBUdbfsaved
      RELEASE WINDOW _DBUcreadbf
      lModYes := .T.
   ELSE
      IF msgyesno("Are you sure to abort Modifying this dbf?",PROGRAM)
         lModYes := .F.
         RELEASE WINDOW _DBUcreadbf
      ENDIF
   ENDIF

   RETURN (lModYes)

FUNCTION Modi_Now(cBase)

   LOCAL lResult := .F.

   DEFINE WINDOW Form_idx AT 274,282 WIDTH 298 HEIGHT 100 ;
         TITLE "Structure Changing in progress !!!" ICON "Main1" MODAL NOSIZE ;
         ON INIT lResult := DBUmodistructure(cBase) ;
         FONT 'Arial' SIZE 09 nosysmenu nomaximize nominimize

      @  6,94 LABEL Label_001 VALUE "Completed " WIDTH 120 HEIGHT 18
      @ 26,19 PROGRESSBAR ProgressBar_1 RANGE 0,100 WIDTH 252 HEIGHT 18

   END WINDOW

   Form_idx.Center
   Form_idx.Activate

   RETURN( lResult )

FUNCTION App_Progress()

   LOCAL nComplete := Max( Min( ( RecNo()/LastRec() ) * 100, 100 ), 0 )
   LOCAL cComplete := Ltrim(Str(nComplete))

   Form_idx.Label_001.Value := "Completed "+ cComplete + "%"
   Form_idx.ProgressBar_1.Value := nComplete

   RETURN(.T.)

FUNCTION cFilePath( cPathMask )

   LOCAL n := RAt( "\", cPathMask ), cDisk

   RETURN If( n > 0, Upper( Left( cPathMask, n ) ),;
      ( cDisk := cFileDisc( cPathMask ) ) + If( ! Empty( cDisk ), "\", "" ) )

FUNCTION cFileDisc( cPathMask )

   RETURN If( At( ":", cPathMask ) == 2, Upper( Left( cPathMask, 2 ) ), "" )
