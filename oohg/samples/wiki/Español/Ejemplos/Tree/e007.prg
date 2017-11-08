/*
 * Ejemplo Tree n° 7
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo arrastrar un item desde un
 * control Tree a una ventana de tipo internal.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 *
 * El archivo de recursos y las imágenes pueden descargarse desde:
 * https://github.com/fyurisich/OOHG_Samples/tree/master/Español/Ejemplos/Tree
 */

#include "oohg.ch"

FUNCTION Main

   PUBLIC nRow := 0, ;
          nImage := 1, ;
          aImages := { "WINDOW", "WATCH", "LED_OFF", "LED_ON" }

   DEFINE WINDOW Form_1 ;
      OBJ oForm ;
      AT 0,0 ;
      WIDTH 640 ;
      HEIGHT 480 ;
      TITLE "Como arrastrar un item de un Tree a una ventana internal" ;
      MAIN

      DEFINE TREE Tree_1 ;
         OBJ oTree ;
         AT 10,10 ;
         WIDTH 200 ;
         HEIGHT 400 ;
         ENABLEDRAG ;
         TARGET { {|| oAuxWin } } ;
         NODEIMAGES {"WINDOW", "WATCH"} ;
         ITEMIMAGES {"LED_OFF", "LED_ON"}

         NODE 'Item 1'
            TREEITEM 'Item 1.1'
            TREEITEM 'Item 1.2'
            TREEITEM 'Item 1.3'
         END NODE

         NODE 'Item 2'
            TREEITEM 'Item 2.1'

            NODE 'Item 2.2'
               TREEITEM 'Item 2.2.1'
               TREEITEM 'Item 2.2.2'
               TREEITEM 'Item 2.2.3'
               TREEITEM 'Item 2.2.4'
               TREEITEM 'Item 2.2.5'
               TREEITEM 'Item 2.2.6'
               TREEITEM 'Item 2.2.7'
               TREEITEM 'Item 2.2.8'
            END NODE

            TREEITEM 'Item 2.3'
         END NODE

         NODE 'Item 3'
            TREEITEM 'Item 3.1'
            TREEITEM 'Item 3.2'

            NODE 'Item 3.3'
               TREEITEM 'Item 3.3.1'
               TREEITEM 'Item 3.3.2'
            END NODE
         END NODE
      END TREE

      DEFINE INTERNAL AuxWin ;
         OBJ oAuxWin ;
         AT oTree:Row, oTree:Col + oTree:Width + 20 ;
         WIDTH oForm:ClientWidth - oTree:Col * 2 - oTree:Width - 30 ;
         HEIGHT oTree:Height ;
         BACKCOLOR WHITE ;
         BORDER
      END INTERNAL

      WITH OBJECT oAuxWin
         :DropEnabled := .T.
         :OnMouseDrag := ;
            { |oOrigin, oTarget, wParam| Generic_OnMouseDrag( wParam ) }
         :OnMouseDrop := ;
            { |oOrigin, oTarget, wParam| AuxWin_OnDrop( oOrigin, oTarget ) }
      END WITH

      ON KEY ESCAPE ACTION Form_1.Release()
   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN Nil

FUNCTION AuxWin_OnDrop( oOrigin, oTarget )

   LOCAL nItem, aItemImages, nImage

   WITH OBJECT oOrigin
      nItem := :HandleToItem( :ItemOnDrag )
      aItemImages := :ItemImages( :HandleToItem( :ItemOnDrag ) )
      If nItem == :Value
         nImage := aItemImages[ 2 ] + 1 // imagen para item seleccionados
      Else
         nImage := aItemImages[ 1 ] + 1 // imagen para items no seleccionados
      EndIf

      DEFINE IMAGE ( "Image_" + LTRIM( STR( nImage ) ) )
         PARENT  (oTarget)
         ROW     nRow
         COL     20
         PICTURE ( aImages[ nImage ] )
         WIDTH   50
         HEIGHT  50
         STRETCH .T.
      END IMAGE

      nRow += 60
      nImage ++
   END WITH

RETURN Nil

/*
 * EOF
 */
