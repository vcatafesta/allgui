/*
sistema     : superchef pizzaria
programa    : funções genéricas
compilador  : xharbour 1.2 simplex
lib gráfica : minigui 1.7 extended
programador : marcelo neves
*/

#include 'minigui.ch'

MEMVAR path_dbf
MEMVAR _nome_unidade

FUNCTION open_dbf(nome,apelido,modo)

   LOCAL arquivo := path_dbf + nome + '.dbf'
   LOCAL ret

   IF modo
      USE (arquivo) alias (apelido) via 'dbfcdx' shared new
   ELSE
      USE (arquivo) alias (apelido) via 'dbfcdx' exclusive new
   ENDIF

   IF .not. neterr()
      ret := .T.
   ELSE
      msgstop('Não foi possível abrir '+alltrim(apelido)+', Tente novamente','Atenção')
      ret := .F.
   ENDIF

   RETURN(ret)
   *________________________________________________________________________________________

FUNCTION Lock_Dbf()

   LOCAL ret

   IF flock()
      ret := .T.
   ELSE
      msgstop('Não foi possível bloquear uma tabela','Atenção')
      ret := .F.
   ENDIF

   RETURN(ret)
   *________________________________________________________________________________________________

FUNCTION Lock_Reg()

   LOCAL ret

   IF rlock()
      ret := .T.
   ELSE
      msgstop('Não foi possível acessar esta informação','Atenção')
      ret := .F.
   ENDIF

   RETURN(ret)
   *________________________________________________________________________________________________

FUNCTION add_reg()

   LOCAL ret

   dbappend()

   IF .not. neterr()
      ret := .T.
   ELSE
      msgstop('Não foi possível gravar estas informações','Atenção')
      ret := .F.
   ENDIF

   RETURN(ret)
   *________________________________________________________________________________________________

FUNCTION Chk_Mes(parametro,tipo)

   LOCAL retorno

   IF tipo == 1
      retorno := {'Jan','Fev','Mar','Abr','Mai','Jun',;
         'Jul','Ago','Set','Out','Nov','Dez'} [Parametro]
   ELSEIF tipo == 2
      retorno := {'Janeiro  ','Fevereiro','Marco    ','Abril    ','Maio     ','Junho    ',;
         'Julho    ','Agosto   ','Setembro ','Outubro  ','Novembro ',;
         'Dezembro '} [Parametro]
   ENDIF

   RETURN(retorno)
   *________________________________________________________________________________________________

FUNCTION dia_da_semana(p_data,p_tipo)

   LOCAL cSem_ext,cSem_abv,cData

   IF p_tipo == 1
      cSem_ext := {'Domingo','Segunda-Feira','Terça-Feira' ,;
         'Quarta-Feira','Quinta-Feira','Sexta-Feira' ,;
         'Sábado'}
      cData := cSem_ext[dow(p_data)]

      RETURN(cData)
   ELSEIF p_tipo == 2
      cSem_abv := {'Dom','Seg','Ter','Qua','Qui','Sex','Sáb'}
      cData    := cSem_abv[dow(p_data)]

      RETURN(cData)
   ENDIF

   RETURN(nil)
   *________________________________________________________________________________________________

FUNCTION check_window()

   LOCAL largura := getdesktopwidth()
   LOCAL altura  := getdesktopheight()
   LOCAL ret

   IF largura < 1000 .and. altura < 750
      msgstop('Este programa é melhor visualizado e operado com a resolução de vídeo 1024 x 768','Atenção')
      ret := .F.
   ELSEIF largura > 1030 .and. altura > 780
      msgstop('Este programa é melhor visualizado e operado com a resolução de vídeo 1024 x 768','Atenção')
      ret := .F.
   ELSE
      ret := .T.
   ENDIF

   RETURN(ret)
   *________________________________________________________________________________________________

FUNCTION valor_coluna(xObj,xForm,nCol)

   LOCAL nPos := GetProperty(xForm,xObj,'Value')
   LOCAL aRet := GetProperty(xForm,xObj,'Item',nPos)

   RETURN aRet[nCol]

FUNCTION acha_unidade(parametro)

   LOCAL area_aberta := select()
   LOCAL retorno     := space(10)

   IF empty(parametro)

      RETURN('---')
   ENDIF

   dbselectarea('unidade_medida')
   unidade_medida->(ordsetfocus('codigo'))
   unidade_medida->(dbgotop())
   unidade_medida->(dbseek(parametro))

   IF found()
      retorno := unidade_medida->nome
   ELSE
      retorno := '---'
   ENDIF

   dbselectarea(area_aberta)

   RETURN(retorno)

FUNCTION acha_banco(parametro)

   LOCAL area_aberta := select()
   LOCAL retorno     := space(20)

   IF empty(parametro)

      RETURN('---')
   ENDIF

   dbselectarea('bancos')
   bancos->(ordsetfocus('codigo'))
   bancos->(dbgotop())
   bancos->(dbseek(parametro))

   IF found()
      retorno := bancos->nome
   ELSE
      retorno := '---'
   ENDIF

   dbselectarea(area_aberta)

   RETURN(retorno)

FUNCTION acha_tamanho(parametro)

   LOCAL area_aberta := select()
   LOCAL retorno     := space(20)

   IF empty(parametro)

      RETURN('---')
   ENDIF

   dbselectarea('tamanho_pizza')
   tamanho_pizza->(ordsetfocus('codigo'))
   tamanho_pizza->(dbgotop())
   tamanho_pizza->(dbseek(parametro))

   IF found()
      retorno := tamanho_pizza->nome
   ELSE
      retorno := '---'
   ENDIF

   dbselectarea(area_aberta)

   RETURN(retorno)

FUNCTION acha_mprima(parametro)

   LOCAL area_aberta := select()
   LOCAL retorno     := space(20)

   IF empty(parametro)

      RETURN('---')
   ENDIF

   dbselectarea('materia_prima')
   materia_prima->(ordsetfocus('codigo'))
   materia_prima->(dbgotop())
   materia_prima->(dbseek(parametro))

   IF found()
      retorno       := materia_prima->nome
      _nome_unidade := materia_prima->unidade
   ELSE
      retorno := '---'
   ENDIF

   dbselectarea(area_aberta)

   RETURN(retorno)

FUNCTION acha_vmprima(parametro)

   LOCAL area_aberta := select()
   LOCAL retorno     := space(20)

   IF empty(parametro)

      RETURN('---')
   ENDIF

   dbselectarea('materia_prima')
   materia_prima->(ordsetfocus('codigo'))
   materia_prima->(dbgotop())
   materia_prima->(dbseek(parametro))

   IF found()
      retorno := trans(materia_prima->preco,'@E 99,999.99')
   ELSE
      retorno := '---'
   ENDIF

   dbselectarea(area_aberta)

   RETURN(retorno)

FUNCTION acha_fornecedor(parametro)

   LOCAL area_aberta := select()
   LOCAL retorno     := space(40)

   IF empty(parametro)

      RETURN('---')
   ENDIF

   dbselectarea('fornecedores')
   fornecedores->(ordsetfocus('codigo'))
   fornecedores->(dbgotop())
   fornecedores->(dbseek(parametro))

   IF found()
      retorno := alltrim(fornecedores->nome)
   ELSE
      retorno := '---'
   ENDIF

   dbselectarea(area_aberta)

   RETURN(retorno)

FUNCTION acha_fornecedor_2(parametro)

   LOCAL area_aberta := select()
   LOCAL retorno     := space(40)

   IF empty(parametro)

      RETURN('---')
   ENDIF

   dbselectarea('fornecedores')
   fornecedores->(ordsetfocus('codigo'))
   fornecedores->(dbgotop())
   fornecedores->(dbseek(parametro))

   IF found()
      retorno := fornecedores->nome+'- '+alltrim(fornecedores->fixo)+' - '+alltrim(fornecedores->celular)
   ELSE
      retorno := '---'
   ENDIF

   dbselectarea(area_aberta)

   RETURN(retorno)

FUNCTION acha_produto(parametro)

   LOCAL area_aberta := select()
   LOCAL retorno     := space(40)

   IF empty(parametro)

      RETURN('---')
   ENDIF

   dbselectarea('produtos')
   produtos->(ordsetfocus('codigo'))
   produtos->(dbgotop())
   produtos->(dbseek(parametro))

   IF found()
      retorno := alltrim(produtos->nome_longo)
   ELSE
      retorno := '---'
   ENDIF

   dbselectarea(area_aberta)

   RETURN(retorno)

FUNCTION acha_forma_pagamento(parametro)

   LOCAL area_aberta := select()
   LOCAL retorno     := space(40)

   IF empty(parametro)

      RETURN('---')
   ENDIF

   dbselectarea('formas_pagamento')
   formas_pagamento->(ordsetfocus('codigo'))
   formas_pagamento->(dbgotop())
   formas_pagamento->(dbseek(parametro))

   IF found()
      retorno := alltrim(formas_pagamento->nome)
   ELSE
      retorno := '---'
   ENDIF

   dbselectarea(area_aberta)

   RETURN(retorno)

FUNCTION acha_forma_recebimento(parametro)

   LOCAL area_aberta := select()
   LOCAL retorno     := space(40)

   IF empty(parametro)

      RETURN('---')
   ENDIF

   dbselectarea('formas_recebimento')
   formas_recebimento->(ordsetfocus('codigo'))
   formas_recebimento->(dbgotop())
   formas_recebimento->(dbseek(parametro))

   IF found()
      retorno := alltrim(formas_recebimento->nome)
   ELSE
      retorno := '---'
   ENDIF

   dbselectarea(area_aberta)

   RETURN(retorno)

FUNCTION acha_cliente(parametro)

   LOCAL area_aberta := select()
   LOCAL retorno     := space(40)

   IF empty(parametro)

      RETURN('---')
   ENDIF

   dbselectarea('clientes')
   clientes->(ordsetfocus('codigo'))
   clientes->(dbgotop())
   clientes->(dbseek(parametro))

   IF found()
      retorno := alltrim(clientes->nome)
   ELSE
      retorno := '---'
   ENDIF

   dbselectarea(area_aberta)

   RETURN(retorno)

FUNCTION acha_motoboy(parametro)

   LOCAL area_aberta := select()
   LOCAL retorno     := space(20)

   IF empty(parametro)

      RETURN('---')
   ENDIF

   dbselectarea('motoboys')
   motoboys->(ordsetfocus('codigo'))
   motoboys->(dbgotop())
   motoboys->(dbseek(parametro))

   IF found()
      retorno := motoboys->nome
   ELSE
      retorno := '---'
   ENDIF

   dbselectarea(area_aberta)

   RETURN(retorno)

FUNCTION acha_atendente(parametro)

   LOCAL area_aberta := select()
   LOCAL retorno     := space(20)

   IF empty(parametro)

      RETURN('---')
   ENDIF

   dbselectarea('atendentes')
   atendentes->(ordsetfocus('codigo'))
   atendentes->(dbgotop())
   atendentes->(dbseek(parametro))

   IF found()
      retorno := atendentes->nome
   ELSE
      retorno := '---'
   ENDIF

   dbselectarea(area_aberta)

   RETURN(retorno)

FUNCTION DbfVazio( cParametro )

   sele (cParametro )

   IF Eof()
      msgexclamation('A tabela '+alltrim(upper(cParametro))+' está vazia','Atenção')

      RETURN( .t. )
   ENDIF

   RETURN( .f. )
