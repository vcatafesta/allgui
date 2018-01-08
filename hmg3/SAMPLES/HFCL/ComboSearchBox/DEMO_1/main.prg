/*

CSBox ( Combined Search Box ) try

*/

#include "hmg.ch"

*!!!!!!!!!!!!!!!!!!!!!!
#include "hfcl.ch"
*!!!!!!!!!!!!!!!!!!!!!!

PROC Main()

   aCountries := HB_ATOKENS( MEMOREAD( "Countries.lst" ),   CRLF )

   ASORT( aCountries )                    // This Array MUST be sorted

   DEFINE WINDOW frmCSBTest ;
         AT 0,0 ;
         WIDTH 550 ;
         HEIGHT 300;
         TITLE 'CSBox ( Combined Search Box ) Test' ;
         MAIN

      ON KEY ESCAPE ACTION frmCSBTest.Release

      DEFINE LABEL countries
         ROW 25
         COL 100
         WIDTH 100
         value "Countries"
      END LABEL

      DEFINE COMBOSEARCHBOX s1
         ROW 25
         COL 190
         WIDTH 200
         fontname "Courier"
         fontitalic .t.
         fontbold .t.
         fontcolor {255,255,255}
         BACKCOLOR {0,0,255}
         items acountries
         on enter msginfo(frmcsbtest.s1.value)
         anywheresearch .f.
         // dropheight 50
         additive .t.
         rowoffset 50
         coloffset 0
      END COMBOSEARCHBOX

   END WINDOW // frmCSBTest

   frmCSBTest.Center

   * !!!!!!
   * CombosearchBox already inherits all properties events
   * and methods from TextBox!!!
   * Test it uncommenting the following:
   * frmCSBTest.s1.Value := '*'
   * !!!!!!

   frmCSBTest.Activate

   RETU // Main()
