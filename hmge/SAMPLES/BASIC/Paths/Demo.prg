/******
* MINIGUI - Harbour Win32 GUI library Demo
* Demo functions for show system paths
* (c) 2008 Vladimir Chumachenko <ChVolodymyr@yandex.ru>
* Revised by Grigory Filatov <gfilatov@inbox.ru>
*/

#include "MiniGUI.ch"

STATIC cCurDir

/******
*       Варианты представления системных путей
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

   wMain.Label_3.Value := ''          // Компактная форма
   wMain.Label_6.Value := ''          // Сокращённое представление (в формате 8.3)

   wMain.Label_7.Value := ( wMain.Label_7.Value + ' ' + cCurDir )

   wMain.Label_8.Value := ''          // Относительный маршрут

   wMain.Spinner_1.Value := 30

   MakePaths()

   CENTER WINDOW wMain
   ACTIVATE WINDOW wMain

   RETURN

   ****** End of Main ******

   /******
   *       SelectDir()
   *       Выбор каталога для сканирования
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
   *       Формирование представлений путей
   */

STATIC PROCEDURE MakePaths

   ShowCompactPath()
   ShowShortPath()
   ShowRelPath()

   RETURN

   ****** End of MakePaths ******

   /******
   *       ShowCompactPath()
   *       Сжатая форма представления маршрута
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
   *       Сокращённое (формат 8.3) представление представлений путей
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
   *       Отображение маршрута относительно текущего каталога
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
   *       Относительное выражение пути поиска
   */

STATIC FUNCTION RelativePath( cCurPath, cTargetPath )

   LOCAL aCurrPath    := HB_ATokens( cCurPath, '\' )   , ;
      aTargetPath  := HB_ATokens( cTargetPath, '\' ), ;
      cRelPath     := ''                            , ;
      nLen                                          , ;
      Cycle

   IF ( Upper( cCurPath ) == Upper( cTargetPath ) )

      // Каталоги одинаковы

      RETURN ''

      // ... или можно возвращать текущий маршрут
      // Return cCurPath

   ENDIF

   // При построении относительного пути доступа учитываются следующие варианты:
   // 1) Каталоги находятся на разных дисках - можно использовать только абсолютный путь
   // 2) Целевой каталог подчинён текущему (ниже уровнем)
   // 3) Целевой каталог находится в той же ветви, что и текущий, но на более высоком
   //    уровне
   // 4) Текущий и целевой каталоги находятся на одном диске, но в разных ветвях.

   IF ( Upper( aCurrPath[ 1 ] ) == Upper( aTargetPath[ 1 ] ) )       // Диск общий?

      // Пытаемся избавиться от общей части имён каталогов

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

      // Если в массиве описания текущего каталога остались элементы, то к
      // определению относительного пути добавляем соответсвующее число переходов
      // на верхний уровень и остаток описания целевого каталога

      IF !Empty( aCurrPath )
         cRelPath += Replicate( '..\', Len( aCurrPath ) )
      ENDIF

      IF ( ( nLen := Len( aTargetPath ) ) > 0 )
         FOR Cycle := 1 to nLen
            cRelPath += ( aTargetPath[ Cycle ] + '\' )
         NEXT
      ENDIF

   ELSE
      cRelPath := cTargetPath        // Каталоги на разных дисках

   ENDIF

   IF ( Right( cRelPath, 1 ) == '\' )
      cRelPath := Left( cRelPath, ( Len( cRelPath ) - 1 ) )
   ENDIF

   RETURN cRelPath

   ****** End of RelativePath ******

