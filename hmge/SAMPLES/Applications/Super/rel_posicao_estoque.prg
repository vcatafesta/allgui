/*
sistema     : superchef pizzaria
programa    : relat�rio posi��o do estoque - produtos
compilador  : xharbour 1.2 simplex
lib gr�fica : minigui 1.7 extended
programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'super.ch'

FUNCTION posicao_estoque()

   DEFINE WINDOW form_estoque_produtos;
         at 000,000;
         width 400;
         height 250;
         title 'Posi��o do estoque (produtos)';
         icon path_imagens+'icone.ico';
         modal;
         nosize

      @ 010,010 label lbl_001;
         of form_estoque_produtos;
         value 'Este relat�rio ir� listar todos os produtos em estoque';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 030,010 label lbl_002;
         of form_estoque_produtos;
         value 'mostrando a quantidade atual dispon�vel de cada um.';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 050,010 label lbl_003;
         of form_estoque_produtos;
         value 'Somente produtos que n�o sejam - pizza -';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 070,010 label lbl_004;
         of form_estoque_produtos;
         value 'aparecer�o no relat�rio.';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent

      * linha separadora
      DEFINE LABEL linha_rodape
         col 000
         row form_estoque_produtos.height-090
         value ''
         width form_estoque_produtos.width
         height 001
         backcolor _preto_001
         transparent .F.
      END LABEL

      * bot�es
      DEFINE BUTTONEX button_ok
         picture path_imagens+'img_relatorio.bmp'
         col form_estoque_produtos.width-255
         row form_estoque_produtos.height-085
         width 150
         height 050
         caption 'Ok, imprimir'
         action relatorio()
         fontbold .T.
         tooltip 'Gerar o relat�rio'
         flat .F.
         noxpstyle .T.
      end buttonex
      DEFINE BUTTONEX button_cancela
         picture path_imagens+'img_sair.bmp'
         col form_estoque_produtos.width-100
         row form_estoque_produtos.height-085
         width 090
         height 050
         caption 'Voltar'
         action form_estoque_produtos.release
         fontbold .T.
         tooltip 'Sair desta tela'
         flat .F.
         noxpstyle .T.
      end buttonex

      on key escape action thiswindow.release

   END WINDOW

   form_estoque_produtos.center
   form_estoque_produtos.activate

   return(nil)

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

            IF !produtos->pizza
               @ linha,020 PRINT alltrim(produtos->codigo) FONT 'courier new' SIZE 010
               @ linha,040 PRINT alltrim(produtos->nome_longo) FONT 'courier new' SIZE 010
               @ linha,100 PRINT str(produtos->qtd_estoq,6) FONT 'courier new' SIZE 010

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

         end

         rodape()

      END PRINTPAGE
   END PRINTDOC

   return(nil)

STATIC FUNCTION cabecalho(p_pagina)

   @ 007,010 PRINT IMAGE path_imagens+'logotipo.bmp' WIDTH 050 HEIGHT 020 STRETCH
   @ 010,070 PRINT 'RELA��O POSI��O ESTOQUE - produtos' FONT 'courier new' SIZE 018 BOLD
   @ 024,070 PRINT 'p�gina : '+strzero(p_pagina,4) FONT 'courier new' SIZE 012

   @ 030,000 PRINT LINE TO 030,205 PENWIDTH 0.5 COLOR _preto_001

   @ 035,020 PRINT 'C�DIGO' FONT 'courier new' SIZE 010 BOLD
   @ 035,040 PRINT 'PRODUTO' FONT 'courier new' SIZE 010 BOLD
   @ 035,100 PRINT 'QTD.ESTOQUE' FONT 'courier new' SIZE 010 BOLD

   return(nil)

STATIC FUNCTION rodape()

   @ 275,000 PRINT LINE TO 275,205 PENWIDTH 0.5 COLOR _preto_001
   @ 276,010 PRINT 'impresso em '+dtoc(date())+' as '+time() FONT 'courier new' SIZE 008

   return(nil)
