#include "MiniGUI.ch"

FUNCTION main()

   DEFINE WINDOW Form_1 AT 97,62 WIDTH 440 HEIGHT 449 ;
         TITLE "ListBox MultiSelect - by CAS - webcas@bol.com.br" ;
         MAIN ;
         NOMAXIMIZE NOSIZE

      @ 1,2 LISTBOX ListBox_1 WIDTH 429 HEIGHT 160 ;
         ITEMS { 'Line 1' , 'Line 2' , 'Line 3' , 'Line 4' , 'Line 5' } ;
         VALUE { 1 , 4 , 5} ;
         TOOLTIP 'ListBOX MultiSelect - Press <Ctrl + Click>' ;
         ON CHANGE cas_action() ;
         ON GOTFOCUS cas_action() ;
         MULTISELECT

      DEFINE STATUSBAR
         statusitem ''
      END STATUSBAR

      @ 200,10 button bt1 caption 'Add'        action cas_add()
      @ 230,10 button bt2 caption 'Del'        action cas_del()
      @ 260,10 button bt3 caption 'Del All'    action cas_delete_all()
      @ 290,10 button bt4 caption 'Modify'     action cas_modify()

      @ 200,170 button bt5 caption 'Select All' action cas_select_all()
      @ 230,170 button bt6 caption 'No Select'  action ( form_1.listbox_1.value := {}, cas_action() )
      @ 260,170 button bt7 caption 'Result'     action cas_result()
   END WINDOW
   Form_1.Center  ;  Form_1.Activate

   RETURN NIL

   *.....................................................*

   proc cas_action

      LOCAL x1 := alltrim(str(len( form_1.listbox_1.value )))
      LOCAL x2 := alltrim(str( form_1.listbox_1.ItemCount ))

      Form_1.StatusBar.Item(1) := "Select " + x1 + ' / ' + x2

      RETURN

      *.....................................................*

      proc cas_add

         LOCAL m_array := form_1.ListBox_1.value
         LOCAL nn := form_1.ListBox_1.ItemCount + 1

         form_1.ListBox_1.AddItem( 'Line_' + alltrim(str( nn )) )
         form_1.ListBox_1.setfocus

         RETURN

         *.....................................................*

         proc cas_del

            LOCAL m_array := form_1.ListBox_1.value

            repeat
            IF len( m_array ) = 0
               EXIT
            ENDIF
            form_1.ListBox_1.DeleteItem( m_array[ 1 ] )
            m_array := form_1.ListBox_1.value
            until len( m_array ) > 0
            IF form_1.listbox_1.ItemCount > 0
               form_1.ListBox_1.value := {1}
            ENDIF
            cas_action()

            RETURN

            *.....................................................*

            proc cas_delete_all

               form_1.ListBox_1.DeleteAllItems
               Form_1.StatusBar.Item(1) := "Select 0 / 0"

               RETURN

               *.....................................................*

               proc cas_modify

                  LOCAL nn, n_for
                  LOCAL m_array := form_1.ListBox_1.value

                  FOR n_for = 1 to len( m_array )
                     nn := m_array[ n_for ]
                     form_1.ListBox_1.item( nn ) := 'Nº ' + alltrim( str(nn) )
                  NEXT

                  RETURN

                  *.....................................................*

                  proc cas_select_all

                     LOCAL x2, n_for
                     LOCAL m_add := {}

                     FOR n_for = 1 to form_1.ListBox_1.ItemCount
                        aadd( m_add , n_for )
                     NEXT
                     form_1.listbox_1.value := m_add
                     x2 := alltrim(str( form_1.listbox_1.ItemCount ))
                     Form_1.StatusBar.Item(1) := "Select " + x2 + ' / ' + x2

                     RETURN

                     *.....................................................*

                     proc cas_result

                        LOCAL nn, n_for
                        LOCAL m_array := form_1.ListBox_1.value
                        LOCAL xx_var := ''

                        FOR n_for = 1 to len( m_array )
                           nn := m_array[ n_for ]
                           xx_var += alltrim(str( nn )) +space(10)+;
                              form_1.ListBox_1.item( nn ) + chr(13)
                        NEXT
                        msginfo( xx_var , 'Items: ' + alltrim( str(form_1.listbox_1.ItemCount) ) )

                        RETURN
