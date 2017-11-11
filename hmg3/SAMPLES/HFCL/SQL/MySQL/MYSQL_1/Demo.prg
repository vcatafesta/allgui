/*
Exemplo com Uso de xHarbour + HMG + MySql

Humberto Fornazier - Dezembro/2002
hfornazier@brfree.com.br / www.geocities.com/harbourminas

xHarbour Compiler Build 0.73.7 (SimpLex )
Copyright 1999-2002, http://www.xharbour.org http://www.harbour-project.org/

HMG - Harbour Win32 GUI library - Release 53 (2002/12/21)
Copyright 2002 Roberto Lopez <mail.box.hmg@gmail.com>
http://www.hmgforum.com//

*** Para Utilizar este exemplo é necessário que você tenha  em seu computador o MySql. ***

*/
#include "hmg.ch"
#define QUEBRA     Chr(13)+Chr(10)
#define SISTEMA     "Teste Harbour + HMG + MySql"
/*
*/

PROCEDURE Main()

   PRIVATE oServer        := Nil
   PRIVATE cHostName  := "localhost"
   PRIVATE cUser          := "root"
   PRIVATE cPassWord  := ""
   PRIVATE cDataBase   := "Cadastros"
   PRIVATE lLogin           := .F.

   DEFINE WINDOW Form_1 AT 05,05 WIDTH 640 HEIGHT 480;
         TITLE "Harbour + HMG + MySql" MAIN NOSIZE NOMINIMIZE ON INIT Login() ON RELEASE My_Fechar_Conexao_com_Base_De_Dados()

      @ 00,565 IMAGE Flag01 PICTURE "Argentina.bmp" WIDTH 32 HEIGHT 22
      @ 00,600 IMAGE Flag02 PICTURE "Brasil.bmp" WIDTH 32 HEIGHT 22

      DEFINE STATUSBAR
         STATUSITEM "www.geocities.com/harbourminas  - hfornazier@brfree.com.br"
      END STATUSBAR

      @ 100,40 LABEL Label_Info1  ;
         VALUE "*** ATENCAO ***";
         WIDTH 450 HEIGHT 27 FONT "Arial" SIZE 10 FONTCOLOR RED BOLD
      @ 130,40 LABEL Label_Info2  ;
         VALUE "Antes de Executar o Grid:";
         WIDTH 450 HEIGHT 27 FONT "Arial" SIZE 10 FONTCOLOR RED BOLD
      @ 160,40  LABEL Label_Info3  ;
         VALUE "1) Execute primeiro a opção para Conectar e Criar a base de Dados e a Tabela";
         WIDTH 500 HEIGHT 27 FONT "Arial" SIZE 10 FONTCOLOR RED BOLD
      @ 190,40  LABEL Label_Info4  ;
         VALUE "2) A Exportação pode demorar uns segundos porque irá importar 500 Registros";
         WIDTH 500 HEIGHT 27 FONT "Arial" SIZE 10 FONTCOLOR RED BOLD

      @ 355,65   FRAME Panel_Msg WIDTH 520 HEIGHT 40 OPAQUE
      @ 365,145 LABEL Label_Mensagem     ;
         VALUE "O Clipper não Morreu!!   Conheça o xHarbour & o HMG";
         WIDTH 400 HEIGHT 27 FONT "Arial" SIZE 10 FONTCOLOR WHITE BOLD

      DEFINE MAIN MENU
         POPUP "Sistema"
            ITEM "&Conecta MySql, Cria Base e Tabela, Insere Registros  " ACTION Operacoes()
            SEPARATOR
            ITEM "&Exemplo de Grid com Pesquisa                                  "  ACTION Grid_Pesquisa()
         END POPUP
         POPUP "Help"
            ITEM "&Sobre o Sistema"  ACTION  Sobre_o_Sistema()
         END POPUP
      END MENU

   END WINDOW

   Form_1.Label_info1.visible := .F.
   Form_1.Label_info2.visible := .F.
   Form_1.Label_info3.visible := .F.
   Form_1.Label_info4.visible := .F.

   CENTER    WINDOW Form_1
   ACTIVATE  WINDOW Form_1

   /*
   */

FUNCTION Grid_Pesquisa()

   DEFINE WINDOW Grid_Nomes AT 05,05 WIDTH 425 HEIGHT 460 TITLE "Nomes Cadastrados" CHILD NOSYSMENU

      @ 010,010 GRID Grid_1   WIDTH  400  HEIGHT 329 HEADERS {"Código","Nome"};
         WIDTHS  {60,333}   VALUE 1 FONT "Arial" SIZE 09 ;
         ON DBLCLICK Tela_Nomes(2)

      @ 357,011 LABEL  Label_Pesq_Generic ;
         VALUE "Pesquisa "              ;
         WIDTH 70                            ;
         HEIGHT 20                           ;
         FONT "Arial" SIZE 09

      @ 353,085 TEXTBOX cPesquisa                 ;
         WIDTH 326                              ;
         TOOLTIP "Pesquisar"                ;
         MAXLENGTH 40 UPPERCASE  ;
         ON ENTER Iif( !Empty(  Grid_Nomes.cPesquisa.Value ) , SqlPesquisa() , Grid_Nomes.cPesquisa.SetFocus )

      @ 397,011 BUTTON Bt_Novo             ;
         CAPTION '&Novo'                      ;
         ACTION Tela_Nomes(1)              ;
         FONT "MS Sans Serif" SIZE 09 FLAT

      @ 397,111 BUTTON Bt_Editar                    ;
         CAPTION '&Editar'                    ;
         ACTION Tela_Nomes(2)            ;
         FONT "MS Sans Serif" SIZE 09 FLAT

      @ 397,211 BUTTON Bt_Excluir            ;
         CAPTION 'E&xcluir'                   ;
         ACTION Deleta_Registro()         ;
         FONT "MS Sans Serif" SIZE 09 FLAT

      @ 397,311 BUTTON Bt_Sair                      ;
         CAPTION '&Sair'                      ;
         ACTION Sair_do_Grid()             ;
         FONT "MS Sans Serif" SIZE 09 FLAT

   END WINDOW

   Grid_Nomes.cPesquisa.Value := "A"
   Grid_Nomes.cPesquisa.SetFocus

   My_Abre_uma_Conexao_com_MySql()
   My_Conecta_Banco_De_Dados( "CADASTROS" )

   SqlPesquisa()

   CENTER   WINDOW Grid_Nomes
   ACTIVATE WINDOW Grid_Nomes

   RETURN NIL

   /*
   */

FUNCTION SqlPesquisa()

   LOCAL cPesquisa    := ' "'+Upper(AllTrim(   Grid_Nomes.cPesquisa.Value ))+'%" '
   LOCAL nContador     := 0
   LOCAL oRow            := {}
   LOCAL i                   := 0
   LOCAL oQuery         := ""
   LOCAL QuantMaximaDeRegistrosNoGrid := Iif( Len( cPesquisa) == 0 ,  30 , 1000000 )

   /*  Exclui todos os Dados do Grid */
   DELETE ITEM ALL FROM Grid_1 Of  Grid_Nomes

   /*  Monta Objeto Query com Selecão */
   oQuery := oServer:Query( "Select Codigo , Nome From NOMES WHERE NOME LIKE "+cPesquisa+" Order By Nome" )

   /*  Verifica se ocorreu algum erro na Pesquisa */
   IF oQuery:NetErr()
      MsgInfo("Erro de Pesquisa (Grid) (Select): " + oQuery:Error())
      RELEASE WINDOW ALL
      QUIT
   ENDIF

   FOR i := 1 To oQuery:LastRec()
      nContador += 1
      IF nContador ==  QuantMaximaDeRegistrosNoGrid
         EXIT
      ENDIF
      oRow := oQuery:GetRow(i)
      /* Adiciona Registros no Grid */
      ADD ITEM {  Str( oRow:fieldGet(1) , 8 )  , oRow:fieldGet(2)  } TO Grid_1 Of  Grid_Nomes
      oQuery:Skip(1)
   NEXT

   /*  Elimina Objeto Query */
   oQuery:Destroy()

   Grid_Nomes.cPesquisa.SetFocus

   RETURN NIL
   /*
   */

FUNCTION Sair_do_Grid()

   Grid_Nomes.Release

   RETURN NIL
   /*
   */

FUNCTION  Tela_Nomes( nOperacao )

   LOCAL pCodigo      := AllTrim( PegaValorDaColuna( "Grid_1" , "Grid_Nomes" , 1 ) )
   LOCAL cCodigo      := ""
   LOCAL cNome        := ""
   LOCAL cEndereco   := ""
   LOCAL cEMail          := ""
   LOCAL oQuery
   LOCAL oRow          := {}

   IF nOperacao == 2   && Se operacao for 2 seleciona registro na Tabela Nomes e preenche variaveis
      oQuery  := oServer:Query( "Select * From NOMES WHERE CODIGO = " + AllTrim( pCodigo )  )
      IF oQuery:NetErr()
         MsgInfo("Erro de Pesquisa (Operação) (Select): " + oQuery:Error())

         RETURN NIL
      ENDIF
      oRow          := oQuery:GetRow(1)
      cCodigo      := Str( oRow:fieldGet(1) )
      cNome        := AllTrim( oRow:fieldGet(2) )
      cEndereco  := AllTrim( oRow:fieldGet(3) )
      cEMail        := AllTrim( oRow:fieldGet(4) )
      oQuery:Destroy()
   ENDIF

   DEFINE WINDOW Form_4          ;
         AT 0,0                           ;
         WIDTH 485 HEIGHT 240 ;
         TITLE 'Operação: '+Iif( nOperacao == 1 , "Incluindo Novo registro" , "Alterando Nome: "+cNome )  ;
         NOMAXIMIZE BACKCOLOR BLUE

      @020,030 LABEL Label_Codigo             ;
         VALUE "Código"                     ;
         WIDTH 150          ;
         HEIGHT 35          ;
         FONT "Arial" SIZE 09;
         BACKCOLOR BLUE ;
         FONTCOLOR WHITE BOLD

      @055,030 LABEL Label_Nome                ;
         VALUE "Nome              "        ;
         WIDTH 120          ;
         HEIGHT 35          ;
         FONT "Arial" SIZE 09;
         BACKCOLOR BLUE ;
         FONTCOLOR WHITE BOLD

      @090,030 LABEL Label_Endereco          ;
         VALUE "Endereço         "        ;
         WIDTH 120          ;
         HEIGHT 35          ;
         FONT "Arial" SIZE 09;
         BACKCOLOR BLUE ;
         FONTCOLOR WHITE BOLD

      @125,030 LABEL Label_eMail                ;
         VALUE "e-Mail              "        ;
         WIDTH 120          ;
         HEIGHT 35          ;
         FONT "Arial" SIZE 09;
         BACKCOLOR BLUE ;
         FONTCOLOR WHITE BOLD

      @024,100 TEXTBOX p_Codigo                 ;
         HEIGHT 25                           ;
         VALUE  cCodigo                   ;
         WIDTH 50          ;
         FONT "Arial" SIZE 09              ;
         ON ENTER Iif( !Empty( Form_4.p_Codigo.Value ) , Form_4.p_Nome.SetFocus , Form_4.p_Codigo.SetFocus )

      @059,100 TEXTBOX  p_Nome                ;
         HEIGHT 25                            ;
         VALUE cNome                      ;
         WIDTH 350                           ;
         FONT "Arial" SIZE 09              ;
         ON ENTER Iif( !Empty(  Form_4.p_Nome.Value    ) ,  Form_4.p_Endereco.SetFocus  , Form_4.p_Nome.SetFocus )

      @094,100 TEXTBOX  p_Endereco           ;
         HEIGHT 25                            ;
         VALUE cEndereco                 ;
         WIDTH 350                           ;
         FONT "Arial" SIZE 09              ;
         ON ENTER  Iif( !Empty(  Form_4.p_Endereco.Value ) ,  Form_4.p_eMail.SetFocus ,  Form_4.p_Endereco.SetFocus )

      @129,100 TEXTBOX  p_eMail                ;
         HEIGHT 25                            ;
         VALUE cEMail                      ;
         WIDTH 350                           ;
         FONT "Arial" SIZE 09              ;
         ON ENTER  Iif( !Empty( Form_4.p_eMail.Value  ) ,  Form_4.Bt_Confirma.SetFocus  ,  Form_4.p_eMail.SetFocus )

      @ 165,100 BUTTON Bt_Confirma           ;
         CAPTION '&Confirma'              ;
         ACTION Grava_Registro( nOperacao )   ;
         FONT "MS Sans Serif" SIZE 09 FLAT

      @ 165,300 BUTTON Bt_Cancela               ;
         CAPTION '&Cancela'                 ;
         ACTION Form_4.Release      ;
         FONT "MS Sans Serif" SIZE 09 FLAT

   END WINDOW

   Form_4.p_Codigo.Enabled := .F.

   CENTER WINDOW Form_4
   ACTIVATE WINDOW Form_4

   RETURN NIL

   /*
   */

FUNCTION PegaValorDaColuna( xObj, xForm, nCol)

   LOCAL nPos := GetProperty  ( xForm , xObj , 'Value' )
   LOCAL aRet := GetProperty  ( xForm , xObj , 'Item' , nPos )

   RETURN aRet[nCol]
   /*
   */

FUNCTION Grava_Registro( nOperacao )

   LOCAL gCodigo     := AllTrim( PegaValorDaColuna( "Grid_1" , "Grid_Nomes" , 1 ) )
   LOCAL cCodigo     := AllTrim( Form_4.p_Codigo.Value )
   LOCAL cNome       := AllTrim( Form_4.p_Nome.Value )
   LOCAL cEndereco := AllTrim(  Form_4.p_Endereco.Value )
   LOCAL cEMail       := AllTrim(  Form_4.p_EMail.Value )
   LOCAL cQuery
   LOCAL oQuery

   msginfo(cCodigo)

   IF nOperacao == 1  && Inclusão de Registros
      cQuery := "INSERT INTO NOMES  VALUES ( '"+cCodigo+"' , '"+ AllTrim(cNome)+"' , '"+cEndereco+"' , '"+cEmail+ "' ) "
   ELSE
      cQuery := "UPDATE NOMES SET  Nome = '"+cNome+"' , Endereco = '"+cEndereco+"' , eMail = '"+cEMail+"'  WHERE CODIGO = " + AllTrim( gCodigo )
   ENDIF

   oQuery      := oQuery  :=  oServer:Query( cQuery )
   IF oQuery:NetErr()
      MsgInfo("Erro na Alteração (UpDate): " + oQuery:Error())

      RETURN NIL
   ENDIF

   oQuery:Destroy()

   MsgInfo( Iif( nOperacao == 1 , "Registro Incluído", "Registro Alterado!!" ) )

   Form_4.Release

   Grid_Nomes.cPesquisa.Value := cNome
   Grid_Nomes.cPesquisa.SetFocus

   SqlPesquisa()

   RETURN NIL

   /*
   */

FUNCTION Deleta_Registro()

   LOCAL gCodigo     := AllTrim( PegaValorDaColuna( "Grid_1" , "Grid_Nomes" , 1 ) )
   LOCAL gNome       := AllTrim( PegaValorDaColuna( "Grid_1" , "Grid_Nomes" , 2 ) )
   LOCAL cQuery
   LOCAL oQuery

   IF MsgYesNo( "Confirma Exclusão de: "+ gNome+ "??" )
      cQuery     := "DELETE FROM NOMES  WHERE CODIGO = " + AllTrim( gCodigo )
      oQuery      := oQuery  :=  oServer:Query( cQuery )
      IF oQuery:NetErr()
         MsgInfo("Erro na Exclusão (Delete): " + oQuery:Error())

         RETURN NIL
      ENDIF
      oQuery:Destroy()
      MsgInfo(  "Registro Excluído !!" )
      SqlPesquisa()
   ENDIF

   RETURN NIL
   /*
   */

FUNCTION  Login()

   DEFINE WINDOW Form_0 ;
         AT 0,0 ;
         WIDTH 280 HEIGHT 200 ;
         TITLE 'Login MySql'  NOSYSMENU BACKCOLOR BLUE

      @020,030 LABEL Label_HostName        ;
         VALUE "HostName/IP"            ;
         WIDTH 150          ;
         HEIGHT 35          ;
         FONT "Arial" SIZE 09;
         BACKCOLOR BLUE ;
         FONTCOLOR WHITE BOLD

      @055,030 LABEL Label_User                 ;
         VALUE "User                "        ;
         WIDTH 120          ;
         HEIGHT 35          ;
         FONT "Arial" SIZE 09;
         BACKCOLOR BLUE ;
         FONTCOLOR WHITE BOLD

      @090,030 LABEL Label_Password         ;
         VALUE "Password        "        ;
         WIDTH 120          ;
         HEIGHT 35          ;
         FONT "Arial" SIZE 09;
         BACKCOLOR BLUE ;
         FONTCOLOR WHITE BOLD

      @020,120 TEXTBOX p_HostName          ;
         HEIGHT 25                           ;
         VALUE cHostName               ;
         WIDTH 120          ;
         FONT "Arial" SIZE 09              ;
         ON ENTER Iif( !Empty( Form_0.p_HostName.Value ) ,  Form_0.p_User.SetFocus , Form_0.p_HostName.SetFocus )

      @055,120 TEXTBOX  p_User                  ;
         HEIGHT 25                            ;
         VALUE cUser                       ;
         WIDTH 120                           ;
         FONT "Arial" SIZE 09              ;
         ON ENTER Iif( !Empty( Form_0.p_User.Value ) , Form_0.p_Password.SetFocus , Form_0.p_user.SetFocus  )

      @090,120 TEXTBOX  p_password           ;
         VALUE cPassWord               ;
         PASSWORD                         ;
         FONT "Arial" SIZE 09             ;
         TOOLTIP "Senha de Acesso";
         ON ENTER  Iif( !Empty( Form_0.p_password.Value ) , Set_Variaveis() , Form_0.p_password.SetFocus )

      @ 130,030 BUTTON Bt_Login                 ;
         CAPTION '&Login'                  ;
         ACTION Set_Variaveis()          ;
         FONT "MS Sans Serif" SIZE 09 FLAT

      @ 130,143 BUTTON Bt_Logoff                   ;
         CAPTION '&Cancela'                 ;
         ACTION Form_1.Release     ;
         FONT "MS Sans Serif" SIZE 09 FLAT

   END WINDOW
   CENTER WINDOW Form_0
   ACTIVATE WINDOW Form_0

   /*
   */

FUNCTION Set_Variaveis()

   cHostName  := AllTrim(  Form_0.p_HostName.Value )
   cUser      := AllTrim( Form_0.p_User.Value )
   cPassWord  := AllTrim( Form_0.p_password.Value )
   *----------------------------------------------------------------------------------------------------------- Abre Conexao com MySql
   oServer := TMySQLServer():New(cHostName, cUser, cPassWord )
   *----------------------------------------------------------------------------------------------------------- Verifica se ocorreu algum erro na Conexão
   IF oServer:NetErr()
      MsGInfo("Erro de Conexão com Servidor / <TMySQLServer> " + oServer:Error(),SISTEMA )
      RELEASE WINDOW ALL
      QUIT
   ENDIF

   MsgInfo("Conexão Com Servidor MySql Completada!!",SISTEMA)

   lLogin := .T.

   Form_0.Release
   Form_1.Label_info1.visible := .T.
   Form_1.Label_info2.visible := .T.
   Form_1.Label_info3.visible := .T.
   Form_1.Label_info4.visible := .T.

   RETURN NIL

   /*
   */

FUNCTION Operacoes()

   PRIVATE cServidor         := cHostName
   PRIVATE cUsuario         := cUser
   PRIVATE cSenha           := cPassWord
   PRIVATE BaseDeDados := "CADASTROS"

   *--------------------------------------------------------------------------------------- Abre uma conexão co  MySql
   My_Abre_uma_conexao_com_MySql()
   *--------------------------------------------------------------------------------------- Cria Base de Dados CADASTROS
   My_Cria_uma_Base_De_Dados( "CADASTROS" )
   *--------------------------------------------------------------------------------------- Conecta com o Banco de Dados CADASTROS
   My_Conecta_Banco_De_Dados( "CADASTROS" )
   *--------------------------------------------------------------------------------------- Cria Tabela de NOMES na Base de Dados CADASTROS
   My_Cria_Tabela( "NOMES" )
   *--------------------------------------------------------------------------------------- Insere Registros na Tabela de Nomes usando um DBF
   Insere_Registros_na_Tabela( "NOMES" )
   *--------------------------------------------------------------------------------------- Fecha Conexao com MySql
   My_Fechar_Conexao_com_Base_De_Dados()
   *---------------------------------------------------------------------------------------- Encerra Operações

   RETURN NIL
   /*
   */

FUNCTION  My_Abre_uma_conexao_com_MySql()

   /* Verifica se já está conectado */
   IF oServer != Nil ; Return Nil ; Endif

   /* Abre Conexao com MySql  */
   oServer := TMySQLServer():New(cHostName, cUser, cPassWord )

   /* Verifica se ocorreu algum erro na Conexão */
   IF oServer:NetErr()
      MsGInfo("Erro de Conexão com Servidor / <TMySQLServer> " + oServer:Error(),SISTEMA )
      RELEASE WINDOW ALL
      QUIT
   ENDIF

   *** Obs: a Variável oServer será sempre a referência em todo o sistema para qualquer tipo de operação

   RETURN NIL
   /*
   */

FUNCTION  My_Cria_uma_Base_De_Dados( cBaseDeDados )

   LOCAL i                                           := 0
   LOCAL aBaseDeDadosExistentes      := {}

   cBaseDeDados                              := Lower(cBaseDeDados)

   /*  Verifica se esta conectado ao MySql */
   IF oServer == Nil ; MsgInfo("Conexão com MySql não foi Iniciada!!") ; Return Nil ; EndIf

   /*  Antes de criar Verifica se a Base de Dados já existe */
   aBaseDeDadosExistentes  := oServer:ListDBs()

   /*  Verifica se ocorreu algum erro */
   IF oServer:NetErr()
      MsGInfo("Erro verificando Lista de base de Dados / <TMySQLServer> " + oServer:Error(),SISTEMA )
      RELEASE WINDOW ALL
      QUIT
   ENDIF

   /* Verifica se na Array aBaseDeDadosExistentes tem a Base de Dados */
   IF AScan( aBaseDeDadosExistentes, Lower( cBaseDeDados ) ) != 0
      MsgINFO( "Base de Dados "+cBaseDeDados+" Já Existe!!")

      RETURN NIL
   ENDIF

   /* Cria a Base De Dados */
   oServer:CreateDatabase( cBaseDeDados )

   /*  Verifica se ocorreu algum erro */
   IF oServer:NetErr()
      MsGInfo("Erro Criando Base de Dados "+cBaseDeDados+" / <TMySQLServer> " + oServer:Error(),SISTEMA )
      RELEASE WINDOW ALL
      QUIT
   ENDIF

   ////MsgInfo("Base de Dados << "+cBaseDeDados+" >> Criada com Sucesso!!" )

   RETURN NIL
   /*
   */

FUNCTION My_Conecta_Banco_de_Dados( cBaseDeDados )

   LOCAL i                                           := 0
   LOCAL aBaseDeDadosExistentes      := {}

   cBaseDeDados                              := Lower(cBaseDeDados)

   /*  Verifica se esta conectado ao MySql */
   IF oServer == Nil ; MsgInfo("Conexão com MySql não foi Iniciada!!") ; Return Nil ; EndIf

   /*  Antes de Conectar Verifica se a Base de Dados já existe */
   aBaseDeDadosExistentes := oServer:ListDBs()

   /*  Verifica se ocorreu algum erro */
   IF oServer:NetErr()
      MsGInfo("Erro verificando Lista de base de Dados / <TMySQLServer> " + oServer:Error(),SISTEMA )
      RELEASE WINDOW ALL
      QUIT
   ENDIF

   /* Verifica se na Array aBaseDeDadosExistentes tem a Base de Dados */
   IF AScan( aBaseDeDadosExistentes, Lower( cBaseDeDados ) ) == 0
      MsgINFO( "Base de Dados "+cBaseDeDados+" Não Existe!!")

      RETURN NIL
   ENDIF

   /* Conecta a Base De Dados */
   oServer:SelectDB( cBaseDeDados )

   /*  Verifica se ocorreu algum erro */
   IF oServer:NetErr()
      MsGInfo("Erro Conectando à Base de Dados "+cBaseDeDados+" / <TMySQLServer> " + oServer:Error(),SISTEMA )
      RELEASE WINDOW ALL
      QUIT
   ENDIF

   ///MsgInfo("Banco de Dados << "+cBaseDeDados+" >> Aberto!!" )

   RETURN NIL
   /*
   */

FUNCTION My_Cria_Tabela( cTabela )

   LOCAL i                                := 0
   LOCAL aTabelasExistentes    := {}
   LOCAL aStruc                       := {}
   LOCAL cQuery

   /* Usei esta sintaxe porque não consegui criar tabela com TMySQLServer usando a variável Codigo com AutoIncremento */
   cQuery  := "CREATE TABLE "+ cTabela+" ( Codigo SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT ,  Nome  VarChar(40) ,  Endereco  VarChar(40) , eMail  VarChar(40) , PRIMARY KEY (Codigo) ) "

   /*  Verifica se esta conectado ao MySql */
   IF oServer == Nil ; MsgInfo("Conexão com MySql não foi Iniciada!!") ; Return Nil ; EndIf

   /*  Antes de criar Verifica se a Tabela  já existe */
   aTabelasExistentes  := oServer:ListTables()

   /*  Verifica se ocorreu algum erro */
   IF oServer:NetErr()
      MsGInfo("Erro verificando Lista de Tabelas / <TMySQLServer> " + oServer:Error(),SISTEMA )
      RELEASE WINDOW ALL
      QUIT
   ENDIF

   /* Verifica se na Array aTabelasExistentes tem a Tabela */
   IF AScan( aTabelasExistentes, Lower( cTabela ) ) != 0
      MsgINFO( "Tabela "+cTabela+" Já Existe!!")

      RETURN NIL
   ENDIF

   /* Cria a Tabela */
   oQuery := oServer:Query( cQuery )

   /*  Verifica se ocorreu algum erro */
   IF oServer:NetErr()
      MsGInfo("Erro Criando Tabela "+cTabela+" / <TMySQLServer> " + oServer:Error(),SISTEMA )
      RELEASE WINDOW ALL
      QUIT
   ENDIF

   /*  Elimina Objeto Query */
   oQuery:Destroy()

   ////MsgInfo("Tabela << "+cTabela+" >> Criada com Sucesso!!" )

   RETURN NIL

   /*
   Insere registros (importa Registros da tabela Nomes.DBF
   */

FUNCTION Insere_Registros_na_Tabela( cTabela )

   LOCAL cQuery := ""
   LOCAL NrReg   := 0

   IF ! MsgYesNo( "Importa Dados de NOMES.DBF para Nomes(MySql) ??" )

      RETURN NIL
   ENDIF

   Form_1.Label_Mensagem.Value := "Exportando dados de Nomes.DBF para Nome(MySql)   Aguarde..."

   IF ! File( "NOMES.DBF" )
      MsgBox( "Arquivo NOMES.DBF não encontrado para Importação!!" , "Falta de Arquivo" )

      RETURN NIL
   ENDIF

   /* O Arquivo NOMES.DBF foi utilizado para facilitar a Importacao            */
   /* de Dados e mostrar que pode-se usar as Duas Base de dados ao mesmo Tempo */

   USE Nomes Alias Nomes New
   Nomes->(DBGoTop())
   DO WHILE ! Nomes->(Eof())

      /* Monta Query */
      cQuery := "INSERT INTO "+ cTabela + " VALUES ( '"+Str(Nomes->Codigo,8)+"' , '"+ AllTrim(Nomes->Nome)+"' , '"+Nomes->endereco+"' , '"+Nomes->Email+ "' ) "

      /* Executa Query */
      oQuery := oServer:Query(  cQuery )

      /*  Verifica se ocorreu algum erro */
      IF oServer:NetErr()
         MsGInfo("Erro Executando Query <<<  "+cQuery+" / <TMySQLServer> " + oServer:Error(),SISTEMA )
         EXIT
      ENDIF

      oQuery:Destroy()

      NrReg += 1

      Nomes->(DBSkip())

   ENDDO

   Form_1.Label_Mensagem.Value := "O Clipper não Morreu!!   Conheça o xHarbour & o HMG"

   MsgInfo( StrZero( NrReg , 6 )+"  Registros Inseridos na Tabela "+cTabela+" !!")

   RETURN NIL
   /*
   */

FUNCTION My_Fechar_Conexao_com_Base_De_Dados()

   IF oServer != Nil
      oServer:Destroy()
      oServer := Nil
   ENDIF

   RETURN NIL
   /*
   */

FUNCTION Sobre_o_Sistema()

   PlayExclamation()
   MsgINFO ( PadC("*** Sistema de Exemplo ***",60)+QUEBRA+;
      PadC(" ",30)+QUEBRA+;
      PadC(" xHarbour + HMG + MySQL",60)+QUEBRA+;
      PadC(" ",30)+QUEBRA+;
      PadC("Desenvolvido por Humberto_Fornazier  hfornazier@brfree.com.br",60)+QUEBRA+;
      PadC(" ",30)+QUEBRA+;
      PadC("HMG = Roberto Lopez = mail.box.hmg@gmail.com",60)+QUEBRA+;
      PadC(" ",30)+QUEBRA+;
      PadC("xharbour = www.xharbour.org",60),"Exemplo xHarbour + HMG + MYSql")

   RETURN NIL

