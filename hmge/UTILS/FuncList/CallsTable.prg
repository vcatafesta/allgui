/*
with GAL edition (Alexey L. Gustow <gustow33 [dog] mail.ru>)
2011.Oct.01-Nov.01
*/

#include "MiniGUI.ch"
#include "Stock.ch"

/// GAL added
#ifndef __XHARBOUR__
#xtranslate At(<a>,<b>,[<x,...>]) => hb_At(<a>,<b>,<x>)
#endif

DECLARE window wStock

MEMVAR agugu, gugupath  // GAL

/******
*       CallsTable()
*       Manipulation table for procedures/functions
*/

PROCEDURE CallsTable

   MEMVAR aOptions
   LOCAL aLangStrings := GetLangStrings( GET_CALLSTABLE_LANG, aOptions[ OPTIONS_LANGFILE ] )

   // GAL added (for export to HTML)
   PRIVATE agugu

   DEFINE WINDOW wConsole            ;
         At 132, 235                ;
         WIDTH 380                  ;
         HEIGHT 390                 ;  /* was 350 */
         TITLE aLangStrings[ 1, 2 ] ;
         ICON 'STOCK'               ;
         Modal                      ;
         ON INIT BuildList()

      @ 5, 5 EditBox edtConsole              ;
         HEIGHT ( wConsole.Height - 80 ) ;  /* was 40 */
         WIDTH ( wConsole.Width - 20 )   ;
         READONLY

      // GAL added (with what .PRG we're working now?)
      @ wConsole.edtConsole.Row + wConsole.edtConsole.Height + 5, 5 ;
         LABEL guworkConsole ;
         VALUE "" ;
         WIDTH ( wConsole.Width - 20 )

      @ wConsole.guworkConsole.Row + wConsole.guworkConsole.Height + 5, 5 ;
         ProgressBar guPbConsole ;
         Range 1, 100 ;
         VALUE 0 ;
         WIDTH ( wConsole.Width - 20 ) ;
         HEIGHT 10
      // GAL

   END WINDOW

   CenterInside( 'wStock', 'wConsole' )
   DisableCloseButton( GetFormHandle( 'wConsole' ) )

   DEFINE WINDOW wCallsTable         ;
         At 132, 235                ;
         WIDTH 500                  ;
         HEIGHT 380                 ;  /* was 350 */
         TITLE aLangStrings[ 1, 2 ] ;
         ICON 'STOCK'               ;
         Modal

      @ 5, 5 Grid grdList                                          ;
         WIDTH 480                                             ;
         HEIGHT 310                                            ;
         HEADERS { aLangStrings[ 3, 2 ], aLangStrings[ 4, 2 ], ;
         aLangStrings[ 5, 2 ], aLangStrings[ 6, 2 ]  ;
         }                                             ;
         WIDTHS { 130, 100, 130, 130 }                        ;
         FONT 'Tahoma' Size 10

      // GAL added
      @ wCallsTable.grdList.Row + wCallsTable.grdList.Height + 5, 5 ;
         Button guExpAll ;
         CAPTION "Export To HTML (all)" ;
         ACTION ExpHTML( 0, aLangStrings ) ;
         WIDTH 200

      @ wCallsTable.guExpAll.Row, ;
         wCallsTable.guExpAll.Col + wCallsTable.guExpAll.Width + 5 ;
         Button ExpNone ;
         CAPTION "Export To HTML (UNcalled only)" ;
         ACTION ExpHTML( 1, aLangStrings ) ;
         WIDTH 200

      On key Escape of wCallsTable Action wCallsTable.Release
      On key Alt+X  of wCallsTable Action ReleaseAllWindows()

   END WINDOW
   CenterInside( 'wStock', 'wCallsTable' )

   ACTIVATE WINDOW wConsole
   ACTIVATE WINDOW wCallsTable

   RETURN

   ****** End of CallsTable ******

   /*****
   *       BuildList()
   *       Array of shared procedures/functions
   */

STATIC PROCEDURE BuildList

   LOCAL nCount := wStock.grdContent.ItemCount, ;
      Cycle                                , ;
      cFile  := ''                         , ;
      cName                                , ;
      cType                                , ;
      aList  := {}

   wCallsTable.grdList.DeleteAllItems
   wCallsTable.grdList.DisableUpdate

   FOR Cycle := 1 to nCount

      cName := RTrim( wStock.grdContent.Item( Cycle )[ 1 ] )
      cType := wStock.grdContent.Item( Cycle )[ 2 ]

      IF !Empty( Left( cName, 1 ) )
         cFile := cName
      ENDIF

      /// GAL edition
      IF ( ( Upper( cType ) == 'PROCEDURE' ) .or. ;
            ( Upper( cType ) == 'FUNCTION'  ) .or. ;
            ( Upper( cType ) == 'HB_FUNC'   ) .or. ;
            ( Upper( cType ) == 'STATIC  PROCEDURE' ) .or. ;
            ( Upper( cType ) == 'STATIC  FUNCTION'  ) .or. ;
            ( Upper( cType ) == 'STATIC  HB_FUNC'   )      ;
            )

         AAdd( aList, { LTrim( cName ), cType, cFile, '' } )
      ENDIF

   NEXT

   // Fill a list

   aList := FillList( aList )

   agugu := aList // GAL added (for export to HTML)
   // because after import "aList" to grid and "ColumnsAutoFit"
   // 4th element of grid is not empty (?? but visible as empty ??)
   // (when 4th element of "aList" is empty)

   AEval( aList, { | elem | wCallsTable.grdList.AddItem( elem ) } )

   wCallsTable.grdList.ColumnsAutoFit
   wCallsTable.grdList.EnableUpdate

   wConsole.edtConsole.Value := ( wConsole.edtConsole.Value + 'Finished' + CRLF )
   wConsole.Release

   RETURN

   ****** End of BuildList ******

   /******
   *       FillList( aList ) --> aList
   *       Fill a list
   */

STATIC FUNCTION FillList( aList )

   MEMVAR aOptions
   LOCAL aFiles   := {}, ;
      aNewList := {}, ;
      aTmp          , ;
      nLen          , ;
      nLen1         , ;
      Cycle         , ;
      Cycle1        , ;
      oFile         , ;
      cString := '' , ;
      cMsg          , ;
      cName         , ;
      nPos

   // GAL added
   LOCAL cType, lLongComment, guPos

   // Sort by function & path

   ASort( aList, , , { | x, y | Upper( x[ 3 ] + x[ 1 ] ) < Upper( y[ 3 ] + y[ 1 ] ) } )
   aTmp := AClone( aList )

   // Build list of all program files

   nLen := Len( aList )

   FOR Cycle := 1 to nLen

      IF !( aList[ Cycle, 3 ] == cString )
         cString := aList[ Cycle, 3 ]
         AAdd( aFiles, cString )
      ENDIF

   NEXT

   // Functions search

   nLen  := Len( aFiles )
   nLen1 := Len( aList )

   FOR Cycle := 1 to nLen

      oFile := TFileRead() : New( aOptions[ OPTIONS_GETPATH ] + '\' + aFiles[ Cycle ] )

      oFile : Open()
      IF !oFile : Error()

         // Check proceedures/functions entry
         // for each string of program file

         wConsole.edtConsole.Value := ( wConsole.edtConsole.Value + aFiles[ Cycle ] )

         // GAL added (indicate working process - what .PRG we proceed now?)
         wConsole.guworkConsole.Value := "Processing file: " + aFiles[ Cycle ]
         wConsole.guPbConsole.Value := int( 100 * Cycle / nLen )

         cMsg := GetProperty( 'wConsole', 'edtConsole', 'Value' )

         lLongComment := .F.   // GAL added (to skip a long comment)

         guPos := 0    // GAL added

         DO WHILE oFile : MoreToRead()

            cString := oFile : ReadLine()

            SetProperty( 'wConsole', 'edtConsole', 'Value', ( cMsg + ' - ' + LTrim( Str( guPos ) ) ) )
            // GAL added
            wConsole.guworkConsole.Value := "Processing file: " + aFiles[ Cycle ] + ' - ' + LTrim( Str( guPos ) )
            DoMethod( 'wConsole', 'Show' )
            Do Events
            guPos ++

            //// GAL added (find end of long MULTI-line comment "*/")
            IF lLongComment
               IF ( "*/" $ cString )
                  lLongComment := .F.
                  cString := Iif( At( cString, "*/" ) < Len( cString ), ;
                     Substr( cString, At( cString, "*/" ) + 2 ), "" )
               ENDIF
               IF Empty( cString )
                  LOOP
               ENDIF
            ENDIF

            //// GAL added (skip comments - WHY IT WASN'T USED BEFORE ???)

            // delete leading (and ending) spaces and tabs
            cString := strtran( cString, Chr( 9 ), " " )   // tabs to spaces

            IF ( "//" $ cString )         // skip endind comments
               cString := iif( At( "//", cString ) > 1, ;
               Left( cString, At( "//", cString ) - 1 ), "" )
            ENDIF

            cString := AllTrim( cString )
            DO WHILE ( "  " $ cString )
               cString := Strtran( cString, "  ", " " )
            ENDDO

            // skip comments
            IF Left( cString, 1 ) == "*"
               LOOP
            ENDIF

            IF Left( cString, 2 ) == "//"
               LOOP
            ENDIF

            // skip "/*" - "*/" comments
            IF Left( cString, 2 ) == "/*"
               IF ( "*/" $ cString )      // if "/* .... */" into one line
                  LOOP
               ENDIF
               lLongComment := .T.
               LOOP
            ENDIF

            // GAL 20111101 - skip while lLongComment = . T.
            IF lLongComment
               LOOP
            ENDIF

            // GAL added
            cString := AllTrim( cString )
            IF Empty( cString )
               LOOP
            ENDIF

            FOR Cycle1 := 1 to nLen1

               // Search is not make in files with determined function

               //// GAL - if STATIC, don't look to other files (only to own)
               IF !( Upper( aList[ Cycle1, 3 ] ) == Upper( aFiles[ Cycle ] ) ) ;
                     .and. ( Upper( Left( aList [ Cycle1, 2 ], 6 ) ) == "STATIC" )
                  LOOP
               ENDIF

               cName := Upper( aList[ Cycle1, 1 ] )

               // GAL 20111101 - don't analyze func/proc header lines
               IF ( ;
                     ( Upper( Left( cString,  9 ) ) == "FUNCTION " ) .or. ;
                     ( Upper( Left( cString, 16 ) ) == "STATIC FUNCTION " ) .or. ;
                     ( Upper( Left( cString, 10 ) ) == "PROCEDURE " ) .or. ;
                     ( Upper( Left( cString, 17 ) ) == "STATIC PROCEDURE " ) .or. ;
                     ( Upper( Left( cString,  7 ) ) == "HB_FUNC" ) .or. ;
                     ( Upper( Left( cString, 14 ) ) == "STATIC HB_FUNC" ) ;
                     )

                  LOOP

               ENDIF

               //// GAL edition (to skip func/proc definition)
               IF ( ( ( cName + '(' ) $ Upper( cString ) ) .or. ;
                     ( ( cName + ' (' ) $ Upper( cString ) ) .or. ;
                     ( ( Upper( Left( cString, 8 ) ) == "SET KEY " ) .and. ;
                     ( Upper( Right( cString, Len( cName ) + 4 ) ) == " TO " + cName) ) ;
                     )

                  IF !Empty( nPos := AScan( aTmp, { | elem | Upper( elem[ 1 ] ) == cName } ) )

                     IF Empty( aTmp[ nPos, 4 ] )
                        aTmp[ nPos, 4 ] := aFiles[ Cycle ]
                     ELSE
                        aTmp := ASize( aTmp, ( Len( aTmp ) + 1 ) )
                        AIns( aTmp, ( nPos + 1 ) )
                        aTmp[ nPos + 1 ] := { '', '', '', aFiles[ Cycle ] }
                     ENDIF

                  ENDIF

               ENDIF

            NEXT

         ENDDO

         oFile : Close()

         cMsg += CRLF
         SetProperty( 'wConsole', 'edtConsole', 'Value', cMsg )
         // GAL added
         wConsole.guworkConsole.Value := ""

      ENDIF

   NEXT

   // Table compacting

   nLen := Len( aTmp )

   //// GAL added (for last func/proc name - if we have 2 or more calls from one file)
   cType := {}

   FOR Cycle := 1 to nLen

      //// GAL added
      IF !( Empty( aTmp[ Cycle, 1 ] ) )
         cType := { aTmp[ Cycle, 4 ] }
      ENDIF

      IF ( Cycle == 1 )
         AAdd( aNewList, { aTmp[ Cycle, 1 ], aTmp[ Cycle, 2 ], aTmp[ Cycle, 3 ], aTmp[ Cycle, 4 ] } )
      ELSE

         /*
         If !( Upper( aTmp[ Cycle, 4 ] ) == Upper( ATail( aNewList )[ 4 ] ) )
         AAdd( aNewList, { aTmp[ Cycle, 1 ], aTmp[ Cycle, 2 ], aTmp[ Cycle, 3 ], aTmp[ Cycle, 4 ] } )
         Endif
         */

         //// GAL edition (if _next_ func called from the same file as _previous_)

         IF ( Empty( aTmp[ Cycle, 1 ] ) )
            IF ( Ascan( cType, aTmp[ Cycle, 4 ] ) == 0 )
               Aadd( cType, aTmp[ Cycle, 4 ] )
               AAdd( aNewList, { aTmp[ Cycle, 1 ], aTmp[ Cycle, 2 ], aTmp[ Cycle, 3 ], aTmp[ Cycle, 4 ] } )
            ELSE
            ENDIF
         ELSE
            AAdd( aNewList, { aTmp[ Cycle, 1 ], aTmp[ Cycle, 2 ], aTmp[ Cycle, 3 ], aTmp[ Cycle, 4 ] } )
         ENDIF

      ENDIF

   NEXT

   RETURN aNewList

   ****** End of FillList ******

   /*+*+*+*
   *       ExpHTML()    by GAL
   *       Export of shared procedures/functions to HTML
   *       parameters: gupar = 0 - all, = 1 - UNcalled only
   *                   guheads = "aLangStrings" array from "CallsTable" procedure
   *+*+*+*/

STATIC FUNCTION ExpHTML( gupar, guheads )

   LOCAL ii, filehtml

   IF gupar<0 .or. gupar>1
      MsgStop( "Bad parameter! gupar=" + ltrim(str(gupar)) + ". Must be 0 or 1." )

      RETURN NIL
   ENDIF

   IF wCallsTable.grdList.ItemCount = 0
      MsgStop( "Empty list of function calls..." )

      RETURN NIL
   ENDIF

   //// gugupath = path where sources is
   IF gupar=0
      filehtml := gugupath + "\Func_Calls_All.html"
   ELSE
      filehtml := gugupath + "\Func_Calls_UnCalled.html"
   ENDIF

   SET alter to &(filehtml)
   SET alter on

   ? "<HTML>" + CRLF + ;
      "<HEAD>" + CRLF + ;
      iif( guHeads[ 5, 2 ] == "Определена", ;  // for Russian
      '<meta http-equiv="Content-Type" content="text/html; charset=windows-1251">' + CRLF, ;
      "" )
   ? "<TITLE>List of Function Calls (" + ;
      iif( gupar=0, "all", "UNcalled only" ) + ")</TITLE>" + CRLF + ;
      "</HEAD>" + CRLF
   ? "<BODY>" + CRLF
   ? "<center>Project folder: <b>" + gugupath + "</b></center>" + CRLF
   ? "<H2><center>" + ;
      "List of Function Calls (" + ;
      iif( gupar=0, "all", "UNcalled only" ) + ")</center></H2>" + CRLF
   ? "<center>" + CRLF + "<table width=90% border=1 cellspacing=0>" + CRLF
   ? "<tr><th>" + guHeads[ 5, 2 ] + "</th>" + ;            // "Defined"
      "<th>" + guHeads[ 3, 2 ] + "</th>" + ;            // "Name"
      "<th>" + guHeads[ 4, 2 ] + "</th>" + ;            // "Type"
      "<th>" + guHeads[ 6, 2 ] + "</th></tr>" + CRLF    // "Called from"

   FOR ii := 1 to len( agugu )
      IF gupar=1    // UNcalled only
         IF .not.empty( agugu[ ii, 4 ] )
            LOOP
         ENDIF
      ENDIF

      //// 20101013 - if .PRG is the same as in previous,
      ////            print '- " -' in 1st column ("Defined")
      ? "<tr>" + CRLF + ;
         "<td>" + iif( empty( agugu[ ii, 3 ] ), "&nbsp;", ;
         iif( ii>1, ;
         iif( agugu[ ii, 3 ] == agugu[ ii-1, 3 ], '&nbsp;- " - ', agugu[ ii, 3 ] ), ;
         agugu[ ii, 3 ] ) ;
         ) + "</td>" + CRLF + ;
         "<td>" + iif( empty( agugu[ ii, 1 ] ), "&nbsp;", agugu[ ii, 1 ] ) + "</td>" + CRLF + ;
         "<td>" + iif( empty( agugu[ ii, 2 ] ), "&nbsp;", agugu[ ii, 2 ] ) + "</td>" + CRLF + ;
         "<td>" + iif( empty( agugu[ ii, 4 ] ), "&nbsp;", agugu[ ii, 4 ] ) + "</td>" + CRLF + ;
         "</tr>" + CRLF

   NEXT ii

   ? "</table></center>" + CRLF + ;
      "</BODY>" + CRLF + "</HTML>" + CRLF
   ?

   SET alter off
   SET alter to

   MsgInfo( "Export " + iif( gupar=0, "(all)", "(UNcalled only)" ) + ;
      " to" + CRLF + filehtml + CRLF + "is over!" )

   // run browser

   // GAL - it must be write better!! (_NEW_ browser window - not uses now!)
   ShellExecute( 0, "open", "rundll32.exe", "url.dll,FileProtocolHandler " + filehtml, , 1 )

   RETURN NIL

   *+*+*+* End of ExpHTML *+*+*+*
