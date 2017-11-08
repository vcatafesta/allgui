/*
 * Ejemplo Tree n° 5
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo es una adaptación de una contribución realizada
 * por Alejandro Carvalho <alejandrocarvalho@gmail.com>
 *
 * Este ejemplo muestra cómo guardar la estructura de un
 * control Tree y los datos de sus items en un archivo INI,
 * y cómo definir un control Tree a partir de la información
 * guardada en un archivo INI.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main()
   LOCAL oTree1

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 368 ;
      HEIGHT 368 ;
      TITLE 'TreeView - Guardar en / Crear desde un archivo INI' ;
      MAIN

      DEFINE TREE Tree_1 OBJ oTree1 ;
         AT 10,10 ;
         WIDTH 340 ;
         HEIGHT 260 ;
         VALUE 1 ;
         SELBOLD

         FOR i := 1 TO 4
            NODE 'T1 Item ' + LTRIM(STR(i))
               FOR j := 1 TO 3
                  NODE 'T1 Item ' + LTRIM(STR(i)) + '.' + LTRIM(STR(j))
                     FOR k := 1 TO 5
                        TREEITEM 'T1 Item ' + ;
                                 LTRIM(STR(i)) + '.' + ;
                                 LTRIM(STR(j)) + '.' + ;
                                 LTRIM(STR(k))
                     NEXT
                  END NODE
               NEXT
            END NODE
         NEXT
      END TREE

      @ 290,10 BUTTON Button_1 ;
         CAPTION 'Guardar' ;
         ACTION SaveTreeToINI(oTree1);
         WIDTH 140

      @ 290,210 BUTTON Button_2 ;
         CAPTION 'Cargar' ;
         ACTION LoadTreeFromINI(oTree1);
         WIDTH 140

      ON KEY ESCAPE ACTION Form_1.Release()
   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN NIL

FUNCTION SaveTreeToINI(oTree)
   LOCAL nItems, nLen, i, Parent, cItem, cValue

   nItems := oTree:ItemCount
   IF nItems < 1
      RETURN NIL
   ENDIF

   nLen := LEN(LTRIM(STR(nItems)))

   DELETE FILE "tree.ini"

   BEGIN INI FILE "tree.ini"
      SET SECTION "TREE" ENTRY "ItemCount" TO LTRIM(STR(nItems))

      FOR i := 1 TO nItems
         IF oTree:GetParent(i) == NIL                 // Root item
            cItem := "ITEM_" + STRZERO(i, nLen, 0)
            cValue := STRZERO(0, nLen, 0) + "-" + oTree:Item(i)

            SET SECTION "TREE" ENTRY cItem TO cValue

            SaveChildren(oTree, i, nLen)
         ENDIF
      NEXT i
   END INI

   MsgInfo(LTRIM(STR(nItems)) + " items guardados en TREE.INI")

RETURN NIL

FUNCTION SaveChildren(oTree, Parent, nLen)
   LOCAL aChildren, i, cItem, cValue

   aChildren := oTree:GetChildren(Parent)

   FOR i := 1 TO LEN(aChildren)
      cItem := "ITEM_" + STRZERO(aChildren[i], nLen, 0)
      cValue := STRZERO(Parent, nLen, 0) + "-" + oTree:Item(aChildren[i])

      SET SECTION "TREE" ENTRY cItem TO cValue

      SaveChildren(oTree, aChildren[i], nLen)
   NEXT i

RETURN NIL

FUNCTION LoadTreeFromINI(oTree)
   LOCAL nItems, nLen, i, cItem, cValue

   BEGIN INI FILE "tree.ini"
      nItems := 0
      GET nItems SECTION "TREE" ENTRY "ItemCount"
      nLen := LEN(LTRIM(STR(nItems)))

      oTree:DeleteAllItems()
      cValue := ""

      FOR i := 1 to nItems
         cItem := "ITEM_" + STRZERO(i, nLen, 0)

         GET cValue SECTION "TREE" ENTRY cItem
         oTree:AddItem(SUBSTR(cValue, nLen + 2), VAL(SUBSTR(cValue, 1, nLen)))
      NEXT i
   END INI

   MsgInfo(LTRIM(STR(nItems)) + " items cargados desde TREE.INI")

RETURN NIL

/*
 * EOF
 */
