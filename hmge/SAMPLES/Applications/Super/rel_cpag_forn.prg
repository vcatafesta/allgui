/*
sistema     : superchef pizzaria
programa    : relatório movimentação contas a pagar - por fornecedor
compilador  : xharbour 1.2 simplex
lib gráfica : minigui 1.7 extended
programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'super.ch'

FUNCTION relatorio_cpag_002()

   LOCAL a_001 := {}

   dbselectarea('fornecedores')
   fornecedores->(ordsetfocus('nome'))
   fornecedores->(dbgotop())
   WHILE .not. eof()
      aadd(a_001,strzero(fornecedores->codigo,6)+' - '+fornecedores->nome)
      fornecedores->(dbskip())
   END

   DEFINE WINDOW form_mov_cpag_forn;
         at 000,000;
         WIDTH 400;
         HEIGHT 250;
         TITLE 'Contas a Pagar por fornecedor';
         ICON path_imagens+'icone.ico';
         modal;
         NOSIZE

      @ 010,010 label lbl_001;
         of form_mov_cpag_forn;
         VALUE 'Escolha o intervalo de datas';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 080,010 label lbl_002;
         of form_mov_cpag_forn;
         VALUE 'Escolha o fornecedor';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT

      @ 040,010 datepicker dp_inicio;
         parent form_mov_cpag_forn;
         VALUE date();
         WIDTH 150;
         HEIGHT 030;
         font 'verdana' size 014
      @ 040,170 datepicker dp_final;
         parent form_mov_cpag_forn;
         VALUE date();
         WIDTH 150;
         HEIGHT 030;
         font 'verdana' size 014
      define comboboxex cbo_001
      ROW   110
      COL   010
      WIDTH 310
      HEIGHT 200
      ITEMS a_001
      VALUE 1
   END comboboxex

   * linha separadora
   DEFINE LABEL linha_rodape
      COL 000
      ROW form_mov_cpag_forn.height-090
      VALUE ''
      WIDTH form_mov_cpag_forn.width
      HEIGHT 001
      BACKCOLOR _preto_001
      TRANSPARENT .F.
   END LABEL

   * botões
   DEFINE BUTTONEX button_ok
      PICTURE path_imagens+'img_relatorio.bmp'
      COL form_mov_cpag_forn.width-255
      ROW form_mov_cpag_forn.height-085
      WIDTH 150
      HEIGHT 050
      CAPTION 'Ok, imprimir'
      ACTION relatorio()
      FONTBOLD .T.
      TOOLTIP 'Gerar o relatório'
      flat .F.
      noxpstyle .T.
   END BUTTONEX
   DEFINE BUTTONEX button_cancela
      PICTURE path_imagens+'img_sair.bmp'
      COL form_mov_cpag_forn.width-100
      ROW form_mov_cpag_forn.height-085
      WIDTH 090
      HEIGHT 050
      CAPTION 'Voltar'
      ACTION form_mov_cpag_forn.release
      FONTBOLD .T.
      TOOLTIP 'Sair desta tela'
      flat .F.
      noxpstyle .T.
   END BUTTONEX

   ON KEY ESCAPE ACTION thiswindow.release

END WINDOW

form_mov_cpag_forn.center
form_mov_cpag_forn.activate

RETURN NIL

STATIC FUNCTION relatorio()

   LOCAL x_codigo_fornecedor := 0
   LOCAL x_de                := form_mov_cpag_forn.dp_inicio.value
   LOCAL x_ate               := form_mov_cpag_forn.dp_final.value
   LOCAL x_fornecedor        := form_mov_cpag_forn.cbo_001.value

   LOCAL p_linha := 051
   LOCAL u_linha := 260
   LOCAL linha   := p_linha
   LOCAL pagina  := 1

   LOCAL x_soma_dia   := 0
   LOCAL x_soma_geral := 0
   LOCAL x_old_data   := ctod('  /  /  ')

   x_codigo_fornecedor := val(substr(form_mov_cpag_forn.cbo_001.item(x_fornecedor),1,6))

   dbselectarea('contas_pagar')
   contas_pagar->(ordsetfocus('composto'))
   contas_pagar->(dbgotop())
   ordscope(0,str(x_codigo_fornecedor,6)+dtos(x_de))
   ordscope(1,str(x_codigo_fornecedor,6)+dtos(x_ate))
   contas_pagar->(dbgotop())

   SELECT PRINTER DIALOG PREVIEW

   START PRINTDOC NAME 'Gerenciador de impressão'
      START PRINTPAGE

         cabecalho(pagina)

         WHILE .not. eof()

            x_old_data := contas_pagar->data
            x_soma_dia := x_soma_dia + contas_pagar->valor

            @ linha,015 PRINT dtoc(contas_pagar->data) FONT 'courier new' SIZE 010
            @ linha,040 PRINT acha_fornecedor(contas_pagar->fornec) FONT 'courier new' SIZE 010
            @ linha,120 PRINT acha_forma_pagamento(contas_pagar->forma) FONT 'courier new' SIZE 010
            @ linha,160 PRINT trans(contas_pagar->valor,'@E 999,999.99') FONT 'courier new' SIZE 010

            linha += 5

            IF linha >= u_linha
            END PRINTPAGE
            START PRINTPAGE
               pagina ++
               cabecalho(pagina)
               linha := p_linha
            ENDIF

            @ linha,040 PRINT alltrim(contas_pagar->obs) FONT 'courier new' SIZE 010
            @ linha,120 PRINT alltrim(contas_pagar->numero) FONT 'courier new' SIZE 010

            linha += 5

            IF linha >= u_linha
            END PRINTPAGE
            START PRINTPAGE
               pagina ++
               cabecalho(pagina)
               linha := p_linha
            ENDIF

            contas_pagar->(dbskip())

            IF contas_pagar->data <> x_old_data
               @ linha,100 PRINT 'Subtotal : R$ ' FONT 'courier new' SIZE 010 BOLD
               @ linha,160 PRINT trans(x_soma_dia,'@E 999,999.99') FONT 'courier new' SIZE 010 BOLD
               x_soma_geral := x_soma_geral + x_soma_dia
               x_soma_dia   := 0
               linha += 5
            ENDIF

         END

         @ linha,090 PRINT 'Total do período : R$ ' FONT 'courier new' SIZE 010 BOLD
         @ linha,160 PRINT trans(x_soma_geral,'@E 999,999.99') FONT 'courier new' SIZE 010 BOLD

         rodape()

      END PRINTPAGE
   END PRINTDOC

   ordscope(0,0)
   ordscope(1,0)
   contas_pagar->(dbgotop())

   RETURN NIL

STATIC FUNCTION cabecalho(p_pagina)

   LOCAL x_de                := form_mov_cpag_forn.dp_inicio.value
   LOCAL x_ate               := form_mov_cpag_forn.dp_final.value
   LOCAL x_codigo_fornecedor := 0
   LOCAL x_fornecedor        := form_mov_cpag_forn.cbo_001.value

   x_codigo_fornecedor       := val(substr(form_mov_cpag_forn.cbo_001.item(x_fornecedor),1,6))

   @ 007,010 PRINT IMAGE path_imagens+'logotipo.bmp' WIDTH 050 HEIGHT 020 STRETCH
   @ 010,070 PRINT 'CONTAS A PAGAR - PERÍODO' FONT 'courier new' SIZE 018 BOLD
   @ 018,070 PRINT dtoc(x_de)+' até '+dtoc(x_ate) FONT 'courier new' SIZE 014
   @ 024,070 PRINT 'Fornecedor : '+acha_fornecedor(x_codigo_fornecedor) FONT 'courier new' SIZE 014
   @ 030,070 PRINT 'página     : '+strzero(p_pagina,4) FONT 'courier new' SIZE 012

   @ 036,000 PRINT LINE TO 036,205 PENWIDTH 0.5 COLOR _preto_001

   @ 041,015 PRINT 'DATA' FONT 'courier new' SIZE 010 BOLD
   @ 041,040 PRINT 'FORNECEDOR/' FONT 'courier new' SIZE 010 BOLD
   @ 041,120 PRINT 'FORMA PAGAMENTO/' FONT 'courier new' SIZE 010 BOLD
   @ 041,160 PRINT 'VALOR R$' FONT 'courier new' SIZE 010 BOLD
   @ 046,040 PRINT 'OBSERVAÇÃO' FONT 'courier new' SIZE 010 BOLD
   @ 046,120 PRINT 'NÚMERO' FONT 'courier new' SIZE 010 BOLD

   RETURN NIL

STATIC FUNCTION rodape()

   @ 275,000 PRINT LINE TO 275,205 PENWIDTH 0.5 COLOR _preto_001
   @ 276,010 PRINT 'impresso em '+dtoc(date())+' as '+time() FONT 'courier new' SIZE 008

   RETURN NIL
