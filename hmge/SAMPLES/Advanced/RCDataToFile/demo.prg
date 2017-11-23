/*
* Author: P.Chornyj <myorg63@mail.ru>
*/

ANNOUNCE RDDSYS

#ifdef __XHARBOUR__
#include "hbcompat.ch"
#endif

#define IDR_HELLO 1001

PROCEDURE main()

   LOCAL cDiskFile := hb_dirTemp() + "\" + "he$$o.tmp"
   LOCAL nResult, hProcess, nRet

   DELETE file cDiskFile

   nResult := RCDataToFile( IDR_HELLO, cDiskFile )

   IF nResult > 0
      hProcess := hb_processOpen( cDiskFile )
      nRet := hb_processValue( hProcess, .T. )

      MsgInfo( "Exit Code: " + hb_NtoS( nRet ), "he$$o.tmp" )
   ELSE
      MsgInfo( "Code: " + hb_NtoS( nResult ), "Error" )
   ENDIF

   RETURN
