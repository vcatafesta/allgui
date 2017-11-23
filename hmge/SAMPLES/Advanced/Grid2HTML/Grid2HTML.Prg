#include <hmg.ch>

FUNCTION _grid2html( cGrid, cWindow, cHTMLFile, aHeaders )

   LOCAL i, j
   LOCAL nDecimals := Set( _SET_DECIMALS )
   LOCAL aec := ""
   LOCAL aItems := {}
   LOCAL printdata := {}
   LOCAL nTotalColumns := 0
   LOCAL nRows := 0
   LOCAL cFontName := 'Arial'
   LOCAL nFontSize := 12
   LOCAL aData := {}
   LOCAL aPrintData := {}
   LOCAL aColumnJustify := {}
   LOCAL aColumnWidths := {}
   LOCAL aColumnHeaders := {}
   LOCAL aColumnControls := {}
   LOCAL nTopMargin := 20.0
   LOCAL nBottomMargin := 20.0
   LOCAL nLeftMargin := 20.0
   LOCAL nRightMargin := 20.0
   LOCAL aEditcontrols := {}
   LOCAL xRes := {}
   LOCAL aJustify := {}
   LOCAL nWidth := 0
   LOCAL cPrintData := ''
   LOCAL aLineData
   LOCAL cType
   LOCAL fHandle := 0
   LOCAL cHTML := ''
   LOCAL cHeader1 := ''
   LOCAL cHeader2 := ''
   LOCAL cHeader3 := ''
   LOCAL aFinalData := {}
   LOCAL cTimeString
   LOCAL nColumnCount

   DEFAULT aHeaders := { '', '', '' }
   DEFAULT cWindow := ""
   DEFAULT cGrid := ""
   DEFAULT cHTMLFile := ''

   DO CASE
   CASE len( aHeaders ) == 3
      cHeader1 := aHeaders[ 1 ]
      cHeader2 := aHeaders[ 2 ]
      cHeader3 := aHeaders[ 3 ]
   CASE len( aHeaders ) == 2
      cHeader1 := aHeaders[ 1 ]
      cHeader2 := aHeaders[ 2 ]
   CASE len( aHeaders ) == 1
      cHeader1 := aHeaders[ 1 ]
   ENDCASE

   IF len( alltrim( cHTMLFile ) ) == 0
      cTimeString := time()
      cTimeString := hb_usubstr( cTimeString, 1, 2 ) + hb_usubstr( cTimeString, 4, 2 ) + hb_usubstr( cTimeString, 7, 2 )
      cHTMLFile   := iif( len( alltrim( cHTMLFile ) ) == 0, 'Report_' + dtos( date() ) + '_' + cTimeString  + '.html', cHTMLFile )
   ENDIF

   nRows      := getproperty( cWindow, cGrid, "ITEMCOUNT" )
   IF nRows == 0

      RETURN NIL
   ENDIF

   cFontName  := iif( getproperty( cWindow, cGrid, 'FONTNAME' ) <> nil, getproperty( cWindow, cGrid, 'FONTNAME' ), cFontName )
   nFontSize  := iif( getproperty( cWindow, cGrid, 'FONTSIZE' ) <> nil, getproperty( cWindow, cGrid, 'FONTSIZE' ), nFontSize )
   nColumnCount := _GetColumnCount( cGrid, cWindow )
   FOR i := 1 to nColumnCount
      aadd( aColumnWidths,  getproperty( cWindow, cGrid, 'COLUMNWIDTH', i ) )
      aadd( aColumnJustify, _HTMLAlign( _GetColumnJustify( cGrid, cWindow, i ) ) )
      aadd( aColumnHeaders, _GetColumnHeader( cGrid, cWindow, i ) )
      aadd( aColumnControls, _GetColumnControl( cGrid, cWindow, i ) )
      nTotalColumns += aColumnWidths[ i ]
   NEXT i
   nWidth := nTotalColumns
   FOR i := 1 TO nRows
      cPrintData := ''
      aLineData := getproperty( cWindow, cGrid, 'ITEM', i )
      asize( aPrintData, 0 )
      cType := ''
      FOR j := 1 TO nColumnCount
         cType := ValType( aLineData[ j ] )
         DO CASE
         CASE cType == "N"
            IF valtype( aColumnControls[ j ] ) == 'A'
               IF upper( aColumnControls[ j, 1 ] ) == 'COMBOBOX'
                  aItems := aColumnControls[ j, 2 ]
                  cPrintdata := aItems[ aLineData[ j ] ]
               ELSE
                  cPrintdata := LTrim( Str( aLineData[ j ] ) )
               ENDIF
            ELSE
               cPrintdata := LTrim( Str( aLineData[ j ] ) )
            ENDIF
         CASE cType == "D"
            cPrintdata := dtoc( aLineData[ j ] )
         CASE cType == "L"
            IF valtype( aColumnControls[ j ] ) == 'A'
               IF upper( aColumnControls[ j, 1 ] ) == 'CHECKBOX'
                  cPrintdata := if( aLineData[ j ], aColumnControls[ j, 2 ], aColumnControls[ j, 3 ] )
               ELSE
                  cPrintdata := if( aLineData[ j ], "T", "F" )
               ENDIF
            ELSE
               cPrintdata := if( aLineData[ j ], "T", "F" )
            ENDIF
         OTHERWISE
            cPrintdata := aLineData[ j ]
         ENDCASE
         aadd( aPrintData, cPrintData )
      NEXT j
      aadd( aFinalData, aclone( aPrintData ) )
   NEXT i

   IF file( cHTMLFile )
      IF .not. msgyesno( "File Exists! Are you sure to overwrite?", 'Report Writer' )

         RETURN NIL
      ENDIF
   ENDIF

   fHandle := fcreate( cHTMLFile )

   IF fHandle < 0
      msgstop( "File "+ cHTMLFile + " could not be created!" )

      RETURN NIL
   ENDIF

   cHTML := '<HTML>' + CRLF
   IF len( cHeader1 ) > 0
      cHTML := cHTML + '<HEAD><TITLE>' + cHeader1 + '</TITLE></HEAD>' + CRLF
   ENDIF
   cHTML := cHTML + '<STYLE>' + CRLF
   cHTML := cHTML + '.td1 { font-family:"' + cFontName + '", "Arial"; font-size:' + alltrim( str( nFontSize ) ) + 'pt; border-style:outset; border-width:0 }' + CRLF
   cHTML := cHTML + 'table { border-collapse: collapse }' + CRLF
   cHTML := cHTML + 'td, th { font-family:"' + cFontName + '", "Arial"; font-size:' + alltrim( str( nFontSize ) ) + 'pt; border-style:outset; border-width:1; padding: 2px }' + CRLF
   cHTML := cHTML + 'tr:hover {background-color: #f5f5f5}' + CRLF
   cHTML := cHTML + 'table-layout: fixed' + CRLF
   cHTML := cHTML + '</STYLE>'
   cHTML := cHTML + '<BODY TOPMARGIN=' + alltrim( str( nTopMargin ) ) + ' LEFTMARGIN=' + alltrim( str( nLeftMargin ) ) + ' RIGHTMARGIN=' + alltrim( str( nRightMargin ) ) + ' BOTTOMMARGIN=' + alltrim( str( nBottomMargin ) ) + '>' + CRLF

   // report headers table
   cHTML := cHTML + '<TABLE Width="' + alltrim( str( nWidth ) ) + '">' + CRLF
   IF len( cHeader1 ) > 0
      cHTML := cHTML + '<TR><TD align="CENTER" class="TD1"><font size=5><u>' + cHeader1 + '</u></font></TD></TR>' + CRLF
   ENDIF
   IF len( cHeader2 ) > 0
      cHTML := cHTML + '<TR><TD align="CENTER" class="TD1"><font size=4>' + cHeader2 + '</font></TD></TR>' + CRLF
   ENDIF
   IF len( cHeader3 ) > 0
      cHTML := cHTML + '<TR><TD align="CENTER" class="TD1"><font size=4>' + cHeader3 + '</font></TD></TR>' + CRLF
   ENDIF
   cHTML := cHTML + '</TABLE>' + CRLF

   // Main Table

   cHTML := cHTML + '<TABLE Width="' + alltrim( str( nWidth ) ) + '">' + CRLF
   // Column Headers
   cHTML := cHTML + '<TR>' + CRLF
   FOR i := 1 to nColumnCount
      IF aColumnWidths[ i ] > 0
         cHTML := cHTML + '<TD WIDTH=' + alltrim( str( aColumnWidths[ i ] ) ) + ' ALIGN="' + aColumnJustify[ i ] + '" border-width=0><B>' + aColumnHeaders[ i ] + '</B></TD>' + CRLF
      ENDIF
   NEXT i
   cHTML := cHTML + '</TR>' + CRLF

   // Now it is time for data

   FOR i := 1 to nRows
      aLineData := aFinalData[ i ]
      cHTML := cHTML + '<TR>' + CRLF
      FOR j := 1 to nColumnCount
         IF aColumnWidths[ j ] > 0
            cHTML := cHTML + '<TD WIDTH=' + alltrim( str( aColumnWidths[ j ] ) ) + ' ALIGN="' + aColumnJustify[ j ] + '">' + aLineData[ j ] + '</TD>' + CRLF
         ENDIF
      NEXT i
      cHTML := cHTML + '</TR>' + CRLF
   NEXT i
   cHTML := cHTML + '</TABLE>' + CRLF
   cHTML := cHTML + '</HTML>' + CRLF
   fWrite( fHandle, cHTML )
   IF .not. fclose( fhandle )
      msgstop( 'Error in Saving the Report!', 'Report Writer' )
   ENDIF

   RETURN cHTMLFile

FUNCTION _HTMLAlign( nAlign )

   DEFAULT nAlign := 0
   DO CASE
   CASE nAlign == 1 // right

      RETURN 'RIGHT'
   CASE nAlign == 2 // Center

      RETURN 'CENTER'
   ENDCASE

   RETURN 'LEFT'

FUNCTION _GetColumnCount( ControlName , ParentForm )

   LOCAL i, ColumnCount

   i := GetControlIndex( ControlName , ParentForm )
   ColumnCount := Len( _HMG_aControlCaption [i] )

   RETURN ColumnCount

FUNCTION _GetColumnHeader( ControlName , ParentForm , i )

   LOCAL idx

   idx := GetControlIndex( ControlName , ParentForm )

   RETURN _HMG_aControlCaption [idx][i]

FUNCTION _GetColumnJustify( ControlName , ParentForm , i )

   LOCAL idx

   idx := GetControlIndex( ControlName , ParentForm )

   RETURN _HMG_aControlMiscData1 [idx] [3] [i]

FUNCTION _GetColumnControl( ControlName , ParentForm , i )

   LOCAL idx

   idx := GetControlIndex( ControlName , ParentForm )

   IF valtype(_HMG_aControlMiscData1 [idx] [13]) == 'A'

      RETURN _HMG_aControlMiscData1 [idx] [13] [i]
   ENDIF

   RETURN ''
