/*
sistema     : superchef pizzaria
programa    : relat�rio movimenta��o do caixa
compilador  : xharbour 1.2 simplex
lib gr�fica : minigui 1.7 extended
programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'super.ch'

FUNCTION movimentacao_caixa()

   DEFINE WINDOW form_mov_caixa;
         at 000,000;
         WIDTH 400;
         HEIGHT 250;
         TITLE 'Movimenta��o do Caixa';
         ICON path_imagens+'icone.ico';
         modal;
         NOSIZE

      @ 010,010 label lbl_001;
         of form_mov_caixa;
         value 'Escolha o intervalo de datas';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent

      @ 040,010 datepicker dp_inicio;
         parent form_mov_caixa;
         value date();
         WIDTH 150;
         HEIGHT 030;
         font 'verdana' size 014
      @ 040,170 datepicker dp_final;
         parent form_mov_caixa;
         value date();
         WIDTH 150;
         HEIGHT 030;
         font 'verdana' size 014

      * linha separadora
      DEFINE LABEL linha_rodape
         COL 000
         ROW form_mov_caixa.height-090
         value ''
         WIDTH form_mov_caixa.width
         HEIGHT 001
         BACKCOLOR _preto_001
         transparent .F.
      END LABEL

      * bot�es
      DEFINE BUTTONEX button_ok
         PICTURE path_imagens+'img_relatorio.bmp'
         COL form_mov_caixa.width-255
         ROW form_mov_caixa.height-085
         WIDTH 150
         HEIGHT 050
         caption 'Ok, imprimir'
         action relatorio()
         fontbold .T.
         tooltip 'Gerar o relat�rio'
         flat .F.
         noxpstyle .T.
      END BUTTONEX
      DEFINE BUTTONEX button_cancela
         PICTURE path_imagens+'img_sair.bmp'
         COL form_mov_caixa.width-100
         ROW form_mov_caixa.height-085
         WIDTH 090
         HEIGHT 050
         caption 'Voltar'
         action form_mov_caixa.release
         fontbold .T.
         tooltip 'Sair desta tela'
         flat .F.
         noxpstyle .T.
      END BUTTONEX

      ON KEY ESCAPE ACTION thiswindow.release

   END WINDOW

   form_mov_caixa.center
   form_mov_caixa.activate

   RETURN NIL

STATIC FUNCTION relatorio()

   LOCAL x_de  := form_mov_caixa.dp_inicio.value
   LOCAL x_ate := form_mov_caixa.dp_final.value

   LOCAL p_linha := 040
   LOCAL u_linha := 260
   LOCAL linha   := p_linha
   LOCAL pagina  := 1

   LOCAL x_saldo := 0
   LOCAL x_old_data := ctod('  /  /  ')

   dbselectarea('caixa')
   caixa->(ordsetfocus('data'))
   caixa->(dbgotop())
   ordscope(0,dtos(x_de))
   ordscope(1,dtos(x_ate))
   caixa->(dbgotop())

   SELECT PRINTER DIALOG PREVIEW

   START PRINTDOC NAME 'Gerenciador de impress�o'
      START PRINTPAGE

         cabecalho(pagina)

         WHILE .not. eof()

            x_saldo := x_saldo + caixa->entrada
            x_saldo := x_saldo - caixa->saida

            x_old_data := caixa->data

            @ linha,015 PRINT dtoc(caixa->data) FONT 'courier new' SIZE 010
            @ linha,040 PRINT caixa->historico FONT 'courier new' SIZE 010
            @ linha,100 PRINT trans(caixa->entrada,'@E 999,999.99') FONT 'courier new' SIZE 010
            @ linha,130 PRINT trans(caixa->saida,'@E 999,999.99') FONT 'courier new' SIZE 010
            @ linha,160 PRINT trans(x_saldo,'@E 999,999.99') FONT 'courier new' SIZE 010

            linha += 5

            IF linha >= u_linha
            END PRINTPAGE
            START PRINTPAGE
               pagina ++
               cabecalho(pagina)
               linha := p_linha
            ENDIF

            caixa->(dbskip())

            IF caixa->data <> x_old_data
               linha += 5
               @ linha,015 PRINT 'Saldo de '+dtoc(x_old_data)+' : R$ '+trans(x_saldo,'@E 999,999.99') FONT 'courier new' SIZE 010
               linha += 5
            ENDIF

         END

         rodape()

      END PRINTPAGE
   END PRINTDOC

   ordscope(0,0)
   ordscope(1,0)
   caixa->(dbgotop())

   RETURN NIL

STATIC FUNCTION cabecalho(p_pagina)

   LOCAL x_de  := form_mov_caixa.dp_inicio.value
   LOCAL x_ate := form_mov_caixa.dp_final.value

   @ 007,010 PRINT IMAGE path_imagens+'logotipo.bmp' WIDTH 050 HEIGHT 020 STRETCH
   @ 010,070 PRINT 'MOVIMENTA��O DO CAIXA' FONT 'courier new' SIZE 018 BOLD
   @ 018,070 PRINT dtoc(x_de)+' at� '+dtoc(x_ate) FONT 'courier new' SIZE 014
   @ 024,070 PRINT 'p�gina : '+strzero(p_pagina,4) FONT 'courier new' SIZE 012

   @ 030,000 PRINT LINE TO 030,205 PENWIDTH 0.5 COLOR _preto_001

   @ 035,015 PRINT 'DATA' FONT 'courier new' SIZE 010 BOLD
   @ 035,040 PRINT 'HIST�RICO' FONT 'courier new' SIZE 010 BOLD
   @ 035,100 PRINT 'ENTRADAS' FONT 'courier new' SIZE 010 BOLD
   @ 035,130 PRINT 'SA�DAS' FONT 'courier new' SIZE 010 BOLD
   @ 035,160 PRINT 'SALDO' FONT 'courier new' SIZE 010 BOLD

   RETURN NIL

STATIC FUNCTION rodape()

   @ 275,000 PRINT LINE TO 275,205 PENWIDTH 0.5 COLOR _preto_001
   @ 276,010 PRINT 'impresso em '+dtoc(date())+' as '+time() FONT 'courier new' SIZE 008

   RETURN NIL
