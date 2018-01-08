/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2002-10 Roberto Lopez <harbourminigui@gmail.com>
* http://harbourminigui.googlepages.com/
*/

#include "MiniGUI.ch"
#include "I_QHTM.ch"
#include "Inkey.ch"

// ќпределени€ WinAPI

#define WM_NOTIFY                78

//  оманды (переназначаемые ссылки)

#define ID_CMD                  'CMD:'
#define ID_CMD_STOPLOG          ( ID_CMD + 'STOPLOG' )  // ќстановить логирование

MEMVAR nScrollPos, aBreak

PROCEDURE Main

   LOCAL cIntro := ''

   IF !QHTM_Init()
      MsgStop( ( 'Library QHTM.dll not loaded.' + CRLF + ;
         'Program terminated.'                   ;
         ), 'Error' )
      QUIT
   ENDIF

   SET default icon to 'MAIN'

   SET Events function to MyEvents

   cIntro := '<body bgcolor="White">'
   cIntro += '<center><img src="res:QHTM_LOGO"></center>'
   cIntro += '<h3 align="center"><font color="Navy" face="Georgia">This example shows next functions:</font></h3>'
   cIntro += '<big><ol>'
   cIntro += '<li>Adding web-page text to display text'
   cIntro += '<ul><font color="Maroon">'
   cIntro += '<li>QHTM_AddHTML()'
   cIntro += '<li>QHTM_AddHTML2()'
   cIntro += '</ul></font>'
   cIntro += '<li>Getting and restore position of scrolling'
   cIntro += '<ul><font color="Maroon">'
   cIntro += '<li>QHTM_GetScrollPos()'
   cIntro += '<li>QHTM_SetScrollPos()'
   cIntro += '<li>QHTM_ScrollPos()'
   cIntro += '<li>QHTM_ScrollPercent()'
   cIntro += '</ul></font>'
   cIntro += '</ol>'

   DEFINE WINDOW wMain at 0, 0 ;
         WIDTH 630 Height 600 ;
         TITLE 'QHTM Demo'    ;
         Main                 ;
         NoMaximize           ;
         NOSIZE

      DEFINE MAIN MENU

         DEFINE POPUP 'File'
            MENUITEM 'Exit Alt+X' Action wMain.Release
         END POPUP

         DEFINE POPUP 'Test'
            MENUITEM 'QHTM_AddHTML()' Action TestAddHTML()
            MENUITEM 'QHTM_AddHTML2()' Action TestAddHTML2()
         END POPUP

      END MENU

      @ 0, 0 QHTM HTML_Intro                                                                         ;
         Value cIntro                                                                            ;
         WIDTH  ( wMain.Width - GetBorderWidth() * 2 )                                           ;
         HEIGHT ( wMain.Height - GetTitleHeight() - GetMenuBarHeight() - GetBorderHeight() * 2 ) ;
         Border

   END WINDOW

   On Key Alt+X of wMain Action AppDone()

   CENTER WINDOW wMain
   ACTIVATE WINDOW wMain

   RETURN

   ****** End of Main ******

   /******
   *       AppDone()
   *       «авершение работы
   */

PROCEDURE AppDone

   QHTM_End()
   QUIT

   RETURN

   ****** End of AppDone ******

   /******
   *       MyEvents( hWnd, nMsg, wParam, lParam )
   *       ѕользовательска€ обработка событий.
   *       «десь будем раздел€ть команды запуска процедур и перехода по ссылкам
   *       в QHTM
   */

FUNCTION MyEvents( hWnd, nMsg, wParam, lParam )

   MEMVAR aBreak
   LOCAL nPos , ;
      cLink

   IF ( nMsg == WM_NOTIFY )

      IF ( ( nPos := AScan( _HMG_aControlIds , wParam ) ) > 0 )

         IF ( _HMG_aControlNames[ nPos ] == 'MyHTML' )

            IF ( ID_CMD $ QHTM_GetNotify( lParam ) )

               cLink := QHTM_GetLink( lParam )

               IF ( cLink == ID_CMD_STOPLOG )
                  aBreak[ 'Stop' ] := .T.
               ENDIF

            ENDIF

         ENDIF

      ENDIF

   ENDIF

   Events( hWnd, nMsg, wParam, lParam )

   RETURN 0

   ****** End of MyEvents ******

   /******
   *       TestAddHTML()
   *       ƒобавление кода HTML к существующему с сохранением
   *       текущего положени€
   */

STATIC PROCEDURE TestAddHTML

   LOCAL cValue  := GetWindowText( GetControlHandle( 'HTML_Intro', 'wMain' ) ), ;
      nHandle

   PRIVATE nScrollPos := 0

   DEFINE WINDOW wAddHTML at 0, 0     ;
         WIDTH 600 Height 400        ;
         TITLE 'Demo QHTM_AddHTML()' ;
         Modal                       ;
         NOSIZE

      @ 0, 0 QHTM MyHTML                                                                ;
         WIDTH  ( wAddHTML.Width - GetBorderWidth() * 2 )                           ;
         HEIGHT ( wAddHTML.Height - GetTitleHeight() - GetBorderHeight() * 2 - 45 ) ;
         Border

      @ ( wAddHTML.MyHTML.Height + 10 ), ( wAddHTML.MyHTML.Col + 10 ) Button btnGetPos ;
         Caption 'GetScrollPos' Action GetQHTMPos( nHandle )

      @ ( wAddHTML.MyHTML.Height + 10 ), ( wAddHTML.btnGetPos.Col + wAddHTML.btnGetPos.Width + 20 ) Button btnSetPos ;
         Caption 'SetScrollPos' Action SetQHTMPos( nHandle )

      @ ( wAddHTML.MyHTML.Height + 10 ), ( wAddHTML.btnSetPos.Col + wAddHTML.btnSetPos.Width + 20 ) Button btnGoTo ;
         Caption 'Goto 50%' Action { || MsgInfo( 'Current position: ' + hb_ntos( QHTM_ScrollPercent( nHandle ) ) + '%' ), ;
         QHTM_ScrollPercent( nHandle, 50 )                                                     ;
         }

      @ ( wAddHTML.MyHTML.Height + 10 ), ( wAddHTML.MyHTML.Width - 120 ) Button btnStart                          ;
         Caption 'Add HTML' Action { | nHeight, aSize | QHTM_AddHTML( nHandle, cValue )                          , ;
         nHeight := GetWindowHeight( nHandle )                    , ;
         aSize := QHTM_GetSize( nHandle )                         , ;
         Iif( ( aSize[ 2 ] > nHeight )                            , ;
         SetProperty( 'wAddHTML', 'btnGoTo', 'Enabled', .T. ), ;
         )                                                       ;
         }

   END WINDOW

   nHandle := GetControlHandle( 'MyHTML', 'wAddHTML' )

   //  нопку восстановлени€ позиции прокрутки запрещаем до запоминани€ позиции

   wAddHTML.btnSetPos.Enabled := .F.
   wAddHTML.btnGoTo.Enabled   := .F.

   On Key Escape of wAddHTML Action wAddHTML.Release
   On Key Alt+X of wAddHTML Action AppDone()

   CENTER WINDOW wAddHTML
   ACTIVATE WINDOW wAddHTML

   RETURN

   ****** End of TestAddHTML ******

   /******
   *       GetQHTMPos( nHandle )
   *       ѕолучение текущей позиции прокрутки
   */

STATIC PROCEDURE GetQHTMPos( nHandle )

   LOCAL nPos      , ;
      cMsg := ''

   nPos := QHTM_GetScrollPos( nHandle )
   //nPos := QHTM_ScrollPos( nHandle )

   cMsg += '<p><b>QHTM_GetScrollPos()</b></p><p>'
   cMsg += ( 'Position:' + Str( nPos ) )

   IF Empty( nPos )
      cMsg += ( '<br>' + '<font color="Red"><i>A zero value is not remembered.</i></font>' )
   ELSE
      nScrollPos := nPos
      wAddHTML.btnSetPos.Enabled := .T.
   ENDIF

   QHTM_MessageBox( cMsg, 'Get scroll pos' )

   RETURN

   ****** End of GetQHTMPos ******

   /******
   *       SetQHTMPos( nHandle )
   *       ¬осстановление позиции прокрутки
   */

STATIC PROCEDURE SetQHTMPos( nHandle )

   MEMVAR nScrollPos

   QHTM_SetScrollPos( nHandle, nScrollPos )
   //QHTM_ScrollPos( nHandle, nScrollPos )

   RETURN

   ****** End of SetQHTMPos ******

   /******
   *       TestAddHTML2()
   *       ƒобавление кода HTML к существующему с возможностью
   *       выбора текущего положени€ (не измен€ть или устанавливать
   *       на добавленные строки)
   */

STATIC PROCEDURE TestAddHTML2

   PRIVATE aBreak := { 'Stop' => .F., ;
      'Exit' => .T.  ;
      }

   DEFINE WINDOW wAddHTML at 0, 0                    ;
         WIDTH 400 Height 190                       ;
         TITLE 'Logging ouput demo QHTM_AddHTML2()' ;
         Modal                                      ;
         NOSIZE

      @ 0, 0 QHTM MyHTML                                                                ;
         Value '<body bgcolor="White"><h3>Lengthy operation</h3></body>'            ;
         WIDTH  ( wAddHTML.Width - GetBorderWidth() * 2 )                           ;
         HEIGHT ( wAddHTML.Height - GetTitleHeight() - GetBorderHeight() * 2 - 45 ) ;
         Border

      @ ( wAddHTML.MyHTML.Height + 20 ), ( wAddHTML.MyHTML.Col + 20 ) Checkbox cbxScroll ;
         Caption 'Auto scroll' Width 80 Height 15

      @ ( wAddHTML.MyHTML.Height + 10 ), ( wAddHTML.MyHTML.Width - 120 ) Button btnStart ;
         Caption 'Start' Action { || HB_HFill( aBreak, .F. ), Logging() }

   END WINDOW

   On Key Escape of wAddHTML Action { || HB_HFill( aBreak, .T. ), wAddHTML.Release }
   On Key Alt+X of wAddHTML Action AppDone()

   CENTER WINDOW wAddHTML
   ACTIVATE WINDOW wAddHTML

   RETURN

   ****** End of TestAddHTML2 ******

   /******
   *       Logging()
   *       ѕример формирование лога
   */

STATIC PROCEDURE Logging

   MEMVAR aBreak

   STATIC nLine := 1
   LOCAL nHandle := GetControlHandle( 'MyHTML', 'wAddHTML' )                                                             , ;
      aMsg    := { '<code><br>Line number %1$s</code>'                                                                , ;
      '<code><br>Oops, something went wrong at line %1$s</code>'                                         , ;
      '<code><br><font color="red"Oops, something went wrong at line %1$s</code></font>'                 , ;
      '<code><br><font bgcolor="red">Something went wrong <i>really</i> wrong at line %1$s</font></code>', ;
      '<code><br><font color=blue>Warning on line %1$s, <a href="CMD:STOPLOG" title="click me and I promise to stop">Click here</a> to stop this output.</font></code>', ;
      "<code><br><font bgcolor='yellow'>This looks groovy</font> don't you think?</code>"                  ;
      }                                                                                                    , ;
      nLen                                                                                                            , ;
      cString

   //<code><br><font color=blue>Warning on line %d, <a href=\"blah\" title='click me and I promise to stop'>Click here</a> to stop this output.</font></code>"
   wAddHTML.btnStart.Caption := 'Stop'
   wAddHTML.btnStart.Action  := { || aBreak[ 'Stop' ] := .T. }

   nLen := Len( aMsg )

   DO WHILE !aBreak[ 'Stop' ]

      cString := aMsg[ HB_RandomInt( 1, nLen ) ]
      cString := HB_StrFormat( cString, LTrim( Str( nLine ) ) )

      IF wAddHTML.cbxScroll.Value
         QHTM_AddHTML2( nHandle, cString, 2 )
      ELSE
         QHTM_AddHTML2( nHandle, cString, 1 )
      ENDIF

      nLine ++

      Do Events

      // «амедл€ет вывод

      Inkey( 0.1, INKEY_ALL )

   ENDDO

   IF !aBreak[ 'Exit' ]
      wAddHTML.btnStart.Caption := 'Start'
      wAddHTML.btnStart.Action  := { || HB_HFill( aBreak, .F. ), Logging() }
   ENDIF

   RETURN

   ****** End of Logging ******
