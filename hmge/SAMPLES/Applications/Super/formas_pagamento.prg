/*
sistema     : superchef pizzaria
programa    : formas de pagamento
compilador  : xharbour 1.2 simplex
lib gráfica : minigui 1.7 extended
programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'super.ch'

FUNCTION formas_pagamento()

   dbselectarea('formas_pagamento')
   ordsetfocus('nome')
   formas_pagamento->(dbgotop())

   DEFINE WINDOW form_formas_pagamento;
         at 000,000;
         WIDTH 800;
         HEIGHT 605;
         TITLE 'Formas de Pagamento';
         ICON path_imagens+'icone.ico';
         modal;
         nosize;
         on init pesquisar()

      * botões (toolbar)
      DEFINE BUTTONEX button_incluir
         PICTURE path_imagens+'incluir.bmp'
         COL 005
         ROW 002
         WIDTH 100
         HEIGHT 100
         caption 'F5 Incluir'
         action dados(1)
         fontname 'verdana'
         fontsize 009
         fontbold .T.
         fontcolor _preto_001
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
         caption 'F6 Alterar'
         action dados(2)
         fontname 'verdana'
         fontsize 009
         fontbold .T.
         fontcolor _preto_001
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
         caption 'F7 Excluir'
         action excluir()
         fontname 'verdana'
         fontsize 009
         fontbold .T.
         fontcolor _preto_001
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
         caption 'F8 Imprimir'
         action relacao()
         fontname 'verdana'
         fontsize 009
         fontbold .T.
         fontcolor _preto_001
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
         caption 'Atualizar'
         action atualizar()
         fontname 'verdana'
         fontsize 009
         fontbold .T.
         fontcolor _preto_001
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
         caption 'ESC Voltar'
         action form_formas_pagamento.release
         fontname 'verdana'
         fontsize 009
         fontbold .T.
         fontcolor _preto_001
         vertical .T.
         flat .T.
         noxpstyle .T.
         BACKCOLOR _branco_001
      END BUTTONEX

      DEFINE SPLITBOX
         DEFINE GRID grid_formas_pagamento
            parent form_formas_pagamento
            COL 000
            ROW 105
            WIDTH 795
            HEIGHT 430
            headers {'Código','Nome','Banco','Dias p/pag.'}
            widths {100,350,200,100}
            fontname 'verdana'
            fontsize 010
            fontbold .T.
            BACKCOLOR _amarelo_001
            fontcolor _preto_001
            ondblclick dados(2)
         END GRID
      END SPLITBOX

      DEFINE LABEL rodape_001
         parent form_formas_pagamento
         COL 005
         ROW 545
         value 'Digite sua pesquisa'
         autosize .T.
         fontname 'verdana'
         fontsize 010
         fontbold .T.
         fontcolor _cinza_001
         transparent .T.
      END LABEL
      @ 540,160 textbox tbox_pesquisa;
         of form_formas_pagamento;
         HEIGHT 027;
         WIDTH 300;
         value '';
         maxlength 040;
         font 'verdana' size 010;
         BACKCOLOR _fundo_get;
         fontcolor _letra_get_1;
         uppercase;
         on change pesquisar()
      DEFINE LABEL rodape_002
         parent form_formas_pagamento
         COL form_formas_pagamento.width - 270
         ROW 545
         value 'DUPLO CLIQUE : Alterar informação'
         autosize .T.
         fontname 'verdana'
         fontsize 010
         fontbold .T.
         fontcolor _verde_002
         transparent .T.
      END LABEL

      ON KEY F5 ACTION dados(1)
      ON KEY F6 ACTION dados(2)
      ON KEY F7 ACTION excluir()
      ON KEY F8 ACTION relacao()
      ON KEY ESCAPE ACTION thiswindow.release

   END WINDOW

   form_formas_pagamento.center
   form_formas_pagamento.activate

   RETURN NIL

STATIC FUNCTION dados(parametro)

   LOCAL id
   LOCAL titulo  := ''
   LOCAL x_nome  := ''
   LOCAL x_banco := 0
   LOCAL x_dias  := 0

   IF parametro == 1
      titulo := 'Incluir'
   ELSEIF parametro == 2
      id     := val(valor_coluna('grid_formas_pagamento','form_formas_pagamento',1))
      titulo := 'Alterar'
      dbselectarea('formas_pagamento')
      formas_pagamento->(ordsetfocus('codigo'))
      formas_pagamento->(dbgotop())
      formas_pagamento->(dbseek(id))
      IF found()
         x_nome  := formas_pagamento->nome
         x_banco := formas_pagamento->banco
         x_dias  := formas_pagamento->dias_paga
         formas_pagamento->(ordsetfocus('nome'))
      ELSE
         msgexclamation('Selecione uma informação','Atenção')
         formas_pagamento->(ordsetfocus('nome'))

         RETURN NIL
      ENDIF
   ENDIF

   DEFINE WINDOW form_dados;
         at 000,000;
         WIDTH 325;
         HEIGHT 260;
         TITLE (titulo);
         ICON path_imagens+'icone.ico';
         modal;
         NOSIZE

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
         HEIGHT 027;
         WIDTH 310;
         value x_nome;
         maxlength 020;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         fontcolor _letra_get_1;
         uppercase
      @ 060,005 label lbl_003;
         of form_dados;
         value 'Banco/Conta';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 080,005 textbox tbox_003;
         of form_dados;
         HEIGHT 027;
         WIDTH 060;
         value x_banco;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         fontcolor _letra_get_1;
         numeric;
         on enter procura_banco('form_dados','tbox_003')
      @ 080,070 label lbl_nome_banco;
         of form_dados;
         value '';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _azul_001;
         transparent
      @ 110,005 label lbl_004;
         of form_dados;
         value 'Dias para pagar';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 130,005 textbox tbox_004;
         of form_dados;
         HEIGHT 027;
         WIDTH 060;
         value x_dias;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         fontcolor _letra_get_1;
         numeric

      * linha separadora
      DEFINE LABEL linha_rodape
         COL 000
         ROW form_dados.height-090
         value ''
         WIDTH form_dados.width
         HEIGHT 001
         BACKCOLOR _preto_001
         transparent .F.
      END LABEL

      * botões
      DEFINE BUTTONEX button_ok
         PICTURE path_imagens+'img_gravar.bmp'
         COL form_dados.width-225
         ROW form_dados.height-085
         WIDTH 120
         HEIGHT 050
         caption 'Ok, gravar'
         action gravar(parametro)
         fontbold .T.
         tooltip 'Confirmar as informações digitadas'
         flat .F.
         noxpstyle .T.
      END BUTTONEX
      DEFINE BUTTONEX button_cancela
         PICTURE path_imagens+'img_voltar.bmp'
         COL form_dados.width-100
         ROW form_dados.height-085
         WIDTH 090
         HEIGHT 050
         caption 'Voltar'
         action form_dados.release
         fontbold .T.
         tooltip 'Sair desta tela sem gravar informações'
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

   LOCAL id := val(valor_coluna('grid_formas_pagamento','form_formas_pagamento',1))

   dbselectarea('formas_pagamento')
   formas_pagamento->(ordsetfocus('codigo'))
   formas_pagamento->(dbgotop())
   formas_pagamento->(dbseek(id))

   IF .not. found()
      msgexclamation('Selecione uma informação','Atenção')
      formas_pagamento->(ordsetfocus('nome'))

      RETURN NIL
   ELSE
      IF msgyesno('Nome : '+alltrim(formas_pagamento->nome),'Excluir')
         IF lock_reg()
            formas_pagamento->(dbdelete())
            formas_pagamento->(dbunlock())
            formas_pagamento->(dbgotop())
         ENDIF
         formas_pagamento->(ordsetfocus('nome'))
         atualizar()
      ENDIF
   ENDIF

   RETURN NIL

STATIC FUNCTION relacao()

   LOCAL p_linha := 040
   LOCAL u_linha := 260
   LOCAL linha   := p_linha
   LOCAL pagina  := 1

   dbselectarea('formas_pagamento')
   formas_pagamento->(ordsetfocus('nome'))
   formas_pagamento->(dbgotop())

   SELECT PRINTER DIALOG PREVIEW

   START PRINTDOC NAME 'Gerenciador de impressão'
      START PRINTPAGE

         cabecalho(pagina)

         WHILE .not. eof()

            @ linha,030 PRINT strzero(formas_pagamento->codigo,4) FONT 'courier new' SIZE 010
            @ linha,050 PRINT formas_pagamento->nome FONT 'courier new' SIZE 010
            @ linha,110 PRINT acha_banco(formas_pagamento->banco) FONT 'courier new' SIZE 010
            @ linha,170 PRINT alltrim(str(formas_pagamento->dias_paga)) FONT 'courier new' SIZE 010

            linha += 5

            IF linha >= u_linha
            END PRINTPAGE
            START PRINTPAGE
               pagina ++
               cabecalho(pagina)
               linha := p_linha
            ENDIF

            formas_pagamento->(dbskip())

         END

         rodape()

      END PRINTPAGE
   END PRINTDOC

   RETURN NIL

STATIC FUNCTION cabecalho(p_pagina)

   @ 007,010 PRINT IMAGE path_imagens+'logotipo.bmp' WIDTH 050 HEIGHT 020 STRETCH
   @ 010,070 PRINT 'RELAÇÃO DE FORMAS DE PAGAMENTO' FONT 'courier new' SIZE 018 BOLD
   @ 018,070 PRINT 'ordem alfabética' FONT 'courier new' SIZE 014
   @ 024,070 PRINT 'página : '+strzero(p_pagina,4) FONT 'courier new' SIZE 012

   @ 030,000 PRINT LINE TO 030,205 PENWIDTH 0.5 COLOR _preto_001

   @ 035,030 PRINT 'CÓDIGO' FONT 'courier new' SIZE 010 BOLD
   @ 035,050 PRINT 'NOME' FONT 'courier new' SIZE 010 BOLD
   @ 035,110 PRINT 'BANCO/CONTA' FONT 'courier new' SIZE 010 BOLD
   @ 035,170 PRINT 'DIAS P/PAG.' FONT 'courier new' SIZE 010 BOLD

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
      msgalert('Preencha todos os campos','Atenção')

      RETURN NIL
   ENDIF

   IF parametro == 1
      WHILE .T.
         dbselectarea('conta')
         conta->(dbgotop())
         IF lock_reg()
            codigo := conta->c_fpaga
            REPLACE c_fpaga with c_fpaga + 1
            conta->(dbcommit())
            conta->(dbunlock())
            EXIT
         ELSE
            msgexclamation('Servidor congestionado, tecle ENTER e aguarde','Atenção')
            LOOP
         ENDIF
      END
      dbselectarea('formas_pagamento')
      formas_pagamento->(dbappend())
      formas_pagamento->codigo    := codigo
      formas_pagamento->nome      := form_dados.tbox_001.value
      formas_pagamento->banco     := form_dados.tbox_003.value
      formas_pagamento->dias_paga := form_dados.tbox_004.value
      formas_pagamento->(dbcommit())
      formas_pagamento->(dbgotop())
      form_dados.release
      atualizar()
   ELSEIF parametro == 2
      dbselectarea('formas_pagamento')
      IF lock_reg()
         formas_pagamento->nome      := form_dados.tbox_001.value
         formas_pagamento->banco     := form_dados.tbox_003.value
         formas_pagamento->dias_paga := form_dados.tbox_004.value
         formas_pagamento->(dbcommit())
         formas_pagamento->(dbunlock())
         formas_pagamento->(dbgotop())
      ENDIF
      form_dados.release
      atualizar()
   ENDIF

   RETURN NIL

STATIC FUNCTION pesquisar()

   LOCAL cPesq        := alltrim(form_formas_pagamento.tbox_pesquisa.value)
   LOCAL lGridFreeze  := .T.
   LOCAL nTamNomePesq := len(cPesq)

   dbselectarea('formas_pagamento')
   formas_pagamento->(ordsetfocus('nome'))
   formas_pagamento->(dbseek(cPesq))

   IF lGridFreeze
      form_formas_pagamento.grid_formas_pagamento.disableupdate
   ENDIF

   DELETE item all from grid_formas_pagamento of form_formas_pagamento

   WHILE .not. eof()
      IF substr(field->nome,1,nTamNomePesq) == cPesq
         add item {str(formas_pagamento->codigo),alltrim(formas_pagamento->nome),acha_banco(formas_pagamento->banco),str(formas_pagamento->dias_paga)} to grid_formas_pagamento of form_formas_pagamento
      ELSEIF substr(field->nome,1,nTamNomePesq) > cPesq
         EXIT
      ENDIF
      formas_pagamento->(dbskip())
   END

   IF lGridFreeze
      form_formas_pagamento.grid_formas_pagamento.enableupdate
   ENDIF

   RETURN NIL

STATIC FUNCTION atualizar()

   DELETE item all from grid_formas_pagamento of form_formas_pagamento

   dbselectarea('formas_pagamento')
   formas_pagamento->(ordsetfocus('nome'))
   formas_pagamento->(dbgotop())

   WHILE .not. eof()
      add item {str(formas_pagamento->codigo),alltrim(formas_pagamento->nome),acha_banco(formas_pagamento->banco),str(formas_pagamento->dias_paga)} to grid_formas_pagamento of form_formas_pagamento
      formas_pagamento->(dbskip())
   END

   RETURN NIL

STATIC FUNCTION procura_banco(cform,ctextbtn)

   LOCAL flag    := .F.
   LOCAL creg    := ''
   LOCAL nreg_01 := getproperty(cform,ctextbtn,'value')
   LOCAL nreg_02 := nreg_01

   dbselectarea('bancos')
   bancos->(ordsetfocus('codigo'))
   bancos->(dbgotop())
   bancos->(dbseek(nreg_02))
   IF found()
      flag := .T.
   ELSE
      creg := getcode_banco(getproperty(cform,ctextbtn,'value'))
      dbselectarea('bancos')
      bancos->(ordsetfocus('codigo'))
      bancos->(dbgotop())
      bancos->(dbseek(creg))
      IF found()
         flag := .T.
      ENDIF
   ENDIF

   IF flag
      setproperty('form_dados','lbl_nome_banco','value',bancos->nome)
   ENDIF

   IF !empty(creg)
      setproperty(cform,ctextbtn,'value',creg)
   ENDIF

   RETURN NIL

STATIC FUNCTION getcode_banco(value)

   LOCAL creg := ''
   LOCAL nreg := 1

   dbselectarea('bancos')
   bancos->(ordsetfocus('nome'))
   bancos->(dbgotop())

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
         value 'Buscar'
         autosize .T.
         fontname 'verdana'
         fontsize 012
         fontbold .T.
         fontcolor _preto_001
         transparent .T.
      END LABEL
      DEFINE TEXTBOX txt_pesquisa
         COL 075
         ROW 440
         WIDTH 400
         maxlength 040
         onchange find_banco()
         uppercase .T.
      END TEXTBOX

      DEFINE BROWSE browse_pesquisa
         ROW 002
         COL 002
         WIDTH 480
         HEIGHT 430
         headers {'Código','Nome'}
         widths {080,370}
         workarea bancos
         fields {'bancos->codigo','bancos->nome'}
         value nreg
         fontname 'verdana'
         fontsize 010
         fontbold .T.
         BACKCOLOR _ciano_001
         nolines .T.
         lock .T.
         readonly {.T.,.T.}
         justify {BROWSE_JTFY_LEFT,BROWSE_JTFY_LEFT}
         on dblclick (creg:=bancos->codigo,thiswindow.release)
      END browse

      ON KEY ESCAPE ACTION thiswindow.release

   END WINDOW

   form_pesquisa.browse_pesquisa.setfocus

   form_pesquisa.center
   form_pesquisa.activate

   return(creg)

STATIC FUNCTION find_banco()

   LOCAL pesquisa := alltrim(form_pesquisa.txt_pesquisa.value)

   bancos->(dbgotop())

   IF pesquisa == ''

      RETURN NIL
   ELSEIF bancos->(dbseek(pesquisa))
      form_pesquisa.browse_pesquisa.value := bancos->(recno())
   ENDIF

   RETURN NIL
