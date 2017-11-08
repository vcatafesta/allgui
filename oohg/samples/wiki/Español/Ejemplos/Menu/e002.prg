/*
 * Ejemplo Menu n° 2
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo crear un menú dinámico
 * utilizando los métodos InsertPopup, InsertItem e
 * InsertSeparator.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main()

   DEFINE WINDOW Form OBJ oForm ;
      AT 0,0 ;
      WIDTH 400 ;
      HEIGHT 200 ;
      TITLE 'Crear y Borrar Items de un Menú' ;
      MAIN

      DEFINE MAIN MENU OBJ mnu_Principal
         POPUP 'Acciones'  OBJ mnu_Acciones
            ITEM 'Acción 1' ACTION MsgInfo( 'Acción 1' ) NAME mnu_Accion1
            SEPARATOR
            ITEM 'Acción 2' ACTION MsgInfo( 'Acción 2' ) NAME mnu_Accion2
            ITEM 'Acción 3' ACTION MsgInfo( 'Acción 3' ) NAME mnu_Accion3
         END POPUP

         POPUP 'Probar'
            ITEM 'Borrar Acción 2' ;
               ACTION ( oForm:mnu_Accion2:Release(), ;
                        MsgInfo( 'Menu "Acción 2" ha sido borrado !!!' ), ;
                        oForm:mnu_Crear:Enabled( .T. ), ;
                        oForm:mnu_Borrar:Enabled( .F. ) ) ;
               NAME mnu_Borrar
            ITEM 'Crear Acción 2' ;
               ACTION ( TMenuItem():InsertItem( "Acción 2" , ;
                                                { || MsgInfo("Acción 2") }, ;
                                                "mnu_Accion2", ;
                                                NIL, ;
                                                .F., ;
                                                .F., ;
                                                mnu_Acciones, ;
                                                .F., ;
                                                .F., ;
                                                .F., ;
                                                NIL, ;
                                                2 ), ;
                        MsgInfo( 'Menu "Acción 2" ha sido creado !!!'), ;
                        oForm:mnu_Crear:Enabled( .F. ) , ;
                        oForm:mnu_Borrar:Enabled( .T. ) ) ;
               NAME mnu_Crear ;
               DISABLED
         END POPUP
      END MENU

      INSERT ITEM 'Acción 4' ;
         AT -1 ACTION MsgInfo( 'Acción 4' ) FROM mnu_Acciones

      INSERT SEPARATOR AT 3 FROM mnu_Acciones

      INSERT POPUP 'Acerca de' OBJ mnu_Acerca FROM mnu_Principal
      END POPUP

      INSERT ITEM 'El poder de OOHG !!!' ;
         AT -1 ACTION MsgInfo( 'Disfrutalo !!!' ) FROM mnu_Acerca

      ON KEY ESCAPE ACTION Form.Release
   END WINDOW

   CENTER WINDOW Form
   ACTIVATE WINDOW Form

RETURN NIL

/*
 * EOF
 */
