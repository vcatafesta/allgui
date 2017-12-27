/*******************************************************************************
Filename         : Presa.prg

Created         : 05 April 2012 (10:50:55)
Created by      : Pierpaolo Martinello

Last Updated      : 01/11/2014 16:36:12
Updated by      : Pierpaolo

Comments         : Freeware
*******************************************************************************/

#include 'minigui.ch'
#include 'inkey.ch'
#include 'hbclass.ch'
#include 'Prenota.ch'
#include 'MINIPRINT.CH'

MEMVAR _ControlPosFirst_ , ofatt, delay, acolore
MEMVAR _HMG_IsValidInProgres, aRisorse, _HMG_BField, a_res
MEMVAR aLng,atooltip

SET Procedure to "prenota.prg"
SET Procedure to "Tools.prg"
SET Procedure to "GraphPrint.prg"
/*
*/

FUNCTION Main(putlimit)

   LOCAL hWnd

   DEFAULT putlimit to ""

   PUBLIC _HMG_IsValidInProgres := .F. , _HMG_BField := .F.
   PUBLIC delay, a_res:= {}
   PUBLIC aRisorse:= {{"Room 1","Room 2","Room 3","Video","Car"},{"Sala 2°P","Sala 3°P","Sala 5°P","Videopr.","Macchina"}}
   PUBLIC atooltip:= {" (Click for edit)"," (Click per editare)"}
   PUBLIC aCOLORe := {{255,255,128},{255,128,64},{128,255,255},{107,142,35},{255,0,255} }

   PUBLIC oFatt := Tapplication() ; oFatt:New()
   PRIVATE alng := 1

   Putlimit := upper (Putlimit)

   IF MyGetini( "INTERVALLO","LANG","EN", oFatt:IniFile )= "IT"
      SET LANGUAGE TO ITALIAN
   ENDIF

   DO CASE
   CASE putlimit == "PACK"
      oFatt:pack := .T.
   CASE putlimit == "ITA"
      SET LANGUAGE TO ITALIAN
   CASE putlimit == "EN"
      SET LANGUAGE TO ENGLISH
   CASE putlimit == "NEW"
      ofatt:importNew := .T.
   CASE "HELP" $ putlimit .OR. "/H" $ putlimit .OR. "?" $ putlimit
      msgmulty({"ITA      Per la lingua italiana.","EN       For english language.";
         ,"PACK To delete records marked for deletion.","NEW  To re-create the archive from a certain date.";
         ,"NOTE:","You cannot specify multiple options simultaneously!"},"OPTIONAL PARAMETERS:")
      ChiudiPrg(.T.,"")
   ENDCASE

   aLng :=if(Upper( Left( Set ( _SET_LANGUAGE ), 2 ))="IT",2,1)

   delay := sectotime(ofatt:delay*60)+":00" //"00:30:00:00"

   IF !File(oFatt:IniFile)
      saveparam(oFatt:IniFile,.t.)
   ENDIF

   IF IsExeRunning( cFileName( HB_ArgV( 0 ) ) )
      MsgStop(_HMG_MESSAGE [4], PROGRAM )
      hWnd = FindWindow( PROGRAM )
      IF hWnd > 0
         IF IsIconic( hWnd )
            _Restore( hWnd )
         ELSE
            SetActiveWindow( hWnd )
            _Minimize( hWnd )
            _Restore( hWnd )
         ENDIF
      ELSE

         RETURN NIL
      ENDIF
   ELSE
      SET PROGRAMMATICCHANGE OFF
      IniziaAmbiente()
      LOAD WINDOW Principale
      principale.MonthCal_1.height := principale.MonthCal_1.height +22
      principale.MonthCal_1.width := principale.MonthCal_1.width +10

      IF alng = 1  // ENG
         Principale.label_1.VALUE:= "Click on the colored bars for new or edit!"
         _setitem("statusbar","Principale",1,"     The least interval among the bookings is of "+zaps(oFatt:Delay)+" minutes.")
      ELSE
         Principale.label_1.VALUE:= "Click sulle barre colorate per nuova o editare!"
         _setitem("statusbar","Principale",1,"    L'Intervallo minimo tra le prenotazioni è di "+zaps(oFatt:Delay)+" minuti.")
      ENDIF
      Principale.center
      Principale.activate
   ENDIF
   RELEASE alng, _HMG_BField, delay, a_res , aRisorse,aTooltip, aCOLORe

   RETURN NIL
   /*
   */

PROCEDURE Load_base()

   _DefineHotKey ( "PRINCIPALE" , MOD_ALT + MOD_CONTROL , IF(alng = 1 ,VK_P,VK_S) , {||Statistic()} )
   esc_quit("Principale")
   DRAWMETER(principale.MonthCal_1.value)
   IF ofatt:importNew
      ofatt:ifdata()
   ENDIF

   RETURN
   /*
   */

FUNCTION IniziaAmbiente()

   SET DATE TO FRENCH //ITALIAN
   SET CENT OFF
   SET DELETED ON
   SET EPOCH TO 1995

   SET FONT TO "ARIAL",9
   SET MENUSTYLE EXTENDED
   SET NAVIGATION EXTENDED
   // SET AUTOZOOMING ON

   REQUEST HB_LANG_IT, DBFCDX , DBFFPT
   RDDSETDEFAULT ( "DBFCDX" )
   // Msgbox("ofatt:inifile")

   RETURN NIL
   /*
   */

FUNCTION DrawMeter(day)

   LOCAL n0 ,  wh
   LOCAL k , cnt,  ws ,avl, rPos := 256

   oFAtt:aFrecno := {}
   DEFAULT DAY TO DATE()
   SET( 11 , !ofatt:listdelete )

   EraseWindow("Principale")

   FOR n0 = 0 to 23
      drawline("Principale",rpos+11,30+(n0*20),rpos-1,30+(n0*20))
   NEXT

   FOR n0 = 0 to 24
      drawline("Principale",rpos+11,20+(n0*20),rpos-11,20+(n0*20))

      DRAW TEXT IN WINDOW Principale;
         AT rpos-25, 15+(n0*20) ;
         VALUE zaps(n0) ;
         FONT "MS Sans Serif" SIZE 9 BOLD;
         FONTCOLOR BLACK ;
         TRANSPARENT
   NEXT

   sele 1
   IF ! used()
      opentable()
   ENDIF
   dbgotop()
   Presa->(dbsetorder(1))  // mette in ordine di data

   IF recc() > 0

      FOR k = 1 to 5
         cnt := 0
         n0  := 0

         Presa->(DbGoTop ())
         Presa->(OrdScope (0, dtos(DAY)+LTRIM(STR(k)) ))
         Presa->(OrdScope (1, dtos(DAY)+LTRIM(STR(k)) ))
         Presa->(DbSeek (dtos(DAY)+LTRIM(STR(k))) )

         WHILE !eof()

            avl := TIMETOSEC(alltrim(1->time_in)+":00:00")
            AADD( oFAtt:aFrecno,recno() )
            wh  := 20*(TIMETOSEC(alltrim(1->time_out)+":00:00");
               - TIMETOSEC(alltrim(1->time_in)+":00:00"))/3600
            ws := 20+( 20*(TIMETOSEC(alltrim(1->time_in)+":00:00")/3600 ))

            DRAW RECTANGLE IN WINDOW PRINCIPALE ;
               AT rPos+(k*30)+(n0*5), ws ;
               TO rPos+22+(k*30), wh+ws ;
               PENCOLOR aCOLORE[k] ;
               FILLCOLOR ReduceColor(aCOLORE[k] , cnt) //COLOR[k]

            DRAW RECTANGLE IN WINDOW PRINCIPALE ;
               AT rPos+(k*30)+(n0*5), ws ;
               TO rPos+22+(k*30), wh+ws

            dbskip()
            cnt ++
            IF min(TIMETOSEC(alltrim(1->time_in)+":00:00"),avl)= TIMETOSEC(alltrim(1->time_in)+":00:00")
               n0 ++
            ENDIF
         End
      NEXT
   ENDIF

   Presa->(OrdScope (0, NIL ))
   Presa->(OrdScope (1, NIL ))

   RETURN NIL
   /*
   */

FUNCTION ReduceColor(icolor , level)

   LOCAL lcolor := aclone(icolor)

   lcolor[2]:= icolor [2] -(level*70)

   RETURN lcolor
   /*
   */

FUNCTION Stampe()

   LOCAL n0 , rPos:= 253
   LOCAL title := {"Reservations of ","Prenotazioni del "}[alng]

   Principale.buttonex_1.hide
   Principale.image_1.row := 50

   DRAW TEXT IN WINDOW Principale;
      AT 140, 400 ;
      VALUE title ;
      FONT "MS Sans Serif" SIZE 9 BOLD;
      FONTCOLOR BLACK ;
      TRANSPARENT

   DRAW TEXT IN WINDOW Principale;
      AT 160, 415 ;
      VALUE dtoc(principale.MonthCal_1.value) ;
      FONT "MS Sans Serif" SIZE 9 BOLD;
      FONTCOLOR BLACK ;
      TRANSPARENT

   FOR n0 = 1 to 5
      DRAW TEXT IN WINDOW Principale;
         AT rPos+9+(n0*30), 20 ;
         VALUE left(arisorse[alng,n0],1)+". "+if(n0 <4,if(alng=2,right(arisorse[alng,n0],3 ),zaps(n0)),'') ;
         FONT "MS Sans Serif" SIZE 9 BOLD;
         FONTCOLOR BLACK ;
         TRANSPARENT
   NEXT

   PrintWindow ( "Principale" , .t. , .t. , 0 , 0 , 520 ,440  )
   drawMeter(principale.MonthCal_1.value)
   Principale.image_1.row := 30
   Principale.buttonex_1.show

   RETURN NIL
   /*
   */

FUNCTION PRINTWINDOW ( cWindowName , lPreview , ldialog , nRow , nCol , nWidth , nHeight )

   LOCAL msgPerr := {"Can't Init Printer.","Impossibile Inizializzare la stampante."}
   LOCAL msgWerr := {"Window Not Defined.","Window Non definito."}
   LOCAL lSuccess
   LOCAL TempName
   LOCAL W
   LOCAL H
   LOCAL HO
   LOCAL VO
   LOCAL bw , bh , r , tw , th
   LOCAL ntop , nleft , nbottom , nright

   IF valtype ( nRow ) == 'U' ;
         .or. ;
         valtype ( nCol ) == 'U' ;
         .or. ;
         valtype ( nWidth ) == 'U' ;
         .or. ;
         valtype ( nHeight ) == 'U'

      ntop    := -1
      nleft   := -1
      nbottom := -1
      nright  := -1

   ELSE

      ntop    := nRow
      nleft   := nCol
      nbottom := nHeight + nRow
      nright  := nWidth + nCol

   ENDIF

   IF ValType ( lDialog ) == 'U'
      lDialog   := .F.
   ENDIF

   IF ValType ( lPreview ) == 'U'
      lPreview := .F.
   ENDIF

   IF lDialog

      IF lPreview
         SELECT PRINTER DIALOG TO lSuccess PREVIEW
      ELSE
         SELECT PRINTER DIALOG TO lSuccess
      ENDIF

      IF ! lSuccess

         RETURN NIL
      ENDIF

   ELSE

      IF lPreview
         SELECT PRINTER DEFAULT TO lSuccess PREVIEW
      ELSE
         SELECT PRINTER DEFAULT TO lSuccess
      ENDIF

      IF !lSuccess
         MSGMINIGUIERROR ( msgPerr[alng] ) //( "Can't Init Printer." )
      ENDIF

   ENDIF

   IF ! _IsWIndowDefined ( cWindowName )
      MSGMINIGUIERROR  ( msgWerr[alng] )  //( 'Window Not Defined.' )
   ENDIF

   TempName := GetTempFolder() + '\_hmg_printwindow_' + alltrim(str(int(seconds()*100))) + '.bmp'
   //DoMethod( cWindowName, 'SaveAs', TempName )
   SAVEWINDOWBYHANDLE ( GetFormHandle ( cWindowName ) , TempName , ntop , nleft , nbottom , nright )

   HO := GETPRINTABLEAREAHORIZONTALOFFSET()
   VO := GETPRINTABLEAREAVERTICALOFFSET()

   W := GETPRINTABLEAREAWIDTH() - 10 - ( HO * 2 )
   H := GETPRINTABLEAREAHEIGHT() - 10 - ( VO * 2 )

   IF ntop == -1

      bw := GetProperty ( cWindowName , 'Width' )
      bh := GetProperty ( cWindowName , 'Height' ) - GetTitleHeight ()

   ELSE

      bw := nright - nleft
      bh := nbottom - ntop

   ENDIF

   r := bw / bh

   tw := 0
   th := 0

   DO WHILE .t.

      tw ++
      th := tw / r

      IF tw > w .or. th > h
         EXIT
      ENDIF

   ENDDO

   START PRINTDOC

      START PRINTPAGE

         @ VO + 10 + ( ( h - th ) / 2 ) , HO + 10 + ( ( w - tw ) / 2 ) PRINT IMAGE TempName WIDTH tW HEIGHT tH

      END PRINTPAGE

   END PRINTDOC

   DO EVENTS
   Ferase(TempName)

   RETURN NIL
   /*
   msgbox(tstring(timetosec(PRESA->TIME_out)-timetosec(PRESA->TIME_IN)),"Totale")
   */

FUNCTION Statistic()

   LOCAL cnt := {} , ;
      noldorder   := Presa->(indexord()), ; // original file index order
      ntargetpos  := Presa->(recno())       // position of target file
   LOCAL aLbl    := {{ 'From day:' ,'to day:'},{'Dal giorno:','Al giorno' }}[alng] ,;
      aIniVal := { presa->data_in, date() },;
      aFmt    := { '99/99/99' , '99/99/99' },;
      a_msg   := {"The final date cannot be inferior to that initial!";
      ,"La data finale NON può essere inferiore a quella iniziale !"},;
      a_imsg  := {'Selection options:','Opzioni di selezione:' } [alng]
   PRIVATE a_res := {}

   a_Res    := InputWindow ( a_imsg , aLbl , aIniVal , aFmt )

   IF a_Res [1] == Nil

      RETURN NIL
   ELSEIF a_Res[2] < a_Res [1]
      msgstop(a_msg[alng])

      RETURN NIL
   ENDIF

   Presa->(dbsetorder(1))  // mette in ordine di val(codice articolo)

   Presa->(DbGoTop ())
   Presa->(OrdScope (0, dtos(a_res[1])))
   Presa->(OrdScope (1, dtos(a_res[2])))
   Presa->(DbSeek (dtos(a_Res[1])) )

   cnt := { 0, 0, 0, 0, 0 }
   DBEval( {|| cnt[val(_field->resource)]+= (timetosec(PRESA->TIME_out)-timetosec(PRESA->TIME_IN))/60 },;
      {|| !deleted()},,,, .F. )

   IF ordkeycount() > 0
      IF recc() > 0
         MainGraph(cnt)
      ENDIF
   ELSE
      msginfo({"There am no booking among the gives suitable!";
         ,"Non ci sono prenotazioni tra le date indicate!"}[alng] )
   ENDIF
   Presa->(OrdScope (0, NIL ))
   Presa->(OrdScope (1, NIL ))

   Presa->(dbgoto(ntargetpos))
   Presa->(dbsetorder(noldorder))  // restore index order
   RELEASE a_res

   RETURN NIL

   /*
   */

FUNCTION ReviseDate(data)

   DEFAULT data to date()
   ofatt:prenuova:=.F.
   SetProperty ( "Principale", "MONTHCAL_1" , "VALUE" ,Data)
   DrawMeter(data)

   RETURN NIL
   /*
   */

FUNCTION CLASSE // function used only for texteditor search

   RETURN NIL
   /*
   */

CREATE CLASS TAPPLICATION

   DATA DELAY            INIT 0
   DATA ExePath          INIT ''
   DATA DataPath         INIT ''
   DATA ReportPath       INIT ''
   DATA SpoolPath        INIT ''
   DATA ProtPath         INIT ''
   DATA aFrecno          INIT {}
   DATA pack             INIT .f.
   DATA Prenuova         INIT .F.
   DATA Action           INIT .F.
   DATA IMPORTNEW        INIT .F.
   DATA INIFILE          INIT ''
   DATA ListDelete       init .F.
   DATA Dbf_driver       INIT "DBFCDX"

   METHOD New()  CONSTRUCTOR
   METHOD IFDATA()

   ENDCLASS

   /*
   */

METHOD New() CLASS TApplication

   ::ExePath    := cFilePath(GetExeFileName())+"\"
   ::DataPath   := ::ExePath
   ::ReportPath := ::ExePath
   ::SpoolPath  := ::ExePath
   ::Inifile    := ::ExePath + Proper( "Prenota")+ ".Ini"
   ::Delay      := val(MyGetini( "INTERVALLO","DELAY","12", ::IniFile ))

   RETURN NIL
   /*
   */

METHOD IFDATA() CLASS TApplication

   LOCAL aLbl    := {{ 'From day:' },{'Dal giorno:' }}[alng] ,;
      aIniVal := {  presa->data_in },;
      aFmt    := { '99/99/99' },;
      status  := 0 ,;
      a_imsg  := {'New archive with import:','Nuovo archivio con importazione:' } [alng]
   LOCAL aEmsg   := {[Repeat the operation!]+CRLF+[as the only active user!];
      ,[Ripetere l'operazione]+CRLF+[come unico utente attivo!]} [alng]
   LOCAL localIp := GetLocalIp()[1],uTmp:=SubStr(LocalIP,Rat(".",LocalIP)+1)+"_"
   LOCAL archivio:= oFatt:DataPath+ uTmp+"PresaNew.DbF"
   LOCAL a_res   := {}
   LOCAL aQmsg   := {"With this option will be untraceable" + CRLF +;
      padc ("each deletion done." ,54) + CRLF + padc ("Continue?",64);
      ,"Con questa opzione verranno perse le tracce"+CRLF+;
      padc("di ogni cancellazione eseguita.",54)+CRLF+padc("Continuo?",64)}

   IF !msgyesno(aQmsg [alng] ,{"Warning","Avviso"}[alng],.t.)

      RETURN NIL
   ENDIF

   StrFile("Maintenance in progress...",oFatt:DataPath+"Maint_"+uTmp+".txt")

   //Check if another user use this option
   IF len(directory(oFatt:DataPath+"Maint*.txt","H")) > 1
      MsgExclamation(aEmsg,"")

      RETURN NIL
   ENDIF

   a_Res   := InputWindow ( a_imsg , aLbl , aIniVal , aFmt )

   IF a_Res [1] == Nil
      deletefile(oFatt:DataPath+"Maint_"+uTmp+".txt")

      RETURN NIL
   ENDIF
   // clean all previous
   IF File(Archivio)
      status := DELETEFILE(archivio)
      IF Status == -5
         msgstop({"File in use elsewhere!","File in uso altrove!"}[alng],"PresaNew" )
      ENDIF
   ENDIF
   COPY to (archivio) for presa->data_in >= a_res[1]
   archivio:= oFatt:DataPath+"Presa.DbF"
   dbcloseall()
   IF File(Archivio)
      status := DELETEFILE(archivio)
      IF Status == -5
         msgstop({"File in use elsewhere!","File in uso altrove!"}[alng],"PresaNew" )
      ENDIF
   ENDIF
   archivio:= oFatt:DataPath+ uTmp+"PresaNew.DbF"
   opentable()
   sele 1
   APPEND from (archivio)
   IF File(Archivio)
      status := DELETEFILE(archivio)
      IF Status == -5
         msgstop({"File in use elsewhere!","File in uso altrove!"}[alng],"PresaNew" )
      ENDIF
   ENDIF
   deletefile(oFatt:DataPath+"Maint_"+uTmp+".txt")
   msginfo({"Import complete!","Importazione completata!"}[alng],"")

   RETURN NIL
   /*
   */

PROCEDURE esci(arg1)

   RELEASE WINDOW &arg1

   RETURN
   /*
   */

PROCEDURE esc_quit(arg1)

   _definehotkey(arg1,0,27,{||chiudiPrg()})

   RETURN
   /*
   */

PROCEDURE Autore()

   LOCAL fsize := Directory( oFatt:ExePath+"Presa.exe" )[1,2]
   ShellAbout( OS(), PROGRAM +[ HMG 1.0]+[ ]+Chr(169) + COPYRIGHT+ LICENZA ;
      +" "+ transform(fsize,"@be 99,999,999" ) )

   RETURN
   /*
   */

PROCEDURE ChiudiPrg(forced,msg)

   LOCAL rtv :=.F.

   DEFAULT forced := .f. ,msg  := {"Quit the program? ","Termino il programma?"}[alng]
   IF !forced
      rtv := msgYESNO(msg,_HMG_MESSAGE [1])
   ENDIF
   IF rtv .or. forced
      DBCOMMITALL()
      DBUNLOCKALL()
      dbcloseall()
      IF _Iswindowdefined('Principale')
         Principale.release
      ENDIF
      QUIT
   ENDIF

   RETURN

   /*
   */

FUNCTION MyGetIni( cSection, cEntry, cDefault, cFile )

   RETURN GetPrivateProfileString(cSection, cEntry, cDefault, cFile )
   /*
   */

FUNCTION SetDelay()

   LOCAL aLbl    := { {'Minutes:'},{'Minuti:'}},;
      aIniVal := { ofatt:delay },;
      aFmt    := { '999' } ,;
      a_res    , ;
      a_msg   := {'Interval among the bookings :','Intervallo tra le prenotazioni:'}[alng]

   a_Res    := InputWindow ( a_msg , aLbl[alng] , aIniVal , aFmt )

   IF a_Res [1] == Nil

      RETURN NIL
   ELSEIF a_Res[1] <> ofatt:Delay
      ofatt:delay:= a_res[1]
      SaveParam(oFatt:IniFile,.t.)
      IF alng = 1  // ENG
         _setitem("statusbar","Principale",1,"     The least interval among the bookings is of "+zaps(oFatt:Delay)+" minutes.")
      ELSE
         _setitem("statusbar","Principale",1,"    L'Intervallo minimo tra le prenotazioni è di "+zaps(oFatt:Delay)+" minuti.")
      ENDIF
   ENDIF

   RETURN NIL
   /*
   */

FUNCTION SaveParam(cIniFile, lForce)

   IF !FILE(cIniFile) .OR. lForce
      BEGIN INI FILE cIniFile
         SET SECTION 'INTERVALLO' ENTRY 'DELAY' TO Zaps(oFatt:Delay)
      END INI
   ENDIF

   RETURN NIL
   /*
   */
#include "indici.prg"
   /*
   */
#pragma BEGINDUMP

#define _WIN32_IE      0x0500
#define HB_OS_WIN_USED
#define _WIN32_WINNT   0x0400
#include <shlobj.h>

#include <windows.h>
#include "hbapi.h"
#include "hbvm.h"
#include "hbstack.h"
#include "hbapiitm.h"
#include "commctrl.h"

#ifdef __XHARBOUR__
#define HB_PARNI( n, x ) hb_parni( n, x )
#define HB_STORC( n, x, y ) hb_storc( n, x, y )
#define HB_STORNI( n, x, y ) hb_storni( n, x, y )
#else
#define HB_PARNI( n, x ) hb_parvni( n, x )
#define HB_STORC( n, x, y ) hb_storvc( n, x, y )
#define HB_STORNI( n, x, y ) hb_storvni( n, x, y )
#endif

HB_FUNC( GETLOCALIP )
{
   WSADATA wsa;
   char cHost[256];
   struct hostent *h;
   int nAddr = 0, n = 0;

   WSAStartup( MAKEWORD( 2, 0 ), &wsa );

   if( gethostname( cHost, 256 ) == 0 )
   {
      h = gethostbyname( cHost );
      if( h )
         while( h->h_addr_list[ nAddr ] )
            nAddr++;
   }

   hb_reta( nAddr );

   if( nAddr )
      while( h->h_addr_list[n] )
         {
         char cAddr[256];
         wsprintf( cAddr, "%d.%d.%d.%d", (BYTE) h->h_addr_list[n][0],
                                         (BYTE) h->h_addr_list[n][1],
                                         (BYTE) h->h_addr_list[n][2],
                                         (BYTE) h->h_addr_list[n][3] );
         HB_STORC( cAddr, -1, ++n );
         }

   WSACleanup();
}

// SAVE WINDOW (Based On Code Contributed by Ciro Vargas Clemov)

HANDLE DibFromBitmap( HBITMAP, HPALETTE );
WORD GetDIBColors( LPSTR lpDIB );

HB_FUNC( SAVEWINDOWBYHANDLE )
{

   HWND            hWnd   = ( HWND ) hb_parnl( 1 );
   HDC            hDC   = GetDC( hWnd );
   HDC            hMemDC ;
   RECT            rc ;
   HBITMAP            hBitmap ;
   HBITMAP            hOldBmp ;
   HPALETTE         hPal = 0;
   const char *          File   = hb_parc(2) ;
   HANDLE            hDIB ;
   int            top   = hb_parni(3) ;
   int            left   = hb_parni(4) ;
   int            bottom   = hb_parni(5) ;
   int            right   = hb_parni(6) ;
   BITMAPFILEHEADER      bmfHdr ;
   LPBITMAPINFOHEADER      lpBI ;
   HANDLE            filehandle ;
   DWORD            dwDIBSize ;
   DWORD            dwWritten ;
   DWORD            dwBmBitsSize ;

   if ( top != -1 && left != -1 && bottom != -1 && right != -1 )
   {
      rc.top = top ;
      rc.left = left ;
      rc.bottom = bottom ;
      rc.right = right ;
   }
   else
   {
      GetClientRect( hWnd, &rc );
   }

   hMemDC  = CreateCompatibleDC( hDC );
   hBitmap = CreateCompatibleBitmap( hDC, rc.right-rc.left, rc.bottom-rc.top );
   hOldBmp = ( HBITMAP ) SelectObject( hMemDC, hBitmap );
   BitBlt( hMemDC, 0, 0 , rc.right-rc.left, rc.bottom-rc.top, hDC, rc.top, rc.left, SRCCOPY );
   SelectObject( hMemDC, hOldBmp );
   hDIB = DibFromBitmap( hBitmap, hPal );

   filehandle = CreateFile( File, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL | FILE_FLAG_SEQUENTIAL_SCAN, NULL);

   lpBI = (LPBITMAPINFOHEADER) GlobalLock(hDIB);
   if (!lpBI)
   {
      CloseHandle(filehandle);

      return;
   }

   if (lpBI->biSize != sizeof(BITMAPINFOHEADER))
   {
      GlobalUnlock(hDIB);
      CloseHandle(filehandle);

      return;
   }

   bmfHdr.bfType = ((WORD) ('M' << 8) | 'B');

   dwDIBSize = *(LPDWORD)lpBI + ( GetDIBColors( (LPSTR) lpBI ) * sizeof(RGBTRIPLE)) ;

   dwBmBitsSize = ((((lpBI->biWidth)*((DWORD)lpBI->biBitCount))+ 31) / 32 * 4) *  lpBI->biHeight;
   dwDIBSize += dwBmBitsSize;
   lpBI->biSizeImage = dwBmBitsSize;

   bmfHdr.bfSize = dwDIBSize + sizeof(BITMAPFILEHEADER);
   bmfHdr.bfReserved1 = 0;
   bmfHdr.bfReserved2 = 0;

   bmfHdr.bfOffBits = (DWORD)sizeof(BITMAPFILEHEADER) + lpBI->biSize + ( GetDIBColors( (LPSTR) lpBI ) * sizeof(RGBTRIPLE)) ;

   WriteFile(filehandle, (LPSTR)&bmfHdr, sizeof(BITMAPFILEHEADER), &dwWritten, NULL);

   WriteFile(filehandle, (LPSTR)lpBI, dwDIBSize, &dwWritten, NULL);

   GlobalUnlock(hDIB);
   CloseHandle(filehandle);

   DeleteObject( hBitmap );
   DeleteDC( hMemDC );
   GlobalFree (hDIB);
   ReleaseDC( hWnd, hDC );

}

#pragma ENDDUMP
