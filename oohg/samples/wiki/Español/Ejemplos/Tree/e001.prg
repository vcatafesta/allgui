/*
 * Ejemplo Tree n° 1
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra como:
 *    Arrastrar y soltar entre dos controles TREE.
 *    Utilizar los métodos EditLabel, Expand, FirstVisible,
 *    IsItemExpanded, IsItemVisible, ItemCount, ItemDraggable,
 *    ItemEnabled, ItemHeight, ItemVisible, LastVisible,
 *    NextVisible, Value y VisibleCount.
 *    Obtener los items visibles y los actualmente mostrados
 *    en la ventana del control.
 *    Obtener los números de referencia de los items visibles
 *    y los números de referencia de los items actualmente
 *    mostrados en la ventana del control.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 *
 * El archivo de recursos y las imágenes pueden descargarse desde:
 * https://github.com/fyurisich/OOHG_Samples/tree/master/Español/Ejemplos/Tree
 */

#include "oohg.ch"

FUNCTION Main

   LOCAL oForm, oTree1, oTree2, oTree, lIsGreen

   SET LANGUAGE TO SPANISH

   DEFINE WINDOW Form_1 OBJ oForm ;
      AT 0,0 ;
      WIDTH 640 ;
      HEIGHT 530 ;
      TITLE 'Tree - Arrastrar/Soltar y otras cosas' ;
      MAIN

      DEFINE TREE Tree_1 OBJ oTree1 ;
         AT 10,10 ;
         WIDTH 300 ;
         HEIGHT 202 ;
         ENABLEDRAG ;
         ENABLEDROP ;
         TARGET { {|| oTree1 }, {|| oTree2 } } ;
         NODEIMAGES {"WINDOW", "WATCH"} ;
         ITEMIMAGES {"LED_OFF", "LED_ON"} ;
         SELBOLD ;
         INDENT 25 ;
         VALUE 1 ;
         BACKCOLOR YELLOW

         ON KEY F2 OF (oTree1) ACTION {|| Form_1.Tree_1.EditLabel }

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

      FOR i := 1 TO Form_1.Tree_1.ItemCount
         Form_1.Tree_1.Expand(i)
      NEXT

      oTree1:ItemVisible(oTree1:Value)

      Form_1.Tree_1.ItemDraggable(3, .F.)
      Form_1.Tree_1.ItemDraggable(4, .F.)
      Form_1.Tree_1.ItemEnabled(5, .F.)
      Form_1.Tree_1.ItemEnabled(6, .F.)


      DEFINE TREE Tree_2 OBJ oTree2 ;
         AT 10,320 ;
         WIDTH 300 ;
         HEIGHT 200 ;
         ENABLEDRAG ;
         ENABLEDROP ;
         TARGET { {|| oTree1 }, {|| oTree2 } } ;
         NODEIMAGES {"WATCH", "WINDOW"} ;
         ITEMIMAGES {"LED_OFF", "LED_ON"} ;
         VALUE 1 ;
         SELBOLD ;
         INDENT 25 ;

         ON KEY F2 OF (oTree2) ACTION {|| Form_1.Tree_2.EditLabel }

         FOR i := 1 TO 4
            NODE 'T2 Item ' + LTRIM(STR(i))
               FOR j := 1 TO 3
                  NODE 'T2 Item ' + LTRIM(STR(i)) + '.' + LTRIM(STR(j))
                     FOR k := 1 TO 5
                        TREEITEM 'T2 Item ' + ;
                                 LTRIM(STR(i)) + '.' + ;
                                 LTRIM(STR(j)) + '.' + ;
                                 LTRIM(STR(k))
                     NEXT
                  END NODE
               NEXT
            END NODE
         NEXT
      END TREE

      FOR i := 1 TO Form_1.Tree_2.ItemCount
         Form_1.Tree_2.Expand(i)
      NEXT

      Form_1.Tree_2.ItemDraggable(3, .F.)
      Form_1.Tree_2.ItemDraggable(4, .F.)
      Form_1.Tree_2.ItemEnabled(5, .F.)
      Form_1.Tree_2.ItemEnabled(6, .F.)

      @ 250,10 BUTTON Button_1 ;
         CAPTION 'Está expandido' ;
         ACTION EstaExpandido(oTree) ;
         WIDTH 140

      @ 250,160 BUTTON Button_2 ;
         CAPTION 'El primero visible' ;
         ACTION AutoMsgBox(oTree:FirstVisible()) ;
         WIDTH 140

      @ 250,310 BUTTON Button_3 ;
         CAPTION 'Ítems visibles' ;
         ACTION ItemsVisibles(oTree) ;
         WIDTH 140

      @ 250,460 BUTTON Button_4 ;
         CAPTION 'Mostrar item' ;
         ACTION MostrarItem( oTree ) ;
         WIDTH 140

      @ 280,10 BUTTON Button_5 ;
         CAPTION 'Cambiar BackColor' ;
         ACTION if( oTree:BackColorCode == ColorToCode( YELLOW ), oTree:Backcolor := GREEN, oTree:Backcolor := YELLOW ) ;
         WIDTH 140

      @ 280,160 BUTTON Button_6 ;
         CAPTION 'Cantidad visible' ;
         ACTION AutoMsgBox(oTree:VisibleCount()) ;
         WIDTH 140

      @ 280,310 BUTTON Button_7 ;
         CAPTION 'Ítems en la ventana' ;
         ACTION ItemsEnLaVentana(oTree) ;
         WIDTH 140

      @ 280,460 BUTTON Button_8 ;
         CAPTION 'Altura de cada ítem' ;
         ACTION AutoMsgBox( oTree:ItemHeight(VAL(InputBox('New Item Height')))) ;
         WIDTH 140

      @ 310,10 BUTTON Button_9 ;
         CAPTION 'Está en la ventana' ;
         ACTION EstaVisible(oTree) ;
         WIDTH 140

      @ 310,160 BUTTON Button_10 ;
         CAPTION 'Último visible' ;
         ACTION AutoMsgBox(oTree:LastVisible()) ;
         WIDTH 140

      @ 345,400 LABEL Lbl_1 ;
         VALUE "Aplicar a:" ;
         WIDTH 60

      @ 342,460 COMBOBOX Cmb_1 ;
         ITEMS {"Tree1", "Tree2"} ;
         WIDTH 140 ;
         VALUE 1 ;
         ON CHANGE oTree := if(Form_1.Cmb_1.Value == 1, oTree1, oTree2)

      oTree := oTree1

      ON KEY ESCAPE OF (oForm) ACTION oForm:Release()

   END WINDOW

   ACTIVATE WINDOW Form_1

RETURN NIL

/*
 * cómo saber si un ítem está expandido.
 */
FUNCTION EstaExpandido( oTree )
   LOCAL uItem

   uItem := VAL(InputBox('Ítem a verificar'))

   IF oTree:IsItemValid( uItem )
      AutoMsgBox( oTree:IsItemExpanded( uItem ) )
   ELSE
      MsgStop( "Ítem no valido !!!" )
   ENDIF

RETURN NIL

/*
 * Ítems que son visible ahora o que serán visibles
 * cuando se haga scroll del control.
 */
FUNCTION ItemsVisibles( oTree )
  LOCAL i, Item, lFound

  i := 1
  Item := oTree:FirstVisible()
  lFound := .F.

  DO WHILE Item # 0
     AutoMsgBox(Item)

     i ++
     lFound := .T.

     Item := oTree:NextVisible(Item)
  ENDDO

  IF ! lFound
     MsgBox("No existen ítems visibles !!!")
  ENDIF

RETURN NIL

/*
 * cómo mostrar un ítem
 */
FUNCTION MostrarItem( oTree )
   LOCAL uItem

   uItem := VAL(InputBox('Item a mostrar'))

   IF oTree:IsItemValid( uItem )
      AutoMsgBox( oTree:ItemVisible( uItem ) )
   ELSE
      MsgStop( "Ítem no valido!!!" )
   ENDIF

RETURN NIL

/* Ítems que se muestran ahora.
 * El segundo parámetro en IsItemVisible indica si el método
 * debe considerar visible a un item mostrado parcialmente.
 */
FUNCTION ItemsEnLaVentana( oTree )
  LOCAL i, Item, Partial, lFound

  i := 1
  Item := oTree:FirstVisible()
  lFound := .F.

  DO WHILE Item # 0 .AND. oTree:IsItemVisible(Item, .F.)
     AutoMsgBox({Item, IF(oTree:IsItemVisible(Item, .T.), ;
                          "completo", "parcial")})
     i ++
     lFound := .T.

     Item := oTree:NextVisible(Item)
  ENDDO

  IF ! lFound
     MsgBox("No se muestran ítems en la ventana !!!")
  ENDIF

RETURN NIL

/*
 * cómo saber si un ítem esta visible (esté o no en la ventana)
 */
FUNCTION EstaVisible( oTree )
   LOCAL uItem

   uItem := VAL(InputBox('Ítem a verificar'))

   IF oTree:IsItemValid( uItem )
      AutoMsgBox( oTree:IsItemVisible( uItem ) )
   ELSE
      MsgStop( "Ítem no valido !!!" )
   ENDIF

RETURN NIL

FUNCTION ColorToCode( aColor )
RETURN aColor[3] * 256 * 256 + aColor[2] * 256 + aColor[1]

/*
 * EOF
 */
