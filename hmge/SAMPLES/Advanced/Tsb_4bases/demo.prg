/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2016 SergKis - http://clipper.borda.ru
* Design and color were made by Verchenko Andrey <verchenkoag@gmail.com>
*/

#include "hmg.ch"
#include "tsbrowse.ch"

REQUEST DBFCDX

MEMVAR nY, nX, nW, nH, aPrivBColor, nPrivFsize

SET PROCEDURE TO util.prg

#define PROGRAM     "TSBrowse: The discovery of different databases on a single form."

PROCEDURE Main

   LOCAL aBase, nFontSize, nMaxWidth, nMaxHeight

   PRIVATE nY, nX, nW, nH, nPrivFsize
   PRIVATE aPrivBColor := { {192,185,154} , {159,191,236} , {195,224,133}, {251,230,148} }

   SET EXACT    ON
   SET CENTURY  ON
   SET EPOCH    TO ( Year(Date()) - 50 )
   SET DATE     TO GERMAN

   RDDSETDEFAULT('DBFCDX')

   SET AUTOPEN   ON
   SET EXCLUSIVE ON
   SET SOFTSEEK  ON
   SET DELETED   ON

   SET TOOLTIP BALLOON ON

   // Create a database and return a list of databases
   aBase := MyCreateDbfCdx()

   nFontSize  := 9
   nMaxWidth  := GetDesktopWidth()
   nMaxHeight := ( GetDesktopHeight() - GetTaskBarHeight() )
   IF nMaxWidth > 1200
      nFontSize  := 12
      nMaxWidth  := 1200
      nMaxHeight := 700
   ENDIF
   nPrivFsize := nFontSize  // to declare the size of the background for the table

   SET FONT TO "Arial" , nFontSize             // Default font

   DEFINE WINDOW      wMain      ;
         AT          0, 0        ;
         WIDTH       nMaxWidth   ;
         HEIGHT      nMaxHeight  ;
         TITLE       'DEMO Tsb4' ;
         ICON        '1MAIN_ICO' ;
         MAIN                    ;
         ON INIT ( wStandardWnd(aBase, nMaxWidth, nMaxHeight), ;
         wMain.Release() )

   END WINDOW

   CENTER    WINDOW wMain
   ACTIVATE  WINDOW wMain

   RETURN

FUNCTION wStandardWnd( aBase, nMaxWidth, nMaxHeight )

   LOCAL cForm  := "Form_1"
   LOCAL oBrw, nHbar, nCliW
   LOCAL nRow := 10, nCol := 10

   IF _IsWindowDefined(cForm)

      RETURN NIL
   ENDIF

   DEFINE WINDOW &cForm AT 0, 0 WIDTH nMaxWidth HEIGHT nMaxHeight ;
         TITLE PROGRAM                 ;
         ICON "1MAIN_ICO"              ;
         WINDOWTYPE STANDARD TOPMOST   ;
         NOMAXIMIZE NOSIZE             ;
         BACKCOLOR { 93,114,148}       ;
         ON INIT   {|| wMain.Hide, DoMethod( cForm, "Restore" ), ;
         SetProperty(cForm, "Topmost", .F.) }

      nCliW := This.ClientWidth

      DEFINE STATUSBAR BOLD
         STATUSITEM ''                           // остаток ширины тут
         STATUSITEM MiniGuiVersion() WIDTH nCliW * 0.4 ICON '1MAIN_ICO'
         STATUSITEM ''               WIDTH nCliW * 0.1
         DATE                        WIDTH 100
         CLOCK                       WIDTH 100
      END STATUSBAR

      // верхнее меню кнопок таблицы
      nHbar := MyToolBar(cForm, nRow, nCol, aBase )
      // установим кооординаты таблицы
      nY := nHbar + 5
      nX := 2
      nW := -( nX * 2 )
      nH := -( GetWindowHeight(This.StatusBar.Handle) + 4 )

      oBrw := MyTsb(1,aBase)  // первый вызов построения таблицы

      oBrw:SetFocus()

   END WINDOW

   CENTER   WINDOW &cForm
   ACTIVATE WINDOW &cForm

   RETURN NIL

FUNCTION MyTsb( nBrw, aBase )

   LOCAL cForm  := ThisWindow.Name
   LOCAL cBrw   := "BrwLog"
   LOCAL cAlias
   LOCAL oBrw, lCell := .T., cFile
   LOCAL aFont, cFont, nFont
   LOCAL aBackcolor, aMarker[2], aCursorBC, aBackColor2

   aFont  := { "Tahoma", "Times New Roman", "Comic Sans MS", 'Arial' }
   cFile  := aBase[ nBrw, 1 ]     // File dbf
   cAlias := aBase[ nBrw, 2 ]     // Alias dbf
   cFont  := aFont[ nBrw ]
   nFont  := nPrivFsize               // Private variable
   aBackcolor := aPrivBColor[ nBrw ]  // Private variable
   This.BaseName.Value := "Alias: " + cAlias

   // Закрываем базу и удаляем объект таблицы при нажатии кнопки верхнего меню !
   // Close the database and delete the table object by clicking the top menu button!
   IF _IsControlDefined(cBrw, cForm)
      IF Select(cAlias) > 0
         ( cAlias )->( dbClosearea() )
      ENDIF
      DoMethod(cForm, cBrw, 'Release')
   ENDIF

   USE &cFile Via "DBFCDX" Alias &cAlias Shared New

   IF OrdCount() > 0
      OrdSetFocus(1)
   ENDIF

   // DEFINE TBROWSE ...
   oBrw := TBrw_Create(cBrw, cForm, nY, nX, nW, nH, cAlias, lCell, cFont, nFont, aBackcolor)

   WITH OBJECT oBrw   // oBrw объект установлен\зарегистрирован

      :LoadFields(.F.)

      :lNoChangeOrd := .T.               // убрать сортировку по полю
      :lNoGrayBar   := .T.               // неактивный курсор
      :nColOrder    := 0                 // убрать значок сортировки по полю
      :lNoHScroll   := .T.               // показ горизонтального скролинга
      :nHeightCell  += 5
      :nHeightHead  := :nHeightCell
      :nHeightFoot  := :nHeightHead      // высота строки подвала
      :lFooting     := .T.               // использовать подвал
      :lDrawFooters := .T.               // рисовать  подвалы

      aEval(:aColumns, {|oCol,nCol| oCol:cFooting := hb_ntos(nCol) }) // цифры в подвале таблицы
      aEval(:aColumns, {|oCol     | oCol:nFAlign  := DT_CENTER     }) // центровка подвала таблицы
      aEval(:aColumns, {|oCol     | oCol:lFixLite := .T.           }) // Fixed cursor , фикс.курсор

      // -------------- Тестовый вывод отладки в файл наимен.колонок таблицы ---------
      //   AEval(oBrw:aColumns, {|oCol,nCol| _LogFile(.T.,nCol, oCol:cName) })

      aMarker[ 1 ] := Rgb( 255, 255, 255 )   // белый
      aMarker[ 2 ] := Rgb( 127, 127, 127 )   // серый 25%

      // переназначим цвет: строка маркера/курсора текущй записи базы
      aCursorBC := { 4915199,255}
      :SetColor( { 6}, { { |a,b,c,d| a:=d, IF( c:nCell == b, aCursorBC ,;
         { aMarker[1], aMarker[2] })  }  } )

      // -------------------- Установить цвета в таблице ------------------------------
      :SetColor( { 1}, { { || CLR_BLACK                         } } ) // текста в ячейках таблицы
      :SetColor( { 3}, { { || CLR_YELLOW                        } } ) // текста шапки таблицы
      :SetColor( { 4}, { { || { RGB(43,149,168), RGB(0,54,94) } } } ) // фона шапка таблицы
      :SetColor( { 9}, { { ||   CLR_YELLOW                      } } ) // текста подвала таблицы
      :SetColor( {10}, { { || { RGB(43,149,168), RGB(0,54,94) } } } ) // фона подвала таблицы

      :nClrLine := RGB(43,149,168) // цвет линий между ячейками таблицы

      aBackColor2 := { 215, 215, 215 }   // белый, затенение 15%
      IF nBrw < 4
         // примеры закраски всей строки по номеру строки чётная\нечётная
         :SetColor( { 2}, { { |a,b,o| a:=b, iif( o:nAt % 2 == 0, MyRGB(aBackColor2 ), ;
            MyRGB(aBackcolor) ) } } )
         IF nBrw == 1
            // --- меняем цвета текста в ячейках таблицы --( oCol:nClrFore = oBrw:SetColor({1}...)---
            AEval(:aColumns, {|oCol| oCol:nClrFore := { |a,b,o| a:=b, MyTsbColorText( (o:cAlias)->ERR_1 ) } } )
         ELSEIF nBrw == 2
            // --- меняем цвета текста в ячейках таблицы --( oCol:nClrFore = oBrw:SetColor({1}...)---
            AEval(:aColumns, {|oCol| oCol:nClrFore := { |a,b,o| a:=b, MyTsbColorText( (o:cAlias)->ERR_2 ) } } )
         ENDIF
      ELSE
         // цвета для 4-й таблицы
         // примеры закраски всей строки по году поля FIELD->DATE_4
         :SetColor( { 2}, { { |a,b,o| a:=b, iif( Year( (o:cAlias)->DATE_4 ) % 2 == 0, ;
            MyRGB( aBackColor2 ), MyRGB( aBackcolor ) ) } } )

         // --- меняем цвета текста в ячейках таблицы --( oCol:nClrFore = oBrw:SetColor({1}...)---
         AEval(:aColumns, {|oCol| oCol:nClrFore := { |a,b,o| a:=b, MyTsbColorText( (o:cAlias)->ERR_4 ) } } )
      ENDIF

      IF nBrw == 3  // цвета для 3-й таблицы
         // ---- Ставим по всем колонкам ----( oCol:nClrBack = oBrw:SetColor( {2} ...) ----
         AEval(:aColumns, {|oCol| oCol:nClrBack := { |a,b,o| a:=b, ;
            iif( 'hmg' $ LOWER( (o:cAlias)->NAME_3 ) .OR. ;
            'box' $ LOWER( (o:cAlias)->NAME_3 ), MyRGB({235,117,123}), ;
            iif( o:nAt % 2 == 0, MyRGB(aBackcolor), MyRGB(aBackColor2) ) ) } })
         // --- меняем цвета текста в ячейках таблицы --( oCol:nClrFore = oBrw:SetColor({1}...)---
         AEval(:aColumns, {|oCol| oCol:nClrFore := { |a,b,o| a:=b, MyTsbColorText( (o:cAlias)->ERR_3 ) } } )
      ENDIF

      :ResetVScroll()  // показ вертикального скроллинга

      // ------------ вывод в подвале ИТОГО по колонкам -----------------------
      :aColumns[1]:cFooting := { || '[' + HB_NtoS( oBrw:nLen ) + ']' }
      :aColumns[5]:cFooting := { || '[' + HB_NtoS( MyGetCountField("SIZE_",nBrw) ) + ' Mb]' }

   END WITH         // oBrw объект снят

   // END TBROWSE
   TBrw_Show(oBrw)

   oBrw:Refresh(.T.)  // перечитать таблицу

   oBrw:nCell := 2    // передвинуть МАРКЕР

   RETURN oBrw

STATIC FUNCTION MyTsbColorText(nVal)

   LOCAL nColor

   IF nVal == -1
      nColor := CLR_HRED
   ELSEIF nVal == 1
      nColor := CLR_HBLUE
   ELSE
      nColor := CLR_BLACK
   ENDIF

   RETURN nColor

   // Функция подсчета суммы поля по таблице

FUNCTION MyGetCountField(cField,nBrw)

   LOCAL cAlias, nLen, nRec

   nLen := 0
   cAlias := ALIAS()
   nRec := ( cAlias )->( RecNo() )
   cField := cField + HB_NtoS(nBrw)

   ( cAlias )->( DbEval( { || nLen += &(cField) } ) )

   ( cAlias )->( DbGoTo( nRec ) )

   nLen := nLen  / 1024 / 1024

   RETURN nLen

FUNCTION MyToolBar( cForm, nRow, nCol, aBase )

   LOCAL nY,nX,nW,nH,cB,cC,cT
   LOCAL nMaxWidth := This.ClientWidth

   //-------------------Define user toolbar buttons------------------------------//
   nY := nRow
   nX := nCol
   nW := 48
   nH := 48

   cB := "Butt_1"; cC := "Dbf-1";  cT := "Open Base_1.dbf"
   @ nY, nX  BUTTONEX &cB  CAPTION cC  TOOLTIP cT ;
      BACKCOLOR aPrivBColor[1] BOLD ;
      ACTION {|oBrw| oBrw := MyTsb(1,aBase), oBrw:SetFocus() } ;
      WIDTH  nW HEIGHT nH NOXPSTYLE HANDCURSOR NOTABSTOP
   nX += GetWindowWidth(GetControlHandle(cB, cForm))

   cB := "Butt_2"; cC := "Dbf-2";  cT := "Open Base_2.dbf"
   @ nY, nX  BUTTONEX &cB  CAPTION cC TOOLTIP cT  ;
      BACKCOLOR aPrivBColor[2] BOLD ;
      ACTION {|oBrw| oBrw := MyTsb(2,aBase), oBrw:SetFocus() } ;
      WIDTH  nW HEIGHT nH NOXPSTYLE HANDCURSOR NOTABSTOP
   nX += GetWindowWidth(GetControlHandle(cB, cForm))

   cB := "Butt_3"; cC := "Dbf-3";  cT := "Open Base_3.dbf"
   @ nY, nX  BUTTONEX &cB  CAPTION cC  TOOLTIP cT  ;
      BACKCOLOR aPrivBColor[3] BOLD ;
      ACTION {|oBrw| oBrw := MyTsb(3,aBase), oBrw:SetFocus() } ;
      WIDTH  nW HEIGHT nH NOXPSTYLE HANDCURSOR NOTABSTOP
   nX += GetWindowWidth(GetControlHandle(cB, cForm))

   cB := "Butt_4"; cC := "Dbf-4";  cT := "Open Base_4.dbf"
   @ nY, nX  BUTTONEX &cB  CAPTION cC  TOOLTIP cT  ;
      BACKCOLOR aPrivBColor[4] BOLD ;
      ACTION {|oBrw| oBrw := MyTsb(4,aBase), oBrw:SetFocus() } ;
      WIDTH  nW HEIGHT nH NOXPSTYLE HANDCURSOR NOTABSTOP
   nX += GetWindowWidth(GetControlHandle(cB, cForm))

   cB := "Butt_5"; cC := "Exit";   cT := "Exit from programm"
   @ nY, nX  BUTTONEX &cB  CAPTION cC  TOOLTIP cT  ;
      FONTCOLOR WHITE BACKCOLOR MAROON BOLD     ;
      ACTION ThisWindow.Release                 ;
      WIDTH  nW HEIGHT nH NOXPSTYLE HANDCURSOR NOTABSTOP
   nX += GetWindowWidth(GetControlHandle(cB, cForm)) + nW

   @ nY, nX LABEL BaseName  VALUE '' WIDTH nMaxWidth-nX HEIGHT nH SIZE 20 ;
      FONTCOLOR WHITE TRANSPARENT VCENTERALIGN

   nY += GetWindowHeight(GetControlHandle(cB, cForm))

   RETURN nY

FUNCTION MyCreateDbfCdx()

   LOCAL aBase, aDbf, aStr, a2Str, cPath := GetStartUpFolder()+"\"
   LOCAL aFindPath, aFiles, cFileMask, aResult := NIL, cFld, cStr, nErr
   LOCAL nL, nI, nJ, cAlias, cFile, cFileIndx, cI, aField /*[9]*/
   LOCAL cPathBCC, cPathGUI, cPathSmpl, cPathIncl, lHmg

   aDbf := {'zBASE_1.DBF','zBASE_2.DBF','zBASE_3.DBF','zBASE_4.DBF'}
   aStr := {}
   AAdd( aStr, { 'NN'  , 'N',  6, 0 } )
   AAdd( aStr, { 'TBL' , 'C', 15, 0 } )
   AAdd( aStr, { 'PATH', 'C', 35, 0 } )
   AAdd( aStr, { 'NAME', 'C', 30, 0 } )
   AAdd( aStr, { 'SIZE', 'N', 12, 0 } )
   AAdd( aStr, { 'DATE', 'D',  8, 0 } )
   AAdd( aStr, { 'TIME', 'C', 10, 0 } )
   AAdd( aStr, { 'DIR' , 'L',  1, 0 } )
   AAdd( aStr, { 'ERR' , 'N',  2, 0 } )

   aBase := {}
   // Проверка на наличие файлов и создание их из путей МиниГуи
   IF !file(cPath + aDbf[1]) .OR. !file(cPath + aDbf[2])  .OR. ;
         !file(cPath + aDbf[3]) .OR. !file(cPath + aDbf[4])

      cPathBCC  := GetEnv( 'MG_BCC'  )
      cPathGUI  := GetEnv( 'MG_ROOT' )
      lHmg := IIF( cPathGUI == "", .F., .T. )
      cPathBCC  := IIF( cPathBCC == "", GetEnv( 'windir' ), cPathBCC )
      cPathGUI  := IIF( lHmg, cPathGUI, GetEnv( 'windir' )                              )
      cPathIncl := IIF( lHmg, cPathGUI+"\Include" , GetEnv( 'windir' )+"\Help"          )
      cPathSmpl := IIF( lHmg, cPathGUI+"\SAMPLES" , GetEnv( 'windir' )+"\Microsoft.NET" )
      aFindPath := { cPathBCC, cPathGUI, cPathIncl, cPathSmpl }

      SET WINDOW MAIN OFF
      WaitWindow( "Processing...", .T. )
      FOR nI := 1 TO 4
         a2Str := {}
         FOR nJ := 1 TO LEN(aStr)
            cFld := aStr[nJ,1]+"_"+hb_ntos(nI)
            AADD( a2Str, { cFld,aStr[nJ,2],aStr[nJ,3],aStr[nJ,4] } )
         NEXT
         cFile := cPath + aDbf[nI]
         DbCreate( cFile, a2Str )
         USE (cFile) Via "DBFCDX" Alias BASE Exclusive New

         cFileMask := IIF( nI == 4 .AND. lHmg, "*.prg", "*.*" )
         aFiles := DirectoryRecurse( aFindPath[nI], cFileMask, aResult )
         SELECT BASE
         cI := "_"+hb_ntos(nI)
         aField := { 'NN'+cI, 'TBL'+cI, 'PATH'+cI, 'NAME'+cI, 'SIZE'+cI,'DATE'+cI, 'TIME'+cI, 'DIR'+cI, 'ERR'+cI }
         FOR nJ := 1 TO LEN(aFiles)
            APPEND BLANK
            BASE->&(aField[1]) := nJ
            BASE->&(aField[2]) := "Table ( " + HB_NtoS(nI) + " )"
            IF nI == 4
               nL := LEN(cPathSmpl)
               cStr := cFilePath( aFiles[nJ,1] ) + "\"
               cStr := "..." + SUBSTR( cStr, nL+1 )
               BASE->&(aField[3]) := cStr
            ELSE
               BASE->&(aField[3]) := cFilePath( aFiles[nJ,1] ) + "\"
            ENDIF
            BASE->&(aField[4]) := cFileNoPath( aFiles[nJ,1] )
            BASE->&(aField[5]) := aFiles[nJ,2]
            BASE->&(aField[6]) := aFiles[nJ,3]
            BASE->&(aField[7]) := aFiles[nJ,4]
            BASE->&(aField[8]) := IIF( aFiles[nJ,5] == "D", .F. , .T. )
            nErr := IIF( nJ % 11 == 0, -1, IIF( nJ % 7 == 0, 1, 0 ) )
            BASE->&(aField[9]) := nErr
         NEXT
         cFileIndx := ChangeFileExt( cFile, ".cdx" )
         IF ! File(cFileIndx)
            cFld := "Upper(FIELD->PATH_"+hb_ntos(nI)+")"
            IF nI == 1
               INDEX ON &cFld TAG Name
            ELSEIF nI == 2
               INDEX ON &cFld TAG Name
            ELSEIF nI == 3
               INDEX ON &cFld TAG Name
            ELSE
               INDEX ON DTOS(FIELD->DATE_4) TAG Name
            ENDIF
         ENDIF
         CLOSE BASE
         cAlias := 'BASE_' + HB_NtoS(nI)
         AADD( aBase, { cFile, cAlias } )
      NEXT
      WaitWindow()
      SET WINDOW MAIN ON
   ELSE
      FOR nI := 1 TO 4
         cFile := cPath + aDbf[nI]
         cAlias := 'BASE_' + HB_NtoS(nI)
         AADD( aBase, { cFile, cAlias } )
      NEXT
   ENDIF

   RETURN aBase

STATIC FUNCTION DirectoryRecurse( cPath, cFileMask, aResult )

   LOCAL n, aFiles := Directory( cPath + "\*.*", "D" )
   LOCAL aFindMask := Directory( cPath + "\" + cFileMask )

   IF ProcName( 5 ) == "DIRECTORYRECURSE"

      RETURN {}
   ENDIF

   IF aResult == NIL
      aResult := {}
   ENDIF

   IF Len( aFindMask ) > 0

      Aeval( aFindMask, { |e| if( "TMP" $ e[ 1 ] .or. !"." $ e[ 1 ], , Aadd( aResult, {cPath + "\" + e[ 1 ], e[ 2 ], e[ 3 ], e[ 4 ], e[ 5 ]} ) ) } )

   ENDIF

   FOR n := 1 to Len( aFiles )

      IF "D" $ aFiles[ n ][ 5 ] .and. ! ( aFiles[ n ][ 1 ] $ ".." )

         DirectoryRecurse( cPath + "\" + aFiles[ n ][ 1 ], cFileMask, aResult )

      ENDIF

   NEXT

   RETURN aResult

STATIC FUNCTION MyRGB( aDim )

   RETURN RGB( aDim[1], aDim[2], aDim[3] )
