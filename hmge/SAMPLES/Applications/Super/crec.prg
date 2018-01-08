/*
sistema     : superchef pizzaria
programa    : contas a receber
compilador  : xharbour 1.2 simplex
lib gráfica : minigui 1.7 extended
programador : marcelo neves
*/

#include 'minigui.ch'
#include 'super.ch'

FUNCTION crec()

   DEFINE WINDOW form_crec;
         at 000,000;
         WIDTH 1000;
         HEIGHT 680;
         TITLE 'Contas a Receber';
         ICON path_imagens+'icone.ico';
         modal;
         NOSIZE

      * botões (toolbar)
      DEFINE BUTTONEX button_incluir_2
         PICTURE path_imagens+'incluir.bmp'
         COL 005
         ROW 002
         WIDTH 100
         HEIGHT 100
         CAPTION 'F5 Incluir'
         ACTION dados_crec(1)
         FONTNAME 'verdana'
         fontsize 009
         FONTBOLD .T.
         FONTCOLOR _preto_001
         vertical .T.
         flat .T.
         noxpstyle .T.
         BACKCOLOR _branco_001
      END BUTTONEX
      DEFINE BUTTONEX button_alterar_2
         PICTURE path_imagens+'alterar.bmp'
         COL 107
         ROW 002
         WIDTH 100
         HEIGHT 100
         CAPTION 'F6 Alterar'
         ACTION dados_crec(2)
         FONTNAME 'verdana'
         fontsize 009
         FONTBOLD .T.
         FONTCOLOR _preto_001
         vertical .T.
         flat .T.
         noxpstyle .T.
         BACKCOLOR _branco_001
      END BUTTONEX
      DEFINE BUTTONEX button_excluir_2
         PICTURE path_imagens+'excluir.bmp'
         COL 209
         ROW 002
         WIDTH 100
         HEIGHT 100
         CAPTION 'F7 Excluir'
         ACTION excluir_crec()
         FONTNAME 'verdana'
         fontsize 009
         FONTBOLD .T.
         FONTCOLOR _preto_001
         vertical .T.
         flat .T.
         noxpstyle .T.
         BACKCOLOR _branco_001
      END BUTTONEX
      DEFINE BUTTONEX button_atualizar_2
         PICTURE path_imagens+'atualizar.bmp'
         COL 311
         ROW 002
         WIDTH 100
         HEIGHT 100
         CAPTION 'Atualizar'
         ACTION atualizar_crec()
         FONTNAME 'verdana'
         fontsize 009
         FONTBOLD .T.
         FONTCOLOR _preto_001
         vertical .T.
         flat .T.
         noxpstyle .T.
         BACKCOLOR _branco_001
      END BUTTONEX
      DEFINE BUTTONEX button_sair_2
         PICTURE path_imagens+'sair.bmp'
         COL 413
         ROW 002
         WIDTH 100
         HEIGHT 100
         CAPTION 'ESC Voltar'
         ACTION form_crec.release
         FONTNAME 'verdana'
         fontsize 009
         FONTBOLD .T.
         FONTCOLOR _preto_001
         vertical .T.
         flat .T.
         noxpstyle .T.
         BACKCOLOR _branco_001
      END BUTTONEX

      DEFINE GRID grid_crec
         parent form_crec
         COL 005
         ROW 105
         WIDTH 980
         HEIGHT 500
         HEADERS {'id','Vencimento','Cliente','Forma Recebimento','Valor R$','Nº Documento','Observação'}
         WIDTHS {001,120,300,200,120,120,200}
         FONTNAME 'verdana'
         fontsize 010
         FONTBOLD .T.
         BACKCOLOR _amarelo_001
         FONTCOLOR _preto_001
         ondblclick dados_crec(2)
      END GRID

      DEFINE LABEL rodape_001_2
         parent form_crec
         COL 005
         ROW 615
         VALUE 'Escolha o período'
         autosize .T.
         FONTNAME 'verdana'
         fontsize 010
         FONTBOLD .T.
         FONTCOLOR _cinza_001
         transparent .T.
      END LABEL
      DEFINE LABEL rodape_002_2
         parent form_crec
         COL 250
         ROW 615
         VALUE 'até'
         autosize .T.
         FONTNAME 'verdana'
         fontsize 010
         FONTBOLD .T.
         FONTCOLOR _cinza_001
         transparent .T.
      END LABEL
      @ 610,140 datepicker dp_inicio_2;
         parent form_crec;
         VALUE date();
         WIDTH 100;
         font 'verdana' size 010
      @ 610,280 datepicker dp_final_2;
         parent form_crec;
         VALUE date();
         WIDTH 100;
         font 'verdana' size 010
      @ 610,390 buttonex botao_filtrar_2;
         parent form_crec;
         CAPTION 'Filtrar';
         WIDTH 100 height 030;
         ACTION atualizar_crec();
         bold;
         TOOLTIP 'Clique aqui para mostrar as informações com base no período selecionado'

      DEFINE LABEL rodape_003_2
         parent form_crec
         COL form_crec.width - 270
         ROW 615
         VALUE 'DUPLO CLIQUE : Alterar informação'
         autosize .T.
         FONTNAME 'verdana'
         fontsize 010
         FONTBOLD .T.
         FONTCOLOR _verde_002
         transparent .T.
      END LABEL

      ON KEY ESCAPE ACTION thiswindow.release

   END WINDOW

   form_crec.center
   form_crec.activate

   RETURN NIL

STATIC FUNCTION dados_crec(parametro)

   LOCAL id
   LOCAL titulo    := ''
   LOCAL x_cliente := 0
   LOCAL x_forma   := 0
   LOCAL x_data    := date()
   LOCAL x_valor   := 0
   LOCAL x_numero  := ''
   LOCAL x_obs     := ''

   IF parametro == 1
      titulo := 'Incluir'
   ELSEIF parametro == 2
      id     := valor_coluna('grid_crec','form_crec',1)
      titulo := 'Alterar'
      dbselectarea('contas_receber')
      contas_receber->(ordsetfocus('id'))
      contas_receber->(dbgotop())
      contas_receber->(dbseek(id))
      IF found()
         x_cliente := contas_receber->cliente
         x_forma   := contas_receber->forma
         x_data    := contas_receber->data
         x_valor   := contas_receber->valor
         x_numero  := contas_receber->numero
         x_obs     := contas_receber->obs
         contas_receber->(ordsetfocus('data'))
      ELSE
         msgexclamation('Selecione uma informação','Atenção')
         contas_receber->(ordsetfocus('data'))

         RETURN NIL
      ENDIF
   ENDIF

   DEFINE WINDOW form_dados;
         at 000,000;
         WIDTH 430;
         HEIGHT 330;
         TITLE (titulo);
         ICON path_imagens+'icone.ico';
         modal;
         NOSIZE

      * entrada de dados
      @ 010,005 label lbl_001;
         of form_dados;
         VALUE 'Cliente';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         transparent
      @ 030,005 textbox tbox_001;
         of form_dados;
         HEIGHT 027;
         WIDTH 060;
         VALUE x_cliente;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         numeric;
         ON ENTER procura_cliente('form_dados','tbox_001')
      @ 030,075 label lbl_nome_cliente;
         of form_dados;
         VALUE '';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _azul_001;
         transparent
      @ 060,005 label lbl_002;
         of form_dados;
         VALUE 'Forma Recebimento';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         transparent
      @ 080,005 textbox tbox_002;
         of form_dados;
         HEIGHT 027;
         WIDTH 060;
         VALUE x_forma;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         numeric;
         ON ENTER procura_forma_recebimento('form_dados','tbox_002')
      @ 080,075 label lbl_nome_forma_recebimento;
         of form_dados;
         VALUE '';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _azul_001;
         transparent

      @ 110,005 label lbl_003;
         of form_dados;
         VALUE 'Data';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR BLUE;
         transparent
      @ 130,005 textbox tbox_003;
         of form_dados;
         HEIGHT 027;
         WIDTH 120;
         VALUE x_data;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         date

      @ 110,140 label lbl_004;
         of form_dados;
         VALUE 'Valor R$';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _vermelho_002;
         transparent
      @ 130,140 getbox tbox_004;
         of form_dados;
         HEIGHT 027;
         WIDTH 120;
         VALUE x_valor;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         PICTURE '@E 999,999.99'

      @ 110,270 label lbl_005;
         of form_dados;
         VALUE 'Número documento';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         transparent
      @ 130,270 textbox tbox_005;
         of form_dados;
         HEIGHT 027;
         WIDTH 150;
         VALUE x_numero;
         MAXLENGTH 015;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         uppercase

      @ 160,005 label lbl_006;
         of form_dados;
         VALUE 'Observação';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         transparent
      @ 180,005 textbox tbox_006;
         of form_dados;
         HEIGHT 027;
         WIDTH 200;
         VALUE x_obs;
         MAXLENGTH 030;
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
         transparent .F.
      END LABEL

      * botões
      DEFINE BUTTONEX button_ok
         PICTURE path_imagens+'img_gravar.bmp'
         COL form_dados.width-225
         ROW form_dados.height-085
         WIDTH 120
         HEIGHT 050
         CAPTION 'Ok, gravar'
         ACTION gravar_crec(parametro)
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

STATIC FUNCTION excluir_crec()

   LOCAL id := valor_coluna('grid_crec','form_crec',1)

   dbselectarea('contas_receber')
   contas_receber->(ordsetfocus('id'))
   contas_receber->(dbgotop())
   contas_receber->(dbseek(id))

   IF .not. found()
      msgexclamation('Selecione uma informação','Atenção')
      contas_receber->(ordsetfocus('data'))

      RETURN NIL
   ELSE
      IF msgyesno('Histórico : '+alltrim(contas_receber->numero),'Excluir')
         IF lock_reg()
            contas_receber->(dbdelete())
            contas_receber->(dbunlock())
            contas_receber->(dbgotop())
         ENDIF
         contas_receber->(ordsetfocus('data'))
         atualizar_crec()
      ENDIF
   ENDIF

   RETURN NIL

STATIC FUNCTION gravar_crec(parametro)

   LOCAL x_id := substr(alltrim(str(HB_RANDOM(0001240003,9999999999))),1,10)

   IF parametro == 1
      WHILE .T.
         dbselectarea('contas_receber')
         contas_receber->(ordsetfocus('id'))
         contas_receber->(dbgotop())
         contas_receber->(dbseek(x_id))
         IF found()
            x_id := substr(alltrim(str(HB_RANDOM(0001240003,9999999999))),1,10)
            LOOP
         ELSE
            EXIT
         ENDIF
      END
      dbselectarea('contas_receber')
      IF l_demo
         IF reccount() > _limite_registros
            msgstop('Limite de registros esgotado','Atenção')

            RETURN NIL
         ENDIF
      ENDIF
      contas_receber->(dbappend())
      contas_receber->id      := x_id
      contas_receber->data    := form_dados.tbox_003.value
      contas_receber->valor   := form_dados.tbox_004.value
      contas_receber->forma   := form_dados.tbox_002.value
      contas_receber->cliente := form_dados.tbox_001.value
      contas_receber->numero  := form_dados.tbox_005.value
      contas_receber->obs     := form_dados.tbox_006.value
      contas_receber->(dbcommit())
      contas_receber->(dbgotop())
      form_dados.release
      atualizar_crec()
   ELSEIF parametro == 2
      dbselectarea('contas_receber')
      IF lock_reg()
         contas_receber->data    := form_dados.tbox_003.value
         contas_receber->valor   := form_dados.tbox_004.value
         contas_receber->forma   := form_dados.tbox_002.value
         contas_receber->cliente := form_dados.tbox_001.value
         contas_receber->numero  := form_dados.tbox_005.value
         contas_receber->obs     := form_dados.tbox_006.value
         contas_receber->(dbcommit())
         contas_receber->(dbunlock())
         contas_receber->(dbgotop())
      ENDIF
      form_dados.release
      atualizar_crec()
   ENDIF

   RETURN NIL

STATIC FUNCTION atualizar_crec()

   LOCAL x_data_001 := form_crec.dp_inicio_2.value
   LOCAL x_data_002 := form_crec.dp_final_2.value

   DELETE item all from grid_crec of form_crec

   dbselectarea('contas_receber')
   INDEX ON dtos(data) to ind001 for data >= x_data_001 .and. data <= x_data_002
   GO TOP

   WHILE .not. eof()
      add item {contas_receber->id,dtoc(contas_receber->data),acha_cliente(contas_receber->cliente),acha_forma_recebimento(contas_receber->forma),trans(contas_receber->valor,'@E 999,999.99'),alltrim(contas_receber->numero),alltrim(contas_receber->obs)} to grid_crec of form_crec
      contas_receber->(dbskip())
   END

   RETURN NIL

STATIC FUNCTION procura_cliente(cform,ctextbtn)

   LOCAL flag    := .F.
   LOCAL creg    := ''
   LOCAL nreg_01 := getproperty(cform,ctextbtn,'value')
   LOCAL nreg_02 := nreg_01

   dbselectarea('clientes')
   clientes->(ordsetfocus('codigo'))
   clientes->(dbgotop())
   clientes->(dbseek(nreg_02))
   IF found()
      flag := .T.
   ELSE
      creg := getcode_clientes(getproperty(cform,ctextbtn,'value'))
      dbselectarea('clientes')
      clientes->(ordsetfocus('codigo'))
      clientes->(dbgotop())
      clientes->(dbseek(creg))
      IF found()
         flag := .T.
      ENDIF
   ENDIF

   IF flag
      setproperty('form_dados','lbl_nome_cliente','value',clientes->nome)
   ENDIF

   IF !empty(creg)
      setproperty(cform,ctextbtn,'value',creg)
   ENDIF

   RETURN NIL

STATIC FUNCTION getcode_clientes(value)

   LOCAL creg := ''
   LOCAL nreg := 1

   dbselectarea('clientes')
   clientes->(ordsetfocus('nome'))
   clientes->(dbgotop())

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
         autosize .T.
         FONTNAME 'verdana'
         fontsize 012
         FONTBOLD .T.
         FONTCOLOR _preto_001
         transparent .T.
      END LABEL
      DEFINE TEXTBOX txt_pesquisa
         COL 075
         ROW 440
         WIDTH 400
         MAXLENGTH 040
         onchange find_clientes()
         uppercase .T.
      END TEXTBOX

      DEFINE BROWSE browse_pesquisa
         ROW 002
         COL 002
         WIDTH 480
         HEIGHT 430
         HEADERS {'Código','Nome'}
         WIDTHS {080,370}
         WORKAREA clientes
         FIELDS {'clientes->codigo','clientes->nome'}
         VALUE nreg
         FONTNAME 'verdana'
         fontsize 010
         FONTBOLD .T.
         BACKCOLOR _ciano_001
         nolines .T.
         lock .T.
         readonly {.T.,.T.}
         justify {BROWSE_JTFY_LEFT,BROWSE_JTFY_LEFT}
         on dblclick (creg:=clientes->codigo,thiswindow.release)
      END browse

      ON KEY ESCAPE ACTION thiswindow.release

   END WINDOW

   form_pesquisa.browse_pesquisa.setfocus

   form_pesquisa.center
   form_pesquisa.activate

   return(creg)

STATIC FUNCTION find_clientes()

   LOCAL pesquisa := alltrim(form_pesquisa.txt_pesquisa.value)

   clientes->(dbgotop())

   IF pesquisa == ''

      RETURN NIL
   ELSEIF clientes->(dbseek(pesquisa))
      form_pesquisa.browse_pesquisa.value := clientes->(recno())
   ENDIF

   RETURN NIL

STATIC FUNCTION procura_forma_recebimento(cform,ctextbtn)

   LOCAL flag    := .F.
   LOCAL creg    := ''
   LOCAL nreg_01 := getproperty(cform,ctextbtn,'value')
   LOCAL nreg_02 := nreg_01

   dbselectarea('formas_recebimento')
   formas_recebimento->(ordsetfocus('codigo'))
   formas_recebimento->(dbgotop())
   formas_recebimento->(dbseek(nreg_02))
   IF found()
      flag := .T.
   ELSE
      creg := getcode_formas_recebimento(getproperty(cform,ctextbtn,'value'))
      dbselectarea('formas_recebimento')
      formas_recebimento->(ordsetfocus('codigo'))
      formas_recebimento->(dbgotop())
      formas_recebimento->(dbseek(creg))
      IF found()
         flag := .T.
      ENDIF
   ENDIF

   IF flag
      setproperty('form_dados','lbl_nome_forma_recebimento','value',formas_recebimento->nome)
   ENDIF

   IF !empty(creg)
      setproperty(cform,ctextbtn,'value',creg)
   ENDIF

   RETURN NIL

STATIC FUNCTION getcode_formas_recebimento(value)

   LOCAL creg := ''
   LOCAL nreg := 1

   dbselectarea('formas_recebimento')
   formas_recebimento->(ordsetfocus('nome'))
   formas_recebimento->(dbgotop())

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
         autosize .T.
         FONTNAME 'verdana'
         fontsize 012
         FONTBOLD .T.
         FONTCOLOR _preto_001
         transparent .T.
      END LABEL
      DEFINE TEXTBOX txt_pesquisa
         COL 075
         ROW 440
         WIDTH 400
         MAXLENGTH 040
         onchange find_formas_recebimento()
         uppercase .T.
      END TEXTBOX

      DEFINE BROWSE browse_pesquisa
         ROW 002
         COL 002
         WIDTH 480
         HEIGHT 430
         HEADERS {'Código','Nome'}
         WIDTHS {080,370}
         WORKAREA formas_recebimento
         FIELDS {'formas_recebimento->codigo','formas_recebimento->nome'}
         VALUE nreg
         FONTNAME 'verdana'
         fontsize 010
         FONTBOLD .T.
         BACKCOLOR _ciano_001
         nolines .T.
         lock .T.
         readonly {.T.,.T.}
         justify {BROWSE_JTFY_LEFT,BROWSE_JTFY_LEFT}
         on dblclick (creg:=formas_recebimento->codigo,thiswindow.release)
      END browse

      ON KEY ESCAPE ACTION thiswindow.release

   END WINDOW

   form_pesquisa.browse_pesquisa.setfocus

   form_pesquisa.center
   form_pesquisa.activate

   return(creg)

STATIC FUNCTION find_formas_recebimento()

   LOCAL pesquisa := alltrim(form_pesquisa.txt_pesquisa.value)

   formas_recebimento->(dbgotop())

   IF pesquisa == ''

      RETURN NIL
   ELSEIF formas_recebimento->(dbseek(pesquisa))
      form_pesquisa.browse_pesquisa.value := formas_recebimento->(recno())
   ENDIF

   RETURN NIL
