/*
 * Ejemplo Listbox n° 3
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo definir un listbox con múltiples
 * tabulaciones y otro con múltiples tabulaciones y columnas.
 *
 * Basado en un ejemplo de HMG Extended aportado por Janusz Pora.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "minigui.ch"

Function main()
   LOCAL aItem := {{'AG','001','ARGENTINA       '},;
                   {'AK','002','ALASKA          '},;
                   {'AL','003','ALABAMA         '},;
                   {'AR','004','ARKANSAS        '},;
                   {'AZ','005','ARIZONA         '},;
                   {'BE','006','BELGICA         '},;
                   {'BR','007','BRASIL          '},;
                   {'CA','008','CALIFORNIA      '},;
                   {'CH','009','CHILE           '},;
                   {'CL','010','COLOMBIA        '},;
                   {'CN','011','CANADA          '},;
                   {'CO','012','COLORADO        '},;
                   {'CR','013','COSTA RICA      '},;
                   {'CT','014','CONNECTICUT     '},;
                   {'DE','015','DELAWARE        '},;
                   {'DF','016','DISTRITO FEDERAL'},;
                   {'EC','017','ECUADOR         '},;
                   {'ES','018','ESPAÑA          '},;
                   {'FL','019','FLORIDA         '},;
                   {'GA','020','GEORGIA         '},;
                   {'GR','021','GRECIA          '},;
                   {'ID','022','IDAHO           '},;
                   {'IL','023','ILLINOIS        '},;
                   {'IN','024','INDIANA         '},;
                   {'IR','025','IRELAND         '},;
                   {'KA','026','KANSAS          '},;
                   {'KY','027','KENTUCKY        '},;
                   {'LA','028','LOUSIANA        '},;
                   {'MA','029','MASSACHUSETTS   '},;
                   {'MI','030','MISSOURI        '},;
                   {'MN','031','MINNESOTA       '},;
                   {'MO','032','MONTANA         '},;
                   {'MS','033','MISSISSIPPI     '},;
                   {'MX','034','MEXICO          '},;
                   {'NC','035','NORTH CAROLINA  '},;
                   {'ND','036','NORTH DAKOTA    '},;
                   {'NE','037','NEW ENGLAND     '},;
                   {'NH','038','NEW HAMPSHIRE   '},;
                   {'NJ','039','NEW JERSEY      '},;
                   {'NM','040','NEW MEXICO      '},;
                   {'NV','041','NEVADA          '},;
                   {'NY','042','NEW YORK        '},;
                   {'OH','043','OHIO            '},;
                   {'OK','044','OKLAHOMA        '},;
                   {'OR','045','OREGON          '},;
                   {'PA','046','PENNSYLVANIA    '},;
                   {'PE','047','PERU            '},;
                   {'SC','048','SOUTH CAROLINA  '},;
                   {'SD','049','SOUTH DAKOTA    '},;
                   {'TE','050','TENNESSEE       '},;
                   {'TX','051','TEXAS           '},;
                   {'UT','052','UTAH            '},;
                   {'UY','053','URUGUAY         '},;
                   {'VA','054','VIRGINIA        '},;
                   {'VE','055','VENEZUELA       '},;
                   {'VT','056','VERMONT         '},;
                   {'WA','057','WASHINGTON      '},;
                   {'WI','058','WISCONSIN       '},;
                   {'WV','059','WEST VIRGINIA   '},;
                   {'WY','060','WYOMING         '},;
                   {'HI','061','HAWAII          '}}

   SetOneArrayItemPerLine( .T. )

   DEFINE WINDOW Form_1 ;
      AT 100, 60 ;
      WIDTH 750 ;
      HEIGHT 500 ;
      TITLE "ListBox MultiTab y ListBox MultiColumn + MultiTab" ;
      MAIN ;
      NOMAXIMIZE ;
      NOSIZE

      @ 010, 010 LABEL lbl_1 ;
         VALUE 'Estilo MULTITAB' ;
         AUTOSIZE ;
         BOLD

      @ 030, 010 LISTBOX lst_1 ;
         WIDTH 700 ;
         HEIGHT 160 ;
         ITEMS aItem ;
         VALUE 2 ;
         MULTITAB TABSWIDTH {100,300}     // la primera columna comienza en 0

      @ 200, 010 BUTTON btn_11 CAPTION 'Agregar'   ACTION Item_Agregar_1()
      @ 200, 120 BUTTON btn_12 CAPTION 'Borrar'    ACTION Item_Borrar_1()
      @ 200, 230 BUTTON btn_13 CAPTION 'Modificar' ACTION Item_Modificar_1()
      @ 200, 340 BUTTON btn_14 CAPTION 'Ver'       ACTION Item_Ver_1()

      @ 240, 010 LABEL lbl_2 ;
         VALUE 'Estilo MULTITAB y MULTICOLUMN ' ;
         AUTOSIZE ;
         BOLD

      @ 260, 010 LISTBOX lst_2 ;
         WIDTH 700 ;
         HEIGHT 160 ;
         ITEMS aItem ;
         VALUE 3 ;
         MULTICOLUMN COLUMNWIDTH 348 ;
         MULTITAB TABSWIDTH {50,200}      // pixels

      @ 430, 010 BUTTON btn_21 CAPTION 'Agregar'   ACTION Item_Agregar_2()
      @ 430, 120 BUTTON btn_22 CAPTION 'Borrar'    ACTION Item_Borrar_2()
      @ 430, 230 BUTTON btn_23 CAPTION 'Modificar' ACTION Item_Modificar_2()
      @ 430, 340 BUTTON btn_24 CAPTION 'Ver'       ACTION Item_Ver_2()

      ON KEY ESCAPE ACTION ThisWindow.Release()
   END WINDOW

   Form_1.Center
   Form_1.Activate
RETURN Nil


PROCEDURE Item_Agregar_1
   LOCAL nn := Form_1.lst_1.ItemCount + 1
   Form_1.lst_1.AddItem( {'XX', STRZERO( nn, 3, 0 ), 'Col3'} )
   Form_1.lst_1.Value := nn
   Form_1.lst_1.SetFocus
RETURN


PROCEDURE Item_Borrar_1
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


PROCEDURE Item_Modificar_1
   LOCAL nn := Form_1.lst_1.Value
   Form_1.lst_1.Item( nn ) := {'YY', STRZERO( nn, 3, 0 ), 'Col3'}
   // También se puede asignar LB_Array2String( {'YY', STRZERO( nn, 3, 0 ), 'Col3'} )
   Form_1.lst_1.Value := nn
   Form_1.lst_1.SetFocus
RETURN


PROCEDURE Item_Ver_1
   LOCAL uValue := Form_1.lst_1.Item( Form_1.lst_1.Value )
   AutoMsgBox( {"ValType: " + VALTYPE( uValue ), "", "Items:", uValue } )
   Form_1.lst_1.SetFocus
RETURN


PROCEDURE Item_Agregar_2
   LOCAL nn := Form_1.lst_2.ItemCount + 1
   Form_1.lst_2.AddItem( {'AA', STRZERO( nn, 3, 0 ), 'Info in Col 3'} )
   Form_1.lst_2.Value := nn
   Form_1.lst_2.SetFocus
RETURN


PROCEDURE Item_Borrar_2
   LOCAL n1
   LOCAL nn := Form_1.lst_2.Value
   Form_1.lst_2.DeleteItem( nn )
   n1 := Form_1.lst_2.ItemCount
   IF nn <= n1
      Form_1.lst_2.Value := nn
   ELSE
      Form_1.lst_2.Value := n1
   ENDIF
   Form_1.lst_2.SetFocus
RETURN


PROCEDURE Item_Modificar_2
   LOCAL nn := Form_1.lst_2.Value
   Form_1.lst_2.Item( nn ) := {'MM', STRZERO( nn, 3, 0 ), 'Data in Col 3'}
   // También se puede asignar LB_Array2String( {'MM', STRZERO( nn, 3, 0 ), 'Data in Col 3'} )
   Form_1.lst_2.Value := nn
   Form_1.lst_2.SetFocus
RETURN


PROCEDURE Item_Ver_2
   LOCAL uValue := Form_1.lst_2.Item( Form_1.lst_2.Value )
   AutoMsgBox( {"ValType: " + VALTYPE( uValue ), "", "Items:", uValue } )
   Form_1.lst_2.SetFocus
RETURN


/*
 * EOF
 */
