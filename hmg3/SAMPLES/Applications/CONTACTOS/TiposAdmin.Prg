#include 'hmg.ch'

FUNCTION AdministradorDeTipos

   DBSELECTAREA( 'Tipos')
   DBSetOrder(1)

   DEFINE WINDOW Win_2               ;
         AT 0,0                         ;
         WIDTH 310                      ;
         HEIGHT 460                     ;
         TITLE 'Administrador de Tipos' ;
         MODAL                          ;
         FONT 'ARIAL' SIZE 9            ;
         NOSIZE

      DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 58,35 IMAGESIZE 20,20  FLAT BORDER

         BUTTON Nuevo            ;
            CAPTION '&Nuevo'    ;
            PICTURE 'nuevo' ;
            ACTION Agregar()

         BUTTON EDITAR             ;
            CAPTION '&Editar'     ;
            PICTURE 'editar'  ;
            ACTION Modificar()

         BUTTON ELIMINAR          ;
            CAPTION 'E&liminar'  ;
            PICTURE 'borrar' ;
            ACTION Borrar()

         BUTTON IMPRIMIR             ;
            CAPTION '&Imprimir'     ;
            PICTURE 'imprimir2' ;
            ACTION Impresion()

         BUTTON CERRAR             ;
            CAPTION '&Cerrar'     ;
            PICTURE 'cerrar'  ;
            ACTION Win_2.release

      END TOOLBAR

      DEFINE STATUSBAR
         STATUSITEM ""
      END STATUSBAR

      // Todos los controles @... tienen una sintaxis altena.
      // La ventaja principal de esta sintaxis es que las propiedades
      // pueden incluirse en cualquier orden.

      DEFINE LABEL Label_1
         ROW 60
         COL 10
         VALUE   'Buscar:'
         WIDTH   40
      END LABEL

      // La clausula ONENTER permite definir un procedimiento que se
      // ejecutara cuando el usuario presione enter mientras el control
      // tenga el foco.

      // La clausula TOOLTIP permite definir un texto de ayuda que aparecera
      // automaticamente cuando el mouse pasa sobre el control.

      DEFINE TEXTBOX Text_1
         ROW     60
         COL     60
         WIDTH       195
         ONENTER     If ( Busqueda() == .T. , ( Win_2.Grid_2.Value := 1 , Win_2.Grid_2.SetFocus ) , Nil )
         TOOLTIP     'Buscar (Ingrese "*" para todos los registros)'
         UPPERCASE   .T.
      END TEXTBOX

      // La clausula PICTURE permite definir un archivo de imagen
      // que se asociara al control.

      DEFINE BUTTON Button_1
         ROW 60
         COL 265
         WIDTH   25
         HEIGHT  25
         PICTURE 'buscar'
         ACTION If ( Busqueda() == .T. , ( Win_2.Grid_2.Value := 1 , Win_2.Grid_2.SetFocus ) , Nil )
         TOOLTIP 'Buscar'
      END BUTTON

      // El control GRID permite mostrar datos en forma de tabla.
      // La clausula HEADERS requiere un array de caracteres conteniendo
      // los encabezados de las columnas del control.
      // La clausula WIDTHS requiere un array numerico conteniendo
      // los anchos de las columnas del control.

      DEFINE GRID Grid_2
         ROW 95
         COL 10
         WIDTH 280
         HEIGHT 310
         HEADERS { 'Codigo' , 'Descripcion' }
         WIDTHS { 60 , 220 }
         ROWSOURCE "Tipos"
         COLUMNFIELDS { 'Cod_Tipo' , 'Desc' }
         ON DBLCLICK Modificar()
         ALLOWEDIT .F.
         ALLOWAPPEND .F.
         ALLOWDELETE .T.
         CELLNAVIGATION .F.
      END GRID

   END WINDOW
   Win_2.Text_1.SetFocus
   CENTER WINDOW Win_2
   ACTIVATE WINDOW Win_2

   RETURN NIL

FUNCTION Busqueda

   LOCAL RetVal := .F. , nRecCount := 0

   IF Empty( Win_2.Text_1.Value )

      RETURN RetVal
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

   Win_2.Grid_2.DeleteAllItems
   SELECT Tipos
   SET Order To Tag Desc
   IF AllTrim (AllTrim(Win_2.Text_1.Value)) == '*'
      GO TOP
      DO WHILE .Not. Eof()
         nRecCount++
         Win_2.Grid_2.AddItem ( { Str(Tipos->Cod_Tipo) , Tipos->Desc } )
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
         DO WHILE HMG_Upper(Tipos->Desc) = AllTrim(Win_2.Text_1.Value)
            nRecCount++
            Win_2.Grid_2.AddItem ( { Str(Tipos->Cod_Tipo) , Tipos->Desc } )
            SKIP
         ENDDO
         RetVal := .T.
         Win_2.StatusBar.Item(1) := AllTrim(Str(nRecCount)) + ' Registros Encontrados'
      ELSE
         Win_2.StatusBar.Item(1) := 'No se encontraron registros'
      ENDIF
   ENDIF
   DBSetOrder(1)

   RETURN RetVal

FUNCTION Agregar

   LOCAL cDesc

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
      DBSELECTAREA( 'Tipos')
      DBSetOrder(1)
      IF flock()
         Go Bottom
         nCod_Tipo := Tipos->Cod_Tipo + 1
         APPEND BLANK
         Tipos->Cod_Tipo := nCod_Tipo
         Tipos->Desc := cDesc
         IF ( Busqueda() == .T. , ( Win_2.Grid_2.Value := 1 , Win_2.Grid_2.SetFocus ) , Nil )
         ELSE
            MsgStop ('Operacion Cancelada: El Archivo esta siendo actualizado por otro usuario. Reintente mas tarde')
         ENDIF
      ENDIF
      DBSetOrder(1)

      RETURN

FUNCTION Borrar

   LOCAL nRecno:=Win_2.Grid_2.RecNo

   // Si la propiedad 'Value' en un GRID es cero, significa que no hay
   // items seleccionados

   // La funcion 'MsgYestNo' muestra una ventana con un texto (primer parametro)
   // un titulo (segundo parametro) y botones 'Si' y 'No'.
   // Si se selecciona el boton 'Si' la funcion retorna .t.
   // Seleccionando 'No' la funcion retorna .F.

   IF nRecno == 0
      MsgStop ('No hay registros seleccionados','Borrar Registro')

      RETURN
   ENDIF

   IF MsgYesNo ( 'Esta Seguro' , 'Borrar Registro' )
      GOTO nRecno
      IF rlock()
         DBSetOrder(3)
         IF Contactos->(DbSeek(Tipos->Cod_Tipo))
            MsgStop('Operacion cancelada: El registro esta asociado a uno o mas contactos. No puede eliminarse','Borrar registro')
         ELSE
            DELETE
            IF ( Busqueda() == .T. , ( Win_2.Grid_2.Value := 1 , Win_2.Grid_2.SetFocus ) , Nil )
            ENDIF
         ELSE
            MsgStop('Operacion cancelada: El registro esta siendo editado por otro usuario. reintente mas tarde','Borrar registro')
         ENDIF
      ENDIF
      DBSetOrder(1)

      RETURN

FUNCTION Modificar

   LOCAL nRecno:=Win_2.Grid_2.Recno
   LOCAL cDesc

   // La propiedad 'Item' del control GRID retorna un array de caracteres con
   // tantos elementos como columnas tenga el control.

   IF nRecno == 0
      MsgStop ('No hay registros seleccionados','Editar Registro')

      RETURN
   ENDIF

   SELECT Tipos
   GOTO nRecno
   cDesc := InputBox ( 'Descripcion:','Editar Registro', AllTrim(Tipos->Desc))
   IF Empty ( cDesc )

      RETURN NIL
   ENDIF
   IF RLock()
      Tipos->Desc := cDesc
      UNLOCK
      Win_2.Grid_2.Refresh
      Win_2.Grid_2.Value:={nRecno,2}
   ELSE
      MsgStop('Operacion cancelada: El registro esta siendo editado por otro usuario. reintente mas tarde','Editar Registro')
   ENDIF

   RETURN NIL

FUNCTION Impresion()

   SELECT Tipos
   //  Use Tipos Index Tipos Shared New
   SET Order To Tag Cod_Tipo
   GO TOP

   DO REPORT                                       ;
      TITLE 'Tipos'                               ;
      HEADERS  {'',''} , {'Codigo','Descripcion'} ;
      FIELDS   {'Cod_Tipo','Desc'}                ;
      WIDTHS   {20,20}                            ;
      TOTALS   {.F.,.F.}                          ;
      WORKAREA Tipos                              ;
      LPP 50                                      ;
      CPL 80                                      ;
      LMARGIN 5                                   ;
      PREVIEW

   DBSetOrder(1)

   RETURN NIL

