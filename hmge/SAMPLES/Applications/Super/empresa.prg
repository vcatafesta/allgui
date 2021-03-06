/*
sistema     : superchef pizzaria
programa    : cadastro da empresa
compilador  : xharbour 1.2 simplex
lib gr�fica : minigui 1.7 extended
programador : marcelo neves
*/

#include 'minigui.ch'
#include 'super.ch'

FUNCTION empresa()

   LOCAL x_nome     := ''
   LOCAL x_fixo_1   := ''
   LOCAL x_fixo_2   := ''
   LOCAL x_endereco := ''
   LOCAL x_numero   := ''
   LOCAL x_complem  := ''
   LOCAL x_bairro   := ''
   LOCAL x_cidade   := ''
   LOCAL x_uf       := 'PR'
   LOCAL x_cep      := ''
   LOCAL x_email    := ''
   LOCAL x_site     := ''

   dbselectarea('empresa')
   empresa->(dbgotop())
   x_nome     := empresa->nome
   x_fixo_1   := empresa->fixo_1
   x_fixo_2   := empresa->fixo_2
   x_endereco := empresa->endereco
   x_numero   := empresa->numero
   x_complem  := empresa->complem
   x_bairro   := empresa->bairro
   x_cidade   := empresa->cidade
   x_uf       := empresa->uf
   x_cep      := empresa->cep
   x_email    := empresa->email
   x_site     := empresa->site

   DEFINE WINDOW form_empresa ;
         at 000,000 ;
         WIDTH 585 ;
         HEIGHT 380 ;
         TITLE 'Cadastro da Pizzaria' ;
         ICON path_imagens+'icone.ico' ;
         modal ;
         NOSIZE

      * entrada de dados
      @ 010,005 label lbl_001 ;
         of form_empresa ;
         VALUE 'Nome' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 030,005 getbox tbox_001 ;
         of form_empresa ;
         HEIGHT 027 ;
         WIDTH 310 ;
         VALUE x_nome ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         PICTURE '@!'
      @ 010,325 label lbl_002 ;
         of form_empresa ;
         VALUE 'Telefone (1)' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 030,325 getbox tbox_002 ;
         of form_empresa ;
         HEIGHT 027 ;
         WIDTH 120 ;
         VALUE x_fixo_1 ;
         FONT 'verdana' size 012 ;
         bold ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         PICTURE '@!'
      @ 010,455 label lbl_003 ;
         of form_empresa ;
         VALUE 'Telefone (2)' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 030,455 getbox tbox_003 ;
         of form_empresa ;
         HEIGHT 027 ;
         WIDTH 120 ;
         VALUE x_fixo_2 ;
         FONT 'verdana' size 012 ;
         bold ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         PICTURE '@!'
      @ 060,005 label lbl_004 ;
         of form_empresa ;
         VALUE 'Endere�o' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 080,005 getbox tbox_004 ;
         of form_empresa ;
         HEIGHT 027 ;
         WIDTH 310 ;
         VALUE x_endereco ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         PICTURE '@!'
      @ 060,325 label lbl_005 ;
         of form_empresa ;
         VALUE 'N�mero' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 080,325 getbox tbox_005 ;
         of form_empresa ;
         HEIGHT 027 ;
         WIDTH 060 ;
         VALUE x_numero ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         PICTURE '@!'
      @ 060,395 label lbl_006 ;
         of form_empresa ;
         VALUE 'Complemento' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 080,395 getbox tbox_006 ;
         of form_empresa ;
         HEIGHT 027 ;
         WIDTH 180 ;
         VALUE x_complem ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         PICTURE '@!'
      @ 110,005 label lbl_007 ;
         of form_empresa ;
         VALUE 'Bairro' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 130,005 getbox tbox_007 ;
         of form_empresa ;
         HEIGHT 027 ;
         WIDTH 180 ;
         VALUE x_bairro ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         PICTURE '@!'
      @ 110,195 label lbl_008 ;
         of form_empresa ;
         VALUE 'Cidade' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 130,195 getbox tbox_008 ;
         of form_empresa ;
         HEIGHT 027 ;
         WIDTH 180 ;
         VALUE x_cidade ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         PICTURE '@!'
      @ 110,385 label lbl_009 ;
         of form_empresa ;
         VALUE 'UF' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 130,385 getbox tbox_009 ;
         of form_empresa ;
         HEIGHT 027 ;
         WIDTH 040 ;
         VALUE x_uf ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         PICTURE '@!'
      @ 110,435 label lbl_010 ;
         of form_empresa ;
         VALUE 'CEP' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 130,435 getbox tbox_010 ;
         of form_empresa ;
         HEIGHT 027 ;
         WIDTH 080 ;
         VALUE x_cep ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1 ;
         PICTURE '@!'
      @ 160,005 label lbl_011 ;
         of form_empresa ;
         VALUE 'e-mail' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 180,005 getbox tbox_011 ;
         of form_empresa ;
         HEIGHT 027 ;
         WIDTH 450 ;
         VALUE x_email ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1
      @ 210,005 label lbl_012 ;
         of form_empresa ;
         VALUE 'site' ;
         autosize ;
         FONT 'tahoma' size 010 ;
         bold ;
         FONTCOLOR _preto_001 ;
         TRANSPARENT
      @ 230,005 getbox tbox_012 ;
         of form_empresa ;
         HEIGHT 027 ;
         WIDTH 450 ;
         VALUE x_site ;
         FONT 'tahoma' size 010 ;
         BACKCOLOR _fundo_get ;
         FONTCOLOR _letra_get_1

      * linha separadora
      DEFINE LABEL linha_rodape
         COL 000
         ROW form_empresa.height-090
         VALUE ''
         WIDTH form_empresa.width
         HEIGHT 001
         BACKCOLOR _preto_001
         TRANSPARENT .F.
      END LABEL

      * bot�es
      DEFINE BUTTONEX button_ok
         PICTURE path_imagens+'img_gravar.bmp'
         COL form_empresa.width-225
         ROW form_empresa.height-085
         WIDTH 120
         HEIGHT 050
         CAPTION 'Ok, gravar'
         ACTION gravar()
         FONTBOLD .T.
         TOOLTIP 'Confirmar as informa��es digitadas'
         flat .F.
         noxpstyle .T.
      END BUTTONEX
      DEFINE BUTTONEX button_cancela
         PICTURE path_imagens+'img_voltar.bmp'
         COL form_empresa.width-100
         ROW form_empresa.height-085
         WIDTH 090
         HEIGHT 050
         CAPTION 'Voltar'
         ACTION form_empresa.release
         FONTBOLD .T.
         TOOLTIP 'Sair desta tela sem gravar informa��es'
         flat .F.
         noxpstyle .T.
      END BUTTONEX

      ON KEY ESCAPE ACTION thiswindow.release

   END WINDOW

   form_empresa.center
   form_empresa.activate

   RETURN NIL

STATIC FUNCTION gravar()

   IF lock_reg()
      empresa->nome     := form_empresa.tbox_001.value
      empresa->fixo_1   := form_empresa.tbox_002.value
      empresa->fixo_2   := form_empresa.tbox_003.value
      empresa->endereco := form_empresa.tbox_004.value
      empresa->numero   := form_empresa.tbox_005.value
      empresa->complem  := form_empresa.tbox_006.value
      empresa->bairro   := form_empresa.tbox_007.value
      empresa->cidade   := form_empresa.tbox_008.value
      empresa->uf       := form_empresa.tbox_009.value
      empresa->cep      := form_empresa.tbox_010.value
      empresa->email    := form_empresa.tbox_011.value
      empresa->site     := form_empresa.tbox_012.value
      empresa->(dbcommit())
      empresa->(dbunlock())
      empresa->(dbgotop())
   ENDIF

   form_empresa.release

   RETURN NIL
