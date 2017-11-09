/*
sistema     : superchef pizzaria
programa    : relatório movimentação bancária
compilador  : xharbour 1.2 simplex
lib gráfica : minigui 1.7 extended
programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'super.ch'

FUNCTION movimentacao_bancaria()

   LOCAL a_001 := {}

   dbselectarea('bancos')
   bancos->(ordsetfocus('nome'))
   bancos->(dbgotop())
   WHILE .not. eof()
      aadd(a_001,strzero(bancos->codigo,4)+' - '+bancos->nome)
      bancos->(dbskip())
   end

   DEFINE WINDOW form_mov_banco;
         at 000,000;
         width 400;
         height 250;
         title 'Movimentação Bancária';
         icon path_imagens+'icone.ico';
         modal;
         nosize

      @ 010,010 label lbl_001;
         of form_mov_banco;
         value 'Escolha o intervalo de datas';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 080,010 label lbl_002;
         of form_mov_banco;
         value 'Escolha o banco';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent

      @ 040,010 datepicker dp_inicio;
         parent form_mov_banco;
         value date();
         width 150;
         height 030;
         font 'verdana' size 014
      @ 040,170 datepicker dp_final;
         parent form_mov_banco;
         value date();
         width 150;
         height 030;
         font 'verdana' size 014
      DEFINE COMBOBOXex cbo_001
         row   110
         col   010
         width 310
         height 200
         items a_001
         value 1
      END COMBOBOXex

      * linha separadora
      DEFINE LABEL linha_rodape
         col 000
         row form_mov_banco.height-090
         value ''
         width form_mov_banco.width
         height 001
         backcolor _preto_001
         transparent .F.
      END LABEL

      * botões
      DEFINE BUTTONex button_ok
         picture path_imagens+'img_relatorio.bmp'
         col form_mov_banco.width-255
         row form_mov_banco.height-085
         width 150
         height 050
         caption 'Ok, imprimir'
         action relatorio()
         fontbold .T.
         tooltip 'Gerar o relatório'
         flat .F.
         noxpstyle .T.
      END BUTTONex
      DEFINE BUTTONex button_cancela
         picture path_imagens+'img_sair.bmp'
         col form_mov_banco.width-100
         row form_mov_banco.height-085
         width 090
         height 050
         caption 'Voltar'
         action form_mov_banco.release
         fontbold .T.
         tooltip 'Sair desta tela'
         flat .F.
         noxpstyle .T.
      END BUTTONex

      on key escape action thiswindow.release

   END WINDOW

   form_mov_banco.center
   form_mov_banco.activate

   RETURN(nil)

STATIC FUNCTION relatorio()

   LOCAL x_codigo_banco := 0
   LOCAL x_de           := form_mov_banco.dp_inicio.value
   LOCAL x_ate          := form_mov_banco.dp_final.value
   LOCAL x_banco        := form_mov_banco.cbo_001.value

   LOCAL p_linha := 046
   LOCAL u_linha := 260
   LOCAL linha   := p_linha
   LOCAL pagina  := 1

   LOCAL x_saldo := 0
   LOCAL x_old_data := ctod('  /  /  ')

   x_codigo_banco := val(substr(form_mov_banco.cbo_001.item(x_banco),1,4))

   dbselectarea('movimento_bancario')
   movimento_bancario->(ordsetfocus('composto'))
   movimento_bancario->(dbgotop())
   ordscope(0,str(x_codigo_banco,4)+dtos(x_de))
   ordscope(1,str(x_codigo_banco,4)+dtos(x_ate))
   movimento_bancario->(dbgotop())

   SELECT PRINTER DIALOG PREVIEW

   START PRINTDOC NAME 'Gerenciador de impressão'
      START PRINTPAGE

         cabecalho(pagina)

         WHILE .not. eof()

            x_saldo := x_saldo + movimento_bancario->entrada
            x_saldo := x_saldo - movimento_bancario->saida

            x_old_data := movimento_bancario->data

            @ linha,015 PRINT dtoc(movimento_bancario->data) FONT 'courier new' SIZE 010
            @ linha,040 PRINT movimento_bancario->historico FONT 'courier new' SIZE 010
            @ linha,100 PRINT trans(movimento_bancario->entrada,'@E 999,999.99') FONT 'courier new' SIZE 010
            @ linha,130 PRINT trans(movimento_bancario->saida,'@E 999,999.99') FONT 'courier new' SIZE 010
            @ linha,160 PRINT trans(x_saldo,'@E 999,999.99') FONT 'courier new' SIZE 010

            linha += 5

            IF linha >= u_linha
            END PRINTPAGE
            START PRINTPAGE
               pagina ++
               cabecalho(pagina)
               linha := p_linha
            ENDIF

            movimento_bancario->(dbskip())

            IF movimento_bancario->data <> x_old_data
               linha += 5
               @ linha,015 PRINT 'Saldo de '+dtoc(x_old_data)+' : R$ '+trans(x_saldo,'@E 999,999.99') FONT 'courier new' SIZE 010
               linha += 5
            ENDIF

         end

         rodape()

      END PRINTPAGE
   END PRINTDOC

   ordscope(0,0)
   ordscope(1,0)
   movimento_bancario->(dbgotop())

   RETURN(nil)

STATIC FUNCTION cabecalho(p_pagina)

   LOCAL x_codigo_banco := 0
   LOCAL x_de           := form_mov_banco.dp_inicio.value
   LOCAL x_ate          := form_mov_banco.dp_final.value
   LOCAL x_banco        := form_mov_banco.cbo_001.value

   x_codigo_banco       := val(substr(form_mov_banco.cbo_001.item(x_banco),1,4))

   @ 007,010 PRINT IMAGE path_imagens+'logotipo.bmp' WIDTH 050 HEIGHT 020 STRETCH
   @ 010,070 PRINT 'MOVIMENTAÇÃO BANCÁRIA' FONT 'courier new' SIZE 018 BOLD
   @ 018,070 PRINT dtoc(x_de)+' até '+dtoc(x_ate) FONT 'courier new' SIZE 014
   @ 024,070 PRINT 'Banco : '+acha_banco(x_codigo_banco) FONT 'courier new' SIZE 014
   @ 030,070 PRINT 'página : '+strzero(p_pagina,4) FONT 'courier new' SIZE 012

   @ 036,000 PRINT LINE TO 036,205 PENWIDTH 0.5 COLOR _preto_001

   @ 041,015 PRINT 'DATA' FONT 'courier new' SIZE 010 BOLD
   @ 041,040 PRINT 'HISTÓRICO' FONT 'courier new' SIZE 010 BOLD
   @ 041,100 PRINT 'ENTRADAS' FONT 'courier new' SIZE 010 BOLD
   @ 041,130 PRINT 'SAÍDAS' FONT 'courier new' SIZE 010 BOLD
   @ 041,160 PRINT 'SALDO' FONT 'courier new' SIZE 010 BOLD

   RETURN(nil)

STATIC FUNCTION rodape()

   @ 275,000 PRINT LINE TO 275,205 PENWIDTH 0.5 COLOR _preto_001
   @ 276,010 PRINT 'impresso em '+dtoc(date())+' as '+time() FONT 'courier new' SIZE 008

   RETURN(nil)
