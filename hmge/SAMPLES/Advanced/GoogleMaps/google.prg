/*
Walter Formigoni, December of 2007
Copyright 2007 Walter Formigoni <walter.formigoni@uol.com.br>
Google Map, Adapted from sample of <Rafael Clemente> (Barcelona, Spain) and <shrkod> from Fivewin to Minigui
Added function fprint(), October of 2008. Contribution by Adilson Urso <a.urso@uol.com.br>
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

#define OLECMDID_PRINT 6
#define OLECMDID_PRINTPREVIEW 7
#define OLECMDEXECOPT_DODEFAULT 0

STATIC  oActiveX
STATIC  oWActiveX

PROCEDURE Main()

   LOAD WINDOW GOOGLE

   GOOGLE.Center()
   GOOGLE.Activate()

   RETURN

STATIC PROCEDURE fOpenActivex()

   LOCAL cStreet := PadR( "BROADWAY 500", 80 )
   LOCAL cCity := PadR( "NEW YORK", 80 )
   LOCAL cCountry := PadR( "USA", 80 )

   GOOGLE.TEXT_1.VALUE  :=  cStreet
   GOOGLE.TEXT_2.VALUE  := cCity
   GOOGLE.TEXT_3.VALUE  := cCountry

   oWActiveX := TActiveX():New( "GOOGLE", "Shell.Explorer.2" , 0 , 0 ,;
      GetProperty( "GOOGLE" , "width" ) - 8 , GetProperty( "GOOGLE" , "height" ) - 150 )
   oActiveX := oWActiveX:Load()

   SHOW( cStreet, cCity, cCountry )

   RETURN

PROCEDURE SEARCH()

   LOCAL cStreet := GOOGLE.TEXT_1.VALUE
   LOCAL cCity := GOOGLE.TEXT_2.VALUE
   LOCAL cCountry := GOOGLE.TEXT_3.VALUE

   SHOW(cStreet, cCity, cCountry )

   RETURN

FUNCTION Show( cStreet, cCity, cCountry )

   LOCAL cHtml := MemoRead( "gmap.html" )

   cHtml = StrTran( cHtml, "<<STREET>>", AllTrim( cStreet ) )
   cHtml = StrTran( cHtml, "<<CITY>>", AllTrim( cCity ) )
   cHtml = StrTran( cHtml, "<<COUNTRY>>", AllTrim( cCountry ) )

   MemoWrit( "temp.html", cHtml )

   oActiveX:Navigate( CurDrive() + ":\" + CurDir() + "\temp.html" )

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
