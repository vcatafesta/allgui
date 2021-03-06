/*
sistema     : superchef pizzaria
programa    : clientes
compilador  : xharbour 1.2 simplex
lib gr�fica : minigui 1.7 extended
programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'super.ch'

FUNCTION clientes()

   dbselectarea('clientes')
   ordsetfocus('nome')
   clientes->(dbgotop())

   DEFINE WINDOW form_clientes ;
         at 000,000 ;
         WIDTH 800 ;
         HEIGHT 605 ;
         TITLE 'Clientes' ;
         ICON path_imagens+'icone.ico' ;
         modal ;
         nosize ;
         ON INIT pesquisar()

      * bot�es (toolbar)
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
         ACTION form_clientes.release
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
         DEFINE GRID grid_clientes
            PARENT form_clientes
            COL 000
            ROW 105
            WIDTH 795
            HEIGHT 430
            HEADERS {'C�digo','Nome','Telefone fixo','Telefone celular'}
            WIDTHS {080,400,140,140}
            FONTNAME 'verdana'
            FONTSIZE 010
            FONTBOLD .T.
            BACKCOLOR _amarelo_001
            FONTCOLOR _preto_001
            ONDBLCLICK dados(2)
         END GRID
      END SPLITBOX

      DEFINE LABEL rodape_001
         PARENT form_clientes
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
      @ 540,160 textbox tbox_pesquisa ;
         of form_clientes ;
         HEIGHT 027 ;
         WIDTH 300 ;
         VALUE '' ;
         MAXLENGTH 040 ;
         FONT 'verdana' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         uppercase ;
         ON CHANGE pesquisar()
      DEFINE LABEL rodape_002
         PARENT form_clientes
         COL form_clientes.width - 270
         ROW 545
         VALUE 'DUPLO CLIQUE : Alterar informa��o'
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

   form_clientes.center
   form_clientes.activate

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
   LOCAL x_aniv_dia := 0
   LOCAL x_aniv_mes := 0

   IF parametro == 1
      titulo := 'Incluir'
   ELSEIF parametro == 2
      id     := val(valor_coluna('grid_clientes','form_clientes',1))
      titulo := 'Alterar'
      dbselectarea('clientes')
      clientes->(ordsetfocus('codigo'))
      clientes->(dbgotop())
      clientes->(dbseek(id))
      IF found()
         x_nome     := clientes->nome
         x_fixo     := clientes->fixo
         x_celular  := clientes->celular
         x_endereco := clientes->endereco
         x_numero   := clientes->numero
         x_complem  := clientes->complem
         x_bairro   := clientes->bairro
         x_cidade   := clientes->cidade
         x_uf       := clientes->uf
         x_cep      := clientes->cep
         x_email    := clientes->email
         x_aniv_dia := clientes->aniv_dia
         x_aniv_mes := clientes->aniv_mes
         clientes->(ordsetfocus('nome'))
      ELSE
         msgexclamation('Selecione uma informa��o','Aten��o')
         clientes->(ordsetfocus('nome'))

         RETURN NIL
      ENDIF
   ENDIF

   DEFINE WINDOW form_dados ;
         at 000,000 ;
         WIDTH 585 ;
         HEIGHT 380 ;
         TITLE (titulo) ;
         ICON path_imagens+'icone.ico' ;
         modal ;
         NOSIZE

      * entrada de dados
      @ 010,005 label lbl_001 ;
         of form_dados ;
         VALUE 'Nome' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 030,005 textbox tbox_001 ;
         of form_dados ;
         HEIGHT 027 ;
         WIDTH 310 ;
         VALUE x_nome ;
         MAXLENGTH 040 ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 010,325 label lbl_002 ;
         of form_dados ;
         VALUE 'Telefone fixo' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 030,325 textbox tbox_002 ;
         of form_dados ;
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
         of form_dados ;
         VALUE 'Telefone celular' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 030,455 textbox tbox_003 ;
         of form_dados ;
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
         of form_dados ;
         VALUE 'Endere�o' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 080,005 textbox tbox_004 ;
         of form_dados ;
         HEIGHT 027 ;
         WIDTH 310 ;
         VALUE x_endereco ;
         MAXLENGTH 040 ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 060,325 label lbl_005 ;
         of form_dados ;
         VALUE 'N�mero' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 080,325 textbox tbox_005 ;
         of form_dados ;
         HEIGHT 027 ;
         WIDTH 060 ;
         VALUE x_numero ;
         MAXLENGTH 006 ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 060,395 label lbl_006 ;
         of form_dados ;
         VALUE 'Complemento' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 080,395 textbox tbox_006 ;
         of form_dados ;
         HEIGHT 027 ;
         WIDTH 180 ;
         VALUE x_complem ;
         MAXLENGTH 020 ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 110,005 label lbl_007 ;
         of form_dados ;
         VALUE 'Bairro' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 130,005 textbox tbox_007 ;
         of form_dados ;
         HEIGHT 027 ;
         WIDTH 180 ;
         VALUE x_bairro ;
         MAXLENGTH 020 ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 110,195 label lbl_008 ;
         of form_dados ;
         VALUE 'Cidade' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 130,195 textbox tbox_008 ;
         of form_dados ;
         HEIGHT 027 ;
         WIDTH 180 ;
         VALUE x_cidade ;
         MAXLENGTH 020 ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 110,385 label lbl_009 ;
         of form_dados ;
         VALUE 'UF' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 130,385 textbox tbox_009 ;
         of form_dados ;
         HEIGHT 027 ;
         WIDTH 040 ;
         VALUE x_uf ;
         MAXLENGTH 002 ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 110,435 label lbl_010 ;
         of form_dados ;
         VALUE 'CEP' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 130,435 textbox tbox_010 ;
         of form_dados ;
         HEIGHT 027 ;
         WIDTH 080 ;
         VALUE x_cep ;
         MAXLENGTH 008 ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 160,005 label lbl_011 ;
         of form_dados ;
         VALUE 'e-mail' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 180,005 textbox tbox_011 ;
         of form_dados ;
         HEIGHT 027 ;
         WIDTH 450 ;
         VALUE x_email ;
         MAXLENGTH 050 ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         lowercase
      @ 210,005 label lbl_012 ;
         of form_dados ;
         VALUE 'Dia anivers�rio' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 230,005 textbox tbox_012 ;
         of form_dados ;
         HEIGHT 027 ;
         WIDTH 080 ;
         VALUE x_aniv_dia ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         NUMERIC
      @ 210,120 label lbl_013 ;
         of form_dados ;
         VALUE 'M�s anivers�rio' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 230,120 textbox tbox_013 ;
         of form_dados ;
         HEIGHT 027 ;
         WIDTH 080 ;
         VALUE x_aniv_mes ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         NUMERIC

      * texto de observa��o
      @ 265,005 label lbl_observacao ;
         of form_dados ;
         VALUE '* os campos na cor azul, telefones fixo e celular, ser�o utilizados no DELIVERY' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR BLUE ;
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

      * bot�es
      DEFINE BUTTONEX button_ok
         PICTURE path_imagens+'img_gravar.bmp'
         COL form_dados.width-225
         ROW form_dados.height-085
         WIDTH 120
         HEIGHT 050
         CAPTION 'Ok, gravar'
         ACTION gravar(parametro)
         FONTBOLD .T.
         TOOLTIP 'Confirmar as informa��es digitadas'
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
         TOOLTIP 'Sair desta tela sem gravar informa��es'
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

   LOCAL id := val(valor_coluna('grid_clientes','form_clientes',1))

   dbselectarea('clientes')
   clientes->(ordsetfocus('codigo'))
   clientes->(dbgotop())
   clientes->(dbseek(id))

   IF .not. found()
      msgexclamation('Selecione uma informa��o','Aten��o')
      clientes->(ordsetfocus('nome'))

      RETURN NIL
   ELSE
      IF clientes->codigo == 999999
         msgstop('Este cliente n�o pode ser exclu�do por ser padr�o do programa','Aten��o')

         RETURN NIL
      ELSE
         IF msgyesno('Nome : '+alltrim(clientes->nome),'Excluir')
            IF lock_reg()
               clientes->(dbdelete())
               clientes->(dbunlock())
               clientes->(dbgotop())
            ENDIF
            clientes->(ordsetfocus('nome'))
            atualizar()
         ENDIF
      ENDIF
   ENDIF

   RETURN NIL

STATIC FUNCTION relacao()

   LOCAL p_linha := 040
   LOCAL u_linha := 260
   LOCAL linha   := p_linha
   LOCAL pagina  := 1

   dbselectarea('clientes')
   clientes->(ordsetfocus('nome'))
   clientes->(dbgotop())

   SELECT PRINTER DIALOG PREVIEW

   START PRINTDOC NAME 'Gerenciador de impress�o'
      START PRINTPAGE

         cabecalho(pagina)

         WHILE .not. eof()

            @ linha,010 PRINT strzero(clientes->codigo,4) FONT 'courier new' SIZE 010
            @ linha,025 PRINT clientes->nome FONT 'courier new' SIZE 010
            @ linha,100 PRINT clientes->fixo FONT 'courier new' SIZE 010
            @ linha,130 PRINT clientes->celular FONT 'courier new' SIZE 010
            @ linha,160 PRINT clientes->cidade FONT 'courier new' SIZE 010

            linha += 5

            IF linha >= u_linha
            END PRINTPAGE
            START PRINTPAGE
               pagina ++
               cabecalho(pagina)
               linha := p_linha
            ENDIF

            clientes->(dbskip())

         END

         rodape()

      END PRINTPAGE
   END PRINTDOC

   RETURN NIL

STATIC FUNCTION cabecalho(p_pagina)

   @ 007,010 PRINT IMAGE path_imagens+'logotipo.bmp' WIDTH 050 HEIGHT 020 STRETCH
   @ 010,070 PRINT 'RELA��O DE CLIENTES' FONT 'courier new' SIZE 018 BOLD
   @ 018,070 PRINT 'ordem alfab�tica' FONT 'courier new' SIZE 014
   @ 024,070 PRINT 'p�gina : '+strzero(p_pagina,4) FONT 'courier new' SIZE 012

   @ 030,000 PRINT LINE TO 030,205 PENWIDTH 0.5 COLOR _preto_001

   @ 035,010 PRINT 'C�DIGO' FONT 'courier new' SIZE 010 BOLD
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

   IF retorna
      msgalert('Preencha todos os campos','Aten��o')

      RETURN NIL
   ENDIF

   IF parametro == 1
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
      IF l_demo
         IF reccount() > _limite_registros
            msgstop('Limite de registros esgotado','Aten��o')

            RETURN NIL
         ENDIF
      ENDIF
      clientes->(dbappend())
      clientes->codigo   := codigo
      clientes->nome     := form_dados.tbox_001.value
      clientes->fixo     := form_dados.tbox_002.value
      clientes->celular  := form_dados.tbox_003.value
      clientes->endereco := form_dados.tbox_004.value
      clientes->numero   := form_dados.tbox_005.value
      clientes->complem  := form_dados.tbox_006.value
      clientes->bairro   := form_dados.tbox_007.value
      clientes->cidade   := form_dados.tbox_008.value
      clientes->uf       := form_dados.tbox_009.value
      clientes->cep      := form_dados.tbox_010.value
      clientes->email    := form_dados.tbox_011.value
      clientes->aniv_dia := form_dados.tbox_012.value
      clientes->aniv_mes := form_dados.tbox_013.value
      clientes->(dbcommit())
      clientes->(dbgotop())
      form_dados.release
      atualizar()
   ELSEIF parametro == 2
      dbselectarea('clientes')
      IF lock_reg()
         clientes->nome     := form_dados.tbox_001.value
         clientes->fixo     := form_dados.tbox_002.value
         clientes->celular  := form_dados.tbox_003.value
         clientes->endereco := form_dados.tbox_004.value
         clientes->numero   := form_dados.tbox_005.value
         clientes->complem  := form_dados.tbox_006.value
         clientes->bairro   := form_dados.tbox_007.value
         clientes->cidade   := form_dados.tbox_008.value
         clientes->uf       := form_dados.tbox_009.value
         clientes->cep      := form_dados.tbox_010.value
         clientes->email    := form_dados.tbox_011.value
         clientes->aniv_dia := form_dados.tbox_012.value
         clientes->aniv_mes := form_dados.tbox_013.value
         clientes->(dbcommit())
         clientes->(dbunlock())
         clientes->(dbgotop())
      ENDIF
      form_dados.release
      atualizar()
   ENDIF

   RETURN NIL

STATIC FUNCTION pesquisar()

   LOCAL cPesq        := alltrim(form_clientes.tbox_pesquisa.value)
   LOCAL lGridFreeze  := .T.
   LOCAL nTamNomePesq := len(cPesq)

   dbselectarea('clientes')
   clientes->(ordsetfocus('nome'))
   clientes->(dbseek(cPesq))

   IF lGridFreeze
      form_clientes.grid_clientes.disableupdate
   ENDIF

   DELETE item all from grid_clientes of form_clientes

   WHILE .not. eof()
      IF substr(field->nome,1,nTamNomePesq) == cPesq
         add item {str(clientes->codigo),alltrim(clientes->nome),alltrim(clientes->fixo),alltrim(clientes->celular)} to grid_clientes of form_clientes
      ELSEIF substr(field->nome,1,nTamNomePesq) > cPesq
         EXIT
      ENDIF
      clientes->(dbskip())
   END

   IF lGridFreeze
      form_clientes.grid_clientes.enableupdate
   ENDIF

   RETURN NIL

STATIC FUNCTION atualizar()

   DELETE item all from grid_clientes of form_clientes

   dbselectarea('clientes')
   clientes->(ordsetfocus('nome'))
   clientes->(dbgotop())

   WHILE .not. eof()
      add item {str(clientes->codigo),alltrim(clientes->nome),alltrim(clientes->fixo),alltrim(clientes->celular)} to grid_clientes of form_clientes
      clientes->(dbskip())
   END

   RETURN NIL
