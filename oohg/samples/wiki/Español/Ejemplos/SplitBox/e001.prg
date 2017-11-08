/*
 * Ejemplo SplitBox # 1
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo demuestra cómo mostrar/ocultar las bandas de
 * un SplitBox y cómo mostrar/ocultar sus grippers, de modo
 * que no se pueda modificar el tamaño de las bandas.
 * También muestra cómo averiguar si una banda es visible y
 * si tien un gripper.
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
      TITLE "OOHG - Control Splitbox" ;
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

         COMBOBOX cmb_Address ;
            FONT "Arial" SIZE 9 ;
            ITEMS {"http://www.oohg.org", ;
                   "http://oohg.wikia.com", ;
                   "http://sourceforge.net/projects/oohg/"} ;
            VALUE 1 ;
            ON ENTER Action() ;
            DISPLAYEDIT

         DEFINE TOOLBAR ToolBar_2 BUTTONSIZE 20,20 FLAT BOTTOM
            BUTTON btn_Go CAPTION "Ir" ACTION Action() AUTOSIZE
         END TOOLBAR
      END SPLITBOX


      /*
       * El número de una banda está dado por el orden en que fueron
       * creadas. En este ejemplo ToolBar_1 es la banda 1, cmb_Address
       * es la banda 2 y ToolBar_2 es la banda 3.
       */

      @ 90, 10 BUTTON btn_ShowB ;
         OBJ btn_ShowB ;
         CAPTION "Mostrar banda" ;
         ACTION {|| Split:ShowBand( 3 ), ;
                    btn_ShowB:Enabled := .F., ;
                    btn_HideB:Enabled := .T.} ;
         DISABLED

      @ 130, 10 BUTTON btn_HideB ;
         OBJ btn_HideB ;
         CAPTION "Ocultar banda" ;
         ACTION {|| Split:HideBand( 3 ), ;
                    btn_ShowB:Enabled := .T., ;
                    btn_HideB:Enabled := .F.} ;

      @ 170, 10 BUTTON btn_IsV ;
         OBJ btn_IsV ;
         CAPTION "Es visible" ;
         ACTION AUTOMSGBOX( Split:IsBandVisible( 3 ), "Información" )


      @ 90, 230 BUTTON btn_ShowG ;
         OBJ btn_ShowG ;
         CAPTION "Mostrar gripper" ;
         ACTION {|| Split:BandGripperON( 3 ), ;
                    btn_ShowG:Enabled := .F., ;
                    btn_HideG:Enabled := .T.} ;
         DISABLED

      @ 130, 230 BUTTON btn_HideG ;
         OBJ btn_HideG ;
         CAPTION "Ocultar gripper" ;
         ACTION {|| Split:BandGripperOFF( 3 ), ;
                    btn_ShowG:Enabled := .T., ;
                    btn_HideG:Enabled := .F.} ;

      @ 170, 230 BUTTON btn_IsG ;
         OBJ btn_IsG ;
         CAPTION "Tiene gripper" ;
         ACTION AUTOMSGBOX( Split:BandHasGripper( 3 ), "Información" )

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
