#include "MiniGUI.ch"

FUNCTION main()

   DEFINE WINDOW Form_1 AT 97,62 WIDTH 402 HEIGHT 449 ;
         TITLE "ListBox - By CAS - webcas@bol.com.br" ;
         MAIN ;
         NOMAXIMIZE NOSIZE

      @ 0,1 LISTBOX ListBox_1 WIDTH 392 HEIGHT 160 ;
         ITEMS { '01 UM' , '02 DOIS' , '03 TRES' } ;
         value 2

      @ 200,10 button bt1 caption 'Add'     action cas_add()
      @ 230,10 button bt2 caption 'Del'     action cas_del()
      @ 260,10 button bt3 caption 'Del All' action cas_delete_all()
      @ 290,10 button bt4 caption 'Modify'  action cas_modify()
   END WINDOW
   Form_1.Center ; Form_1.Activate

   RETURN NIL

   *.....................................................*

   proc cas_add

      LOCAL nn := form_1.ListBox_1.ItemCount + 1

      form_1.ListBox_1.AddItem( 'ITEM_' + alltrim(str( nn )) )
      form_1.ListBox_1.value := nn

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

         RETURN

         *.....................................................*

         proc cas_delete_all

            form_1.ListBox_1.DeleteAllItems
            form_1.ListBox_1.value := 1

            RETURN

            *.....................................................*

            proc cas_modify

               LOCAL nn := form_1.ListBox_1.value

               form_1.ListBox_1.item( nn ) := 'Nº ' + alltrim( str(nn) )
               form_1.ListBox_1.Setfocus

               RETURN

