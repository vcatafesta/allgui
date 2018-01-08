/*
sistema     : superchef pizzaria
programa    : operadores do programa
compilador  : xharbour 1.2 simplex
lib gráfica : minigui 1.7 extended
programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'super.ch'

FUNCTION operadores()

   dbselectarea('operadores')
   ordsetfocus('nome')
   operadores->(dbgotop())

   DEFINE WINDOW form_operadores;
         at 000,000;
         WIDTH 800;
         HEIGHT 605;
         TITLE 'Operadores do Programa';
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
      DEFINE BUTTONEX button_acessos
         PICTURE path_imagens+'acessos.bmp'
         COL 515
         ROW 002
         WIDTH 100
         HEIGHT 100
         CAPTION 'Acessos'
         ACTION acesso()
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
         COL 617
         ROW 002
         WIDTH 100
         HEIGHT 100
         CAPTION 'ESC Voltar'
         ACTION form_operadores.release
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
         DEFINE GRID grid_operadores
            parent form_operadores
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
         parent form_operadores
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
         of form_operadores;
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
         parent form_operadores
         COL form_operadores.width - 270
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

   form_operadores.center
   form_operadores.activate

   RETURN NIL

STATIC FUNCTION dados(parametro)

   LOCAL id
   LOCAL titulo  := ''
   LOCAL x_nome  := ''
   LOCAL x_senha := ''

   IF parametro == 1
      titulo := 'Incluir'
   ELSEIF parametro == 2
      id     := val(valor_coluna('grid_operadores','form_operadores',1))
      titulo := 'Alterar'
      dbselectarea('operadores')
      operadores->(ordsetfocus('codigo'))
      operadores->(dbgotop())
      operadores->(dbseek(id))
      IF found()
         x_nome  := operadores->nome
         x_senha := operadores->senha
         operadores->(ordsetfocus('nome'))
      ELSE
         msgexclamation('Selecione uma informação','Atenção')
         operadores->(ordsetfocus('nome'))

         RETURN NIL
      ENDIF
   ENDIF

   DEFINE WINDOW form_dados;
         at 000,000;
         WIDTH 325;
         HEIGHT 220;
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
      @ 060,005 label lbl_002;
         of form_dados;
         VALUE 'Senha';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 080,005 textbox tbox_002;
         of form_dados;
         HEIGHT 027;
         WIDTH 120;
         VALUE x_senha;
         MAXLENGTH 010;
         font 'tahoma' size 010;
         BACKCOLOR _fundo_get;
         FONTCOLOR _letra_get_1;
         uppercase;
         password

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

   LOCAL id := val(valor_coluna('grid_operadores','form_operadores',1))

   dbselectarea('operadores')
   operadores->(ordsetfocus('codigo'))
   operadores->(dbgotop())
   operadores->(dbseek(id))

   IF .not. found()
      msgexclamation('Selecione uma informação','Atenção')
      operadores->(ordsetfocus('nome'))

      RETURN NIL
   ELSE
      IF msgyesno('Nome : '+alltrim(operadores->nome),'Excluir')
         IF lock_reg()
            operadores->(dbdelete())
            operadores->(dbunlock())
            operadores->(dbgotop())
         ENDIF
         operadores->(ordsetfocus('nome'))
         atualizar()
      ENDIF
   ENDIF

   RETURN NIL

STATIC FUNCTION relacao()

   LOCAL p_linha := 040
   LOCAL u_linha := 260
   LOCAL linha   := p_linha
   LOCAL pagina  := 1

   dbselectarea('operadores')
   operadores->(ordsetfocus('nome'))
   operadores->(dbgotop())

   SELECT PRINTER DIALOG PREVIEW

   START PRINTDOC NAME 'Gerenciador de impressão'
      START PRINTPAGE

         cabecalho(pagina)

         WHILE .not. eof()

            @ linha,030 PRINT strzero(operadores->codigo,4) FONT 'courier new' SIZE 010
            @ linha,050 PRINT operadores->nome FONT 'courier new' SIZE 010

            linha += 5

            IF linha >= u_linha
            END PRINTPAGE
            START PRINTPAGE
               pagina ++
               cabecalho(pagina)
               linha := p_linha
            ENDIF

            operadores->(dbskip())

         END

         rodape()

      END PRINTPAGE
   END PRINTDOC

   RETURN NIL

STATIC FUNCTION cabecalho(p_pagina)

   @ 007,010 PRINT IMAGE path_imagens+'logotipo.bmp' WIDTH 050 HEIGHT 020 STRETCH
   @ 010,070 PRINT 'RELAÇÃO DE OPERADORES' FONT 'courier new' SIZE 018 BOLD
   @ 018,070 PRINT 'ordem alfabética' FONT 'courier new' SIZE 014
   @ 024,070 PRINT 'página : '+strzero(p_pagina,4) FONT 'courier new' SIZE 012

   @ 030,000 PRINT LINE TO 030,205 PENWIDTH 0.5 COLOR _preto_001

   @ 035,030 PRINT 'CÓDIGO' FONT 'courier new' SIZE 010 BOLD
   @ 035,050 PRINT 'NOME' FONT 'courier new' SIZE 010 BOLD

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
            codigo := conta->c_operador
            REPLACE c_operador with c_operador + 1
            conta->(dbcommit())
            conta->(dbunlock())
            EXIT
         ELSE
            msgexclamation('Servidor congestionado, tecle ENTER e aguarde','Atenção')
            LOOP
         ENDIF
      END
      dbselectarea('operadores')
      operadores->(dbappend())
      operadores->codigo := codigo
      operadores->nome   := form_dados.tbox_001.value
      operadores->senha  := form_dados.tbox_002.value
      operadores->(dbcommit())
      operadores->(dbgotop())
      form_dados.release
      atualizar()
   ELSEIF parametro == 2
      dbselectarea('operadores')
      IF lock_reg()
         operadores->nome  := form_dados.tbox_001.value
         operadores->senha := form_dados.tbox_002.value
         operadores->(dbcommit())
         operadores->(dbunlock())
         operadores->(dbgotop())
      ENDIF
      form_dados.release
      atualizar()
   ENDIF

   RETURN NIL

STATIC FUNCTION pesquisar()

   LOCAL cPesq        := alltrim(form_operadores.tbox_pesquisa.value)
   LOCAL lGridFreeze  := .T.
   LOCAL nTamNomePesq := len(cPesq)

   dbselectarea('operadores')
   operadores->(ordsetfocus('nome'))
   operadores->(dbseek(cPesq))

   IF lGridFreeze
      form_operadores.grid_operadores.disableupdate
   ENDIF

   DELETE item all from grid_operadores of form_operadores

   WHILE .not. eof()
      IF substr(field->nome,1,nTamNomePesq) == cPesq
         add item {str(operadores->codigo),alltrim(operadores->nome)} to grid_operadores of form_operadores
      ELSEIF substr(field->nome,1,nTamNomePesq) > cPesq
         EXIT
      ENDIF
      operadores->(dbskip())
   END

   IF lGridFreeze
      form_operadores.grid_operadores.enableupdate
   ENDIF

   RETURN NIL

STATIC FUNCTION atualizar()

   DELETE item all from grid_operadores of form_operadores

   dbselectarea('operadores')
   operadores->(ordsetfocus('nome'))
   operadores->(dbgotop())

   WHILE .not. eof()
      add item {str(operadores->codigo),alltrim(operadores->nome)} to grid_operadores of form_operadores
      operadores->(dbskip())
   END

   RETURN NIL

STATIC FUNCTION acesso()

   LOCAL x_id   := val(valor_coluna('grid_operadores','form_operadores',1))
   LOCAL x_nome := alltrim(valor_coluna('grid_operadores','form_operadores',2))
   LOCAL x_opcao_001, x_opcao_002, x_opcao_003, x_opcao_004
   LOCAL x_opcao_005, x_opcao_006, x_opcao_007, x_opcao_008
   LOCAL x_opcao_009, x_opcao_010, x_opcao_011, x_opcao_012
   LOCAL x_opcao_013, x_opcao_014, x_opcao_015, x_opcao_016
   LOCAL x_opcao_017, x_opcao_018, x_opcao_019, x_opcao_020
   LOCAL x_opcao_021, x_opcao_022, x_opcao_023, x_opcao_024
   LOCAL x_opcao_025, x_opcao_026, x_opcao_027, x_opcao_028
   LOCAL x_opcao_029, x_opcao_030, x_opcao_031, x_opcao_032
   LOCAL x_opcao_033, x_opcao_034, x_opcao_035, x_opcao_036
   LOCAL x_opcao_037, x_opcao_038, x_opcao_039, x_opcao_040
   LOCAL x_opcao_041, x_opcao_042, x_opcao_043
   LOCAL x_tipo := 1

   x_opcao_001 := x_opcao_002 := x_opcao_003 := x_opcao_004 := .F.
   x_opcao_005 := x_opcao_006 := x_opcao_007 := x_opcao_008 := .F.
   x_opcao_009 := x_opcao_010 := x_opcao_011 := x_opcao_012 := .F.
   x_opcao_013 := x_opcao_014 := x_opcao_015 := x_opcao_016 := .F.
   x_opcao_017 := x_opcao_018 := x_opcao_019 := x_opcao_020 := .F.
   x_opcao_021 := x_opcao_022 := x_opcao_023 := x_opcao_024 := .F.
   x_opcao_025 := x_opcao_026 := x_opcao_027 := x_opcao_028 := .F.
   x_opcao_029 := x_opcao_030 := x_opcao_031 := x_opcao_032 := .F.
   x_opcao_033 := x_opcao_034 := x_opcao_035 := x_opcao_036 := .F.
   x_opcao_037 := x_opcao_038 := x_opcao_039 := x_opcao_040 := .F.
   x_opcao_041 := x_opcao_042 := x_opcao_043 := .F.

   IF empty(x_id)
      msgalert('Escolha uma informação primeiro','Atenção')

      RETURN NIL
   ENDIF

   dbselectarea('acesso')
   acesso->(ordsetfocus('operador'))
   acesso->(dbgotop())
   acesso->(dbseek(x_id))
   IF found()
      x_tipo := 2
      x_opcao_001 := acesso->acesso_001
      x_opcao_002 := acesso->acesso_002
      x_opcao_003 := acesso->acesso_003
      x_opcao_004 := acesso->acesso_004
      x_opcao_005 := acesso->acesso_005
      x_opcao_006 := acesso->acesso_006
      x_opcao_007 := acesso->acesso_007
      x_opcao_008 := acesso->acesso_008
      x_opcao_009 := acesso->acesso_009
      x_opcao_010 := acesso->acesso_010
      x_opcao_011 := acesso->acesso_011
      x_opcao_012 := acesso->acesso_012
      x_opcao_013 := acesso->acesso_013
      x_opcao_014 := acesso->acesso_014
      x_opcao_015 := acesso->acesso_015
      x_opcao_016 := acesso->acesso_016
      x_opcao_017 := acesso->acesso_017
      x_opcao_018 := acesso->acesso_018
      x_opcao_019 := acesso->acesso_019
      x_opcao_020 := acesso->acesso_020
      x_opcao_021 := acesso->acesso_021
      x_opcao_022 := acesso->acesso_022
      x_opcao_023 := acesso->acesso_023
      x_opcao_024 := acesso->acesso_024
      x_opcao_025 := acesso->acesso_025
      x_opcao_026 := acesso->acesso_026
      x_opcao_027 := acesso->acesso_027
      x_opcao_028 := acesso->acesso_028
      x_opcao_029 := acesso->acesso_029
      x_opcao_030 := acesso->acesso_030
      x_opcao_031 := acesso->acesso_031
      x_opcao_032 := acesso->acesso_032
      x_opcao_033 := acesso->acesso_033
      x_opcao_034 := acesso->acesso_034
      x_opcao_035 := acesso->acesso_035
      x_opcao_036 := acesso->acesso_036
      x_opcao_037 := acesso->acesso_037
      x_opcao_038 := acesso->acesso_038
      x_opcao_039 := acesso->acesso_039
      x_opcao_040 := acesso->acesso_040
      x_opcao_041 := acesso->acesso_041
      x_opcao_042 := acesso->acesso_042
      x_opcao_043 := acesso->acesso_043
   ENDIF

   DEFINE WINDOW form_acesso;
         at 000,000;
         WIDTH 625;
         HEIGHT 560;
         TITLE 'Definir acessos para : '+x_nome;
         ICON path_imagens+'icone.ico';
         modal;
         NOSIZE

      DEFINE TAB tab_acesso;
            of form_acesso;
            at 003,003;
            WIDTH 615;
            HEIGHT form_acesso.height-090;
            font 'verdana';
            size 010;
            bold;
            VALUE 001;
            flat

         page 'Principal' image path_imagens+'img_hum.bmp'
            DEFINE CHECKBOX chkbox_001
               CAPTION 'Venda Delivery'
               COL 150
               ROW 050
               WIDTH 350
               VALUE x_opcao_001
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
            DEFINE CHECKBOX chkbox_002
               CAPTION 'Venda Mesas'
               COL 150
               ROW 080
               WIDTH 350
               VALUE x_opcao_002
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
            DEFINE CHECKBOX chkbox_003
               CAPTION 'Venda Balcão'
               COL 150
               ROW 110
               WIDTH 350
               VALUE x_opcao_003
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
            DEFINE CHECKBOX chkbox_004
               CAPTION 'Cadastro Clientes'
               COL 150
               ROW 140
               WIDTH 350
               VALUE x_opcao_004
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
            DEFINE CHECKBOX chkbox_005
               CAPTION 'Cadastro Produtos'
               COL 150
               ROW 170
               WIDTH 350
               VALUE x_opcao_005
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
         END PAGE
         page 'Tabelas' image path_imagens+'img_dois.bmp'
            DEFINE CHECKBOX chkbox_006
               CAPTION 'Fornecedores'
               COL 150
               ROW 050
               WIDTH 350
               VALUE x_opcao_006
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
            DEFINE CHECKBOX chkbox_007
               CAPTION 'Grupo de Fornecedores'
               COL 150
               ROW 080
               WIDTH 350
               VALUE x_opcao_007
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
            DEFINE CHECKBOX chkbox_008
               CAPTION 'Matéria Prima'
               COL 150
               ROW 110
               WIDTH 350
               VALUE x_opcao_008
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
            DEFINE CHECKBOX chkbox_009
               CAPTION 'Categorias de Produtos'
               COL 150
               ROW 140
               WIDTH 350
               VALUE x_opcao_009
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
            DEFINE CHECKBOX chkbox_010
               CAPTION 'Sub-Categorias de Produtos'
               COL 150
               ROW 170
               WIDTH 350
               VALUE x_opcao_010
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
            DEFINE CHECKBOX chkbox_011
               CAPTION 'Formas de Recebimento'
               COL 150
               ROW 200
               WIDTH 350
               VALUE x_opcao_011
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
            DEFINE CHECKBOX chkbox_012
               CAPTION 'Formas de Pagamento'
               COL 150
               ROW 230
               WIDTH 350
               VALUE x_opcao_012
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
            DEFINE CHECKBOX chkbox_013
               CAPTION 'Unidades de Medida'
               COL 150
               ROW 260
               WIDTH 350
               VALUE x_opcao_013
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
            DEFINE CHECKBOX chkbox_014
               CAPTION 'Contas Bancárias'
               COL 150
               ROW 290
               WIDTH 350
               VALUE x_opcao_014
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
            DEFINE CHECKBOX chkbox_015
               CAPTION 'Impostos e Alíquotas'
               COL 150
               ROW 320
               WIDTH 350
               VALUE x_opcao_015
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
            DEFINE CHECKBOX chkbox_016
               CAPTION 'Mesas da Pizzaria'
               COL 150
               ROW 350
               WIDTH 350
               VALUE x_opcao_016
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
            DEFINE CHECKBOX chkbox_017
               CAPTION 'Atendentes ou Garçons'
               COL 150
               ROW 380
               WIDTH 350
               VALUE x_opcao_017
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
            DEFINE CHECKBOX chkbox_018
               CAPTION 'Motoboys ou Entregadores'
               COL 150
               ROW 410
               WIDTH 350
               VALUE x_opcao_018
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
            DEFINE CHECKBOX chkbox_019
               CAPTION 'Operadores do Programa'
               COL 150
               ROW 440
               WIDTH 350
               VALUE x_opcao_019
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
         END PAGE
         page 'Relatórios' image path_imagens+'img_tres.bmp'
            DEFINE CHECKBOX chkbox_020
               CAPTION 'Fechamento do dia de trabalho'
               COL 150
               ROW 050
               WIDTH 350
               VALUE x_opcao_020
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
            DEFINE CHECKBOX chkbox_021
               CAPTION 'Movimentação do Caixa'
               COL 150
               ROW 080
               WIDTH 350
               VALUE x_opcao_021
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
            DEFINE CHECKBOX chkbox_022
               CAPTION 'Movimentação Bancária'
               COL 150
               ROW 110
               WIDTH 350
               VALUE x_opcao_022
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
            DEFINE CHECKBOX chkbox_023
               CAPTION 'Contas a Pagar por período'
               COL 150
               ROW 140
               WIDTH 350
               VALUE x_opcao_023
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
            DEFINE CHECKBOX chkbox_024
               CAPTION 'Contas a Pagar por fornecedor'
               COL 150
               ROW 170
               WIDTH 350
               VALUE x_opcao_024
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
            DEFINE CHECKBOX chkbox_025
               CAPTION 'Contas a Receber por período'
               COL 150
               ROW 200
               WIDTH 350
               VALUE x_opcao_025
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
            DEFINE CHECKBOX chkbox_026
               CAPTION 'Contas a Receber por cliente'
               COL 150
               ROW 230
               WIDTH 350
               VALUE x_opcao_026
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
            DEFINE CHECKBOX chkbox_027
               CAPTION 'Pizzas mais vendidas'
               COL 150
               ROW 260
               WIDTH 350
               VALUE x_opcao_027
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
            DEFINE CHECKBOX chkbox_028
               CAPTION 'Produtos mais vendidos'
               COL 150
               ROW 290
               WIDTH 350
               VALUE x_opcao_028
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
            DEFINE CHECKBOX chkbox_029
               CAPTION 'Relação estoque mínimo'
               COL 150
               ROW 320
               WIDTH 350
               VALUE x_opcao_029
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
            DEFINE CHECKBOX chkbox_030
               CAPTION 'Posição do estoque (produtos)'
               COL 150
               ROW 350
               WIDTH 350
               VALUE x_opcao_030
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
            DEFINE CHECKBOX chkbox_031
               CAPTION 'Posição do estoque (matéria prima)'
               COL 150
               ROW 380
               WIDTH 350
               VALUE x_opcao_031
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
            DEFINE CHECKBOX chkbox_032
               CAPTION 'Comissão Motoboys/Entregadores'
               COL 150
               ROW 410
               WIDTH 350
               VALUE x_opcao_032
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
            DEFINE CHECKBOX chkbox_033
               CAPTION 'Comissão Atendentes/Garçons'
               COL 150
               ROW 440
               WIDTH 350
               VALUE x_opcao_033
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
         END PAGE
         page 'Financeiro' image path_imagens+'img_quatro.bmp'
            DEFINE CHECKBOX chkbox_034
               CAPTION 'Movimentação do Caixa'
               COL 150
               ROW 050
               WIDTH 350
               VALUE x_opcao_034
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
            DEFINE CHECKBOX chkbox_035
               CAPTION 'Movimentação Bancária'
               COL 150
               ROW 080
               WIDTH 350
               VALUE x_opcao_035
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
            DEFINE CHECKBOX chkbox_036
               CAPTION 'Compras / Entrada Estoque'
               COL 150
               ROW 110
               WIDTH 350
               VALUE x_opcao_036
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
            DEFINE CHECKBOX chkbox_037
               CAPTION 'Contas a Pagar'
               COL 150
               ROW 140
               WIDTH 350
               VALUE x_opcao_037
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
            DEFINE CHECKBOX chkbox_038
               CAPTION 'Contas a Receber'
               COL 150
               ROW 170
               WIDTH 350
               VALUE x_opcao_038
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
         END PAGE
         page 'Ferramentas' image path_imagens+'img_cinco.bmp'
            DEFINE CHECKBOX chkbox_039
               CAPTION 'Tamanhos de Pizza'
               COL 150
               ROW 050
               WIDTH 350
               VALUE x_opcao_039
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
            DEFINE CHECKBOX chkbox_040
               CAPTION 'Cadastro da Pizzaria'
               COL 150
               ROW 080
               WIDTH 350
               VALUE x_opcao_040
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
            DEFINE CHECKBOX chkbox_041
               CAPTION 'Incluir ou Excluir Promoção'
               COL 150
               ROW 110
               WIDTH 350
               VALUE x_opcao_041
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
            DEFINE CHECKBOX chkbox_042
               CAPTION 'Reajustar Preços de Produtos'
               COL 150
               ROW 140
               WIDTH 350
               VALUE x_opcao_042
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
            DEFINE CHECKBOX chkbox_043
               CAPTION 'Backup do Banco de Dados'
               COL 150
               ROW 170
               WIDTH 350
               VALUE x_opcao_043
               FONTNAME 'verdana'
               FONTSIZE 10
               FONTBOLD .T.
               TRANSPARENT .F.
            END CHECKBOX
         END PAGE

      END TAB

      * botões
      DEFINE BUTTONEX button_ok
         PICTURE path_imagens+'img_gravar.bmp'
         COL form_acesso.width-225
         ROW form_acesso.height-085
         WIDTH 120
         HEIGHT 050
         CAPTION 'Ok, gravar'
         ACTION gravar_acesso(x_id,x_tipo)
         FONTBOLD .T.
         TOOLTIP 'Confirmar as informações selecionadas'
         flat .F.
         noxpstyle .T.
      END BUTTONEX
      DEFINE BUTTONEX button_cancela
         PICTURE path_imagens+'img_voltar.bmp'
         COL form_acesso.width-100
         ROW form_acesso.height-085
         WIDTH 090
         HEIGHT 050
         CAPTION 'Voltar'
         ACTION form_acesso.release
         FONTBOLD .T.
         TOOLTIP 'Sair desta tela sem selecionar informações'
         flat .F.
         noxpstyle .T.
      END BUTTONEX

      ON KEY ESCAPE ACTION thiswindow.release

   END WINDOW

   form_acesso.center
   form_acesso.activate

   RETURN NIL

STATIC FUNCTION gravar_acesso(parametro,tipo)

   IF tipo == 1
      dbselectarea('acesso')
      acesso->(dbappend())
      acesso->operador   := parametro
      acesso->acesso_001 := form_acesso.chkbox_001.value
      acesso->acesso_002 := form_acesso.chkbox_002.value
      acesso->acesso_003 := form_acesso.chkbox_003.value
      acesso->acesso_004 := form_acesso.chkbox_004.value
      acesso->acesso_005 := form_acesso.chkbox_005.value
      acesso->acesso_006 := form_acesso.chkbox_006.value
      acesso->acesso_007 := form_acesso.chkbox_007.value
      acesso->acesso_008 := form_acesso.chkbox_008.value
      acesso->acesso_009 := form_acesso.chkbox_009.value
      acesso->acesso_010 := form_acesso.chkbox_010.value
      acesso->acesso_011 := form_acesso.chkbox_011.value
      acesso->acesso_012 := form_acesso.chkbox_012.value
      acesso->acesso_013 := form_acesso.chkbox_013.value
      acesso->acesso_014 := form_acesso.chkbox_014.value
      acesso->acesso_015 := form_acesso.chkbox_015.value
      acesso->acesso_016 := form_acesso.chkbox_016.value
      acesso->acesso_017 := form_acesso.chkbox_017.value
      acesso->acesso_018 := form_acesso.chkbox_018.value
      acesso->acesso_019 := form_acesso.chkbox_019.value
      acesso->acesso_020 := form_acesso.chkbox_020.value
      acesso->acesso_021 := form_acesso.chkbox_021.value
      acesso->acesso_022 := form_acesso.chkbox_022.value
      acesso->acesso_023 := form_acesso.chkbox_023.value
      acesso->acesso_024 := form_acesso.chkbox_024.value
      acesso->acesso_025 := form_acesso.chkbox_025.value
      acesso->acesso_026 := form_acesso.chkbox_026.value
      acesso->acesso_027 := form_acesso.chkbox_027.value
      acesso->acesso_028 := form_acesso.chkbox_028.value
      acesso->acesso_029 := form_acesso.chkbox_029.value
      acesso->acesso_030 := form_acesso.chkbox_030.value
      acesso->acesso_031 := form_acesso.chkbox_031.value
      acesso->acesso_032 := form_acesso.chkbox_032.value
      acesso->acesso_033 := form_acesso.chkbox_033.value
      acesso->acesso_034 := form_acesso.chkbox_034.value
      acesso->acesso_035 := form_acesso.chkbox_035.value
      acesso->acesso_036 := form_acesso.chkbox_036.value
      acesso->acesso_037 := form_acesso.chkbox_037.value
      acesso->acesso_038 := form_acesso.chkbox_038.value
      acesso->acesso_039 := form_acesso.chkbox_039.value
      acesso->acesso_040 := form_acesso.chkbox_040.value
      acesso->acesso_041 := form_acesso.chkbox_041.value
      acesso->acesso_042 := form_acesso.chkbox_042.value
      acesso->acesso_043 := form_acesso.chkbox_043.value
      acesso->(dbcommit())
      acesso->(dbgotop())
      form_acesso.release
   ELSEIF tipo == 2
      dbselectarea('acesso')
      IF lock_reg()
         acesso->acesso_001 := form_acesso.chkbox_001.value
         acesso->acesso_002 := form_acesso.chkbox_002.value
         acesso->acesso_003 := form_acesso.chkbox_003.value
         acesso->acesso_004 := form_acesso.chkbox_004.value
         acesso->acesso_005 := form_acesso.chkbox_005.value
         acesso->acesso_006 := form_acesso.chkbox_006.value
         acesso->acesso_007 := form_acesso.chkbox_007.value
         acesso->acesso_008 := form_acesso.chkbox_008.value
         acesso->acesso_009 := form_acesso.chkbox_009.value
         acesso->acesso_010 := form_acesso.chkbox_010.value
         acesso->acesso_011 := form_acesso.chkbox_011.value
         acesso->acesso_012 := form_acesso.chkbox_012.value
         acesso->acesso_013 := form_acesso.chkbox_013.value
         acesso->acesso_014 := form_acesso.chkbox_014.value
         acesso->acesso_015 := form_acesso.chkbox_015.value
         acesso->acesso_016 := form_acesso.chkbox_016.value
         acesso->acesso_017 := form_acesso.chkbox_017.value
         acesso->acesso_018 := form_acesso.chkbox_018.value
         acesso->acesso_019 := form_acesso.chkbox_019.value
         acesso->acesso_020 := form_acesso.chkbox_020.value
         acesso->acesso_021 := form_acesso.chkbox_021.value
         acesso->acesso_022 := form_acesso.chkbox_022.value
         acesso->acesso_023 := form_acesso.chkbox_023.value
         acesso->acesso_024 := form_acesso.chkbox_024.value
         acesso->acesso_025 := form_acesso.chkbox_025.value
         acesso->acesso_026 := form_acesso.chkbox_026.value
         acesso->acesso_027 := form_acesso.chkbox_027.value
         acesso->acesso_028 := form_acesso.chkbox_028.value
         acesso->acesso_029 := form_acesso.chkbox_029.value
         acesso->acesso_030 := form_acesso.chkbox_030.value
         acesso->acesso_031 := form_acesso.chkbox_031.value
         acesso->acesso_032 := form_acesso.chkbox_032.value
         acesso->acesso_033 := form_acesso.chkbox_033.value
         acesso->acesso_034 := form_acesso.chkbox_034.value
         acesso->acesso_035 := form_acesso.chkbox_035.value
         acesso->acesso_036 := form_acesso.chkbox_036.value
         acesso->acesso_037 := form_acesso.chkbox_037.value
         acesso->acesso_038 := form_acesso.chkbox_038.value
         acesso->acesso_039 := form_acesso.chkbox_039.value
         acesso->acesso_040 := form_acesso.chkbox_040.value
         acesso->acesso_041 := form_acesso.chkbox_041.value
         acesso->acesso_042 := form_acesso.chkbox_042.value
         acesso->acesso_043 := form_acesso.chkbox_043.value
      ENDIF
      form_acesso.release
   ENDIF

   RETURN NIL
