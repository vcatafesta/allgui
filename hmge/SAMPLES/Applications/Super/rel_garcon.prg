/*
sistema     : superchef pizzaria
programa    : relatório comissão garçons
compilador  : xharbour 1.2 simplex
lib gráfica : minigui 1.7 extended
programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'super.ch'

FUNCTION relatorio_garcon()

   LOCAL a_001 := {}

   dbselectarea('atendentes')
   atendentes->(ordsetfocus('nome'))
   atendentes->(dbgotop())
   WHILE .not. eof()
      aadd(a_001,strzero(atendentes->codigo,4)+' - '+atendentes->nome)
      atendentes->(dbskip())
   end

   DEFINE WINDOW form_comissao_garcon;
         at 000,000;
         width 400;
         height 250;
         title 'Comissão Atendentes/Garçons';
         icon path_imagens+'icone.ico';
         modal;
         nosize

      @ 010,010 label lbl_001;
         of form_comissao_garcon;
         value 'Escolha o intervalo de datas';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 080,010 label lbl_002;
         of form_comissao_garcon;
         value 'Escolha o atendente/garçon';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent

      @ 040,010 datepicker dp_inicio;
         parent form_comissao_garcon;
         value date();
         width 150;
         height 030;
         font 'verdana' size 014
      @ 040,170 datepicker dp_final;
         parent form_comissao_garcon;
         value date();
         width 150;
         height 030;
         font 'verdana' size 014
      define comboboxex cbo_001
      row   110
      col   010
      width 310
      height 200
      items a_001
      value 1
   end comboboxex

   * linha separadora
   DEFINE LABEL linha_rodape
      col 000
      row form_comissao_garcon.height-090
      value ''
      width form_comissao_garcon.width
      height 001
      backcolor _preto_001
      transparent .F.
   END LABEL

   * botões
   DEFINE BUTTONEX button_ok
      picture path_imagens+'img_relatorio.bmp'
      col form_comissao_garcon.width-255
      row form_comissao_garcon.height-085
      width 150
      height 050
      caption 'Ok, imprimir'
      action relatorio()
      fontbold .T.
      tooltip 'Gerar o relatório'
      flat .F.
      noxpstyle .T.
   end buttonex
   DEFINE BUTTONEX button_cancela
      picture path_imagens+'img_sair.bmp'
      col form_comissao_garcon.width-100
      row form_comissao_garcon.height-085
      width 090
      height 050
      caption 'Voltar'
      action form_comissao_garcon.release
      fontbold .T.
      tooltip 'Sair desta tela'
      flat .F.
      noxpstyle .T.
   end buttonex

   on key escape action thiswindow.release

END WINDOW

form_comissao_garcon.center
form_comissao_garcon.activate

return(nil)

STATIC FUNCTION relatorio()

   LOCAL x_codigo_garcon := 0
   LOCAL x_de            := form_comissao_garcon.dp_inicio.value
   LOCAL x_ate           := form_comissao_garcon.dp_final.value
   LOCAL x_garcon        := form_comissao_garcon.cbo_001.value

   LOCAL p_linha := 046
   LOCAL u_linha := 260
   LOCAL linha   := p_linha
   LOCAL pagina  := 1

   LOCAL x_subtotal := 0
   LOCAL x_total    := 0
   LOCAL x_old_data := ctod('  /  /  ')

   x_codigo_garcon := val(substr(form_comissao_garcon.cbo_001.item(x_garcon),1,4))

   dbselectarea('comissao_mesa')
   INDEX ON dtos(data)+hora to indcatb for data >= x_de .and. data <= x_ate .and. id == x_codigo_garcon
   GO TOP

   SELECT PRINTER DIALOG PREVIEW

   START PRINTDOC NAME 'Gerenciador de impressão'
      START PRINTPAGE

         cabecalho(pagina)

         WHILE .not. eof()

            x_subtotal := x_subtotal + valor
            x_old_data := data

            @ linha,030 PRINT dtoc(data) FONT 'courier new' SIZE 010
            @ linha,060 PRINT hora FONT 'courier new' SIZE 010
            @ linha,100 PRINT trans(valor,'@E 9,999.99') FONT 'courier new' SIZE 010

            linha += 5

            IF linha >= u_linha
            END PRINTPAGE
            START PRINTPAGE
               pagina ++
               cabecalho(pagina)
               linha := p_linha
            ENDIF

            SKIP

            IF data <> x_old_data
               linha += 5
               @ linha,070 PRINT 'Subtotal Comissões : R$ '+trans(x_subtotal,'@E 9,999.99') FONT 'courier new' SIZE 010
               linha += 5
               @ linha,030 PRINT LINE TO linha,150 PENWIDTH 0.3 COLOR _preto_001
               linha += 3
               x_total := x_total + x_subtotal
               x_subtotal := 0
            ENDIF

         end

         linha += 5
         @ linha,070 PRINT 'Total COMISSÕES : R$ '+trans(x_total,'@E 9,999.99') FONT 'courier new' SIZE 010

         rodape()

      END PRINTPAGE
   END PRINTDOC

   return(nil)

STATIC FUNCTION cabecalho(p_pagina)

   LOCAL x_codigo_garcon := 0
   LOCAL x_de            := form_comissao_garcon.dp_inicio.value
   LOCAL x_ate           := form_comissao_garcon.dp_final.value
   LOCAL x_garcon        := form_comissao_garcon.cbo_001.value

   x_codigo_garcon       := val(substr(form_comissao_garcon.cbo_001.item(x_garcon),1,4))

   @ 007,010 PRINT IMAGE path_imagens+'logotipo.bmp' WIDTH 050 HEIGHT 020 STRETCH
   @ 010,070 PRINT 'COMISSÃO ATENDENTE/GARÇON' FONT 'courier new' SIZE 018 BOLD
   @ 018,070 PRINT dtoc(x_de)+' até '+dtoc(x_ate) FONT 'courier new' SIZE 014
   @ 024,070 PRINT 'De     : '+acha_atendente(x_codigo_garcon) FONT 'courier new' SIZE 012
   @ 030,070 PRINT 'página : '+strzero(p_pagina,4) FONT 'courier new' SIZE 012

   @ 036,000 PRINT LINE TO 036,205 PENWIDTH 0.5 COLOR _preto_001

   @ 041,030 PRINT 'DATA' FONT 'courier new' SIZE 010 BOLD
   @ 041,060 PRINT 'HORA' FONT 'courier new' SIZE 010 BOLD
   @ 041,100 PRINT 'VALOR R$' FONT 'courier new' SIZE 010 BOLD

   return(nil)

STATIC FUNCTION rodape()

   @ 275,000 PRINT LINE TO 275,205 PENWIDTH 0.5 COLOR _preto_001
   @ 276,010 PRINT 'impresso em '+dtoc(date())+' as '+time() FONT 'courier new' SIZE 008

   return(nil)

