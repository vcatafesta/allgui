/*
sistema     : superchef pizzaria
programa    : relatório produtos mais vendidas - por período
compilador  : xharbour 1.2 simplex
lib gráfica : minigui 1.7 extended
programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'super.ch'

MEMVAR x_nome_pizza
MEMVAR x_old_pizza

FUNCTION relatorio_produto_001()

   LOCAL a_001 := {}

   dbselectarea('produtos')
   produtos->(ordsetfocus('nome'))
   produtos->(dbgotop())
   aadd(a_001,'TODOS OS PRODUTOS - menos pizzas')
   WHILE .not. eof()
      IF !produtos->pizza
         aadd(a_001,produtos->nome_longo)
      ENDIF
      produtos->(dbskip())
   end

   DEFINE WINDOW form_pizzas_001;
         at 000,000;
         width 400;
         height 250;
         title 'Produtos mais vendidas';
         icon path_imagens+'icone.ico';
         modal;
         nosize

      @ 010,010 label lbl_001;
         of form_pizzas_001;
         value 'Escolha o intervalo de datas';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 080,010 label lbl_002;
         of form_pizzas_001;
         value 'Escolha o produto';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent

      @ 040,010 datepicker dp_inicio;
         parent form_pizzas_001;
         value date();
         width 150;
         height 030;
         font 'verdana' size 014
      @ 040,170 datepicker dp_final;
         parent form_pizzas_001;
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
      row form_pizzas_001.height-090
      value ''
      width form_pizzas_001.width
      height 001
      backcolor _preto_001
      transparent .F.
   END LABEL

   * botões
   DEFINE BUTTONEX button_ok
      picture path_imagens+'img_relatorio.bmp'
      col form_pizzas_001.width-255
      row form_pizzas_001.height-085
      width 150
      height 050
      caption 'Ok, imprimir'
      action relatorio()
      fontbold .T.
      tooltip 'Gerar o relatório'
      flat .F.
      noxpstyle .T.
   END BUTTONex
   DEFINE BUTTONEX button_cancela
      picture path_imagens+'img_sair.bmp'
      col form_pizzas_001.width-100
      row form_pizzas_001.height-085
      width 090
      height 050
      caption 'Voltar'
      action form_pizzas_001.release
      fontbold .T.
      tooltip 'Sair desta tela'
      flat .F.
      noxpstyle .T.
   END BUTTONex

   on key escape action thiswindow.release

END WINDOW

form_pizzas_001.center
form_pizzas_001.activate

RETURN(nil)

STATIC FUNCTION relatorio()

   LOCAL x_de    := form_pizzas_001.dp_inicio.value
   LOCAL x_ate   := form_pizzas_001.dp_final.value
   LOCAL x_pizza := form_pizzas_001.cbo_001.value

   LOCAL p_linha := 051
   LOCAL u_linha := 260
   LOCAL linha   := p_linha
   LOCAL pagina  := 1

   LOCAL x_soma_qtd := 0
   LOCAL x_codigo_produto := space(10)

   x_nome_pizza := alltrim(form_pizzas_001.cbo_001.item(x_pizza))

   dbselectarea('tmp_pizza_relatorio')
   ZAP
   PACK

   dbselectarea('produtos')
   produtos->(ordsetfocus('nome_longo'))
   produtos->(dbgotop())
   produtos->(dbseek(x_nome_pizza))
   IF found()
      x_codigo_produto := produtos->codigo
   ENDIF

   SELECT PRINTER DIALOG PREVIEW

   START PRINTDOC NAME 'Gerenciador de impressão'
      START PRINTPAGE

         cabecalho(pagina)

         IF x_pizza == 1 //todas
            dbselectarea('detalhamento_compras')
            INDEX ON id_prod to indp001 for data >= x_de .and. data <= x_ate .and. qtd <> 0
            GO TOP
            x_old_pizza := space(10)
            x_soma_qtd  := 0
            WHILE .not. eof()

               x_old_pizza := detalhamento_compras->id_prod
               x_soma_qtd  := x_soma_qtd + detalhamento_compras->qtd

               detalhamento_compras->(dbskip())

               IF detalhamento_compras->id_prod <> x_old_pizza
                  dbselectarea('tmp_pizza_relatorio')
                  APPEND BLANK
                  REPLACE produto with acha_produto(x_old_pizza)
                  REPLACE qtd with x_soma_qtd
                  dbselectarea('detalhamento_compras')
                  x_soma_qtd := 0
               ENDIF
            end
            dbselectarea('tmp_pizza_relatorio')
            INDEX ON qtd to indp002 descend
            GO TOP
            WHILE .not. eof()

               @ linha,020 PRINT tmp_pizza_relatorio->produto FONT 'courier new' SIZE 010
               @ linha,105 PRINT strzero(tmp_pizza_relatorio->qtd,6) FONT 'courier new' SIZE 010

               tmp_pizza_relatorio->(dbskip())

               linha += 5

               IF linha >= u_linha
               END PRINTPAGE
               START PRINTPAGE
                  pagina ++
                  cabecalho(pagina)
                  linha := p_linha
               ENDIF
            end
         ELSE
            dbselectarea('detalhamento_compras')
            INDEX ON id_prod to indp001 for data >= x_de .and. data <= x_ate .and. qtd <> 0
            GO TOP
            x_old_pizza := space(10)
            x_soma_qtd  := 0
            WHILE .not. eof()

               x_old_pizza := detalhamento_compras->id_prod
               x_soma_qtd  := x_soma_qtd + detalhamento_compras->qtd

               detalhamento_compras->(dbskip())

               IF detalhamento_compras->id_prod <> x_old_pizza
                  dbselectarea('tmp_pizza_relatorio')
                  APPEND BLANK
                  REPLACE produto with acha_produto(x_old_pizza)
                  REPLACE qtd with x_soma_qtd
                  dbselectarea('detalhamento_compras')
                  x_soma_qtd := 0
               ENDIF
            end
            dbselectarea('tmp_pizza_relatorio')
            INDEX ON qtd to indp002 for alltrim(produto) == alltrim(x_nome_pizza)
            GO TOP
            WHILE .not. eof()

               @ linha,020 PRINT tmp_pizza_relatorio->produto FONT 'courier new' SIZE 010
               @ linha,105 PRINT strzero(tmp_pizza_relatorio->qtd,6) FONT 'courier new' SIZE 010

               tmp_pizza_relatorio->(dbskip())

               linha += 5

               IF linha >= u_linha
               END PRINTPAGE
               START PRINTPAGE
                  pagina ++
                  cabecalho(pagina)
                  linha := p_linha
               ENDIF
            end
         ENDIF

         rodape()

      END PRINTPAGE
   END PRINTDOC

   RETURN(nil)

STATIC FUNCTION cabecalho(p_pagina)

   LOCAL x_de    := form_pizzas_001.dp_inicio.value
   LOCAL x_ate   := form_pizzas_001.dp_final.value
   LOCAL x_pizza := form_pizzas_001.cbo_001.value

   x_nome_pizza  := alltrim(form_pizzas_001.cbo_001.item(x_pizza))

   @ 007,010 PRINT IMAGE path_imagens+'logotipo.bmp' WIDTH 050 HEIGHT 020 STRETCH
   @ 010,070 PRINT 'PRODUTOS MAIS VENDIDOS' FONT 'courier new' SIZE 018 BOLD
   @ 018,070 PRINT dtoc(x_de)+' até '+dtoc(x_ate) FONT 'courier new' SIZE 014
   IF x_pizza == 1 //todas
      @ 024,070 PRINT 'Produto : TODOS' FONT 'courier new' SIZE 014
   ELSE
      @ 024,070 PRINT 'Produto : '+x_nome_pizza FONT 'courier new' SIZE 014
   ENDIF
   @ 030,070 PRINT 'página : '+strzero(p_pagina,4) FONT 'courier new' SIZE 012

   @ 036,000 PRINT LINE TO 036,205 PENWIDTH 0.5 COLOR _preto_001

   @ 041,020 PRINT 'PRODUTO' FONT 'courier new' SIZE 010 BOLD
   @ 041,100 PRINT 'QUANTIDADE' FONT 'courier new' SIZE 010 BOLD

   RETURN(nil)

STATIC FUNCTION rodape()

   @ 275,000 PRINT LINE TO 275,205 PENWIDTH 0.5 COLOR _preto_001
   @ 276,010 PRINT 'impresso em '+dtoc(date())+' as '+time() FONT 'courier new' SIZE 008

   RETURN(nil)

