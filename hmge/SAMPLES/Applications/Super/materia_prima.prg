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
         WIDTH 800;
         HEIGHT 605;
         TITLE 'Matéria Prima';
         ICON path_imagens+'icone.ico';
         modal;
         nosize;
         ON INIT pesquisar()

      * botões (toolbar)
      DEFINE BUTTONEX button_incluir
         PICTURE path_imagens+'incluir.bmp'
         COL 005
         ROW 002
         WIDTH 100
         HEIGHT 100
         CAPTION 'F5 Incluir'
         ACTION dados(1)
         FONTNAME 'verdana'
         FONTSIZE 009
         FONTBOLD .T.
         FONTCOLOR _preto_001
         vertical .T.
         flat .T.
         noxpstyle .T.
         BACKCOLOR _branco_001
      END BUTTONEX
      DEFINE BUTTONEX button_alterar
         PICTURE path_imagens+'alterar.bmp'
         COL 107
         ROW 002
         WIDTH 100
         HEIGHT 100
         CAPTION 'F6 Alterar'
         ACTION dados(2)
         FONTNAME 'verdana'
         FONTSIZE 009
         FONTBOLD .T.
         FONTCOLOR _preto_001
         vertical .T.
         flat .T.
         noxpstyle .T.
         BACKCOLOR _branco_001
      END BUTTONEX
      DEFINE BUTTONEX button_excluir
         PICTURE path_imagens+'excluir.bmp'
         COL 209
         ROW 002
         WIDTH 100
         HEIGHT 100
         CAPTION 'F7 Excluir'
         ACTION excluir()
         FONTNAME 'verdana'
         FONTSIZE 009
         FONTBOLD .T.
         FONTCOLOR _preto_001
         vertical .T.
         flat .T.
         noxpstyle .T.
         BACKCOLOR _branco_001
      END BUTTONEX
      DEFINE BUTTONEX button_imprimir
         PICTURE path_imagens+'imprimir.bmp'
         COL 311
         ROW 002
         WIDTH 100
         HEIGHT 100
         CAPTION 'F8 Imprimir'
         ACTION relacao()
         FONTNAME 'verdana'
         FONTSIZE 009
         FONTBOLD .T.
         FONTCOLOR _preto_001
         vertical .T.
         flat .T.
         noxpstyle .T.
         BACKCOLOR _branco_001
      END BUTTONEX
      DEFINE BUTTONEX button_atualizar
         PICTURE path_imagens+'atualizar.bmp'
         COL 413
         ROW 002
         WIDTH 100
         HEIGHT 100
         CAPTION 'Atualizar'
         ACTION atualizar()
         FONTNAME 'verdana'
         FONTSIZE 009
         FONTBOLD .T.
         FONTCOLOR _preto_001
         vertical .T.
         flat .T.
         noxpstyle .T.
         BACKCOLOR _branco_001
      END BUTTONEX
      DEFINE BUTTONEX button_fornecedores
         PICTURE path_imagens+'fornecedores.bmp'
         COL 515
         ROW 002
         WIDTH 100
         HEIGHT 100
         CAPTION 'Fornecedores'
         ACTION fornecedores_mprima()
         FONTNAME 'verdana'
         FONTSIZE 009
         FONTBOLD .T.
         FONTCOLOR _preto_001
         vertical .T.
         flat .T.
         noxpstyle .T.
         BACKCOLOR _branco_001
      END BUTTONEX
      DEFINE BUTTONEX button_sair
         PICTURE path_imagens+'sair.bmp'
         COL 617
         ROW 002
         WIDTH 100
         HEIGHT 100
         CAPTION 'ESC Voltar'
         ACTION form_materia_prima.release
         FONTNAME 'verdana'
         FONTSIZE 009
         FONTBOLD .T.
         FONTCOLOR _preto_001
         vertical .T.
         flat .T.
         noxpstyle .T.
         BACKCOLOR _branco_001
      END BUTTONEX

      DEFINE SPLITBOX
         DEFINE GRID grid_materia_prima
            parent form_materia_prima
            COL 000
            ROW 105
            WIDTH 795
            HEIGHT 430
            HEADERS {'Código','Nome','Unidade','Preço R$','Qtd.'}
            WIDTHS {080,320,120,120,120}
            FONTNAME 'verdana'
            FONTSIZE 010
            FONTBOLD .T.
            BACKCOLOR _amarelo_001
            FONTCOLOR _preto_001
            ONDBLCLICK dados(2)
         END GRID
      END SPLITBOX

      DEFINE LABEL rodape_001
         parent form_materia_prima
         COL 005
         ROW 545
         VALUE 'Digite sua pesquisa'
         AUTOSIZE .T.
         FONTNAME 'verdana'
         FONTSIZE 010
         FONTBOLD .T.
         FONTCOLOR _cinza_001
         TRANSPARENT .T.
      END LABEL
      @ 540,160 textbox tbox_pesquisa;
         of form_materia_prima;
         HEIGHT 027;
         WIDTH 300;
         VALUE '';
         MAXLENGTH 040;
         font 'verdana' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         uppercase;
         ON CHANGE pesquisar()
      DEFINE LABEL rodape_002
         parent form_materia_prima
         COL form_materia_prima.width - 270
         ROW 545
         VALUE 'DUPLO CLIQUE : Alterar informação'
         AUTOSIZE .T.
         FONTNAME 'verdana'
         FONTSIZE 010
         FONTBOLD .T.
         FONTCOLOR _verde_002
         TRANSPARENT .T.
      END LABEL

      ON KEY F5 ACTION dados(1)
      ON KEY F6 ACTION dados(2)
      ON KEY F7 ACTION excluir()
      ON KEY F8 ACTION relacao()
      ON KEY ESCAPE ACTION thiswindow.release

   END WINDOW

   form_materia_prima.center
   form_materia_prima.activate

   RETURN NIL

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

         RETURN NIL
      ENDIF
   ENDIF

   DEFINE WINDOW form_dados;
         at 000,000;
         WIDTH 325;
         HEIGHT 300;
         TITLE (titulo);
         ICON path_imagens+'icone.ico';
         modal;
         NOSIZE

      * entrada de dados
      @ 010,005 label lbl_001;
         of form_dados;
         VALUE 'Nome';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 030,005 textbox tbox_001;
         of form_dados;
         HEIGHT 027;
         WIDTH 310;
         VALUE x_nome;
         MAXLENGTH 020;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         uppercase
      @ 060,005 label lbl_002;
         of form_dados;
         VALUE 'Unidade';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 080,005 textbox tbox_002;
         of form_dados;
         HEIGHT 027;
         WIDTH 060;
         VALUE x_unidade;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         numeric;
         ON ENTER procura_unidade('form_dados','tbox_002')
      @ 080,075 label lbl_nome_unidade;
         of form_dados;
         VALUE '';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _azul_001;
         TRANSPARENT
      @ 110,005 label lbl_003;
         of form_dados;
         VALUE 'Preço R$';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 130,005 getbox tbox_003;
         of form_dados;
         HEIGHT 027;
         WIDTH 120;
         VALUE x_preco;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         PICTURE '@E 999,999.99'
      @ 110,135 label lbl_004;
         of form_dados;
         VALUE 'Quantidade';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 130,135 getbox tbox_004;
         of form_dados;
         HEIGHT 027;
         WIDTH 120;
         VALUE x_qtd;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         PICTURE '@R 99,999.999'

      * linha separadora
      DEFINE LABEL linha_rodape
         COL 000
         ROW form_dados.height-090
         VALUE ''
         WIDTH form_dados.width
         HEIGHT 001
         BACKCOLOR _preto_001
         TRANSPARENT .F.
      END LABEL

      * botões
      DEFINE BUTTONEX button_ok
         PICTURE path_imagens+'img_gravar.bmp'
         COL form_dados.width-225
         ROW form_dados.height-085
         WIDTH 120
         HEIGHT 050
         CAPTION 'Ok, gravar'
         ACTION gravar(parametro)
         FONTBOLD .T.
         TOOLTIP 'Confirmar as informações digitadas'
         flat .F.
         noxpstyle .T.
      END BUTTONEX
      DEFINE BUTTONEX button_cancela
         PICTURE path_imagens+'img_voltar.bmp'
         COL form_dados.width-100
         ROW form_dados.height-085
         WIDTH 090
         HEIGHT 050
         CAPTION 'Voltar'
         ACTION form_dados.release
         FONTBOLD .T.
         TOOLTIP 'Sair desta tela sem gravar informações'
         flat .F.
         noxpstyle .T.
      END BUTTONEX

   END WINDOW

   sethandcursor(getcontrolhandle('button_ok','form_dados'))
   sethandcursor(getcontrolhandle('button_cancela','form_dados'))

   form_dados.center
   form_dados.activate

   RETURN NIL

STATIC FUNCTION excluir()

   LOCAL id := val(valor_coluna('grid_materia_prima','form_materia_prima',1))

   dbselectarea('materia_prima')
   materia_prima->(ordsetfocus('codigo'))
   materia_prima->(dbgotop())
   materia_prima->(dbseek(id))

   IF .not. found()
      msgexclamation('Selecione uma informação','Atenção')
      materia_prima->(ordsetfocus('nome'))

      RETURN NIL
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

   RETURN NIL

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

         END

         rodape()

      END PRINTPAGE
   END PRINTDOC

   RETURN NIL

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

   RETURN NIL

STATIC FUNCTION rodape()

   @ 275,000 PRINT LINE TO 275,205 PENWIDTH 0.5 COLOR _preto_001
   @ 276,010 PRINT 'impresso em '+dtoc(date())+' as '+time() FONT 'courier new' SIZE 008

   RETURN NIL

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

      RETURN NIL
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
      END
      dbselectarea('materia_prima')
      IF l_demo
         IF reccount() > _limite_registros
            msgstop('Limite de registros esgotado','Atenção')

            RETURN NIL
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

   RETURN NIL

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
   END

   IF lGridFreeze
      form_materia_prima.grid_materia_prima.enableupdate
   ENDIF

   RETURN NIL

STATIC FUNCTION atualizar()

   DELETE item all from grid_materia_prima of form_materia_prima

   dbselectarea('materia_prima')
   materia_prima->(ordsetfocus('nome'))
   materia_prima->(dbgotop())

   WHILE .not. eof()
      add item {str(materia_prima->codigo),alltrim(materia_prima->nome),acha_unidade(materia_prima->unidade),trans(materia_prima->preco,'@E 999,999.99'),trans(materia_prima->qtd,'@R 99,999.999')} to grid_materia_prima of form_materia_prima
      materia_prima->(dbskip())
   END

   RETURN NIL

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

   RETURN NIL

STATIC FUNCTION getcode_unidade(value)

   LOCAL creg := ''
   LOCAL nreg := 1

   dbselectarea('unidade_medida')
   unidade_medida->(ordsetfocus('nome'))
   unidade_medida->(dbgotop())

   DEFINE WINDOW form_pesquisa;
         at 000,000;
         WIDTH 490;
         HEIGHT 500;
         TITLE 'Pesquisa por nome';
         ICON path_imagens+'icone.ico';
         modal;
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
         ONCHANGE find_unidade()
         uppercase .T.
      END TEXTBOX

      DEFINE BROWSE browse_pesquisa
         ROW 002
         COL 002
         WIDTH 480
         HEIGHT 430
         HEADERS {'Código','Nome'}
         WIDTHS {080,370}
         WORKAREA unidade_medida
         FIELDS {'unidade_medida->codigo','unidade_medida->nome'}
         VALUE nreg
         FONTNAME 'verdana'
         FONTSIZE 010
         FONTBOLD .T.
         BACKCOLOR _ciano_001
         nolines .T.
         lock .T.
         readonly {.T.,.T.}
         JUSTIFY {BROWSE_JTFY_LEFT,BROWSE_JTFY_LEFT}
         on dblclick (creg:=unidade_medida->codigo,thiswindow.release)
      END browse

      ON KEY ESCAPE ACTION thiswindow.release

   END WINDOW

   form_pesquisa.browse_pesquisa.setfocus

   form_pesquisa.center
   form_pesquisa.activate

   return(creg)

STATIC FUNCTION find_unidade()

   LOCAL pesquisa := alltrim(form_pesquisa.txt_pesquisa.value)

   unidade_medida->(dbgotop())

   IF pesquisa == ''

      RETURN NIL
   ELSEIF unidade_medida->(dbseek(pesquisa))
      form_pesquisa.browse_pesquisa.value := unidade_medida->(recno())
   ENDIF

   RETURN NIL

STATIC FUNCTION fornecedores_mprima()

   LOCAL x_codigo_mprima := val(valor_coluna('grid_materia_prima','form_materia_prima',1))
   LOCAL x_nome_mprima   := valor_coluna('grid_materia_prima','form_materia_prima',2)

   IF empty(x_nome_mprima)
      msgexclamation('Escolha uma matéria prima','Atenção')

      RETURN NIL
   ENDIF

   DEFINE WINDOW form_fornecedor_mprima;
         at 000,000;
         WIDTH 600;
         HEIGHT 500;
         TITLE 'Fornecedores de : '+alltrim(x_nome_mprima);
         ICON path_imagens+'icone.ico';
         modal;
         NOSIZE

      * botões (toolbar)
      DEFINE BUTTONEX button_sair
         PICTURE path_imagens+'sair.bmp'
         COL 005
         ROW 002
         WIDTH 100
         HEIGHT 100
         CAPTION 'ESC Voltar'
         ACTION form_fornecedor_mprima.release
         FONTNAME 'verdana'
         FONTSIZE 009
         FONTBOLD .T.
         FONTCOLOR _preto_001
         vertical .T.
         flat .T.
         noxpstyle .T.
         BACKCOLOR _branco_001
      END BUTTONEX

      DEFINE GRID grid_fornecedor_mprima
         parent form_fornecedor_mprima
         COL 005
         ROW 104
         WIDTH 585
         HEIGHT 360
         HEADERS {'Nome do fornecedor'}
         WIDTHS {570}
         FONTNAME 'verdana'
         FONTSIZE 010
         FONTBOLD .F.
         nolines .T.
         BACKCOLOR _branco_001
         FONTCOLOR _preto_001
      END GRID

      ON KEY ESCAPE ACTION thiswindow.release

   END WINDOW

   filtra_fornecedor(x_codigo_mprima)

   form_fornecedor_mprima.center
   form_fornecedor_mprima.activate

   RETURN NIL

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
   END

   RETURN NIL
