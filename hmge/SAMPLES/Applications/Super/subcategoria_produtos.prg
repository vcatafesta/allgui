/*
sistema     : superchef pizzaria
programa    : subcategoria produtos
compilador  : xharbour 1.2 simplex
lib gráfica : minigui 1.7 extended
programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'super.ch'

FUNCTION subcategoria_produtos()

   dbselectarea('subcategoria_produtos')
   ordsetfocus('nome')
   subcategoria_produtos->(dbgotop())

   DEFINE WINDOW form_subcategoria_produtos;
         at 000,000;
         width 800;
         height 605;
         title 'Sub-Categorias de Produtos';
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
      end buttonex
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
      end buttonex
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
      end buttonex
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
      end buttonex
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
      end buttonex
      DEFINE BUTTONEX button_sair
         picture path_imagens+'sair.bmp'
         col 515
         row 002
         width 100
         height 100
         caption 'ESC Voltar'
         action form_subcategoria_produtos.release
         fontname 'verdana'
         fontsize 009
         fontbold .T.
         fontcolor _preto_001
         vertical .T.
         flat .T.
         noxpstyle .T.
         backcolor _branco_001
      end buttonex

      DEFINE SPLITBOX
         DEFINE GRID grid_subcategoria_produtos
            parent form_subcategoria_produtos
            col 000
            row 105
            width 795
            height 430
            headers {'Código','Nome'}
            widths {100,650}
            fontname 'verdana'
            fontsize 010
            fontbold .T.
            backcolor _amarelo_001
            fontcolor _preto_001
            ondblclick dados(2)
         END GRID
      END SPLITBOX

      DEFINE LABEL rodape_001
         parent form_subcategoria_produtos
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
         of form_subcategoria_produtos;
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
         parent form_subcategoria_produtos
         col form_subcategoria_produtos.width - 270
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

   form_subcategoria_produtos.center
   form_subcategoria_produtos.activate

   return(nil)

STATIC FUNCTION dados(parametro)

   LOCAL id
   LOCAL titulo := ''
   LOCAL x_nome := ''

   IF parametro == 1
      titulo := 'Incluir'
   ELSEIF parametro == 2
      id     := val(valor_coluna('grid_subcategoria_produtos','form_subcategoria_produtos',1))
      titulo := 'Alterar'
      dbselectarea('subcategoria_produtos')
      subcategoria_produtos->(ordsetfocus('codigo'))
      subcategoria_produtos->(dbgotop())
      subcategoria_produtos->(dbseek(id))
      IF found()
         x_nome := subcategoria_produtos->nome
         subcategoria_produtos->(ordsetfocus('nome'))
      ELSE
         msgexclamation('Selecione uma informação','Atenção')
         subcategoria_produtos->(ordsetfocus('nome'))

         return(nil)
      ENDIF
   ENDIF

   DEFINE WINDOW form_dados;
         at 000,000;
         width 325;
         height 200;
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
      end buttonex
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
      end buttonex

   END WINDOW

   sethandcursor(getcontrolhandle('button_ok','form_dados'))
   sethandcursor(getcontrolhandle('button_cancela','form_dados'))

   form_dados.center
   form_dados.activate

   return(nil)

STATIC FUNCTION excluir()

   LOCAL id := val(valor_coluna('grid_subcategoria_produtos','form_subcategoria_produtos',1))

   dbselectarea('subcategoria_produtos')
   subcategoria_produtos->(ordsetfocus('codigo'))
   subcategoria_produtos->(dbgotop())
   subcategoria_produtos->(dbseek(id))

   IF .not. found()
      msgexclamation('Selecione uma informação','Atenção')
      subcategoria_produtos->(ordsetfocus('nome'))

      return(nil)
   ELSE
      IF msgyesno('Nome : '+alltrim(subcategoria_produtos->nome),'Excluir')
         IF lock_reg()
            subcategoria_produtos->(dbdelete())
            subcategoria_produtos->(dbunlock())
            subcategoria_produtos->(dbgotop())
         ENDIF
         subcategoria_produtos->(ordsetfocus('nome'))
         atualizar()
      ENDIF
   ENDIF

   return(nil)

STATIC FUNCTION relacao()

   LOCAL p_linha := 040
   LOCAL u_linha := 260
   LOCAL linha   := p_linha
   LOCAL pagina  := 1

   dbselectarea('subcategoria_produtos')
   subcategoria_produtos->(ordsetfocus('nome'))
   subcategoria_produtos->(dbgotop())

   SELECT PRINTER DIALOG PREVIEW

   START PRINTDOC NAME 'Gerenciador de impressão'
      START PRINTPAGE

         cabecalho(pagina)

         WHILE .not. eof()

            @ linha,030 PRINT strzero(subcategoria_produtos->codigo,4) FONT 'courier new' SIZE 010
            @ linha,045 PRINT subcategoria_produtos->nome FONT 'courier new' SIZE 010

            linha += 5

            IF linha >= u_linha
            END PRINTPAGE
            START PRINTPAGE
               pagina ++
               cabecalho(pagina)
               linha := p_linha
            ENDIF

            subcategoria_produtos->(dbskip())

         end

         rodape()

      END PRINTPAGE
   END PRINTDOC

   return(nil)

STATIC FUNCTION cabecalho(p_pagina)

   @ 007,010 PRINT IMAGE path_imagens+'logotipo.bmp' WIDTH 050 HEIGHT 020 STRETCH
   @ 010,070 PRINT 'RELAÇÃO DE SUB-CATEGORIA PRODUTOS' FONT 'courier new' SIZE 018 BOLD
   @ 018,070 PRINT 'ordem alfabética' FONT 'courier new' SIZE 014
   @ 024,070 PRINT 'página : '+strzero(p_pagina,4) FONT 'courier new' SIZE 012

   @ 030,000 PRINT LINE TO 030,205 PENWIDTH 0.5 COLOR _preto_001

   @ 035,030 PRINT 'CÓDIGO' FONT 'courier new' SIZE 010 BOLD
   @ 035,045 PRINT 'NOME' FONT 'courier new' SIZE 010 BOLD

   return(nil)

STATIC FUNCTION rodape()

   @ 275,000 PRINT LINE TO 275,205 PENWIDTH 0.5 COLOR _preto_001
   @ 276,010 PRINT 'impresso em '+dtoc(date())+' as '+time() FONT 'courier new' SIZE 008

   return(nil)

STATIC FUNCTION gravar(parametro)

   LOCAL codigo  := 0
   LOCAL retorna := .F.

   IF empty(form_dados.tbox_001.value)
      retorna := .T.
   ENDIF

   IF retorna
      msgalert('Preencha todos os campos','Atenção')

      return(nil)
   ENDIF

   IF parametro == 1
      WHILE .T.
         dbselectarea('conta')
         conta->(dbgotop())
         IF lock_reg()
            codigo := conta->c_scatprod
            REPLACE c_scatprod with c_scatprod + 1
            conta->(dbcommit())
            conta->(dbunlock())
            EXIT
         ELSE
            msgexclamation('Servidor congestionado, tecle ENTER e aguarde','Atenção')
            LOOP
         ENDIF
      end
      dbselectarea('subcategoria_produtos')
      subcategoria_produtos->(dbappend())
      subcategoria_produtos->codigo := codigo
      subcategoria_produtos->nome   := form_dados.tbox_001.value
      subcategoria_produtos->(dbcommit())
      subcategoria_produtos->(dbgotop())
      form_dados.release
      atualizar()
   ELSEIF parametro == 2
      dbselectarea('subcategoria_produtos')
      IF lock_reg()
         subcategoria_produtos->nome := form_dados.tbox_001.value
         subcategoria_produtos->(dbcommit())
         subcategoria_produtos->(dbunlock())
         subcategoria_produtos->(dbgotop())
      ENDIF
      form_dados.release
      atualizar()
   ENDIF

   return(nil)

STATIC FUNCTION pesquisar()

   LOCAL cPesq        := alltrim(form_subcategoria_produtos.tbox_pesquisa.value)
   LOCAL lGridFreeze  := .T.
   LOCAL nTamNomePesq := len(cPesq)

   dbselectarea('subcategoria_produtos')
   subcategoria_produtos->(ordsetfocus('nome'))
   subcategoria_produtos->(dbseek(cPesq))

   IF lGridFreeze
      form_subcategoria_produtos.grid_subcategoria_produtos.disableupdate
   ENDIF

   DELETE item all from grid_subcategoria_produtos of form_subcategoria_produtos

   WHILE .not. eof()
      IF substr(field->nome,1,nTamNomePesq) == cPesq
         add item {str(subcategoria_produtos->codigo),alltrim(subcategoria_produtos->nome)} to grid_subcategoria_produtos of form_subcategoria_produtos
      ELSEIF substr(field->nome,1,nTamNomePesq) > cPesq
         EXIT
      ENDIF
      subcategoria_produtos->(dbskip())
   end

   IF lGridFreeze
      form_subcategoria_produtos.grid_subcategoria_produtos.enableupdate
   ENDIF

   return(nil)

STATIC FUNCTION atualizar()

   DELETE item all from grid_subcategoria_produtos of form_subcategoria_produtos

   dbselectarea('subcategoria_produtos')
   subcategoria_produtos->(ordsetfocus('nome'))
   subcategoria_produtos->(dbgotop())

   WHILE .not. eof()
      add item {str(subcategoria_produtos->codigo),alltrim(subcategoria_produtos->nome)} to grid_subcategoria_produtos of form_subcategoria_produtos
      subcategoria_produtos->(dbskip())
   end

   return(nil)
