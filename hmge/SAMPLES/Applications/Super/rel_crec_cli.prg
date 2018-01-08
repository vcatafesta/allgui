/*
sistema     : superchef pizzaria
programa    : relat�rio movimenta��o contas a receber - por cliente
compilador  : xharbour 1.2 simplex
lib gr�fica : minigui 1.7 extended
programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'super.ch'

FUNCTION relatorio_crec_002()

   LOCAL a_001 := {}

   dbselectarea('clientes')
   clientes->(ordsetfocus('nome'))
   clientes->(dbgotop())
   WHILE .not. eof()
      aadd(a_001,strzero(clientes->codigo,6)+' - '+clientes->nome)
      clientes->(dbskip())
   END

   DEFINE WINDOW form_mov_crec_cli;
         at 000,000;
         WIDTH 400;
         HEIGHT 250;
         TITLE 'Contas a Receber por cliente';
         ICON path_imagens+'icone.ico';
         modal;
         NOSIZE

      @ 010,010 label lbl_001;
         of form_mov_crec_cli;
         VALUE 'Escolha o intervalo de datas';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         transparent
      @ 080,010 label lbl_002;
         of form_mov_crec_cli;
         VALUE 'Escolha o cliente';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         transparent

      @ 040,010 datepicker dp_inicio;
         parent form_mov_crec_cli;
         VALUE date();
         WIDTH 150;
         HEIGHT 030;
         font 'verdana' size 014
      @ 040,170 datepicker dp_final;
         parent form_mov_crec_cli;
         VALUE date();
         WIDTH 150;
         HEIGHT 030;
         font 'verdana' size 014
      define comboboxex cbo_001
      ROW   110
      COL   010
      WIDTH 310
      HEIGHT 200
      items a_001
      VALUE 1
   END comboboxex

   * linha separadora
   DEFINE LABEL linha_rodape
      COL 000
      ROW form_mov_crec_cli.height-090
      VALUE ''
      WIDTH form_mov_crec_cli.width
      HEIGHT 001
      BACKCOLOR _preto_001
      transparent .F.
   END LABEL

   * bot�es
   DEFINE BUTTONEX button_ok
      PICTURE path_imagens+'img_relatorio.bmp'
      COL form_mov_crec_cli.width-255
      ROW form_mov_crec_cli.height-085
      WIDTH 150
      HEIGHT 050
      CAPTION 'Ok, imprimir'
      ACTION relatorio()
      FONTBOLD .T.
      TOOLTIP 'Gerar o relat�rio'
      flat .F.
      noxpstyle .T.
   END BUTTONEX
   DEFINE BUTTONEX button_cancela
      PICTURE path_imagens+'img_sair.bmp'
      COL form_mov_crec_cli.width-100
      ROW form_mov_crec_cli.height-085
      WIDTH 090
      HEIGHT 050
      CAPTION 'Voltar'
      ACTION form_mov_crec_cli.release
      FONTBOLD .T.
      TOOLTIP 'Sair desta tela'
      flat .F.
      noxpstyle .T.
   END BUTTONEX

   ON KEY ESCAPE ACTION thiswindow.release

END WINDOW

form_mov_crec_cli.center
form_mov_crec_cli.activate

RETURN NIL

STATIC FUNCTION relatorio()

   LOCAL x_codigo_cliente := 0
   LOCAL x_de             := form_mov_crec_cli.dp_inicio.value
   LOCAL x_ate            := form_mov_crec_cli.dp_final.value
   LOCAL x_cliente        := form_mov_crec_cli.cbo_001.value

   LOCAL p_linha := 051
   LOCAL u_linha := 260
   LOCAL linha   := p_linha
   LOCAL pagina  := 1

   LOCAL x_soma_dia   := 0
   LOCAL x_soma_geral := 0
   LOCAL x_old_data   := ctod('  /  /  ')

   x_codigo_cliente := val(substr(form_mov_crec_cli.cbo_001.item(x_cliente),1,6))

   dbselectarea('contas_receber')
   contas_receber->(ordsetfocus('composto'))
   contas_receber->(dbgotop())
   ordscope(0,str(x_codigo_cliente,6)+dtos(x_de))
   ordscope(1,str(x_codigo_cliente,6)+dtos(x_ate))
   contas_receber->(dbgotop())

   SELECT PRINTER DIALOG PREVIEW

   START PRINTDOC NAME 'Gerenciador de impress�o'
      START PRINTPAGE

         cabecalho(pagina)

         WHILE .not. eof()

            x_old_data := contas_receber->data
            x_soma_dia := x_soma_dia + contas_receber->valor

            @ linha,015 PRINT dtoc(contas_receber->data) FONT 'courier new' SIZE 010
            @ linha,040 PRINT acha_cliente(contas_receber->cliente) FONT 'courier new' SIZE 010
            @ linha,120 PRINT acha_forma_recebimento(contas_receber->forma) FONT 'courier new' SIZE 010
            @ linha,160 PRINT trans(contas_receber->valor,'@E 999,999.99') FONT 'courier new' SIZE 010

            linha += 5

            IF linha >= u_linha
            END PRINTPAGE
            START PRINTPAGE
               pagina ++
               cabecalho(pagina)
               linha := p_linha
            ENDIF

            @ linha,040 PRINT alltrim(contas_receber->obs) FONT 'courier new' SIZE 010
            @ linha,120 PRINT alltrim(contas_receber->numero) FONT 'courier new' SIZE 010

            linha += 5

            IF linha >= u_linha
            END PRINTPAGE
            START PRINTPAGE
               pagina ++
               cabecalho(pagina)
               linha := p_linha
            ENDIF

            contas_receber->(dbskip())

            IF contas_receber->data <> x_old_data
               @ linha,100 PRINT 'Subtotal : R$ ' FONT 'courier new' SIZE 010 BOLD
               @ linha,160 PRINT trans(x_soma_dia,'@E 999,999.99') FONT 'courier new' SIZE 010 BOLD
               x_soma_geral := x_soma_geral + x_soma_dia
               x_soma_dia   := 0
               linha += 5
            ENDIF

         END

         @ linha,090 PRINT 'Total do per�odo : R$ ' FONT 'courier new' SIZE 010 BOLD
         @ linha,160 PRINT trans(x_soma_geral,'@E 999,999.99') FONT 'courier new' SIZE 010 BOLD

         rodape()

      END PRINTPAGE
   END PRINTDOC

   ordscope(0,0)
   ordscope(1,0)
   contas_receber->(dbgotop())

   RETURN NIL

STATIC FUNCTION cabecalho(p_pagina)

   LOCAL x_de             := form_mov_crec_cli.dp_inicio.value
   LOCAL x_ate            := form_mov_crec_cli.dp_final.value
   LOCAL x_codigo_cliente := 0
   LOCAL x_cliente        := form_mov_crec_cli.cbo_001.value

   x_codigo_cliente       := val(substr(form_mov_crec_cli.cbo_001.item(x_cliente),1,6))

   @ 007,010 PRINT IMAGE path_imagens+'logotipo.bmp' WIDTH 050 HEIGHT 020 STRETCH
   @ 010,070 PRINT 'CONTAS A RECEBER - PER�ODO' FONT 'courier new' SIZE 018 BOLD
   @ 018,070 PRINT dtoc(x_de)+' at� '+dtoc(x_ate) FONT 'courier new' SIZE 014
   @ 024,070 PRINT 'Cliente : '+acha_cliente(x_codigo_cliente) FONT 'courier new' SIZE 014
   @ 030,070 PRINT 'p�gina  : '+strzero(p_pagina,4) FONT 'courier new' SIZE 012

   @ 036,000 PRINT LINE TO 036,205 PENWIDTH 0.5 COLOR _preto_001

   @ 041,015 PRINT 'DATA' FONT 'courier new' SIZE 010 BOLD
   @ 041,040 PRINT 'CLIENTE/' FONT 'courier new' SIZE 010 BOLD
   @ 041,120 PRINT 'FORMA RECEBIMENTO/' FONT 'courier new' SIZE 010 BOLD
   @ 041,160 PRINT 'VALOR R$' FONT 'courier new' SIZE 010 BOLD
   @ 046,040 PRINT 'OBSERVA��O' FONT 'courier new' SIZE 010 BOLD
   @ 046,120 PRINT 'N�MERO' FONT 'courier new' SIZE 010 BOLD

   RETURN NIL

STATIC FUNCTION rodape()

   @ 275,000 PRINT LINE TO 275,205 PENWIDTH 0.5 COLOR _preto_001
   @ 276,010 PRINT 'impresso em '+dtoc(date())+' as '+time() FONT 'courier new' SIZE 008

   RETURN NIL
