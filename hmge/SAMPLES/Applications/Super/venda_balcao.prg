/*
sistema     : superchef pizzaria
programa    : venda balcão
compilador  : xharbour 1.2 simplex
lib gráfica : minigui 1.7 extended
programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'super.ch'

MEMVAR _conta_pizza
MEMVAR x_valor_pizza
MEMVAR x_valor_prod
MEMVAR x_hora, x_old

FUNCTION venda_balcao()

   PRIVATE _conta_pizza := 1

   DEFINE WINDOW form_balcao;
         at 000,000;
         WIDTH getdesktopwidth();
         HEIGHT getdesktopheight();
         TITLE 'Venda Balcão';
         ICON path_imagens+'icone.ico';
         modal;
         ON INIT zera_tabelas()

      * mostrar texto explicando como fechar o pedido
      @ getdesktopheight()-100,000 label label_fechar_pedido;
         of form_balcao;
         WIDTH getdesktopwidth();
         HEIGHT 040;
         VALUE 'F9-fechar este pedido  ESC-sair';
         font 'verdana' size 022;
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
         transparent .F.
         BACKCOLOR _cinza_002
      END LABEL

      * digitar o telefone
      @ 010,010 label label_telefone;
         of form_balcao;
         VALUE 'Telefone';
         autosize;
         font 'courier new' size 012;
         bold;
         FONTCOLOR _preto_001;
         transparent
      @ 030,010 textbox tbox_telefone;
         of form_balcao;
         HEIGHT 030;
         WIDTH 150;
         VALUE '';
         MAXLENGTH 015;
         font 'courier new' size 016;
         bold;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         ON ENTER procura_cliente('form_balcao','tbox_telefone')

      * botão para cadastrar cliente caso não exista
      @ 020,170 buttonex botao_cadastrar_cliente;
         parent form_balcao;
         CAPTION 'Cadastrar novo cliente';
         WIDTH 220 height 040;
         PICTURE path_imagens+'cadastrar_cliente.bmp';
         ACTION cadastrar_novo_cliente();
         notabstop;
         TOOLTIP 'Clique aqui para cadastrar um cliente novo, sem precisar sair desta tela'

      * mostrar nome do cliente
      @ 070,010 label label_nome_cliente;
         of form_balcao;
         VALUE '';
         autosize;
         font 'courier new' size 016;
         bold;
         FONTCOLOR BLUE;
         transparent

      * mostrar o endereço
      @ 100,010 label label_endereco_001;
         of form_balcao;
         VALUE '';
         autosize;
         font 'courier new' size 014;
         bold;
         FONTCOLOR _preto_001;
         transparent
      @ 120,010 label label_endereco_002;
         of form_balcao;
         VALUE '';
         autosize;
         font 'courier new' size 014;
         bold;
         FONTCOLOR _preto_001;
         transparent
      @ 140,010 label label_endereco_003;
         of form_balcao;
         VALUE '';
         autosize;
         font 'courier new' size 014;
         bold;
         FONTCOLOR _preto_001;
         transparent

      * histórico do cliente
      @ 180,010 grid grid_historico;
         parent form_balcao;
         WIDTH 380;
         HEIGHT 200;
         HEADERS {'id cliente','Onde','Data','Hora','Valor R$'};
         WIDTHS {001,100,100,075,090};
         font 'tahoma' size 010;
         bold;
         BACKCOLOR _branco_001;
         FONTCOLOR BLUE;
         ON CHANGE mostra_detalhamento_2()
      @ 390,010 grid grid_detalhamento;
         parent form_balcao;
         WIDTH 380;
         HEIGHT (getdesktopheight()-390)-105;
         HEADERS {'Qtd.','Produto','Valor R$'};
         WIDTHS {080,190,100};
         font 'tahoma' size 010;
         bold;
         BACKCOLOR _branco_001;
         FONTCOLOR BLUE

      *-Pizzas------------------------------------------------------------------------
      * escolher código da pizza
      @ 010,410 label label_pizza;
         of form_balcao;
         VALUE 'Pizza';
         autosize;
         font 'courier new' size 012;
         bold;
         FONTCOLOR _preto_001;
         transparent
      @ 030,410 textbox tbox_pizza;
         of form_balcao;
         HEIGHT 030;
         WIDTH 100;
         VALUE '';
         MAXLENGTH 015;
         font 'courier new' size 016;
         bold;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         ON ENTER procura_pizza()
      * mostrar nome da pizza
      @ 030,520 label label_nome_pizza;
         of form_balcao;
         VALUE '';
         autosize;
         font 'courier new' size 016;
         bold;
         FONTCOLOR BLUE;
         transparent
      * botão para confirmar a escolha da pizza
      @ 030,850 buttonex botao_confirmar_pizza;
         parent form_balcao;
         CAPTION 'Selecionar pizza';
         WIDTH 165 height 040;
         PICTURE path_imagens+'adicionar.bmp';
         ACTION gravar_adicionar();
         TOOLTIP 'Clique aqui para confirmar a pizza selecionada'

      * mostrar pizzas já selecionadas
      @ 060,410 label label_pizza_selecionada;
         of form_balcao;
         VALUE 'Pizzas selecionadas';
         autosize;
         font 'courier new' size 012;
         bold;
         FONTCOLOR _preto_001;
         transparent
      @ 080,410 browse grid_pizzas;
         parent form_balcao;
         WIDTH getdesktopwidth()-420;
         HEIGHT 200;
         HEADERS {'id produto','Seq.','Nome','Tamanho','Preço R$'};
         WIDTHS {001,100,190,180,100};
         WORKAREA tmp_pizza;
         FIELDS {'tmp_pizza->id_produto','tmp_pizza->sequencia','tmp_pizza->nome','tmp_pizza->tamanho','trans(tmp_pizza->preco,"@E 99,999.99")'};
         VALUE 1;
         font 'tahoma' size 010;
         bold;
         BACKCOLOR _amarelo_001;
         FONTCOLOR _preto_001
      @ 285,410 label label_observacoes;
         of form_balcao;
         VALUE 'Observações para a montagem da(s) pizza(s)';
         autosize;
         font 'courier new' size 012;
         bold;
         FONTCOLOR _preto_001;
         transparent
      @ 305,410 textbox tbox_observacoes;
         of form_balcao;
         HEIGHT 030;
         WIDTH 420;
         VALUE '';
         MAXLENGTH 030;
         font 'courier new' size 012;
         bold;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         uppercase

      * botão para excluir ítem na escolha das pizzas
      @ 285,850 buttonex botao_excluir_pizza;
         parent form_balcao;
         CAPTION 'Excluir ítem';
         WIDTH 165 height 040;
         PICTURE path_imagens+'excluir_item.bmp';
         ACTION excluir_pizza();
         notabstop;
         TOOLTIP 'Clique aqui para excluir uma pizza selecionada acima'

      * explicação de como finalizar as pizzas
      @ 340,410 label label_instrucao_001;
         of form_balcao;
         VALUE 'tecle F5 após completar a composição de 1 (uma) pizza, para finalizá-la,';
         autosize;
         font 'verdana' size 010;
         bold;
         FONTCOLOR _cinza_001;
         transparent
      @ 360,410 label label_instrucao_002;
         of form_balcao;
         VALUE 'ou, para vender mais de 1 (uma) pizza, finalize uma para começar outra.';
         autosize;
         font 'verdana' size 010;
         bold;
         FONTCOLOR _cinza_001;
         transparent

      *-Produtos----------------------------------------------------------------------
      * escolher código do produto
      @ 400,410 label label_produto;
         of form_balcao;
         VALUE 'Produto';
         autosize;
         font 'courier new' size 012;
         bold;
         FONTCOLOR _preto_001;
         transparent
      @ 420,410 textbox tbox_produto;
         of form_balcao;
         HEIGHT 030;
         WIDTH 100;
         VALUE '';
         MAXLENGTH 015;
         font 'courier new' size 016;
         bold;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         ON ENTER procura_produto()
      @ 420,520 label label_nome_produto;
         of form_balcao;
         VALUE '';
         autosize;
         font 'courier new' size 016;
         bold;
         FONTCOLOR BLUE;
         transparent

      * quantidade
      @ 450,410 label label_quantidade;
         of form_balcao;
         VALUE 'Quantidade';
         autosize;
         font 'courier new' size 012;
         bold;
         FONTCOLOR _preto_001;
         transparent
      @ 470,410 textbox tbox_quantidade;
         of form_balcao;
         HEIGHT 030;
         WIDTH 100;
         VALUE 0;
         font 'courier new' size 016;
         bold;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         numeric;
         ON ENTER verifica_zero()

      * preço
      @ 450,530 label label_preco;
         of form_balcao;
         VALUE 'Preço R$';
         autosize;
         font 'courier new' size 012;
         bold;
         FONTCOLOR _preto_001;
         transparent
      @ 470,530 getbox tbox_preco;
         of form_balcao;
         HEIGHT 030;
         WIDTH 130;
         VALUE 0;
         font 'courier new' size 016;
         bold;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         PICTURE '@E 9,999.99'

      * botão para confirmar a escolha do produto
      @ 460,670 buttonex botao_confirmar_produto;
         parent form_balcao;
         CAPTION 'Selecionar produto';
         WIDTH 165 height 040;
         PICTURE path_imagens+'adicionar.bmp';
         ACTION gravar_produto();
         TOOLTIP 'Clique aqui para confirmar o produto selecionado'

      * produtos já selecionados
      @ 510,410 browse grid_produtos;
         parent form_balcao;
         WIDTH getdesktopwidth()-420;
         HEIGHT getdesktopheight()-615;
         HEADERS {'id produto','Qtd','Produto','Unitário R$','Subtotal R$'};
         WIDTHS {001,080,210,140,140};
         WORKAREA tmp_produto;
         FIELDS {'tmp_produto->produto','tmp_produto->qtd','tmp_produto->nome','trans(tmp_produto->unitario,"@E 9,999.99")','trans(tmp_produto->subtotal,"@E 99,999.99")'};
         VALUE 1;
         font 'tahoma' size 010;
         bold;
         BACKCOLOR _amarelo_001;
         FONTCOLOR _preto_001

      * botão para excluir produto já selecionado
      @ 460,850 buttonex botao_excluir_produto;
         parent form_balcao;
         CAPTION 'Excluir produto';
         WIDTH 165 height 040;
         PICTURE path_imagens+'excluir_item.bmp';
         ACTION excluir_produto();
         notabstop;
         TOOLTIP 'Clique aqui para excluir um produto já selecionado'

      ON KEY F5 ACTION fecha_pizza()
      on key F9 action fecha_pedido()
      ON KEY ESCAPE ACTION thiswindow.release

   END WINDOW

   form_balcao.maximize
   form_balcao.activate

   RETURN NIL

STATIC FUNCTION procura_cliente(cform,ctextbtn)

   LOCAL flag    := .F.
   LOCAL creg    := ''
   LOCAL nreg_01 := getproperty(cform,ctextbtn,'value')
   LOCAL nreg_02 := nreg_01

   IF empty(nreg_02)
      creg := getcode_clientes(getproperty(cform,ctextbtn,'value'))
      IF .not. empty(creg)
         dbselectarea('clientes')
         clientes->(ordsetfocus('fixo'))
         clientes->(dbgotop())
         clientes->(dbseek(creg))
         IF found()
            __codigo_cliente := clientes->codigo
            setproperty('form_balcao','label_nome_cliente','value',clientes->nome)
            setproperty('form_balcao','label_endereco_001','value',alltrim(clientes->endereco)+', '+alltrim(clientes->numero))
            setproperty('form_balcao','label_endereco_002','value',alltrim(clientes->complem))
            setproperty('form_balcao','label_endereco_003','value',alltrim(clientes->bairro)+', '+alltrim(clientes->cidade))
            IF !empty(creg)
               setproperty(cform,ctextbtn,'value',creg)
            ENDIF
            historico_cliente_2(__codigo_cliente)
            form_balcao.tbox_pizza.setfocus

            RETURN NIL
         ENDIF
      ENDIF
      IF .not. empty(creg)
         dbselectarea('clientes')
         clientes->(ordsetfocus('celular'))
         clientes->(dbgotop())
         clientes->(dbseek(creg))
         IF found()
            __codigo_cliente := clientes->codigo
            setproperty('form_balcao','label_nome_cliente','value',clientes->nome)
            setproperty('form_balcao','label_endereco_001','value',alltrim(clientes->endereco)+', '+alltrim(clientes->numero))
            setproperty('form_balcao','label_endereco_002','value',alltrim(clientes->complem))
            setproperty('form_balcao','label_endereco_003','value',alltrim(clientes->bairro)+', '+alltrim(clientes->cidade))
            IF !empty(creg)
               setproperty(cform,ctextbtn,'value',creg)
            ENDIF
            historico_cliente_2(__codigo_cliente)
            form_balcao.tbox_pizza.setfocus

            RETURN NIL
         ENDIF
      ENDIF
   ELSE
      WHILE .T.
         dbselectarea('clientes')
         clientes->(ordsetfocus('fixo'))
         clientes->(dbgotop())
         clientes->(dbseek(nreg_02))
         IF found()
            __codigo_cliente := clientes->codigo
            setproperty('form_balcao','label_nome_cliente','value',clientes->nome)
            setproperty('form_balcao','label_endereco_001','value',alltrim(clientes->endereco)+', '+alltrim(clientes->numero))
            setproperty('form_balcao','label_endereco_002','value',alltrim(clientes->complem))
            setproperty('form_balcao','label_endereco_003','value',alltrim(clientes->bairro)+', '+alltrim(clientes->cidade))
            historico_cliente_2(__codigo_cliente)
            form_balcao.tbox_pizza.setfocus
            EXIT
         ENDIF
         dbselectarea('clientes')
         clientes->(ordsetfocus('celular'))
         clientes->(dbgotop())
         clientes->(dbseek(nreg_02))
         IF found()
            __codigo_cliente := clientes->codigo
            setproperty('form_balcao','label_nome_cliente','value',clientes->nome)
            setproperty('form_balcao','label_endereco_001','value',alltrim(clientes->endereco)+', '+alltrim(clientes->numero))
            setproperty('form_balcao','label_endereco_002','value',alltrim(clientes->complem))
            setproperty('form_balcao','label_endereco_003','value',alltrim(clientes->bairro)+', '+alltrim(clientes->cidade))
            historico_cliente_2(__codigo_cliente)
            form_balcao.tbox_pizza.setfocus
            EXIT
         ELSE
            msgalert('Telefone não está cadastrado','Atenção')
            form_balcao.tbox_telefone.setfocus

            RETURN NIL
         ENDIF
      END
   ENDIF

   RETURN NIL

STATIC FUNCTION getcode_clientes(value)

   LOCAL creg := ''
   LOCAL nreg := 1

   dbselectarea('clientes')
   clientes->(ordsetfocus('nome'))
   clientes->(dbgotop())

   DEFINE WINDOW form_pesquisa;
         at 000,000;
         WIDTH 690;
         HEIGHT 500;
         TITLE 'Pesquisa por nome';
         ICON path_imagens+'icone.ico';
         modal;
         NOSIZE

      DEFINE LABEL label_pesquisa
         COL 005
         ROW 440
         VALUE 'Buscar'
         autosize .T.
         FONTNAME 'verdana'
         fontsize 012
         FONTBOLD .T.
         FONTCOLOR _preto_001
         transparent .T.
      END LABEL
      DEFINE TEXTBOX txt_pesquisa
         COL 075
         ROW 440
         WIDTH 600
         MAXLENGTH 040
         onchange find_clientes()
         uppercase .T.
      END TEXTBOX

      DEFINE BROWSE browse_pesquisa
         ROW 002
         COL 002
         WIDTH 680
         HEIGHT 430
         HEADERS {'Fixo','Celular','Nome'}
         WIDTHS {150,150,350}
         WORKAREA clientes
         FIELDS {'clientes->fixo','clientes->celular','clientes->nome'}
         VALUE nreg
         FONTNAME 'courier new'
         fontsize 012
         FONTBOLD .T.
         BACKCOLOR _ciano_001
         nolines .T.
         lock .T.
         readonly {.T.,.T.,.T.}
         justify {BROWSE_JTFY_LEFT,BROWSE_JTFY_LEFT,BROWSE_JTFY_LEFT}
         on dblclick (iif(empty(clientes->fixo),creg:=clientes->celular,creg:=clientes->fixo),thiswindow.release)
      END browse

      ON KEY ESCAPE ACTION thiswindow.release

   END WINDOW

   form_pesquisa.browse_pesquisa.setfocus

   form_pesquisa.center
   form_pesquisa.activate

   return(creg)

STATIC FUNCTION find_clientes()

   LOCAL pesquisa := alltrim(form_pesquisa.txt_pesquisa.value)

   clientes->(dbgotop())

   IF pesquisa == ''

      RETURN NIL
   ELSEIF clientes->(dbseek(pesquisa))
      form_pesquisa.browse_pesquisa.value := clientes->(recno())
   ENDIF

   RETURN NIL

STATIC FUNCTION procura_produto()

   LOCAL x_codigo := form_balcao.tbox_produto.value

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
            form_balcao.tbox_produto.setfocus

            RETURN NIL
         ENDIF
      ELSE
         setproperty('form_balcao','label_nome_produto','value',produtos->nome_longo)
         setproperty('form_balcao','tbox_preco','value',produtos->vlr_venda)

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
         showheaders .F.
         nolines .T.
         FONTNAME 'courier new'
         fontsize 012
         BACKCOLOR _ciano_001
         FONTCOLOR _preto_001
         ondblclick mostra_informacao_produto()
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

   setproperty('form_balcao','tbox_produto','value',alltrim(x_codigo))
   setproperty('form_balcao','label_nome_produto','value',alltrim(x_nome))

   dbselectarea('produtos')
   produtos->(ordsetfocus('codigo'))
   produtos->(dbgotop())
   produtos->(dbseek(x_codigo))
   IF found()
      x_preco := produtos->vlr_venda
   ENDIF
   setproperty('form_balcao','tbox_preco','value',x_preco)

   form_pesquisa.release

   RETURN NIL

STATIC FUNCTION procura_pizza()

   LOCAL x_codigo := form_balcao.tbox_pizza.value

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
            form_balcao.tbox_pizza.setfocus

            RETURN NIL
         ENDIF
      ELSE
         setproperty('form_balcao','label_nome_pizza','value',produtos->nome_longo)

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
         showheaders .F.
         nolines .T.
         FONTNAME 'courier new'
         fontsize 012
         BACKCOLOR _ciano_001
         FONTCOLOR _preto_001
         ondblclick mostra_informacao()
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

   setproperty('form_balcao','tbox_pizza','value',alltrim(x_codigo))
   setproperty('form_balcao','label_nome_pizza','value',alltrim(x_nome))

   form_pesquisa.release

   RETURN NIL

STATIC FUNCTION zera_tabelas()

   dbselectarea('tmp_pizza')
   ZAP
   PACK

   dbselectarea('tmp_produto')
   ZAP
   PACK

   RETURN NIL

STATIC FUNCTION cadastrar_novo_cliente()

   LOCAL x_nome     := ''
   LOCAL x_fixo     := ''
   LOCAL x_celular  := ''
   LOCAL x_endereco := ''
   LOCAL x_numero   := ''
   LOCAL x_complem  := ''
   LOCAL x_bairro   := ''
   LOCAL x_cidade   := ''
   LOCAL x_uf       := 'PR'
   LOCAL x_cep      := ''
   LOCAL x_email    := ''
   LOCAL x_aniv_dia := 0
   LOCAL x_aniv_mes := 0

   DEFINE WINDOW form_incluir_novo_cliente;
         at 000,000;
         WIDTH 585;
         HEIGHT 380;
         TITLE 'Incluir novo cliente';
         ICON path_imagens+'icone.ico';
         modal;
         NOSIZE

      * entrada de dados
      @ 010,005 label lbl_001;
         of form_incluir_novo_cliente;
         VALUE 'Nome';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         transparent
      @ 030,005 textbox tbox_001;
         of form_incluir_novo_cliente;
         HEIGHT 027;
         WIDTH 310;
         VALUE x_nome;
         MAXLENGTH 040;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         uppercase
      @ 010,325 label lbl_002;
         of form_incluir_novo_cliente;
         VALUE 'Telefone fixo';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         transparent
      @ 030,325 textbox tbox_002;
         of form_incluir_novo_cliente;
         HEIGHT 027;
         WIDTH 120;
         VALUE x_fixo;
         MAXLENGTH 010;
         font 'verdana' size 012;
         bold;
         BACKCOLOR BLUE;
         FONTCOLOR WHITE;
         uppercase
      @ 010,455 label lbl_003;
         of form_incluir_novo_cliente;
         VALUE 'Telefone celular';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         transparent
      @ 030,455 textbox tbox_003;
         of form_incluir_novo_cliente;
         HEIGHT 027;
         WIDTH 120;
         VALUE x_celular;
         MAXLENGTH 010;
         font 'verdana' size 012;
         bold;
         BACKCOLOR BLUE;
         FONTCOLOR WHITE;
         uppercase
      @ 060,005 label lbl_004;
         of form_incluir_novo_cliente;
         VALUE 'Endereço';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         transparent
      @ 080,005 textbox tbox_004;
         of form_incluir_novo_cliente;
         HEIGHT 027;
         WIDTH 310;
         VALUE x_endereco;
         MAXLENGTH 040;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         uppercase
      @ 060,325 label lbl_005;
         of form_incluir_novo_cliente;
         VALUE 'Número';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         transparent
      @ 080,325 textbox tbox_005;
         of form_incluir_novo_cliente;
         HEIGHT 027;
         WIDTH 060;
         VALUE x_numero;
         MAXLENGTH 006;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         uppercase
      @ 060,395 label lbl_006;
         of form_incluir_novo_cliente;
         VALUE 'Complemento';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         transparent
      @ 080,395 textbox tbox_006;
         of form_incluir_novo_cliente;
         HEIGHT 027;
         WIDTH 180;
         VALUE x_complem;
         MAXLENGTH 020;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         uppercase
      @ 110,005 label lbl_007;
         of form_incluir_novo_cliente;
         VALUE 'Bairro';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         transparent
      @ 130,005 textbox tbox_007;
         of form_incluir_novo_cliente;
         HEIGHT 027;
         WIDTH 180;
         VALUE x_bairro;
         MAXLENGTH 020;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         uppercase
      @ 110,195 label lbl_008;
         of form_incluir_novo_cliente;
         VALUE 'Cidade';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         transparent
      @ 130,195 textbox tbox_008;
         of form_incluir_novo_cliente;
         HEIGHT 027;
         WIDTH 180;
         VALUE x_cidade;
         MAXLENGTH 020;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         uppercase
      @ 110,385 label lbl_009;
         of form_incluir_novo_cliente;
         VALUE 'UF';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         transparent
      @ 130,385 textbox tbox_009;
         of form_incluir_novo_cliente;
         HEIGHT 027;
         WIDTH 040;
         VALUE x_uf;
         MAXLENGTH 002;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         uppercase
      @ 110,435 label lbl_010;
         of form_incluir_novo_cliente;
         VALUE 'CEP';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         transparent
      @ 130,435 textbox tbox_010;
         of form_incluir_novo_cliente;
         HEIGHT 027;
         WIDTH 080;
         VALUE x_cep;
         MAXLENGTH 008;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         uppercase
      @ 160,005 label lbl_011;
         of form_incluir_novo_cliente;
         VALUE 'e-mail';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         transparent
      @ 180,005 textbox tbox_011;
         of form_incluir_novo_cliente;
         HEIGHT 027;
         WIDTH 450;
         VALUE x_email;
         MAXLENGTH 050;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         lowercase
      @ 210,005 label lbl_012;
         of form_incluir_novo_cliente;
         VALUE 'Dia aniversário';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         transparent
      @ 230,005 textbox tbox_012;
         of form_incluir_novo_cliente;
         HEIGHT 027;
         WIDTH 080;
         VALUE x_aniv_dia;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         NUMERIC
      @ 210,120 label lbl_013;
         of form_incluir_novo_cliente;
         VALUE 'Mês aniversário';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         transparent
      @ 230,120 textbox tbox_013;
         of form_incluir_novo_cliente;
         HEIGHT 027;
         WIDTH 080;
         VALUE x_aniv_mes;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         NUMERIC

      * texto de observação
      @ 265,005 label lbl_observacao;
         of form_incluir_novo_cliente;
         VALUE '* os campos na cor azul, telefones fixo e celular, serão utilizados no DELIVERY';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR BLUE;
         transparent

      * linha separadora
      DEFINE LABEL linha_rodape
         COL 000
         ROW form_incluir_novo_cliente.height-090
         VALUE ''
         WIDTH form_incluir_novo_cliente.width
         HEIGHT 001
         BACKCOLOR _preto_001
         transparent .F.
      END LABEL

      * botões
      DEFINE BUTTONEX button_ok
         PICTURE path_imagens+'img_gravar.bmp'
         COL form_incluir_novo_cliente.width-225
         ROW form_incluir_novo_cliente.height-085
         WIDTH 120
         HEIGHT 050
         CAPTION 'Ok, gravar'
         ACTION gravar_novo_cliente()
         FONTBOLD .T.
         TOOLTIP 'Confirmar as informações digitadas'
         flat .F.
         noxpstyle .T.
      END BUTTONEX
      DEFINE BUTTONEX button_cancela
         PICTURE path_imagens+'img_voltar.bmp'
         COL form_incluir_novo_cliente.width-100
         ROW form_incluir_novo_cliente.height-085
         WIDTH 090
         HEIGHT 050
         CAPTION 'Voltar'
         ACTION form_incluir_novo_cliente.release
         FONTBOLD .T.
         TOOLTIP 'Sair desta tela sem gravar informações'
         flat .F.
         noxpstyle .T.
      END BUTTONEX

      ON KEY ESCAPE ACTION thiswindow.release

   END WINDOW

   sethandcursor(getcontrolhandle('button_ok','form_incluir_novo_cliente'))
   sethandcursor(getcontrolhandle('button_cancela','form_incluir_novo_cliente'))

   form_incluir_novo_cliente.center
   form_incluir_novo_cliente.activate

   RETURN NIL

STATIC FUNCTION gravar_novo_cliente()

   LOCAL codigo  := 0
   LOCAL retorna := .F.

   IF empty(form_incluir_novo_cliente.tbox_001.value)
      retorna := .T.
   ENDIF

   IF retorna
      msgalert('Preencha o campo nome','Atenção')

      RETURN NIL
   ENDIF

   WHILE .T.
      dbselectarea('conta')
      conta->(dbgotop())
      IF lock_reg()
         codigo := conta->c_clientes
         REPLACE c_clientes with c_clientes + 1
         conta->(dbcommit())
         conta->(dbunlock())
         EXIT
      ELSE
         msgexclamation('Servidor congestionado, tecle ENTER e aguarde','Atenção')
         LOOP
      ENDIF
   END
   dbselectarea('clientes')
   clientes->(dbappend())
   clientes->codigo   := codigo
   clientes->nome     := form_incluir_novo_cliente.tbox_001.value
   clientes->fixo     := form_incluir_novo_cliente.tbox_002.value
   clientes->celular  := form_incluir_novo_cliente.tbox_003.value
   clientes->endereco := form_incluir_novo_cliente.tbox_004.value
   clientes->numero   := form_incluir_novo_cliente.tbox_005.value
   clientes->complem  := form_incluir_novo_cliente.tbox_006.value
   clientes->bairro   := form_incluir_novo_cliente.tbox_007.value
   clientes->cidade   := form_incluir_novo_cliente.tbox_008.value
   clientes->uf       := form_incluir_novo_cliente.tbox_009.value
   clientes->cep      := form_incluir_novo_cliente.tbox_010.value
   clientes->email    := form_incluir_novo_cliente.tbox_011.value
   clientes->aniv_dia := form_incluir_novo_cliente.tbox_012.value
   clientes->aniv_mes := form_incluir_novo_cliente.tbox_013.value
   clientes->(dbcommit())
   clientes->(dbgotop())

   form_incluir_novo_cliente.release

   IF .not. empty(form_incluir_novo_cliente.tbox_002.value)
      setproperty('form_balcao','tbox_telefone','value',form_incluir_novo_cliente.tbox_002.value)
      form_balcao.tbox_telefone.setfocus
   ELSE
      setproperty('form_balcao','tbox_telefone','value',form_incluir_novo_cliente.tbox_003.value)
      form_balcao.tbox_telefone.setfocus
   ENDIF

   RETURN NIL

STATIC FUNCTION gravar_adicionar()

   dbselectarea('tmp_pizza')
   tmp_pizza->(dbappend())
   tmp_pizza->id_produto := form_balcao.tbox_pizza.value
   tmp_pizza->nome       := form_balcao.label_nome_pizza.value
   tmp_pizza->(dbcommit())
   tmp_pizza->(dbgotop())

   form_balcao.grid_pizzas.refresh
   form_balcao.grid_pizzas.setfocus
   form_balcao.grid_pizzas.value := recno()

   form_balcao.tbox_pizza.value := ''
   form_balcao.tbox_pizza.setfocus

   RETURN NIL

STATIC FUNCTION gravar_produto()

   dbselectarea('tmp_produto')
   tmp_produto->(dbappend())
   tmp_produto->produto  := form_balcao.tbox_produto.value
   tmp_produto->nome     := form_balcao.label_nome_produto.value
   tmp_produto->qtd      := form_balcao.tbox_quantidade.value
   tmp_produto->unitario := form_balcao.tbox_preco.value
   tmp_produto->subtotal := (form_balcao.tbox_preco.value*form_balcao.tbox_quantidade.value)
   tmp_produto->(dbcommit())
   tmp_produto->(dbgotop())

   form_balcao.grid_produtos.refresh
   form_balcao.grid_produtos.setfocus
   form_balcao.grid_produtos.value := recno()

   form_balcao.tbox_produto.value := ''
   form_balcao.tbox_produto.setfocus

   RETURN NIL

STATIC FUNCTION excluir_pizza()

   IF empty(tmp_pizza->nome)
      msgalert('Escolha o que deseja excluir primeiro','Atenção')

      RETURN NIL
   ENDIF

   IF msgyesno('Excluir : '+alltrim(tmp_pizza->nome),'Excluir')
      tmp_pizza->(dbdelete())
   ENDIF

   form_balcao.grid_pizzas.refresh
   form_balcao.grid_pizzas.setfocus
   form_balcao.grid_pizzas.value := recno()

   RETURN NIL

STATIC FUNCTION excluir_produto()

   IF empty(tmp_produto->nome)
      msgalert('Escolha o que deseja excluir primeiro','Atenção')

      RETURN NIL
   ENDIF

   IF msgyesno('Excluir : '+alltrim(tmp_produto->nome),'Excluir')
      tmp_produto->(dbdelete())
   ENDIF

   form_balcao.grid_produtos.refresh
   form_balcao.grid_produtos.setfocus
   form_balcao.grid_produtos.value := recno()

   RETURN NIL

STATIC FUNCTION fecha_pizza()

   dbselectarea('tmp_pizza')
   tmp_pizza->(dbgotop())
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
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         transparent
      @ 025,005 label lbl_002;
         of form_finaliza_pizza;
         VALUE '2- Você poderá escolher entre o menor e o maior preço à ser cobrado, no caso de ter mais de 1 sabor na mesma pizza';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         transparent
      @ 045,005 label lbl_003;
         of form_finaliza_pizza;
         VALUE '3- Caso deseje, ao fechamento deste pedido, poderá conceder um desconto especial ao cliente';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         transparent
      @ 065,005 label lbl_004;
         of form_finaliza_pizza;
         VALUE '4- Para finalizar esta pizza e continuar vendendo, dê duplo-clique ou enter sobre o tamanho/preço escolhido';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR BLUE;
         transparent
      @ 085,005 label lbl_005;
         of form_finaliza_pizza;
         VALUE '5- ESC fecha esta janela e retorna para a tela de vendas';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _vermelho_002;
         transparent

      DEFINE GRID grid_finaliza_pizza
         parent form_finaliza_pizza
         COL 005
         ROW 105
         WIDTH 985
         HEIGHT 260
         HEADERS {'id','Pizza',_tamanho_001,_tamanho_002,_tamanho_003,_tamanho_004,_tamanho_005,_tamanho_006}
         WIDTHS {001,250,120,120,120,120,120,120}
         VALUE 1
         celled .T.
         FONTNAME 'verdana'
         fontsize 010
         FONTBOLD .T.
         BACKCOLOR _cinza_005
         FONTCOLOR _preto_001
         ondblclick pega_tamanho_valor_pizza()
      END GRID

      ON KEY ESCAPE ACTION thiswindow.release

   END WINDOW

   monta_informacao_pizza()

   form_finaliza_pizza.center
   form_finaliza_pizza.activate

   RETURN NIL

STATIC FUNCTION monta_informacao_pizza()

   dbselectarea('tmp_pizza')
   tmp_pizza->(dbgotop())

   DELETE item all from grid_finaliza_pizza of form_finaliza_pizza

   WHILE .not. eof()
      dbselectarea('produtos')
      produtos->(ordsetfocus('codigo'))
      produtos->(dbgotop())
      produtos->(dbseek(tmp_pizza->id_produto))
      IF found()
         add item {produtos->codigo,alltrim(produtos->nome_longo)+iif(produtos->promocao,' (promoção)',''),trans(produtos->val_tm_001,'@E 99,999.99'),trans(produtos->val_tm_002,'@E 99,999.99'),trans(produtos->val_tm_003,'@E 99,999.99'),trans(produtos->val_tm_004,'@E 99,999.99'),trans(produtos->val_tm_005,'@E 99,999.99'),trans(produtos->val_tm_006,'@E 99,999.99')} to grid_finaliza_pizza of form_finaliza_pizza
      ENDIF
      dbselectarea('tmp_pizza')
      tmp_pizza->(dbskip())
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

   dbselectarea('tmp_pizza')
   tmp_pizza->(dbgotop())
   WHILE .not. eof()
      IF empty(tmp_pizza->sequencia)
         REPLACE sequencia with 'pizza '+alltrim(str(_conta_pizza))
         REPLACE tamanho with x_nome_tamanho
         REPLACE preco with x_preco
      ENDIF
      tmp_pizza->(dbskip())
   END

   _conta_pizza ++

   form_finaliza_pizza.release
   form_balcao.grid_pizzas.refresh
   form_balcao.grid_pizzas.setfocus
   form_balcao.tbox_observacoes.setfocus

   RETURN NIL

STATIC FUNCTION verifica_zero()

   LOCAL x_qtd := form_balcao.tbox_quantidade.value

   IF empty(x_qtd)
      form_balcao.tbox_quantidade.setfocus

      RETURN NIL
   ENDIF

   RETURN NIL

STATIC FUNCTION fecha_pedido()

   LOCAL x_old_pizza      := space(10)
   LOCAL x_old_valor      := 0
   LOCAL x_total_pedido   := 0
   LOCAL x_total_recebido := 0
   PRIVATE x_valor_pizza  := 0
   PRIVATE x_valor_prod   := 0

   dbselectarea('tmp_pizza')
   tmp_pizza->(dbgotop())
   IF eof()
      msgstop('Nenhuma pizza foi vendida','Atenção')
   ELSE
      WHILE .not. eof()
         x_old_pizza := tmp_pizza->sequencia
         x_old_valor := tmp_pizza->preco
         tmp_pizza->(dbskip())
         IF tmp_pizza->sequencia <> x_old_pizza
            x_valor_pizza := (x_valor_pizza+x_old_valor)
         ENDIF
      END
   ENDIF

   dbselectarea('tmp_produto')
   tmp_produto->(dbgotop())
   IF eof()
      msgstop('Nenhum produto foi vendido','Atenção')
   ELSE
      WHILE .not. eof()
         x_valor_prod := (x_valor_prod+tmp_produto->subtotal)
         tmp_produto->(dbskip())
      END
   ENDIF

   DEFINE WINDOW form_fecha_pedido;
         at 000,000;
         WIDTH 500;
         HEIGHT 540;
         TITLE 'Fechamento do pedido';
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
         transparent .F.
         BACKCOLOR _cinza_002
      END LABEL
      DEFINE LABEL label_sep_002
         COL 000
         ROW 390
         VALUE ''
         WIDTH 500
         HEIGHT 002
         transparent .F.
         BACKCOLOR _cinza_002
      END LABEL

      @ 010,020 label label_001;
         of form_fecha_pedido;
         VALUE 'SUBTOTAL PIZZAS';
         autosize;
         font 'verdana' size 012;
         bold;
         FONTCOLOR BLUE;
         transparent
      @ 010,250 label label_001_valor;
         of form_fecha_pedido;
         VALUE trans(x_valor_pizza,'@E 999,999.99');
         autosize;
         font 'courier new' size 016;
         bold;
         FONTCOLOR BLUE;
         transparent
      @ 040,020 label label_002;
         of form_fecha_pedido;
         VALUE 'SUBTOTAL PRODUTOS';
         autosize;
         font 'verdana' size 012;
         bold;
         FONTCOLOR BLUE;
         transparent
      @ 040,250 label label_002_valor;
         of form_fecha_pedido;
         VALUE trans(x_valor_prod,'@E 999,999.99');
         autosize;
         font 'courier new' size 016;
         bold;
         FONTCOLOR BLUE;
         transparent
      @ 110,020 label label_004;
         of form_fecha_pedido;
         VALUE 'DESCONTO';
         autosize;
         font 'verdana' size 012;
         bold;
         FONTCOLOR _vermelho_002;
         transparent
      @ 110,250 getbox tbox_desconto;
         of form_fecha_pedido;
         HEIGHT 030;
         WIDTH 130;
         VALUE 0;
         font 'courier new' size 016;
         bold;
         BACKCOLOR _fundo_get;
         FONTCOLOR _vermelho_002;
         PICTURE '@E 9,999.99';
         ON CHANGE setproperty('form_fecha_pedido','label_005_valor','value',trans((x_valor_pizza+x_valor_prod)-form_fecha_pedido.tbox_desconto.value,'@E 999,999.99'));
         ON LOSTFOCUS setproperty('form_fecha_pedido','label_005_valor','value',trans((x_valor_pizza+x_valor_prod)-form_fecha_pedido.tbox_desconto.value,'@E 999,999.99'))
      @ 150,020 label label_005;
         of form_fecha_pedido;
         VALUE 'TOTAL DESTE PEDIDO';
         autosize;
         font 'verdana' size 012;
         bold;
         FONTCOLOR BLUE;
         transparent
      @ 150,250 label label_005_valor;
         of form_fecha_pedido;
         VALUE '';
         autosize;
         font 'courier new' size 016;
         bold;
         FONTCOLOR BLUE;
         transparent

      * escolher formas de recebimento
      @ 200,020 label label_006;
         of form_fecha_pedido;
         VALUE 'Você pode escolher até 3 formas de recebimento';
         autosize;
         font 'verdana' size 012;
         bold;
         FONTCOLOR _preto_001;
         transparent
      * formas de recebimento
      * 1º
      @ 230,020 combobox combo_1;
         itemsource formas_recebimento->nome;
         valuesource formas_recebimento->codigo;
         VALUE 1;
         WIDTH 250;
         font 'courier new' size 010
      @ 230,300 getbox tbox_fr001;
         of form_fecha_pedido;
         HEIGHT 030;
         WIDTH 130;
         VALUE 0;
         font 'courier new' size 014;
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
         font 'courier new' size 010
      @ 270,300 getbox tbox_fr002;
         of form_fecha_pedido;
         HEIGHT 030;
         WIDTH 130;
         VALUE 0;
         font 'courier new' size 014;
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
         font 'courier new' size 010
      @ 310,300 getbox tbox_fr003;
         of form_fecha_pedido;
         HEIGHT 030;
         WIDTH 130;
         VALUE 0;
         font 'courier new' size 014;
         bold;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         PICTURE '@E 99,999.99';
         ON LOSTFOCUS calcula_final()

      @ 360,020 label label_011;
         of form_fecha_pedido;
         VALUE 'TOTAL RECEBIDO';
         autosize;
         font 'verdana' size 012;
         bold;
         FONTCOLOR BLUE;
         transparent
      @ 360,250 label label_011_valor;
         of form_fecha_pedido;
         VALUE '';
         autosize;
         font 'courier new' size 016;
         bold;
         FONTCOLOR BLUE;
         transparent

      @ 400,020 label label_012;
         of form_fecha_pedido;
         VALUE 'TROCO';
         autosize;
         font 'verdana' size 012;
         bold;
         FONTCOLOR _vermelho_002;
         transparent
      @ 400,250 label label_012_valor;
         of form_fecha_pedido;
         VALUE '';
         autosize;
         font 'courier new' size 016;
         bold;
         FONTCOLOR BLUE;
         transparent

      * botões
      @ 460,115 buttonex botao_ok;
         parent form_fecha_pedido;
         CAPTION 'Fechar pedido';
         WIDTH 150 height 040;
         PICTURE path_imagens+'img_pedido.bmp';
         ACTION fechamento_geral();
         TOOLTIP 'Clique aqui para finalizar o pedido'
      @ 460,270 buttonex botao_voltar;
         parent form_fecha_pedido;
         CAPTION 'Voltar para tela anterior';
         WIDTH 220 height 040;
         PICTURE path_imagens+'img_sair.bmp';
         ACTION form_fecha_pedido.release;
         TOOLTIP 'Clique aqui para voltar a vender'

      ON KEY ESCAPE ACTION thiswindow.release

   END WINDOW

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
   x_val_003 := 0
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

STATIC FUNCTION fechamento_geral()

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
   x_val_003     := 0
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
      contas_receber->cliente := __codigo_cliente
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
      contas_receber->cliente := __codigo_cliente
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
      contas_receber->cliente := __codigo_cliente
      contas_receber->(dbcommit())
   ENDIF

   * caixa

   dbselectarea('caixa')
   caixa->(dbappend())
   caixa->id        := substr(alltrim(str(HB_RANDOM(0010023003,9999999999))),1,10)
   caixa->data      := date()
   caixa->historico := 'Venda Balcão'
   caixa->entrada   := x_recebido
   caixa->saida     := 0
   caixa->(dbcommit())

   * baixar os produtos

   dbselectarea('tmp_produto')
   tmp_produto->(dbgotop())
   WHILE .not. eof()
      dbselectarea('produtos')
      produtos->(ordsetfocus('codigo'))
      produtos->(dbgotop())
      produtos->(dbseek(tmp_produto->produto))
      IF found()
         IF lock_reg()
            produtos->qtd_estoq := produtos->qtd_estoq - tmp_produto->qtd
            produtos->(dbcommit())
         ENDIF
      ENDIF
      dbselectarea('tmp_produto')
      tmp_produto->(dbskip())
   END

   * baixar matéria prima

   x_old := space(10)

   dbselectarea('tmp_pizza')
   tmp_pizza->(dbgotop())
   WHILE .not. eof()
      dbselectarea('produto_composto')
      produto_composto->(ordsetfocus('id_produto'))
      produto_composto->(dbgotop())
      produto_composto->(dbseek(tmp_pizza->id_produto))
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
      dbselectarea('tmp_pizza')
      tmp_pizza->(dbskip())
   END

   * ultimas compras do cliente

   x_hora := space(08)
   x_hora := time()

   dbselectarea('ultimas_compras')
   ultimas_compras->(dbappend())
   ultimas_compras->id_cliente := __codigo_cliente
   ultimas_compras->data       := date()
   ultimas_compras->hora       := x_hora
   ultimas_compras->onde       := 3 //1=delivery 2=mesa 3=balcão
   ultimas_compras->valor      := x_total
   ultimas_compras->(dbcommit())

   * detalhamento - ultimas compras do cliente

   dbselectarea('tmp_produto')
   tmp_produto->(dbgotop())
   WHILE .not. eof()
      dbselectarea('detalhamento_compras')
      detalhamento_compras->(dbappend())
      detalhamento_compras->id_cliente := __codigo_cliente
      detalhamento_compras->data       := date()
      detalhamento_compras->hora       := x_hora
      detalhamento_compras->id_prod    := tmp_produto->produto
      detalhamento_compras->qtd        := tmp_produto->qtd
      detalhamento_compras->unitario   := tmp_produto->unitario
      detalhamento_compras->subtotal   := tmp_produto->subtotal
      detalhamento_compras->(dbcommit())
      dbselectarea('tmp_produto')
      tmp_produto->(dbskip())
   END
   dbselectarea('tmp_pizza')
   tmp_pizza->(dbgotop())
   WHILE .not. eof()
      dbselectarea('detalhamento_compras')
      detalhamento_compras->(dbappend())
      detalhamento_compras->id_cliente := __codigo_cliente
      detalhamento_compras->data       := date()
      detalhamento_compras->hora       := x_hora
      detalhamento_compras->id_prod    := tmp_pizza->id_produto
      detalhamento_compras->subtotal   := tmp_pizza->preco
      detalhamento_compras->(dbcommit())
      dbselectarea('tmp_pizza')
      tmp_pizza->(dbskip())
   END

   * jogar para acompanhamento

   dbselectarea('clientes')
   clientes->(ordsetfocus('codigo'))
   clientes->(dbgotop())
   clientes->(dbseek(__codigo_cliente))
   dbselectarea('entrega')
   entrega->(dbappend())
   entrega->cliente  := alltrim(clientes->nome)
   entrega->endereco := alltrim(clientes->endereco)+', '+alltrim(clientes->numero)
   IF empty(clientes->fixo)
      entrega->telefone := clientes->celular
   ELSE
      entrega->telefone := clientes->fixo
   ENDIF
   entrega->hora     := x_hora
   entrega->origem   := 'Balcão'
   entrega->situacao := 'Montando'
   entrega->vlr_taxa := 0
   entrega->(dbcommit())

   * fechar as janelas

   form_fecha_pedido.release
   form_balcao.release

   RETURN NIL

STATIC FUNCTION historico_cliente_2(parametro)

   DELETE item all from grid_historico of form_balcao

   dbselectarea('ultimas_compras')
   ultimas_compras->(ordsetfocus('id_cliente'))
   ultimas_compras->(dbgotop())
   ultimas_compras->(dbseek(parametro))

   IF found()
      WHILE .T.
         add item {str(ultimas_compras->id_cliente,6),a_onde[ultimas_compras->onde],dtoc(ultimas_compras->data),alltrim(ultimas_compras->hora),trans(ultimas_compras->valor,'@E 999,999.99')} to grid_historico of form_balcao
         ultimas_compras->(dbskip())
         IF ultimas_compras->id_cliente <> parametro
            EXIT
         ENDIF
      END
   ENDIF

   RETURN NIL

STATIC FUNCTION mostra_detalhamento_2()

   LOCAL x_id      := valor_coluna('grid_historico','form_balcao',1)
   LOCAL x_data    := valor_coluna('grid_historico','form_balcao',3)
   LOCAL x_hora    := alltrim(valor_coluna('grid_historico','form_balcao',4))
   LOCAL x_data_2  := ctod(x_data)
   LOCAL x_chave   := x_id+dtos(x_data_2)+x_hora
   LOCAL parametro := val(x_id)

   DELETE item all from grid_detalhamento of form_balcao

   dbselectarea('detalhamento_compras')
   detalhamento_compras->(ordsetfocus('id'))
   detalhamento_compras->(dbgotop())
   detalhamento_compras->(dbseek(x_chave))

   IF found()
      WHILE .T.
         add item {str(detalhamento_compras->qtd,6),acha_produto(detalhamento_compras->id_prod),trans(detalhamento_compras->subtotal,'@E 999,999.99')} to grid_detalhamento of form_balcao
         detalhamento_compras->(dbskip())
         IF detalhamento_compras->id_cliente <> parametro
            EXIT
         ENDIF
      END
   ENDIF

   RETURN NIL
