/*
* Harbour MiniGUI Clipboard Test
* (c) 2002-2009 Roberto Lopez <harbourminigui@gmail.com>
* Revised by Vladimir Chumachenko <ChVolodymyr@yandex.ru>
*/

#include "MiniGUI.ch"

#translate MSGINFO_( <cMessage>, <cTitle> )        ;
   =>                                      ;
   MsgInfo( <cMessage>, <cTitle>, , .F., .F. )

/*****
*   Set tests for:
*   - clipboard (get/store text, clear)
*   - Desktop size (width, height)
*   - location of system folders (Desktop, My documents, Program Files,
*     Windows, System32, Tmp)
*   - the name of the default printer
*/

PROCEDURE Main

   DEFINE WINDOW wDemo                    ;
         At 0, 0                          ;
         WIDTH 400                        ;
         HEIGHT 400                       ;
         TITLE 'Clipboard & Others Tests' ;
         Main                             ;
         NoMaximize                       ;
         NOSIZE

      DEFINE TAB tbTest ;
            At 5, 5    ;
            WIDTH 380  ;
            HEIGHT 360 ;
            HotTrack

         Page 'Clipboard'  // Operations with Clipboard

            @ 35, 20 ButtonEx btnGetClip                                      ;
               Caption 'Get'                                            ;
               WIDTH 50                                                 ;
               FontColor BROWN                                          ;
               Action MSGINFO_( System.Clipboard, 'Text in clipboard' ) ;
               BACKCOLOR WHITE

            @ 35, 80 ButtonEx btnSetClip                             ;
               Caption 'Set'                                   ;
               WIDTH 50                                        ;
               FontColor BROWN                                 ;
               Action System.Clipboard := 'Hello Clipboard!!!' ;
               BACKCOLOR WHITE

            @ 35, 180 ButtonEx btnClearClip                                                       ;
               Caption 'Clear'                                                             ;
               WIDTH 50                                                                    ;
               FontColor RED                                                               ;
               Action { || ClearClipboard(), MSGINFO_( 'Clipboard cleaned!', 'Warning' ) } ;
               BACKCOLOR WHITE

            @ 35, 280 ButtonEx btnTag    ;
               Caption '{...}'    ;
               WIDTH 50           ;
               FontColor BLUE     ;
               Bold               ;
               Action Bracketed() ;
               BACKCOLOR WHITE

            @ 75, 20 EditBox edtText ;
               WIDTH 340       ;
               HEIGHT 260      ;
               Value 'Highlight the text in a word or more, and then click button "{...}"'  ;
               NoHScroll
         END PAGE

         Page 'Desktop'   // Desktop sizes

            @ 60, 110 ButtonEx btnWidth                                       ;
               Caption 'Get Desktop Width'                             ;
               WIDTH 140                                               ;
               Action MSGINFO_( System.DesktopWidth, 'Desktop width' ) ;
               FontColor BROWN                                         ;
               BACKCOLOR WHITE

            @ 130, 110 ButtonEx btnHeight                                        ;
               Caption 'Get Desktop Height'                              ;
               WIDTH 140                                                 ;
               Action MSGINFO_( System.DesktopHeight, 'Desktop height' ) ;
               FontColor BROWN                                           ;
               BACKCOLOR WHITE

         END PAGE

         Page 'System Folders'  // System Folders location

            @ 60, 95 ButtonEx btnDesktopPath                                    ;
               Caption 'Get Desktop Folder'                               ;
               WIDTH 170                                                  ;
               Action MSGINFO_( System.DesktopFolder, 'Path to Desktop' ) ;
               FontColor BROWN                                            ;
               BACKCOLOR WHITE

            @ 105, 95 ButtonEx btnMyDocPath                                               ;
               Caption 'Get MyDocuments Folder'                                    ;
               WIDTH 170                                                           ;
               Action MSGINFO_( System.MyDocumentsFolder, 'Path to My Documents' ) ;
               FontColor BROWN                                                     ;
               BACKCOLOR WHITE

            @ 150, 95 ButtonEx btnProgPath                                                  ;
               Caption 'Get Program Files Folder'                                    ;
               WIDTH 170                                                             ;
               Action MSGINFO_( System.ProgramFilesFolder, 'Path to Program Files' ) ;
               FontColor BROWN                                                       ;
               BACKCOLOR WHITE

            @ 195, 95 ButtonEx btnWinPath                                               ;
               Caption 'Get Windows Folder'                                      ;
               WIDTH 170                                                         ;
               Action MSGINFO_( System.WindowsFolder, 'Path to Windows folder' ) ;
               FontColor BROWN                                                   ;
               BACKCOLOR WHITE

            @ 240, 95 ButtonEx btnSysPath                                               ;
               Caption 'Get System Folder'                                       ;
               WIDTH 170                                                         ;
               Action MSGINFO_( System.SystemFolder, 'Path to System32 folder' ) ;
               FontColor BROWN                                                   ;
               BACKCOLOR WHITE

            @ 285, 95 ButtonEx btnTempPath                                        ;
               Caption 'Get Temp Folder'                                   ;
               WIDTH 170                                                   ;
               Action MSGINFO_( System.TempFolder, 'Path to Temp folder' ) ;
               FontColor BROWN                                             ;
               BACKCOLOR WHITE

         END PAGE

         Page 'Printer'  // Show Default Printer

            @ 60, 110 ButtonEx btnDefPrinter                                         ;
               Caption 'Get Default Printer'                                  ;
               WIDTH 140                                                      ;
               Action MSGINFO_( System.DefaultPrinter, 'Printer by default' ) ;
               FontColor BROWN                                                ;
               BACKCOLOR WHITE

         END PAGE

      END TAB

      ON KEY ESCAPE ACTION ThisWindow.Release()

   END WINDOW

   CENTER WINDOW wDemo
   ACTIVATE WINDOW wDemo

   RETURN

   /******
   *       Bracketed()
   *       Cut text and paste it in the brackets
   */

STATIC PROCEDURE Bracketed

   LOCAL nHandle  := GetControlHandle( 'edtText', 'wDemo' ), ;
      cNewText                                          , ;
      cText

   wDemo.edtText.SetFocus

   ClearClipboard( Application.Handle )
   Cut_Text( nHandle )

   cText := AllTrim( System.Clipboard )
   // OR
   // cText := AllTrim( RetrieveTextFromClipboard() )
   cNewText := ( '{' + cText + '}' )
   IF !Empty( cText )
      cNewText += ' '
   ENDIF

   CopyToClipboard( cNewText )
   Paste_Text( nHandle )

   RETURN

#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

/*

   Cut_Text( nHandle )
   Cut the selected text to clipboard from window

*/

HB_FUNC( CUT_TEXT )
{
   SetFocus( (HWND) hb_parnl( 1 ) );
   SendMessage( ( HWND ) hb_parnl( 1 ), WM_CUT, 0 , 0 );
}

/*

   Paste_Text( nHandle )
   Paste text from the clipboard into the window

*/

HB_FUNC( PASTE_TEXT )
{
   SetFocus( ( HWND ) hb_parnl( 1 ) );
   SendMessage( ( HWND ) hb_parnl( 1 ), WM_PASTE, 0 , 0 );
}

#pragma ENDDUMP
