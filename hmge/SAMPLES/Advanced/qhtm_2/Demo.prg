/*
* MINIGUI - Harbour Win32 GUI library Demo
* Joint usage of QHTM & SQLite3 demo
* (c) 2009 Vladimir Chumachenko <ChVolodymyr@yandex.ru>
* Revised by Grigory Filatov <gfilatov@inbox.ru>
*/

/*
������������ ������������� ������� ������������ ���������� QHTM (freeware version)

������������ ��������� �������:
- ����������� DLL QHTM (QHTM_Init(), QHTM_End())
- �������� �������� QHTM; �������� ���������� �� ����������, ���������� ����� (@...QHTM)
- ��������� �������� ��������� QHTM � ���������� �� �����������
- ��������� ��������� � �������� �������� QHTM (QHTM_GetTitle(), QHTM_GetSize())
- ������������� MsgBox() � ����� QHTM (QHTM_MessageBox())
- ������������� ����������� ��������� � ����� QHTM (QHTM_EnableCooltips())
- �������� HTML ���� �������� QHTM
- ������������� ������ � ������ �������� QHTM ��� ���������� ���������� ��������
- ���������� ���-�������� �� ������� (QHTM_SetHTMLButton())
- ���������� ���-���� � ��������� ����������

������� QHTM (���������):
QHTM_Init( [ cDllName ] )
QHTM_End()
QHTM_MessageBox( cMessage [,cTitle ] [,nFlags ] )
QHTM_LoadFile( handle, cFileName )
QHTM_LoadRes( handle, cResourceName )
QHTM_AddHtml( handle, cText )
QHTM_GetTitle( handle )
QHTM_GetSize( handle )
QHTM_EnableCooltips()
QHTM_SetHTMLButton( handle )
QHTM_PrintCreateContext() --> hContext
QHTM_PrintSetText( hContext,cHtmlText )
QHTM_PrintSetTextFile( hContext,cFileName )
QHTM_PrintSetTextResource( hContext,cResourceName )
QHTM_PrintLayOut( hDC,hContext ) --> nNumberOfPages
QHTM_PrintPage( hDC,hContext,nPage )
QHTM_PrintDestroyContext( hContext )

QhtmFormProc() - ��������������� ��� ��������� ��������� ���������� �����
� ���-�����
*/

#include "Directry.ch"
#include "HBSQLit3.ch"
#include "i_qhtm.ch"
#include "MiniGUI.ch"
#include "winprint.ch"

// ����������� WinAPI

#define WM_NOTIFY                78
#define WM_CTLCOLORSTATIC           312

// ��� ��������� ���� ��������� ����

#define WS_EX_CLIENTEDGE            512   // ����������, ��� ���� ����� ����� � ����������� �����.
#define WS_EX_STATICEDGE           8192   // ���� � �������� ������. ���� ����� ������ ������������
// ��� ��������� ����������, �� ����������� ���� ������.

#define WS_FLAT                    ( WS_EX_CLIENTEDGE + WS_EX_STATICEDGE )

// ����� ������ � �������� ������������� �������� � ������������� ���������� ��������� �������.

#define MB_YESNO                      4

#define IDYES                         6       // � ������� "��-���" ������ ������ "��"
#define MB_DEFBUTTON2               256       // 2-� ������ � ������� ������� �� ���������

#define DB_NAME            'PicBase.db'       // ������� ����
#define TMP_SOURCE_TXT     'Temp.txt'         // ��������� ���� ��� ��������� ���� ��������

// ������� ������ ������������ ����������� �����������

// ������� ���������

#define LOGO_TOP                      5
#define LOGO_LEFT                     5
#define LOGO_HEIGHT                 130

// ���� �������

#define TB_TOP                      ( LOGO_TOP +  LOGO_HEIGHT + 5 )
#define TB_LEFT                     LOGO_LEFT
#define TB_WIDTH                    260

// ������� ������ ������

#define DATA_TOP                    TB_TOP
#define DATA_LEFT                   ( TB_LEFT + TB_WIDTH + 5 )

// �������������� �������������� ��������� QHTM

#define HWND_HTMLDATA               GetControlHandle( 'HtmlData', 'wMain' )

// ������� (��������������� ������)

#define ID_COMMAND                  'COMMAND:'
#define ID_COMMAND_EXPLORER         ( ID_COMMAND + 'EXPLORER'     )  // ������ Explorer
#define ID_COMMAND_CHANGEFOLDER     ( ID_COMMAND + 'CHANGEFOLDER' )  // ������� ������� �����
#define ID_COMMAND_VIEWIMAGE        ( ID_COMMAND + 'VIEWIMAGE'    )  // ������������� �������� �������

// ������� �����, ������������ � ����������

#define HTML_PRINT_DEMO             'Files\QHTM.html'       // ������������ ������
#define HTML_SUBMIT_DEMO            'Files\Index.htm'       // ������������ ������������� ����

STATIC aParams                      // ������ ������� ����������

/******
*       ������������ ��������, ���������� � ����������� ������
*       � � ���� SQLite
*/

PROCEDURE Main

   LOCAL cHTML := ''

   aParams := { 'StartDir'    => GetSpecialFolder( CSIDL_MYPICTURES ), ;        // ������� "��� �������"
      'pDB'         => nil                                 , ;        // ���������� ����
      'ReadFiles'   => .T.                                 , ;        // ���������� ������ ������
      'SavePos'     => .F.                                 , ;        // ��������� ������� � ������ ������
      'Reload'      => .T.                                 , ;        // ������� ������������� ���������� ��
      'TmpDir'      => ( GetTempFolder() + '\' )           , ;        // ������� ��������� ������
      'TmpFilePict' => ''                                    ;        // ��������� ���� ������� �� ����
      }

   IF Empty( aParams[ 'pDB' ] := OpenBase() )
      MsgStop( "Can't open/create " + DB_NAME, 'Error' )
      QUIT
   ENDIF

   IF !QHTM_Init()
      MsgStop( ( 'Library QHTM.dll not loaded.' + CRLF + ;
         'Program terminated.'                   ;
         ), 'Error' )
      QUIT
   ENDIF

   SET CENTURY ON
   SET DATE German

   SET font to 'Tahoma', 9
   SET default icon to 'MAIN'

   SET Events function to MyEvents

   // ��������� ������������� HTML � ������ ����������� ���������. ������� ������
   // ���������� �� ����������� ��������� ����.
   // ! ������������� ���� ������� ����������� ������� SET TOOLTIP

   QHTM_EnableCooltips()

   DEFINE WINDOW wMain                      ;
         At 0, 0                           ;
         WIDTH 780                         ;
         HEIGHT 565                        ;
         TITLE 'QHTM & SQLite3 Usage Demo' ;
         Main                              ;
         On init ReSize()                  ;
         On maximize ReSize()              ;
         On size ReSize()

      // ������� ����

      DEFINE MAIN MENU

         DEFINE POPUP 'File'
            MENUITEM 'Change folder' Action ChangeFolder()
            SEPARATOR
            MENUITEM 'Exit Alt+X'    Action AppDone()
         END POPUP

         DEFINE POPUP 'View'
            MENUITEM 'Less save to disk' Action SetMarker() ;
               Name pdLess        ;
               Checked
         END POPUP

         DEFINE POPUP 'Record'
            MENUITEM 'Add files to base' Action AddToBase()
            MENUITEM 'Delete record'     Name pdDelete      ;
               Action DelRecord() ;
               Disabled
         END POPUP

         DEFINE POPUP 'Tests'
            MENUITEM 'Print'    Action DemoPrint()
            SEPARATOR
            MENUITEM 'Web-form' Action DemoSubmit()
         END POPUP

         DEFINE POPUP 'Info'
            MENUITEM 'Get HTML title' Action GetHTMLTitle()
            MENUITEM 'Get sizes'      Action GetHTMLSize()
         END POPUP

      END MENU

      @ LOGO_TOP, LOGO_LEFT QHTM HtmlLogo of wMain ;
         Resource 'TOPBAR'                          ;
         WIDTH 760                                  ;
         HEIGHT LOGO_HEIGHT                         ;
         Border

      // ������ ������/�������

      DEFINE TAB tbData         ;
            at TB_TOP, TB_LEFT ;
            WIDTH TB_WIDTH     ;
            HEIGHT 105         ;
            On change SwitchTab()

         Page 'Files'

            @ 32, 5 Grid grdFiles           ;
               WIDTH ( TB_WIDTH - 10 ) ;
               HEIGHT 360              ;
               Widths { 200 }          ;
               NoHeaders               ;
               On Change ShowMe()      ;
               Tooltip ( '<img src="res:INFO" align="right">List files in <br><font color="blue"><b>' + ;
               aParams[ 'StartDir' ] + '</font></b>' )

         END PAGE

         Page 'Records'

            @ 32, 5 Grid grdRecords          ;
               WIDTH ( TB_WIDTH - 10 )  ;
               HEIGHT 360               ;
               Widths { 50, 180 }       ;
               Headers { 'ID', 'Name' } ;
               On Change ShowMe()       ;
               Tooltip ( '<img src="res:INFO">List of pictures, stored in a base' )

         END PAGE

      END TAB

      @ DATA_TOP, DATA_LEFT QHTM HtmlData of wMain ;
         Value cHTML                                ;
         WIDTH 505                                  ;
         HEIGHT 105                                 ;
         Border

      DEFINE CONTEXT menu control HtmlData
         MENUITEM 'View HTML source' action ViewSource()
      END MENU

      DEFINE STATUSBAR
         StatusItem aParams[ 'StartDir' ] Action ChangeFolder() Tooltip 'Current folder'
         StatusItem 'Exit Alt+X without confirm' Width IF(IsXPThemeActive(), 72, 68) Action AppDone() Tooltip 'Click here for exit with confirmation'
      END STATUSBAR

   END WINDOW

   On Key Alt+X of wMain Action AppDone( .T. )

   ListFiles()     // ��������� ������ ������
   ChangeStyle( GetControlHandle( 'tbData', 'wMain' ), WS_FLAT, , .T. )

   CENTER WINDOW wMain
   ACTIVATE WINDOW wMain

   RETURN

   ****** End of Main ******

   /******
   *       ReSize()
   *       ���������� � ������������ �������� ��������� ��� ���������
   *       ������� ����
   */

STATIC PROCEDURE ReSize

   LOCAL nWidth   := ( wMain.Width - 2 * GetBorderWidth() )                                                   , ;
      nHeight  := ( wMain.Height - GetTitleHeight() - ( 2 * GetBorderHeight() ) - GetMenuBarHeight() - 20 ), ;
      nHeight1

   nHeight1 := ( nHeight - DATA_TOP - 5 )

   wMain.HtmlLogo.Width    := ( nWidth - 2 * LOGO_LEFT )
   wMain.tbData.Height     := nHeight1
   wMain.grdFiles.Height   := ( nHeight1 - 40 )
   wMain.grdRecords.Height := ( nHeight1 - 40 )
   wMain.HtmlData.Width    := ( nWidth - TB_LEFT - TB_WIDTH - 2 * LOGO_LEFT  )
   wMain.HtmlData.Height   := nHeight1

   RETURN

   ****** End of ReSize ******

   /******
   *       AppDone( lForce )
   *       ���������� ������
   */

STATIC PROCEDURE AppDone( lForce )

   LOCAL cMsg       := ( '<img src="res:THINK" border="0" hspace="20">' + ;
      '<font size=+4>  Are you sure that you <i><font color="red">really</font></i> want to <b>exit</b> ?   </font>' + ;
      '<img src="res:TEAR" border="0" hspace="20">'    ;
      )                                                , ;
      cTmpSource := ( aParams[ 'TmpDir' ] + TMP_SOURCE_TXT )

   DEFAULT lForce to .F.

   IF Iif( !lForce, ( QHTM_MessageBox( cMsg, 'Confirm action' , ( MB_YESNO + MB_DEFBUTTON2 ) ) == IDYES ), .T. )

      QHTM_End()

      // �������� ��������� �������

      CleanTmpFile()

      IF File( cTmpSource )
         ERASE ( cTmpSource )
      ENDIF

      ReleaseAllWindows()

   ENDIF

   RETURN

   ***** End of AppDone *****

   /******
   *      SetMarker()
   *      ��������� �������� �������� ���������� ����� �������
   */

STATIC PROCEDURE SetMarker

   LOCAL lChecked := wMain.pdLess.Checked, ;
      nValue   := wMain.tbData.Value

   lChecked := !lChecked
   wMain.pdLess.Checked := lChecked

   // ���� � ���� �������� ������ ����, ��������� ���������� ���������

   IF ( nValue == 2 )

      IF lChecked
         // ������ ����� ��� ������ �������� �� ��������� ����. ������� ��������
         // �������
         CleanTmpFile()
      ENDIF

      ShowMe()

   ENDIF

   RETURN

   ****** End of SetMarker ******

   /******
   *       CleanTmpFile()
   *       �������� ���������� ����� �������, ������������ �� ����
   *       ��� ������ � ����
   */

STATIC PROCEDURE CleanTmpFile

   LOCAL cFile := ( aParams[ 'TmpDir' ] + aParams[ 'TmpFilePict' ] )

   IF !Empty( aParams[ 'TmpFilePict' ] )
      IF File( cFile )
         ERASE ( cFile )
      ENDIF
   ENDIF

   RETURN

   ****** End of CleanTmpFile ******

   /*****
   *       OpenBase() --> pHandleDB
   *       ��������/�������� ��
   */

STATIC FUNCTION OpenBase

   LOCAL lExistDB  := File( DB_NAME )             , ;
      pHandleDB := SQLite3_Open( DB_NAME, .T. ), ;
      cCommand

   IF !Empty( pHandleDB )

      // ��� auto_vacuum = 0 ����� ���������� �������� �������� ������ ������ ����� �� �� ����������.
      // ������������ ����� ���������� ��� "���������" � ����� �������� �������������� �
      // ����������� ��������� ���������� ����� �������.
      // ��� ���������� ������� ����� ���������� ��������� ������� Vacuum

      SQLite3_Exec( pHandleDB, 'PRAGMA auto_vacuum = 0' )

      IF !lExistDB

         // ������ �������

         cCommand := 'Create table if not exists Picts( Id INTEGER PRIMARY KEY AUTOINCREMENT, Name TEXT, Image BLOB );'
         SQLite3_Exec( pHandleDB, cCommand )

      ENDIF

   ENDIF

   RETURN pHandleDB

   ****** End of OpenBase ******

   /******
   *      SwitchTab()
   *      ��������� ������������ ����� �������� (�����-������)
   */

STATIC PROCEDURE SwitchTab

   LOCAL nValue := wMain.tbData.Value

   CleanTmpFile()

   // ��������� ��������� ��������

   IF ( nValue == 1 )              // ������� ������
      ListFiles()
      wMain.pdDelete.Enabled :=.F.
      wMain.grdFiles.SetFocus

      ElseIf( nValue == 2 )           // ������� �������
      ListRecords()
      wMain.pdDelete.Enabled :=.T.
      wMain.grdRecords.SetFocus

   ENDIF

   ShowMe()

   RETURN

   ****** End of SwitchTab ******

   /******
   *       ListFiles()
   *       ������������ ������ ����������� ������
   */

STATIC PROCEDURE ListFiles

   LOCAL nPos   := wMain.grdFiles.Value, ;
      aFiles := {}

   IF aParams[ 'ReadFiles' ]

      // ���������� ������ ��������� ���� ������

      AEval( Directory( aParams[ 'StartDir' ] + '\*.jpg'  ), { | elem | AAdd( aFiles, Lower( elem[ F_NAME ] ) ) } )
      AEval( Directory( aParams[ 'StartDir' ] + '\*.jpeg' ), { | elem | AAdd( aFiles, Lower( elem[ F_NAME ] ) ) } )
      AEval( Directory( aParams[ 'StartDir' ] + '\*.png'  ), { | elem | AAdd( aFiles, Lower( elem[ F_NAME ] ) ) } )
      AEval( Directory( aParams[ 'StartDir' ] + '\*.gif'  ), { | elem | AAdd( aFiles, Lower( elem[ F_NAME ] ) ) } )
      AEval( Directory( aParams[ 'StartDir' ] + '\*.bmp'  ), { | elem | AAdd( aFiles, Lower( elem[ F_NAME ] ) ) } )
      AEval( Directory( aParams[ 'StartDir' ] + '\*.ico'  ), { | elem | AAdd( aFiles, Lower( elem[ F_NAME ] ) ) } )

      wMain.grdFiles.DeleteAllItems

      IF !Empty( aFiles )

         ASort( aFiles, { | x, y | x < y } )       // ��������� ������

         wMain.grdFiles.DisableUpdate              // ������ �� ���������� ����� (��������� ��� ������� ���������� ����������� ������ � �����)

         AEval( aFiles, { | elem | wMain.grdFiles.AddItem( { elem } ) } )

         wMain.grdFiles.EnableUpdate               // ��������� �������� ����������� ��������� � �����

         // ��� ���������� ������ �������� �������� ������� ��������� ���������

         IF !aParams[ 'SavePos' ]

            wMain.grdFiles.Value := 1
            wMain.grdFiles.SetFocus

            aParams[ 'SavePos' ] := .T.

         ELSE

            IF ( nPos > 0 )
               wMain.grdFiles.Value := nPos
            ENDIF

         ENDIF

      ENDIF

      aParams[ 'ReadFiles' ] := .F.

   ENDIF

   RETURN

   ****** End of ListFiles ******

   /******
   *       ListRecords()
   *       ���������� ������� ��������� � �� �������
   */

STATIC PROCEDURE ListRecords

   LOCAL aData, ;
      aItem

   IF aParams[ 'Reload' ]

      wMain.grdRecords.DeleteAllItems

      aData := Do_SQL_Query( 'Select Id, Name from Picts Order by Name;' )

      IF !Empty( aData )

         FOR EACH aItem in aData
            // � ������� ������ 2 ����: ������������� � ��� �����
            wMain.grdRecords.AddItem( { aItem[ 1 ], aItem[ 2 ] } )
         NEXT

         wMain.grdRecords.Value := 1

      ENDIF

      // ���������� ���������������� ������ �������, ��������� � ��
      // ������� ��������������� ��� ������������� ��� ����� ���������� �
      // �������� �������

      aParams[ 'Reload' ] := .F.

   ENDIF

   RETURN

   ****** End of ListRecords ******

   /******
   *       Do_SQL_Query( cQuery ) --> aResult
   *       ���������� �������
   */

STATIC FUNCTION Do_SQL_Query( cQuery )

   LOCAL pStatement := SQLite3_Prepare( aParams[ 'pDB' ], cQuery ), ;
      aResult    := {}                                         , ;
      aTmp                                                     , ;
      nColAmount                                               , ;
      Cycle                                                    , ;
      nType

   IF !Empty( pStatement )

      DO WHILE ( SQlite3_Step( pStatement ) == SQLITE_ROW )

         IF ( ( nColAmount := SQLite3_Column_Count( pStatement ) ) > 0 )

            aTmp := Array( nColAmount )
            AFill( aTmp, '' )

            FOR Cycle := 1 to nColAmount

               nType := SQLite3_Column_Type( pStatement, Cycle )

               DO CASE
               CASE ( nType == SQLITE_NULL )
               CASE ( nType == SQLITE_FLOAT )
               CASE ( nType == SQLITE_INTEGER )
                  aTmp[ Cycle ] := LTrim( Str( SQLite3_Column_Int( pStatement, Cycle ) ) )

               CASE ( nType == SQLITE_TEXT )
                  aTmp[ Cycle ] := SQLite3_Column_Text( pStatement, Cycle )

               CASE ( nType == SQLITE_BLOB )
                  aTmp[ Cycle ] := SQLite3_Column_Blob( pStatement, Cycle )

               ENDCASE

            NEXT

            AAdd( aResult, aTmp )

         ENDIF

      ENDDO

      SQLite3_Finalize( pStatement )

   ENDIF

   RETURN aResult

   ****** End of Do_SQL_Query ******

   /******
   *       HTMLForFile( cFile ) --> cHTML
   *       ������������ ������ ���-�������� ��� ������������� �����
   */

STATIC FUNCTION HTMLForFile( cFile )

   LOCAL cFullName := ( aParams[ 'StartDir' ] + '\' + cFile ), ;
      cHTML     := ''                                     , ;
      aFileInfo

   aFileInfo := Directory( cFullName )

   cHTML += ( '<html>' + ;
      '<title>Info for file</title>' + ;
      '<body margintop=10 marginbottom=10 marginleft=10 marginright=10>' + ;
      CRLF + '<p>' + CRLF )
   cHTML += ( '<IMG src="' + cFullName + '" ' + ;
      'align="left" hspace=20 vspace=20 border=0><br>' + CRLF )

   // ���������� � ����� (CRLF ������������ �� �����������; ������ ���� ��������
   // ������������� ��������� ���������� �����, �������� ��������� � �����
   // MsgBox( cHTML ) )

   cHTML += ( '<b><font size=+2>File: </font></b>' + cFile + CRLF )
   cHTML += ( '<br><b><font size=+2>Size: </font></b>' + LTrim( Str( aFileInfo[ 1, F_SIZE ] ) ) + ' byte' + CRLF )
   cHTML += ( '<br><b><font size=+2>Date: </font></b>' + DtoC( aFileInfo[ 1, F_DATE ] ) + CRLF )
   cHTML += ( '<br><b><font size=+2>Time: </font></b>' + aFileInfo[ 1, F_TIME ] + CRLF )

   cHTML += ( '</p>' + CRLF + '</body>' + CRLF + '</html>' )

   RETURN cHTML

   ****** End of HTMLForFile ******

   /******
   *       HTMLForRec( cID, cName, cImage, lForce ) --> cHTML
   *       ������������ ������ ���-�������� ��� ������ ��
   */

STATIC FUNCTION HTMLForRec( cID, cName, cImage, lForce )

   LOCAL lChecked  := wMain.pdLess.Checked                  , ;
      cFile := ( aParams[ 'TmpDir' ] + AllTrim( cName ) ), ;
      cHTML := ''

   DEFAULT lForce to .F.    // �������������� ����� �����������

   IF ( !lChecked .or. lForce )
      CleanTmpFile()
      MemoWrit( cFile, cImage )
      aParams[ 'TmpFilePict' ] := AllTrim( cName )   // �������� ��� ���������� ����� (��� ����������� �������)
   ENDIF

   cHTML += ( '<html>' + ;
      '<title>Info for record</title>' + ;
      '<body margintop=10 marginbottom=10 marginleft=10 marginright=10>' + ;
      CRLF + '<p>' + CRLF )

   IF ( !lChecked .or. lForce )
      // ����� � ��������� ���������� �����
      cHTML += ( '<IMG src="' + cFile + '" ' + ;
         'align="left" hspace=20 vspace=20 border=0><br>' + CRLF )
   ELSE
      // �������� ������������ �� ��������� ���� �� ����������
      cHTML += '<A href="COMMAND:VIEWIMAGE" title="Click for view with image">'
      cHTML += ( '<IMG src="res:GALLERY" align="left" hspace=20 vspace=20 border=0></A><br>' + CRLF )
   ENDIF

   cHTML += ( '<b><font size=+2>Record: </font></b>' + cID + CRLF )

   cHTML += ( '</p>' + CRLF + '</body>' + CRLF + '</html>' )

   RETURN cHTML

   ****** End of HTMLForRec ******

   /******
   *       ShowMe( lForce )
   *       ����������� ����������
   */

STATIC PROCEDURE ShowMe( lForce )

   LOCAL nValue := wMain.tbData.Value, ;
      nPos                        , ;
      cID                         , ;
      cHTML  := ''                , ;
      aData

   DEFAULT lForce to .F.

   IF ( nValue == 1 )
      nPos := wMain.grdFiles.Value
      ElseIf( nValue == 2 )
      nPos := wMain.grdRecords.Value
   ENDIF

   IF !Empty( nPos )

      IF ( nValue == 1 )
         cHTML := HTMLForFile( wMain.grdFiles.Item( nPos )[ 1 ] )

      ELSE

         cID   := wMain.grdRecords.Item( nPos )[ 1 ]
         aData := Do_SQL_Query( 'Select Name, Image from Picts Where Id = ' + cId + ';' )

         cHTML := HTMLForRec( cID, aData[ 1, 1 ], aData[ 1, 2 ], lForce )

      ENDIF

   ENDIF

   // �������� ������� ������. ������� �������� ����� �� ����������� � ���������
   // �������. ��������, ��� ������� ����� ����� ������������� ������� QHTM_RenderHTML()
   // � QHTM_RenderHTMLRect(). �� ������ � ���� �� �������� ������� ������� (��� registered only?),
   // � ������ ����������� BCC ������������ ������������.

   SetWindowText( HWND_HTMLDATA, cHTML )

   IF lForce
      CleanTmpFile()
   ENDIF

   RETURN

   ****** End of ShowMe ******

   /******
   *       ChangeFolder()
   *       ����� �������� ��������
   */

STATIC PROCEDURE ChangeFolder

   LOCAL cFolder := GetFolder( 'Select folder', aParams[ 'StartDir' ] )

   IF !Empty( cFolder )

      aParams[ 'StartDir'  ] := cFolder
      aParams[ 'ReadFiles' ] := .T.
      aParams[ 'SavePos'   ] := .F.

      ListFiles()

      wMain.StatusBar.Item( 1 ) := aParams[ 'StartDir' ]

      ShowMe()

   ENDIF

   RETURN

   ****** End of ChangeFolder ******

   /******
   *       AddToBase()
   *       ���������� ������� � ����
   */

STATIC PROCEDURE AddToBase

   LOCAL aFiles     := GetFile( { { 'Images', '*.jpg;*.jpeg;*.png;*.gif;*.bmp;*.ico' } }, ;
      'Open file(s)'                                          , ;
      aParams[ 'StartDir' ], .T., .T. )                       , ;
      pStatement                                                                     , ;
      cFile                                                                          , ;
      cName                                                                          , ;
      cExt                                                                           , ;
      cImage                                                                         , ;
      nTab       := wMain.tbData.Value

   IF !Empty( aFiles )

      SQLite3_Exec( aParams[ 'pDB' ], 'Begin transaction "DoIt";' )
      pStatement := SQLite3_Prepare( aParams[ 'pDB' ], 'Insert into Picts( Name, Image ) Values( :Name, :Image )' )

      IF !Empty( pStatement )

         FOR EACH cFile in aFiles

            cImage := SQLite3_File_to_buff( cFile )
            cName := cExt := ''

            HB_FNameSplit( cFile, , @cName, @cExt )

            IF ( ( SQLite3_Bind_Text( pStatement, 1, ( cName + cExt )) == SQLITE_OK ) .and. ;
                  ( SQLite3_Bind_Blob( pStatement, 2, @cImage )         == SQLITE_OK )       ;
                  )

               IF ( SQLite3_Step( pStatement ) == SQLITE_DONE )
                  aParams[ 'Reload' ] := .T.
               ENDIF
               SQLite3_Reset( pStatement )

            ENDIF

         NEXT

         SQLite3_Clear_bindings( pStatement )
         SQLite3_Finalize( pStatement )

         IF aParams[ 'Reload' ]
            SQLite3_Exec( aParams[ 'pDB' ], 'Commit transaction "DoIt";' )
         ELSE
            SQLite3_Exec( aParams[ 'pDB' ], 'Rollback transaction "DoIt";' )
         ENDIF

      ENDIF

   ENDIF

   IF ( nTab == 2 )
      ListRecords()
   ENDIF

   RETURN

   ****** End of AddToBase ******

   /******
   *       DelRecord()
   *       �������� ������ �� ����
   */

STATIC PROCEDURE DelRecord

   LOCAL nTab     := wMain.tbData.Value    , ;
      nPos     := wMain.grdRecords.Value, ;
      cID                               , ;
      cCommand                          , ;
      nCount                            , ;
      cMsg

   IF !( nTab == 2 )

      RETURN
   ENDIF

   IF !Empty( nPos )

      cMsg := ( '<img src="res:CRAZY" border="0" hspace="20" vspace="20">'                    + ;
         '<strong><font color="red" size=+5>Are you want to delete of the current record?</font></strong>'   ;
         )

      IF ( QHTM_MessageBox( cMsg, 'Confirm action', ( MB_YESNO + MB_DEFBUTTON2 ) ) == IDYES )

         cID := wMain.grdRecords.Item( nPos )[ 1 ]
         cCommand := ( 'Delete from Picts Where Id = ' + cId + ';' )

         IF ( SQLite3_Exec( aParams[ 'pDB' ], cCommand ) == SQLITE_OK )

            // ���������� ������

            aParams[ 'Reload' ] := .T.
            ListRecords()

            // �� �����������, ��������� �������� �� ��� �� �������

            nCount := wMain.grdRecords.ItemCount

            nPos := Iif( ( nPos >= nCount ), nCount, nPos )
            wMain.grdRecords.Value := nPos

            ShowMe()

         ENDIF

      ENDIF

   ENDIF

   wMain.grdRecords.SetFocus

   RETURN

   ****** End of DelRecord ******

   /******
   *       MyEvents( hWnd, nMsg, wParam, lParam )
   *       ���������������� ��������� �������.
   *       ����� ����� ��������� ������� ������� �������� � �������� �� �������
   *       � QHTM
   */

FUNCTION MyEvents( hWnd, nMsg, wParam, lParam )

   LOCAL nPos , ;
      cLink

   // � �������� QHTM �� C ��� ����������� ������� �� ����� ������ ������������
   // ��������� ��������� ( nMsg == WM_COMMAND ) � ����������� ���������� ��
   // LOWORD(wParam). �� ����� ����� ����� �� �����������. ������������� ����
   // �� WM_NOTIFY

   IF ( nMsg == WM_NOTIFY )

      // ������������������ �������� nPos := AScan() + _HMG_aControlNames[ nPos ]
      // (��� nPos := AScan() + (_HMG_aControlType[ nPos ] == 'QHTM' ) ), ������,
      // �����������. ��� �� ��������� ������� � [������ �� ����� ���� "read"]

      IF ( ( nPos := AScan( _HMG_aControlIds , wParam ) ) > 0 )

         IF ( ( _HMG_aControlNames[ nPos ] == 'HtmlLogo' ) .or. ;
               ( _HMG_aControlNames[ nPos ] == 'HtmlData' )      ;
               )                                                        // ��������� �� ����� ��������...
            // If ( _HMG_aControlType[ nPos ] == 'QHTM' )                  // ...��� �� ����

            // ����� ����� ���� ��������� ��������� ������� �� ����� ������.
            // ����� � HTML �������� ��������� ������:
            // <a href="http://www.gipsysoft.com">GipsySoft</a>
            // <br><a href="COMMAND:32774">Display QHTM_Box</a>
            // (������� �� ���� QHTM � ����������� ���� ���������)

            // 1-� ������� ���������
            // If ( QHTM_GetNotify( lParam ) == 'COMMAND:32774' )
            //   MsgBox( 'Display QHTM_Box' )
            // Endif
            // ��������:
            // - ��� ������ ������ "Display QHTM_Box" ������������ ���� ��������� �
            //   ����� �� ���� ����������� ������� �� ��������� "command:32774" � ������ ������
            // - ��� ������ ������ "GipsySoft" ����������� ������� ��� �������� �� http://www.gipsysoft.com

            // 2-� ������� ���������
            // If ( QHTM_GetLink( lParam ) == 'COMMAND:32774' )
            //   MsgBox( 'Display QHTM_Box' )
            // Endif
            // ��������:
            // - ��� ������ ������ "Display QHTM_Box" ������������ ���� ���������
            // - ��� ������ ������ "GipsySoft" - ������� �������. QHTM_GetLink( lParam )
            //   ����� ���������� "http://www.gipsysoft.com"

            // 3-� ������� ���������
            // � ���� ������:
            // - ��� ������ ������ "Display QHTM_Box" ������������ ���� ���������
            // - ��� ������ ������ "GipsySoft" ����������� ������� ��� �������� �� http://www.gipsysoft.com

            IF ( ID_COMMAND $ QHTM_GetNotify( lParam ) )

               cLink := QHTM_GetLink( lParam )

               IF ( cLink == ID_COMMAND_EXPLORER )              // ������� ������� ����� � ����������
                  Execute operation 'Open' file aParams[ 'StartDir' ]

               ELSEIF ( cLink == ID_COMMAND_CHANGEFOLDER )      // �������� ������� �����
                  ChangeFolder()

               ELSEIF ( cLink == ID_COMMAND_VIEWIMAGE )         // �������� ����������� � ������
                  ShowMe( .T. )

               ENDIF

            ENDIF

         ENDIF

      ENDIF

   ELSEIF ( nMsg == WM_CTLCOLORSTATIC )

      // ��� ������������� QHTM � ��������� Label �������� �������� ��������� �����
      // ������ (��������, Form_1.Label_1.FontColor := RED). ������� ������� ���������
      // � �������� ������� � ��������� ����������.

      RETURN Events( hWnd, nMsg, wParam, lParam )

   ENDIF

   Events( hWnd, nMsg, wParam, lParam )

   RETURN 0

   ****** End of MyEvents ******

   /******
   *       GetHTMLTitle()
   *       �������� ��������� HTML-��������
   *       (� �������� ������ �������� �� ������ ����������� ����� ������
   *       <title></title>)
   */

STATIC PROCEDURE GetHTMLTitle

   LOCAL cMsg := ( '<p>Data area has title:<br><br><i><font color="blue" size=+3>"' + ;
      QHTM_GetTitle( HWND_HTMLDATA ) + '"</font></i></p>' )

   QHTM_MessageBox( cMsg, 'Get title' )

   RETURN

   ****** End of GetHTMLTitle ******

   /******
   *       GetHTMLSize()
   *       ���������� ������� ������� HTML
   */

STATIC PROCEDURE GetHTMLSize

   LOCAL aSize := QHTM_GetSize( HWND_HTMLDATA ), ;
      cMsg  := ''

   IF !Empty( aSize )

      cMsg += '<p><b>QHTM_GetSize() for HTML</b></p><p>'
      cMsg += ( 'Height:' + Str( aSize[ 2 ] )  + '<br>' )
      cMsg += ( 'Width :'  + Str( aSize[ 1 ] ) + '<br>' )
      cMsg += '</p><p><b>MiniGUI control</b></p><p>'
      cMsg += ( 'Height:' + Str( wMain.HtmlData.Height ) + '<br>' )
      cMsg += ( 'Width :' + Str( wMain.HtmlData.Width ) + '</p>' )

      QHTM_MessageBox( cMsg, 'Get sizes' )

   ENDIF

   RETURN

   ****** End of GetHTMLSize ******

   /******
   *       ViewSource()
   *       �������� ��������� ����
   */

STATIC PROCEDURE ViewSource

   LOCAL cFile := ( aParams[ 'TmpDir' ] + TMP_SOURCE_TXT )

   // ���������� HTML-��� �� ��������� ����

   MemoWrit( cFile, GetWindowText( HWND_HTMLDATA ) )

   IF File( cFile )
      Execute operation 'Open' file cFile
   ENDIF

   RETURN

   ****** End of ViewSource ******

   /******
   *       DemoPrint()
   *       ��������� ������������� ���-��������
   */

STATIC PROCEDURE DemoPrint

   LOCAL cHTMLFile := HTML_PRINT_DEMO, ;
      cCaption

   DEFINE WINDOW wForm       ;
         At 0, 0            ;
         WIDTH 500          ;
         HEIGHT 500         ;
         TITLE 'Print demo' ;
         Modal

      @ 5, 5 QHTM HtmlForm of wForm ;
         File cHTMLFile         ;
         WIDTH 480              ;
         HEIGHT 350             ;
         Border

      @ 370, 160 Button btnPrint ;
         Caption 'Print' ;
         WIDTH 150       ;
         HEIGHT 80       ;
         Action PrintHTML( cHTMLFile )

   END WINDOW

   // ��������� ���-�������� �� ������ � �������� ����� �������

   QHTM_SetHTMLButton( GetControlHandle( 'btnPrint', 'wForm' ) )

   cCaption := ( '<p align="center"><img src="res:THINK" border="0" hspace="20" align="middle">' + ;
      '<font color="green" size=+2><b>Print</font></b>' )

   wForm.btnPrint.Caption := cCaption

   On Key Escape of wForm Action wForm.Release
   On Key Alt+X of wForm Action AppDone( .T. )

   CENTER WINDOW wForm
   ACTIVATE WINDOW wForm

   RETURN

   ****** End of DemoPrint ******

   /******
   *       PrintHTML( cHTMLFile )
   *       ������ ���-��������
   */

STATIC PROCEDURE PrintHTML( cHTMLFile )

   LOCAL hContext   , ;
      nCountPages, ;
      Cycle

   INIT PrintSys
   SELECT by dialog

   IF !Empty( HBPRNERROR )

      RETURN
   ENDIF

   // ��������� ������ � ���������� �����, ������������ ����� �������

   SET orientation PORTRAIT
   SET PaperSize DMPAPER_A4
   SET print margins Top 2 Left 5
   SET Preview on
   SET preview rect 0, 0, GetDesktopRealHeight(), GetDesktopRealWidth()
   SET preview scale 2
   SET thumbnails on

   hContext := QHTM_PrintCreateContext()

   Start doc name 'Print form'

   IF QHTM_PrintSetTextFile( hContext, cHTMLFile )

      // HBPrn - ������, ����������� Init PrintSys
      // HBPrn : hDC - �������� ���������� ������

      nCountPages := QHTM_PrintLayout( HBPrn : hDC, hContext )

      FOR Cycle := 1 to nCountPages
         Start Page
         QHTM_PrintPage( HBPrn : hDC, hContext, Cycle )
      END PAGE
   NEXT

ENDIF

END Doc

QHTM_PrintDestroyContext( hContext )
RELEASE PrintSys

RETURN

****** End of PrintHTML ******

/******
*       DemoSubmit()
*       ������������� ���-����
*/

STATIC PROCEDURE DemoSubmit

   LOCAL cHTMLFile := HTML_SUBMIT_DEMO

   DEFINE WINDOW wForm        ;
         At 0, 0             ;
         WIDTH 495           ;
         HEIGHT 385 + Iif( IsAppThemed(), 8, 0 ) ;
         TITLE 'Submit demo' ;
         Modal               ;
         NOSIZE

      @ 5, 5 QHTM HtmlForm of wForm ;
         File cHTMLFile         ;
         WIDTH 480              ;
         HEIGHT 350             ;
         Border

   END WINDOW

   On Key Escape of wForm Action wForm.Release
   On Key Alt+X of wForm Action AppDone( .T. )

   CENTER WINDOW wForm
   ACTIVATE WINDOW wForm

   RETURN

   ****** End of DemoSubmit ******

   /******
   *       QhtmFormProc( ControlHandle, cMethod, cAction, cName, aFields )
   *       ������� �������� ��������� ���������:
   *       - ControlHandle - ������������� ������� QHTM
   *       - cMethod       - ����� (POST)
   *       - cAction       - ���������� ( http://127.0.0.1/cgi-win/myapp.exe)
   *       - cName         - ������������ ����� (� ���� <FORM></FORM>)
   *       - aFields       - ��������� ������ ����������� ������ ("������������� ����"-"��������")
   *       ��������� ������ ���-����
   *       ! 1) ������� ������ ���������� ������ ���: QhtmFormProc()
   *            (�������� "������" � ���������� ���������� HMG_QHTM)
   *         2) ������� �� �.�. ��������� ��� Static
   */

PROCEDURE QhtmFormProc( ControlHandle, cMethod, cAction, cName, aFields )

   LOCAL nCycle        , ;
      cMessage := '', ;
      nCount

   HB_SYMBOL_UNUSED( ControlHandle )

   nCount := Len( aFields )

   IF ( Valtype( cName ) == 'C' )
      cMessage += ( 'Name of form: ' + cName + CRLF )
   ENDIF

   cMessage += ( 'Method       : ' + cMethod                + CRLF + ;
      'Action       : ' + cAction                + CRLF + ;
      'Amount fields: ' + LTrim( Str( nCount ) ) + CRLF   ;
      )

   FOR nCycle := 1 to nCount
      cMessage += ( aFields[ nCycle, 1 ] + '  -  ' + aFields[ nCycle, 2 ] + CRLF )
   NEXT

   MsgInfo( cMessage, 'Web-form filling' )

   RETURN

   ****** End of QhtmFormProc ******

   // C-level functions

#pragma BEGINDUMP

#define HB_OS_WIN_USED
#define _WIN32_WINNT 0x0400
#include <windows.h>
#include "hbapi.h"

/******
*       Real width of desktop
*/

HB_FUNC_STATIC( GETDESKTOPREALWIDTH )
{
   RECT rect;
   SystemParametersInfo( SPI_GETWORKAREA, 1, &rect, 0 );

   hb_retni(rect.right - rect.left);

}

/******
*       Real height of desktop (without taskbar)
*/

HB_FUNC_STATIC( GETDESKTOPREALHEIGHT )
{
   RECT rect;
   SystemParametersInfo( SPI_GETWORKAREA, 1, &rect, 0 );

   hb_retni(rect.bottom - rect.top);
}

#pragma ENDDUMP
