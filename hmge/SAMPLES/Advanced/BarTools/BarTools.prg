/*----------------------------------------------------------------------------
MINIGUI - Harbour Win32 GUI library source code

Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
http://harbourminigui.googlepages.com/

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this software; see the file COPYING. If not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA (or
visit the web site http://www.gnu.org/).

As a special exception, you have permission for additional uses of the text
contained in this release of Harbour Minigui.

The exception is that, if you link the Harbour Minigui library with other
files to produce an executable, this does not by itself cause the resulting
executable to be covered by the GNU General Public License.
Your use of that executable is in no way restricted on account of linking the
Harbour-Minigui library code into it.

Parts of this project are based upon:

"Harbour GUI framework for Win32"
Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
Copyright 2001 Antonio Linares <alinares@fivetech.com>

www - http://harbour-project.org

"Harbour Project"
Copyright 1999-2003, http://harbour-project.org/

---------------------------------------------------------------------------*/
/*
File:      BarTools.prg
Contributors:   "SerialComm" By Panagiotis Siampanis <panosavlida@yahoo.gr>
"BarTools" By Pierpaolo Martinello <pier.martinello[at]alice.it>
Description:   Barcode Reader with serial input for MiniGUI
Status:      Public Domain
*/

#include <fileio.ch>
#include <minigui.ch>

MEMVAR cur_path
MEMVAR cIniFile

FUNCTION Main(PRINT)

   cur_path := cFilePath( GetModuleFileName( GetInstance() ) )

   cIniFile := cur_path + Lower( cFileNoExt( GetModuleFileName( GetInstance() ) ) ) + ".ini"

   m->f_Com := 'COM1'
   m->delay    := 500
   M->anno     :=ZAPS(YEAR(DATE()))
   m->label    :="Etichetta.mod"
   m->ScanSet  :='9600,N,8,1'
   m->baud     :={"2400","4800","9600","19200"}
   m->parity   :={"N","O","M","E"}
   // 0,1,2,3 -> none, odd, mark, even

   IF !File(CInifile)
      saveparam(cInifile,.t.)
   ENDIF
   LOAD WINDOW Setbarcode
   ACTIVATE WINDOW setbarcode

   RETURN NIL
   /*
   */

FUNCTION MyGetIni( cSection, cEntry, cDefault, cFile )

   RETURN GetPrivateProfileString(cSection, cEntry, cDefault, cFile )
   /*
   */

FUNCTION cFileDisc( cPathMask )

   RETURN If( At( ":", cPathMask ) == 2, Upper( Left( cPathMask, 2 ) ), "" )
   /*
   */

FUNCTION cFilePath( cPathMask )

   LOCAL n := RAt( "\", cPathMask )

   RETURN If( n > 0, Upper( Left( cPathMask, n ) ), Left( cPathMask, 2 ) + "\" )
   /*
   */

PROCEDURE SaveParam(cIniFile, lForce)

   DEFAULT lForce to .f.
   IF lForce
      writeini( "Barcode","port",m->f_com, cIniFile )
      writeini( "Barcode","Settings",m->scanset, cIniFile )
      writeini( "Barcode","Delay",zaps(m->delay), cIniFile )
   ELSEIF !FILE(cIniFile)
      writeini( "BarCode","port","COM1", cIniFile )
      writeini( "Barcode","Settings",'9600,N,8,1', cIniFile )
      writeini( "Barcode","Delay",zaps(m->delay), cIniFile )
   ENDIF

   RETURN
   /*
   */

FUNCTION GetParam(cIniFile)

   LOCAL pos

   m->F_com       :=MyGetini( "BarCode","port","COM1", cIniFile )
   m->delay       :=val(MyGetini( "Barcode","Delay",zaps(m->delay), cIniFile ))
   m->scanset     :=MyGetini( "BarCode","Settings",'9600,N,8,1', cIniFile )
   pos:=at(",",m->scanset)
   m->string:=substr(m->scanset,pos+1)
   m->f_BaudeRate := val(m->baud[ascan(m->baud,substr(m->scanset,1,pos-1))])
   m->f_parity    := ascan(m->parity,substr(m->string,1,1))
   m->f_databits  := val(substr(m->string,3,1))
   m->f_stopbit   := val(right(m->scanset,1))

   RETURN NIL
   /*
   */

FUNCTION WriteIni( cSection, cEntry, cValue, cFileIni )

   LOCAL hFile
   LOCAL lcSection := "[" + AllTrim( cSection ) + "]"
   LOCAL contenuto
   LOCAL achousecao := .F.
   LOCAL achouvar   := .F.
   LOCAL procura
   LOCAL cArq
   LOCAL nLinhas
   LOCAL nContador  := 0
   LOCAL vargrav     :=  upper( AllTrim( cEntry ) ) + "=" + ;
      AllTrim( cValue ) + Chr( 13 ) + Chr( 10 )
   LOCAL Puntatore
   LOCAL pontvar
   LOCAL pontfim
   LOCAL linha
   LOCAL i
   LOCAL armou   := .F.
   LOCAL disparou := .F.
   LOCAL letra

   IF ! File( cFileIni )
      hFile := FCreate( cFileIni )
   ELSE
      hFile := FOpen( cFileIni, FO_READ + FO_SHARED )
   ENDIF

   IF Ferror() # 0
      MsgInfo( "Errore in apertura di "+CFileini+".INI - DOS ERROR: " + Str( FError(), 2, 0 ) )

      RETURN ""
   ENDIF

   FClose( hFile )

   procura := Upper( AllTrim( lcSection ) )

   contenuto := MemoRead( cFileIni )

   Puntatore := At( procura, Upper( contenuto ) )

   IF Puntatore == 0
      contenuto := contenuto + Chr( 13 ) + Chr( 10 ) + procura + Chr( 13 ) + ;
         Chr( 10 ) + vargrav
   ELSEIF ( pontvar := At(Upper(AllTrim(cEntry)), Upper(contenuto)) ) == 0
      contenuto := Left( contenuto, Puntatore + Len( lcSection ) + 1 ) + vargrav + ;
         Right( contenuto, Len(contenuto) - (1+Puntatore+Len(lcSection)))
   ELSE
      FOR i := pontvar To Len( contenuto )
         letra := SubStr( contenuto, i, 1 )
         IF letra == Chr( 13 )
            armou := .T.
         ELSEIF letra == Chr( 10 ) .AND. armou
            disparou := .T.
         ENDIF
         IF disparou
            pontfim := i
            EXIT
         ENDIF
      NEXT
      pontfim  := Iif( ! disparou, Len( contenuto ), pontfim )
      letra    := SubStr( contenuto, pontvar, ;
         ( pontfim - pontvar ) + 1 )
      contenuto := SubStr( contenuto, 1, pontvar - 1 ) + ;
         vargrav + SubStr( contenuto, pontfim + 1, Len( contenuto ) )
   ENDIF
   MemoWrit( cFileIni, StrTran( contenuto, Chr(26), "" ) )

   RETURN NIL
   /*
   */
   Proc ESCAPE_ON(ARG1)
      LOCAL WinName:=if(arg1==NIL,procname(1),arg1)

      IF upper(WinName)<>'OFF'
         _definehotkey(arg1,0,27,{||_releasewindow(arg1)})
      ELSE
         ON KEY ESCAPE ACTION nil
      ENDIF

      RETURN
      /*
      */

FUNCTION Zaps(nValue)

   DEFAULT nValue to 0

   RETURN ALLTRIM(STR(nValue))
   /*
   */

FUNCTION Setbarcode()

   IF !IsWindowDefined(Setbarcode)
      m->FirstTime:=.F.
      LOAD WINDOW Setbarcode
      ACTIVATE WINDOW Setbarcode
   ENDIF

   RETURN NIL
   */

   Proc CommConnect(set)
      DEFAULT set to .f.
      BarRSet(set)
      IF Init_Com(m->f_com,m->scanset)
         IF set
            SetProperty("Setbarcode","Timer_1","ENABLED",.t.)
         ENDIF
      ELSE
         MsgInfo ("Connesso Su Com "+right(m->f_com,1),"Attivazione")
      ENDIF

      RETURN

      Proc CommDisConnect(set)
         DEFAULT set to .f.
         FinCom()
         IF set
            SetProperty("Setbarcode","Timer_1","ENABLED",.f.)
         ENDIF

         RETURN
         /*
         Proc CommDataSend
         Local nRetBytes

         nRetBytes=WRITECOM32(SetBarcode.text_101.Value)
         //msginfo((HB_VALTOSTR(nRetBytes)),"INFORMATION")

         return nil
         */
         /*
         */

FUNCTION CommDataRx(clear)

   LOCAL nRetBytes:=readcommpure()

   RETURN substr(nRetBytes,1,At( chr(13), nRetBytes ) - 1)
   /*
   */
   proc BarSset()

      m->f_com:="COM"+zaps(Setbarcode.radiogroup_1.value)
      m->scanset :=setbarcode.combo_1.item(setbarcode.combo_1.value)+","+ ;
         setbarcode.combo_2.item(setbarcode.combo_2.value)+","+ ;
         setbarcode.combo_3.item(setbarcode.combo_3.value)+","+ ;
         setbarcode.combo_4.item(setbarcode.combo_4.value)

      //m->delay:=setbarcode.Spinner_1.value
      Saveparam(cInifile,.t.)
      CommDisConnect(.t.)
      BarRSet()
      CommConnect(.t.)

      RETURN

      proc BarRset(set)
         LOCAL pos,string:=m->scanset

         DEFAULT set to .t.
         IF set
            Getparam(cInifile)
            Setbarcode.Label_3.Value:="Last Barcode"
            //setbarcode.Spinner_1.value:=m->delay
            setbarcode.radiogroup_1.value:=val(right(m->f_com,1))
            pos:=at(",",string)
            string:=substr(m->scanset,pos+1)
            setbarcode.combo_1.value:= ascan(m->baud,substr(m->scanset,1,pos-1))
            setbarcode.combo_2.value:= ascan(m->parity,substr(string,1,1))
            setbarcode.combo_3.value:= if(substr(string,3,1)="7",1,2)
            setbarcode.combo_4.value:= val(right(m->scanset,1))
         ENDIF

         RETURN

#pragma BEGINDUMP

#define _WIN32_WINNT  0x0400

#include <windows.h>

#include "hbapi.h"

char   TMP_STR [1024];
static UCHAR   bRead[255];
static HANDLE  ComNum;

HB_FUNC (INIT_COM)
 {
  static DCB BarDCB;

  static  long  retval;

  static  COMMTIMEOUTS  CtimeOut;

  static  char  Msg[2048];
  static  char *ComNumber;
  static  char *Comsettings;

  ComNumber = (char *) hb_parc(1);
  Comsettings = (char *) hb_parc(2);

  //  Open the communications port for read/write (&HC0000000).
  //  Must specify existing file (3).
  ComNum=CreateFile(ComNumber,GENERIC_READ|GENERIC_WRITE,0,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL);
  if(ComNum==INVALID_HANDLE_VALUE)
    {
      strcat(Msg,"Com Port ");
      strcat(Msg,ComNumber);
      strcat(Msg," not available. Use Serial settings (on the main menu) to setup your ports.");
      MessageBox (GetActiveWindow(),Msg,"TestCom",MB_ICONWARNING);
      hb_retl(FALSE);
    }
  // Setup Time Outs for com port
  CtimeOut.ReadIntervalTimeout=20;
  CtimeOut.ReadTotalTimeoutConstant=1;
  CtimeOut.ReadTotalTimeoutMultiplier=1;
  CtimeOut.WriteTotalTimeoutConstant=10;
  CtimeOut.WriteTotalTimeoutMultiplier=1;
  retval=SetCommTimeouts(ComNum,&CtimeOut);
  *Msg=0;
  if(retval==-1)
    {
      retval=GetLastError();
      strcat(Msg,"Unable to set timeouts for port ");
      strcat(Msg,ComNumber);
      strcat(Msg," Error: ");
      strcat(Msg,(char *)(retval));
      MessageBox (GetActiveWindow(),Msg,"TestCom",MB_ICONWARNING);
      retval=CloseHandle(ComNum);
      hb_retl(FALSE);
    }
  retval=BuildCommDCB(Comsettings,&BarDCB);
  *Msg=0;
  if(retval==-1)
    {
      retval=GetLastError();
      strcat(Msg,"Unable to build Comm DCB");
      strcat(Msg,Comsettings);
      strcat(Msg," Error: ");
      strcat(Msg,(char *)(retval));
      MessageBox (GetActiveWindow(),Msg,"TestCom",MB_ICONWARNING);
      retval=CloseHandle(ComNum);
      hb_retl(FALSE);
    }
  retval=SetCommState(ComNum,&BarDCB);
  *Msg=0;
  if(retval==-1)
    {
      retval=GetLastError();
      strcat(Msg,"Unable to set Comm DCB ");
      strcat(Msg,Comsettings);
      strcat(Msg," Error: ");
      strcat(Msg,(char *)(retval));
      MessageBox (GetActiveWindow(),Msg,"TestCom",MB_ICONWARNING);
      retval=CloseHandle(ComNum);
      hb_retl(FALSE);
    }
    hb_retl(TRUE);
}

HB_FUNC (FINCOM )
{
   PurgeComm(ComNum,PURGE_TXCLEAR);
   CloseHandle(ComNum);
}

HB_FUNC (READCOMMPURE)
{
  static  DWORD  RetBytes;
  static  DWORD  i;
  static  char  ReadStr[2048];
  static  long  retval;

   if (hb_parl(1))   // add By Pier for clear buffer if necesssary
   {
    ReadStr[0]=0;
   }
   retval=ReadFile(ComNum,bRead,255,&RetBytes,0);

   if(RetBytes>0)
   {
        sprintf(TMP_STR,"%c",bRead[0]);
        strcpy(ReadStr,TMP_STR);

      for( i=1;i<=RetBytes-1;i++)
      {
        sprintf(TMP_STR,"%c",bRead[i]);
        strcat(ReadStr,TMP_STR);
      }
   }
  // Return the string read from serial port

  hb_retc(ReadStr);

}
HB_FUNC (WRITECOM32)
{
  static DWORD   LenVal;
  static DWORD   RetBytes;
  static char    ComString[2048];
  static char    CRLF[2048];
  static  long  retval;

  sprintf(TMP_STR,"%c%c",13,10);
  strcpy(CRLF,TMP_STR);
  strcpy(ComString,hb_parc(1));
  strcat(ComString,CRLF);

  for( LenVal=0;LenVal<=strlen(ComString)-1;LenVal++)
  {

    bRead[LenVal]=(unsigned char)ComString[LenVal];

  }

  retval=WriteFile(ComNum,bRead,strlen(ComString),&RetBytes,0);

  hb_retnl( RetBytes);
}

#pragma ENDDUMP
