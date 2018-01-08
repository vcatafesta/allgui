#include <hmg.ch>
#include "combosearchgrid.ch"

FUNCTION Main

   LOCAL aItems := randomdatafill()

   DEFINE WINDOW csg at 0, 0 width 600 height 500 main title 'ComboSearchGrid - Sample'
      DEFINE LABEL namelabel
         ROW 10
         COL 10
         WIDTH 60
         VALUE 'Name'
         VCENTERALIGN .t.
      END LABEL
      DEFINE COMBOSEARCHGRID name
         ROW 10
         COL 80
         WIDTH 480
         ITEMS aItems
         HEADERS { 'First Name', 'Last Name', 'Code' }
         WIDTHS { 200, 150, 100 }
         JUSTIFY { 0, 0, 1 }
         anywheresearch .t.
         showheaders .t.
      END COMBOSEARCHGRID
      DEFINE LABEL label2
         ROW 40
         COL 10
         WIDTH 60
         VALUE 'Label 2'
         VCENTERALIGN .t.
      END LABEL
      DEFINE TEXTBOX textbox2
         ROW 40
         COL 80
         WIDTH 200
      END TEXTBOX
      DEFINE BUTTON selected
         ROW 40
         COL 300
         CAPTION 'Click after selecting an item'
         WIDTH 200
         ACTION findselecteditem()
      END BUTTON
   END WINDOW
   csg.center
   csg.activate

   RETURN NIL

FUNCTION findselecteditem

   LOCAL aData := {}
   LOCAL i
   LOCAL cMsg

   aData := _HMG_CSG_ItemSelected( 'csg', 'name' )
   IF len( aData ) > 0
      cMsg := '{'
      FOR i := 1 to len( aData )
         cMsg := cMsg + aData[ i ]
         IF i < len( aData )
            cMsg := cMsg + ', '
         ENDIF
      NEXT i
      cMsg := cMsg + '}'
      msginfo( 'You have selected the item - ' + cMsg )
   ENDIF

   RETURN NIL

FUNCTION randomdatafill

   LOCAL aItems := {}
   LOCAL i, j
   LOCAL c := ''
   LOCAL d := ''

   FOR i := 1 to 10000
      c := ''
      FOR j := 1 to 10
         c := c + chr( int( random( 26 ) ) + 65 )
      NEXT j
      d := ''
      FOR j := 1 to 5
         d := d + chr( int( random( 26 ) ) + 65 )
      NEXT j
      aadd( aItems, { c, d, alltrim( str( i ) ) } )
   NEXT i

   RETURN aItems
