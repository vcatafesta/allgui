/*
 * Ejemplo Tree n° 8
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo utilizar checkboxes en un
 * control Tree.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "ooHG.ch"

PROCEDURE Main

   DEFINE WINDOW Form_1 ;
      AT 0, 0 ;
      WIDTH 640 ;
      HEIGHT 480 ;
      ON RELEASE Bye();
      MAIN ;
      TITLE "Como utilizar checkboxes en un control Tree"

      ON KEY ESCAPE ACTION Form_1.Release

      DEFINE TREE Tree_1 obj oTree;
         AT 10, 10 ;
         WIDTH 200 ;
         HEIGHT 400 ;
         CHECKBOXES

         NODE 'Item 1'
            TREEITEM 'Item 1.1' CHECKED
            TREEITEM 'Item 1.2'
            TREEITEM 'Item 1.3'
         END NODE
      END TREE
   END WINDOW

   oTree:CheckItem( 3, .T.)

   Form_1.Center
   Form_1.Activate

RETURN

PROCEDURE Bye
   LOCAL cMsg, nNum

   cMsg := "ItemCount = " + Ltrim(Str(oTree:ItemCount)) + HB_OsNewLine()

   FOR nNum := 1 TO oTree:ItemCount
      cMsg += "Item " + Ltrim(Str(nNum)) + " = "
      cMsg += IF(oTree:CheckItem(nNum), ".T.", ".F.")
      cMsg += HB_OsNewLine()
   NEXT nNum

   MSGBOX(cMsg)

RETURN

/*
 * EOF
 */
