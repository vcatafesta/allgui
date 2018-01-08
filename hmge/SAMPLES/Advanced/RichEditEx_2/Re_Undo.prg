/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2002-2005 Roberto Lopez <harbourminigui@gmail.com>
* http://harbourminigui.googlepages.com/
* Copyright 2003-2009 Janusz Pora <JanuszPora@onet.eu>
*/

#include "minigui.ch"

FUNCTION Undo_Click()

   lUndo :=.t.
   UndoRTF(hEd)
   lUndo :=.f.

   RETURN NIL

FUNCTION Redo_Click()

   RedoRTF(hEd)

   RETURN NIL

FUNCTION AddMenuUndo( nUndo ,typ )

   LOCAL x, n, cx, nu
   LOCAL action , cAction , Caption, cyUndo_Id, cxUndo_Id

   X:=len(aUndo)
   CAPTION := emumUndo[nUndo+1]
   cAction := '{|| mUndo_Click( 1 ) }'
   ACTION :=&cAction

   IF typ == 1
      // Check if this is the first item
      IF len(aUndo) == 0
         // Modify a first element the menu
         cxUndo_Id := cUndo_Id
         _ModifyMenuItem ( cxUndo_Id , MainForm ,caption , action  )
         aadd( aUndo , { nUndo, cUndo_Id, action, 1 })
      ELSE
         IF aUndo[1,1] != nUndo
            cx:=  alltrim(str( x ))   //strzero(x,2)
            cyUndo_Id := cUndo_Id +'_'+ cx
            cxUndo_Id := aUndo[1,2]
            _InsertMenuItem ( cxUndo_Id , MainForm ,caption , action, cyUndo_Id  )
            ASIZE(aUndo, Len(aUndo)+1)
            AINS( aUndo, 1 )
            cAction := '{|| mUndo_Click( 1 )}'
            ACTION :=&cAction
            aUndo[ 1 ] := {nUndo,cyUndo_Id,action,1}
         ELSE
            nU := aUndo[ 1 , 4 ] + 1
            aUndo[ 1 , 4 ] := nU
            cxUndo_Id := aUndo[1,2]
            _ModifyMenuItem ( cxUndo_Id , MainForm , Caption+' ('+alltrim(str(nU))+')' , aUndo[1,3] )

         ENDIF

      ENDIF
   ELSE
      IF aUndo[1,1] != nUndo
         cxUndo_Id := aUndo[ 1 , 2 ]
         ADEL( aUndo, 1 )
         ASIZE(aUndo, Len(aUndo)-1)
         IF len(aUndo)>0
            _RemoveMenuItem( cxUndo_Id , MainForm)
         ELSE
            _ModifyMenuItem ( cxUndo_Id , MainForm ,caption , action  )
         ENDIF
      ELSE
         nU := aUndo[ 1 , 4 ] - 1
         aUndo[ 1 , 4 ] := nU
         cxUndo_Id := aUndo[1,2]
         _ModifyMenuItem ( cxUndo_Id , MainForm , Caption+' ('+alltrim(str(nU))+')' , aUndo[1,3] )
      ENDIF
   ENDIF
   IF CanUndo(hEd)
      IF len(aUndo) != X
         FOR n := 1 to len(aUndo)
            cAction := '{|| mUndo_Click( '+str(n) + ') }'
            ACTION :=&cAction
            nU := aUndo[ n , 4 ]
            CAPTION := emumUndo[aUndo[n,1]+1]
            cxUndo_Id := aUndo[n,2]
            _ModifyMenuItem ( cxUndo_Id , MainForm , Caption+' ('+alltrim(str(nU))+')' , action )
         NEXT
      ENDIF
   ELSE
      aUndo := {}
   ENDIF

   RETURN NIL

FUNCTION mUndo_Click( nUndoIt )

   LOCAL nPos , n , nUndo
   LOCAL aTyp := {}

   nPos :=  nUndoIt
   FOR n := 1 to nPos
      Aadd(aTyp,aUndo[n,1])
   NEXT
   syg(0)
   FOR n := 1 to len(aTyp)
      nUndo := aTyp[n]
      DO WHILE nUndo == GetUndoName(hEd) .and. CanUndo(hEd)
         Undo_Click()
      ENDDO
   NEXT
   IF ! CanUndo(hEd)
      aUndo := {}
   ENDIF

   RETURN NIL

FUNCTION ClearUndo_Click()

   LOCAL n , cxUndo_Id

   FOR n :=1 to len(aUndo)
      cxUndo_Id := aUndo[ n , 2 ]
      _RemoveMenuItem( cxUndo_Id , MainForm)
   NEXT
   aUndo:={}
   ClearUndoBuffer(hEd)
   Btn_Stat(1)

   RETURN NIL

#pragma BEGINDUMP

#define _WIN32_IE      0x0500
#define HB_OS_WIN_USED
#define _WIN32_WINNT   0x0400
#include <shlobj.h>

#include <windows.h>
#include <commctrl.h>
#include <richedit.h>
#include "hbapi.h"
#include "hbvm.h"
#include "hbstack.h"
#include "hbapiitm.h"
#include "winreg.h"
#include "tchar.h"
#include "Winuser.h"
#include <wingdi.h>
#include <setupapi.h>

#pragma argsused
int CALLBACK enumFontFamilyProc(ENUMLOGFONTEX *lpelfe, NEWTEXTMETRICEX *lpntme, DWORD FontType, LPARAM lParam)
{
   if (lpelfe && lParam)
   {
      if (FontType == TRUETYPE_FONTTYPE ) //DEVICE_FONTTYPE | RASTER_FONTTYPE
         SendMessage( (HWND) lParam, CB_ADDSTRING, 0, (LPARAM) (LPSTR) lpelfe->elfFullName);
   }

    return 1;
}

void enumFonts(HWND hWndEdit )
{
   LOGFONT lf;
   HDC hDC = GetDC(NULL);
   HWND hWnd = hWndEdit;
   lf.lfCharSet=ANSI_CHARSET;
   lf.lfPitchAndFamily=0;
   strcpy(lf.lfFaceName,"\0");

   EnumFontFamiliesEx(hDC, &lf, (FONTENUMPROC) enumFontFamilyProc, (LPARAM) hWnd, 0);
   SendMessage( (HWND) hWnd, CB_SETDROPPEDWIDTH, 200, 0);
   ReleaseDC(NULL, hDC);
}

HB_FUNC( RE_GETFONTS)
{
   enumFonts((HWND) hb_parnl (1) );
}

HB_FUNC ( GETDEVCAPS ) // GetDevCaps ( hwnd )
{

    INT      ix;
    HDC      hdc;
    HWND     hwnd;

    hwnd =   (HWND) hb_parnl (1);

    hdc = GetDC( hwnd );

    ix =  GetDeviceCaps( hdc,LOGPIXELSX );

    ReleaseDC( hwnd, hdc );

    hb_retni( (UINT) ix );

}

#pragma ENDDUMP
