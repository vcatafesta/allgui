/*
sistema     : superchef pizzaria
programa    : contas banc�rias
compilador  : xharbour 1.2 simplex
lib gr�fica : minigui 1.7 extended
programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'super.ch'

FUNCTION contas_bancarias()

   dbselectarea('bancos')
   ordsetfocus('nome')
   bancos->(dbgotop())

   DEFINE WINDOW form_bancos ;
         at 000,000 ;
         WIDTH 800 ;
         HEIGHT 605 ;
         TITLE 'Contas Banc�rias' ;
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
         ACTION form_bancos.release
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
         DEFINE GRID grid_bancos
            PARENT form_bancos
            COL 000
            ROW 105
            WIDTH 795
            HEIGHT 430
            HEADERS {'C�digo','Nome','Banco','Ag�ncia','Conta'}
            WIDTHS {100,250,150,150,100}
            FONTNAME 'verdana'
            FONTSIZE 010
            FONTBOLD .T.
            BACKCOLOR _amarelo_001
            FONTCOLOR _preto_001
            ONDBLCLICK dados(2)
         END GRID
      END SPLITBOX

      DEFINE LABEL rodape_001
         PARENT form_bancos
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
         of form_bancos ;
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
         PARENT form_bancos
         COL form_bancos.width - 270
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

   form_bancos.center
   form_bancos.activate

   RETURN NIL

STATIC FUNCTION dados(parametro)

   LOCAL id
   LOCAL titulo     := ''
   LOCAL x_nome     := ''
   LOCAL x_banco    := ''
   LOCAL x_agencia  := ''
   LOCAL x_conta    := ''
   LOCAL x_limite   := 0
   LOCAL x_titular  := ''
   LOCAL x_gerente  := ''
   LOCAL x_telefone := ''

   IF parametro == 1
      titulo := 'Incluir'
   ELSEIF parametro == 2
      id     := val(valor_coluna('grid_bancos','form_bancos',1))
      titulo := 'Alterar'
      dbselectarea('bancos')
      bancos->(ordsetfocus('codigo'))
      bancos->(dbgotop())
      bancos->(dbseek(id))
      IF found()
         x_nome     := bancos->nome
         x_banco    := bancos->banco
         x_agencia  := bancos->agencia
         x_conta    := bancos->conta_c
         x_limite   := bancos->limite
         x_titular  := bancos->titular
         x_gerente  := bancos->gerente
         x_telefone := bancos->telefone
         bancos->(ordsetfocus('nome'))
      ELSE
         msgexclamation('Selecione uma informa��o','Aten��o')
         bancos->(ordsetfocus('nome'))

         RETURN NIL
      ENDIF
   ENDIF

   DEFINE WINDOW form_dados ;
         at 000,000 ;
         WIDTH 325 ;
         HEIGHT 420 ;
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
         MAXLENGTH 020 ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 060,005 label lbl_002 ;
         of form_dados ;
         VALUE 'Banco' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 080,005 textbox tbox_002 ;
         of form_dados ;
         HEIGHT 027 ;
         WIDTH 140 ;
         VALUE x_banco ;
         MAXLENGTH 010 ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 060,155 label lbl_003 ;
         of form_dados ;
         VALUE 'Ag�ncia' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 080,155 textbox tbox_003 ;
         of form_dados ;
         HEIGHT 027 ;
         WIDTH 140 ;
         VALUE x_agencia ;
         MAXLENGTH 010 ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 110,005 label lbl_004 ;
         of form_dados ;
         VALUE 'N� conta' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 130,005 textbox tbox_004 ;
         of form_dados ;
         HEIGHT 027 ;
         WIDTH 140 ;
         VALUE x_conta ;
         MAXLENGTH 010 ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 110,155 label lbl_005 ;
         of form_dados ;
         VALUE 'Limite R$' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 130,155 getbox tbox_005 ;
         of form_dados ;
         HEIGHT 027 ;
         WIDTH 140 ;
         VALUE x_limite ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         PICTURE '@E 999,999.99'
      @ 160,005 label lbl_006 ;
         of form_dados ;
         VALUE 'Titular da conta' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 180,005 textbox tbox_006 ;
         of form_dados ;
         HEIGHT 027 ;
         WIDTH 310 ;
         VALUE x_titular ;
         MAXLENGTH 020 ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 210,005 label lbl_007 ;
         of form_dados ;
         VALUE 'Gerente da conta' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 230,005 textbox tbox_007 ;
         of form_dados ;
         HEIGHT 027 ;
         WIDTH 310 ;
         VALUE x_gerente ;
         MAXLENGTH 020 ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE
      @ 260,005 label lbl_008 ;
         of form_dados ;
         VALUE 'Telefone' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 280,005 textbox tbox_008 ;
         of form_dados ;
         HEIGHT 027 ;
         WIDTH 140 ;
         VALUE x_telefone ;
         MAXLENGTH 010 ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         UPPERCASE

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

   LOCAL id := val(valor_coluna('grid_bancos','form_bancos',1))

   dbselectarea('bancos')
   bancos->(ordsetfocus('codigo'))
   bancos->(dbgotop())
   bancos->(dbseek(id))

   IF .not. found()
      msgexclamation('Selecione uma informa��o','Aten��o')
      bancos->(ordsetfocus('nome'))

      RETURN NIL
   ELSE
      IF msgyesno('Nome : '+alltrim(bancos->nome),'Excluir')
         IF lock_reg()
            bancos->(dbdelete())
            bancos->(dbunlock())
            bancos->(dbgotop())
         ENDIF
         bancos->(ordsetfocus('nome'))
         atualizar()
      ENDIF
   ENDIF

   RETURN NIL

STATIC FUNCTION relacao()

   LOCAL p_linha := 040
   LOCAL u_linha := 260
   LOCAL linha   := p_linha
   LOCAL pagina  := 1

   dbselectarea('bancos')
   bancos->(ordsetfocus('nome'))
   bancos->(dbgotop())

   SELECT PRINTER DIALOG PREVIEW

   START PRINTDOC NAME 'Gerenciador de impress�o'
      START PRINTPAGE

         cabecalho(pagina)

         WHILE .not. eof()

            @ linha,020 PRINT strzero(bancos->codigo,4) FONT 'courier new' SIZE 010
            @ linha,035 PRINT bancos->nome FONT 'courier new' SIZE 010
            @ linha,080 PRINT bancos->banco FONT 'courier new' SIZE 010
            @ linha,120 PRINT bancos->agencia FONT 'courier new' SIZE 010
            @ linha,160 PRINT bancos->conta_c FONT 'courier new' SIZE 010

            linha += 5

            IF linha >= u_linha
            END PRINTPAGE
            START PRINTPAGE
               pagina ++
               cabecalho(pagina)
               linha := p_linha
            ENDIF

            bancos->(dbskip())

         END

         rodape()

      END PRINTPAGE
   END PRINTDOC

   RETURN NIL

STATIC FUNCTION cabecalho(p_pagina)

   @ 007,010 PRINT IMAGE path_imagens+'logotipo.bmp' WIDTH 050 HEIGHT 020 STRETCH
   @ 010,070 PRINT 'RELA��O DE CONTAS BANC�RIAS' FONT 'courier new' SIZE 018 BOLD
   @ 018,070 PRINT 'ordem alfab�tica' FONT 'courier new' SIZE 014
   @ 024,070 PRINT 'p�gina : '+strzero(p_pagina,4) FONT 'courier new' SIZE 012

   @ 030,000 PRINT LINE TO 030,205 PENWIDTH 0.5 COLOR _preto_001

   @ 035,020 PRINT 'C�DIGO' FONT 'courier new' SIZE 010 BOLD
   @ 035,035 PRINT 'NOME' FONT 'courier new' SIZE 010 BOLD
   @ 035,080 PRINT 'BANCO' FONT 'courier new' SIZE 010 BOLD
   @ 035,120 PRINT 'AG�NCIA' FONT 'courier new' SIZE 010 BOLD
   @ 035,160 PRINT 'N� CONTA' FONT 'courier new' SIZE 010 BOLD

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
   IF empty(form_dados.tbox_004.value)
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
            codigo := conta->c_bancos
            REPLACE c_bancos with c_bancos + 1
            conta->(dbcommit())
            conta->(dbunlock())
            EXIT
         ELSE
            msgexclamation('Servidor congestionado, tecle ENTER e aguarde','Aten��o')
            LOOP
         ENDIF
      END
      dbselectarea('bancos')
      bancos->(dbappend())
      bancos->codigo   := codigo
      bancos->nome     := form_dados.tbox_001.value
      bancos->banco    := form_dados.tbox_002.value
      bancos->agencia  := form_dados.tbox_003.value
      bancos->conta_c  := form_dados.tbox_004.value
      bancos->limite   := form_dados.tbox_005.value
      bancos->titular  := form_dados.tbox_006.value
      bancos->gerente  := form_dados.tbox_007.value
      bancos->telefone := form_dados.tbox_008.value
      bancos->(dbcommit())
      bancos->(dbgotop())
      form_dados.release
      atualizar()
   ELSEIF parametro == 2
      dbselectarea('bancos')
      IF lock_reg()
         bancos->nome     := form_dados.tbox_001.value
         bancos->banco    := form_dados.tbox_002.value
         bancos->agencia  := form_dados.tbox_003.value
         bancos->conta_c  := form_dados.tbox_004.value
         bancos->limite   := form_dados.tbox_005.value
         bancos->titular  := form_dados.tbox_006.value
         bancos->gerente  := form_dados.tbox_007.value
         bancos->telefone := form_dados.tbox_008.value
         bancos->(dbcommit())
         bancos->(dbunlock())
         bancos->(dbgotop())
      ENDIF
      form_dados.release
      atualizar()
   ENDIF

   RETURN NIL

STATIC FUNCTION pesquisar()

   LOCAL cPesq        := alltrim(form_bancos.tbox_pesquisa.value)
   LOCAL lGridFreeze  := .T.
   LOCAL nTamNomePesq := len(cPesq)

   dbselectarea('bancos')
   bancos->(ordsetfocus('nome'))
   bancos->(dbseek(cPesq))

   IF lGridFreeze
      form_bancos.grid_bancos.disableupdate
   ENDIF

   DELETE item all from grid_bancos of form_bancos

   WHILE .not. eof()
      IF substr(field->nome,1,nTamNomePesq) == cPesq
         add item {str(bancos->codigo),alltrim(bancos->nome),alltrim(bancos->banco),alltrim(bancos->agencia),alltrim(bancos->conta_c)} to grid_bancos of form_bancos
      ELSEIF substr(field->nome,1,nTamNomePesq) > cPesq
         EXIT
      ENDIF
      bancos->(dbskip())
   END

   IF lGridFreeze
      form_bancos.grid_bancos.enableupdate
   ENDIF

   RETURN NIL

STATIC FUNCTION atualizar()

   DELETE item all from grid_bancos of form_bancos

   dbselectarea('bancos')
   bancos->(ordsetfocus('nome'))
   bancos->(dbgotop())

   WHILE .not. eof()
      add item {str(bancos->codigo),alltrim(bancos->nome),alltrim(bancos->banco),alltrim(bancos->agencia),alltrim(bancos->conta_c)} to grid_bancos of form_bancos
      bancos->(dbskip())
   END

   RETURN NIL
