/*
sistema     : superchef pizzaria
programa    : venda delivery
compilador  : xharbour 1.2 simplex
lib gr�fica : minigui 1.7 extended
programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'hbcompat.ch'
#include 'super.ch'

MEMVAR _conta_pizza
MEMVAR _total_pedido
MEMVAR _preco_antes_borda
MEMVAR _tamanho_selecionado
MEMVAR _numero_tamanho
MEMVAR _conta_sequencia
MEMVAR x_valor_pizza
MEMVAR x_valor_prod
MEMVAR n_largura_janela
MEMVAR n_largura_grid
MEMVAR a_tamanhos_pedacos
MEMVAR x_hora, x_old

FUNCTION venda_delivery()

   LOCAL x_observacao_1 := ''
   LOCAL x_observacao_2 := ''
   LOCAL a_bordas := {}

   PRIVATE _conta_pizza := 1
   PRIVATE _total_pedido := 0
   PRIVATE _preco_antes_borda := 0
   PUBLIC _tamanho_selecionado
   PUBLIC _numero_tamanho := 1

   PUBLIC _conta_sequencia := 100

   SELE bordas
   GO TOP
   WHILE .not. eof()
      aadd(a_bordas,bordas->nome+'-'+trans(bordas->preco,'@E 999.99'))
      SKIP
   END

   SELE montagem
   ZAP
   PACK
   SELE temp_vendas
   ZAP
   PACK
   SELE tmp_tela
   ZAP
   PACK

   DEFINE WINDOW form_delivery ;
         at 000,000 ;
         WIDTH getdesktopwidth() ;
         HEIGHT getdesktopheight() ;
         TITLE 'Venda Delivery' ;
         ICON path_imagens+'icone.ico' ;
         modal ;
         ON INIT zera_tabelas()

      * mostrar texto explicando como fechar o pedido
      @ getdesktopheight()-100,000 label label_fechar_pedido ;
         of form_delivery ;
         WIDTH getdesktopwidth() ;
         HEIGHT 040 ;
         VALUE 'F9-fechar este pedido  ESC-sair' ;
         FONT 'verdana' size 022 ;
         bold ;
         BACKCOLOR _preto_001 ;
         FONTCOLOR _cinza_001 ;
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

      * digitar o telefone
      @ 010,010 label label_telefone ;
         of form_delivery ;
         VALUE 'Telefone' ;
         autosize ;
         FONT 'courier new' size 012 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 030,010 textbox tbox_telefone ;
         of form_delivery ;
         HEIGHT 030 ;
         WIDTH 150 ;
         VALUE '' ;
         MAXLENGTH 015 ;
         FONT 'courier new' size 016 ;
         bold ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         ON ENTER procura_cliente('form_delivery','tbox_telefone')

      * bot�o para cadastrar cliente caso n�o exista
      @ 020,170 buttonex botao_cadastrar_cliente ;
         PARENT form_delivery ;
         CAPTION 'Cadastrar novo cliente' ;
         WIDTH 220 height 040 ;
         PICTURE path_imagens+'cadastrar_cliente.bmp' ;
         ACTION cadastrar_novo_cliente() ;
         notabstop ;
         TOOLTIP 'Clique aqui para cadastrar um cliente novo, sem precisar sair desta tela'

      * mostrar nome do cliente
      @ 070,010 label label_nome_cliente ;
         of form_delivery ;
         VALUE '' ;
         autosize ;
         FONT 'courier new' size 016 ;
         bold ;
         FONTCOLOR BLUE ;
         TRANSPARENT

      * mostrar o endere�o
      @ 100,010 label label_endereco_001 ;
         of form_delivery ;
         VALUE '' ;
         autosize ;
         FONT 'courier new' size 014 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 120,010 label label_endereco_002 ;
         of form_delivery ;
         VALUE '' ;
         autosize ;
         FONT 'courier new' size 014 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 140,010 label label_endereco_003 ;
         of form_delivery ;
         VALUE '' ;
         autosize ;
         FONT 'courier new' size 014 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT

      * hist�rico do cliente
      @ 180,010 grid grid_historico ;
         PARENT form_delivery ;
         WIDTH 380 ;
         HEIGHT 200 ;
         HEADERS {'id cliente','Onde','Data','Hora','Valor R$'} ;
         WIDTHS {001,100,100,075,090} ;
         FONT 'tahoma' size 010 ;
         bold ;
         BACKCOLOR _branco_001 ;
         FONTCOLOR BLUE ;
         ON CHANGE mostra_detalhamento()
      @ 390,010 grid grid_detalhamento ;
         PARENT form_delivery ;
         WIDTH 380 ;
         HEIGHT (getdesktopheight()-390)-105 ;
         HEADERS {'Qtd.','Produto','Valor R$'} ;
         WIDTHS {080,190,100} ;
         FONT 'tahoma' size 010 ;
         bold ;
         BACKCOLOR _branco_001 ;
         FONTCOLOR BLUE

      n_largura_janela := form_delivery.width - 410
      n_largura_grid   := n_largura_janela / 2
      a_tamanhos_pedacos := {}
      aadd(a_tamanhos_pedacos,_tamanho_001+' - '+alltrim(str(_pedaco_001))+' peda�os')
      aadd(a_tamanhos_pedacos,_tamanho_002+' - '+alltrim(str(_pedaco_002))+' peda�os')
      aadd(a_tamanhos_pedacos,_tamanho_003+' - '+alltrim(str(_pedaco_003))+' peda�os')
      aadd(a_tamanhos_pedacos,_tamanho_004+' - '+alltrim(str(_pedaco_004))+' peda�os')
      aadd(a_tamanhos_pedacos,_tamanho_005+' - '+alltrim(str(_pedaco_005))+' peda�os')
      aadd(a_tamanhos_pedacos,_tamanho_006+' - '+alltrim(str(_pedaco_006))+' peda�os')

      @ 010,410 label label_pizza ;
         of form_delivery ;
         VALUE 'Escolha o tamanho da pizza' ;
         autosize ;
         FONT 'courier new' size 12 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      define comboboxex cbo_tamanhos
      ROW 30
      COL 410
      WIDTH 300
      HEIGHT 400
      ITEMS a_tamanhos_pedacos
      VALUE 1
      FONTNAME 'courier new'
      FONTSIZE 12
      FONTCOLOR BLUE
      ONCHANGE pega_tamanho()
   END comboboxex

   * grids

   * pizzas
   @ 060,410 label label_sabores ;
      of form_delivery ;
      VALUE 'Defina os sabores' ;
      autosize ;
      FONT 'courier new' size 12 ;
      bold ;
      FONTCOLOR _preto_001 ;
      TRANSPARENT
   @ 080,410 label label_sabores_2 ;
      of form_delivery ;
      VALUE 'duplo-clique/enter seleciona' ;
      autosize ;
      FONT 'courier new' size 12 ;
      bold ;
      FONTCOLOR _azul_001 ;
      TRANSPARENT
   DEFINE GRID grid_pizzas
      PARENT form_delivery
      COL 410
      ROW 100
      WIDTH n_largura_grid
      HEIGHT 300
      HEADERS {'','Nome','.','.','.','.','.','.'}
      WIDTHS {1,200,100,100,100,100,100,100}
      SHOWHEADERS .T.
      NOLINES .T.
      FONTNAME 'courier new'
      FONTSIZE 12
      BACKCOLOR _ciano_001
      FONTCOLOR _preto_001
      ONDBLCLICK adiciona_montagem()
   END GRID
   @ 440,410 Browse grid_montagem        ;
      Of         form_delivery   ;
      WIDTH      n_largura_grid              ;
      HEIGHT     100              ;
      HEADERS    {'ID','Nome'} ;
      WIDTHS     {1,n_largura_grid - 30}         ;
      WORKAREA   montagem ;
      FIELDS     {'montagem->codigo','montagem->nome'} ;
      VALUE      1                 ;
      FONT        'courier new'        ;
      Size 12                      ;
      JUSTIFY     {BROWSE_JTFY_CENTER,BROWSE_JTFY_LEFT} ;
      BACKCOLOR   _amarelo_001            ;
      FONTCOLOR   _preto_001

   @ 403,410 buttonex botao_fecha_pizza ;
      PARENT form_delivery ;
      CAPTION 'Pizza montada' ;
      WIDTH 120 height 35 ;
      PICTURE path_imagens+'adicionar.bmp' ;
      ACTION fecha_montagem_pizza()
   @ 403,535 buttonex botao_exclui_pizza ;
      PARENT form_delivery ;
      CAPTION 'Excluir sabor' ;
      WIDTH 120 height 35 ;
      PICTURE path_imagens+'img_cancela.bmp' ;
      ACTION excluir_sabor()

   * observa��es da pizza, borda e TOTAL
   @ 403,(410 + n_largura_grid + 10) textbox tbox_obs_1 ;
      of form_delivery ;
      HEIGHT 027 ;
      WIDTH 250 ;
      VALUE x_observacao_1 ;
      MAXLENGTH 30 ;
      FONT 'tahoma' size 010 ;
      BACKCOLOR _fundo_get ;
      FONTCOLOR _letra_get_1 ;
      UPPERCASE
   @ 431,(410 + n_largura_grid + 10) textbox tbox_obs_2 ;
      of form_delivery ;
      HEIGHT 027 ;
      WIDTH 250 ;
      VALUE x_observacao_2 ;
      MAXLENGTH 30 ;
      FONT 'tahoma' size 010 ;
      BACKCOLOR _fundo_get ;
      FONTCOLOR _letra_get_1 ;
      UPPERCASE
   define comboboxex cbo_bordas
   ROW 460
   COL (410 + n_largura_grid + 10)
   WIDTH 250
   HEIGHT 400
   ITEMS a_bordas
   VALUE 1
   FONTNAME 'courier new'
   FONTSIZE 12
   FONTCOLOR BLUE
   ONCHANGE adiciona_borda()
END comboboxex
@ 490,(410 + n_largura_grid + 10) label label_total_0 ;
   of form_delivery ;
   WIDTH 250 ;
   HEIGHT 20 ;
   VALUE 'TOTAL DO PEDIDO' ;
   FONT 'courier new' size 12 ;
   bold ;
   FONTCOLOR _branco_001 ;
   BACKCOLOR _azul_002 ;
   centeralign
@ 510,(410 + n_largura_grid + 10) label label_total ;
   of form_delivery ;
   WIDTH 250 ;
   HEIGHT 50 ;
   VALUE '0,00' ;
   FONT 'courier new' size 24 ;
   bold ;
   FONTCOLOR _vermelho_001 ;
   BACKCOLOR _ciano_001 ;
   RIGHTALIGN
* bot�o para imprimir o cupom
@ 520,(410 + n_largura_grid + 265) buttonex botao_cupom ;
   PARENT form_delivery ;
   CAPTION '' ;
   WIDTH 40 height 40 ;
   PICTURE path_imagens+'img_relatorio.bmp' ;
   ACTION imprimir_cupom('-',0,0,0,0,0) ;
   TOOLTIP 'Emitir CUPOM'

* bebidas e outros
@ 060,(410 + n_largura_grid + 10) label label_bebidas ;
   of form_delivery ;
   VALUE 'Bebidas / Outros' ;
   autosize ;
   FONT 'courier new' size 12 ;
   bold ;
   FONTCOLOR _preto_001 ;
   TRANSPARENT
@ 080,(410 + n_largura_grid + 10) label label_bebidas_2 ;
   of form_delivery ;
   VALUE 'duplo-clique/enter seleciona' ;
   autosize ;
   FONT 'courier new' size 12 ;
   bold ;
   FONTCOLOR _azul_001 ;
   TRANSPARENT
DEFINE GRID grid_produtos
   PARENT form_delivery
   COL 410 + n_largura_grid + 10
   ROW 100
   WIDTH n_largura_grid - 20
   HEIGHT 300
   HEADERS {'','Nome','Pre�o'}
   WIDTHS {1,250,150}
   SHOWHEADERS .F.
   NOLINES .T.
   FONTNAME 'courier new'
   FONTSIZE 12
   BACKCOLOR _ciano_001
   FONTCOLOR _preto_001
   ONDBLCLICK pede_quantidade()
END GRID

* pedido completo
@ 545,410 label label_pedido ;
   of form_delivery ;
   VALUE 'Pedido do cliente' ;
   autosize ;
   FONT 'courier new' size 12 ;
   bold ;
   FONTCOLOR _preto_001 ;
   TRANSPARENT
@ 540,585 buttonex botao_exclui_item_pedido ;
   PARENT form_delivery ;
   CAPTION 'excluir item pedido' ;
   WIDTH 130 height 25 ;
   FONTCOLOR RED ;
   ACTION excluir_item_pedido()

@ 565,410 Browse grid_pedido        ;
   Of         form_delivery   ;
   WIDTH      form_delivery.width - 420              ;
   HEIGHT     form_delivery.height - 670              ;
   HEADERS    {'SEQ','Item','Qtd','Unit.R$','SubTotal R$'} ;
   WIDTHS     {1,400,60,140,150}         ;
   WORKAREA   tmp_tela ;
   FIELDS     {'tmp_tela->seq','tmp_tela->item','tmp_tela->qtd','tmp_tela->unitario','tmp_tela->subtotal'} ;
   VALUE      1                 ;
   FONT        'courier new'        ;
   Size 12                      ;
   JUSTIFY     {BROWSE_JTFY_LEFT,BROWSE_JTFY_LEFT,BROWSE_JTFY_RIGHT,BROWSE_JTFY_RIGHT,BROWSE_JTFY_RIGHT} ;
   BACKCOLOR   _branco_001            ;
   FONTCOLOR   _azul_002

separa_pizza()
separa_produto()

on key F9 action fecha_pedido()
ON KEY ESCAPE ACTION thiswindow.release

END WINDOW

form_delivery.grid_pizzas.Header(3) := alltrim(_tamanho_001)
form_delivery.grid_pizzas.Header(4) := alltrim(_tamanho_002)
form_delivery.grid_pizzas.Header(5) := alltrim(_tamanho_003)
form_delivery.grid_pizzas.Header(6) := alltrim(_tamanho_004)
form_delivery.grid_pizzas.Header(7) := alltrim(_tamanho_005)
form_delivery.grid_pizzas.Header(8) := alltrim(_tamanho_006)

form_delivery.maximize
form_delivery.activate

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
            setproperty('form_delivery','label_nome_cliente','value',clientes->nome)
            setproperty('form_delivery','label_endereco_001','value',alltrim(clientes->endereco)+', '+alltrim(clientes->numero))
            setproperty('form_delivery','label_endereco_002','value',alltrim(clientes->complem))
            setproperty('form_delivery','label_endereco_003','value',alltrim(clientes->bairro)+', '+alltrim(clientes->cidade))
            IF !empty(creg)
               setproperty(cform,ctextbtn,'value',creg)
            ENDIF
            historico_cliente(__codigo_cliente)
            form_delivery.cbo_tamanhos.setfocus

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
            setproperty('form_delivery','label_nome_cliente','value',clientes->nome)
            setproperty('form_delivery','label_endereco_001','value',alltrim(clientes->endereco)+', '+alltrim(clientes->numero))
            setproperty('form_delivery','label_endereco_002','value',alltrim(clientes->complem))
            setproperty('form_delivery','label_endereco_003','value',alltrim(clientes->bairro)+', '+alltrim(clientes->cidade))
            IF !empty(creg)
               setproperty(cform,ctextbtn,'value',creg)
            ENDIF
            historico_cliente(__codigo_cliente)
            form_delivery.cbo_tamanhos.setfocus

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
            setproperty('form_delivery','label_nome_cliente','value',clientes->nome)
            setproperty('form_delivery','label_endereco_001','value',alltrim(clientes->endereco)+', '+alltrim(clientes->numero))
            setproperty('form_delivery','label_endereco_002','value',alltrim(clientes->complem))
            setproperty('form_delivery','label_endereco_003','value',alltrim(clientes->bairro)+', '+alltrim(clientes->cidade))
            historico_cliente(__codigo_cliente)
            form_delivery.cbo_tamanhos.setfocus
            EXIT
         ENDIF
         dbselectarea('clientes')
         clientes->(ordsetfocus('celular'))
         clientes->(dbgotop())
         clientes->(dbseek(nreg_02))
         IF found()
            __codigo_cliente := clientes->codigo
            setproperty('form_delivery','label_nome_cliente','value',clientes->nome)
            setproperty('form_delivery','label_endereco_001','value',alltrim(clientes->endereco)+', '+alltrim(clientes->numero))
            setproperty('form_delivery','label_endereco_002','value',alltrim(clientes->complem))
            setproperty('form_delivery','label_endereco_003','value',alltrim(clientes->bairro)+', '+alltrim(clientes->cidade))
            historico_cliente(__codigo_cliente)
            form_delivery.cbo_tamanhos.setfocus
            EXIT
         ELSE
            msgalert('Telefone n�o est� cadastrado','Aten��o')
            form_delivery.tbox_telefone.setfocus

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

   DEFINE WINDOW form_pesquisa ;
         at 000,000 ;
         WIDTH 690 ;
         HEIGHT 500 ;
         TITLE 'Pesquisa por nome' ;
         ICON path_imagens+'icone.ico' ;
         modal ;
         NOSIZE

      DEFINE LABEL label_pesquisa
         COL 005
         ROW 440
         VALUE 'Buscar'
         AUTOSIZE .T.
         FONTNAME 'verdana'
         FONTSIZE 012
         FONTBOLD .T.
         FONTCOLOR _preto_001
         TRANSPARENT .T.
      END LABEL
      DEFINE TEXTBOX txt_pesquisa
         COL 075
         ROW 440
         WIDTH 600
         MAXLENGTH 040
         ONCHANGE find_clientes()
         UPPERCASE .T.
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
         FONTSIZE 012
         FONTBOLD .T.
         BACKCOLOR _ciano_001
         NOLINES .T.
         LOCK .T.
         READONLY {.T.,.T.,.T.}
         JUSTIFY {BROWSE_JTFY_LEFT,BROWSE_JTFY_LEFT,BROWSE_JTFY_LEFT}
         ON DBLCLICK (iif(empty(clientes->fixo),creg:=clientes->celular,creg:=clientes->fixo),thiswindow.release)
      END BROWSE

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

   LOCAL x_codigo := form_delivery.tbox_produto.value

   IF empty(x_codigo)
      x_codigo := '9999'
   ENDIF

   dbselectarea('produtos')
   produtos->(ordsetfocus('codigo'))
   produtos->(dbgotop())
   produtos->(dbseek(x_codigo))

   IF found()
      IF produtos->pizza
         IF msgyesno('Este c�digo n�o � v�lido. Deseja procurar na lista ?','Aten��o')
            mostra_listagem_produto()

            RETURN NIL
         ELSE
            form_delivery.tbox_produto.setfocus

            RETURN NIL
         ENDIF
      ELSE
         setproperty('form_delivery','label_nome_produto','value',produtos->nome_longo)
         setproperty('form_delivery','tbox_preco','value',produtos->vlr_venda)

         RETURN NIL
      ENDIF
   ELSE
      mostra_listagem_produto()
   ENDIF

   RETURN NIL

STATIC FUNCTION mostra_listagem_produto()

   DEFINE WINDOW form_pesquisa ;
         at 000,000 ;
         WIDTH 560 ;
         HEIGHT 610 ;
         TITLE 'Produtos' ;
         ICON path_imagens+'icone.ico' ;
         modal ;
         NOSIZE

      DEFINE GRID grid_pesquisa
         PARENT form_pesquisa
         COL 000
         ROW 000
         WIDTH 555
         HEIGHT 580
         HEADERS {'','Nome','Pre�o R$'}
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

   DELETE item all from grid_produtos of form_delivery

   dbselectarea('produtos')
   produtos->(ordsetfocus('nome_longo'))
   produtos->(dbgotop())

   WHILE .not. eof()
      IF !produtos->pizza
         add item {produtos->codigo,alltrim(produtos->nome_longo),trans(produtos->vlr_venda,'@E 999,999.99')} to grid_produtos of form_delivery
      ENDIF
      produtos->(dbskip())
   END

   RETURN NIL

STATIC FUNCTION mostra_informacao_produto()

   LOCAL x_codigo := valor_coluna('grid_pesquisa','form_pesquisa',1)
   LOCAL x_nome   := valor_coluna('grid_pesquisa','form_pesquisa',2)
   LOCAL x_preco  := 0

   setproperty('form_delivery','tbox_produto','value',alltrim(x_codigo))
   setproperty('form_delivery','label_nome_produto','value',alltrim(x_nome))

   dbselectarea('produtos')
   produtos->(ordsetfocus('codigo'))
   produtos->(dbgotop())
   produtos->(dbseek(x_codigo))
   IF found()
      x_preco := produtos->vlr_venda
   ENDIF
   setproperty('form_delivery','tbox_preco','value',x_preco)

   form_pesquisa.release

   RETURN NIL

STATIC FUNCTION procura_pizza()

   LOCAL x_codigo := form_delivery.tbox_pizza.value

   IF empty(x_codigo)
      x_codigo := '9999'
   ENDIF

   dbselectarea('produtos')
   produtos->(ordsetfocus('codigo'))
   produtos->(dbgotop())
   produtos->(dbseek(x_codigo))

   IF found()
      IF !produtos->pizza
         IF msgyesno('Este c�digo n�o � de uma Pizza. Deseja procurar na lista ?','Aten��o')
            mostra_listagem_pizza()

            RETURN NIL
         ELSE
            form_delivery.tbox_pizza.setfocus

            RETURN NIL
         ENDIF
      ELSE
         setproperty('form_delivery','label_nome_pizza','value',produtos->nome_longo)

         RETURN NIL
      ENDIF
   ELSE
      mostra_listagem_pizza()
   ENDIF

   RETURN NIL

STATIC FUNCTION mostra_listagem_pizza()

   DEFINE WINDOW form_pesquisa ;
         at 000,000 ;
         WIDTH 410 ;
         HEIGHT 610 ;
         TITLE 'Pizzas' ;
         ICON path_imagens+'icone.ico' ;
         modal ;
         NOSIZE

      DEFINE GRID grid_pesquisa
         PARENT form_pesquisa
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

   DELETE item all from grid_pizzas of form_delivery

   dbselectarea('produtos')
   produtos->(ordsetfocus('nome_longo'))
   produtos->(dbgotop())

   WHILE .not. eof()
      IF produtos->pizza
         add item {produtos->codigo,alltrim(produtos->nome_longo),alltrim(trans(produtos->val_tm_001,'@E 99,999.99')),alltrim(trans(produtos->val_tm_002,'@E 99,999.99')),alltrim(trans(produtos->val_tm_003,'@E 99,999.99')),alltrim(trans(produtos->val_tm_004,'@E 99,999.99')),alltrim(trans(produtos->val_tm_005,'@E 99,999.99')),alltrim(trans(produtos->val_tm_006,'@E 99,999.99'))} to grid_pizzas of form_delivery
      ENDIF
      produtos->(dbskip())
   END

   RETURN NIL

STATIC FUNCTION mostra_informacao()

   LOCAL x_codigo := valor_coluna('grid_pesquisa','form_pesquisa',1)
   LOCAL x_nome   := valor_coluna('grid_pesquisa','form_pesquisa',2)

   setproperty('form_delivery','tbox_pizza','value',alltrim(x_codigo))
   setproperty('form_delivery','label_nome_pizza','value',alltrim(x_nome))

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

   DEFINE WINDOW form_incluir_novo_cliente ;
         at 000,000 ;
         WIDTH 585 ;
         HEIGHT 380 ;
         TITLE 'Incluir novo cliente' ;
         ICON path_imagens+'icone.ico' ;
         modal ;
         NOSIZE

      * entrada de dados
      @ 010,005 label lbl_001 ;
         of form_incluir_novo_cliente ;
         VALUE 'Nome' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 030,005 textbox tbox_001 ;
         of form_incluir_novo_cliente ;
         HEIGHT 027 ;
         WIDTH 310 ;
         VALUE x_nome ;
         MAXLENGTH 040 ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 010,325 label lbl_002 ;
         of form_incluir_novo_cliente ;
         VALUE 'Telefone fixo' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 030,325 textbox tbox_002 ;
         of form_incluir_novo_cliente ;
         HEIGHT 027 ;
         WIDTH 120 ;
         VALUE x_fixo ;
         MAXLENGTH 010 ;
         FONT 'verdana' size 012 ;
         bold ;
         BACKCOLOR BLUE ;
         FONTCOLOR WHITE ;
         UPPERCASE
      @ 010,455 label lbl_003 ;
         of form_incluir_novo_cliente ;
         VALUE 'Telefone celular' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 030,455 textbox tbox_003 ;
         of form_incluir_novo_cliente ;
         HEIGHT 027 ;
         WIDTH 120 ;
         VALUE x_celular ;
         MAXLENGTH 010 ;
         FONT 'verdana' size 012 ;
         bold ;
         BACKCOLOR BLUE ;
         FONTCOLOR WHITE ;
         UPPERCASE
      @ 060,005 label lbl_004 ;
         of form_incluir_novo_cliente ;
         VALUE 'Endere�o' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 080,005 textbox tbox_004 ;
         of form_incluir_novo_cliente ;
         HEIGHT 027 ;
         WIDTH 310 ;
         VALUE x_endereco ;
         MAXLENGTH 040 ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 060,325 label lbl_005 ;
         of form_incluir_novo_cliente ;
         VALUE 'N�mero' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 080,325 textbox tbox_005 ;
         of form_incluir_novo_cliente ;
         HEIGHT 027 ;
         WIDTH 060 ;
         VALUE x_numero ;
         MAXLENGTH 006 ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 060,395 label lbl_006 ;
         of form_incluir_novo_cliente ;
         VALUE 'Complemento' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 080,395 textbox tbox_006 ;
         of form_incluir_novo_cliente ;
         HEIGHT 027 ;
         WIDTH 180 ;
         VALUE x_complem ;
         MAXLENGTH 020 ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 110,005 label lbl_007 ;
         of form_incluir_novo_cliente ;
         VALUE 'Bairro' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 130,005 textbox tbox_007 ;
         of form_incluir_novo_cliente ;
         HEIGHT 027 ;
         WIDTH 180 ;
         VALUE x_bairro ;
         MAXLENGTH 020 ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 110,195 label lbl_008 ;
         of form_incluir_novo_cliente ;
         VALUE 'Cidade' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 130,195 textbox tbox_008 ;
         of form_incluir_novo_cliente ;
         HEIGHT 027 ;
         WIDTH 180 ;
         VALUE x_cidade ;
         MAXLENGTH 020 ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 110,385 label lbl_009 ;
         of form_incluir_novo_cliente ;
         VALUE 'UF' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 130,385 textbox tbox_009 ;
         of form_incluir_novo_cliente ;
         HEIGHT 027 ;
         WIDTH 040 ;
         VALUE x_uf ;
         MAXLENGTH 002 ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 110,435 label lbl_010 ;
         of form_incluir_novo_cliente ;
         VALUE 'CEP' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 130,435 textbox tbox_010 ;
         of form_incluir_novo_cliente ;
         HEIGHT 027 ;
         WIDTH 080 ;
         VALUE x_cep ;
         MAXLENGTH 008 ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 160,005 label lbl_011 ;
         of form_incluir_novo_cliente ;
         VALUE 'e-mail' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 180,005 textbox tbox_011 ;
         of form_incluir_novo_cliente ;
         HEIGHT 027 ;
         WIDTH 450 ;
         VALUE x_email ;
         MAXLENGTH 050 ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         lowercase
      @ 210,005 label lbl_012 ;
         of form_incluir_novo_cliente ;
         VALUE 'Dia anivers�rio' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 230,005 textbox tbox_012 ;
         of form_incluir_novo_cliente ;
         HEIGHT 027 ;
         WIDTH 080 ;
         VALUE x_aniv_dia ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         NUMERIC
      @ 210,120 label lbl_013 ;
         of form_incluir_novo_cliente ;
         VALUE 'M�s anivers�rio' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 230,120 textbox tbox_013 ;
         of form_incluir_novo_cliente ;
         HEIGHT 027 ;
         WIDTH 080 ;
         VALUE x_aniv_mes ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         NUMERIC

      * texto de observa��o
      @ 265,005 label lbl_observacao ;
         of form_incluir_novo_cliente ;
         VALUE '* os campos na cor azul, telefones fixo e celular, ser�o utilizados no DELIVERY' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR BLUE ;
         TRANSPARENT

      * linha separadora
      DEFINE LABEL linha_rodape
         COL 000
         ROW form_incluir_novo_cliente.height-090
         VALUE ''
         WIDTH form_incluir_novo_cliente.width
         HEIGHT 001
         BACKCOLOR _preto_001
         TRANSPARENT .F.
      END LABEL

      * bot�es
      DEFINE BUTTONEX button_ok
         PICTURE path_imagens+'img_gravar.bmp'
         COL form_incluir_novo_cliente.width-225
         ROW form_incluir_novo_cliente.height-085
         WIDTH 120
         HEIGHT 050
         CAPTION 'Ok, gravar'
         ACTION gravar_novo_cliente()
         FONTBOLD .T.
         TOOLTIP 'Confirmar as informa��es digitadas'
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
         TOOLTIP 'Sair desta tela sem gravar informa��es'
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
      msgalert('Preencha o campo nome','Aten��o')

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
         msgexclamation('Servidor congestionado, tecle ENTER e aguarde','Aten��o')
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
      setproperty('form_delivery','tbox_telefone','value',form_incluir_novo_cliente.tbox_002.value)
      form_delivery.tbox_telefone.setfocus
   ELSE
      setproperty('form_delivery','tbox_telefone','value',form_incluir_novo_cliente.tbox_003.value)
      form_delivery.tbox_telefone.setfocus
   ENDIF

   RETURN NIL

STATIC FUNCTION gravar_adicionar()

   dbselectarea('tmp_pizza')
   tmp_pizza->(dbappend())
   tmp_pizza->id_produto := form_delivery.tbox_pizza.value
   tmp_pizza->nome       := form_delivery.label_nome_pizza.value
   tmp_pizza->(dbcommit())
   tmp_pizza->(dbgotop())

   form_delivery.grid_pizzas.refresh
   form_delivery.grid_pizzas.setfocus
   form_delivery.grid_pizzas.value := recno()

   form_delivery.tbox_pizza.value := ''
   form_delivery.tbox_pizza.setfocus

   RETURN NIL

STATIC FUNCTION gravar_produto()

   /*
   dbselectarea('tmp_produto')
   tmp_produto->(dbappend())
   tmp_produto->produto  := form_delivery.tbox_produto.value
   tmp_produto->nome     := form_delivery.label_nome_produto.value
   tmp_produto->qtd      := form_delivery.tbox_quantidade.value
   tmp_produto->unitario := form_delivery.tbox_preco.value
   tmp_produto->subtotal := (form_delivery.tbox_preco.value*form_delivery.tbox_quantidade.value)
   tmp_produto->(dbcommit())
   tmp_produto->(dbgotop())

   form_delivery.grid_produtos.refresh
   form_delivery.grid_produtos.setfocus
   form_delivery.grid_produtos.value := recno()

   form_delivery.tbox_produto.value := ''
   form_delivery.tbox_produto.setfocus
   */

   RETURN NIL

STATIC FUNCTION excluir_pizza()

   IF empty(tmp_pizza->nome)
      msgalert('Escolha o que deseja excluir primeiro','Aten��o')

      RETURN NIL
   ENDIF

   IF msgyesno('Excluir : '+alltrim(tmp_pizza->nome),'Excluir')
      tmp_pizza->(dbdelete())
   ENDIF

   form_delivery.grid_pizzas.refresh
   form_delivery.grid_pizzas.setfocus
   form_delivery.grid_pizzas.value := recno()

   RETURN NIL

STATIC FUNCTION excluir_produto()

   IF empty(tmp_produto->nome)
      msgalert('Escolha o que deseja excluir primeiro','Aten��o')

      RETURN NIL
   ENDIF

   IF msgyesno('Excluir : '+alltrim(tmp_produto->nome),'Excluir')
      tmp_produto->(dbdelete())
   ENDIF

   form_delivery.grid_produtos.refresh
   form_delivery.grid_produtos.setfocus
   form_delivery.grid_produtos.value := recno()

   RETURN NIL

STATIC FUNCTION fecha_pizza()

   dbselectarea('tmp_pizza')
   tmp_pizza->(dbgotop())
   IF eof()
      msgexclamation('Nenhuma pizza foi selecionada ainda','Aten��o')

      RETURN NIL
   ENDIF

   DEFINE WINDOW form_finaliza_pizza ;
         at 000,000 ;
         WIDTH 1000 ;
         HEIGHT 400 ;
         TITLE 'Finalizar pizza' ;
         ICON path_imagens+'icone.ico' ;
         modal ;
         NOSIZE

      @ 005,005 label lbl_001 ;
         of form_finaliza_pizza ;
         VALUE '1- Selecione o tamanho da pizza' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 025,005 label lbl_002 ;
         of form_finaliza_pizza ;
         VALUE '2- Voc� poder� escolher entre o menor e o maior pre�o � ser cobrado, no caso de ter mais de 1 sabor na mesma pizza' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 045,005 label lbl_003 ;
         of form_finaliza_pizza ;
         VALUE '3- Caso deseje, ao fechamento deste pedido, poder� conceder um desconto especial ao cliente' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 065,005 label lbl_004 ;
         of form_finaliza_pizza ;
         VALUE '4- Para finalizar esta pizza e continuar vendendo, d� duplo-clique ou enter sobre o tamanho/pre�o escolhido' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR BLUE ;
         TRANSPARENT
      @ 085,005 label lbl_005 ;
         of form_finaliza_pizza ;
         VALUE '5- ESC fecha esta janela e retorna para a tela de vendas' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _vermelho_002 ;
         TRANSPARENT

      DEFINE GRID grid_finaliza_pizza
         PARENT form_finaliza_pizza
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

   dbselectarea('tmp_pizza')
   tmp_pizza->(dbgotop())

   DELETE item all from grid_finaliza_pizza of form_finaliza_pizza

   WHILE .not. eof()
      dbselectarea('produtos')
      produtos->(ordsetfocus('codigo'))
      produtos->(dbgotop())
      produtos->(dbseek(tmp_pizza->id_produto))
      IF found()
         add item {produtos->codigo,alltrim(produtos->nome_longo)+iif(produtos->promocao,' (promo��o)',''),trans(produtos->val_tm_001,'@E 99,999.99'),trans(produtos->val_tm_002,'@E 99,999.99'),trans(produtos->val_tm_003,'@E 99,999.99'),trans(produtos->val_tm_004,'@E 99,999.99'),trans(produtos->val_tm_005,'@E 99,999.99'),trans(produtos->val_tm_006,'@E 99,999.99')} to grid_finaliza_pizza of form_finaliza_pizza
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
   form_delivery.grid_pizzas.refresh
   form_delivery.grid_pizzas.setfocus
   form_delivery.tbox_observacoes.setfocus

   RETURN NIL

STATIC FUNCTION verifica_zero()

   LOCAL x_qtd := form_delivery.tbox_quantidade.value

   IF empty(x_qtd)
      form_delivery.tbox_quantidade.setfocus

      RETURN NIL
   ENDIF

   RETURN NIL

STATIC FUNCTION fecha_pedido()

   LOCAL x_old_pizza      := space(10)
   LOCAL x_old_valor      := 0
   LOCAL x_total_pedido   := 0
   LOCAL x_total_recebido := 0

   LOCAL x_borda := form_delivery.cbo_bordas.value
   LOCAL x_preco := 0

   PRIVATE x_valor_pizza  := 0
   PRIVATE x_valor_prod   := 0

   dbselectarea('temp_vendas')
   temp_vendas->(dbgotop())

   IF eof()
      msgstop('Nenhuma venda foi realizada, tecle ENTER','Aten��o')

      RETURN NIL
   ENDIF

   INDEX ON sequencia to indseq for tipo == 1
   GO TOP

   WHILE .not. eof()
      x_old_pizza := temp_vendas->sequencia
      x_old_valor := temp_vendas->subtotal

      temp_vendas->(dbskip())

      IF temp_vendas->sequencia <> x_old_pizza
         x_valor_pizza := (x_valor_pizza+x_old_valor)
      ENDIF

   END

   SET index to

   dbselectarea('temp_vendas')
   temp_vendas->(dbgotop())
   WHILE .not. eof()
      IF temp_vendas->tipo == 2
         x_valor_prod := (x_valor_prod+temp_vendas->subtotal)
      ENDIF
      temp_vendas->(dbskip())
   END

   DEFINE WINDOW form_fecha_pedido ;
         at 000,000 ;
         WIDTH 500 ;
         HEIGHT 540 ;
         TITLE 'Fechamento do pedido' ;
         ICON path_imagens+'icone.ico' ;
         modal ;
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

      * valor borda *
      dbselectarea('bordas')
      GO TOP
      go x_borda
      x_preco := bordas->preco

      @ 010,020 label label_001 ;
         of form_fecha_pedido ;
         VALUE 'SUBTOTAL PIZZAS' ;
         autosize ;
         FONT 'verdana' size 012 ;
         bold ;
         FONTCOLOR BLUE ;
         TRANSPARENT
      @ 010,250 label label_001_valor ;
         of form_fecha_pedido ;
         VALUE trans(x_valor_pizza,'@E 999,999.99') ;
         autosize ;
         FONT 'courier new' size 016 ;
         bold ;
         FONTCOLOR BLUE ;
         TRANSPARENT

      IF .not. empty(x_preco)
         @ 004,390 label label_b001 ;
            of form_fecha_pedido ;
            VALUE 'valor da borda' ;
            autosize ;
            FONT 'tahoma' size 8 ;
            bold ;
            FONTCOLOR BLACK ;
            TRANSPARENT
         @ 018,390 label label_b002 ;
            of form_fecha_pedido ;
            VALUE trans(x_preco,'@E 9,999.99') ;
            autosize ;
            FONT 'courier new' size 014 ;
            bold ;
            FONTCOLOR BLUE ;
            TRANSPARENT
      ENDIF
      @ 040,020 label label_002 ;
         of form_fecha_pedido ;
         VALUE 'SUBTOTAL PRODUTOS' ;
         autosize ;
         FONT 'verdana' size 012 ;
         bold ;
         FONTCOLOR BLUE ;
         TRANSPARENT
      @ 040,250 label label_002_valor ;
         of form_fecha_pedido ;
         VALUE trans(x_valor_prod,'@E 999,999.99') ;
         autosize ;
         FONT 'courier new' size 016 ;
         bold ;
         FONTCOLOR BLUE ;
         TRANSPARENT
      @ 070,020 label label_003 ;
         of form_fecha_pedido ;
         VALUE 'TAXA DE ENTREGA' ;
         autosize ;
         FONT 'verdana' size 012 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 070,250 getbox tbox_taxa ;
         of form_fecha_pedido ;
         HEIGHT 030 ;
         WIDTH 130 ;
         VALUE 0 ;
         FONT 'courier new' size 016 ;
         bold ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         PICTURE '@E 9,999.99'
      @ 110,020 label label_004 ;
         of form_fecha_pedido ;
         VALUE 'DESCONTO' ;
         autosize ;
         FONT 'verdana' size 012 ;
         bold ;
         FONTCOLOR _vermelho_002 ;
         TRANSPARENT
      @ 110,250 getbox tbox_desconto ;
         of form_fecha_pedido ;
         HEIGHT 030 ;
         WIDTH 130 ;
         VALUE 0 ;
         FONT 'courier new' size 016 ;
         bold ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _vermelho_002 ;
         PICTURE '@E 9,999.99' ;
         ON CHANGE setproperty('form_fecha_pedido','label_005_valor','value',trans((x_valor_pizza+x_valor_prod+form_fecha_pedido.tbox_taxa.value+x_preco)-form_fecha_pedido.tbox_desconto.value,'@E 999,999.99')) ;
         ON LOSTFOCUS setproperty('form_fecha_pedido','label_005_valor','value',trans((x_valor_pizza+x_valor_prod+form_fecha_pedido.tbox_taxa.value+x_preco)-form_fecha_pedido.tbox_desconto.value,'@E 999,999.99'))
      @ 150,020 label label_005 ;
         of form_fecha_pedido ;
         VALUE 'TOTAL DESTE PEDIDO' ;
         autosize ;
         FONT 'verdana' size 012 ;
         bold ;
         FONTCOLOR BLUE ;
         TRANSPARENT
      @ 150,250 label label_005_valor ;
         of form_fecha_pedido ;
         VALUE '' ;
         autosize ;
         FONT 'courier new' size 016 ;
         bold ;
         FONTCOLOR BLUE ;
         TRANSPARENT

      * escolher formas de recebimento
      @ 200,020 label label_006 ;
         of form_fecha_pedido ;
         VALUE 'Voc� pode escolher at� 3 formas de recebimento' ;
         autosize ;
         FONT 'verdana' size 012 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      * formas de recebimento
      * 1�
      @ 230,020 combobox combo_1 ;
         itemsource formas_recebimento->nome ;
         valuesource formas_recebimento->codigo ;
         VALUE 1 ;
         WIDTH 250 ;
         FONT 'courier new' size 010
      @ 230,300 getbox tbox_fr001 ;
         of form_fecha_pedido ;
         HEIGHT 030 ;
         WIDTH 130 ;
         VALUE 0 ;
         FONT 'courier new' size 014 ;
         bold ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         PICTURE '@E 99,999.99'
      * 2�
      @ 270,020 combobox combo_2 ;
         itemsource formas_recebimento->nome ;
         valuesource formas_recebimento->codigo ;
         VALUE 1 ;
         WIDTH 250 ;
         FONT 'courier new' size 010
      @ 270,300 getbox tbox_fr002 ;
         of form_fecha_pedido ;
         HEIGHT 030 ;
         WIDTH 130 ;
         VALUE 0 ;
         FONT 'courier new' size 014 ;
         bold ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         PICTURE '@E 99,999.99'
      * 3�
      @ 310,020 combobox combo_3 ;
         itemsource formas_recebimento->nome ;
         valuesource formas_recebimento->codigo ;
         VALUE 1 ;
         WIDTH 250 ;
         FONT 'courier new' size 010
      @ 310,300 getbox tbox_fr003 ;
         of form_fecha_pedido ;
         HEIGHT 030 ;
         WIDTH 130 ;
         VALUE 0 ;
         FONT 'courier new' size 014 ;
         bold ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         PICTURE '@E 99,999.99' ;
         ON LOSTFOCUS calcula_final(x_preco)

      @ 360,020 label label_011 ;
         of form_fecha_pedido ;
         VALUE 'TOTAL RECEBIDO' ;
         autosize ;
         FONT 'verdana' size 012 ;
         bold ;
         FONTCOLOR BLUE ;
         TRANSPARENT
      @ 360,250 label label_011_valor ;
         of form_fecha_pedido ;
         VALUE '' ;
         autosize ;
         FONT 'courier new' size 016 ;
         bold ;
         FONTCOLOR BLUE ;
         TRANSPARENT

      @ 400,020 label label_012 ;
         of form_fecha_pedido ;
         VALUE 'TROCO' ;
         autosize ;
         FONT 'verdana' size 012 ;
         bold ;
         FONTCOLOR _vermelho_002 ;
         TRANSPARENT
      @ 400,250 label label_012_valor ;
         of form_fecha_pedido ;
         VALUE '' ;
         autosize ;
         FONT 'courier new' size 016 ;
         bold ;
         FONTCOLOR BLUE ;
         TRANSPARENT

      * bot�es
      @ 460,005 buttonex botao_cupom ;
         PARENT form_fecha_pedido ;
         CAPTION 'Imprimir CUPOM' ;
         WIDTH 155 height 040 ;
         PICTURE path_imagens+'img_relatorio.bmp' ;
         ACTION imprimir_cupom('-',x_valor_pizza+x_valor_prod,form_fecha_pedido.tbox_taxa.value,x_preco,form_fecha_pedido.tbox_desconto.value,0) ;
         TOOLTIP 'Clique aqui imprimir o cupom'
      @ 460,165 buttonex botao_ok ;
         PARENT form_fecha_pedido ;
         CAPTION 'Fechar pedido' ;
         WIDTH 140 height 040 ;
         PICTURE path_imagens+'img_pedido.bmp' ;
         ACTION fechamento_geral(x_preco) ;
         TOOLTIP 'Clique aqui para finalizar o pedido'
      @ 460,310 buttonex botao_voltar ;
         PARENT form_fecha_pedido ;
         CAPTION 'Voltar tela anterior' ;
         WIDTH 180 height 040 ;
         PICTURE path_imagens+'img_sair.bmp' ;
         ACTION form_fecha_pedido.release ;
         TOOLTIP 'Clique aqui para voltar a vender'

      ON KEY ESCAPE ACTION thiswindow.release

   END WINDOW

   form_fecha_pedido.center
   form_fecha_pedido.activate

   RETURN NIL

STATIC FUNCTION calcula_final(p_borda)

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

   x_total    := (x_val_001+x_val_002+x_val_003+p_borda)-(x_val_004)
   x_recebido := (x_val_005+x_val_006+x_val_007)
   x_troco    := (x_recebido-x_total)

   setproperty('form_fecha_pedido','label_011_valor','value',trans(x_recebido,'@E 999,999.99'))
   setproperty('form_fecha_pedido','label_012_valor','value',trans(x_troco,'@E 999,999.99'))

   RETURN NIL

STATIC FUNCTION fechamento_geral(p_borda)

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

   x_total    := (x_val_001+x_val_002+x_val_003+p_borda)-(x_val_004)
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
   caixa->historico := 'Venda Delivery'
   caixa->entrada   := x_recebido
   caixa->saida     := 0
   caixa->(dbcommit())

   * baixar os produtos

   dbselectarea('temp_vendas')
   INDEX ON tipo to indtip1 for tipo == 2
   temp_vendas->(dbgotop())
   IF .not. eof()
      WHILE .not. eof()
         dbselectarea('produtos')
         produtos->(ordsetfocus('codigo'))
         produtos->(dbgotop())
         produtos->(dbseek(temp_vendas->produto))
         IF found()
            IF lock_reg()
               produtos->qtd_estoq := produtos->qtd_estoq - temp_vendas->qtd
               produtos->(dbcommit())
            ENDIF
         ENDIF
         dbselectarea('temp_vendas')
         temp_vendas->(dbskip())
      END
   ENDIF
   SET index to

   * baixar mat�ria prima

   x_old := space(10)

   dbselectarea('temp_vendas')
   INDEX ON tipo to indtip0 for tipo == 1
   temp_vendas->(dbgotop())
   IF .not. eof()
      WHILE .not. eof()
         dbselectarea('produto_composto')
         produto_composto->(ordsetfocus('id_produto'))
         produto_composto->(dbgotop())
         produto_composto->(dbseek(temp_vendas->produto))
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
         dbselectarea('temp_vendas')
         temp_vendas->(dbskip())
      END
   ENDIF
   SET index to

   * ultimas compras do cliente

   x_hora := space(08)
   x_hora := time()

   dbselectarea('ultimas_compras')
   ultimas_compras->(dbappend())
   ultimas_compras->id_cliente := __codigo_cliente
   ultimas_compras->data       := date()
   ultimas_compras->hora       := x_hora
   ultimas_compras->onde       := 1 //1=delivery 2=mesa 3=balc�o
   ultimas_compras->valor      := x_total
   ultimas_compras->(dbcommit())

   * detalhamento - ultimas compras do cliente

   * produtos
   dbselectarea('temp_vendas')
   INDEX ON tipo to indtip2 for tipo == 2
   temp_vendas->(dbgotop())
   IF .not. eof()
      WHILE .not. eof()
         dbselectarea('detalhamento_compras')
         detalhamento_compras->(dbappend())
         detalhamento_compras->id_cliente := __codigo_cliente
         detalhamento_compras->data       := date()
         detalhamento_compras->hora       := x_hora
         detalhamento_compras->id_prod    := temp_vendas->produto
         detalhamento_compras->qtd        := temp_vendas->qtd
         detalhamento_compras->unitario   := temp_vendas->unitario
         detalhamento_compras->subtotal   := temp_vendas->subtotal
         detalhamento_compras->(dbcommit())
         dbselectarea('temp_vendas')
         temp_vendas->(dbskip())
      END
   ENDIF
   SET index to
   * pizzas
   dbselectarea('temp_vendas')
   INDEX ON tipo to indtip3 for tipo == 1
   temp_vendas->(dbgotop())
   IF .not. eof()
      WHILE .not. eof()
         dbselectarea('detalhamento_compras')
         detalhamento_compras->(dbappend())
         detalhamento_compras->id_cliente := __codigo_cliente
         detalhamento_compras->data       := date()
         detalhamento_compras->hora       := x_hora
         detalhamento_compras->id_prod    := temp_vendas->produto
         detalhamento_compras->subtotal   := temp_vendas->subtotal
         detalhamento_compras->(dbcommit())
         dbselectarea('temp_vendas')
         temp_vendas->(dbskip())
      END
   ENDIF
   SET index to

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
   entrega->origem   := 'Delivery'
   entrega->situacao := 'Montando'
   entrega->vlr_taxa := x_val_003
   entrega->(dbcommit())

   * fechar as janelas

   form_fecha_pedido.release
   form_delivery.release

   RETURN NIL

STATIC FUNCTION historico_cliente(parametro)

   DELETE item all from grid_historico of form_delivery

   dbselectarea('ultimas_compras')
   ultimas_compras->(ordsetfocus('id_cliente'))
   ultimas_compras->(dbgotop())
   ultimas_compras->(dbseek(parametro))

   IF found()
      WHILE .T.
         add item {str(ultimas_compras->id_cliente,6),a_onde[ultimas_compras->onde],dtoc(ultimas_compras->data),alltrim(ultimas_compras->hora),trans(ultimas_compras->valor,'@E 999,999.99')} to grid_historico of form_delivery
         ultimas_compras->(dbskip())
         IF ultimas_compras->id_cliente <> parametro
            EXIT
         ENDIF
      END
   ENDIF

   RETURN NIL

STATIC FUNCTION mostra_detalhamento()

   LOCAL x_id      := valor_coluna('grid_historico','form_delivery',1)
   LOCAL x_data    := valor_coluna('grid_historico','form_delivery',3)
   LOCAL x_hora    := alltrim(valor_coluna('grid_historico','form_delivery',4))
   LOCAL x_data_2  := ctod(x_data)
   LOCAL x_chave   := x_id+dtos(x_data_2)+x_hora
   LOCAL parametro := val(x_id)

   DELETE item all from grid_detalhamento of form_delivery

   dbselectarea('detalhamento_compras')
   detalhamento_compras->(ordsetfocus('id'))
   detalhamento_compras->(dbgotop())
   detalhamento_compras->(dbseek(x_chave))

   IF found()
      WHILE .T.
         add item {str(detalhamento_compras->qtd,6),acha_produto(detalhamento_compras->id_prod),trans(detalhamento_compras->subtotal,'@E 999,999.99')} to grid_detalhamento of form_delivery
         detalhamento_compras->(dbskip())
         IF detalhamento_compras->id_cliente <> parametro
            EXIT
         ENDIF
      END
   ENDIF

   RETURN NIL

STATIC FUNCTION pede_quantidade()

   LOCAL x_codigo := alltrim(valor_coluna('grid_produtos','form_delivery',1))
   LOCAL x_nome := alltrim(valor_coluna('grid_produtos','form_delivery',2))
   LOCAL x_unitario := alltrim(valor_coluna('grid_produtos','form_delivery',3))

   DEFINE WINDOW form_pquantidade ;
         at 0,0 ;
         WIDTH 300 ;
         HEIGHT 150 ;
         TITLE 'Digita��o' ;
         ICON path_imagens+'icone.ico' ;
         modal ;
         NOSIZE

      @ 10,10 label label_1 ;
         VALUE 'Digite a quantidade' ;
         autosize ;
         FONT 'courier new' size 12 ;
         bold ;
         TRANSPARENT
      @ 10,230 textbox tbox_quantidade ;
         HEIGHT 30 ;
         WIDTH 60 ;
         VALUE '' ;
         numeric ;
         FONT 'courier new' size 12 ;
         bold ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         ON ENTER transfere_produto_pedido(x_codigo,x_nome,x_unitario)
      @ 50,10 label label_2 ;
         WIDTH form_pquantidade.width ;
         VALUE 'e tecle ENTER' ;
         FONT 'courier new' size 12 ;
         FONTCOLOR BLUE ;
         bold ;
         transparent ;
         centeralign

      ON KEY ESCAPE ACTION thiswindow.release

   END WINDOW

   form_pquantidade.center
   form_pquantidade.activate

   RETURN NIL

STATIC FUNCTION pega_tamanho()

   _numero_tamanho := 0

   _tamanho_selecionado := alltrim(substr(form_delivery.cbo_tamanhos.displayvalue,1,10))
   _numero_tamanho      := form_delivery.cbo_tamanhos.value

   form_delivery.grid_pizzas.setfocus

   RETURN NIL

STATIC FUNCTION adiciona_montagem()

   LOCAL x_codigo := valor_coluna('grid_pizzas','form_delivery',1)
   LOCAL x_nome   := valor_coluna('grid_pizzas','form_delivery',2)

   SELE montagem
   APPEND BLANK
   REPLACE id with x_codigo
   REPLACE nome with x_nome

   form_delivery.grid_montagem.setfocus
   form_delivery.grid_montagem.refresh
   form_delivery.grid_montagem.value := 1

   RETURN NIL

STATIC FUNCTION transfere_produto_pedido(p_codigo,p_nome,p_unitario)

   LOCAL p_qtd := alltrim(str(form_pquantidade.tbox_quantidade.value))
   LOCAL x_unitario := 0
   LOCAL total_geral := 0

   IF p_qtd == '0'
      msginfo('Quantidade n�o pode ser zero','Aten��o')

      RETURN NIL
   ENDIF

   dbselectarea('produtos')
   produtos->(ordsetfocus('codigo'))
   produtos->(dbgotop())
   produtos->(dbseek(p_codigo))
   IF found()
      x_unitario := produtos->vlr_venda
   ENDIF

   dbselectarea('temp_vendas')
   APPEND BLANK
   REPLACE seq with _conta_sequencia
   REPLACE id with alltrim(str(hb_random(0111222233,9999999889)))
   REPLACE tipo with 2
   REPLACE produto with p_codigo
   REPLACE preco with 0
   REPLACE sequencia with ''
   REPLACE nome with p_nome
   REPLACE qtd with val(p_qtd)
   REPLACE unitario with x_unitario
   REPLACE subtotal with x_unitario * val(p_qtd)

   *                                     *
   * grava para aparecer na tela somente *
   *                                     *

   dbselectarea('tmp_tela')
   APPEND BLANK
   REPLACE seq with _conta_sequencia
   REPLACE item with p_nome
   REPLACE qtd with val(p_qtd)
   REPLACE unitario with x_unitario
   REPLACE subtotal with x_unitario * val(p_qtd)

   * end job *

   _conta_sequencia ++

   form_delivery.grid_pedido.setfocus
   form_delivery.grid_pedido.refresh
   form_delivery.grid_pedido.value := 1

   _total_pedido := ( _total_pedido + (x_unitario * val(p_qtd)) )
   setproperty('form_delivery','label_total','value',trans(_total_pedido,'@E 99,999.99'))

   form_pquantidade.release

   RETURN NIL

STATIC FUNCTION excluir_sabor()

   IF DbfVazio('montagem')

      Return(Nil)
   ENDIF

   montagem->(DbDelete())
   PACK
   montagem->(DbGoTop())

   form_delivery.grid_montagem.setFocus
   form_delivery.grid_montagem.refresh
   form_delivery.grid_montagem.value := 1

   Return(Nil)

STATIC FUNCTION excluir_item_pedido()

   LOCAL n_seq := tmp_tela->seq
   LOCAL x_old_seq := 0
   LOCAL x_valor := 0
   LOCAL x_menos := 0

   IF DbfVazio('tmp_tela')

      Return(Nil)
   ENDIF

   dbselectarea('tmp_tela')
   GO TOP
   WHILE .not. eof()
      IF tmp_tela->seq == n_seq
         tmp_tela->(DbDelete())
      ENDIF
      SKIP
   END
   PACK
   * nessa rotina pega o valor para diminuir *
   dbselectarea('temp_vendas')
   INDEX ON seq to indseq9 for seq == n_seq
   GO TOP
   WHILE .not. eof()
      x_old_seq := temp_vendas->seq
      x_valor := temp_vendas->subtotal
      SKIP
      IF temp_vendas->seq <> x_old_seq
         x_menos := ( x_menos + x_valor )
      ENDIF
   END
   SET index to
   * nessa rotina apaga *
   dbselectarea('temp_vendas')
   GO TOP
   WHILE .not. eof()
      IF temp_vendas->seq == n_seq
         temp_vendas->(DbDelete())
      ENDIF
      SKIP
   END
   PACK

   dbselectarea('temp_vendas')
   GO TOP
   dbselectarea('tmp_tela')
   GO TOP

   *                                       *
   * diminui valor total do pedido na tela *
   *                                       *
   _total_pedido := ( _total_pedido - x_menos )
   setproperty('form_delivery','label_total','value',trans(_total_pedido,'@E 99,999.99'))

   form_delivery.grid_pedido.setFocus
   form_delivery.grid_pedido.refresh
   form_delivery.grid_pedido.value := 1

   Return(Nil)

STATIC FUNCTION fecha_montagem_pizza()

   LOCAL x_valor := 0
   LOCAL x_maior_valor := 0
   LOCAL x_soma := 0
   LOCAL x_qtd := 0
   LOCAL x_valor_cobrado := 0
   LOCAL a_nome_pizza := {}

   STATIC x_sequencia := 1

   dbselectarea('temp_cpz')
   PACK
   ZAP

   dbselectarea('montagem')
   montagem->(dbgotop())

   IF eof()
      msginfo('N�o existe(m) sabor(es) selecionado(s), tecle ENTER','Aten��o')

      RETURN NIL
   ENDIF

   WHILE .not. eof()

      dbselectarea('produtos')
      produtos->(ordsetfocus('codigo'))
      produtos->(dbgotop())
      produtos->(dbseek(montagem->id))
      IF found()
         IF _numero_tamanho == 1
            x_valor := produtos->val_tm_001
         ELSEIF _numero_tamanho == 2
            x_valor := produtos->val_tm_002
         ELSEIF _numero_tamanho == 3
            x_valor := produtos->val_tm_003
         ELSEIF _numero_tamanho == 4
            x_valor := produtos->val_tm_004
         ELSEIF _numero_tamanho == 5
            x_valor := produtos->val_tm_005
         ELSEIF _numero_tamanho == 6
            x_valor := produtos->val_tm_006
         ENDIF
         x_soma := x_soma + x_valor
         aadd(a_nome_pizza,alltrim(produtos->nome_longo))
         dbselectarea('temp_cpz')
         APPEND BLANK
         REPLACE preco with x_valor
         dbselectarea('produtos')
      ENDIF

      dbselectarea('montagem')
      montagem->(dbskip())

   END

   dbselectarea('temp_cpz')
   INDEX ON preco to indpcpz descend
   GO TOP
   x_maior_valor := temp_cpz->preco

   dbselectarea('montagem')
   GO TOP
   x_qtd := montagem->(reccount())

   IF _tipo_cobranca == 1 // maior valor
      x_valor_cobrado := x_maior_valor
   ELSEIF _tipo_cobranca == 2 // m�dia do valor
      x_valor_cobrado := ( x_soma / x_qtd )
   ENDIF

   * gravar as informa��es *

   dbselectarea('montagem')
   GO TOP

   WHILE .not. eof()

      dbselectarea('temp_vendas')
      APPEND BLANK
      REPLACE seq with _conta_sequencia
      REPLACE id with alltrim(str(hb_random(0111222233,9999999889)))
      REPLACE tipo with 1
      REPLACE produto with montagem->id
      REPLACE preco with 0
      REPLACE sequencia with 'pza '+alltrim(str(x_sequencia))
      REPLACE nome with montagem->nome
      REPLACE qtd with 1
      //replace unitario with x_valor_cobrado
      REPLACE subtotal with x_valor_cobrado

      dbselectarea('montagem')
      montagem->(dbskip())

   END

   *                                     *
   * grava para aparecer na tela somente *
   *                                     *
   dbselectarea('montagem')
   GO TOP

   WHILE .not. eof()

      dbselectarea('tmp_tela')
      APPEND BLANK
      REPLACE seq with _conta_sequencia
      REPLACE item with '1/'+alltrim(str(x_qtd))+' - '+alltrim(montagem->nome)

      dbselectarea('montagem')
      montagem->(dbskip())

   END
   dbselectarea('tmp_tela')
   APPEND BLANK
   REPLACE seq with _conta_sequencia
   REPLACE item with '  TOTAL pizza '+alltrim(str(x_sequencia))+' R$ '+trans(x_valor_cobrado,'@E 99,999.99')

   * end job *

   x_sequencia ++
   _conta_sequencia ++

   _total_pedido := ( _total_pedido + x_valor_cobrado )
   setproperty('form_delivery','label_total','value',trans(_total_pedido,'@E 99,999.99'))

   dbselectarea('montagem')
   ZAP
   PACK
   form_delivery.grid_montagem.setfocus
   form_delivery.grid_montagem.refresh
   form_delivery.grid_montagem.value := 1

   dbselectarea('tmp_tela')
   GO TOP
   form_delivery.grid_pedido.setfocus
   form_delivery.grid_pedido.refresh
   form_delivery.grid_pedido.value := 1

   RETURN NIL

STATIC FUNCTION imprimir_cupom(p_entregador,p_pedido,p_entrega,p_borda,p_desconto,p_total)

   LOCAL x_observacao_1 := form_delivery.tbox_obs_1.value
   LOCAL x_observacao_2 := form_delivery.tbox_obs_2.value
   LOCAL x_borda := alltrim(substr(form_delivery.cbo_bordas.displayvalue,1,15))
   LOCAL x_nome, x_fixo, x_endereco, x_numero
   LOCAL x_telefone_cliente := alltrim(form_delivery.tbox_telefone.value)
   LOCAL x_nome_cliente := alltrim(form_delivery.label_nome_cliente.value)
   LOCAL x_endereco_1 := alltrim(form_delivery.label_endereco_001.value)
   LOCAL x_endereco_2 := alltrim(form_delivery.label_endereco_002.value)
   LOCAL x_endereco_3 := alltrim(form_delivery.label_endereco_003.value)
   LOCAL x_total := alltrim(form_delivery.label_total.value)

   dbselectarea('empresa')
   empresa->(dbgotop())
   x_nome     := alltrim(empresa->nome)
   x_fixo     := alltrim(empresa->fixo_1)
   x_endereco := alltrim(empresa->endereco)
   x_numero   := alltrim(empresa->numero)

   Try

      SET PRINTER ON
      SET PRINTER TO LPT1
      SET CONSOLE OFF

      ? x_nome
      ? x_endereco+', '+x_numero+', '+x_fixo
      ? '------------------------------------------------'
      ? '         CUPOM PARA SIMPLES CONFERENCIA'
      ? '             NAO E DOCUMENTO FISCAL'
      ? '================================================'
      ? 'CLIENTE   : '+x_telefone_cliente+'-'+x_nome_cliente
      ? ' '+x_endereco_1
      ? ' '+x_endereco_2
      ? ' '+x_endereco_3
      ? 'ENTREGADOR: '+alltrim(p_entregador)
      ? 'DATA      : '+dtoc(date())+'  HORA: '+time()
      ? '------------------------------------------------'
      ? 'PRODUTO             QTD  UNITARIO     SUB-TOTAL'
      ? ''
      dbselectarea('tmp_tela')
      GO TOP
      WHILE .not. eof()
         IF empty(tmp_tela->qtd)
            IF substr(alltrim(tmp_tela->item),1,8) == 'TOTAL'
               ? '                            '+alltrim(tmp_tela->item)
            ELSE
               ? alltrim(tmp_tela->item)
            ENDIF
         ELSE
            ? substr(tmp_tela->item,1,20)+' '+trans(tmp_tela->qtd,'@R 99999')+'   '+trans(tmp_tela->unitario,'@E 999.99')+'      '+trans(tmp_tela->subtotal,'@E 999.99')
         ENDIF
         SKIP
      END
      ? ''
      ? 'BORDA'
      ? '*** '+x_borda+' ***'
      ? ''
      ? '================================================'
      IF empty(p_pedido)
         ? '                      TOTAL PEDIDO : '+trans(_total_pedido,'@E 999,999.99')
         ? '                   TAXA DE ENTREGA : '+trans(p_entrega,'@E 999,999.99')
         ? '                             BORDA : '+trans(p_borda,'@E 999,999.99')
         ? '                          DESCONTO : '+trans(p_desconto,'@E 999,999.99')
         ? '                             TOTAL : '+trans(_total_pedido,'@E 999,999.99')
      ELSE
         ? '                      TOTAL PEDIDO : '+trans(p_pedido,'@E 999,999.99')
         ? '                   TAXA DE ENTREGA : '+trans(p_entrega,'@E 999,999.99')
         ? '                             BORDA : '+trans(p_borda,'@E 999,999.99')
         ? '                          DESCONTO : '+trans(p_desconto,'@E 999,999.99')
         ? '                             TOTAL : '+trans((p_pedido+p_entrega+p_borda)-(p_desconto),'@E 999,999.99')
      ENDIF
      ? ''
      ? '------------------------------------------------'
      ? 'Agradecemos a preferencia, Volte Sempre !'
      ? ''
      ? ''
      ? '------------------------------------------------'
      ? ''
      ? 'Observacoes deste pedido'
      ? '( '+x_observacao_1+' )'
      ? '( '+x_observacao_2+' )'

      ? ''
      ? ''
      ? ''
      ? ''
      ? ''
      ? ''
      ? ''
      ? ''
      ? ''
      ? ''
      ? ''

      SET CONSOLE ON
      SET PRINTER TO
      SET PRINTER OFF

   CATCH

      msgexclamation('A IMPRESSORA est� DESLIGADA, por favor verifique','Aten��o')

   END

   //     y_flag := .F.

   RETURN NIL

STATIC FUNCTION adiciona_borda()

   LOCAL x_borda := form_delivery.cbo_bordas.value
   LOCAL x_preco := 0

   dbselectarea('bordas')
   GO TOP
   go x_borda
   x_preco := bordas->preco

   _total_pedido := ( _total_pedido - _preco_antes_borda ) + ( x_preco )
   setproperty('form_delivery','label_total','value',trans(_total_pedido,'@E 99,999.99'))

   _preco_antes_borda := x_preco

   RETURN NIL
