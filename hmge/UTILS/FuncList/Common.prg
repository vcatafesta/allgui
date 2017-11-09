/******
*       Common procedures
*/

#include "Common.ch"

/******
*       CenterInsife( cMainWindow, cClientWindow )
*       Centring the child windows inside parent window
*/

PROCEDURE CenterInside( cMainWindow, cClientWindow )

   LOCAL nColMain      := GetProperty( cMainWindow  , 'Col'    ), ;
      nRowMain      := GetProperty( cMainWindow  , 'Row'    ), ;
      nWidthMain    := GetProperty( cMainWindow  , 'Width'  ), ;
      nHeightMain   := GetProperty( cMainWindow  , 'Height' ), ;
      nWidthClient  := GetProperty( cClientWindow, 'Width'  ), ;
      nHeightClient := GetProperty( cClientWindow, 'Height' ), ;
      nCol                                                   , ;
      nRow

   nCol := ( nColMain + Int( ( nWidthMain  - nWidthClient  ) / 2 ) )
   nRow := ( nRowMain + Int( ( nHeightMain - nHeightClient ) / 2 ) )

   SetProperty( cClientWindow, 'Col', nCol )
   SetProperty( cClientWindow, 'Row', nRow )

   RETURN

   ****** End of CenterInside ******

   /******
   *       CheckPath( cPath [, lCreate ] ) --> lSuccess
   *       Path's verify, absent folders is created,
   *       if specify lCreate = .T.
   *       Remark: The verify is maked for folder with lower level
   *          than current folder.
   */

FUNCTION CheckPath( cPath, lCreate )

   LOCAL cCurrDisk   := DiskName(), ;
      cCurrDir    := CurDir()  , ;
      lDiskChange := .F.       , ;
      lSuccess    := .F.       , ;
      nError                   , ;
      aDirs                    , ;
      Cycle                    , ;
      nLen

   IF ( !( Valtype( 'cPath' ) == 'C' ) .or. ;
         Empty( cPath )                     ;
         )

      RETURN .F.
   ENDIF

   IF Empty( cPath )

      RETURN .T.
   ENDIF

   DEFAULT lCreate to .F.

   cPath    := AllTrim( cPath )
   cCurrDir := AllTrim( cCurrDisk + ':\' + cCurrDir )

   IF ( Right( cPath, 1 ) == '\' )
      cPath := Substr( cPath, 1, ( Len( cPath ) - 1 ) )
   ENDIF

   IF ( Left( cPath, 1 ) == '\' )
      cPath := Substr( cPath, 2 )
   ENDIF

   nLen := Len( aDirs := StrToArray( cPath, '\' ) )

   BEGIN Sequence

      FOR Cycle := 1 to nLen

         // The each folders are verify successively.
         // Firstly check for designated disk.
         // If it is true and disk is available, pass to
         // the root directory of this disk.

         IF ( Right( aDirs[ Cycle ], 1 ) == ':' )

            IF IsDisk( aDirs[ Cycle ] )

               IF DiskChange( aDirs[ Cycle ] )

                  DirChange( '\' )
                  lDiskChange := .T.
                  LOOP

               ELSE
                  Break

               ENDIF

            ELSE
               Break

            ENDIF

         ENDIF

         // If the folder is not exist and parameter lCreate = .T., try
         // to create this folder and pass to it. If it is unsuccessful attempt
         // the further operations are breaked.

         nError := DirChange( aDirs[ Cycle ] )
         IF !Empty( nError )

            IF lCreate
               IF Empty( MakeDir( aDirs[ Cycle ] ) )

                  IF !Empty( DirChange( aDirs[ Cycle ] ) )
                     Break
                  ENDIF

               ELSE
                  Break

               ENDIF

            ELSE
               Break

            ENDIF

         ENDIF

      NEXT

      lSuccess := .T.

   End

   // Return to current folder

   IF lDiskChange
      DiskChange( cCurrDisk )
      DirChange( '\' )
   ENDIF

   DirChange( cCurrDir )

   RETURN lSuccess

   ****** End of CheckPath ******

   /******
   *       StrToArray( cString, cDelimiter ) --> aResult
   *       Converting the string to array.
   *       Parameters:
   *          cString     - processed string
   *          cDelimiter  - one or a few delimiters. Default value is
   *                        defined for functions Token() and NumToken().
   */

FUNCTION StrToArray( cString, cDelimiter )

   LOCAL aResult := {}                             , ;
      nCount  := NumToken( cString, cDelimiter ), ;
      Cycle

   FOR Cycle := 1 to nCount
      AAdd( aResult, Token( cString, cDelimiter, Cycle ) )
   NEXT

   RETURN aResult

   ****** End of StrToArray ******

#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

/******
*       Blocking window close button
*/

HB_FUNC( DISABLECLOSEBUTTON )
{
  HWND hWnd;
  HMENU hMenu;

  hWnd = (HWND) hb_parnl( 1 );
  hMenu = GetSystemMenu( hWnd, FALSE );

  if (hMenu != 0)
  {
   DeleteMenu( hMenu, SC_CLOSE, MF_BYCOMMAND);
  }

}

#pragma ENDDUMP

