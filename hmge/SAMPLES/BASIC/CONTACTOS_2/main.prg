/*
* Contactos
* (C) 2003 Roberto Lopez <harbourminigui@gmail.com>
* (C) 2005 Designed by MigSoft with MiniGUI IDE :: Roberto Lopez ::
*/

#include "minigui.ch"

STATIC Nuevo := .F.

FUNCTION Main

   SET delete on
   SET browsesync on
   SET CENTURY ON
   SET DATE french

   REQUEST DBFCDX , DBFFPT
   Rddsetdefault( "DBFCDX" )

   SET Default Icon To "Tutor"
   LOAD WINDOW Principal
   ACTIVATE WINDOW Principal

   RETURN NIL

PROCEDURE AdministradorDeContactos

   LOAD WINDOW Win_1
   Win_1.Browse_1.SetFocus
   CENTER WINDOW Win_1
   ACTIVATE WINDOW Win_1

   RETURN

PROCEDURE AbrirTablas

   USE TIPOS INDEX TIPOS SHARED NEW
   SET ORDER TO TAG Cod_Tipo
   GO TOP

   USE CONTACTOS INDEX CONTACTOS SHARED NEW
   SET ORDER TO TAG Apellido
   GO TOP

   Win_1.Browse_1.Value := Contactos->(RecNo())

   RETURN

PROCEDURE CerrarTablas

   CLOSE Contactos
   CLOSE Tipos

   RETURN

PROCEDURE DesactivarEdicion

   Win_1.Browse_1.Enabled      := .T.
   Win_1.Control_1.Enabled      := .F.
   Win_1.Control_2.Enabled      := .F.
   Win_1.Control_3.Enabled      := .F.
   Win_1.Control_4.Enabled      := .F.
   Win_1.Control_5.Enabled      := .F.
   Win_1.Control_6.Enabled      := .F.
   Win_1.Control_7.Enabled      := .F.
   Win_1.Control_8.Enabled      := .F.
   Win_1.Control_9.Enabled      := .F.
   Win_1.Control_10.Enabled   := .F.
   Win_1.Control_11.Enabled   := .F.
   Win_1.Control_12.Enabled   := .F.

   Win_1.Aceptar.Enabled      := .F.
   Win_1.Cancelar.Enabled      := .F.

   Win_1.ToolBar_1.Enabled      := .T.

   Win_1.Browse_1.SetFocus

   RETURN

PROCEDURE ActivarEdicion

   Win_1.Browse_1.Enabled      := .F.
   Win_1.Control_1.Enabled      := .T.
   Win_1.Control_2.Enabled      := .T.
   Win_1.Control_3.Enabled      := .T.
   Win_1.Control_4.Enabled      := .T.
   Win_1.Control_5.Enabled      := .T.
   Win_1.Control_6.Enabled      := .T.
   Win_1.Control_7.Enabled      := .T.
   Win_1.Control_8.Enabled      := .T.
   Win_1.Control_9.Enabled      := .T.
   Win_1.Control_10.Enabled   := .T.
   Win_1.Control_11.Enabled   := .T.
   Win_1.Control_12.Enabled   := .T.

   Win_1.Aceptar.Enabled      := .T.
   Win_1.Cancelar.Enabled      := .T.
   Win_1.ToolBar_1.Enabled      := .F.

   Win_1.Control_1.SetFocus

   RETURN

PROCEDURE CancelarEdicion()

   DesactivarEdicion()
   Actualizar()
   UNLOCK
   Nuevo := .F.

   RETURN

PROCEDURE AceptarEdicion()

   DesactivarEdicion()

   Tipos->(DbGoTo (Win_1.Control_2.Value))

   IF Nuevo == .T.
      Contactos->(DbAppend())
      Nuevo := .F.
   ENDIF

   Contactos->Apellido   := Win_1.Control_1.Value
   Contactos->Cod_Tipo   := Tipos->Cod_Tipo
   Contactos->Nombres   := Win_1.Control_3.Value
   Contactos->Calle   := Win_1.Control_4.Value
   Contactos->Numero   := Win_1.Control_5.Value
   Contactos->Piso      := Win_1.Control_6.Value
   Contactos->Dpto      := Win_1.Control_7.Value
   Contactos->Tel_Part   := Win_1.Control_8.Value
   Contactos->Tel_Cel   := Win_1.Control_9.Value
   Contactos->E_Mail   := Win_1.Control_10.Value
   Contactos->Fecha_Nac   := Win_1.Control_11.Value
   Contactos->Observ   := Win_1.Control_12.Value

   Win_1.Browse_1.Refresh

   IF Nuevo == .T.
      Win_1.Browse_1.Value := Contactos->(RecNo())
   ENDIF

   UNLOCK

   RETURN

PROCEDURE Nuevo()

   // Se asignan valores iniciales a los controles.

   Win_1.Control_1.Value := ''
   Win_1.Control_2.Value := 0
   Win_1.Control_3.Value := ''
   Win_1.Control_4.Value := ''
   Win_1.Control_5.Value := 0
   Win_1.Control_6.Value := 0
   Win_1.Control_7.Value := ''
   Win_1.Control_8.Value := ''
   Win_1.Control_9.Value := ''
   Win_1.Control_10.Value := ''
   Win_1.Control_11.Value := CtoD ('01/01/1960')
   Win_1.Control_12.Value := ''

   ActivarEdicion()

   RETURN

PROCEDURE Actualizar()

   Tipos->( DbSeek ( Contactos->Cod_Tipo ) )

   Win_1.Control_1.Value   := Contactos->Apellido
   Win_1.Control_2.Value   := Tipos->(RecNo())
   Win_1.Control_3.Value   := Contactos->Nombres
   Win_1.Control_4.Value   := Contactos->Calle
   Win_1.Control_5.Value    := Contactos->Numero
   Win_1.Control_6.Value   := Contactos->Piso
   Win_1.Control_7.Value    := Contactos->Dpto
   Win_1.Control_8.Value   := Contactos->Tel_Part
   Win_1.Control_9.Value   := Contactos->Tel_Cel
   Win_1.Control_10.Value   := Contactos->E_Mail
   Win_1.Control_11.Value   := Contactos->Fecha_Nac
   Win_1.Control_12.Value   := Contactos->Observ

   RETURN

FUNCTION BloquearRegistro()

   LOCAL RetVal

   IF Contactos->(RLock())
      RetVal := .t.
   ELSE
      MsgExclamation ('El Registro Esta Siendo Editado Por Otro Usuario. Reintente Mas Tarde')
      RetVal := .f.
   ENDIF

   RETURN RetVal

PROCEDURE Eliminar

   IF MsgYesNo ( 'Esta Seguro')

      IF BloquearRegistro()
         Contactos->(dbdelete())
         Contactos->(dbgotop())
         Win_1.Browse_1.Refresh
         Win_1.Browse_1.Value := Contactos->(RecNo())
         Actualizar()
      ENDIF
   ENDIF

   RETURN

PROCEDURE Buscar

   LOCAL Buscar

   Buscar := Upper ( AllTrim ( InputBox( 'Ingrese Apellido a Buscar:' , 'Busqueda' ) ) )

   IF .Not. Empty(Buscar)

      IF Contactos->(DbSeek(Buscar))
         Win_1.Browse_1.Value := Contactos->(RecNo())
      ELSE
         MsgExclamation('No se encontraron registros')
      ENDIF

   ENDIF

   RETURN

PROCEDURE Imprimir()

   LOCAL RecContactos , RecTipos

   RecContactos := Contactos->(RecNo())
   RecTipos := Tipos->(RecNo())

   SELECT Contactos
   SET RELATION TO Field->Cod_Tipo Into Tipos
   GO TOP

   DO REPORT                        ;
      TITLE 'Contactos'                  ;
      HEADERS  {'','','','',''} , {'Apellido','Nombres','Calle','Numero','Tipo'};
      FIELDS   {'Contactos->Apellido','Contactos->Nombres','Contactos->Calle','Contactos->Numero','Tipos->Desc'};
      WIDTHS   {10,15,20,7,15}                   ;
      TOTALS   {.F.,.F.,.F.,.F.,.F.}               ;
      WORKAREA Contactos                  ;
      LPP 50                        ;
      CPL 80                        ;
      LMARGIN 5                     ;
      PREVIEW

   SELECT Contactos
   SET RELATION TO

   Contactos->(DbGoTo(RecContactos))
   Tipos->(DbGoTo(RecTipos))

   RETURN

PROCEDURE AdministradorDeTipos

   LOAD WINDOW Win_2
   Win_2.Text_1.SetFocus
   CENTER WINDOW Win_2
   ACTIVATE WINDOW Win_2

   RETURN

FUNCTION Busqueda

   LOCAL RetVal := .F. , nRecCount := 0

   IF Empty ( Win_2.Text_1.Value )

      RETURN .F.
   ENDIF

   Win_2.Grid_1.DeleteAllItems

   USE Tipos Index Tipos Shared
   SET Order To Tag Desc

   IF AllTrim (AllTrim(Win_2.Text_1.Value)) == '*'

      GO TOP

      DO WHILE .Not. Eof()
         nRecCount++
         Win_2.Grid_1.AddItem ( { Str(Tipos->Cod_Tipo) , Tipos->Desc } )
         SKIP
      ENDDO

      IF nRecCount > 0
         RetVal := .T.
         Win_2.StatusBar.Item(1) := AllTrim(Str(nRecCount)) + ' Registros Encontrados'
      ELSE
         RetVal := .F.
         Win_2.StatusBar.Item(1) := 'No se encontraron registros'
      ENDIF

   ELSE

      IF DbSeek(AllTrim(Win_2.Text_1.Value))

         RetVal := .T.

         DO WHILE Upper(Tipos->Desc) = AllTrim(Win_2.Text_1.Value)
            nRecCount++
            Win_2.Grid_1.AddItem ( { Str(Tipos->Cod_Tipo) , Tipos->Desc } )
            SKIP
         ENDDO

         RetVal := .T.
         Win_2.StatusBar.Item(1) := AllTrim(Str(nRecCount)) + ' Registros Encontrados'

      ELSE
         Win_2.StatusBar.Item(1) := 'No se encontraron registros'
      ENDIF

   ENDIF

   CLOSE Tipos

   RETURN ( RetVal )

PROCEDURE Agregar

   LOCAL cDesc , nCod_Tipo

   cDesc := InputBox ( 'Descripcion:' , 'Agregar Registro' )

   IF .Not. Empty ( cDesc )

      USE Tipos Index Tipos Shared
      SET Order To Tag Cod_Tipo

      IF flock()

         Go Bottom

         nCod_Tipo := Tipos->Cod_Tipo + 1

         APPEND BLANK

         Tipos->Cod_Tipo := nCod_Tipo
         Tipos->Desc   := cDesc

         CLOSE Tipos

         IF ( Busqueda() == .T. , ( Win_2.Grid_1.Value := 1 , Win_2.Grid_1.SetFocus ) , Nil )

         ELSE

            MsgStop ('Operacion Cancelada: El Archivo esta siendo actualizado por otro usuario. Reintente mas tarde')

         ENDIF

      ENDIF

      RETURN

PROCEDURE Borrar

   LOCAL ItemPos , aItem

   ItemPos := Win_2.Grid_1.Value

   IF ItemPos == 0
      MsgStop ('No hay regostros seleccionados','Borrar Registro')

      RETURN
   ENDIF

   IF MsgYesNo ( 'Esta Seguro' , 'Borrar Registro' )

      USE Contactos Index Contactos Shared New
      SET Order To Tag Cod_Tipo

      USE Tipos Index Tipos Shared New
      SET Order To Tag Cod_Tipo

      aItem := Win_2.Grid_1.Item ( ItemPos )

      SEEK Val ( aItem[1] )

      IF found()
         IF rlock()
            IF Contactos->(DbSeek(Tipos->Cod_Tipo))
               CLOSE Tipos
               CLOSE Contactos
               MsgStop('Operacion cancelada: El registro esta asociado a uno o mas contactos. No puede eliminarse','Borrar registro')
            ELSE
               DELETE
               CLOSE Tipos
               CLOSE Contactos
               IF ( Busqueda() == .T. , ( Win_2.Grid_1.Value := 1 , Win_2.Grid_1.SetFocus ) , Nil )
               ENDIF
            ELSE
               CLOSE Tipos
               MsgStop('Operacion cancelada: El registro esta siendo editado por otro usuario. reintente mas tarde','Borrar registro')
            ENDIF
         ELSE
            CLOSE Tipos
            MsgStop('Operacion cancelada: El registro ha sido eliminado por otro usuario','Borrar registro')
         ENDIF

      ENDIF

      RETURN

PROCEDURE Modificar

   LOCAL ItemPos , aItem , cDesc , nCodTipo , i

   ItemPos := Win_2.Grid_1.Value

   IF ItemPos == 0
      MsgStop ('No hay regostros seleccionados','Editar Registro')

      RETURN
   ENDIF

   USE Tipos Index Tipos Shared
   SET Order To Tag Cod_Tipo

   aItem := Win_2.Grid_1.Item ( ItemPos )

   IF dBSeek ( Val ( aItem[1] ) )
      IF rlock()
         cDesc := InputBox ( 'Descripcion:','Editar Registro', AllTrim(Tipos->Desc))

         IF ! Empty ( cDesc )
            Tipos->Desc := cDesc
         ENDIF

         nCodTipo := Tipos->Cod_Tipo

         CLOSE Tipos

         IF Busqueda()

            Win_2.Grid_1.Value := 1

            FOR i := 1 To Win_2.Grid_1.ItemCount

               aItem := Win_2.Grid_1.Item ( i )

               IF Val ( aItem [1] ) == nCodTipo
                  Win_2.Grid_1.Value := i
                  Win_2.Grid_1.SetFocus
                  EXIT
               ENDIF

            NEXT i

         ENDIF
      ELSE
         CLOSE Tipos
         MsgStop('Operacion cancelada: El registro esta siendo editado por otro usuario. reintente mas tarde','Editar Registro')
      ENDIF
   ELSE
      CLOSE Tipos
      MsgStop('Operacion cancelada: El registro ha sido eliminado por otro usuario','Editar Registro')
   ENDIF

   RETURN

PROCEDURE Impresion()

   USE Tipos Index Tipos Shared New
   SET Order To Tag Cod_Tipo
   GO TOP

   DO REPORT                     ;
      TITLE 'Tipos'                  ;
      HEADERS  {'',''} , {'Codigo','Descripcion'}      ;
      FIELDS   {'Cod_Tipo','Desc'}            ;
      WIDTHS   {20,20}                ;
      TOTALS   {.F.,.F.}               ;
      WORKAREA Tipos                  ;
      LPP 50                     ;
      CPL 80                     ;
      LMARGIN 5                  ;
      PREVIEW

   CLOSE Tipos

   RETURN
