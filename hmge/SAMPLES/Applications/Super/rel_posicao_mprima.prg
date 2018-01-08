/*
sistema     : superchef pizzaria
programa    : relatório posição do estoque - matéria prima
compilador  : xharbour 1.2 simplex
lib gráfica : minigui 1.7 extended
programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'super.ch'

FUNCTION posicao_mprima()

   DEFINE WINDOW form_estoque_mprima;
         at 000,000;
         WIDTH 400;
         HEIGHT 250;
         TITLE 'Posição do estoque (matéria prima)';
         ICON path_imagens+'icone.ico';
         modal;
         NOSIZE

      @ 010,010 label lbl_001;
         of form_estoque_mprima;
         VALUE 'Este relatório irá listar todas as matérias primas em';
         autosize;
         FONT 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT
      @ 030,010 label lbl_002;
         of form_estoque_mprima;
         VALUE 'estoque, mostrando a quantidade atual disponível.';
         autosize;
         FONT 'tahoma' size 010;
         bold;
         FONTCOLOR _preto_001;
         TRANSPARENT

      * linha separadora
      DEFINE LABEL linha_rodape
         COL 000
         ROW form_estoque_mprima.height-090
         VALUE ''
         WIDTH form_estoque_mprima.width
         HEIGHT 001
         BACKCOLOR _preto_001
         TRANSPARENT .F.
      END LABEL

      * botões
      DEFINE BUTTONEX button_ok
         PICTURE path_imagens+'img_relatorio.bmp'
         COL form_estoque_mprima.width-255
         ROW form_estoque_mprima.height-085
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
         COL form_estoque_mprima.width-100
         ROW form_estoque_mprima.height-085
         WIDTH 090
         HEIGHT 050
         CAPTION 'Voltar'
         ACTION form_estoque_mprima.release
         FONTBOLD .T.
         TOOLTIP 'Sair desta tela'
         flat .F.
         noxpstyle .T.
      END BUTTONEX

      ON KEY ESCAPE ACTION thiswindow.release

   END WINDOW

   form_estoque_mprima.center
   form_estoque_mprima.activate

   RETURN NIL

STATIC FUNCTION relatorio()

   LOCAL p_linha := 040
   LOCAL u_linha := 260
   LOCAL linha   := p_linha
   LOCAL pagina  := 1

   SELECT PRINTER DIALOG PREVIEW

   START PRINTDOC NAME 'Gerenciador de impressão'
      START PRINTPAGE

         dbselectarea('materia_prima')
         materia_prima->(ordsetfocus('nome'))
         materia_prima->(dbgotop())

         cabecalho(pagina)

         WHILE .not. eof()

            @ linha,020 PRINT alltrim(str(materia_prima->codigo)) FONT 'courier new' SIZE 010
            @ linha,040 PRINT alltrim(materia_prima->nome) FONT 'courier new' SIZE 010
            @ linha,100 PRINT str(materia_prima->qtd,12,3) FONT 'courier new' SIZE 010
            @ linha,150 PRINT acha_unidade(materia_prima->unidade) FONT 'courier new' SIZE 010

            linha += 5

            IF linha >= u_linha
            END PRINTPAGE
            START PRINTPAGE
               pagina ++
               cabecalho(pagina)
               linha := p_linha
            ENDIF

            materia_prima->(dbskip())

         END

         rodape()

      END PRINTPAGE
   END PRINTDOC

   RETURN NIL

STATIC FUNCTION cabecalho(p_pagina)

   @ 007,010 PRINT IMAGE path_imagens+'logotipo.bmp' WIDTH 050 HEIGHT 020 STRETCH
   @ 010,070 PRINT 'RELAÇÃO POSIÇÃO ESTOQUE - m.prima' FONT 'courier new' SIZE 018 BOLD
   @ 024,070 PRINT 'página : '+strzero(p_pagina,4) FONT 'courier new' SIZE 012

   @ 030,000 PRINT LINE TO 030,205 PENWIDTH 0.5 COLOR _preto_001

   @ 035,020 PRINT 'CÓDIGO' FONT 'courier new' SIZE 010 BOLD
   @ 035,040 PRINT 'PRODUTO' FONT 'courier new' SIZE 010 BOLD
   @ 035,100 PRINT 'QUANTIDADE ESTOQUE' FONT 'courier new' SIZE 010 BOLD
   @ 035,150 PRINT 'UNIDADE' FONT 'courier new' SIZE 010 BOLD

   RETURN NIL

STATIC FUNCTION rodape()

   @ 275,000 PRINT LINE TO 275,205 PENWIDTH 0.5 COLOR _preto_001
   @ 276,010 PRINT 'impresso em '+dtoc(date())+' as '+time() FONT 'courier new' SIZE 008

   RETURN NIL
