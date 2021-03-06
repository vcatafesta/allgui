
#define BUFFLEN  4096

*ΥΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΈ
*³ Function Bopen( <cFileName>, [nAccessMode] )                 ³
*³ Return:   .t. if file was opened                             ³
*³ Assumes:  All file access will be done with the B* functions ³
*ΤΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΎ

FUNCTION Bopen( cFileName, nAccMode )

   DEFAULT nAccMode to FO_READ // default access mode is Read Only

   nHandle := fopen( cFileName, nAccMode )
   cLineBuffer := ''
   lFullBuff := .t.
   nTotBytes := 0
   lIsOpen := .t.

   RETURN ( nHandle != -1 )

   *ΥΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΈ
   *³ Function BReadLine()                                         ³
   *³ Return:   The next line of the file read buffer              ³
   *³ Assumes:  The file pointer will be left as last positioned   ³
   *ΤΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΎ

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

   *ΥΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΈ
   *³ Function BDisk2Buff()                                        ³
   *³ Return:   .t. if there was no read error                     ³
   *ΤΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΎ

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

   *ΥΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΈ
   *³ Function BEof()                                              ³
   *³ Return:   TRUE  if End of buffered file                      ³
   *³           FALSE if not                                       ³
   *ΤΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΎ

FUNCTION BEof()

   RETURN !lFullBuff .and. len( cLineBuffer ) == 0

   *ΥΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΈ
   *³ Function BClose()                                            ³
   *ΤΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΎ

FUNCTION BClose()

   IF lIsOpen
      fclose( nHandle )
      lIsOpen := .f.
   ENDIF

   RETURN FError()

   *ΥΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΈ
   *³ Function BPosition()                                         ³
   *³ Returns the position of virtual file pointer                 ³
   *ΤΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΎ

FUNCTION BPosition()

   RETURN nTotBytes
