/*
* MINIGUI - Harbour Win32 GUI library Demo
* Joint usage of FreeImage & SQLite3 demo
* (c) 2008 Vladimir Chumachenko <ChVolodymyr@yandex.ru>
* Revised by Grigory Filatov <gfilatov@inbox.ru>
*/

#include "Directry.ch"
#include "FreeImage.ch"
#include "HBSQLit3.ch"
#include "MiniGUI.ch"

#define DB_NAME            'PicBase.s3db'   // Рабочая база

#define WM_PAINT        15             // Для принудительной перерисовки окна

// Область вывода графического изображения фиксирована

// Координаты

#define FI_TOP                5
#define FI_LEFT             260
#define FI_BOTTOM           470
#define FI_RIGHT            765

// Размеры

#define FI_WIDTH            ( FI_RIGHT - FI_LEFT )
#define FI_HEIGHT           ( FI_BOTTOM - FI_TOP )

STATIC lCreateBase := .T.   // Признак: автоматически создавать новую базу
STATIC aParams              // Массив рабочих параметров

/******
*       Демонстрация рисунков, хранящихся в графических файлах
*       и в базе SQLite
*/

PROCEDURE Main

   aParams := { 'StartDir'  => GetCurrentFolder(), ;        // Текущий каталог
      'pDB'       => nil               , ;        // Дескриптор базы
      'ReadFiles' => .T.               , ;        // Перечитать список файлов
      'SavePos'   => .F.               , ;        // Сохранять позицию в списке файлов
      'Reload'    => .T.                 ;        // Признак необходимости перечитать БД
      }

   IF Empty( aParams[ 'pDB' ] := OpenBase() )
      MsgStop( "Can't open/create " + DB_NAME, "Error" )
      QUIT
   ENDIF

   FI_Initialise()          // Инициализация библиотеки FreeImage

   SET font to 'Tahoma', 9

   DEFINE WINDOW wMain                   ;
         At 0, 0                        ;
         WIDTH 780                      ;
         HEIGHT 525                     ;
         TITLE 'FreeImage & SQLite3 Usage Demo' ;
         NOMAXIMIZE                     ;
         NOSIZE                         ;
         ICON 'main.ico'                ;
         MAIN                           ;
         ON RELEASE FI_DeInitialise()   ;
         On Paint ShowMe()

      // ShowMe() - процедура вывода изображения. В описании окна её лучше
      // указать только в On paint. Это позволит обновлять содержимое
      // главного окна при всякой перерисовке. Дополнительное указание
      // On init ShowMe() приводит к мерцанию окна программы при запуске.

      DEFINE TAB tbData ;
            at 5, 5    ;
            WIDTH 250  ;
            HEIGHT 470 ;
            ON CHANGE SwitchTab()

         Page 'Files'

            @ 32, 5 Grid grdFiles   ;
               WIDTH 235       ;
               HEIGHT 340      ;
               WIDTHS { 200 }  ;
               NoHeaders       ;
               ON CHANGE ShowMe()

            @ 385, 5 ButtonEx btnChDir       ;
               CAPTION 'Change folder' ;
               WIDTH 235               ;
               PICTURE 'DIR'           ;
               ACTION ChangeFolder()

            @ 430, 5 ButtonEx btnAdd        ;
               CAPTION 'Copy to base' ;
               WIDTH 235              ;
               PICTURE 'COPY'         ;
               ACTION AddToBase()

         END PAGE

         Page 'Records'

            @ 32, 5 Grid grdRecords          ;
               WIDTH 235                ;
               HEIGHT 340               ;
               WIDTHS { 50, 180 }       ;
               HEADERS { 'ID', 'Name' } ;
               ON CHANGE ShowMe()

            @ 385, 5 ButtonEx btnDelete      ;
               CAPTION 'Delete record' ;
               WIDTH 235               ;
               PICTURE 'DELETE'        ;
               ACTION DelRecord()

            @ 430, 5 ButtonEx btnSave       ;
               CAPTION 'Save to file' ;
               WIDTH 235              ;
               PICTURE 'SAVE'         ;
               ACTION SaveToFile()

         END PAGE

      END TAB

      DEFINE STATUSBAR
         StatusItem aParams[ 'StartDir' ]
         StatusItem 'Exit Alt+X' Width 70
      END STATUSBAR

   END WINDOW

   On Key Alt+X of wMain Action ReleaseAllWindows()

   ListFiles()     // Заполняем список файлов

   CENTER WINDOW wMain
   ACTIVATE WINDOW wMain

   RETURN

   ****** End of Main ******

   /*****
   *       OpenBase() --> pHandleDB
   *       Открытие/создание БД
   */

STATIC FUNCTION OpenBase

   LOCAL lExistDB  := File( DB_NAME )                     , ;
      pHandleDB := SQLite3_Open( DB_NAME, lCreateBase ), ;
      cCommand

   IF !Empty( pHandleDB )

      // При auto_vacuum = 0 после завершения операций удаления данных размер файла БД не изменяется.
      // Освобождённые блоки помечаются как "свободные" и могут повторно использоваться в
      // последующих операциях добавления новых записей.
      // Для уменьшения размера файла необходимо выполнить команду Vacuum

      SQLite3_Exec( pHandleDB, 'PRAGMA auto_vacuum = 0' )

      IF !lExistDB

         // Создаём таблицу

         cCommand := 'Create table if not exists Picts( Id INTEGER PRIMARY KEY AUTOINCREMENT, Name TEXT, Image BLOB );'
         SQLite3_Exec( pHandleDB, cCommand )

      ENDIF

   ENDIF

   RETURN pHandleDB

   ****** End of OpenBase ******

   /******
   *      SwitchTab()
   *      Обработка переключения между списками (файлы-записи)
   */

STATIC PROCEDURE SwitchTab

   LOCAL nValue := wMain.tbData.Value

   // Установка активного элемента

   IF ( nValue == 1 )
      ListFiles()
      wMain.grdFiles.SetFocus       // Вкладка файлов

      ElseIf( nValue == 2 )

      ListRecords()
      wMain.grdRecords.SetFocus     // Вкладка записей

   ENDIF

   RefreshMe()

   RETURN

   ****** End of SwitchTab ******

   /******
   *       ListFiles()
   *       Формирование списка графических файлов
   */

STATIC PROCEDURE ListFiles

   LOCAL nPos   := wMain.grdFiles.Value, ;
      aFiles := {}

   IF aParams[ 'ReadFiles' ]

      // Из поддерживаемых FreeImage типов файлов используем только часть

      AEval( Directory( aParams[ 'StartDir' ] + '\*.jpg'  ), { | elem | AAdd( aFiles, Lower( elem[ F_NAME ] ) ) } )
      AEval( Directory( aParams[ 'StartDir' ] + '\*.jpeg' ), { | elem | AAdd( aFiles, Lower( elem[ F_NAME ] ) ) } )
      AEval( Directory( aParams[ 'StartDir' ] + '\*.png'  ), { | elem | AAdd( aFiles, Lower( elem[ F_NAME ] ) ) } )
      AEval( Directory( aParams[ 'StartDir' ] + '\*.gif'  ), { | elem | AAdd( aFiles, Lower( elem[ F_NAME ] ) ) } )
      AEval( Directory( aParams[ 'StartDir' ] + '\*.bmp'  ), { | elem | AAdd( aFiles, Lower( elem[ F_NAME ] ) ) } )
      AEval( Directory( aParams[ 'StartDir' ] + '\*.ico'  ), { | elem | AAdd( aFiles, Lower( elem[ F_NAME ] ) ) } )

      wMain.grdFiles.DeleteAllItems

      IF !Empty( aFiles )

         ASort( aFiles, { | x, y | x < y } )       // Сортируем список

         wMain.grdFiles.DisableUpdate              // Запрет на обновление грида (актуально при большом количестве графических файлов в папке)

         AEval( aFiles, { | elem | wMain.grdFiles.AddItem( { elem } ) } )

         wMain.grdFiles.EnableUpdate               // Разрешаем показать выполненные изменения в гриде

         // При обновлении списка текущего каталога позицию указателя сохраняем

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
   *       Заполнение таблицы имеющихся в БД записей
   */

STATIC PROCEDURE ListRecords

   LOCAL aData, ;
      aItem

   IF aParams[ 'Reload' ]

      wMain.grdRecords.DeleteAllItems

      aData := Do_SQL_Query( 'Select Id, Name from Picts Order by Name;' )

      IF !Empty( aData )

         FOR EACH aItem in aData
            // В выборке только 2 поля: идентификатор и имя файла
            wMain.grdRecords.AddItem( { aItem[ 1 ], aItem[ 2 ] } )
         NEXT

         wMain.grdRecords.Value := 1

      ENDIF

      // Необходимо переформирование списка записей, имеющихся в БД
      // Признак устанавливается при инициализации или после добавления и
      // удаления записей

      aParams[ 'Reload' ] := .F.

      IF ( wMain.grdRecords.ItemCount > 0 )
         wMain.btnDelete.Enabled := .T.
      ELSE
         wMain.btnDelete.Enabled := .F.
      ENDIF

   ENDIF

   RETURN

   ****** End of ListRecords ******

   /******
   *       ChangeFolder()
   *       Смена текущего каталога
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
   *       ShowMe()
   *       Вывод изображения
   */

STATIC PROCEDURE ShowMe

   STATIC nHandleImg
   LOCAL nTabValue := wMain.tbData.Value, ;
      nTop      := FI_TOP            , ;
      nLeft     := FI_LEFT           , ;
      nBottom   := FI_BOTTOM         , ;
      nRight    := FI_RIGHT          , ;
      nPos                           , ;
      cFile                          , ;
      cImage                         , ;
      pps                            , ;
      hDC                            , ;
      nWidth                         , ;
      nHeight                        , ;
      cID                            , ;
      aData                          , ;
      nKoeff                         , ;
      nHandleClone

   IF !( nHandleImg == nil )

      FI_Unload( nHandleImg )

      // Вывод изображения меньшего размера после большого приводит к
      // наложению картинок. Поэтому нужно очистить область, объявив
      // её "недействительной".
      // Рациональнее обрабатывать не всё окно программы, а только часть,
      // в которой показывается картинка.

      // Подгонка очистки: при перемещении окна за пределы экрана от изображения
      // остаются артефакты.

      InvalidateRect( Application.Handle, 1, FI_LEFT, 0, ( wMain.Width - 1 ), ( wMain.Height - 15 ) )

      nHandleImg := nil

   ENDIF

   IF ( nTabValue == 1 )
      nPos := wMain.grdFiles.Value
   ELSE
      nPos := wMain.grdRecords.Value
   ENDIF

   IF Empty( nPos )

      RETURN
   ENDIF

   // Рисунок получаем из разных источников, в зависимости от текущей вкладки

   IF ( nTabValue == 1 )

      // Из файла

      IF !File( cFile := aParams[ 'StartDir' ] + '\' + wMain.grdFiles.Item( nPos )[ 1 ] )

         RETURN
      ENDIF

      cImage := MemoRead( cFile )         // Загрузка в память

   ELSE

      cID := wMain.grdRecords.Item( nPos )[ 1 ]
      aData := Do_SQL_Query( 'Select Image from Picts Where Id = ' + cId + ';' )

      IF !Empty( aData )
         cImage := aData[ 1, 1 ]
      ELSE

         RETURN
      ENDIF

   ENDIF

   IF Empty( cImage )

      RETURN
   ENDIF

   // Это загрузка рисунка непосредственно из файла
   // nHandleImg := FI_Load( FI_GetFileType( cFile ), cFile, 0 )

   // Рисунок предварительно загружается в память и выводится оттуда

   nHandleImg := FI_LoadFromMemory( FI_GetFileTypeFromMemory( cImage, Len( cImage ) ), cImage, 0 )

   // Оригинальный размер изображения

   nWidth  := FI_GetWidth( nHandleImg )
   nHeight := FI_GetHeight( nHandleImg )

   // FreeImage будет стараться вписать изображение в заданную область, но
   // при этом будут искажения. Поэтому для больших рисунков рассчитываем
   // коэффициент уменьшения (масштабирования).

   // ! ВНИМАНИЕ
   // Расчет и изменение пропорций больших рисунков замедляет вывод изображения

   IF ( ( nHeight > FI_HEIGHT ) .or. ( nWidth > FI_WIDTH )  )

      // Коэффициент выводим по наибольшему превышению размера.
      // Изображение подгоняется пропорционально.

      IF ( ( nHeight - FI_HEIGHT ) > ( nWidth - FI_WIDTH ) )

         // Превышение области по высоте. Расчёт выполняется по этому
         // параметру.

         nKoeff := ( FI_HEIGHT / nHeight )
      ELSE
         nKoeff := ( FI_WIDTH / nWidth )
      ENDIF

      nHeight := Round( ( nHeight * nKoeff ), 0 )
      nWidth  := Round( ( nWidth  * nKoeff ), 0 )

      nHandleClone := FI_Clone( nHandleImg )
      FI_Unload( nHandleImg )

      nHandleImg := FI_Rescale( nHandleClone, nWidth, nHeight, FILTER_BICUBIC )
      FI_Unload( nHandleClone )

   ENDIF

   // Позиционирование изображения. Если размер меньше заданной области
   // вывода, рисунок центрируется по этой оси.

   IF ( nWidth < FI_WIDTH )
      nLeft  += Int( ( FI_WIDTH - nWidth ) / 2 )
      nRight := ( nLeft + nWidth )
   ENDIF

   IF ( nHeight < FI_HEIGHT )
      nTop    += Int( ( FI_HEIGHT - nHeight ) / 2 )
      nBottom := ( nTop + nHeight )
   ENDIF

   // Вывод изображения

   hDC := BeginPaint( Application.Handle, @pps )

   FI_WinDraw( nHandleImg, hDC, nTop, nLeft, nBottom, nRight )

   EndPaint( Application.Handle, pps )

   RETURN

   ****** End of ShowMe ******

   /******
   *       RefreshMe()
   *       Перерисовка изображения
   */

STATIC PROCEDURE RefreshMe

   DO EVENTS

   SendMessage( _HMG_MainHandle, WM_PAINT, 0, 0 )

   RETURN

   ****** End of RefreshMe ******

   /******
   *       Do_SQL_Query( cQuery ) --> aResult
   *       Выполнение выборки
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
   *       AddToBase()
   *       Добавление рисунка в базу
   */

STATIC PROCEDURE AddToBase

   LOCAL nPos       := wMain.grdFiles.Value, ;
      cFile                             , ;
      cImage                            , ;
      pStatement

   IF !Empty( nPos )

      cFile := wMain.grdFiles.Item( nPos )[ 1 ]

      IF !File( aParams[ 'StartDir' ] + '\' + cFile )

         RETURN
      ENDIF

   ELSE

      RETURN

   ENDIF

   pStatement := SQLite3_Prepare( aParams[ 'pDB' ], 'Insert into Picts( Name, Image ) Values( :Name, :Image )' )

   IF !Empty( pStatement )

      cImage := SQLite3_File_to_buff( aParams[ 'StartDir' ] + '\' + cFile )

      IF ( ( SQLite3_Bind_text( pStatement, 1, cFile   ) == SQLITE_OK ) .and. ;
            ( SQLite3_Bind_blob( pStatement, 2, @cImage ) == SQLITE_OK )       ;
            )

         IF ( SQLite3_Step( pStatement ) == SQLITE_DONE )
            aParams[ 'Reload' ] := .T.
            MsgInfo( ( 'File' + CRLF + cFile + CRLF + 'is copied in a base.' ), ;
               'Success', , .F., .F. )
         ENDIF

      ENDIF

      SQLite3_Clear_bindings( pStatement )
      SQLite3_Finalize( pStatement )

   ENDIF

   wMain.grdFiles.SetFocus

   RETURN

   ****** End of AddToBase ******

   /******
   *       DelRecord()
   *       Удаление записи из базы
   */

STATIC PROCEDURE DelRecord

   LOCAL nPos     := wMain.grdRecords.Value, ;
      cID                               , ;
      cCommand                          , ;
      nCount

   IF !Empty( nPos )

      IF MsgYesNo( 'Delete current record?', 'Confirm', .T., , .F., .F.  )

         cID := wMain.grdRecords.Item( nPos )[ 1 ]
         cCommand := ( 'Delete from Picts Where Id = ' + cId + ';' )

         IF ( SQLite3_Exec( aParams[ 'pDB' ], cCommand ) == SQLITE_OK )

            // Для уменьшения размера файла БД необходимо выполняем команду
            // Vacuum. Но при большой БД на это может потребоваться
            // некоторое время.

            IF ( SQLite3_exec( aParams[ 'pDB' ], 'Vacuum' ) == SQLITE_OK )

               // Перечитать список

               aParams[ 'Reload' ] := .T.
               ListRecords()

               // По возможности, указатель оставить на той же позиции

               nCount := wMain.grdRecords.ItemCount

               nPos := Iif( ( nPos >= nCount ), nCount, nPos )
               wMain.grdRecords.Value := nPos

               RefreshMe()

            ENDIF

         ENDIF

      ENDIF

   ENDIF

   wMain.grdRecords.SetFocus

   RETURN

   ****** End of DelRecord ******

   /******
   *       SaveToFile()
   *       Экспорт рисунка из БД в файл
   */

STATIC PROCEDURE SaveToFile

   LOCAL nPos       := wMain.grdRecords.Value, ;
      cID                                 , ;
      aData                               , ;
      cImage                              , ;
      cFile                               , ;
      cExt                                , ;
      nHandleImg                          , ;
      nFIF                                , ;
      nFormat                             , ;
      lSuccess

   IF !Empty( nPos )

      cID   := wMain.grdRecords.Item( nPos )[ 1 ]
      cFile := wMain.grdRecords.Item( nPos )[ 2 ]
      aData := Do_SQL_Query( 'Select Image from Picts Where Id = ' + cId + ';' )

      IF Empty( aData )

         RETURN
      ENDIF

      cImage := aData[ 1, 1 ]

      // Т.к. по расширению файла определяем новый формат изображения,
      // то при операции сохранения необходимо явно указывать расширение файла
      // (по умолчанию используется его текущий формат)

      cFile := PutFile( { { 'JPG files', '*.jpg' }, { 'JPEG files', '*.jpeg' }, ;
         { 'PNG files', '*.png' }, { 'GIF files' , '*.gif'  }, ;
         { 'BMP files', '*.bmp' }, { 'ICO files', '*.ico'   }  ;
         }                                                     , ;
         'Save image'                                          , ;
         aParams[ 'StartDir' ]                                 , ;
         .T.                                                   , ;
         cFile                                                   ;
         )

      IF Empty( cFile )

         RETURN

      ELSE
         IF File( cFile )
            IF !MsgYesNo( ( 'File' + CRLF + ;
                  cFile  + CRLF + ;
                  'already exist. Rewrite it?' ;
                  ), 'Confirm', .T., , .F., .F.  )

               RETURN
            ENDIF
         ENDIF

      ENDIF

      nHandleImg := FI_LoadFromMemory( FI_GetFileTypeFromMemory( cImage, Len( cImage ) ), cImage, 0 )

      IF Empty( nHandleImg )

         RETURN
      ENDIF

      // По расширению файла определяем идентификатор изображения и
      // константу для операции сохранения

      HB_FNameSplit( cFile, , , @cExt )
      cExt := Lower( cExt )

      DO CASE
      CASE ( cExt == '.png' )
         nFIF    := FIF_PNG            // Идентификатор изображения для ввода/вывода
         nFormat := PNG_DEFAULT

      CASE ( cExt == '.gif' )
         nFIF    := FIF_GIF
         nFormat := GIF_DEFAULT

      CASE ( cExt == '.bmp' )
         nFIF    := BMP_DEFAULT
         nFormat := GIF_DEFAULT

      CASE ( cExt == '.ico' )
         nFIF    := FIF_ICO
         nFormat := ICO_DEFAULT

      OTHERWISE

         // По умолчанию JPG или JPEG
         nFIF    := FIF_JPEG
         nFormat := JPEG_DEFAULT

      ENDCASE

      lSuccess := FI_Save( nFIF, nHandleImg, cFile, nFormat )

      IF !lSuccess
         MsgStop( ( "Can't save a file" + HB_OSNewLine() + cFile ), 'Error', , .F., .F. )
      ENDIF

      FI_Unload( nHandleImg )

      // Если запись выполнена успешно, необходимо перечитать список файлов.
      // Позицию указателя не изменяем (для упрощения), хотя список упорядочен
      // по именам файлов и здесь можно запоминать текущий файл и искать его
      // положение в переформированном списке.

      IF lSuccess
         aParams[ 'ReadFiles' ] := .T.
      ENDIF

   ENDIF

   RETURN

   ****** End of SaveToFile ******
