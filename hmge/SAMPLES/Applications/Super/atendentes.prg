/*
sistema     : superchef pizzaria
programa    : atendentes da pizzaria
compilador  : xharbour 1.2 simplex
lib gráfica : minigui 1.7 extended
programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'super.ch'

FUNCTION atendentes()

   dbselectarea('atendentes')
   ordsetfocus('nome')
   atendentes->(dbgotop())

   DEFINE WINDOW form_atendentes;
         at 000,000;
         width 800;
         height 605;
         title 'Atendentes ou Garçons';
         icon path_imagens+'icone.ico';
         modal;
         nosize;
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
      DEFINE BUTTONex button_sair
         picture path_imagens+'sair.bmp'
         col 515
         row 002
         width 100
         height 100
         caption 'ESC Voltar'
         action form_atendentes.release
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
         DEFINE GRID grid_atendentes
            parent form_atendentes
            col 000
            row 105
            width 795
            height 430
            headers {'Código','Nome','Comissão (%)'}
            widths {100,500,150}
            fontname 'verdana'
            fontsize 010
            fontbold .T.
            backcolor _amarelo_001
            fontcolor _preto_001
            ondblclick dados(2)
         END GRID
      END SPLITBOX

      DEFINE LABEL rodape_001
         parent form_atendentes
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
         of form_atendentes;
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
         parent form_atendentes
         col form_atendentes.width - 270
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

   form_atendentes.center
   form_atendentes.activate

   RETURN(nil)

STATIC FUNCTION dados(parametro)

   LOCAL id
   LOCAL titulo     := ''
   LOCAL x_nome     := ''
   LOCAL x_comissao := 0

   IF parametro == 1
      titulo := 'Incluir'
   ELSEIF parametro == 2
      id     := val(valor_coluna('grid_atendentes','form_atendentes',1))
      titulo := 'Alterar'
      dbselectarea('atendentes')
      atendentes->(ordsetfocus('codigo'))
      atendentes->(dbgotop())
      atendentes->(dbseek(id))
      IF found()
         x_nome     := atendentes->nome
         x_comissao := atendentes->comissao
         atendentes->(ordsetfocus('nome'))
      ELSE
         msgexclamation('Selecione uma informação','Atenção')
         atendentes->(ordsetfocus('nome'))

         RETURN(nil)
      ENDIF
   ENDIF

   DEFINE WINDOW form_dados;
         at 000,000;
         width 325;
         height 220;
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
         value 'Comissão (%)';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 080,005 getbox tbox_002;
         of form_dados;
         height 027;
         width 120;
         value x_comissao;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         picture '@R 999.99'

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

   END WINDOW

   sethandcursor(getcontrolhandle('button_ok','form_dados'))
   sethandcursor(getcontrolhandle('button_cancela','form_dados'))

   form_dados.center
   form_dados.activate

   RETURN(nil)

STATIC FUNCTION excluir()

   LOCAL id := val(valor_coluna('grid_atendentes','form_atendentes',1))

   dbselectarea('atendentes')
   atendentes->(ordsetfocus('codigo'))
   atendentes->(dbgotop())
   atendentes->(dbseek(id))

   IF .not. found()
      msgexclamation('Selecione uma informação','Atenção')
      atendentes->(ordsetfocus('nome'))

      RETURN(nil)
   ELSE
      IF msgyesno('Nome : '+alltrim(atendentes->nome),'Excluir')
         IF lock_reg()
            atendentes->(dbdelete())
            atendentes->(dbunlock())
            atendentes->(dbgotop())
         ENDIF
         atendentes->(ordsetfocus('nome'))
         atualizar()
      ENDIF
   ENDIF

   RETURN(nil)

STATIC FUNCTION relacao()

   LOCAL p_linha := 040
   LOCAL u_linha := 260
   LOCAL linha   := p_linha
   LOCAL pagina  := 1

   dbselectarea('atendentes')
   atendentes->(ordsetfocus('nome'))
   atendentes->(dbgotop())

   SELECT PRINTER DIALOG PREVIEW

   START PRINTDOC NAME 'Gerenciador de impressão'
      START PRINTPAGE

         cabecalho(pagina)

         WHILE .not. eof()

            @ linha,030 PRINT strzero(atendentes->codigo,4) FONT 'courier new' SIZE 010
            @ linha,045 PRINT atendentes->nome FONT 'courier new' SIZE 010
            @ linha,090 PRINT trans(atendentes->comissao,'@R 999.99') FONT 'courier new' SIZE 010

            linha += 5

            IF linha >= u_linha
            END PRINTPAGE
            START PRINTPAGE
               pagina ++
               cabecalho(pagina)
               linha := p_linha
            ENDIF

            atendentes->(dbskip())

         end

         rodape()

      END PRINTPAGE
   END PRINTDOC

   RETURN(nil)

STATIC FUNCTION cabecalho(p_pagina)

   @ 007,010 PRINT IMAGE path_imagens+'logotipo.bmp' WIDTH 050 HEIGHT 020 STRETCH
   @ 010,070 PRINT 'RELAÇÃO DE ATENDENTES/GARÇONS' FONT 'courier new' SIZE 018 BOLD
   @ 018,070 PRINT 'ordem alfabética' FONT 'courier new' SIZE 014
   @ 024,070 PRINT 'página : '+strzero(p_pagina,4) FONT 'courier new' SIZE 012

   @ 030,000 PRINT LINE TO 030,205 PENWIDTH 0.5 COLOR _preto_001

   @ 035,030 PRINT 'CÓDIGO' FONT 'courier new' SIZE 010 BOLD
   @ 035,045 PRINT 'NOME' FONT 'courier new' SIZE 010 BOLD
   @ 035,090 PRINT 'COMISSÃO (%)' FONT 'courier new' SIZE 010 BOLD

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

   IF retorna
      msgalert('Preencha todos os campos','Atenção')

      RETURN(nil)
   ENDIF

   IF parametro == 1
      WHILE .T.
         dbselectarea('conta')
         conta->(dbgotop())
         IF lock_reg()
            codigo := conta->c_atende
            REPLACE c_atende with c_atende + 1
            conta->(dbcommit())
            conta->(dbunlock())
            EXIT
         ELSE
            msgexclamation('Servidor congestionado, tecle ENTER e aguarde','Atenção')
            LOOP
         ENDIF
      end
      dbselectarea('atendentes')
      atendentes->(dbappend())
      atendentes->codigo   := codigo
      atendentes->nome     := form_dados.tbox_001.value
      atendentes->comissao := form_dados.tbox_002.value
      atendentes->(dbcommit())
      atendentes->(dbgotop())
      form_dados.release
      atualizar()
   ELSEIF parametro == 2
      dbselectarea('atendentes')
      IF lock_reg()
         atendentes->nome     := form_dados.tbox_001.value
         atendentes->comissao := form_dados.tbox_002.value
         atendentes->(dbcommit())
         atendentes->(dbunlock())
         atendentes->(dbgotop())
      ENDIF
      form_dados.release
      atualizar()
   ENDIF

   RETURN(nil)

STATIC FUNCTION pesquisar()

   LOCAL cPesq        := alltrim(form_atendentes.tbox_pesquisa.value)
   LOCAL lGridFreeze  := .T.
   LOCAL nTamNomePesq := len(cPesq)

   dbselectarea('atendentes')
   atendentes->(ordsetfocus('nome'))
   atendentes->(dbseek(cPesq))

   IF lGridFreeze
      form_atendentes.grid_atendentes.disableupdate
   ENDIF

   DELETE item all from grid_atendentes of form_atendentes

   WHILE .not. eof()
      IF substr(field->nome,1,nTamNomePesq) == cPesq
         add item {str(atendentes->codigo),alltrim(atendentes->nome),trans(atendentes->comissao,'@R 999.99')} to grid_atendentes of form_atendentes
      ELSEIF substr(field->nome,1,nTamNomePesq) > cPesq
         EXIT
      ENDIF
      atendentes->(dbskip())
   end

   IF lGridFreeze
      form_atendentes.grid_atendentes.enableupdate
   ENDIF

   RETURN(nil)

STATIC FUNCTION atualizar()

   DELETE item all from grid_atendentes of form_atendentes

   dbselectarea('atendentes')
   atendentes->(ordsetfocus('nome'))
   atendentes->(dbgotop())

   WHILE .not. eof()
      add item {str(atendentes->codigo),alltrim(atendentes->nome),trans(atendentes->comissao,'@R 999.99')} to grid_atendentes of form_atendentes
      atendentes->(dbskip())
   end

   RETURN(nil)

