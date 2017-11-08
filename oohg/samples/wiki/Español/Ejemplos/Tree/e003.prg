/*
 * Ejemplo Tree n° 3
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo:
 *    Arrastrar y soltar entre dos controles TREE (uno con
 *    ITEMDIDS y el otro sin ITEMIDS).
 *    Utilizar las cláusulas AutoID y ON DROP.
 *    Utilizar los métodos FirstVisible, GetChildren, IsItemVisible,
 *    ItemCount, ItemHeight, ItemVisible, LastVisible,
 *    NextVisible, SelectionID, Value y VisibleCount.
 *    Obtener los elementos visibles y los elementos que
 *    actualmente se muestran en la ventana del control.
 *    Obtener los números de referencia de los elementos
 *    visibles y los números de referencia de los elementos
 *    que actualmente se muestran en la ventana del control.
 *    Obtener y establecer el ID del elemento seleccionado.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 *
 * El archivo de recursos y las imágenes pueden descargarse desde:
 * https://github.com/fyurisich/OOHG_Samples/tree/master/Español/Ejemplos/Tree
 */

#include "oohg.ch"

FUNCTION Main()

   LOCAL oForm, oTree1, oTree2, aIDs := {}, oTree

   DEFINE WINDOW Form_1 OBJ oForm ;
      AT 0,0 ;
      WIDTH 640 ;
      HEIGHT 410 ;
      TITLE 'Control Tree con ITEMIDS' ;
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
         ITEMIDS ;
         VALUE "NODO1" ;
         ON DROP {|uNewItem| Tree1_Drop( oTree1, uNewItem )}

         FOR i := 1 TO 4
            NODE 'T1 Item ' + LTRIM(STR(i)) ID "NODO" + LTRIM(STR(i))
               FOR j := 1 TO 3
                  NODE 'T1 Item ' + ;
                       LTRIM(STR(i)) + ;
                       '.' + ;
                       LTRIM(STR(j)) AUTOID
                     FOR k := 1 TO 5
                        TREEITEM 'T1 Item ' + ;
                                 LTRIM(STR(i)) + '.' + ;
                                 LTRIM(STR(j)) + '.' + ;
                                 LTRIM(STR(k)) AUTOID
                     NEXT
                  END NODE
               NEXT
            END NODE
         NEXT
      END TREE

      FOR i := 1 TO 4
         Form_1.Tree_1.Expand("NODO" + LTRIM(STR(i)))
      NEXT

      oTree1:ItemVisible(oTree1:Value)

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
         ON DROP {|uNewItem| Tree2_Drop(oTree2, uNewItem)}

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

      @ 250,10 BUTTON Button_1 ;
         CAPTION 'ID del Item Seleccionado' ;
         ACTION AutoMsgBox(oTree:Value) ;
         WIDTH 140

      @ 250,160 BUTTON Button_2 ;
         CAPTION 'Primero Visible' ;
         ACTION AutoMsgBox(oTree:FirstVisible()) ;
         WIDTH 140

      @ 250,310 BUTTON Button_3 ;
         CAPTION 'Items Visibles' ;
         ACTION VisibleItems(oTree) ;
         WIDTH 140

      @ 250,460 BUTTON Button_4 ;
         CAPTION 'Mostrar Item' ;
         ACTION MostrarItem( oTree ) ;
         WIDTH 140

      @ 280,10 BUTTON Button_5 ;
         CAPTION 'Cambiar ID del Item Sel.' ;
         ACTION ChangeID(oTree) ;
         WIDTH 140

      @ 280,160 BUTTON Button_6 ;
         CAPTION 'Cantidad Visible' ;
         ACTION AutoMsgBox(oTree:VisibleCount()) ;
         WIDTH 140

      @ 280,310 BUTTON Button_7 ;
         CAPTION 'Items en Ventana' ;
         ACTION ItemsInWindow(oTree) ;
         WIDTH 140

      @ 280,460 BUTTON Button_8 ;
         CAPTION 'Moverse al Item' ;
         ACTION MoverItem( oTree ) ;
         WIDTH 140

      @ 310,10 BUTTON Button_9 ;
         CAPTION 'Está en la Ventana' ;
         ACTION EstaVisible( oTree ) ;
         WIDTH 140

      @ 310,160 BUTTON Button_10 ;
         CAPTION 'Último Visible' ;
         ACTION AutoMsgBox(oTree:LastVisible()) ;
         WIDTH 140

      @ 310,310 BUTTON Button_11 ;
         CAPTION 'Alto del Item' ;
         ACTION AutoMsgBox(;
                oTree:ItemHeight(;
                   VAL(InputBox('New Item Height')))) ;
         WIDTH 140

      @ 340,10 BUTTON Button_12 ;
         CAPTION 'Hijos' ;
         ACTION MostrarHijos( oTree ) ;
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
 * Items que son visibles ahora o que pueden ser visibles
 * cuando se navegue por el control.
 */
FUNCTION VisibleItems( oTree )
   LOCAL i, Item, lFound

   i := 1
   Item := oTree:FirstVisible()
   lFound := .F.

   DO WHILE Item # IF( oTRee:ItemIds, NIL, 0)
      AutoMsgBox(Item)

      i ++
      lFound := .T.

      Item := oTree:NextVisible(Item)
   ENDDO

   IF ! lFound
      MsgBox("No hay items visibles !!!")
   ENDIF

RETURN NIL

/* Items que son visibles ahora
 * El segundo parámetro en IsItemVisible indica si el método
 * considerará visible a un item parcialmente mostrado.
 */
FUNCTION ItemsInWindow( oTree )
   LOCAL i, Item, Partial, lFound

   i := 1
   Item := oTree:FirstVisible()
   lFound := .F.

   DO WHILE Item #  IF( oTRee:ItemIds, NIL, 0) .AND. ;
            oTree:IsItemVisible(Item, .F.)
      AutoMsgBox({Item, IF(oTree:IsItemVisible(Item, .T.), ;
                           "completo", "parcial")})
      i ++
      lFound := .T.

      Item := oTree:NextVisible(Item)
   ENDDO

   IF ! lFound
      MsgBox("Tree's window shows no item !!!")
   ENDIF

RETURN NIL

FUNCTION MostrarItem( oTree )
   LOCAL uItem

   uItem := InputBox('Item To Show')

   IF oTree:IsItemValid( uItem )
      AutoMsgBox( oTree:ItemVisible( uItem ) )
   ELSE
      MsgStop( "Invalid item !!!" )
   ENDIF

RETURN NIL

/* En controles TREE sin la claúsula ITEMID se puede usar
 * oTree:SelectionID := Nil para borrar el ID del item.
 *
 * Hacer eso en controles con la claúsula ITEMID generará un error.
 *
 * Note que oTree:SelectionID() devuelve el ID del item seleccionado,
 * mientras que oTree:SelectionID(Nil) tratará de borrar el mismo.
 */
FUNCTION ChangeID(oTree)
   LOCAL newID

   // se asumen IDs de tipo Character
   newID := InputBox('Cambiar ID de ' + ;
                     AutoType( oTree:SelectionID() ) + ' a:')
   // para IDs numéricos habilite la siguiente línea y adapte la validacion
   // newID := VAL(newID)
   // para IDs mixtos desarrollo y use su propia función de captura

   IF EMPTY(newID)
      MsgStop("ID no puede quedar vacío !!!")
   ELSE
      AutoMsgBox(oTree:SelectionID(newID))
   ENDIF

RETURN NIL

FUNCTION EstaVisible( oTree )
   LOCAL uItem

   uItem := InputBox('Item a verificar')
   IF ! oTree:ItemIds
      uItem := VAL( uItem )
   ENDIF

   IF oTree:IsItemValid( uItem )
      AutoMsgBox( oTree:IsItemVisible( uItem ) )
   ELSE
      MsgStop( "Item inválido !!!" )
   ENDIF

RETURN NIL

/* Estas funciones son llamadas siempre que un item es soltado sobre
 * los controles por los codeblocks de las cláusulas ON DROP.
 * Estos codeblocks reciben, cómo primer parámetro, una referencia al
 * nuevo item agregado o movido (después que la operación ha terminado).
 * Puede utilizar estos codeblocks para hacer cualquier operación,
 * incluyendo cambiar cualquiera de las propiedas del item (incluso
 * asignar un nuevo ID).
 */
FUNCTION Tree1_Drop(oTree, uNewItem)

   MsgBox("Nuevo Item: " + AutoType(uNewItem) + hb_OsNewLine() + ;
          "Hijos: " + AutoType(oTree:GetChildren(uNewItem)))

RETURN NIL

FUNCTION Tree2_Drop(oTree, uNewItem)

   MsgBox("Nuevo Item: " + LTRIM(STR(uNewItem)) + hb_OsNewLine() + ;
          "Hijos: " + AutoType(oTree:GetChildren(uNewItem)))

RETURN NIL

FUNCTION MoverItem( oTree )
   LOCAL uItem

   uItem := InputBox('Item a mover')
   IF ! oTree:ItemIds
      uItem := VAL( uItem )
   ENDIF

   IF oTree:IsItemValid( uItem )
      AutoMsgBox( oTree:Value( uItem ) )
   ELSE
      MsgStop( "Item inválido !!!" )
   ENDIF

RETURN NIL

FUNCTION MostrarHijos( oTree )

   IF Empty(oTree:Value)
      MsgBox( "El control no tiene items o ninguno está seleccionado !!!" )
   ELSE
      AutoMsgBox(oTree:GetChildren(oTree:Value))
   ENDIF

RETURN NIL

/*
 * EOF
 */
