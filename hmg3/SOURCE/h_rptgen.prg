/*----------------------------------------------------------------------------
HMG - Harbour Windows GUI library source code

Copyright 2002-2016 Roberto Lopez <mail.box.hmg@gmail.com>
http://sites.google.com/site/hmgweb/

Head of HMG project:

2002-2012 Roberto Lopez <mail.box.hmg@gmail.com>
http://sites.google.com/site/hmgweb/

2012-2016 Dr. Claudio Soto <srvet@adinet.com.uy>
http://srvet.blogspot.com

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this software; see the file COPYING. If not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA (or
visit the web site http://www.gnu.org/).

As a special exception, you have permission for additional uses of the text
contained in this release of HMG.

The exception is that, if you link the HMG library with other
files to produce an executable, this does not by itself cause the resulting
executable to be covered by the GNU General Public License.
Your use of that executable is in no way restricted on account of linking the
HMG library code into it.

Parts of this project are based upon:

"Harbour GUI framework for Win32"
Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
Copyright 2001 Antonio Linares <alinares@fivetech.com>
www - http://www.harbour-project.org

"Harbour Project"
Copyright 1999-2009, http://www.harbour-project.org/

"WHAT32"
Copyright 2002 AJ Wos <andrwos@aust1.net>

"HWGUI"
Copyright 2001-2009 Alexander S.Kresin <alex@belacy.belgorod.su>

---------------------------------------------------------------------------*/

MEMVAR _HMG_SYSDATA

#include "hmg.ch"
#include "Fileio.ch"

* Main ************************************************************************

PROCEDURE _DefineReport ( cName )

   _HMG_SYSDATA [ 206 ] := Nil
   _HMG_SYSDATA [ 207 ] := Nil

   _HMG_SYSDATA [ 118 ] := 0
   _HMG_SYSDATA [ 119 ] := 0

   _HMG_SYSDATA [ 120 ] := 0

   _HMG_SYSDATA [ 121 ] := {}
   _HMG_SYSDATA [ 122 ] := {}

   _HMG_SYSDATA [ 123 ] := 0
   _HMG_SYSDATA [ 124 ] := 0

   _HMG_SYSDATA [ 155 ] := 0
   _HMG_SYSDATA [ 156 ] := 0

   _HMG_SYSDATA [ 157 ] := {}
   _HMG_SYSDATA [ 158 ] := {}
   _HMG_SYSDATA [ 159 ] := {}
   _HMG_SYSDATA [ 160 ] := {}
   _HMG_SYSDATA [ 126 ] := {}
   _HMG_SYSDATA [ 127 ] := 0
   _HMG_SYSDATA [161] := 'MAIN'

   IF cName <> '_TEMPLATE_'

      _HMG_SYSDATA [162] := cName

   ELSE

      cName := _HMG_SYSDATA [162]

   ENDIF

   PUBLIC &cName := {}

   RETURN

PROCEDURE _EndReport

   LOCAL cReportName
   LOCAL aMiscdata

   aMiscData := {}

   aadd ( aMiscData , _HMG_SYSDATA [ 120 ] ) // nGroupCount
   aadd ( aMiscData , _HMG_SYSDATA [ 152 ] ) // nHeadeHeight
   aadd ( aMiscData , _HMG_SYSDATA [ 153 ] ) // nDetailHeight
   aadd ( aMiscData , _HMG_SYSDATA [ 154 ] ) // nFooterHeight
   aadd ( aMiscData , _HMG_SYSDATA [ 127 ] ) // nSummaryHeight
   aadd ( aMiscData , _HMG_SYSDATA [ 124 ] ) // nGroupHeaderHeight
   aadd ( aMiscData , _HMG_SYSDATA [ 123 ] ) // nGroupFooterHeight
   aadd ( aMiscData , _HMG_SYSDATA [ 125 ] ) // xGroupExpression
   aadd ( aMiscData , _HMG_SYSDATA [ 206 ] ) // xSkipProcedure
   aadd ( aMiscData , _HMG_SYSDATA [ 207 ] ) // xEOF

   cReportName := _HMG_SYSDATA [162]

   &cReportName := { _HMG_SYSDATA [159] , _HMG_SYSDATA [160] , _HMG_SYSDATA [158] , _HMG_SYSDATA [157] , _HMG_SYSDATA [ 126 ] , _HMG_SYSDATA [ 121 ] , _HMG_SYSDATA [ 122 ] , aMiscData }

   RETURN

   * Layout **********************************************************************

PROCEDURE _BeginLayout

   _HMG_SYSDATA [161] := 'LAYOUT'

   RETURN

PROCEDURE _EndLayout

   aadd ( _HMG_SYSDATA [159] , _HMG_SYSDATA [ 155 ] )
   aadd ( _HMG_SYSDATA [159] , _HMG_SYSDATA [ 156 ] )
   aadd ( _HMG_SYSDATA [159] , _HMG_SYSDATA [ 118 ] )
   aadd ( _HMG_SYSDATA [159] , _HMG_SYSDATA [ 119 ] )

   RETURN

   * Header **********************************************************************

PROCEDURE _BeginHeader

   _HMG_SYSDATA [161] := 'HEADER'

   _HMG_SYSDATA [160] := {}

   RETURN

PROCEDURE _EndHeader

   RETURN

   * Detail **********************************************************************

PROCEDURE _BeginDetail

   _HMG_SYSDATA [161] := 'DETAIL'

   _HMG_SYSDATA [158] := {}

   RETURN

PROCEDURE _EndDetail

   RETURN

   * Footer **********************************************************************

PROCEDURE _BeginFooter

   _HMG_SYSDATA [161] := 'FOOTER'

   _HMG_SYSDATA [157] := {}

   RETURN

PROCEDURE _EndFooter

   RETURN

   * Summary **********************************************************************

PROCEDURE _BeginSummary

   _HMG_SYSDATA [161] := 'SUMMARY'

   RETURN

PROCEDURE _EndSummary

   RETURN

   * Text **********************************************************************

PROCEDURE _BeginText

   _HMG_SYSDATA[116] := ''         // Text
   _HMG_SYSDATA[431] := 0         // Row
   _HMG_SYSDATA[432] := 0         // Col
   _HMG_SYSDATA[420] := 0                  // Width
   _HMG_SYSDATA[421] := 0         // Height
   _HMG_SYSDATA[422] := 'Arial'      // FontName
   _HMG_SYSDATA[423] := 9         // FontSize
   _HMG_SYSDATA[412] := .F.      // FontBold
   _HMG_SYSDATA[413] := .F.      // FontItalic
   _HMG_SYSDATA[415] := .F.      // FontUnderLine
   _HMG_SYSDATA[414] := .F.      // FontStrikeout
   _HMG_SYSDATA[458] := { 0 , 0 , 0 }   // FontColor
   _HMG_SYSDATA[440] := .F.      // Alignment
   _HMG_SYSDATA[393] := .F.      // Alignment

   RETURN

PROCEDURE _EndText

   LOCAL aText

   aText := {           ;
      'TEXT'         , ;
      _HMG_SYSDATA[116]   , ;
      _HMG_SYSDATA[431]   , ;
      _HMG_SYSDATA[432]   , ;
      _HMG_SYSDATA[420]   , ;
      _HMG_SYSDATA[421]   , ;
      _HMG_SYSDATA[422]   , ;
      _HMG_SYSDATA[423]   , ;
      _HMG_SYSDATA[412]   , ;
      _HMG_SYSDATA[413]   , ;
      _HMG_SYSDATA[415]   , ;
      _HMG_SYSDATA[414]   , ;
      _HMG_SYSDATA[458]   , ;
      _HMG_SYSDATA[440]   , ;
      _HMG_SYSDATA[393]     ;
      }

   IF   _HMG_SYSDATA [161] == 'HEADER'

      aadd (    _HMG_SYSDATA [160] , aText )

   ELSEIF   _HMG_SYSDATA [161] == 'DETAIL'

      aadd ( _HMG_SYSDATA [158] , aText )

   ELSEIF   _HMG_SYSDATA [161] == 'FOOTER'

      aadd ( _HMG_SYSDATA [157] , aText )

   ELSEIF   _HMG_SYSDATA [161] == 'SUMMARY'

      aadd ( _HMG_SYSDATA [126] , aText )

   ELSEIF   _HMG_SYSDATA [161] == 'GROUPHEADER'

      aadd ( _HMG_SYSDATA [ 121 ] , aText )

   ELSEIF   _HMG_SYSDATA [161] == 'GROUPFOOTER'

      aadd ( _HMG_SYSDATA [ 122 ] , aText )

   ENDIF

   RETURN

   * Band Height *****************************************************************

PROCEDURE _BandHeight ( nValue )

   IF   _HMG_SYSDATA [ 161 ] == 'HEADER'

      _HMG_SYSDATA [ 152 ] := nValue

   ELSEIF   _HMG_SYSDATA [ 161 ] == 'DETAIL'

      _HMG_SYSDATA [ 153 ] := nValue

   ELSEIF   _HMG_SYSDATA [ 161 ] == 'FOOTER'

      _HMG_SYSDATA [ 154 ] := nValue

   ELSEIF   _HMG_SYSDATA [ 161 ] == 'SUMMARY'

      _HMG_SYSDATA [ 127 ] := nValue

   ELSEIF   _HMG_SYSDATA [ 161 ] == 'GROUPHEADER'

      _HMG_SYSDATA [ 124 ] := nValue

   ELSEIF   _HMG_SYSDATA [ 161 ] == 'GROUPFOOTER'

      _HMG_SYSDATA [ 123 ] := nValue

   ENDIF

   RETURN

   * Execute *********************************************************************

PROCEDURE ExecuteReport ( cReportName , lPreview , lSelect , cOutputFileName )

   LOCAL aLayout
   LOCAL aHeader
   LOCAL aDetail
   LOCAL aFooter
   LOCAL aSummary
   LOCAL aTemp
   LOCAL cPrinter
   LOCAL nDetailBandsPerPage
   LOCAL nPaperWidth
   LOCAL nPaperHeight
   LOCAL nOrientation
   LOCAL nPaperSize
   LOCAL nHeadeHeight
   LOCAL nDetailHeight
   LOCAL nFooterHeight
   LOCAL nBandSpace
   LOCAL nCurrentOffset
   LOCAL nPreviousRecNo
   LOCAL nSummaryHeight
   LOCAL aGroupHeader
   LOCAL aGroupFooter
   LOCAL nGroupHeaderHeight
   LOCAL nGroupFooterHeight
   LOCAL xGroupExpression
   LOCAL nGroupCount
   LOCAL xPreviousGroupExpression
   LOCAL lGroupStarted
   LOCAL aMiscData
   LOCAL xTemp
   LOCAL aPaper [18] [2]
   LOCAL cPdfPaperSize := ''
   LOCAL cPdfOrientation := ''
   LOCAL nOutfile
   LOCAL xSkipProcedure
   LOCAL xEOF
   LOCAL aReport, lSuccess, lTempEof

   IF _HMG_SYSDATA [ 120 ] > 1
      MsgHMGError('Only One Group Level Allowed')
   ENDIF

   _HMG_SYSDATA [ 149 ] := ''
   _HMG_SYSDATA [ 151 ] := .F.
   _HMG_SYSDATA [ 163 ] := .F.

   IF ValType ( cOutputFileName ) == 'C'

      IF ALLTRIM ( HMG_UPPER ( HB_URIGHT ( cOutputFileName , 4 ) ) ) == '.PDF'

         _HMG_SYSDATA [ 151 ] := .T.

      ELSEIF ALLTRIM ( HMG_UPPER ( HB_URIGHT ( cOutputFileName , 5 ) ) ) == '.HTML'

         _HMG_SYSDATA [ 163 ] := .T.

      ENDIF

   ENDIF

   IF _HMG_SYSDATA [ 163 ] == .T.

      _HMG_SYSDATA [ 149 ] += '<html>' + CHR(13) + CHR(10)

      _HMG_SYSDATA [ 149 ] += '<style>' + CHR(13) + CHR(10)
      _HMG_SYSDATA [ 149 ] += 'div {position:absolute}' + CHR(13) + CHR(10)
      _HMG_SYSDATA [ 149 ] += '.line { }' + CHR(13) + CHR(10)
      _HMG_SYSDATA [ 149 ] += '</style>' + CHR(13) + CHR(10)

      _HMG_SYSDATA [ 149 ] += '<body>' + CHR(13) + CHR(10)

   ENDIF

   IF _HMG_SYSDATA [ 151 ] == .T.
      aReport := PdfInit()
      pdfOpen( cOutputFileName , 200 , .t. )
   ENDIF

   IF ValType ( xSkipProcedure ) = 'U'

      * If not workarea open, cancel report execution

      IF Select() == 0

         RETURN
      ENDIF

      nPreviousRecNo := RecNo()

   ENDIF

   * Determine Print Parameters

   aTemp := __MVGET ( cReportName )

   aLayout      := aTemp [1]
   aHeader      := aTemp [2]
   aDetail      := aTemp [3]
   aFooter      := aTemp [4]
   aSummary   := aTemp [5]
   aGroupHeader   := aTemp [6]
   aGroupFooter   := aTemp [7]
   aMiscData   := aTemp [8]

   nGroupCount      := aMiscData [1]
   nHeadeHeight      := aMiscData [2]
   nDetailHeight      := aMiscData [3]
   nFooterHeight      := aMiscData [4]
   nSummaryHeight      := aMiscData [5]
   nGroupHeaderHeight   := aMiscData [6]
   nGroupFooterHeight   := aMiscData [7]
   xTemp         := aMiscData [8]
   xSkipProcedure      := aMiscData [9]
   xEOF         := aMiscData [10]

   nOrientation      := aLayout [1]
   nPaperSize      := aLayout [2]
   nPaperWidth      := aLayout [3]
   nPaperHeight      := aLayout [4]

   IF ValType ( lPreview ) <> 'L'
      lPreview := .F.
   ENDIF

   IF ValType ( lSelect ) <> 'L'
      lSelect := .F.
   ENDIF

   IF _HMG_SYSDATA [ 151 ] == .F. .AND. _HMG_SYSDATA [ 163 ] == .F.

      IF lSelect == .T.
         cPrinter := GetPrinter()
      ELSE
         cPrinter := GetDefaultPrinter()
      ENDIF

      IF Empty (cPrinter)

         RETURN
      ENDIF

   ENDIF

   * Select Printer

   IF _HMG_SYSDATA [ 151 ] == .F. .AND. _HMG_SYSDATA [ 163 ] == .F.

      IF lPreview == .T.

         IF nPaperSize == PRINTER_PAPER_USER

            SELECT PRINTER cPrinter         ;
               TO lSuccess         ;
               ORIENTATION   nOrientation   ;
               PAPERSIZE   nPaperSize   ;
               PAPERWIDTH   nPaperWidth   ;
               PAPERLENGTH   nPaperHeight   ;
               PREVIEW

         ELSE

            SELECT PRINTER cPrinter         ;
               TO lSuccess         ;
               ORIENTATION   nOrientation   ;
               PAPERSIZE   nPaperSize   ;
               PREVIEW

         ENDIF

      ELSE

         IF nPaperSize == PRINTER_PAPER_USER

            SELECT PRINTER cPrinter         ;
               TO lSuccess         ;
               ORIENTATION   nOrientation   ;
               PAPERSIZE   nPaperSize   ;
               PAPERWIDTH   nPaperWidth   ;
               PAPERLENGTH   nPaperHeight

         ELSE

            SELECT PRINTER cPrinter         ;
               TO lSuccess         ;
               ORIENTATION   nOrientation   ;
               PAPERSIZE   nPaperSize

         ENDIF

      ENDIF

   ENDIF

   * Determine Paper Dimensions in mm.

   IF npaperSize >=1 .and. nPaperSize <= 18

      /*
      aPaper [ PRINTER_PAPER_LETTER          ] := { 215.9   , 279.4  }
      aPaper [ PRINTER_PAPER_LETTERSMALL     ] := { 215.9   , 279.4  }
      aPaper [ PRINTER_PAPER_TABLOID         ] := { 279.4   , 431.8  }
      aPaper [ PRINTER_PAPER_LEDGER          ] := { 431.8   , 279.4  }
      aPaper [ PRINTER_PAPER_LEGAL           ] := { 215.9   , 355.6  }
      aPaper [ PRINTER_PAPER_STATEMENT       ] := { 139.7   , 215.9  }
      aPaper [ PRINTER_PAPER_EXECUTIVE       ] := { 184.15  , 266.7  }
      aPaper [ PRINTER_PAPER_A3              ] := { 297     , 420    }
      aPaper [ PRINTER_PAPER_A4              ] := { 210     , 297    }
      aPaper [ PRINTER_PAPER_A4SMALL         ] := { 210     , 297    }
      aPaper [ PRINTER_PAPER_A5              ] := { 148     , 210    }
      aPaper [ PRINTER_PAPER_B4              ] := { 250     , 354    }
      aPaper [ PRINTER_PAPER_B5              ] := { 182     , 257    }
      aPaper [ PRINTER_PAPER_FOLIO           ] := { 215.9   , 330.2  }
      aPaper [ PRINTER_PAPER_QUARTO          ] := { 215     , 275    }
      aPaper [ PRINTER_PAPER_10X14           ] := { 254     , 355.6  }
      aPaper [ PRINTER_PAPER_11X17           ] := { 279.4   , 431.8  }
      aPaper [ PRINTER_PAPER_NOTE            ] := { 215.9   , 279.4  }
      */

      aPaper [ 1 ] := { 215.9   , 279.4 }
      aPaper [ 2 ] := { 215.9   , 279.4 }
      aPaper [ 3 ] := { 279.4   , 431.8 }
      aPaper [ 4 ] := { 431.8   , 279.4 }
      aPaper [ 5 ] := { 215.9   , 355.6 }
      aPaper [ 6 ] := { 139.7   , 215.9 }
      aPaper [ 7 ] := { 184.15   , 266.7 }
      aPaper [ 8 ] := { 297   , 420   }
      aPaper [ 9 ] := { 210   , 297   }
      aPaper [ 10 ] := { 210   , 297   }
      aPaper [ 11 ] := { 148   , 210   }
      aPaper [ 12 ] := { 250   , 354   }
      aPaper [ 13 ] := { 182   , 257   }
      aPaper [ 14 ] := { 215.9   , 330.2   }
      aPaper [ 15 ] := { 215   , 275   }
      aPaper [ 16 ] := { 254   , 355.6   }
      aPaper [ 17 ] := { 279.4   , 431.8   }
      aPaper [ 18 ] := { 215.9   , 279.4 }

      IF    nOrientation == PRINTER_ORIENT_PORTRAIT

         nPaperWidth   := aPaper [ nPaperSize ] [ 1 ]
         npaperHeight   := aPaper [ nPaperSize ] [ 2 ]

      ELSEIF   nOrientation == PRINTER_ORIENT_LANDSCAPE

         nPaperWidth   := aPaper [ nPaperSize ] [ 2 ]
         npaperHeight   := aPaper [ nPaperSize ] [ 1 ]

      ELSE

         MsgHMGError('Report: Orientation Not Supported')

      ENDIF

   ELSE

      MsgHMGError('Report: Paper Size Not Supported')

   ENDIF

   IF _HMG_SYSDATA [ 151 ] == .T.

      * PDF Paper Size

      IF   nPaperSize == PRINTER_PAPER_LETTER

         cPdfPaperSize := "LETTER"

      ELSEIF   nPaperSize == PRINTER_PAPER_LEGAL

         cPdfPaperSize := "LEGAL"

      ELSEIF nPaperSize == PRINTER_PAPER_A4

         cPdfPaperSize := "A4"

      ELSEIF nPaperSize == PRINTER_PAPER_TABLOID

         cPdfPaperSize := "LEDGER"

      ELSEIF nPaperSize == PRINTER_PAPER_EXECUTIVE

         cPdfPaperSize := "EXECUTIVE"

      ELSEIF nPaperSize == PRINTER_PAPER_A3

         cPdfPaperSize := "A3"

      ELSEIF nPaperSize == PRINTER_PAPER_ENV_10

         cPdfPaperSize := "COM10"

      ELSEIF nPaperSize == PRINTER_PAPER_B4

         cPdfPaperSize := "JIS B4"

      ELSEIF nPaperSize == PRINTER_PAPER_B5

         cPdfPaperSize := "B5"

      ELSEIF nPaperSize == PRINTER_PAPER_P32K

         cPdfPaperSize := "JPOST"

      ELSEIF nPaperSize == PRINTER_PAPER_ENV_C5

         cPdfPaperSize := "C5"

      ELSEIF nPaperSize == PRINTER_PAPER_ENV_DL

         cPdfPaperSize := "DL"

      ELSEIF nPaperSize == PRINTER_PAPER_ENV_B5

         cPdfPaperSize := "B5"

      ELSEIF nPaperSize == PRINTER_PAPER_ENV_MONARCH

         cPdfPaperSize := "MONARCH"

      ELSE

         MsgHMGError("Report: PDF Paper Size Not Supported")

      ENDIF

      * PDF Orientation

      IF    nOrientation == PRINTER_ORIENT_PORTRAIT

         cPdfOrientation := 'P'

      ELSEIF   nOrientation == PRINTER_ORIENT_LANDSCAPE

         cPdfOrientation := 'L'

      ELSE

         MsgHMGError('Report: Orientation Not Supported')

      ENDIF

   ENDIF

   * Calculate Bands

   nBandSpace      := nPaperHeight - nHeadeHeight - nFooterHeight

   nDetailBandsPerPage   := Int ( nBandSpace / nDetailHeight )

   * Print Document

   IF nGroupCount > 0

      xGroupExpression := &(xTemp)

   ENDIF

   _HMG_SYSDATA [ 117 ] := 1

   IF _HMG_SYSDATA [ 151 ] == .F. .AND. _HMG_SYSDATA [ 163 ] == .F.

      START PRINTDOC

      ENDIF

      IF ValType ( xSkipProcedure ) = 'U'
         GO TOP
      ENDIF

      xPreviousGroupExpression := ''
      lGroupStarted := .f.

      IF ValType ( xSkipProcedure ) = 'U'
         lTempEof := Eof()
      ELSE
         lTempEof := Eval(xEof)
      ENDIF

      DO WHILE .Not. lTempEof

         IF _HMG_SYSDATA [ 163 ] == .F.

            IF _HMG_SYSDATA [ 151 ] == .T.

               pdfNewPage( cPdfPaperSize , cPdfOrientation, 6 )

            ELSE

               START PRINTPAGE

               ENDIF

               nCurrentOffset := 0

               _ProcessBand ( aHeader , 0 )

               nCurrentOffset := nHeadeHeight

               DO WHILE .t.

                  IF nGroupCount > 0

                     IF ( valtype (xPreviousGroupExpression) != valtype (xGroupExpression) ) .or. ( xPreviousGroupExpression <> xGroupExpression )

                        IF lGroupStarted

                           _ProcessBand ( aGroupFooter , nCurrentOffset )
                           nCurrentOffset += nGroupFooterHeight

                        ENDIF

                        _ProcessBand ( aGroupHeader , nCurrentOffset )
                        nCurrentOffset += nGroupHeaderHeight

                        xPreviousGroupExpression := xGroupExpression

                        lGroupStarted := .T.

                     ENDIF

                  ENDIF

                  _ProcessBand ( aDetail , nCurrentOffset )

                  nCurrentOffset += nDetailHeight

                  IF ValType ( xSkipProcedure ) = 'U'
                     SKIP
                     lTempEof := Eof()
                  ELSE
                     Eval(xSkipProcedure)
                     lTempEof := Eval(xEof)
                  ENDIF

                  IF lTempEof

                     * If group footer defined, print it.

                     IF nGroupFooterHeight > 0

                        * If group footer don't fit in the current page, print page footer,
                        * start a new page and print header first

                        IF nCurrentOffset + nGroupFooterHeight > nPaperHeight - nFooterHeight

                           nCurrentOffset := nPaperHeight - nFooterHeight
                           _ProcessBand ( aFooter , nCurrentOffset )

                           IF _HMG_SYSDATA [ 151 ] == .F.

                           END PRINTPAGE
                           START PRINTPAGE

                           ELSE

                              pdfNewPage( cPdfPaperSize , cPdfOrientation, 6 )

                           ENDIF

                           _HMG_SYSDATA [ 117 ]++

                           nCurrentOffset := 0
                           _ProcessBand ( aHeader , 0 )
                           nCurrentOffset := nHeadeHeight

                        ENDIF

                        _ProcessBand ( aGroupFooter , nCurrentOffset )
                        nCurrentOffset += nGroupFooterHeight

                     ENDIF

                     * If Summary defined, print it.

                     IF HMG_LEN ( aSummary ) > 0

                        * If summary don't fit in the current page, print footer,
                        * start a new page and print header first

                        IF nCurrentOffset + nSummaryHeight > nPaperHeight - nFooterHeight

                           nCurrentOffset := nPaperHeight - nFooterHeight
                           _ProcessBand ( aFooter , nCurrentOffset )

                           IF _HMG_SYSDATA [ 151 ] == .F.

                           END PRINTPAGE
                           START PRINTPAGE

                           ELSE

                              pdfNewPage( cPdfPaperSize , cPdfOrientation, 6 )

                           ENDIF

                           _HMG_SYSDATA [ 117 ]++

                           nCurrentOffset := 0
                           _ProcessBand ( aHeader , 0 )
                           nCurrentOffset := nHeadeHeight

                        ENDIF

                        _ProcessBand ( aSummary , nCurrentOffset )

                        EXIT

                     ENDIF

                     EXIT

                  ENDIF

                  IF nGroupCount > 0

                     xGroupExpression := &(xTemp)

                  ENDIF

                  IF nCurrentOffset + nDetailHeight > nPaperHeight - nFooterHeight

                     EXIT

                  ENDIF

               ENDDO

               nCurrentOffset := nPaperHeight - nFooterHeight

               _ProcessBand ( aFooter , nCurrentOffset )

               IF _HMG_SYSDATA [ 151 ] == .F.

               END PRINTPAGE

            ENDIF

            _HMG_SYSDATA [ 117 ]++

         ELSE

            nCurrentOffset := 0

            _ProcessBand ( aHeader , 0 )

            nCurrentOffset := nHeadeHeight

            DO WHILE .t.

               IF nGroupCount > 0

                  IF xPreviousGroupExpression <> xGroupExpression

                     IF lGroupStarted

                        _ProcessBand ( aGroupFooter , nCurrentOffset )
                        nCurrentOffset += nGroupFooterHeight

                     ENDIF

                     _ProcessBand ( aGroupHeader , nCurrentOffset )
                     nCurrentOffset += nGroupHeaderHeight

                     xPreviousGroupExpression := xGroupExpression

                     lGroupStarted := .T.

                  ENDIF

               ENDIF

               _ProcessBand ( aDetail , nCurrentOffset )

               nCurrentOffset += nDetailHeight

               IF ValType ( xSkipProcedure ) = 'U'
                  SKIP
                  lTempEof := Eof()
               ELSE
                  Eval(xSkipProcedure)
                  lTempEof := Eval(xEof)
               ENDIF

               IF lTempEof

                  * If group footer defined, print it.

                  IF nGroupFooterHeight > 0

                     _ProcessBand ( aGroupFooter , nCurrentOffset )
                     nCurrentOffset += nGroupFooterHeight

                  ENDIF

                  * If Summary defined, print it.

                  IF HMG_LEN ( aSummary ) > 0
                     _ProcessBand ( aSummary , nCurrentOffset )
                     nCurrentOffset += nSummaryHeight
                  ENDIF

                  EXIT

               ENDIF

               IF nGroupCount > 0
                  xGroupExpression := &(xTemp)
               ENDIF

            ENDDO

            _ProcessBand ( aFooter , nCurrentOffset )

         ENDIF

      ENDDO

      IF _HMG_SYSDATA [ 151 ] == .F. .AND. _HMG_SYSDATA [ 163 ] == .F.

      END PRINTDOC

   ELSEIF _HMG_SYSDATA [ 151 ] == .T.

      pdfClose()

   ELSEIF _HMG_SYSDATA [ 163 ] == .T.

      _HMG_SYSDATA [ 149 ] += '</body>' + CHR(13) + CHR(10)
      _HMG_SYSDATA [ 149 ] += '</html>' + CHR(13) + CHR(10)

      nOutfile := FCREATE( cOutputFileName , FC_NORMAL)

      FWRITE( nOutfile , _HMG_SYSDATA [ 149 ] , HMG_LEN(_HMG_SYSDATA [ 149 ]) )

      FCLOSE(nOutfile)

   ENDIF

   IF ValType ( xSkipProcedure ) = 'U'
      Go nPreviousRecNo
   ENDIF

   RETURN

   *.............................................................................*

PROCEDURE _ProcessBand ( aBand  , nOffset )

   *.............................................................................*
   LOCAL i

   FOR i := 1 To HMG_LEN ( aBand )

      _PrintObject ( aBand [i] , nOffset )

   NEXT i

   RETURN

   *.............................................................................*

PROCEDURE _PrintObject ( aObject , nOffset )

   *.............................................................................*

   IF   aObject [1] == 'TEXT'

      _PrintText( aObject , nOffset )

   ELSEIF aObject [1] == 'IMAGE'

      _PrintImage( aObject , nOffset )

   ELSEIF aObject [1] == 'LINE'

      _PrintLine( aObject , nOffset )

   ELSEIF aObject [1] == 'RECTANGLE'

      _PrintRectangle( aObject , nOffset )

   ENDIF

   RETURN

PROCEDURE _PrintText( aObject , nOffset )

   LOCAL cValue      := aObject [ 2]
   LOCAL nRow      := aObject [ 3]
   LOCAL nCol      := aObject [ 4]
   LOCAL nWidth      := aObject [ 5]
   LOCAL nHeight      := aObject [ 6]
   LOCAL cFontname      := aObject [ 7]
   LOCAL nFontSize      := aObject [ 8]
   LOCAL lFontBold      := aObject [ 9]
   LOCAL lFontItalic   := aObject [10]
   LOCAL lFontUnderLine   := aObject [11]
   LOCAL lFOntStrikeout   := aObject [12]
   LOCAL aFontColor   := aObject [13]
   LOCAL lAlignment_1    := aObject [14]
   LOCAL lAlignment_2    := aObject [15]
   LOCAL cAlignment   := ''
   LOCAL nFontStyle   := 0
   LOCAL nTextRowFix   := 5
   LOCAL cHtmlAlignment

   cValue := &cValue

   IF _HMG_SYSDATA [ 151 ] == .F. .AND. _HMG_SYSDATA [ 163 ] == .F.

      IF   lAlignment_1 == .F. .and.  lAlignment_2 == .T.

         cAlignment   := 'CENTER'

      ELSEIF   lAlignment_1 == .T. .and.  lAlignment_2 == .F.

         cAlignment   := 'RIGHT'

      ELSEIF   lAlignment_1 == .F. .and.  lAlignment_2 == .F.

         cAlignment   := ''

      ENDIF

      _HMG_PRINTER_H_MULTILINE_PRINT ( _HMG_SYSDATA [ 374 ] , nRow  + nOffset , nCol , nRow + nHeight  + nOffset , nCol + nWidth , cFontName , nFontSize , aFontColor[1] , aFontColor[2] , aFontColor[3] , cValue , lFontBold , lFontItalic , lFontUnderline , lFontStrikeout , .T. , .T. , .T. , cAlignment )

   ELSEIF _HMG_SYSDATA [ 163 ] == .T.

      IF   ValType (cValue) == "N"

         cValue := ALLTRIM(STR(cValue))

      ELSEIF   ValType (cValue) == "D"

         cValue := dtoc (cValue)

      ELSEIF   ValType (cValue) == "L"

         cValue := if ( cValue == .T. , _HMG_SYSDATA [ 371 ] [24] , _HMG_SYSDATA [ 371 ] [25] )

      ENDIF

      IF   lAlignment_1 == .F. .and.  lAlignment_2 == .T.

         cHtmlAlignment   := 'center'

      ELSEIF   lAlignment_1 == .T. .and.  lAlignment_2 == .F.

         cHtmlAlignment   := 'RIGHT'

      ELSEIF   lAlignment_1 == .F. .and.  lAlignment_2 == .F.

         cHtmlAlignment   := 'LEFT'

      ENDIF

      _HMG_SYSDATA [ 149 ] += '<div style=position:absolute;LEFT:' + ALLTRIM(STR(nCol)) +  'mm;top:' +  ALLTRIM(STR(nRow+nOffset)) + 'mm;width:' +  ALLTRIM(STR(nWidth)) + 'mm;font-size:' + ALLTRIM(STR(nFontSize)) + 'pt;font-family:"' +  cFontname + '";text-align:' + cHtmlAlignment + ';font-weight:' + if(lFontBold,'bold','normal') + ';font-style:' + if(lFontItalic,'italic','normal') + ';text-decoration:' + if(lFontUnderLine,'underline','none') + ';color:rgb(' + ALLTRIM(STR(aFontColor[1])) + ',' + ALLTRIM(STR(aFontColor[2])) + ',' +  ALLTRIM(STR(aFontColor[3])) + ');>' + cValue + '</div>' + CHR(13) + CHR(10)

   ELSEIF _HMG_SYSDATA [ 151 ] == .T.

      IF   ValType (cValue) == "N"

         cValue := ALLTRIM(STR(cValue))

      ELSEIF   ValType (cValue) == "D"

         cValue := dtoc (cValue)

      ELSEIF   ValType (cValue) == "L"

         cValue := if ( cValue == .T. , _HMG_SYSDATA [ 371 ] [24] , _HMG_SYSDATA [ 371 ] [25] )

      ENDIF

      IF   lFontBold == .f. .and. lFontItalic == .f.

         nFontStyle := 0

      ELSEIF   lFontBold == .t. .and. lFontItalic == .f.

         nFontStyle := 1

      ELSEIF   lFontBold == .f. .and. lFontItalic == .t.

         nFontStyle := 2

      ELSEIF   lFontBold == .t. .and. lFontItalic == .t.

         nFontStyle := 3

      ENDIF

      pdfSetFont( cFontname , nFontStyle , nFontSize )

      IF   lAlignment_1 == .F. .and.  lAlignment_2 == .T. // Center

         IF lFontUnderLine

            pdfAtSay ( cValue + CHR(254) , nRow + nOffset + nTextRowFix , nCol + ( nWidth - ( pdfTextWidth( cValue ) * 25.4 ) ) / 2  , 'M' )

         ELSE

            pdfAtSay ( CHR(253) + CHR(aFontColor[1]) + CHR(aFontColor[2]) + CHR(aFontColor[3]) + cValue , nRow + nOffset + nTextRowFix , nCol + ( nWidth - ( pdfTextWidth( cValue ) * 25.4 ) ) / 2  , 'M' )

         ENDIF

      ELSEIF   lAlignment_1 == .T. .and.  lAlignment_2 == .F. // RIGHT

         IF lFontUnderLine

            pdfAtSay ( cValue + CHR(254) , nRow + nOffset + nTextRowFix , nCol + nWidth - pdfTextWidth( cValue ) * 25.4 , 'M' )

         ELSE

            pdfAtSay ( CHR(253) + CHR(aFontColor[1]) + CHR(aFontColor[2]) + CHR(aFontColor[3]) + cValue , nRow + nOffset + nTextRowFix , nCol + nWidth - pdfTextWidth( cValue ) * 25.4 , 'M' )

         ENDIF

      ELSEIF   lAlignment_1 == .F. .and.  lAlignment_2 == .F. // LEFT

         IF lFontUnderLine

            pdfAtSay ( cValue + CHR(254) , nRow + nOffset + nTextRowFix , nCol , 'M' )

         ELSE

            pdfAtSay ( CHR(253) + CHR(aFontColor[1]) + CHR(aFontColor[2]) + CHR(aFontColor[3]) + cValue , nRow + nOffset + nTextRowFix , nCol , 'M' )

         ENDIF

      ENDIF

   ENDIF

   RETURN

PROCEDURE _PrintImage( aObject , nOffset )

   LOCAL cValue      := aObject [ 2]
   LOCAL nRow      := aObject [ 3]
   LOCAL nCol      := aObject [ 4]
   LOCAL nWidth      := aObject [ 5]
   LOCAL nHeight      := aObject [ 6]
   LOCAL lStretch      := aObject [ 7]

   IF _HMG_SYSDATA [ 151 ] == .F. .AND. _HMG_SYSDATA [ 163 ] == .F.

      _HMG_PRINTER_H_IMAGE ( _HMG_SYSDATA [ 374 ] , cValue , nRow + nOffset , nCol , nHeight , nWidth , .T. )

   ELSEIF _HMG_SYSDATA [ 151 ] == .T.

      IF HMG_UPPER ( HB_URIGHT( cValue , 4 ) ) == '.JPG'

         pdfImage( cValue , nRow + nOffset , nCol , "M" , nHeight , nWidth )

      ELSE

         MsgHMGError("Report: Only JPG images allowed" )

      ENDIF

   ELSEIF _HMG_SYSDATA [ 163 ] == .T.

      _HMG_SYSDATA [ 149 ] += '<div style=position:absolute;LEFT:' + ALLTRIM(STR(nCol)) + 'mm;top:' + ALLTRIM(STR(nRow+nOffset))  + 'mm;> <img src="' + cValue + '" ' + 'width=' + ALLTRIM(STR(nWidth*3.85)) + 'mm height=' + ALLTRIM(STR(nHeight*3.85)) + 'mm/> </div>' + CHR(13) + CHR(10)

   ENDIF

   RETURN

PROCEDURE _PrintLine( aObject , nOffset )

   LOCAL nFromRow      := aObject [ 2]
   LOCAL nFromCol      := aObject [ 3]
   LOCAL nToRow      := aObject [ 4]
   LOCAL nToCol      := aObject [ 5]
   LOCAL nPenWidth      := aObject [ 6]
   LOCAL aPenColor      := aObject [ 7]

   IF _HMG_SYSDATA [ 151 ] == .F. .AND. _HMG_SYSDATA [ 163 ] == .F.

      _HMG_PRINTER_H_LINE ( _HMG_SYSDATA [ 374 ] , nFromRow + nOffset , nFromCol , nToRow  + nOffset , nToCol , nPenWidth , aPenColor[1] , aPenColor[2] , aPenColor[3]  , .T. , .T. )

   ELSEIF _HMG_SYSDATA [ 151 ] == .T.

      IF nFromRow <> nToRow .and. nFromCol <> nToCol
         MsgHMGError('Report: Only horizontal and vertical lines are supported with PDF output')
      ENDIF

      pdfBox( nFromRow + nOffset , nFromCol, nToRow + nOffset + nPenWidth , nToCol , 0 , 1 , "M" , CHR(253) + CHR(aPenColor[1]) + CHR(aPenColor[2]) + CHR(aPenColor[3]) )

   ELSEIF _HMG_SYSDATA [ 163 ] == .T.

      _HMG_SYSDATA [ 149 ] += '<div style="LEFT:' + ALLTRIM(STR(nFromCol)) + 'mm;top:' +  ALLTRIM(STR(nFromRow+nOffset)) +  'mm;width:' +  ALLTRIM(STR(nToCol-nFromCol)) +  'mm;height:0mm;BORDER-STYLE:SOLID;BORDER-COLOR:' + 'rgb(' + ALLTRIM(STR(aPenColor[1])) + ',' + ALLTRIM(STR(aPenColor[2])) + ',' +  ALLTRIM(STR(aPenColor[3])) + ')' + ';BORDER-WIDTH:' + ALLTRIM(STR(nPenWidth)) + 'mm;BACKGROUND-COLOR:#FFFFFF;"><span class="line"></span></DIV>' + CHR(13) + CHR(10)

   ENDIF

   RETURN

PROCEDURE _PrintRectangle( aObject , nOffset )

   LOCAL nFromRow      := aObject [ 2]
   LOCAL nFromCol      := aObject [ 3]
   LOCAL nToRow      := aObject [ 4]
   LOCAL nToCol      := aObject [ 5]
   LOCAL nPenWidth      := aObject [ 6]
   LOCAL aPenColor      := aObject [ 7]

   IF _HMG_SYSDATA [ 151 ] == .F. .AND. _HMG_SYSDATA [ 163 ] == .F.

      _HMG_PRINTER_H_RECTANGLE ( _HMG_SYSDATA [ 374 ] , nFromRow + nOffset , nFromCol , nToRow  + nOffset , nToCol , nPenWidth , aPenColor[1] , aPenColor[2] , aPenColor[3] , .T. , .T. )

   ELSEIF _HMG_SYSDATA [ 151 ] == .T.

      pdfBox( nFromRow + nOffset , nFromCol, nFromRow + nOffset + nPenWidth , nToCol , 0 , 1 , "M" , CHR(253) + CHR(aPenColor[1]) + CHR(aPenColor[2]) + CHR(aPenColor[3]) )
      pdfBox( nToRow + nOffset , nFromCol, nToRow + nOffset + nPenWidth , nToCol , 0 , 1 , "M" , CHR(253) + CHR(aPenColor[1]) + CHR(aPenColor[2]) + CHR(aPenColor[3]) )
      pdfBox( nFromRow + nOffset , nFromCol, nToRow + nOffset , nFromCol + nPenWidth , 0 , 1 , "M" , CHR(253) + CHR(aPenColor[1]) + CHR(aPenColor[2]) + CHR(aPenColor[3]) )
      pdfBox( nFromRow + nOffset , nToCol, nToRow + nOffset , nToCol + nPenWidth , 0 , 1 , "M" , CHR(253) + CHR(aPenColor[1]) + CHR(aPenColor[2]) + CHR(aPenColor[3]) )

   ELSEIF _HMG_SYSDATA [ 163 ] == .T.

      _HMG_SYSDATA [ 149 ] += '<div style="LEFT:' + ALLTRIM(STR(nFromCol)) + 'mm;top:' +  ALLTRIM(STR(nFromRow+nOffset)) +  'mm;width:' +  ALLTRIM(STR(nToCol-nFromCol)) +  'mm;height:' + ALLTRIM(STR(nToRow-nFromRow)) + 'mm;BORDER-STYLE:SOLID;BORDER-COLOR:' + 'rgb(' + ALLTRIM(STR(aPenColor[1])) + ',' + ALLTRIM(STR(aPenColor[2])) + ',' +  ALLTRIM(STR(aPenColor[3])) + ')' + ';BORDER-WIDTH:' + ALLTRIM(STR(nPenWidth)) + 'mm;BACKGROUND-COLOR:#FFFFFF;"><span class="line"></span></DIV>' + CHR(13) + CHR(10)

   ENDIF

   RETURN

   * Line **********************************************************************

PROCEDURE _BeginLine

   _HMG_SYSDATA [ 110 ] := 0      // FromRow
   _HMG_SYSDATA [ 111 ] := 0      // FromCol
   _HMG_SYSDATA [ 112 ] := 0      // ToRow
   _HMG_SYSDATA [ 113 ] := 0      // ToCol
   _HMG_SYSDATA [ 114 ] := 1      // PenWidth
   _HMG_SYSDATA [ 115 ] := { 0 , 0 , 0 }   // PenColor

   RETURN

PROCEDURE _EndLine

   LOCAL aLine

   aLine := {           ;
      'LINE'         , ;
      _HMG_SYSDATA [ 110 ]   , ;
      _HMG_SYSDATA [ 111 ]   , ;
      _HMG_SYSDATA [ 112 ]   , ;
      _HMG_SYSDATA [ 113 ]   , ;
      _HMG_SYSDATA [ 114 ]   , ;
      _HMG_SYSDATA [ 115 ]     ;
      }

   IF   _HMG_SYSDATA [161] == 'HEADER'

      aadd (    _HMG_SYSDATA [160] , aLine )

   ELSEIF   _HMG_SYSDATA [161] == 'DETAIL'

      aadd ( _HMG_SYSDATA [158] , aLine )

   ELSEIF   _HMG_SYSDATA [161] == 'FOOTER'

      aadd ( _HMG_SYSDATA [157] , aLine )

   ELSEIF   _HMG_SYSDATA [161] == 'SUMMARY'

      aadd ( _HMG_SYSDATA [126] , aLine )

   ELSEIF   _HMG_SYSDATA [161] == 'GROUPHEADER'

      aadd ( _HMG_SYSDATA [ 121 ] , aLine )

   ELSEIF   _HMG_SYSDATA [161] == 'GROUPFOOTER'

      aadd ( _HMG_SYSDATA [ 122 ] , aLine )

   ENDIF

   RETURN

   * Image **********************************************************************

PROCEDURE _BeginImage

   _HMG_SYSDATA[434] := ''   // Value
   _HMG_SYSDATA[431] := 0    // Row
   _HMG_SYSDATA[432] := 0    // Col
   _HMG_SYSDATA[420] := 0    // Width
   _HMG_SYSDATA[421] := 0    // Height
   _HMG_SYSDATA[411] := .F.  // Stretch

   RETURN

PROCEDURE _EndImage

   LOCAL aImage

   aImage := {           ;
      'IMAGE'         , ;
      _HMG_SYSDATA[434]   , ;
      _HMG_SYSDATA[431]   , ;
      _HMG_SYSDATA[432]   , ;
      _HMG_SYSDATA[420]   , ;
      _HMG_SYSDATA[421]   , ;
      _HMG_SYSDATA[411]     ;
      }

   IF   _HMG_SYSDATA [161] == 'HEADER'

      aadd (    _HMG_SYSDATA [160] , aImage )

   ELSEIF   _HMG_SYSDATA [161] == 'DETAIL'

      aadd ( _HMG_SYSDATA [158] , aImage )

   ELSEIF   _HMG_SYSDATA [161] == 'FOOTER'

      aadd ( _HMG_SYSDATA [157] , aImage )

   ELSEIF   _HMG_SYSDATA [161] == 'SUMMARY'

      aadd ( _HMG_SYSDATA [126] , aImage )

   ELSEIF   _HMG_SYSDATA [161] == 'GROUPHEADER'

      // aadd ( _HMG_SYSDATA [ 121 ] , aLine )    // REMOVE
      aadd ( _HMG_SYSDATA [ 121 ] , aImage )      // ADD

   ELSEIF   _HMG_SYSDATA [161] == 'GROUPFOOTER'

      // aadd ( _HMG_SYSDATA [ 122 ] , aLine )    // REMOVE
      aadd ( _HMG_SYSDATA [ 122 ] , aImage )      // ADD

   ENDIF

   RETURN

   * Rectangle **********************************************************************

PROCEDURE _BeginRectangle

   _HMG_SYSDATA [ 110 ] := 0      // FromRow
   _HMG_SYSDATA [ 111 ] := 0      // FromCol
   _HMG_SYSDATA [ 112 ] := 0      // ToRow
   _HMG_SYSDATA [ 113 ] := 0      // ToCol
   _HMG_SYSDATA [ 114 ] := 1      // PenWidth
   _HMG_SYSDATA [ 115 ] := { 0 , 0 , 0 }   // PenColor

   RETURN

PROCEDURE _EndRectangle

   LOCAL aRectangle

   aRectangle := {           ;
      'RECTANGLE'      , ;
      _HMG_SYSDATA [ 110 ]   , ;
      _HMG_SYSDATA [ 111 ]   , ;
      _HMG_SYSDATA [ 112 ]   , ;
      _HMG_SYSDATA [ 113 ]   , ;
      _HMG_SYSDATA [ 114 ]   , ;
      _HMG_SYSDATA [ 115 ]     ;
      }

   IF   _HMG_SYSDATA [161] == 'HEADER'

      aadd (    _HMG_SYSDATA [160] , aRectangle )

   ELSEIF   _HMG_SYSDATA [161] == 'DETAIL'

      aadd ( _HMG_SYSDATA [158] , aRectangle )

   ELSEIF   _HMG_SYSDATA [161] == 'FOOTER'

      aadd ( _HMG_SYSDATA [157] , aRectangle )

   ELSEIF   _HMG_SYSDATA [161] == 'SUMMARY'

      aadd ( _HMG_SYSDATA [126] , aRectangle )

   ELSEIF   _HMG_SYSDATA [161] == 'GROUPHEADER'

      // aadd ( _HMG_SYSDATA [ 121 ] , aLine )      // REMOVE
      aadd ( _HMG_SYSDATA [ 121 ] , aRectangle )    // ADD

   ELSEIF   _HMG_SYSDATA [161] == 'GROUPFOOTER'

      // aadd ( _HMG_SYSDATA [ 122 ] , aLine )      // REMOVE
      aadd ( _HMG_SYSDATA [ 122 ] , aRectangle )    // ADD

   ENDIF

   RETURN

   *..............................................................................

PROCEDURE _BeginGroup()

   *..............................................................................

   _HMG_SYSDATA [161] := 'GROUP'

   _HMG_SYSDATA [ 120 ]++

   RETURN

   *..............................................................................

PROCEDURE _EndGroup()

   *..............................................................................

   RETURN

   *..............................................................................

PROCEDURE _BeginGroupHeader()

   *..............................................................................

   _HMG_SYSDATA [161] := 'GROUPHEADER'

   RETURN

   *..............................................................................

PROCEDURE _EndGroupHeader()

   *..............................................................................

   RETURN

   *..............................................................................

PROCEDURE _BeginGroupFooter()

   *..............................................................................

   _HMG_SYSDATA [161] := 'GROUPFOOTER'

   RETURN

   *..............................................................................

PROCEDURE _EndGroupFooter()

   *..............................................................................

   RETURN

   *..............................................................................

FUNCTION _dbSum( cField )

   *..............................................................................
   LOCAL nVar

   IF type ( cField ) == 'N'

      SUM &(cField) TO nVar

   ELSE

      nVar := 0

   ENDIF

   RETURN nVar

PROCEDURE _BeginData()

   RETURN

PROCEDURE _EndData()

   RETURN

