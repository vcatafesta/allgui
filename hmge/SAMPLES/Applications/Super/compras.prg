/*
sistema     : superchef pizzaria
programa    : compras - entradas no estoque de produtos e matéria prima
compilador  : xharbour 1.2 simplex
lib gráfica : minigui 1.7 extended
programador : marcelo neves
*/

#include 'minigui.ch'
#include 'super.ch'

FUNCTION compras()

   DEFINE WINDOW form_compras ;
         at 000,000 ;
         WIDTH 1000 ;
         HEIGHT 680 ;
         TITLE 'Compras / Entrada Estoque ( Produtos e Matéria Prima )' ;
         ICON path_imagens+'icone.ico' ;
         modal ;
         nosize ;
         ON INIT zera_temps()

      * linhas separadoras
      DEFINE LABEL label_sep_001
         COL 000
         ROW 140
         VALUE ''
         WIDTH 1000
         HEIGHT 002
         TRANSPARENT .F.
         BACKCOLOR _cinza_002
      END LABEL
      DEFINE LABEL label_sep_002
         COL 000
         ROW 590
         VALUE ''
         WIDTH 1000
         HEIGHT 002
         TRANSPARENT .F.
         BACKCOLOR _cinza_002
      END LABEL
      DEFINE LABEL label_sep_003
         COL 495
         ROW 140
         VALUE ''
         WIDTH 002
         HEIGHT 450
         TRANSPARENT .F.
         BACKCOLOR _cinza_002
      END LABEL

      * solicita fornecedor
      @ 010,005 label lbl_001 ;
         of form_compras ;
         VALUE 'Fornecedor' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 030,005 textbox tbox_001 ;
         of form_compras ;
         HEIGHT 027 ;
         WIDTH 060 ;
         VALUE 0 ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         numeric ;
         ON ENTER procura_fornecedor('form_compras','tbox_001')
      @ 030,070 label lbl_nome_fornecedor ;
         of form_compras ;
         VALUE '' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _azul_001 ;
         TRANSPARENT

      * solicita forma de pagamento
      @ 010,400 label lbl_004 ;
         of form_compras ;
         VALUE 'Forma de pagamento' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 030,400 textbox tbox_004 ;
         of form_compras ;
         HEIGHT 027 ;
         WIDTH 060 ;
         VALUE 0 ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         numeric ;
         ON ENTER procura_forma_pagamento('form_compras','tbox_004')
      @ 030,470 label lbl_nome_forma_pagamento ;
         of form_compras ;
         VALUE '' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _azul_001 ;
         TRANSPARENT

      * solicita número do documento (nf/recibo/etc)
      @ 010,650 label lbl_documento ;
         of form_compras ;
         VALUE 'Nº do documento' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 030,650 textbox tbox_documento ;
         of form_compras ;
         HEIGHT 027 ;
         WIDTH 200 ;
         VALUE '' ;
         MAXLENGTH 020 ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE

      * número de parcelas
      @ 070,005 label lbl_005 ;
         of form_compras ;
         VALUE 'Nº de parcelas' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 070,110 getbox tbox_005 ;
         of form_compras ;
         HEIGHT 027 ;
         WIDTH 060 ;
         VALUE 1 ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         PICTURE '@R 999'

      * vencimento
      @ 070,180 label lbl_006 ;
         of form_compras ;
         VALUE 'Data de vencimento (se for uma única parcela) ou Data início da primeira parcela' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 070,715 textbox tbox_006 ;
         of form_compras ;
         HEIGHT 027 ;
         WIDTH 100 ;
         VALUE date() ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         date

      * dias entre as parcelas
      @ 100,180 label lbl_007 ;
         of form_compras ;
         VALUE 'Caso a compra seja parcelada, digite a quantidade de dias entre as parcelas' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 120,180 label lbl_008 ;
         of form_compras ;
         VALUE 'para que o programa possa calcular os vencimentos futuros.' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 110,715 getbox tbox_008 ;
         of form_compras ;
         HEIGHT 027 ;
         WIDTH 060 ;
         VALUE 0 ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         PICTURE '@R 999'

      *                    *
      * compra de produtos *
      *                    *

      * escolher código do produto
      @ 150,005 label label_produto ;
         of form_compras ;
         VALUE 'Produto' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 170,005 textbox tbox_produto ;
         of form_compras ;
         HEIGHT 030 ;
         WIDTH 060 ;
         VALUE '' ;
         MAXLENGTH 015 ;
         FONT 'tahoma' size 010 ;
         bold ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         ON ENTER procura_produto_2()
      @ 170,075 label label_nome_produto ;
         of form_compras ;
         VALUE '' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR BLUE ;
         TRANSPARENT
      * quantidade
      @ 210,005 label lbl_002 ;
         of form_compras ;
         VALUE 'Quantidade' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 230,005 getbox tbox_002 ;
         of form_compras ;
         HEIGHT 027 ;
         WIDTH 120 ;
         VALUE 0 ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         PICTURE '@R 999999'
      * valor da compra
      @ 210,135 label lbl_003 ;
         of form_compras ;
         VALUE 'Valor Unitário R$' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 230,135 getbox tbox_003 ;
         of form_compras ;
         HEIGHT 027 ;
         WIDTH 120 ;
         VALUE 0 ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         PICTURE '@E 999,999.99'
      * botão para confirmar
      @ 217,265 buttonex botao_confirmar_001 ;
         PARENT form_compras ;
         CAPTION 'Confirma' ;
         WIDTH 115 height 040 ;
         PICTURE path_imagens+'adicionar.bmp' ;
         ACTION gravar_produto()
      * botão para excluir
      @ 217,385 buttonex botao_excluir_produto ;
         PARENT form_compras ;
         CAPTION 'Excluir' ;
         WIDTH 100 height 040 ;
         PICTURE path_imagens+'excluir_item.bmp' ;
         ACTION excluir_produto() ;
         NOTABSTOP
      * grid
      DEFINE GRID grid_produtos
         PARENT form_compras
         COL 005
         ROW 265
         WIDTH 480
         HEIGHT 320
         HEADERS {'id','Fornecedor','Produto','Qtd.','Unitário R$','Subtotal R$'}
         WIDTHS {001,250,200,100,120,120}
         FONTNAME 'verdana'
         FONTSIZE 010
         FONTBOLD .T.
         BACKCOLOR _amarelo_001
         FONTCOLOR _preto_001
      END GRID

      *                         *
      * compra de matéria prima *
      *                         *

      * escolher código da matéria prima
      @ 150,505 label label_mprima ;
         of form_compras ;
         VALUE 'Matéria prima' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 170,505 textbox tbox_mprima ;
         of form_compras ;
         HEIGHT 027 ;
         WIDTH 060 ;
         VALUE 0 ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         numeric ;
         ON ENTER procura_mprima_2('form_compras','tbox_mprima')
      @ 170,570 label lbl_nome_mprima ;
         of form_compras ;
         VALUE '' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _azul_001 ;
         TRANSPARENT
      * quantidade
      @ 210,505 label lbl_002_2 ;
         of form_compras ;
         VALUE 'Quantidade' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 230,505 getbox tbox_002_2 ;
         of form_compras ;
         HEIGHT 027 ;
         WIDTH 120 ;
         VALUE 0 ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         PICTURE '@R 999,999.999'
      * valor da compra
      @ 210,635 label lbl_003_2 ;
         of form_compras ;
         VALUE 'Valor Unitário R$' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 230,635 getbox tbox_003_2 ;
         of form_compras ;
         HEIGHT 027 ;
         WIDTH 120 ;
         VALUE 0 ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         PICTURE '@E 999,999.99'
      * botão para confirmar
      @ 217,765 buttonex botao_confirmar_002 ;
         PARENT form_compras ;
         CAPTION 'Confirma' ;
         WIDTH 115 height 040 ;
         PICTURE path_imagens+'adicionar.bmp' ;
         ACTION gravar_mprima()
      * botão para excluir
      @ 217,885 buttonex botao_excluir_mprima ;
         PARENT form_compras ;
         CAPTION 'Excluir' ;
         WIDTH 100 height 040 ;
         PICTURE path_imagens+'excluir_item.bmp' ;
         ACTION excluir_mprima() ;
         NOTABSTOP
      DEFINE GRID grid_materia_prima
         PARENT form_compras
         COL 505
         ROW 265
         WIDTH 485
         HEIGHT 320
         HEADERS {'id','Fornecedor','Matéria Prima','Qtd.','Unitário R$','Subtotal R$'}
         WIDTHS {001,250,200,100,120,120}
         FONTNAME 'verdana'
         FONTSIZE 010
         FONTBOLD .T.
         BACKCOLOR _amarelo_001
         FONTCOLOR _preto_001
      END GRID

      @ 595,635 buttonex botao_gravar ;
         PARENT form_compras ;
         PICTURE path_imagens+'img_salvar.bmp' ;
         CAPTION 'Gravar as informações' ;
         WIDTH 200 height 050 ;
         ACTION gravar_compras() ;
         bold ;
         TOOLTIP 'Clique aqui para gravar todas as informações'
      @ 595,840 buttonex botao_sair ;
         PARENT form_compras ;
         PICTURE path_imagens+'img_sair.bmp' ;
         CAPTION 'Sair desta tela' ;
         WIDTH 150 height 050 ;
         ACTION form_compras.release ;
         bold ;
         TOOLTIP 'Sair desta tela sem gravar informações'

      ON KEY ESCAPE ACTION thiswindow.release

   END WINDOW

   form_compras.center
   form_compras.activate

   RETURN NIL

STATIC FUNCTION procura_fornecedor(cform,ctextbtn)

   LOCAL flag    := .F.
   LOCAL creg    := ''
   LOCAL nreg_01 := getproperty(cform,ctextbtn,'value')
   LOCAL nreg_02 := nreg_01

   dbselectarea('fornecedores')
   fornecedores->(ordsetfocus('codigo'))
   fornecedores->(dbgotop())
   fornecedores->(dbseek(nreg_02))
   IF found()
      flag := .T.
   ELSE
      creg := getcode_fornecedor(getproperty(cform,ctextbtn,'value'))
      dbselectarea('fornecedores')
      fornecedores->(ordsetfocus('codigo'))
      fornecedores->(dbgotop())
      fornecedores->(dbseek(creg))
      IF found()
         flag := .T.
      ENDIF
   ENDIF

   IF flag
      setproperty('form_compras','lbl_nome_fornecedor','value',fornecedores->nome)
   ENDIF

   IF !empty(creg)
      setproperty(cform,ctextbtn,'value',creg)
   ENDIF

   RETURN NIL

STATIC FUNCTION getcode_fornecedor(value)

   LOCAL creg := ''
   LOCAL nreg := 1

   dbselectarea('fornecedores')
   fornecedores->(ordsetfocus('nome'))
   fornecedores->(dbgotop())

   DEFINE WINDOW form_pesquisa ;
         at 000,000 ;
         WIDTH 490 ;
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
         WIDTH 400
         MAXLENGTH 040
         ONCHANGE find_fornecedor()
         UPPERCASE .T.
      END TEXTBOX

      DEFINE BROWSE browse_pesquisa
         ROW 002
         COL 002
         WIDTH 480
         HEIGHT 430
         HEADERS {'Código','Nome'}
         WIDTHS {080,370}
         WORKAREA fornecedores
         FIELDS {'fornecedores->codigo','fornecedores->nome'}
         VALUE nreg
         FONTNAME 'verdana'
         FONTSIZE 010
         FONTBOLD .T.
         BACKCOLOR _ciano_001
         NOLINES .T.
         LOCK .T.
         READONLY {.T.,.T.}
         JUSTIFY {BROWSE_JTFY_LEFT,BROWSE_JTFY_LEFT}
         ON DBLCLICK (creg:=fornecedores->codigo,thiswindow.release)
      END BROWSE

      ON KEY ESCAPE ACTION thiswindow.release

   END WINDOW

   form_pesquisa.browse_pesquisa.setfocus

   form_pesquisa.center
   form_pesquisa.activate

   return(creg)

STATIC FUNCTION find_fornecedor()

   LOCAL pesquisa := alltrim(form_pesquisa.txt_pesquisa.value)

   fornecedores->(dbgotop())

   IF pesquisa == ''

      RETURN NIL
   ELSEIF fornecedores->(dbseek(pesquisa))
      form_pesquisa.browse_pesquisa.value := fornecedores->(recno())
   ENDIF

   RETURN NIL

STATIC FUNCTION procura_forma_pagamento(cform,ctextbtn)

   LOCAL flag    := .F.
   LOCAL creg    := ''
   LOCAL nreg_01 := getproperty(cform,ctextbtn,'value')
   LOCAL nreg_02 := nreg_01

   dbselectarea('formas_pagamento')
   formas_pagamento->(ordsetfocus('codigo'))
   formas_pagamento->(dbgotop())
   formas_pagamento->(dbseek(nreg_02))
   IF found()
      flag := .T.
   ELSE
      creg := getcode_forma_pagamento(getproperty(cform,ctextbtn,'value'))
      dbselectarea('formas_pagamento')
      formas_pagamento->(ordsetfocus('codigo'))
      formas_pagamento->(dbgotop())
      formas_pagamento->(dbseek(creg))
      IF found()
         flag := .T.
      ENDIF
   ENDIF

   IF flag
      setproperty('form_compras','lbl_nome_forma_pagamento','value',formas_pagamento->nome)
   ENDIF

   IF !empty(creg)
      setproperty(cform,ctextbtn,'value',creg)
   ENDIF

   RETURN NIL

STATIC FUNCTION getcode_forma_pagamento(value)

   LOCAL creg := ''
   LOCAL nreg := 1

   dbselectarea('formas_pagamento')
   formas_pagamento->(ordsetfocus('nome'))
   formas_pagamento->(dbgotop())

   DEFINE WINDOW form_pesquisa ;
         at 000,000 ;
         WIDTH 490 ;
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
         WIDTH 400
         MAXLENGTH 040
         ONCHANGE find_forma_pagamento()
         UPPERCASE .T.
      END TEXTBOX

      DEFINE BROWSE browse_pesquisa
         ROW 002
         COL 002
         WIDTH 480
         HEIGHT 430
         HEADERS {'Código','Nome'}
         WIDTHS {080,370}
         WORKAREA formas_pagamento
         FIELDS {'formas_pagamento->codigo','formas_pagamento->nome'}
         VALUE nreg
         FONTNAME 'verdana'
         FONTSIZE 010
         FONTBOLD .T.
         BACKCOLOR _ciano_001
         NOLINES .T.
         LOCK .T.
         READONLY {.T.,.T.}
         JUSTIFY {BROWSE_JTFY_LEFT,BROWSE_JTFY_LEFT}
         ON DBLCLICK (creg:=formas_pagamento->codigo,thiswindow.release)
      END BROWSE

      ON KEY ESCAPE ACTION thiswindow.release

   END WINDOW

   form_pesquisa.browse_pesquisa.setfocus

   form_pesquisa.center
   form_pesquisa.activate

   return(creg)

STATIC FUNCTION find_forma_pagamento()

   LOCAL pesquisa := alltrim(form_pesquisa.txt_pesquisa.value)

   formas_pagamento->(dbgotop())

   IF pesquisa == ''

      RETURN NIL
   ELSEIF formas_pagamento->(dbseek(pesquisa))
      form_pesquisa.browse_pesquisa.value := formas_pagamento->(recno())
   ENDIF

   RETURN NIL

STATIC FUNCTION procura_produto_2()

   LOCAL x_codigo := form_compras.tbox_produto.value

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
            mostra_listagem_produto_2()

            RETURN NIL
         ELSE
            form_compras.tbox_produto.setfocus

            RETURN NIL
         ENDIF
      ELSE
         setproperty('form_compras','label_nome_produto','value',produtos->nome_longo)

         RETURN NIL
      ENDIF
   ELSE
      mostra_listagem_produto_2()
   ENDIF

   RETURN NIL

STATIC FUNCTION mostra_listagem_produto_2()

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
         HEADERS {'','Nome','Preço R$'}
         WIDTHS {001,395,150}
         SHOWHEADERS .F.
         NOLINES .T.
         FONTNAME 'courier new'
         FONTSIZE 012
         BACKCOLOR _ciano_001
         FONTCOLOR _preto_001
         ONDBLCLICK mostra_informacao_produto_2()
      END GRID

      ON KEY ESCAPE ACTION thiswindow.release

   END WINDOW

   separa_produto_2()
   form_pesquisa.grid_pesquisa.setfocus
   form_pesquisa.grid_pesquisa.value := 1

   form_pesquisa.center
   form_pesquisa.activate

   RETURN NIL

STATIC FUNCTION separa_produto_2()

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

STATIC FUNCTION mostra_informacao_produto_2()

   LOCAL x_codigo := valor_coluna('grid_pesquisa','form_pesquisa',1)
   LOCAL x_nome   := valor_coluna('grid_pesquisa','form_pesquisa',2)
   LOCAL x_preco  := 0

   setproperty('form_compras','tbox_produto','value',alltrim(x_codigo))
   setproperty('form_compras','label_nome_produto','value',alltrim(x_nome))

   dbselectarea('produtos')
   produtos->(ordsetfocus('codigo'))
   produtos->(dbgotop())
   produtos->(dbseek(x_codigo))
   IF found()
      x_preco := produtos->vlr_venda
   ENDIF

   form_pesquisa.release

   RETURN NIL

STATIC FUNCTION procura_mprima_2(cform,ctextbtn)

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
      creg := getcode_materia_prima_2(getproperty(cform,ctextbtn,'value'))
      dbselectarea('materia_prima')
      materia_prima->(ordsetfocus('codigo'))
      materia_prima->(dbgotop())
      materia_prima->(dbseek(creg))
      IF found()
         flag := .T.
      ENDIF
   ENDIF

   IF flag
      setproperty('form_compras','lbl_nome_mprima','value',materia_prima->nome)
   ENDIF

   IF !empty(creg)
      setproperty(cform,ctextbtn,'value',creg)
   ENDIF

   RETURN NIL

STATIC FUNCTION getcode_materia_prima_2(value)

   LOCAL creg := ''
   LOCAL nreg := 1

   dbselectarea('materia_prima')
   materia_prima->(ordsetfocus('nome'))
   materia_prima->(dbgotop())

   DEFINE WINDOW form_pesquisa ;
         at 000,000 ;
         WIDTH 490 ;
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
         WIDTH 400
         MAXLENGTH 040
         ONCHANGE find_materia_prima_2()
         UPPERCASE .T.
      END TEXTBOX

      DEFINE BROWSE browse_pesquisa
         ROW 002
         COL 002
         WIDTH 480
         HEIGHT 430
         HEADERS {'Código','Nome'}
         WIDTHS {080,370}
         WORKAREA materia_prima
         FIELDS {'materia_prima->codigo','materia_prima->nome'}
         VALUE nreg
         FONTNAME 'verdana'
         FONTSIZE 010
         FONTBOLD .T.
         BACKCOLOR _ciano_001
         NOLINES .T.
         LOCK .T.
         READONLY {.T.,.T.}
         JUSTIFY {BROWSE_JTFY_LEFT,BROWSE_JTFY_LEFT}
         ON DBLCLICK (creg:=materia_prima->codigo,thiswindow.release)
      END BROWSE

      ON KEY ESCAPE ACTION thiswindow.release

   END WINDOW

   form_pesquisa.browse_pesquisa.setfocus

   form_pesquisa.center
   form_pesquisa.activate

   return(creg)

STATIC FUNCTION find_materia_prima_2()

   LOCAL pesquisa := alltrim(form_pesquisa.txt_pesquisa.value)

   materia_prima->(dbgotop())

   IF pesquisa == ''

      RETURN NIL
   ELSEIF materia_prima->(dbseek(pesquisa))
      form_pesquisa.browse_pesquisa.value := materia_prima->(recno())
   ENDIF

   RETURN NIL

STATIC FUNCTION gravar_produto()

   LOCAL x_id := substr(alltrim(str(HB_RANDOM(4000385713,9999999999))),1,10)

   tmp_cpa1->(dbappend())
   tmp_cpa1->id         := x_id
   tmp_cpa1->fornecedor := form_compras.tbox_001.value
   tmp_cpa1->forma_pag  := form_compras.tbox_004.value
   tmp_cpa1->num_parc   := form_compras.tbox_005.value
   tmp_cpa1->data_venc  := form_compras.tbox_006.value
   tmp_cpa1->dias_parc  := form_compras.tbox_008.value
   tmp_cpa1->produto    := form_compras.tbox_produto.value
   tmp_cpa1->qtd        := form_compras.tbox_002.value
   tmp_cpa1->vlr_unit   := form_compras.tbox_003.value
   tmp_cpa1->num_doc    := form_compras.tbox_documento.value
   tmp_cpa1->(dbcommit())

   atualiza_produtos()

   form_compras.tbox_produto.setfocus

   RETURN NIL

STATIC FUNCTION atualiza_produtos()

   DELETE item all from grid_produtos of form_compras

   dbselectarea('tmp_cpa1')
   tmp_cpa1->(dbgotop())

   WHILE .not. eof()
      add item {tmp_cpa1->id,acha_fornecedor(tmp_cpa1->fornecedor),acha_produto(tmp_cpa1->produto),trans(tmp_cpa1->qtd,'@R 999999'),trans(tmp_cpa1->vlr_unit,'@E 99,999.99'),trans(tmp_cpa1->qtd*tmp_cpa1->vlr_unit,'@E 999,999.99')} to grid_produtos of form_compras
      tmp_cpa1->(dbskip())
   END

   RETURN NIL

STATIC FUNCTION excluir_produto()

   LOCAL x_id := valor_coluna('grid_produtos','form_compras',1)

   dbselectarea('tmp_cpa1')
   tmp_cpa1->(dbgotop())

   WHILE .not. eof()
      IF tmp_cpa1->id == x_id
         IF msgyesno('Confirma ?','Excluir')
            tmp_cpa1->(dbdelete())
            EXIT
         ENDIF
      ENDIF
      tmp_cpa1->(dbskip())
   END

   atualiza_produtos()

   RETURN NIL

STATIC FUNCTION gravar_mprima()

   LOCAL x_id := substr(alltrim(str(HB_RANDOM(4000385713,9999999999))),1,10)

   tmp_cpa2->(dbappend())
   tmp_cpa2->id         := x_id
   tmp_cpa2->fornecedor := form_compras.tbox_001.value
   tmp_cpa2->forma_pag  := form_compras.tbox_004.value
   tmp_cpa2->num_parc   := form_compras.tbox_005.value
   tmp_cpa2->data_venc  := form_compras.tbox_006.value
   tmp_cpa2->dias_parc  := form_compras.tbox_008.value
   tmp_cpa2->mat_prima  := form_compras.tbox_mprima.value
   tmp_cpa2->qtd        := form_compras.tbox_002_2.value
   tmp_cpa2->vlr_unit   := form_compras.tbox_003_2.value
   tmp_cpa2->num_doc    := form_compras.tbox_documento.value
   tmp_cpa2->(dbcommit())

   atualiza_mprima()

   form_compras.tbox_mprima.setfocus

   RETURN NIL

STATIC FUNCTION atualiza_mprima()

   DELETE item all from grid_materia_prima of form_compras

   dbselectarea('tmp_cpa2')
   tmp_cpa2->(dbgotop())

   WHILE .not. eof()
      add item {tmp_cpa2->id,acha_fornecedor(tmp_cpa2->fornecedor),acha_mprima(tmp_cpa2->mat_prima),trans(tmp_cpa2->qtd,'@R 99,999.999'),trans(tmp_cpa2->vlr_unit,'@E 99,999.99'),trans(tmp_cpa2->qtd*tmp_cpa2->vlr_unit,'@E 999,999.99')} to grid_materia_prima of form_compras
      tmp_cpa2->(dbskip())
   END

   RETURN NIL

STATIC FUNCTION excluir_mprima()

   LOCAL x_id := valor_coluna('grid_materia_prima','form_compras',1)

   dbselectarea('tmp_cpa2')
   tmp_cpa2->(dbgotop())

   WHILE .not. eof()
      IF tmp_cpa2->id == x_id
         IF msgyesno('Confirma ?','Excluir')
            tmp_cpa2->(dbdelete())
            EXIT
         ENDIF
      ENDIF
      tmp_cpa2->(dbskip())
   END

   atualiza_mprima()

   RETURN NIL

STATIC FUNCTION zera_temps()

   dbselectarea('tmp_cpa1')
   ZAP
   PACK

   dbselectarea('tmp_cpa2')
   ZAP
   PACK

   RETURN NIL

STATIC FUNCTION gravar_compras()

   LOCAL x_dbf_1            := 0
   LOCAL x_dbf_2            := 0
   LOCAL x_fornecedor       := 0
   LOCAL x_forma_pagamento  := 0
   LOCAL x_numero_documento := space(15)
   LOCAL x_numero_parcelas  := 0
   LOCAL x_data_vencimento  := ctod('  /  /  ')
   LOCAL x_dias             := 0
   LOCAL x_total            := 0
   LOCAL x_i                := 0

   dbselectarea('tmp_cpa1')
   tmp_cpa1->(dbgotop())
   IF eof()
      x_dbf_1 := 1
   ENDIF

   dbselectarea('tmp_cpa2')
   tmp_cpa2->(dbgotop())
   IF eof()
      x_dbf_2 := 1
   ENDIF

   IF (x_dbf_1+x_dbf_2) == 2
      msginfo('Não existem informações a serem processadas','Atenção')

      RETURN NIL
   ENDIF

   * clonar para as tabelas da rede

   * produtos

   IF x_dbf_1 == 0
      dbselectarea('tmp_cpa1')
      tmp_cpa1->(dbgotop())
      WHILE .not. eof()
         dbselectarea('tcompra1')
         tcompra1->(dbappend())
         tcompra1->fornecedor := tmp_cpa1->fornecedor
         tcompra1->forma_pag  := tmp_cpa1->forma_pag
         tcompra1->num_parc   := tmp_cpa1->num_parc
         tcompra1->data_venc  := tmp_cpa1->data_venc
         tcompra1->dias_parc  := tmp_cpa1->dias_parc
         tcompra1->produto    := tmp_cpa1->produto
         tcompra1->qtd        := tmp_cpa1->qtd
         tcompra1->vlr_unit   := tmp_cpa1->vlr_unit
         tcompra1->num_doc    := tmp_cpa1->num_doc
         tcompra1->(dbcommit())
         dbselectarea('tmp_cpa1')
         tmp_cpa1->(dbskip())
      END
   ENDIF

   * matéria prima

   IF x_dbf_2 == 0
      dbselectarea('tmp_cpa2')
      tmp_cpa2->(dbgotop())
      WHILE .not. eof()
         dbselectarea('tcompra2')
         tcompra2->(dbappend())
         tcompra2->fornecedor := tmp_cpa2->fornecedor
         tcompra2->forma_pag  := tmp_cpa2->forma_pag
         tcompra2->num_parc   := tmp_cpa2->num_parc
         tcompra2->data_venc  := tmp_cpa2->data_venc
         tcompra2->dias_parc  := tmp_cpa2->dias_parc
         tcompra2->mat_prima  := tmp_cpa2->mat_prima
         tcompra2->qtd        := tmp_cpa2->qtd
         tcompra2->vlr_unit   := tmp_cpa2->vlr_unit
         tcompra2->num_doc    := tmp_cpa2->num_doc
         tcompra2->(dbcommit())
         dbselectarea('tmp_cpa2')
         tmp_cpa2->(dbskip())
      END
   ENDIF

   * aumentar quantidade - produto

   IF x_dbf_1 == 0
      dbselectarea('tmp_cpa1')
      tmp_cpa1->(dbgotop())
      WHILE .not. eof()
         dbselectarea('produtos')
         produtos->(ordsetfocus('codigo'))
         produtos->(dbgotop())
         produtos->(dbseek(tmp_cpa1->produto))
         IF found()
            IF lock_reg()
               produtos->qtd_estoq := produtos->qtd_estoq + tmp_cpa1->qtd
               produtos->(dbcommit())
            ENDIF
         ENDIF
         dbselectarea('tmp_cpa1')
         tmp_cpa1->(dbskip())
      END
   ENDIF

   * aumentar quantidade - matéria prima

   IF x_dbf_2 == 0
      dbselectarea('tmp_cpa2')
      tmp_cpa2->(dbgotop())
      WHILE .not. eof()
         dbselectarea('materia_prima')
         materia_prima->(ordsetfocus('codigo'))
         materia_prima->(dbgotop())
         materia_prima->(dbseek(tmp_cpa2->mat_prima))
         IF found()
            IF lock_reg()
               materia_prima->qtd := materia_prima->qtd + tmp_cpa2->qtd
               materia_prima->(dbcommit())
            ENDIF
         ENDIF
         dbselectarea('tmp_cpa2')
         tmp_cpa2->(dbskip())
      END
   ENDIF

   * contas a pagar - produtos

   IF x_dbf_1 == 0
      dbselectarea('tmp_cpa1')
      INDEX ON fornecedor to indpfor
      GO TOP
      WHILE .not. eof()
         x_fornecedor       := tmp_cpa1->fornecedor
         x_forma_pagamento  := tmp_cpa1->forma_pag
         x_numero_documento := tmp_cpa1->num_doc
         x_numero_parcelas  := tmp_cpa1->num_parc
         x_data_vencimento  := tmp_cpa1->data_venc
         x_dias             := tmp_cpa1->dias_parc
         x_total            := x_total + (tmp_cpa1->qtd*tmp_cpa1->vlr_unit)
         SKIP
         IF tmp_cpa1->fornecedor <> x_fornecedor
            dbselectarea('contas_pagar')
            FOR x_i := 1 to x_numero_parcelas
               contas_pagar->(dbappend())
               IF x_i > 1
                  contas_pagar->data   := x_data_vencimento + x_dias
               ELSE
                  contas_pagar->data   := x_data_vencimento
               ENDIF
               contas_pagar->valor  := (x_total/x_numero_parcelas)
               contas_pagar->forma  := x_forma_pagamento
               contas_pagar->fornec := x_fornecedor
               contas_pagar->numero := x_numero_documento
               contas_pagar->id     := substr(alltrim(str(HB_RANDOM(0001240003,9999999999))),1,10)
               contas_pagar->(dbcommit())
            NEXT x_i
         ENDIF
      END
   ENDIF

   * contas a pagar - matéria prima

   IF x_dbf_2 == 0
      dbselectarea('tmp_cpa2')
      INDEX ON fornecedor to indmfor
      GO TOP
      WHILE .not. eof()
         x_fornecedor       := tmp_cpa2->fornecedor
         x_forma_pagamento  := tmp_cpa2->forma_pag
         x_numero_documento := tmp_cpa2->num_doc
         x_numero_parcelas  := tmp_cpa2->num_parc
         x_data_vencimento  := tmp_cpa2->data_venc
         x_dias             := tmp_cpa2->dias_parc
         x_total            := x_total + (tmp_cpa2->qtd*tmp_cpa2->vlr_unit)
         SKIP
         IF tmp_cpa2->fornecedor <> x_fornecedor
            dbselectarea('contas_pagar')
            FOR x_i := 1 to x_numero_parcelas
               contas_pagar->(dbappend())
               IF x_i > 1
                  contas_pagar->data   := x_data_vencimento + x_dias
               ELSE
                  contas_pagar->data   := x_data_vencimento
               ENDIF
               contas_pagar->valor  := (x_total/x_numero_parcelas)
               contas_pagar->forma  := x_forma_pagamento
               contas_pagar->fornec := x_fornecedor
               contas_pagar->numero := x_numero_documento
               contas_pagar->id     := substr(alltrim(str(HB_RANDOM(0001240003,9999999999))),1,10)
               contas_pagar->(dbcommit())
            NEXT x_i
         ENDIF
      END
   ENDIF

   msginfo('Informações gravadas com sucesso, tecle ENTER','Mensagem')

   form_compras.release

   RETURN NIL
