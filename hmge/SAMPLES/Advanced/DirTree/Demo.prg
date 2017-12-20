/******
* MINIGUI - Harbour Win32 GUI library Demo
* Build tree of folders, files and archives
* (c) 2008-2009 Vladimir Chumachenko <ChVolodymyr@yandex.ru>
* Revised by Grigory Filatov <gfilatov@inbox.ru>
*/

/*
������� ���������.

+ ���������
* ��������
- �������

������ 2009 �.

* ����� �� Zip-������ ����������� � ����������� ���������.
������ ������� ���������� hbzlib.lib �� ziparchive.lib � �������
��������� HB_OEMtoANSI() �� ����� ��������� ����� ����� �����������
����������, ���������� 7-Zip
* ��� ��������� ���������� Zip-������� ������ ������� ZipIndex()
������������ ������� HB_GetFilesInZip(). ZipIndex() ��������� �
������ ��������� � ������������������ ���� (�� ������ ������).
+ ��������� ������ 7-Zip ������ � ���� ����������� ���������� �
���������� ������ ��� ������ ������, ���������� ���� � ������
��������� ������ ��������. ������� ��� ��������� ������, ����������
��� ��������������� ������ ������������.
+ ���������� �������� ������������ ������

������� 2008 �.

��������� ������.
*/

#include "HBCompat.ch"
#include "Directry.ch"
#include "MiniGUI.ch"

// ����������� ����� ���������� 7-Zip

#define FULL_7Z             '7z.exe'         // ������ ������
#define DLL_7Z              '7z.dll'         // ���������� � ������ ������
#define ALONE_7Z            '7za.exe'        // ���������� �������

#define TEMP_FOLDER         ( GetTempFolder() + '\' )
#define TMP_ARC_INDEX       ( TEMP_FOLDER + '_Arc_.lst' )     // ��������� ���� ��� ������ ���������� ������

// ���������� ���������

#translate BREAK_ACTION_()                                                                                 ;
   =>                   lBreak := MsgYesNo( 'Stop operation?', 'Confirm action', .T., , .F., .F. )

// ��������� ������ ���������

// 1) �������� ��������: ������ ������������
#translate SET_DOSCAN_()                                                           ;
   =>                   wMain.ButtonEX_1.Caption     := 'Scan'             ;
   ; wMain.ButtonEX_1.Picture   := 'OK'               ;
   ; wMain.ButtonEX_1.Action    := { || BuildTree() }
// 2) ���������� ������: ���������� ���������
#translate SET_STOP_SCAN_()                                                        ;
   =>                   wMain.ButtonEX_1.Caption   := '[Esc] Stop'         ;
   ; wMain.ButtonEX_1.Picture := 'STOP'               ;
   ; wMain.ButtonEX_1.Action  := { || BREAK_ACTION_() }

STATIC cApp7z   := ''         // ��������� 7-Zip
STATIC cOSPaths := ''         // �������� ��������� ���������� PATH (������������ ������ ��� ������ ������ 7-Zip)

MEMVAR lBreak                 // �������� ���������

/******
*    ������ ��������� � ������
*/

PROCEDURE Main

   LOCAL cSysPath := Upper( GetEnv( 'PATH' ) ), ;
      cPath7z  := ''                       , ;
      oReg

   SET font to 'Tahoma', 9

   // ��� ������ � �������� (����� Zip) ���������� 7-Zip. ��������� ���� �� ���������:
   // - ��������� ������������� (������ ������);
   // - � ������� � ���������� �������� ����� 7z.exe � 7z.dll (��������� �� �������������, ��
   //   ���������������� ����������� �� ��, ��� � � ������������ ������);
   // - � �������� � ���������� ��������� ���������� ������ (7za.exe)
   // �������� ������ �� ���������. ��� ����� ��������� ����������� ����������� ��������. ����������
   // ������ ������ 7-Zip (���������������� �������������) ���� ����� ������ �������
   // ����� ����, ��� ������������� 7-Zip, ������������ � Program Files, ����������� ��������� ����������
   // ��������� ������ - �� ����������� �������, � ������� � � ����� ���������, � �����-���������
   // ������������ ����� � ���������:
   // %COMSPEC% /C "%\ProgramFiles%\7-Zip\7z.exe" L -slt "Some data.7z"
   // ��� ������ ����� �������� � ��������� ���������� PATH ��������� ������� ������ 7z.exe, � �����
   // ���������� ��������� - ��������������� �������� �������� PATH.
   // ���� 7z.exe � 7z.dll ��������� � �������� ���������, �������� PATH �� ����������.

   // ��� ������� Zip ������ ���������� ���������� �����������.

   Open registry oReg key HKEY_LOCAL_MACHINE Section 'Software\7-Zip'
   GET value cPath7z Name 'Path' of oReg
   CLOSE registry oReg

   IF !Empty( cPath7z )                              // ���������������� ������

      cPath7z := Upper( cPath7z )

      IF !( cPath7z $ cSysPath )

         cOSPaths := cSysPath

         IF !( Right( cOSPaths, 1 ) == ';' )
            cOSPaths += ';'
         ENDIF

         cOSPaths += ( cPath7z + '\' )
         cApp7z := FULL_7Z

      ENDIF

   ELSEIF ( File( FULL_7Z ) .and. File( DLL_7Z ) )   // � �������� � ���������� ��������� 7z.exe � 7z.dll
      cApp7z := FULL_7Z

   ELSEIF File( ALONE_7Z )                           // � �������� � ���������� ��������� 7za.exe
      cApp7z := ALONE_7Z

   ENDIF

   LOAD WINDOW Demo as wMain

   wMain.BtnTextBox_1.Value := GetMyDocumentsFolder()   // ������� ��� ������������ �� ���������

   // ��� ����������� ���������� ������ 7-Zip ��������� ������ ��������� �������� ��������,
   // ����, ��������, ��� ��������� RAR ����� ������������ ������ ������ 7-Zip

   IF !Empty( cApp7z )

      // �������������� ���� ������� ��� ������ � ���������� ������

      IF ( cApp7z == FULL_7Z )
         wMain.Combo_1.AddItem( 'ZIP; 7Z; RAR; CAB; ARJ; LZH' )
      ELSE
         wMain.Combo_1.AddItem( 'ZIP; 7Z' )
      ENDIF

      wMain.Combo_1.Value := 2

   ENDIF

   SET_DOSCAN_()

   wMain.ButtonEX_2.Enabled := .F.
   wMain.ButtonEX_3.Enabled := .F.
   wMain.ButtonEX_4.Enabled := .F.

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

   IF !Empty( cPath := GetFolder( 'Select folder', cPath ) )
      wMain.BtnTextBox_1.Value := cPath
   ENDIF

   RETURN

   ****** End of SelectDir ******

   /******
   *       BuildTree()
   *       ���������� ������
   */

STATIC PROCEDURE BuildTree

   LOCAL cPath     := wMain.BtnTextBox_1.Value, ;
      cSavePath := ''

   PRIVATE lBreak := .F.          // �������� ���������

   SET_STOP_SCAN_()
   On key Escape of wMain Action BREAK_ACTION_()

   IF !Empty( cPath )

      // ��� ������������� ������������ ������ 7-Zip �������� ���������
      // ���������� PATH

      IF !Empty( cOSPaths )
         cSavePath := GetEnv( 'PATH' )
         SetEnvironmentVariable( 'PATH', cOSPaths )
      ENDIF

      wMain.Tree_1.DeleteAllItems
      wMain.Tree_1.DisableUpdate

      // ������� ������� ���� ��������� ��������

      Node wMain.BtnTextBox_1.Value Images { 'STRUCTURE' }
         ScanDir( cPath )
      End Node
      wMain.StatusBar.Item( 1 ) := ''

      // ������������ �������� �������� ��������� ���������� PATH (���� ���
      // ���� ��������).

      IF !Empty( cSavePath )
         SetEnvironmentVariable( 'PATH', cSavePath )
      ENDIF

      wMain.Tree_1.Expand( 1 )
      wMain.Tree_1.EnableUpdate

      wMain.Tree_1.Value := 1
      wMain.Tree_1.SetFocus

      IF ( wMain.Tree_1.ItemCount > 1 )
         wMain.ButtonEX_2.Enabled := .T.
         wMain.ButtonEX_3.Enabled := .T.
         wMain.ButtonEX_4.Enabled := .T.
      ELSE
         wMain.ButtonEX_2.Enabled := .F.
         wMain.ButtonEX_3.Enabled := .F.
         wMain.ButtonEX_4.Enabled := .T.
      ENDIF

   ENDIF

   SET_DOSCAN_()
   RELEASE key Escape of wMain

   RETURN

   ****** End of BuildTree ******

   /******
   *       ScanDir( cPath )
   *       ������������ ��������
   */

STATIC PROCEDURE ScanDir( cPath )

   LOCAL cMask     := AllTrim( wMain.Text_1.Value )      , ;
      cAttr     := Iif( wMain.Check_1.Value, 'H', '' ), ;
      aFullList                                       , ;
      aDir      := {}                                 , ;
      aFiles                                          , ;
      xItem

   IF !( Right( cPath, 1 ) == '\' )
      cPath += '\'
   ENDIF

   BEGIN Sequence

      // ��������� ��� ������� ����� �������������� �����, ��������� ��������� �������.
      // 1) �������� ������ ���� ������������ ��������� ���������� (����� �� �����������,
      //    ��������� ��� ���� ����� �������������� ���� �����������)
      // 2) ��� ������� ����������� ����������� ������ ������������� ��� ������
      //    � ������ �������
      // 3) ���������� �� ����������� � ������, ���� ��������� ������ ��� � �� ���������
      //    ���������� ������ ���������

      IF !Empty( aFullList := ASort( Directory( cPath, ( 'D' + cAttr ) ),,, ;
            { | x, y | Upper( x[ F_NAME ] ) < Upper( y[ F_NAME ] ) } ) )

         FOR EACH xItem in aFullList

            IF ( 'D' $ xItem[ F_ATTR ] )
               IF ( !( xItem[ F_NAME ] == '.' ) .and. !( xItem[ F_NAME ] == '..' ) )
                  AAdd( aDir, xItem[ F_NAME ] )
               ENDIF
            ENDIF

            Do Events

            IF lBreak
               Break
            ENDIF

         NEXT

      ENDIF

      // ������������ ���������� ������ ���������. ��� ���� ����������� �����������
      // ����� ��������� ��� ������������ ����� �������� �������

      IF !Empty( aDir )

         FOR EACH xItem in aDir

            // ����� ����������� ���� �������� ��������� ������� � ��
            // ������, ����������� � �������� ��� ������������. ����� ����� ������ ����
            // �� �����.

            // ���� ����� ��������� ������ ������� ������:
            // If !Empty( Directory( ( cPath + xItem + '\' + cMask ), cAttr ) )
            // ������ � ���� ������ ��������, � ������� ��� ������ (�� �������� �����),
            // �� ���� �����������, � ���������� �������� �� �����, ��� � �����, �����������
            // � ���.

            IF ( !Empty( Directory( ( cPath + xItem + '\' + cMask ), cAttr ) ) .or.  ;
                  ( wMain.Check_3.Value                                         .and. ;
                  !Empty( Directory( ( cPath + xItem ), ( 'D' + cAttr ) ) )         ;
                  )                                                                   ;
                  )

               Node xItem
                  ScanDir( cPath + xItem )
               End Node

               Do Events

               IF lBreak
                  Break
               ENDIF

            ENDIF

         NEXT

      ENDIF

      // ��������� ������ ������

      IF !Empty( aFiles := ASort( Directory( ( cPath + cMask ), cAttr ),,, ;
            { | x, y | Upper( x[ F_NAME ] ) < Upper( y[ F_NAME ] ) } ) )

         FOR EACH xItem in aFiles

            wMain.StatusBar.Item( 1 ) := ( cPath + xItem[ F_NAME ] )

            Do Events

            IF !wMain.Check_2.Value         // �� ����������� ������
               TreeItem xItem[ F_NAME ]
            ELSE
               GetArc( cPath, xItem[ F_NAME ] )
            ENDIF

            IF lBreak
               Break
            ENDIF

         NEXT

      ENDIF

   End

   RETURN

   ****** End of ScanDir ******

   /******
   *       GetArc( cPath, cFile )
   *       ��������� ��������� �����
   */

STATIC PROCEDURE GetArc( cPath, cFile )

   LOCAL cArcTypes := wMain.Combo_1.DisplayValue, ;
      cExt                                   , ;
      aFileList                              , ;
      cItem

   HB_FNameSplit( cFile, , , @cExt )

   IF !Empty( cExt := Upper( cExt ) )

      IF ( Left( cExt, 1 ) == '.' )
         cExt := Substr( cExt, 2 )
      ENDIF

      // ���� ���������� ����������� ��������� ����, �������� ����������
      // ������. ��� ���� ������ ZIP �������������� ������������ ����������.
      // � ��������� - ������� �����������

      IF !( cExt $ cArcTypes )
         TreeItem cFile

      ELSE

         // ���������� ������ �������� 2-� ���������: ����������� ����������
         // ZIP � �������� 7-Zip. ������ ������ � Zip-������ ����� �������� �
         // ������� �������� HB_GetFilesInZip( cPath + cFile ).
         // � ���������� ������� Harbour ���������� ������� ��������� � ���������
         // ������� ��� ���������� ���� ������� �� ������� ���������� �������,
         // ������� ���� ������� ������� ZipIndex(). �� � ��������� ����� ��� �����
         // ���������, ������� ZipIndex() ��������� � ������ ���������, �� �� ������������.

         Try
            //aFileList := Iif( ( cExt == 'ZIP' ), ZipIndex( cPath + cFile ), ArcIndex( cPath + cFile ) )
            aFileList := Iif( ( cExt == 'ZIP' ), HB_GetFilesInZip( cPath + cFile ), ArcIndex( cPath + cFile ) )
         CATCH
            aFileList := {}
         End

         IF !Empty( aFileList )

            Node cFile Images Iif( ( cExt == 'ZIP' ), { 'ARC_ZIP' }, { 'ARC_7ZIP' } )
               FOR EACH cItem in aFileList
                  TreeItem cItem
               NEXT
            End Node

         ELSE
            TreeItem cFile

         ENDIF

      ENDIF

   ELSE
      TreeItem cFile

   ENDIF

   RETURN

   ****** End of GetArc ******

   // ������� ZipIndex() �������������� ��� ������ HB_GetFilesInZip(), �� � ���������
   // ������� Harbour ������������� � ��� ������. ��������� ��� �������.

   /******
   *       ZipIndex( cArcFile ) --> aFiles
   *       ������ ������ � ������ ZIP
   */

   /*
   Static Function ZipIndex( cArcFile )
   Local aFiles := {}                      , ;
   hUnzip := HB_UnZipOpen( cArcFile ), ;
   nError                            , ;
   cFile

   If !Empty( hUnzip )

   nError := HB_UnZipFileFirst( hUnzip )

   Do while Empty( nError )

   HB_UnZipFileInfo( hUnzip, @cFile )

   AAdd( aFiles, cFile )

   nError := HB_UnZipFileNext( hUnzip )

   Enddo

   HB_UnZipClose( hUnzip )

   Endif

   Return aFiles
   */

   ****** End of ZipIndex ******

   /******
   *       ArcIndex( cArcFile ) --> aFiles
   *       ������ ������ � ������ �� ZIP-����
   */

STATIC FUNCTION ArcIndex( cArcFile )

   LOCAL aFiles   := {}                                       , ;
      cCommand := ( GetEnv( 'COMSPEC' ) + ' /C ' + cApp7z ), ;
      cString, oFile

   // ���������� ������ ������� �� ��������� ���� � ����� ��������� ��� ������ �
   // ���������.

   // � ���������� ����� �������� �� � ���������, � � ����������� ������ (�������������
   // -slt). ����� ������ ���� ���� ����� ����������� � ��������� ������� �������� ���
   // (���������� � ������������ �� ���� ������):
   // Path = ��� ���� ������
   // Size =
   // Packed Size =
   // Modified =
   // Attributes =
   // CRC =
   // Method =
   // Block =
   // � ��� �������� ������ ����� ���������� � ������ ������������ Path =

   cCommand += ( ' L -slt "' + cArcFile + '" > ' + TMP_ARC_INDEX )
   EXECUTE FILE ( cCommand ) Wait Hide

   IF File( TMP_ARC_INDEX )

      // ��������� ���� ����� � �� ���������, ��������, ���������� ������
      // � ������ �������. ������������� �� ������ �� ��������� � ��� ������.
      // ���� ������� - �� � �� ��� ������.

      // ��������� ������

      oFile := TFileRead() : New( TMP_ARC_INDEX )
      oFile : Open()

      IF !oFile : Error()

         DO WHILE oFile : MoreToRead()

            IF !Empty( cString := oFile : ReadLine() )

               // ��������� ���������� ���������. ������ ���������, �� ����������
               // �� ������ � "Path =" �, ���� �� - �� ��� ��� �����. ���
               // �������������, ����� ������� ���������. ��������, ������������
               // ����� ��������� (������ "Attributes = D...." ��� ������ .7z)

               IF ( Left( cString, 7 ) == 'Path = ' )

                  cString := HB_OEMtoANSI( AllTrim( Substr( cString, 8 ) ) )

                  // ��������� ������ 7-Zip � ����� � ���������� ������ ���������
                  // ������������ ������ ������ (����� � ������ "Path =").
                  // ������� ������ ��������.

                  IF !( Upper( cArcFile ) == Upper( cString ) )
                     AAdd( aFiles, cString )
                  ENDIF

               ENDIF

            ENDIF

         ENDDO

         oFile : Close()

      ENDIF

   ENDIF

   // ��������� ���� ������ ���� ���� � �.�. �����.

   ERASE ( TMP_ARC_INDEX )

   RETURN aFiles

   ****** End of ArcIndex ******

   /******
   *       ShowTreeNode( nMode )
   *       ���������� (1) ��� �������� (0) ��� ���� ������
   */

STATIC PROCEDURE ShowTreeNode( nMode )

   LOCAL nCount := wMain.Tree_1.ItemCount, ;
      Cycle

   IF !Empty( nCount )

      wMain.Tree_1.DisableUpdate

      FOR Cycle := 1 to nCount

         // ������������ ������ ��������, �� ������� �������� ������ (����)

         IF IsTreeNode( 'wMain', 'Tree_1', Cycle )

            IF ( nMode == 1 )
               wMain.Tree_1.Expand( Cycle )
            ELSE
               wMain.Tree_1.Collapse( Cycle )
            ENDIF

         ENDIF

      NEXT

      IF ( nMode == 1 )
         wMain.Tree_1.Value := 1
      ENDIF

      wMain.Tree_1.EnableUpdate
      wMain.Tree_1.SetFocus

   ENDIF

   RETURN

   ****** End of ShowTreeNode ******

   /******
   *       IsTreeNode( cFormName, cTreeName, nPos ) --> lIsNode
   *       ��������, �������� �� ������� ������ �����
   */

STATIC FUNCTION IsTreeNode( cFormName, cTreeName, nPos )

   LOCAL nVal            := GetProperty( cFormName, cTreeName, 'Value' )    , ;
      nAmount         := GetProperty( cFormName, cTreeName, 'ItemCount' ), ;
      nIndex                                                             , ;
      nHandle                                                            , ;
      nTreeItemHandle

   IF ( Valtype( nPos ) == 'N' )
      IF ( ( nPos > 0 ) .and. ( nPos <= nAmount ) )
         nVal := nPos
      ENDIF
   ENDIF

   nIndex          := GetControlIndex( cTreeName, cFormName )
   nHandle         := _HMG_aControlHandles[ nIndex ]
   nTreeItemHandle := _HMG_aControlPageMap[ nIndex, nVal ]

   // ������� ������ ��������� �����, ���� ����� ���������� ��������

   RETURN !Empty( TreeView_GetChild( nHandle, nTreeItemHandle ) )

   ****** End of IsTreeNode ******

   /******
   *       OpenObj( cFormName, cTreeName )
   *       ������� ������� ������, �������������� ��������� ������
   */

STATIC PROCEDURE OpenObj( cFormName, cTreeName )

   LOCAL nVal            := GetProperty( cFormName, cTreeName, 'Value' ), ;
      nIndex                                                         , ;
      nHandle                                                        , ;
      nTreeHandle                                                    , ;
      nTreeItemHandle                                                , ;
      nTempHandle                                                    , ;
      cChain                                                         , ;
      aTokens                                                        , ;
      cArcName        := ''                                          , ;
      cElem                                                          , ;
      cExt                                                           , ;
      cSavePath       := ''                                          , ;
      cCommand        := ( GetEnv( 'COMSPEC' ) + ' /C ' + cApp7z )

   IF Empty( nVal )

      RETURN
   ENDIF

   // ������������ ����� � �������� ������� ��� ����������� �������� � �����

   nTreeHandle := GetControlHandle( cTreeName, cFormName )

   nIndex  := GetControlIndex( cTreeName, cFormName )
   nHandle := _HMG_aControlHandles[ nIndex ]

   nTreeItemHandle := _HMG_aControlPageMap[ nIndex, nVal ]

   cChain      := TreeView_GetItem( nTreeHandle, nTreeItemHandle )
   nTempHandle := TreeView_GetParent( nHandle, nTreeItemHandle )

   DO WHILE !Empty( nTempHandle )
      nTreeItemHandle := nTempHandle
      nTempHandle     := TreeView_GetParent( nHandle, nTreeItemHandle )
      cChain          := ( TreeView_GetItem( nTreeHandle, nTreeItemHandle ) + ;
         Iif( Right( TreeView_GetItem( nTreeHandle, nTreeItemHandle ), 1 ) == '\', '', '\' ) + cChain )
   ENDDO

   // ���������� �������� �.�. ���������, ������ ��� ������ � ������. � ��������� ������
   // ���� ����� ������������� ������ �����������, ���������� � �����.

   IF ( HB_DirExists( cChain ) .or. File( cChain ) )

      // ������� ��� ����. ��� �������� ��������� �����, ��� ����� - ��������� ��������������� ���������.
      // !!! ����� � ��������� "�������" � ��� ����� �� ��������.

      Execute operation 'Open' file ( '"' + cChain + '"' )

   ELSE

      // ���� � ������. ��������� ������ ��� � ���������� ������������ ������ ������.

      aTokens := HB_ATokens( cChain, '\' )

      FOR EACH cElem in aTokens

         IF !Empty( cArcName )
            cArcName += '\'
         ENDIF

         cArcName += cElem

         IF File( cArcName )
            EXIT
         ENDIF

      NEXT

      // ��� ������ ��������� �� ���������� ������ ��������.

      cChain := Substr( cChain, ( Len( cArcName ) + 1 ) )  // ������ ��� ��� ����� � ������

      IF ( Left( cChain, 1 ) == '\' )
         cChain := Substr( cChain, 2 )
      ENDIF

      // ��� ��� ��������� �������� ������������� �����, ��������� � ���
      // ����� �������� ��������� ������ � ��������� "�������".

      IF File( cArcName )

         HB_FNameSplit( cArcName, , , @cExt )

         IF !Empty( cExt := Upper( cExt ) )

            IF ( Left( cExt, 1 ) == '.' )
               cExt := Substr( cExt, 2 )
            ENDIF

            IF ( cExt == 'ZIP' )

               // ������ ZIP �������������� ������������ ����������.

               // !!! ����� � ������ � ���������� � ����� ���������� ZIP �� �����������.
               // ����� ��������������� 7-Zip

               IF HB_UnZipFile( cArcName,,,, TEMP_FOLDER, cChain )

                  // ����������� � Zip-������ ����� ����������� ������ ������, �������
                  // ���� ���������������.

                  cChain := Slashs( cChain )

                  // ��������� ��������������� ��������� ���������, ������� � ����������
                  // � ������� ����������� ���� (��� ������������� - � �������).

                  // !!! ������ � ������ �� �����������.

                  ShowFile( cChain )

                  IF !Empty( nVal := At( '\', cChain ) )

                     cChain := Left( cChain, ( nVal - 1 ) )

                     IF HB_DirExists( TEMP_FOLDER + cChain )
                        DirRemove( TEMP_FOLDER + cChain )
                     ENDIF

                  ENDIF

               ENDIF

            ELSE

               // ��������� 7-Zip

               IF !Empty( cOSPaths )
                  cSavePath := GetEnv( 'PATH' )
                  SetEnvironmentVariable( 'PATH', cOSPaths )
               ENDIF

               cCommand += ( ' E -y -o' + TEMP_FOLDER + ' "' + cArcName + '" "' + cChain + '"' )

               EXECUTE FILE ( cCommand ) Wait Hide

               IF !Empty( cSavePath )
                  SetEnvironmentVariable( 'PATH', cSavePath )
               ENDIF

               cChain := Slashs( cChain )

               // ����� ��������� �������� ����� ������ �� ����� �����.

               IF !Empty( nVal := ( RAt( '\', cChain ) ) )
                  cChain := Substr( cChain, ( nVal + 1 ) )
               ENDIF

               ShowFile( cChain )

            ENDIF

         ENDIF

      ENDIF

   ENDIF

   RETURN

   ****** End of OpenObj ******

   /******
   *       Slashs( cPath ) --> cPath
   *       ��������� ������������ ���������, ������������ �
   *       �������, �� ���������
   */

STATIC FUNCTION Slashs( cPath )

   IF !Empty( At( '/', cPath ) )
      cPath := StrTran( cPath, '/', '\' )
   ENDIF

   RETURN cPath

   ****** End of Slashs ******

   /******
   *       ShowFile( cChain )
   *       ������� ����������� �� ������ ����.
   *       ����� ���������� ��������� ���� ���������.
   */

STATIC PROCEDURE ShowFile( cChain )

   LOCAL cExt, ;
      cApp, ;
      nPos

   // ���� � ���������� ����� ����� ���������� ����� ���� (���������� � ������),
   // ���������� ���������� �� ��.

   IF ( ( nPos := RAt( '\', cChain ) ) > 0 )
      cChain := Substr( cChain, ( nPos + 1 ) )
   ENDIF

   IF File( TEMP_FOLDER + cChain  )

      HB_FNameSplit( cChain, , , @cExt )

      // ���������� ��������������� ��������� � ������� � ��� ����.
      // ���� ��������� �� ����� ������������, ����������� ������
      // ��������� ����������� ���� (��� �������, ����� ���������
      // ���������, � ������� ����� ����������� ��� �����).

      IF !Empty( cApp := GetOpenCommand( cExt ) )
         EXECUTE FILE ( cApp + ' "' + TEMP_FOLDER + cChain + '"' ) Wait
      ELSE
         EXECUTE FILE ( TEMP_FOLDER + cChain ) Wait
      ENDIF

      Erase( TEMP_FOLDER + cChain )

   ENDIF

   RETURN

   ****** End of ShowFile ******

   /******
   *       GetOpenCommand( cExt )
   *       ����������� ���������, ��������� � �����������.
   */

STATIC FUNCTION GetOpenCommand( cExt )

   LOCAL oReg       , ;
      cVar1      , ;
      cVar2 := '', ;
      nPos

   IF !IsChar( cExt )

      RETURN ''
   ENDIF

   // ������� ��������. � HKEY_CLASSES_ROOT ���� �����, �������������� �����������
   // ���������� (� ������� ������) � ���������� ������������ ���� ����� (��������
   // "(�� ���������)". ��������, ��� ���������� "jpg" ���� HKEY_CLASSES_ROOT\.jpg
   // � �������� ��� ���������� - "jpegfile".
   // � ���� �� ����� HKEY_CLASSES_ROOT ���� ������ ������� ���������, ��������� �
   // ���� ����� ����� (HKEY_CLASSES_ROOT\<��� ����������>\shell\open\command)
   // ��������, HKEY_CLASSES_ROOT\jpegfile\shell\open\command
   // � �������� ��������� "(�� ���������)" ��������� ������� �������� ����� ����
   // �����: "C:\\Program Files\\Internet Explorer\\iexplore.exe\" -nohome

   IF ( !Left( cExt, 1 ) == '.' )
      cExt := ( '.' + cExt )
   ENDIF

   oReg  := TReg32() : New( HKEY_CLASSES_ROOT, cExt, .F. )
   cVar1 := RTrim( StrTran( oReg : Get( Nil, '' ), Chr( 0 ), ' ' ) )   // �������� ����� "(�� ���������)"
   oReg : Close()

   IF !Empty( cVar1 )

      oReg  := TReg32() : New( HKEY_CLASSES_ROOT, ( cVar1 + '\shell\open\command' ), .F. )
      cVar2 := RTrim( StrTran( oReg : Get( Nil, '' ), Chr( 0 ), ' ' ) )  // �������� ����� "(�� ���������)"
      oReg : Close()

      // ��������� �������� �� �������� ���������� ��������������� ���������

      IF ( nPos := RAt( ' %1', cVar2 ) ) > 0        // �������� �� ����������� ��������� (�������)
         cVar2 := SubStr( cVar2, 1, nPos )

      ELSEIF ( nPos := RAt( '"%', cVar2 ) ) > 0     // ��������� ���� "%1", "%L" � �.�. (� ���������)
         cVar2 := SubStr( cVar2, 1, ( nPos - 1 ) )

      ELSEIF ( nPos := RAt( '%', cVar2 ) ) > 0      // ��������� ���� "%1", "%L" � �.�. (��� �������)
         cVar2 := SubStr( cVar2, 1, ( nPos - 1 ) )

      ELSEIF ( nPos := RAt( ' /', cVar2 ) ) > 0     // ������� "/"
         cVar2 := SubStr( cVar2, 1, ( nPos - 1 ) )

      ENDIF

   ENDIF

   RETURN RTrim( cVar2 )

   ****** End of GetOpenCommand ******

#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"
#include "hbapiitm.h"

// ������ ������� ���� � ����������� Harbour/xHarbour
// Harbour - VWN_SETENVIRONMENTVARIABLE � CONTRIB\HBWHAT\whtmisc.c
// xHarbour - SETENVIRONMENTVARIABLE � CONTRIB\WHAT32\SOURCE\_winmisc.c

HB_FUNC_STATIC( SETENVIRONMENTVARIABLE )
{
   hb_retl( SetEnvironmentVariableA( hb_parcx( 1 ),
                                     hb_parcx( 2 )
                                     ) );
}

#pragma ENDDUMP
