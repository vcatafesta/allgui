/*
sistema     : superchef pizzaria
programa    : movimentação do caixa
compilador  : xharbour 1.2 simplex
lib gráfica : minigui 1.7 extended
programador : marcelo neves
*/

#include 'minigui.ch'
#include 'super.ch'

FUNCTION caixa()

   DEFINE WINDOW form_caixa;
         at 000,000;
         WIDTH 800;
         HEIGHT 605;
         TITLE 'Movimentação do Caixa';
         ICON path_imagens+'icone.ico';
         modal;
         NOSIZE

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
      DEFINE BUTTONEX button_atualizar
         PICTURE path_imagens+'atualizar.bmp'
         COL 311
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
         COL 413
         ROW 002
         WIDTH 100
         HEIGHT 100
         CAPTION 'ESC Voltar'
         ACTION form_caixa.release
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
         DEFINE GRID grid_caixa
            parent form_caixa
            COL 000
            ROW 105
            WIDTH 795
            HEIGHT 430
            HEADERS {'id','Data','Histórico','Entradas','Saídas'}
            WIDTHS {001,120,400,120,120}
            FONTNAME 'verdana'
            FONTSIZE 010
            FONTBOLD .T.
            BACKCOLOR _amarelo_001
            FONTCOLOR _preto_001
            ondblclick dados(2)
         END GRID
      END SPLITBOX

      DEFINE LABEL rodape_001
         parent form_caixa
         COL 005
         ROW 545
         VALUE 'Escolha o período'
         AUTOSIZE .T.
         FONTNAME 'verdana'
         FONTSIZE 010
         FONTBOLD .T.
         FONTCOLOR _cinza_001
         TRANSPARENT .T.
      END LABEL
      DEFINE LABEL rodape_002
         parent form_caixa
         COL 250
         ROW 545
         VALUE 'até'
         AUTOSIZE .T.
         FONTNAME 'verdana'
         FONTSIZE 010
         FONTBOLD .T.
         FONTCOLOR _cinza_001
         TRANSPARENT .T.
      END LABEL
      @ 540,140 datepicker dp_inicio;
         parent form_caixa;
         VALUE date();
         WIDTH 100;
         font 'verdana' size 010
      @ 540,280 datepicker dp_final;
         parent form_caixa;
         VALUE date();
         WIDTH 100;
         font 'verdana' size 010
      @ 540,390 buttonex botao_filtrar;
         parent form_caixa;
         CAPTION 'Filtrar';
         WIDTH 100 height 030;
         ACTION atualizar();
         bold;
         TOOLTIP 'Clique aqui para mostrar as informações com base no período selecionado'

      DEFINE LABEL rodape_003
         parent form_caixa
         COL form_caixa.width - 270
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
      ON KEY ESCAPE ACTION thiswindow.release

   END WINDOW

   form_caixa.center
   form_caixa.activate

   RETURN NIL

STATIC FUNCTION dados(parametro)

   LOCAL id
   LOCAL titulo      := ''
   LOCAL x_data      := date()
   LOCAL x_historico := ''
   LOCAL x_entrada   := 0
   LOCAL x_saida     := 0

   IF parametro == 1
      titulo := 'Incluir'
   ELSEIF parametro == 2
      id     := valor_coluna('grid_caixa','form_caixa',1)
      titulo := 'Alterar'
      dbselectarea('caixa')
      caixa->(ordsetfocus('id'))
      caixa->(dbgotop())
      caixa->(dbseek(id))
      IF found()
         x_data      := caixa->data
         x_historico := caixa->historico
         x_entrada   := caixa->entrada
         x_saida     := caixa->saida
         caixa->(ordsetfocus('nome'))
      ELSE
         msgexclamation('Selecione uma informação','Atenção')
         caixa->(ordsetfocus('data'))

         RETURN NIL
      ENDIF
   ENDIF

   DEFINE WINDOW form_dados;
         at 000,000;
         WIDTH 325;
         HEIGHT 270;
         TITLE (titulo);
         ICON path_imagens+'icone.ico';
         modal;
         NOSIZE

      * entrada de dados
      @ 010,005 label lbl_001;
         of form_dados;
         VALUE 'Data';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 030,005 textbox tbox_001;
         of form_dados;
         HEIGHT 027;
         WIDTH 120;
         VALUE x_data;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         date
      @ 060,005 label lbl_002;
         of form_dados;
         VALUE 'Histórico';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 080,005 textbox tbox_002;
         of form_dados;
         HEIGHT 027;
         WIDTH 310;
         VALUE x_historico;
         MAXLENGTH 030;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         uppercase
      @ 110,005 label lbl_003;
         of form_dados;
         VALUE 'Entrada';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR BLUE;
         TRANSPARENT
      @ 130,005 getbox tbox_003;
         of form_dados;
         HEIGHT 027;
         WIDTH 120;
         VALUE x_entrada;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         PICTURE '@E 999,999.99'
      @ 110,140 label lbl_004;
         of form_dados;
         VALUE 'Saída';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _vermelho_002;
         TRANSPARENT
      @ 130,140 getbox tbox_004;
         of form_dados;
         HEIGHT 027;
         WIDTH 120;
         VALUE x_saida;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         PICTURE '@E 999,999.99'

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

   LOCAL id := valor_coluna('grid_caixa','form_caixa',1)

   dbselectarea('caixa')
   caixa->(ordsetfocus('id'))
   caixa->(dbgotop())
   caixa->(dbseek(id))

   IF .not. found()
      msgexclamation('Selecione uma informação','Atenção')
      caixa->(ordsetfocus('data'))

      RETURN NIL
   ELSE
      IF msgyesno('Histórico : '+alltrim(caixa->historico),'Excluir')
         IF lock_reg()
            caixa->(dbdelete())
            caixa->(dbunlock())
            caixa->(dbgotop())
         ENDIF
         caixa->(ordsetfocus('data'))
         atualizar()
      ENDIF
   ENDIF

   RETURN NIL

STATIC FUNCTION gravar(parametro)

   LOCAL x_id := substr(alltrim(str(HB_RANDOM(0001240003,9999999999))),1,10)

   IF empty(form_dados.tbox_001.value)
      msginfo('Preencha a data','Atenção')

      RETURN NIL
   ENDIF

   IF empty(form_dados.tbox_002.value)
      msginfo('Preencha o histórico','Atenção')

      RETURN NIL
   ENDIF

   IF parametro == 1
      WHILE .T.
         dbselectarea('caixa')
         caixa->(ordsetfocus('id'))
         caixa->(dbgotop())
         caixa->(dbseek(x_id))
         IF found()
            x_id := substr(alltrim(str(HB_RANDOM(0001240003,9999999999))),1,10)
            LOOP
         ELSE
            EXIT
         ENDIF
      END
      dbselectarea('caixa')
      caixa->(dbappend())
      caixa->id        := x_id
      caixa->data      := form_dados.tbox_001.value
      caixa->historico := form_dados.tbox_002.value
      caixa->entrada   := form_dados.tbox_003.value
      caixa->saida     := form_dados.tbox_004.value
      caixa->(dbcommit())
      caixa->(dbgotop())
      form_dados.release
      atualizar()
   ELSEIF parametro == 2
      dbselectarea('caixa')
      IF lock_reg()
         caixa->data      := form_dados.tbox_001.value
         caixa->historico := form_dados.tbox_002.value
         caixa->entrada   := form_dados.tbox_003.value
         caixa->saida     := form_dados.tbox_004.value
         caixa->(dbcommit())
         caixa->(dbunlock())
         caixa->(dbgotop())
      ENDIF
      form_dados.release
      atualizar()
   ENDIF

   RETURN NIL

STATIC FUNCTION atualizar()

   LOCAL x_data_001 := form_caixa.dp_inicio.value
   LOCAL x_data_002 := form_caixa.dp_final.value

   DELETE item all from grid_caixa of form_caixa

   dbselectarea('caixa')
   caixa->(ordsetfocus('data'))
   caixa->(dbgotop())

   ordscope(0,dtos(x_data_001))
   ordscope(1,dtos(x_data_002))

   caixa->(dbgotop())

   WHILE .not. eof()
      add item {caixa->id,dtoc(caixa->data),alltrim(caixa->historico),trans(caixa->entrada,'@E 999,999.99'),trans(caixa->saida,'@E 999,999.99')} to grid_caixa of form_caixa
      caixa->(dbskip())
   END

   RETURN NIL
