/*
sistema     : superchef pizzaria
programa    : relatório posição do estoque - produtos
compilador  : xharbour 1.2 simplex
lib gráfica : minigui 1.7 extended
programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'super.ch'

FUNCTION posicao_estoque()

   DEFINE WINDOW form_estoque_produtos;
         at 000,000;
         WIDTH 400;
         HEIGHT 250;
         TITLE 'Posição do estoque (produtos)';
         ICON path_imagens+'icone.ico';
         modal;
         NOSIZE

      @ 010,010 label lbl_001;
         of form_estoque_produtos;
         VALUE 'Este relatório irá listar todos os produtos em estoque';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         transparent
      @ 030,010 label lbl_002;
         of form_estoque_produtos;
         VALUE 'mostrando a quantidade atual disponível de cada um.';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         transparent
      @ 050,010 label lbl_003;
         of form_estoque_produtos;
         VALUE 'Somente produtos que não sejam - pizza -';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         transparent
      @ 070,010 label lbl_004;
         of form_estoque_produtos;
         VALUE 'aparecerão no relatório.';
         autosize;
         font 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         transparent

      * linha separadora
      DEFINE LABEL linha_rodape
         COL 000
         ROW form_estoque_produtos.height-090
         VALUE ''
         WIDTH form_estoque_produtos.width
         HEIGHT 001
         BACKCOLOR _preto_001
         transparent .F.
      END LABEL

      * botões
      DEFINE BUTTONEX button_ok
         PICTURE path_imagens+'img_relatorio.bmp'
         COL form_estoque_produtos.width-255
         ROW form_estoque_produtos.height-085
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
         COL form_estoque_produtos.width-100
         ROW form_estoque_produtos.height-085
         WIDTH 090
         HEIGHT 050
         CAPTION 'Voltar'
         ACTION form_estoque_produtos.release
         FONTBOLD .T.
         TOOLTIP 'Sair desta tela'
         flat .F.
         noxpstyle .T.
      END BUTTONEX

      ON KEY ESCAPE ACTION thiswindow.release

   END WINDOW

   form_estoque_produtos.center
   form_estoque_produtos.activate

   RETURN NIL

STATIC FUNCTION relatorio()

   LOCAL p_linha := 040
   LOCAL u_linha := 260
   LOCAL linha   := p_linha
   LOCAL pagina  := 1

   SELECT PRINTER DIALOG PREVIEW

   START PRINTDOC NAME 'Gerenciador de impressão'
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

         END

         rodape()

      END PRINTPAGE
   END PRINTDOC

   RETURN NIL

STATIC FUNCTION cabecalho(p_pagina)

   @ 007,010 PRINT IMAGE path_imagens+'logotipo.bmp' WIDTH 050 HEIGHT 020 STRETCH
   @ 010,070 PRINT 'RELAÇÃO POSIÇÃO ESTOQUE - produtos' FONT 'courier new' SIZE 018 BOLD
   @ 024,070 PRINT 'página : '+strzero(p_pagina,4) FONT 'courier new' SIZE 012

   @ 030,000 PRINT LINE TO 030,205 PENWIDTH 0.5 COLOR _preto_001

   @ 035,020 PRINT 'CÓDIGO' FONT 'courier new' SIZE 010 BOLD
   @ 035,040 PRINT 'PRODUTO' FONT 'courier new' SIZE 010 BOLD
   @ 035,100 PRINT 'QTD.ESTOQUE' FONT 'courier new' SIZE 010 BOLD

   RETURN NIL

STATIC FUNCTION rodape()

   @ 275,000 PRINT LINE TO 275,205 PENWIDTH 0.5 COLOR _preto_001
   @ 276,010 PRINT 'impresso em '+dtoc(date())+' as '+time() FONT 'courier new' SIZE 008

   RETURN NIL
