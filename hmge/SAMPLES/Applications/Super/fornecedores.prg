/*
sistema     : superchef pizzaria
programa    : fornecedores
compilador  : xharbour 1.2 simplex
lib gráfica : minigui 1.7 extended
programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'super.ch'

FUNCTION fornecedores()

   dbselectarea('fornecedores')
   ordsetfocus('nome')
   fornecedores->(dbgotop())

   DEFINE WINDOW form_fornecedores;
         at 000,000;
         WIDTH 800;
         HEIGHT 605;
         TITLE 'Fornecedores';
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
      DEFINE BUTTONEX button_sair
         PICTURE path_imagens+'sair.bmp'
         COL 515
         ROW 002
         WIDTH 100
         HEIGHT 100
         CAPTION 'ESC Voltar'
         ACTION form_fornecedores.release
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
         DEFINE GRID grid_fornecedores
            parent form_fornecedores
            COL 000
            ROW 105
            WIDTH 795
            HEIGHT 430
            HEADERS {'Código','Nome','Telefone fixo','Telefone celular'}
            WIDTHS {080,400,140,140}
            FONTNAME 'verdana'
            FONTSIZE 010
            FONTBOLD .T.
            BACKCOLOR _amarelo_001
            FONTCOLOR _preto_001
            ondblclick dados(2)
         END GRID
      END SPLITBOX

      DEFINE LABEL rodape_001
         parent form_fornecedores
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
         of form_fornecedores;
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
         parent form_fornecedores
         COL form_fornecedores.width - 270
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

   form_fornecedores.center
   form_fornecedores.activate

   RETURN NIL

STATIC FUNCTION dados(parametro)

   LOCAL id
   LOCAL titulo     := ''
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
   LOCAL x_grupo    := 0

   IF parametro == 1
      titulo := 'Incluir'
   ELSEIF parametro == 2
      id     := val(valor_coluna('grid_fornecedores','form_fornecedores',1))
      titulo := 'Alterar'
      dbselectarea('fornecedores')
      fornecedores->(ordsetfocus('codigo'))
      fornecedores->(dbgotop())
      fornecedores->(dbseek(id))
      IF found()
         x_nome     := fornecedores->nome
         x_fixo     := fornecedores->fixo
         x_celular  := fornecedores->celular
         x_endereco := fornecedores->endereco
         x_numero   := fornecedores->numero
         x_complem  := fornecedores->complem
         x_bairro   := fornecedores->bairro
         x_cidade   := fornecedores->cidade
         x_uf       := fornecedores->uf
         x_cep      := fornecedores->cep
         x_email    := fornecedores->email
         x_grupo    := fornecedores->grupo
         fornecedores->(ordsetfocus('nome'))
      ELSE
         msgexclamation('Selecione uma informação','Atenção')
         fornecedores->(ordsetfocus('nome'))

         RETURN NIL
      ENDIF
   ENDIF

   DEFINE WINDOW form_dados;
         at 000,000;
         WIDTH 585;
         HEIGHT 360;
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
         MAXLENGTH 040;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         uppercase
      @ 010,325 label lbl_002;
         of form_dados;
         VALUE 'Telefone fixo';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 030,325 textbox tbox_002;
         of form_dados;
         HEIGHT 027;
         WIDTH 120;
         VALUE x_fixo;
         MAXLENGTH 010;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         uppercase
      @ 010,455 label lbl_003;
         of form_dados;
         VALUE 'Telefone celular';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 030,455 textbox tbox_003;
         of form_dados;
         HEIGHT 027;
         WIDTH 120;
         VALUE x_celular;
         MAXLENGTH 010;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         uppercase
      @ 060,005 label lbl_004;
         of form_dados;
         VALUE 'Endereço';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 080,005 textbox tbox_004;
         of form_dados;
         HEIGHT 027;
         WIDTH 310;
         VALUE x_endereco;
         MAXLENGTH 040;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         uppercase
      @ 060,325 label lbl_005;
         of form_dados;
         VALUE 'Número';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 080,325 textbox tbox_005;
         of form_dados;
         HEIGHT 027;
         WIDTH 060;
         VALUE x_numero;
         MAXLENGTH 006;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         uppercase
      @ 060,395 label lbl_006;
         of form_dados;
         VALUE 'Complemento';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 080,395 textbox tbox_006;
         of form_dados;
         HEIGHT 027;
         WIDTH 180;
         VALUE x_complem;
         MAXLENGTH 020;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         uppercase
      @ 110,005 label lbl_007;
         of form_dados;
         VALUE 'Bairro';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 130,005 textbox tbox_007;
         of form_dados;
         HEIGHT 027;
         WIDTH 180;
         VALUE x_bairro;
         MAXLENGTH 020;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         uppercase
      @ 110,195 label lbl_008;
         of form_dados;
         VALUE 'Cidade';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 130,195 textbox tbox_008;
         of form_dados;
         HEIGHT 027;
         WIDTH 180;
         VALUE x_cidade;
         MAXLENGTH 020;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         uppercase
      @ 110,385 label lbl_009;
         of form_dados;
         VALUE 'UF';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 130,385 textbox tbox_009;
         of form_dados;
         HEIGHT 027;
         WIDTH 040;
         VALUE x_uf;
         MAXLENGTH 002;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         uppercase
      @ 110,435 label lbl_010;
         of form_dados;
         VALUE 'CEP';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 130,435 textbox tbox_010;
         of form_dados;
         HEIGHT 027;
         WIDTH 080;
         VALUE x_cep;
         MAXLENGTH 008;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         uppercase
      @ 160,005 label lbl_011;
         of form_dados;
         VALUE 'e-mail';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 180,005 textbox tbox_011;
         of form_dados;
         HEIGHT 027;
         WIDTH 450;
         VALUE x_email;
         MAXLENGTH 050;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         lowercase
      @ 210,005 label lbl_012;
         of form_dados;
         VALUE 'Grupo';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 230,005 textbox tbox_012;
         of form_dados;
         HEIGHT 027;
         WIDTH 060;
         VALUE x_grupo;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         numeric;
         ON ENTER procura_grupo_fornecedores('form_dados','tbox_012')
      @ 230,075 label lbl_nome_grupo_fornecedores;
         of form_dados;
         VALUE '';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _azul_001;
         TRANSPARENT

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

   LOCAL id := val(valor_coluna('grid_fornecedores','form_fornecedores',1))

   dbselectarea('fornecedores')
   fornecedores->(ordsetfocus('codigo'))
   fornecedores->(dbgotop())
   fornecedores->(dbseek(id))

   IF .not. found()
      msgexclamation('Selecione uma informação','Atenção')
      fornecedores->(ordsetfocus('nome'))

      RETURN NIL
   ELSE
      IF msgyesno('Nome : '+alltrim(fornecedores->nome),'Excluir')
         IF lock_reg()
            fornecedores->(dbdelete())
            fornecedores->(dbunlock())
            fornecedores->(dbgotop())
         ENDIF
         fornecedores->(ordsetfocus('nome'))
         atualizar()
      ENDIF
   ENDIF

   RETURN NIL

STATIC FUNCTION relacao()

   LOCAL p_linha := 040
   LOCAL u_linha := 260
   LOCAL linha   := p_linha
   LOCAL pagina  := 1

   dbselectarea('fornecedores')
   fornecedores->(ordsetfocus('nome'))
   fornecedores->(dbgotop())

   SELECT PRINTER DIALOG PREVIEW

   START PRINTDOC NAME 'Gerenciador de impressão'
      START PRINTPAGE

         cabecalho(pagina)

         WHILE .not. eof()

            @ linha,010 PRINT strzero(fornecedores->codigo,4) FONT 'courier new' SIZE 010
            @ linha,025 PRINT fornecedores->nome FONT 'courier new' SIZE 010
            @ linha,100 PRINT fornecedores->fixo FONT 'courier new' SIZE 010
            @ linha,130 PRINT fornecedores->celular FONT 'courier new' SIZE 010
            @ linha,160 PRINT fornecedores->cidade FONT 'courier new' SIZE 010

            linha += 5

            IF linha >= u_linha
            END PRINTPAGE
            START PRINTPAGE
               pagina ++
               cabecalho(pagina)
               linha := p_linha
            ENDIF

            fornecedores->(dbskip())

         END

         rodape()

      END PRINTPAGE
   END PRINTDOC

   RETURN NIL

STATIC FUNCTION cabecalho(p_pagina)

   @ 007,010 PRINT IMAGE path_imagens+'logotipo.bmp' WIDTH 050 HEIGHT 020 STRETCH
   @ 010,070 PRINT 'RELAÇÃO DE FORNECEDORES' FONT 'courier new' SIZE 018 BOLD
   @ 018,070 PRINT 'ordem alfabética' FONT 'courier new' SIZE 014
   @ 024,070 PRINT 'página : '+strzero(p_pagina,4) FONT 'courier new' SIZE 012

   @ 030,000 PRINT LINE TO 030,205 PENWIDTH 0.5 COLOR _preto_001

   @ 035,010 PRINT 'CÓDIGO' FONT 'courier new' SIZE 010 BOLD
   @ 035,025 PRINT 'NOME' FONT 'courier new' SIZE 010 BOLD
   @ 035,100 PRINT 'TEL.FIXO' FONT 'courier new' SIZE 010 BOLD
   @ 035,130 PRINT 'TEL.CELULAR' FONT 'courier new' SIZE 010 BOLD
   @ 035,160 PRINT 'CIDADE' FONT 'courier new' SIZE 010 BOLD

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

   IF retorna
      msgalert('Preencha todos os campos','Atenção')

      RETURN NIL
   ENDIF

   IF parametro == 1
      WHILE .T.
         dbselectarea('conta')
         conta->(dbgotop())
         IF lock_reg()
            codigo := conta->c_fornec
            REPLACE c_fornec with c_fornec + 1
            conta->(dbcommit())
            conta->(dbunlock())
            EXIT
         ELSE
            msgexclamation('Servidor congestionado, tecle ENTER e aguarde','Atenção')
            LOOP
         ENDIF
      END
      dbselectarea('fornecedores')
      IF l_demo
         IF reccount() > _limite_registros
            msgstop('Limite de registros esgotado','Atenção')

            RETURN NIL
         ENDIF
      ENDIF
      fornecedores->(dbappend())
      fornecedores->codigo   := codigo
      fornecedores->nome     := form_dados.tbox_001.value
      fornecedores->fixo     := form_dados.tbox_002.value
      fornecedores->celular  := form_dados.tbox_003.value
      fornecedores->endereco := form_dados.tbox_004.value
      fornecedores->numero   := form_dados.tbox_005.value
      fornecedores->complem  := form_dados.tbox_006.value
      fornecedores->bairro   := form_dados.tbox_007.value
      fornecedores->cidade   := form_dados.tbox_008.value
      fornecedores->uf       := form_dados.tbox_009.value
      fornecedores->cep      := form_dados.tbox_010.value
      fornecedores->email    := form_dados.tbox_011.value
      fornecedores->grupo    := form_dados.tbox_012.value
      fornecedores->(dbcommit())
      fornecedores->(dbgotop())
      form_dados.release
      atualizar()
   ELSEIF parametro == 2
      dbselectarea('fornecedores')
      IF lock_reg()
         fornecedores->nome     := form_dados.tbox_001.value
         fornecedores->fixo     := form_dados.tbox_002.value
         fornecedores->celular  := form_dados.tbox_003.value
         fornecedores->endereco := form_dados.tbox_004.value
         fornecedores->numero   := form_dados.tbox_005.value
         fornecedores->complem  := form_dados.tbox_006.value
         fornecedores->bairro   := form_dados.tbox_007.value
         fornecedores->cidade   := form_dados.tbox_008.value
         fornecedores->uf       := form_dados.tbox_009.value
         fornecedores->cep      := form_dados.tbox_010.value
         fornecedores->email    := form_dados.tbox_011.value
         fornecedores->grupo    := form_dados.tbox_012.value
         fornecedores->(dbcommit())
         fornecedores->(dbunlock())
         fornecedores->(dbgotop())
      ENDIF
      form_dados.release
      atualizar()
   ENDIF

   RETURN NIL

STATIC FUNCTION pesquisar()

   LOCAL cPesq        := alltrim(form_fornecedores.tbox_pesquisa.value)
   LOCAL lGridFreeze  := .T.
   LOCAL nTamNomePesq := len(cPesq)

   dbselectarea('fornecedores')
   fornecedores->(ordsetfocus('nome'))
   fornecedores->(dbseek(cPesq))

   IF lGridFreeze
      form_fornecedores.grid_fornecedores.disableupdate
   ENDIF

   DELETE item all from grid_fornecedores of form_fornecedores

   WHILE .not. eof()
      IF substr(field->nome,1,nTamNomePesq) == cPesq
         add item {str(fornecedores->codigo),alltrim(fornecedores->nome),alltrim(fornecedores->fixo),alltrim(fornecedores->celular)} to grid_fornecedores of form_fornecedores
      ELSEIF substr(field->nome,1,nTamNomePesq) > cPesq
         EXIT
      ENDIF
      fornecedores->(dbskip())
   END

   IF lGridFreeze
      form_fornecedores.grid_fornecedores.enableupdate
   ENDIF

   RETURN NIL

STATIC FUNCTION atualizar()

   DELETE item all from grid_fornecedores of form_fornecedores

   dbselectarea('fornecedores')
   fornecedores->(ordsetfocus('nome'))
   fornecedores->(dbgotop())

   WHILE .not. eof()
      add item {str(fornecedores->codigo),alltrim(fornecedores->nome),alltrim(fornecedores->fixo),alltrim(fornecedores->celular)} to grid_fornecedores of form_fornecedores
      fornecedores->(dbskip())
   END

   RETURN NIL

STATIC FUNCTION procura_grupo_fornecedores(cform,ctextbtn)

   LOCAL flag    := .F.
   LOCAL creg    := ''
   LOCAL nreg_01 := getproperty(cform,ctextbtn,'value')
   LOCAL nreg_02 := nreg_01

   dbselectarea('grupo_fornecedores')
   grupo_fornecedores->(ordsetfocus('codigo'))
   grupo_fornecedores->(dbgotop())
   grupo_fornecedores->(dbseek(nreg_02))
   IF found()
      flag := .T.
   ELSE
      creg := getcode_grupo_fornecedores(getproperty(cform,ctextbtn,'value'))
      dbselectarea('grupo_fornecedores')
      grupo_fornecedores->(ordsetfocus('codigo'))
      grupo_fornecedores->(dbgotop())
      grupo_fornecedores->(dbseek(creg))
      IF found()
         flag := .T.
      ENDIF
   ENDIF

   IF flag
      setproperty('form_dados','lbl_nome_grupo_fornecedores','value',grupo_fornecedores->nome)
   ENDIF

   IF !empty(creg)
      setproperty(cform,ctextbtn,'value',creg)
   ENDIF

   RETURN NIL

STATIC FUNCTION getcode_grupo_fornecedores(value)

   LOCAL creg := ''
   LOCAL nreg := 1

   dbselectarea('grupo_fornecedores')
   grupo_fornecedores->(ordsetfocus('nome'))
   grupo_fornecedores->(dbgotop())

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
         ONCHANGE find_grupo_fornecedores()
         uppercase .T.
      END TEXTBOX

      DEFINE BROWSE browse_pesquisa
         ROW 002
         COL 002
         WIDTH 480
         HEIGHT 430
         HEADERS {'Código','Nome'}
         WIDTHS {080,370}
         WORKAREA grupo_fornecedores
         FIELDS {'grupo_fornecedores->codigo','grupo_fornecedores->nome'}
         VALUE nreg
         FONTNAME 'verdana'
         FONTSIZE 010
         FONTBOLD .T.
         BACKCOLOR _ciano_001
         nolines .T.
         lock .T.
         readonly {.T.,.T.}
         JUSTIFY {BROWSE_JTFY_LEFT,BROWSE_JTFY_LEFT}
         on dblclick (creg:=grupo_fornecedores->codigo,thiswindow.release)
      END browse

      ON KEY ESCAPE ACTION thiswindow.release

   END WINDOW

   form_pesquisa.browse_pesquisa.setfocus

   form_pesquisa.center
   form_pesquisa.activate

   return(creg)

STATIC FUNCTION find_grupo_fornecedores()

   LOCAL pesquisa := alltrim(form_pesquisa.txt_pesquisa.value)

   grupo_fornecedores->(dbgotop())

   IF pesquisa == ''

      RETURN NIL
   ELSEIF grupo_fornecedores->(dbseek(pesquisa))
      form_pesquisa.browse_pesquisa.value := grupo_fornecedores->(recno())
   ENDIF

   RETURN NIL
