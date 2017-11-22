#include "MiniGUI.ch"
#include "Stock.ch"

#define STEP_INDENT         3                 // Indention step

DECLARE window wConsole

/*****
*       PRG_Fine( cFileInput, cFileOutput, nCaseFormat, aLangStrings )
*       Formatting program code
*/

PROCEDURE PRG_Fine( cFileInput, cFileOutput, nCaseFormat, aLangStrings )

   LOCAL oFile        , ;
      cMsg         , ;
      nHandle      , ;
      cString      , ;
      aTokens      , ;
      nCounter := 1

   // Open processed file

   oFile := TFileRead() : New( cFileInput )

   BEGIN Sequence

      oFile : Open()
      IF oFile : Error()
         cMsg := GetProperty( 'wConsole', 'edtConsole', 'Value' )
         cMsg += ( aLangStrings[ 19, 2 ] + ' ' + cFileInput + CRLF )
         SetProperty( 'wConsole', 'edtConsole', 'Value', cMsg )
         Do Events
         Break
      ENDIF

      IF ( ( nHandle := FCreate( cFileOutput ) ) < 0 )
         cMsg := GetProperty( 'wConsole', 'edtConsole', 'Value' )
         cMsg += ( aLangStrings[ 20, 2 ] + ' ' + cFileOutput + CRLF )
         SetProperty( 'wConsole', 'edtConsole', 'Value', cMsg )
         Do Events
         Break
      ENDIF

      // Write a title

      WriteHeader( nHandle, { ( 'Source: ' + cFileInput )                             , ;
         ''                                                    , ;
         ( 'Generate by Stock ' + DtoC( Date() ) + ' ' + Time() )  ;
         } )

      // Rowwise reading and processing

      cMsg := GetProperty( 'wConsole', 'edtConsole', 'Value' )

      DO WHILE oFile : MoreToRead()

         cString := oFile : ReadLine()

         // Process indicator tweaking: complementary show window DoMethod( 'wConsole', 'Show' )

         SetProperty( 'wConsole', 'edtConsole', 'Value', ( cMsg + ' - ' + LTrim( Str( nCounter ) ) ) )
         DoMethod( 'wConsole', 'Show' )
         Do Events
         nCounter ++

         // Empty strings and strings, starting with #define, #command, #translate,
         // #xcommand, #xtranslate write without changing

         IF ( !Empty( cString )                                                 .and. ;
               !( Upper( Left( LTrim( cString ), MINKEYWORD_LEN ) ) == '#DEFI' ) .and. ;
               !( Upper( Left( LTrim( cString ), MINKEYWORD_LEN ) ) == '#COMM' ) .and. ;
               !( Upper( Left( LTrim( cString ), MINKEYWORD_LEN ) ) == '#XCOM' ) .and. ;
               !( Upper( Left( LTrim( cString ), MINKEYWORD_LEN ) ) == '#TRAN' ) .and. ;
               !( Upper( Left( LTrim( cString ), MINKEYWORD_LEN ) ) == '#XTRA' )       ;
               )

            // String to array

            cString := LTrim( cString )
            aTokens := StrToArray( cString, ' ' )

            IF !Empty( aTokens )

               // Separate by a such delimiters as
               // brackets, '!' (function name allocation),
               // analyse and write

               aTokens := SeparateByChar( aTokens, '!' )
               aTokens := SeparateByChar( aTokens, '(' )
               aTokens := SeparateByChar( aTokens, ')' )

               Analysis( nHandle, aTokens, nCaseFormat )

            ENDIF

         ELSE
            WriteString( nHandle, cString )

         ENDIF

      ENDDO

      // Close result file

      CloseFile( nHandle )

      oFile : Close()

   End

   cMsg += CRLF
   SetProperty( 'wConsole', 'edtConsole', 'Value', cMsg )

   RETURN

   ****** End of PRG_Fine ******

   /******
   *       SeparateByChar( aTokens, cBracket ) --> aResult
   *       Separate a string by delimiter ( '(',  ')', ... )
   *       The function StrToArray() is inefficient because
   *       will lose the delimiters yoursselves
   */

STATIC FUNCTION SeparateByChar( aTokens, cBracket )

   LOCAL aResult := {}            , ;
      nLen    := Len( aTokens ), ;
      Cycle                    , ;
      cString                  , ;
      nPos

   FOR Cycle := 1 to nLen

      cString := aTokens[ Cycle ]

      DO WHILE !Empty( nPos := At( cBracket, cString ) )
         AAdd( aResult, Left( cString, ( nPos - 1 ) ) )
         AAdd( aResult, cBracket )
         cString := LTrim( Substr( cString, ( nPos + 1 ) ) )
      ENDDO

      IF !Empty( cString )
         AAdd( aResult, cString )
      ENDIF

   NEXT

   RETURN aResult

   ****** End of SeparateByChar ******

   /******
   *       ArrayToStr( aTokens ) --> cString
   *       Array to string
   */

STATIC FUNCTION ArrayToStr( aTokens )

   LOCAL nLen    := Len( aTokens ), ;
      Cycle                    , ;
      cString := ''

   FOR Cycle := 1 to nLen

      IF !Empty( aTokens[ Cycle ] )

         aTokens[ Cycle ] := AllTrim( aTokens[ Cycle ] )

         IF ( aTokens[ Cycle ] == '(' )
            cString := ( RTrim( cString ) + aTokens[ Cycle ] + ' ' )

         ELSEIF ( Left( aTokens[ Cycle ], 1 ) == ')' )

            IF ( Right( cString, 2 ) == '( ' )
               cString := ( RTrim( cString ) + aTokens[ Cycle ] + ' ' )
            ELSE
               cString += ( aTokens[ Cycle ] + ' ' )
            ENDIF

         ELSEIF ( aTokens[ Cycle ] == '!' )
            cString := ( RTrim( cString ) + ' ' + aTokens[ Cycle ] )

         ELSE
            cString += ( aTokens[ Cycle ] + ' ' )
         ENDIF

      ENDIF

   NEXT

   RETURN cString

   ****** End of ArrayToStr ******

   /******
   *       CloseFile( nHandle )
   *       Close file (masking descriptor check)
   */

STATIC PROCEDURE CloseFile( nHandle )

   IF ( nHandle > -1 )
      FClose( nHandle )
   ENDIF

   RETURN

   ****** End of CloseFile ******

   /******
   *       WriteHeader( nHandle, aStrings )
   *       Write header
   */

STATIC PROCEDURE WriteHeader( nHandle, aStrings )

   WriteString( nHandle, '/******' )
   WriteString( nHandle, '*'  )

   AEval( aStrings, { | elem | WriteString( nHandle, ( '*  ' + elem ) ) } )

   WriteString( nHandle, '*'  )
   WriteString( nHandle, '*/' )
   WriteString( nHandle, '' )

   RETURN

   ****** End of WriteHeader ******

   /******
   *       WriteString( nHandle, cString )
   *       Write string to result file
   */

STATIC PROCEDURE WriteString( nHandle, cString )

   IF ( nHandle > -1 )

      FWrite( nHandle, ( cString + HB_OSNewLine() ) )

   ENDIF

   RETURN

   ****** End of WriteString ******

   /******
   *       Analysis( nHandle, aTokens, nCaseFormat )
   *       The analysis of string array.
   *       Analysis and data output conditions:
   *       1) The key words are distinguish by first 5 symbol
   *          (set in MINKEYWORD_LEN, uncorrect detection for some words
   *          at smaller value, for example, Next replace with NextKey)
   *       2) The initial indent is zero
   *       3) The headers [Static] Procedure|Function and HB_FUNC set up zero indent
   *       4) The indent increase after If, Begin [Sequence], For, Do case|while,
   *          Switch, Define (for MiniGUI), Class, Method. And for testing into
   *          Do case|Switch indent increase doubly for allocation of branchings
   *          Case|Otherwise
   *       5) The indent is decrease after End[if|do|case|class], Next
   *       6) The indent is decrease for Case, Otherwise, Else[If] only for string,
   *          contained these commands
   */

STATIC PROCEDURE Analysis( nHandle, aTokens, nCaseFormat )

   STATIC nIndent   := 0  , ;
      lIsWinAPI := .F., ;
      lContinue := .F., ;
      nAddon    := 0
   LOCAL cFirstWord       , ;
      cSecondWord      , ;
      cString          , ;
      nPreInc     := 0 , ;
      nPostInc    := 0

   cFirstWord := Upper( AllTrim( Left( aTokens[ 1 ], MINKEYWORD_LEN ) ) )

   IF !lIsWinAPI

      // String with sequel

      cString := Right( ATail( aTokens ), 1 )

      IF !lContinue

         // The command is not proceed to next string

         IF ( cString == ';' )

            // Processed string have a sequel

            nAddon := ( Len( aTokens[ 1 ] ) + 1 )
            cString := FineSyntax( aTokens, nCaseFormat )
            WriteString( nHandle, ( Space( nIndent ) + cString ) )
            lContinue := .T.

            RETURN

         ELSE
            nAddon := 0

         ENDIF

      ELSE

         // String sequel

         lContinue := ( cString == ';' )
         cString := FineSyntax( aTokens, nCaseFormat )
         WriteString( nHandle, ( Space( nIndent + nAddon ) + cString ) )

         RETURN

      ENDIF

   ENDIF

   cString := ''

   DO CASE

   CASE ( ( cFirstWord == 'PROCE' ) .or. ;
         ( cFirstWord == 'FUNCT' ) .or. ;
         ( cFirstWord == 'HB_FU' ) .or. ;
         ( cFirstWord == '#PRAG' )      ;
         )

      // Start for procedure/function or Ñ-function section.
      // Create a comment block with the name before procedure,
      // indents are dumped.

      IF !( cFirstWord == '#PRAG' )
         AEval( aTokens, { | elem | cString += ( ' ' + elem ) } )
         WriteString( nHandle, '' )
         WriteHeader( nHandle, { cString } )
      ENDIF

      nIndent := nPreInc := 0

      // Indention setup fixed for HB_FUNC, HB_FUNC_STATIC. Herewith
      // marks the satrt of block Ñ-function (his formatting, change
      // the register of key words is not make).

      IF ( ( cFirstWord == '#PRAG' ) .or. ;
            ( cFirstWord == 'HB_FU' )      ;
            )
         nPostInc  := STEP_INDENT
         lIsWinAPI := .T.
      ELSE
         nPostInc  := 0
         lIsWinAPI := .F.
      ENDIF

   CASE ( cFirstWord == 'STATI' )
      cSecondWord := Upper( AllTrim( Left( aTokens[ 2 ], MINKEYWORD_LEN ) ) )

      IF ( ( cSecondWord == 'PROCE' ) .or. ;
            ( cSecondWord == 'FUNCT' )      ;
            )

         // Start of procedure or function. Similar to previous,
         // but intended for definition of Static Procedure|Function

         AEval( aTokens, { | elem | cString += ( ' ' + elem ) }, 2 )
         WriteString( nHandle, '' )
         WriteHeader( nHandle, { cString } )

         nIndent := nPreInc := nPostInc := 0

      ENDIF

   CASE ( ( cFirstWord == 'IF'    ) .or. ;
         ( cFirstWord == 'BEGIN' ) .or. ;
         ( cFirstWord == 'FOR'   ) .or. ;
         ( cFirstWord == 'WHILE' ) .or. ;
         ( cFirstWord == 'DEFIN' ) .or. ;
         ( cFirstWord == 'CLASS' ) .or. ;
         ( cFirstWord == 'METHO' ) .or. ;
         ( cFirstWord == '#IFDE' ) .or. ;
         ( cFirstWord == '{'     )      ;
         )

      // Cycles, control structures. MiniGUI commands and
      // preprocessor instructions are determined supementally.

      nPreInc  := 0
      nPostInc := STEP_INDENT

   CASE ( cFirstWord == 'DO' )

      cSecondWord := Upper( AllTrim( Left( aTokens[ 2 ], MINKEYWORD_LEN ) ) )

      // Cycle Do while and structure Do case

      IF ( ( cSecondWord == 'CASE'  ) .or. ;
            ( cSecondWord == 'WHILE' )      ;
            )

         nPreInc := 0

         IF ( cSecondWord == 'CASE' )
            nPostInc := ( STEP_INDENT * 2 )
         ELSE
            nPostInc := STEP_INDENT
         ENDIF

      ENDIF

   CASE ( ( cFirstWord == 'ENDIF' ) .or. ;
         ( cFirstWord == 'ENDDO' ) .or. ;
         ( cFirstWord == 'NEXT'  ) .or. ;
         ( cFirstWord == 'ENDCA' ) .or. ;
         ( cFirstWord == 'END'   ) .or. ;
         ( cFirstWord == '#ENDI' ) .or. ;
         ( cFirstWord == '}'     )      ;
         )

      // Closure of cucles and control structures, preprocessor instructions.

      IF !( cFirstWord == 'ENDCA' )          // Endcase
         nPreInc  := ( -1 ) * STEP_INDENT
      ELSE
         nPreInc  := ( -2 ) * STEP_INDENT
      ENDIF

      nPostInc := 0

   CASE ( ( cFirstWord == 'CASE'  ) .or. ;
         ( cFirstWord == 'OTHER' ) .or. ;
         ( cFirstWord == 'ELSE'  ) .or. ;
         ( cFirstWord == 'ELSEI' ) .or. ;
         ( cFirstWord == '#ELSE' )      ;
         )

      // Branchings variants.

      nPreInc  := ( -1 ) * STEP_INDENT
      nPostInc := STEP_INDENT

   ENDCASE

   nIndent += nPreInc

   IF !lIsWinAPI
      cString := FineSyntax( aTokens, nCaseFormat )

   ELSE

      // Code, belonging HB_FUNC() and HB_FUNC_STATIC() is not check for
      // key words.

      cString := ArrayToStr( aTokens )

   ENDIF

   cString := ( Space( nIndent ) + cString )

   nIndent += nPostInc

   WriteString( nHandle, cString )

   RETURN

   ****** End of Analysis ******

   /******
   *       FineSyntax( aTokens, nCaseFormat ) --> cString
   *       Formation of output string, transformation of command abbreviations
   */

STATIC FUNCTION FineSyntax( aTokens, nCaseFormat )

   MEMVAR aCommands, aPhrases
   LOCAL nLen    := Len( aTokens ), ;
      Cycle                    , ;
      cString                  , ;
      cPhrase                  , ;
      nPos

   // Processing the array of words for current string, replacement with determined in list

   FOR Cycle := 1 to nLen

      cString := Upper( aTokens[ Cycle ] )

      IF ( Len( cString ) < MINKEYWORD_LEN )
         cString := PadR( cString, MINKEYWORD_LEN )
      ENDIF

      // Word search in the array (ignore MINKEYWORD_LEN constant).
      // Reason - try to avoid of the error replacement.

      IF !Empty( nPos := AScan( aCommands, { | elem | Upper( Left( elem[ KEYWORD_LONG ], Len( cString ) ) ) == cString } ) )

         // The register change for the permited words only

         IF !aCommands[ nPos, KEYWORD_FREEZE ]

            DO CASE
            CASE ( nCaseFormat == KEYWORD_LOWER )
               aTokens[ Cycle ] := Lower( aCommands[ nPos, KEYWORD_LONG ] )

            CASE ( nCaseFormat == KEYWORD_UPPER )
               aTokens[ Cycle ] := Upper( aCommands[ nPos, KEYWORD_LONG ] )

            CASE ( nCaseFormat == KEYWORD_CAPITALIZE )
               aTokens[ Cycle ] := ( Upper( Left( aCommands[ nPos, KEYWORD_LONG ], 1 ) )    + ;
                  Lower( Substr( aCommands[ nPos, KEYWORD_LONG ], 2  ) )   ;
                  )

            OTHERWISE
               aTokens[ Cycle ] := aCommands[ nPos, KEYWORD_LONG ]

            ENDCASE

         ELSE
            aTokens[ Cycle ] := aCommands[ nPos, KEYWORD_LONG ]
         ENDIF

      ENDIF

   NEXT

   cString := ArrayToStr( aTokens )

   // Phrases replacement. Processing for phrases with exact tracing (marked * in the list)

   nLen := Len( aPhrases )

   FOR Cycle := 1 to nLen

      IF aPhrases[ Cycle, KEYWORD_FREEZE ]

         cPhrase := ( Upper( aPhrases[ Cycle, KEYWORD_LONG ] ) + ' ' )

         IF !Empty( nPos := At( cPhrase, Upper( cString ) ) )
            cString := Stuff( cString, nPos, Len( cPhrase ), ( aPhrases[ Cycle, KEYWORD_LONG ] + ' ' ) )
         ENDIF

      ENDIF

   NEXT

   RETURN cString

   ****** End of FineSyntax ******

