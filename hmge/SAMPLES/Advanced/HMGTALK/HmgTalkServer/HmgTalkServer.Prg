/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
* http://harbourminigui.googlepages.com/
* Simple Server for test with NETIO
* Created by : Paulo Sérgio Durço - 23/10/2009 8:30 Hrs
* Thanks Master Roberto Lopez for your great work.
* It is HMG SERVERIO with some modifications.
* update in 27/01/2010
*/

#include "minigui.ch"

MEMVAR c_TITLE
MEMVAR pListenSocket

* Function Main

FUNCTION Main

   PUBLIC c_TITLE := "HMG Talk Server"
   PUBLIC pListenSocket

   SET MULTIPLE OFF

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH 587 HEIGHT 173 ;
         TITLE 'Configurations -- HMG Talk Server' ;
         MAIN ;
         NOSHOW ;
         NOSIZE NOCAPTION ;
         ICON "MAIN" ;
         NOTIFYICON "MAIN" ;
         NOTIFYTOOLTIP 'HMG Talk Server' ;
         ON NOTIFYCLICK Show_Status() ;
         ON INIT Start_Server() ;
         ON RELEASE Delete_Table()

      DEFINE NOTIFY MENU
         ITEM 'About...'      ACTION MsgInfo( 'HMG Talk Server', c_TITLE )
         ITEM 'Configurations'   ACTION Show_Config()
         ITEM 'Restart Server'   ACTION Restart_Server()
         SEPARATOR
         ITEM 'Exit Server'     ACTION Form_1.Release
      END MENU

      @ 10,10 FRAME Frame_1 ;
         WIDTH  560 ;
         HEIGHT 120 ;
         OPAQUE

      @ 20,20 LABEL Label_1 ;
         WIDTH  40 ;
         HEIGHT 20 ;
         VALUE "Port"

      @ 20,110 TEXTBOX Text_1 ;
         WIDTH  40 ;
         HEIGHT 20 ;
         INPUTMASK "9999"

      @ 50,20 LABEL Label_2 ;
         WIDTH  90 ;
         HEIGHT 20 ;
         VALUE "Database Path"

      @ 50,110 TEXTBOX Text_2 ;
         WIDTH  410 ;
         HEIGHT 20 ;
         READONLY ;
         MAXLENGTH 100 ;

      @ 50,530 BUTTON Button_1 ;
         CAPTION "..." ;
         ON CLICK SetProperty( "Form_1","Text_2","Value",GetFolder ( "Database Path" ) ) ;
         WIDTH  30 ;
         HEIGHT 20

      @ 90,20 BUTTON Button_2 ;
         CAPTION "Restart Server" ;
         ON CLICK Write_Ini() ;
         WIDTH  100 ;
         HEIGHT 28

      @ 90,460 BUTTON Button_3 ;
         CAPTION "Close" ;
         ON CLICK Form_1.Hide ;
         WIDTH  100 ;
         HEIGHT 28

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

   RETURN NIL

   * Show config window

FUNCTION Show_Config()

   Form_1.Restore

   RETURN NIL

   * Start the Server

FUNCTION Start_Server()

   LOCAL c_Path := GetStartupFolder()
   LOCAL c_Port := "2941"
   LOCAL c_Addr := "127.0.0.1"

   pListenSocket := NIL

   IF !File("Config.ini")
      BEGIN INI FILE ("Config.ini")
         SET SECTION "CONFIGURATIONS" ENTRY "Port"    To c_Port
         SET SECTION "CONFIGURATIONS" ENTRY "Path"    To c_Path
         SET SECTION "CONFIGURATIONS" ENTRY "Address" To c_Addr
      END INI
   ELSE
      BEGIN INI FILE ("Config.ini")
         GET c_Port Section "CONFIGURATIONS" ENTRY "Port"
         GET c_Path Section "CONFIGURATIONS" ENTRY "Path"
         GET c_Addr Section "CONFIGURATIONS" ENTRY "Address" DEFAULT c_Addr
      END INI
   ENDIF

   Form_1.Text_1.Value := c_Port
   Form_1.Text_2.Value := c_Path

   pListenSocket := netio_mtserver( Val( AllTrim(c_Port) ), c_Addr )

   IF empty( pListenSocket )
      SetProperty( "Form_1","NOTIFYICON","STOP" )
      MsgStop( "Cannot start server!", c_TITLE )
   ELSE
      SetProperty( "Form_1","NOTIFYICON","MAIN" )
      DBCreate( "Messenger.DBF", {{"COD","N",5,0}, {"NICK","C",10,0}, {"MSG","C",200,0}, ;
         {"ONLINE","L",1,0}, {"TONICK","C",10,0}} )
      Show_Status()
   ENDIF

   RETURN NIL

FUNCTION Delete_Table()

   FErase("Messenger.DBF")

   RETURN NIL

   * Stop the Server

FUNCTION Stop_Server()

   IF !empty( pListenSocket )
      SetProperty( "Form_1","NOTIFYICON","STOP" )
      netio_serverstop( pListenSocket )
      pListenSocket := NIL
   ENDIF

   RETURN NIL

   * Show Server status

FUNCTION Show_Status()

   IF !empty( pListenSocket )
      MsgInfo( "Hmg Talk Server is running at Port: " ;
         + AllTrim(Form_1.Text_1.Value) + CHR(13) ;
         + "Database Path : " + AllTrim(Form_1.Text_2.Value), c_TITLE )
   ELSE
      MsgInfo( "Hmg Talk Server is stopped!", c_TITLE )
   ENDIF

   RETURN NIL

   * Restart the Server

FUNCTION Restart_Server()

   Stop_Server()
   Delete_Table()
   Start_Server()

   RETURN NIL

   * Write the INI file with content in text´s box on Form_1 (Config Window)

FUNCTION Write_Ini()

   IF File("Config.ini")
      fErase("Config.ini")
   ENDIF

   BEGIN INI FILE ("Config.ini")
      SET SECTION "CONFIGURATIONS" ENTRY "Port"    To Form_1.Text_1.Value
      SET SECTION "CONFIGURATIONS" ENTRY "Path"    To Form_1.Text_2.Value
      SET SECTION "CONFIGURATIONS" ENTRY "Address" To "127.0.0.1"
   END INI

   Restart_Server()

   RETURN NIL
