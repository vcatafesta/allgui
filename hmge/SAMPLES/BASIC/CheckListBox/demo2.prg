#include "MiniGUI.ch"

#xcommand ON KEY SPACE [ OF <parent> ] ACTION <action> ;
   => ;
   _DefineHotKey ( <"parent"> , 0 , VK_SPACE , <{action}> )

FUNCTION Main()

   LOCAL aItems_1 := {}, i
   LOCAL aItems_2 := {"Item 1","Item 2","Item 3","Item 4","Item 5"}

   FOR i:=1 TO 5
      AAdd( aItems_1, {"Item "+hb_ntos(i), (i==1)} )
   NEXT

   DEFINE WINDOW Form_1 AT 97,62 WIDTH 402 HEIGHT 449 ;
         TITLE "Checked ListBox - By Janusz Pora" ;
         MAIN ;
         NOMAXIMIZE NOSIZE

      DEFINE CHECKLISTBOX ListBox_1
      ROW 10
      COL 10
      WIDTH 150
      HEIGHT 160
      ITEMS aItems_1
      VALUE 2
      CHECKBOXITEM {3,5}
      ON DBLCLICK clb_Check()
      ITEMHEIGHT 19
      FONTNAME 'Arial'
      FONTSIZE 9
   END CHECKLISTBOX

   @ 10,200 CHECKLISTBOX ListBox_2 ;
      WIDTH 150 HEIGHT 160 ;
      ITEMS aItems_2 ;
      VALUE {2} ;
      CHECKBOXITEM {4,5} ;
      ON DBLCLICK cmlb_Check() ;
      MULTISELECT ;
      ITEMHEIGHT 19 ;
      FONT 'Arial' SIZE 9

   @ 200,10 button bt1 caption 'Add'     action clb_add()
   @ 230,10 button bt2 caption 'Del'     action clb_del()
   @ 260,10 button bt3 caption 'Del All' action clb_delete_all()
   @ 290,10 button bt4 caption 'Modify'  action clb_modify()
   @ 320,10 button bt5 caption 'Check'   action clb_Check()
   @ 350,10 button bt6 caption 'Check #4'   action clb_Check(4)

   @ 200,200 button btm1 caption 'Add'     action cmlb_add()
   @ 230,200 button btm2 caption 'Del'     action cmlb_del()
   @ 260,200 button btm3 caption 'Del All' action cmlb_delete_all()
   @ 290,200 button btm4 caption 'Modify'  action cmlb_modify()
   @ 320,200 button btm5 caption 'Check'   action cmlb_Check()
   @ 350,200 button btm6 caption 'Check #4'   action cmlb_Check(4)

   on key space action OnPressSpacebar()

END WINDOW

Form_1.Center ; Form_1.Activate

RETURN NIL

*.....................................................*

proc clb_add

   LOCAL nn := form_1.ListBox_1.ItemCount + 1

   form_1.ListBox_1.AddItem( 'ITEM_' + alltrim(str( nn )) )
   form_1.ListBox_1.value := nn

   RETURN

   *.....................................................*

   proc clb_del
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

      proc clb_delete_all
         form_1.ListBox_1.DeleteAllItems
         form_1.ListBox_1.value := 1

         RETURN

         *.....................................................*

         proc clb_modify
            LOCAL nn := form_1.ListBox_1.value

            IF nn > 0
               form_1.ListBox_1.item( nn ) := 'New ' + alltrim( str(nn) )
            ENDIF
            form_1.ListBox_1.Setfocus

            RETURN

            *.....................................................*

FUNCTION clb_Check(nn)

   LOCAL lCheck

   DEFAULT nn := form_1.ListBox_1.value
   IF nn > 0
      lCheck :=  clb_getCheck(nn)
      setproperty('form_1','ListBox_1',"CHECKBOXITEM",nn,!lCheck)
   ENDIF
   form_1.ListBox_1.Setfocus

   RETURN NIL

   *.....................................................*

FUNCTION clb_getCheck(nn)

   LOCAL lCheck

   lCheck := GetProperty('form_1','ListBox_1',"CHECKBOXITEM",nn)

   RETURN lCheck

   *.....................................................*

   proc OnPressSpacebar()
      IF GetProperty('form_1',"FOCUSEDCONTROL") == "ListBox_1"
         clb_Check()
      ELSE
         cmlb_Check()
      ENDIF

      RETURN

      *.....................................................*

      proc cmlb_add
         LOCAL nn := form_1.ListBox_2.ItemCount + 1

         form_1.ListBox_2.AddItem( 'ITEM_' + alltrim(str( nn )) )
         form_1.ListBox_2.value := {nn}

         RETURN

         *.....................................................*

         proc cmlb_del
            LOCAL n1, i
            LOCAL nn := form_1.ListBox_2.value

            IF len (nn) > 0
               FOR i:= len(nn) to 1 step -1
                  form_1.ListBox_2.DeleteItem( nn[i] )
               NEXT
               n1 := form_1.ListBox_2.ItemCount
               IF nn[1] <= n1
                  form_1.ListBox_2.value := {nn[1]}
               ELSE
                  form_1.ListBox_2.value := {n1}
               ENDIF
            ENDIF

            RETURN

            *.....................................................*

            proc cmlb_delete_all
               form_1.ListBox_2.DeleteAllItems
               form_1.ListBox_2.value := 1

               RETURN

               *.....................................................*

               proc cmlb_modify
                  LOCAL i, nn := form_1.ListBox_2.value

                  FOR i := 1 to len(nn)
                     form_1.ListBox_2.item( nn[i] ) := 'New ' + alltrim( str(nn[i]) )
                  NEXT
                  form_1.ListBox_2.Setfocus

                  RETURN

                  *.....................................................*

FUNCTION cmlb_Check(n)

   LOCAL lCheck, i
   LOCAL nn := form_1.ListBox_2.value

   DEFAULT n := 0
   IF n == 0
      FOR i :=1 to len(nn)
         lCheck :=  cmlb_getCheck(nn[i])
         setproperty('form_1','ListBox_2',"CHECKBOXITEM",nn[i],!lCheck)
      NEXT
   ELSE
      lCheck :=  cmlb_getCheck(n)
      setproperty('form_1','ListBox_2',"CHECKBOXITEM",n,!lCheck)
   ENDIF
   form_1.ListBox_2.Setfocus

   RETURN NIL

   *.....................................................*

FUNCTION cmlb_getCheck(nn)

   LOCAL lCheck

   lCheck := GetProperty('form_1','ListBox_2',"CHECKBOXITEM",nn)

   RETURN lCheck
