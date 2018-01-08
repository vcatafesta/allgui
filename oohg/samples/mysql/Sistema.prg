#include <oohg.ch>

* ooSQL - Proyecto simple para ver el funcionamiento de la Clase ooSQL con el  *
*         control xBrowse mediante la LIB MySqlLib                             *
*                                                                              *
*  ABM de una consulta a MySql                                                 *
*                                                                              *
* Autor: Sergio D.Castellari (c) 10-2010 - Navarro, Argentina                  *
*        soportesdcgestion@yahoo.com.ar - www.sdcinformatica.com.ar            *
*                                                                              *

* Main() Inicio del Sistema!                                                   *

FUNCTION Main

   REQUEST HB_LANG_ES
   HB_LANGSELECT( "ES" )            //Esta linea con la de arriba declaran el idioma español

   SET CENTURY ON
   SET EPOCH TO 1960
   SET DATE To British
   SET MULTIPLE OFF WARNING
   SET NAVIGATION EXTENDED
   SET TOOLTIPBALLOON ON

   _OOHG_NestedSameEvent( .T. )  //Esto permite multiples ejecuciones de Procedure o Function

   PUBLIC oServer:=Nil
   PUBLIC cNomSistema:="ooSQL - Clase para xBrowse..."
   PUBLIC cDataBase:= "ooSQL"
   PUBLIC cUsuario:=''
   PUBLIC cUsuId:=''

   LOAD WINDOW Sistema
   PRIVATE lMaxi:=.t.     //Maximizar Pantalla principal del Sistema

   IF !File('Parametros.Ini') ; CrearIniPar() ; EndIf
   BEGIN INI FILE "Parametros.Ini"
      GET lMaxi SECTION "General" ENTRY 'Maximizar'
   END INI
   CENTER WINDOW Sistema
   IF lMaxi ; Sistema.Maximize ; EndIf
   ACTIVATE WINDOW Sistema

   RETURN

   * Arranco() Utilizada por el InitInicio del Sistema!                           *

STATIC FUNCTION Arranco

   Sistema.Label_1.Value:='SDC Soluciones Informáticas' ; Sistema.Label_1.Enabled:=.f.
   ImagenSDC()
   Sistema.Title:=Sistema.Title+' - '+cNomSistema
   ConectoMySql()

   RETURN

   * ConectoMySql() Carga los datos de conexión de MySQL a partir de Sistema.Ini  *

STATIC FUNCTION ConectoMySql

   LOCAL aBaseDeDatosExistentes:= {}
   PRIVATE cHostName:="", cUser:="", cPassWord:=""

   IF !File('Parametros.Ini') ; CrearIniPar() ; EndIf
   BEGIN INI FILE "Parametros.Ini"
      GET cHostName      SECTION "Acceso"     ENTRY 'Host'
      GET cUser          SECTION "Acceso"     ENTRY 'Usuario'
      GET cPassWord      SECTION "Acceso"     ENTRY 'Pass'
   END INI
   IF !Conexion(cHostName, cUser, cPassWord, cDataBase )
      MsgStop('No se pudo conectar con Mysql','Sistema ooSQL')
   ENDIF

   RETURN

   * Conexion() Realiza la conexión con el Servidor MySQL                         *

STATIC FUNCTION Conexion(cHostName, cUser, cPassWord, cDataBase )

   LOCAL lBnd:=.f.

   Sistema.Statusbar.Item(1):="Conectando a "+cHostName
   IF oServer != Nil                                                               //Verifico si Ya esta conectado
      Sistema.StatusBar.Item(1):="Conectado a Base De Datos" ; Return .t.
   ENDIF
   oServer:=TMySQLServer():New(cHostName, cUser, cPassWord )                       //Abro la conexión con MySQL
   Sistema.statusBar.item(1):="Conectando a MySql"
   IF oServer:NetErr()                                                             //Verifica si ocurrió algún error en la Conexión
      MsgInfo("Error de Conexión con Servidor " +chr(13)+ oServer:Error(),'Sistema ooSQL')
      oServer:=Nil ; Return .f.
   ENDIF
   cBaseDeDatos:=Lower(cDataBase)                                                  //Conectado con la Base de Datos
   Sistema.Statusbar.Item(1):="Conectando a Base De datos"
   IF oServer == Nil                                                               //Verifica si se Conectó realmente
      MsgInfo("Conexión con MySQL NO fue Iniciada!!",'Sistema ooSQL')
      Sistema.StatusBar.Item(1):="No Conectado" ; Return Nil
   ENDIF
   aBaseDeDatosExistentes:=oServer:ListDBs()                                       //Antes de Conectar Verifica si la Base de Datos ya existe
   IF oServer:NetErr()                                                             //Verifica si ocurrio algun error en Conexión
      MsgInfo("Error de Conexión con Servidor / <TMySQLServer> " + oServer:Error(),'Sistema ooSQL' )
      Sistema.StatusBar.Item(1):="No Conectado a MySQL" ; oServer:=Nil ; Return .F.
   ENDIF
   IF AScan( aBaseDeDatosExistentes, Lower( cBaseDeDatos ) ) == 0                  //Verifica si en el Array aBaseDeDadosExistentes tiene la Base de Datos
      MsgInfo("Base de Datos "+cBaseDeDatos+" No Existe!!",'Sistema ooSQL')
      IF MsgYesNo('Desea Crear la Base MySQL [ooSQL] ???','Atención!!!. Crear Base...')
         IF !CreoBase()
            oServer:=Nil ; Return .f.
         ELSE
            lBnd:=.t.   //Como la Base No existia...la creo...y luego debo crear la Tabla Clientes...
         ENDIF
      ELSE
         oServer:=Nil ; Return .F.
      ENDIF
   ENDIF
   oServer:SelectDB( cBaseDeDatos )
   IF oServer:NetErr()                                                             //Verifica si ocurrio algun error en Conexión
      MsgInfo("Error de Conexión con Servidor / <TMySQLServer> " + oServer:Error(),'Sistema ooSQL' )
      oServer:=Nil ; Return .F.
   ELSE
      IF lBnd == .t.
         IF !CreoTabla()
            oServer:=Nil ; Return .f.
         ENDIF
      ENDIF
   ENDIF
   Sistema.StatusBar.Item(1):='Conectado como: '+oServer:cUser + "@" + cHostName

   RETURN .T.

   * ImagenSDC() Controla la visualización del logo de SDC Soluciones!            *

STATIC FUNCTION ImagenSDC

   LOCAL nAlto,nAncho,nAjusAl,nAjusAn,nAltura, nAnchura

   nAlto  :=110             //Altura de la Imagen
   nAncho :=172             //Anchura de la Imagen
   nAjusAl:=90
   nAjusAn:=30
   IF Sistema.Height-nAlto-nAjusAl<nAlto
      Sistema.Image_1.Visible:=.f.
      RETURN NIL
   ELSE
      Sistema.Image_1.Visible:=.t.
      nAltura:=Sistema.Height-nAlto-nAjusAl
   ENDIF
   IF Sistema.Width-nAncho-nAjusAn<nAncho
      Sistema.Image_1.Visible:=.f.
      RETURN NIL
   ELSE
      Sistema.Image_1.Visible:=.t.
      nAnchura:=Sistema.Width-nAncho-nAjusAn
   ENDIF
   Modify Control Image_1 of Sistema  ROW nAltura
   Modify Control Image_1 of Sistema  COL nAnchura
   Modify Control Label_1 of Sistema  ROW Sistema.Height-220
   Modify Control Label_1 of Sistema  COL 20

   RETURN NIL

   * SalidaSistema() Salida...                                                    *

FUNCTION SalidaSistema

   RETURN

   * CreoBase() Creo la Base de Datos ooSQL                                       *

FUNCTION CreoBase

   LOCAL oQuery

   oQuery:=oServer:Query("CREATE DATABASE ooSQL")
   IF oQuery:NetErr()
      MsgExclamation('Error'+chr(13)+oQuery:Error(),'Creando Base...') ; Return .f.
   ENDIF

   RETURN .t.

   * CreoTabla() Creo la Tabla Clientes                                           *

FUNCTION CreoTabla

   LOCAL oQuery, oQuery1, cQuery

   oQuery:=oServer:Query("Drop Table If Exists CLIENTES")
   IF oQuery:NetErr()
      MsgExclamation('Error'+chr(13)+oQuery:Error(),'Creando Tabla...') ; Return .f.
   ENDIF
   cQuery:="Create Table CLIENTES ("+ ;
      "CODIGO     Mediumint(5) default 0,"+ ;
      "TIPO       Char(1)      default 'S',"+ ;
      "NOMBRE     Char(30)     default '',"+ ;
      "TELEFONO   Char(15)     default '',"+ ;
      "DIRECCION  Char(30)     default '',"+ ;
      "DOCUMENTO  Char(10)     default '',"+ ;
      "LOCALIDAD  Char(20)     default '',"+ ;
      "NROCUIT    Char(13)     default '',"+ ;
      "FECHAINGRE Date         null,"+ ;
      "FECHAEGRE  Date         null,"+ ;
      "CLIEID Int(10) unsigned Not Null auto_increment, Primary Key (CLIEID)) ENGINE=InnoDB Default Charset=latin1"
   oQuery1:=oServer:Query(cQuery)
   IF oQuery1:NetErr()
      MsgExclamation('Error'+chr(13)+oQuery1:Error(),'Creando Tabla...') ; Return .f.
   ENDIF

   RETURN .t.
