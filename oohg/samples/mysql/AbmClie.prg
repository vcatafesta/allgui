#include <oohg.ch>
#include "SDC_Colores.ch"

DECLARE Window AbmClie

* AbmClie() Administra el padrón de Socios/Clientes                            *

PROCEDURE AbmClie

   IF IsWindowActive('AbmClie')
      RESTORE Window AbmClie ; AbmClie.SetFocus ; Return Nil
   ENDIF
   PRIVATE Ok:=.f., oBaseClie, oQuery
   PRIVATE bColor  := { |Col, Row, Item| If ( Item[3]='  /  /    ', Nil , GrisClaro ) }

   IF oServer == Nil
      MsgStop('No hay conexion a MySql!!!','Acceso...') ; Return nil
   ENDIF
   oQuery:=oServer:Query("Select c.NOMBRE, c.CODIGO, c.FECHAEGRE, c.CLIEID From CLIENTES c Order By c.NOMBRE")
   IF oQuery:NetErr()
      MsgExclamation('Error '+oQuery:Error()+chr(13)+'Actualizando Contenido...','Actualizaciones de Clientes...') ; Return
   ENDIF
   oBaseClie:=ooSQL():New(oQuery)
   LOAD WINDOW AbmClie ; Center Window AbmClie ; Activate Window AbmClie

   RETURN NIL

   * ArrancoAbmClie() Apago los controles al iniciar el Form.                            *

STATIC FUNCTION ArrancoAbmClie

   AbmClie.Title:='Padrón de Clientes...'
   AbmClie.Nuevo.Enabled:=.T. ; AbmClie.Editar.Enabled:=.T.; AbmClie.Grabar.Enabled:=.F.; AbmClie.Cancelar.Enabled:=.F.
   AbmClie.Borrar.Enabled:=.T.; AbmClie.Buscar.Enabled:=.T.; AbmClie.Salir.Enabled:=.T.;AbmClie.Text_20.Enabled:=.f.
   FOR nI:=1 to 8 ; SetProperty('AbmClie','Text_'+AllTrim(Str(nI)),'Enabled',.f.) ; Next
      FOR nI:=2 to 8 ; SetProperty('AbmClie','Text_'+AllTrim(Str(nI)),'Value','') ; Next
         AbmClie.Text_1.Value:=0 ; AbmClie.Text_9.Value:=CtoD('') ; AbmClie.Text_9.Enabled:=.f.
         AbmClie.Browse_1.Enabled:=.T. ; Navego() ; AbmClie.Browse_1.Refresh ; AbmClie.Browse_1.SetFocus

         RETURN

         * Habilito() Habilito controles para edición.                                  *

STATIC FUNCTION Habilito

   AbmClie.Nuevo.Enabled:=.F.; AbmClie.Editar.Enabled:=.F.; AbmClie.Grabar.Enabled:=.T.; AbmClie.Cancelar.Enabled:=.T.
   AbmClie.Borrar.Enabled:=.F.; AbmClie.Buscar.Enabled:=.F.; AbmClie.Salir.Enabled:=.F.
   AbmClie.Browse_1.Enabled:=.F.
   IF Ok  //Es un Alta
      FOR nI:=1 to 8 ; SetProperty('AbmClie','Text_'+AllTrim(Str(nI)),'Enabled',.t.) ; Next
         AbmClie.Text_9.Enabled:=.t.; AbmClie.Text_1.SetFocus
      ELSE   //Es una Modificación
         FOR nI:=2 to 8 ; SetProperty('AbmClie','Text_'+AllTrim(Str(nI)),'Enabled',.t.) ; Next
            AbmClie.Text_9.Enabled:=.t. ; AbmClie.Text_2.SetFocus
         ENDIF

         RETURN

         * Cancelo() Es llamada por el Boton Cancelar del AbmClie.FMG                   *

STATIC FUNCTION Cancelo

   Ok:=.F. ; ArrancoAbmClie()

   RETURN

   * Edito() Es llamada por el boton Modificar...                                 *
   *       Recibe .t. cuando es un Alta                                           *
   *              .f. cuando es una Modificación                                  *

STATIC FUNCTION Edito(Vengo)

   LOCAL oQuery, oRow, nNewCod:=0

   Ok:=Vengo
   IF Ok   //Es un Alta
      AbmClie.Title:='Padrón de Clientes...(Nuevo)'
      oQuery:=oServer:Query("Select Max(CODIGO) From CLIENTES")
      IF oQuery:NetErr()
         MsgStop('Error '+oQuery:Error()+Chr(13)+'Buscando siguiente Código sugerido...')
      ELSE
         oRow:=oQuery:GetRow(1) ; nNewCod:=oRow:FieldGet(1)+1
      ENDIF
      AbmClie.Text_1.Value:=nNewCod
      FOR nI:=2 to 8 ; SetProperty('AbmClie','Text_'+AllTrim(Str(nI)),'Value','') ; Next ; AbmClie.Text_3.Value:='S'
         AbmClie.Text_9.Value:=CtoD('')
      ELSE
         AbmClie.Title:='Padrón de Clientes...(Modificación)'
      ENDIF
      Habilito()

      RETURN

      * Grabo() Grabo los valores del Form en la Tabla, ya sea una Modificación o un *
      *        Alta.                                                                 *

STATIC FUNCTION Grabo

   LOCAL cQuery, oQuery, oRow

   IF !Verificaciones()  //Realiza todas las comprobaciones ANTES de Grabar!

      RETURN
   ENDIF
   BEGIN Sequence
      oQuery:=oServer:Query("START TRANSACTION")
      IF oQuery:NetErr()
         MsgStop(oQuery:Error(),'Inicio Transaction...') ; BREAK
      ENDIF
      cCampo1:=Str(AbmClie.Text_1.Value) ; cCampo2:=CambioAcentoSQL(,AbmClie.Text_2.Value) ; cCampo3:=AbmClie.Text_3.Value
      cCampo4:=AbmClie.Text_4.Value ; cCampo5:=AbmClie.Text_5.Value ; cCampo6:=AbmClie.Text_6.Value ; cCampo7:=AbmClie.Text_7.Value
      cCampo8:=AbmClie.Text_8.Value ; cCampo9:=d2c(AbmClie.Text_9.Value)
      IF Ok   //Es un Alta
         cQuery:="Insert Into CLIENTES (CODIGO,NOMBRE,TIPO,TELEFONO,DIRECCION,LOCALIDAD,DOCUMENTO,NROCUIT,FECHAINGRE) Value ('"+;
            cCampo1+"','"+cCampo2+"','"+cCampo3+"','"+cCampo4+"','"+cCampo5+"','"+cCampo6+"','"+cCampo7+"','"+cCampo8+"','"+cCampo9+"')"
      ELSE
         cQuery:="Update CLIENTES Set CODIGO='"+cCampo1+"',NOMBRE='"+cCampo2+"',TIPO='"+cCampo3+"',TELEFONO='"+cCampo4+"',DIRECCION='"+cCampo5+;
            "',LOCALIDAD='"+cCampo6+"',DOCUMENTO='"+cCampo7+"',NROCUIT='"+cCampo8+"',FECHAINGRE='"+cCampo9+"' Where CODIGO='"+cCampo1+"'"
      ENDIF
      oQuery:=oServer:Query(cQuery)
      IF oQuery:NetErr()
         MsgStop(oQuery:Error(),'Error de Actualización...') ; BREAK
      ENDIF
      oQuery:=oServer:Query("COMMIT")
      IF oQuery:NetErr()
         MsgStop(oQuery:Error(),'Error en Commit...') ; BREAK
      ENDIF
      Ok:=.F.
      oQuery:=oServer:Query("Select c.NOMBRE, c.CODIGO, c.FECHAEGRE, c.CLIEID From CLIENTES c Order By c.NOMBRE")
      IF oQuery:NetErr()
         MsgExclamation('Error '+oQuery:Error()+chr(13)+'Actualizando Contenido...','Actualizaciones Tabla...') ; BREAK
      ENDIF
      nRec:=oBaseClie:Recno()                //Obtengo el Recno() actual
      oBaseClie:oQuery:=oQuery               //Actualizo oBaseClie con el nuevo oQuery -Actualiza automaticamente el WorkArea del xBrowse-
      oQuery:Goto(nRec)                      //Posiciona el Recno() -provoca una actualizacion del xBrowse
      ArrancoAbmClie()
   RECOVER
      oQuery:=oServer:Query("ROLLBACK")
      IF oQuery:NetErr()
         MsgStop(oQuery:Error(),'Error en RoolBack...')
      ENDIF
   End

   RETURN

   * Borro() Habilito o NO un Cliente                                             *

STATIC FUNCTION Borro

   LOCAL cQuery,oQuery, cSQL, cTipo:='H'

   IF oBaseClie:FieldGet('CLIEID')=0    //Si no hay renglon del xBrowse seleccionado...

      RETURN
   ENDIF
   IF DtoC(oBaseClie:FieldGet('FECHAEGRE')) <> DtoC(CtoD('')) //Si el Cliente esta Deshabilitado...
      cTipo:='D' ; cSQL:="Update CLIENTES Set FECHAEGRE='0000-00-00' Where CLIEID='"+Str(oBaseClie:FieldGet('CLIEID'))+"'"
   ELSE
      cSQL:="Update CLIENTES Set FECHAEGRE='"+DtoS(Date())+"' Where CLIEID='"+Str(oBaseClie:FieldGet('CLIEID'))+"'"
   ENDIF
   PlayOk()
   IF cTipo='D'
      IF !MsgYesNo(AllTrim(oBaseClie:FieldGet('NOMBRE'))+' es un Cliente DESHABILITADO!, desea Habilitarlo ???','Habilitar Clientes...') ; Return ; EndIf
   ELSEIF cTipo='H'
      IF !MsgYesNo(AllTrim(oBaseClie:FieldGet('NOMBRE'))+' es un Cliente HABILITADO!, desea DesHabilitarlo ???','Deshabilitar Clientes...') ; Return ; EndIf
   ENDIF
   BEGIN Sequence
      oQuery:=oServer:Query("START TRANSACTION")
      IF oQuery:NetErr()
         MsgStop(oQuery:Error(),'Error de TRANSACTION') ; BREAK
      ENDIF
      oQuery:=oServer:Query(cSQL)
      IF oQuery:NetErr()
         Msgstop(oQuery:Error(),'Habilitar/deshabilitar Cliente...') ; BREAK
      ENDIF
      oQuery:=oServer:Query("COMMIT")
      IF oQuery:NetErr()
         Msgstop(oQuery:Error(),'Error en COMMIT') ; BREAK
      ENDIF
      oQuery:Destroy()
      oQuery:=oServer:Query("Select c.NOMBRE, c.CODIGO, c.FECHAEGRE, c.CLIEID From CLIENTES c Order By c.NOMBRE")
      IF oQuery:NetErr()
         PlayExclamation() ; MsgExclamation('Error'+chr(13)+oQuery:Error(),'Actualizando Clientes...') ; BREAK
      ENDIF
      oBaseClie:oQuery:=oQuery       //Actualizo oBaseClie con el nuevo oQuery -Actualiza automaticamente el WorkArea del xBrowse-
      oQuery:Gotop()                 //Posiciona el Recno() -provoca una actualizacion del xBrowse desde el 1er.registro-
      AbmClie.Browse_1.Refresh
      ArrancoAbmClie()
   RECOVER
      oQuery:=oServer:Query("ROLLBACK")
      IF oQuery:NetErr()
         Msgstop(oQuery:Error(),'Error en roolback')
      ENDIF
      oQuery:Destroy()
   End

   RETURN

   * Navego() Actualiza el contenido de los TextBox con la Tabla de MySQL         *

STATIC FUNCTION Navego

   LOCAL oQuery, oRow

   IF oBaseClie:FieldGet('CLIEID')=0    //Si no hay renglon del xBrowse seleccionado...

      RETURN
   ENDIF
   oQuery:=oServer:Query("Select * From CLIENTES Where CLIEID='"+Str(oBaseClie:FieldGet('CLIEID'))+"'")
   IF oQuery:NetErr()
      MsgStop('Error '+oQuery:Error()+Chr(13)+'Buscando Registro...') ;   AbmClie.Text_2.SetFocus ; Return
   ENDIF
   AbmClie.Label_1.Value:=''
   IF oQuery:LastRec>0
      oRow:=oQuery:GetRow(1)
      AbmClie.Text_1.Value :=oRow:FieldGet('CODIGO')
      AbmClie.Text_2.Value :=oRow:FieldGet('NOMBRE')
      AbmClie.Text_3.Value :=oRow:FieldGet('TIPO')
      AbmClie.Text_4.Value :=oRow:FieldGet('TELEFONO')
      AbmClie.Text_5.Value :=oRow:FieldGet('DIRECCION')
      AbmClie.Text_6.Value :=oRow:FieldGet('LOCALIDAD')
      AbmClie.Text_7.Value :=oRow:FieldGet('DOCUMENTO')
      AbmClie.Text_8.Value :=oRow:FieldGet('NROCUIT')
      AbmClie.Text_9.Value :=CtoD(DtoC(oRow:FieldGet('FECHAINGRE')))
      IF DtoC(oQuery:FieldGet('FECHAEGRE')) <> DtoC(CtoD(''))    //Muestro si el Cliente esta Deshabilitado!
         AbmClie.Label_1.Value:='[Deshabilitado]'
      ENDIF
   ENDIF

   RETURN

   * Buscar() Es activado al presionar el Boton Buscar.                           *

STATIC FUNCTION Buscar

   AbmClie.Text_20.Value:='' ; AbmClie.Text_20.Enabled:=.t. ; AbmClie.Text_20.SetFocus

   RETURN

   * Buscando() Procesa la búsqueda...                                            *

STATIC FUNCTION Buscando

   LOCAL nAncho:=Len(AllTrim(AbmClie.Text_20.value)), lBnd:=.f., nRec:=0

   IF Empty(AbmClie.Text_20.Value)

      RETURN
   ENDIF
   nRec:=oBaseClie:Recno()
   oBaseClie:GoTop()
   DO WHILE !oBaseClie:Eof()
      IF SubStr(oBaseClie:FieldGet('NOMBRE'),1,nAncho) == AbmClie.Text_20.Value
         lBnd:=.t. ; Exit
      ENDIF
      oBaseClie:Skip()
   ENDDO
   IF !lBnd
      PlayExclamation() ; oQuery:Goto(nRec)
   ENDIF
   Navego()
   AbmClie.Browse_1.Refresh

   RETURN

   * Salir() Se procesa en el OnEnter de la Búsqueda.                             *

STATIC FUNCTION Salir

   AbmClie.Text_20.Value:='' ; AbmClie.Text_20.Enabled:=.f. ; AbmClie.Browse_1.SetFocus

   RETURN

   * Verificaciones() Realiza TODAS las comprobaciones necesarias antes de Grabar *

STATIC FUNCTION Verificaciones

   LOCAL cTit:='Padrón de Clientes...', cError:='] es Obligatorio!!', oQuery, oRow, cDes, cNewCod

   IF Empty(AbmClie.Text_1.Value)
      MsgExclamation('El campo [' + AllTrim(AbmClie.Label_01.Value) + cError,cTit) ; AbmClie.Text_1.SetFocus ; Return .f.
   ENDIF
   IF Ok   //Es un Alta
      oQuery:=oServer:Query("Select * from CLIENTES where CODIGO='"+Str(AbmClie.Text_1.Value)+"'")
      IF oQuery:NetErr()
         MsgStop('Error '+oQuery:Error()+Chr(13)+'Intentelo nuevamente...') ; AbmClie.Text_1.SetFocus ; Return .f.
      ENDIF
      IF oQuery:LastRec()>0
         oRow:=oQuery:GetRow(1) ; cDes:=oRow:FieldGet('NOMBRE')
         oQuery:=oServer:Query("Select Max(CODIGO) From CLIENTES")
         IF oQuery:NetErr()
            MsgStop('Error '+oQuery:Error()+Chr(13)+'Buscando siguiente Código...'+Chr(13)+'Intentelo nuevamente...') ; AbmClie.Text_1.SetFocus ; Return .f.
         ELSE
            oRow:=oQuery:GetRow(1) ; cNewCod:=AllTrim(Str(oRow:FieldGet('CODIGO')+1))
         ENDIF
         MsgExclamation('Este Código YA fue asignado a: '+cDes+Chr(13)+'Próximo Código sugerido: '+cNewCod,'Agregar Cliente...') ; AbmClie.Text_1.SetFocus ; Return .f.
      ENDIF
   ENDIF
   IF Empty(AbmClie.Text_2.Value)
      MsgExclamation('El campo [' + AllTrim(AbmClie.Label_02.Value) + cError,cTit) ; AbmClie.Text_2.SetFocus ; Return .f.
   ENDIF
   IF Empty(AbmClie.Text_3.Value) .or. (AbmClie.Text_3.Value<>'S' .and. AbmClie.Text_3.Value<>'C')
      MsgExclamation('El campo [' + AllTrim(AbmClie.Label_3.Value)+cError+chr(13)+"Valores válidos 'S' = Socios, 'C' = Clientes",cTit) ; AbmClie.Text_3.SetFocus ; Return .f.
   ENDIF

   RETURN .t.
