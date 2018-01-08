#include "hmg.ch"

MEMVAR _HMG_CSG_DBO
MEMVAR cTblName
MEMVAR _HMG_CSG_aTable
MEMVAR _HMG_CSG_nCols
MEMVAR _HMG_CSG_lShowHeaders

PROC _DefineComboSearchGrid( cCSBoxName, ;
      cCSBoxParent, ;
      cCSBoxCol, ;
      cCSBoxRow, ;
      cCSBoxWidth, ;
      cCSBoxHeight, ;
      cCSBoxValue, ;
      cFontName, ;
      nFontSize, ;
      cToolTip, ;
      nMaxLenght, ;
      lUpper, ;
      lLower, ;
      lNumeric, ;
      bLostFocus, ;
      bGotFocus, ;
      bEnter, ;
      lRightAlign, ;
      nHelpId, ;
      lBold, ;
      lItalic, ;
      lUnderline, ;
      aBackColor, ;
      aFontColor, ;
      lNoTabStop, ;
      aArray, ;
      lAnyWhere, ;
      nDropHeight, ;
      aColumnHeaders, ;
      aColumnJustify, ;
      aColumnWidths, ;
      lShowHeaders ;
      )

   LOCAL   cParentName
   LOCAL   lOk := .f.
   LOCAL   i
   LOCAL   j
   LOCAL   cTblName := ''
   LOCAL   cQStr

   DEFAULT cCSBoxWidth  := 120
   DEFAULT cCSBoxHeight := 24
   DEFAULT cCSBoxValue  := ""
   DEFAULT bGotFocus    := ""
   DEFAULT bLostFocus   := ""
   DEFAULT nMaxLenght   := 255
   DEFAULT lUpper       := .F.
   DEFAULT lLower       := .F.
   DEFAULT lNumeric     := .F.
   DEFAULT bEnter       := ""
   DEFAULT lAnyWhere    := .f.
   DEFAULT nDropHeight  := 0
   DEFAULT aColumnJustify := {}
   DEFAULT aColumnWidths := {}
   DEFAULT lShowHeaders := .t.

   IF _HMG_BeginWindowActive = .T.
      cParentName := _HMG_ActiveFormName
   ELSE
      cParentName := cCSBoxParent
   ENDIF

   IF TYPE( '_HMG_CSG_DBO' ) == 'U'
      PUBLIC _HMG_CSG_DBO

      _HMG_CSG_DBO := _Connect_CSG_DB( '', .t. )
   ENDIF

   IF _HMG_CSG_DBO == Nil

      RETURN
   ENDIF

   IF LEN( aColumnJustify ) == 0
      FOR i := 1 to len( aArray[ 1 ] )
         aadd( aColumnJustify, 0 ) // left aligned
      NEXT i
   ENDIF

   IF LEN( aColumnWidths ) == 0
      FOR i := 1 to len( aArray[ 1 ] )
         aadd( aColumnWidths, 100 ) // default column width
      NEXT i
   ENDIF

   lOk := _HMG_CSG_MiscSQL( _HMG_CSG_DBO, "create table if not exists itemselected ( tblname VARCHAR NOT NULL  DEFAULT '', tblrowid INTEGER NOT NULL  DEFAULT 0) ")
   IF .not. lOk

      RETURN
   ENDIF

   cTblName := cParentName + '_' + cCSBoxName

   lOk := _HMG_CSG_MiscSQL( _HMG_CSG_DBO, 'drop table if exists ' + cTblName )
   IF .not. lOk

      RETURN
   ENDIF

   // create table

   cQStr := 'create table ' + cTblName + '('
   FOR i := 1 to len( aArray[ 1 ] )
      cQStr := cQStr + 'col' + alltrim( str( i ) )
      IF i < len( aArray[ 1 ] )
         cQStr := cQStr + ', '
      ENDIF
   NEXT i
   cQStr := cQStr + ')'

   lOk := _HMG_CSG_MiscSQL( _HMG_CSG_DBO, cQStr )
   IF .not. lOk

      RETURN
   ENDIF

   // add data to table

   lOk := _HMG_CSG_MiscSQL( _HMG_CSG_DBO, 'Begin Transaction' )
   IF .not. lOk

      RETURN
   ENDIF
   FOR i := 1 to len( aArray )
      cQStr := 'insert into ' + cTblName + ' values ('
      FOR j := 1 to len( aArray[ i ] )
         cQStr := cQStr + _HMG_CSG_C2SQL( aArray[ i, j ] )
         IF j < len( aArray[ i ] )
            cQStr := cQStr + ', '
         ENDIF
      NEXT j
      cQStr := cQStr + ')'
      _HMG_CSG_MiscSQL( _HMG_CSG_DBO, cQStr )
      IF .not. lOk

         RETURN
      ENDIF
   NEXT i
   lOk := _HMG_CSG_MiscSQL( _HMG_CSG_DBO, 'commit Transaction' )
   IF .not. lOk

      RETURN
   ENDIF

   lOk := _HMG_CSG_MiscSQL( _HMG_CSG_DBO, 'delete from itemselected where tblname = ' + _HMG_CSG_C2SQL( cTblName ) )
   IF .not. lOk

      RETURN
   ENDIF

   lOk := _HMG_CSG_MiscSQL( _HMG_CSG_DBO, 'insert into itemselected values ( ' + _HMG_CSG_C2SQL( cTblName ) + ', ' + _HMG_CSG_C2SQL( cTblName ) + ' )' )
   IF .not. lOk

      RETURN
   ENDIF

   DEFINE TEXTBOX &cCSBoxName
      PARENT        &cCSBoxParent
      ROW           cCSBoxRow
      COL           cCSBoxCol
      WIDTH         cCSBoxWidth
      HEIGHT        cCSBoxHeight
      VALUE         cCSBoxValue
      FONTNAME      cFontName
      FONTSIZE      nFontSize
      TOOLTIP       cToolTip
      MAXLENGTH     nMaxLenght
      UPPERCASE     lUpper
      LOWERCASE     lLower
      NUMERIC       lNumeric
      ONLOSTFOCUS   iif(ISBLOCK(bLostFocus), Eval(bLostFocus), NIL)
      ONGOTFOCUS    iif(ISBLOCK(bGotFocus), Eval(bGotFocus), NIL)
      ONENTER       iif(ISBLOCK(bEnter), Eval(bEnter), NIL)
      ONCHANGE      CreateCSGrid( cParentName, cCSBoxName, aArray, cCSBoxRow, cCSBoxCol, lAnyWhere, nDropHeight, cTblName, aColumnHeaders, aColumnJustify, aColumnWidths, lShowHeaders )
      RIGHTALIGN    lRightAlign
      HELPID        nHelpId
      FONTBOLD      lBold
      FONTITALIC    lItalic
      FONTUNDERLINE lUnderline
      BACKCOLOR     aBackColor
      FONTCOLOR     aFontColor
      TABSTOP       lNoTabStop
   END TEXTBOX

   RETURN // _DefineComboSearchBox()

   *-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

   STATIC PROC CreateCSGrid( cParentName, cCSBoxName, aitems, cCSBoxRow, cCSBoxCol, lAnyWhere, nDropHeight, cTableName, aColumnHeaders, aColumnJustify, aColumnWidths, lShowHeaders )

      LOCAL nFormRow       := thisWindow.row
      LOCAL nFormCol       := thisWindow.col
      LOCAL nControlRow    := this.row + 1
      LOCAL nControlCol    := this.col + 1
      LOCAL nControlWidth  := this.width
      LOCAL nControlHeight := this.height
      LOCAL cCurValue      := this.value
      LOCAL cFontname      := this.fontname
      LOCAL nFontsize      := this.Fontsize
      LOCAL cTooltip       := this.tooltip
      LOCAL lFontbold      := this.fontbold
      LOCAL lFontitalic    := this.fontitalic
      LOCAL lFontunderline := this.fontunderline
      LOCAL aBackcolor     := this.backcolor
      LOCAL aFontcolor     := this.fontcolor
      LOCAL aResults       := {}
      LOCAL nContIndx      := GetControlIndex( this.name, thiswindow.name )
      LOCAL result         := 0
      LOCAL nItemNo        := 0
      LOCAL nListBoxHeight := 0
      LOCAL caret          := this.CaretPos
      LOCAL cCSBxName      := 'frm' + cCSBoxName
      LOCAL cQStr
      LOCAL i

      HB_SYMBOL_UNUSED( aitems )
      HB_SYMBOL_UNUSED( cCSBoxRow )
      HB_SYMBOL_UNUSED( cCSBoxCol )
      HB_SYMBOL_UNUSED( aColumnJustify )

      PRIVATE cTblName := cTableName
      PRIVATE _HMG_CSG_aTable := {}
      PRIVATE _HMG_CSG_nCols := len( aColumnHeaders )
      PRIVATE _HMG_CSG_lShowHeaders := lShowHeaders

      IF iswindowdefined( &cCSBxName )

         RETURN
      ENDIF

      IF !EMPTY(cCurValue)

         IF _HMG_aControlContainerRow [nContIndx] # -1
            nControlRow += _HMG_aControlContainerRow [nContIndx]
            nControlCol += _HMG_aControlContainerCol [nContIndx]
         ENDIF

         cQStr := 'select * from ' + cTblName + ' where '
         FOR i := 1 to _HMG_CSG_nCols
            IF lAnyWhere
               cQStr := cQStr + 'col' + alltrim( str( i ) ) + ' like ' + _HMG_CSG_c2SQL( '%' + cCurValue + '%' )
            ELSE
               cQStr := cQStr + 'col' + alltrim( str( i ) ) + ' like ' + _HMG_CSG_c2SQL( cCurValue + '%' )
            ENDIF
            IF i < _HMG_CSG_nCols
               cQStr := cQStr + ' or '
            ENDIF
         NEXT i
         cQStr := cQStr + ' order by '
         FOR i := 1 to _HMG_CSG_nCols
            cQStr := cQstr + 'col' + alltrim( str( i ) )
            IF i < _HMG_CSG_nCols
               cQStr := cQstr + ', '
            ENDIF
         NEXT i
         _HMG_CSG_aTable := _HMG_CSG_SQL( _HMG_CSG_DBO, cQStr )

         IF LEN( _HMG_CSG_aTable ) > 0

            nListBoxHeight := MAX( MIN( iif( nDropHeight == 0, ( LEN( _HMG_CSG_aTable ) * 16 ) + 30, nDropHeight ), thiswindow.height - nControlRow - nControlHeight - 10 ), iif( _HMG_CSG_lShowHeaders, 80, 60) )

            DEFINE WINDOW &cCSBxName ;
                  AT     nFormRow+nControlRow+20, nFormCol+nControlCol ;
                  WIDTH  nControlWidth+6 ;
                  HEIGHT nListBoxHeight + nControlHeight + 10 ;
                  TITLE '' ;
                  MODAL ;
                  NOCAPTION ;
                  NOSIZE ;
                  ON INIT SetProperty( cCSBxName, '_cstext', "CaretPos", caret )

               ON KEY UP     ACTION _CSGDoUpKey()
               ON KEY DOWN   ACTION _CSGDoDownKey()
               ON KEY ESCAPE ACTION _CSGDoEscKey(cParentName, cCSBoxName)
               ON KEY TAB    ACTION _CSGItemSelected( cParentName, cCSBoxName, .t. )

               DEFINE TEXTBOX _cstext
                  ROW           3
                  COL           3
                  WIDTH         nControlWidth
                  HEIGHT        nControlHeight
                  FONTNAME      cFontname
                  FONTSIZE      nFontsize
                  TOOLTIP       cTooltip
                  FONTBOLD      lFontbold
                  FONTITALIC    lFontitalic
                  FONTUNDERLINE lFontunderline
                  BACKCOLOR     aBackcolor
                  FONTCOLOR     aFontcolor
                  ON CHANGE     _CSGTextChanged( cParentName, cCSBoxName, lAnyWhere, nDropHeight )
                  ON ENTER      _CSGItemSelected( cParentName, cCSBoxName, .t. )
               END TEXTBOX

               DEFINE GRID _cslist
                  ROW          nControlHeight+3
                  COL          3
                  WIDTH        nControlWidth
                  HEIGHT       nListBoxHeight
                  ON DBLCLICK  _CSGItemSelected( cParentName, cCSBoxName, .t. )
                  VALUE        1
                  HEADERS      aColumnHeaders
                  WIDTHS       aColumnWidths
                  SHOWHEADERS  lShowHeaders
                  VIRTUAL      .t.
                  ITEMCOUNT    len( _HMG_CSG_aTable )
                  ON QUERYDATA _HMG_CSG_QueryItem()
               END GRID

            END WINDOW

            SetProperty( cCSBxName, '_cstext', "VALUE", cCurValue )

            ACTIVATE WINDOW &cCSBxName

         ENDIF
      ENDIF

      RETURN // CreateCSGBox()

FUNCTION _HMG_CSG_QueryItem

   LOCAL i := this.QueryRowIndex
   LOCAL j := this.QueryColIndex

   IF i > 0 .and. j > 0
      IF i <= len( _HMG_CSG_aTable )
         IF j <= len( _HMG_CSG_aTable[ i ] )
            this.QueryData := _HMG_CSG_aTable[ i, j ]
         ENDIF
      ENDIF
   ENDIF

   RETURN NIL

   *-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

   STATIC PROC _CSGTextChanged( cParentName, cTxBName, lAnyWhere, nDropHeight )

      LOCAL cCurValue      := GetProperty( ThisWindow.Name, '_cstext', "VALUE" )
      LOCAL aResults       := {}
      LOCAL nItemNo        := 0
      LOCAL nListBoxHeight := 0
      LOCAL nParentHeight  := GetProperty(cParentName,"HEIGHT")
      LOCAL nParentRow     := GetProperty(cParentName,"ROW")
      LOCAL cQStr         := ''
      LOCAL i := 0

      HB_SYMBOL_UNUSED( cTxBName )

      SetProperty( ThisWindow.Name, "_csList", 'ITEMCOUNT', 0 )
      aSize( _HMG_CSG_aTable, 0 )
      cQStr := 'select * from ' + cTblName + ' where '

      FOR i := 1 to _HMG_CSG_nCols
         IF lAnyWhere
            cQStr := cQStr + 'col' + alltrim( str( i ) ) + ' like ' + _HMG_CSG_c2SQL( '%' + cCurValue + '%' )
         ELSE
            cQStr := cQSTr + 'col' + alltrim( str( i ) ) + ' like ' + _HMG_CSG_c2SQL( cCurValue + '%' )
         ENDIF
         IF i < _HMG_CSG_nCols
            cQStr := cQStr + ' or '
         ENDIF
      NEXT i
      cQStr := cQStr + ' order by '
      FOR i := 1 to _HMG_CSG_nCols
         cQStr := cQStr + 'col' + alltrim( str( i ) )
         IF i < _HMG_CSG_nCols
            cQStr := cQStr + ', '
         ENDIF
      NEXT i

      _HMG_CSG_aTable := _HMG_CSG_SQL( _HMG_CSG_DBO, cQStr )
      SetProperty( ThisWindow.Name, "_csList", 'ITEMCOUNT', len( _HMG_CSG_aTable ) )
      IF len( _HMG_CSG_aTable ) > 0
         SetProperty( ThisWindow.Name, "_csList", 'VALUE', 1 )
      ENDIF

      nListBoxHeight := MAX( MIN( if( nDropHeight == 0, ( LEN( _HMG_CSG_aTable ) * 16 ) + 40, nDropHeight ), ( nParentHeight - nParentRow - ;
         GetProperty( ThisWindow.Name, "_csText", 'HEIGHT' ) -  10)), iif( _HMG_CSG_lShowHeaders, 60, 40))

      SetProperty( ThisWindow.Name, "_csList", "HEIGHT", nListBoxHeight )
      SetProperty( ThisWindow.Name, "HEIGHT", nListBoxHeight + GetProperty( ThisWindow.Name, '_cstext', "HEIGHT" ) + 20 )

      RETURN // _CSGTextChanged()

      *-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

      STATIC PROC _CSGItemSelected( cParentName, cTxBName, lTab )
         LOCAL lOk := .f.
         LOCAL nListValue
         LOCAL cListItem
         LOCAL aLineData
         LOCAL i
         LOCAL cQStr

         IF GetProperty( ThisWindow.Name, "_csList", "VALUE" ) > 0

            nListValue := GetProperty( ThisWindow.Name, '_csList', "VALUE" )
            cListItem  := _HMG_CSG_aTable[ nListValue, 1 ]
            aLineData := _HMG_CSG_aTable[ nListValue ]
            cQStr := 'update itemselected set tblrowid = ( select rowid from ' + cTblName + ' where '
            FOR i := 1 to _HMG_CSG_nCols
               cQStr := cQStr + 'col' + alltrim( str( i ) ) + ' = ' + _HMG_CSG_C2SQL( aLineData[ i ] )
               IF i < _HMG_CSG_nCols
                  cQStr := cQStr + ' and '
               ENDIF
            NEXT i
            cQStr := cQStr + ')'
            lOk := _HMG_CSG_MiscSQL( _HMG_CSG_DBO, cQStr )
            IF .not. lOk
               msgstop( 'Error in ComboSearchGrid!' )

               RETURN
            ENDIF

            SetProperty( cParentName, cTxBName, "VALUE", cListItem )

            SetProperty(cParentName,cTxBName,"CARETPOS", ;
               LEN( cListItem ) )

            DoMethod( ThisWindow.Name, "Release" )
            IF pcount() == 3
               IF lTab
                  _Pushkey(VK_TAB)
               ENDIF
            ENDIF
         ENDIF

         RETURN // _CSGItemSelected()

         *-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

         STATIC PROC _CSGDoUpKey()

            IF GetProperty( ThisWindow.Name, '_csList', "ItemCount" ) > 0 .AND. ;
                  GetProperty( ThisWindow.Name, '_csList', "VALUE" ) > 1
               SetProperty( ThisWindow.Name, '_csList', "VALUE", GetProperty( ThisWindow.Name, '_csList', "VALUE" ) - 1 )
            ENDIF

            RETURN // _CSGDoUpKey()

            *-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

            STATIC PROC _CSGDoDownKey()

               IF GetProperty( ThisWindow.Name, '_csList', "ItemCount" ) > 0 .AND. ;
                     GetProperty( ThisWindow.Name, '_csList', "VALUE" )     < ;
                     GetProperty( ThisWindow.Name, '_csList', "ItemCount" )
                  SetProperty( ThisWindow.Name, '_csList', "VALUE", GetProperty( ThisWindow.Name, '_csList', "VALUE" ) + 1 )
               ENDIF

               RETURN // _CSGDoDownKey()

               *-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

               STATIC PROC _CSGDoEscKey(cParentName, cCSBoxName)
                  LOCAL lOk := .f.
                  LOCAL cQStr

                  SetProperty( ThisWindow.Name, '_csText', "VALUE",'')
                  SetProperty( cParentName, cCSBoxName, "VALUE",'')
                  cQStr := 'update itemselected set tblrowid = 0'
                  lOk := _HMG_CSG_MiscSQL( _HMG_CSG_DBO, cQStr )
                  IF .not. lOk
                     msgstop( 'Error in ComboSearchGrid!' )

                     RETURN
                  ENDIF

                  DoMethod( ThisWindow.Name, "Release" )

                  RETURN // _CSGDoEscKey()

                  *-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNCTION _HMG_CSG_ItemSelected( cFrmName, cCSBoxName )

   LOCAL cTblName := cFrmName + '_' + cCSBoxName
   LOCAL aReturn := {}
   LOCAL aTable := {}

   IF !( _HMG_CSG_DBO == Nil )
      aTable := _HMG_CSG_SQL( _HMG_CSG_DBO, 'select * from ' + cTblName + ' where rowid = ( select tblrowid from itemselected where tblname = ' + _HMG_CSG_C2SQL( cTblName ) + ')' )
      IF len( aTable ) > 0
         aReturn := aClone( aTable[ 1 ] )
      ENDIF
   ENDIF

   RETURN aReturn

   *-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

   // SQLite Bridge Functions

STATIC FUNCTION _Connect_CSG_DB( cDBName, lCreate )

   LOCAL oDB := Nil

   oDB := sqlite3_open( cDBName, lCreate )
   IF Empty( oDB )
      msginfo("Database could not be created!")
   ENDIF

   RETURN oDB // _Connect_CSG_DB

STATIC FUNCTION _HMG_CSG_SQL( dbo1, qstr )

   LOCAL table := {}
   LOCAL currow := nil
   LOCAL tablearr := {}
   LOCAL rowarr := {}
   LOCAL typesarr := {}
   LOCAL cDate
   LOCAL current := ""
   LOCAL i
   LOCAL j
   LOCAL type1 := ""
   LOCAL stmt := nil

   IF empty(dbo1)
      msgstop("Database Connection Error!")

      RETURN tablearr
   ENDIF
   table := sqlite3_get_table(dbo1,qstr)
   IF sqlite3_errcode(dbo1) > 0 // error
      msgstop(sqlite3_errmsg(dbo1)+" Query is : "+qstr)

      RETURN NIL
   ENDIF
   stmt := sqlite3_prepare(dbo1,qstr)
   IF ! Empty( stmt )
      FOR i := 1 to sqlite3_column_count( stmt )
         type1 := upper(alltrim(sqlite3_column_decltype( stmt,i)))
         DO CASE
         CASE type1 == "INTEGER" .or. type1 == "REAL" .or. type1 == "FLOAT" .or. type1 == "DOUBLE"
            aadd(typesarr,"N")
         CASE type1 == "DATE" .or. type1 == "DATETIME"
            aadd(typesarr,"D")
         CASE type1 == "BOOL"
            aadd(typesarr,"L")
         OTHERWISE
            aadd(typesarr,"C")
         ENDCASE
      NEXT i
   ENDIF
   SQLITE3_FINALIZE( stmt )
   stmt := nil
   IF len(table) > 1
      asize(tablearr,0)
      FOR i := 2 to len(table)
         rowarr := table[i]
         FOR j := 1 to len(rowarr)
            DO CASE
            CASE typesarr[j] == "D"
               cDate := substr(rowarr[j],1,4)+substr(rowarr[j],6,2)+substr(rowarr[j],9,2)
               rowarr[j] := stod(cDate)
            CASE typesarr[j] == "N"
               rowarr[j] := val(rowarr[j])
            CASE typesarr[j] == "L"
               IF val(rowarr[j]) == 1
                  rowarr[j] := .t.
               ELSE
                  rowarr[j] := .f.
               ENDIF
            ENDCASE
         NEXT j
         aadd(tablearr,aclone(rowarr))
      NEXT i
   ENDIF

   RETURN tablearr

STATIC FUNCTION _HMG_CSG_MiscSQL( dbo1, qstr )

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

STATIC FUNCTION _HMG_CSG_C2SQL( Value )

   LOCAL cValue := ""
   LOCAL cdate := ""

   IF ( valtype(value) == "C" .or. valtype( value ) == "M" ) .and. len(alltrim(value)) > 0
      VALUE := strtran(value, "'", "''" )
   ENDIF
   DO CASE
   CASE Valtype(Value) == "N"
      cValue := AllTrim(Str(Value))
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
