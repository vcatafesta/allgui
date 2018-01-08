* Programa..: cas_listbox.prg
* Versao....: v0.1: 26/05/2004 01:20am
* versao....: v0.2: 04/11/2005 02:15am
* email.....: cas_webnet@yahoo.com.br
* obs.......: LISTBOX - com a maioria das funçoes possiveis
* obs.......:           sem MULTISELECT

#include "MiniGUI.ch"

FUNCTION main()

   DEFINE WINDOW Form_1 AT 0,0 WIDTH 700 HEIGHT 450 ;
         TITLE "ListBox - cas_webnet@yahoo.com.br" ;
         MAIN ;
         NOMAXIMIZE NOSIZE ;
         ON INIT cas_change()

      on key INSERT action cas_add()
      on key DELETE action cas_del()
      _DefineHotKey( "form_1" , 0 , 13       , {|| cas_modify()     } )  && ENTER
      _DefineHotKey( "form_1" , 2 , asc('D') , {|| cas_delete_all() } )  && CTRL + D

      DEFINE STATUSBAR
         statusitem '' action nil
      END STATUSBAR

      @ 0,1 LISTBOX ListBox_1 WIDTH form_1.width-10 HEIGHT 170 ;
         ITEMS { '01 UM' , '02 DOIS' , '03 TRES' , '04 QUATRO' , '05 CINCO' } ;
         VALUE 2 ;
         ON CHANGE cas_change() ;
         ON DBLCLICK msginfo( ;
         'this.value = ' + str(this.value) +chr(13)+;
         'this.item( this.value ) = ' + this.item(this.value) )

      @ 200,10 button bt1 caption '<Insert>' action cas_add()
      @ 230,10 button bt2 caption '<Delete>' action cas_del()
      @ 260,10 button bt3 caption '<Ctrl D>  Del All' action cas_delete_all()
      @ 290,10 button bt4 caption '<Enter>'  action cas_modify()
   END WINDOW

   Form_1.Center ; Form_1.Activate

   RETURN NIL

   *.....................................................*

   proc cas_change
      LOCAL x1 := alltrim(str( form_1.listbox_1.value ))
      LOCAL x2 := alltrim(str( form_1.listbox_1.ItemCount ))
      LOCAL x3 := form_1.listbox_1.Item( val(x1) )
      Form_1.StatusBar.Item(1) := ;
         "form_1.listbox_1.value = "     + x1 +space(15)+;
         "form_1.listbox_1.ItemCount = " + x2 +space(15)+;
         "form_1.listbox_1.Item(" + x1 + ") = " + x3

      RETURN

      *.....................................................*

      proc cas_add
         LOCAL nn := form_1.ListBox_1.ItemCount + 1
         LOCAL xx := alltrim(str( nn ))

         form_1.ListBox_1.AddItem( 'ITEM_' + xx )
         form_1.ListBox_1.value := nn
         cas_change()

         RETURN

         *.....................................................*

         proc cas_del
            LOCAL n1
            LOCAL nn := form_1.ListBox_1.value

            form_1.ListBox_1.DeleteItem( nn )
            n1 := form_1.ListBox_1.ItemCount
            IF nn <= n1
               form_1.ListBox_1.value := nn
            ELSE
               form_1.ListBox_1.value := n1
            ENDIF
            cas_change()

            RETURN

            *.....................................................*

            proc cas_delete_all
               form_1.ListBox_1.DeleteAllItems
               //form_1.ListBox_1.value := 0
               cas_change()

               RETURN

               *.....................................................*

               proc cas_modify
                  LOCAL nn := form_1.ListBox_1.value

                  form_1.ListBox_1.item( nn ) := 'Nº ' + alltrim( str(nn) )
                  form_1.ListBox_1.value := nn
                  form_1.ListBox_1.setfocus
                  cas_change()

                  RETURN
