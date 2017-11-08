/*
 * Ejemplo SplitBox n° 2
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo demuestra cómo definir un SplitBox con dos
 * ToolBars en la misma fila.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include 'oohg.ch'

Function Main()

   DEFINE WINDOW MainForm ;
      OBJ MainForm ;
      AT 0, 0 ;
      WIDTH 600 ;
      HEIGHT 240 ;
      TITLE "OOHG - Splitbox con 2 ToolBars en la misma fila" ;
      MAIN

      DEFINE SPLITBOX OBJ Split
         DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 20,20 FLAT BOTTOM
            BUTTON btn_NewPage CAPTION "Nueva página"    ACTION Action() AUTOSIZE
            BUTTON btn_Back    CAPTION "Atras"           ACTION Action() AUTOSIZE
            BUTTON btn_Forward CAPTION "Adelante"        ACTION Action() AUTOSIZE
            BUTTON btn_Reload  CAPTION "Volver a cargar" ACTION Action() AUTOSIZE
            BUTTON btn_Stop    CAPTION "Detener"         ACTION Action() AUTOSIZE
            BUTTON btn_Home    CAPTION "Inicio"          ACTION Action() AUTOSIZE
            BUTTON btn_About   CAPTION "Acerca de"       ACTION Action() AUTOSIZE
         END TOOLBAR

         /*
          * Si se omite la cláusula NOBREAK, las toolbars se
          * muestran en diferentes filas.
          */

         DEFINE TOOLBAR ToolBar_2 BUTTONSIZE 20,20 FLAT BOTTOM
            BUTTON btn_Go CAPTION "Ir" ACTION Action() AUTOSIZE
         END TOOLBAR
      END SPLITBOX

      ON KEY ESCAPE ACTION MainForm:Release()

   END WINDOW

   CENTER WINDOW MainForm
   ACTIVATE WINDOW MainForm

RETURN NIL

FUNCTION Action()

  MSGINFO( 'Acción', 'Información' )

RETURN NIL

/*
 * EOF
 */
