#include "minigui.ch"

FUNCTION main()

   LOCAL aItem

   aItem := {{'AG',' ARGENTINA'},;
      {'AK','ALASKA'},;
      {'AL','ALABAMA'},;
      {'AR','ARKANSAS'},;
      {'AZ','ARIZONA'},;
      {'BE','BELGICA'},;
      {'BR','BRASIL'},;
      {'CA','CALIFORNIA'},;
      {'CH','CHILE'},;
      {'CL','COLOMBIA'},;
      {'CN','CANADA'},;
      {'CO','COLORADO'},;
      {'CR','COSTA RICA'},;
      {'CT','CONNECTICUT'},;
      {'DE','DELAWARE'},;
      {'DF','DISTRITO FEDERAL'},;
      {'EC','ECUADOR'},;
      {'ES','ESPA¥A'},;
      {'FL','FLORIDA'},;
      {'GA','GEORGIA'},;
      {'GR','GRECIA'},;
      {'ID','IDAHO'},;
      {'IL','ILLINOIS'},;
      {'IN','INDIANA'},;
      {'IR','IRELAND'},;
      {'KA','KANSAS'},;
      {'KY','KENTUCKY'},;
      {'LA','LOUSIANA'},;
      {'MA','MASSACHUSETTS'},;
      {'MI','MISSOURI'},;
      {'MN','MINNESOTA'},;
      {'MO','MONTANA'},;
      {'MS','MISSISSIPPI'},;
      {'MX','MEXICO'},;
      {'NC','NORTH CAROLINA'},;
      {'ND','NORTH DAKOTA'},;
      {'NE','NEW ENGLAND'},;
      {'NH','NEW HAMPSHIRE'},;
      {'NJ','NEW JERSEY'},;
      {'NM','NEW MEXICO'},;
      {'NV','NEVADA'},;
      {'NY','NEW YORK'},;
      {'OH','OHIO'},;
      {'OK','OKLAHOMA'},;
      {'OR','OREGON'},;
      {'PA','PENNSYLVANIA'},;
      {'PE','PERU'},;
      {'SC','SOUTH CAROLINA'},;
      {'SD','SOUTH DAKOTA'},;
      {'TE','TENNESSEE'},;
      {'TX','TEXAS'},;
      {'UT','UTAH'},;
      {'UY','URUGAY'},;
      {'VA','VIRGINIA'},;
      {'VE','VENEZUELA'},;
      {'VT','VERMONT'},;
      {'WA','WASHINGTON'},;
      {'WI','WISCONSIN'},;
      {'WV','WEST VIRGINIA'},;
      {'WY','WYOMING'},;
      {'HI','HAWAII'}}

   DEFINE WINDOW Form_1 AT 100,60 WIDTH 450 HEIGHT 450 ;
         TITLE "MultiColumn ListBox - By Janusz Pora" ;
         MAIN ;
         NOMAXIMIZE NOSIZE

      @ 10,10 LABEL  Lbl_1 VALUE 'Style MULTITAB' AUTOSIZE BOLD

      @ 30,10 LISTBOX ListBox_1 WIDTH 200 HEIGHT 160 ;
         ITEMS aItem ;
         VALUE 2 ;
         MULTITAB ;
         TABSWIDTH {40,150}

      @ 10,220 LABEL  Lbl_2 VALUE 'Style MULTITAB and MULTICOLUMN ' AUTOSIZE BOLD

      @ 30,220 LISTBOX ListBox_2 WIDTH 200 HEIGHT 160 ;
         ITEMS aItem ;
         VALUE 2 ;
         MULTICOLUMN ;
         MULTITAB ;
         TABSWIDTH {40,150}

      @ 220,10 button bt1 caption 'Add'     action Item_add()
      @ 250,10 button bt2 caption 'Del'     action Item_del()
      @ 280,10 button bt3 caption 'Modify'  action Item_modify()
      @ 310,10 button bt4 caption 'View'    action Item_view()
      @ 340,10 button bt5 caption 'Close'   action form_1.Release()

   END WINDOW

   Form_1.Center
   Form_1.Activate

   RETURN NIL

   *.....................................................*

PROCEDURE Item_add

   LOCAL nn := form_1.ListBox_1.ItemCount + 1

   form_1.ListBox_1.AddItem( { 'ITEM_'+  alltrim(str( nn )),'Col2'} )
   form_1.ListBox_1.value := nn

   RETURN

   *.....................................................*

PROCEDURE Item_del

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

PROCEDURE Item_modify

   LOCAL nn := form_1.ListBox_1.value

   form_1.ListBox_1.item( nn ) := LB_Array2String({'New_' + alltrim( str(nn)),'Col2'})
   form_1.ListBox_1.Setfocus

   RETURN

   *.....................................................*

PROCEDURE Item_view

   LOCAL cStr, aItem

   aitem := form_1.ListBox_1.item(form_1.ListBox_1.value)
   cStr := LB_Array2String(aItem,CHR(13))

   msginfo( cStr )

   RETURN
