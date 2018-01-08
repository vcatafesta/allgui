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
         MAIN                             ;
         NOMAXIMIZE                       ;
         NOSIZE

      DEFINE TAB tbTest ;
            At 5, 5    ;
            WIDTH 380  ;
            HEIGHT 360 ;
            HotTrack

         Page 'Clipboard'  // Operations with Clipboard

            @ 35, 20 ButtonEx btnGetClip                                      ;
               CAPTION 'Get'                                            ;
               WIDTH 50                                                 ;
               FONTCOLOR BROWN                                          ;
               ACTION MSGINFO_( System.Clipboard, 'Text in clipboard' ) ;
               BACKCOLOR WHITE

            @ 35, 80 ButtonEx btnSetClip                             ;
               CAPTION 'Set'                                   ;
               WIDTH 50                                        ;
               FONTCOLOR BROWN                                 ;
               ACTION System.Clipboard := 'Hello Clipboard!!!' ;
               BACKCOLOR WHITE

            @ 35, 180 ButtonEx btnClearClip                                                       ;
               CAPTION 'Clear'                                                             ;
               WIDTH 50                                                                    ;
               FONTCOLOR RED                                                               ;
               ACTION { || ClearClipboard(), MSGINFO_( 'Clipboard cleaned!', 'Warning' ) } ;
               BACKCOLOR WHITE

            @ 35, 280 ButtonEx btnTag    ;
               CAPTION '{...}'    ;
               WIDTH 50           ;
               FONTCOLOR BLUE     ;
               Bold               ;
               ACTION Bracketed() ;
               BACKCOLOR WHITE

            @ 75, 20 EditBox edtText ;
               WIDTH 340       ;
               HEIGHT 260      ;
               VALUE 'Highlight the text in a word or more, and then click button "{...}"'  ;
               NOHSCROLL
         END PAGE

         Page 'Desktop'   // Desktop sizes

            @ 60, 110 ButtonEx btnWidth                                       ;
               CAPTION 'Get Desktop Width'                             ;
               WIDTH 140                                               ;
               ACTION MSGINFO_( System.DesktopWidth, 'Desktop width' ) ;
               FONTCOLOR BROWN                                         ;
               BACKCOLOR WHITE

            @ 130, 110 ButtonEx btnHeight                                        ;
               CAPTION 'Get Desktop Height'                              ;
               WIDTH 140                                                 ;
               ACTION MSGINFO_( System.DesktopHeight, 'Desktop height' ) ;
               FONTCOLOR BROWN                                           ;
               BACKCOLOR WHITE

         END PAGE

         Page 'System Folders'  // System Folders location

            @ 60, 95 ButtonEx btnDesktopPath                                    ;
               CAPTION 'Get Desktop Folder'                               ;
               WIDTH 170                                                  ;
               ACTION MSGINFO_( System.DesktopFolder, 'Path to Desktop' ) ;
               FONTCOLOR BROWN                                            ;
               BACKCOLOR WHITE

            @ 105, 95 ButtonEx btnMyDocPath                                               ;
               CAPTION 'Get MyDocuments Folder'                                    ;
               WIDTH 170                                                           ;
               ACTION MSGINFO_( System.MyDocumentsFolder, 'Path to My Documents' ) ;
               FONTCOLOR BROWN                                                     ;
               BACKCOLOR WHITE

            @ 150, 95 ButtonEx btnProgPath                                                  ;
               CAPTION 'Get Program Files Folder'                                    ;
               WIDTH 170                                                             ;
               ACTION MSGINFO_( System.ProgramFilesFolder, 'Path to Program Files' ) ;
               FONTCOLOR BROWN                                                       ;
               BACKCOLOR WHITE

            @ 195, 95 ButtonEx btnWinPath                                               ;
               CAPTION 'Get Windows Folder'                                      ;
               WIDTH 170                                                         ;
               ACTION MSGINFO_( System.WindowsFolder, 'Path to Windows folder' ) ;
               FONTCOLOR BROWN                                                   ;
               BACKCOLOR WHITE

            @ 240, 95 ButtonEx btnSysPath                                               ;
               CAPTION 'Get System Folder'                                       ;
               WIDTH 170                                                         ;
               ACTION MSGINFO_( System.SystemFolder, 'Path to System32 folder' ) ;
               FONTCOLOR BROWN                                                   ;
               BACKCOLOR WHITE

            @ 285, 95 ButtonEx btnTempPath                                        ;
               CAPTION 'Get Temp Folder'                                   ;
               WIDTH 170                                                   ;
               ACTION MSGINFO_( System.TempFolder, 'Path to Temp folder' ) ;
               FONTCOLOR BROWN                                             ;
               BACKCOLOR WHITE

         END PAGE

         Page 'Printer'  // Show Default Printer

            @ 60, 110 ButtonEx btnDefPrinter                                         ;
               CAPTION 'Get Default Printer'                                  ;
               WIDTH 140                                                      ;
               ACTION MSGINFO_( System.DefaultPrinter, 'Printer by default' ) ;
               FONTCOLOR BROWN                                                ;
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
