/*
* Agenda de Contatos (2)
* Humberto Fornazier - Março/2003
* hfornazier@brfree.com.br
* HMG - Harbour Win32 GUI library - Release 60
* Copyright 2002 Roberto Lopez <mail.box.hmg@gmail.com>
* http://www.hmgforum.com//
*/

#include "hmg.ch"

#define BLUE { 0, 0, 128 }

FUNCTION Main()

   LOCAL i := 0

   SET DELETED ON
   SET CENTURY ON

   PRIVATE lNovo := .F.

   AgendaOpen()

   DEFINE WINDOW Form_1   ;
         AT 0,0                ;
         WIDTH 480   ;
         HEIGHT 470  ;
         TITLE "Agenda de Contatos";
         MAIN                  ;
         ICON "AGENDA"   ;
         NOMAXIMIZE  ;
         NOSIZE      ;
         ON RELEASE Finaliza_Sistema() ;
         BACKCOLOR BLUE

      @ 010,415 Grid GIndice Of Form_1 WIDTH 48 HEIGHT 360 HEADERS {""} WIDTHS { 28 } ;
         FONT "Arial" SIZE 09 BOLD ;
         TOOLTIP "Click na Letra Desejada"  ;
         ON CLICK Pesquisa_Agenda()

      @ 010,010 GRID Grid_Agenda      ;
         WIDTH  398            ;
         HEIGHT 360            ;
         HEADERS {"Código","Nome"}    ;
         WIDTHS  {53,338}      ;
         FONT "Arial" SIZE 09  ;
         ON DBLCLICK Novo_Registro(.F.)

      @ 385,010 BUTTON Btn_Novo Of Form_1 ;
         CAPTION '&Novo'       ;
         ACTION Novo_Registro(.T.)     ;
         WIDTH 120 HEIGHT 27       ;
         FONT "Arial" SIZE 09      ;
         TOOLTIP "Novo Registro"       ;
         FLAT

      @ 385,165 BUTTON Btn_Imprimir Of Form_1 ;
         CAPTION '&Imprimir'       ;
         ACTION Imprimir()     ;
         WIDTH 120 HEIGHT 27       ;
         FONT "Arial" SIZE 09      ;
         TOOLTIP "Imprime Contatos"    ;
         FLAT

      @ 385,318 BUTTON Btn_Sair Of Form_1  ;
         CAPTION '&Sair'       ;
         ACTION Form_1.Release       ;
         WIDTH 120 HEIGHT 27     ;
         FONT "Arial" SIZE 09      ;
         TOOLTIP "Finalizar Sistema"   ;
         FLAT

      @ 418,16 ANIMATEBOX mensagem ;
         WIDTH 390      ;
         HEIGHT 20      ;
         FILE 'MSG02' AUTOPLAY

   END WINDOW
   FOR i := 1 To 26
      ADD ITEM { CHR(i+64) } TO GIndice OF Form_1
   NEXT
   MODIFY CONTROL GIndice OF Form_1 VALUE 1

   Pesquisa_Agenda()

   CENTER WINDOW   Form_1
   ACTIVATE WINDOW Form_1

   RETURN

FUNCTION Pesquisa_Agenda()

   cPesq := ValorDaColuna( "GIndice" ,  "Form_1" , 1 )

   cPesq := IIf( Empty(cPesq), "A" , cPesq )

   Agenda->(DBSetOrder(2))
   Agenda->(DBSeek(cPesq,.T.))
   DELETE ITEM ALL FROM Grid_Agenda OF Form_1
   DO WHILE ! Agenda->(Eof())
      IF Substr(Agenda->Nome,1,1) == cPesq
         ADD ITEM {Agenda->Codigo,Agenda->Nome} TO Grid_Agenda OF Form_1
      ELSE
         EXIT
      ENDIF
      Agenda->(DBSkip())
   ENDDO

   RETURN NIL

FUNCTION Novo_Registro( lNovo_Registro  )

   LOCAL cCodigo   := ""
   LOCAL cNome := ""
   LOCAL cEndereco := ""
   LOCAL cBairro   := ""
   LOCAL cCep  := ""
   LOCAL cCidade   := ""
   LOCAL cEstado   := ""
   LOCAL cFone1    := ""
   LOCAL cFone2    := ""
   LOCAL cEmail    := ""

   Form_1.Btn_Novo.Enabled := .F.
   Form_1.Btn_Sair.Enabled := .F.

   lNovo := lNovo_Registro

   IF ! lNovo
      cCodigo := ValorDaColuna( "Grid_Agenda" ,  "Form_1" , 1 )
      Agenda->(DBSetOrder(1))
      IF ! Agenda->(DBSeek( cCodigo  ))
         MsgSTOP("Registro "+cCodigo+" não localizado!!","Agenda")
         RELEASE WINDOW ALL
      ENDIF
      cNome        := AllTrim( Agenda->Nome)
      cEndereco    := AllTrim( Agenda->Endereco)
      cBairro        := AllTrim( Agenda->Bairro)
      cCep     := AllTrim( Agenda->Cep)
      cCidade  := AllTrim( Agenda->Cidade)
      cEstado  := AllTrim( Agenda->Estado)
      cFone1       := AllTrim( Agenda->Fone1)
      cFone2       := AllTrim( Agenda->Fone2)
      cEmail       := AllTrim( Agenda->EMail)
   ENDIF

   DEFINE WINDOW Form_2   ;
         AT 0,0               ;
         WIDTH 490  ;
         HEIGHT 300 ;
         TITLE "Agenda de Contatos - "+Iif( lNovo , "Novo Registro" , "Alterando Registro");
         ICON "AGENDA"  ;
         MODAL      ;
         NOSIZE     ;
         ON RELEASE  {|| Form_1.Btn_Novo.Enabled := .T. , Form_1.Btn_Sair.Enabled := .T. , Form_2.Btn_Excluir.Enabled := .T. , Agenda->(DBSetOrder(2)) , Pesquisa_Agenda() , Form_1.Grid_Agenda.SetFocus() } ;
         BACKCOLOR WHITE

      @ 10,10 LABEL Label_Codigo ;
         VALUE 'Código'     ;
         WIDTH 140       ;
         HEIGHT 30       ;
         FONT 'Arial' SIZE 09      ;
         BACKCOLOR WHITE   ;
         FONTCOLOR BLUE BOLD

      @ 40,10 LABEL Label_Nome   ;
         VALUE 'Nome'        ;
         WIDTH 140       ;
         HEIGHT 30       ;
         FONT 'Arial' SIZE 09      ;
         BACKCOLOR WHITE   ;
         FONTCOLOR BLUE BOLD

      @ 70,10 LABEL Label_Endereco   ;
         VALUE 'Endereço'       ;
         WIDTH 140       ;
         HEIGHT 30       ;
         FONT 'Arial' SIZE 09      ;
         BACKCOLOR WHITE   ;
         FONTCOLOR BLUE BOLD

      @ 100,10 LABEL Label_Bairro ;
         VALUE 'Bairro'      ;
         WIDTH 140       ;
         HEIGHT 30       ;
         FONT 'Arial' SIZE 09      ;
         BACKCOLOR WHITE   ;
         FONTCOLOR BLUE BOLD

      @ 100,360 LABEL Label_Cep       ;
         VALUE 'Cep'     ;
         WIDTH 80            ;
         HEIGHT 30       ;
         FONT 'Arial' SIZE 09      ;
         BACKCOLOR WHITE   ;
         FONTCOLOR BLUE BOLD

      @ 130,10 LABEL Label_Cidade ;
         VALUE 'Cidade'      ;
         WIDTH 140       ;
         HEIGHT 30       ;
         FONT 'Arial' SIZE 09      ;
         BACKCOLOR WHITE   ;
         FONTCOLOR BLUE BOLD

      @ 130,345 LABEL Label_Estado    ;
         VALUE 'Estado'      ;
         WIDTH 80            ;
         HEIGHT 30       ;
         FONT 'Arial' SIZE 09      ;
         BACKCOLOR WHITE   ;
         FONTCOLOR BLUE BOLD

      @ 160,10 LABEL Label_Fone1  ;
         VALUE 'Fone 1'      ;
         WIDTH 80            ;
         HEIGHT 30       ;
         FONT 'Arial' SIZE 09      ;
         BACKCOLOR WHITE   ;
         FONTCOLOR BLUE BOLD

      @ 160,346 LABEL Label_Fone2 ;
         VALUE 'Fone 2'      ;
         WIDTH 80            ;
         HEIGHT 30       ;
         FONT 'Arial' SIZE 09      ;
         BACKCOLOR WHITE   ;
         FONTCOLOR BLUE BOLD

      @ 190,10 LABEL Label_Email  ;
         VALUE 'e-mail'      ;
         WIDTH 140       ;
         HEIGHT 30       ;
         FONT 'Arial' SIZE 09      ;
         BACKCOLOR WHITE   ;
         FONTCOLOR BLUE BOLD

      @ 13,70 TEXTBOX T_Codigo       ;
         WIDTH 40           ;
         VALUE cCodigo      ;
         TOOLTIP 'Código do Contato'

      @ 43,70 TEXTBOX T_Nome      ;
         OF Form_2     ;
         WIDTH 400     ;
         VALUE cNome       ;
         TOOLTIP 'Nome do Contato' ;
         MAXLENGTH 40      ;
         UPPERCASE     ;
         ON ENTER Iif( ! Empty( Form_2.T_Nome.Value ) , Form_2.T_Endereco.SetFocus , Form_2.T_Nome.SetFocus )

      @ 73,70 TEXTBOX T_Endereco   ;
         OF Form_2      ;
         WIDTH 400        ;
         VALUE cEndereco      ;
         TOOLTIP 'Endereço do Contato';
         MAXLENGTH 40     ;
         UPPERCASE        ;
         ON GOTFOCUS Form_2.Btn_Salvar.Enabled := .T.  ;
         ON ENTER Form_2.T_Bairro.SetFocus

      @ 103,70 TEXTBOX T_Bairro     ;
         OF Form_2      ;
         WIDTH 250     ;
         VALUE cBairro     ;
         TOOLTIP 'Bairro do Contato'   ;
         MAXLENGTH 25      ;
         UPPERCASE     ;
         ON ENTER Form_2.T_Cep.SetFocus

      @ 103,390 TEXTBOX T_Cep       ;
         OF Form_2     ;
         WIDTH 80      ;
         VALUE cCep        ;
         TOOLTIP 'Cep do Contato'  ;
         MAXLENGTH 08      ;
         UPPERCASE     ;
         ON ENTER Form_2.T_Cidade.SetFocus

      @ 133,70 TEXTBOX T_Cidade     ;
         OF Form_2     ;
         WIDTH 250     ;
         VALUE cCidade     ;
         TOOLTIP 'Bairro do Contato'   ;
         MAXLENGTH 25      ;
         UPPERCASE     ;
         ON ENTER Form_2.T_Estado.SetFocus

      @ 133,390 TEXTBOX T_Estado    ;
         OF Form_2     ;
         WIDTH 30      ;
         VALUE cEstado     ;
         TOOLTIP 'Estado do Contato';
         MAXLENGTH 02      ;
         UPPERCASE     ;
         ON ENTER Form_2.T_Fone1.SetFocus

      @ 163,70 TEXTBOX T_Fone1      ;
         OF Form_2       ;
         WIDTH 110     ;
         VALUE cFone1      ;
         TOOLTIP 'Telefone do Contato';
         MAXLENGTH 10      ;
         UPPERCASE     ;
         ON ENTER Form_2.T_Fone2.SetFocus

      @ 163,390 TEXTBOX T_Fone2 ;
         OF Form_2     ;
         WIDTH 80      ;
         VALUE cFone2      ;
         TOOLTIP 'Telefone do Contato';
         MAXLENGTH 10      ;
         UPPERCASE     ;
         ON ENTER Form_2.T_Email.SetFocus

      @ 193,70 TEXTBOX T_Email      ;
         OF Form_2       ;
         WIDTH 400     ;
         VALUE cEmail      ;
         TOOLTIP 'E-mail do Contato'   ;
         MAXLENGTH 40      ;
         LOWERCASE     ;
         ON ENTER Form_2.Btn_Salvar.SetFocus

      @ 232,70 BUTTON Btn_Salvar Of Form_2   ;
         CAPTION '&Salvar'     ;
         ACTION Salvar_Registro()        ;
         WIDTH 120 HEIGHT 27     ;
         FONT "Arial" SIZE 09      ;
         TOOLTIP "Salvar Registro" ;
         FLAT

      @ 232,210  BUTTON Btn_Excluir Of Form_2   ;
         CAPTION '&Deletar'        ;
         ACTION Excluir_Registro()   ;
         WIDTH 120 HEIGHT 27     ;
         FONT "Arial" SIZE 09      ;
         TOOLTIP "Excluir Registro"    ;
         FLAT

      @ 232,346  BUTTON Btn_Cancelar Of Form_2  ;
         CAPTION '&Cancelar'       ;
         ACTION Sair_do_Form2()      ;
         WIDTH 120 HEIGHT 27     ;
         FONT "Arial" SIZE 09      ;
         TOOLTIP "Cancelar Operação" ;
         FLAT

   END WINDOW
   Form_2.T_Codigo.Enabled := .F.

   IF lNovo
      Form_2.Btn_Salvar.Enabled := .F.
      Form_2.Btn_Excluir.Enabled := .F.
   ENDIF

   CENTER WINDOW   Form_2
   ACTIVATE WINDOW Form_2

   RETURN NIL

FUNCTION Salvar_Registro()

   LOCAL ProximoCodigo := ""
   LOCAL cCodigo       := ""

   IF Empty( Form_2.T_Nome.Value )
      MsgINFO( "Nome não foi Informado!!" , "Agenda" )
      Form_2.T_Nome.SetFocus

      RETURN NIL
   ENDIF

   IF lNovo
      Agenda->(DBSetOrder(1))
      Agenda->(DBGoBottom())
      ProximoCodigo := StrZero(  Val( Agenda->Codigo ) + 1 , 4 )
      Agenda->(DBAppend())
      Agenda->Codigo := ProximoCodigo
      Agenda->Nome := Form_2.T_Nome.Value
      Agenda->Endereco := Form_2.T_Endereco.Value
      Agenda->Bairro := Form_2.T_Bairro.Value
      Agenda->Cep  := Form_2.T_Cep.Value
      Agenda->Cidade   := Form_2.T_Cidade.Value
      Agenda->Estado   := Form_2.T_Estado.Value
      Agenda->Fone1    := Form_2.T_Fone1.Value
      Agenda->Fone2    := Form_2.T_Fone2.Value
      Agenda->EMail    := Form_2.T_Email   .Value
   ELSE
      cCodigo := Form_2.T_Codigo.Value
      Agenda->(DBSetOrder(1))
      IF ! Agenda->(DBSeek( cCodigo  ))
         MsgSTOP("Registro "+cCodigo+" não localizado!!","Agenda")
         RELEASE WINDOW ALL
      ENDIF
      IF BloqueiaRegistroNaRede( "Agenda" )
         Agenda->Nome  := Form_2.T_Nome.Value
         Agenda->Endereco    := Form_2.T_Endereco.Value
         Agenda->Bairro  := Form_2.T_Bairro.Value
         Agenda->Cep       := Form_2.T_Cep.Value
         Agenda->Cidade    := Form_2.T_Cidade.Value
         Agenda->Estado    := Form_2.T_Estado.Value
         Agenda->Fone1 := Form_2.T_Fone1.Value
         Agenda->Fone2 := Form_2.T_Fone2.Value
         Agenda->EMail := Form_2.T_Email.Value
         Agenda->(DBUnlock())
      ENDIF
   ENDIF
   MsgInfo( "Registo "+Iif( lNovo , "Incluído" ,"Alterado!!" )  )
   PosicionaIndice( Left( Agenda->Nome , 1 ) )
   Pesquisa_Agenda()
   Form_2.Release

   RETURN NIL

FUNCTION Sair_do_Form2()

   Form_1.Btn_Novo.Enabled := .T.
   Form_1.Btn_Sair.Enabled := .T.
   Form_2.Btn_Excluir.Enabled := .T.
   Form_2.Release
   Agenda->(DBSetOrder(2))
   Pesquisa_Agenda()
   Form_1.Grid_Agenda.SetFocus()

   RETURN NIL

FUNCTION Excluir_Registro()

   IF MsgOkCancel ("Confirma Exclusão do Registro??", "Excluir "+AllTrim(Agenda->Nome))
      IF BloqueiaRegistroNaRede( "Agenda" )
         Agenda->(DBDelete())
         Agenda->(DBUnlock())
         MsgINFO("Registro Excluído!!","Agenda")
         Sair_do_Form2()
      ENDIF
   ENDIF
   Form_1.Grid_Agenda.SetFocus

   RETURN NIL

FUNCTION Finaliza_Sistema()

   Agenda->(DBCloseArea())

   RETURN NIL

FUNCTION AgendaOpen()

   LOCAL nArea    := Select( 'Agenda' )
   LOCAL aarq := {}
   LOCAL aDados   := {}

   IF nArea == 0
      IF ! FILE( "AGENDA.DBF" )
         Aadd( aArq , { 'CODIGO'  , 'C'   , 04    , 0 } )
         Aadd( aArq , { 'NOME '       , 'C'   , 40    , 0 } )
         Aadd( aArq , { 'ENDERECO'    , 'C'   , 40    , 0 } )
         Aadd( aArq , { 'BAIRRO'      , 'C'   , 25    , 0 } )
         Aadd( aArq , { 'CEP'         , 'C'   , 08    , 0 } )
         Aadd( aArq , { 'CIDADE'      , 'C'   , 25    , 0 } )
         Aadd( aArq , { 'ESTADO'  , 'C'   , 02    , 0 } )
         Aadd( aArq , { 'FONE1'       , 'C'   , 10    , 0 } )
         Aadd( aArq , { 'FONE2'       , 'C'   , 10    , 0 } )
         Aadd( aArq , { 'EMAIL'       , 'C'   , 40    , 0 } )
         DBCreate( "AGENDA.DBF" , aArq  )
      ENDIF
      USE AGENDA Alias Agenda new shared
      IF ! File( 'Agenda1.ntx' )
         INDEX ON Codigo to Agenda1
      ENDIF
      IF ! File( 'Agenda2.ntx' )
         INDEX ON Nome  to Agenda2
      ENDIF
      Agenda->(DBCLearIndex())
      Agenda->(DBSetIndex( 'Agenda1'))
      Agenda->(DBSetIndex( 'Agenda2'))
   ENDIF

   RETURN NIL

FUNCTION ValorDaColuna( ControlName, ParentForm , nCol )

   LOCAL aRet := {}

   IF GetControlType (ControlName,ParentForm) != "GRID"
      MsgBox( "Objeto não é um Grid!!")

      RETURN( aRet )
   ENDIF
   nCol := Iif( nCol == Nil .Or. nCol == 0 , 1 , nCol )
   aRet := GetProperty (  ParentForm  , ControlName , 'Item' , GetProperty( ParentForm , ControlName , 'Value' ) )

   RETURN( aRet[ nCol ] )

FUNCTION BloqueiaRegistroNaRede( cArea )

   DO WHILE ! (cArea)->(RLock())
      IF ! MSGRetryCancel("Registro em Uso na Rede Tenta Acesso??","Agenda")

         RETURN .F.
      ENDIF
   ENDDO

   RETURN .T.

FUNCTION PosicionaIndice(cLetra)

   LOCAL i := 0

   FOR i := 1 To 26
      IF CHR(i+64) == cLetra
         MODIFY CONTROL GIndice OF Form_1 VALUE i
      ENDIF
   NEXT
   Form_1.GIndice.SetFocus

   RETURN NIL

FUNCTION Imprimir()

   LOCAL nLinha := 0
   LOCAL i :=  0
   LOCAL cLetra := ""
   LOCAL nReg   := 0

   PRIVATE nFont := 11
   PRIVATE cArquivo := ""

   SET PRINTER TO REL.TMP
   SET PRINTER ON
   SET CONSOLE OFF

   cLetra := ValorDaColuna( "GIndice" ,  "Form_1" , 1 )

   Agenda->(DBSetOrder(2))
   Agenda->(DBSeek(cLetra,.T.))
   DO WHILE ! Agenda->(Eof())
      IF Substr(Agenda->Nome,1,1) == cLetra
         IF nLinha == 0
            ? PadC("     Agenda de Contatos",78)
            ? PadC("Contatos Cadastrados com letra "+cLetra,78)
            ? "Código  Nome"
            ? Replicate("-",78)
         ENDIF
         nLinha += 1
         nReg += 1
         ?   "  "+Agenda->Codigo +   "   "
         ?? Agenda->Nome
      ELSE
         EXIT
      ENDIF
      Agenda->(DBSkip())
   ENDDO
   ? Replicate("-",78)
   ? "Registros Impressos: "+StrZero(nReg,4)

   SET PRINTER TO
   SET PRINTER OFF
   SET CONSOLE ON

   cArquivo :=memoRead("REL.TMP")

   DEFINE WINDOW Form_3;
         At 0,0              ;
         Width 450        ;
         Height 500       ;
         Title "Contatos Cadastrados com Letra "+cLetra;
         ICON "AGENDA";
         CHILD ;
         NOSYSMENU;
         NOSIZE       ;
         BACKCOLOR WHITE

      @ 20,-1 EDITBOX Edit_1 ;
         WIDTH 460 ;
         HEIGHT 510 ;
         VALUE cArquivo ;
         TOOLTIP "Contatos Cadastrados com Letra "+cLetra ;
         MAXLENGTH 255

      @ 01,01 BUTTON Bt_Zoom_Mais  ;
         CAPTION '&Zoom(+)'             ;
         WIDTH 120 HEIGHT 17    ;
         ACTION ZoomLabel(1);
         FONT "MS Sans Serif" SIZE 09 FLAT

      @ 01,125 BUTTON Bt_Zoom_menos  ;
         CAPTION '&Zoom(-)'             ;
         WIDTH 120 HEIGHT 17    ;
         ACTION ZoomLabel(2);
         FONT "MS Sans Serif" SIZE 09 FLAT

      @ 01,321 BUTTON Sair_1  ;
         CAPTION '&Sair'             ;
         WIDTH 120 HEIGHT 17    ;
         ACTION Form_3.Release;
         FONT "MS Sans Serif" SIZE 09 FLAT

   END WINDOW
   MODIFY CONTROL Edit_1 OF Form_3 FONTSIZE nFont
   CENTER WINDOW Form_3
   ACTIVATE WINDOW Form_3

   RETURN NIL

FUNCTION ZoomLabel(nmm)

   IF nmm == 1
      nFont++
   ELSE
      nFont--
   ENDIF
   MODIFY CONTROL Edit_1 OF Form_3 FONTSIZE nFont

   RETURN NIL

