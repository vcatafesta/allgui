/*
sistema     : superchef pizzaria
programa    : contas bancárias
compilador  : xharbour 1.2 simplex
lib gráfica : minigui 1.7 extended
programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'super.ch'

FUNCTION contas_bancarias()

   dbselectarea('bancos')
   ordsetfocus('nome')
   bancos->(dbgotop())

   DEFINE WINDOW form_bancos;
         at 000,000;
         width 800;
         height 605;
         title 'Contas Bancárias';
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
      DEFINE BUTTONEX button_sair
         picture path_imagens+'sair.bmp'
         col 515
         row 002
         width 100
         height 100
         caption 'ESC Voltar'
         action form_bancos.release
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
         DEFINE GRID grid_bancos
            parent form_bancos
            col 000
            row 105
            width 795
            height 430
            headers {'Código','Nome','Banco','Agência','Conta'}
            widths {100,250,150,150,100}
            fontname 'verdana'
            fontsize 010
            fontbold .T.
            backcolor _amarelo_001
            fontcolor _preto_001
            ondblclick dados(2)
         END GRID
      END SPLITBOX

      DEFINE LABEL rodape_001
         parent form_bancos
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
         of form_bancos;
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
         parent form_bancos
         col form_bancos.width - 270
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

   form_bancos.center
   form_bancos.activate

   RETURN(nil)

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
         msgexclamation('Selecione uma informação','Atenção')
         bancos->(ordsetfocus('nome'))

         RETURN(nil)
      ENDIF
   ENDIF

   DEFINE WINDOW form_dados;
         at 000,000;
         width 325;
         height 420;
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
         value 'Banco';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 080,005 textbox tbox_002;
         of form_dados;
         height 027;
         width 140;
         value x_banco;
         maxlength 010;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         uppercase
      @ 060,155 label lbl_003;
         of form_dados;
         value 'Agência';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 080,155 textbox tbox_003;
         of form_dados;
         height 027;
         width 140;
         value x_agencia;
         maxlength 010;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         uppercase
      @ 110,005 label lbl_004;
         of form_dados;
         value 'Nº conta';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 130,005 textbox tbox_004;
         of form_dados;
         height 027;
         width 140;
         value x_conta;
         maxlength 010;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         uppercase
      @ 110,155 label lbl_005;
         of form_dados;
         value 'Limite R$';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 130,155 getbox tbox_005;
         of form_dados;
         height 027;
         width 140;
         value x_limite;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         picture '@E 999,999.99'
      @ 160,005 label lbl_006;
         of form_dados;
         value 'Titular da conta';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 180,005 textbox tbox_006;
         of form_dados;
         height 027;
         width 310;
         value x_titular;
         maxlength 020;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         uppercase
      @ 210,005 label lbl_007;
         of form_dados;
         value 'Gerente da conta';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 230,005 textbox tbox_007;
         of form_dados;
         height 027;
         width 310;
         value x_gerente;
         maxlength 020;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         uppercase
      @ 260,005 label lbl_008;
         of form_dados;
         value 'Telefone';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 280,005 textbox tbox_008;
         of form_dados;
         height 027;
         width 140;
         value x_telefone;
         maxlength 010;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         uppercase

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

   LOCAL id := val(valor_coluna('grid_bancos','form_bancos',1))

   dbselectarea('bancos')
   bancos->(ordsetfocus('codigo'))
   bancos->(dbgotop())
   bancos->(dbseek(id))

   IF .not. found()
      msgexclamation('Selecione uma informação','Atenção')
      bancos->(ordsetfocus('nome'))

      RETURN(nil)
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

   RETURN(nil)

STATIC FUNCTION relacao()

   LOCAL p_linha := 040
   LOCAL u_linha := 260
   LOCAL linha   := p_linha
   LOCAL pagina  := 1

   dbselectarea('bancos')
   bancos->(ordsetfocus('nome'))
   bancos->(dbgotop())

   SELECT PRINTER DIALOG PREVIEW

   START PRINTDOC NAME 'Gerenciador de impressão'
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

         end

         rodape()

      END PRINTPAGE
   END PRINTDOC

   RETURN(nil)

STATIC FUNCTION cabecalho(p_pagina)

   @ 007,010 PRINT IMAGE path_imagens+'logotipo.bmp' WIDTH 050 HEIGHT 020 STRETCH
   @ 010,070 PRINT 'RELAÇÃO DE CONTAS BANCÁRIAS' FONT 'courier new' SIZE 018 BOLD
   @ 018,070 PRINT 'ordem alfabética' FONT 'courier new' SIZE 014
   @ 024,070 PRINT 'página : '+strzero(p_pagina,4) FONT 'courier new' SIZE 012

   @ 030,000 PRINT LINE TO 030,205 PENWIDTH 0.5 COLOR _preto_001

   @ 035,020 PRINT 'CÓDIGO' FONT 'courier new' SIZE 010 BOLD
   @ 035,035 PRINT 'NOME' FONT 'courier new' SIZE 010 BOLD
   @ 035,080 PRINT 'BANCO' FONT 'courier new' SIZE 010 BOLD
   @ 035,120 PRINT 'AGÊNCIA' FONT 'courier new' SIZE 010 BOLD
   @ 035,160 PRINT 'Nº CONTA' FONT 'courier new' SIZE 010 BOLD

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
   IF empty(form_dados.tbox_004.value)
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
            codigo := conta->c_bancos
            REPLACE c_bancos with c_bancos + 1
            conta->(dbcommit())
            conta->(dbunlock())
            EXIT
         ELSE
            msgexclamation('Servidor congestionado, tecle ENTER e aguarde','Atenção')
            LOOP
         ENDIF
      end
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

   RETURN(nil)

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
   end

   IF lGridFreeze
      form_bancos.grid_bancos.enableupdate
   ENDIF

   RETURN(nil)

STATIC FUNCTION atualizar()

   DELETE item all from grid_bancos of form_bancos

   dbselectarea('bancos')
   bancos->(ordsetfocus('nome'))
   bancos->(dbgotop())

   WHILE .not. eof()
      add item {str(bancos->codigo),alltrim(bancos->nome),alltrim(bancos->banco),alltrim(bancos->agencia),alltrim(bancos->conta_c)} to grid_bancos of form_bancos
      bancos->(dbskip())
   end

   RETURN(nil)

