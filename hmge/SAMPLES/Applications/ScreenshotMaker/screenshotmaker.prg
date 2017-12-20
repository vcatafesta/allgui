/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2002-2007 Roberto Lopez <harbourminigui@gmail.com>
* Copyright 2005-2007 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#ifdef __XHARBOUR__
#define __CALLDLL__
#endif

#include "minigui.ch"

#define PROGRAM 'Screenshot Maker'
#define VERSION ' version 1.2'
#define COPYRIGHT ' 2005-2007 Grigory Filatov'

STATIC nJpg := 0, nShotInterval := 2, cSaveFolder := "", cFilename := "#", lMouseClick := .T.

DECLARE WINDOW Form_2

PROCEDURE Main( lStartUp )

   LOCAL lWinRun := .F.

   cSaveFolder := cFilePath( HB_ArgV(0) ) + "\"

   IF !Empty(lStartUp) .AND. Upper(Substr(lStartUp, 2)) == "STARTUP" .OR. ;
         !Empty(GETREGVAR( NIL, "Software\Microsoft\Windows\CurrentVersion\Run", PROGRAM ))
      lWinRun := .T.
   ENDIF

   SET MULTIPLE OFF

   DEFINE WINDOW Form_1          ;
         AT 0,0             ;
         WIDTH 0 HEIGHT 0      ;
         TITLE PROGRAM          ;
         MAIN NOSHOW          ;
         NOTIFYICON 'MAIN'       ;
         NOTIFYTOOLTIP PROGRAM       ;
         ON NOTIFYCLICK IF( lMouseClick, SnapShot(), StopTimer() )

      DEFINE NOTIFY MENU
         ITEM '&AutoRun'      ACTION ( lWinRun := !lWinRun, ;
            Form_1.Auto_Run.Checked := lWinRun, WinRun(lWinRun) ) ;
            NAME Auto_Run
         SEPARATOR
         ITEM '&Options...'      ACTION Form_2()
         ITEM 'A&bout...'      ACTION ShellAbout( "", PROGRAM + VERSION + CRLF + ;
            "Copyright " + Chr(169) + COPYRIGHT, LoadIconByName( "MAIN", 32, 32 ) )
         SEPARATOR
         ITEM 'E&xit'         ACTION Form_1.Release
      END MENU

      Form_1.Auto_Run.Checked := lWinRun

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

   RETURN

STATIC PROCEDURE SnapShot()

   LOCAL cSaveFile, nW := GetDesktopWidth(), nH := GetDesktopHeight()

   nJpg++

   DO WHILE FILE( ( cSaveFile := cSaveFolder + cFilename + StrZero(nJpg, 9)+".jpg" ) ) .AND. nJpg < 999999999

      nJpg++

   ENDDO

   PlayHand()

   Save2Jpg(0, cSaveFile, nW, nH)

   RETURN

#ifdef __XHARBOUR__   // Declaration of DLLs using syntax in CallDll.Lib

   DECLARE SaveToJpgEx(hWnd, cFileName, nWidth, nHeight) IN JPG.DLL ALIAS SAVE2JPG

#else

   DECLARE DLL_TYPE_VOID SaveToJpgEx(DLL_TYPE_LONG hWnd, DLL_TYPE_LPCSTR cFileName, ;
      DLL_TYPE_INT nWidth, DLL_TYPE_INT nHeight) IN JPG.DLL ALIAS SAVE2JPG

#endif

STATIC PROCEDURE Form_2()

   LOCAL cTmpFld

   IF .not. IsWindowDefined(Form_2)

      LOAD WINDOW Form_2

      Form_2.Button_2.Enabled := !IsControlDefined(Timer_1, Form_1)
      Form_2.Button_3.Enabled := IsControlDefined(Timer_1, Form_1)

      CENTER WINDOW Form_2

      ACTIVATE WINDOW Form_2

   ENDIF

   RETURN

STATIC PROCEDURE StartTimer()

   DEFINE TIMER Timer_1 OF Form_1 ;
      INTERVAL 60 / nShotInterval * 1000 ;
      ACTION SnapShot()

   PlayOk()

   Form_2.Release

   RETURN

STATIC PROCEDURE StopTimer()

   IF IsControlDefined(Timer_1, Form_1)

      Form_1.Timer_1.Release
      PlayOk()

   ENDIF

   IF IsWindowDefined(Form_2)

      Form_2.Button_2.Enabled := .T.
      Form_2.Button_3.Enabled := .F.

   ENDIF

   RETURN

STATIC PROCEDURE WinRun( lMode )

   LOCAL cRunName := Upper( GetModuleFileName( GetInstance() ) ) + " /STARTUP", ;
      cRunKey  := "Software\Microsoft\Windows\CurrentVersion\Run", ;
      cRegKey  := GETREGVAR( NIL, cRunKey, PROGRAM )

   IF IsWinNT()
      EnablePermissions()
   ENDIF

   IF lMode
      IF Empty(cRegKey) .OR. cRegKey # cRunName
         SETREGVAR( NIL, cRunKey, PROGRAM, cRunName )
      ENDIF
   ELSE
      DELREGVAR( NIL, cRunKey, PROGRAM )
   ENDIF

   RETURN

STATIC FUNCTION GETREGVAR(nKey, cRegKey, cSubKey, uValue)

   LOCAL oReg, cValue

   nKey := IF(nKey == NIL, HKEY_CURRENT_USER, nKey)
   uValue := IF(uValue == NIL, "", uValue)
   oReg := TReg32():Create(nKey, cRegKey)
   cValue := oReg:Get(cSubKey, uValue)
   oReg:Close()

   RETURN cValue

STATIC FUNCTION SETREGVAR(nKey, cRegKey, cSubKey, uValue)

   LOCAL oReg, cValue

   nKey := IF(nKey == NIL, HKEY_CURRENT_USER, nKey)
   uValue := IF(uValue == NIL, "", uValue)
   oReg := TReg32():Create(nKey, cRegKey)
   cValue := oReg:Set(cSubKey, uValue)
   oReg:Close()

   RETURN cValue

STATIC FUNCTION DELREGVAR(nKey, cRegKey, cSubKey)

   LOCAL oReg, nValue

   nKey := IF(nKey == NIL, HKEY_CURRENT_USER, nKey)
   oReg := TReg32():New(nKey, cRegKey)
   nValue := oReg:Delete(cSubKey)
   oReg:Close()

   RETURN nValue

#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

HB_FUNC( ENABLEPERMISSIONS )

{
   LUID tmpLuid;
   TOKEN_PRIVILEGES tkp, tkpNewButIgnored;
   DWORD lBufferNeeded;
   HANDLE hdlTokenHandle;
   HANDLE hdlProcessHandle = GetCurrentProcess();

   OpenProcessToken(hdlProcessHandle, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, &hdlTokenHandle);

   LookupPrivilegeValue(NULL, "SeSystemEnvironmentPrivilege", &tmpLuid);

   tkp.PrivilegeCount            = 1;
   tkp.Privileges[0].Luid        = tmpLuid;
   tkp.Privileges[0].Attributes  = SE_PRIVILEGE_ENABLED;

   AdjustTokenPrivileges(hdlTokenHandle, FALSE, &tkp, sizeof(tkpNewButIgnored), &tkpNewButIgnored, &lBufferNeeded);
}

#pragma ENDDUMP
