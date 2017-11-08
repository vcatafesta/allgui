/*
 * Ejemplo Menu n° 1
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo utilizar la cláusula
 * BREAKMENU [SEPARATOR] para cambiar la forma en
 * que un menú es mostrado.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main()

   DEFINE WINDOW Form_1 ;
      OBJ oForm_1 ;
      AT 0,0 ;
      WIDTH 400 ;
      HEIGHT 200 ;
      TITLE 'OOHG - Menú con la cláusula BREAKMENU' ;
      MAIN

      DEFINE STATUSBAR
        KEYBOARD
        DATE
      END STATUSBAR

      DEFINE MAIN MENU

         POPUP 'PopUp1'
            ITEM 'Item 1 del PopUp1' ;
               ACTION MsgInfo( 'Item 1 del PopUp1' )
            ITEM 'Item 2 del PopUp1' ;
               ACTION MsgInfo( 'Item 2 del PopUp1' )
            ITEM 'Item 3 del PopUp1' ;
               ACTION MsgInfo( 'Item 3 del PopUp1' ) ;
               BREAKMENU
            ITEM 'Item 4 del PopUp1' ;
               ACTION MsgInfo( 'Item 4 del PopUp1' )
            ITEM 'Item 5 del PopUp1' ;
               ACTION MsgInfo( 'Item 5 del PopUp1' )
            SEPARATOR
            ITEM 'Salir' ;
               ACTION oForm_1:Release()
         END POPUP

         POPUP 'PopUp2'
            ITEM 'Item 1 del PopUp2' ;
               ACTION MsgInfo( 'Item 1 del PopUp2' )
            ITEM 'Item 2 del PopUp2' ;
               ACTION MsgInfo( 'Item 2 del PopUp2' )

            POPUP 'Item 3 del PopUp2'
               ITEM 'Item 3.1 del PopUp2' ;
                  ACTION MsgInfo( 'Item 3.1 del PopUp2' )
               ITEM 'Item 3.2 del PopUp2' ;
                  ACTION MsgInfo( 'Item 3.2 del PopUp2' )

               POPUP 'Item 3.3 del PopUp2'
                  ITEM 'Item 3.3.1 del PopUp2' ;
                     ACTION MsgInfo( 'Item 3.3.1 del PopUp2' )
                  ITEM 'Item 3.3.2 del PopUp2' ;
                     ACTION MsgInfo( 'Item 3.3.2 del PopUp2' )

                  POPUP 'Item 3.3.3 del PopUp2'
                     ITEM 'Item 3.3.3.1 del PopUp2' ;
                        ACTION MsgInfo( 'Item 3.3.3.1 del PopUp2' )
                     ITEM 'Item 3.3.3.2 del PopUp2' ;
                        ACTION MsgInfo( 'Item 3.3.3.2 del PopUp2' )
                     ITEM 'Item 3.3.3.3 del PopUp2' ;
                        ACTION MsgInfo( 'Item 3.3.3.3 del PopUp2' )
                     ITEM 'Item 3.3.3.4 del PopUp2' ;
                        ACTION MsgInfo( 'Item 3.3.3.4 del PopUp2' ) ;
                        BREAKMENU SEPARATOR
                     ITEM 'Item 3.3.3.5 del PopUp2' ;
                        ACTION MsgInfo( 'Item 3.3.3.5 del PopUp2' )
                     ITEM 'Item 3.3.3.6 del PopUp2' ;
                        ACTION MsgInfo( 'Item 3.3.3.6 del PopUp2' )
                  END POPUP

                  ITEM 'Item 3.3.4 del PopUp2' ;
                     ACTION MsgInfo( 'Item 3.3.4 del PopUp2' )
               END POPUP
            END POPUP

            ITEM 'Item 4 del PopUp2' ;
               ACTION MsgInfo( 'Item 4 del PopUp2' )
         END POPUP

         POPUP 'PopUp3' BREAKMENU
            ITEM 'Item 1 del PopUp3' ;
               ACTION MsgInfo( 'Item 1 del PopUp3' )
         END POPUP

      END MENU

      ON KEY ESCAPE ACTION oForm_1:Release()

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

RETURN Nil

/*
 * EOF
 */
