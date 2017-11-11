/*
sistema     : superchef pizzaria
programa    : produtos
compilador  : xharbour 1.2 simplex
lib gráfica : minigui 1.7 extended
programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'super.ch'

FUNCTION produtos()

   dbselectarea('produtos')
   ordsetfocus('nome_longo')
   produtos->(dbgotop())

   DEFINE WINDOW form_produtos;
         at 000,000;
         width getdesktopwidth();
         height getdesktopheight();
         title 'Produtos';
         icon path_imagens+'icone.ico';
         modal;
         on init pesquisar()

      * botões (toolbar)
      DEFINE BUTTONex button_incluir
         picture path_imagens+'incluir.bmp'
         col 005
         row 002
         width 100
         height 100
         caption 'F5 Incluir'
         action dados(1)
         fontname 'verdana'
         fontsize 009
         fontbold .T.
         fontcolor _preto_001
         vertical .T.
         flat .T.
         noxpstyle .T.
         backcolor _branco_001
      END BUTTONex
      DEFINE BUTTONex button_alterar
         picture path_imagens+'alterar.bmp'
         col 107
         row 002
         width 100
         height 100
         caption 'F6 Alterar'
         action dados(2)
         fontname 'verdana'
         fontsize 009
         fontbold .T.
         fontcolor _preto_001
         vertical .T.
         flat .T.
         noxpstyle .T.
         backcolor _branco_001
      END BUTTONex
      DEFINE BUTTONex button_excluir
         picture path_imagens+'excluir.bmp'
         col 209
         row 002
         width 100
         height 100
         caption 'F7 Excluir'
         action excluir()
         fontname 'verdana'
         fontsize 009
         fontbold .T.
         fontcolor _preto_001
         vertical .T.
         flat .T.
         noxpstyle .T.
         backcolor _branco_001
      END BUTTONex
      DEFINE BUTTONex button_imprimir
         picture path_imagens+'imprimir.bmp'
         col 311
         row 002
         width 100
         height 100
         caption 'F8 Imprimir'
         action relacao()
         fontname 'verdana'
         fontsize 009
         fontbold .T.
         fontcolor _preto_001
         vertical .T.
         flat .T.
         noxpstyle .T.
         backcolor _branco_001
      END BUTTONex
      DEFINE BUTTONex button_atualizar
         picture path_imagens+'atualizar.bmp'
         col 413
         row 002
         width 100
         height 100
         caption 'Atualizar'
         action atualizar()
         fontname 'verdana'
         fontsize 009
         fontbold .T.
         fontcolor _preto_001
         vertical .T.
         flat .T.
         noxpstyle .T.
         backcolor _branco_001
      END BUTTONex
      DEFINE BUTTONex button_fornecedores
         picture path_imagens+'fornecedores.bmp'
         col 515
         row 002
         width 100
         height 100
         caption 'Fornecedores'
         action fornecedores_produto()
         fontname 'verdana'
         fontsize 009
         fontbold .T.
         fontcolor _preto_001
         vertical .T.
         flat .T.
         noxpstyle .T.
         backcolor _branco_001
      END BUTTONex
      DEFINE BUTTONex button_compor
         picture path_imagens+'compor.bmp'
         col 617
         row 002
         width 100
         height 100
         caption 'Compor Prod.'
         action compor_produto()
         fontname 'verdana'
         fontsize 009
         fontbold .T.
         fontcolor _preto_001
         vertical .T.
         flat .T.
         noxpstyle .T.
         backcolor _branco_001
      END BUTTONex
      DEFINE BUTTONex button_sair
         picture path_imagens+'sair.bmp'
         col 719
         row 002
         width 100
         height 100
         caption 'ESC Voltar'
         action form_produtos.release
         fontname 'verdana'
         fontsize 009
         fontbold .T.
         fontcolor _preto_001
         vertical .T.
         flat .T.
         noxpstyle .T.
         backcolor _branco_001
      END BUTTONex

      DEFINE SPLITBOX
         DEFINE GRID grid_produtos
            parent form_produtos
            col 000
            row 105
            width getdesktopwidth()
            height getdesktopheight()-210
            headers {'Pizza','Promoção','Baixa','Código','Código Barra','Nome (longo)','Qtd.Estoque'}
            widths {060,100,060,100,150,400,120}
            fontname 'verdana'
            fontsize 010
            fontbold .T.
            backcolor _amarelo_001
            fontcolor _preto_001
            ondblclick dados(2)
         END GRID
      END SPLITBOX

      DEFINE LABEL rodape_001
         parent form_produtos
         col 005
         row getdesktopheight()-090
         value 'Digite sua pesquisa'
         autosize .T.
         fontname 'verdana'
         fontsize 010
         fontbold .T.
         fontcolor _cinza_001
         transparent .T.
      END LABEL
      @ getdesktopheight()-095,160 textbox tbox_pesquisa;
         of form_produtos;
         height 027;
         width 550;
         value '';
         maxlength 040;
         font 'verdana' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         uppercase;
         on change pesquisar()
      DEFINE LABEL rodape_002
         parent form_produtos
         col form_produtos.width - 270
         row getdesktopheight()-085
         value 'DUPLO CLIQUE : Alterar informação'
         autosize .T.
         fontname 'verdana'
         fontsize 010
         fontbold .T.
         fontcolor _verde_002
         transparent .T.
      END LABEL

      on key F5 action dados(1)
      on key F6 action dados(2)
      on key F7 action excluir()
      on key F8 action relacao()
      on key escape action thiswindow.release

   END WINDOW

   form_produtos.maximize
   form_produtos.activate

   RETURN(nil)

STATIC FUNCTION dados(parametro)

   LOCAL id
   LOCAL titulo           := ''
   LOCAL x_codigo         := space(10)
   LOCAL x_nome_longo     := ''
   LOCAL x_nome_cupom     := ''
   LOCAL x_cbarra         := ''
   LOCAL x_pizza          := .T.
   LOCAL x_promocao       := .F.
   LOCAL x_baixa          := .F.
   LOCAL x_categoria      := 0
   LOCAL x_subcategoria   := 0
   LOCAL x_qtd_estoque    := 0
   LOCAL x_qtd_minimo     := 0
   LOCAL x_qtd_maximo     := 0
   LOCAL x_imposto        := 0
   LOCAL x_valor_custo    := 0
   LOCAL x_valor_venda    := 0
   LOCAL x_valor_001      := 0
   LOCAL x_valor_002      := 0
   LOCAL x_valor_003      := 0
   LOCAL x_valor_004      := 0
   LOCAL x_valor_005      := 0
   LOCAL x_valor_006      := 0

   IF parametro == 1
      titulo := 'Incluir'
   ELSEIF parametro == 2
      id     := valor_coluna('grid_produtos','form_produtos',4)
      titulo := 'Alterar'
      dbselectarea('produtos')
      produtos->(ordsetfocus('codigo'))
      produtos->(dbgotop())
      produtos->(dbseek(id))
      IF found()
         x_codigo         := produtos->codigo
         x_nome_longo     := produtos->nome_longo
         x_nome_cupom     := produtos->nome_cupom
         x_cbarra         := produtos->cbarra
         x_pizza          := produtos->pizza
         x_promocao       := produtos->promocao
         x_baixa          := produtos->baixa
         x_categoria      := produtos->categoria
         x_subcategoria   := produtos->scategoria
         x_qtd_estoque    := produtos->qtd_estoq
         x_qtd_minimo     := produtos->qtd_min
         x_qtd_maximo     := produtos->qtd_max
         x_imposto        := produtos->imposto
         x_valor_custo    := produtos->vlr_custo
         x_valor_venda    := produtos->vlr_venda
         x_valor_001      := produtos->val_tm_001
         x_valor_002      := produtos->val_tm_002
         x_valor_003      := produtos->val_tm_003
         x_valor_004      := produtos->val_tm_004
         x_valor_005      := produtos->val_tm_005
         x_valor_006      := produtos->val_tm_006
         produtos->(ordsetfocus('nome_longo'))
      ELSE
         msgexclamation('Selecione uma informação','Atenção')
         produtos->(ordsetfocus('nome_longo'))

         RETURN(nil)
      ENDIF
   ENDIF

   DEFINE WINDOW form_dados;
         at 000,000;
         width 830;
         height 550;
         title (titulo);
         icon path_imagens+'icone.ico';
         modal;
         nosize

      * entrada de dados
      @ 005,005 frame frame_geral;
         parent form_dados;
         caption 'Informações do cadastro';
         width 510;
         height 440;
         font 'verdana';
         size 010;
         bold;
         opaque

      @ 025,015 label lbl_001;
         of form_dados;
         value 'Código';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 045,015 getbox tbox_001;
         of form_dados;
         height 027;
         width 120;
         value x_codigo;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1
      @ 025,145 label lbl_002;
         of form_dados;
         value 'Nome (longo)';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 045,145 textbox tbox_002;
         of form_dados;
         height 027;
         width 360;
         value x_nome_longo;
         maxlength 040;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         uppercase
      @ 075,015 label lbl_003;
         of form_dados;
         value 'Nome (cupom)';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 095,015 textbox tbox_003;
         of form_dados;
         height 027;
         width 250;
         value x_nome_cupom;
         maxlength 015;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         uppercase
      @ 075,275 label lbl_004;
         of form_dados;
         value 'Código Barra';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 095,275 textbox tbox_004;
         of form_dados;
         height 027;
         width 230;
         value x_cbarra;
         maxlength 015;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         uppercase
      DEFINE CHECKBOX tbox_005
         row 130
         col 015
         width 150
         caption 'Produto é PIZZA ?'
         value x_pizza
         fontname 'verdana'
         fontsize 010
         fontbold .T.
      END CHECKBOX
      DEFINE CHECKBOX tbox_006
         row 130
         col 175
         width 130
         caption 'Em Promoção ?'
         value x_promocao
         fontname 'verdana'
         fontsize 010
         fontbold .T.
      END CHECKBOX
      DEFINE CHECKBOX tbox_007
         row 130
         col 315
         width 180
         caption 'Baixa o estoque ?'
         value x_baixa
         fontname 'verdana'
         fontsize 010
         fontbold .T.
      END CHECKBOX
      @ 180,015 label lbl_008;
         of form_dados;
         value 'Categoria';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 200,015 textbox tbox_008;
         of form_dados;
         height 027;
         width 060;
         value x_categoria;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         numeric;
         on enter procura_categoria('form_dados','tbox_008')
      @ 200,085 label lbl_nome_categoria;
         of form_dados;
         value '';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _azul_001;
         transparent
      @ 230,015 label lbl_009;
         of form_dados;
         value 'Sub Categoria';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 250,015 textbox tbox_009;
         of form_dados;
         height 027;
         width 060;
         value x_subcategoria;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         numeric;
         on enter procura_subcategoria('form_dados','tbox_009')
      @ 250,085 label lbl_nome_subcategoria;
         of form_dados;
         value '';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _azul_001;
         transparent
      @ 290,015 label lbl_010;
         of form_dados;
         value 'Qtd. em estoque';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 310,015 textbox tbox_010;
         of form_dados;
         height 027;
         width 100;
         value x_qtd_estoque;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         numeric
      @ 290,130 label lbl_011;
         of form_dados;
         value 'Qtd. mínima';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 310,130 textbox tbox_011;
         of form_dados;
         height 027;
         width 100;
         value x_qtd_minimo;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         numeric
      @ 290,240 label lbl_012;
         of form_dados;
         value 'Qtd. máxima';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 310,240 textbox tbox_012;
         of form_dados;
         height 027;
         width 100;
         value x_qtd_maximo;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         numeric
      @ 340,015 label lbl_013;
         of form_dados;
         value 'Imposto';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 360,015 textbox tbox_013;
         of form_dados;
         height 027;
         width 060;
         value x_imposto;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         numeric;
         on enter procura_imposto('form_dados','tbox_013')
      @ 360,085 label lbl_nome_imposto;
         of form_dados;
         value '';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _azul_001;
         transparent
      @ 390,015 label lbl_014;
         of form_dados;
         value 'Valor CUSTO R$';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _verde_001;
         transparent
      @ 410,015 getbox tbox_014;
         of form_dados;
         height 027;
         width 150;
         value x_valor_custo;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         picture '@E 999,999.99'
      @ 390,175 label lbl_015;
         of form_dados;
         value 'Valor VENDA R$';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor BLUE;
         transparent
      @ 410,175 getbox tbox_015;
         of form_dados;
         height 027;
         width 150;
         value x_valor_venda;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         picture '@E 999,999.99'

      * valores referentes aos tamanhos
      @ 005,525 frame frame_valores;
         parent form_dados;
         caption 'Tamanhos e preços (pizza)';
         width 290;
         height 440;
         font 'verdana';
         size 010;
         bold;
         opaque
      @ 025,535 label lbl_t001;
         of form_dados;
         value 'Tamanhos';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 025,670 label lbl_t002;
         of form_dados;
         value 'Preços R$';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent

      * mostrar os tamanhos pré-definidos
      @ 050,535 label lbl_t003;
         of form_dados;
         value _tamanho_001;
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor BLUE;
         transparent
      @ 090,535 label lbl_t004;
         of form_dados;
         value _tamanho_002;
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor BLUE;
         transparent
      @ 130,535 label lbl_t005;
         of form_dados;
         value _tamanho_003;
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor BLUE;
         transparent
      @ 170,535 label lbl_t006;
         of form_dados;
         value _tamanho_004;
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor BLUE;
         transparent
      @ 210,535 label lbl_t007;
         of form_dados;
         value _tamanho_005;
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor BLUE;
         transparent
      @ 250,535 label lbl_t008;
         of form_dados;
         value _tamanho_006;
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor BLUE;
         transparent

      * preços das pizzas
      @ 050,670 getbox tbox_preco_001;
         of form_dados;
         height 030;
         width 140;
         value x_valor_001;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         picture '@E 999,999.99'
      @ 090,670 getbox tbox_preco_002;
         of form_dados;
         height 030;
         width 140;
         value x_valor_002;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         picture '@E 999,999.99'
      @ 130,670 getbox tbox_preco_003;
         of form_dados;
         height 030;
         width 140;
         value x_valor_003;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         picture '@E 999,999.99'
      @ 170,670 getbox tbox_preco_004;
         of form_dados;
         height 030;
         width 140;
         value x_valor_004;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         picture '@E 999,999.99'
      @ 210,670 getbox tbox_preco_005;
         of form_dados;
         height 030;
         width 140;
         value x_valor_005;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         picture '@E 999,999.99'
      @ 250,670 getbox tbox_preco_006;
         of form_dados;
         height 030;
         width 140;
         value x_valor_006;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         picture '@E 999,999.99'

      * linha separadora
      DEFINE LABEL linha_rodape
         col 000
         row form_dados.height-090
         value ''
         width form_dados.width
         height 001
         backcolor _preto_001
         transparent .F.
      END LABEL

      * botões
      DEFINE BUTTONex button_ok
         picture path_imagens+'img_gravar.bmp'
         col form_dados.width-225
         row form_dados.height-085
         width 120
         height 050
         caption 'Ok, gravar'
         action gravar(parametro)
         fontbold .T.
         tooltip 'Confirmar as informações digitadas'
         flat .F.
         noxpstyle .T.
      END BUTTONex
      DEFINE BUTTONex button_cancela
         picture path_imagens+'img_voltar.bmp'
         col form_dados.width-100
         row form_dados.height-085
         width 090
         height 050
         caption 'Voltar'
         action form_dados.release
         fontbold .T.
         tooltip 'Sair desta tela sem gravar informações'
         flat .F.
         noxpstyle .T.
      END BUTTONex

      on key escape action thiswindow.release

   END WINDOW

   IF parametro == 2
      form_dados.tbox_001.enabled := .F.
   ENDIF

   sethandcursor(getcontrolhandle('button_ok','form_dados'))
   sethandcursor(getcontrolhandle('button_cancela','form_dados'))

   form_dados.center
   form_dados.activate

   RETURN(nil)

STATIC FUNCTION compor_produto()

   LOCAL x_codigo_produto := valor_coluna('grid_produtos','form_produtos',4)
   LOCAL x_nome_produto   := valor_coluna('grid_produtos','form_produtos',6)

   IF empty(x_nome_produto)
      msgexclamation('Escolha um produto','Atenção')

      RETURN(nil)
   ENDIF

   DEFINE WINDOW form_compor;
         at 000,000;
         width 600;
         height 500;
         title 'Compor produto : '+alltrim(x_nome_produto);
         icon path_imagens+'icone.ico';
         modal;
         nosize

      * botões (toolbar)
      DEFINE BUTTONex button_incluir
         picture path_imagens+'incluir.bmp'
         col 005
         row 002
         width 100
         height 100
         caption 'F5 Incluir'
         action incluir_composicao(x_codigo_produto)
         fontname 'verdana'
         fontsize 009
         fontbold .T.
         fontcolor _preto_001
         vertical .T.
         flat .T.
         noxpstyle .T.
         backcolor _branco_001
      END BUTTONex
      DEFINE BUTTONex button_excluir
         picture path_imagens+'excluir.bmp'
         col 107
         row 002
         width 100
         height 100
         caption 'F7 Excluir'
         action excluir_composicao()
         fontname 'verdana'
         fontsize 009
         fontbold .T.
         fontcolor _preto_001
         vertical .T.
         flat .T.
         noxpstyle .T.
         backcolor _branco_001
      END BUTTONex
      DEFINE BUTTONex button_sair
         picture path_imagens+'sair.bmp'
         col 209
         row 002
         width 100
         height 100
         caption 'ESC Voltar'
         action form_compor.release
         fontname 'verdana'
         fontsize 009
         fontbold .T.
         fontcolor _preto_001
         vertical .T.
         flat .T.
         noxpstyle .T.
         backcolor _branco_001
      END BUTTONex

      DEFINE GRID grid_mprima_composicao
         parent form_compor
         col 005
         row 104
         width 585
         height 360
         headers {'id produto','id matéria prima','Nome','Quantidade','Unidade Medida'}
         widths {001,001,300,120,150}
         fontname 'verdana'
         fontsize 010
         fontbold .F.
         nolines .T.
         backcolor _grid_002
         fontcolor BLUE
      END GRID

      on key escape action thiswindow.release

   END WINDOW

   filtra_composicao(x_codigo_produto)

   form_compor.center
   form_compor.activate

   RETURN(nil)

STATIC FUNCTION incluir_composicao(parametro)

   DEFINE WINDOW form_inccpo;
         at 000,000;
         width 400;
         height 200;
         title 'Incluir composição';
         icon path_imagens+'icone.ico';
         modal;
         nosize

      @ 005,005 label lbl_001;
         of form_inccpo;
         value 'Matéria Prima';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 025,005 textbox tbox_001;
         of form_inccpo;
         height 027;
         width 060;
         value 0;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         numeric;
         on enter procura_mprima('form_inccpo','tbox_001')
      @ 025,075 label lbl_nome_mprima;
         of form_inccpo;
         value '';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _azul_001;
         transparent
      @ 065,005 label lbl_002;
         of form_inccpo;
         value 'Quantidade utilizada';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 065,150 getbox tbox_002;
         of form_inccpo;
         height 027;
         width 080;
         value 0;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         picture '@R 9999.999'

      * linha separadora
      DEFINE LABEL linha_rodape
         col 000
         row form_inccpo.height-090
         value ''
         width form_inccpo.width
         height 001
         backcolor _preto_001
         transparent .F.
      END LABEL

      * botões
      DEFINE BUTTONex button_ok
         picture path_imagens+'img_gravar.bmp'
         col form_inccpo.width-225
         row form_inccpo.height-085
         width 120
         height 050
         caption 'Ok, gravar'
         action gravar_composicao(parametro)
         fontbold .T.
         tooltip 'Confirmar as informações digitadas'
         flat .F.
         noxpstyle .T.
      END BUTTONex
      DEFINE BUTTONex button_cancela
         picture path_imagens+'img_voltar.bmp'
         col form_inccpo.width-100
         row form_inccpo.height-085
         width 090
         height 050
         caption 'Voltar'
         action form_inccpo.release
         fontbold .T.
         tooltip 'Sair desta tela sem gravar informações'
         flat .F.
         noxpstyle .T.
      END BUTTONex

      on key escape action thiswindow.release

   END WINDOW

   form_inccpo.center
   form_inccpo.activate

   RETURN(nil)

STATIC FUNCTION gravar_composicao(parametro)

   produto_composto->(dbappend())
   produto_composto->id_produto := parametro
   produto_composto->id_mprima  := form_inccpo.tbox_001.value
   produto_composto->quantidade := form_inccpo.tbox_002.value
   produto_composto->(dbcommit())
   produto_composto->(dbgotop())

   form_inccpo.release

   filtra_composicao(parametro)

   RETURN(nil)

STATIC FUNCTION filtra_composicao(parametro)

   DELETE item all from grid_mprima_composicao of form_compor

   dbselectarea('produto_composto')
   produto_composto->(ordsetfocus('id_produto'))
   produto_composto->(dbgotop())
   produto_composto->(dbseek(parametro))

   IF found()
      WHILE .not. eof()
         add item {produto_composto->id_produto,str(produto_composto->id_mprima,6),acha_mprima(produto_composto->id_mprima),trans(produto_composto->quantidade,'@R 99,999.999'),acha_unidade(_nome_unidade)} to grid_mprima_composicao of form_compor
         produto_composto->(dbskip())
         IF produto_composto->id_produto <> parametro
            EXIT
         ENDIF
      end
   ENDIF

   RETURN(nil)

STATIC FUNCTION excluir()

   LOCAL id := valor_coluna('grid_produtos','form_produtos',4)

   dbselectarea('produtos')
   produtos->(ordsetfocus('codigo'))
   produtos->(dbgotop())
   produtos->(dbseek(id))

   IF .not. found()
      msgexclamation('Selecione uma informação','Atenção')
      produtos->(ordsetfocus('nome_longo'))

      RETURN(nil)
   ELSE
      IF msgyesno('Nome : '+alltrim(produtos->nome_longo),'Excluir')
         IF lock_reg()
            produtos->(dbdelete())
            produtos->(dbunlock())
            produtos->(dbgotop())
         ENDIF
         produtos->(ordsetfocus('nome_longo'))
         atualizar()
      ENDIF
   ENDIF

   RETURN(nil)

STATIC FUNCTION excluir_composicao()

   LOCAL x_id_prod   := valor_coluna('grid_mprima_composicao','form_compor',1)
   LOCAL x_id_mprima := val(valor_coluna('grid_mprima_composicao','form_compor',2))

   IF empty(x_id_prod) .or. empty(x_id_mprima)
      msgexclamation('Selecione uma informação','Atenção')

      RETURN(nil)
   ELSE
      IF msgyesno('Confirma ?','Excluir')
         dbselectarea('produto_composto')
         produto_composto->(dbgotop())
         WHILE .not. eof()
            IF produto_composto->id_produto == x_id_prod .and. produto_composto->id_mprima == x_id_mprima
               IF lock_reg()
                  produto_composto->(dbdelete())
                  produto_composto->(dbunlock())
                  EXIT
               ENDIF
            ENDIF
            produto_composto->(dbskip())
         end
         filtra_composicao(x_id_prod)
      ENDIF
   ENDIF

   RETURN(nil)

STATIC FUNCTION relacao()

   LOCAL p_linha := 040
   LOCAL u_linha := 260
   LOCAL linha   := p_linha
   LOCAL pagina  := 1

   dbselectarea('produtos')
   produtos->(ordsetfocus('nome_longo'))
   produtos->(dbgotop())

   SELECT PRINTER DIALOG PREVIEW

   START PRINTDOC NAME 'Gerenciador de impressão'
      START PRINTPAGE

         cabecalho(pagina)

         WHILE .not. eof()

            @ linha,010 PRINT produtos->codigo FONT 'courier new' SIZE 010
            @ linha,030 PRINT produtos->nome_longo FONT 'courier new' SIZE 010
            @ linha,110 PRINT iif(produtos->pizza,'Sim','Não') FONT 'courier new' SIZE 010
            @ linha,140 PRINT iif(produtos->baixa,'Sim','Não') FONT 'courier new' SIZE 010
            @ linha,170 PRINT alltrim(str(produtos->qtd_estoq)) FONT 'courier new' SIZE 010

            linha += 5

            IF linha >= u_linha
            END PRINTPAGE
            START PRINTPAGE
               pagina ++
               cabecalho(pagina)
               linha := p_linha
            ENDIF

            produtos->(dbskip())

         end

         rodape()

      END PRINTPAGE
   END PRINTDOC

   RETURN(nil)

STATIC FUNCTION cabecalho(p_pagina)

   @ 007,010 PRINT IMAGE path_imagens+'logotipo.bmp' WIDTH 050 HEIGHT 020 STRETCH
   @ 010,070 PRINT 'RELAÇÃO DE PRODUTOS (simples)' FONT 'courier new' SIZE 018 BOLD
   @ 018,070 PRINT 'ordem alfabética' FONT 'courier new' SIZE 014
   @ 024,070 PRINT 'página : '+strzero(p_pagina,4) FONT 'courier new' SIZE 012

   @ 030,000 PRINT LINE TO 030,205 PENWIDTH 0.5 COLOR _preto_001

   @ 035,010 PRINT 'CÓDIGO' FONT 'courier new' SIZE 010 BOLD
   @ 035,030 PRINT 'NOME (longo)' FONT 'courier new' SIZE 010 BOLD
   @ 035,110 PRINT 'PIZZA' FONT 'courier new' SIZE 010 BOLD
   @ 035,140 PRINT 'BAIXA EST.' FONT 'courier new' SIZE 010 BOLD
   @ 035,170 PRINT 'QTD. EST.' FONT 'courier new' SIZE 010 BOLD

   RETURN(nil)

STATIC FUNCTION rodape()

   @ 275,000 PRINT LINE TO 275,205 PENWIDTH 0.5 COLOR _preto_001
   @ 276,010 PRINT 'impresso em '+dtoc(date())+' as '+time() FONT 'courier new' SIZE 008

   RETURN(nil)

STATIC FUNCTION gravar(parametro)

   LOCAL codigo  := form_dados.tbox_001.value
   LOCAL retorna := .F.

   IF empty(form_dados.tbox_001.value)
      retorna := .T.
   ENDIF
   IF empty(form_dados.tbox_002.value)
      retorna := .T.
   ENDIF

   IF retorna
      msgalert('Preencha todos os campos','Atenção')

      RETURN(nil)
   ENDIF

   IF parametro == 1
      dbselectarea('produtos')
      produtos->(ordsetfocus('codigo'))
      produtos->(dbgotop())
      produtos->(dbseek(codigo))
      IF found()
         msgalert('Este CÓDIGO JÁ EXISTE, tecle ENTER','Atenção')

         RETURN(nil)
      ELSE
         IF l_demo
            IF reccount() > _limite_registros
               msgstop('Limite de registros esgotado','Atenção')

               RETURN(nil)
            ENDIF
         ENDIF
         produtos->(dbappend())
         produtos->codigo     := form_dados.tbox_001.value
         produtos->cbarra     := form_dados.tbox_004.value
         produtos->nome_longo := form_dados.tbox_002.value
         produtos->nome_cupom := form_dados.tbox_003.value
         produtos->categoria  := form_dados.tbox_008.value
         produtos->scategoria := form_dados.tbox_009.value
         produtos->imposto    := form_dados.tbox_013.value
         produtos->baixa      := form_dados.tbox_007.value
         produtos->qtd_estoq  := form_dados.tbox_010.value
         produtos->qtd_min    := form_dados.tbox_011.value
         produtos->qtd_max    := form_dados.tbox_012.value
         produtos->vlr_custo  := form_dados.tbox_014.value
         produtos->vlr_venda  := form_dados.tbox_015.value
         produtos->promocao   := form_dados.tbox_006.value
         produtos->pizza      := form_dados.tbox_005.value
         produtos->val_tm_001 := form_dados.tbox_preco_001.value
         produtos->val_tm_002 := form_dados.tbox_preco_002.value
         produtos->val_tm_003 := form_dados.tbox_preco_003.value
         produtos->val_tm_004 := form_dados.tbox_preco_004.value
         produtos->val_tm_005 := form_dados.tbox_preco_005.value
         produtos->val_tm_006 := form_dados.tbox_preco_006.value
         produtos->(dbcommit())
         produtos->(dbgotop())
         form_dados.release
         atualizar()
      ENDIF
   ELSEIF parametro == 2
      dbselectarea('produtos')
      IF lock_reg()
         produtos->cbarra     := form_dados.tbox_004.value
         produtos->nome_longo := form_dados.tbox_002.value
         produtos->nome_cupom := form_dados.tbox_003.value
         produtos->categoria  := form_dados.tbox_008.value
         produtos->scategoria := form_dados.tbox_009.value
         produtos->imposto    := form_dados.tbox_013.value
         produtos->baixa      := form_dados.tbox_007.value
         produtos->qtd_estoq  := form_dados.tbox_010.value
         produtos->qtd_min    := form_dados.tbox_011.value
         produtos->qtd_max    := form_dados.tbox_012.value
         produtos->vlr_custo  := form_dados.tbox_014.value
         produtos->vlr_venda  := form_dados.tbox_015.value
         produtos->promocao   := form_dados.tbox_006.value
         produtos->pizza      := form_dados.tbox_005.value
         produtos->val_tm_001 := form_dados.tbox_preco_001.value
         produtos->val_tm_002 := form_dados.tbox_preco_002.value
         produtos->val_tm_003 := form_dados.tbox_preco_003.value
         produtos->val_tm_004 := form_dados.tbox_preco_004.value
         produtos->val_tm_005 := form_dados.tbox_preco_005.value
         produtos->val_tm_006 := form_dados.tbox_preco_006.value
         produtos->(dbcommit())
         produtos->(dbunlock())
         produtos->(dbgotop())
      ENDIF
      form_dados.release
      atualizar()
   ENDIF

   RETURN(nil)

STATIC FUNCTION pesquisar()

   LOCAL cPesq        := alltrim(form_produtos.tbox_pesquisa.value)
   LOCAL lGridFreeze  := .T.
   LOCAL nTamNomePesq := len(cPesq)

   dbselectarea('produtos')
   produtos->(ordsetfocus('nome_longo'))
   produtos->(dbseek(cPesq))

   IF lGridFreeze
      form_produtos.grid_produtos.disableupdate
   ENDIF

   DELETE item all from grid_produtos of form_produtos

   WHILE .not. eof()
      IF substr(field->nome_longo,1,nTamNomePesq) == cPesq
         add item {iif(produtos->pizza,'Sim','Não'),iif(produtos->promocao,'Sim','Não'),iif(produtos->baixa,'Sim','Não'),alltrim(produtos->codigo),alltrim(produtos->cbarra),alltrim(produtos->nome_longo),str(produtos->qtd_estoq,6)} to grid_produtos of form_produtos
      ELSEIF substr(field->nome_longo,1,nTamNomePesq) > cPesq
         EXIT
      ENDIF
      produtos->(dbskip())
   end

   IF lGridFreeze
      form_produtos.grid_produtos.enableupdate
   ENDIF

   RETURN(nil)

STATIC FUNCTION atualizar()

   DELETE item all from grid_produtos of form_produtos

   dbselectarea('produtos')
   produtos->(ordsetfocus('nome_longo'))
   produtos->(dbgotop())

   WHILE .not. eof()
      add item {iif(produtos->pizza,'Sim','Não'),iif(produtos->promocao,'Sim','Não'),iif(produtos->baixa,'Sim','Não'),alltrim(produtos->codigo),alltrim(produtos->cbarra),alltrim(produtos->nome_longo),str(produtos->qtd_estoq,6)} to grid_produtos of form_produtos
      produtos->(dbskip())
   end

   RETURN(nil)

STATIC FUNCTION procura_categoria(cform,ctextbtn)

   LOCAL flag    := .F.
   LOCAL creg    := ''
   LOCAL nreg_01 := getproperty(cform,ctextbtn,'value')
   LOCAL nreg_02 := nreg_01

   dbselectarea('categoria_produtos')
   categoria_produtos->(ordsetfocus('codigo'))
   categoria_produtos->(dbgotop())
   categoria_produtos->(dbseek(nreg_02))
   IF found()
      flag := .T.
   ELSE
      creg := getcode_categoria_produtos(getproperty(cform,ctextbtn,'value'))
      dbselectarea('categoria_produtos')
      categoria_produtos->(ordsetfocus('codigo'))
      categoria_produtos->(dbgotop())
      categoria_produtos->(dbseek(creg))
      IF found()
         flag := .T.
      ENDIF
   ENDIF

   IF flag
      setproperty('form_dados','lbl_nome_categoria','value',categoria_produtos->nome)
   ENDIF

   IF !empty(creg)
      setproperty(cform,ctextbtn,'value',creg)
   ENDIF

   RETURN(nil)

STATIC FUNCTION getcode_categoria_produtos(value)

   LOCAL creg := ''
   LOCAL nreg := 1

   dbselectarea('categoria_produtos')
   categoria_produtos->(ordsetfocus('nome'))
   categoria_produtos->(dbgotop())

   DEFINE WINDOW form_pesquisa;
         at 000,000;
         width 490;
         height 500;
         title 'Pesquisa por nome';
         icon path_imagens+'icone.ico';
         modal;
         nosize

      DEFINE LABEL label_pesquisa
         col 005
         row 440
         value 'Buscar'
         autosize .T.
         fontname 'verdana'
         fontsize 012
         fontbold .T.
         fontcolor _preto_001
         transparent .T.
      END LABEL
      DEFINE TEXTBOX txt_pesquisa
         col 075
         row 440
         width 400
         maxlength 040
         onchange find_categoria_produtos()
         uppercase .T.
      END TEXTBOX

      DEFINE BROWSE browse_pesquisa
         row 002
         col 002
         width 480
         height 430
         headers {'Código','Nome'}
         widths {080,370}
         workarea categoria_produtos
         fields {'categoria_produtos->codigo','categoria_produtos->nome'}
         value nreg
         fontname 'verdana'
         fontsize 010
         fontbold .T.
         backcolor _ciano_001
         nolines .T.
         lock .T.
         READonly {.T.,.T.}
         justify {BROWSE_JTFY_LEFT,BROWSE_JTFY_LEFT}
         on dblclick (creg:=categoria_produtos->codigo,thiswindow.release)
      end browse

      on key escape action thiswindow.release

   END WINDOW

   form_pesquisa.browse_pesquisa.setfocus

   form_pesquisa.center
   form_pesquisa.activate

   RETURN(creg)

STATIC FUNCTION find_categoria_produtos()

   LOCAL pesquisa := alltrim(form_pesquisa.txt_pesquisa.value)

   categoria_produtos->(dbgotop())

   IF pesquisa == ''

      RETURN(nil)
   ELSEIF categoria_produtos->(dbseek(pesquisa))
      form_pesquisa.browse_pesquisa.value := categoria_produtos->(recno())
   ENDIF

   RETURN(nil)

STATIC FUNCTION procura_subcategoria(cform,ctextbtn)

   LOCAL flag    := .F.
   LOCAL creg    := ''
   LOCAL nreg_01 := getproperty(cform,ctextbtn,'value')
   LOCAL nreg_02 := nreg_01

   dbselectarea('subcategoria_produtos')
   subcategoria_produtos->(ordsetfocus('codigo'))
   subcategoria_produtos->(dbgotop())
   subcategoria_produtos->(dbseek(nreg_02))
   IF found()
      flag := .T.
   ELSE
      creg := getcode_subcategoria_produtos(getproperty(cform,ctextbtn,'value'))
      dbselectarea('subcategoria_produtos')
      subcategoria_produtos->(ordsetfocus('codigo'))
      subcategoria_produtos->(dbgotop())
      subcategoria_produtos->(dbseek(creg))
      IF found()
         flag := .T.
      ENDIF
   ENDIF

   IF flag
      setproperty('form_dados','lbl_nome_subcategoria','value',subcategoria_produtos->nome)
   ENDIF

   IF !empty(creg)
      setproperty(cform,ctextbtn,'value',creg)
   ENDIF

   RETURN(nil)

STATIC FUNCTION getcode_subcategoria_produtos(value)

   LOCAL creg := ''
   LOCAL nreg := 1

   dbselectarea('subcategoria_produtos')
   subcategoria_produtos->(ordsetfocus('nome'))
   subcategoria_produtos->(dbgotop())

   DEFINE WINDOW form_pesquisa;
         at 000,000;
         width 490;
         height 500;
         title 'Pesquisa por nome';
         icon path_imagens+'icone.ico';
         modal;
         nosize

      DEFINE LABEL label_pesquisa
         col 005
         row 440
         value 'Buscar'
         autosize .T.
         fontname 'verdana'
         fontsize 012
         fontbold .T.
         fontcolor _preto_001
         transparent .T.
      END LABEL
      DEFINE TEXTBOX txt_pesquisa
         col 075
         row 440
         width 400
         maxlength 040
         onchange find_subcategoria_produtos()
         uppercase .T.
      END TEXTBOX

      DEFINE BROWSE browse_pesquisa
         row 002
         col 002
         width 480
         height 430
         headers {'Código','Nome'}
         widths {080,370}
         workarea subcategoria_produtos
         fields {'subcategoria_produtos->codigo','subcategoria_produtos->nome'}
         value nreg
         fontname 'verdana'
         fontsize 010
         fontbold .T.
         backcolor _ciano_001
         nolines .T.
         lock .T.
         READonly {.T.,.T.}
         justify {BROWSE_JTFY_LEFT,BROWSE_JTFY_LEFT}
         on dblclick (creg:=subcategoria_produtos->codigo,thiswindow.release)
      end browse

      on key escape action thiswindow.release

   END WINDOW

   form_pesquisa.browse_pesquisa.setfocus

   form_pesquisa.center
   form_pesquisa.activate

   RETURN(creg)

STATIC FUNCTION find_subcategoria_produtos()

   LOCAL pesquisa := alltrim(form_pesquisa.txt_pesquisa.value)

   subcategoria_produtos->(dbgotop())

   IF pesquisa == ''

      RETURN(nil)
   ELSEIF subcategoria_produtos->(dbseek(pesquisa))
      form_pesquisa.browse_pesquisa.value := subcategoria_produtos->(recno())
   ENDIF

   RETURN(nil)

STATIC FUNCTION procura_imposto(cform,ctextbtn)

   LOCAL flag    := .F.
   LOCAL creg    := ''
   LOCAL nreg_01 := getproperty(cform,ctextbtn,'value')
   LOCAL nreg_02 := nreg_01

   dbselectarea('impostos')
   impostos->(ordsetfocus('codigo'))
   impostos->(dbgotop())
   impostos->(dbseek(nreg_02))
   IF found()
      flag := .T.
   ELSE
      creg := getcode_impostos(getproperty(cform,ctextbtn,'value'))
      dbselectarea('impostos')
      impostos->(ordsetfocus('codigo'))
      impostos->(dbgotop())
      impostos->(dbseek(creg))
      IF found()
         flag := .T.
      ENDIF
   ENDIF

   IF flag
      setproperty('form_dados','lbl_nome_imposto','value',impostos->nome)
   ENDIF

   IF !empty(creg)
      setproperty(cform,ctextbtn,'value',creg)
   ENDIF

   RETURN(nil)

STATIC FUNCTION getcode_impostos(value)

   LOCAL creg := ''
   LOCAL nreg := 1

   dbselectarea('impostos')
   impostos->(ordsetfocus('nome'))
   impostos->(dbgotop())

   DEFINE WINDOW form_pesquisa;
         at 000,000;
         width 490;
         height 500;
         title 'Pesquisa por nome';
         icon path_imagens+'icone.ico';
         modal;
         nosize

      DEFINE LABEL label_pesquisa
         col 005
         row 440
         value 'Buscar'
         autosize .T.
         fontname 'verdana'
         fontsize 012
         fontbold .T.
         fontcolor _preto_001
         transparent .T.
      END LABEL
      DEFINE TEXTBOX txt_pesquisa
         col 075
         row 440
         width 400
         maxlength 040
         onchange find_impostos()
         uppercase .T.
      END TEXTBOX

      DEFINE BROWSE browse_pesquisa
         row 002
         col 002
         width 480
         height 430
         headers {'Código','Nome'}
         widths {080,370}
         workarea impostos
         fields {'impostos->codigo','impostos->nome'}
         value nreg
         fontname 'verdana'
         fontsize 010
         fontbold .T.
         backcolor _ciano_001
         nolines .T.
         lock .T.
         READonly {.T.,.T.}
         justify {BROWSE_JTFY_LEFT,BROWSE_JTFY_LEFT}
         on dblclick (creg:=impostos->codigo,thiswindow.release)
      end browse

      on key escape action thiswindow.release

   END WINDOW

   form_pesquisa.browse_pesquisa.setfocus

   form_pesquisa.center
   form_pesquisa.activate

   RETURN(creg)

STATIC FUNCTION find_impostos()

   LOCAL pesquisa := alltrim(form_pesquisa.txt_pesquisa.value)

   impostos->(dbgotop())

   IF pesquisa == ''

      RETURN(nil)
   ELSEIF impostos->(dbseek(pesquisa))
      form_pesquisa.browse_pesquisa.value := impostos->(recno())
   ENDIF

   RETURN(nil)

STATIC FUNCTION procura_mprima(cform,ctextbtn)

   LOCAL flag    := .F.
   LOCAL creg    := ''
   LOCAL nreg_01 := getproperty(cform,ctextbtn,'value')
   LOCAL nreg_02 := nreg_01

   dbselectarea('materia_prima')
   materia_prima->(ordsetfocus('codigo'))
   materia_prima->(dbgotop())
   materia_prima->(dbseek(nreg_02))
   IF found()
      flag := .T.
   ELSE
      creg := getcode_materia_prima(getproperty(cform,ctextbtn,'value'))
      dbselectarea('materia_prima')
      materia_prima->(ordsetfocus('codigo'))
      materia_prima->(dbgotop())
      materia_prima->(dbseek(creg))
      IF found()
         flag := .T.
      ENDIF
   ENDIF

   IF flag
      setproperty('form_inccpo','lbl_nome_mprima','value',materia_prima->nome)
   ENDIF

   IF !empty(creg)
      setproperty(cform,ctextbtn,'value',creg)
   ENDIF

   RETURN(nil)

STATIC FUNCTION getcode_materia_prima(value)

   LOCAL creg := ''
   LOCAL nreg := 1

   dbselectarea('materia_prima')
   materia_prima->(ordsetfocus('nome'))
   materia_prima->(dbgotop())

   DEFINE WINDOW form_pesquisa;
         at 000,000;
         width 490;
         height 500;
         title 'Pesquisa por nome';
         icon path_imagens+'icone.ico';
         modal;
         nosize

      DEFINE LABEL label_pesquisa
         col 005
         row 440
         value 'Buscar'
         autosize .T.
         fontname 'verdana'
         fontsize 012
         fontbold .T.
         fontcolor _preto_001
         transparent .T.
      END LABEL
      DEFINE TEXTBOX txt_pesquisa
         col 075
         row 440
         width 400
         maxlength 040
         onchange find_materia_prima()
         uppercase .T.
      END TEXTBOX

      DEFINE BROWSE browse_pesquisa
         row 002
         col 002
         width 480
         height 430
         headers {'Código','Nome'}
         widths {080,370}
         workarea materia_prima
         fields {'materia_prima->codigo','materia_prima->nome'}
         value nreg
         fontname 'verdana'
         fontsize 010
         fontbold .T.
         backcolor _ciano_001
         nolines .T.
         lock .T.
         READonly {.T.,.T.}
         justify {BROWSE_JTFY_LEFT,BROWSE_JTFY_LEFT}
         on dblclick (creg:=materia_prima->codigo,thiswindow.release)
      end browse

      on key escape action thiswindow.release

   END WINDOW

   form_pesquisa.browse_pesquisa.setfocus

   form_pesquisa.center
   form_pesquisa.activate

   RETURN(creg)

STATIC FUNCTION find_materia_prima()

   LOCAL pesquisa := alltrim(form_pesquisa.txt_pesquisa.value)

   materia_prima->(dbgotop())

   IF pesquisa == ''

      RETURN(nil)
   ELSEIF materia_prima->(dbseek(pesquisa))
      form_pesquisa.browse_pesquisa.value := materia_prima->(recno())
   ENDIF

   RETURN(nil)

STATIC FUNCTION fornecedores_produto()

   LOCAL x_codigo_produto := valor_coluna('grid_produtos','form_produtos',4)
   LOCAL x_nome_produto   := valor_coluna('grid_produtos','form_produtos',6)

   IF empty(x_nome_produto)
      msgexclamation('Escolha um produto','Atenção')

      RETURN(nil)
   ENDIF

   DEFINE WINDOW form_fornecedor_produto;
         at 000,000;
         width 600;
         height 500;
         title 'Fornecedores de : '+alltrim(x_nome_produto);
         icon path_imagens+'icone.ico';
         modal;
         nosize

      * botões (toolbar)
      DEFINE BUTTONex button_sair
         picture path_imagens+'sair.bmp'
         col 005
         row 002
         width 100
         height 100
         caption 'ESC Voltar'
         action form_fornecedor_produto.release
         fontname 'verdana'
         fontsize 009
         fontbold .T.
         fontcolor _preto_001
         vertical .T.
         flat .T.
         noxpstyle .T.
         backcolor _branco_001
      END BUTTONex

      DEFINE GRID grid_fornecedor_produto
         parent form_fornecedor_produto
         col 005
         row 104
         width 585
         height 360
         headers {'Nome do fornecedor'}
         widths {570}
         fontname 'verdana'
         fontsize 010
         fontbold .F.
         nolines .T.
         backcolor _branco_001
         fontcolor _preto_001
      END GRID

      on key escape action thiswindow.release

   END WINDOW

   filtra_fornecedor(x_codigo_produto)

   form_fornecedor_produto.center
   form_fornecedor_produto.activate

   RETURN(nil)

STATIC FUNCTION filtra_fornecedor(parametro)

   LOCAL x_old_fornecedor := 0

   DELETE item all from grid_fornecedor_produto of form_fornecedor_produto

   dbselectarea('tcompra1')
   INDEX ON fornecedor to indcpa11 for produto == parametro
   GO TOP

   WHILE .not. eof()
      x_old_fornecedor := fornecedor
      SKIP
      IF fornecedor <> x_old_fornecedor
         add item {acha_fornecedor_2(x_old_fornecedor)} to grid_fornecedor_produto of form_fornecedor_produto
      ENDIF
   end

   RETURN(nil)

