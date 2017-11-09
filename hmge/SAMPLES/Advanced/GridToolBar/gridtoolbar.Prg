#include <hmg.ch>

FUNCTION  _addGridToolBar( cGrid, cWindow )

   LOCAL nRow := getproperty( cWindow, cGrid, 'ROW' )
   LOCAL nCol := getproperty( cWindow, cGrid, 'COL' )
   LOCAL nWidth := getproperty( cWindow, cGrid, 'WIDTH' )
   LOCAL nHeight := getproperty( cWindow, cGrid, 'HEIGHT' )
   LOCAL nButtonSize := 36
   LOCAL nInterval := 8
   LOCAL nToolBarRow := nRow + nHeight + nInterval
   LOCAL nToolBarCol := nCol + nWidth - ( ( 3 * nButtonSize ) + ( nInterval * 2 ) )
   LOCAL cSuffix := alltrim( str( random() ) )
   LOCAL cPdf := 'pdf' + cSuffix
   LOCAL cCsv := 'csv' + cSuffix
   LOCAL cPrint := 'print' + cSuffix
   LOCAL cName := cWindow

   DEFINE BUTTON &cpdf
      parent &cWindow
      row nToolBarRow
      col nToolBarCol
      width nButtonSize
      height nButtonSize
      picture 'pdf'
      tooltip 'Export to PDF file'
      action _grid2pdf( cGrid, cWindow )
   END BUTTON
   DEFINE BUTTON &cCsv
      parent &cWindow
      row nToolBarRow
      col nToolBarCol + nButtonSize + nInterval
      width nButtonSize
      height nButtonSize
      picture 'csv'
      tooltip 'Export to CSV file'
      action _grid2csv( cGrid, cWindow )
   END BUTTON
   DEFINE BUTTON &cPrint
      parent &cWindow
      row nToolBarRow
      col nToolBarCol + nButtonSize + nInterval + nButtonSize + nInterval
      width nButtonSize
      height nButtonSize
      picture 'print'
      tooltip 'Print this table'
      action _gridprint( cGrid, cWindow )
   END BUTTON

   RETURN NIL

FUNCTION _grid2pdf( cGrid, cWindow )

   LOCAL cFileName := ''

   cFileName :=  PutFile ( { {"Portable Document Format (*.pdf)", "*.pdf" } } , "Export to PDF file" ,  , .f. )
   IF len(alltrim(cFileName)) == 0

      RETURN NIL
   ENDIF

   IF at( ".pdf", lower( cFileName ) ) > 0
      IF .not. right( lower( cFileName ), 4 ) == ".pdf"
         cFileName := cFileName + ".pdf"
      ENDIF
   ELSE
      cFileName := cFileName + ".pdf"
   ENDIF

   IF file( cFileName )
      IF .not. msgyesno("Are you sure to overwrite?","Export to PDF file")

         RETURN NIL
      ENDIF
   ENDIF
   _gridpdf( cGrid, cWindow, cFileName, , , , , .f. )

   RETURN NIL
