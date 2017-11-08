/*
 * Ejemplo Label n° 2
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo desplegar un control LABEL
 * vertical o rotado.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

#define CRLF Chr(13) + Chr(10)

FUNCTION Main

   DEFINE WINDOW Form_1 OBJ oWin ;
      AT 0,0 ;
      WIDTH 640 HEIGHT 480 ;
      CLIENTAREA ;
      TITLE "Control Label en OOHG" ;
      MAIN

      @ 20, 20 LABEL lbl_1 ;
         VALUE "E" + CRLF + ;
               "s" + CRLF + ;
               "t" + CRLF + ;
               "e" + CRLF + ;
               " " + CRLF + ;
               "e" + CRLF + ;
               "s" + CRLF + ;
               " " + CRLF + ;
               "u" + CRLF + ;
               "n" + CRLF + ;
               " " + CRLF + ;
               "l" + CRLF + ;
               "a" + CRLF + ;
               "b" + CRLF + ;
               "e" + CRLF + ;
               "l" + CRLF + ;
               " " + CRLF + ;
               "v" + CRLF + ;
               "e" + CRLF + ;
               "r" + CRLF + ;
               "t" + CRLF + ;
               "i" + CRLF + ;
               "c" + CRLF + ;
               "a" + CRLF + ;
               "l"          ;
         WIDTH 24 ;
         HEIGHT 440

      @ 20, 100 LABEL lbl_2 OBJ oLbl2 ;
         VALUE " Este es un label rotado" ;
         WIDTH 170 ;
         HEIGHT 170 ;
         CENTERALIGN ;
         BORDER
      oLbl2:SetFont( NIL, NIL, NIL, NIL, NIL, NIL, -900, NIL )

      @ 20, 300 LABEL lbl_3 OBJ oLbl3 ;
         VALUE " Este es otro" ;
         WIDTH 150 ;
         HEIGHT 150 ;
         CENTERALIGN ;
         BORDER
      oLbl3:SetFont( NIL, NIL, NIL, NIL, NIL, NIL, -450, NIL )

      ON KEY ESCAPE ACTION Form_1.Release
   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN NIL

/*
 * EOF
 */
