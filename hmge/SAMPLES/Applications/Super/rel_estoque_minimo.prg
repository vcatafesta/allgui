/*
sistema     : superchef pizzaria
programa    : relat�rio controle do estoque m�nimo
compilador  : xharbour 1.2 simplex
lib gr�fica : minigui 1.7 extended
programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'super.ch'

FUNCTION relatorio_estoque_minimo()

   DEFINE WINDOW form_est_minimo;
         at 000,000;
         WIDTH 400;
         HEIGHT 250;
         TITLE 'Rela��o estoque m�nimo';
         ICON path_imagens+'icone.ico';
         modal;
         NOSIZE

      @ 010,010 label lbl_001;
         of form_est_minimo;
         value 'Este relat�rio ir� listar somente os produtos que';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 030,010 label lbl_002;
         of form_est_minimo;
         value 'estejam com o estoque atual igual ou abaixo do m�nimo';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 050,010 label lbl_003;
         of form_est_minimo;
         value 'cadastrado. Somente produtos que n�o sejam - pizza -';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 070,010 label lbl_004;
         of form_est_minimo;
         value 'aparecer�o no relat�rio.';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent

      * linha separadora
      DEFINE LABEL linha_rodape
         COL 000
         ROW form_est_minimo.height-090
         value ''
         WIDTH form_est_minimo.width
         HEIGHT 001
         BACKCOLOR _preto_001
         transparent .F.
      END LABEL

      * bot�es
      DEFINE BUTTONEX button_ok
         PICTURE path_imagens+'img_relatorio.bmp'
         COL form_est_minimo.width-255
         ROW form_est_minimo.height-085
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
         COL form_est_minimo.width-100
         ROW form_est_minimo.height-085
         WIDTH 090
         HEIGHT 050
         caption 'Voltar'
         action form_est_minimo.release
         fontbold .T.
         tooltip 'Sair desta tela'
         flat .F.
         noxpstyle .T.
      END BUTTONEX

      ON KEY ESCAPE ACTION thiswindow.release

   END WINDOW

   form_est_minimo.center
   form_est_minimo.activate

   RETURN NIL

STATIC FUNCTION relatorio()

   LOCAL p_linha := 040
   LOCAL u_linha := 260
   LOCAL linha   := p_linha
   LOCAL pagina  := 1

   SELECT PRINTER DIALOG PREVIEW

   START PRINTDOC NAME 'Gerenciador de impress�o'
      START PRINTPAGE

         dbselectarea('produtos')
         produtos->(ordsetfocus('nome_longo'))
         produtos->(dbgotop())

         cabecalho(pagina)

         WHILE .not. eof()

            IF produtos->qtd_estoq <= produtos->qtd_min .and. !produtos->pizza
               @ linha,010 PRINT alltrim(produtos->codigo) FONT 'courier new' SIZE 010
               @ linha,030 PRINT alltrim(produtos->nome_longo) FONT 'courier new' SIZE 010
               @ linha,090 PRINT str(produtos->qtd_min,6) FONT 'courier new' SIZE 010
               @ linha,130 PRINT str(produtos->qtd_estoq,6) FONT 'courier new' SIZE 010
               @ linha,170 PRINT str(produtos->qtd_estoq-produtos->qtd_min,6) FONT 'courier new' SIZE 010

               linha += 5

               IF linha >= u_linha
               END PRINTPAGE
               START PRINTPAGE
                  pagina ++
                  cabecalho(pagina)
                  linha := p_linha
               ENDIF
            ENDIF

            produtos->(dbskip())

         END

         rodape()

      END PRINTPAGE
   END PRINTDOC

   RETURN NIL

STATIC FUNCTION cabecalho(p_pagina)

   @ 007,010 PRINT IMAGE path_imagens+'logotipo.bmp' WIDTH 050 HEIGHT 020 STRETCH
   @ 010,070 PRINT 'RELA��O ESTOQUE M�NIMO' FONT 'courier new' SIZE 018 BOLD
   @ 024,070 PRINT 'p�gina : '+strzero(p_pagina,4) FONT 'courier new' SIZE 012

   @ 030,000 PRINT LINE TO 030,205 PENWIDTH 0.5 COLOR _preto_001

   @ 035,010 PRINT 'C�DIGO' FONT 'courier new' SIZE 010 BOLD
   @ 035,030 PRINT 'PRODUTO' FONT 'courier new' SIZE 010 BOLD
   @ 035,090 PRINT 'QTD.M�NIMA' FONT 'courier new' SIZE 010 BOLD
   @ 035,130 PRINT 'QTD.ESTOQUE' FONT 'courier new' SIZE 010 BOLD
   @ 035,170 PRINT 'QTD.ABAIXO' FONT 'courier new' SIZE 010 BOLD

   RETURN NIL

STATIC FUNCTION rodape()

   @ 275,000 PRINT LINE TO 275,205 PENWIDTH 0.5 COLOR _preto_001
   @ 276,010 PRINT 'impresso em '+dtoc(date())+' as '+time() FONT 'courier new' SIZE 008

   RETURN NIL
