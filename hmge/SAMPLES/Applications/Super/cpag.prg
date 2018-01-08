/*
sistema     : superchef pizzaria
programa    : contas a pagar
compilador  : xharbour 1.2 simplex
lib gráfica : minigui 1.7 extended
programador : marcelo neves
*/

#include 'minigui.ch'
#include 'super.ch'

FUNCTION cpag()

   DEFINE WINDOW form_cpag;
         at 000,000;
         WIDTH 1000;
         HEIGHT 680;
         TITLE 'Contas a Pagar';
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
         ACTION dados_cpag(1)
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
         ACTION dados_cpag(2)
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
         ACTION excluir_cpag()
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
         ACTION atualizar_cpag()
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
         ACTION form_cpag.release
         FONTNAME 'verdana'
         FONTSIZE 009
         FONTBOLD .T.
         FONTCOLOR _preto_001
         vertical .T.
         flat .T.
         noxpstyle .T.
         BACKCOLOR _branco_001
      END BUTTONEX

      DEFINE GRID grid_cpag
         parent form_cpag
         COL 005
         ROW 105
         WIDTH 980
         HEIGHT 500
         HEADERS {'id','Vencimento','Fornecedor','Forma Pagamento','Valor R$','Nº Documento','Observação'}
         WIDTHS {001,120,300,200,120,120,200}
         FONTNAME 'verdana'
         FONTSIZE 010
         FONTBOLD .T.
         BACKCOLOR _amarelo_001
         FONTCOLOR _preto_001
         ondblclick dados_cpag(2)
      END GRID

      DEFINE LABEL rodape_001
         parent form_cpag
         COL 005
         ROW 615
         VALUE 'Escolha o período'
         AUTOSIZE .T.
         FONTNAME 'verdana'
         FONTSIZE 010
         FONTBOLD .T.
         FONTCOLOR _cinza_001
         TRANSPARENT .T.
      END LABEL
      DEFINE LABEL rodape_002
         parent form_cpag
         COL 250
         ROW 615
         VALUE 'até'
         AUTOSIZE .T.
         FONTNAME 'verdana'
         FONTSIZE 010
         FONTBOLD .T.
         FONTCOLOR _cinza_001
         TRANSPARENT .T.
      END LABEL
      @ 610,140 datepicker dp_inicio;
         parent form_cpag;
         VALUE date();
         WIDTH 100;
         font 'verdana' size 010
      @ 610,280 datepicker dp_final;
         parent form_cpag;
         VALUE date();
         WIDTH 100;
         font 'verdana' size 010
      @ 610,390 buttonex botao_filtrar;
         parent form_cpag;
         CAPTION 'Filtrar';
         WIDTH 100 height 030;
         ACTION atualizar_cpag();
         bold;
         TOOLTIP 'Clique aqui para mostrar as informações com base no período selecionado'

      DEFINE LABEL rodape_003
         parent form_cpag
         COL form_cpag.width - 270
         ROW 615
         VALUE 'DUPLO CLIQUE : Alterar informação'
         AUTOSIZE .T.
         FONTNAME 'verdana'
         FONTSIZE 010
         FONTBOLD .T.
         FONTCOLOR _verde_002
         TRANSPARENT .T.
      END LABEL

      ON KEY ESCAPE ACTION thiswindow.release

   END WINDOW

   form_cpag.center
   form_cpag.activate

   RETURN NIL

STATIC FUNCTION dados_cpag(parametro)

   LOCAL id
   LOCAL titulo       := ''
   LOCAL x_fornecedor := 0
   LOCAL x_forma      := 0
   LOCAL x_data       := date()
   LOCAL x_valor      := 0
   LOCAL x_numero     := ''
   LOCAL x_obs        := ''

   IF parametro == 1
      titulo := 'Incluir'
   ELSEIF parametro == 2
      id     := valor_coluna('grid_cpag','form_cpag',1)
      titulo := 'Alterar'
      dbselectarea('contas_pagar')
      contas_pagar->(ordsetfocus('id'))
      contas_pagar->(dbgotop())
      contas_pagar->(dbseek(id))
      IF found()
         x_fornecedor := contas_pagar->fornec
         x_forma      := contas_pagar->forma
         x_data       := contas_pagar->data
         x_valor      := contas_pagar->valor
         x_numero     := contas_pagar->numero
         x_obs        := contas_pagar->obs
         contas_pagar->(ordsetfocus('data'))
      ELSE
         msgexclamation('Selecione uma informação','Atenção')
         contas_pagar->(ordsetfocus('data'))

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
         VALUE 'Fornecedor';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 030,005 textbox tbox_001;
         of form_dados;
         HEIGHT 027;
         WIDTH 060;
         VALUE x_fornecedor;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         numeric;
         ON ENTER procura_fornecedor('form_dados','tbox_001')
      @ 030,075 label lbl_nome_fornecedor;
         of form_dados;
         VALUE '';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _azul_001;
         TRANSPARENT
      @ 060,005 label lbl_002;
         of form_dados;
         VALUE 'Forma Pagamento';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 080,005 textbox tbox_002;
         of form_dados;
         HEIGHT 027;
         WIDTH 060;
         VALUE x_forma;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         numeric;
         ON ENTER procura_forma_pagamento('form_dados','tbox_002')
      @ 080,075 label lbl_nome_forma_pagamento;
         of form_dados;
         VALUE '';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _azul_001;
         TRANSPARENT

      @ 110,005 label lbl_003;
         of form_dados;
         VALUE 'Data';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR BLUE;
         TRANSPARENT
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
         TRANSPARENT
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
         TRANSPARENT
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
         TRANSPARENT
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
         ACTION gravar_cpag(parametro)
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

STATIC FUNCTION excluir_cpag()

   LOCAL id := valor_coluna('grid_cpag','form_cpag',1)

   dbselectarea('contas_pagar')
   contas_pagar->(ordsetfocus('id'))
   contas_pagar->(dbgotop())
   contas_pagar->(dbseek(id))

   IF .not. found()
      msgexclamation('Selecione uma informação','Atenção')
      contas_pagar->(ordsetfocus('data'))

      RETURN NIL
   ELSE
      IF msgyesno('Histórico : '+alltrim(contas_pagar->numero),'Excluir')
         IF lock_reg()
            contas_pagar->(dbdelete())
            contas_pagar->(dbunlock())
            contas_pagar->(dbgotop())
         ENDIF
         contas_pagar->(ordsetfocus('data'))
         atualizar_cpag()
      ENDIF
   ENDIF

   RETURN NIL

STATIC FUNCTION gravar_cpag(parametro)

   LOCAL x_id := substr(alltrim(str(HB_RANDOM(0001240003,9999999999))),1,10)

   IF parametro == 1
      WHILE .T.
         dbselectarea('contas_pagar')
         contas_pagar->(ordsetfocus('id'))
         contas_pagar->(dbgotop())
         contas_pagar->(dbseek(x_id))
         IF found()
            x_id := substr(alltrim(str(HB_RANDOM(0001240003,9999999999))),1,10)
            LOOP
         ELSE
            EXIT
         ENDIF
      END
      dbselectarea('contas_pagar')
      IF l_demo
         IF reccount() > _limite_registros
            msgstop('Limite de registros esgotado','Atenção')

            RETURN NIL
         ENDIF
      ENDIF
      contas_pagar->(dbappend())
      contas_pagar->id     := x_id
      contas_pagar->data   := form_dados.tbox_003.value
      contas_pagar->valor  := form_dados.tbox_004.value
      contas_pagar->forma  := form_dados.tbox_002.value
      contas_pagar->fornec := form_dados.tbox_001.value
      contas_pagar->numero := form_dados.tbox_005.value
      contas_pagar->obs    := form_dados.tbox_006.value
      contas_pagar->(dbcommit())
      contas_pagar->(dbgotop())
      form_dados.release
      atualizar_cpag()
   ELSEIF parametro == 2
      dbselectarea('contas_pagar')
      IF lock_reg()
         contas_pagar->data   := form_dados.tbox_003.value
         contas_pagar->valor  := form_dados.tbox_004.value
         contas_pagar->forma  := form_dados.tbox_002.value
         contas_pagar->fornec := form_dados.tbox_001.value
         contas_pagar->numero := form_dados.tbox_005.value
         contas_pagar->obs    := form_dados.tbox_006.value
         contas_pagar->(dbcommit())
         contas_pagar->(dbunlock())
         contas_pagar->(dbgotop())
      ENDIF
      form_dados.release
      atualizar_cpag()
   ENDIF

   RETURN NIL

STATIC FUNCTION atualizar_cpag()

   LOCAL x_data_001 := form_cpag.dp_inicio.value
   LOCAL x_data_002 := form_cpag.dp_final.value

   DELETE item all from grid_cpag of form_cpag

   dbselectarea('contas_pagar')
   INDEX ON dtos(data) to ind001 for data >= x_data_001 .and. data <= x_data_002
   GO TOP

   WHILE .not. eof()
      add item {contas_pagar->id,dtoc(contas_pagar->data),acha_fornecedor(contas_pagar->fornec),acha_forma_pagamento(contas_pagar->forma),trans(contas_pagar->valor,'@E 999,999.99'),alltrim(contas_pagar->numero),alltrim(contas_pagar->obs)} to grid_cpag of form_cpag
      contas_pagar->(dbskip())
   END

   RETURN NIL

STATIC FUNCTION procura_fornecedor(cform,ctextbtn)

   LOCAL flag    := .F.
   LOCAL creg    := ''
   LOCAL nreg_01 := getproperty(cform,ctextbtn,'value')
   LOCAL nreg_02 := nreg_01

   dbselectarea('fornecedores')
   fornecedores->(ordsetfocus('codigo'))
   fornecedores->(dbgotop())
   fornecedores->(dbseek(nreg_02))
   IF found()
      flag := .T.
   ELSE
      creg := getcode_fornecedores(getproperty(cform,ctextbtn,'value'))
      dbselectarea('fornecedores')
      fornecedores->(ordsetfocus('codigo'))
      fornecedores->(dbgotop())
      fornecedores->(dbseek(creg))
      IF found()
         flag := .T.
      ENDIF
   ENDIF

   IF flag
      setproperty('form_dados','lbl_nome_fornecedor','value',fornecedores->nome)
   ENDIF

   IF !empty(creg)
      setproperty(cform,ctextbtn,'value',creg)
   ENDIF

   RETURN NIL

STATIC FUNCTION getcode_fornecedores(value)

   LOCAL creg := ''
   LOCAL nreg := 1

   dbselectarea('fornecedores')
   fornecedores->(ordsetfocus('nome'))
   fornecedores->(dbgotop())

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
         ONCHANGE find_fornecedores()
         uppercase .T.
      END TEXTBOX

      DEFINE BROWSE browse_pesquisa
         ROW 002
         COL 002
         WIDTH 480
         HEIGHT 430
         HEADERS {'Código','Nome'}
         WIDTHS {080,370}
         WORKAREA fornecedores
         FIELDS {'fornecedores->codigo','fornecedores->nome'}
         VALUE nreg
         FONTNAME 'verdana'
         FONTSIZE 010
         FONTBOLD .T.
         BACKCOLOR _ciano_001
         nolines .T.
         lock .T.
         readonly {.T.,.T.}
         JUSTIFY {BROWSE_JTFY_LEFT,BROWSE_JTFY_LEFT}
         on dblclick (creg:=fornecedores->codigo,thiswindow.release)
      END browse

      ON KEY ESCAPE ACTION thiswindow.release

   END WINDOW

   form_pesquisa.browse_pesquisa.setfocus

   form_pesquisa.center
   form_pesquisa.activate

   return(creg)

STATIC FUNCTION find_fornecedores()

   LOCAL pesquisa := alltrim(form_pesquisa.txt_pesquisa.value)

   fornecedores->(dbgotop())

   IF pesquisa == ''

      RETURN NIL
   ELSEIF fornecedores->(dbseek(pesquisa))
      form_pesquisa.browse_pesquisa.value := fornecedores->(recno())
   ENDIF

   RETURN NIL

STATIC FUNCTION procura_forma_pagamento(cform,ctextbtn)

   LOCAL flag    := .F.
   LOCAL creg    := ''
   LOCAL nreg_01 := getproperty(cform,ctextbtn,'value')
   LOCAL nreg_02 := nreg_01

   dbselectarea('formas_pagamento')
   formas_pagamento->(ordsetfocus('codigo'))
   formas_pagamento->(dbgotop())
   formas_pagamento->(dbseek(nreg_02))
   IF found()
      flag := .T.
   ELSE
      creg := getcode_formas_pagamento(getproperty(cform,ctextbtn,'value'))
      dbselectarea('formas_pagamento')
      formas_pagamento->(ordsetfocus('codigo'))
      formas_pagamento->(dbgotop())
      formas_pagamento->(dbseek(creg))
      IF found()
         flag := .T.
      ENDIF
   ENDIF

   IF flag
      setproperty('form_dados','lbl_nome_forma_pagamento','value',formas_pagamento->nome)
   ENDIF

   IF !empty(creg)
      setproperty(cform,ctextbtn,'value',creg)
   ENDIF

   RETURN NIL

STATIC FUNCTION getcode_formas_pagamento(value)

   LOCAL creg := ''
   LOCAL nreg := 1

   dbselectarea('formas_pagamento')
   formas_pagamento->(ordsetfocus('nome'))
   formas_pagamento->(dbgotop())

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
         ONCHANGE find_formas_pagamento()
         uppercase .T.
      END TEXTBOX

      DEFINE BROWSE browse_pesquisa
         ROW 002
         COL 002
         WIDTH 480
         HEIGHT 430
         HEADERS {'Código','Nome'}
         WIDTHS {080,370}
         WORKAREA formas_pagamento
         FIELDS {'formas_pagamento->codigo','formas_pagamento->nome'}
         VALUE nreg
         FONTNAME 'verdana'
         FONTSIZE 010
         FONTBOLD .T.
         BACKCOLOR _ciano_001
         nolines .T.
         lock .T.
         readonly {.T.,.T.}
         JUSTIFY {BROWSE_JTFY_LEFT,BROWSE_JTFY_LEFT}
         on dblclick (creg:=formas_pagamento->codigo,thiswindow.release)
      END browse

      ON KEY ESCAPE ACTION thiswindow.release

   END WINDOW

   form_pesquisa.browse_pesquisa.setfocus

   form_pesquisa.center
   form_pesquisa.activate

   return(creg)

STATIC FUNCTION find_formas_pagamento()

   LOCAL pesquisa := alltrim(form_pesquisa.txt_pesquisa.value)

   formas_pagamento->(dbgotop())

   IF pesquisa == ''

      RETURN NIL
   ELSEIF formas_pagamento->(dbseek(pesquisa))
      form_pesquisa.browse_pesquisa.value := formas_pagamento->(recno())
   ENDIF

   RETURN NIL
