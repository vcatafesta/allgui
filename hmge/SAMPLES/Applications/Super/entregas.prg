/*
sistema     : superchef pizzaria
programa    : entregas
compilador  : xharbour 1.2 simplex
lib gráfica : minigui 1.7 extended
programador : marcelo neves
*/

#include 'minigui.ch'
#include 'super.ch'

FUNCTION mostra_entregas()

   DEFINE WINDOW form_entrega;
         at 000,000;
         WIDTH getdesktopwidth();
         HEIGHT getdesktopheight();
         TITLE 'Acompanhamento dos pedidos feitos em : venda delivery e : venda balcão';
         ICON path_imagens+'icone.ico';
         modal

      @ 005,005 browse grid_entrega;
         parent form_entrega;
         WIDTH getdesktopwidth()-015;
         HEIGHT getdesktopheight()-125;
         HEADERS {'Situação','Telefone','Cliente','Endereço','Hora','Origem','Motoboy','Taxa R$'};
         WIDTHS {120,080,220,220,080,080,100,080};
         WORKAREA entrega;
         FIELDS {'entrega->situacao','entrega->telefone','entrega->cliente','entrega->endereco','entrega->hora','entrega->origem','entrega->motoboy','trans(entrega->vlr_taxa,"@E 999.99")'};
         VALUE 1;
         font 'tahoma' size 010;
         bold;
         BACKCOLOR _acompanhamento;
         FONTCOLOR BLUE

      * botões
      @ getdesktopheight()-110,005 buttonex botao_f5;
         parent form_entrega;
         CAPTION 'F5 - Escolher motoboy/entregador';
         WIDTH 280 height 040;
         PICTURE path_imagens+'img_motent.bmp';
         font 'tahoma' size 010;
         bold;
         ACTION escolher_motoboy()
      @ getdesktopheight()-110,295 buttonex botao_f6;
         parent form_entrega;
         CAPTION 'F6 - Mudar situação do pedido';
         WIDTH 260 height 040;
         PICTURE path_imagens+'img_situacao.bmp';
         font 'tahoma' size 010;
         bold;
         ACTION mudar_situacao()
      @ getdesktopheight()-110,565 buttonex botao_f9;
         parent form_entrega;
         CAPTION 'F9 - Atualizar pedidos';
         WIDTH 210 height 040;
         PICTURE path_imagens+'img_atualiza.bmp';
         font 'tahoma' size 010;
         bold;
         ACTION atualizar_pedidos()
      @ getdesktopheight()-110,785 buttonex botao_esc;
         parent form_entrega;
         CAPTION 'ESC - Sair desta tela';
         WIDTH 200 height 040;
         PICTURE path_imagens+'img_sair.bmp';
         font 'tahoma' size 010;
         bold;
         ACTION form_entrega.release

      ON KEY F5 ACTION escolher_motoboy()
      ON KEY F6 ACTION mudar_situacao()
      on key F9 action atualizar_pedidos()
      ON KEY ESCAPE ACTION thiswindow.release

   END WINDOW

   form_entrega.maximize
   form_entrega.activate

   RETURN NIL

STATIC FUNCTION escolher_motoboy()

   dbselectarea('motoboys')
   motoboys->(dbgotop())

   DEFINE WINDOW form_escolhe;
         at 000,000;
         WIDTH 400;
         HEIGHT 400;
         TITLE 'Escolher Motoboy/Entregador';
         ICON path_imagens+'icone.ico';
         modal;
         NOSIZE

      DEFINE LABEL info_001
         parent form_escolhe
         COL 010
         ROW 005
         VALUE 'Duplo clique ou ENTER escolhe motoboy'
         AUTOSIZE .T.
         FONTNAME 'tahoma'
         FONTSIZE 010
         FONTBOLD .T.
         FONTCOLOR _preto_001
         TRANSPARENT .T.
      END LABEL
      DEFINE LABEL info_002
         parent form_escolhe
         COL 010
         ROW 025
         VALUE 'ESC fecha esta janela'
         AUTOSIZE .T.
         FONTNAME 'tahoma'
         FONTSIZE 010
         FONTBOLD .T.
         FONTCOLOR _vermelho_002
         TRANSPARENT .T.
      END LABEL
      @ 005,290 button btn_sair;
         parent form_escolhe;
         CAPTION 'Sair';
         ACTION form_escolhe.release;
         WIDTH 100;
         HEIGHT 030

      @ 045,010 browse browse_escolhe;
         of form_escolhe;
         WIDTH 375;
         HEIGHT 310;
         HEADERS {'ID','Motoboy/Entregador'};
         WIDTHS {1,320};
         WORKAREA motoboys;
         FIELDS {'motoboys->codigo','motoboys->nome'};
         VALUE 1;
         font 'verdana';
         size 010;
         BACKCOLOR _branco_001;
         FONTCOLOR BLUE;
         ON DBLCLICK grava_motoboy(motoboys->codigo,alltrim(motoboys->nome))

      ON KEY ESCAPE ACTION form_escolhe.release

   END WINDOW

   form_escolhe.center
   form_escolhe.activate

   RETURN NIL

STATIC FUNCTION grava_motoboy(p_codigo,p_nome)

   dbselectarea('entrega')
   IF lock_reg()
      REPLACE cod_moto with p_codigo
      REPLACE motoboy with p_nome
      COMMIT
      entrega->(dbunlock())
      form_escolhe.release
      form_entrega.grid_entrega.refresh
   ELSE
      msginfo('Não foi possível selecionar a informação, tecle ENTER','Atenção')

      RETURN NIL
   ENDIF

   RETURN NIL

STATIC FUNCTION mudar_situacao()

   DEFINE WINDOW form_situacao;
         at 000,000;
         WIDTH 400;
         HEIGHT 400;
         TITLE 'Mudar situação do pedido';
         ICON path_imagens+'icone.ico';
         modal;
         NOSIZE

      DEFINE LABEL info_001
         parent form_situacao
         COL 010
         ROW 005
         VALUE 'Duplo clique ou ENTER escolhe situação'
         AUTOSIZE .T.
         FONTNAME 'tahoma'
         FONTSIZE 010
         FONTBOLD .T.
         FONTCOLOR _preto_001
         TRANSPARENT .T.
      END LABEL
      DEFINE LABEL info_002
         parent form_situacao
         COL 010
         ROW 025
         VALUE 'ESC fecha esta janela'
         AUTOSIZE .T.
         FONTNAME 'tahoma'
         FONTSIZE 010
         FONTBOLD .T.
         FONTCOLOR _vermelho_002
         TRANSPARENT .T.
      END LABEL
      @ 005,290 button btn_sair;
         parent form_situacao;
         CAPTION 'Sair';
         ACTION form_situacao.release;
         WIDTH 100;
         HEIGHT 030

      ON KEY ESCAPE ACTION form_situacao.release

      @ 45,10 grid grid_situacao;
         of form_situacao;
         WIDTH 375;
         HEIGHT 310;
         HEADERS {'Situações'};
         WIDTHS {320};
         FONTCOLOR BLUE;
         ON DBLCLICK grava_situacao()

   END WINDOW

   mostra_situacao()

   form_situacao.center
   form_situacao.activate

   RETURN NIL

STATIC FUNCTION mostra_situacao()

   LOCAL i := 0
   LOCAL n_tamanho := len(a_situacao)

   DELETE item all from grid_situacao of form_situacao

   FOR i := 1 to n_tamanho
      add item {a_situacao[i]} to grid_situacao of form_situacao
   NEXT

   RETURN NIL

STATIC FUNCTION grava_situacao()

   LOCAL x_nome := alltrim(valor_coluna('grid_situacao','form_situacao',1))

   dbselectarea('entrega')
   IF lock_reg()
      REPLACE situacao with x_nome
      COMMIT
      entrega->(dbunlock())
      form_situacao.release
      form_entrega.grid_entrega.refresh
   ELSE
      msginfo('Não foi possível selecionar a informação, tecle ENTER','Atenção')

      RETURN NIL
   ENDIF

   RETURN NIL

STATIC FUNCTION atualizar_pedidos()

   IF msgyesno('Atualizar agora ?','Atenção')
      dbselectarea('entrega')
      entrega->(dbgotop())
      WHILE .not. eof()
         IF alltrim(entrega->situacao) == 'PEDIDO OK'
            * comissão motoboy
            dbselectarea('comissao')
            comissao->(dbappend())
            comissao->id    := entrega->cod_moto
            comissao->data  := date()
            comissao->hora  := time()
            comissao->valor := entrega->vlr_taxa
            comissao->(dbcommit())
            * apaga da listagem
            dbselectarea('entrega')
            IF lock_reg()
               entrega->(dbdelete())
               entrega->(dbunlock())
            ENDIF
         ENDIF
         entrega->(dbskip())
      END
   ENDIF

   entrega->(dbgotop())
   form_entrega.grid_entrega.refresh

   RETURN NIL
