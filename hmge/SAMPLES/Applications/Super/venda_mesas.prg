/*
sistema     : superchef pizzaria
programa    : venda mesas
compilador  : xharbour 1.2 simplex
lib gráfica : minigui 1.7 extended
programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'super.ch'

MEMVAR _id_consumo
MEMVAR _escape
MEMVAR x_valor_pizza
MEMVAR x_valor_prod
MEMVAR x_hora, x_old

FUNCTION venda_mesas()

   PRIVATE _id_consumo  := space(20)
   PRIVATE _escape      := .T.

   * não mostrar informações no inicio (aplicar filtro)
   dbselectarea('temp_pizzas')
   temp_pizzas->(ordsetfocus('id'))
   temp_pizzas->(dbgotop())
   ordscope(0,'abc')
   ordscope(1,'abc')
   temp_pizzas->(dbgotop())

   * não mostrar informações no inicio (aplicar filtro)
   dbselectarea('temp_produtos')
   temp_produtos->(ordsetfocus('id'))
   temp_produtos->(dbgotop())
   ordscope(0,'abc')
   ordscope(1,'abc')
   temp_produtos->(dbgotop())

   DEFINE WINDOW form_vda_mesas;
         at 000,000;
         WIDTH getdesktopwidth();
         HEIGHT getdesktopheight();
         TITLE 'Venda Mesas';
         ICON path_imagens+'icone.ico';
         modal;
         ON INIT (desabilita_consumo(),mostra_mesas())

      * mostrar texto explicando como fechar o pedido
      @ getdesktopheight()-100,000 label label_fechar_pedido;
         of form_vda_mesas;
         WIDTH getdesktopwidth();
         HEIGHT 040;
         VALUE 'F2-abrir mesa  F3-consumo  F4-fechar mesa  F8-limpar mesa  ESC-sair';
         FONT 'verdana' size 018;
         bold;
         BACKCOLOR _preto_001;
         FONTCOLOR _cinza_001;
         centeralign

      * separar a tela em 2 partes distintas
      DEFINE LABEL label_separador
         COL 400
         ROW 000
         VALUE ''
         WIDTH 002
         HEIGHT getdesktopheight()-100
         TRANSPARENT .F.
         BACKCOLOR _cinza_002
      END LABEL

      * mesas
      @ 010,010 grid grid_mesas;
         parent form_vda_mesas;
         WIDTH 380;
         HEIGHT getdesktopheight()-115;
         HEADERS {'id','id mesa','Mesa','Aberta as'};
         WIDTHS {001,001,230,130};
         FONT 'tahoma' size 010;
         bold;
         BACKCOLOR _branco_001;
         FONTCOLOR BLUE

      *-Pizzas------------------------------------------------------------------------
      * escolher código da pizza
      @ 010,410 label label_pizza;
         of form_vda_mesas;
         VALUE 'Pizza';
         autosize;
         FONT 'courier new' size 012;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 030,410 textbox tbox_pizza;
         of form_vda_mesas;
         HEIGHT 030;
         WIDTH 100;
         VALUE '';
         MAXLENGTH 015;
         FONT 'courier new' size 016;
         bold;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         ON ENTER procura_pizza()
      * mostrar nome da pizza
      @ 030,520 label label_nome_pizza;
         of form_vda_mesas;
         VALUE '';
         autosize;
         FONT 'courier new' size 016;
         bold;
         FONTCOLOR BLUE;
         TRANSPARENT
      * botão para confirmar a escolha da pizza
      @ 030,850 buttonex botao_confirmar_pizza;
         parent form_vda_mesas;
         CAPTION 'Selecionar pizza';
         WIDTH 165 height 040;
         PICTURE path_imagens+'adicionar.bmp';
         ACTION gravar_adicionar();
         TOOLTIP 'Clique aqui para confirmar a pizza selecionada'

      * mostrar pizzas já selecionadas
      @ 060,410 label label_pizza_selecionada;
         of form_vda_mesas;
         VALUE 'Pizzas selecionadas';
         autosize;
         FONT 'courier new' size 012;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 080,410 browse grid_pizzas;
         parent form_vda_mesas;
         WIDTH getdesktopwidth()-420;
         HEIGHT 200;
         HEADERS {'id produto','Seq.','Nome','Tamanho','Preço R$'};
         WIDTHS {001,100,190,180,100};
         WORKAREA temp_pizzas;
         FIELDS {'temp_pizzas->id_produto','temp_pizzas->sequencia','temp_pizzas->nome','temp_pizzas->tamanho','trans(temp_pizzas->preco,"@E 99,999.99")'};
         VALUE 1;
         FONT 'tahoma' size 010;
         bold;
         BACKCOLOR _amarelo_001;
         FONTCOLOR _preto_001
      @ 285,410 label label_observacoes;
         of form_vda_mesas;
         VALUE 'Observações para a montagem da(s) pizza(s)';
         autosize;
         FONT 'courier new' size 012;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 305,410 textbox tbox_observacoes;
         of form_vda_mesas;
         HEIGHT 030;
         WIDTH 420;
         VALUE '';
         MAXLENGTH 030;
         FONT 'courier new' size 012;
         bold;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         uppercase

      * botão para excluir ítem na escolha das pizzas
      @ 285,850 buttonex botao_excluir_pizza;
         parent form_vda_mesas;
         CAPTION 'Excluir ítem';
         WIDTH 165 height 040;
         PICTURE path_imagens+'excluir_item.bmp';
         ACTION excluir_pizza();
         notabstop;
         TOOLTIP 'Clique aqui para excluir uma pizza selecionada acima'

      * explicação de como finalizar as pizzas
      @ 340,410 label label_instrucao_001;
         of form_vda_mesas;
         VALUE 'tecle F5 após completar a composição de 1 (uma) pizza, para finalizá-la,';
         autosize;
         FONT 'verdana' size 010;
         bold;
         FONTCOLOR _cinza_001;
         TRANSPARENT
      @ 360,410 label label_instrucao_002;
         of form_vda_mesas;
         VALUE 'ou, para vender mais de 1 (uma) pizza, finalize uma para começar outra.';
         autosize;
         FONT 'verdana' size 010;
         bold;
         FONTCOLOR _cinza_001;
         TRANSPARENT

      *-Produtos----------------------------------------------------------------------
      * escolher código do produto
      @ 400,410 label label_produto;
         of form_vda_mesas;
         VALUE 'Produto';
         autosize;
         FONT 'courier new' size 012;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 420,410 textbox tbox_produto;
         of form_vda_mesas;
         HEIGHT 030;
         WIDTH 100;
         VALUE '';
         MAXLENGTH 015;
         FONT 'courier new' size 016;
         bold;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         ON ENTER procura_produto()
      @ 420,520 label label_nome_produto;
         of form_vda_mesas;
         VALUE '';
         autosize;
         FONT 'courier new' size 016;
         bold;
         FONTCOLOR BLUE;
         TRANSPARENT

      * quantidade
      @ 450,410 label label_quantidade;
         of form_vda_mesas;
         VALUE 'Quantidade';
         autosize;
         FONT 'courier new' size 012;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 470,410 textbox tbox_quantidade;
         of form_vda_mesas;
         HEIGHT 030;
         WIDTH 100;
         VALUE 0;
         FONT 'courier new' size 016;
         bold;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         numeric;
         ON ENTER verifica_zero()

      * preço
      @ 450,530 label label_preco;
         of form_vda_mesas;
         VALUE 'Preço R$';
         autosize;
         FONT 'courier new' size 012;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 470,530 getbox tbox_preco;
         of form_vda_mesas;
         HEIGHT 030;
         WIDTH 130;
         VALUE 0;
         FONT 'courier new' size 016;
         bold;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         PICTURE '@E 9,999.99'

      * botão para confirmar a escolha do produto
      @ 460,670 buttonex botao_confirmar_produto;
         parent form_vda_mesas;
         CAPTION 'Selecionar produto';
         WIDTH 165 height 040;
         PICTURE path_imagens+'adicionar.bmp';
         ACTION gravar_produto();
         TOOLTIP 'Clique aqui para confirmar o produto selecionado'

      * produtos já selecionados
      @ 510,410 browse grid_produtos;
         parent form_vda_mesas;
         WIDTH getdesktopwidth()-420;
         HEIGHT getdesktopheight()-615;
         HEADERS {'id produto','Qtd','Produto','Unitário R$','Subtotal R$'};
         WIDTHS {001,080,210,140,140};
         WORKAREA temp_produtos;
         FIELDS {'temp_produtos->produto','temp_produtos->qtd','temp_produtos->nome','trans(temp_produtos->unitario,"@E 9,999.99")','trans(temp_produtos->subtotal,"@E 99,999.99")'};
         VALUE 1;
         FONT 'tahoma' size 010;
         bold;
         BACKCOLOR _amarelo_001;
         FONTCOLOR _preto_001

      * botão para excluir produto já selecionado
      @ 460,850 buttonex botao_excluir_produto;
         parent form_vda_mesas;
         CAPTION 'Excluir produto';
         WIDTH 165 height 040;
         PICTURE path_imagens+'excluir_item.bmp';
         ACTION excluir_produto();
         notabstop;
         TOOLTIP 'Clique aqui para excluir um produto já selecionado'

      on key F2 action abrir_mesa()
      on key F3 action lancar_consumo()
      on key F4 action fecha_pedido()
      ON KEY F5 ACTION fecha_pizza()
      ON KEY F8 ACTION limpar_mesa()

      ON KEY ESCAPE ACTION fecha_janela()

   END WINDOW

   form_vda_mesas.maximize
   form_vda_mesas.activate

   RETURN NIL

STATIC FUNCTION procura_produto()

   LOCAL x_codigo := form_vda_mesas.tbox_produto.value

   IF empty(x_codigo)
      x_codigo := '9999'
   ENDIF

   dbselectarea('produtos')
   produtos->(ordsetfocus('codigo'))
   produtos->(dbgotop())
   produtos->(dbseek(x_codigo))

   IF found()
      IF produtos->pizza
         IF msgyesno('Este código não é válido. Deseja procurar na lista ?','Atenção')
            mostra_listagem_produto()

            RETURN NIL
         ELSE
            form_vda_mesas.tbox_produto.setfocus

            RETURN NIL
         ENDIF
      ELSE
         setproperty('form_vda_mesas','label_nome_produto','value',produtos->nome_longo)
         setproperty('form_vda_mesas','tbox_preco','value',produtos->vlr_venda)

         RETURN NIL
      ENDIF
   ELSE
      mostra_listagem_produto()
   ENDIF

   RETURN NIL

STATIC FUNCTION mostra_listagem_produto()

   DEFINE WINDOW form_pesquisa;
         at 000,000;
         WIDTH 560;
         HEIGHT 610;
         TITLE 'Produtos';
         ICON path_imagens+'icone.ico';
         modal;
         NOSIZE

      DEFINE GRID grid_pesquisa
         parent form_pesquisa
         COL 000
         ROW 000
         WIDTH 555
         HEIGHT 580
         HEADERS {'','Nome','Preço R$'}
         WIDTHS {001,395,150}
         SHOWHEADERS .F.
         NOLINES .T.
         FONTNAME 'courier new'
         FONTSIZE 012
         BACKCOLOR _ciano_001
         FONTCOLOR _preto_001
         ONDBLCLICK mostra_informacao_produto()
      END GRID

      ON KEY ESCAPE ACTION thiswindow.release

   END WINDOW

   separa_produto()
   form_pesquisa.grid_pesquisa.setfocus
   form_pesquisa.grid_pesquisa.value := 1

   form_pesquisa.center
   form_pesquisa.activate

   RETURN NIL

STATIC FUNCTION separa_produto()

   DELETE item all from grid_pesquisa of form_pesquisa

   dbselectarea('produtos')
   produtos->(ordsetfocus('nome_longo'))
   produtos->(dbgotop())

   WHILE .not. eof()
      IF !produtos->pizza
         add item {produtos->codigo,alltrim(produtos->nome_longo),trans(produtos->vlr_venda,'@E 999,999.99')} to grid_pesquisa of form_pesquisa
      ENDIF
      produtos->(dbskip())
   END

   RETURN NIL

STATIC FUNCTION mostra_informacao_produto()

   LOCAL x_codigo := valor_coluna('grid_pesquisa','form_pesquisa',1)
   LOCAL x_nome   := valor_coluna('grid_pesquisa','form_pesquisa',2)
   LOCAL x_preco  := 0

   setproperty('form_vda_mesas','tbox_produto','value',alltrim(x_codigo))
   setproperty('form_vda_mesas','label_nome_produto','value',alltrim(x_nome))

   dbselectarea('produtos')
   produtos->(ordsetfocus('codigo'))
   produtos->(dbgotop())
   produtos->(dbseek(x_codigo))
   IF found()
      x_preco := produtos->vlr_venda
   ENDIF
   setproperty('form_vda_mesas','tbox_preco','value',x_preco)

   form_pesquisa.release

   RETURN NIL

STATIC FUNCTION procura_pizza()

   LOCAL x_codigo := form_vda_mesas.tbox_pizza.value

   IF empty(x_codigo)
      x_codigo := '9999'
   ENDIF

   dbselectarea('produtos')
   produtos->(ordsetfocus('codigo'))
   produtos->(dbgotop())
   produtos->(dbseek(x_codigo))

   IF found()
      IF !produtos->pizza
         IF msgyesno('Este código não é de uma Pizza. Deseja procurar na lista ?','Atenção')
            mostra_listagem_pizza()

            RETURN NIL
         ELSE
            form_vda_mesas.tbox_pizza.setfocus

            RETURN NIL
         ENDIF
      ELSE
         setproperty('form_vda_mesas','label_nome_pizza','value',produtos->nome_longo)

         RETURN NIL
      ENDIF
   ELSE
      mostra_listagem_pizza()
   ENDIF

   RETURN NIL

STATIC FUNCTION mostra_listagem_pizza()

   DEFINE WINDOW form_pesquisa;
         at 000,000;
         WIDTH 410;
         HEIGHT 610;
         TITLE 'Pizzas';
         ICON path_imagens+'icone.ico';
         modal;
         NOSIZE

      DEFINE GRID grid_pesquisa
         parent form_pesquisa
         COL 000
         ROW 000
         WIDTH 405
         HEIGHT 580
         HEADERS {'','Nome'}
         WIDTHS {001,395}
         SHOWHEADERS .F.
         NOLINES .T.
         FONTNAME 'courier new'
         FONTSIZE 012
         BACKCOLOR _ciano_001
         FONTCOLOR _preto_001
         ONDBLCLICK mostra_informacao()
      END GRID

      ON KEY ESCAPE ACTION thiswindow.release

   END WINDOW

   separa_pizza()
   form_pesquisa.grid_pesquisa.setfocus
   form_pesquisa.grid_pesquisa.value := 1

   form_pesquisa.center
   form_pesquisa.activate

   RETURN NIL

STATIC FUNCTION separa_pizza()

   DELETE item all from grid_pesquisa of form_pesquisa

   dbselectarea('produtos')
   produtos->(ordsetfocus('nome_longo'))
   produtos->(dbgotop())

   WHILE .not. eof()
      IF produtos->pizza
         add item {produtos->codigo,alltrim(produtos->nome_longo)+iif(produtos->promocao,' (promoção)','')} to grid_pesquisa of form_pesquisa
      ENDIF
      produtos->(dbskip())
   END

   RETURN NIL

STATIC FUNCTION mostra_informacao()

   LOCAL x_codigo := valor_coluna('grid_pesquisa','form_pesquisa',1)
   LOCAL x_nome   := valor_coluna('grid_pesquisa','form_pesquisa',2)

   setproperty('form_vda_mesas','tbox_pizza','value',alltrim(x_codigo))
   setproperty('form_vda_mesas','label_nome_pizza','value',alltrim(x_nome))

   form_pesquisa.release

   RETURN NIL

STATIC FUNCTION gravar_adicionar()

   dbselectarea('temp_pizzas')
   temp_pizzas->(dbappend())
   temp_pizzas->id_mesa    := _id_consumo
   temp_pizzas->id_produto := form_vda_mesas.tbox_pizza.value
   temp_pizzas->nome       := form_vda_mesas.label_nome_pizza.value
   temp_pizzas->(dbcommit())

   temp_pizzas->(ordsetfocus('id'))
   temp_pizzas->(dbgotop())
   ordscope(0,_id_consumo)
   ordscope(1,_id_consumo)
   temp_pizzas->(dbgotop())

   form_vda_mesas.grid_pizzas.refresh
   form_vda_mesas.grid_pizzas.setfocus
   form_vda_mesas.grid_pizzas.value := recno()

   form_vda_mesas.tbox_pizza.value := ''
   form_vda_mesas.tbox_pizza.setfocus

   RETURN NIL

STATIC FUNCTION gravar_produto()

   dbselectarea('temp_produtos')
   temp_produtos->(dbappend())
   temp_produtos->id_mesa  := _id_consumo
   temp_produtos->produto  := form_vda_mesas.tbox_produto.value
   temp_produtos->nome     := form_vda_mesas.label_nome_produto.value
   temp_produtos->qtd      := form_vda_mesas.tbox_quantidade.value
   temp_produtos->unitario := form_vda_mesas.tbox_preco.value
   temp_produtos->subtotal := (form_vda_mesas.tbox_preco.value*form_vda_mesas.tbox_quantidade.value)
   temp_produtos->(dbcommit())

   temp_produtos->(ordsetfocus('id'))
   temp_produtos->(dbgotop())
   ordscope(0,_id_consumo)
   ordscope(1,_id_consumo)
   temp_produtos->(dbgotop())

   form_vda_mesas.grid_produtos.refresh
   form_vda_mesas.grid_produtos.setfocus
   form_vda_mesas.grid_produtos.value := recno()

   form_vda_mesas.tbox_produto.value := ''
   form_vda_mesas.tbox_produto.setfocus

   RETURN NIL

STATIC FUNCTION excluir_pizza()

   IF empty(temp_pizzas->nome)
      msgalert('Escolha o que deseja excluir primeiro','Atenção')

      RETURN NIL
   ENDIF

   IF msgyesno('Excluir : '+alltrim(temp_pizzas->nome),'Excluir')
      IF lock_reg()
         temp_pizzas->(dbdelete())
         temp_pizzas->(dbunlock())
         temp_pizzas->(dbgotop())
      ENDIF
   ENDIF

   dbselectarea('temp_pizzas')
   temp_pizzas->(ordsetfocus('id'))
   temp_pizzas->(dbgotop())
   ordscope(0,_id_consumo)
   ordscope(1,_id_consumo)
   temp_pizzas->(dbgotop())

   form_vda_mesas.grid_pizzas.refresh
   form_vda_mesas.grid_pizzas.setfocus
   form_vda_mesas.grid_pizzas.value := recno()

   RETURN NIL

STATIC FUNCTION excluir_produto()

   IF empty(temp_produtos->nome)
      msgalert('Escolha o que deseja excluir primeiro','Atenção')

      RETURN NIL
   ENDIF

   IF msgyesno('Excluir : '+alltrim(temp_produtos->nome),'Excluir')
      IF lock_reg()
         temp_produtos->(dbdelete())
         temp_produtos->(dbunlock())
         temp_produtos->(dbgotop())
      ENDIF
   ENDIF

   dbselectarea('temp_produtos')
   temp_produtos->(ordsetfocus('id'))
   temp_produtos->(dbgotop())
   ordscope(0,_id_consumo)
   ordscope(1,_id_consumo)
   temp_produtos->(dbgotop())

   form_vda_mesas.grid_produtos.refresh
   form_vda_mesas.grid_produtos.setfocus
   form_vda_mesas.grid_produtos.value := recno()

   RETURN NIL

STATIC FUNCTION fecha_pizza()

   IF _escape
      msgexclamation('Você deve estar montando uma pizza para usar a tecla F5 - leia o texto na tela para orientar-se melhor','Atenção')

      RETURN NIL
   ENDIF

   dbselectarea('temp_pizzas')
   temp_pizzas->(dbgotop())
   IF eof()
      msgexclamation('Nenhuma pizza foi selecionada ainda','Atenção')

      RETURN NIL
   ENDIF

   DEFINE WINDOW form_finaliza_pizza;
         at 000,000;
         WIDTH 1000;
         HEIGHT 400;
         TITLE 'Finalizar pizza';
         ICON path_imagens+'icone.ico';
         modal;
         NOSIZE

      @ 005,005 label lbl_001;
         of form_finaliza_pizza;
         VALUE '1- Selecione o tamanho da pizza';
         autosize;
         FONT 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 025,005 label lbl_002;
         of form_finaliza_pizza;
         VALUE '2- Você poderá escolher entre o menor e o maior preço à ser cobrado, no caso de ter mais de 1 sabor na mesma pizza';
         autosize;
         FONT 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 045,005 label lbl_003;
         of form_finaliza_pizza;
         VALUE '3- Caso deseje, ao fechamento deste pedido, poderá conceder um desconto especial ao cliente';
         autosize;
         FONT 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 065,005 label lbl_004;
         of form_finaliza_pizza;
         VALUE '4- Para finalizar esta pizza e continuar vendendo, dê duplo-clique ou enter sobre o tamanho/preço escolhido';
         autosize;
         FONT 'tahoma' size 010;
         bold;
         FONTCOLOR BLUE;
         TRANSPARENT
      @ 085,005 label lbl_005;
         of form_finaliza_pizza;
         VALUE '5- ESC fecha esta janela e retorna para a tela de vendas';
         autosize;
         FONT 'tahoma' size 010;
         bold;
         FONTCOLOR _vermelho_002;
         TRANSPARENT

      DEFINE GRID grid_finaliza_pizza
         parent form_finaliza_pizza
         COL 005
         ROW 105
         WIDTH 985
         HEIGHT 260
         HEADERS {'id','Pizza',_tamanho_001,_tamanho_002,_tamanho_003,_tamanho_004,_tamanho_005,_tamanho_006}
         WIDTHS {001,250,120,120,120,120,120,120}
         VALUE 1
         CELLED .T.
         FONTNAME 'verdana'
         FONTSIZE 010
         FONTBOLD .T.
         BACKCOLOR _cinza_005
         FONTCOLOR _preto_001
         ONDBLCLICK pega_tamanho_valor_pizza()
      END GRID

      ON KEY ESCAPE ACTION thiswindow.release

   END WINDOW

   monta_informacao_pizza()

   form_finaliza_pizza.center
   form_finaliza_pizza.activate

   RETURN NIL

STATIC FUNCTION monta_informacao_pizza()

   dbselectarea('temp_pizzas')
   temp_pizzas->(dbgotop())

   DELETE item all from grid_finaliza_pizza of form_finaliza_pizza

   WHILE .not. eof()
      dbselectarea('produtos')
      produtos->(ordsetfocus('codigo'))
      produtos->(dbgotop())
      produtos->(dbseek(temp_pizzas->id_produto))
      IF found()
         add item {produtos->codigo,alltrim(produtos->nome_longo)+iif(produtos->promocao,' (promoção)',''),trans(produtos->val_tm_001,'@E 99,999.99'),trans(produtos->val_tm_002,'@E 99,999.99'),trans(produtos->val_tm_003,'@E 99,999.99'),trans(produtos->val_tm_004,'@E 99,999.99'),trans(produtos->val_tm_005,'@E 99,999.99'),trans(produtos->val_tm_006,'@E 99,999.99')} to grid_finaliza_pizza of form_finaliza_pizza
      ENDIF
      dbselectarea('temp_pizzas')
      temp_pizzas->(dbskip())
   END

   RETURN NIL

STATIC FUNCTION pega_tamanho_valor_pizza()

   LOCAL valor_do_grid  := form_finaliza_pizza.grid_finaliza_pizza.value
   LOCAL item_valor     := form_finaliza_pizza.grid_finaliza_pizza.cell(getproperty('form_finaliza_pizza','grid_finaliza_pizza','value')[1],getproperty('form_finaliza_pizza','grid_finaliza_pizza','value')[2])
   LOCAL x_preco        := val(strtran(item_valor,','))/100
   LOCAL x_coluna       := valor_do_grid[2]
   LOCAL x_nome_tamanho := space(30)

   IF x_coluna == 1

      RETURN NIL
   ELSEIF x_coluna == 2

      RETURN NIL
   ELSEIF x_coluna == 3
      x_nome_tamanho := alltrim(_tamanho_001)+' '+alltrim(str(_pedaco_001))+'ped'
   ELSEIF x_coluna == 4
      x_nome_tamanho := alltrim(_tamanho_002)+' '+alltrim(str(_pedaco_002))+'ped'
   ELSEIF x_coluna == 5
      x_nome_tamanho := alltrim(_tamanho_003)+' '+alltrim(str(_pedaco_003))+'ped'
   ELSEIF x_coluna == 6
      x_nome_tamanho := alltrim(_tamanho_004)+' '+alltrim(str(_pedaco_004))+'ped'
   ELSEIF x_coluna == 7
      x_nome_tamanho := alltrim(_tamanho_005)+' '+alltrim(str(_pedaco_005))+'ped'
   ELSEIF x_coluna == 8
      x_nome_tamanho := alltrim(_tamanho_006)+' '+alltrim(str(_pedaco_006))+'ped'
   ENDIF

   dbselectarea('temp_pizzas')
   temp_pizzas->(dbgotop())
   WHILE .not. eof()
      IF empty(temp_pizzas->sequencia)
         IF lock_reg()
            REPLACE sequencia with 'pizza ok'
            REPLACE tamanho with x_nome_tamanho
            REPLACE preco with x_preco
            temp_pizzas->(dbcommit())
         ENDIF
      ENDIF
      temp_pizzas->(dbskip())
   END

   form_finaliza_pizza.release
   form_vda_mesas.grid_pizzas.refresh
   form_vda_mesas.grid_pizzas.setfocus
   form_vda_mesas.tbox_observacoes.setfocus

   RETURN NIL

STATIC FUNCTION verifica_zero()

   LOCAL x_qtd := form_vda_mesas.tbox_quantidade.value

   IF empty(x_qtd)
      form_vda_mesas.tbox_quantidade.setfocus

      RETURN NIL
   ENDIF

   RETURN NIL

STATIC FUNCTION fecha_pedido()

   LOCAL x_id        := valor_coluna('grid_mesas','form_vda_mesas',1)
   LOCAL x_hora      := valor_coluna('grid_mesas','form_vda_mesas',4)
   LOCAL x_nome_mesa := valor_coluna('grid_mesas','form_vda_mesas',3)
   LOCAL x_mesa      := 0

   LOCAL x_old_pizza      := space(10)
   LOCAL x_old_valor      := 0
   LOCAL x_total_pedido   := 0
   LOCAL x_total_recebido := 0

   PRIVATE x_valor_pizza  := 0
   PRIVATE x_valor_prod   := 0

   * essa informação será passada para a rotina final de fechamento
   x_mesa := val(valor_coluna('grid_mesas','form_vda_mesas',2))

   * checagens
   IF !_escape
      msgalert('Para fechar a mesa, esteja na tela ao lado e tecle F4','Atenção')

      RETURN NIL
   ENDIF
   IF empty(x_nome_mesa)
      msgalert('Escolha uma mesa primeiro','Atenção')

      RETURN NIL
   ENDIF
   IF empty(x_hora)
      msgalert('Esta mesa não está aberta, tecle F2 para abrir a mesa primeiro e F3 para digitar o consumo','Atenção')

      RETURN NIL
   ENDIF

   * associar id para filtrar as tabelas de pizza e produtos
   _id_consumo := alltrim(x_id)

   dbselectarea('temp_pizzas')
   temp_pizzas->(ordsetfocus('id'))
   temp_pizzas->(dbgotop())
   ordscope(0,_id_consumo)
   ordscope(1,_id_consumo)
   temp_pizzas->(dbgotop())
   IF eof()
      msgstop('Nenhuma pizza foi vendida','Atenção')
   ELSE
      WHILE .not. eof()
         x_old_pizza := temp_pizzas->sequencia
         x_old_valor := temp_pizzas->preco
         temp_pizzas->(dbskip())
         IF temp_pizzas->sequencia <> x_old_pizza
            x_valor_pizza := (x_valor_pizza+x_old_valor)
         ENDIF
      END
   ENDIF

   dbselectarea('temp_produtos')
   temp_produtos->(ordsetfocus('id'))
   temp_produtos->(dbgotop())
   ordscope(0,_id_consumo)
   ordscope(1,_id_consumo)
   temp_produtos->(dbgotop())
   IF eof()
      msgstop('Nenhum produto foi vendido','Atenção')
   ELSE
      WHILE .not. eof()
         x_valor_prod := (x_valor_prod+temp_produtos->subtotal)
         temp_produtos->(dbskip())
      END
   ENDIF

   DEFINE WINDOW form_fecha_pedido;
         at 000,000;
         WIDTH 500;
         HEIGHT 590;
         TITLE 'Fechamento da mesa : '+alltrim(x_nome_mesa);
         ICON path_imagens+'icone.ico';
         modal;
         NOSIZE

      * linhas para separar os elementos na tela
      DEFINE LABEL label_sep_001
         COL 000
         ROW 190
         VALUE ''
         WIDTH 500
         HEIGHT 002
         TRANSPARENT .F.
         BACKCOLOR _cinza_002
      END LABEL
      DEFINE LABEL label_sep_002
         COL 000
         ROW 390
         VALUE ''
         WIDTH 500
         HEIGHT 002
         TRANSPARENT .F.
         BACKCOLOR _cinza_002
      END LABEL
      DEFINE LABEL label_sep_003
         COL 000
         ROW 440
         VALUE ''
         WIDTH 500
         HEIGHT 002
         TRANSPARENT .F.
         BACKCOLOR _cinza_002
      END LABEL

      @ 010,020 label label_001;
         of form_fecha_pedido;
         VALUE 'SUBTOTAL PIZZAS';
         autosize;
         FONT 'verdana' size 012;
         bold;
         FONTCOLOR BLUE;
         TRANSPARENT
      @ 010,250 label label_001_valor;
         of form_fecha_pedido;
         VALUE trans(x_valor_pizza,'@E 999,999.99');
         autosize;
         FONT 'courier new' size 016;
         bold;
         FONTCOLOR BLUE;
         TRANSPARENT
      @ 040,020 label label_002;
         of form_fecha_pedido;
         VALUE 'SUBTOTAL PRODUTOS';
         autosize;
         FONT 'verdana' size 012;
         bold;
         FONTCOLOR BLUE;
         TRANSPARENT
      @ 040,250 label label_002_valor;
         of form_fecha_pedido;
         VALUE trans(x_valor_prod,'@E 999,999.99');
         autosize;
         FONT 'courier new' size 016;
         bold;
         FONTCOLOR BLUE;
         TRANSPARENT
      @ 070,020 label label_003;
         of form_fecha_pedido;
         VALUE 'TAXA DE ENTREGA';
         autosize;
         FONT 'verdana' size 012;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 070,250 getbox tbox_taxa;
         of form_fecha_pedido;
         HEIGHT 030;
         WIDTH 130;
         VALUE 0;
         FONT 'courier new' size 016;
         bold;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         PICTURE '@E 9,999.99'
      @ 110,020 label label_004;
         of form_fecha_pedido;
         VALUE 'DESCONTO';
         autosize;
         FONT 'verdana' size 012;
         bold;
         FONTCOLOR _vermelho_002;
         TRANSPARENT
      @ 110,250 getbox tbox_desconto;
         of form_fecha_pedido;
         HEIGHT 030;
         WIDTH 130;
         VALUE 0;
         FONT 'courier new' size 016;
         bold;
         BACKCOLOR _fundo_get;
         FONTCOLOR _vermelho_002;
         PICTURE '@E 9,999.99';
         ON CHANGE setproperty('form_fecha_pedido','label_005_valor','value',trans((x_valor_pizza+x_valor_prod+form_fecha_pedido.tbox_taxa.value)-form_fecha_pedido.tbox_desconto.value,'@E 999,999.99'));
         ON LOSTFOCUS setproperty('form_fecha_pedido','label_005_valor','value',trans((x_valor_pizza+x_valor_prod+form_fecha_pedido.tbox_taxa.value)-form_fecha_pedido.tbox_desconto.value,'@E 999,999.99'))
      @ 150,020 label label_005;
         of form_fecha_pedido;
         VALUE 'TOTAL DESTA MESA';
         autosize;
         FONT 'verdana' size 012;
         bold;
         FONTCOLOR BLUE;
         TRANSPARENT
      @ 150,250 label label_005_valor;
         of form_fecha_pedido;
         VALUE '';
         autosize;
         FONT 'courier new' size 016;
         bold;
         FONTCOLOR BLUE;
         TRANSPARENT

      * escolher formas de recebimento
      @ 200,020 label label_006;
         of form_fecha_pedido;
         VALUE 'Você pode escolher até 3 formas de recebimento';
         autosize;
         FONT 'verdana' size 012;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      * formas de recebimento
      * 1º
      @ 230,020 combobox combo_1;
         itemsource formas_recebimento->nome;
         valuesource formas_recebimento->codigo;
         VALUE 1;
         WIDTH 250;
         FONT 'courier new' size 010
      @ 230,300 getbox tbox_fr001;
         of form_fecha_pedido;
         HEIGHT 030;
         WIDTH 130;
         VALUE 0;
         FONT 'courier new' size 014;
         bold;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         PICTURE '@E 99,999.99'
      * 2º
      @ 270,020 combobox combo_2;
         itemsource formas_recebimento->nome;
         valuesource formas_recebimento->codigo;
         VALUE 1;
         WIDTH 250;
         FONT 'courier new' size 010
      @ 270,300 getbox tbox_fr002;
         of form_fecha_pedido;
         HEIGHT 030;
         WIDTH 130;
         VALUE 0;
         FONT 'courier new' size 014;
         bold;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         PICTURE '@E 99,999.99'
      * 3º
      @ 310,020 combobox combo_3;
         itemsource formas_recebimento->nome;
         valuesource formas_recebimento->codigo;
         VALUE 1;
         WIDTH 250;
         FONT 'courier new' size 010
      @ 310,300 getbox tbox_fr003;
         of form_fecha_pedido;
         HEIGHT 030;
         WIDTH 130;
         VALUE 0;
         FONT 'courier new' size 014;
         bold;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         PICTURE '@E 99,999.99';
         ON LOSTFOCUS calcula_final()

      @ 360,020 label label_011;
         of form_fecha_pedido;
         VALUE 'TOTAL RECEBIDO';
         autosize;
         FONT 'verdana' size 012;
         bold;
         FONTCOLOR BLUE;
         TRANSPARENT
      @ 360,250 label label_011_valor;
         of form_fecha_pedido;
         VALUE '';
         autosize;
         FONT 'courier new' size 016;
         bold;
         FONTCOLOR BLUE;
         TRANSPARENT

      @ 400,020 label label_012;
         of form_fecha_pedido;
         VALUE 'TROCO';
         autosize;
         FONT 'verdana' size 012;
         bold;
         FONTCOLOR _vermelho_002;
         TRANSPARENT
      @ 400,250 label label_012_valor;
         of form_fecha_pedido;
         VALUE '';
         autosize;
         FONT 'courier new' size 016;
         bold;
         FONTCOLOR BLUE;
         TRANSPARENT

      * selecionar atendente/garçon
      @ 450,020 label label_013;
         of form_fecha_pedido;
         VALUE 'atendente/garçon';
         autosize;
         FONT 'verdana' size 012;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 470,020 combobox combo_motoboy;
         itemsource atendentes->nome;
         valuesource atendentes->codigo;
         VALUE 1;
         WIDTH 250;
         FONT 'courier new' size 010

      * botões
      @ 510,115 buttonex botao_ok;
         parent form_fecha_pedido;
         CAPTION 'Fechar mesa';
         WIDTH 150 height 040;
         PICTURE path_imagens+'img_pedido.bmp';
         ACTION fechamento_geral(x_mesa);
         TOOLTIP 'Clique aqui para finalizar a mesa'
      @ 510,270 buttonex botao_voltar;
         parent form_fecha_pedido;
         CAPTION 'Voltar para tela anterior';
         WIDTH 220 height 040;
         PICTURE path_imagens+'img_sair.bmp';
         ACTION form_fecha_pedido.release;
         TOOLTIP 'Clique aqui para voltar a vender'

      ON KEY ESCAPE ACTION thiswindow.release

   END WINDOW

   form_fecha_pedido.tbox_taxa.enabled := .F.

   form_fecha_pedido.center
   form_fecha_pedido.activate

   RETURN NIL

STATIC FUNCTION calcula_final()

   LOCAL x_val_001  := 0
   LOCAL x_val_002  := 0
   LOCAL x_val_003  := 0
   LOCAL x_val_004  := 0
   LOCAL x_val_005  := 0
   LOCAL x_val_006  := 0
   LOCAL x_val_007  := 0
   LOCAL x_total    := 0
   LOCAL x_recebido := 0
   LOCAL x_troco    := 0

   x_val_001 := x_valor_pizza
   x_val_002 := x_valor_prod
   x_val_003 := form_fecha_pedido.tbox_taxa.value
   x_val_004 := form_fecha_pedido.tbox_desconto.value
   x_val_005 := form_fecha_pedido.tbox_fr001.value
   x_val_006 := form_fecha_pedido.tbox_fr002.value
   x_val_007 := form_fecha_pedido.tbox_fr003.value

   x_total    := (x_val_001+x_val_002+x_val_003)-(x_val_004)
   x_recebido := (x_val_005+x_val_006+x_val_007)
   x_troco    := (x_recebido-x_total)

   setproperty('form_fecha_pedido','label_011_valor','value',trans(x_recebido,'@E 999,999.99'))
   setproperty('form_fecha_pedido','label_012_valor','value',trans(x_troco,'@E 999,999.99'))

   RETURN NIL

STATIC FUNCTION fechamento_geral(parametro)

   LOCAL x_percentual
   LOCAL x_comissao
   LOCAL x_codigo

   LOCAL x_val_001  := 0
   LOCAL x_val_002  := 0
   LOCAL x_val_003  := 0
   LOCAL x_val_004  := 0
   LOCAL x_val_005  := 0
   LOCAL x_val_006  := 0
   LOCAL x_val_007  := 0
   LOCAL x_total    := 0
   LOCAL x_recebido := 0
   LOCAL x_cod_forma_1 := 0
   LOCAL x_cod_forma_2 := 0
   LOCAL x_cod_forma_3 := 0
   LOCAL x_dias := 0

   x_val_001     := x_valor_pizza
   x_val_002     := x_valor_prod
   x_val_003     := form_fecha_pedido.tbox_taxa.value
   x_val_004     := form_fecha_pedido.tbox_desconto.value
   x_cod_forma_1 := form_fecha_pedido.combo_1.value
   x_cod_forma_2 := form_fecha_pedido.combo_2.value
   x_cod_forma_3 := form_fecha_pedido.combo_3.value
   x_val_005     := form_fecha_pedido.tbox_fr001.value
   x_val_006     := form_fecha_pedido.tbox_fr002.value
   x_val_007     := form_fecha_pedido.tbox_fr003.value

   x_total    := (x_val_001+x_val_002+x_val_003)-(x_val_004)
   x_recebido := (x_val_005+x_val_006+x_val_007)

   * formas de recebimento
   * 1
   IF .not. empty(x_val_005)
      dbselectarea('formas_recebimento')
      formas_recebimento->(ordsetfocus('codigo'))
      formas_recebimento->(dbgotop())
      formas_recebimento->(dbseek(x_cod_forma_1))
      IF found()
         x_dias := formas_recebimento->dias_receb
      ENDIF
      dbselectarea('contas_receber')
      contas_receber->(dbappend())
      contas_receber->id      := substr(alltrim(str(HB_RANDOM(0001240003,9999999999))),1,10)
      contas_receber->data    := date() + x_dias
      contas_receber->valor   := x_val_005
      contas_receber->forma   := x_cod_forma_1
      contas_receber->cliente := 999999
      contas_receber->(dbcommit())
   ENDIF
   * 2
   IF .not. empty(x_val_006)
      dbselectarea('formas_recebimento')
      formas_recebimento->(ordsetfocus('codigo'))
      formas_recebimento->(dbgotop())
      formas_recebimento->(dbseek(x_cod_forma_2))
      IF found()
         x_dias := formas_recebimento->dias_receb
      ENDIF
      dbselectarea('contas_receber')
      contas_receber->(dbappend())
      contas_receber->id      := substr(alltrim(str(HB_RANDOM(0001240003,9999999999))),1,10)
      contas_receber->data    := date() + x_dias
      contas_receber->valor   := x_val_006
      contas_receber->forma   := x_cod_forma_2
      contas_receber->cliente := 999999
      contas_receber->(dbcommit())
   ENDIF
   * 3
   IF .not. empty(x_val_007)
      dbselectarea('formas_recebimento')
      formas_recebimento->(ordsetfocus('codigo'))
      formas_recebimento->(dbgotop())
      formas_recebimento->(dbseek(x_cod_forma_3))
      IF found()
         x_dias := formas_recebimento->dias_receb
      ENDIF
      dbselectarea('contas_receber')
      contas_receber->(dbappend())
      contas_receber->id      := substr(alltrim(str(HB_RANDOM(0001240003,9999999999))),1,10)
      contas_receber->data    := date() + x_dias
      contas_receber->valor   := x_val_007
      contas_receber->forma   := x_cod_forma_3
      contas_receber->cliente := 999999
      contas_receber->(dbcommit())
   ENDIF

   * caixa

   dbselectarea('caixa')
   caixa->(dbappend())
   caixa->id        := substr(alltrim(str(HB_RANDOM(0010023003,9999999999))),1,10)
   caixa->data      := date()
   caixa->historico := 'Venda Mesa'
   caixa->entrada   := x_recebido
   caixa->saida     := 0
   caixa->(dbcommit())

   * comissão atendente/garçon

   x_percentual := 0
   x_comissao   := 0
   x_codigo     := 0
   x_codigo     := form_fecha_pedido.combo_motoboy.value
   dbselectarea('atendentes')
   atendentes->(ordsetfocus('codigo'))
   atendentes->(dbgotop())
   atendentes->(dbseek(x_codigo))
   IF found()
      x_percentual := atendentes->comissao
   ENDIF
   IF x_percentual <> 0
      x_comissao := (x_total*x_percentual)/100
   ENDIF
   dbselectarea('comissao_mesa')
   comissao_mesa->(dbappend())
   comissao_mesa->id    := form_fecha_pedido.combo_motoboy.value
   comissao_mesa->data  := date()
   comissao_mesa->hora  := time()
   comissao_mesa->valor := x_comissao
   comissao_mesa->(dbcommit())

   * baixar os produtos

   dbselectarea('temp_produtos')
   temp_produtos->(ordsetfocus('id'))
   temp_produtos->(dbgotop())
   ordscope(0,_id_consumo)
   ordscope(1,_id_consumo)
   temp_produtos->(dbgotop())

   WHILE .not. eof()
      dbselectarea('produtos')
      produtos->(ordsetfocus('codigo'))
      produtos->(dbgotop())
      produtos->(dbseek(temp_produtos->produto))
      IF found()
         IF lock_reg()
            produtos->qtd_estoq := produtos->qtd_estoq - temp_produtos->qtd
            produtos->(dbcommit())
         ENDIF
      ENDIF
      dbselectarea('temp_produtos')
      temp_produtos->(dbskip())
   END

   * baixar matéria prima

   x_old := space(10)

   dbselectarea('temp_pizzas')
   temp_pizzas->(ordsetfocus('id'))
   temp_pizzas->(dbgotop())
   ordscope(0,_id_consumo)
   ordscope(1,_id_consumo)
   temp_pizzas->(dbgotop())

   WHILE .not. eof()
      dbselectarea('produto_composto')
      produto_composto->(ordsetfocus('id_produto'))
      produto_composto->(dbgotop())
      produto_composto->(dbseek(temp_pizzas->id_produto))
      IF found()
         WHILE .T.
            x_old := produto_composto->id_produto
            dbselectarea('materia_prima')
            materia_prima->(ordsetfocus('codigo'))
            materia_prima->(dbgotop())
            materia_prima->(dbseek(produto_composto->id_mprima))
            IF found()
               IF lock_reg()
                  materia_prima->qtd := materia_prima->qtd - produto_composto->quantidade
                  materia_prima->(dbcommit())
                  materia_prima->(dbunlock())
               ENDIF
            ENDIF
            dbselectarea('produto_composto')
            produto_composto->(dbskip())
            IF produto_composto->id_produto <> x_old
               EXIT
            ENDIF
         END
      ENDIF
      dbselectarea('temp_pizzas')
      temp_pizzas->(dbskip())
   END

   * ultimas compras do cliente

   x_hora := space(08)
   x_hora := time()

   dbselectarea('ultimas_compras')
   ultimas_compras->(dbappend())
   ultimas_compras->id_cliente := 999999
   ultimas_compras->data       := date()
   ultimas_compras->hora       := x_hora
   ultimas_compras->onde       := 2 //1=delivery 2=mesa 3=balcão
   ultimas_compras->valor      := x_total
   ultimas_compras->(dbcommit())

   * detalhamento - ultimas compras do cliente

   dbselectarea('temp_produtos')
   temp_produtos->(dbgotop())
   WHILE .not. eof()
      dbselectarea('detalhamento_compras')
      detalhamento_compras->(dbappend())
      detalhamento_compras->id_cliente := 999999
      detalhamento_compras->data       := date()
      detalhamento_compras->hora       := x_hora
      detalhamento_compras->id_prod    := temp_produtos->produto
      detalhamento_compras->qtd        := temp_produtos->qtd
      detalhamento_compras->unitario   := temp_produtos->unitario
      detalhamento_compras->subtotal   := temp_produtos->subtotal
      detalhamento_compras->(dbcommit())
      dbselectarea('temp_produtos')
      temp_produtos->(dbskip())
   END
   dbselectarea('temp_pizzas')
   temp_pizzas->(dbgotop())
   WHILE .not. eof()
      dbselectarea('detalhamento_compras')
      detalhamento_compras->(dbappend())
      detalhamento_compras->id_cliente := 999999
      detalhamento_compras->data       := date()
      detalhamento_compras->hora       := x_hora
      detalhamento_compras->id_prod    := temp_pizzas->id_produto
      detalhamento_compras->subtotal   := temp_pizzas->preco
      detalhamento_compras->(dbcommit())
      dbselectarea('temp_pizzas')
      temp_pizzas->(dbskip())
   END

   * fechar a janela do fechamento

   form_fecha_pedido.release

   * liberar a mesa que acabou de ser fechada

   dbselectarea('mesas')
   mesas->(ordsetfocus('codigo'))
   mesas->(dbgotop())
   mesas->(dbseek(parametro))
   IF found()
      IF lock_reg()
         mesas->hora := ''
         mesas->id   := ''
         mesas->(dbcommit())
         mesas->(dbunlock())
      ENDIF
   ENDIF

   limpar_mesa()

   RETURN NIL

STATIC FUNCTION mostra_mesas()

   DELETE item all from grid_mesas of form_vda_mesas

   dbselectarea('mesas')
   mesas->(ordsetfocus('codigo'))
   mesas->(dbgotop())

   WHILE .not. eof()
      add item {alltrim(mesas->id),str(mesas->codigo,4),alltrim(mesas->nome),alltrim(mesas->hora)} to grid_mesas of form_vda_mesas
      mesas->(dbskip())
   END

   RETURN NIL

STATIC FUNCTION abrir_mesa()

   LOCAL x_nome_mesa := valor_coluna('grid_mesas','form_vda_mesas',3)
   LOCAL x_id        := valor_coluna('grid_mesas','form_vda_mesas',1)
   LOCAL x_id_mesa   := valor_coluna('grid_mesas','form_vda_mesas',2)
   LOCAL x_dia       := substr(dtoc(date()),1,2)
   LOCAL x_mes       := substr(dtoc(date()),4,2)
   LOCAL x_ano       := substr(dtoc(date()),7,4)
   LOCAL x_hora      := substr(time(),1,2)
   LOCAL x_minuto    := substr(time(),4,2)
   LOCAL x_segundo   := substr(time(),7,2)
   LOCAL x_gera_id   := alltrim(x_id_mesa)+x_dia+x_mes+x_ano+x_hora+x_minuto+x_segundo
   LOCAL x_mesa      := 0

   IF empty(x_nome_mesa)
      msgalert('Escolha uma mesa primeiro','Atenção')

      RETURN NIL
   ENDIF

   IF .not. empty(x_id)
      msgalert('Mesa já está aberta','Atenção')

      RETURN NIL
   ENDIF

   x_mesa := val(valor_coluna('grid_mesas','form_vda_mesas',2))

   IF msgyesno('Abrir a mesa : '+alltrim(x_nome_mesa),'Atenção')
      dbselectarea('mesas')
      mesas->(ordsetfocus('codigo'))
      mesas->(dbgotop())
      mesas->(dbseek(x_mesa))
      IF found()
         IF lock_reg()
            mesas->hora := time()
            mesas->id   := x_gera_id
            mesas->(dbcommit())
            mesas->(dbunlock())
         ENDIF
      ENDIF
   ENDIF

   mostra_mesas()

   RETURN NIL

STATIC FUNCTION limpar_mesa()

   LOCAL x_nome_mesa := valor_coluna('grid_mesas','form_vda_mesas',3)
   LOCAL x_id        := valor_coluna('grid_mesas','form_vda_mesas',1)
   LOCAL x_id_mesa   := valor_coluna('grid_mesas','form_vda_mesas',2)
   LOCAL x_mesa      := 0

   IF empty(x_nome_mesa)
      msgalert('Escolha uma mesa primeiro','Atenção')

      RETURN NIL
   ENDIF

   x_mesa := val(valor_coluna('grid_mesas','form_vda_mesas',2))

   IF msgyesno('Só utilize esta opção caso tenha aberto a mesa por engano','Atenção')
      dbselectarea('mesas')
      mesas->(ordsetfocus('codigo'))
      mesas->(dbgotop())
      mesas->(dbseek(x_mesa))
      IF found()
         IF lock_reg()
            mesas->hora := ''
            mesas->id   := ''
            mesas->(dbcommit())
            mesas->(dbunlock())
         ENDIF
      ENDIF
   ENDIF

   mostra_mesas()

   RETURN NIL

STATIC FUNCTION lancar_consumo()

   habilita_consumo()

   RETURN NIL

STATIC FUNCTION desabilita_consumo()

   form_vda_mesas.tbox_pizza.enabled := .F.
   form_vda_mesas.botao_confirmar_pizza.enabled := .F.
   form_vda_mesas.grid_pizzas.enabled := .F.
   form_vda_mesas.tbox_observacoes.enabled := .F.
   form_vda_mesas.botao_excluir_pizza.enabled := .F.
   form_vda_mesas.tbox_produto.enabled := .F.
   form_vda_mesas.tbox_quantidade.enabled := .F.
   form_vda_mesas.tbox_preco.enabled := .F.
   form_vda_mesas.botao_confirmar_produto.enabled := .F.
   form_vda_mesas.botao_excluir_produto.enabled := .F.
   form_vda_mesas.grid_produtos.enabled := .F.
   form_vda_mesas.label_nome_pizza.enabled := .F.
   form_vda_mesas.label_nome_produto.enabled := .F.

   RETURN NIL

STATIC FUNCTION habilita_consumo()

   LOCAL x_hora      := valor_coluna('grid_mesas','form_vda_mesas',4)
   LOCAL x_nome_mesa := valor_coluna('grid_mesas','form_vda_mesas',3)
   LOCAL x_id        := valor_coluna('grid_mesas','form_vda_mesas',1)

   IF empty(x_nome_mesa)
      msgalert('Escolha uma mesa primeiro','Atenção')

      RETURN NIL
   ENDIF

   IF empty(x_hora)
      msgalert('Esta mesa não está aberta, tecle F2 para abrir a mesa primeiro','Atenção')

      RETURN NIL
   ENDIF

   _id_consumo := alltrim(x_id)

   form_vda_mesas.tbox_pizza.enabled := .T.
   form_vda_mesas.botao_confirmar_pizza.enabled := .T.
   form_vda_mesas.grid_pizzas.enabled := .T.
   form_vda_mesas.tbox_observacoes.enabled := .T.
   form_vda_mesas.botao_excluir_pizza.enabled := .T.
   form_vda_mesas.tbox_produto.enabled := .T.
   form_vda_mesas.tbox_quantidade.enabled := .T.
   form_vda_mesas.tbox_preco.enabled := .T.
   form_vda_mesas.botao_confirmar_produto.enabled := .T.
   form_vda_mesas.botao_excluir_produto.enabled := .T.
   form_vda_mesas.grid_produtos.enabled := .T.
   form_vda_mesas.label_nome_pizza.enabled := .T.
   form_vda_mesas.label_nome_produto.enabled := .T.

   form_vda_mesas.grid_mesas.enabled := .F.

   * mostrar as pizzas
   dbselectarea('temp_pizzas')
   temp_pizzas->(ordsetfocus('id'))
   temp_pizzas->(dbgotop())
   ordscope(0,_id_consumo)
   ordscope(1,_id_consumo)
   temp_pizzas->(dbgotop())
   form_vda_mesas.grid_pizzas.refresh
   form_vda_mesas.grid_pizzas.setfocus
   form_vda_mesas.grid_pizzas.value := recno()

   * mostrar os produtos
   dbselectarea('temp_produtos')
   temp_produtos->(ordsetfocus('id'))
   temp_produtos->(dbgotop())
   ordscope(0,_id_consumo)
   ordscope(1,_id_consumo)
   temp_produtos->(dbgotop())
   form_vda_mesas.grid_produtos.refresh
   form_vda_mesas.grid_produtos.setfocus
   form_vda_mesas.grid_produtos.value := recno()

   form_vda_mesas.tbox_pizza.setfocus

   _escape := .F.

   RETURN NIL

STATIC FUNCTION fecha_janela()

   IF _escape
      form_vda_mesas.release
   ELSE
      desabilita_consumo()
      form_vda_mesas.grid_mesas.enabled := .T.
      _escape := .T.
   ENDIF

   RETURN NIL
