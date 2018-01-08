/*
sistema     : superchef pizzaria
programa    : unidades de medida
compilador  : xharbour 1.2 simplex
lib gráfica : minigui 1.7 extended
programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'super.ch'

FUNCTION unidades_medida()

   dbselectarea('unidade_medida')
   ordsetfocus('nome')
   unidade_medida->(dbgotop())

   DEFINE WINDOW form_unidade_medida;
         at 000,000;
         WIDTH 800;
         HEIGHT 605;
         TITLE 'Unidades de Medida';
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
         ACTION form_unidade_medida.release
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
         DEFINE GRID grid_unidade_medida
            parent form_unidade_medida
            COL 000
            ROW 105
            WIDTH 795
            HEIGHT 430
            HEADERS {'Código','Nome'}
            WIDTHS {100,650}
            FONTNAME 'verdana'
            FONTSIZE 010
            FONTBOLD .T.
            BACKCOLOR _amarelo_001
            FONTCOLOR _preto_001
            ondblclick dados(2)
         END GRID
      END SPLITBOX

      DEFINE LABEL rodape_001
         parent form_unidade_medida
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
         of form_unidade_medida;
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
         parent form_unidade_medida
         COL form_unidade_medida.width - 270
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

   form_unidade_medida.center
   form_unidade_medida.activate

   RETURN NIL

STATIC FUNCTION dados(parametro)

   LOCAL id
   LOCAL titulo := ''
   LOCAL x_nome := ''

   IF parametro == 1
      titulo := 'Incluir'
   ELSEIF parametro == 2
      id     := val(valor_coluna('grid_unidade_medida','form_unidade_medida',1))
      titulo := 'Alterar'
      dbselectarea('unidade_medida')
      unidade_medida->(ordsetfocus('codigo'))
      unidade_medida->(dbgotop())
      unidade_medida->(dbseek(id))
      IF found()
         x_nome := unidade_medida->nome
         unidade_medida->(ordsetfocus('nome'))
      ELSE
         msgexclamation('Selecione uma informação','Atenção')
         unidade_medida->(ordsetfocus('nome'))

         RETURN NIL
      ENDIF
   ENDIF

   DEFINE WINDOW form_dados;
         at 000,000;
         WIDTH 325;
         HEIGHT 200;
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
         MAXLENGTH 010;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         uppercase

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

   LOCAL id := val(valor_coluna('grid_unidade_medida','form_unidade_medida',1))

   dbselectarea('unidade_medida')
   unidade_medida->(ordsetfocus('codigo'))
   unidade_medida->(dbgotop())
   unidade_medida->(dbseek(id))

   IF .not. found()
      msgexclamation('Selecione uma informação','Atenção')
      unidade_medida->(ordsetfocus('nome'))

      RETURN NIL
   ELSE
      IF msgyesno('Nome : '+alltrim(unidade_medida->nome),'Excluir')
         IF lock_reg()
            unidade_medida->(dbdelete())
            unidade_medida->(dbunlock())
            unidade_medida->(dbgotop())
         ENDIF
         unidade_medida->(ordsetfocus('nome'))
         atualizar()
      ENDIF
   ENDIF

   RETURN NIL

STATIC FUNCTION relacao()

   LOCAL p_linha := 040
   LOCAL u_linha := 260
   LOCAL linha   := p_linha
   LOCAL pagina  := 1

   dbselectarea('unidade_medida')
   unidade_medida->(ordsetfocus('nome'))
   unidade_medida->(dbgotop())

   SELECT PRINTER DIALOG PREVIEW

   START PRINTDOC NAME 'Gerenciador de impressão'
      START PRINTPAGE

         cabecalho(pagina)

         WHILE .not. eof()

            @ linha,030 PRINT strzero(unidade_medida->codigo,4) FONT 'courier new' SIZE 010
            @ linha,045 PRINT unidade_medida->nome FONT 'courier new' SIZE 010

            linha += 5

            IF linha >= u_linha
            END PRINTPAGE
            START PRINTPAGE
               pagina ++
               cabecalho(pagina)
               linha := p_linha
            ENDIF

            unidade_medida->(dbskip())

         END

         rodape()

      END PRINTPAGE
   END PRINTDOC

   RETURN NIL

STATIC FUNCTION cabecalho(p_pagina)

   @ 007,010 PRINT IMAGE path_imagens+'logotipo.bmp' WIDTH 050 HEIGHT 020 STRETCH
   @ 010,070 PRINT 'RELAÇÃO DE UNIDADES DE MEDIDA' FONT 'courier new' SIZE 018 BOLD
   @ 018,070 PRINT 'ordem alfabética' FONT 'courier new' SIZE 014
   @ 024,070 PRINT 'página : '+strzero(p_pagina,4) FONT 'courier new' SIZE 012

   @ 030,000 PRINT LINE TO 030,205 PENWIDTH 0.5 COLOR _preto_001

   @ 035,030 PRINT 'CÓDIGO' FONT 'courier new' SIZE 010 BOLD
   @ 035,045 PRINT 'NOME' FONT 'courier new' SIZE 010 BOLD

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
            codigo := conta->c_umedida
            REPLACE c_umedida with c_umedida + 1
            conta->(dbcommit())
            conta->(dbunlock())
            EXIT
         ELSE
            msgexclamation('Servidor congestionado, tecle ENTER e aguarde','Atenção')
            LOOP
         ENDIF
      END
      dbselectarea('unidade_medida')
      unidade_medida->(dbappend())
      unidade_medida->codigo := codigo
      unidade_medida->nome   := form_dados.tbox_001.value
      unidade_medida->(dbcommit())
      unidade_medida->(dbgotop())
      form_dados.release
      atualizar()
   ELSEIF parametro == 2
      dbselectarea('unidade_medida')
      IF lock_reg()
         unidade_medida->nome := form_dados.tbox_001.value
         unidade_medida->(dbcommit())
         unidade_medida->(dbunlock())
         unidade_medida->(dbgotop())
      ENDIF
      form_dados.release
      atualizar()
   ENDIF

   RETURN NIL

STATIC FUNCTION pesquisar()

   LOCAL cPesq        := alltrim(form_unidade_medida.tbox_pesquisa.value)
   LOCAL lGridFreeze  := .T.
   LOCAL nTamNomePesq := len(cPesq)

   dbselectarea('unidade_medida')
   unidade_medida->(ordsetfocus('nome'))
   unidade_medida->(dbseek(cPesq))

   IF lGridFreeze
      form_unidade_medida.grid_unidade_medida.disableupdate
   ENDIF

   DELETE item all from grid_unidade_medida of form_unidade_medida

   WHILE .not. eof()
      IF substr(field->nome,1,nTamNomePesq) == cPesq
         add item {str(unidade_medida->codigo),alltrim(unidade_medida->nome)} to grid_unidade_medida of form_unidade_medida
      ELSEIF substr(field->nome,1,nTamNomePesq) > cPesq
         EXIT
      ENDIF
      unidade_medida->(dbskip())
   END

   IF lGridFreeze
      form_unidade_medida.grid_unidade_medida.enableupdate
   ENDIF

   RETURN NIL

STATIC FUNCTION atualizar()

   DELETE item all from grid_unidade_medida of form_unidade_medida

   dbselectarea('unidade_medida')
   unidade_medida->(ordsetfocus('nome'))
   unidade_medida->(dbgotop())

   WHILE .not. eof()
      add item {str(unidade_medida->codigo),alltrim(unidade_medida->nome)} to grid_unidade_medida of form_unidade_medida
      unidade_medida->(dbskip())
   END

   RETURN NIL
