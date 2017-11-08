/*
 * Ejemplo Grid n° 05
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Basado en un ejemplo de la distribución de OOHG creada por
 * Ciro Vargas C. <cvc@oohg.org>
 *
 * Este ejemplo muestra cómo utilizar imágenes en los
 * cabezales de columna. Es posible utilizar código similar
 * en los controles Browse y XBrowse.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main
   LOCAL oForm, oGrid, aRows[ 20 ]

   DEFINE WINDOW Form_1 OBJ oForm ;
      AT 0, 0 ;
      WIDTH 640 ;
      HEIGHT 400 ;
      TITLE 'Grid - Imágenes en los Cabezales de Columna' ;
      MAIN

      DEFINE MAIN MENU
         DEFINE POPUP 'Ver aquí'
            MENUITEM 'Remover col. 1' ACTION oGrid:DeleteColumn( 1, .T. )
            MENUITEM 'Agregar col. 5' ;
               ACTION oGrid:AddColumn( 5, ;
                                       "Nueva col.", ;
                                       70, ;
                                       HEADER_IMG_AT_LEFT, ;
                                       WHITE, ;
                                       RED, ;
                                       .T., ;
                                       Nil, ;
                                       { 'TEXTBOX', 'CHARACTER', '!!!' }, ;
                                       { || automsgbox("Cliqueada !!!") }, ;
                                       { |x| ! empty(x) }, ;
                                       "No puede estar vacía !!!", ;
                                       { |col, item| empty(item[col]) }, ;
                                       2, ;
                                       HEADER_IMG_AT_LEFT )
            MENUITEM 'Cambiar imágenes' ;
               ACTION oGrid:LoadHeaderImages( {'MINIGUI_EDIT_ADD', ;
                                               'MINIGUI_EDIT_CANCEL', ;
                                               'MINIGUI_EDIT_ADD', ;
                                               'MINIGUI_EDIT_CANCEL', ;
                                               'MINIGUI_EDIT_ADD'} )
            SEPARATOR
            MENUITEM 'Remover imagen de la col. 3' ;
               ACTION oGrid:HeaderImage( 3, 0 )
            MENUITEM 'Agregar imagen 2 a la col. 3' ;
               ACTION oGrid:HeaderImage( 3, 2 )
            SEPARATOR
            MENUITEM 'Ubicar a la izquierda en la col. 3' ;
               ACTION oGrid:HeaderImageAlign( 3, HEADER_IMG_AT_LEFT )
            MENUITEM 'Ubicar a la derecha en la col. 3' ;
               ACTION oGrid:HeaderImageAlign( 3, HEADER_IMG_AT_RIGHT )
            SEPARATOR
            MENUITEM "Índice de la imagen en la col 3" ;
               ACTION AutoMsgBox( oGrid:HeaderImage( 3 ) )
            MENUITEM "Alineación de la imagen en la col. 3" ;
               ACTION MsgBox( ;
                  IF( oGrid:HeaderImageAlign( 3 ) == HEADER_IMG_AT_LEFT, ;
                      'IZQUIERDA', 'DERECHA') )
            SEPARATOR
            MENUITEM 'Cambiar valores del ítem 2' ACTION SetItem()
            MENUITEM 'Obtener valores del ítem 2' ACTION GetItem()
            SEPARATOR
            MENUITEM 'Ocultar la col. 2' ACTION oGrid:ColumnHide( 2 )
            MENUITEM 'Mostrar la col. 2' ACTION oGrid:ColumnShow( 2 )
            MENUITEM 'Ajustar columnas al mejor ancho' ;
               ACTION oGrid:ColumnsBetterAutoFit()
            MENUITEM 'Cambiar el cabezal de la col. 1' ;
               ACTION ChangeHeader(oGrid)
         END POPUP
      END MENU

      aRows [01] := { 113.12, date(), 1, 01, .T. }
      aRows [02] := { 123.12, date(), 2, 02, .F. }
      aRows [03] := { 133.12, date(), 3, 03, .T. }
      aRows [04] := { 143.12, date(), 1, 04, .F. }
      aRows [05] := { 153.12, date(), 2, 05, .T. }
      aRows [06] := { 163.12, date(), 3, 06, .F. }
      aRows [07] := { 173.12, date(), 1, 07, .T. }
      aRows [08] := { 183.12, date(), 2, 08, .F. }
      aRows [09] := { 193.12, date(), 3, 09, .T. }
      aRows [10] := { 113.12, date(), 1, 10, .F. }
      aRows [11] := { 123.12, date(), 2, 11, .T. }
      aRows [12] := { 133.12, date(), 3, 12, .F. }
      aRows [13] := { 143.12, date(), 1, 13, .T. }
      aRows [14] := { 153.12, date(), 2, 14, .F. }
      aRows [15] := { 163.12, date(), 3, 15, .T. }
      aRows [16] := { 173.12, date(), 1, 16, .F. }
      aRows [17] := { 183.12, date(), 2, 17, .T. }
      aRows [18] := { 193.12, date(), 3, 18, .F. }
      aRows [19] := { 113.12, date(), 1, 19, .T. }
      aRows [20] := { 123.12, date(), 2, 20, .F. }

      DEFINE GRID Grid_1
         ROW 10
         COL 10
         WIDTH 620
         HEIGHT 330
         HEADERS { 'Col. 1', 'Col. 2', 'Col. 3', 'Col. 4', 'Col. 5' }
         HEADERIMAGES { 'MINIGUI_EDIT_EDIT', ;
                        'MINIGUI_EDIT_DELETE', ;
                        'MINIGUI_EDIT_EDIT', ;
                        'MINIGUI_EDIT_CLOSE', ;
                        'MINIGUI_EDIT_EDIT' }
         IMAGESALIGN { HEADER_IMG_AT_RIGHT, ;
                       HEADER_IMG_AT_LEFT, ;
                       HEADER_IMG_AT_RIGHT, ;
                       HEADER_IMG_AT_LEFT, ;
                       HEADER_IMG_AT_RIGHT }
         JUSTIFY { GRID_JTFY_RIGHT, ;
                   GRID_JTFY_RIGHT, ;
                   GRID_JTFY_RIGHT, ;
                   GRID_JTFY_RIGHT, ;
                   GRID_JTFY_RIGHT }
         WIDTHS { 140, 140, 140, 140, 140 }
         ITEMS aRows
         ALLOWEDIT .T.
         COLUMNCONTROLS { { 'TEXTBOX', 'NUMERIC', '$ 999,999.99' }, ;
                          { 'DATEPICKER', 'DROPDOWN' }, ;
                          { 'COMBOBOX', { 'Uno', 'Dos', 'Tres' } }, ;
                          { 'SPINNER', 1, 20 }, ;
                          { 'CHECKBOX', 'Si', 'No' } }
      END GRID

      oGrid := GetControlObject( "Grid_1", "Form_1" )

      ON KEY ESCAPE OF Form_1 ACTION Form_1.Release()
   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

RETURN NIL

/*
 *  HEADERIMAGES { 'MINIGUI_EDIT_EDIT', ;
 *                 'MINIGUI_EDIT_DELETE', ;
 *                 'MINIGUI_EDIT_EDIT', ;
 *                 'MINIGUI_EDIT_CLOSE', ;
 *                 'MINIGUI_EDIT_EDIT' }
 *
 *  Define las imágenes para cada cabezal de columna.
 *
 *  Las imágenes son cargadas (sin repeticiones) en una "imagelist" en
 *  - la posición 1: MINIGUI_EDIT_EDIT
 *  - la posición 2: MINIGUI_EDIT_DELETE
 *  - la posición 3: MINIGUI_EDIT_CLOSE
 *
 *  Las imágenes son asociadas a cada columna por el índice de la imagen
 *  en la "imagelist", por lo que
 *  ::HeaderImage(1) retorna 1
 *  ::HeaderImage(2) retorna 2
 *  ::HeaderImage(3) retorna 1
 *  ::HeaderImage(4) retorna 3
 *  ::HeaderImage(5) retorna 1
 *
 */

PROCEDURE SetItem

   Form_1.Grid_1.Item( 2 ) := { 123.45, date(), 2, 10, .T. }

RETURN

PROCEDURE GetItem
   LOCAL a

   a := Form_1.Grid_1.Item( 2 )

   MsgInfo( str( a[ 1 ] ), 'Item 2  Col. 1' )
   MsgInfo( dtoc( a[ 2 ] ), 'Item 2  Col. 2' )
   MsgInfo( str( a[ 3 ] ), 'Item 2  Col. 3' )
   MsgInfo( str( a[ 4 ] ), 'Item 2  Col. 4' )
   MsgInfo( if( a[ 5 ], '.T.', '.F.' ), 'Item 2  Col. 5' )

RETURN

PROCEDURE ChangeHeader

   IF GetProperty( 'Form_1', 'Grid_1', 'HEADER', 1 ) == 'Nuevo'
      Form_1.Grid_1.Header( 1 ) := "Col. 1"
   Else
      SetProperty( 'Form_1', 'Grid_1', 'HEADER', 1, 'Nuevo' )
   ENDIF

RETURN

/*
 * EOF
 */
