/*
sistema     : superchef pizzaria
programa    : matéria prima
compilador  : xharbour 1.2 simplex
lib gráfica : minigui 1.7 extended
programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'super.ch'

FUNCTION materia_prima()

   dbselectarea('materia_prima')
   ordsetfocus('nome')
   materia_prima->(dbgotop())

   DEFINE WINDOW form_materia_prima;
         at 000,000;
         width 800;
         height 605;
         title 'Matéria Prima';
         icon path_imagens+'icone.ico';
         modal;
         nosize;
         on init pesquisar()

      * botões (toolbar)
      DEFINE BUTTONEX button_incluir
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
      DEFINE BUTTONEX button_alterar
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
      DEFINE BUTTONEX button_excluir
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
      DEFINE BUTTONEX button_imprimir
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
      DEFINE BUTTONEX button_atualizar
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
      DEFINE BUTTONEX button_fornecedores
         picture path_imagens+'fornecedores.bmp'
         col 515
         row 002
         width 100
         height 100
         caption 'Fornecedores'
         action fornecedores_mprima()
         fontname 'verdana'
         fontsize 009
         fontbold .T.
         fontcolor _preto_001
         vertical .T.
         flat .T.
         noxpstyle .T.
         backcolor _branco_001
      END BUTTONex
      DEFINE BUTTONEX button_sair
         picture path_imagens+'sair.bmp'
         col 617
         row 002
         width 100
         height 100
         caption 'ESC Voltar'
         action form_materia_prima.release
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
         DEFINE GRID grid_materia_prima
            parent form_materia_prima
            col 000
            row 105
            width 795
            height 430
            headers {'Código','Nome','Unidade','Preço R$','Qtd.'}
            widths {080,320,120,120,120}
            fontname 'verdana'
            fontsize 010
            fontbold .T.
            backcolor _amarelo_001
            fontcolor _preto_001
            ondblclick dados(2)
         END GRID
      END SPLITBOX

      DEFINE LABEL rodape_001
         parent form_materia_prima
         col 005
         row 545
         value 'Digite sua pesquisa'
         autosize .T.
         fontname 'verdana'
         fontsize 010
         fontbold .T.
         fontcolor _cinza_001
         transparent .T.
      END LABEL
      @ 540,160 textbox tbox_pesquisa;
         of form_materia_prima;
         height 027;
         width 300;
         value '';
         maxlength 040;
         font 'verdana' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         uppercase;
         on change pesquisar()
      DEFINE LABEL rodape_002
         parent form_materia_prima
         col form_materia_prima.width - 270
         row 545
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

   form_materia_prima.center
   form_materia_prima.activate

   RETURN(nil)

STATIC FUNCTION dados(parametro)

   LOCAL id
   LOCAL titulo    := ''
   LOCAL x_nome    := ''
   LOCAL x_unidade := 0
   LOCAL x_preco   := 0
   LOCAL x_qtd     := 0

   IF parametro == 1
      titulo := 'Incluir'
   ELSEIF parametro == 2
      id     := val(valor_coluna('grid_materia_prima','form_materia_prima',1))
      titulo := 'Alterar'
      dbselectarea('materia_prima')
      materia_prima->(ordsetfocus('codigo'))
      materia_prima->(dbgotop())
      materia_prima->(dbseek(id))
      IF found()
         x_nome    := materia_prima->nome
         x_unidade := materia_prima->unidade
         x_preco   := materia_prima->preco
         x_qtd     := materia_prima->qtd
         materia_prima->(ordsetfocus('nome'))
      ELSE
         msgexclamation('Selecione uma informação','Atenção')
         materia_prima->(ordsetfocus('nome'))

         RETURN(nil)
      ENDIF
   ENDIF

   DEFINE WINDOW form_dados;
         at 000,000;
         width 325;
         height 300;
         title (titulo);
         icon path_imagens+'icone.ico';
         modal;
         nosize

      * entrada de dados
      @ 010,005 label lbl_001;
         of form_dados;
         value 'Nome';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 030,005 textbox tbox_001;
         of form_dados;
         height 027;
         width 310;
         value x_nome;
         maxlength 020;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         uppercase
      @ 060,005 label lbl_002;
         of form_dados;
         value 'Unidade';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 080,005 textbox tbox_002;
         of form_dados;
         height 027;
         width 060;
         value x_unidade;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         numeric;
         on enter procura_unidade('form_dados','tbox_002')
      @ 080,075 label lbl_nome_unidade;
         of form_dados;
         value '';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _azul_001;
         transparent
      @ 110,005 label lbl_003;
         of form_dados;
         value 'Preço R$';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 130,005 getbox tbox_003;
         of form_dados;
         height 027;
         width 120;
         value x_preco;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         picture '@E 999,999.99'
      @ 110,135 label lbl_004;
         of form_dados;
         value 'Quantidade';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 130,135 getbox tbox_004;
         of form_dados;
         height 027;
         width 120;
         value x_qtd;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         picture '@R 99,999.999'

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
      DEFINE BUTTONEX button_ok
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
      DEFINE BUTTONEX button_cancela
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

   END WINDOW

   sethandcursor(getcontrolhandle('button_ok','form_dados'))
   sethandcursor(getcontrolhandle('button_cancela','form_dados'))

   form_dados.center
   form_dados.activate

   RETURN(nil)

STATIC FUNCTION excluir()

   LOCAL id := val(valor_coluna('grid_materia_prima','form_materia_prima',1))

   dbselectarea('materia_prima')
   materia_prima->(ordsetfocus('codigo'))
   materia_prima->(dbgotop())
   materia_prima->(dbseek(id))

   IF .not. found()
      msgexclamation('Selecione uma informação','Atenção')
      materia_prima->(ordsetfocus('nome'))

      RETURN(nil)
   ELSE
      IF msgyesno('Nome : '+alltrim(materia_prima->nome),'Excluir')
         IF lock_reg()
            materia_prima->(dbdelete())
            materia_prima->(dbunlock())
            materia_prima->(dbgotop())
         ENDIF
         materia_prima->(ordsetfocus('nome'))
         atualizar()
      ENDIF
   ENDIF

   RETURN(nil)

STATIC FUNCTION relacao()

   LOCAL p_linha := 040
   LOCAL u_linha := 260
   LOCAL linha   := p_linha
   LOCAL pagina  := 1

   dbselectarea('materia_prima')
   materia_prima->(ordsetfocus('nome'))
   materia_prima->(dbgotop())

   SELECT PRINTER DIALOG PREVIEW

   START PRINTDOC NAME 'Gerenciador de impressão'
      START PRINTPAGE

         cabecalho(pagina)

         WHILE .not. eof()

            @ linha,030 PRINT strzero(materia_prima->codigo,4) FONT 'courier new' SIZE 010
            @ linha,045 PRINT materia_prima->nome FONT 'courier new' SIZE 010
            @ linha,120 PRINT acha_unidade(materia_prima->unidade) FONT 'courier new' SIZE 010
            @ linha,150 PRINT trans(materia_prima->preco,'@E 9,999.99') FONT 'courier new' SIZE 010
            @ linha,170 PRINT trans(materia_prima->qtd,'@R 99,999.999') FONT 'courier new' SIZE 010

            linha += 5

            IF linha >= u_linha
            END PRINTPAGE
            START PRINTPAGE
               pagina ++
               cabecalho(pagina)
               linha := p_linha
            ENDIF

            materia_prima->(dbskip())

         end

         rodape()

      END PRINTPAGE
   END PRINTDOC

   RETURN(nil)

STATIC FUNCTION cabecalho(p_pagina)

   @ 007,010 PRINT IMAGE path_imagens+'logotipo.bmp' WIDTH 050 HEIGHT 020 STRETCH
   @ 010,070 PRINT 'RELAÇÃO DE MATÉRIA PRIMA' FONT 'courier new' SIZE 018 BOLD
   @ 018,070 PRINT 'ordem alfabética' FONT 'courier new' SIZE 014
   @ 024,070 PRINT 'página : '+strzero(p_pagina,4) FONT 'courier new' SIZE 012

   @ 030,000 PRINT LINE TO 030,205 PENWIDTH 0.5 COLOR _preto_001

   @ 035,030 PRINT 'CÓDIGO' FONT 'courier new' SIZE 010 BOLD
   @ 035,045 PRINT 'NOME' FONT 'courier new' SIZE 010 BOLD
   @ 035,120 PRINT 'UNIDADE' FONT 'courier new' SIZE 010 BOLD
   @ 035,150 PRINT 'PREÇO R$' FONT 'courier new' SIZE 010 BOLD
   @ 035,180 PRINT 'QTD.' FONT 'courier new' SIZE 010 BOLD

   RETURN(nil)

STATIC FUNCTION rodape()

   @ 275,000 PRINT LINE TO 275,205 PENWIDTH 0.5 COLOR _preto_001
   @ 276,010 PRINT 'impresso em '+dtoc(date())+' as '+time() FONT 'courier new' SIZE 008

   RETURN(nil)

STATIC FUNCTION gravar(parametro)

   LOCAL codigo  := 0
   LOCAL retorna := .F.

   IF empty(form_dados.tbox_001.value)
      retorna := .T.
   ENDIF
   IF empty(form_dados.tbox_002.value)
      retorna := .T.
   ENDIF
   IF empty(form_dados.tbox_003.value)
      retorna := .T.
   ENDIF

   IF retorna
      msgalert('Preencha todos os campos','Atenção')

      RETURN(nil)
   ENDIF

   IF parametro == 1
      WHILE .T.
         dbselectarea('conta')
         conta->(dbgotop())
         IF lock_reg()
            codigo := conta->c_mprima
            REPLACE c_mprima with c_mprima + 1
            conta->(dbcommit())
            conta->(dbunlock())
            EXIT
         ELSE
            msgexclamation('Servidor congestionado, tecle ENTER e aguarde','Atenção')
            LOOP
         ENDIF
      end
      dbselectarea('materia_prima')
      IF l_demo
         IF reccount() > _limite_registros
            msgstop('Limite de registros esgotado','Atenção')

            RETURN(nil)
         ENDIF
      ENDIF
      materia_prima->(dbappend())
      materia_prima->codigo  := codigo
      materia_prima->nome    := form_dados.tbox_001.value
      materia_prima->unidade := form_dados.tbox_002.value
      materia_prima->preco   := form_dados.tbox_003.value
      materia_prima->qtd     := form_dados.tbox_004.value
      materia_prima->(dbcommit())
      materia_prima->(dbgotop())
      form_dados.release
      atualizar()
   ELSEIF parametro == 2
      dbselectarea('materia_prima')
      IF lock_reg()
         materia_prima->nome    := form_dados.tbox_001.value
         materia_prima->unidade := form_dados.tbox_002.value
         materia_prima->preco   := form_dados.tbox_003.value
         materia_prima->qtd     := form_dados.tbox_004.value
         materia_prima->(dbcommit())
         materia_prima->(dbunlock())
         materia_prima->(dbgotop())
      ENDIF
      form_dados.release
      atualizar()
   ENDIF

   RETURN(nil)

STATIC FUNCTION pesquisar()

   LOCAL cPesq        := alltrim(form_materia_prima.tbox_pesquisa.value)
   LOCAL lGridFreeze  := .T.
   LOCAL nTamNomePesq := len(cPesq)

   dbselectarea('materia_prima')
   materia_prima->(ordsetfocus('nome'))
   materia_prima->(dbseek(cPesq))

   IF lGridFreeze
      form_materia_prima.grid_materia_prima.disableupdate
   ENDIF

   DELETE item all from grid_materia_prima of form_materia_prima

   WHILE .not. eof()
      IF substr(field->nome,1,nTamNomePesq) == cPesq
         add item {str(materia_prima->codigo),alltrim(materia_prima->nome),acha_unidade(materia_prima->unidade),trans(materia_prima->preco,'@E 999,999.99'),trans(materia_prima->qtd,'@R 99,999.999')} to grid_materia_prima of form_materia_prima
      ELSEIF substr(field->nome,1,nTamNomePesq) > cPesq
         EXIT
      ENDIF
      materia_prima->(dbskip())
   end

   IF lGridFreeze
      form_materia_prima.grid_materia_prima.enableupdate
   ENDIF

   RETURN(nil)

STATIC FUNCTION atualizar()

   DELETE item all from grid_materia_prima of form_materia_prima

   dbselectarea('materia_prima')
   materia_prima->(ordsetfocus('nome'))
   materia_prima->(dbgotop())

   WHILE .not. eof()
      add item {str(materia_prima->codigo),alltrim(materia_prima->nome),acha_unidade(materia_prima->unidade),trans(materia_prima->preco,'@E 999,999.99'),trans(materia_prima->qtd,'@R 99,999.999')} to grid_materia_prima of form_materia_prima
      materia_prima->(dbskip())
   end

   RETURN(nil)

STATIC FUNCTION procura_unidade(cform,ctextbtn)

   LOCAL flag    := .F.
   LOCAL creg    := ''
   LOCAL nreg_01 := getproperty(cform,ctextbtn,'value')
   LOCAL nreg_02 := nreg_01

   dbselectarea('unidade_medida')
   unidade_medida->(ordsetfocus('codigo'))
   unidade_medida->(dbgotop())
   unidade_medida->(dbseek(nreg_02))
   IF found()
      flag := .T.
   ELSE
      creg := getcode_unidade(getproperty(cform,ctextbtn,'value'))
      dbselectarea('unidade_medida')
      unidade_medida->(ordsetfocus('codigo'))
      unidade_medida->(dbgotop())
      unidade_medida->(dbseek(creg))
      IF found()
         flag := .T.
      ENDIF
   ENDIF

   IF flag
      setproperty('form_dados','lbl_nome_unidade','value',unidade_medida->nome)
   ENDIF

   IF !empty(creg)
      setproperty(cform,ctextbtn,'value',creg)
   ENDIF

   RETURN(nil)

STATIC FUNCTION getcode_unidade(value)

   LOCAL creg := ''
   LOCAL nreg := 1

   dbselectarea('unidade_medida')
   unidade_medida->(ordsetfocus('nome'))
   unidade_medida->(dbgotop())

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
         onchange find_unidade()
         uppercase .T.
      END TEXTBOX

      DEFINE BROWSE browse_pesquisa
         row 002
         col 002
         width 480
         height 430
         headers {'Código','Nome'}
         widths {080,370}
         workarea unidade_medida
         fields {'unidade_medida->codigo','unidade_medida->nome'}
         value nreg
         fontname 'verdana'
         fontsize 010
         fontbold .T.
         backcolor _ciano_001
         nolines .T.
         lock .T.
         READonly {.T.,.T.}
         justify {BROWSE_JTFY_LEFT,BROWSE_JTFY_LEFT}
         on dblclick (creg:=unidade_medida->codigo,thiswindow.release)
      end browse

      on key escape action thiswindow.release

   END WINDOW

   form_pesquisa.browse_pesquisa.setfocus

   form_pesquisa.center
   form_pesquisa.activate

   RETURN(creg)

STATIC FUNCTION find_unidade()

   LOCAL pesquisa := alltrim(form_pesquisa.txt_pesquisa.value)

   unidade_medida->(dbgotop())

   IF pesquisa == ''

      RETURN(nil)
   ELSEIF unidade_medida->(dbseek(pesquisa))
      form_pesquisa.browse_pesquisa.value := unidade_medida->(recno())
   ENDIF

   RETURN(nil)

STATIC FUNCTION fornecedores_mprima()

   LOCAL x_codigo_mprima := val(valor_coluna('grid_materia_prima','form_materia_prima',1))
   LOCAL x_nome_mprima   := valor_coluna('grid_materia_prima','form_materia_prima',2)

   IF empty(x_nome_mprima)
      msgexclamation('Escolha uma matéria prima','Atenção')

      RETURN(nil)
   ENDIF

   DEFINE WINDOW form_fornecedor_mprima;
         at 000,000;
         width 600;
         height 500;
         title 'Fornecedores de : '+alltrim(x_nome_mprima);
         icon path_imagens+'icone.ico';
         modal;
         nosize

      * botões (toolbar)
      DEFINE BUTTONEX button_sair
         picture path_imagens+'sair.bmp'
         col 005
         row 002
         width 100
         height 100
         caption 'ESC Voltar'
         action form_fornecedor_mprima.release
         fontname 'verdana'
         fontsize 009
         fontbold .T.
         fontcolor _preto_001
         vertical .T.
         flat .T.
         noxpstyle .T.
         backcolor _branco_001
      END BUTTONex

      DEFINE GRID grid_fornecedor_mprima
         parent form_fornecedor_mprima
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

   filtra_fornecedor(x_codigo_mprima)

   form_fornecedor_mprima.center
   form_fornecedor_mprima.activate

   RETURN(nil)

STATIC FUNCTION filtra_fornecedor(parametro)

   LOCAL x_old_fornecedor := 0

   DELETE item all from grid_fornecedor_mprima of form_fornecedor_mprima

   dbselectarea('tcompra2')
   INDEX ON fornecedor to indcpa12 for mat_prima == parametro
   GO TOP

   WHILE .not. eof()
      x_old_fornecedor := fornecedor
      SKIP
      IF fornecedor <> x_old_fornecedor
         add item {acha_fornecedor_2(x_old_fornecedor)} to grid_fornecedor_mprima of form_fornecedor_mprima
      ENDIF
   end

   RETURN(nil)

