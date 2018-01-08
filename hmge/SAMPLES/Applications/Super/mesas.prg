/*
sistema     : superchef pizzaria
programa    : mesas da pizzaria
compilador  : xharbour 1.2 simplex
lib gr�fica : minigui 1.7 extended
programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'super.ch'

FUNCTION mesas()

   dbselectarea('mesas')
   ordsetfocus('nome')
   mesas->(dbgotop())

   DEFINE WINDOW form_mesas;
         at 000,000;
         WIDTH 800;
         HEIGHT 605;
         TITLE 'Mesas da Pizzaria';
         ICON path_imagens+'icone.ico';
         modal;
         nosize;
         on init pesquisar()

      * bot�es (toolbar)
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
         action form_mesas.release
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
         DEFINE GRID grid_mesas
            parent form_mesas
            COL 000
            ROW 105
            WIDTH 795
            HEIGHT 430
            headers {'C�digo','Nome'}
            widths {100,650}
            fontname 'verdana'
            fontsize 010
            fontbold .T.
            BACKCOLOR _amarelo_001
            fontcolor _preto_001
            ondblclick dados(2)
         END GRID
      END SPLITBOX

      DEFINE LABEL rodape_001
         parent form_mesas
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
         of form_mesas;
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
         parent form_mesas
         COL form_mesas.width - 270
         ROW 545
         value 'DUPLO CLIQUE : Alterar informa��o'
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

   form_mesas.center
   form_mesas.activate

   RETURN NIL

STATIC FUNCTION dados(parametro)

   LOCAL id
   LOCAL titulo := ''
   LOCAL x_nome := ''

   IF parametro == 1
      titulo := 'Incluir'
   ELSEIF parametro == 2
      id     := val(valor_coluna('grid_mesas','form_mesas',1))
      titulo := 'Alterar'
      dbselectarea('mesas')
      mesas->(ordsetfocus('codigo'))
      mesas->(dbgotop())
      mesas->(dbseek(id))
      IF found()
         x_nome := mesas->nome
         mesas->(ordsetfocus('nome'))
      ELSE
         msgexclamation('Selecione uma informa��o','Aten��o')
         mesas->(ordsetfocus('nome'))

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

      * bot�es
      DEFINE BUTTONEX button_ok
         PICTURE path_imagens+'img_gravar.bmp'
         COL form_dados.width-225
         ROW form_dados.height-085
         WIDTH 120
         HEIGHT 050
         caption 'Ok, gravar'
         action gravar(parametro)
         fontbold .T.
         tooltip 'Confirmar as informa��es digitadas'
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
         tooltip 'Sair desta tela sem gravar informa��es'
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

   LOCAL id := val(valor_coluna('grid_mesas','form_mesas',1))

   dbselectarea('mesas')
   mesas->(ordsetfocus('codigo'))
   mesas->(dbgotop())
   mesas->(dbseek(id))

   IF .not. found()
      msgexclamation('Selecione uma informa��o','Aten��o')
      mesas->(ordsetfocus('nome'))

      RETURN NIL
   ELSE
      IF msgyesno('Nome : '+alltrim(mesas->nome),'Excluir')
         IF lock_reg()
            mesas->(dbdelete())
            mesas->(dbunlock())
            mesas->(dbgotop())
         ENDIF
         mesas->(ordsetfocus('nome'))
         atualizar()
      ENDIF
   ENDIF

   RETURN NIL

STATIC FUNCTION relacao()

   LOCAL p_linha := 040
   LOCAL u_linha := 260
   LOCAL linha   := p_linha
   LOCAL pagina  := 1

   dbselectarea('mesas')
   mesas->(ordsetfocus('nome'))
   mesas->(dbgotop())

   SELECT PRINTER DIALOG PREVIEW

   START PRINTDOC NAME 'Gerenciador de impress�o'
      START PRINTPAGE

         cabecalho(pagina)

         WHILE .not. eof()

            @ linha,030 PRINT strzero(mesas->codigo,4) FONT 'courier new' SIZE 010
            @ linha,045 PRINT mesas->nome FONT 'courier new' SIZE 010

            linha += 5

            IF linha >= u_linha
            END PRINTPAGE
            START PRINTPAGE
               pagina ++
               cabecalho(pagina)
               linha := p_linha
            ENDIF

            mesas->(dbskip())

         END

         rodape()

      END PRINTPAGE
   END PRINTDOC

   RETURN NIL

STATIC FUNCTION cabecalho(p_pagina)

   @ 007,010 PRINT IMAGE path_imagens+'logotipo.bmp' WIDTH 050 HEIGHT 020 STRETCH
   @ 010,070 PRINT 'RELA��O DE MESAS' FONT 'courier new' SIZE 018 BOLD
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
            codigo := conta->c_mesas
            REPLACE c_mesas with c_mesas + 1
            conta->(dbcommit())
            conta->(dbunlock())
            EXIT
         ELSE
            msgexclamation('Servidor congestionado, tecle ENTER e aguarde','Aten��o')
            LOOP
         ENDIF
      END
      dbselectarea('mesas')
      mesas->(dbappend())
      mesas->codigo := codigo
      mesas->nome   := form_dados.tbox_001.value
      mesas->(dbcommit())
      mesas->(dbgotop())
      form_dados.release
      atualizar()
   ELSEIF parametro == 2
      dbselectarea('mesas')
      IF lock_reg()
         mesas->nome := form_dados.tbox_001.value
         mesas->(dbcommit())
         mesas->(dbunlock())
         mesas->(dbgotop())
      ENDIF
      form_dados.release
      atualizar()
   ENDIF

   RETURN NIL

STATIC FUNCTION pesquisar()

   LOCAL cPesq        := alltrim(form_mesas.tbox_pesquisa.value)
   LOCAL lGridFreeze  := .T.
   LOCAL nTamNomePesq := len(cPesq)

   dbselectarea('mesas')
   mesas->(ordsetfocus('nome'))
   mesas->(dbseek(cPesq))

   IF lGridFreeze
      form_mesas.grid_mesas.disableupdate
   ENDIF

   DELETE item all from grid_mesas of form_mesas

   WHILE .not. eof()
      IF substr(field->nome,1,nTamNomePesq) == cPesq
         add item {str(mesas->codigo),alltrim(mesas->nome)} to grid_mesas of form_mesas
      ELSEIF substr(field->nome,1,nTamNomePesq) > cPesq
         EXIT
      ENDIF
      mesas->(dbskip())
   END

   IF lGridFreeze
      form_mesas.grid_mesas.enableupdate
   ENDIF

   RETURN NIL

STATIC FUNCTION atualizar()

   DELETE item all from grid_mesas of form_mesas

   dbselectarea('mesas')
   mesas->(ordsetfocus('nome'))
   mesas->(dbgotop())

   WHILE .not. eof()
      add item {str(mesas->codigo),alltrim(mesas->nome)} to grid_mesas of form_mesas
      mesas->(dbskip())
   END

   RETURN NIL
