#include "MiniGUI.ch"
#include "Stock.ch"

// Processing range

#define FILE_CURRENT                 1             // Current file
#define FILE_ALL                     2             // All files

DECLARE window wStock

/******
*       Formater()
*       Start code formatting
*/

PROCEDURE Formater

   MEMVAR aOptions
   LOCAL lContinue := .F.                                                               , ;
      aStrings  := GetLangStrings( GET_FORMATTER_LANG, aOptions[ OPTIONS_LANGFILE ] ), ;
      nRange    := FILE_CURRENT                                                      , ;
      nCharCase := KEYWORD_CAPITALIZE

   DEFINE WINDOW wReformat       ;
         At 132, 235            ;
         WIDTH 280              ;
         HEIGHT 275             ;
         TITLE aStrings[ 1, 2 ] ;
         ICON 'STOCK'           ;
         Modal

      @ 5, 5 Frame frmFiles           ;
         CAPTION aStrings[ 2, 2 ] ;
         WIDTH ( wReformat.Width - 20 ) ;
         HEIGHT 75                ;
         Bold                     ;
         FONTCOLOR BLUE

      @ ( wReformat.frmFiles.Row + 15 ), ( wReformat.frmFiles.Col + 10 ) ;
         RadioGroup rdgFiles                                              ;
         Options { aStrings[ 3, 2 ], aStrings[ 4, 2 ] }                   ;
         VALUE nRange                                                     ;
         WIDTH ( wReformat.frmFiles.Width - 20 )

      @ ( wReformat.frmFiles.Row + wReformat.frmFiles.Height + 5 ), wReformat.frmFiles.Col ;
         Frame frmCase                  ;
         CAPTION aStrings[ 5, 2 ]       ;
         WIDTH wReformat.frmFiles.Width ;
         HEIGHT 100                     ;
         Bold                           ;
         FONTCOLOR BLUE

      @ ( wReformat.frmCase.Row + 15 ), ( wReformat.frmCase.Col + 10 )   ;
         RadioGroup rdgCase                                               ;
         Options { aStrings[ 6, 2 ], aStrings[ 7, 2 ], aStrings[ 8, 2 ] } ;
         WIDTH wReformat.rdgFiles.Width                                   ;
         VALUE nCharCase

      @ ( wReformat.frmCase.Row + wReformat.frmCase.Height + 20 ), ;
         ( wReformat.frmCase.Col + 15 )                             ;
         Button btnGoto                                             ;
         CAPTION aStrings[ 9, 2 ]                                   ;
         ACTION { || lContinue := .T.                    , ;
         nRange := wReformat.rdgFiles.Value  , ;
         nCharCase := wReformat.rdgCase.Value, ;
         wReformat.Release                     ;
         }

      @ wReformat.btnGoto.Row, ( wReformat.btnGoto.Col + wReformat.btnGoto.Width + 30 ) ;
         Button btnCancel                                                                ;
         CAPTION _HMG_MESSAGE[ 7 ]                                                       ;
         ACTION wReformat.Release

      On key Escape of wReformat Action wReformat.Release
      On key Alt+X  of wReformat Action ReleaseAllWindows()

   END WINDOW

   CenterInside( 'wStock', 'wReformat' )
   ACTIVATE WINDOW wReformat

   IF lContinue

      // Formatting

      DEFINE WINDOW wConsole       ;
            At 132, 235             ;
            WIDTH 380               ;
            HEIGHT 350              ;
            TITLE aStrings[ 10, 2 ] ;
            ICON 'STOCK'            ;
            Modal                   ;
            ON INIT Do_Format( nRange, nCharCase, aStrings )

         @ 5, 5 EditBox edtConsole              ;
            HEIGHT ( wConsole.Height - 90 ) ;
            WIDTH ( wConsole.Width - 20 )   ;
            READONLY

         @ ( wConsole.edtConsole.Row + wConsole.edtConsole.Height + 15 ), ;
            ( wConsole.edtConsole.Col + 125 )                              ;
            Button btnOK                                                   ;
            CAPTION _HMG_MESSAGE[ 6 ]                                      ;
            ACTION wConsole.Release

         On key Alt+X  of wConsole Action ReleaseAllWindows()

      END WINDOW

      wConsole.btnOK.Enabled := .F.

      CenterInside( 'wStock', 'wConsole' )
      DisableCloseButton( GetFormHandle( 'wConsole' ) )
      ACTIVATE WINDOW wConsole

   ENDIF

   RETURN

   ****** End of Formater ******

   /******
   *       Do_Format( nRange, nCharCase, aLangStrings )
   *       Start of processing
   */

STATIC PROCEDURE Do_Format( nRange, nCharCase, aLangStrings )

   MEMVAR aOptions, aCommands, aPhrases
   LOCAL cStartTime  := Time()                                                   , ;
      cFinishTime                                                             , ;
      cDir        := ( aOptions[ OPTIONS_GETPATH ] + '\' + APPTITLE + '.SRC' ), ;
      cFileInput                                                              , ;
      cFileOutput                                                             , ;
      nCount      := wStock.grdContent.ItemCount                              , ;
      Cycle

   wConsole.edtConsole.SetFocus
   wConsole.edtConsole.Value := ( aLangStrings[ 11, 2 ] + ' ' + cStartTime + CRLF )
   Do Events

   // Folder for placing processed files

   IF !CheckPath( cDir, .T. )
      wConsole.edtConsole.Value := ( wConsole.edtConsole.Value + 'Error create ' + cDir )
      wConsole.btnOK.Enabled    := .T.

      RETURN
   ENDIF

   // Load key words lists

   PRIVATE aCommands := LoadKeywords( FILE_COMMANDS ), ;
      aPhrases  := LoadKeywords( FILE_PHRASES  )

   wConsole.edtConsole.Value := ( wConsole.edtConsole.Value   + ;
      Iif( !Empty( aCommands )    , ;
      aLangStrings[ 15, 2 ] , ;
      aLangStrings[ 16, 2 ]   ;
      )                        + ;
      CRLF                       ;
      )
   Do Events

   wConsole.edtConsole.Value := ( wConsole.edtConsole.Value  + ;
      Iif( !Empty( aPhrases )    , ;
      aLangStrings[ 17, 2 ] , ;
      aLangStrings[ 18, 2 ]   ;
      )                       + ;
      CRLF                      ;
      )
   Do Events

   // Start of processing

   IF ( nRange == FILE_CURRENT )   // Current file

      cFileInput := CurrFileName()

      IF IsPRG( cFileInput, aLangStrings )

         cFileOutput := ( cDir + '\' + cFileInput )
         cFileInput  := ( aOptions[ OPTIONS_GETPATH ] + '\' + cFileInput )
         PRG_Fine( cFileInput, cFileOutput, nCharCase, aLangStrings )

      ENDIF

   ELSE

      // All files

      FOR Cycle := 1 to nCount

         cFileInput := RTrim( wStock.grdContent.Item( Cycle )[ 1 ] )

         IF !Empty( Left( cFileInput, 1 ) )

            // Is it file?

            IF IsPRG( cFileInput, aLangStrings )
               cFileOutput := ( cDir + '\' + cFileInput )
               cFileInput  := ( aOptions[ OPTIONS_GETPATH ] + '\' + cFileInput )
               PRG_Fine( cFileInput, cFileOutput, nCharCase, aLangStrings )
            ENDIF

         ENDIF

      NEXT

   ENDIF

   cFinishTime := Time()
   wConsole.edtConsole.Value := ( wConsole.edtConsole.Value + ;
      aLangStrings[ 13, 2 ]     + ;
      ' '                       + ;
      cFinishTime + CRLF )
   wConsole.edtConsole.Value := ( wConsole.edtConsole.Value           + ;
      aLangStrings[ 14, 2 ]               + ;
      ' '                                 + ;
      ElapTime( cStartTime, cFinishTime ) + ;
      CRLF                                  ;
      )
   wConsole.btnOK.Enabled := .T.
   Do Events

   RETURN

   ****** End of Do_Format ******

   /******
   *       LoadKeywords( cFile ) --> aWords
   *       Load key words list
   */

STATIC FUNCTION LoadKeywords( cFile )

   LOCAL oFile   := TFileRead() : New( cFile ), ;
      aWords  := {}                        , ;
      cString                              , ;
      aTmp

   oFile : Open()

   IF !oFile : Error()

      DO WHILE oFile : MoreToRead()

         // Ignore empty strings and strings, starting with ';' (COMMENT_CHAR)

         IF !Empty( cString := oFile : ReadLine() )

            cString := AllTrim( cString )

            aTmp := Array( KEYWORD_ALEN )

            IF !( Left( cString, 1 ) == COMMENT_CHAR )

               // Strings, starting with symbol '*' indicate, that necessary
               // to use the word/phrase at substitution without the register changing

               IF ( Left( cString, 1 ) == '*' )

                  cString := Substr( cString, 2 )

                  aTmp[ KEYWORD_LONG   ] := cString
                  aTmp[ KEYWORD_FREEZE ] := .T.

               ELSE

                  aTmp[ KEYWORD_LONG   ] := cString
                  aTmp[ KEYWORD_FREEZE ] := .F.

               ENDIF

               // If the short word (DO, for example), increase the length

               IF ( Len( aTmp[ KEYWORD_LONG ] ) < MINKEYWORD_LEN )
                  aTmp[ KEYWORD_LONG ] := PadR( aTmp[ KEYWORD_LONG ], MINKEYWORD_LEN )
               ENDIF

               AAdd( aWords, aTmp )

            ENDIF

         ENDIF

      ENDDO

      oFile : Close()

      ASort( aWords,,, { | x, y | Upper(x[ 1 ] ) < Upper( y[ 1 ] ) } )

   ENDIF

   RETURN aWords

   ****** End of LoadKeywords ******

   /******
   *       IsPRG( cFile, aLangStrings ) --> lIsPRG
   *       Check the file extension - processing for
   *       the .PRG files only
   */

STATIC FUNCTION IsPRG( cFile, aLangStrings )

   LOCAL lIsPRG := ( Upper( Right( cFile, 4 ) ) == '.PRG' )

   IF !lIsPRG
      wConsole.edtConsole.Value := ( wConsole.edtConsole.Value + cFile + ' - ' + aLangStrings[ 13, 2 ] + CRLF )
   ELSE
      wConsole.edtConsole.Value := ( wConsole.edtConsole.Value + cFile )
   ENDIF

   Do Events

   RETURN lIsPRG

   ****** End of lIsPRG ******
