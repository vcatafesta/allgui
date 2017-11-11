/*
sistema     : superchef pizzaria
programa    : relat�rio fechamento do dia
compilador  : xharbour 1.2 simplex
lib gr�fica : minigui 1.7 extended
programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'super.ch'

MEMVAR x_total_vendas
MEMVAR x_saldo
MEMVAR x_soma_dia
MEMVAR x_soma_geral
MEMVAR x_old_data
MEMVAR x_diaria
MEMVAR x_subtotal
MEMVAR x_old_id

FUNCTION fechamento_dia()

   DEFINE WINDOW form_fechamento;
         at 000,000;
         width 400;
         height 250;
         title 'Fechamento do dia de trabalho';
         icon path_imagens+'icone.ico';
         modal;
         nosize

      @ 010,010 label lbl_001;
         of form_fechamento;
         value 'Escolha o dia';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor _preto_001;
         transparent
      @ 080,010 label lbl_002;
         of form_fechamento;
         value 'Este relat�rio totaliza todas as opera��es realizadas no';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor BLUE;
         transparent
      @ 100,010 label lbl_003;
         of form_fechamento;
         value 'dia escolhido pelo usu�rio, oferecendo um mapa de';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor BLUE;
         transparent
      @ 120,010 label lbl_004;
         of form_fechamento;
         value 'informa��es muito �til.';
         autosize;
         font 'tahoma' size 010;
         bold;
         fontcolor BLUE;
         transparent

      @ 040,010 datepicker dp_data;
         parent form_fechamento;
         value date();
         width 150;
         height 030;
         font 'verdana' size 014

      * linha separadora
      DEFINE LABEL linha_rodape
         col 000
         row form_fechamento.height-090
         value ''
         width form_fechamento.width
         height 001
         backcolor _preto_001
         transparent .F.
      END LABEL

      * bot�es
      DEFINE BUTTONex button_ok
         picture path_imagens+'img_relatorio.bmp'
         col form_fechamento.width-255
         row form_fechamento.height-085
         width 150
         height 050
         caption 'Ok, imprimir'
         action relatorio()
         fontbold .T.
         tooltip 'Gerar o relat�rio'
         flat .F.
         noxpstyle .T.
      END BUTTONex
      DEFINE BUTTONex button_cancela
         picture path_imagens+'img_sair.bmp'
         col form_fechamento.width-100
         row form_fechamento.height-085
         width 090
         height 050
         caption 'Voltar'
         action form_fechamento.release
         fontbold .T.
         tooltip 'Sair desta tela'
         flat .F.
         noxpstyle .T.
      END BUTTONex

      on key escape action thiswindow.release

   END WINDOW

   form_fechamento.center
   form_fechamento.activate

   RETURN(nil)

STATIC FUNCTION relatorio()

   LOCAL x_data := form_fechamento.dp_data.value

   LOCAL p_linha := 035
   LOCAL u_linha := 260
   LOCAL linha   := p_linha
   LOCAL pagina  := 1

   SELECT PRINTER DIALOG PREVIEW

   START PRINTDOC NAME 'Gerenciador de impress�o'
      START PRINTPAGE

         cabecalho(pagina)

         *        *
         * Vendas *
         *        *

         PRIVATE x_total_vendas := 0

         dbselectarea('detalhamento_compras')
         detalhamento_compras->(ordsetfocus('data'))
         detalhamento_compras->(dbgotop())
         ordscope(0,dtos(x_data))
         ordscope(1,dtos(x_data))
         detalhamento_compras->(dbgotop())

         @ linha,010 PRINT '1 - Vendas (Delivery/Mesas/Balc�o)' FONT 'courier new' SIZE 012 BOLD

         linha += 10
         IF linha >= u_linha
         END PRINTPAGE
         START PRINTPAGE
            pagina ++
            cabecalho(pagina)
            linha := p_linha
         ENDIF

         @ linha,015 PRINT 'DATA' FONT 'courier new' SIZE 010 BOLD
         @ linha,040 PRINT 'PRODUTO' FONT 'courier new' SIZE 010 BOLD
         @ linha,100 PRINT 'QTD.' FONT 'courier new' SIZE 010 BOLD
         @ linha,130 PRINT 'UNIT�RIO R$' FONT 'courier new' SIZE 010 BOLD
         @ linha,160 PRINT 'SUBTOTAL R$' FONT 'courier new' SIZE 010 BOLD

         linha += 5
         IF linha >= u_linha
         END PRINTPAGE
         START PRINTPAGE
            pagina ++
            cabecalho(pagina)
            linha := p_linha
         ENDIF

         WHILE .not. eof()

            x_total_vendas := x_total_vendas + detalhamento_compras->subtotal

            @ linha,015 PRINT dtoc(detalhamento_compras->data) FONT 'courier new' SIZE 010
            @ linha,040 PRINT alltrim(acha_produto(detalhamento_compras->id_prod)) FONT 'courier new' SIZE 010
            @ linha,100 PRINT trans(detalhamento_compras->qtd,'@R 999999') FONT 'courier new' SIZE 010
            @ linha,130 PRINT trans(detalhamento_compras->unitario,'@E 99,999.99') FONT 'courier new' SIZE 010
            @ linha,160 PRINT trans(detalhamento_compras->subtotal,'@E 99,999.99') FONT 'courier new' SIZE 010

            linha += 5

            IF linha >= u_linha
            END PRINTPAGE
            START PRINTPAGE
               pagina ++
               cabecalho(pagina)
               linha := p_linha
            ENDIF

            detalhamento_compras->(dbskip())

         end

         @ linha,145 PRINT 'Total : R$' FONT 'courier new' SIZE 010 BOLD
         @ linha,160 PRINT trans(x_total_vendas,'@E 99,999.99') FONT 'courier new' SIZE 010 BOLD

         linha += 5
         IF linha >= u_linha
         END PRINTPAGE
         START PRINTPAGE
            pagina ++
            cabecalho(pagina)
            linha := p_linha
         ENDIF

         @ linha,000 PRINT LINE TO linha,205 PENWIDTH 0.3 COLOR _preto_001

         linha += 5
         IF linha >= u_linha
         END PRINTPAGE
         START PRINTPAGE
            pagina ++
            cabecalho(pagina)
            linha := p_linha
         ENDIF

         *                  *
         * Contas a receber *
         *                  *

         PRIVATE x_soma_dia   := 0
         PRIVATE x_soma_geral := 0
         PRIVATE x_old_data   := ctod('  /  /  ')

         dbselectarea('contas_receber')
         contas_receber->(ordsetfocus('data'))
         contas_receber->(dbgotop())
         ordscope(0,dtos(x_data))
         ordscope(1,dtos(x_data))
         contas_receber->(dbgotop())

         @ linha,010 PRINT '2 - Contas a Receber' FONT 'courier new' SIZE 012 BOLD

         linha += 10
         IF linha >= u_linha
         END PRINTPAGE
         START PRINTPAGE
            pagina ++
            cabecalho(pagina)
            linha := p_linha
         ENDIF

         @ linha,015 PRINT 'DATA' FONT 'courier new' SIZE 010 BOLD
         @ linha,040 PRINT 'CLIENTE/' FONT 'courier new' SIZE 010 BOLD
         @ linha,120 PRINT 'FORMA RECEBIMENTO/' FONT 'courier new' SIZE 010 BOLD
         @ linha,165 PRINT 'VALOR R$' FONT 'courier new' SIZE 010 BOLD
         @ linha+5,040 PRINT 'OBSERVA��O' FONT 'courier new' SIZE 010 BOLD
         @ linha+5,120 PRINT 'N�MERO' FONT 'courier new' SIZE 010 BOLD

         linha += 10
         IF linha >= u_linha
         END PRINTPAGE
         START PRINTPAGE
            pagina ++
            cabecalho(pagina)
            linha := p_linha
         ENDIF

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
               @ linha,107 PRINT 'Subtotal : R$ ' FONT 'courier new' SIZE 010 BOLD
               @ linha,160 PRINT trans(x_soma_dia,'@E 999,999.99') FONT 'courier new' SIZE 010 BOLD
               x_soma_geral := x_soma_geral + x_soma_dia
               x_soma_dia   := 0
               linha += 5
               IF linha >= u_linha
               END PRINTPAGE
               START PRINTPAGE
                  pagina ++
                  cabecalho(pagina)
                  linha := p_linha
               ENDIF
            ENDIF

         end

         @ linha,090 PRINT 'Total do per�odo : R$ ' FONT 'courier new' SIZE 010 BOLD
         @ linha,160 PRINT trans(x_soma_geral,'@E 999,999.99') FONT 'courier new' SIZE 010 BOLD

         linha += 5
         IF linha >= u_linha
         END PRINTPAGE
         START PRINTPAGE
            pagina ++
            cabecalho(pagina)
            linha := p_linha
         ENDIF

         @ linha,000 PRINT LINE TO linha,205 PENWIDTH 0.3 COLOR _preto_001

         linha += 5
         IF linha >= u_linha
         END PRINTPAGE
         START PRINTPAGE
            pagina ++
            cabecalho(pagina)
            linha := p_linha
         ENDIF

         *                 *
         * Movimento Caixa *
         *                 *

         PRIVATE x_saldo := 0

         dbselectarea('caixa')
         caixa->(ordsetfocus('data'))
         caixa->(dbgotop())
         ordscope(0,dtos(x_data))
         ordscope(1,dtos(x_data))
         caixa->(dbgotop())

         @ linha,010 PRINT '3 - Movimento do Caixa' FONT 'courier new' SIZE 012 BOLD

         linha += 10
         IF linha >= u_linha
         END PRINTPAGE
         START PRINTPAGE
            pagina ++
            cabecalho(pagina)
            linha := p_linha
         ENDIF

         @ linha,015 PRINT 'DATA' FONT 'courier new' SIZE 010 BOLD
         @ linha,040 PRINT 'HIST�RICO' FONT 'courier new' SIZE 010 BOLD
         @ linha,100 PRINT 'ENTRADAS' FONT 'courier new' SIZE 010 BOLD
         @ linha,130 PRINT 'SA�DAS' FONT 'courier new' SIZE 010 BOLD
         @ linha,160 PRINT 'SALDO' FONT 'courier new' SIZE 010 BOLD

         linha += 5
         IF linha >= u_linha
         END PRINTPAGE
         START PRINTPAGE
            pagina ++
            cabecalho(pagina)
            linha := p_linha
         ENDIF

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
               IF linha >= u_linha
               END PRINTPAGE
               START PRINTPAGE
                  pagina ++
                  cabecalho(pagina)
                  linha := p_linha
               ENDIF
            ENDIF

         end

         @ linha,000 PRINT LINE TO linha,205 PENWIDTH 0.3 COLOR _preto_001

         linha += 5
         IF linha >= u_linha
         END PRINTPAGE
         START PRINTPAGE
            pagina ++
            cabecalho(pagina)
            linha := p_linha
         ENDIF

         *                *
         * Contas a pagar *
         *                *

         PRIVATE x_soma_dia   := 0
         PRIVATE x_soma_geral := 0
         PRIVATE x_old_data   := ctod('  /  /  ')

         dbselectarea('contas_pagar')
         contas_pagar->(ordsetfocus('data'))
         contas_pagar->(dbgotop())
         ordscope(0,dtos(x_data))
         ordscope(1,dtos(x_data))
         contas_pagar->(dbgotop())

         @ linha,010 PRINT '4 - Contas a Pagar' FONT 'courier new' SIZE 012 BOLD

         linha += 10
         IF linha >= u_linha
         END PRINTPAGE
         START PRINTPAGE
            pagina ++
            cabecalho(pagina)
            linha := p_linha
         ENDIF

         @ linha,015 PRINT 'DATA' FONT 'courier new' SIZE 010 BOLD
         @ linha,040 PRINT 'FORNECEDOR/' FONT 'courier new' SIZE 010 BOLD
         @ linha,120 PRINT 'FORMA PAGAMENTO/' FONT 'courier new' SIZE 010 BOLD
         @ linha,165 PRINT 'VALOR R$' FONT 'courier new' SIZE 010 BOLD
         @ linha+5,040 PRINT 'OBSERVA��O' FONT 'courier new' SIZE 010 BOLD
         @ linha+5,120 PRINT 'N�MERO' FONT 'courier new' SIZE 010 BOLD

         linha += 10
         IF linha >= u_linha
         END PRINTPAGE
         START PRINTPAGE
            pagina ++
            cabecalho(pagina)
            linha := p_linha
         ENDIF

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
               @ linha,107 PRINT 'Subtotal : R$ ' FONT 'courier new' SIZE 010 BOLD
               @ linha,160 PRINT trans(x_soma_dia,'@E 999,999.99') FONT 'courier new' SIZE 010 BOLD
               x_soma_geral := x_soma_geral + x_soma_dia
               x_soma_dia   := 0
               linha += 5
               IF linha >= u_linha
               END PRINTPAGE
               START PRINTPAGE
                  pagina ++
                  cabecalho(pagina)
                  linha := p_linha
               ENDIF
            ENDIF

         end

         @ linha,090 PRINT 'Total do per�odo : R$ ' FONT 'courier new' SIZE 010 BOLD
         @ linha,160 PRINT trans(x_soma_geral,'@E 999,999.99') FONT 'courier new' SIZE 010 BOLD

         linha += 5
         IF linha >= u_linha
         END PRINTPAGE
         START PRINTPAGE
            pagina ++
            cabecalho(pagina)
            linha := p_linha
         ENDIF

         @ linha,000 PRINT LINE TO linha,205 PENWIDTH 0.3 COLOR _preto_001

         linha += 5
         IF linha >= u_linha
         END PRINTPAGE
         START PRINTPAGE
            pagina ++
            cabecalho(pagina)
            linha := p_linha
         ENDIF

         *                   *
         * Comiss�o motoboys *
         *                   *

         PRIVATE x_diaria   := 0
         PRIVATE x_subtotal := 0
         PRIVATE x_old_id   := 0

         @ linha,010 PRINT '5 - Comiss�o Motoboys/Entregadores' FONT 'courier new' SIZE 012 BOLD

         linha += 10
         IF linha >= u_linha
         END PRINTPAGE
         START PRINTPAGE
            pagina ++
            cabecalho(pagina)
            linha := p_linha
         ENDIF

         dbselectarea('comissao')
         INDEX ON id to indcxtb for data == x_data
         GO TOP

         @ linha,030 PRINT 'DATA' FONT 'courier new' SIZE 010 BOLD
         @ linha,060 PRINT 'HORA' FONT 'courier new' SIZE 010 BOLD
         @ linha,100 PRINT 'VALOR R$' FONT 'courier new' SIZE 010 BOLD

         linha += 5
         IF linha >= u_linha
         END PRINTPAGE
         START PRINTPAGE
            pagina ++
            cabecalho(pagina)
            linha := p_linha
         ENDIF

         WHILE .not. eof()

            x_old_id   := id
            x_subtotal := x_subtotal + valor

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

            IF id <> x_old_id
               dbselectarea('motoboys')
               motoboys->(ordsetfocus('codigo'))
               motoboys->(dbgotop())
               motoboys->(dbseek(x_old_id))
               IF found()
                  x_diaria := motoboys->diaria
               ENDIF
               dbselectarea('comissao')
               @ linha,070 PRINT 'Nome         : '+alltrim(acha_motoboy(x_old_id)) FONT 'courier new' SIZE 010 BOLD
               linha += 5
               IF linha >= u_linha
               END PRINTPAGE
               START PRINTPAGE
                  pagina ++
                  cabecalho(pagina)
                  linha := p_linha
               ENDIF
               @ linha,070 PRINT 'Valor Di�ria : R$ '+trans(x_diaria,'@E 9,999.99') FONT 'courier new' SIZE 010 BOLD
               linha += 5
               IF linha >= u_linha
               END PRINTPAGE
               START PRINTPAGE
                  pagina ++
                  cabecalho(pagina)
                  linha := p_linha
               ENDIF
               @ linha,070 PRINT 'Comiss�es    : R$ '+trans(x_subtotal,'@E 9,999.99') FONT 'courier new' SIZE 010 BOLD
               linha += 5
               IF linha >= u_linha
               END PRINTPAGE
               START PRINTPAGE
                  pagina ++
                  cabecalho(pagina)
                  linha := p_linha
               ENDIF
               @ linha,070 PRINT 'Total do dia : R$ '+trans(x_diaria+x_subtotal,'@E 9,999.99') FONT 'courier new' SIZE 010 BOLD
               linha += 10
               IF linha >= u_linha
               END PRINTPAGE
               START PRINTPAGE
                  pagina ++
                  cabecalho(pagina)
                  linha := p_linha
               ENDIF
               x_diaria   := 0
               x_subtotal := 0
            ENDIF

         end

         linha += 5
         IF linha >= u_linha
         END PRINTPAGE
         START PRINTPAGE
            pagina ++
            cabecalho(pagina)
            linha := p_linha
         ENDIF

         @ linha,000 PRINT LINE TO linha,205 PENWIDTH 0.3 COLOR _preto_001

         linha += 5
         IF linha >= u_linha
         END PRINTPAGE
         START PRINTPAGE
            pagina ++
            cabecalho(pagina)
            linha := p_linha
         ENDIF

         *                  *
         * Comiss�o gar�ons *
         *                  *

         PRIVATE x_subtotal := 0
         PRIVATE x_old_id   := 0

         @ linha,010 PRINT '6 - Comiss�o Atendentes/Gar�ons' FONT 'courier new' SIZE 012 BOLD

         linha += 10
         IF linha >= u_linha
         END PRINTPAGE
         START PRINTPAGE
            pagina ++
            cabecalho(pagina)
            linha := p_linha
         ENDIF

         dbselectarea('comissao_mesa')
         INDEX ON id to indcytb for data == x_data
         GO TOP

         @ linha,030 PRINT 'DATA' FONT 'courier new' SIZE 010 BOLD
         @ linha,060 PRINT 'HORA' FONT 'courier new' SIZE 010 BOLD
         @ linha,100 PRINT 'VALOR R$' FONT 'courier new' SIZE 010 BOLD

         linha += 5
         IF linha >= u_linha
         END PRINTPAGE
         START PRINTPAGE
            pagina ++
            cabecalho(pagina)
            linha := p_linha
         ENDIF

         WHILE .not. eof()

            x_old_id   := id
            x_subtotal := x_subtotal + valor

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

            IF id <> x_old_id
               @ linha,070 PRINT 'Nome      : '+alltrim(acha_atendente(x_old_id)) FONT 'courier new' SIZE 010 BOLD
               linha += 5
               IF linha >= u_linha
               END PRINTPAGE
               START PRINTPAGE
                  pagina ++
                  cabecalho(pagina)
                  linha := p_linha
               ENDIF
               @ linha,070 PRINT 'Comiss�es : R$ '+trans(x_subtotal,'@E 9,999.99') FONT 'courier new' SIZE 010 BOLD
               linha += 10
               IF linha >= u_linha
               END PRINTPAGE
               START PRINTPAGE
                  pagina ++
                  cabecalho(pagina)
                  linha := p_linha
               ENDIF
               x_subtotal := 0
            ENDIF

         end

         linha += 5
         IF linha >= u_linha
         END PRINTPAGE
         START PRINTPAGE
            pagina ++
            cabecalho(pagina)
            linha := p_linha
         ENDIF

         @ linha,000 PRINT LINE TO linha,205 PENWIDTH 0.3 COLOR _preto_001

         linha += 5
         IF linha >= u_linha
         END PRINTPAGE
         START PRINTPAGE
            pagina ++
            cabecalho(pagina)
            linha := p_linha
         ENDIF

         * FINAL

         rodape()

      END PRINTPAGE
   END PRINTDOC

   RETURN(nil)

STATIC FUNCTION cabecalho(p_pagina)

   LOCAL x_data := form_fechamento.dp_data.value

   @ 007,010 PRINT IMAGE path_imagens+'logotipo.bmp' WIDTH 050 HEIGHT 020 STRETCH
   @ 010,070 PRINT 'FECHAMENTO DO DIA' FONT 'courier new' SIZE 018 BOLD
   @ 018,070 PRINT 'Dia    : '+dtoc(x_data) FONT 'courier new' SIZE 012 BOLD
   @ 024,070 PRINT 'p�gina : '+strzero(p_pagina,4) FONT 'courier new' SIZE 012

   @ 030,000 PRINT LINE TO 030,205 PENWIDTH 0.5 COLOR _preto_001

   RETURN(nil)

STATIC FUNCTION rodape()

   @ 275,000 PRINT LINE TO 275,205 PENWIDTH 0.5 COLOR _preto_001
   @ 276,010 PRINT 'impresso em '+dtoc(date())+' as '+time() FONT 'courier new' SIZE 008

   RETURN(nil)

