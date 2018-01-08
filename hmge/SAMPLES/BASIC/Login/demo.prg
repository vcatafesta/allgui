/*
* MINIGUI - Harbour Win32 GUI library Demo
*/

#include "minigui.ch"

STATIC logindata := {}, rank

// -------------------------------------------------------------------------- //

FUNCTION main

   SET NAVIGATION EXTENDED

   AAdd( logindata, { "ADMIN", "ADMIN", 99, 1 } )
   AAdd( logindata, { "USERNAME", "PASSWORD", 5, 50 } )
   AAdd( logindata, { "GUEST", "GUEST", 3, 100 } )

   DEFINE WINDOW sample ;
         At 0, 0 width 600 height 400 ;
         MAIN ;
         TITLE "Want to login?" ;
         ON INIT loginattempt( 2 )

      DEFINE MAIN MENU

         POPUP "&Login"
            item "Login as &Admin" action loginattempt( 1 )
            item "Login as &User" action loginattempt( 2 )
            item "Login as &Guest" action loginattempt( 3 )
            SEPARATOR
            item "E&xit" action sample.release
         END POPUP

         POPUP "&Test"
            item "Check &Permissions" action CheckPermissions()
            item "Show &User List" action ShowUserList() name UserList
         END POPUP

      END MENU

   END WINDOW

   sample.center
   sample.activate

   RETURN NIL

   // -------------------------------------------------------------------------- //

FUNCTION loginattempt( level )

   LOCAL username := logindata[ level ][ 1 ]
   LOCAL password := logindata[ level ][ 2 ]
   LOCAL maxattempt := logindata[ level ][ 3 ]
   LOCAL ok, attempts := 0

   rank := logindata[ level ][ 4 ]

   SET INTERACTIVECLOSE OFF

   DEFINE WINDOW login At 0, 0 width 220 height 155 title "User Login" modal

      DEFINE LABEL usernamelabel
         ROW 10
         COL 10
         WIDTH 80
         VALUE "Username"
      END LABEL
      DEFINE TEXTBOX username
         ROW 10
         COL 90
         WIDTH 100
         VALUE username
         uppercase .T.
      END TEXTBOX
      DEFINE LABEL passwordlabel
         ROW 40
         COL 10
         WIDTH 80
         VALUE "Password"
      END LABEL
      DEFINE TEXTBOX password
         ROW 40
         COL 90
         WIDTH 100
         password .T.
         VALUE ""
         uppercase .T.
      END TEXTBOX
      DEFINE BUTTON login
         ROW 80
         COL 45
         WIDTH 50
         CAPTION "Login"
         ACTION ( attempts++, ok := ( login.username.value == username .AND. login.password.value == password ), ;
            iif( ok, Loginok( username ), iif( attempts < maxattempt, ( MsgStop( "Not Authorized!" ), login.username.setfocus ), logincancelled( .T. ) ) ) )
      END BUTTON
      DEFINE BUTTON cancel
         ROW 80
         COL 115
         WIDTH 50
         CAPTION "Cancel"
         ACTION logincancelled( .F. )
      END BUTTON

   END WINDOW

   login.center
   login.activate

   RETURN NIL

   // -------------------------------------------------------------------------- //

STATIC FUNCTION loginok( user )

   MsgInfo( "Login Successful" )

   sample.title := "User: " + user

   login.release()

   SET INTERACTIVECLOSE QUERY MAIN

   sample.userlist.enabled := ( rank < 99 )

   RETURN NIL

   // -------------------------------------------------------------------------- //

STATIC FUNCTION logincancelled( immediate )

   IF immediate
      RELEASE WINDOW ALL
   ENDIF

   IF MsgYesNo( "Are you sure to cancel?", "Confirmation" )
      Msginfo( "GoodBye!" )

      RELEASE WINDOW ALL
   ENDIF

   RETURN NIL

   // -------------------------------------------------------------------------- //

FUNCTION CheckPermissions()

   LOCAL permission

   DO CASE
   CASE rank < 10
      permission := "ALL"
   CASE rank < 100
      permission := "READ/WRITE"
   CASE rank > 99
      permission := "READ ONLY"
   END CASE

   MsgInfo( "You have " + permission + " permissions." )

   RETURN NIL

   // -------------------------------------------------------------------------- //

FUNCTION ShowUserList()

   LOCAL i, count := Len( logindata ), list := {}

   FOR i = 1 TO count
      IF rank > 9 .AND. logindata[ i ][ 4 ] < 10
         LOOP
      ENDIF
      AAdd( list, logindata[ i ] )
   NEXT

   DEFINE WINDOW LIST ;
         At 0, 0 width 400 - if( isvista() .OR. isseven(), 0, 8 ) height 300 - if( isvista() .OR. isseven(), 0, 10 ) ;
         TITLE "User List" ;
         modal ;
         ON RELEASE if( rank < 10, savelist(), nil )

      DEFINE GRID userlist
         ROW     0
         COL     0
         WIDTH   384
         HEIGHT  262
         HEADERS { 'User', 'Password', 'Max attempt', 'Rank' }
         WIDTHS  { 110, 110, 90, 50 }
         ITEMS   list
         VALUE   1
         inplaceedit { ;
            { 'TEXTBOX', 'CHARACTER' }, ;
            { 'TEXTBOX', 'CHARACTER' }, ;
            { 'TEXTBOX', 'NUMERIC', '99' }, ;
            { 'TEXTBOX', 'NUMERIC', '999' }, ;
            }
         JUSTIFY { GRID_JTFY_LEFT, ;
            GRID_JTFY_LEFT, ;
            GRID_JTFY_RIGHT, ;
            GRID_JTFY_RIGHT }
         ALLOWEDIT ( rank < 10 )
         CELLNAVIGATION ( rank < 10 )
      END GRID

   END WINDOW

   LIST.center
   LIST.activate

   RETURN NIL

   // -------------------------------------------------------------------------- //

STATIC FUNCTION savelist()

   LOCAL i, count := LIST.userlist.itemcount

   logindata := {}
   FOR i = 1 TO count
      AAdd( logindata, { LIST.userlist.cell( i, 1 ), LIST.userlist.cell( i, 2 ), LIST.userlist.cell( i, 3 ), LIST.userlist.cell( i, 4 ) } )
   NEXT

   RETURN NIL
