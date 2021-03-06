#include <hmg.ch>

MEMVAR _cAnywhereSearchStr

FUNCTION Main

   LOCAL aCountries := HB_ATOKENS( MEMOREAD( "Countries.lst" ),   CRLF )
   LOCAL aCities := HB_ATOKENS( MEMOREAD( "LargCits.lst" ),   CRLF )
   LOCAL aNationalities := HB_ATOKENS( MEMOREAD( "Nationality.lst" ),   CRLF )
   LOCAL i
   LOCAL aGrid := {}
   LOCAL cActiveControl := 'tree1'
   PUBLIC _cAnywhereSearchStr := ''

   SET NAVIGATION EXTENDED

   asort( aCountries )
   asort( aCities )
   asort( aNationalities )

   FOR i := 1 to 150
      aadd( aGrid, { aCountries[ i ], aCities[ i ], aNationalities[ i ] } )
   NEXT i
   DEFINE WINDOW main at 0, 0 width 800 height 600 main
      DEFINE LABEL textboxlabel
         ROW 10
         COL 10
         VALUE 'Enter a search string'
         AUTOSIZE .t.
         VCENTERALIGN .t.
      END LABEL
      DEFINE TEXTBOX textbox
         ROW 10
         COL 160
         ONCHANGE ( _cAnywhereSearchStr := getproperty( ThisWindow.Name, 'textbox', 'VALUE' ), ;
            setproperty( ThisWindow.Name, '_anywherelabel', 'VALUE', _cAnywhereSearchStr ), ;
            iif( empty(_HMGAnywhereSearch( cActiveControl, ThisWindow.Name, .t. )), ;
            ( setproperty( ThisWindow.Name, 'textbox', 'VALUE', _cAnywhereSearchStr ), ;
            main.textbox.caretpos := len(_cAnywhereSearchStr) ), ) ;
            )
         ON LOSTFOCUS _HMGAnywhereSearchClear()
      END TEXTBOX
      DEFINE RADIOGROUP Radio
         ROW    10
         COL    300
         WIDTH  60
         HEIGHT 20
         OPTIONS { 'tree1','list1','combo1','grid1','grid2'}
         VALUE 1
         ONCHANGE cActiveControl := main.Radio.Caption(this.value)
         TABSTOP .T.
         VISIBLE .T.
         TRANSPARENT .F.
         SPACING 10
         HORIZONTAL .T.
      END RADIOGROUP

      DEFINE TREE tree1 at 40, 10 width 200 height 200 ;
            ON GOTFOCUS ( cActiveControl := this.name, main.Radio.Value := 1 )
         node 'Parent 1'
            treeitem 'Child 1'
            treeitem 'Child 2'
            treeitem 'Child 3'
            node 'Sub-Parent 1'
               treeitem 'Child 4'
            END node
         END node
      END tree
      DEFINE LISTBOX list1
         ROW 40
         COL 210
         WIDTH 200
         HEIGHT 200
         multiselect .t.
         FONTNAME 'Arial'
         FONTSIZE 14
         ITEMS aCountries
         VALUE { 1 }
         ON GOTFOCUS ( cActiveControl := this.name, main.Radio.Value := 2 )
      END listbox
      DEFINE COMBOBOX combo1
         ROW 250
         COL 10
         WIDTH 200
         ITEMS aNationalities
         FONTNAME 'FixedSys'
         FONTSIZE 12
         VALUE 1
         ON GOTFOCUS ( cActiveControl := this.name, main.Radio.Value := 3 )
      END COMBOBOX
      DEFINE GRID grid1
         ROW 280
         COL 10
         WIDTH 350
         HEIGHT 200
         ITEMS aGrid
         HEADERS { 'Head1', 'Head2', 'Head3' }
         WIDTHS { 100, 100, 120 }
         VALUE { 1 }
         multiselect .t.
         ON GOTFOCUS ( cActiveControl := this.name, main.Radio.Value := 4 )
      END GRID
      DEFINE GRID grid2
         ROW 280
         COL 370
         WIDTH 330
         HEIGHT 200
         VIRTUAL .t.
         ITEMCOUNT 1000
         HEADERS { 'Column1', 'Column2' }
         WIDTHS { 150, 150 }
         VALUE 1
         onquerydata testquery()
         ON GOTFOCUS ( cActiveControl := this.name, main.Radio.Value := 5 )
      END GRID
      DEFINE LABEL _anywherelabel
         ROW GetProperty( ThisWindow.Name, 'HEIGHT' ) - 85
         COL 10
         WIDTH 200
         TRANSPARENT .t.
         FONTCOLOR { 255, 0, 0 }
         FONTNAME 'Arial'
         FONTSIZE 14
         FONTBOLD .t.
         AUTOSIZE .t.
      END LABEL

      DEFINE STATUSBAR
         statusitem 'Status 1'
         statusitem 'Status 2'
         statusitem 'Status 3'
      END STATUSBAR
   END WINDOW
   main.textbox.setfocus
   main.center
   main.activate

   RETURN NIL

FUNCTION testquery

   This.QueryData := 'Row' + alltrim( Str ( This.QueryRowIndex ) ) + ', ' + 'Col' + alltrim( Str ( This.QueryColIndex ) )

   RETURN NIL
