/*
sistema     : superchef pizzaria
programa    : grupo fornecedores
compilador  : xharbour 1.2 simplex
lib gr�fica : minigui 1.7 extended
programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'super.ch'

FUNCTION grupo_fornecedores()

   dbselectarea('grupo_fornecedores')
   ordsetfocus('nome')
   grupo_fornecedores->(dbgotop())

   DEFINE WINDOW form_grupo_fornecedores ;
         at 000,000 ;
         WIDTH 800 ;
         HEIGHT 605 ;
         TITLE 'Grupos Fornecedores' ;
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
         ACTION form_grupo_fornecedores.release
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
         DEFINE GRID grid_grupo_fornecedores
            PARENT form_grupo_fornecedores
            COL 000
            ROW 105
            WIDTH 795
            HEIGHT 430
            HEADERS {'C�digo','Nome'}
            WIDTHS {100,650}
            FONTNAME 'verdana'
            FONTSIZE 010
            FONTBOLD .T.
            BACKCOLOR _amarelo_001
            FONTCOLOR _preto_001
            ONDBLCLICK dados(2)
         END GRID
      END SPLITBOX

      DEFINE LABEL rodape_001
         PARENT form_grupo_fornecedores
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
         of form_grupo_fornecedores ;
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
         PARENT form_grupo_fornecedores
         COL form_grupo_fornecedores.width - 270
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

   form_grupo_fornecedores.center
   form_grupo_fornecedores.activate

   RETURN NIL

STATIC FUNCTION dados(parametro)

   LOCAL id
   LOCAL titulo := ''
   LOCAL x_nome := ''

   IF parametro == 1
      titulo := 'Incluir'
   ELSEIF parametro == 2
      id     := val(valor_coluna('grid_grupo_fornecedores','form_grupo_fornecedores',1))
      titulo := 'Alterar'
      dbselectarea('grupo_fornecedores')
      grupo_fornecedores->(ordsetfocus('codigo'))
      grupo_fornecedores->(dbgotop())
      grupo_fornecedores->(dbseek(id))
      IF found()
         x_nome := grupo_fornecedores->nome
         grupo_fornecedores->(ordsetfocus('nome'))
      ELSE
         msgexclamation('Selecione uma informa��o','Aten��o')
         grupo_fornecedores->(ordsetfocus('nome'))

         RETURN NIL
      ENDIF
   ENDIF

   DEFINE WINDOW form_dados ;
         at 000,000 ;
         WIDTH 325 ;
         HEIGHT 200 ;
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

   LOCAL id := val(valor_coluna('grid_grupo_fornecedores','form_grupo_fornecedores',1))

   dbselectarea('grupo_fornecedores')
   grupo_fornecedores->(ordsetfocus('codigo'))
   grupo_fornecedores->(dbgotop())
   grupo_fornecedores->(dbseek(id))

   IF .not. found()
      msgexclamation('Selecione uma informa��o','Aten��o')
      grupo_fornecedores->(ordsetfocus('nome'))

      RETURN NIL
   ELSE
      IF msgyesno('Nome : '+alltrim(grupo_fornecedores->nome),'Excluir')
         IF lock_reg()
            grupo_fornecedores->(dbdelete())
            grupo_fornecedores->(dbunlock())
            grupo_fornecedores->(dbgotop())
         ENDIF
         grupo_fornecedores->(ordsetfocus('nome'))
         atualizar()
      ENDIF
   ENDIF

   RETURN NIL

STATIC FUNCTION relacao()

   LOCAL p_linha := 040
   LOCAL u_linha := 260
   LOCAL linha   := p_linha
   LOCAL pagina  := 1

   dbselectarea('grupo_fornecedores')
   grupo_fornecedores->(ordsetfocus('nome'))
   grupo_fornecedores->(dbgotop())

   SELECT PRINTER DIALOG PREVIEW

   START PRINTDOC NAME 'Gerenciador de impress�o'
      START PRINTPAGE

         cabecalho(pagina)

         WHILE .not. eof()

            @ linha,030 PRINT strzero(grupo_fornecedores->codigo,4) FONT 'courier new' SIZE 010
            @ linha,045 PRINT grupo_fornecedores->nome FONT 'courier new' SIZE 010

            linha += 5

            IF linha >= u_linha
            END PRINTPAGE
            START PRINTPAGE
               pagina ++
               cabecalho(pagina)
               linha := p_linha
            ENDIF

            grupo_fornecedores->(dbskip())

         END

         rodape()

      END PRINTPAGE
   END PRINTDOC

   RETURN NIL

STATIC FUNCTION cabecalho(p_pagina)

   @ 007,010 PRINT IMAGE path_imagens+'logotipo.bmp' WIDTH 050 HEIGHT 020 STRETCH
   @ 010,070 PRINT 'RELA��O DE GRUPOS FORNECEDORES' FONT 'courier new' SIZE 018 BOLD
   @ 018,070 PRINT 'ordem alfab�tica' FONT 'courier new' SIZE 014
   @ 024,070 PRINT 'p�gina : '+strzero(p_pagina,4) FONT 'courier new' SIZE 012

   @ 030,000 PRINT LINE TO 030,205 PENWIDTH 0.5 COLOR _preto_001

   @ 035,030 PRINT 'C�DIGO' FONT 'courier new' SIZE 010 BOLD
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
      msgalert('Preencha todos os campos','Aten��o')

      RETURN NIL
   ENDIF

   IF parametro == 1
      WHILE .T.
         dbselectarea('conta')
         conta->(dbgotop())
         IF lock_reg()
            codigo := conta->c_gfornec
            REPLACE c_gfornec with c_gfornec + 1
            conta->(dbcommit())
            conta->(dbunlock())
            EXIT
         ELSE
            msgexclamation('Servidor congestionado, tecle ENTER e aguarde','Aten��o')
            LOOP
         ENDIF
      END
      dbselectarea('grupo_fornecedores')
      grupo_fornecedores->(dbappend())
      grupo_fornecedores->codigo := codigo
      grupo_fornecedores->nome   := form_dados.tbox_001.value
      grupo_fornecedores->(dbcommit())
      grupo_fornecedores->(dbgotop())
      form_dados.release
      atualizar()
   ELSEIF parametro == 2
      dbselectarea('grupo_fornecedores')
      IF lock_reg()
         grupo_fornecedores->nome := form_dados.tbox_001.value
         grupo_fornecedores->(dbcommit())
         grupo_fornecedores->(dbunlock())
         grupo_fornecedores->(dbgotop())
      ENDIF
      form_dados.release
      atualizar()
   ENDIF

   RETURN NIL

STATIC FUNCTION pesquisar()

   LOCAL cPesq        := alltrim(form_grupo_fornecedores.tbox_pesquisa.value)
   LOCAL lGridFreeze  := .T.
   LOCAL nTamNomePesq := len(cPesq)

   dbselectarea('grupo_fornecedores')
   grupo_fornecedores->(ordsetfocus('nome'))
   grupo_fornecedores->(dbseek(cPesq))

   IF lGridFreeze
      form_grupo_fornecedores.grid_grupo_fornecedores.disableupdate
   ENDIF

   DELETE item all from grid_grupo_fornecedores of form_grupo_fornecedores

   WHILE .not. eof()
      IF substr(field->nome,1,nTamNomePesq) == cPesq
         add item {str(grupo_fornecedores->codigo),alltrim(grupo_fornecedores->nome)} to grid_grupo_fornecedores of form_grupo_fornecedores
      ELSEIF substr(field->nome,1,nTamNomePesq) > cPesq
         EXIT
      ENDIF
      grupo_fornecedores->(dbskip())
   END

   IF lGridFreeze
      form_grupo_fornecedores.grid_grupo_fornecedores.enableupdate
   ENDIF

   RETURN NIL

STATIC FUNCTION atualizar()

   DELETE item all from grid_grupo_fornecedores of form_grupo_fornecedores

   dbselectarea('grupo_fornecedores')
   grupo_fornecedores->(ordsetfocus('nome'))
   grupo_fornecedores->(dbgotop())

   WHILE .not. eof()
      add item {str(grupo_fornecedores->codigo),alltrim(grupo_fornecedores->nome)} to grid_grupo_fornecedores of form_grupo_fornecedores
      grupo_fornecedores->(dbskip())
   END

   RETURN NIL
