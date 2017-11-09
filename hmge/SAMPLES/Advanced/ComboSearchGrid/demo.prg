#include <hmg.ch>
#include "combosearchgrid.ch"

FUNCTION Main

   LOCAL aItems := randomdatafill()

   DEFINE WINDOW csg at 0, 0 width 600 height 500 main title 'ComboSearchGrid - Sample'
      DEFINE LABEL namelabel
         row 10
         col 10
         width 60
         value 'Name'
         vcenteralign .t.
      END LABEL
      DEFINE COMBOSEARCHgrid name
         row 10
         col 80
         width 480
         items aItems
         headers { 'First Name', 'Last Name', 'Code' }
         widths { 200, 150, 100 }
         justify { 0, 0, 1 }
         anywheresearch .t.
         showheaders .t.
      END COMBOSEARCHgrid
      DEFINE LABEL label2
         row 40
         col 10
         width 60
         value 'Label 2'
         vcenteralign .t.
      END LABEL
      DEFINE TEXTBOX textbox2
         row 40
         col 80
         width 200
      END TEXTBOX
      DEFINE BUTTON selected
         row 40
         col 300
         caption 'Click after selecting an item'
         width 200
         action findselecteditem()
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

