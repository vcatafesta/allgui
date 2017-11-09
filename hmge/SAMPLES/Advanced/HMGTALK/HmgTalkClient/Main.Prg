* This is a simple Messenger that was written on HMG and HMG IDE 3
* Please, my code is not so good, i know that :D
* Thanks Master Roberto Lopez for your great work.
* Thanks to my brothers of job, Aloisio Perreira and Sandro Valérius and
* my wife Jaqueline de Freitas Durço to use, tests and your suggestions.
* Paulo Sérgio Durço (Vanguarda) January 2010.
* E-Mail vanguarda.one@gmail.com/vanguarda_one@hotmail.com
* Blog   www.hmglights.wordpress.com

#include <minigui.ch>
#define PROGRAM "HMG Talk"
#define VERSION " Test version "
#define COPYRIGHT " Paulo Sérgio Durço, 2010"

MEMVAR c_W_Title
MEMVAR l_Conected
MEMVAR lMsg_Balloon
MEMVAR c_RingTone
MEMVAR c_Str_Con
MEMVAR c_Ip_Server, c_NickName

* This function call the MAIN Window
* and set the environment variables

FUNCTION Main()

   PUBLIC c_W_Title   :=  "HMG Talk"
   PUBLIC l_Conected  := .f.
   PUBLIC lMsg_Balloon:= .f.
   PUBLIC c_RingTone  := GetCurrentFolder() + "\Media\Toque(1).Wav"
   PUBLIC c_Ip_Server, c_NickName

   SET DELETED ON

   LOAD WINDOW Main
   Main.Center
   Main.Activate

   RETURN NIL

   * This function call the LOGIN Window

FUNCTION Login()

   LOAD WINDOW Login
   Login.Center
   Login.Activate

   RETURN NIL

   * This function open a conexion with HMG Talk Server with NETIO.
   * On server side, a unique table was create.

FUNCTION Start_Conexion()

   PUBLIC c_Str_Con := "net:" + Alltrim(c_Ip_Server) + ":2941:Messenger.DBF"

   IF NETIO_CONNECT(Alltrim(c_Ip_Server),2941)

      DBUseArea(.t.,,c_STR_Con,"Messenger",.t.)

      PUBLIC l_Conected := .t.

      Inc_Line(c_NickName,"I´m on-line...")

      Main.Text_1.SetFocus()

   ELSE
      MsgInfo("Cann't connect at : " + Alltrim(c_Ip_Server),c_W_Title)
      ReleaseAllWindows()
   ENDIF

   RETURN NIL

   * This function will include a new msg on the database

FUNCTION Inc_Line(c_Nick,c_Msg,lOnline,c_TONick)

   DEFAULT lOnline  := .t.
   DEFAULT c_TONick := ""

   iif( Alltrim( c_TONick ) == "All" , c_TONick := "" , )

   IF !Empty(c_Msg)

      while(!Messenger->(RLock()))
   ENDDO
   Messenger->(DbAppend())
   Messenger->COD     := Messenger->( LastRec() + 1 )
   Messenger->Nick    := c_Nick
   Messenger->MSG     := c_Msg + " [" + Time()
   IF !Empty(c_TONick)
      Messenger->MSG  := Alltrim(Messenger->MSG) + " - private to " + ;
         Alltrim(c_TONick)
   ENDIF
   Messenger->MSG      := Alltrim(Messenger->MSG) + "]"
   Messenger->ONLINE    := lOnline
   Messenger->TONick   := c_TONick
   Messenger->(DbCommit())
   Messenger->(DbUnlock())
   Main.Text_1.Value := ""
   Main.Text_1.SetFocus()

ENDIF

RETURN NIL

* This function read the news messages in the server, and
* add it on grid

FUNCTION Read_MSG()

   LOCAL n_Reg_Grid := Main.Grid_1.ItemCount
   LOCAL a_Msgs    := {}
   LOCAL i , a , d , e , n_Rest

   IF l_Conected
      IF n_Reg_Grid < Messenger->(LastRec())
         a_Msgs := Read_Data()

         IF Len(a_Msgs) > 0

            READ_Nicks()

            FOR a := 1 to Len(a_Msgs)
               Main.Grid_1.AddItem( a_Msgs[a] )
               // It is a little easter egg, put this string in your
               //client, so all clients will down, and not be able
               //to connect on server until that the server is restart.
               //Try it on private message, is very fun.
               DO CASE
               CASE SubStr(Alltrim(a_Msgs[a][2]),1,08) == "$LINEOFF"
                  Main.Release
               ENDCASE
            NEXT a

            IF lMsg_Balloon
               IF  Main.Check_1.Value
                  FOR i := 1 to len( a_Msgs )
                     MsgBalloon( Alltrim( a_Msgs[i][2] ), ;
                        Alltrim( a_Msgs[i][1] ) +;
                        " Say:" )
                  NEXT i
               ENDIF

               IF  Main.Check_2.Value
                  FOR e := 1 to 5
                     SetProperty("Main","NOTIFYICON",Nil)
                     hb_idleSleep(0.105)
                     SetProperty("Main","NOTIFYICON","MSG")
                     hb_idleSleep(0.105)
                  NEXT e
               ENDIF
            ENDIF

            Main.Label_2.Value := "Last message received at " + ;
               Time()

            IF Alltrim( c_NickName ) != Alltrim( a_Msgs[Len(a_Msgs)][1] )
               IF !Main.Check_1.Value .and. !Main.Check_2.Value
                  iif(empty(c_RingTone),c_RingTone := "Media\Toque(1).Wav",)
                  CallDll32 ( "sndPlaySoundA" , "WINMM.DLL" , c_RingTone , 0 )
               ENDIF
            ENDIF

         ENDIF
      ENDIF

      IF n_Reg_Grid > Messenger->(LastRec())
         FOR d := 1 to n_Reg_Grid
            Main.Grid_1.DeleteItem(d)
         NEXT d
      ENDIF

      IF Main.Check_3.Value
         Main.Grid_1.Value := Main.Grid_1.ItemCount
      ENDIF

   ENDIF

   RETURN NIL

   * This function returns an array with the all news messages
   * of the database.

FUNCTION Read_Data()

   LOCAL a_Msg      := {}
   LOCAL a_Msgs     := {}
   LOCAL i     := 0
   LOCAL a_Position := Main.Grid_1.Item(Main.Grid_1.ItemCount)
   LOCAL n_Position := 0

   Messenger->( DbGoTo( Main.Grid_1.ItemCount + 1 ) )
   While( Messenger->( !EOF() ) )

   IF Empty(Messenger->TONICK) .or. Alltrim(Messenger->TONICK) == Alltrim(c_NickName) .or. ;
         Alltrim(Messenger->NICK)   == Alltrim(c_NickName)

      FOR i := 1 to Main.Grid_1.ItemCount
         aAdd( a_Position, Main.Grid_1.Item(i)[2] )
      NEXT i

      IF aScan( a_Position, Alltrim(Messenger->MSG) ) > 0
      ELSE
         Aadd( a_Msg, Messenger->NICK )
         Aadd( a_Msg, Messenger->MSG )
         Aadd( a_Msgs, a_Msg )
      ENDIF
   ENDIF
   a_Msg := {}
   Messenger->(DBSkip(1))

ENDDO

RETURN a_Msgs

* This function returns an array with the all NickNames
* logged´s in HMG Talk.

FUNCTION Read_Nicks()

   LOCAL i     := 1
   LOCAL a_Nicks    := {}
   LOCAL n_NoLogged := 0
   LOCAL n_OldItem  := Main.Combo_1.Value

   Main.Combo_1.DeleteAllItems

   While( i <= Messenger->( LastRec() ) )

   Messenger->( DbGoTo( i ) )
   IF Messenger->ONLINE
      IF Alltrim(Messenger->Nick) != c_NickName
         IF aScan( a_Nicks, Alltrim( Messenger->NICK ) ) < 1
            Aadd( a_Nicks, Alltrim( Messenger->NICK ) )
         ENDIF
      ENDIF
   ELSE
      n_NoLogged := aScan( a_Nicks, Alltrim( Messenger->NICK ) )
      IF n_NoLogged > 0
         aDel( a_Nicks, n_NoLogged, .t. )
      ENDIF
   ENDIF
   i ++

ENDDO

Aadd( a_Nicks, "All" )

FOR i := 1 to len( a_Nicks )
   Main.Combo_1.AddItem( a_Nicks[i] )
NEXT i

IF n_OldItem < 1
   Main.Combo_1.Value := Len( a_Nicks )
ELSE
   Main.Combo_1.Value := n_OldItem
ENDIF

RETURN NIL

* Show message for all when close HMG TAlk

FUNCTION Close_Msg()

   IF l_Conected
      Inc_Line(c_NickName,"I'm off-line now...",.f.)
   ENDIF

   RETURN NIL

   * Change variable lMsg_Balloon

FUNCTION Change_lMsg(lStatus)

   lMsg_Balloon := lStatus
   IF !lMsg_Balloon
      Main.Text_1.SetFocus()
   ENDIF

   RETURN NIL

   * Restore window MAIN

FUNCTION Show_talk()

   lMsg_Balloon := .f.
   Main.Restore

   RETURN NIL

   * Change mode, messages on tray, silent mode or only sound.

FUNCTION Change_Mode(nItem)

   DO CASE
   CASE nItem = 1
      IF Main.Check_1.Value
         Main.Check_2.Value := .f.
      ENDIF
   CASE nItem = 2
      IF Main.Check_2.Value
         Main.Check_1.Value := .f.
      ENDIF
   ENDCASE

   RETURN NIL

   #include "login_button_1_action.prg"
   #include "main_button_4_action.prg"

   * This part of the code, was copied of TrayBalloon demo avaliable on HMG Extended
   * This source was writen by Grigory Filatov

STATIC PROCEDURE MsgBalloon( cMessage, cTitle )

   LOCAL i := Ascan( _HMG_aFormHandles, GetFormHandle("Main") )

   DEFAULT cMessage := "Prompt", cTitle := PROGRAM

   ShowNotifyIcon( _HMG_aFormhandles[i], .F. , NIL, NIL )

   ShowNotifyInfo( _HMG_aFormHandles[i], .T. , LoadTrayIcon( GetInstance(), ;
      _HMG_aFormNotifyIconName[i] ), _HMG_aFormNotifyIconToolTip[i], cMessage, cTitle )

   RETURN

   /*
   * C-level
   */
#pragma BEGINDUMP

#define _WIN32_IE      0x0500
#define _WIN32_WINNT   0x0500
#include <shlobj.h>

#include <mgdefs.h>
#include <commctrl.h>

static void ShowNotifyInfo(HWND hWnd, BOOL bAdd, HICON hIcon, LPSTR szText, LPSTR szInfo, LPSTR szInfoTitle);

HB_FUNC ( SHOWNOTIFYINFO )
{
   ShowNotifyInfo( (HWND) HB_PARNL(1), (BOOL) hb_parl(2), (HICON) hb_parnl(3), (LPSTR) hb_parc(4),
         (LPSTR) hb_parc(5), (LPSTR) hb_parc(6) );
}

static void ShowNotifyInfo(HWND hWnd, BOOL bAdd, HICON hIcon, LPSTR szText, LPSTR szInfo, LPSTR szInfoTitle)
{
   NOTIFYICONDATA nid;

   ZeroMemory( &nid, sizeof(nid) );

   nid.cbSize      = sizeof(NOTIFYICONDATA);
   nid.hIcon      = hIcon;
   nid.hWnd      = hWnd;
   nid.uID         = 0;
   nid.uFlags      = NIF_INFO | NIF_TIP | NIF_ICON;
   nid.dwInfoFlags      = NIIF_INFO;

   lstrcpy( nid.szTip, TEXT(szText) );
   lstrcpy( nid.szInfo, TEXT(szInfo) );
   lstrcpy( nid.szInfoTitle, TEXT(szInfoTitle) );

   if(bAdd)
      Shell_NotifyIcon( NIM_ADD, &nid );
   else
      Shell_NotifyIcon( NIM_DELETE, &nid );

   if(hIcon)
      DestroyIcon( hIcon );
}

#pragma ENDDUMP

