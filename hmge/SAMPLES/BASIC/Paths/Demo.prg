/******
* MINIGUI - Harbour Win32 GUI library Demo
* Demo functions for show system paths
* (c) 2008 Vladimir Chumachenko <ChVolodymyr@yandex.ru>
* Revised by Grigory Filatov <gfilatov@inbox.ru>
*/

#include "MiniGUI.ch"

STATIC cCurDir

/******
*       �������� ������������� ��������� �����
*/

PROCEDURE Main

   SET font to 'Tahoma', 9

   cCurDir := GetCurrentFolder()

   LOAD WINDOW Demo as wMain
   IF IsVistaOrLater()
      wMain.Width := (wMain.Width) + GetBorderWidth()
      wMain.Height := (wMain.Height) + GetBorderHeight()
   ENDIF

   wMain.BtnTextBox_1.Value := GetSpecialFolder( CSIDL_APPDATA )

   wMain.Label_3.Value := ''          // ���������� �����
   wMain.Label_6.Value := ''          // ����������� ������������� (� ������� 8.3)

   wMain.Label_7.Value := ( wMain.Label_7.Value + ' ' + cCurDir )

   wMain.Label_8.Value := ''          // ������������� �������

   wMain.Spinner_1.Value := 30

   MakePaths()

   CENTER WINDOW wMain
   ACTIVATE WINDOW wMain

   RETURN

   ****** End of Main ******

   /******
   *       SelectDir()
   *       ����� �������� ��� ������������
   */

STATIC PROCEDURE SelectDir

   LOCAL cPath := AllTrim( wMain.BtnTextBox_1.Value )

   IF !Empty( cPath := GetFolder( 'Choose a directory', cPath ) )
      wMain.BtnTextBox_1.Value := cPath
   ENDIF

   RETURN

   ****** End of SelectDir ******

   /******
   *       MakePaths()
   *       ������������ ������������� �����
   */

STATIC PROCEDURE MakePaths

   ShowCompactPath()
   ShowShortPath()
   ShowRelPath()

   RETURN

   ****** End of MakePaths ******

   /******
   *       ShowCompactPath()
   *       ������ ����� ������������� ��������
   */

STATIC PROCEDURE ShowCompactPath

   LOCAL cPath := wMain.BtnTextBox_1.Value, ;
      nLen  := wMain.Spinner_1.Value

   IF ( ( nLen < GetProperty( 'wMain', 'Spinner_1', 'RangeMin' ) ) .or. ;
         ( nLen > Getproperty( 'wMain', 'Spinner_1', 'RangeMax' ) )      ;
         )
      wMain.Spinner_1.Refresh
   ENDIF

   IF !Empty( cPath )
      wMain.Label_3.Value := _GetCompactPath( cPath, nLen )
   ENDIF

   RETURN

   ****** End of ShowCompactPath ******

   /******
   *       ShowShortPath()
   *       ����������� (������ 8.3) ������������� ������������� �����
   */

STATIC PROCEDURE ShowShortPath

   LOCAL cPath := wMain.BtnTextBox_1.Value

   IF !Empty( cPath )
      wMain.Label_6.Value := _GetShortPathName( cPath )
   ENDIF

   RETURN

   ****** End of ShowShortPath ******

   /******
   *       ShowRelPath()
   *       ����������� �������� ������������ �������� ��������
   */

STATIC PROCEDURE ShowRelPath

   LOCAL cPath := wMain.BtnTextBox_1.Value

   IF !Empty( cPath )
      wMain.Label_8.Value := RelativePath( cCurDir, cPath )
   ENDIF

   RETURN

   ****** End of ShowRelPath ******

   /******
   *       RelativePath( cCurPath, cTargetPath ) --> cRelPath
   *       ������������� ��������� ���� ������
   */

STATIC FUNCTION RelativePath( cCurPath, cTargetPath )

   LOCAL aCurrPath    := HB_ATokens( cCurPath, '\' )   , ;
      aTargetPath  := HB_ATokens( cTargetPath, '\' ), ;
      cRelPath     := ''                            , ;
      nLen                                          , ;
      Cycle

   IF ( Upper( cCurPath ) == Upper( cTargetPath ) )

      // �������� ���������

      RETURN ''

      // ... ��� ����� ���������� ������� �������
      // Return cCurPath

   ENDIF

   // ��� ���������� �������������� ���� ������� ����������� ��������� ��������:
   // 1) �������� ��������� �� ������ ������ - ����� ������������ ������ ���������� ����
   // 2) ������� ������� ������� �������� (���� �������)
   // 3) ������� ������� ��������� � ��� �� �����, ��� � �������, �� �� ����� �������
   //    ������
   // 4) ������� � ������� �������� ��������� �� ����� �����, �� � ������ ������.

   IF ( Upper( aCurrPath[ 1 ] ) == Upper( aTargetPath[ 1 ] ) )       // ���� �����?

      // �������� ���������� �� ����� ����� ��� ���������

      DO WHILE .T.

         IF ( Empty( aCurrPath ) .or. Empty( aTargetPath ) )
            EXIT
         ENDIF

         IF ( Upper( aCurrPath[ 1 ] ) == Upper( aTargetPath[ 1 ] ) )

            ADel( aCurrPath, 1 )
            ASize( aCurrPath, ( Len( aCurrPath ) - 1 ) )

            ADel( aTargetPath, 1 )
            ASize( aTargetPath, ( Len( aTargetPath ) - 1 ) )

         ELSE
            EXIT
         ENDIF

      ENDDO

      // ���� � ������� �������� �������� �������� �������� ��������, �� �
      // ����������� �������������� ���� ��������� �������������� ����� ���������
      // �� ������� ������� � ������� �������� �������� ��������

      IF !Empty( aCurrPath )
         cRelPath += Replicate( '..\', Len( aCurrPath ) )
      ENDIF

      IF ( ( nLen := Len( aTargetPath ) ) > 0 )
         FOR Cycle := 1 to nLen
            cRelPath += ( aTargetPath[ Cycle ] + '\' )
         NEXT
      ENDIF

   ELSE
      cRelPath := cTargetPath        // �������� �� ������ ������

   ENDIF

   IF ( Right( cRelPath, 1 ) == '\' )
      cRelPath := Left( cRelPath, ( Len( cRelPath ) - 1 ) )
   ENDIF

   RETURN cRelPath

   ****** End of RelativePath ******
