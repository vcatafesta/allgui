/*
sistema     : superchef pizzaria
programa    : reajustar preços
compilador  : xharbour 1.2 simplex
lib gráfica : minigui 1.7 extended
programador : marcelo neves
*/

#include 'minigui.ch'
#include 'super.ch'

STATIC _conta_acesso_2 := 0

FUNCTION promocao()

   LOCAL a_001 := {}
   LOCAL a_002 := {}
   LOCAL a_003 := {}

   aadd(a_001,'Somente as pizzas')
   aadd(a_001,'Demais produtos')

   dbselectarea('categoria_produtos')
   categoria_produtos->(dbgotop())
   aadd(a_002,'000000 - Não escolher')
   WHILE .not. eof()
      aadd(a_002,strzero(categoria_produtos->codigo,6)+' - '+categoria_produtos->nome)
      categoria_produtos->(dbskip())
   END

   dbselectarea('subcategoria_produtos')
   subcategoria_produtos->(dbgotop())
   aadd(a_003,'000000 - Não escolher')
   WHILE .not. eof()
      aadd(a_003,strzero(subcategoria_produtos->codigo,6)+' - '+subcategoria_produtos->nome)
      subcategoria_produtos->(dbskip())
   END

   DEFINE WINDOW form_promocao ;
         at 000,000 ;
         WIDTH 900 ;
         HEIGHT 600 ;
         TITLE 'Incluir ou Excluir Promoção' ;
         ICON path_imagens+'icone.ico' ;
         modal ;
         nosize ;
         ON INIT zera_temporario_2() ;
         ON RELEASE zera_acesso_2()

      * fase 1
      @ 010,005 label lbl_001 ;
         of form_promocao ;
         VALUE 'Quais produtos em promoção ?' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      define comboboxex cbo_001
      ROW   030
      COL   005
      WIDTH 200
      HEIGHT 200
      ITEMS a_001
      VALUE 1
   END comboboxex

   * fase 2
   @ 070,005 label lbl_002 ;
      of form_promocao ;
      VALUE 'Selecione a Categoria' ;
      autosize ;
      FONT 'tahoma' size 010 ;
      bold ;
      FONTCOLOR _preto_001 ;
      TRANSPARENT
   define comboboxex cbo_002
   ROW   090
   COL   005
   WIDTH 200
   HEIGHT 400
   ITEMS a_002
   VALUE 1
   listwidth 300
END comboboxex

* fase 3
@ 130,005 label lbl_003 ;
   of form_promocao ;
   VALUE 'Selecione a Subcategoria' ;
   autosize ;
   FONT 'tahoma' size 010 ;
   bold ;
   FONTCOLOR _preto_001 ;
   TRANSPARENT
define comboboxex cbo_003
ROW   150
COL   005
WIDTH 200
HEIGHT 400
ITEMS a_003
VALUE 1
listwidth 300
END comboboxex

* fase 4
@ 200,005 label lbl_004 ;
   of form_promocao ;
   VALUE 'DIMINUIR' ;
   autosize ;
   FONT 'tahoma' size 010 ;
   bold ;
   FONTCOLOR _vermelho_002 ;
   TRANSPARENT
@ 200,070 getbox tbox_004 ;
   of form_promocao ;
   HEIGHT 027 ;
   WIDTH 070 ;
   VALUE 0 ;
   FONT 'tahoma' size 010 ;
   BACKCOLOR _fundo_get ;
   FONTCOLOR _letra_get_1 ;
   PICTURE '@E 9,999.99'
@ 200,150 label lbl_0044 ;
   of form_promocao ;
   VALUE 'no preço' ;
   autosize ;
   FONT 'tahoma' size 010 ;
   bold ;
   FONTCOLOR _preto_001 ;
   TRANSPARENT
@ 230,005 label lbl_00444 ;
   of form_promocao ;
   VALUE 'de venda já existente' ;
   autosize ;
   FONT 'tahoma' size 010 ;
   bold ;
   FONTCOLOR _preto_001 ;
   TRANSPARENT

@ 250,040 label lbl_ou ;
   of form_promocao ;
   VALUE 'ou então' ;
   autosize ;
   FONT 'tahoma' size 018 ;
   bold ;
   FONTCOLOR _preto_001 ;
   TRANSPARENT

* fase 5
@ 290,005 label lbl_005 ;
   of form_promocao ;
   VALUE 'APLICAR' ;
   autosize ;
   FONT 'tahoma' size 010 ;
   bold ;
   FONTCOLOR _vermelho_002 ;
   TRANSPARENT
@ 290,070 getbox tbox_005 ;
   of form_promocao ;
   HEIGHT 027 ;
   WIDTH 060 ;
   VALUE 0 ;
   FONT 'tahoma' size 010 ;
   BACKCOLOR _fundo_get ;
   FONTCOLOR _letra_get_1 ;
   PICTURE '@R 999.99'
@ 290,150 label lbl_0055 ;
   of form_promocao ;
   VALUE '%' ;
   autosize ;
   FONT 'tahoma' size 010 ;
   bold ;
   FONTCOLOR _preto_001 ;
   TRANSPARENT
@ 320,005 label lbl_00555 ;
   of form_promocao ;
   VALUE 'a menos sobre preço de venda' ;
   autosize ;
   FONT 'tahoma' size 010 ;
   bold ;
   FONTCOLOR _preto_001 ;
   TRANSPARENT

* botão filtrar
@ 360,005 buttonex botao_filtrar ;
   PARENT form_promocao ;
   CAPTION 'Filtrar informações' ;
   WIDTH 200 height 040 ;
   PICTURE path_imagens+'img_filtro.bmp' ;
   ACTION filtrar_informacoes_2() ;
   TOOLTIP 'Clique aqui para separar as informações e visualizar as promoções antes de efetivá-las'

* separar a tela em 2 partes
DEFINE LABEL label_separador
   COL 210
   ROW 000
   VALUE ''
   WIDTH 002
   HEIGHT 600
   TRANSPARENT .F.
   BACKCOLOR _cinza_002
END LABEL

* grid e opções do reajuste
@ 010,220 label lbl_reajuste ;
   of form_promocao ;
   VALUE 'Aqui serão visualizadas as informações filtradas com base nos critérios ao lado' ;
   autosize ;
   FONT 'tahoma' size 010 ;
   bold ;
   FONTCOLOR _preto_001 ;
   TRANSPARENT

* botões
@ 520,250 buttonex botao_excluir_promocao ;
   PARENT form_promocao ;
   CAPTION 'Excluir promoção' ;
   WIDTH 150 height 040 ;
   PICTURE path_imagens+'img_rpromo.bmp' ;
   ACTION tira_da_promocao() ;
   TOOLTIP 'Clique aqui para retirar da promoção todos os produtos selecionados'
@ 520,405 buttonex botao_reajustar ;
   PARENT form_promocao ;
   CAPTION 'Ativar as promoções com base na projeção' ;
   WIDTH 300 height 040 ;
   PICTURE path_imagens+'img_aplicar.bmp' ;
   ACTION gravar_reajuste_2() ;
   TOOLTIP 'Clique aqui para gravar a promoção no banco de dados'
@ 520,710 buttonex botao_sair ;
   PARENT form_promocao ;
   CAPTION 'Sair desta tela' ;
   WIDTH 180 height 040 ;
   PICTURE path_imagens+'img_sair.bmp' ;
   ACTION (zera_acesso_2(),form_promocao.release) ;
   TOOLTIP 'Clique aqui para sair'

ON KEY ESCAPE ACTION thiswindow.release

END WINDOW

form_promocao.center
form_promocao.activate

RETURN NIL

STATIC FUNCTION filtrar_informacoes_2()

   LOCAL x_tipo                := form_promocao.cbo_001.value
   LOCAL x_categoria           := form_promocao.cbo_002.value
   LOCAL x_codigo_categoria    := 0
   LOCAL x_subcategoria        := form_promocao.cbo_003.value
   LOCAL x_codigo_subcategoria := 0
   LOCAL x_valor               := form_promocao.tbox_004.value
   LOCAL x_percentual          := form_promocao.tbox_005.value

   IF empty(x_valor) .and. empty(x_percentual)
      msgalert('Você precisa digitar ou valor ou percentual para simular a promoção','Atenção')

      RETURN NIL
   ENDIF

   IF x_categoria <> 1
      x_codigo_categoria := val(substr(form_promocao.cbo_002.item(x_categoria),1,6))
   ENDIF

   IF x_subcategoria <> 1
      x_codigo_subcategoria := val(substr(form_promocao.cbo_003.item(x_subcategoria),1,6))
   ENDIF

   IF _conta_acesso_2 > 0
      form_promocao.grid_promocao.release
   ENDIF

   IF x_tipo == 1 //pizzas
      _conta_acesso_2 ++
      DEFINE GRID grid_promocao
         PARENT form_promocao
         COL 220
         ROW 030
         WIDTH 665
         HEIGHT 480
         HEADERS {'.','Produto',_tamanho_001,_tamanho_002,_tamanho_003,_tamanho_004,_tamanho_005,_tamanho_006}
         WIDTHS {001,300,120,120,120,120,120,120}
         FONTNAME 'verdana'
         FONTSIZE 010
         FONTBOLD .T.
         BACKCOLOR _branco_001
         FONTCOLOR _vermelho_002
      END GRID
   ELSEIF x_tipo == 2 //demais produtos
      _conta_acesso_2 ++
      DEFINE GRID grid_promocao
         PARENT form_promocao
         COL 220
         ROW 030
         WIDTH 665
         HEIGHT 480
         HEADERS {'.','Produto','Preço reajustado R$'}
         WIDTHS {001,400,220}
         FONTNAME 'verdana'
         FONTSIZE 010
         FONTBOLD .T.
         BACKCOLOR _branco_001
         FONTCOLOR _vermelho_002
      END GRID
   ENDIF

   * limpar dbf temporário
   zera_temporario_2()

   dbselectarea('produtos')
   produtos->(dbgotop())

   * separar as informações
   WHILE .not. eof()
      IF x_tipo == 1 //pizzas
         IF produtos->pizza
            dbselectarea('tmp_reajuste')
            APPEND BLANK
            REPLACE cod_prod with produtos->codigo
            REPLACE nom_prod with produtos->nome_longo
            REPLACE tam_001 with produtos->val_tm_001
            REPLACE tam_002 with produtos->val_tm_002
            REPLACE tam_003 with produtos->val_tm_003
            REPLACE tam_004 with produtos->val_tm_004
            REPLACE tam_005 with produtos->val_tm_005
            REPLACE tam_006 with produtos->val_tm_006
            REPLACE id_cat with produtos->categoria
            REPLACE id_subcat with produtos->scategoria
         ENDIF
      ELSEIF x_tipo == 2 //demais produtos
         IF !produtos->pizza
            dbselectarea('tmp_reajuste')
            APPEND BLANK
            REPLACE cod_prod with produtos->codigo
            REPLACE nom_prod with produtos->nome_longo
            REPLACE pre_reaj with produtos->vlr_venda
            REPLACE id_cat with produtos->categoria
            REPLACE id_subcat with produtos->scategoria
         ENDIF
      ENDIF
      dbselectarea('produtos')
      produtos->(dbskip())
   END

   * indexar as informações
   dbselectarea('tmp_reajuste')
   IF x_codigo_categoria == 0 .and. x_codigo_subcategoria == 0
      INDEX ON nom_prod to indreaj
   ENDIF
   IF x_codigo_categoria <> 0 .and. x_codigo_subcategoria <> 0
      INDEX ON nom_prod to indreaj for id_cat == x_codigo_categoria .and. id_subcat == x_codigo_subcategoria
   ENDIF
   IF x_codigo_categoria <> 0 .and. x_codigo_subcategoria == 0
      INDEX ON nom_prod to indreaj for id_cat == x_codigo_categoria
   ENDIF
   IF x_codigo_categoria == 0 .and. x_codigo_subcategoria <> 0
      INDEX ON nom_prod to indreaj for id_subcat == x_codigo_subcategoria
   ENDIF
   tmp_reajuste->(dbgotop())

   * aplicar a promoção (tirando em valor ou percentual)
   WHILE .not. eof()
      IF .not. empty(x_valor)
         IF x_tipo == 1 //pizzas
            REPLACE tam_001 with tam_001 - x_valor
            REPLACE tam_002 with tam_002 - x_valor
            REPLACE tam_003 with tam_003 - x_valor
            REPLACE tam_004 with tam_004 - x_valor
            REPLACE tam_005 with tam_005 - x_valor
            REPLACE tam_006 with tam_006 - x_valor
         ELSEIF x_tipo == 2 //demais produtos
            REPLACE pre_reaj with pre_reaj - x_valor
         ENDIF
      ELSE
         IF x_tipo == 1 //pizzas
            REPLACE tam_001 with tam_001 - ((tam_001*x_percentual)/100)
            REPLACE tam_002 with tam_002 - ((tam_002*x_percentual)/100)
            REPLACE tam_003 with tam_003 - ((tam_003*x_percentual)/100)
            REPLACE tam_004 with tam_004 - ((tam_004*x_percentual)/100)
            REPLACE tam_005 with tam_005 - ((tam_005*x_percentual)/100)
            REPLACE tam_006 with tam_006 - ((tam_006*x_percentual)/100)
         ELSEIF x_tipo == 2 //demais produtos
            REPLACE pre_reaj with pre_reaj - ((pre_reaj*x_percentual)/100)
         ENDIF
      ENDIF
      tmp_reajuste->(dbskip())
   END

   * alimentar o grid
   DELETE item all from grid_promocao of form_promocao
   dbselectarea('tmp_reajuste')
   tmp_reajuste->(dbgotop())
   WHILE .not. eof()
      IF x_tipo == 1 //pizzas
         add item {tmp_reajuste->cod_prod,tmp_reajuste->nom_prod,trans(tmp_reajuste->tam_001,'@E 99,999.99'),trans(tmp_reajuste->tam_002,'@E 99,999.99'),trans(tmp_reajuste->tam_003,'@E 99,999.99'),trans(tmp_reajuste->tam_004,'@E 99,999.99'),trans(tmp_reajuste->tam_005,'@E 99,999.99'),trans(tmp_reajuste->tam_006,'@E 99,999.99')} to grid_promocao of form_promocao
      ELSEIF x_tipo == 2 //demais produtos
         add item {tmp_reajuste->cod_prod,tmp_reajuste->nom_prod,trans(tmp_reajuste->pre_reaj,'@E 999,999.99')} to grid_promocao of form_promocao
      ENDIF
      tmp_reajuste->(dbskip())
   END

   RETURN NIL

STATIC FUNCTION gravar_reajuste_2()

   LOCAL x_flag     := .F.
   LOCAL x_tipo     := form_promocao.cbo_001.value

   dbselectarea('tmp_reajuste')
   tmp_reajuste->(dbgotop())

   WHILE .not. eof()

      dbselectarea('produtos')
      produtos->(ordsetfocus('codigo'))
      produtos->(dbseek(tmp_reajuste->cod_prod))

      IF found()
         IF x_tipo == 1 //pizzas
            IF lock_reg()
               REPLACE val_tm_001 with tmp_reajuste->tam_001
               REPLACE val_tm_002 with tmp_reajuste->tam_002
               REPLACE val_tm_003 with tmp_reajuste->tam_003
               REPLACE val_tm_004 with tmp_reajuste->tam_004
               REPLACE val_tm_005 with tmp_reajuste->tam_005
               REPLACE val_tm_006 with tmp_reajuste->tam_006
               produtos->(dbcommit())
               produtos->(dbunlock())
            ELSE
               x_flag := .T.
            ENDIF
         ELSEIF x_tipo == 2 //demais produtos
            IF lock_reg()
               REPLACE vlr_venda with tmp_reajuste->pre_reaj
               produtos->(dbcommit())
               produtos->(dbunlock())
            ELSE
               x_flag := .T.
            ENDIF
         ENDIF
      ENDIF

      dbselectarea('tmp_reajuste')
      tmp_reajuste->(dbskip())

   END

   IF x_flag
      msgstop('Nem todos produtos foram reajustados, confira','Atenção')
   ELSE
      msginfo('Reajuste processado com sucesso, tecle ENTER','Mensagem')
   ENDIF

   form_promocao.release

   RETURN NIL

STATIC FUNCTION tira_da_promocao()

   dbselectarea('tmp_reajuste')
   tmp_reajuste->(dbgotop())

   WHILE .not. eof()

      dbselectarea('produtos')
      produtos->(ordsetfocus('codigo'))
      produtos->(dbseek(tmp_reajuste->cod_prod))

      IF found()
         IF lock_reg()
            REPLACE promocao with .F.
            produtos->(dbcommit())
            produtos->(dbunlock())
         ENDIF
      ENDIF

      dbselectarea('tmp_reajuste')
      tmp_reajuste->(dbskip())

   END

   msginfo('Processo completado com sucesso, tecle ENTER','Mensagem')

   form_promocao.release

   RETURN NIL

STATIC FUNCTION zera_acesso_2()

   _conta_acesso_2 := 0

   RETURN NIL

STATIC FUNCTION zera_temporario_2()

   dbselectarea('tmp_reajuste')
   ZAP
   PACK

   RETURN NIL
