/*
sistema     : superchef pizzaria
programa    : motoboys/entregadores
compilador  : xharbour 1.2 simplex
lib gráfica : minigui 1.7 extended
programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'super.ch'

FUNCTION motoboys_entregadores()

   dbselectarea('motoboys')
   ordsetfocus('nome')
   motoboys->(dbgotop())

   DEFINE WINDOW form_motoboys;
         at 000,000;
         WIDTH 800;
         HEIGHT 605;
         TITLE 'Motoboys ou Entregadores';
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
         ACTION form_motoboys.release
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
         DEFINE GRID grid_motoboys
            parent form_motoboys
            COL 000
            ROW 105
            WIDTH 795
            HEIGHT 430
            HEADERS {'Código','Nome','Telefone fixo','Telefone celular'}
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
         parent form_motoboys
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
         of form_motoboys;
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
         parent form_motoboys
         COL form_motoboys.width - 270
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

   form_motoboys.center
   form_motoboys.activate

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
   LOCAL x_diaria   := 0

   IF parametro == 1
      titulo := 'Incluir'
   ELSEIF parametro == 2
      id     := val(valor_coluna('grid_motoboys','form_motoboys',1))
      titulo := 'Alterar'
      dbselectarea('motoboys')
      motoboys->(ordsetfocus('codigo'))
      motoboys->(dbgotop())
      motoboys->(dbseek(id))
      IF found()
         x_nome     := motoboys->nome
         x_fixo     := motoboys->fixo
         x_celular  := motoboys->celular
         x_endereco := motoboys->endereco
         x_numero   := motoboys->numero
         x_complem  := motoboys->complem
         x_bairro   := motoboys->bairro
         x_cidade   := motoboys->cidade
         x_uf       := motoboys->uf
         x_cep      := motoboys->cep
         x_email    := motoboys->email
         x_diaria   := motoboys->diaria
         motoboys->(ordsetfocus('nome'))
      ELSE
         msgexclamation('Selecione uma informação','Atenção')
         motoboys->(ordsetfocus('nome'))

         RETURN NIL
      ENDIF
   ENDIF

   DEFINE WINDOW form_dados;
         at 000,000;
         WIDTH 585;
         HEIGHT 360;
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
         MAXLENGTH 040;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         uppercase
      @ 010,325 label lbl_002;
         of form_dados;
         VALUE 'Telefone fixo';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 030,325 textbox tbox_002;
         of form_dados;
         HEIGHT 027;
         WIDTH 120;
         VALUE x_fixo;
         MAXLENGTH 010;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         uppercase
      @ 010,455 label lbl_003;
         of form_dados;
         VALUE 'Telefone celular';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 030,455 textbox tbox_003;
         of form_dados;
         HEIGHT 027;
         WIDTH 120;
         VALUE x_celular;
         MAXLENGTH 010;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         uppercase
      @ 060,005 label lbl_004;
         of form_dados;
         VALUE 'Endereço';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 080,005 textbox tbox_004;
         of form_dados;
         HEIGHT 027;
         WIDTH 310;
         VALUE x_endereco;
         MAXLENGTH 040;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         uppercase
      @ 060,325 label lbl_005;
         of form_dados;
         VALUE 'Número';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 080,325 textbox tbox_005;
         of form_dados;
         HEIGHT 027;
         WIDTH 060;
         VALUE x_numero;
         MAXLENGTH 006;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         uppercase
      @ 060,395 label lbl_006;
         of form_dados;
         VALUE 'Complemento';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 080,395 textbox tbox_006;
         of form_dados;
         HEIGHT 027;
         WIDTH 180;
         VALUE x_complem;
         MAXLENGTH 020;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         uppercase
      @ 110,005 label lbl_007;
         of form_dados;
         VALUE 'Bairro';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 130,005 textbox tbox_007;
         of form_dados;
         HEIGHT 027;
         WIDTH 180;
         VALUE x_bairro;
         MAXLENGTH 020;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         uppercase
      @ 110,195 label lbl_008;
         of form_dados;
         VALUE 'Cidade';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 130,195 textbox tbox_008;
         of form_dados;
         HEIGHT 027;
         WIDTH 180;
         VALUE x_cidade;
         MAXLENGTH 020;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         uppercase
      @ 110,385 label lbl_009;
         of form_dados;
         VALUE 'UF';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 130,385 textbox tbox_009;
         of form_dados;
         HEIGHT 027;
         WIDTH 040;
         VALUE x_uf;
         MAXLENGTH 002;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         uppercase
      @ 110,435 label lbl_010;
         of form_dados;
         VALUE 'CEP';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 130,435 textbox tbox_010;
         of form_dados;
         HEIGHT 027;
         WIDTH 080;
         VALUE x_cep;
         MAXLENGTH 008;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         uppercase
      @ 160,005 label lbl_011;
         of form_dados;
         VALUE 'e-mail';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 180,005 textbox tbox_011;
         of form_dados;
         HEIGHT 027;
         WIDTH 450;
         VALUE x_email;
         MAXLENGTH 050;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         lowercase
      @ 210,005 label lbl_013;
         of form_dados;
         VALUE 'Diária (R$)';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 230,005 getbox tbox_013;
         of form_dados;
         HEIGHT 027;
         WIDTH 140;
         VALUE x_diaria;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         PICTURE '@E 9,999.99'

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

   LOCAL id := val(valor_coluna('grid_motoboys','form_motoboys',1))

   dbselectarea('motoboys')
   motoboys->(ordsetfocus('codigo'))
   motoboys->(dbgotop())
   motoboys->(dbseek(id))

   IF .not. found()
      msgexclamation('Selecione uma informação','Atenção')
      motoboys->(ordsetfocus('nome'))

      RETURN NIL
   ELSE
      IF msgyesno('Nome : '+alltrim(motoboys->nome),'Excluir')
         IF lock_reg()
            motoboys->(dbdelete())
            motoboys->(dbunlock())
            motoboys->(dbgotop())
         ENDIF
         motoboys->(ordsetfocus('nome'))
         atualizar()
      ENDIF
   ENDIF

   RETURN NIL

STATIC FUNCTION relacao()

   LOCAL p_linha := 040
   LOCAL u_linha := 260
   LOCAL linha   := p_linha
   LOCAL pagina  := 1

   dbselectarea('motoboys')
   motoboys->(ordsetfocus('nome'))
   motoboys->(dbgotop())

   SELECT PRINTER DIALOG PREVIEW

   START PRINTDOC NAME 'Gerenciador de impressão'
      START PRINTPAGE

         cabecalho(pagina)

         WHILE .not. eof()

            @ linha,010 PRINT strzero(motoboys->codigo,4) FONT 'courier new' SIZE 010
            @ linha,025 PRINT motoboys->nome FONT 'courier new' SIZE 010
            @ linha,100 PRINT motoboys->fixo FONT 'courier new' SIZE 010
            @ linha,130 PRINT motoboys->celular FONT 'courier new' SIZE 010
            @ linha,160 PRINT trans(motoboys->diaria,'@E 9,999.99') FONT 'courier new' SIZE 010

            linha += 5

            IF linha >= u_linha
            END PRINTPAGE
            START PRINTPAGE
               pagina ++
               cabecalho(pagina)
               linha := p_linha
            ENDIF

            motoboys->(dbskip())

         END

         rodape()

      END PRINTPAGE
   END PRINTDOC

   RETURN NIL

STATIC FUNCTION cabecalho(p_pagina)

   @ 007,010 PRINT IMAGE path_imagens+'logotipo.bmp' WIDTH 050 HEIGHT 020 STRETCH
   @ 010,070 PRINT 'RELAÇÃO DE MOTOBOYS ou ENTREGADORES' FONT 'courier new' SIZE 018 BOLD
   @ 018,070 PRINT 'ordem alfabética' FONT 'courier new' SIZE 014
   @ 024,070 PRINT 'página : '+strzero(p_pagina,4) FONT 'courier new' SIZE 012

   @ 030,000 PRINT LINE TO 030,205 PENWIDTH 0.5 COLOR _preto_001

   @ 035,010 PRINT 'CÓDIGO' FONT 'courier new' SIZE 010 BOLD
   @ 035,025 PRINT 'NOME' FONT 'courier new' SIZE 010 BOLD
   @ 035,100 PRINT 'TEL.FIXO' FONT 'courier new' SIZE 010 BOLD
   @ 035,130 PRINT 'TEL.CELULAR' FONT 'courier new' SIZE 010 BOLD
   @ 035,160 PRINT 'DIÁRIA(R$)' FONT 'courier new' SIZE 010 BOLD

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

   IF retorna
      msgalert('Preencha todos os campos','Atenção')

      RETURN NIL
   ENDIF

   IF parametro == 1
      WHILE .T.
         dbselectarea('conta')
         conta->(dbgotop())
         IF lock_reg()
            codigo := conta->c_motent
            REPLACE c_motent with c_motent + 1
            conta->(dbcommit())
            conta->(dbunlock())
            EXIT
         ELSE
            msgexclamation('Servidor congestionado, tecle ENTER e aguarde','Atenção')
            LOOP
         ENDIF
      END
      dbselectarea('motoboys')
      motoboys->(dbappend())
      motoboys->codigo   := codigo
      motoboys->nome     := form_dados.tbox_001.value
      motoboys->fixo     := form_dados.tbox_002.value
      motoboys->celular  := form_dados.tbox_003.value
      motoboys->endereco := form_dados.tbox_004.value
      motoboys->numero   := form_dados.tbox_005.value
      motoboys->complem  := form_dados.tbox_006.value
      motoboys->bairro   := form_dados.tbox_007.value
      motoboys->cidade   := form_dados.tbox_008.value
      motoboys->uf       := form_dados.tbox_009.value
      motoboys->cep      := form_dados.tbox_010.value
      motoboys->email    := form_dados.tbox_011.value
      motoboys->diaria   := form_dados.tbox_013.value
      motoboys->(dbcommit())
      motoboys->(dbgotop())
      form_dados.release
      atualizar()
   ELSEIF parametro == 2
      dbselectarea('motoboys')
      IF lock_reg()
         motoboys->nome     := form_dados.tbox_001.value
         motoboys->fixo     := form_dados.tbox_002.value
         motoboys->celular  := form_dados.tbox_003.value
         motoboys->endereco := form_dados.tbox_004.value
         motoboys->numero   := form_dados.tbox_005.value
         motoboys->complem  := form_dados.tbox_006.value
         motoboys->bairro   := form_dados.tbox_007.value
         motoboys->cidade   := form_dados.tbox_008.value
         motoboys->uf       := form_dados.tbox_009.value
         motoboys->cep      := form_dados.tbox_010.value
         motoboys->email    := form_dados.tbox_011.value
         motoboys->diaria   := form_dados.tbox_013.value
         motoboys->(dbcommit())
         motoboys->(dbunlock())
         motoboys->(dbgotop())
      ENDIF
      form_dados.release
      atualizar()
   ENDIF

   RETURN NIL

STATIC FUNCTION pesquisar()

   LOCAL cPesq        := alltrim(form_motoboys.tbox_pesquisa.value)
   LOCAL lGridFreeze  := .T.
   LOCAL nTamNomePesq := len(cPesq)

   dbselectarea('motoboys')
   motoboys->(ordsetfocus('nome'))
   motoboys->(dbseek(cPesq))

   IF lGridFreeze
      form_motoboys.grid_motoboys.disableupdate
   ENDIF

   DELETE item all from grid_motoboys of form_motoboys

   WHILE .not. eof()
      IF substr(field->nome,1,nTamNomePesq) == cPesq
         add item {str(motoboys->codigo),alltrim(motoboys->nome),alltrim(motoboys->fixo),alltrim(motoboys->celular)} to grid_motoboys of form_motoboys
      ELSEIF substr(field->nome,1,nTamNomePesq) > cPesq
         EXIT
      ENDIF
      motoboys->(dbskip())
   END

   IF lGridFreeze
      form_motoboys.grid_motoboys.enableupdate
   ENDIF

   RETURN NIL

STATIC FUNCTION atualizar()

   DELETE item all from grid_motoboys of form_motoboys

   dbselectarea('motoboys')
   motoboys->(ordsetfocus('nome'))
   motoboys->(dbgotop())

   WHILE .not. eof()
      add item {str(motoboys->codigo),alltrim(motoboys->nome),alltrim(motoboys->fixo),alltrim(motoboys->celular)} to grid_motoboys of form_motoboys
      motoboys->(dbskip())
   END

   RETURN NIL
