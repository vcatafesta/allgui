/*
- by S. Rathinagiri on October 22nd, 2012

- The adaptation of the source code of this file to support UNICODE character set and WIN64 architecture was made
by Dr. Claudio Soto, November 2012 and June 2014 respectively.

- Revised by Pablo César Arrascaeta on April 12th, 2014
Implement of _HMG_HPDF_SetFont() with improvements extra functions

*/
MEMVAR _HMG_SYSDATA, nFhandle, lDoLog

#include <hmg.ch>
#include "harupdf.ch"

FUNCTION _HMG_HPDF_INIT ( cPDFFile, nOrientation, nPaperSize, nPaperLength, nPaperWidth, lLog )

   LOCAL lReturn := .f.

   DEFAULT nOrientation := 1
   DEFAULT nPaperSize   := 1
   DEFAULT lLog         := .f.

   PUBLIC nFhandle := 0, lDoLog := lLog

   IF valtype( _HMG_SYSDATA[ 150 ] ) == 'U'
      _HMG_SYSDATA[ 150 ] := { ;
         Nil, ;                  //  1.PDF Object
      cPDFFile,;              //  2.PDF File to Save
      0,;                     //  3.PDF PaperSize
      0,;                     //  4.PDF PaperWidth
      0,;                     //  5.PDF PaperHeight
      nOrientation,;          //  6.PDF Orientation
      Nil, ;                  //  7.PDF Current Page
      'Helvetica',;           //  8.PDF default font
      12,;                    //  9.PDF default fontsize
      "StandardEncoding",;    // 10.PDF default encoding
      {},;                    // 11.PDF Outlines Array
      {},;                    // 12.PDF Pages Array
      0;                      // 13.PDF Current Page Number
      }
      _HMG_SYSDATA[ 150 ][ 1 ] := HPDF_New()
      IF _HMG_SYSDATA[ 150 ][ 1 ] == Nil
         _HMG_HPDF_Error( 2 )

         RETURN lReturn
      ENDIF

      IF lLog
         nFhandle := FCreate( 'UsedFonts.htm', 0 )
         Html_Table_Ini(nFHandle,"TruType Fonts used",1024,3)
         HTML_TABLE_LINE( nFHandle,{{HTML_BOLD(nFHandle,"Line (pixels)"),"#ABABAB",.t.},;
            {HTML_BOLD(nFHandle,"Column (pixels)"),"#ABABAB",.t.},;
            {HTML_BOLD(nFHandle,"Page"),"#ABABAB",.t.},;
            {HTML_BOLD(nFHandle,"Given Font Name"),"#ABABAB",.f.},;
            {HTML_BOLD(nFHandle,"Size"),"#ABABAB",.t.},;
            {HTML_BOLD(nFHandle,"Properties"),"#ABABAB",.f.},;
            {HTML_BOLD(nFHandle,"Reassigned Font Name"),"#ABABAB",.f.}} )
      ENDIF

      _HMG_SYSDATA[ 150 ][ 3 ] := nPaperSize
      IF nPaperSize == 256 // user size
         IF _HMG_SYSDATA[ 150 ][ 6 ] == 1 // orientation portrait
            _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( nPaperWidth )
            _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( nPaperLength )
         ELSE // orientation landscape
            _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( nPaperLength )
            _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( nPaperWidth )
         ENDIF
      ELSE
         _HMG_HPDF_INIT_PAPERSIZE( nPaperSize )
      ENDIF
      lReturn := .t.
   ELSE
      _HMG_HPDF_Error( 1 )

      RETURN lReturn
   ENDIF

   RETURN lReturn

FUNCTION _hmg_hpdf_setencoding( cEncoding )

   IF _HMG_SYSDATA[ 150 ][ 1 ] == Nil // PDF object not found!
      _HMG_HPDF_Error( 3 )

      RETURN NIL
   ENDIF
   HPDF_SetCurrentEncoder( _HMG_SYSDATA[ 150 ][ 1 ], cEncoding )
   _HMG_SYSDATA[ 150 ] [ 10 ] := cEncoding

   RETURN NIL

FUNCTION _hmg_hpdf_startdoc() // START HPDFDOC

   RETURN NIL

FUNCTION _hmg_hpdf_startpage()

   IF _HMG_SYSDATA[ 150 ][ 1 ] == Nil // PDF object not found!
      _HMG_HPDF_Error( 3 )

      RETURN NIL
   ENDIF
   IF _HMG_SYSDATA[ 150 ][ 7 ] == Nil // Page is free
      _HMG_SYSDATA[ 150 ][ 7 ] := HPDF_AddPage( _HMG_SYSDATA[ 150 ][ 1 ] )
      IF EMPTY( _HMG_SYSDATA[ 150, 7 ] )
         _HMG_HPDF_Error( 9 , hb_HPDF_GetErrorString( _HMG_SYSDATA[ 150 ][ 7 ] )+" | StartPage" )

         RETURN NIL
      ELSE
         // add current page to the pages array
         aadd( _HMG_SYSDATA[ 150 ][ 12 ], _HMG_SYSDATA[ 150 ][ 7 ] )
         _HMG_SYSDATA[ 150 ][ 13 ] := HMG_LEN( _HMG_SYSDATA[ 150 ][ 12 ] )
         // set page size
         HPDF_Page_SetWidth( _HMG_SYSDATA[ 150 ][ 7 ], _HMG_SYSDATA[ 150 ][ 4 ] )
         HPDF_Page_SetHeight( _HMG_SYSDATA[ 150 ][ 7 ], _HMG_SYSDATA[ 150 ][ 5 ] )
      ENDIF
   ELSE
      _HMG_HPDF_Error( 4 )
   ENDIF

   RETURN NIL

FUNCTION _HMG_HPDF_InsertPage( nPage )

   LOCAL oOldPage := Nil
   LOCAL aPages := aclone( _HMG_SYSDATA[ 150 ][ 12 ] )

   IF nPage > HMG_LEN( aPages ) .or. nPage < 1
      _HMG_HPDF_Error( 16 )

      RETURN NIL
   ENDIF
   oOldPage := aPages[ nPage ]
   IF empty( oOldPage )
      _HMG_HPDF_Error( 16 )

      RETURN NIL
   ENDIF
   IF _HMG_SYSDATA[ 150 ][ 1 ] == Nil // PDF object not found!
      _HMG_HPDF_Error( 3 )

      RETURN NIL
   ENDIF
   IF _HMG_SYSDATA[ 150 ][ 7 ] == Nil // Page is free
      _HMG_SYSDATA[ 150 ][ 7 ] := HPDF_InsertPage( _HMG_SYSDATA[ 150 ][ 1 ], oOldPage )
      IF EMPTY( _HMG_SYSDATA[ 150, 7 ] )
         _HMG_HPDF_Error( 9 , hb_HPDF_GetErrorString( _HMG_SYSDATA[ 150 ][ 7 ] )+" | InsertPage" )

         RETURN NIL
      ELSE
         // insert current page to the pages array
         asize( aPages, HMG_LEN( aPages ) + 1 )
         ains( aPages, nPage )
         aPages[ nPage ] := _HMG_SYSDATA[ 150, 7 ]
         _HMG_SYSDATA[ 150 ][ 12 ] := aclone( aPages )
         _HMG_SYSDATA[ 150 ][ 13 ] := nPage
         HPDF_Page_SetWidth( _HMG_SYSDATA[ 150 ][ 7 ], _HMG_SYSDATA[ 150 ][ 4 ] )
         HPDF_Page_SetHeight( _HMG_SYSDATA[ 150 ][ 7 ], _HMG_SYSDATA[ 150 ][ 5 ] )
      ENDIF
   ELSE
      _HMG_HPDF_Error( 4 )
   ENDIF

   RETURN NIL

FUNCTION _HMG_HPDF_GoToPage( nPage )

   LOCAL oPage := Nil
   LOCAL aPages := aclone( _HMG_SYSDATA[ 150 ][ 12 ] )

   IF nPage > HMG_LEN( aPages ) .or. nPage < 1
      _HMG_HPDF_Error( 18 )

      RETURN NIL
   ENDIF
   oPage := aPages[ nPage ]
   IF empty( oPage )
      _HMG_HPDF_Error( 18 )

      RETURN NIL
   ENDIF
   IF _HMG_SYSDATA[ 150 ][ 1 ] == Nil // PDF object not found!
      _HMG_HPDF_Error( 3 )

      RETURN NIL
   ENDIF
   IF _HMG_SYSDATA[ 150 ][ 7 ] == Nil // Page is free
      _HMG_SYSDATA[ 150 ][ 7 ] := aPages[ nPage ]
      IF EMPTY( _HMG_SYSDATA[ 150, 7 ] )
         _HMG_HPDF_Error( 19 )

         RETURN NIL
      ENDIF
      _HMG_SYSDATA[ 150 ][ 13 ] := nPage
   ENDIF

   RETURN NIL

FUNCTION _hmg_hpdf_endpage()

   IF _HMG_SYSDATA[ 150 ][ 1 ] == Nil // PDF object not found!
      _HMG_HPDF_Error( 3 )

      RETURN NIL
   ENDIF
   IF _HMG_SYSDATA[ 150 ][ 7 ] == Nil // Page is free
      _HMG_HPDF_Error( 5 )

      RETURN NIL
   ELSE
      _HMG_SYSDATA[ 150 ][ 7 ] := Nil
   ENDIF

   RETURN NIL

FUNCTION HMG_HPDF_PageCount()

   IF _HMG_SYSDATA[ 150 ][ 1 ] == Nil // PDF object not found!
      _HMG_HPDF_Error( 3 )

      RETURN NIL
   ENDIF

   RETURN HMG_LEN( _HMG_SYSDATA[ 150 ][ 12 ] )

FUNCTION HMG_HPDF_PageNo()

   IF _HMG_SYSDATA[ 150 ][ 1 ] == Nil // PDF object not found!
      _HMG_HPDF_Error( 3 )

      RETURN NIL
   ENDIF
   IF _HMG_SYSDATA[ 150 ][ 7 ] == Nil // Page is free
      _HMG_HPDF_Error( 5 )

      RETURN NIL
   ENDIF

   RETURN _HMG_SYSDATA[ 150 ][ 13 ]

FUNCTION _hmg_hpdf_enddoc()

   IF _HMG_SYSDATA[ 150 ][ 1 ] == Nil // PDF object not found!
      _HMG_HPDF_Error( 3 )

      RETURN NIL
   ENDIF
   HPDF_SaveToFile( _HMG_SYSDATA[ 150 ][ 1 ], _HMG_SYSDATA[ 150 ][ 2 ] )
   HPDF_Free( _HMG_SYSDATA[ 150 ][ 1 ] )
   _HMG_SYSDATA[ 150 ] := Nil

   //HTML_END(nFHandle)
   //FClose( nFhandle )
   IF lDoLog
      FWrite( nFHandle, "</table></body></html>"+CRLF )
      FClose( nFHandle )
   ENDIF

   RELEASE nFhandle, lDoLog

   RETURN NIL

FUNCTION _hmg_hpdf_abortdoc()

   IF _HMG_SYSDATA[ 150 ][ 1 ] == Nil // PDF object not found!
      _HMG_HPDF_Error( 3 )

      RETURN NIL
   ENDIF
   HPDF_Free( _HMG_SYSDATA[ 150 ][ 1 ] )
   _HMG_SYSDATA[ 150 ][ 1 ] := Nil

   RETURN NIL

FUNCTION _HMG_HPDF_PRINT ( nRow, nCol, cFontName, nFontSize, nRColor, nGColor, nBColor, cText, lBold, lItalic, lUnderline, lStrikeout, lColor, lFont, lSize, cAlign )

   LOCAL nWidth := _HMG_SYSDATA[ 150 ][ 4 ]
   LOCAL nHeight := _HMG_SYSDATA[ 150 ][ 5 ]
   LOCAL nTextWidth := 0
   LOCAL nxPos := _HMG_HPDF_MM2Pixel( nCol )
   LOCAL nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )
   LOCAL oFont := Nil
   LOCAL cFont := ''
   LOCAL cTtfFnt

   DEFAULT cFontName := ''
   DEFAULT nFontSize := 12
   DEFAULT nRColor := 0
   DEFAULT nGColor := 0
   DEFAULT nBColor := 0
   DEFAULT lBold := .f.
   DEFAULT lItalic := .f.
   DEFAULT lUnderline := .f.
   DEFAULT lStrikeout := .f.
   DEFAULT lColor := .f.
   DEFAULT lFont := .f.
   DEFAULT lSize := .f.
   DEFAULT cAlign := ''

   cTtfFnt := cFontName

   IF _HMG_SYSDATA[ 150 ][ 1 ] == Nil // PDF object not found!
      _HMG_HPDF_Error( 3 )

      RETURN NIL
   ENDIF
   IF _HMG_SYSDATA[ 150 ][ 7 ] == Nil // PDF Page object not found!
      _HMG_HPDF_Error( 5 )

      RETURN NIL
   ENDIF

   // set color
   IF lColor
      HPDF_Page_SetRGBFill( _HMG_SYSDATA[ 150 ][ 7 ], nRColor/255, nGColor/255, nBColor/255 )
   ELSE
      HPDF_Page_SetRGBFill( _HMG_SYSDATA[ 150 ][ 7 ], 0.0, 0.0, 0.0 )
   ENDIF

   // set font
   IF HMG_LEN( AllTrim( cFontName ) ) == 0
      cFontName := _HMG_HPDF_SetFont( cFontName, lBold, lItalic )
      oFont := HPDF_GetFont( _HMG_SYSDATA[ 150 ][ 1 ], cFontName, _HMG_SYSDATA[ 150 ][ 10 ] )
   ELSE
      cFontName := AllTrim(_HMG_HPDF_SetFont( cFontName, lBold, lItalic ))

      IF HMG_UPPER (cFileExt (cFontName)) == '.TTF' // load ttf font

         cFont := HPDF_LOADTTFONTFROMFILE( _HMG_SYSDATA[ 150 ][ 1 ], cFontName, .t. )
         IF HMG_LEN( alltrim( cFont ) ) == 0
            _HMG_HPDF_Error( 6 , cFontName )

            RETURN NIL
         ENDIF
         oFont := HPDF_GetFont( _HMG_SYSDATA[ 150 ][ 1 ], cFont, _HMG_SYSDATA[ 150 ][ 10 ] )
      ELSE
         IF HMG_UPPER( alltrim( cFontName ) ) == "SYMBOL" .or. HMG_UPPER( alltrim( cFontName ) ) == "ZAPFDINGBATS"
            oFont := HPDF_GetFont( _HMG_SYSDATA[ 150 ][ 1 ], cFontName, Nil )
         ELSE
            oFont := HPDF_GetFont( _HMG_SYSDATA[ 150 ][ 1 ], cFontName, _HMG_SYSDATA[ 150 ][ 10 ] )
         ENDIF
      ENDIF
   ENDIF
   IF oFont == Nil
      _HMG_HPDF_Error( 6 , cFontName )

      RETURN NIL
   ELSE
      HPDF_Page_SetFontAndSize( _HMG_SYSDATA[ 150 ][ 7 ], oFont, nFontSize )
      nTextWidth := HPDF_Page_TextWidth( _HMG_SYSDATA[ 150 ][ 7 ], cText )
      DO CASE
      CASE HMG_UPPER( alltrim( cAlign ) ) == 'CENTER'
         nxPos := nxPos - ( nTextWidth / 2 )
      CASE HMG_UPPER( alltrim( cAlign ) ) == 'RIGHT'
         nxPos := nxPos - ( nTextWidth )
      ENDCASE
      nyPos -= nFontSize
      HPDF_Page_BeginText( _HMG_SYSDATA[ 150 ][ 7 ] )
      HPDF_PAGE_TEXTOUT( _HMG_SYSDATA[ 150 ][ 7 ], nxPos, nyPos, cText )
      HPDF_Page_EndText( _HMG_SYSDATA[ 150 ][ 7 ] )

      IF lDoLog
         HTML_TABLE_LINE(nFHandle,{{StrZero(nRow,4,0)+" ("+StrZero(nyPos,7,2)+")","#FFFFFF",.t.},;
            {StrZero(nCol,4,0)+" ("+StrZero(nxPos,7,2)+")","#FFFFFF",.t.},;
            {StrZero(_HMG_SYSDATA[ 150 ][ 13 ],3,0),"#FFFFFF",.t.},;
            {PadR(If(Empty(cTtfFnt),"<Default>",cTtfFnt),If(HMG_Len(cTtfFnt)>30,HMG_Len(cTtfFnt),30)),"#FFFFFF",.f.},;
            {StrZero(nFontSize,2,0),"#FFFFFF",.t.},;
            {If(lBold,"BOLD" ,Space(4))+If(lItalic," ITALIC",Space(7)),"#FFFFFF",.f.},;
            {cFontName,If(If(Empty(cTtfFnt),HMG_Len(cFontName),HMG_Len(cTtfFnt))==HMG_Len(cFontName),"#FFFFFF","#FFFF66"),.f.}})
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION _HMG_HPDF_MULTILINE_PRINT ( nRow, nCol, nToRow, nToCol, cFontName, nFontSize, nRColor, nGColor, nBColor, cText, lBold, lItalic, lUnderline, lStrikeout, lColor, lFont, lSize, cAlign )

   LOCAL nWidth := _HMG_SYSDATA[ 150 ][ 4 ]
   LOCAL nHeight := _HMG_SYSDATA[ 150 ][ 5 ]
   LOCAL nTextWidth := 0
   LOCAL nxPos := _HMG_HPDF_MM2Pixel( nCol )
   LOCAL nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )
   LOCAL nToxPos := nxPos + _HMG_HPDF_MM2Pixel( nToCol - nCol )
   LOCAL nToyPos := nyPos - _HMG_HPDF_MM2Pixel( nToRow - nRow )
   LOCAL oFont := Nil
   LOCAL cFont := ''
   LOCAL cTtfFnt // Pablo June, 2014

   DEFAULT cFontName := ''
   DEFAULT nFontSize := 12
   DEFAULT nRColor := 0
   DEFAULT nGColor := 0
   DEFAULT nBColor := 0
   DEFAULT lBold := .f.
   DEFAULT lItalic := .f.
   DEFAULT lUnderline := .f.
   DEFAULT lStrikeout := .f.
   DEFAULT lColor := .f.
   DEFAULT lFont := .f.
   DEFAULT lSize := .f.
   DEFAULT cAlign := ''

   cTtfFnt := cFontName // Pablo June, 2014

   IF _HMG_SYSDATA[ 150 ][ 1 ] == Nil // PDF object not found!
      _HMG_HPDF_Error( 3 )

      RETURN NIL
   ENDIF
   IF _HMG_SYSDATA[ 150 ][ 7 ] == Nil // PDF Page object not found!
      _HMG_HPDF_Error( 5 )

      RETURN NIL
   ENDIF

   // set color
   IF lColor
      HPDF_Page_SetRGBFill( _HMG_SYSDATA[ 150 ][ 7 ], nRColor/255, nGColor/255, nBColor/255 )
   ELSE
      HPDF_Page_SetRGBFill( _HMG_SYSDATA[ 150 ][ 7 ], 0.0, 0.0, 0.0 )
   ENDIF

   // set font
   IF HMG_LEN( alltrim( cFontName ) ) == 0
      cFontName := _HMG_HPDF_SetFont( cFontName, lBold, lItalic )
      oFont := HPDF_GetFont( _HMG_SYSDATA[ 150 ][ 1 ], cFontName, _HMG_SYSDATA[ 150 ][ 10 ] )
   ELSE
      // cFontName := alltrim( cFontName )
      cFontName := AllTrim(_HMG_HPDF_SetFont( cFontName, lBold, lItalic ))

      IF HMG_UPPER (cFileExt (cFontName)) == '.TTF' // load ttf font

         cFont := HPDF_LOADTTFONTFROMFILE( _HMG_SYSDATA[ 150 ][ 1 ], cFontName, .t. )
         IF HMG_LEN( alltrim( cFont ) ) == 0
            _HMG_HPDF_Error( 6 , cFontName )

            RETURN NIL
         ENDIF
         oFont := HPDF_GetFont( _HMG_SYSDATA[ 150 ][ 1 ], cFont, _HMG_SYSDATA[ 150 ][ 10 ] )
      ELSE
         IF HMG_UPPER( alltrim( cFontName ) ) == "SYMBOL" .or. HMG_UPPER( alltrim( cFontName ) ) == "ZAPFDINGBATS"
            oFont := HPDF_GetFont( _HMG_SYSDATA[ 150 ][ 1 ], cFontName, Nil )
         ELSE
            oFont := HPDF_GetFont( _HMG_SYSDATA[ 150 ][ 1 ], cFontName, _HMG_SYSDATA[ 150 ][ 10 ] )
         ENDIF
      ENDIF
   ENDIF
   IF oFont == Nil
      _HMG_HPDF_Error( 6 , cFontName )

      RETURN NIL
   ELSE
      HPDF_Page_SetFontAndSize( _HMG_SYSDATA[ 150 ][ 7 ], oFont, nFontSize )
      HPDF_Page_BeginText( _HMG_SYSDATA[ 150 ][ 7 ] )
      DO CASE
      CASE HMG_UPPER( cAlign ) == 'CENTER'
         HPDF_Page_TextRect( _HMG_SYSDATA[ 150 ][ 7 ], nxPos, nyPos, nToxPos, nToyPos, cText, HPDF_TALIGN_CENTER, Nil )
      CASE HMG_UPPER( cAlign ) == 'RIGHT'
         HPDF_Page_TextRect( _HMG_SYSDATA[ 150 ][ 7 ], nxPos, nyPos, nToxPos, nToyPos, cText, HPDF_TALIGN_RIGHT, Nil )
      CASE HMG_UPPER( cAlign ) == 'JUSTIFY'
         HPDF_Page_TextRect( _HMG_SYSDATA[ 150 ][ 7 ], nxPos, nyPos, nToxPos, nToyPos, cText, HPDF_TALIGN_JUSTIFY, Nil )
      OTHERWISE
         HPDF_Page_TextRect( _HMG_SYSDATA[ 150 ][ 7 ], nxPos, nyPos, nToxPos, nToyPos, cText, HPDF_TALIGN_LEFT, Nil )
      ENDCASE
      HPDF_Page_EndText( _HMG_SYSDATA[ 150 ][ 7 ] )

      IF lDoLog // Pablo June, 2014
         HTML_TABLE_LINE(nFHandle,{{StrZero(nRow,4,0)+" ("+StrZero(nyPos,7,2)+")","#FFFFFF",.t.},;
            {StrZero(nCol,4,0)+" ("+StrZero(nxPos,7,2)+")","#FFFFFF",.t.},;
            {StrZero(_HMG_SYSDATA[ 150 ][ 13 ],3,0),"#FFFFFF",.t.},;
            {PadR(If(Empty(cTtfFnt),"<Default>",cTtfFnt),If(HMG_Len(cTtfFnt)>30,HMG_Len(cTtfFnt),30)),"#FFFFFF",.f.},;
            {StrZero(nFontSize,2,0),"#FFFFFF",.t.},;
            {If(lBold,"BOLD" ,Space(4))+If(lItalic," ITALIC",Space(7)),"#FFFFFF",.f.},;
            {cFontName,If(If(Empty(cTtfFnt),HMG_Len(cFontName),HMG_Len(cTtfFnt))==HMG_Len(cFontName),"#FFFFFF","#FFFF66"),.f.}})
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION _HMG_HPDF_LINE ( nRow , nCol , nToRow, nToCol, nLineWidth, nRColor, nGColor, nBColor, lWidth, lColor )

   LOCAL nWidth := _HMG_SYSDATA[ 150 ][ 4 ]
   LOCAL nHeight := _HMG_SYSDATA[ 150 ][ 5 ]
   LOCAL nTextWidth := 0
   LOCAL nxPos := _HMG_HPDF_MM2Pixel( nCol )
   LOCAL nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )
   LOCAL nToxPos := nxPos + _HMG_HPDF_MM2Pixel( nToCol - nCol )
   LOCAL nToyPos := nyPos - _HMG_HPDF_MM2Pixel( nToRow - nRow )

   DEFAULT nRColor := 0
   DEFAULT nGColor := 0
   DEFAULT nBColor := 0
   DEFAULT nWidth := 1
   DEFAULT lWidth := .f.
   DEFAULT lColor := .f.

   IF _HMG_SYSDATA[ 150 ][ 1 ] == Nil // PDF object not found!
      _HMG_HPDF_Error( 3 )

      RETURN NIL
   ENDIF
   IF _HMG_SYSDATA[ 150 ][ 7 ] == Nil // PDF Page object not found!
      _HMG_HPDF_Error( 5 )

      RETURN NIL
   ENDIF

   // set color
   IF lColor
      HPDF_Page_SetRGBSTROKE( _HMG_SYSDATA[ 150 ][ 7 ], nRColor/255, nGColor/255, nBColor/255 )
   ELSE
      HPDF_Page_SetRGBSTROKE( _HMG_SYSDATA[ 150 ][ 7 ], 0.0, 0.0, 0.0 )
   ENDIF

   IF lWidth
      HPDF_Page_SetLineWidth( _HMG_SYSDATA[ 150 ][ 7 ], _HMG_HPDF_MM2Pixel( nlineWidth ) )
   ELSE
      HPDF_Page_SetLineWidth( _HMG_SYSDATA[ 150 ][ 7 ], 1 )
   ENDIF
   HPDF_Page_MoveTo( _HMG_SYSDATA[ 150 ][ 7 ], nxPos, nyPos )
   HPDF_Page_LineTo( _HMG_SYSDATA[ 150 ][ 7 ], nToxPos, nToyPos )
   HPDF_Page_Stroke( _HMG_SYSDATA[ 150 ][ 7 ] )

   RETURN NIL

FUNCTION _HMG_HPDF_RECTANGLE ( nRow, nCol, nToRow, nToCol, nLineWidth, nRColor, nGColor, nBColor, lWidth, lColor, lFilled )

   LOCAL nWidth := _HMG_SYSDATA[ 150 ][ 4 ]
   LOCAL nHeight := _HMG_SYSDATA[ 150 ][ 5 ]
   LOCAL nTextWidth := 0
   LOCAL nxPos := _HMG_HPDF_MM2Pixel( nCol )
   LOCAL nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )
   LOCAL nToxPos := nxPos + _HMG_HPDF_MM2Pixel( nToCol - nCol )
   LOCAL nToyPos := nyPos - _HMG_HPDF_MM2Pixel( nToRow - nRow )

   DEFAULT nRColor := 0
   DEFAULT nGColor := 0
   DEFAULT nBColor := 0
   DEFAULT nWidth := 1
   DEFAULT lWidth := .f.
   DEFAULT lColor := .f.
   DEFAULT lFilled := .f.

   IF _HMG_SYSDATA[ 150 ][ 1 ] == Nil // PDF object not found!
      _HMG_HPDF_Error( 3 )

      RETURN NIL
   ENDIF
   IF _HMG_SYSDATA[ 150 ][ 7 ] == Nil // PDF Page object not found!
      _HMG_HPDF_Error( 5 )

      RETURN NIL
   ENDIF

   // set color
   IF lColor
      HPDF_Page_SetRGBSTROKE( _HMG_SYSDATA[ 150 ][ 7 ], nRColor/255, nGColor/255, nBColor/255 )
      IF lFilled
         HPDF_Page_SetRGBFill( _HMG_SYSDATA[ 150 ][ 7 ], nRColor/255, nGColor/255, nBColor/255 )
      ENDIF
   ELSE
      HPDF_Page_SetRGBSTROKE( _HMG_SYSDATA[ 150 ][ 7 ], 0.0, 0.0, 0.0 )
   ENDIF

   IF lWidth
      HPDF_Page_SetLineWidth( _HMG_SYSDATA[ 150 ][ 7 ], _HMG_HPDF_MM2Pixel( nlineWidth ) )
   ELSE
      HPDF_Page_SetLineWidth( _HMG_SYSDATA[ 150 ][ 7 ], 1 )
   ENDIF
   HPDF_Page_Rectangle( _HMG_SYSDATA[ 150 ][ 7 ], nxPos , nyPos - _HMG_HPDF_MM2Pixel( nToRow - nRow ), _HMG_HPDF_MM2Pixel( nToCol - nCol ), _HMG_HPDF_MM2Pixel( nToRow - nRow ) )
   IF lFilled
      HPDF_Page_FillStroke( _HMG_SYSDATA[ 150 ][ 7 ] )
   ELSE
      HPDF_Page_Stroke( _HMG_SYSDATA[ 150 ][ 7 ] )
   ENDIF

   RETURN NIL

FUNCTION _HMG_HPDF_ROUNDRECTANGLE ( nRow , nCol , nToRow , nToCol , nLineWidth, nRColor , nGColor , nBColor , lWidth , lColor, lFilled, nRoundness )

   LOCAL nWidth := _HMG_SYSDATA[ 150 ][ 4 ]
   LOCAL nHeight := _HMG_SYSDATA[ 150 ][ 5 ]
   LOCAL nTextWidth := 0
   LOCAL nxPos := _HMG_HPDF_MM2Pixel( nCol )
   LOCAL nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )
   LOCAL nToxPos := nxPos + _HMG_HPDF_MM2Pixel( nToCol - nCol )
   LOCAL nToyPos := nyPos - _HMG_HPDF_MM2Pixel( nToRow - nRow )
   LOCAL nRectWidth := nToCol - nCol
   LOCAL nRectHeight := nToRow - nRow

   DEFAULT nRColor := 0
   DEFAULT nGColor := 0
   DEFAULT nBColor := 0
   DEFAULT nWidth := 1
   DEFAULT lWidth := .f.
   DEFAULT lColor := .f.
   DEFAULT lFilled := .f.
   DEFAULT nRoundness := 0
   IF _HMG_SYSDATA[ 150 ][ 1 ] == Nil // PDF object not found!
      _HMG_HPDF_Error( 3 )

      RETURN NIL
   ENDIF
   IF _HMG_SYSDATA[ 150 ][ 7 ] == Nil // PDF Page object not found!
      _HMG_HPDF_Error( 5 )

      RETURN NIL
   ENDIF
   // set color
   IF lColor
      HPDF_Page_SetRGBSTROKE( _HMG_SYSDATA[ 150 ][ 7 ], nRColor/255, nGColor/255, nBColor/255 )
      IF lFilled
         HPDF_Page_SetRGBFill( _HMG_SYSDATA[ 150 ][ 7 ], nRColor/255, nGColor/255, nBColor/255 )
      ENDIF
   ELSE
      HPDF_Page_SetRGBSTROKE( _HMG_SYSDATA[ 150 ][ 7 ], 0.0, 0.0, 0.0 )
   ENDIF
   // set line Width
   IF lWidth
      HPDF_Page_SetLineWidth( _HMG_SYSDATA[ 150 ][ 7 ], _HMG_HPDF_MM2Pixel( nlineWidth ) )
   ELSE
      HPDF_Page_SetLineWidth( _HMG_SYSDATA[ 150 ][ 7 ], 1 )
   ENDIF
   IF nRoundness == 0
      nRoundness := int( min( nRectWidth, nRectHeight ) * 10 / 100 )
   ELSE
      IF nRoundness > int( min( nRectWidth, nRectHeight ) / 2 )
         _HMG_HPDF_Error( 8 )

         RETURN NIL
      ENDIF
   ENDIF

   nRoundness := _HMG_HPDF_MM2Pixel( nRoundness )

   // start rounded rectangle path
   HPDF_Page_MoveTo( _HMG_SYSDATA[ 150 ][ 7 ], nxPos + nRoundness, nyPos )  // top line left position
   HPDF_Page_LineTo( _HMG_SYSDATA[ 150 ][ 7 ], nToxPos - nRoundness, nyPos ) // draw top line
   HPDF_Page_CurveTo2( _HMG_SYSDATA[ 150 ][ 7 ], nToxPos, nyPos, nToxPos, nyPos - nRoundness ) // draw top right curve
   HPDF_Page_LineTo( _HMG_SYSDATA[ 150 ][ 7 ], nToxPos , nToyPos + nRoundness ) // draw right line
   HPDF_Page_CurveTo2( _HMG_SYSDATA[ 150 ][ 7 ], nToxPos, nToyPos, nToxPos - nRoundness, nToyPos ) // draw bottom right curve
   HPDF_Page_LineTo( _HMG_SYSDATA[ 150 ][ 7 ], nxPos + nRoundness , nToyPos ) // draw bottom line
   HPDF_Page_CurveTo2( _HMG_SYSDATA[ 150 ][ 7 ], nxPos, nToyPos, nxPos, nToyPos + nRoundness ) // draw bottom left curve
   HPDF_Page_LineTo( _HMG_SYSDATA[ 150 ][ 7 ], nxPos, nyPos - nRoundness ) // draw left line
   HPDF_Page_CurveTo2( _HMG_SYSDATA[ 150 ][ 7 ], nxPos, nyPos, nxPos + nRoundness, nyPos ) // draw top left curve

   // now start and finish drawing along the path
   IF lFilled
      HPDF_Page_FillStroke( _HMG_SYSDATA[ 150 ][ 7 ] )
   ELSE
      HPDF_Page_Stroke( _HMG_SYSDATA[ 150 ][ 7 ] )
   ENDIF

   RETURN NIL

FUNCTION _HMG_HPDF_CIRCLE( nRow, nCol, nR, nLineWidth, nRColor, nGColor, nBColor, lWidth, lColor, lFilled )

   LOCAL nWidth := _HMG_SYSDATA[ 150 ][ 4 ]
   LOCAL nHeight := _HMG_SYSDATA[ 150 ][ 5 ]
   LOCAL nxPos := _HMG_HPDF_MM2Pixel( nCol )
   LOCAL nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )

   DEFAULT nWidth := 1
   DEFAULT lWidth := .f.
   DEFAULT lColor := .f.
   DEFAULT lFilled := .f.
   IF _HMG_SYSDATA[ 150 ][ 1 ] == Nil // PDF object not found!
      _HMG_HPDF_Error( 3 )

      RETURN NIL
   ENDIF
   IF _HMG_SYSDATA[ 150 ][ 7 ] == Nil // PDF Page object not found!
      _HMG_HPDF_Error( 5 )

      RETURN NIL
   ENDIF

   // set color
   IF lColor
      HPDF_Page_SetRGBSTROKE( _HMG_SYSDATA[ 150 ][ 7 ], nRColor/255, nGColor/255, nBColor/255 )
      IF lFilled
         HPDF_Page_SetRGBFill( _HMG_SYSDATA[ 150 ][ 7 ], nRColor/255, nGColor/255, nBColor/255 )
      ENDIF
   ELSE
      HPDF_Page_SetRGBSTROKE( _HMG_SYSDATA[ 150 ][ 7 ], 0.0, 0.0, 0.0 )
   ENDIF
   // set line Width
   IF lWidth
      HPDF_Page_SetLineWidth( _HMG_SYSDATA[ 150 ][ 7 ], _HMG_HPDF_MM2Pixel( nlineWidth ) )
   ELSE
      HPDF_Page_SetLineWidth( _HMG_SYSDATA[ 150 ][ 7 ], 1 )
   ENDIF
   HPDF_Page_Circle( _HMG_SYSDATA[ 150 ][ 7 ], nxPos , nyPos, _HMG_HPDF_MM2Pixel( nR ) )
   IF lFilled
      HPDF_Page_FillStroke( _HMG_SYSDATA[ 150 ][ 7 ] )
   ELSE
      HPDF_Page_Stroke( _HMG_SYSDATA[ 150 ][ 7 ] )
   ENDIF

   RETURN NIL

FUNCTION _HMG_HPDF_ELLIPSE( nRow, nCol, nHR, nVR, nLineWidth, nRColor, nGColor, nBColor, lWidth, lColor, lFilled )

   LOCAL nWidth := _HMG_SYSDATA[ 150 ][ 4 ]
   LOCAL nHeight := _HMG_SYSDATA[ 150 ][ 5 ]
   LOCAL nxPos := _HMG_HPDF_MM2Pixel( nCol )
   LOCAL nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )

   DEFAULT nWidth := 1
   DEFAULT lWidth := .f.
   DEFAULT lColor := .f.
   DEFAULT lFilled := .f.
   IF _HMG_SYSDATA[ 150 ][ 1 ] == Nil // PDF object not found!
      _HMG_HPDF_Error( 3 )

      RETURN NIL
   ENDIF
   IF _HMG_SYSDATA[ 150 ][ 7 ] == Nil // PDF Page object not found!
      _HMG_HPDF_Error( 5 )

      RETURN NIL
   ENDIF

   // set color
   IF lColor
      HPDF_Page_SetRGBSTROKE( _HMG_SYSDATA[ 150 ][ 7 ], nRColor/255, nGColor/255, nBColor/255 )
      IF lFilled
         HPDF_Page_SetRGBFill( _HMG_SYSDATA[ 150 ][ 7 ], nRColor/255, nGColor/255, nBColor/255 )
      ENDIF
   ELSE
      HPDF_Page_SetRGBSTROKE( _HMG_SYSDATA[ 150 ][ 7 ], 0.0, 0.0, 0.0 )
   ENDIF
   // set line Width
   IF lWidth
      HPDF_Page_SetLineWidth( _HMG_SYSDATA[ 150 ][ 7 ], _HMG_HPDF_MM2Pixel( nlineWidth ) )
   ELSE
      HPDF_Page_SetLineWidth( _HMG_SYSDATA[ 150 ][ 7 ], 1 )
   ENDIF
   HPDF_Page_Ellipse( _HMG_SYSDATA[ 150 ][ 7 ], nxPos , nyPos, _HMG_HPDF_MM2Pixel( nHR ), _HMG_HPDF_MM2Pixel( nVR ) )
   IF lFilled
      HPDF_Page_FillStroke( _HMG_SYSDATA[ 150 ][ 7 ] )
   ELSE
      HPDF_Page_Stroke( _HMG_SYSDATA[ 150 ][ 7 ] )
   ENDIF

   RETURN NIL

FUNCTION _HMG_HPDF_ARC( nRow, nCol, nR, nFromAngle, nToAngle, nLineWidth, nRColor, nGColor, nBColor, lWidth, lColor )

   LOCAL nWidth := _HMG_SYSDATA[ 150 ][ 4 ]
   LOCAL nHeight := _HMG_SYSDATA[ 150 ][ 5 ]
   LOCAL nxPos := _HMG_HPDF_MM2Pixel( nCol )
   LOCAL nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )

   DEFAULT nWidth := 1
   DEFAULT lWidth := .f.
   DEFAULT lColor := .f.
   IF _HMG_SYSDATA[ 150 ][ 1 ] == Nil // PDF object not found!
      _HMG_HPDF_Error( 3 )

      RETURN NIL
   ENDIF
   IF _HMG_SYSDATA[ 150 ][ 7 ] == Nil // PDF Page object not found!
      _HMG_HPDF_Error( 5 )

      RETURN NIL
   ENDIF

   // set color
   IF lColor
      HPDF_Page_SetRGBSTROKE( _HMG_SYSDATA[ 150 ][ 7 ], nRColor/255, nGColor/255, nBColor/255 )
   ELSE
      HPDF_Page_SetRGBSTROKE( _HMG_SYSDATA[ 150 ][ 7 ], 0.0, 0.0, 0.0 )
   ENDIF
   // set line Width
   IF lWidth
      HPDF_Page_SetLineWidth( _HMG_SYSDATA[ 150 ][ 7 ], _HMG_HPDF_MM2Pixel( nlineWidth ) )
   ELSE
      HPDF_Page_SetLineWidth( _HMG_SYSDATA[ 150 ][ 7 ], 1 )
   ENDIF
   HPDF_Page_Arc( _HMG_SYSDATA[ 150 ][ 7 ], nxPos , nyPos, _HMG_HPDF_MM2Pixel( nR ), nFromAngle, nToAngle )
   HPDF_Page_Stroke( _HMG_SYSDATA[ 150 ][ 7 ] )

   RETURN NIL

FUNCTION _HMG_HPDF_CURVE ( nRow , nCol , nFromRow, nFromCol, nToRow, nToCol, nLineWidth, nRColor, nGColor, nBColor, lWidth, lColor )

   LOCAL nWidth := _HMG_SYSDATA[ 150 ][ 4 ]
   LOCAL nHeight := _HMG_SYSDATA[ 150 ][ 5 ]
   LOCAL nTextWidth := 0
   LOCAL nxPos := _HMG_HPDF_MM2Pixel( nCol )
   LOCAL nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )
   LOCAL nToxPos := nxPos + _HMG_HPDF_MM2Pixel( nToCol - nCol )
   LOCAL nToyPos := nyPos - _HMG_HPDF_MM2Pixel( nToRow - nRow )
   LOCAL nFromxPos := _HMG_HPDF_MM2Pixel( nFromCol )
   LOCAL nFromyPos := nHeight - _HMG_HPDF_MM2Pixel( nFromRow )

   DEFAULT nRColor := 0
   DEFAULT nGColor := 0
   DEFAULT nBColor := 0
   DEFAULT nWidth := 1
   DEFAULT lWidth := .f.
   DEFAULT lColor := .f.

   IF _HMG_SYSDATA[ 150 ][ 1 ] == Nil // PDF object not found!
      _HMG_HPDF_Error( 3 )

      RETURN NIL
   ENDIF
   IF _HMG_SYSDATA[ 150 ][ 7 ] == Nil // PDF Page object not found!
      _HMG_HPDF_Error( 5 )

      RETURN NIL
   ENDIF

   // set color
   IF lColor
      HPDF_Page_SetRGBSTROKE( _HMG_SYSDATA[ 150 ][ 7 ], nRColor/255, nGColor/255, nBColor/255 )
   ELSE
      HPDF_Page_SetRGBSTROKE( _HMG_SYSDATA[ 150 ][ 7 ], 0.0, 0.0, 0.0 )
   ENDIF

   IF lWidth
      HPDF_Page_SetLineWidth( _HMG_SYSDATA[ 150 ][ 7 ], _HMG_HPDF_MM2Pixel( nlineWidth ) )
   ELSE
      HPDF_Page_SetLineWidth( _HMG_SYSDATA[ 150 ][ 7 ], 1 )
   ENDIF
   HPDF_Page_MoveTo( _HMG_SYSDATA[ 150 ][ 7 ], nxPos, nyPos )
   HPDF_Page_CurveTo2( _HMG_SYSDATA[ 150 ][ 7 ], nFromxPos, nFromyPos, nToxPos, nToyPos )
   HPDF_Page_Stroke( _HMG_SYSDATA[ 150 ][ 7 ] )

   RETURN NIL

FUNCTION _HMG_HPDF_IMAGE ( cImage, nRow, nCol, nImageheight, nImageWidth, lStretch , cImageType)

   LOCAL nWidth := _HMG_SYSDATA[ 150 ][ 4 ]
   LOCAL nHeight := _HMG_SYSDATA[ 150 ][ 5 ]
   LOCAL nxPos := _HMG_HPDF_MM2Pixel( nCol )
   LOCAL nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )
   LOCAL oImage := Nil

   DEFAULT lStretch := .f.
   DEFAULT cImageType := "PNG"

   IF _HMG_SYSDATA[ 150 ][ 1 ] == Nil // PDF object not found!
      _HMG_HPDF_Error( 3 )

      RETURN NIL
   ENDIF
   IF _HMG_SYSDATA[ 150 ][ 7 ] == Nil // PDF Page object not found!
      _HMG_HPDF_Error( 5 )

      RETURN NIL
   ENDIF

   DO CASE
   CASE HMG_UPPER( alltrim( cImageType ) ) = "PNG"
      oImage := _HPDF_LOAD_PNG (_HMG_SYSDATA[ 150 ][ 1 ], cImage)
   CASE HMG_UPPER( alltrim( cImageType ) ) = "JPG"
      oImage := _HPDF_LOAD_JPG (_HMG_SYSDATA[ 150 ][ 1 ], cImage)
   OTHERWISE
      _HMG_HPDF_Error( 20 )
   ENDCASE

   IF oImage = Nil
      _HMG_HPDF_Error( 7 )

      RETURN NIL
   ENDIF

   IF empty( oImage )
      _HMG_HPDF_Error( 7 )

      RETURN NIL
   ENDIF
   HPDF_Page_DrawImage( _HMG_SYSDATA[ 150 ][ 7 ], oImage, nxPos, nyPos - _HMG_HPDF_MM2Pixel( nImageHeight ), _HMG_HPDF_MM2Pixel( nImageWidth ), _HMG_HPDF_MM2Pixel( nImageHeight ) )

   RETURN NIL

FUNCTION _HMG_HPDF_SetPassword( cOwnerPass, cUserPass )

   DEFAULT cUserPass := ''
   IF _HMG_SYSDATA[ 150 ][ 1 ] == Nil // PDF object not found!
      _HMG_HPDF_Error( 3 )

      RETURN NIL
   ENDIF
   HPDF_SetPassword( _HMG_SYSDATA[ 150 ][ 1 ], cOwnerPass, cUserPass )

   RETURN NIL

FUNCTION _HMG_HPDF_SetCompression( cMode )

   DEFAULT cMode := ''
   IF _HMG_SYSDATA[ 150 ][ 1 ] == Nil // PDF object not found!
      _HMG_HPDF_Error( 3 )

      RETURN NIL
   ENDIF
   cMode := HMG_UPPER( cMode )
   DO CASE
   CASE cMode == 'NONE'
      HPDF_SetCompressionMode( _HMG_SYSDATA[ 150 ][ 1 ], HPDF_COMP_NONE )
   CASE cMode == 'TEXT'
      HPDF_SetCompressionMode( _HMG_SYSDATA[ 150 ][ 1 ], HPDF_COMP_TEXT )
   CASE cMode == 'IMAGE'
      HPDF_SetCompressionMode( _HMG_SYSDATA[ 150 ][ 1 ], HPDF_COMP_IMAGE )
   CASE cMode == 'METADATA'
      HPDF_SetCompressionMode( _HMG_SYSDATA[ 150 ][ 1 ], HPDF_COMP_METADATA )
   CASE cMode == 'ALL'
      HPDF_SetCompressionMode( _HMG_SYSDATA[ 150 ][ 1 ], HPDF_COMP_ALL )
   OTHERWISE
      HPDF_SetCompressionMode( _HMG_SYSDATA[ 150 ][ 1 ], HPDF_COMP_NONE )
   ENDCASE

   RETURN NIL

FUNCTION _HMG_HPDF_SetPermission( cMode )

   DEFAULT cMode := ''
   IF _HMG_SYSDATA[ 150 ][ 1 ] == Nil // PDF object not found!
      _HMG_HPDF_Error( 3 )

      RETURN NIL
   ENDIF
   cMode := HMG_UPPER( cMode )
   DO CASE
   CASE cMode == 'READ'
      HPDF_SetPermission( _HMG_SYSDATA[ 150 ][ 1 ], HPDF_ENABLE_READ )
   CASE cMode == 'PRINT'
      HPDF_SetPermission( _HMG_SYSDATA[ 150 ][ 1 ], HPDF_ENABLE_PRINT )
   CASE cMode == 'COPY'
      HPDF_SetPermission( _HMG_SYSDATA[ 150 ][ 1 ], HPDF_ENABLE_COPY )
   CASE cMode == 'EDIT'
      HPDF_SetPermission( _HMG_SYSDATA[ 150 ][ 1 ], HPDF_ENABLE_EDIT )
   CASE cMode == 'EDIT_ALL'
      HPDF_SetPermission( _HMG_SYSDATA[ 150 ][ 1 ], HPDF_ENABLE_EDIT_ALL )
   ENDCASE

   RETURN NIL

FUNCTION _HMG_HPDF_SetPageMode( cMode )

   DEFAULT cMode := ''
   IF _HMG_SYSDATA[ 150 ][ 1 ] == Nil // PDF object not found!
      _HMG_HPDF_Error( 3 )

      RETURN NIL
   ENDIF
   cMode := HMG_UPPER( cMode )
   DO CASE
   CASE cMode == 'OUTLINE'
      HPDF_SetPageMode( _HMG_SYSDATA[ 150 ][ 1 ], HPDF_PAGE_MODE_USE_OUTLINE )
   CASE cMode == 'NONE'
      HPDF_SetPageMode( _HMG_SYSDATA[ 150 ][ 1 ], HPDF_PAGE_MODE_USE_NONE )
   CASE cMode == 'THUMBS'
      HPDF_SetPageMode( _HMG_SYSDATA[ 150 ][ 1 ], HPDF_PAGE_MODE_USE_THUMBS )
   CASE cMode == 'FULL_SCREEN'
      HPDF_SetPageMode( _HMG_SYSDATA[ 150 ][ 1 ], HPDF_PAGE_MODE_FULL_SCREEN )
   CASE cMode == 'EOF'
      HPDF_SetPageMode( _HMG_SYSDATA[ 150 ][ 1 ], HPDF_PAGE_MODE_EOF )
   ENDCASE

   RETURN NIL

FUNCTION _HMG_HPDF_RootOutline( cTitle, cName, cParent )

   LOCAL aOutlines := {}
   LOCAL oOutline := Nil
   LOCAL i

   DEFAULT cParent := ''
   IF _HMG_SYSDATA[ 150 ][ 1 ] == Nil // PDF object not found!
      _HMG_HPDF_Error( 3 )

      RETURN NIL
   ENDIF
   IF HMG_LEN( alltrim( cTitle ) ) == 0
      _HMG_HPDF_Error( 11 )

      RETURN NIL
   ENDIF
   IF HMG_LEN( alltrim( cName ) ) == 0
      _HMG_HPDF_Error( 12 )

      RETURN NIL
   ENDIF
   IF HMG_LEN( alltrim( cParent ) ) == 0 // make this a root outline
      oOutline := HPDF_CreateOutline( _HMG_SYSDATA[ 150 ][ 1 ], Nil, cTitle, HPDF_GetCurrentEncoder() )
      IF Empty( oOutLine )
         _HMG_HPDF_Error( 10 )

         RETURN NIL
      ELSE
         aadd( _HMG_SYSDATA[ 150 ][ 11 ], { oOutline, cName } )
      ENDIF
   ELSE
      aOutLines := aclone( _HMG_SYSDATA[ 150 ][ 11 ] )
      FOR i := 1 to HMG_LEN( aOutLines )
         IF HMG_UPPER( alltrim( aOutLines[ i, 2 ] ) ) == HMG_UPPER( alltrim( cParent ) )
            oOutline := HPDF_CreateOutline( _HMG_SYSDATA[ 150 ][ 1 ], aOutLines[ i, 1 ], cTitle, HPDF_GetCurrentEncoder() )
            IF Empty( oOutLine )
               _HMG_HPDF_Error( 10 )

               RETURN NIL
            ELSE
               aadd( _HMG_SYSDATA[ 150 ][ 11 ], { oOutline, cName } )
            ENDIF
            EXIT
         ENDIF
      NEXT i
   ENDIF

   RETURN NIL

FUNCTION _HMG_HPDF_PageOutline( cTitle, cParent, cName )

   LOCAL aOutlines := {}
   LOCAL oOutline := Nil
   LOCAL oDestination := Nil
   LOCAL i

   DEFAULT cParent := ''
   DEFAULT cName := ''
   IF _HMG_SYSDATA[ 150 ][ 1 ] == Nil // PDF object not found!
      _HMG_HPDF_Error( 3 )

      RETURN NIL
   ENDIF
   IF _HMG_SYSDATA[ 150 ][ 7 ] == Nil // PDF Page object not found!
      _HMG_HPDF_Error( 5 )

      RETURN NIL
   ENDIF
   oDestination := HPDF_Page_CreateDestination( _HMG_SYSDATA[ 150 ][ 7 ] )
   IF empty( oDestination )
      _HMG_HPDF_Error( 13 )

      RETURN NIL
   ENDIF
   IF HMG_LEN( alltrim( cParent ) ) == 0 // No parent make this page root element
      oOutline := HPDF_CreateOutline( _HMG_SYSDATA[ 150 ][ 1 ], Nil, cTitle, HPDF_GetCurrentEncoder() )
      IF empty( oOutline )
         _HMG_HPDF_Error( 13 )

         RETURN NIL
      ENDIF
   ELSE
      aOutlines := aclone( _HMG_SYSDATA[ 150 ][ 11 ] )
      FOR i := 1 to HMG_LEN( aOutlines )
         IF HMG_UPPER( alltrim( aOutlines[ i, 2 ] ) ) == HMG_UPPER( alltrim( cParent ) )
            oOutline := HPDF_CreateOutline( _HMG_SYSDATA[ 150 ][ 1 ], aOutlines[ i, 1 ], cTitle, HPDF_GetCurrentEncoder() )
            EXIT
         ENDIF
      NEXT i
      IF empty( oOutline )
         _HMG_HPDF_Error( 14 )

         RETURN NIL
      ENDIF
   ENDIF
   IF HMG_LEN( alltrim( cName ) ) > 0
      aadd( _HMG_SYSDATA[ 150 ][ 11 ], { oOutline, cName } )
   ENDIF
   HPDF_Outline_SetDestination( oOutline, oDestination )

   RETURN NIL

FUNCTION _HMG_HPDF_SetTextAnnot( nRow, nCol, cToolTip, cIcon )

   LOCAL nWidth := _HMG_SYSDATA[ 150 ][ 4 ]
   LOCAL nHeight := _HMG_SYSDATA[ 150 ][ 5 ]
   LOCAL nToRow := nRow + 5
   LOCAL nToCol := nCol + 5
   LOCAL nxPos := _HMG_HPDF_MM2Pixel( nCol )
   LOCAL nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )
   LOCAL nToxPos := nxPos + _HMG_HPDF_MM2Pixel( nToCol - nCol )
   LOCAL nToyPos := nyPos - _HMG_HPDF_MM2Pixel( nToRow - nRow )
   LOCAL aRect := { nxPos, nyPos, nToxPos, nToyPos }
   LOCAL oAnnot := Nil

   IF _HMG_SYSDATA[ 150 ][ 1 ] == Nil // PDF object not found!
      _HMG_HPDF_Error( 3 )

      RETURN NIL
   ENDIF
   IF _HMG_SYSDATA[ 150 ][ 7 ] == Nil // PDF Page object not found!
      _HMG_HPDF_Error( 5 )

      RETURN NIL
   ENDIF
   oAnnot := HPDF_Page_CreateTextAnnot ( _HMG_SYSDATA[ 150 ][ 7 ], aRect, cTooltip, HPDF_GetCurrentEncoder() )
   IF empty( oAnnot )
      _HMG_HPDF_Error( 15 )

      RETURN NIL
   ENDIF
   DO CASE
   CASE HMG_UPPER( alltrim( cIcon ) ) == "COMMENT"
      HPDF_TextAnnot_SetIcon ( oAnnot, HPDF_ANNOT_ICON_COMMENT )
   CASE HMG_UPPER( alltrim( cIcon ) ) == "KEY"
      HPDF_TextAnnot_SetIcon ( oAnnot, HPDF_ANNOT_ICON_KEY )
   CASE HMG_UPPER( alltrim( cIcon ) ) == "NOTE"
      HPDF_TextAnnot_SetIcon ( oAnnot, HPDF_ANNOT_ICON_NOTE )
   CASE HMG_UPPER( alltrim( cIcon ) ) == "HELP"
      HPDF_TextAnnot_SetIcon ( oAnnot, HPDF_ANNOT_ICON_HELP )
   CASE HMG_UPPER( alltrim( cIcon ) ) == "NEW_PARAGRAPH"
      HPDF_TextAnnot_SetIcon ( oAnnot, HPDF_ANNOT_ICON_NEW_PARAGRAPH )
   CASE HMG_UPPER( alltrim( cIcon ) ) == "PARAGRAPH"
      HPDF_TextAnnot_SetIcon ( oAnnot, HPDF_ANNOT_ICON_PARAGRAPH )
   CASE HMG_UPPER( alltrim( cIcon ) ) == "INSERT"
      HPDF_TextAnnot_SetIcon ( oAnnot, HPDF_ANNOT_ICON_INSERT )
   ENDCASE

   RETURN NIL

FUNCTION _HMG_HPDF_SetPageLink( nRow, nCol, cText, nPage, cFontName, nFontSize, nRColor, nGColor, nBColor, cAlign, lColor, lFont, lSize, lBorder, lWidth, nBorderWidth )

   LOCAL nWidth := _HMG_SYSDATA[ 150 ][ 4 ]
   LOCAL nHeight := _HMG_SYSDATA[ 150 ][ 5 ]
   LOCAL nTextWidth := 0
   LOCAL nxPos := _HMG_HPDF_MM2Pixel( nCol )
   LOCAL nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )
   LOCAL oFont := Nil
   LOCAL cFont := ''
   LOCAL aRect := { }
   LOCAL aCurXY := {}
   LOCAL oAnnot := Nil
   LOCAL oDest := Nil
   LOCAL aPages := {}
   LOCAL oLinkPage := Nil

   DEFAULT cFontName := ''
   DEFAULT nFontSize := 12
   DEFAULT nRColor := 0
   DEFAULT nGColor := 0
   DEFAULT nBColor := 0
   DEFAULT lColor := .f.
   DEFAULT lFont := .f.
   DEFAULT lSize := .f.
   DEFAULT cAlign := ''
   DEFAULT lBorder := .f.
   DEFAULT lWidth := .f.
   DEFAULT nBorderWidth := 0

   IF _HMG_SYSDATA[ 150 ][ 1 ] == Nil // PDF object not found!
      _HMG_HPDF_Error( 3 )

      RETURN NIL
   ENDIF
   IF _HMG_SYSDATA[ 150 ][ 7 ] == Nil // PDF Page object not found!
      _HMG_HPDF_Error( 5 )

      RETURN NIL
   ENDIF

   aPages := aClone( _HMG_SYSDATA[ 150 ][ 12 ] )
   IF nPage > HMG_LEN( aPages ) .or. nPage < 1
      _HMG_HPDF_Error( 17 )

      RETURN NIL
   ENDIF

   oLinkPage := aPages[ nPage ]
   IF empty( oLinkPage )
      _HMG_HPDF_Error( 17 )

      RETURN NIL
   ENDIF
   oDest := HPDF_Page_CreateDestination( oLinkPage )
   IF empty( oDest )
      _HMG_HPDF_Error( 17 )

      RETURN NIL
   ENDIF

   // set color
   IF lColor
      HPDF_Page_SetRGBFill( _HMG_SYSDATA[ 150 ][ 7 ], nRColor/255, nGColor/255, nBColor/255 )
   ELSE
      HPDF_Page_SetRGBFill( _HMG_SYSDATA[ 150 ][ 7 ], 0.0, 0.0, 0.0 )
   ENDIF

   // set font
   IF HMG_LEN( alltrim( cFontName ) ) == 0
      cFontName := _HMG_HPDF_SetFont( cFontName )
      oFont := HPDF_GetFont( _HMG_SYSDATA[ 150 ][ 1 ], cFontName, _HMG_SYSDATA[ 150 ][ 10 ] )
   ELSE
      // cFontName := alltrim( cFontName )
      cFontName := AllTrim(_HMG_HPDF_SetFont( cFontName ))

      IF HMG_UPPER (cFileExt (cFontName)) == '.TTF' // load ttf font

         cFont := HPDF_LOADTTFONTFROMFILE( _HMG_SYSDATA[ 150 ][ 1 ], cFontName, .t. )
         IF HMG_LEN( alltrim( cFont ) ) == 0
            _HMG_HPDF_Error( 6 , cFontName )

            RETURN NIL
         ENDIF
         oFont := HPDF_GetFont( _HMG_SYSDATA[ 150 ][ 1 ], cFont, _HMG_SYSDATA[ 150 ][ 10 ] )
      ELSE
         IF HMG_UPPER( alltrim( cFontName ) ) == "SYMBOL" .or. HMG_UPPER( alltrim( cFontName ) ) == "ZAPFDINGBATS"
            oFont := HPDF_GetFont( _HMG_SYSDATA[ 150 ][ 1 ], cFontName, Nil )
         ELSE
            oFont := HPDF_GetFont( _HMG_SYSDATA[ 150 ][ 1 ], cFontName, _HMG_SYSDATA[ 150 ][ 10 ] )
         ENDIF
      ENDIF
   ENDIF
   IF oFont == Nil
      _HMG_HPDF_Error( 6 , cFontName )

      RETURN NIL
   ELSE
      HPDF_Page_SetFontAndSize( _HMG_SYSDATA[ 150 ][ 7 ], oFont, nFontSize )
      nTextWidth := HPDF_Page_TextWidth( _HMG_SYSDATA[ 150 ][ 7 ], cText )
      DO CASE
      CASE HMG_UPPER( alltrim( cAlign ) ) == 'CENTER'
         nxPos := nxPos - ( nTextWidth / 2 )
      CASE HMG_UPPER( alltrim( cAlign ) ) == 'RIGHT'
         nxPos := nxPos - ( nTextWidth )
      ENDCASE
      HPDF_Page_BeginText( _HMG_SYSDATA[ 150 ][ 7 ] )
      HPDF_PAGE_TEXTOUT( _HMG_SYSDATA[ 150 ][ 7 ], nxPos, nyPos, cText )
      aRect := { nxPos - 4, nyPos + nFontsize + 4, nxPos + nTextWidth + 4, nyPos - 4 }
      oAnnot := HPDF_Page_CreateLinkAnnot( _HMG_SYSDATA[ 150 ][ 7 ], aRect, oDest )
      IF lBorder
         IF nBorderWidth == 0
            nBorderWidth := 1
         ELSE
            nBorderWidth := _HMG_HPDF_MM2Pixel( nBorderWidth )
         ENDIF
         HPDF_LinkAnnot_SetBorderStyle ( oAnnot, nBorderWidth, 0, 0)
      ELSE
         HPDF_LinkAnnot_SetBorderStyle ( oAnnot, 0, 0, 0)
      ENDIF
      HPDF_Page_EndText( _HMG_SYSDATA[ 150 ][ 7 ] )
   ENDIF

   RETURN NIL

FUNCTION _HMG_HPDF_SetURLLink( nRow, nCol, cText, cLink, cFontName, nFontSize, nRColor, nGColor, nBColor, cAlign, lColor, lFont, lSize, lBold, lItalic  )

   LOCAL nWidth := _HMG_SYSDATA[ 150 ][ 4 ]
   LOCAL nHeight := _HMG_SYSDATA[ 150 ][ 5 ]
   LOCAL nTextWidth := 0
   LOCAL nxPos := _HMG_HPDF_MM2Pixel( nCol )
   LOCAL nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )
   LOCAL oFont := Nil
   LOCAL cFont := ''
   LOCAL aRect := { }
   LOCAL aCurXY := {}
   LOCAL oAnnot := Nil

   DEFAULT cFontName := ''
   DEFAULT nFontSize := 12
   DEFAULT nRColor := 0
   DEFAULT nGColor := 0
   DEFAULT nBColor := 0
   DEFAULT lColor := .f.
   DEFAULT lFont := .f.
   DEFAULT lSize := .f.
   DEFAULT lBold := .f.
   DEFAULT lItalic := .f.
   DEFAULT cAlign := ''

   IF _HMG_SYSDATA[ 150 ][ 1 ] == Nil // PDF object not found!
      _HMG_HPDF_Error( 3 )

      RETURN NIL
   ENDIF
   IF _HMG_SYSDATA[ 150 ][ 7 ] == Nil // PDF Page object not found!
      _HMG_HPDF_Error( 5 )

      RETURN NIL
   ENDIF

   // set color
   IF lColor
      HPDF_Page_SetRGBFill( _HMG_SYSDATA[ 150 ][ 7 ], nRColor/255, nGColor/255, nBColor/255 )
   ELSE
      HPDF_Page_SetRGBFill( _HMG_SYSDATA[ 150 ][ 7 ], 0.0, 0.0, 0.0 )
   ENDIF

   // set font
   IF HMG_LEN( alltrim( cFontName ) ) == 0
      cFontName := _HMG_HPDF_SetFont( cFontName )
      oFont := HPDF_GetFont( _HMG_SYSDATA[ 150 ][ 1 ], cFontName, _HMG_SYSDATA[ 150 ][ 10 ] )
   ELSE
      // cFontName := alltrim( cFontName )
      cFontName := AllTrim(_HMG_HPDF_SetFont( cFontName, lBold, lItalic ))

      IF HMG_UPPER (cFileExt (cFontName)) == '.TTF' // load ttf font

         cFont := HPDF_LOADTTFONTFROMFILE( _HMG_SYSDATA[ 150 ][ 1 ], cFontName, .t. )
         IF HMG_LEN( alltrim( cFont ) ) == 0
            _HMG_HPDF_Error( 6 , cFontName )

            RETURN NIL
         ENDIF
         oFont := HPDF_GetFont( _HMG_SYSDATA[ 150 ][ 1 ], cFont, _HMG_SYSDATA[ 150 ][ 10 ] )
      ELSE
         IF HMG_UPPER( alltrim( cFontName ) ) == "SYMBOL" .or. HMG_UPPER( alltrim( cFontName ) ) == "ZAPFDINGBATS"
            oFont := HPDF_GetFont( _HMG_SYSDATA[ 150 ][ 1 ], cFontName, Nil )
         ELSE
            oFont := HPDF_GetFont( _HMG_SYSDATA[ 150 ][ 1 ], cFontName, _HMG_SYSDATA[ 150 ][ 10 ] )
         ENDIF
      ENDIF
   ENDIF
   IF oFont == Nil
      _HMG_HPDF_Error( 6 , cFontName )

      RETURN NIL
   ELSE
      HPDF_Page_SetFontAndSize( _HMG_SYSDATA[ 150 ][ 7 ], oFont, nFontSize )
      nTextWidth := HPDF_Page_TextWidth( _HMG_SYSDATA[ 150 ][ 7 ], cText )
      DO CASE
      CASE HMG_UPPER( alltrim( cAlign ) ) == 'CENTER'
         nxPos := nxPos - ( nTextWidth / 2 )
      CASE HMG_UPPER( alltrim( cAlign ) ) == 'RIGHT'
         nxPos := nxPos - ( nTextWidth )
      ENDCASE
      HPDF_Page_BeginText( _HMG_SYSDATA[ 150 ][ 7 ] )
      HPDF_PAGE_TEXTOUT( _HMG_SYSDATA[ 150 ][ 7 ], nxPos, nyPos, cText )
      aRect := { nxPos - 4, nyPos + nFontsize + 4, nxPos + nTextWidth + 4, nyPos - 4 }
      HPDF_Page_CreateURILinkAnnot( _HMG_SYSDATA[ 150 ][ 7 ], aRect, cLink )
      HPDF_Page_EndText( _HMG_SYSDATA[ 150 ][ 7 ] )
   ENDIF

   RETURN NIL

FUNCTION _HMG_HPDF_SetLineSpacing( nSpacing )

   IF _HMG_SYSDATA[ 150 ][ 1 ] == Nil // PDF object not found!
      _HMG_HPDF_Error( 3 )

      RETURN NIL
   ENDIF
   IF _HMG_SYSDATA[ 150 ][ 7 ] == Nil // PDF Page object not found!
      _HMG_HPDF_Error( 5 )

      RETURN NIL
   ENDIF
   HPDF_Page_SetTextLeading( _HMG_SYSDATA[ 150 ][ 7 ], _HMG_HPDF_MM2Pixel( nSpacing ) )

   RETURN NIL

FUNCTION _HMG_HPDF_SetInfo( cAttrib, xValue, cTime )

   LOCAL cValue := ''
   LOCAL dValue := ''
   LOCAL nHours := 0
   LOCAL nMinutes := 0
   LOCAL nSeconds := 0

   DEFAULT cTime := ''
   IF _HMG_SYSDATA[ 150 ][ 1 ] == Nil // PDF object not found!
      _HMG_HPDF_Error( 3 )

      RETURN NIL
   ENDIF
   DO CASE
   CASE valtype( xValue ) == 'D'
      dValue := xValue
   OTHERWISE
      cValue := xValue
   ENDCASE
   DO CASE
   CASE HMG_UPPER( alltrim( cAttrib ) ) == "AUTHOR"
      HPDF_SetInfoAttr( _HMG_SYSDATA[ 150 ][ 1 ], HPDF_INFO_AUTHOR, cValue )
   CASE HMG_UPPER( alltrim( cAttrib ) ) == "CREATOR"
      HPDF_SetInfoAttr( _HMG_SYSDATA[ 150 ][ 1 ], HPDF_INFO_CREATOR, cValue )
   CASE HMG_UPPER( alltrim( cAttrib ) ) == "TITLE"
      HPDF_SetInfoAttr( _HMG_SYSDATA[ 150 ][ 1 ], HPDF_INFO_TITLE, cValue )
   CASE HMG_UPPER( alltrim( cAttrib ) ) == "SUBJECT"
      HPDF_SetInfoAttr( _HMG_SYSDATA[ 150 ][ 1 ], HPDF_INFO_SUBJECT, cValue )
   CASE HMG_UPPER( alltrim( cAttrib ) ) == "KEYWORDS"
      HPDF_SetInfoAttr( _HMG_SYSDATA[ 150 ][ 1 ], HPDF_INFO_KEYWORDS, cValue )
   CASE HMG_UPPER( alltrim( cAttrib ) ) == "DATECREATED"
      IF HMG_LEN( alltrim( cTime ) ) > 0
         nHours := val( HB_USUBSTR( cTime, 1, 2) )
         nMinutes := val( HB_USUBSTR( cTime, 4, 2) )
         nSeconds := val( HB_USUBSTR( cTime, 7, 2) )
      ENDIF
      HPDF_SetInfoDateAttr( _HMG_SYSDATA[ 150 ][ 1 ], HPDF_INFO_CREATION_DATE, { year( dValue ), month( dVAlue ), day( dValue ), nHours, nMinutes, nSeconds } )
   CASE HMG_UPPER( alltrim( cAttrib ) ) == "DATEMODIFIED"
      IF HMG_LEN( alltrim( cTime ) ) > 0
         nHours := val( HB_USUBSTR( cTime, 1, 2) )
         nMinutes := val( HB_USUBSTR( cTime, 4, 2) )
         nSeconds := val( HB_USUBSTR( cTime, 7, 2) )
      ENDIF
      HPDF_SetInfoDateAttr( _HMG_SYSDATA[ 150 ][ 1 ], HPDF_INFO_MOD_DATE, { year( dValue ), month( dVAlue ), day( dValue ), nHours, nMinutes, nSeconds } )
   ENDCASE

   RETURN NIL

FUNCTION _HMG_HPDF_GetInfo( cAttrib )

   LOCAL cRetValue := ''

   IF _HMG_SYSDATA[ 150 ][ 1 ] == Nil // PDF object not found!
      _HMG_HPDF_Error( 3 )

      RETURN NIL
   ENDIF
   DO CASE
   CASE HMG_UPPER( alltrim( cAttrib ) ) == "AUTHOR"
      cRetValue := HPDF_GetInfoAttr( _HMG_SYSDATA[ 150 ][ 1 ], HPDF_INFO_AUTHOR )
   CASE HMG_UPPER( alltrim( cAttrib ) ) == "CREATOR"
      cRetValue := HPDF_GetInfoAttr( _HMG_SYSDATA[ 150 ][ 1 ], HPDF_INFO_CREATOR )
   CASE HMG_UPPER( alltrim( cAttrib ) ) == "TITLE"
      cRetValue := HPDF_GetInfoAttr( _HMG_SYSDATA[ 150 ][ 1 ], HPDF_INFO_TITLE )
   CASE HMG_UPPER( alltrim( cAttrib ) ) == "SUBJECT"
      cRetValue := HPDF_GetInfoAttr( _HMG_SYSDATA[ 150 ][ 1 ], HPDF_INFO_SUBJECT )
   CASE HMG_UPPER( alltrim( cAttrib ) ) == "KEYWORDS"
      cRetValue := HPDF_GetInfoAttr( _HMG_SYSDATA[ 150 ][ 1 ], HPDF_INFO_KEYWORDS )
   CASE HMG_UPPER( alltrim( cAttrib ) ) == "DATECREATED"
      cRetValue := HPDF_GetInfoAttr( _HMG_SYSDATA[ 150 ][ 1 ], HPDF_INFO_CREATION_DATE )
   CASE HMG_UPPER( alltrim( cAttrib ) ) == "DATEMODIFIED"
      cRetValue := HPDF_GetInfoAttr( _HMG_SYSDATA[ 150 ][ 1 ], HPDF_INFO_MOD_DATE )
   ENDCASE

   RETURN cRetValue

FUNCTION _HMG_HPDF_SetPageLabel( nPage, cStyle, cCase, cPrefix )

   DEFAULT cCase := ""
   DEFAULT cStyle := "DECIMAL"
   DEFAULT nPage := 1
   DEFAULT cPrefix := ""
   IF _HMG_SYSDATA[ 150 ][ 1 ] == Nil // PDF object not found!
      _HMG_HPDF_Error( 3 )

      RETURN NIL
   ENDIF
   DO CASE
   CASE HMG_UPPER( alltrim( cStyle ) ) == "DECIMAL"
      HPDF_AddPageLabel( _HMG_SYSDATA[ 150 ][ 1 ], nPage, HPDF_PAGE_NUM_STYLE_DECIMAL, nPage, cPrefix )
   CASE HMG_UPPER( alltrim( cStyle ) ) == "ROMAN"
      IF HMG_UPPER( alltrim( cCase ) ) == "LOWER"
         HPDF_AddPageLabel( _HMG_SYSDATA[ 150 ][ 1 ], nPage, HPDF_PAGE_NUM_STYLE_LOWER_ROMAN, nPage, cPrefix )
      ELSE
         HPDF_AddPageLabel( _HMG_SYSDATA[ 150 ][ 1 ], nPage, HPDF_PAGE_NUM_STYLE_UPPER_ROMAN, nPage, cPrefix )
      ENDIF
   CASE HMG_UPPER( alltrim( cStyle ) ) == "LETTERS"
      IF HMG_UPPER( alltrim( cCase ) ) == "LOWER"
         HPDF_AddPageLabel( _HMG_SYSDATA[ 150 ][ 1 ], nPage, HPDF_PAGE_NUM_STYLE_LOWER_LETTERS, nPage, cPrefix )
      ELSE
         HPDF_AddPageLabel( _HMG_SYSDATA[ 150 ][ 1 ], nPage, HPDF_PAGE_NUM_STYLE_UPPER_LETTERS, nPage, cPrefix )
      ENDIF
   ENDCASE

   RETURN NIL

FUNCTION _HMG_HPDF_Error( nErr, ctxt )

   LOCAL cErr := ''

   DEFAULT ctxt := ""
   DO CASE
   CASE nErr == 1
      cErr := 'A PDF document is already initiated.'
   CASE nErr == 2
      cErr := 'PDF document cannot be initialized.'
   CASE nErr == 3
      cErr := 'PDF PAGE cannot be added. PDF document cannot be found.'
   CASE nErr == 4
      cErr := 'A PDF PAGE is already inititated.'
   CASE nErr == 5
      cErr := 'PDF PAGE cannot be found.'
   CASE nErr == 6
      cErr := 'Font cannot be loaded.'+" | "+ctxt
   CASE nErr == 7
      cErr := 'Image cannot be loaded.'
   CASE nErr == 8
      cErr := 'Round curve can not be longer than half of the width/height.'
   CASE nErr == 9
      cErr := 'Can not start new page.'+" | "+ctxt
   CASE nErr == 10
      cErr := 'Can not create new parent outline.'
   CASE nErr == 11
      cErr := 'Outline Title is not valid.'
   CASE nErr == 12
      cErr := 'Outline Name is not valid.'
   CASE nErr == 13
      cErr := 'Can not create Page Outline.'
   CASE nErr == 14
      cErr := 'Can not find Parent Node.'
   CASE nErr == 15
      cErr := 'Tooltip creation error!'
   CASE nErr == 16
      cErr := 'Page not found. New page can not be inserted.'
   CASE nErr == 17
      cErr := 'Link Page not found.'
   CASE nErr == 18
      cErr := 'Selected Page can not be found.'
   CASE nErr == 19
      cErr := 'Page Selection error!'
   CASE nErr == 20
      cErr := 'Invalid Image Type!'
   ENDCASE
   MsgStop( cErr )

   RETURN NIL

FUNCTION _HMG_HPDF_Inch2Pixel( nInches )

   RETURN ( nInches * 72 )

FUNCTION _HMG_HPDF_Pixel2Inch( nPixels )

   RETURN ( nPixels / 72 )

FUNCTION _HMG_HPDF_MM2Pixel( nMM )

   RETURN ( ( nMM / 25.4 ) * 72 )

FUNCTION _HMG_HPDF_Pixel2MM( nPixel )

   RETURN ( ( nPixel / 72 ) * 25.4 )

FUNCTION _HMG_HPDF_INIT_PAPERSIZE( nPaperSize )

   LOCAL nTemp := 0

   DO CASE
   CASE nPaperSize == 1 .or. nPaperSize == -999 // HPDF_PAPER_LETTER or default
      _HMG_SYSDATA[ 150 ][ 4 ] := 612
      _HMG_SYSDATA[ 150 ][ 5 ] := 792
   CASE nPaperSize == 2 // HPDF_PAPER_LETTERSMALL
      _HMG_SYSDATA[ 150 ][ 4 ] := 612
      _HMG_SYSDATA[ 150 ][ 5 ] := 792
   CASE nPaperSize == 3 // HPDF_PAPER_TABLOID
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 11 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 17 )
   CASE nPaperSize == 4 // HPDF_PAPER_LEDGER
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 17 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 11 )
   CASE nPaperSize == 5 // HPDF_PAPER_LEGAL
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 8.5 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 14 )
   CASE nPaperSize == 6 // HPDF_PAPER_STATEMENT
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 5.5 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 8.5 )
   CASE nPaperSize == 7 // HPDF_PAPER_EXECUTIVE
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 5.5 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 8.5 )
   CASE nPaperSize == 8 // HPDF_PAPER_A3
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 297 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 420 )
   CASE nPaperSize == 9 // HPDF_PAPER_A4
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 210 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 297 )
   CASE nPaperSize == 10 // HPDF_PAPER_A4SMALL
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 210 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 297 )
   CASE nPaperSize == 11 // HPDF_PAPER_A5
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 148 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 210 )
   CASE nPaperSize == 12 // HPDF_PAPER_B4
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 250 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 354 )
   CASE nPaperSize == 13 // HPDF_PAPER_B5
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 185 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 257 )
   CASE nPaperSize == 14 // HPDF_PAPER_FOLIO
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 8.5 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 13 )
   CASE nPaperSize == 15 // HPDF_PAPER_QUARTO
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 215 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 275 )
   CASE nPaperSize == 16 // HPDF_PAPER_10X14
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 10 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 140 )
   CASE nPaperSize == 17 // HPDF_PAPER_11X17
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 11 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 17 )
   CASE nPaperSize == 18 // HPDF_PAPER_NOTE
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 8.5 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 11 )
   CASE nPaperSize == 19 // HPDF_PAPER_ENV_9
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 3 + (7 / 8) )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 8 + (7 / 8) )
   CASE nPaperSize == 20 // HPDF_PAPER_ENV_10
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 4 + (1 / 8) )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 9.5 )
   CASE nPaperSize == 21 // HPDF_PAPER_ENV_11
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 4.5 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 10 + (3 / 8) )
   CASE nPaperSize == 22 // HPDF_PAPER_ENV_12
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 4.75 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 11 )
   CASE nPaperSize == 23 // HPDF_PAPER_ENV_14
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 5 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 11.5 )
   CASE nPaperSize == 24 // HPDF_PAPER_CSHEET
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 17 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 22 )
   CASE nPaperSize == 25 // HPDF_PAPER_DSHEET
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 22 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 34 )
   CASE nPaperSize == 26 // HPDF_PAPER_ESHEET
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 34 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 44 )
   CASE nPaperSize == 27 // HPDF_PAPER_ENV_DL
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 110 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 220 )
   CASE nPaperSize == 28 // HPDF_PAPER_ENV_C5
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 162 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 229 )
   CASE nPaperSize == 29 // HPDF_PAPER_ENV_C3
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 324 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 458 )
   CASE nPaperSize == 30 // HPDF_PAPER_ENV_C4
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 229 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 324 )
   CASE nPaperSize == 31 // HPDF_PAPER_ENV_C6
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 114 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 162 )
   CASE nPaperSize == 32 // HPDF_PAPER_ENV_C65
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 114 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 229 )
   CASE nPaperSize == 33 // HPDF_PAPER_ENV_B4
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 250 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 353 )
   CASE nPaperSize == 34 // HPDF_PAPER_ENV_B5
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 176 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 250 )
   CASE nPaperSize == 35 // HPDF_PAPER_ENV_B6
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 176 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 125 )
   CASE nPaperSize == 36 // HPDF_PAPER_ENV_ITALY
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 110 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 230 )
   CASE nPaperSize == 37 // HPDF_PAPER_ENV_MONARCH
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 3.875 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 7.5 )
   CASE nPaperSize == 38 // HPDF_PAPER_ENV_PERSONAL
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 3 + ( 5 / 8 ) )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 6.5 )
   CASE nPaperSize == 39 // HPDF_PAPER_FANFOLD_US
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 14 + ( 7 / 8 ) )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 11 )
   CASE nPaperSize == 40 // HPDF_PAPER_FANFOLD_STD_GERMAN
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 8.5 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 12 )
   CASE nPaperSize == 41 // HPDF_PAPER_FANFOLD_LGL_GERMAN
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 8.5 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 13 )
   CASE nPaperSize == 42 // HPDF_PAPER_ISO_B4
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 250 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 353 )
   CASE nPaperSize == 43 // HPDF_PAPER_JAPANESE_POSTCARD
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 100 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 148 )
   CASE nPaperSize == 44 // HPDF_PAPER_9X11
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 9 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 11 )
   CASE nPaperSize == 45 // HPDF_PAPER_10X11
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 10 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 11 )
   CASE nPaperSize == 46 // HPDF_PAPER_15X11
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 15 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 11 )
   CASE nPaperSize == 47 // HPDF_PAPER_ENV_INVITE
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 220 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 220 )
   CASE nPaperSize == 48 // HPDF_PAPER_RESERVED_48
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 210 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 297 )
   CASE nPaperSize == 49 // HPDF_PAPER_RESERVED_49
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 210 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 297 )
   CASE nPaperSize == 50 // HPDF_PAPER_LETTER_EXTRA
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 9.5 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 12 )
   CASE nPaperSize == 51 // HPDF_PAPER_LEGAL_EXTRA
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 9.5 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 15 )
   CASE nPaperSize == 52 // HPDF_PAPER_TABLOID_EXTRA
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 11.69 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 18 )
   CASE nPaperSize == 53 // HPDF_PAPER_A4_EXTRA
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 9.27 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 12.69 )
   CASE nPaperSize == 54 // HPDF_PAPER_LETTER_TRANSVERSE
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 8.5 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 11 )
   CASE nPaperSize == 55 // HPDF_PAPER_A4_TRANSVERSE
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 210 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 297 )
   CASE nPaperSize == 56 // HPDF_PAPER_LETTER_EXTRA_TRANSVERSE
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 9.5 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 12 )
   CASE nPaperSize == 57 // HPDF_PAPER_A_PLUS
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 227 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 356 )
   CASE nPaperSize == 58 // HPDF_PAPER_B_PLUS
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 305 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 487 )
   CASE nPaperSize == 59 // HPDF_PAPER_LETTER_PLUS
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 8.5 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 12.69 )
   CASE nPaperSize == 60 // HPDF_PAPER_A4_PLUS
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 210 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 330 )
   CASE nPaperSize == 61 // HPDF_PAPER_A5_TRANSVERSE
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 148 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 210 )
   CASE nPaperSize == 62 // HPDF_PAPER_B5_TRANSVERSE
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 182 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 257 )
   CASE nPaperSize == 63 // HPDF_PAPER_A3_EXTRA
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 322 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 445 )
   CASE nPaperSize == 64 // HPDF_PAPER_A5_EXTRA
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 174 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 235 )
   CASE nPaperSize == 65 // HPDF_PAPER_B5_EXTRA
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 201 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 276 )
   CASE nPaperSize == 66 // HPDF_PAPER_A2
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 420 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 594 )
   CASE nPaperSize == 67 // HPDF_PAPER_A3_TRANSVERSE
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 297 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 420 )
   CASE nPaperSize == 68 // HPDF_PAPER_A3_EXTRA_TRANSVERSE
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 322 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 445 )
   CASE nPaperSize == 69 // HPDF_PAPER_DBL_JAPANESE_POSTCARD
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 200 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 148 )
   CASE nPaperSize == 70 // HPDF_PAPER_A6
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 105 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 148 )
   CASE nPaperSize == 71 // HPDF_PAPER_JENV_KAKU2
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 240 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 332 )
   CASE nPaperSize == 72 // HPDF_PAPER_JENV_KAKU2
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 216 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 277 )
   CASE nPaperSize == 73 // HPDF_PAPER_JENV_CHOU3
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 120 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 235 )
   CASE nPaperSize == 74 // HPDF_PAPER_JENV_CHOU4
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 90 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 205 )
   CASE nPaperSize == 75 // HPDF_PAPER_LETTER_ROTATED
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 11 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 8.5 )
   CASE nPaperSize == 76 // HPDF_PAPER_A3_ROTATED
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 420 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 297 )
   CASE nPaperSize == 77 // HPDF_PAPER_A4_ROTATED
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 297 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 210 )
   CASE nPaperSize == 78 // HPDF_PAPER_A5_ROTATED
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 210 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 148 )
   CASE nPaperSize == 79 // HPDF_PAPER_B4_JIS_ROTATED
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 364 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 257 )
   CASE nPaperSize == 80 // HPDF_PAPER_B5_JIS_ROTATED
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 257 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 182 )
   CASE nPaperSize == 81 // HPDF_PAPER_B5_JAPANESE_POSTCARD_ROTATED
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 148 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 100 )
   CASE nPaperSize == 82 // HPDF_PAPER_B5_DBL_JAPANESE_POSTCARD_ROTATED
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 148 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 200 )
   CASE nPaperSize == 83 // HPDF_PAPER_A6_ROTATED
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 148 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 105 )
   CASE nPaperSize == 84 // HPDF_PAPER_JENV_KAKU2_ROTATED
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 332 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 240 )
   CASE nPaperSize == 85 // HPDF_PAPER_JENV_KAKU3_ROTATED
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 277 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 216 )
   CASE nPaperSize == 86 // HPDF_PAPER_JENV_CHOU3_ROTATED
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 235 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 120 )
   CASE nPaperSize == 87 // HPDF_PAPER_JENV_CHOU4_ROTATED
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 205 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 90 )
   CASE nPaperSize == 88 // HPDF_PAPER_B6_JIS
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 128 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 182 )
   CASE nPaperSize == 89 // HPDF_PAPER_B6_JIS_ROTATED
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 182 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 128 )
   CASE nPaperSize == 90 // HPDF_PAPER_12X11
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 12 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 11 )
   CASE nPaperSize == 91 // HPDF_PAPER_JENV_YOU4
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 235 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 105 )
   CASE nPaperSize == 92 // HPDF_PAPER_JENV_YOU4_ROTATED
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 105 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 235 )
   CASE nPaperSize == 93 // HPDF_PAPER_P16K
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 146 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 215 )
   CASE nPaperSize == 94 // HPDF_PAPER_P32K
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 97 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 151 )
   CASE nPaperSize == 95 // HPDF_PAPER_P32KBIG
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 97 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 151 )
   CASE nPaperSize == 96 // HPDF_PAPER_PENV_1
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 102 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 165 )
   CASE nPaperSize == 97 // HPDF_PAPER_PENV_2
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 102 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 176 )
   CASE nPaperSize == 98 // HPDF_PAPER_PENV_3
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 125 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 176 )
   CASE nPaperSize == 99 // HPDF_PAPER_PENV_4
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 110 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 208 )
   CASE nPaperSize == 100 // HPDF_PAPER_PENV_5
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 110 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 220 )
   CASE nPaperSize == 101 // HPDF_PAPER_PENV_6
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 120 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 230 )
   CASE nPaperSize == 102 // HPDF_PAPER_PENV_7
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 160 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 230 )
   CASE nPaperSize == 103 // HPDF_PAPER_PENV_8
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 120 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 208 )
   CASE nPaperSize == 104 // HPDF_PAPER_PENV_9
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 229 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 324 )
   CASE nPaperSize == 105 // HPDF_PAPER_PENV_10
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 324 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 458 )
   CASE nPaperSize == 106 // HPDF_PAPER_P16K_ROTATED
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 215 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 146 )
   CASE nPaperSize == 107 // HPDF_PAPER_P32K_ROTATED
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 151 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 97 )
   CASE nPaperSize == 108 // HPDF_PAPER_P32KBIG_ROTATED
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 151 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 97 )
   CASE nPaperSize == 109 // HPDF_PAPER_PENV_1_ROTATED
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 165 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 102 )
   CASE nPaperSize == 110 // HPDF_PAPER_PENV_2_ROTATED
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 176 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 102 )
   CASE nPaperSize == 111 // HPDF_PAPER_PENV_3_ROTATED
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 176 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 125 )
   CASE nPaperSize == 112 // HPDF_PAPER_PENV_4_ROTATED
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 208 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 110 )
   CASE nPaperSize == 113 // HPDF_PAPER_PENV_5_ROTATED
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 220 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 110 )
   CASE nPaperSize == 114 // HPDF_PAPER_PENV_6_ROTATED
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 230 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 120 )
   CASE nPaperSize == 115 // HPDF_PAPER_PENV_7_ROTATED
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 230 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 160 )
   CASE nPaperSize == 116 // HPDF_PAPER_PENV_8_ROTATED
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 309 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 120 )
   CASE nPaperSize == 117 // HPDF_PAPER_PENV_9_ROTATED
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 324 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 229 )
   CASE nPaperSize == 118 // HPDF_PAPER_PENV_10_ROTATED
      _HMG_SYSDATA[ 150 ][ 4 ] := _HMG_HPDF_MM2Pixel( 458 )
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_HPDF_MM2Pixel( 324 )
   ENDCASE
   IF _HMG_SYSDATA[ 150 ][ 6 ] == 2 // landscape
      nTemp := _HMG_SYSDATA[ 150 ][ 5 ]
      _HMG_SYSDATA[ 150 ][ 5 ] := _HMG_SYSDATA[ 150 ][ 4 ]
      _HMG_SYSDATA[ 150 ][ 4 ] := nTemp
   ENDIF

   RETURN NIL

   *-12th April, 2014
   *-Author: Pablo César Arrascaeta
   *-_HMG_HPDF validation/selection fonts

FUNCTION _HMG_HPDF_SetFont( cFntName, lBold, lItalic )

   LOCAL cFntTmp := "", cFnt := "", cFntNoExt

   DEFAULT lBold := .f., lItalic := .f.

   IF HMG_Len( AllTrim( cFntName ) ) == 0
      cFnt := _HMG_SYSDATA[ 150 ][ 8 ]
      IF lBold .and. lItalic
         cFnt += '-BoldOblique'
      ELSEIF lBold
         cFnt += '-Bold'
      ELSEIF lItalic
         cFnt += '-Oblique'
      ENDIF

      RETURN cFnt
   ENDIF

   IF HMG_UPPER (cFileExt (cFntName)) == '.TTF' // load ttf font
      cFnt := _HMG_HPDF_ExistInLocal(cFntName)
      IF !Empty(cFnt)

         RETURN cFnt
      ENDIF
   ENDIF

   cFntTmp := cFileNoExt( cFntName )
   cFntNoExt := cFntTmp
   cFnt := _HMG_HPDF_SeekHaruFonts(cFntTmp,lBold,lItalic)
   IF !Empty(cFnt)

      RETURN cFnt
   ENDIF

   cFnt := _HMG_HPDF_SeekEquivalences(cFntNoExt,lBold,lItalic)
   IF !Empty(cFnt)

      RETURN cFnt
   ENDIF

   cFnt := _HMG_HPDF_SeekInLocalOptions(cFntNoExt,lBold,lItalic)
   IF !Empty(cFnt)
      cFntTmp := _HMG_HPDF_ExistInLocal(cFnt)
      IF !Empty(cFntTmp)

         RETURN cFntTmp
      ENDIF
   ENDIF

   RETURN "Helvetica"

FUNCTION _HMG_HPDF_SeekHaruFonts(cFontName,lBold,lItalic)

   LOCAL aHpdf_Font := {"Courier",;
      "Courier-Bold",;
      "Courier-Oblique",;
      "Courier-BoldOblique",;
      "Helvetica",;
      "Helvetica-Bold",;
      "Helvetica-Oblique",;
      "Helvetica-BoldOblique",;
      "Times-Roman",;
      "Times-Bold",;
      "Times-Italic",;
      "Times-BoldItalic",;
      "Symbol",;
      "ZapfDingbats"}
   LOCAL nPos, cFnt, cFont, cFntHaru

   IF (nPos := AScan(aHpdf_Font, {|cFnt| HMG_Upper(cFnt) == HMG_Upper(cFontName)})) > 0
      cFont := aHpdf_Font[nPos]
      DO CASE
      CASE "SYMBOL" $ HMG_Upper( cFont )
         cFntHaru := "Symbol"
      CASE "ZAPFDINGBATS" $ HMG_Upper( cFont )
         cFntHaru := "ZapfDingbats"
      CASE HMG_Upper(HB_USubStr(cFont,1,5)) == 'TIMES'
         cFnt := "Times"
         IF lBold .and. lItalic
            cFntHaru := cFnt + '-BoldItalic'
         ELSEIF lBold
            cFntHaru := cFnt + '-Bold'
         ELSEIF lItalic
            cFntHaru := cFnt + '-Italic'
         ELSE
            cFntHaru := cFnt + '-Roman'
         ENDIF
      OTHERWISE
         IF (nPos := HB_UAt('-',cFont)) > 0
            cFnt := HB_USubStr(cFont, 1, nPos-1)
         ENDIF
         IF lBold .and. lItalic
            cFntHaru := cFnt + '-BoldOblique'
         ELSEIF lBold
            cFntHaru := cFnt + '-Bold'
         ELSEIF lItalic
            cFntHaru := cFnt + '-Oblique'
         ENDIF
      ENDCASE
      IF lBold .or. lItalic

         RETURN cFntHaru
      ELSE

         RETURN cFont
      ENDIF
   ENDIF

   RETURN ""

FUNCTION _HMG_HPDF_SeekEquivalences(FontName,lBold,lItalic)

   LOCAL cFldWindows := GetSpecialFolder(CSIDL_FONTS)
   LOCAL cRet:=""

   DEFAULT lBold := .f., lItalic := .f.

   DO CASE
   CASE "COUR" $ HMG_Upper(FontName)
      cRet:="cour"
   CASE "TIMES" $ HMG_Upper(FontName)
      cRet:="times"
   CASE "ARIAL" $ HMG_Upper(FontName)
      cRet:="arial"
   CASE "VERDANA" $ HMG_Upper(FontName)
      cRet:="verdana"
   ENDCASE
   IF !Empty(cRet)
      cRet := cFldWindows + "\" + cRet
      IF lBold .and. lItalic
         cRet := cRet + 'bi.ttf'
      ELSEIF lBold
         cRet := cRet + 'bd.ttf'
      ELSEIF lItalic
         cRet := cRet + 'i.ttf'
      ELSE
         cRet := cRet + '.ttf'
      ENDIF
      cRet := _HMG_HPDF_ExistInLocal(cRet)
   ENDIF

   RETURN cRet

FUNCTION _HMG_HPDF_ExistInLocal(FontName)

   LOCAL cFldWindows := GetSpecialFolder(CSIDL_FONTS)
   LOCAL cFileTTF := cFileNoExt( FontName )+".ttf"
   LOCAL cFldLocal := GetCurrentFolder()
   LOCAL cFntTmp := ""

   IF File(FontName)

      RETURN FontName
   ENDIF
   IF File(cFldWindows+"\"+cFileTTF)
      cFntTmp := cFldWindows+"\"+cFileTTF
   ENDIF
   IF File(cFldLocal+"\"+cFileTTF)
      cFntTmp := cFldLocal+"\"+cFileTTF
   ENDIF

   RETURN cFntTmp

FUNCTION _HMG_HPDF_SeekInLocalOptions(FontName,lBold,lItalic)

   LOCAL aDirFnts := {}, cRet:=""
   LOCAL cFldWindows, cFileTTF

   DEFAULT lBold := .f., lItalic := .f.

   cFldWindows := GetSpecialFolder(CSIDL_FONTS)
   cFileTTF := cFileNoExt( FontName )
   aDirFnts := ASort(Directory(cFldWindows+"\"+HB_USubStr(cFileTTF,1,4)+"*.ttf"),,,{|x,y| HMG_Len(x[1]) < HMG_Len(y[1] )})
   IF Len(aDirFnts)>0
      cRet := cFldWindows + "\" + cFileNoExt( aDirFnts[1,1] )
      IF lBold .and. lItalic
         cRet := cRet + 'bi.ttf'
      ELSEIF lBold
         cRet := cRet + 'bd.ttf'
      ELSEIF lItalic
         cRet := cRet + 'i.ttf'
      ELSE
         cRet := cRet + '.ttf'
      ENDIF
   ENDIF

   RETURN cRet

FUNCTION FWriteLine( nFHandle, cString )

   IF nFHandle>3
      Fwrite( nFHandle, cString )
      Fwrite( nFHandle, chr(13) )
      Fwrite( nFHandle, chr(10) )
   ENDIF

   RETURN NIL

   *-12th April, 2014
   *-Author: Pablo César Arrascaeta
   *-HTML Table

FUNCTION HTML_TABLE_INI(nFHandle,cTit,nWidth,nPading)

   LOCAL cStyle

   DEFAULT nPading := 3
   DEFAULT nWidth := 1024

   cStyle := '<html><head>'+CRLF+;
      '<style>'+CRLF+;
      'table,th,td'+CRLF+;
      '{'+CRLF+;
      'border:1px solid black;'+CRLF+;
      'border-collapse:collapse;'+CRLF+;
      '}'+CRLF+;
      '</style>'+CRLF+;
      '</head>'+CRLF+;
      '<body>'+CRLF+;
      '<table style='+Chr(34)+'width:'+StrZero(nWidth,4,0)+'px'+Chr(34)+' cellpadding='+Chr(34)+Str(nPading,1,0)+Chr(34)+'>'
   cTit := alltrim( cTit )
   FWriteLine( nFHandle,cStyle)

   RETURN NIL

FUNCTION HTML_TABLE_LINE(nFHandle,aLin)

   LOCAL i, nLen:=Len(aLin), cLin := "<tr>"

   FOR i=1 To nLen
      cLin := cLin+CRLF+'<td '+If(aLin[i,3],' align="center" valign="middle" ',"")+'bgcolor='+Chr(34)+aLin[i,2]+Chr(34)+'>'+aLin[i,1]+'</td>'
   NEXT
   FWriteLine( nFHandle, cLin + CRLF +"</tr>" )

   RETURN NIL

FUNCTION HTML_BOLD(nFHandle,cText)

   nFHandle := nFHandle

   RETURN ("<b>"+cText+"</b>")

#pragma BEGINDUMP

#include "SET_COMPILE_HMG_UNICODE.ch"

#ifdef COMPILE_HMG_UNICODE
   #undef COMPILE_HMG_UNICODE   // Force to compile only for ANSI character set
#endif

#include "HMG_UNICODE.h"

#include <windows.h>
#include <tchar.h>
#include "hbapi.h"
#include "hpdf.h"

/*-------------------------------------------------------------------------
   The following Functions are taken from the graphics library Bos Taurus.
   Bos Taurus, (c) 2012 by Dr. Claudio Soto <srvet@adinet.com.uy>
---------------------------------------------------------------------------*/

// _bt_LoadFileFromResources (FileName, TypeResource) ---> Return hGlobalAlloc
HGLOBAL _bt_HPDF_LoadFileFromResources (TCHAR * FileName, TCHAR * TypeResource)
{
   HRSRC     hResourceData;
   HGLOBAL   hGlobalAlloc,  hGlobalResource;
   LPVOID    lpGlobalAlloc, lpGlobalResource;
   DWORD     nFileSize;

   hResourceData = FindResource (NULL, FileName, TypeResource);
   if (hResourceData == NULL)

       return NULL;

   hGlobalResource = LoadResource (NULL, hResourceData);
   if (hGlobalResource == NULL)

       return NULL;

   lpGlobalResource  = LockResource (hGlobalResource);
   if (lpGlobalResource == NULL)

       return NULL;

   nFileSize = SizeofResource (NULL, hResourceData);

   hGlobalAlloc = GlobalAlloc (GHND, nFileSize);
   if (hGlobalAlloc == NULL)
   {   FreeResource (hGlobalResource);

       return NULL;
   }

   lpGlobalAlloc = GlobalLock (hGlobalAlloc);
   memcpy (lpGlobalAlloc, lpGlobalResource, nFileSize);
   GlobalUnlock (hGlobalAlloc);

   FreeResource (hGlobalResource);

   return hGlobalAlloc;
}

// _bt_LoadFileFromDisk (FileName) ---> Return hGlobalAlloc
HGLOBAL _bt_HPDF_LoadFileFromDisk (TCHAR * FileName)
{
   HGLOBAL   hGlobalAlloc;
   LPVOID    lpGlobalAlloc;
   HANDLE    hFile;
   DWORD     nFileSize;
   DWORD     nReadByte;

   hFile = CreateFile (FileName, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
   if (hFile == INVALID_HANDLE_VALUE)

       return NULL;

   nFileSize = GetFileSize (hFile, NULL);
   if (nFileSize == INVALID_FILE_SIZE)
   {   CloseHandle (hFile);

       return NULL;
   }

   hGlobalAlloc = GlobalAlloc (GHND, nFileSize);
   if (hGlobalAlloc == NULL)
   {   CloseHandle (hFile);

       return NULL;
   }
   lpGlobalAlloc = GlobalLock (hGlobalAlloc);
   ReadFile (hFile, lpGlobalAlloc, nFileSize, &nReadByte, NULL);
   GlobalUnlock (hGlobalAlloc);

   CloseHandle (hFile);

   return hGlobalAlloc;
}

//* _HPDF_LOAD_PNG (hPDF_Doc, cFileName) ---> return Pointer   // load PNG image from Resourse or Disk

/*
typedef void*         HPDF_HANDLE;
typedef HPDF_HANDLE   HPDF_Image;   // void* ptr
typedef HPDF_HANDLE   HPDF_Doc;     // void* ptr
HPDF_LoadPngImageFromFile () ---> return image = void* ptr
HPDF_LoadPngImageFromMem  () ---> return image = void* ptr
*/

extern HPDF_Doc hb_HPDF_Doc_par (int);

HB_FUNC (_HPDF_LOAD_PNG)
{
    TCHAR       *FileName;
    HGLOBAL     hGlobalAlloc;
    LPVOID      lpGlobalAlloc;
    UINT        nSizeGlobalAlloc;
    HPDF_Doc    hpdf_Doc;
    HPDF_Image  image;

    hpdf_Doc  = (HPDF_Doc) hb_HPDF_Doc_par (1);
    FileName  = (TCHAR *)  HMG_parc (2);

    hGlobalAlloc = _bt_HPDF_LoadFileFromResources (FileName, _TEXT("PNG"));

 // if fail: find in disk
    if (hGlobalAlloc == NULL)
        hGlobalAlloc = _bt_HPDF_LoadFileFromDisk (FileName);

    if (hGlobalAlloc == NULL)
    {    hb_ret();  // return Nil

         return;
    }

    nSizeGlobalAlloc = (UINT) GlobalSize(hGlobalAlloc);
    lpGlobalAlloc = GlobalLock (hGlobalAlloc);
        image = HPDF_LoadPngImageFromMem  (hpdf_Doc, (BYTE*)lpGlobalAlloc, nSizeGlobalAlloc);
    GlobalUnlock (hGlobalAlloc);
    GlobalFree (hGlobalAlloc);

    if (image == NULL)
    {   hb_ret();  // return Nil

        return;
    }

    hb_retptr ((void *) image); // return image (void* ptr)
}

//* _HPDF_LOAD_JPG (hPDF_Doc, cFileName) ---> return Pointer   // load PNG image from Resourse or Disk

HB_FUNC (_HPDF_LOAD_JPG)
{
    TCHAR       *FileName;
    HGLOBAL     hGlobalAlloc;
    LPVOID      lpGlobalAlloc;
    UINT        nSizeGlobalAlloc;
    HPDF_Doc    hpdf_Doc;
    HPDF_Image  image;

    hpdf_Doc  = (HPDF_Doc) hb_HPDF_Doc_par (1);
    FileName  = (TCHAR *)  HMG_parc (2);

    hGlobalAlloc = _bt_HPDF_LoadFileFromResources (FileName, _TEXT("JPG"));

 // if fail: find in disk
    if (hGlobalAlloc == NULL)
        hGlobalAlloc = _bt_HPDF_LoadFileFromDisk (FileName);

    if (hGlobalAlloc == NULL)
    {    hb_ret();  // return Nil

         return;
    }

    nSizeGlobalAlloc = (UINT) GlobalSize(hGlobalAlloc);
    lpGlobalAlloc = GlobalLock (hGlobalAlloc);
        image = HPDF_LoadJpegImageFromMem (hpdf_Doc, (BYTE*)lpGlobalAlloc, nSizeGlobalAlloc);
    GlobalUnlock (hGlobalAlloc);
    GlobalFree (hGlobalAlloc);

    if (image == NULL)
    {   hb_ret();  // return Nil

        return;
    }

    hb_retptr ((void *) image); // return image (void* ptr)
}

#pragma ENDDUMP

