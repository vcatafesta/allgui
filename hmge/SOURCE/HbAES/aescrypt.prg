# include <hmg.ch>

FUNCTION EncryptFileAES( cFileIn, cFileOut, cPassword )

   LOCAL nMode := 0

   IF file( cFileOut )
      IF ! msgyesno( 'Destination File ' + cFileIn + ' already exists. Do you want to overwrite?' )

         RETURN .f.
      ENDIF
   ENDIF

   IF ! file( cFileIn )
      msgstop( 'Source File ' + cFileIn + ' not found!' )

      RETURN .f.
   ENDIF

   IF lower( alltrim( cFileIn ) ) == lower( alltrim( cFileOut ) )
      msgstop( 'Source File and Destination File can not be the same!' )

      RETURN .f.
   ENDIF

   IF len( cPassword ) == 0
      msgstop( 'Password can not be empty!' )

      RETURN .f.
   ENDIF

   IF CryptFileAES( cFileIn, cFileOut, cPassword, nMode ) == 1
      msgstop( 'Destination file can not be created successfully!' )

      RETURN .f.
   ENDIF

   RETURN .t.

FUNCTION DecryptFileAES( cFileIn, cFileOut, cPassword )

   LOCAL nMode := 1

   IF file( cFileOut )
      IF ! msgyesno( 'Destination File ' + cFileIn + ' already exists. Do you want to overwrite?' )

         RETURN .f.
      ENDIF
   ENDIF

   IF ! file( cFileIn )
      msgstop( 'Source File ' + cFileIn + ' not found!' )

      RETURN .f.
   ENDIF

   IF lower( alltrim( cFileIn ) ) == lower( alltrim( cFileOut ) )
      msgstop( 'Source File and Destination File can not be the same!' )

      RETURN .f.
   ENDIF

   IF len( cPassword ) == 0
      msgstop( 'Password can not be empty!' )

      RETURN .f.
   ENDIF

   IF CryptFileAES( cFileIn, cFileOut, cPassword, nMode ) == 1
      msgstop( 'Destination file can not be created successfully!' )

      RETURN .f.
   ENDIF

   RETURN .t.
