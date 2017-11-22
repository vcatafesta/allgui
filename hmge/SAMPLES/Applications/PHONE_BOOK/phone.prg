/*
* This program is generated by HMGCASE
* developed by Dragan Cizmarevic <dragancesu(at)gmail.com>
*/
#include <hmg.ch>

FIELD group, name, phone, adress

STATIC aGrid1 := {}, aGrid2 := {}, _start := .T., _sort := 'N', NewRec := .F.

PROCEDURE MAIN

   SET NAVIGATION EXTENDED
   SET DELETED ON

   OpenPhoneDB()

   DEFINE WINDOW MD_Form_1 ;
         AT 10, 10 ;
         WIDTH 800 ;
         HEIGHT 600 ;
         TITLE "Phone book" ;
         ICON "phone" ;
         MAIN ;
         ON INIT RefreshWinPhone( _sort ) ;
         ON RELEASE dbCloseAll()

      ON KEY ESCAPE ACTION MD_Form_1.Release

      PaintDisplayPhone()
      DisablePhone()

      @ 480, 700 BUTTON cmd2Ok  CAPTION "OK"       ACTION SaveRecPhone()   WIDTH 60  HEIGHT 25

      @ 10,  20 BUTTON cmd1Grp  CAPTION "by GROUP" ACTION sort_data( "G" ) WIDTH 100 HEIGHT 30
      @ 10, 330 BUTTON cmd1Name CAPTION "by NAME"  ACTION sort_data( "N" ) WIDTH 100 HEIGHT 30

      @ 50, 20 GRID MD_Grid_1 ;
         WIDTH 150 ;
         HEIGHT 400 ;
         HEADERS { "List" } ;
         WIDTHS { 120 } ;
         FONT "Arial" ;
         SIZE 10 ;
         ON CHANGE RefreshWinPhone2( MD_Form_1.MD_Grid_1.Value ) ;
         JUSTIFY { 0 }

      @ 50, 190 GRID MD_Grid_2 ;
         WIDTH 550 ;
         HEIGHT 400 ;
         HEADERS { "Phone", "Name", "Address", "Rec" } ;
         WIDTHS { 130, 200, 200, 0 } ;
         FONT "Arial" ;
         SIZE 10 ;
         ON DBLCLICK Det_Edit_1( "E" ) ;
         JUSTIFY { 0, 0, 0, 1 }

      @ 520,  20 BUTTON cmd2Edt CAPTION "Edit"   PICTURE "form_edit" LEFT ACTION Det_Edit_1( "E" ) WIDTH 100 HEIGHT 32
      @ 520, 130 BUTTON cmd2New CAPTION "New"    PICTURE "form_new"  LEFT ACTION Det_Edit_1( "N" ) WIDTH 100 HEIGHT 32
      @ 520, 240 BUTTON cmd2Del CAPTION "Delete" PICTURE "form_del"  LEFT ACTION Det_Edit_1( "D" ) WIDTH 100 HEIGHT 32
      @ 520, 350 BUTTON cmd2Ext CAPTION "Exit"   PICTURE "form_exit" LEFT ACTION ExitPhone()       WIDTH 100 HEIGHT 32

   END WINDOW

   CENTER WINDOW MD_Form_1
   ACTIVATE WINDOW MD_Form_1

   RETURN

PROCEDURE OpenPhoneDB()

   LOCAL alist_fld

   IF ! File ( "PHONES.dbf" )
      alist_fld := {}
      AAdd( alist_fld, { "GROUP", "C", 15, 0 } )
      AAdd( alist_fld, { "PHONE", "C", 15, 0 } )
      AAdd( alist_fld, { "NAME", "C", 25, 0 } )
      AAdd( alist_fld, { "ADRESS", "C", 25, 0 } )
      dbCreate( "PHONES", alist_fld )
   ENDIF

   IF ! File ( "P1.ntx" )
      USE PHONES
      INDEX ON GROUP TO P1 FOR !DELETED()
      USE
   ENDIF

   IF ! File ( "P2.ntx" )
      USE PHONES
      INDEX ON NAME TO P2 FOR !DELETED()
      USE
   ENDIF

   USE phones SHARED
   IF Used ()
      SET INDEX TO p1, p2
   ENDIF

   RETURN

PROCEDURE enablePhone()

   MD_Form_1.mGrupa.Enabled  := .T.
   MD_Form_1.mBroj.Enabled   := .T.
   MD_Form_1.mIme.Enabled    := .T.
   MD_Form_1.mAdresa.Enabled := .T.

   RETURN

PROCEDURE disablePhone()

   MD_Form_1.mGrupa.Enabled  := .F.
   MD_Form_1.mBroj.Enabled   := .F.
   MD_Form_1.mIme.Enabled    := .F.
   MD_Form_1.mAdresa.Enabled := .F.

   RETURN

PROCEDURE RefreshWinPhone ( _x1 )

   LOCAL _old, i

   _old := 0
   dbEval( { || _old++ }, { || Deleted() == .F. } )

   IF _old == 0
      MD_Form_1.MD_Grid_1.DeleteAllItems()

      RETURN
   ENDIF

   _old := ''

   IF _x1 == 'G'
      SET ORDER TO 1
   ELSE
      SET ORDER TO 2
   ENDIF

   aGrid1 := {}

   dbGoTop()

   DO WHILE .NOT. Eof()

      IF _x1 == 'G'

         IF _old == GROUP
            dbSkip()
            LOOP
         ENDIF

         AAdd( aGrid1, { group } )
         _old := GROUP

      ELSE

         IF _old == SubStr( name, 1, 1 )
            dbSkip()
            LOOP
         ENDIF

         AAdd( aGrid1, { SubStr( name, 1, 1 ) } )
         _old := SubStr( name, 1, 1 )

      ENDIF

      dbSkip()

   ENDDO

   MD_Form_1.MD_Grid_1.DeleteAllItems()
   FOR i = 1 TO Len( aGrid1 )
      MD_Form_1.MD_Grid_1.AddItem( aGrid1[ i ] )
   NEXT

   dbGoTop()
   MD_form_1.MD_grid_1.Refresh
   MD_form_1.MD_grid_1.SetFocus

   IF _start
      RefreshWinPhone2( 1 )
      _start = .F.
   ENDIF

   RETURN

PROCEDURE RefreshWinPhone2( _x2 )

   LOCAL _key, i

   _key := 0
   dbEval( { || _key++ }, { || Deleted() == .F. } )

   IF _key == 0 .OR. _x2 > MD_Form_1.MD_Grid_1.ItemCount
      MD_Form_1.MD_Grid_2.DeleteAllItems()

      RETURN
   ENDIF

   MD_Form_1.MD_Grid_1.Value := _x2

   _key := aGrid1[ MD_Form_1.MD_Grid_1.Value ]

   IF _sort == 'G'
      SET ORDER TO 1
   ELSE
      SET ORDER TO 2
   ENDIF

   aGrid2 := {}

   SELECT phones
   dbGoTop()
   DO WHILE .NOT. Eof()

      IF _sort == 'G'

         IF GROUP != _key[ 1 ]
            dbSkip()
            LOOP
         ENDIF

         AAdd( aGrid2, { phone, name, adress, Str( RecNo() ) } )
         dbSkip()

      ELSE

         IF SubStr( NAME, 1, 1 ) != SubStr( _key[ 1 ], 1, 1 )
            dbSkip()
            LOOP
         ENDIF

         AAdd( aGrid2, { phone, name, adress, Str( RecNo() ) } )
         dbSkip()

      ENDIF

   ENDDO

   MD_Form_1.MD_Grid_2.DeleteAllItems()
   FOR i = 1 TO Len( aGrid2 )
      MD_Form_1.MD_Grid_2.AddItem( aGrid2[ i ] )
   NEXT

   dbGoTop()
   MD_form_1.MD_grid_2.Refresh

   RETURN

FUNCTION ExitPhone()

   MD_Form_1.Release

   RETURN 0

PROCEDURE sort_data ( _xx )

   _start := .T.
   _sort := _xx

   RefreshWinPhone( _sort )

   RETURN

PROCEDURE det_edit_1 ( _tip )

   LOCAL _red, _rec

   IF _tip == 'E' .OR. _tip == 'D'

      IF MD_Form_1.MD_Grid_2.Value == 0
         MsgInfo( 'Nothing selected' )

         RETURN
      ENDIF

      _red := aGrid2[ MD_Form_1 .MD_Grid_2. Value ]
      _rec := Val( _red[ 4 ] )
      GO _rec

      EnablePhone()
   ENDIF

   IF _tip == 'D'
      DisablePhone()
      IF MsgYesNo ( "Are you sure you want to delete this record?" )
         IF FLock()
            DELETE
            UNLOCK
         ENDIF
         _rec := MD_Form_1.MD_Grid_1.Value
         RefreshWinPhone( _sort )
         RefreshWinPhone2( _rec )
      ENDIF

      RETURN
   ENDIF

   IF _tip == 'N'
      NewRecPhone()
      NewRec := .T.
      EnablePhone()
   ENDIF

   IF _tip == 'E'
      MD_Form_1.mGrupa.Value  := phones->group
      MD_Form_1.mBroj.Value   := phones->phone
      MD_Form_1.mIme.Value    := phones->name
      MD_Form_1.mAdresa.Value := phones->adress
   ENDIF

   MD_Form_1.mGrupa.SetFocus

   RETURN

PROCEDURE PaintDisplayPhone ()

   @ 460,  20 LABEL label_1 VALUE "GROUP"
   @ 460, 130 LABEL label_2 VALUE "PHONE"
   @ 460, 270 LABEL label_3 VALUE "NAME"
   @ 460, 480 LABEL label_4 VALUE "ADDRESS"

   @ 480,  20 TEXTBOX mGrupa  WIDTH 100 UPPERCASE
   @ 480, 130 TEXTBOX mBroj   WIDTH 130
   @ 480, 270 TEXTBOX mIme    WIDTH 200 UPPERCASE
   @ 480, 480 TEXTBOX mAdresa WIDTH 200 UPPERCASE

   RETURN

PROCEDURE SaveRecPhone ()

   IF MD_Form_1.mGrupa.Enabled == .F.

      RETURN
   ENDIF

   IF NewRec
      dbAppend()
   ENDIF

   RLock()

   phones->group  := LTrim(MD_Form_1.mGrupa.Value)
   phones->phone  := MD_Form_1.mBroj.Value
   phones->name   := LTrim(MD_Form_1.mIme.Value)
   phones->adress := MD_Form_1.mAdresa.Value

   dbCommit()
   dbUnlock()
   NewRec := .F.

   sort_data( 'N' )

   MD_Form_1.MD_Grid_1.Refresh
   MD_Form_1.MD_Grid_2.Refresh
   MD_Form_1.MD_Grid_2.SetFocus

   RETURN

PROCEDURE NewRecPhone()

   MD_Form_1.mGrupa.Value  := 'GROUP'
   MD_Form_1.mBroj.Value   := '123-456'
   MD_Form_1.mIme.Value    := 'FIRSTNAME LASTNAME'
   MD_Form_1.mAdresa.Value := 'ADDRESS'

   RETURN

