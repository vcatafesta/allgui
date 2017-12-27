/*
with GAL edition (Alexey L. Gustow <gustow33 [dog] mail.ru>)
2011.Oct.01-08
*/

#include "Directry.ch"
#include "Common.ch"
#include "Inkey.ch"
#include "MiniGUI.ch"
#include "Stock.ch"

// Max amount of space character, adde to function name
// at saving to file

#define SPACES_TO_NAME            30
#define SPACES_TO_TYPE            20

// Bims in the catalog

#define SOURCE_PATH               '#Path '        // Path to sources
#define SOURCE_TITLE              '#Title '       // Catalog's description

// Work parameters

#define ONSTART_NONEACTION        1              // No startup action
#define ONSTART_OPENLAST          2              // To open MRU folder
#define SEARCH_EQUAL              1              // Search for exact correspondence
#define SEARCH_ENTRY              2              // Search for matched entry
#define EDITOR_SIMPLEOPEN         1              // To open in editor (without conditions)
#define EDITOR_GOTO               2              // To open and go to string
#define EDITOR_FIND               3              // To open and transfer the search expression

MEMVAR aOptions

MEMVAR gugupath // GAL

/******
*       Stock()
*       Inventory of the distribution's structure
*/

PROCEDURE Main

   // �������� �� ������� ����������� ���������. ��������� ��
   // ������� ���������� ��� ��������� ���������, ���������
   // ��������� ����� ������ ���������� � ����������� ���������.

   IF !DirCheck()
      MsgStop( "Don't create work directories!", 'Fatal error' )
      QUIT
   ENDIF

   SET Navigation Extended
   SET Font To 'Tahoma', 9

   PRIVATE aOptions := ReadOptions()

   //// GAL added (for path to sources)
   PRIVATE gugupath := CurDrive() + ":\" + CurDir()

   SetBaseLang()     // ��������� ����� ���������

   DEFINE WINDOW wStock                                      ;
         At 132, 235                                        ;
         Width 556                                          ;
         Height 403                                         ;
         Title APPTITLE                                     ;
         Icon 'STOCK'                                       ;
         Main                                               ;
         On Init ReSize()                                   ;
         On Size ReSize()                                   ;
         On Maximize ReSize()                               ;
         On Minimize ReSize()

      // ������ ������������

      DEFINE TOOLBAR tbrTools ButtonSize 20, 20
         Button btnNew     Picture 'NEW'     Action NewList()  Tooltip 'Create new list'
         Button btnOpen    Picture 'OPEN'    Action LoadList() Tooltip 'Load list from file'
         Button btnSave    Picture 'SAVE'    Action SaveList() Tooltip 'Save to file'
         Button btnEdit    Picture 'EDIT'    Action OpenFile() Tooltip 'Open in external editor'
         Button btnOptions Picture 'OPTIONS' Action Options()  Tooltip 'Settings'
      End Toolbar

      // ������� ��������� ������� �������, �.�. �� ��������� ����������� ����������.

      // ������� ������. ��� �� ����������, �� ���������� DynamicBackcolor
      // ����� ��������� ������������ ������ ������.

      @ 31, 3 Grid grdContent                                   ;
         Width 535                                         ;
         Height 305                                        ;
         Headers { 'Name', 'Type', 'Comment' }             ;
         Widths { 200, 100, 200 }                          ;
         Font 'Tahoma' Size 10                             ;
         On change GridStatus()                            ;
         NoLines                                           ;
         Edit Inplace {}                                   ;
         ColumnWhen { { || .F. }, { || .F. }, { || .T. } }

      // ������� ������

      @ 340, 5 Label lblSearch    ;
         Value 'Find'       ;
         Width 40 Height 18 ;
         FontColor BLUE     ;
         Bold

      @ ( wStock.lblSearch.Row - 4 ), ( wStock.lblSearch.Col + wStock.lblSearch.Width + 10 ) ;
         TextBox txbSearch                    ;
         Width 400                            ;
         Height 20                            ;
         UpperCase                            ;
         On change QSeek()                    ;
         On enter wStock.grdContent.SetFocus  ;
         Tooltip 'String for search'

      @ wStock.txbSearch.Row, ( wStock.txbSearch.Col + wStock.txbSearch.Width + 5 ) ;
         Button btnSearch   ;
         Picture 'FIND'     ;
         Width 20           ;
         Height 20          ;
         Action QSeek()     ;
         Tooltip 'Find more'

      @ wStock.btnSearch.Row, ( wStock.btnSearch.Col + wStock.btnSearch.Width + 5 ) ;
         Button btnFindAll  ;
         Picture 'FINDALL'  ;
         Width 20           ;
         Height 20          ;
         Action FindAll()   ;
         Tooltip 'Find all'

      // ������ ���������

      DEFINE STATUSBAR
         StatusItem '' Default
         StatusItem '' Width 80 Default
      END STATUSBAR

      On key ALT+X of wStock Action wStock.Release

   END WINDOW

   // ���� ������ �������� ���� � �� � �������, ����������� �������������

   IF ( !Empty( aOptions[ OPTIONS_LANGFILE ] )              .and. ;
         File( LANGFILE_PATH + aOptions[ OPTIONS_LANGFILE ] )      ;
         )
      BuildMenu( GetLangStrings( GET_MENU_LANG, aOptions[ OPTIONS_LANGFILE ] ) )
      ModifyMainForm( GetLangStrings( GET_MAINFORM_LANG, aOptions[ OPTIONS_LANGFILE ] ) )
   ELSE
      BuildMenu()
      ModifyMainForm()
   ENDIF

   // ���� ������� �������������� ��������� ���������� �����

   IF ( aOptions[ OPTIONS_ONSTART ] == ONSTART_OPENLAST )
      IF !Empty( aOptions[ OPTIONS_LASTFILE ] )
         LoadList( aOptions[ OPTIONS_LASTFILE ] )
      ENDIF
   ENDIF

   SetState()

   CENTER WINDOW wStock
   ACTIVATE WINDOW wStock

   RETURN

   ****** End of Main ******

   /*******
   *       DirCheck() --> lSuccess
   *       Checkup and creation of the folders
   */

STATIC FUNCTION DirCheck

   LOCAL lSuccess := .F.

   BEGIN Sequence

      // ������� �����

      IF !CheckPath( DATA_PATH, .T. )
         Break
      ENDIF

      // ������� �������� ������

      IF !CheckPath( LANGFILE_PATH, .T. )
         Break
      ENDIF

      lSuccess := .T.

   End

   RETURN lSuccess

   ****** End of DirCheck ******

   /******
   *       BuildMenu( aStrings )
   *       Building the main menu of the program.
   *       Separate procedure is exuded for possibility of
   *       the change language interface.
   */

PROCEDURE BuildMenu( aStrings )

   IF !( Valtype( aStrings ) == 'A' )
      aStrings := GetLangStrings( GET_MENU_LANG )
   ENDIF

   DEFINE MAIN MENU of wStock

      DEFINE POPUP aStrings[ 1, 2 ]             // File
         MenuItem aStrings[ 2, 2 ] ;
            Action NewList()      ;
            Message aStrings[ 3, 2 ]
         MenuItem aStrings[ 4, 2 ] ;
            Action LoadList()     ;
            Message aStrings[ 5, 2 ]
         MenuItem aStrings[ 6, 2 ] ;
            Action SaveList()     ;
            Name SaveList         ;
            Message aStrings[ 7, 2 ]
         Separator
         MenuItem ( aStrings[ 8, 2 ]  + '   Alt+X' ) ;
            Action ThisWindow.Release                     ;
            Message aStrings[ 9, 2 ]
      End Popup

      DEFINE POPUP aStrings[ 10, 2 ]           // Edit
         MenuItem aStrings[ 11, 2 ] ;
            Action SetTitle()      ;
            Name SetTitle          ;
            Message aStrings[ 12, 2 ]
         Separator
         MenuItem aStrings[ 13, 2 ] ;
            Action OpenFile()      ;
            Name OpenFile          ;
            Message aStrings[ 14, 2 ]
         Separator
         MenuItem aStrings[ 15, 2 ]                      ;
            Action CopyToClipboard( GetNameFunction() ) ;
            Name CopyIt                                 ;
            Message aStrings[ 16, 2 ]
      End Popup

      DEFINE POPUP aStrings[ 17, 2 ]           // Tools
         MenuItem aStrings[ 18, 2 ] ;
            Action Formater()      ;
            Name Reformatter       ;
            Message aStrings[ 19, 2 ]
         MenuItem aStrings[ 20, 2 ]   ;
            Action CallsTable()      ;
            Name CallsTable          ;
            Message aStrings[ 21, 2 ]
      End Popup

      DEFINE POPUP aStrings[ 22, 2 ]           // Service
         DEFINE POPUP aStrings[ 23, 2 ]
            MenuItem aStrings[ 24, 2 ]  ;
               Action SelectLanguage() ;
               Message aStrings[ 25, 2 ]
            Separator
            MenuItem aStrings[ 26, 2 ]    ;
               Action MakeLangTemplate() ;
               Message aStrings[ 27, 2 ]
         End Popup

         Separator
         MenuItem aStrings[ 28, 2 ] ;
            Action Options()       ;
            Message aStrings[ 29, 2 ]
      End Popup

      DEFINE POPUP '?'                         // ?
         MenuItem aStrings[ 30, 2 ]        ;
            Action About( aStrings[ 30, 2 ] ) ;
            Message aStrings[ 31, 2 ]
      End Popup

   End Menu

   RETURN

   ****** End of BuildMenu *****

   /******
   *       ModifyMainForm( aStrings )
   *       Changing of the main window language interface.
   *       Separate procedure is exuded for possibility of
   *       the change language interface.
   */

PROCEDURE ModifyMainForm( aStrings )

   IF !( Valtype( aStrings ) == 'A' )
      aStrings := GetLangStrings( GET_MAINFORM_LANG )
   ENDIF

   // ��������� �������� ����

   wStock.Title := aStrings[ 1, 2 ]

   // ������ ������������

   wStock.tbrTools.btnNew.Tooltip     := aStrings[ 2, 2 ]
   wStock.tbrTools.btnOpen.Tooltip    := aStrings[ 3, 2 ]
   wStock.tbrTools.btnSave.Tooltip    := aStrings[ 4, 2 ]
   wStock.tbrTools.btnEdit.Tooltip    := aStrings[ 5, 2 ]
   wStock.tbrTools.btnOptions.Tooltip := aStrings[ 6, 2 ]

   // ��������� ������� �������

   wStock.grdContent.Header( 1 ) := aStrings[ 7, 2 ]
   wStock.grdContent.Header( 2 ) := aStrings[ 8, 2 ]
   wStock.grdContent.Header( 3 ) := aStrings[ 9, 2 ]

   // ������� ������

   wStock.lblSearch.Value    := aStrings[ 10, 2 ]
   wStock.txbSearch.Tooltip  := aStrings[ 11, 2 ]
   wStock.btnSearch.Tooltip  := aStrings[ 12, 2 ]
   wStock.btnFindAll.Tooltip := aStrings[ 13, 2 ]

   RETURN

   ****** End of ModifyMainForm *****

   /*****
   *       ReSize()
   *       Matching of the sizes list and window
   */

STATIC PROCEDURE ReSize

   LOCAL nWidth  := wStock.Width , ;
      nHeight := wStock.Height

   // �������� ������ ������������� ������

   wStock.grdContent.Row := 31
   wStock.grdContent.Col := 3
   wStock.grdContent.Width  := ( nWidth - 2 * wStock.grdContent.Col - 2 * GetBorderWidth() )
   wStock.grdContent.Height := ( nHeight - wStock.grdContent.Row - GetTitleHeight() - ;
      GetMenubarHeight() - 2 * GetBorderHeight() - 52 )

   IF !Empty( wStock.grdContent.ItemCount )
      wStock.grdContent.ColumnsAutoFit()
   ENDIF

   // ����� ��������� ������

   wStock.lblSearch.Row := ( wStock.grdContent.Row + wStock.grdContent.Height + 10 )
   wStock.lblSearch.Col := wStock.grdContent.Col

   // ���� ����� ���������� �������� � ������ ������

   wStock.txbSearch.Row := ( wStock.lblSearch.Row - 4 )
   wStock.txbSearch.Col := ( wStock.lblSearch.Col + wStock.lblSearch.Width + 10 )
   wStock.txbSearch.Width := ( wStock.grdContent.Width - wStock.lblSearch.Width - ;
      wStock.txbSearch.Col - wStock.btnSearch.Width + 10 )

   wStock.btnSearch.Row := wStock.txbSearch.Row
   wStock.btnSearch.Col := ( wStock.txbSearch.Col + wStock.txbSearch.Width + 5 )

   wStock.btnFindAll.Row := wStock.btnSearch.Row
   wStock.btnFindAll.Col := ( wStock.btnSearch.Col + wStock.btnSearch.Width + 5 )

   RETURN

   ****** End of ReSize ******

   /******
   *       SetState()
   *       Control for the condition of dialog elements
   */

STATIC PROCEDURE SetState

   MEMVAR aOptions

   IF !Empty( wStock.grdContent.ItemCount )

      wStock.SaveList.Enabled    := .T.
      wStock.SetTitle.Enabled    := .T.
      wStock.CopyIt.Enabled      := .T.
      wStock.Reformatter.Enabled := .T.
      wStock.CallsTable.Enabled  := .T.
      wStock.OpenFile.Enabled    := !Empty( aOptions[ OPTIONS_EDITOR ] )

      wStock.btnSave.Enabled := .T.
      wStock.btnEdit.Enabled := !Empty( aOptions[ OPTIONS_EDITOR ] )

      wStock.txbSearch.Enabled := .T.

   ELSE

      wStock.SaveList.Enabled    := .F.
      wStock.SetTitle.Enabled    := .F.
      wStock.CopyIt.Enabled      := .F.
      wStock.Reformatter.Enabled := .F.
      wStock.CallsTable.Enabled  := .F.
      wStock.OpenFile.Enabled    := .F.

      wStock.btnSave.Enabled := .F.
      wStock.btnEdit.Enabled := .F.

      wStock.txbSearch.Enabled := .F.

   ENDIF

   wStock.btnSearch.Enabled  := !Empty( wStock.txbSearch.Value )
   wStock.btnFindAll.Enabled := !Empty( wStock.txbSearch.Value )

   RETURN

   ****** End of SetState ******

   /*****
   *       GridStatus()
   *       Show of the position inside list
   */

STATIC PROCEDURE GridStatus

   wStock.Statusbar.Item( 2 ) := ( LTrim( Str( wStock.grdContent.Value ) )     + ;
      '/'                                         + ;
      LTrim( Str( wStock.grdContent.ItemCount ) )   ;
      )

   RETURN

   ****** End of GridStatus ******

   /*****
   *       NewList()
   *       Formation of the new list
   */

STATIC PROCEDURE NewList

   MEMVAR aOptions
   LOCAL cPath                                                                           , ;
      aStrings  := GetLangStrings( GET_SYSDIALOGS_LANG, aOptions[ OPTIONS_LANGFILE ] ), ;
      aFileList := {}                                                                 , ;
      Cycle                                                                           , ;
      nLen                                                                            , ;
      cNum

   /// GAL added
   IF Empty( aOptions[ OPTIONS_GETPATH ] )
      aOptions[ OPTIONS_GETPATH ] := GetStartUpFolder()
   ENDIF

   IF !Empty( cPath := GetFolder( aStrings[ 6, 2 ], aOptions[ OPTIONS_GETPATH ] ) )

      //// GAL added
      gugupath := cPath
      IF Empty( gugupath )
         gugupath := CurDrive() + ":\" + Curdir()
      ENDIF

      // �������� � ������ ������ .prg
      aFileList := GetFileList( aFileList, ( cPath + '\*.prg' ) )

      // �������� � ������ ������ .c
      aFileList := GetFileList( aFileList, ( cPath + '\*.c' ) )

      IF !Empty( aFileList )

         // ������������ ������: ����� � ����������� *.prg � *.c
         // ������ ��������� �����

         ASort( aFileList, , , { | x, y | BaseCompare( x ) < BaseCompare( y ) } )

         // �������� � ������������ ������

         nLen := Len( aFileList )
         cNum := LTrim( Str( nLen ) )

         // ��������� ���������� � ������ � GRID

         wStock.grdContent.DisableUpdate
         wStock.grdContent.Enabled := .F.
         wStock.grdContent.DeleteAllItems

         FOR Cycle := 1 to nLen

            wStock.Statusbar.Item( 1 ) := aFileList[ Cycle ]
            wStock.Statusbar.Item( 2 ) := ( LTrim( Str( Cycle ) ) + '/' + cNum )

            // ������ ����������� �����

            ParseFile( cPath, aFileList[ Cycle ] )

         NEXT

         wStock.Statusbar.Item( 1 ) := cPath
         wStock.Statusbar.Item( 2 ) := ''

         // ��������� ������������ ���������� �������� � ���� ��� ����������

         aOptions[ OPTIONS_TITLE ] := cPath

         SetTitle()
         SaveList()

         // ������� �������� ���� � �������� ���������

         wStock.grdContent.ColumnsAutoFit
         wStock.grdContent.EnableUpdate
         wStock.grdContent.Enabled := .T.

         wStock.grdContent.Value := 1
         wStock.grdContent.SetFocus

         // ��������� ��������� �������������� �������

         aOptions[ OPTIONS_GETPATH ] := cPath

      ENDIF

   ENDIF

   SetState()
   GridStatus()

   RETURN

   ****** End of NewList *****

   /*****
   *       GetFileList( aFileList, cPattern ) --> aFileList
   *       Entering to the filelist with required extension
   */

STATIC FUNCTION GetFileList( aFileList, cPattern )

   LOCAL aFiles, ;
      Cycle , ;
      nLen

   IF !Empty( aFiles := Directory( cPattern ) )

      nLen := Len( aFiles )
      FOR Cycle := 1 to nLen
         AAdd( aFileList, aFiles[ Cycle, F_NAME ] )
      NEXT

   ENDIF

   RETURN aFileList

   ***** End of GetFileList *****

   /*****
   *       BaseCompare( cValue ) --> cValue
   *       Allocation of the base for compare from the symbol expression
   */

STATIC FUNCTION BaseCompare( cValue )

   // �� ���������� ������� ����������:
   // - ��������� ����� (prg � c) ����� ������������� �����
   // - ����� � ����������� *.prg ������������� ���� ��������� � ���� ������ *.c

   // ������������� � ������������ MiniGUI ����� ����� �������:
   // - ����������� �� �������� H_ (��� *.prg) � C_ (��� *.c) - ����� ����� �����
   //   ������ ������ ���������
   // - ��� *.prg ������� ���������� - ��� ������������� � �������� ��� ����������
   //   ����� ������� ���������

   cValue := Upper( cValue )

   IF ( Left( cValue, 2 ) == 'H_' )
      cValue := Left( cValue, ( Len( cValue ) - 4 ) )
   ENDIF

   IF ( ( Left( cValue, 2 ) == 'H_' ) .or. ;
         ( Left( cValue, 2 ) == 'C_' )      ;
         )
      cValue := Substr( cValue, 3 )
   ENDIF

   RETURN cValue

   ****** End of BaseCompare *****

   /*****
   *       ParseFile( cPath, cFile )
   *       ����� ����������
   */

STATIC PROCEDURE ParseFile( cPath, cFile )

   LOCAL oFile   := TFileRead() : New( cPath + '\' + cFile ), ;
      cString                                            , ;
      nPos                                               , ;
      cType                                              , ;
      cWord

   AddToContent( cFile, '', '' )   // ��������� � ������ ����������� ����

   oFile : Open()
   IF !oFile : Error()

      DO WHILE oFile : MoreToRead()

         cString := oFile : ReadLine()

         IF !Empty( cString )    // ������ ������ ����������

            cString := LTrim( cString )

            // ����������� ����������

            DO CASE
            CASE ( Left( cString, 1 ) == '*' )
               LOOP

            CASE ( Left( cString, 2 ) == '//' )
               LOOP

            CASE ( ( '/*' $ cString ) .and. ( '*/' $ cString ) )
               LOOP

            CASE ( Left( cString, 2 ) == '/*' )

               // ������������� �����������

               DO WHILE oFile : MoreToRead()

                  cString := oFile : ReadLine()

                  IF ( '*/' $ cString )
                     EXIT
                  ENDIF

               ENDDO

               LOOP

            ENDCASE

            // ��������� ����� ���������/������� � �������� �� � ������� ���������

            IF ( Left( cString, 7 ) == 'HB_FUNC' )

               // ������� C (WinAPI)

               IF !Empty( nPos := At( '(', cString ) )

                  cString := Substr( cString, ( nPos + 1 ) )

                  IF !Empty( nPos := At( ')', cString ) )
                     cString := AllTrim( Left( cString, ( nPos - 1 ) ) )
                     AddToContent( ( Space( 3 ) + cString ), 'HB_FUNC', '' )
                  ENDIF

               ENDIF

            ELSE

               // �������� 1-� �����

               IF !Empty( nPos := At( ' ', cString ) )

                  cWord := AllTrim( Left( cString, ( nPos - 1 ) ) )

                  // ��������� ��������� � ������ �������� ����. � ������
                  // ������� ����������� ������� ���������, ����� ����������
                  // ��������

                  cWord += ' '
                  IF !Empty( AScan( { 'STATIC ', 'STATI ', 'STAT ' }     , ;
                        { | elem | elem == Upper( cWord ) } )  ;
                        )
                     cType := 'Static '

                     // � ���� ������ ���������� �������� ������������ ���������

                     cString := AllTrim( Substr( cString, ( nPos + 1 ) ) )

                     IF !Empty( nPos := At( ' ', cString ) )
                        cWord := ( AllTrim( Left( cString, ( nPos - 1 ) ) ) + ' ' )
                     ENDIF

                  ELSE
                     cType := ''

                  ENDIF

                  IF !Empty( cWord )

                     DO CASE
                     CASE !Empty( AScan( { 'PROCEDURE ', 'PROCEDUR ', 'PROCEDU ', ;
                           'PROCED '   , 'PROCE '   , 'PROC '     ;
                           }                                      , ;
                           { | elem | elem == Upper( cWord ) } )    ;
                           )
                        cType += ' Procedure'

                     CASE !Empty( AScan( { 'FUNCTION ', 'FUNCTIO ', 'FUNCTI ' , ;
                           'FUNCT '   , 'FUNC '                 ;
                           }                                    , ;
                           { | elem | elem == Upper( cWord ) } )  ;
                           )
                        cType += ' Function'

                     ENDCASE

                     // ����������� ����� ���������/�������

                     cType := AllTrim( cType )
                     IF ( !Empty( cType ) .and. !( cType == 'Static' ) )
                        cString := AllTrim( Substr( cString, ( nPos + 1 ) ) )

                        // �������� �����, ��� ������� �� ������

                        IF !Empty( nPos := At( '(', cString ) )
                           cString := AllTrim( Left( cString, ( nPos - 1 ) ) )
                        ENDIF

                        IF !Empty( nPos := At( ' ', cString ) )
                           cString := AllTrim( Left( cString, ( nPos - 1 ) ) )
                        ENDIF

                        AddToContent( ( Space( 3 ) + cString ), cType, '' )

                     ENDIF

                  ENDIF

               ENDIF

            ENDIF

         ENDIF

      ENDDO

      oFile : Close()

   ENDIF

   RETURN

   ****** End of ParseFile ******

   /******
   *       AddToContent( cName, cType, cComment )
   *       Addition of the string to list
   */

STATIC PROCEDURE AddToContent( cName, cType, cComment )

   wStock.grdContent.AddItem( { cName, cType, cComment } )

   RETURN

   ****** End of AddToContent ******

   /******
   *       IsFound( cValue, cItem ) --> lFound
   *       Checkup of the presence required fragment in the string
   */

STATIC FUNCTION IsFound( cValue, cItem )

   MEMVAR aOptions
   LOCAL nLen   := Len( cValue ), ;
      lFound := .F.

   // �������� ���������� ������

   IF ( aOptions[ OPTIONS_SEARCH ] == SEARCH_EQUAL )      // ������ ������������
      lFound := ( Upper( Left( AllTrim( cItem ), nLen ) ) == cValue )

   ELSEIF ( aOptions[ OPTIONS_SEARCH ] == SEARCH_ENTRY )  // ��������� ��������� ���������
      lFound := ( cValue $ Upper( AllTrim( cItem ) ) )

   ENDIF

   RETURN lFound

   ****** End of IsFound ******

   /******
   *       QSeek()
   *       Seek into list
   */

STATIC PROCEDURE QSeek

   LOCAL cValue := AllTrim( wStock.txbSearch.Value ), ;
      nPos   := ( wStock.grdContent.Value + 1 )  , ;
      nCount := wStock.grdContent.ItemCount      , ;
      Cycle                                      , ;
      lFound

   wStock.btnSearch.Enabled   := !Empty( cValue )
   wStock.btnFindAll.Enabled  := !Empty( cValue )
   wStock.txbSearch.Backcolor := WHITE

   IF !Empty( cValue )

      // ����� ���������� �� ��������� ������ �������

      FOR Cycle := nPos to nCount

         IF ( lFound := IsFound( cValue, wStock.grdContent.Item( Cycle )[ 1 ] ) )
            wStock.grdContent.Value := Cycle
            EXIT
         ENDIF

      NEXT

      // �������� ������ ���� ���������� ��������, ���� ��������� �� ����������

      IF !lFound
         wStock.txbSearch.Backcolor := { 255, 127, 127 }
      ENDIF

   ENDIF

   RETURN

   ****** End of QSeek ******

   /******
   *       FindAll()
   *       Find all matched enties
   */

STATIC PROCEDURE FindAll

   MEMVAR aOptions
   LOCAL cValue   := AllTrim( wStock.txbSearch.Value )                               , ;
      nCount   := wStock.grdContent.ItemCount                                     , ;
      aStrings := GetLangStrings( GET_FINDALL_LANG, aOptions[ OPTIONS_LANGFILE ] ), ;
      aMatches := {}                                                              , ;
      Cycle                                                                       , ;
      cItem                                                                       , ;
      cFile

   wStock.btnSearch.Enabled  := !Empty( cValue )
   wStock.btnFindAll.Enabled := !Empty( cValue )

   IF !Empty( cValue )

      DEFINE WINDOW wFindAll     ;
            At 0, 0                ;
            Width 350              ;
            Height 300             ;
            Title aStrings[ 1, 2 ] ;
            Icon 'STOCK'           ;
            Modal

         @ 10, 5 Label lblName                                    ;
            Value ( aStrings[ 1, 2 ] + ' [' + cValue + ']' ) ;
            Width 330                                        ;
            Height 18                                        ;
            Bold                                             ;
            FontColor BLUE

         @ ( wFindAll.lblName.Row + wFindAll.lblName.Height + 3 ), wFindAll.lblName.Col ;
            Grid grdMatches                                                  ;
            Width 330                                                        ;
            Height 200                                                       ;
            Headers { aStrings[ 3, 2 ], aStrings[ 4, 2 ], aStrings[ 5, 2 ] } ;
            Widths { 150, 100, 200 }                                         ;
            Font 'Tahoma' Size 10                                            ;
            NoLines                                                          ;
            On DblClick Do_GoTo( aMatches )

         @ ( wFindAll.grdMatches.Row + wFindAll.grdMatches.Height + 10 ), ;
            ( wFindAll.grdMatches.Col + 55 )                               ;
            Button btnGoto                                                 ;
            Caption aStrings[ 6, 2 ]                                       ;
            Action Do_GoTo( aMatches )

         @ wFindAll.btnGoto.Row, ( wFindAll.btnGoto.Col + wFindAll.btnGoto.Width + 30 ) ;
            Button btnCancel                                                             ;
            Caption _HMG_MESSAGE[ 7 ]                                                    ;
            Action wFindAll.Release

         On key Escape of wFindAll Action wFindAll.Release
         On key Alt+X  of wFindAll Action ReleaseAllWindows()

      END WINDOW

      // �������� ��� ���������

      wFindAll.grdMatches.DeleteAllItems

      FOR Cycle := 1 to nCount

         cItem := wStock.grdContent.Item( Cycle )[ 1 ]

         IF !( Left( cItem, 1 ) == Space( 1 ) )
            cFile := AllTrim( cItem )
         ENDIF

         cItem := AllTrim( cItem )

         IF IsFound( cValue, cItem )
            AAdd( aMatches, Cycle )
            wFindAll.grdMatches.AddItem( { cItem, cFile, wStock.grdContent.Item( Cycle )[ 2 ] } )
         ENDIF

      NEXT

      IF Empty( wFindAll.grdMatches.ItemCount )
         wFindAll.btnGoto.Enabled := .F.
      ELSE
         wFindAll.grdMatches.Value := 1
      ENDIF

      CenterInside( 'wStock', 'wFindAll' )
      ACTIVATE WINDOW wFindAll

   ENDIF

   RETURN

   ****** End of FindAll ******

   /******
   *       Do_GoTo( aMatches )
   *       Go to selected position
   */

STATIC PROCEDURE Do_GoTo( aMatches )

   LOCAL nPos := wFindAll.grdMatches.Value

   IF !Empty( nPos )
      nPos := aMatches[ nPos ]
      wFindAll.Release
      wStock.grdContent.Value := nPos
   ENDIF

   RETURN

   ****** End of Do_GoTo ******

   /******
   *       GetNameFunction() --> cName
   *       Reading the cell value (function name)
   */

STATIC FUNCTION GetNameFunction

   LOCAL nValue := wStock.grdContent.Value

   RETURN AllTrim( wStock.grdContent.Cell( nValue, 1 ) )

   ****** End of GetNameFunction ******

   /******
   *       SaveList()
   *       Saving of list to file
   */

STATIC PROCEDURE SaveList

   MEMVAR aOptions
   LOCAL cFile                                  , ;
      nLen     := wStock.grdContent.ItemCount, ;
      Cycle                                  , ;
      cNum                                   , ;
      aStrings := GetLangStrings( GET_SYSDIALOGS_LANG, aOptions[ OPTIONS_LANGFILE ] )

   cFile := PutFile( { { aStrings[ 3, 2 ], '*.txt' }, ;
      { aStrings[ 5, 2 ], '*.*'   }  ;
      }                              , ;
      aStrings[ 7, 2 ]               , ;
      DATA_PATH                      , ;
      .T.                              ;
      )

   IF !Empty( cFile )

      wStock.grdContent.Enabled  := .F.
      cNum                       := LTrim( Str( nLen ) )

      SET ALTERNATE TO ( cFile )
      SET CONSOLE OFF
      SET ALTERNATE ON

      // ������� � �������� �������� ��������, ��������

      ?? SOURCE_PATH + aOptions[ OPTIONS_GETPATH ]
      ?
      ?? SOURCE_TITLE + aOptions[ OPTIONS_TITLE ]
      ?

      FOR Cycle := 1 to nLen

         wStock.Statusbar.Item( 1 ) := AllTrim( wStock.grdContent.Item( Cycle )[ 1 ] )
         wStock.Statusbar.Item( 2 ) := ( LTrim( Str( Cycle ) ) + '/' + cNum )

         ?? PadR( wStock.grdContent.Item( Cycle )[ 1 ], SPACES_TO_NAME ) + Chr( K_TAB )
         ?? PadR( wStock.grdContent.Item( Cycle )[ 2 ], SPACES_TO_TYPE ) + Chr( K_TAB )
         ?? wStock.grdContent.Item( Cycle )[ 3 ]
         ?
      NEXT

      SET ALTERNATE OFF
      SET CONSOLE ON
      SET ALTERNATE TO

      // ��������� ���� ���������� ��������

      aOptions[ OPTIONS_LASTFILE ] := cFile

      BEGIN INI FILE STOCK_INI

         SET SECTION 'MAIN' entry 'LastFile' to aOptions[ OPTIONS_LASTFILE ]

      END INI

      wStock.Statusbar.Item( 1 ) := aOptions[ OPTIONS_GETPATH ]
      wStock.grdContent.Enabled  := .T.
      wStock.grdContent.SetFocus

      GridStatus()

   ENDIF

   RETURN

   ****** End of SaveList ******

   /******
   *      LoadList( cFile )
   *      Loading of list from file
   */

STATIC PROCEDURE LoadList( cFile )

   MEMVAR aOptions
   LOCAL cString , ;
      oFile   , ;
      nPos    , ;
      cName   , ;
      cType   , ;
      cComment, ;
      aStrings

   IF ( cFile == nil )

      aStrings := GetLangStrings( GET_SYSDIALOGS_LANG, aOptions[ OPTIONS_LANGFILE ] )

      cFile := GetFile( { { aStrings[ 3, 2 ], '*.txt' } , ;
         { aStrings[ 5, 2 ], '*.*'   }   ;
         }                               , ;
         aStrings[ 1, 2 ]                , ;
         DATA_PATH                       , ;
         .F.                             , ;
         .T.                               ;
         )
   ENDIF

   IF !Empty( cFile )

      oFile := TFileRead() : New( cFile )

      oFile : Open()

      IF !oFile : Error()

         // ��������� ���������� � ������ � GRID

         wStock.grdContent.DisableUpdate
         wStock.grdContent.Enabled := .F.
         wStock.grdContent.DeleteAllItems

         wStock.Statusbar.Item( 1 ) := ''
         wStock.Statusbar.Item( 2 ) := ''

         // ���������� ����������� �������� �������� ������������������ ��������.

         aOptions[ OPTIONS_GETPATH ] := ''

         DO WHILE oFile : MoreToRead()

            IF !Empty( cString := oFile : ReadLine() )

               // � ������ ������ - ������� � ������������������ ��������.

               IF ( ( Left( cString, Len( SOURCE_PATH ) ) == SOURCE_PATH ) .and. ;
                     Empty( aOptions[ OPTIONS_GETPATH ] )                         ;
                     )
                  aOptions[ OPTIONS_GETPATH ] := AllTrim( Substr( cString, ( Len( SOURCE_PATH ) + 1 ) ) )
                  LOOP

               ELSEIF ( ( Left( cString, Len( SOURCE_TITLE ) ) == SOURCE_TITLE ) .and. ;
                     Empty( aOptions[ OPTIONS_TITLE ] )                             ;
                     )
                  aOptions[ OPTIONS_TITLE ] := AllTrim( Substr( cString, ( Len( SOURCE_TITLE ) +1 ) ) )
                  LOOP

               ENDIF

               // ���������� �������

               IF !Empty( nPos := At( Chr( K_TAB ), cString ) )

                  cType := cComment := ''
                  cName := Left( cString, ( nPos - 1 ) )

                  cString := Substr( cString, ( nPos + 1 ) )

                  IF !Empty( nPos := At( Chr( K_TAB ), cString ) )
                     cType    := AllTrim( Left( cString, ( nPos - 1 ) ) )
                     cComment := AllTrim( Substr( cString, ( nPos + 1 ) ) )
                  ENDIF

                  wStock.Statusbar.Item( 1 ) := AllTrim( cName )
                  AddToContent( cName, cType, cComment )

               ENDIF

            ENDIF

         ENDDO

         oFile : Close()

         wStock.Statusbar.Item( 1 ) := aOptions[ OPTIONS_GETPATH ]
         wStock.Statusbar.Item( 2 ) := ''

         StoreTitle()

         wStock.grdContent.ColumnsAutoFit
         wStock.grdContent.EnableUpdate
         wStock.grdContent.Enabled := .T.

         wStock.grdContent.Value := 1
         wStock.grdContent.SetFocus

         // ��������� ���� ���������� ��������

         aOptions[ OPTIONS_LASTFILE ] := cFile

         BEGIN INI FILE STOCK_INI

            SET SECTION 'MAIN' entry 'LastFile' to aOptions[ OPTIONS_LASTFILE ]

         END INI

      ENDIF

   ENDIF

   SetState()
   GridStatus()

   RETURN

   ****** End of LoadList ******

   /******
   *       SetTitle()
   *       Input/editing of the catalog name
   */

STATIC PROCEDURE SetTitle

   MEMVAR aOptions
   LOCAL aStrings := GetLangStrings( GET_SETTITLE_LANG, aOptions[ OPTIONS_LANGFILE ] )

   DEFINE WINDOW wSetTitle       ;
         At 132, 235            ;
         Width 406              ;
         Height 142             ;
         Title aStrings[ 1, 2 ] ;
         Icon 'STOCK'           ;
         Modal

      @ 10, 5 Label lblName          ;
         Value aStrings[ 2, 2 ] ;
         Width 100              ;
         Height 18              ;
         Bold                   ;
         FontColor BLUE

      @ ( wSetTitle.lblName.Row + wSetTitle.lblName.Height + 10 ), wSetTitle.lblName.Col ;
         TextBox txbName                 ;
         Height 20                       ;
         Value aOptions[ OPTIONS_TITLE ]

      @ ( wSetTitle.txbName.Row + wSetTitle.txbName.Height + 15 ), 150               ;
         Button btnOK                                                                 ;
         Caption _HMG_MESSAGE[ 6 ]                                                    ;
         Action { || aOptions[ OPTIONS_TITLE ] := AllTrim( wSetTitle.txbName.Value ), ;
         StoreTitle()                                                   , ;
         ThisWindow.Release                                               ;
         }

      @ wSetTitle.btnOk.Row, ( wSetTitle.btnOk.Col + wSetTitle.btnOk.Width + 25 ) ;
         Button btnCancel          ;
         Caption _HMG_MESSAGE[ 7 ] ;
         Action ThisWindow.Release

      On key Escape of wSetTitle Action wSetTitle.Release
      On key Alt+X  of wSetTitle Action ReleaseAllWindows()

   END WINDOW

   wSetTitle.txbName.Width := ( wSetTitle.Width - 2 * wSetTitle.txbName.Col  - ;
      2 * GetBorderWidth() )
   wSetTitle.txbName.SetFocus

   CenterInside( 'wStock', 'wSetTitle')
   ACTIVATE WINDOW wSetTitle

   RETURN

   ****** End of SetTitle ******

   /******
   *       StoreTitle()
   *       Output of the catalog name in the title of main form
   */

STATIC PROCEDURE StoreTitle

   MEMVAR aOptions

   wStock.Title := ( APPTITLE + Iif( !Empty( aOptions[ OPTIONS_TITLE ] )  , ;
      ( ' - ' + aOptions[ OPTIONS_TITLE ] ), ;
      '' )                                   ;
      )

   RETURN

   ****** End of StoreTitle ******

   /******
   *       Options()
   *       Program tuning
   */

STATIC PROCEDURE Options

   MEMVAR aOptions
   LOCAL aStrings := GetLangStrings( GET_OPTIONSFORM_LANG, aOptions[ OPTIONS_LANGFILE ] ), ;
      aLang    := GetLangStrings( GET_SYSDIALOGS_LANG, aOptions[ OPTIONS_LANGFILE ] )

   DEFINE WINDOW wOptions        ;
         At 132, 235            ;
         Width 433              ;
         Height 309             ;
         Title aStrings[ 1, 2 ] ;
         Icon 'STOCK'           ;
         Modal

      @ 5, 5 Frame frmOnStart         ;
         Caption aStrings[ 2, 2 ] ;
         Width 205                ;
         Height 75                ;
         Bold                     ;
         Fontcolor BLUE

      @ ( wOptions.frmOnStart.Row + 15 ), ( wOptions.frmOnStart.Col + 10 ) ;
         RadioGroup rdgOnStart                                              ;
         Options { aStrings[ 3, 2 ], aStrings[ 4, 2 ] }                     ;
         Width 185                                                          ;
         Value aOptions[ OPTIONS_ONSTART ]

      @ wOptions.frmOnStart.Row                                           , ;
         ( wOptions.frmOnStart.Col + wOptions.frmOnStart.Width + 5 )         ;
         Frame frmSearch                                                     ;
         Caption aStrings[ 5, 2 ]                                            ;
         Width wOptions.frmOnStart.Width Height wOptions.frmOnStart.Height   ;
         Bold                                                                ;
         Fontcolor BLUE

      @ wOptions.rdgOnStart.Row, ( wOptions.frmSearch.Col + 15 ) ;
         RadioGroup rdgSearch                                     ;
         Options { aStrings[ 6, 2 ], aStrings[ 7, 2 ] }           ;
         Width 165                                                ;
         Value aOptions[ OPTIONS_SEARCH ]

      @ ( wOptions.frmOnStart.Row + wOptions.frmOnStart.Height + 5 )      , ;
         wOptions.frmOnStart.Col                                             ;
         Frame frmEditor                                                     ;
         Caption aStrings[ 8, 2 ]                                            ;
         Width ( wOptions.frmOnStart.Width + wOptions.frmSearch.Width + 5 )  ;
         Height 140                                                          ;
         Bold                                                                ;
         Fontcolor BLUE

      @ ( wOptions.frmEditor.Row + 25 ), ( wOptions.frmEditor.Col + 10 ) ;
         Textbox txbEditor                                                ;
         Value aOptions[ OPTIONS_EDITOR ]                                 ;
         Height 20                                                        ;
         Width ( wOptions.frmEditor.Width - 45 )

      @ wOptions.txbEditor.Row                                          , ;
         ( wOptions.txbEditor.Col + wOptions.txbEditor.Width + 5 )         ;
         Button btnSearch                                                  ;
         Picture 'FIND'                                                    ;
         Action { |cFile| cFile  := GetFile( { { aLang[ 4, 2 ], '*.exe' }, ;
         { aLang[ 5, 2 ], '*.*'   }  ;
         }                           , ;
         aLang[ 2, 2 ]             , , ;
         .F.                         , ;
         .T.                           ;
         )                             , ;
         Iif( !Empty( cFile )                           , ;
         SetProperty( 'wOptions', 'txbEditor', 'Value', cFile ), ) ;
         }                                                                       ;
         Width 20 Height 20

      @ ( wOptions.txbEditor.Row + 25 ), wOptions.txbEditor.Col            ;
         RadioGroup rdgParameters                                           ;
         Options { aStrings[ 9, 2 ], aStrings[ 10, 2 ], aStrings[ 11, 2 ] } ;
         Width 270                                                          ;
         Spacing 28                                                         ;
         Value aOptions[ OPTIONS_RUNMODE ]                                  ;
         On change EnableParameters()

      @ ( wOptions.rdgParameters.Row + 30 )                              , ;
         ( wOptions.rdgParameters.Col + wOptions.rdgParameters.Width + 5 )  ;
         Textbox txbWithNumber                                              ;
         Height 20                                                          ;
         Width 120

      @ ( wOptions.txbWithNumber.Row + 30 ), wOptions.txbWithNumber.Col ;
         Textbox txbWithName                                             ;
         Height 20                                                       ;
         Width 120

      @ ( wOptions.Height - 70 ), 80 Button btnOk Caption _HMG_MESSAGE[ 6 ] ;
         Action { || SaveOptions(), wOptions.Release }

      @ wOptions.btnOk.Row, ( wOptions.btnOk.Col + wOptions.btnOk.Width + 70 ) ;
         Button btnCancel Caption _HMG_MESSAGE[ 7 ]                             ;
         Action wOptions.Release

      On key Escape of wOptions Action wOptions.Release
      On key Alt+X  of wOptions Action ReleaseAllWindows()

   END WINDOW

   // ������������ �������� � ��������� ������� � ��������� �������

   DO CASE
   CASE ( aOptions[ OPTIONS_RUNMODE ] == EDITOR_SIMPLEOPEN )
      wOptions.txbWithNumber.Value := ''
      wOptions.txbWithName.Value   := ''

   CASE ( aOptions[ OPTIONS_RUNMODE ] == EDITOR_GOTO )
      wOptions.txbWithNumber.Value := aOptions[ OPTIONS_EDITOR_PARMS ]
      wOptions.txbWithName.Value   := ''

   CASE ( aOptions[ OPTIONS_RUNMODE ] == EDITOR_FIND )
      wOptions.txbWithNumber.Value := ''
      wOptions.txbWithName.Value   := aOptions[ OPTIONS_EDITOR_PARMS ]

   ENDCASE

   EnableParameters()

   CenterInside( 'wStock', 'wOptions' )
   ACTIVATE WINDOW wOptions

   RETURN

   ****** End of Options ******

   /******
   *       EnableParameters()
   *       Administration for the edition of complementary parameters
   *       for editor launching
   */

STATIC PROCEDURE EnableParameters

   DO CASE
   CASE ( wOptions.rdgParameters.Value == EDITOR_SIMPLEOPEN )
      wOptions.txbWithNumber.Enabled := .F.
      wOptions.txbWithName.Enabled   := .F.

   CASE ( wOptions.rdgParameters.Value == EDITOR_GOTO )
      wOptions.txbWithNumber.Enabled := .T.
      wOptions.txbWithName.Enabled   := .F.

   CASE ( wOptions.rdgParameters.Value == EDITOR_FIND )
      wOptions.txbWithNumber.Enabled := .F.
      wOptions.txbWithName.Enabled   := .T.

   ENDCASE

   RETURN

   ****** End of EnableParameters ******

   /******
   *       SaveOptions()
   *       Preservation the options
   */

STATIC PROCEDURE SaveOptions

   MEMVAR aOptions

   BEGIN INI FILE STOCK_INI

      SET SECTION 'MAIN' entry 'OnStart' to wOptions.rdgOnStart.Value
      aOptions[ OPTIONS_ONSTART ] := wOptions.rdgOnStart.Value

      SET SECTION 'MAIN' entry 'Search'  to wOptions.rdgSearch.Value
      aOptions[ OPTIONS_SEARCH ] := wOptions.rdgSearch.Value

      SET SECTION 'EDITOR' entry 'Editor'  to AllTrim( wOptions.txbEditor.Value )
      aOptions[ OPTIONS_EDITOR ] := AllTrim( wOptions.txbEditor.Value )

      SET SECTION 'EDITOR' entry 'RunWith' to wOptions.rdgParameters.Value
      aOptions[ OPTIONS_RUNMODE ] := wOptions.rdgParameters.Value

      DO CASE
      CASE ( wOptions.rdgParameters.Value == EDITOR_SIMPLEOPEN ) // ������� ���� � ��������� (��� �������)
         SET SECTION 'EDITOR' entry 'EditParms' to ''
         aOptions[ OPTIONS_EDITOR_PARMS ] := ''

      CASE ( wOptions.rdgParameters.Value == EDITOR_GOTO )       // ������� � ������� �� ������
         SET SECTION 'EDITOR' entry 'EditParms' to AllTrim( wOptions.txbWithNumber.Value )
         aOptions[ OPTIONS_EDITOR_PARMS ] := AllTrim( wOptions.txbWithNumber.Value )

      CASE ( wOptions.rdgParameters.Value == EDITOR_FIND )       // ������� � �������� ��������� ��� ������
         SET SECTION 'EDITOR' entry 'EditParms' to AllTrim( wOptions.txbWithName.Value )
         aOptions[ OPTIONS_EDITOR_PARMS ] := AllTrim( wOptions.txbWithName.Value )

      ENDCASE

   END INI

   SetState()

   RETURN

   ****** End of SaveOptions ******

   /******
   *       ReadOptions() --> aOptions
   *       Restoration the options
   */

STATIC FUNCTION ReadOptions

   LOCAL aOptions := Array( OPTIONS_ALEN )

   aOptions[ OPTIONS_ONSTART      ] := ONSTART_NONEACTION
   aOptions[ OPTIONS_SEARCH       ] := SEARCH_EQUAL
   aOptions[ OPTIONS_GETPATH      ] := ''
   aOptions[ OPTIONS_TITLE        ] := ''
   aOptions[ OPTIONS_LASTFILE     ] := ''
   aOptions[ OPTIONS_EDITOR       ] := ''
   aOptions[ OPTIONS_RUNMODE      ] := EDITOR_SIMPLEOPEN
   aOptions[ OPTIONS_EDITOR_PARMS ] := ''
   aOptions[ OPTIONS_LANGFILE     ] := ''

   IF File( STOCK_INI )

      BEGIN INI FILE STOCK_INI
         GET aOptions[ OPTIONS_ONSTART      ] section 'MAIN'   entry 'OnStart'   Default ONSTART_NONEACTION
         GET aOptions[ OPTIONS_SEARCH       ] section 'MAIN'   entry 'Search'    Default SEARCH_EQUAL
         GET aOptions[ OPTIONS_LASTFILE     ] section 'MAIN'   entry 'LastFile'  Default ''
         GET aOptions[ OPTIONS_LANGFILE     ] section 'MAIN'   entry 'LangFile'  Default ''
         GET aOptions[ OPTIONS_EDITOR       ] section 'EDITOR' entry 'Editor'    Default ''
         GET aOptions[ OPTIONS_RUNMODE      ] section 'EDITOR' entry 'RunWith'   Default EDITOR_SIMPLEOPEN
         GET aOptions[ OPTIONS_EDITOR_PARMS ] section 'EDITOR' entry 'EditParms' Default ''

      END INI

   ENDIF

   RETURN aOptions

   ****** End of ReadOptions ******

   /******
   *       CurrtFileName() --> cFile
   *       To determine the program file ���������� ����������� ����, allusive the current
   *       (into list) procedure
   */

FUNCTION CurrFileName

   LOCAL nPos   := wStock.grdContent.Value, ;
      cFile  := ''

   // ���� ����������� ����, ���������� ������� �������.

   DO WHILE .T.

      IF Empty( wStock.grdContent.Item( nPos )[ 2 ] )
         cFile := AllTrim( wStock.grdContent.Item( nPos )[ 1 ] )
         EXIT
      ENDIF

      nPos --

      IF ( nPos <= 0 )
         EXIT
      ENDIF

   ENDDO

   RETURN cFile

   ****** End of CurrFileName ******

   /******
   *       OpenFile()
   *       To open with external editor
   */

STATIC PROCEDURE OpenFile

   MEMVAR aOptions, cSearch, cString
   LOCAL cFile  := CurrFileName(), ;
      nPos                    , ;
      cParms                  , ;
      oFile                   , ;
      Cycle  := 1

   PRIVATE cSearch, ;
      cString

   IF !Empty( cFile )

      cFile := ( aOptions[ OPTIONS_GETPATH ] + '\' + cFile )

      DO CASE
      CASE ( aOptions[ OPTIONS_RUNMODE ] == EDITOR_SIMPLEOPEN )  // ������� ���� � ���������
         EXECUTE FILE ( aOptions[ OPTIONS_EDITOR ] ) Parameters cFile

      CASE ( aOptions[ OPTIONS_RUNMODE ] == EDITOR_GOTO )        // ������� c ��������� �� ������

         nPos    := wStock.grdContent.Value
         cSearch := ''

         IF ( !Empty( aOptions[ OPTIONS_EDITOR_PARMS ] ) .and. ;
               !Empty( wStock.grdContent.Item( nPos )[ 2 ] )              ;
               )

            // ��������� ��������� ���������

            IF ( AllTrim( wStock.grdContent.Item( nPos )[ 2 ] ) == 'HB_FUNC' )
               cSearch += '.and. ( "HB_FUNC" $ cString )'
            ENDIF

            IF ( 'Static' $ wStock.grdContent.Item( nPos )[ 2 ] )
               cSearch += '.and. ( "STAT" $ cString )'
            ENDIF

            IF ( 'Procedure' $ wStock.grdContent.Item( nPos )[ 2 ] )
               cSearch += '.and. ( "PROC" $ cString )'
            ENDIF

            IF ( 'Function' $ wStock.grdContent.Item( nPos )[ 2 ] )
               cSearch += '.and. ( "FUNC" $ cString )'
            ENDIF

            cSearch += ( '.and. ( "' + Upper( AllTrim( wStock.grdContent.Item( nPos )[ 1 ] ) ) + '" $ cString )' )

            IF ( Left( cSearch, 1 ) == '.' )
               cSearch := Substr( cSearch, 6 )
            ENDIF

            oFile := TFileRead() : New( cFile )
            oFile : Open()

            IF !oFile : Error()

               DO WHILE oFile : MoreToRead()

                  cString := Upper( oFile : ReadLine() )

                  IF &cSearch
                     EXIT
                  ENDIF

                  Cycle ++

               ENDDO

               oFile : Close()

            ENDIF

            IF ( Cycle > 1 )        // �������?
               cParms := StrTran( aOptions[ OPTIONS_EDITOR_PARMS ], '%N', AllTrim( Str( Cycle ) ) )
            ELSE
               cParms := ''
            ENDIF

            cParms := ( cFile + ' ' + cParms )

         ELSE
            cParms := cFile

         ENDIF

         EXECUTE FILE ( aOptions[ OPTIONS_EDITOR ] ) Parameters cParms

      CASE ( aOptions[ OPTIONS_RUNMODE ] == EDITOR_FIND )        // ������� � �������
         IF !Empty( cParms := aOptions[ OPTIONS_EDITOR_PARMS ] )
            nPos   := wStock.grdContent.Value
            cParms := StrTran( cParms, '%P', AllTrim( wStock.grdContent.Item( nPos )[ 1 ] ) )
            cParms := ( cFile + ' ' + cParms )
         ELSE
            cParms := cFile
         ENDIF

         EXECUTE FILE ( aOptions[ OPTIONS_EDITOR ] ) Parameters cParms

      ENDCASE

   ENDIF

   RETURN

   ****** End of OpenFile ******

   /******
   *       About( cTitle )
   *       About program
   */

STATIC PROCEDURE About( cTitle )

   LOCAL cMsg := ( APPTITLE + ' ' + APPVERSION + CRLF + COPYRIGHT + CRLF + ;
      'with GAL edition (Alexey L. Gustow <gustow33 [dog] mail.ru>)' + CRLF + ;
      '2011.Oct.01-08' )

   MsgInfo( cMsg, cTitle )

   RETURN

   ****** End of About ******
