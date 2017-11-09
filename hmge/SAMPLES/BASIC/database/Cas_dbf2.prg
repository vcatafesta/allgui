* Cas_dbf2.prg
* versao: 10/11/2005  02:03am
* Este programa abre arquivos .DBF
* e faz procura pelos campos criando um arquivo .CDX temporario,
* é so clicar na coluna do campo e escrever o que deseja procurar
* por enquanto esta fazendo somente busca por campos do tipo
* caracter, numerico, data e logica
* Falta procurar por campo memo e indexar pelo campo memo.
* Neste programa foi adicionado dois listbox
* para escolher os campos e colocar para ser indexado

*.(cas)....................................................................................*

#include "minigui.ch"
#include "Dbstruct.ch"

MEMVAR a_fields
MEMVAR a_width
MEMVAR x_campo
MEMVAR x_macro
MEMVAR m_filtrado
MEMVAR h_inicial
MEMVAR h_hora
MEMVAR var

FUNCTION Main

   LOCAL n_for
   PRIVATE var
   PRIVATE a_fields
   PRIVATE a_width
   PRIVATE x_campo := '', x_macro
   PRIVATE m_filtrado := 0
   PRIVATE h_inicial, h_hora

   REQUEST DBFCDX, DBFFPT
   RDDSETDEFAULT( "DBFCDX" )

   USE MUSIC Via "DBFCDX"
   VAR := alias()

   a_fields := {}
   a_width  := {}
   FOR n_for=1 to fcount()
      aadd( a_fields , fieldname( n_for ) )
      aadd( a_width  , 150 )
   NEXT

   x_campo := ''
   m_filtrado := 0

   SET DATE BRITISH
   SET CENTURY ON
   SET DELETED ON
   SET BROWSESYNC ON

   DEFINE WINDOW Form_1 ;
         AT 0,0 WIDTH 640 HEIGHT 480 ;
         TITLE 'CAS_DBF - By CAS - cas_webnet@yahoo.com.br' ;
         MAIN NOMAXIMIZE ;
         ICON "ICON_CAS.ICO" ;
         ON INIT (OpenTables()) ;
         ON RELEASE CloseTables()

      @ 0,250 COMBOBOX Combo_2 of Form_1 ;
         WIDTH 150 ;
         ITEMS {'Ascending','Descending'} ;
         VALUE 1 ;
         ON CHANGE f_change_order() ;
         FONT 'Courier' SIZE 10

      @ 30,010 label lbl_1 value 'Campos' width 140 center backcolor {0,255,255} ;
         TOOLTIP 'Escolha os campos abaixo e utilize o duplo click'
      @ 50,010 LISTBOX ListBox_1 WIDTH 140 HEIGHT 110 ;
         ITEMS a_fields ;
         value 1 ;
         TOOLTIP 'Duplo Click - Move o campo para ser indexado' ;
         ON CHANGE nil ;
         ON DBLCLICK f_click() ;
         backcolor {0,255,255}
      @ 30,154 label lbl_2 value 'Indexar por' width 140 center backcolor {0,255,0} ;
         TOOLTIP 'Para apagar os campos abaixo, utilize o duplo click'
      @ 50,154 LISTBOX ListBox_2 WIDTH 140 HEIGHT 110 ;
         ITEMS {} ;
         value 1 ;
         TOOLTIP 'Duplo Click - Para apagar o campo escolhido' ;
         ON CHANGE nil ;
         ON DBLCLICK cas_del() ;
         backcolor {0,255,0}
      * msginfo( ;
      * 'this.value = ' + str(this.value) +chr(13)+;
      * 'this.item( this.value ) = ' + this.item(this.value) )
      @ 050,294 button btn_cima  caption 'Up'   width 44 height 55 action f_up_down(-1)
      @ 104,294 button btn_baixo caption 'Down' width 44 height 56 action f_up_down(+1)

      f_menu()

      DEFINE STATUSBAR
         STATUSITEM ''
      END STATUSBAR

      f_browse()

   END WINDOW

   CENTER WINDOW Form_1
   Form_1.Browse_1.SetFocus
   ACTIVATE WINDOW Form_1

   RETURN NIL

   *.(cas)....................................................................................*

   func f_up_down( n_op )
      LOCAL nn, xx, x1, x2
      LOCAL n_item := form_1.listbox_2.ItemCount

      IF n_item < 2
         retu nil
      end

      nn := form_1.ListBox_2.value
      xx := form_1.ListBox_2.item( nn )

      IF ( n_op = -1 .and. nn # 1      ) .or.;
            ( n_op =  1 .and. nn # n_item )
         form_1.listbox_2.item( nn   ) := form_1.listbox_2.item( nn + n_op )
         form_1.listbox_2.item( nn + n_op ) := xx
         form_1.listbox_2.value := nn + n_op
      end

      IF n_op = -1 .and. nn = 1
         x1 := form_1.listbox_2.item( 1 )
         x2 := form_1.listbox_2.item( n_item )
         form_1.listbox_2.item( 1 )      := x2
         form_1.listbox_2.item( n_item ) := x1
         form_1.listbox_2.value          := n_item
      end

      IF n_op = 1 .and. nn = n_item
         x1 := form_1.listbox_2.item( n_item )
         x2 := form_1.listbox_2.item( 1 )
         form_1.listbox_2.item( n_item ) := x2
         form_1.listbox_2.item( 1 )      := x1
         form_1.listbox_2.value          := 1
      end

      retu nil

      *.(cas)....................................................................................*

      proc cas_del

         LOCAL nn, n1

         nn := form_1.ListBox_2.value
         form_1.ListBox_2.DeleteItem( nn )
         n1 := form_1.ListBox_2.ItemCount
         IF nn <= n1
            form_1.ListBox_2.value := nn
         ENDIF
         IF nn > n1
            form_1.ListBox_2.value := n1
         ENDIF

         RETURN

         *.(cas)....................................................................................*

         func f_click

            LOCAL nn, xx, n_for, x_for

            nn := form_1.ListBox_1.value
            xx := form_1.ListBox_1.item( nn )

            FOR n_for=1 to form_1.listbox_2.ItemCount
               x_for := form_1.ListBox_2.item( n_for )
               IF xx $ x_for
                  msginfo('Campo "'+x_for+'" JA EXISTE, POSICAO: '+alltrim(str(n_for)),'AVISO')
                  retu nil
               end
            NEXT

            IF type(xx) = 'N'
               xx := 'str('+xx+')'
            end
            IF type(xx) = 'D'
               xx := 'dtoc('+xx+')'
            end
            IF type(xx) = 'L'
               xx := "iif(" + xx + ", '.T.','.f.' )"
            end

            form_1.ListBox_2.AddItem( xx )
            form_1.ListBox_2.value := form_1.listbox_2.itemcount

            retu nil

            *.(cas)....................................................................................*

PROCEDURE OpenTables()

   ferase("TMP.CDX")

   Form_1.Browse_1.Value := RecNo()
   f_autofit()

   RETURN

   *.(cas)....................................................................................*

PROCEDURE CloseTables()

   USE
   ferase("TMP.CDX")

   RETURN

   *.(cas)....................................................................................*

   func f_seek( x_campo )

      LOCAL n_for
      LOCAL m_entrada := alltrim( InputBox( 'Campo: '+x_campo , 'cas_webnet@yahoo.com.br' ) )

      IF empty( m_entrada )
         SET index to
         GO TOP
         form_1.browse_1.value := recno()
         msgstop( "Busca cancelada" )
         retu nil
      end

      IF type(x_campo) = 'N'
         x_macro := m_entrada +'='+ x_campo
      ELSEIF type(x_campo) = 'D'
         x_macro := [ctod("] + m_entrada + [")] + " = " + x_campo
      ELSEIF type(x_campo) = 'L'
         x_macro := m_entrada +'='+ x_campo
      ELSE
         x_macro := [upper("] + m_entrada + [")] + " $ upper(" + x_campo + ")"
      end

      SET index to
      ferase("TMP.CDX")

      h_inicial := time()
      h_hora    := time()

      IF form_1.combo_1.value # 0
         x_campo := a_fields[ form_1.combo_1.value ]
      end

      IF form_1.listbox_2.ItemCount # 0
         x_campo := ''
         FOR n_for=1 to form_1.listbox_2.ItemCount
            x_campo += form_1.listbox_2.item( n_for ) + '+'
         NEXT
         x_campo := left( x_campo , len(x_campo)-1 )
      end

      *msginfo( x_campo , 'campos' )

      IF form_1.combo_2.value = 2   && ascending / descending
         INDEX ON  &x_campo  TAG CAS_TAG to TMP ;
            FOR &x_macro ;
               EVAL cas_Progress( 1 , h_hora, h_inicial )  EVERY  LASTREC()/10 DESCENDING
         ELSE
            INDEX ON  &x_campo  TAG CAS_TAG to TMP ;
               FOR &x_macro ;
                  EVAL cas_Progress( 1 , h_hora, h_inicial )  EVERY  LASTREC()/10
            ENDIF

            GO TOP

            form_1.browse_1.value := recno()
            form_1.browse_1.refresh

            f_change()

            f_autofit()

            retu nil

            *.(cas)....................................................................................*

FUNCTION cas_Progress( m_pos , t_time , t_inicio )

   LOCAL cComplete := LTRIM(STR((RECNO()/LASTREC()) * 100))
   LOCAL x_indice  := "Indice: " +alltrim(str(m_pos))

   Form_1.StatusBar.Item(1) := ;
      x_indice + "   Indexing..." +;
      cComplete + "%" +;
      "     Time:" + elaptime( t_time , time() ) +' - '+;
      "    Total:" + elaptime( t_inicio , time() )

   RETURN .T.

   *.(cas)....................................................................................*

   func f_change
      Form_1.StatusBar.Item(1) := ;
         'Recno '+alltrim(str(recno())) +' / '+;
         alltrim(str(lastrec())) + ' Lastrec      Itens filtrado(s) = ' + alltrim(str(f_filtros())) +;
         '       OrdKeyNo() = ' + alltrim(str( OrdKeyNo() )) +;
         '       Porc = ' + alltrim(str( OrdKeyNo() / m_filtrado * 100 ) ) + '%'
      retu nil

      *.(cas)....................................................................................*

      func f_filtros
         LOCAL n_recno := recno()

         go bottom
         m_filtrado := OrdKeyNo()
         go n_recno
         retu m_filtrado

         *.(cas)....................................................................................*

         func f_autofit
            Form_1.Browse_1.DisableUpdate
            Form_1.Browse_1.ColumnsAutoFitH
            Form_1.Browse_1.ColumnsAutoFit
            Form_1.Browse_1.EnableUpdate
            retu nil

            *.(cas)....................................................................................*

            func f_read

               LOCAL i, n_for, File_mp3, n_rat
               LOCAL varios := .t.   && selecionar varios arquivos

               LOCAL arq_mp3 := GetFile ( { ;
                  {'Files DBF' ,;
                  '*.DBF;*.DBF'} ,;
                  {'All Files .DBF' , '*.dbf'} ,;
                  {'All Files .DBF' , '*.DBF'}  } ,;
                  'Open File DBF' , '' , varios , .t. )

               IF len( arq_mp3 ) = 0

                  RETURN NIL
               ENDIF

               FOR n_for := 1 to len( arq_mp3 )
                  i := n_for + 1

                  IF n_for = len(arq_mp3)  && esta consistencia foi feita pq o ultimo arquivo
                     i := 1       && é sempre o primeiro
                  ENDIF

                  File_mp3 := arq_mp3[ i ]

                  n_rat = rat('\\',file_mp3)

                  IF n_rat # 0  && D:\\
                     File_mp3 = stuff( File_mp3 , n_rat , 2 , '\' )
                  end

               NEXT

               form_1.browse_1.release
               form_1.combo_1.release
               form_1.label_1.release

               CLOSE data

               File_mp3 := arq_mp3[ 1 ]
               USE &file_mp3 alias &var
               a_fields := {}
               a_width  := {}
               form_1.ListBox_1.DeleteAllItems
               form_1.ListBox_2.DeleteAllItems
               FOR n_for=1 to fcount()
                  aadd( a_fields , fieldname( n_for ) )
                  aadd( a_width  , 150 )
                  form_1.ListBox_1.AddItem( fieldname( n_for ) )
               NEXT

               f_browse()

               form_1.browse_1.refresh

               RETURN NIL

               *.(cas)....................................................................................*

               func f_browse

                  LOCAL n_for
                  LOCAL a_seek := {}
                  MEMVAR xx_var
                  PRIVATE xx_var

                  FOR n_for=1 to fcount()
                     xx_var := "'" + fieldname( n_for ) + "'"
                     aadd( a_seek , { || f_seek( &xx_var ) } )
                  NEXT

                  @ 160,10 BROWSE Browse_1 of Form_1 ;
                     WIDTH form_1.width-30 ;
                     HEIGHT 240 ;
                     HEADERS a_fields ;
                     WIDTHS a_width ;
                     WORKAREA &var ;
                     FIELDS a_fields ;
                     TOOLTIP 'Browse' ;
                     ON CHANGE f_change() ;
                     ON HEADCLICK ;
                     a_seek ;
                     DELETE ;
                     LOCK ;
                     EDIT INPLACE

                  @ 0,5 label label_1 of form_1 value 'Order by' autosize

                  @ 0,60 COMBOBOX Combo_1 of Form_1 ;
                     WIDTH 150 ;
                     ITEMS a_fields ;
                     VALUE 1 ;
                     ON ENTER MsgInfo ( Str(Form_1.Combo_1.value) ) ;
                     ON CHANGE f_change_order() ;
                     FONT 'Courier' SIZE 10

                  f_menu()

                  retu nil

                  *.(cas)....................................................................................*

                  func f_menu

                     LOCAL n_for, x_for, x_act

                     DEFINE MAIN MENU OF Form_1
                        POPUP 'Arquivo'
                           ITEM 'Abrir'   ACTION f_read()
                           SEPARATOR
                           ITEM 'Ajuda'    ACTION msginfo(;
                              '1) Escolha o campo a ser indexado, utilize o duplo click'+chr(13)+;
                              '2) "Indexar por" para excluir os campos, utilize o duplo click'+chr(13)+;
                              '3) Click em um campo qualquer do browse'+chr(13)+;
                              '4) Ele procurara pelo campo escolhido no browse'+chr(13)+;
                              '5) e indexara pelos campos escolhidos no "indexar por"','Ajuda')
                           ITEM 'AutoFit'   ACTION f_autofit()
                           ITEM 'Sair'   ACTION Form_1.Release
                        END POPUP
                        POPUP '?'
                           ITEM 'Sobre'    ACTION MsgInfo( MiniGuiVersion(), 'CAS_DBF by CAS' )
                        END POPUP
                     END MENU

                     DEFINE CONTEXT MENU OF Form_1
                        FOR n_for=1 to fcount()
                           x_for = fieldname( n_for )
                           x_act = "f_seek('" + x_for + "')"
                           ITEM x_for action &x_act
                        NEXT
                     END MENU

                     retu nil

                     *.(cas)....................................................................................*

                     func f_change_order

                        SET index to
                        ferase("TMP.CDX")

                        h_inicial := time()
                        h_hora    := time()

                        IF form_1.combo_1.value # 0
                           x_campo := a_fields[ form_1.combo_1.value ]
                        end

                        x_macro := '.t.'

                        IF form_1.combo_2.value = 2   && ascending / descending
                           INDEX ON  &x_campo  TAG CAS_TAG to TMP ;
                              FOR &x_macro ;
                                 EVAL cas_Progress( 1 , h_hora, h_inicial )  EVERY  LASTREC()/10 DESCENDING
                           ELSE
                              INDEX ON  &x_campo  TAG CAS_TAG to TMP ;
                                 FOR &x_macro ;
                                    EVAL cas_Progress( 1 , h_hora, h_inicial )  EVERY  LASTREC()/10
                              ENDIF

                              GO TOP
                              form_1.browse_1.value := recno()
                              form_1.browse_1.refresh

                              retu nil

