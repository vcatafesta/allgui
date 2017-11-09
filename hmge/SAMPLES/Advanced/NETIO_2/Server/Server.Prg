/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
* http://harbourminigui.googlepages.com/
* Simple Server for test with NETIO
* Created by : Paulo Sérgio Durço - 23/10/2009 8:30 Hrs
* Thanks Master Roberto Lopez for your great work.
*/

#include "minigui.ch"

MEMVAR c_TITLE, pListenSocket

FUNCTION Main

   LOCAL c_Path := "C:\"
   LOCAL c_Port := "2941"
   LOCAL c_Addr := "127.0.0.1"
   PUBLIC c_TITLE := "HMG Server NetIO"
   PUBLIC pListenSocket

   SET MULTIPLE OFF

   pListenSocket := NIL

   IF !File("Config.ini")
      BEGIN INI FILE ("Config.ini")
         SET SECTION "CONFIGURATION" ENTRY "Port"    To c_Port
         SET SECTION "CONFIGURATION" ENTRY "Path"    To c_Path
         SET SECTION "CONFIGURATION" ENTRY "Address" To c_Addr
      END INI
   ELSE
      BEGIN INI FILE ("Config.ini")
         GET c_Port   Section "CONFIGURATION" ENTRY "Port"
         GET c_Path   Section "CONFIGURATION" ENTRY "Path"
      END INI
   ENDIF

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH 587 HEIGHT 173 ;
         TITLE 'Configurations -- HMG ServerIO' ;
         MAIN ;
         ICON "MAIN" ;
         NOTIFYICON "STOP" ;
         NOTIFYTOOLTIP 'MiniGUI Server NETIO' ;
         ON NOTIFYCLICK Show_Status()

      DEFINE NOTIFY MENU
         ITEM 'About...'      ACTION MsgInfo( 'Simple Server NETIO', c_TITLE )
         ITEM 'Restart Server'   ACTION Restart_Server()
         ITEM 'Configurations'   ACTION Show_Config()
         SEPARATOR
         ITEM 'Exit Server'     ACTION Form_1.Release
      END MENU

      @ 10,10 FRAME Frame_1;
         WIDTH  560;
         HEIGHT 120;
         OPAQUE

      @ 20,20 LABEL Label_1;
         WIDTH  40;
         HEIGHT 20;
         VALUE "Port"

      @ 20,110 TEXTBOX Text_1;
         WIDTH  40;
         HEIGHT 20;
         VALUE c_Port;
         INPUTMASK "9999"

      @ 50,20 LABEL Label_2;
         WIDTH  90;
         HEIGHT 20;
         VALUE "Database Path"

      @ 50,110 TEXTBOX Text_2;
         WIDTH  410;
         HEIGHT 20;
         VALUE c_Path;
         READONLY;
         MAXLENGTH 100

      @ 50,530 BUTTON Button_1;
         CAPTION "...";
         ON CLICK SetProperty( "Form_1", "Text_2", "Value", GetFolder( "Database Path" ) );
         WIDTH  30;
         HEIGHT 20

      @ 90,20 BUTTON Button_2;
         CAPTION "Start Server";
         ON CLICK ( Form_1.Hide, Write_Ini() );
         WIDTH  100;
         HEIGHT 28

      @ 90,460 BUTTON Button_3;
         CAPTION "Close";
         ON CLICK Form_1.Hide;
         WIDTH  100;
         HEIGHT 28

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

   RETURN NIL

   * Show config window

PROCEDURE Show_Config()

   Form_1.Restore

   RETURN

   * Start the Server

FUNCTION Start_Server()

   LOCAL c_Path := "C:\"
   LOCAL c_Port := "2941"
   LOCAL c_Addr := "127.0.0.1"

   BEGIN INI FILE ("Config.ini")
      GET c_Port Section "CONFIGURATION" ENTRY "Port"
      GET c_Path Section "CONFIGURATION" ENTRY "Path"
      GET c_Addr Section "CONFIGURATION" ENTRY "Address"
   END INI

   Form_1.Text_1.Value := c_Port
   Form_1.Text_2.Value := c_Path

   pListenSocket := netio_mtserver( Val( AllTrim(Form_1.Text_1.Value) ), c_Addr )

   IF empty( pListenSocket )
      SetProperty( "Form_1","NOTIFYICON","STOP" )
      MsgStop( "Cannot start server!", c_TITLE )
   ELSE
      SetProperty( "Form_1","NOTIFYICON","MAIN" )
      Show_Status()
   ENDIF

   RETURN NIL

   * Stop the Server

FUNCTION Stop_Server()

   IF !empty( pListenSocket )
      SetProperty( "Form_1","NOTIFYICON","STOP" )
      netio_serverstop( pListenSocket )
      pListenSocket := NIL
      Show_Status()
   ENDIF

   RETURN NIL

   * Show Server status

FUNCTION Show_Status()

   IF !empty( pListenSocket )
      MsgInfo( "Hmg Server NetIO is running at Port: " ;
         + AllTrim(Form_1.Text_1.Value) + CHR(13);
         + "Database Path : " + AllTrim(Form_1.Text_2.Value), c_TITLE )
   ELSE
      MsgInfo( "Hmg Server NetIO is stopped!", c_TITLE )
   ENDIF

   RETURN NIL

   * Restart the Server

FUNCTION Restart_Server()

   Stop_Server()
   Start_Server()

   RETURN NIL

   * Write the INI file with content in textbox on Form_1 (Config Window)

FUNCTION Write_Ini()

   IF !File( "Config.ini" )

      BEGIN INI FILE "Config.ini"
         SET SECTION "CONFIGURATION" ENTRY "Port"    To Form_1.Text_1.Value
         SET SECTION "CONFIGURATION" ENTRY "Path"    To Form_1.Text_2.Value
         SET SECTION "CONFIGURATION" ENTRY "Address" To "127.0.0.1"
      END INI

   ENDIF

   Restart_Server()

   RETURN NIL

