#include "Set.ch"
#include "DbStruct.ch"
#include "MiniGUI.ch"
#include "Modest.ch"

// Program messages

#define MSG_EXPORT_FINISHED      'Finished export to text file '

// Quantity of symbols in row at printing

#define DESCR_CHAR_COUNT          90
#define COMMENT_CHAR_COUNT        50

DECLARE window wModest

/******
*       ExportToTXT()
*       Export of description to text file
*/

PROCEDURE ExportToTXT

   MEMVAR aStat, oEditStru
   LOCAL cFile, ;
      cText, ;
      nLen , ;
      Cycle

   // If field name is absent in the first row when it means that
   // the field's array is empty. The printing is not execute.

   IF Empty( oEditStru : aArray[ 1, DBS_NAME ] )

      RETURN
   ENDIF

   IF Empty( cFile := PutFile( { { 'Text (*.txt)'   , '*.txt' }, ;
         { 'All files (*.*)', '*.*'   }  ;
         }, 'Select file', , .T. )         ;
         )

      RETURN
   ENDIF

   IF File( cFile )
      IF !MsgYesNo( ( 'File ' + HB_OSNewLine() + cFile + ' exist.'  + HB_OSNewLine() + 'Rewrite?' ), 'Confirm', .T., , .F., .F. )

         RETURN
      ENDIF
   ENDIF

   Set( _SET_ALTFILE, cFile )
   Set( _SET_CONSOLE, .F. )
   Set( _SET_ALTERNATE, .T. )

   IF ( aStat[ 'ChStruct' ] .or. aStat[ 'ChDescript' ] )

      DO CASE
      CASE ( aStat[ 'ChStruct' ] .and. aStat[ 'ChDescript' ] )
         ?? 'Structure and description no saved!'
      CASE aStat[ 'ChStruct' ]
         ?? 'Structure no saved!'
      CASE aStat[ 'ChDescript' ]
         ?? 'Description no saved!'
      ENDCASE

      ?

   ENDIF

   // Name and description of database

   cText := AllTrim( wModest.edtGeneral.Value )

   ?? 'Date       : ' + DtoC( Date() )
   ?  'File       : ' + aStat[ 'FileName' ]
   ?  'Description: ' + Left( cText, ( DESCR_CHAR_COUNT - 13 ) )

   cText := LTrim( Substr( cText, ( DESCR_CHAR_COUNT - 12 ) ) )

   IF !Empty( cText )
      SayText( 13, cText, ( DESCR_CHAR_COUNT - 13 ) )
   ENDIF

   // Table header
   ?
   ? Replicate( '=', DESCR_CHAR_COUNT )
   ? '  #' + Space( 11 ) + 'Name' + Space( 6 ) + 'Type  Len  Dec  Comment'
   ? Replicate( '=', DESCR_CHAR_COUNT )

   // Type-out of structure with comments

   nLen := oEditStru : nLen

   FOR Cycle := 1 to nLen
      ? Str( Cycle, 3 ) + Space( 2 )

      IF ( oEditStru : aArray[ Cycle, DBS_FLAG ] == FLAG_INSERTED )
         ?? 'New    '
      ELSEIF ( oEditStru : aArray[ Cycle, DBS_FLAG ] == FLAG_DELETED )
         ?? 'Deleted'
      ELSE
         ?? Space( 7 )
      ENDIF
      ?? Space( 2 )

      ?? PadR( oEditStru : aArray[ Cycle, DBS_NAME ], 10 ) + Space( 2 )
      ?? oEditStru : aArray[ Cycle, DBS_TYPE ] + Space( 2 )
      ?? Str( oEditStru : aArray[ Cycle, DBS_LEN ], 3 ) + Space( 2 )
      ?? Str( oEditStru : aArray[ Cycle, DBS_DEC ], 3 )

      IF !Empty( cText := oEditStru : aArray[ Cycle, DBS_COMMENT ] )
         ?? Space( 2 )

         ?? Left( cText, COMMENT_CHAR_COUNT )

         cText := LTrim( Substr( cText, ( COMMENT_CHAR_COUNT + 1 ) ) )

         IF !Empty( cText )
            SayText( 39, cText, COMMENT_CHAR_COUNT )
         ENDIF

      ENDIF

   NEXT

   ? Replicate( '-', DESCR_CHAR_COUNT )
   ?

   Set( _SET_ALTERNATE, .F. )
   Set( _SET_ALTFILE, '' )
   Set( _SET_CONSOLE, .T. )

   WriteMsg( MSG_EXPORT_FINISHED + cFile )

   RETURN

   ****** End of ExportToTXT ******

   /******
   *       SayText( nIdent, cText, nLenRow )
   *       Text output
   */

STATIC PROCEDURE SayText( nIdent, cText, nLenRow )

   LOCAL nLen  := MLCount( cText, nLenRow,,, .T. ), ;
      Cycle

   FOR Cycle := 1 to nLen
      ? Space( nIdent ) + LTrim( Memoline( cText, nLenRow, Cycle,,, .T. ) )
   NEXT

   RETURN

   ****** End of SayText ******

