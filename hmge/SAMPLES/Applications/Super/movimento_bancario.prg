/*
sistema     : superchef pizzaria
programa    : movimentação bancária
compilador  : xharbour 1.2 simplex
lib gráfica : minigui 1.7 extended
programador : marcelo neves
*/

#include 'minigui.ch'
#include 'super.ch'

FUNCTION movimento_bancario()

   LOCAL a_001 := {}

   dbselectarea('bancos')
   bancos->(ordsetfocus('nome'))
   bancos->(dbgotop())
   WHILE .not. eof()
      aadd(a_001,strzero(bancos->codigo,6)+' - '+bancos->nome)
      bancos->(dbskip())
   END

   DEFINE WINDOW form_movban;
         at 000,000;
         WIDTH 800;
         HEIGHT 605;
         TITLE 'Movimentação Bancária';
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
         ACTION form_movban.release
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
         DEFINE GRID grid_movban
            parent form_movban
            COL 000
            ROW 105
            WIDTH 795
            HEIGHT 380
            HEADERS {'id','Data','Histórico','Entradas','Saídas'}
            WIDTHS {001,120,400,120,120}
            FONTNAME 'verdana'
            FONTSIZE 010
            FONTBOLD .T.
            BACKCOLOR _amarelo_001
            FONTCOLOR _preto_001
            ONDBLCLICK dados(2)
         END GRID
      END SPLITBOX

      DEFINE LABEL rodape_000
         parent form_movban
         COL 005
         ROW 500
         VALUE 'Escolha o banco'
         AUTOSIZE .T.
         FONTNAME 'verdana'
         FONTSIZE 010
         FONTBOLD .T.
         FONTCOLOR _cinza_001
         TRANSPARENT .T.
      END LABEL
      define comboboxex cbo_001
      ROW   500
      COL   140
      WIDTH 300
      HEIGHT 200
      ITEMS a_001
      VALUE 1
   END comboboxex

   DEFINE LABEL rodape_001
      parent form_movban
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
      parent form_movban
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
      parent form_movban;
      VALUE date();
      WIDTH 100;
      font 'verdana' size 010
   @ 540,280 datepicker dp_final;
      parent form_movban;
      VALUE date();
      WIDTH 100;
      font 'verdana' size 010
   @ 540,390 buttonex botao_filtrar;
      parent form_movban;
      CAPTION 'Filtrar';
      WIDTH 100 height 030;
      ACTION atualizar();
      bold;
      TOOLTIP 'Clique aqui para mostrar as informações com base no período selecionado'

   DEFINE LABEL rodape_003
      parent form_movban
      COL form_movban.width - 270
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

form_movban.center
form_movban.activate

RETURN NIL

STATIC FUNCTION dados(parametro)

   LOCAL id
   LOCAL titulo      := ''
   LOCAL x_banco     := 0
   LOCAL x_data      := date()
   LOCAL x_historico := ''
   LOCAL x_entrada   := 0
   LOCAL x_saida     := 0

   IF parametro == 1
      titulo := 'Incluir'
   ELSEIF parametro == 2
      id     := valor_coluna('grid_movban','form_movban',1)
      titulo := 'Alterar'
      dbselectarea('movimento_bancario')
      movimento_bancario->(ordsetfocus('id'))
      movimento_bancario->(dbgotop())
      movimento_bancario->(dbseek(id))
      IF found()
         x_banco     := movimento_bancario->banco
         x_data      := movimento_bancario->data
         x_historico := movimento_bancario->historico
         x_entrada   := movimento_bancario->entrada
         x_saida     := movimento_bancario->saida
         movimento_bancario->(ordsetfocus('nome'))
      ELSE
         msgexclamation('Selecione uma informação','Atenção')
         movimento_bancario->(ordsetfocus('data'))

         RETURN NIL
      ENDIF
   ENDIF

   DEFINE WINDOW form_dados;
         at 000,000;
         WIDTH 325;
         HEIGHT 320;
         TITLE (titulo);
         ICON path_imagens+'icone.ico';
         modal;
         NOSIZE

      * entrada de dados
      @ 010,005 label lbl_000;
         of form_dados;
         VALUE 'Banco';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 030,005 textbox tbox_000;
         of form_dados;
         HEIGHT 027;
         WIDTH 060;
         VALUE x_banco;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         numeric;
         ON ENTER procura_banco_2('form_dados','tbox_000')
      @ 030,070 label lbl_nome_banco;
         of form_dados;
         VALUE '';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _azul_001;
         TRANSPARENT
      @ 060,005 label lbl_001;
         of form_dados;
         VALUE 'Data';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 080,005 textbox tbox_001;
         of form_dados;
         HEIGHT 027;
         WIDTH 120;
         VALUE x_data;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         date
      @ 110,005 label lbl_002;
         of form_dados;
         VALUE 'Histórico';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 130,005 textbox tbox_002;
         of form_dados;
         HEIGHT 027;
         WIDTH 310;
         VALUE x_historico;
         MAXLENGTH 030;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         uppercase
      @ 160,005 label lbl_003;
         of form_dados;
         VALUE 'Entrada';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR BLUE;
         TRANSPARENT
      @ 180,005 getbox tbox_003;
         of form_dados;
         HEIGHT 027;
         WIDTH 120;
         VALUE x_entrada;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         PICTURE '@E 999,999.99'
      @ 160,140 label lbl_004;
         of form_dados;
         VALUE 'Saída';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _vermelho_002;
         TRANSPARENT
      @ 180,140 getbox tbox_004;
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

   LOCAL id := valor_coluna('grid_movban','form_movban',1)

   dbselectarea('movimento_bancario')
   movimento_bancario->(ordsetfocus('id'))
   movimento_bancario->(dbgotop())
   movimento_bancario->(dbseek(id))

   IF .not. found()
      msgexclamation('Selecione uma informação','Atenção')
      movimento_bancario->(ordsetfocus('data'))

      RETURN NIL
   ELSE
      IF msgyesno('Histórico : '+alltrim(movimento_bancario->historico),'Excluir')
         IF lock_reg()
            movimento_bancario->(dbdelete())
            movimento_bancario->(dbunlock())
            movimento_bancario->(dbgotop())
         ENDIF
         movimento_bancario->(ordsetfocus('data'))
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
         dbselectarea('movimento_bancario')
         movimento_bancario->(ordsetfocus('id'))
         movimento_bancario->(dbgotop())
         movimento_bancario->(dbseek(x_id))
         IF found()
            x_id := substr(alltrim(str(HB_RANDOM(0001240003,9999999999))),1,10)
            LOOP
         ELSE
            EXIT
         ENDIF
      END
      dbselectarea('movimento_bancario')
      movimento_bancario->(dbappend())
      movimento_bancario->id        := x_id
      movimento_bancario->banco     := form_dados.tbox_000.value
      movimento_bancario->data      := form_dados.tbox_001.value
      movimento_bancario->historico := form_dados.tbox_002.value
      movimento_bancario->entrada   := form_dados.tbox_003.value
      movimento_bancario->saida     := form_dados.tbox_004.value
      movimento_bancario->(dbcommit())
      movimento_bancario->(dbgotop())
      form_dados.release
      atualizar()
   ELSEIF parametro == 2
      dbselectarea('movimento_bancario')
      IF lock_reg()
         movimento_bancario->banco     := form_dados.tbox_000.value
         movimento_bancario->data      := form_dados.tbox_001.value
         movimento_bancario->historico := form_dados.tbox_002.value
         movimento_bancario->entrada   := form_dados.tbox_003.value
         movimento_bancario->saida     := form_dados.tbox_004.value
         movimento_bancario->(dbcommit())
         movimento_bancario->(dbunlock())
         movimento_bancario->(dbgotop())
      ENDIF
      form_dados.release
      atualizar()
   ENDIF

   RETURN NIL

STATIC FUNCTION atualizar()

   LOCAL x_banco        := form_movban.cbo_001.value
   LOCAL x_codigo_banco := 0
   LOCAL x_data_001     := form_movban.dp_inicio.value
   LOCAL x_data_002     := form_movban.dp_final.value

   x_codigo_banco := val(substr(form_movban.cbo_001.item(x_banco),1,6))

   DELETE item all from grid_movban of form_movban

   dbselectarea('movimento_bancario')
   movimento_bancario->(ordsetfocus('composto'))
   movimento_bancario->(dbgotop())

   ordscope(0,str(x_codigo_banco,4)+dtos(x_data_001))
   ordscope(1,str(x_codigo_banco,4)+dtos(x_data_002))

   movimento_bancario->(dbgotop())

   WHILE .not. eof()
      add item {movimento_bancario->id,dtoc(movimento_bancario->data),alltrim(movimento_bancario->historico),trans(movimento_bancario->entrada,'@E 999,999.99'),trans(movimento_bancario->saida,'@E 999,999.99')} to grid_movban of form_movban
      movimento_bancario->(dbskip())
   END

   RETURN NIL

STATIC FUNCTION procura_banco_2(cform,ctextbtn)

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
      creg := getcode_banco_2(getproperty(cform,ctextbtn,'value'))
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

STATIC FUNCTION getcode_banco_2(value)

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
         VALUE 'Buscar'
         AUTOSIZE .T.
         FONTNAME 'verdana'
         FONTSIZE 012
         FONTBOLD .T.
         FONTCOLOR _preto_001
         TRANSPARENT .T.
      END LABEL
      DEFINE TEXTBOX txt_pesquisa
         COL 075
         ROW 440
         WIDTH 400
         MAXLENGTH 040
         ONCHANGE find_banco_2()
         uppercase .T.
      END TEXTBOX

      DEFINE BROWSE browse_pesquisa
         ROW 002
         COL 002
         WIDTH 480
         HEIGHT 430
         HEADERS {'Código','Nome'}
         WIDTHS {080,370}
         WORKAREA bancos
         FIELDS {'bancos->codigo','bancos->nome'}
         VALUE nreg
         FONTNAME 'verdana'
         FONTSIZE 010
         FONTBOLD .T.
         BACKCOLOR _ciano_001
         nolines .T.
         lock .T.
         readonly {.T.,.T.}
         JUSTIFY {BROWSE_JTFY_LEFT,BROWSE_JTFY_LEFT}
         on dblclick (creg:=bancos->codigo,thiswindow.release)
      END browse

      ON KEY ESCAPE ACTION thiswindow.release

   END WINDOW

   form_pesquisa.browse_pesquisa.setfocus

   form_pesquisa.center
   form_pesquisa.activate

   return(creg)

STATIC FUNCTION find_banco_2()

   LOCAL pesquisa := alltrim(form_pesquisa.txt_pesquisa.value)

   bancos->(dbgotop())

   IF pesquisa == ''

      RETURN NIL
   ELSEIF bancos->(dbseek(pesquisa))
      form_pesquisa.browse_pesquisa.value := bancos->(recno())
   ENDIF

   RETURN NIL
