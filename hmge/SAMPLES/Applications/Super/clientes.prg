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

   DEFINE WINDOW form_clientes;
         at 000,000;
         width 800;
         height 605;
         title 'Clientes';
         icon path_imagens+'icone.ico';
         modal;
         nosize;
         on init pesquisar()

      * bot�es (toolbar)
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
         action form_clientes.release
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
         DEFINE GRID grid_clientes
            parent form_clientes
            col 000
            row 105
            width 795
            height 430
            headers {'C�digo','Nome','Telefone fixo','Telefone celular'}
            widths {080,400,140,140}
            fontname 'verdana'
            fontsize 010
            fontbold .T.
            backcolor _amarelo_001
            fontcolor _preto_001
            ondblclick dados(2)
         END GRID
      END SPLITBOX

      DEFINE LABEL rodape_001
         parent form_clientes
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
         of form_clientes;
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
         parent form_clientes
         col form_clientes.width - 270
         row 545
         value 'DUPLO CLIQUE : Alterar informa��o'
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

   form_clientes.center
   form_clientes.activate

   return(nil)

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

         return(nil)
      ENDIF
   ENDIF

   DEFINE WINDOW form_dados;
         at 000,000;
         width 585;
         height 380;
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
         maxlength 040;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         uppercase
      @ 010,325 label lbl_002;
         of form_dados;
         value 'Telefone fixo';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 030,325 textbox tbox_002;
         of form_dados;
         height 027;
         width 120;
         value x_fixo;
         maxlength 010;
         font 'verdana' size 012;
         bold;
         backcolor BLUE;
         fontcolor WHITE;
         uppercase
      @ 010,455 label lbl_003;
         of form_dados;
         value 'Telefone celular';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 030,455 textbox tbox_003;
         of form_dados;
         height 027;
         width 120;
         value x_celular;
         maxlength 010;
         font 'verdana' size 012;
         bold;
         backcolor BLUE;
         fontcolor WHITE;
         uppercase
      @ 060,005 label lbl_004;
         of form_dados;
         value 'Endere�o';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 080,005 textbox tbox_004;
         of form_dados;
         height 027;
         width 310;
         value x_endereco;
         maxlength 040;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         uppercase
      @ 060,325 label lbl_005;
         of form_dados;
         value 'N�mero';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 080,325 textbox tbox_005;
         of form_dados;
         height 027;
         width 060;
         value x_numero;
         maxlength 006;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         uppercase
      @ 060,395 label lbl_006;
         of form_dados;
         value 'Complemento';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 080,395 textbox tbox_006;
         of form_dados;
         height 027;
         width 180;
         value x_complem;
         maxlength 020;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         uppercase
      @ 110,005 label lbl_007;
         of form_dados;
         value 'Bairro';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 130,005 textbox tbox_007;
         of form_dados;
         height 027;
         width 180;
         value x_bairro;
         maxlength 020;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         uppercase
      @ 110,195 label lbl_008;
         of form_dados;
         value 'Cidade';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 130,195 textbox tbox_008;
         of form_dados;
         height 027;
         width 180;
         value x_cidade;
         maxlength 020;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         uppercase
      @ 110,385 label lbl_009;
         of form_dados;
         value 'UF';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 130,385 textbox tbox_009;
         of form_dados;
         height 027;
         width 040;
         value x_uf;
         maxlength 002;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         uppercase
      @ 110,435 label lbl_010;
         of form_dados;
         value 'CEP';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 130,435 textbox tbox_010;
         of form_dados;
         height 027;
         width 080;
         value x_cep;
         maxlength 008;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         uppercase
      @ 160,005 label lbl_011;
         of form_dados;
         value 'e-mail';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 180,005 textbox tbox_011;
         of form_dados;
         height 027;
         width 450;
         value x_email;
         maxlength 050;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         lowercase
      @ 210,005 label lbl_012;
         of form_dados;
         value 'Dia anivers�rio';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 230,005 textbox tbox_012;
         of form_dados;
         height 027;
         width 080;
         value x_aniv_dia;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         numeric
      @ 210,120 label lbl_013;
         of form_dados;
         value 'M�s anivers�rio';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 230,120 textbox tbox_013;
         of form_dados;
         height 027;
         width 080;
         value x_aniv_mes;
         font 'tahoma' size 010;
         backcolor _fundo_get;
         fontcolor _letra_get_1;
         numeric

      * texto de observa��o
      @ 265,005 label lbl_observacao;
         of form_dados;
         value '* os campos na cor azul, telefones fixo e celular, ser�o utilizados no DELIVERY';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor BLUE;
         transparent

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

      * bot�es
      DEFINE BUTTONEX button_ok
         picture path_imagens+'img_gravar.bmp'
         col form_dados.width-225
         row form_dados.height-085
         width 120
         height 050
         caption 'Ok, gravar'
         action gravar(parametro)
         fontbold .T.
         tooltip 'Confirmar as informa��es digitadas'
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
         tooltip 'Sair desta tela sem gravar informa��es'
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

   LOCAL id := val(valor_coluna('grid_clientes','form_clientes',1))

   dbselectarea('clientes')
   clientes->(ordsetfocus('codigo'))
   clientes->(dbgotop())
   clientes->(dbseek(id))

   IF .not. found()
      msgexclamation('Selecione uma informa��o','Aten��o')
      clientes->(ordsetfocus('nome'))

      return(nil)
   ELSE
      IF clientes->codigo == 999999
         msgstop('Este cliente n�o pode ser exclu�do por ser padr�o do programa','Aten��o')

         return(nil)
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

   return(nil)

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

         end

         rodape()

      END PRINTPAGE
   END PRINTDOC

   return(nil)

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
      msgalert('Preencha todos os campos','Aten��o')

      return(nil)
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
      end
      dbselectarea('clientes')
      IF l_demo
         IF reccount() > _limite_registros
            msgstop('Limite de registros esgotado','Aten��o')

            return(nil)
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

   return(nil)

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
   end

   IF lGridFreeze
      form_clientes.grid_clientes.enableupdate
   ENDIF

   return(nil)

STATIC FUNCTION atualizar()

   DELETE item all from grid_clientes of form_clientes

   dbselectarea('clientes')
   clientes->(ordsetfocus('nome'))
   clientes->(dbgotop())

   WHILE .not. eof()
      add item {str(clientes->codigo),alltrim(clientes->nome),alltrim(clientes->fixo),alltrim(clientes->celular)} to grid_clientes of form_clientes
      clientes->(dbskip())
   end

   return(nil)
