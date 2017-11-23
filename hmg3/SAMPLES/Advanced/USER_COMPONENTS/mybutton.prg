
#define CTRL_TYPE      1
#define CTRL_NAME      2
#define CTRL_HANDLE      3
#define CTRL_PARENT_HANDLE   4
#define CTRL_PROCEDURE      6
#define CTRL_DELETE_STATUS   13
#define WM_COMMAND      0x0111
#define BN_CLICKED      0
#define USR_COMP_PROC_FLAG   63

INIT PROCEDURE _InitMyButton

   InstallEventHandler ( 'MyButtonEventHandler' )
   InstallMethodHandler ( 'SetFocus' , 'MyButtonSetFocus' )
   InstallMethodHandler ( 'Enable' , 'MyButtonEnable' )
   InstallMethodHandler ( 'Disable' , 'MyButtonDisable' )
   InstallPropertyHandler ( 'Handle' , 'SetMyButtonHandle' , 'GetMyButtonHandle' )
   InstallPropertyHandler ( 'Caption' , 'SetMyButtonCaption' , 'GetMyButtonCaption' )

   RETURN

PROCEDURE _DefineMyButton ( cName , nRow , nCol , cCaption , bAction , cParent )

   LOCAL nControlHandle,nId,nParentFormHandle,k,cMacroVar

   IF .Not. _IsWindowDefined (cParent)
      MsgHMGError("Window: "+ cParent + " is not defined.")
   ENDIF

   IF _IsControlDefined (cName,cParent)
      MsgHMGError ("Control: " + cName + " Of " + cParent + " Already defined.")
   ENDIF

   cMacroVar := '_' + cParent + '_' + cName
   k         := _GetControlFree()
   nId         := _GetId()
   nParentFormHandle   := GetFormHandle (cParent)
   nControlHandle      := InitMyButton    ( ;
      nParentFormHandle , ;
      nRow , ;
      nCol , ;
      cCaption , ;
      nId ;
      )

   PUBLIC &cMacroVar. := k

   _HMG_SYSDATA [ CTRL_TYPE ]      [k] := 'MYBUTTON'
   _HMG_SYSDATA [ CTRL_NAME ]      [k] := cName
   _HMG_SYSDATA [ CTRL_HANDLE ]      [k] := nControlHandle
   _HMG_SYSDATA [ CTRL_PARENT_HANDLE ]   [k] := nParentFormHandle
   _HMG_SYSDATA [ 5 ]         [k] := NIL
   _HMG_SYSDATA [ CTRL_PROCEDURE ]      [k] := bAction
   _HMG_SYSDATA [ 7 ]         [k] := NIL
   _HMG_SYSDATA [ 8 ]         [k] := NIL
   _HMG_SYSDATA [ 9 ]         [k] := NIL
   _HMG_SYSDATA [ 10 ]         [k] := NIL
   _HMG_SYSDATA [ 11 ]         [k] := NIL
   _HMG_SYSDATA [ 12 ]         [k] := NIL
   _HMG_SYSDATA [ CTRL_DELETE_STATUS ]   [k] := .F.
   _HMG_SYSDATA [ 14 ]         [k] := NIL
   _HMG_SYSDATA [ 15 ]         [k] := NIL
   _HMG_SYSDATA [ 16 ]         [k] := NIL
   _HMG_SYSDATA [ 17 ]         [k] := NIL
   _HMG_SYSDATA [ 18 ]         [k] := NIL
   _HMG_SYSDATA [ 19 ]         [k] := NIL
   _HMG_SYSDATA [ 20 ]         [k] := NIL
   _HMG_SYSDATA [ 21 ]         [k] := NIL
   _HMG_SYSDATA [ 22 ]         [k] := NIL
   _HMG_SYSDATA [ 23 ]         [k] := NIL
   _HMG_SYSDATA [ 24 ]         [k] := NIL
   _HMG_SYSDATA [ 25 ]         [k] := NIL
   _HMG_SYSDATA [ 26 ]         [k] := NIL
   _HMG_SYSDATA [ 27 ]         [k] := NIL
   _HMG_SYSDATA [ 28 ]         [k] := NIL
   _HMG_SYSDATA [ 29 ]         [k] := NIL
   _HMG_SYSDATA [ 30 ]         [k] := NIL
   _HMG_SYSDATA [ 31 ]         [k] := NIL
   _HMG_SYSDATA [ 32 ]         [k] := NIL
   _HMG_SYSDATA [ 33 ]         [k] := NIL
   _HMG_SYSDATA [ 34 ]         [k] := NIL
   _HMG_SYSDATA [ 35 ]         [k] := NIL
   _HMG_SYSDATA [ 36 ]         [k] := NIL
   _HMG_SYSDATA [ 37 ]         [k] := NIL
   _HMG_SYSDATA [ 38 ]         [k] := NIL
   _HMG_SYSDATA [ 39 ]         [k] := NIL
   _HMG_SYSDATA [ 40 ]         [k] := NIL

   RETURN

FUNCTION MyButtonEventhandler ( hWnd, nMsg, wParam, lParam )

   LOCAL i
   LOCAL RetVal := Nil

   IF nMsg == WM_COMMAND

      i := Ascan ( _HMG_SYSDATA [ CTRL_HANDLE ] , lParam )

      IF i > 0

         IF HiWord (wParam) == BN_CLICKED
            RetVal := 0
            _DoControlEventProcedure ( _HMG_SYSDATA [CTRL_PROCEDURE] [i] , i )
         ENDIF

      ENDIF

   ENDIF

   RETURN RetVal

PROCEDURE MyButtonSetFocus ( cWindow , cControl )

   LOCAL i

   IF GetControlType ( cControl , cWindow ) == 'MYBUTTON'

      SetFocus ( GetControlHandle ( cControl , cWindow ) )

      _HMG_SYSDATA [USR_COMP_PROC_FLAG] := .T.

   ELSE

      _HMG_SYSDATA [USR_COMP_PROC_FLAG] := .F.

   ENDIF

   RETURN

PROCEDURE MyButtonEnable ( cWindow , cControl )

   LOCAL i

   IF GetControlType ( cControl , cWindow ) == 'MYBUTTON'

      EnableWindow ( GetControlHandle ( cControl , cWindow ) )

      _HMG_SYSDATA [USR_COMP_PROC_FLAG] := .T.

   ELSE

      _HMG_SYSDATA [USR_COMP_PROC_FLAG] := .F.

   ENDIF

   RETURN

PROCEDURE MyButtonDisable ( cWindow , cControl )

   LOCAL i

   IF GetControlType ( cControl , cWindow ) == 'MYBUTTON'

      DisableWindow ( GetControlHandle ( cControl , cWindow ) )

      _HMG_SYSDATA [USR_COMP_PROC_FLAG] := .T.

   ELSE

      _HMG_SYSDATA [USR_COMP_PROC_FLAG] := .F.

   ENDIF

   RETURN

FUNCTION SetMyButtonHandle ( cWindow , cControl )

   IF GetControlType ( cControl , cWindow ) == 'MYBUTTON'

      MsgExclamation ( 'This Property is Read Only!' )

   ENDIF

   _HMG_SYSDATA [USR_COMP_PROC_FLAG] := .F.

   RETURN NIL

FUNCTION GetMyButtonHandle ( cWindow , cControl )

   LOCAL RetVal := Nil

   IF GetControlType ( cControl , cWindow ) == 'MYBUTTON'

      _HMG_SYSDATA [USR_COMP_PROC_FLAG] := .T.
      RetVal := GetControlHandle ( cControl , cWindow )

   ELSE

      _HMG_SYSDATA [USR_COMP_PROC_FLAG] := .F.

   ENDIF

   RETURN RetVal

FUNCTION SetMyButtonCaption ( cWindow , cControl , cProperty , cValue )

   IF GetControlType ( cControl , cWindow ) == 'MYBUTTON'

      _HMG_SYSDATA [USR_COMP_PROC_FLAG] := .T.

      SetWindowText ( GetControlHandle ( cControl , cWindow ) , cValue )

   ELSE

      _HMG_SYSDATA [USR_COMP_PROC_FLAG] := .F.

   ENDIF

   RETURN NIL

FUNCTION GetMyButtonCaption ( cWindow , cControl )

   LOCAL RetVal := Nil

   IF GetControlType ( cControl , cWindow ) == 'MYBUTTON'

      _HMG_SYSDATA [USR_COMP_PROC_FLAG] := .T.

      RetVal := GetWindowText ( GetControlHandle ( cControl , cWindow ) )

   ELSE

      _HMG_SYSDATA [USR_COMP_PROC_FLAG] := .F.

   ENDIF

   RETURN RetVal

   * Low Level C Routines

#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"
#include "hbapiitm.h"

HB_FUNC( INITMYBUTTON )
{

   HWND hwnd = (HWND) hb_parnl (1) ;
   HWND hbutton;

   hbutton = CreateWindow( "button" ,
                           hb_parc(4) ,
                           BS_NOTIFY | WS_CHILD | BS_PUSHBUTTON | WS_VISIBLE,
                           hb_parni(3) ,
                           hb_parni(2) ,
                           100 ,
                           28 ,
                           hwnd ,
                           (HMENU)hb_parni(5) ,
                           GetModuleHandle(NULL) ,
                           NULL ) ;

   hb_retnl ( (LONG) hbutton );

}

#pragma ENDDUMP
