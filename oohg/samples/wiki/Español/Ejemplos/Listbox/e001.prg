/*
 * Ejemplo Listbox n° 1
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo definir un listbox multi-columna.
 *
 * Basado en un ejemplo de HMG Extended aportado por Janusz Pora.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main
   LOCAL aItem

   aItem := {'ARGENTINA', ;
             'ALASKA', ;
             'ALABAMA', ;
             'ARKANSAS', ;
             'ARIZONA', ;
             'BELGICA', ;
             'BRASIL', ;
             'CALIFORNIA', ;
             'CHILE', ;
             'COLOMBIA', ;
             'CANADA', ;
             'COLORADO', ;
             'COSTA RICA', ;
             'CONNECTICUT', ;
             'DELAWARE', ;
             'DISTRITO FEDERAL', ;
             'ECUADOR', ;
             'ESPAÑA', ;
             'FLORIDA', ;
             'GEORGIA', ;
             'GRECIA', ;
             'IDAHO', ;
             'ILLINOIS', ;
             'INDIANA', ;
             'IRELAND', ;
             'KANSAS', ;
             'KENTUCKY', ;
             'LOUSIANA', ;
             'MASSACHUSETTS', ;
             'MISSOURI', ;
             'MINNESOTA', ;
             'MONTANA', ;
             'MISSISSIPPI', ;
             'MEXICO', ;
             'NORTH CAROLINA', ;
             'NORTH DAKOTA', ;
             'NEW ENGLAND', ;
             'NEW HAMPSHIRE', ;
             'NEW JERSEY', ;
             'NEW MEXICO', ;
             'NEVADA', ;
             'NEW YORK', ;
             'OHIO', ;
             'OKLAHOMA', ;
             'OREGON', ;
             'PENNSYLVANIA', ;
             'PERU', ;
             'SOUTH CAROLINA', ;
             'SOUTH DAKOTA', ;
             'TENNESSEE', ;
             'TEXAS', ;
             'UTAH', ;
             'URUGUAY', ;
             'VIRGINIA', ;
             'VENEZUELA', ;
             'VERMONT', ;
             'WASHINGTON', ;
             'WISCONSIN', ;
             'WEST VIRGINIA', ;
             'WYOMING', ;
             'HAWAII'}

   DEFINE WINDOW Form_1 AT 100,60 WIDTH 450 HEIGHT 450 ;
      TITLE "ListBox Multi-Columna" ;
      MAIN ;
      NOMAXIMIZE ;
      NOSIZE

      @ 10,10 LABEL lbl_1 VALUE 'Estilo MULTICOLUMN ' ;
         AUTOSIZE ;
         BOLD

      @ 30,10 LISTBOX lst_1 ;
         WIDTH 300 ;
         HEIGHT 160 ;
         ITEMS aItem ;
         VALUE 2 ;
         MULTICOLUMN COLUMNWIDTH 130

      @ 220,10 BUTTON btn1 CAPTION 'Agregar'   ACTION Item_agregar()
      @ 250,10 BUTTON btn2 CAPTION 'Borrar'    ACTION Item_borrar()
      @ 280,10 BUTTON btn3 CAPTION 'Modificar' ACTION Item_modificar()
      @ 310,10 BUTTON btn4 CAPTION 'Ver'       ACTION Item_ver()
      @ 340,10 BUTTON btn5 CAPTION 'Cerrar'    ACTION Form_1.Release()

      ON KEY ESCAPE ACTION Form_1.Release()
   END WINDOW

   Form_1.Center
   Form_1.Activate
RETURN Nil


PROCEDURE Item_agregar
   LOCAL nn := Form_1.lst_1.ItemCount + 1

   Form_1.lst_1.AddItem( 'Item_' + ALLTRIM( STR( nn ) ) )
   Form_1.lst_1.Value := nn
   Form_1.lst_1.SetFocus
RETURN


PROCEDURE Item_borrar
   LOCAL n1
   LOCAL nn := Form_1.lst_1.Value

   Form_1.lst_1.DeleteItem( nn )
   n1 := Form_1.lst_1.ItemCount
   IF nn <= n1
      Form_1.lst_1.Value := nn
   ELSE
      Form_1.lst_1.Value := n1
   ENDIF
   Form_1.lst_1.SetFocus
RETURN


PROCEDURE Item_modificar
   LOCAL nn := Form_1.lst_1.Value

   Form_1.lst_1.Item( nn ) := 'Nuevo_' + ALLTRIM( STR( nn ) )
   Form_1.lst_1.Value := nn
   Form_1.lst_1.SetFocus
RETURN


PROCEDURE Item_ver
   MsgInfo( Form_1.lst_1.Item( Form_1.lst_1.Value ) )
   Form_1.lst_1.SetFocus
RETURN

/*
 * EOF
 */
