#include 'minigui.ch'

PROCEDURE AdministradorDeTipos

   DEFINE WINDOW Win_1            ;
         AT 0,0               ;
         WIDTH 310            ;
         HEIGHT 460 + IF(IsXPThemeActive(),8,0)   ;
         TITLE 'Administrador de Tipos'      ;
         MODAL               ;
         FONT 'ARIAL' SIZE 9         ;
         NOSIZE

      DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 58,35 FLAT BORDER

         BUTTON Nuevo          ;
            CAPTION '&Nuevo'    ;
            PICTURE 'nuevo'   ;
            ACTION Agregar()

         BUTTON EDITAR          ;
            CAPTION '&Editar'    ;
            PICTURE 'editar'   ;
            ACTION Modificar()

         BUTTON ELIMINAR       ;
            CAPTION 'E&liminar'   ;
            PICTURE 'borrar'   ;
            ACTION Borrar()

         BUTTON IMPRIMIR       ;
            CAPTION '&Imprimir'   ;
            PICTURE 'imprimir2' ;
            ACTION Impresion()

         BUTTON CERRAR         ;
            CAPTION '&Cerrar'   ;
            PICTURE 'cerrar'   ;
            ACTION Win_1.release

      END TOOLBAR

      DEFINE STATUSBAR
         STATUSITEM ""
      END STATUSBAR

      // Todos los controles @... tienen una sintaxis altena.
      // La ventaja principal de esta sintaxis es que las propiedades
      // pueden incluirse en cualquier orden.

      DEFINE LABEL Label_1
         ROW   60
         COL   10
         VALUE    'Buscar:'
         WIDTH    40
      END LABEL

      // La clausula ONENTER permite definir un procedimiento que se
      // ejecutara cuando el usuario presione enter mientras el control
      // tenga el foco.

      // La clausula TOOLTIP permite definir un texto de ayuda que aparecera
      // automaticamente cuando el mouse pasa sobre el control.

      DEFINE TEXTBOX Text_1
         ROW      60
         COL      60
         WIDTH      195
         ONENTER      If ( Busqueda() == .T. , ( Win_1.Grid_1.Value := 1 , Win_1.Grid_1.SetFocus ) , Nil )
         TOOLTIP      'Buscar (Ingrese "*" para todos los registros)'
         UPPERCASE   .T.
      END TEXTBOX

      // La clausula PICTURE permite definir un archivo de imagen
      // que se asociara al control.

      DEFINE BUTTON Button_1
         ROW   60
         COL   265
         WIDTH   25
         HEIGHT   25
         PICTURE   'buscar'
         ACTION If ( Busqueda() == .T. , ( Win_1.Grid_1.Value := 1 , Win_1.Grid_1.SetFocus ) , Nil )
         TOOLTIP 'Buscar'
      END BUTTON

      // El control GRID permite mostrar datos en forma de tabla.
      // La clausula HEADERS requiere un array de caracteres conteniendo
      // los encabezados de las columnas del control.
      // La clausula WIDTHS requiere un array numerico conteniendo
      // los anchos de las columnas del control.

      DEFINE GRID Grid_1
         ROW 95
         COL 10
         WIDTH 280
         HEIGHT 310
         HEADERS { 'Codigo' , 'Descripcion' }
         WIDTHS { 60 , 215 }
      END GRID

   END WINDOW

   Win_1.Text_1.SetFocus

   CENTER WINDOW Win_1

   ACTIVATE WINDOW Win_1

   RETURN

FUNCTION Busqueda

   LOCAL RetVal := .F. , nRecCount := 0

   IF Empty ( Win_1.Text_1.Value )

      RETURN .F.
   ENDIF

   // GRID
   // ----

   // El metodo 'DeleteAllItems' se usa para eliminar todos los items de un
   // control GRID

   // El metodo 'AddItem' se usa para agregar items a un control GRID.
   // Su argumento debe ser un array de caracteres conteniendo tantos elementos
   // como columnas tenga el GRID.

   // STATUSBAR
   // ---------

   // Cuando se define un STATUSBAR para una ventana, se le asigna
   // automaticamente el nombre de 'StausBar'.
   // Puede accederse a cada una de sus secciones por medio de la propiedad
   // 'Item', indicando como argumento, la posicion del mismo al
   // definirse el control. La propiedad 'Item' es de tipo caracter par el
   // control STATUSBAR.

   Win_1.Grid_1.DeleteAllItems

   USE Tipos Index Tipos Shared
   SET Order To Tag Desc

   IF AllTrim (AllTrim(Win_1.Text_1.Value)) == '*'

      GO TOP

      DO WHILE .Not. Eof()
         nRecCount++
         Win_1.Grid_1.AddItem ( { Str(Tipos->Cod_Tipo) , Tipos->Desc } )
         SKIP
      ENDDO

      IF nRecCount > 0
         RetVal := .T.
         Win_1.StatusBar.Item(1) := AllTrim(Str(nRecCount)) + ' Registros Encontrados'
      ELSE
         RetVal := .F.
         Win_1.StatusBar.Item(1) := 'No se encontraron registros'
      ENDIF

   ELSE

      IF DbSeek(AllTrim(Win_1.Text_1.Value))

         RetVal := .T.

         DO WHILE Upper(Tipos->Desc) = AllTrim(Win_1.Text_1.Value)
            nRecCount++
            Win_1.Grid_1.AddItem ( { Str(Tipos->Cod_Tipo) , Tipos->Desc } )
            SKIP
         ENDDO

         RetVal := .T.
         Win_1.StatusBar.Item(1) := AllTrim(Str(nRecCount)) + ' Registros Encontrados'

      ELSE
         Win_1.StatusBar.Item(1) := 'No se encontraron registros'
      ENDIF

   ENDIF

   CLOSE Tipos

   RETURN ( RetVal )

PROCEDURE Agregar

   LOCAL cDesc, nCod_Tipo

   // La funcion 'InputBox' crea una ventana que permite
   // ingresar un texto.
   // El primer parametro indica la etiqueta del texto que se desea ingresar
   // y el segundo parametro, el titulo.

   // En el GRID, la propiedad 'Value' (numerica, lectura/escritura)
   // indica o permite establecer el item seleccionado.

   // La funcion 'MsgStop' muestra una venta con un mensaje (primer
   // parametro) un titulo (segundo parametro) un icono de stop y
   // el boton aceptar.

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

         IF ( Busqueda() == .T. , ( Win_1.Grid_1.Value := 1 , Win_1.Grid_1.SetFocus ) , Nil )

         ELSE

            MsgStop ('Operacion Cancelada: El Archivo esta siendo actualizado por otro usuario. Reintente mas tarde')

         ENDIF

      ENDIF

      RETURN

PROCEDURE Borrar

   LOCAL ItemPos , aItem

   // Si la propiedad 'Value' en un GRID es cero, significa que no hay
   // items seleccionados

   // La funcion 'MsgYestNo' muestra una ventana con un texto (primer parametro)
   // un titulo (segundo parametro) y botones 'Si' y 'No'.
   // Si se selecciona el boton 'Si' la funcion retorna .t.
   // Seleccionando 'No' la funcion retorna .F.

   ItemPos := Win_1.Grid_1.Value

   IF ItemPos == 0
      MsgStop ('No hay regostros seleccionados','Borrar Registro')

      RETURN
   ENDIF

   IF MsgYesNo ( 'Esta Seguro' , 'Borrar Registro' )

      USE Contactos Index Contactos Shared New
      SET Order To Tag Cod_Tipo

      USE Tipos Index Tipos Shared New
      SET Order To Tag Cod_Tipo

      aItem := Win_1.Grid_1.Item ( ItemPos )

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
               IF ( Busqueda() == .T. , ( Win_1.Grid_1.Value := 1 , Win_1.Grid_1.SetFocus ) , Nil )
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

   // La propiedad 'Item' del control GRID retorna un array de caracteres con
   // tantos elementos como columnas tenga el control.

   ItemPos := Win_1.Grid_1.Value

   IF ItemPos == 0
      MsgStop ('No hay regostros seleccionados','Editar Registro')

      RETURN
   ENDIF

   USE Tipos Index Tipos Shared
   SET Order To Tag Cod_Tipo

   aItem := Win_1.Grid_1.Item ( ItemPos )

   IF dBSeek ( Val ( aItem[1] ) )
      IF rlock()
         cDesc := InputBox ( 'Descripcion:','Editar Registro', AllTrim(Tipos->Desc))

         IF ! Empty ( cDesc )
            Tipos->Desc := cDesc
         ENDIF

         nCodTipo := Tipos->Cod_Tipo

         CLOSE Tipos

         IF Busqueda()

            Win_1.Grid_1.Value := 1

            FOR i := 1 To Win_1.Grid_1.ItemCount

               aItem := Win_1.Grid_1.Item ( i )

               IF Val ( aItem [1] ) == nCodTipo
                  Win_1.Grid_1.Value := i
                  Win_1.Grid_1.SetFocus
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

