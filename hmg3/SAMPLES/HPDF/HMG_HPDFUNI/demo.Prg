﻿#include <hmg.ch>

FUNCTION Main()

   DEFINE WINDOW main at 0, 0 width 300 height 300 main title 'HMG HPDF Document'
      DEFINE BUTTON create
         ROW 100
         COL 100
         CAPTION 'HMG HPDF UNICODE'
         ACTION pdf_create()
      END BUTTON
   END WINDOW
   main.center
   main.activate

   RETURN

FUNCTION pdf_create()

   LOCAL lSuccess := .f.
   LOCAL cLB := chr( 10 )

   SELECT HPDFDOC 'HMG_HPDF_UNI.pdf' TO lSuccess papersize HPDF_PAPER_A4
   IF lSuccess
      START HPDFDOC
         START HPDFPAGE
            /* UTF8 */
            //            msginfo( str( HPDF_UseUTFEncodings( _HMG_SYSDATA[ 150 ][ 1 ] ) ) )
            //            msginfo( str( HPDF_SetCurrentEncoder( _HMG_SYSDATA[ 150 ][ 1 ], 'UTF-8' ) ) )
            //            SET HPDFDOC ENCODING TO "UTF-8"
            //            HPDF_GetFont( _HMG_SYSDATA[ 150 ][ 1 ], 'latha.ttf', "UTF-8" )
            @ 280, 10 HPDFPRINT UNICODE '@ 290, 10 HPDFPRINT "The font is பொது குறிப்புகள்" ' to 300, 300 size 12
         END HPDFPAGE
      END HPDFDOC
   ENDIF
   EXECUTE FILE 'HMG_HPDF_UNI.pdf'

   RETURN NIL
