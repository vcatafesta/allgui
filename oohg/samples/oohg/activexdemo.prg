/*
* $Id: activexdemo.prg $
*/
/*
Marcelo Torres, Noviembre de 2006.
TActivex para [x]Harbour Minigui.
Adaptacion del trabajo de:
---------------------------------------------
Lira Lira Oscar Joel [oSkAr]
Clase TAxtiveX_FreeWin para Fivewin
Noviembre 8 del 2006
email: oscarlira78@hotmail.com
http://freewin.sytes.net
@CopyRight 2006 Todos los Derechos Reservados
---------------------------------------------
*/

#include "oohg.ch"
#include "hbclass.ch"

STATIC oActiveX, bVerde, WinDemo

FUNCTION Main()

   DEFINE WINDOW WinDemo obj Windemo ;
         AT 118,73 ;
         WIDTH 808 ;
         HEIGHT 534 ;
         TITLE 'ActiveX Support QAC Sample for OOHG' ;
         MAIN ;
         ON SIZE Ajust() ;
         ON MAXIMIZE Ajust() ;
         BACKCOLOR {236 , 233 , 216 } ;
         FONT 'Verdana' ;
         SIZE 10 ;

      @ Windemo:height - 60 , 10 LABEL LSemaforo ;
         VALUE " " ;
         WIDTH 27 ;
         HEIGHT 27 ;
         FONTCOLOR {255,0,0} ;
         BACKCOLOR {255,0,0}

      @ windemo:height - 57 , 43 TEXTBOX URL_ToNavigate  ;
         HEIGHT 23 ;
         WIDTH windemo:width - 165 ;
         FONT 'Verdana' ;
         ON ENTER Navegar() ;

      @ windemo:height - 60 , windemo:width - 115 BUTTON BNavigate ;
         CAPTION 'Navigate' ;
         ACTION Navegar() ;
         WIDTH 100 ;
         HEIGHT 28 ;
         FONT 'Verdana' ;

      @  0, 0 ACTIVEX ActiveX WIDTH WinDemo:width - 7 HEIGHT WinDemo:height - 72 PROGID "Shell.Explorer.2" OBJ oActiveX

      bVerde := .F.
      oActiveX:Navigate( "www.google.com" )

      DEFINE TIMER TSemaforo ;
         INTERVAL    1000 ;
         ACTION SwitchSemaforo() ;

   END WINDOW

   CENTER WINDOW WinDemo

   ACTIVATE WINDOW WinDemo

   RETURN NIL

PROCEDURE SwitchSemaforo()

   IF oActiveX:Busy()
      IF bVerde
         bVerde := .F.
         WinDemo:LSemaforo:BackColor := {255,0,0}
      ENDIF
   ELSE
      IF !bVerde
         bVerde := .T.
         WinDemo:LSemaforo:BackColor := {0,255,0}
         windemo:URL_tonavigate:value := oActiveX:LocationURL()
      ENDIF
   ENDIF

   RETURN

PROCEDURE Navegar()

   oActivex:Navigate(windemo:URL_tonavigate:value)

   RETURN

PROCEDURE Ajust()

   windemo:lsemaforo:row := WinDemo:height - 60
   windemo:URL_tonavigate:row := WinDemo:height - 57
   windemo:URL_tonavigate:width :=  WinDemo:width- 165
   windemo:Bnavigate:row := WinDemo:height- 60
   windemo:bnavigate:col := WinDemo:width- 115
   oActiveX:width := WinDemo:width - 7
   oActiveX:height := WinDemo:height - 72

   RETURN
