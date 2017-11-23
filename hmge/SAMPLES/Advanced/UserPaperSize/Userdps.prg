/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2008 Arcangelo Molinaro <arcangelo.molinaro@fastwebnet.it>
* Revised by Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include <minigui.ch>

STATIC _prtHandle:=0
STATIC _lOpenPrt:=.f.

FUNCTION Main

   LOCAL aPrinters:={}, aPorts:={}, aReturn:={}, aForms:={}
   LOCAL aprnport

   SET DATE BRITISH

   aprnport:=rr_getprinters()
   IF aprnport<>",,"
      aprnport:=str2arr(aprnport,",,")
      aeval(aprnport,{|x,xi| aprnport[xi]:=str2arr(x,',')})
      aeval(aprnport,{|x| aadd(aPrinters,x[1]), aadd(aports,x[2]) })
   ENDIF

   LOAD WINDOW maschera1
   maschera1.Button_1.enabled:=.F.
   maschera1.Button_2.enabled:=.F.
   maschera1.Button_3.enabled:=.F.
   CENTER WINDOW maschera1
   ACTIVATE WINDOW maschera1

   RETURN NIL

PROCEDURE OnInit

   IF !IsWinNT()
      MsgStop( 'This Program Runs In Win2000/XP Only!', 'Stop' )
      QUIT
   ENDIF

   RETURN

STATIC FUNCTION str2arr( cList, cDelimiter )

   LOCAL nPos
   LOCAL aList := {}
   LOCAL nlencd:=0
   LOCAL asub

   DO CASE
   CASE valtype(cdelimiter)=='C'
      cDelimiter:=if(cDelimiter==NIL,",",cDelimiter)
      nlencd:=len(cdelimiter)
      DO WHILE ( nPos := AT( cDelimiter, cList )) != 0
         AADD( aList, SUBSTR( cList, 1, nPos - 1 ))
         cList := SUBSTR( cList, nPos + nlencd )
      ENDDO
      AADD( aList, cList )
   CASE valtype(cdelimiter)=='N'
      DO WHILE len((nPos:=left(clist,cdelimiter)))==cdelimiter
         aadd(alist,npos)
         clist:=substr(clist,cdelimiter+1)
      ENDDO
   CASE valtype(cdelimiter)=='A'
      aeval(cDelimiter,{|x| nlencd+=x})
      DO WHILE len((nPos:=left(clist,nlencd)))==nlencd
         asub:={}
         aeval(cdelimiter,{|x| aadd(asub,left(npos,x)),npos:=substr(npos,x+1)})
         aadd(aList,asub)
         cList:=substr(cList,nlencd+1)
      ENDDO
   ENDCASE

   RETURN ( aList )

FUNCTION Setprtname(aPorts)

   LOCAL nIndex:=This.value

   IF empty(This.Item(nIndex))
      maschera1.Text_1.Value:=""
      maschera1.Text_2.Value:=""
      MSGSTOP("No Printer Selected !","Error")

      RETURN NIL
   ELSE
      maschera1.Text_1.Value:=This.Item(nIndex)
      maschera1.Text_2.Value:=aPorts[nIndex]
      maschera1.Button_1.enabled:=.T.
   ENDIF
   LST2_fill()

   RETURN NIL

FUNCTION Lst2_fill

   LOCAL aReturn:={}

   open_prt()
   aReturn:=ENUM_FORMS(_prtHandle)
   closeprinter()
   IF empty(aReturn)
      MSGSTOP("No Forms found !","Error")
   ELSE
      Lst2_refr(aReturn)
   ENDIF

   RETURN NIL

FUNCTION Lst2_refr(aReturn)

   LOCAL aForms:={},nLen:=0,i

   aForms:=aReturn[1]
   IF !empty(aForms)
      nLen:=LEN(aForms)
      IF nLen>0
         maschera1.List_2.DeleteAllItems
         FOR i= 1 to nLen
            IF !empty(aForms[i])
               maschera1.List_2.Additem(aForms[i])
            ENDIF
         NEXT i
      ELSE
         MSGSTOP("No Forms found !","Error")
      ENDIF
   ENDIF

   RETURN NIL

STATIC FUNCTION closeprinter

   IF _lOpenPrt:=.t.
      close_printer(_prtHandle)
      _prtHandle:=0
      _lOpenPrt:=.f.
   ENDIF

   RETURN NIL

   #define FORM_USER       0
   #define FORM_BUILTIN    1
   #define FORM_PRINTER    2

FUNCTION GetDataForm

   LOCAL nWidth:=0,nLength:=0,aReturn:={},nFlag:=0
   LOCAL cFormName:="",aWidth:={},aLength:={},aName:={},aFlags:={}
   LOCAL nIndex:=This.value

   IF empty(nIndex)
      maschera1.GetBox_1.Value:=""
      MSGALERT("No Form Selected","Warning")

      RETURN NIL
   ENDIF
   open_prt()
   aReturn:=ENUM_FORMS(_prtHandle)
   closeprinter()
   cFormName:=alltrim(This.Item(nIndex))
   aName:=aReturn[1]
   aWidth:=aReturn[2]
   aLength:=aReturn[3]
   aFlags:=aReturn[4]
   maschera1.GetBox_1.Value:=alltrim(cFormName)
   maschera1.GetBox_2.Value:=aWidth [nIndex]
   maschera1.GetBox_3.Value:=aLength[nIndex]
   IF aFlags[nIndex]=FORM_BUILTIN
      maschera1.Text_3.Value:="FORM BUILT IN"
      _distxt(.f.)
   ELSEIF aFlags[nIndex]=FORM_PRINTER
      maschera1.Text_3.Value:="FORM PRINTER"
      _distxt(.f.)
   ELSEIF aFlags[nIndex]=FORM_USER
      maschera1.Text_3.Value:="FORM USER"
      _distxt(.t.)
      maschera1.GetBox_1.enabled:=.f.
      maschera1.Text_3.enabled:=.f.
   ENDIF

   RETURN NIL

STATIC FUNCTION _distxt(lValue)

   maschera1.GetBox_1.enabled:=lValue
   maschera1.GetBox_2.enabled:=lValue
   maschera1.GetBox_3.enabled:=lValue
   maschera1.Text_3.enabled:=lValue
   maschera1.Button_1.enabled:=!lvalue
   maschera1.Button_2.enabled:=lvalue
   maschera1.Button_3.enabled:=lValue

   RETURN NIL

FUNCTION NewUsrFrm()

   LOCAL cFormName:="",nWidth:=0,nHeigth:=0,cReturn:=""

   maschera1.Button_1.enabled:=.f.
   maschera1.Button_2.enabled:=.f.
   maschera1.Button_3.enabled:=.f.
   maschera1.Text_3.enabled:=.f.
   maschera1.GetBox_1.Enabled:=.t.
   maschera1.GetBox_2.Enabled:=.t.
   maschera1.GetBox_3.Enabled:=.t.
   IF (maschera1.Button_1.caption=="New User Form")
      maschera1.GetBox_1.Value:="Form_User"
      maschera1.GetBox_2.Value:=70
      maschera1.GetBox_3.Value:=116
      maschera1.GetBox_1.Setfocus
      maschera1.Button_1.caption:="Save User Form"
      maschera1.Button_1.Enabled:=.t.
      cFormName:=alltrim(maschera1.GetBox_1.Value)
      nWidth:=maschera1.GetBox_2.Value
      nHeigth:=maschera1.GetBox_3.Value
      elseif(maschera1.Button_1.caption=="Save User Form")
      IF MSGYESNO("Add New Form ?","Confirm")
         cFormName:=alltrim(maschera1.GetBox_1.Value)
         nWidth:=maschera1.GetBox_2.Value
         nHeigth:=maschera1.GetBox_3.Value
         open_prt()
         cReturn:=New_Form(_prtHandle,cFormName,nWidth,nHeigth)
         closeprinter()
         maschera1.Button_1.caption:="New User Form"
         IF valtype(cReturn)="A"
            IF !empty(cReturn[1])
               IF cReturn[1]=1902
                  MSGSTOP("Invalid Form Name !","Error")
               ELSEIF cReturn[1]=87
                  MSGSTOP("Invalid Parameter !","Error")
               ELSE
                  MSGSTOP("Error # "+alltrim(str(cReturn[1])),"Error")
               ENDIF
            ENDIF
         ENDIF
      ENDIF
      clean_scrn()
      LST2_fill()
      _ibtnval(.t.)
   ENDIF

   RETURN NIL

FUNCTION ModifyForm

   LOCAL cFormName:="",nWidth:=0,nHeigth:=0,cReturn:=""

   maschera1.Button_1.enabled:=.f.
   maschera1.Button_2.enabled:=.f.
   maschera1.Button_3.enabled:=.f.
   maschera1.Text_3.enabled:=.f.
   maschera1.GetBox_1.enabled:=.t.
   cFormName:=ALLTRIM(maschera1.GetBox_1.Value)
   maschera1.GetBox_1.enabled:=.f.
   nWidth:=maschera1.GetBox_2.Value
   nHeigth:=maschera1.GetBox_3.Value
   IF MSGYESNO("Save Change ?","Confirm")
      open_prt()
      cReturn:=Set_Form(_prtHandle,cFormName,nWidth,nHeigth)
      closeprinter()
      IF valtype(cReturn)="A"
         IF !empty(cReturn[1])
            IF cReturn[1]=1902
               MSGSTOP("Invalid Form Name !","Error")
            ELSEIF cReturn[1]=87
               MSGSTOP("Invalid Parameter !","Error")
            ELSE
               MSGSTOP("Error # "+alltrim(str(cReturn[1])),"Error")
            ENDIF
         ENDIF
      ENDIF
   ENDIF
   clean_scrn()
   LST2_fill()
   _ibtnval(.t.)

   RETURN NIL

STATIC FUNCTION open_prt

   LOCAL cPrinterName:=""

   cPrinterName:=maschera1.Text_1.Value
   IF _lOpenPrt=.t.
      closeprinter()
   ENDIF
   IF _lOpenPrt=.f.
      _prtHandle:=Open_Printer(cPrinterName)
      _lOpenPrt:=.t.
   ENDIF

   RETURN NIL

FUNCTION DelUserForm

   LOCAL cFormName:="",cReturn:=""

   IF MSGYESNO("Delete Selected Form ?","Warning")
      cFormName:=alltrim(maschera1.GetBox_1.Value)
      open_prt()
      cReturn:=delete_form(_prtHandle,cFormName)
      closeprinter()
      IF valtype(cReturn)="A"
         IF !empty(cReturn[1])
            IF cReturn[1]=1902
               MSGSTOP("Invalid Form Name !","Error")
            ELSE
               MSGSTOP("Error # "+alltrim(str(cReturn[1])),"Error")
            ENDIF

            RETURN NIL
         ENDIF
      ENDIF
   ENDIF
   clean_scrn()
   LST2_fill()
   _ibtnval(.t.)

   RETURN NIL

STATIC FUNCTION clean_scrn

   maschera1.Text_3.Value:=""
   maschera1.GetBox_1.Value:=""
   maschera1.GetBox_2.Value:=0
   maschera1.GetBox_3.Value:=0

   RETURN NIL

STATIC FUNCTION _ibtnval(lMode)

   maschera1.Button_1.Enabled:= lMode
   maschera1.Text_3.Enabled  := lMode
   maschera1.Button_2.Enabled:= !lMode
   maschera1.Button_3.Enabled:= !lMode

   RETURN NIL

#pragma BEGINDUMP

#define _WIN32_IE      0x0500
#define _WIN32_WINNT   0x0400

#include <windows.h>

#include "hbapi.h"
#include "hbapiitm.h"

#include <winspool.h>

HB_FUNC (ENUM_FORMS)
{
   PHB_ITEM pfName;
   PHB_ITEM pfSx;
   PHB_ITEM pfSy;
   PHB_ITEM pFlags;
   PHB_ITEM pReturn;
   FORM_INFO_1* pForm ;
   LPBYTE pBuffer ;
   DWORD dwSize = 0;
   DWORD dwForms = 0;
   DWORD i ;

   EnumForms( (HWND) hb_parnl(1),1, NULL,0,&dwSize,&dwForms);
   pBuffer = GlobalAlloc(GPTR, dwSize);
   if (pBuffer == NULL)
     {
         hb_retc("");

         return;
     }
   EnumForms( (HWND) hb_parnl(1),1, pBuffer,dwSize,&dwSize,&dwForms);

   if (dwForms == 0)
     {
//         MessageBox(NULL,"Enum Form Failed","Debug", MB_OK | MB_ICONSTOP );
         hb_retc("");

         return;
     }

   pForm = (FORM_INFO_1*)pBuffer;

   pfName=hb_itemNew(NULL);
   pfSx=hb_itemNew(NULL);
   pfSy=hb_itemNew(NULL);
   pFlags=hb_itemNew(NULL);
   pReturn=hb_itemNew(NULL);

   hb_arrayNew(pfName,dwForms);
   hb_arrayNew(pfSx,dwForms);
   hb_arrayNew(pfSy,dwForms);
   hb_arrayNew(pFlags,dwForms);
   hb_arrayNew(pReturn,0);

   for ( i = 0; i < dwForms; i++)
        {
           hb_arraySetC(pfName,i, pForm->pName);
           hb_arraySetND(pfSx,i,pForm->Size.cx/1000);
           hb_arraySetND(pfSy,i,pForm->Size.cy/1000);
           hb_arraySetNI(pFlags,i,pForm->Flags);
           pForm++;
         }
      hb_arrayAdd(pReturn,pfName);
      hb_arrayAdd(pReturn,pfSx);
      hb_arrayAdd(pReturn,pfSy);
      hb_arrayAdd(pReturn,pFlags);

   hb_itemRelease(hb_itemReturn(pReturn));
   hb_itemRelease  ( pfName );
   hb_itemRelease  ( pfSx );
   hb_itemRelease  ( pfSy );
   hb_itemRelease  ( pFlags );
   GlobalFree(pBuffer);
}

HB_FUNC (OPEN_PRINTER)
{
   OSVERSIONINFO osvi;
   char PrinterName[128] ;
   PRINTER_DEFAULTS pd;
   HANDLE hPrinter = NULL;

   strcpy(PrinterName,hb_parc(1));
   memset(&pd,0, sizeof(pd));
   osvi.dwOSVersionInfoSize = sizeof(OSVERSIONINFO);
   GetVersionEx(&osvi);

   if (osvi.dwPlatformId == VER_PLATFORM_WIN32_NT)
   {
      pd.DesiredAccess = PRINTER_ACCESS_ADMINISTER ;
   }

   if ( !OpenPrinter (PrinterName, &hPrinter, &pd) )
   {
      MessageBox(NULL,"Open Printer Failed","Debug", MB_OK | MB_ICONSTOP );
   }
   hb_retnl((LONG) hPrinter);
}

HB_FUNC (CLOSE_PRINTER)
{
   ClosePrinter((HWND) hb_parnl(1));
}

HB_FUNC (DELETE_FORM)
{
   PHB_ITEM pError;
   DWORD dwFlag;

   dwFlag=DeleteForm( (HWND) hb_parnl(1), (char *) hb_parc(2) );
   if ( dwFlag==0 )
   {
      MessageBox(NULL,"Delete Form Failed","Debug", MB_OK | MB_ICONSTOP );
      pError=hb_itemNew(NULL);
      hb_arrayNew(pError,1);
      hb_arraySetNL(pError,1,GetLastError());
      hb_itemRelease(hb_itemReturn(pError));
   }
}

HB_FUNC (NEW_FORM)
{
  PHB_ITEM pError;
  FORM_INFO_1* pForm ;
  LPBYTE pBuffer ;
  DWORD dwFlag ;

  pBuffer = GlobalAlloc(GPTR, sizeof(pForm));
   if (pBuffer == NULL)
     {
        MessageBox(NULL,"No Allocating Memory","Debug", MB_OK | MB_ICONSTOP );
        hb_retc("");

        return;
     }
   pForm = (FORM_INFO_1*)pBuffer;
   pForm->Flags=0;
   pForm->pName = (char *) hb_parc(2);
   pForm->Size.cx=hb_parnl(3)*1000.00;
   pForm->Size.cy=hb_parnl(4)*1000.00;
   pForm->ImageableArea.left=0;
   pForm->ImageableArea.right= hb_parnl(3)*1000.00   ;
   pForm->ImageableArea.top=0;
   pForm->ImageableArea.bottom = hb_parnl(4)*1000.00  ;

   dwFlag = AddForm( (HWND) hb_parnl(1) , 1 , pBuffer);

   if ( dwFlag == 0 )
    {
      MessageBox(NULL,"Adding New Form Failed","Debug", MB_OK | MB_ICONSTOP );
      pError = hb_itemNew(NULL);
      hb_arrayNew(pError,1);
      hb_arraySetNL(pError,1,GetLastError());
      hb_itemRelease(hb_itemReturn(pError));
      GlobalFree(pBuffer);

      return ;
    }
  GlobalFree(pBuffer);
}

HB_FUNC ( SET_FORM )
{
  PHB_ITEM pError;
  FORM_INFO_1* pForm ;
  LPBYTE pBuffer ;
  DWORD dwFlag ;

   pBuffer = GlobalAlloc(GPTR, sizeof(pForm));
   if (pBuffer == NULL)
     {
        MessageBox(NULL,"No allocated Memory","Debug", MB_OK | MB_ICONSTOP );
        hb_retc("");

        return;
     }
   pForm = (FORM_INFO_1*)pBuffer;

   pForm->Flags=0;
   pForm->pName = (char *) hb_parc(2);
   pForm->Size.cx=hb_parnl(3)*1000.00;
   pForm->Size.cy=hb_parnl(4)*1000.00;
   pForm->ImageableArea.left=0;
   pForm->ImageableArea.right= hb_parnl(3)*1000.00   ;
   pForm->ImageableArea.top=0;
   pForm->ImageableArea.bottom = hb_parnl(4)*1000.00  ;

   dwFlag = SetForm( (HWND) hb_parnl(1), (char *) hb_parc(2), 1, pBuffer );
   if ( dwFlag == 0 )
    {
      MessageBox(NULL,"Modify Form Failed","Debug", MB_OK | MB_ICONSTOP );
      GlobalFree(pBuffer);
      pError = hb_itemNew(NULL);
      hb_arrayNew(pError,1);
      hb_arraySetNL(pError,1,GetLastError());
      hb_itemRelease(hb_itemReturn(pError));

      return;
    }
  GlobalFree(pBuffer);
}

#pragma ENDDUMP
