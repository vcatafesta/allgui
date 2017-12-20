
#define BUFFLEN  4096

*ีออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
*ณ Function Bopen( <cFileName>, [nAccessMode] )                 ณ
*ณ Return:   .t. if file was opened                             ณ
*ณ Assumes:  All file access will be done with the B* functions ณ
*ิออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ

FUNCTION Bopen( cFileName, nAccMode )

   DEFAULT nAccMode to FO_READ // default access mode is Read Only

   nHandle := fopen( cFileName, nAccMode )
   cLineBuffer := ''
   lFullBuff := .t.
   nTotBytes := 0
   lIsOpen := .t.

   RETURN ( nHandle != -1 )

   *ีออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
   *ณ Function BReadLine()                                         ณ
   *ณ Return:   The next line of the file read buffer              ณ
   *ณ Assumes:  The file pointer will be left as last positioned   ณ
   *ิออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ

FUNCTION BReadLine( cDelimiter )

   LOCAL ThisLine
   LOCAL nCrLfAt

   DEFAULT cDelimiter to chr( 13 ) + chr( 10 )

   DO WHILE .t.

      nCrLfAt := at( cDelimiter, cLineBuffer )

      IF empty( nCrLfAt ) .and. lFullBuff
         BDisk2Buff()
         LOOP
      ENDIF

      IF empty( nCrLfAt )
         ThisLine := strtran( cLineBuffer, chr( 26 ) )
         cLineBuffer := ''
      ELSE
         ThisLine := left( cLineBuffer, nCrLfAt - 1 )
         cLineBuffer := substr( cLineBuffer, nCrLfAt + len( cdelimiter ) )
      ENDIF

      EXIT

   ENDDO

   RETURN ThisLine

   *ีออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
   *ณ Function BDisk2Buff()                                        ณ
   *ณ Return:   .t. if there was no read error                     ณ
   *ิออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ

STATIC FUNCTION BDisk2Buff()

   STATIC cDiskBuffer := ''

   IF len( cDiskBuffer ) != BUFFLEN
      cDiskBuffer := space( BUFFLEN )
   ENDIF

   nBytesRead := fread( nHandle, @cDiskBuffer, BUFFLEN )

   nTotBytes += nBytesRead

   lFullBuff := ( nBytesRead == BUFFLEN )

   IF lFullBuff
      cLineBuffer += cDiskBuffer
   ELSE
      cLineBuffer += left( cDiskBuffer, nBytesRead )
   ENDIF

   RETURN ferror()

   *ีออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
   *ณ Function BEof()                                              ณ
   *ณ Return:   TRUE  if End of buffered file                      ณ
   *ณ           FALSE if not                                       ณ
   *ิออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ

FUNCTION BEof()

   RETURN !lFullBuff .and. len( cLineBuffer ) == 0

   *ีออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
   *ณ Function BClose()                                            ณ
   *ิออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ

FUNCTION BClose()

   IF lIsOpen
      fclose( nHandle )
      lIsOpen := .f.
   ENDIF

   RETURN FError()

   *ีออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
   *ณ Function BPosition()                                         ณ
   *ณ Returns the position of virtual file pointer                 ณ
   *ิออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ

FUNCTION BPosition()

   RETURN nTotBytes
