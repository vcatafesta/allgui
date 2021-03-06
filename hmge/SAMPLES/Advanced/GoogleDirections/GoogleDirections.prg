/*
Roberto M Manini
Copyright 2008 Roberto M Manini <manini@terra.com.br>
Google Trace/Route
Re-Adapta��o do GoogleMaps by Walter Formigoni, December of 2007
Google Map, Adapted from sample of <Rafael Clemente> (Barcelona, Spain) and  <shrkod> from Fivewin to Minigui
---------------------------------------------
Marcelo Torres, Noviembre de 2006.
TActivex para [x]Harbour Minigui.
Adaptacion del trabajo de:
---------------------------------------------
Lira Lira Oscar Joel [oSkAr]
Clase TAxtiveX_FreeWin para Fivewin
Noviembre 8 del 2006
email: oscarlira78@hotmail.com
http://freewin.sytes.net
CopyRight 2006 Todos los Derechos Reservados

---------------------------------------------
*/

SET PROCEDURE TO "TAxPrg.prg"

#include "minigui.ch"

DECLARE WINDOW GoogleDirections

#define OLECMDID_PRINT 6
#define OLECMDID_PRINTPREVIEW 7
#define OLECMDEXECOPT_DODEFAULT 0

STATIC  oActiveX
STATIC  oWActiveX

MEMVAR lPreview

PROCEDURE Main()

   PUBLIC lPreview:=.f.

   LOAD WINDOW GoogleDirections

   GoogleDirections.Center()
   GoogleDirections.Activate()

   RETURN

STATIC PROCEDURE fOpenActivex()

   LOCAL cfromAddress := PadR( "CURITIBA,PR", 80 )
   LOCAL ctoAddress := PadR( "MATINHOS,PR", 80 )

   GoogleDirections.TEXT_1.VALUE  := cfromAddress
   GoogleDirections.TEXT_2.VALUE  := ctoAddress

   oWActiveX := TActiveX():New( "GoogleDirections", "Shell.Explorer.2" , 0 , 0 , ;
      GetProperty( "GoogleDirections" , "width" ) - 8 , GetProperty( "GoogleDirections" , "height" ) - 150 )

   oActiveX := oWActiveX:Load()

   SHOW( cfromAddress, ctoAddress )

   RETURN

PROCEDURE SEARCH()

   LOCAL cfromAddress := GoogleDirections.TEXT_1.VALUE
   LOCAL ctoAddress := GoogleDirections.TEXT_2.VALUE

   SHOW( cfromAddress, ctoAddress )

   RETURN

FUNCTION Show( cfromAddress, ctoAddress)

   LOCAL cHtml := MemoRead( "GoogleDirections.html" )

   cHtml = StrTran( cHtml, "<<cfromAddress>>", AllTrim( cfromAddress ) )
   cHtml = StrTran( cHtml, "<<ctoAddress>>", AllTrim( ctoAddress ) )

   MemoWrit( "rtemp.html", cHtml )

   oActiveX:Navigate(CurDrive() + ":\" + CurDir() + "\rtemp.html" )

   RETURN NIL

STATIC FUNCTION fCloseActivex()

   IF VALTYPE(oWActivex) <> "U" .AND. VALTYPE(oActivex) <> "U"
      oWActiveX:Release()
   ENDIF

   RETURN NIL

STATIC PROCEDURE fPrint(lPreview)

   IF Valtype(oWActiveX) <> "U"
      IF lPreview
         oActiveX:ExecWB( OLECMDID_PRINTPREVIEW, OLECMDEXECOPT_DODEFAULT )
      ELSE
         oActiveX:ExecWB( OLECMDID_PRINT, OLECMDEXECOPT_DODEFAULT )
      ENDIF
   ENDIF

   RETURN
