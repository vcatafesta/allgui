/*
 * Ejemplo Tree n° 2
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo enlazar y mostrar diferentes
 * ventanas a un control Tree. Cuando cambia el ítem
 * seleccionado, la ventana correspondiente se muestra en
 * el lado izquierdo del formulario.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

 #include "oohg.ch"

 FUNCTION Main

    DEFINE WINDOW Form_1 ;
       OBJ oForm ;
       AT 0,0 ;
       WIDTH 640 ;
       HEIGHT 480 ;
       TITLE 'Como enlazar diferentes ventana a un control Tree' ;
       MAIN

       DEFINE TREE Tree_1 ;
          OBJ oTree ;
          AT 10,10 ;
          WIDTH 200 ;
          HEIGHT 400 ;
          ON CHANGE MostrarMiVentana( oForm, oTree )

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

    END WINDOW

    CENTER WINDOW Form_1
    ACTIVATE WINDOW Form_1

 RETURN Nil

 FUNCTION MostrarMiVentana( oForm, oTree )

    STATIC oAuxWin := Nil

    IF HB_IsObject( oAuxWin )
      oAuxWin:Release()
      oAuxWin := Nil
    ENDIF

    DEFINE INTERNAL AuxWin ;
       OBJ oAuxWin ;
       OF (oForm) ;
       AT oTree:row, oTree:col + oTree:width + 20 ;
       WIDTH oForm:width - oTree:col * 2 - oTree:width - 30 ;
       HEIGHT oTree:height ;
       BACKCOLOR WHITE ;
       BORDER

       @ 20, 20 LABEL lbl_data ;
          VALUE "Enlazada al ítem " + LTRIM(STR(oTree:value)) ;
          AUTOSIZE ;
          TRANSPARENT
    END INTERNAL

 RETURN Nil

 /*
  * EOF
  */
