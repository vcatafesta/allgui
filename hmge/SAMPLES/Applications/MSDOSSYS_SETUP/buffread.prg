
#define BUFFLEN  4096

*��������������������������������������������������������������͸
*� Function Bopen( <cFileName>, [nAccessMode] )                 �
*� Return:   .t. if file was opened                             �
*� Assumes:  All file access will be done with the B* functions �
*��������������������������������������������������������������;

FUNCTION Bopen( cFileName, nAccMode )

   DEFAULT nAccMode to FO_READ // default access mode is Read Only

   nHandle := fopen( cFileName, nAccMode )
   cLineBuffer := ''
   lFullBuff := .t.
   nTotBytes := 0
   lIsOpen := .t.

   RETURN ( nHandle != -1 )

   *��������������������������������������������������������������͸
   *� Function BReadLine()                                         �
   *� Return:   The next line of the file read buffer              �
   *� Assumes:  The file pointer will be left as last positioned   �
   *��������������������������������������������������������������;

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

   *��������������������������������������������������������������͸
   *� Function BDisk2Buff()                                        �
   *� Return:   .t. if there was no read error                     �
   *��������������������������������������������������������������;

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

   *��������������������������������������������������������������͸
   *� Function BEof()                                              �
   *� Return:   TRUE  if End of buffered file                      �
   *�           FALSE if not                                       �
   *��������������������������������������������������������������;

FUNCTION BEof()

   RETURN !lFullBuff .and. len( cLineBuffer ) == 0

   *��������������������������������������������������������������͸
   *� Function BClose()                                            �
   *��������������������������������������������������������������;

FUNCTION BClose()

   IF lIsOpen
      fclose( nHandle )
      lIsOpen := .f.
   ENDIF

   RETURN FError()

   *��������������������������������������������������������������͸
   *� Function BPosition()                                         �
   *� Returns the position of virtual file pointer                 �
   *��������������������������������������������������������������;

FUNCTION BPosition()

   RETURN nTotBytes
