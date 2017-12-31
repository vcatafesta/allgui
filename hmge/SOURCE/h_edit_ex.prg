/*
* Implementación del comando EDIT EXTENDED para la librería MiniGUI.
* (c) Cristóbal Mollá [cemese@terra.es]
* - Descripción -
* ===============
*      EDIT EXTENDED, es un comando que permite realizar el mantenimiento de una bdd. En principio
*      está diseñado para administrar bases de datos que usen los divers DBFNTX y DBFCDX,
*      presentando otras bases de datos con diferentes drivers resultados inesperados.
* - Sintáxis -
* ============
*      Todos los parámetros del comando EDIT son opcionales.
*      EDIT EXTENDED                           ;
*       [ WORKAREA cWorkArea ]                 ;
*       [ TITLE cTitle ]                       ;
*       [ FIELDNAMES acFieldNames ]            ;
*       [ FIELDMESSAGES acFieldMessages ]      ;
*       [ FIELDENABLED alFieldEnabled ]        ;
*       [ TABLEVIEW alTableView ]              ;
*       [ OPTIONS aOptions ]                   ;
*       [ ON SAVE bSave ]                      ;
*       [ ON FIND bFind ]                      ;
*       [ ON PRINT bPrint ]
*      Si no se pasa ningún parámetro, el comando EDIT toma como bdd de trabajo la del
*      area de trabajo actual.
*      [cWorkArea]             Cadena de texto con el nombre del alias de la base de datos
*                              a editar. Por defecto el alias de la base de datos activa.
*      [cTitle]                Cadena de texto con el título de la ventana de visualización
*                              de registros. Por defecto se toma el alias de la base de datos
*                              activa.
*      [acFieldNames]          Matriz de cadenas de texto con el nombre descriptivo de los
*                              campos de la base de datos. Tiene que tener el mismo número
*                              de elementos que campos la bdd. Por defecto se toma el nombre
*                              de los campos de la estructura de la bdd.
*      [acFieldMessages]       Matriz de cadenas de texto con el texto que aparaecerá en la
*                              barra de estado cuando se este añadiento o editando un registro.
*                              Tiene que tener el mismo numero de elementos que campos la bdd.
*                              Por defecto se rellena con valores internos.
*      [alFieldEnabled]        Matriz de valores lógicos que indica si el campo referenciado
*                              por la matriz esta activo durante la edición de registro. Tiene
*                              que tener el mismo numero de elementos que campos la bdd. Por
*                              defecto toma todos los valores como verdaderos ( .t. ).
*      [alTableView]           Matriz de valores lógicos que indica si el campo referenciado
*                              por la matriz es visible en la tabla. Tiene que tener el mismo
*                              numero de elementos que campos la bdd. Por defecto toma todos
*                              los valores como verdaderos ( .t. ).
*                              Array of logical values that it indicates if the referenced field
*                              by the array is visible in the table. It must have the same one
*                              number of elements as fields count of edited dbf.
*                              By default it takes all the values as true (t.).
*      [aOptions]              Matriz de 2 niveles. el primero de tipo texto es la descripción
*                              de la opción. El segundo de tipo bloque de código es la opción
*                              a ejecutar cuando se selecciona. Si no se pasa esta variable,
*                              se desactiva la lista desplegable de opciones.
*                              Array of 2 elements subarrays. First element( character type)
*                              it is the description of the option. The second (codeblock type)
*                              will evaluate when it is selected. If this variable does not go,
*                              the drop-down list of options is deactivated.
*                              By default this array is empty.
*      [bSave]                 Bloque de codigo con el formato {|aValores, lNuevo| Accion } que
*                              se ejecutará al pulsar la tecla de guardar registro. Se pasan
*                              las variables aValores con el contenido del registro a guardar y
*                              lNuevo que indica si se está añadiendo (.t.) o editando (.f.).
*                              Esta variable ha de devolver .t. para salir del modo de edición.
*                              Por defecto se graba con el código de la función.
*      [bFind]                 Bloque de codigo a ejecutar cuando se pulsa la tecla de busqueda.
*                              Por defecto se usa el código de la función.
*      [bPrint]                Bloque de código a ejecutar cuando se pulsa la tecla de listado.
*                              Por defecto se usa el codigo de la función.
* - Historial -
* =============
*      Mar 03  - Definición de la función.
*              - Pruebas.
*              - Soporte para lenguaje en inglés.
*              - Corregido bug al borrar en bdds con CDX.
*              - Mejora del control de parámetros.
*              - Mejorada la función de de busqueda.
*              - Soprte para multilenguaje.
*              - Versión 1.0 lista.
*      Abr 03  - Corregido bug en la función de busqueda (Nombre del botón).
*              - Añadido soporte para idioma Ruso (Grigory Filiatov).
*              - Añadido soporte para idioma Catalán (Por corregir).
*              - Añadido soporte para idioma Portugués (Clovis Nogueira Jr).
*              - Añadido soporte para idioma Polaco (Janusz Poura).
*              - Añadido soporte para idioma Francés (C. Jouniauxdiv).
*      May 03  - Añadido soporte para idioma Italiano (Lupano Piero).
*              - Añadido soporte para idioma Alemán (Janusz Poura).
*              - Cambio del formato de llamada al comando.
*              - La creación de ventanas se realiza en función del alto y ancho
*                de la pantalla.
*              - Se elimina la restricción de tamaño en los nombre de etiquetas.
*              - Se elimina la restricción de numero de campos del area de la bdd.
*              - Se elimina la restricción de que los campos tipo MEMO tienen que ir
*                al final de la base de datos.
*              - Se añade la opción de visualizar comentarios en la barra de estado.
*              - Se añade opción de control de visualización de campos en el browse.
*              - Se modifica el parámetro nombre del area de la bdd que pasa a ser
*                opcional.
*              - Se añade la opción de saltar al siguiente foco mediante la pulsación
*                de la tecla ENTER (Solo a controles tipo TEXTBOX).
*              - Se añade la opción de cambio del indice activo.
*              - Mejora de la rutina de busqueda.
*              - Mejora en la ventana de definición de listados.
*              - Pequeños cambios en el formato del listado.
*              - Actualización del soporte multilenguaje.
*      Jun 03  - Pruebas de la versión 1.5
*              - Se implementan las nuevas opciones de la librería de Ryszard Rylko
*              - Se implementa el filtrado de la base de datos.
*      Ago 03  - Se corrige bug en establecimiento de filtro.
*              - Actualizado soporte para italiano (Arcangelo Molinaro).
*              - Actualizado soporte multilenguage.
*              - Actualizado el soporte para filtrado.
*      Sep 03  - Idioma Vasco listo. Gracias a Gerardo Fernández.
*              - Idioma Italaino listo. Gracias a Arcangelo Molinaro.
*              - Idioma Francés listo. Gracias a Chris Jouniauxdiv.
*              - Idioma Polaco listo. Gracias a Jacek Kubica.
*      Oct 03  - Solucionado problema con las clausulas ON FIND y ON PRINT, ahora
*                ya tienen el efecto deseado. Gracias a Grigory Filiatov.
*              - Se cambia la referencia a _ExtendedNavigation por _HMG_ExtendedNavigation
*                para adecuarse a la sintaxis de la construción 76.
*              - Idioma Alemán listo. Gracias a Andreas Wiltfang.
*      Nov 03  - Problema con dbs en set exclusive. Gracias a cas_minigui.
*              - Problema con tablas con pocos campos. Gracias a cas_minigui.
*              - Cambio en demo para ajustarse a nueva sintaxis RDD Harbour (DBFFPT).
*      Dic 03  - Ajuste de la longitud del control para fecha. Gracias a Laszlo Henning.
*      Ene 04  - Problema de bloqueo con SET DELETED ON. Gracias a Grigory Filiatov y Roberto L¢pez.
* - Limitaciones -
* ================
*      - No se pueden realizar busquedas por campos lógico o memo.
*      - No se pueden realizar busquedas en indices con claves compuestas, la busqueda
*        se realiza por el primer campo de la clave compuesta.
* - Por hacer -
* =============
*      - Implementar busqueda del siguiente registro.
*/

// Ficheros de definiciones.---------------------------------------------------
#include "minigui.ch"
#include "dbstruct.ch"
#include "winprint.ch"

// Declaración de definiciones.------------------------------------------------
// Generales.
#define ABM_CRLF                HB_OsNewLine()

// Estructura de la etiquetas.
#define ABM_LBL_LEN             5
#define ABM_LBL_NAME            1
#define ABM_LBL_ROW             2
#define ABM_LBL_COL             3
#define ABM_LBL_WIDTH           4
#define ABM_LBL_HEIGHT          5

// Estructura de los controles de edición.
#define ABM_CON_LEN             7
#define ABM_CON_NAME            1
#define ABM_CON_ROW             2
#define ABM_CON_COL             3
#define ABM_CON_WIDTH           4
#define ABM_CON_HEIGHT          5
#define ABM_CON_DES             6
#define ABM_CON_TYPE            7

// Tipos de controles de edición.
#define ABM_TEXTBOXC            1
#define ABM_TEXTBOXN            2
#define ABM_DATEPICKER          3
#define ABM_CHECKBOX            4
#define ABM_EDITBOX             5

// Estructura de las opciones de usuario.
#define ABM_OPC_TEXTO           1
#define ABM_OPC_BLOQUE          2

// Tipo de acción al definir las columnas del listado.
#define ABM_LIS_ADD             1
#define ABM_LIS_DEL             2

// Tipo de acción al definir los registros del listado.
#define ABM_LIS_SET1            1
#define ABM_LIS_SET2            2

#xtranslate Alltrim( Str( <i> ) ) => hb_NtoS( <i> )

// Declaración de variables globales.------------------------------------------
STATIC _cArea           /*as character*/            // Nombre del area de la bdd.
STATIC _aEstructura     /*as array*/                // Estructura de la bdd.
STATIC _aIndice         /*as array*/                // Nombre de los indices de la bdd.
STATIC _aIndiceCampo    /*as array*/                // Número del campo indice.
STATIC _nIndiceActivo   /*as array*/                // Indice activo.
STATIC _aNombreCampo    /*as array*/                // Nombre desciptivo de los campos de la bdd.
STATIC _aEditable       /*as array*/                // Indicador de si son editables.
STATIC _cTitulo         /*as character*/            // Título de la ventana.
STATIC _nAltoPantalla   /*as numeric*/              // Alto de la pantalla.
STATIC _nAnchoPantalla  /*as numeric*/              // Ancho de la pantalla.
STATIC _aEtiqueta       /*as array*/                // Datos de las etiquetas.
STATIC _aControl        /*as array*/                // Datos de los controles.
STATIC _aCampoTabla     /*as array*/                // Nombre de los campos para la tabla.
STATIC _aAnchoTabla     /*as array*/                // Anchos de los campos para la tabla.
STATIC _aCabeceraTabla  /*as array*/                // Texto de las columnas de la tabla.
STATIC _aAlineadoTabla  /*as array*/                // Alineación de las columnas de la tabla.
STATIC _aVisibleEnTabla /*as array*/                // Campos visibles en la tabla.
STATIC _nControlActivo  /*as numeric*/              // Control con foco.
STATIC _aOpciones       /*as array*/                // Opciones del usuario.
STATIC _bGuardar        /*as codeblock*/            // Acción para guardar registro.
STATIC _bBuscar         /*as codeblock*/            // Acción para buscar registro.
STATIC _bImprimir       /*as codeblock*/            // Acción para imprimir listado.
STATIC _lFiltro         /*as logical*/              // Indicativo de filtro activo.
STATIC _cFiltro         /*as character*/            // Condición de filtro.

/****************************************************************************************
*  Aplicación: Comando EDIT para MiniGUI
*       Autor: Cristóbal Mollá [cemese@terra.es]
*     Función: ABM()
* Descripción: Función inicial. Comprueba los parámetros pasados, crea la estructura
*              para las etiquetas y controles de edición y crea la ventana de visualización
*              de registro.
*  Parámetros: cArea           Nombre del area de la bdd. Por defecto se toma el area
*                              actual.
*              cTitulo         Título de la ventana de edición. Por defecto se toma el
*                              nombre de la base de datos actual.
*              aNombreCampo    Matriz de valores carácter con los nombres descriptivos de
*                              los campos de la bdd.
*              aAvisoCampo     Matriz con los textos que se presentarán en la barra de
*                              estado al editar o añadir un registro.
*              aEditable       Matriz de valóre lógicos que indica si el campo referenciado
*                              esta activo en la ventana de edición de registro.
*              aVisibleEnTabla Matriz de valores lógicos que indica la visibilidad de los
*                              campos del browse de la ventana de edición.
*              aOpciones       Matriz con los valores de las opciones de usuario.
*              bGuardar        Bloque de código para la acción de guardar registro.
*              bBuscar         Bloque de código para la acción de buscar registro.
*              bImprimir       Bloque de código para la acción imprimir.
*    Devuelve: NIL
****************************************************************************************/

FUNCTION ABM2( cArea, cTitulo, aNombreCampo, ;
      aAvisoCampo, aEditable, aVisibleEnTabla, ;
      aOpciones, bGuardar, bBuscar, bImprimir )

   // ------- Declaración de variables locales.-----------------------------------
   LOCAL   i              /*as numeric*/   // Indice de iteración.
   LOCAL   k              /*as numeric*/   // Indice de iteración.
   LOCAL   nArea          as numeric       // Numero del area de la bdd.
   LOCAL   nRegistro      as numeric       // Número de regisrto de la bdd.
   LOCAL   nEstructura    /*as numeric*/   // Ancho del estructura de la bdd.
   LOCAL   lSalida        /*as logical*/   // Control de bucle.
   LOCAL   nVeces         /*as numeric*/   // Indice de iteración.
   LOCAL   cIndice        as character     // Nombre del indice.
   LOCAL   cIndiceActivo  as character     // Nombre del indice activo.
   LOCAL   cClave         as character     // Clave del indice.
   LOCAL   nInicio        /*as numeric*/   // Inicio de la cadena de busqueda.
   LOCAL   nAnchoCampo    /*as numeric*/   // Ancho del campo actual.
   LOCAL   nAnchoEtiqueta /*as numeric*/   // Ancho máximo de las etiquetas.
   LOCAL   nFila          /*as numeric*/   // Fila de creación del control de edición.
   LOCAL   nColumna       /*as numeric*/   // Columna de creación del control de edición.
   LOCAL   aTextoOp       /*as numeric*/   // Texto de las opciones de usuario.
   LOCAL   _BakExtendedNavigation          // Estado de SET NAVIAGTION.
   LOCAL   _BackDeleted                    // Estado de SET DELETED.
   LOCAL   cFiltroAnt     as character     // Condición del filtro anterior.

   // ------- Gusrdar estado actual de SET DELETED y activarlo
   _BackDeleted := set( _SET_DELETED )
   SET DELETED OFF

   // ------- Inicialización del soporte multilenguaje.---------------------------
   InitMessages()

   // ------- Desactivación de SET NAVIGATION.------------------------------------
   _BakExtendedNavigation  := _HMG_ExtendedNavigation
   _HMG_ExtendedNavigation := .F.

   // ------- Control de parámetros.----------------------------------------------
   // Area de la base de datos.
   IF ValType( cArea ) != "C" .or. Empty( cArea )
      _cArea := Alias()
      IF _cArea == ""
         msgExclamation( _HMG_aLangUser[ 1 ], "EDIT EXTENDED" )

         RETURN NIL
      ENDIF
   ELSE
      _cArea := cArea
   ENDIF
   _aEstructura := ( _cArea )->( dbStruct() )
   nEstructura := Len( _aEstructura )

   // Título de la ventana.
   IF Empty( cTitulo ) .or. Valtype( cTitulo ) != "C"
      _cTitulo := _cArea
   ELSE
      _cTitulo := cTitulo
   ENDIF

   // Nombres de los campos.
   lSalida := .t.
   IF ValType( aNombreCampo ) != "A"
      lSalida := .f.
   ELSE
      IF Len( aNombreCampo ) != nEstructura
         lSalida := .f.
      ELSE
         FOR i := 1 to Len( aNombreCampo )
            IF ValType( aNombreCampo[ i ] ) != "C"
               lSalida := .f.
               EXIT
            ENDIF
         NEXT
      ENDIF
   ENDIF
   IF lSalida
      _aNombreCampo := aNombreCampo
   ELSE
      _aNombreCampo := {}
      FOR i := 1 to nEstructura
         aAdd( _aNombreCampo, Upper( Left( _aEstructura[ i, DBS_NAME ], 1 ) ) + ;
            Lower( SubStr( _aEstructura[ i, DBS_NAME ], 2 ) ) )
      NEXT
   ENDIF

   // Texto de aviso en la barra de estado de la ventana de edición de registro.
   lSalida := .t.
   IF ValType( aAvisoCampo ) != "A"
      lSalida := .f.
   ELSE
      IF Len( aAvisoCampo ) != nEstructura
         lSalida := .f.
      ELSE
         FOR i := 1 to Len( aAvisoCampo )
            IF Valtype( aAvisoCampo[ i ] ) != "C"
               lSalida := .f.
               EXIT
            ENDIF
         NEXT
      ENDIF
   ENDIF
   IF !lSalida
      aAvisoCampo := {}
      FOR i := 1 to nEstructura
         DO CASE
         CASE _aEstructura[ i, DBS_TYPE ] == "C"
            aAdd( aAvisoCampo, _HMG_aLangUser[ 2 ] )
         CASE _aEstructura[ i, DBS_TYPE ] == "N"
            aAdd( aAvisoCampo, _HMG_aLangUser[ 3 ] )
         CASE _aEstructura[ i, DBS_TYPE ] == "D"
            aAdd( aAvisoCampo, _HMG_aLangUser[ 4 ] )
         CASE _aEstructura[ i, DBS_TYPE ] == "L"
            aAdd( aAvisoCampo, _HMG_aLangUser[ 5 ] )
         CASE _aEstructura[ i, DBS_TYPE ] == "M"
            aAdd( aAvisoCampo, _HMG_aLangUser[ 6 ] )
         OTHERWISE
            aAdd( aAvisoCampo, _HMG_aLangUser[ 7 ] )
         ENDCASE
      NEXT
   ENDIF

   // Campos visibles en la tabla de la ventana de visualización de registros.
   lSalida := .t.
   IF Valtype( aVisibleEnTabla ) != "A"
      lSalida := .f.
   ELSE
      IF Len( aVisibleEnTabla ) != nEstructura
         lSalida := .f.
      ELSE
         FOR i := 1 to Len( aVisibleEnTabla )
            IF ValType( aVisibleEnTabla[ i ] ) != "L"
               lSalida := .f.
               EXIT
            ENDIF
         NEXT
      ENDIF
   ENDIF
   IF lSalida
      _aVisibleEnTabla := aVisibleEnTabla
   ELSE
      _aVisibleEnTabla := {}
      FOR i := 1 to nEstructura
         aAdd( _aVisibleEnTabla, .t. )
      NEXT
   ENDIF

   // Estado de los campos en la ventana de edición de registro.
   lSalida := .t.
   IF ValType( aEditable ) != "A"
      lSalida := .f.
   ELSE
      IF Len( aEditable ) != nEstructura
         lSalida := .f.
      ELSE
         FOR i := 1 to Len( aEditable )
            IF ValType( aEditable[ i ] ) != "L"
               lSalida := .f.
               EXIT
            ENDIF
         NEXT
      ENDIF
   ENDIF
   IF lSalida
      _aEditable := aEditable
   ELSE
      _aEditable := {}
      FOR i := 1 to nEstructura
         aAdd( _aEditable, .t. )
      NEXT
   ENDIF

   // Opciones del usuario.
   lSalida := .t.

   IF ValType( aOpciones ) != "A"
      lSalida := .f.
   ELSEIF len( aOpciones ) < 1
      lSalida := .f.
   ELSEIF Len( aOpciones[ 1 ] ) != 2
      lSalida := .f.
   ELSE
      FOR i := 1 to Len( aOpciones )
         IF ValType( aOpciones[i, ABM_OPC_TEXTO ] ) != "C" .or. ;
               ValType( aOpciones[i, ABM_OPC_BLOQUE ] ) != "B"
            lSalida := .f.
            EXIT
         ENDIF
      NEXT
   ENDIF

   IF lSalida
      _aOpciones := aOpciones
   ELSE
      _aOpciones := {}
   ENDIF

   // Acción al guardar.
   IF ValType( bGuardar ) == "B"
      _bGuardar := bGuardar
   ELSE
      _bGuardar := NIL
   ENDIF

   // Acción al buscar.
   IF ValType( bBuscar ) == "B"
      _bBuscar := bBuscar
   ELSE
      _bBuscar := NIL
   ENDIF

   // Acción al buscar.
   IF ValType( bImprimir ) == "B"
      _bImprimir := bImprimir
   ELSE
      _bImprimir := NIL
   ENDIF

   // ------- Selección del area de la bdd.---------------------------------------
   nRegistro     := ( _cArea )->( RecNo() )
   nArea         := Select()
   cIndiceActivo := ( _cArea )->( ordSetFocus() )
   cFiltroAnt    := ( _cArea )->( dbFilter() )
   dbSelectArea( _cArea )
   ( _cArea )->( dbGoTop() )

   // ------- Inicialización de variables.----------------------------------------
   // Filtro.
   _cFiltro := cFiltroAnt
   _lFiltro := !( Empty( _cFiltro ) )

   // Indices de la base de datos.
   lSalida       := .t.
   k             := 1
   _aIndice      := {}
   _aIndiceCampo := {}
   nVeces        := 1
   aAdd( _aIndice, _HMG_aLangLabel[ 1 ] )
   aAdd( _aIndiceCampo, 0 )
   DO WHILE lSalida
      IF Empty( ( _cArea )->( ordName( k ) ) )
         lSalida := .f.
      ELSE
         cIndice := Upper( ( _cArea )->( ordName( k ) ) )
         aAdd( _aIndice, cIndice )
         cClave := Upper( ( _cArea )->( ordKey( k ) ) )
         FOR i := 1 to nEstructura
            IF nVeces <= 1
               nInicio := At( _aEstructura[ i, DBS_NAME ], cClave )
               IF  nInicio != 0
                  aAdd( _aIndiceCampo, i )
                  nVeces++
               ENDIF
            ENDIF
         NEXT
      ENDIF
      k++
      nVeces := 1
   ENDDO

   // Numero de indice.
   IF Empty( cIndiceActivo )
      _nIndiceActivo := 1
   ELSE
      _nIndiceActivo := aScan( _aIndice, Upper( ( _cArea )->( ordSetFocus() ) ) )
   ENDIF

   // Tamaño de la pantalla.
   _nAltoPantalla  := getDesktopHeight()
   _nAnchoPantalla := getDesktopWidth()

   // Datos de las etiquetas y los controles de la ventana de edición.
   _aEtiqueta     := Array( nEstructura, ABM_LBL_LEN )
   _aControl      := Array( nEstructura, ABM_CON_LEN )
   nFila          := 10
   nColumna       := 10
   nAnchoEtiqueta := 0
   FOR i := 1 to Len( _aNombreCampo )
      nAnchoEtiqueta := iif( nAnchoEtiqueta > ( Len( _aNombreCampo[ i ] ) * 9 ), ;
         nAnchoEtiqueta, ;
         Len( _aNombreCampo[ i ] ) * 9 )
   NEXT
   FOR i := 1 to nEstructura
      _aEtiqueta[ i, ABM_LBL_NAME ]   := "ABM2Etiqueta" + AllTrim( Str( i ) )
      _aEtiqueta[ i, ABM_LBL_ROW ]    := nFila
      _aEtiqueta[ i, ABM_LBL_COL ]    := nColumna
      _aEtiqueta[ i, ABM_LBL_WIDTH ]  := Len( _aNombreCampo[ i ] ) * 9
      _aEtiqueta[ i, ABM_LBL_HEIGHT ] := 25
      SWITCH Left( _aEstructura[ i, DBS_TYPE ], 1 )
      CASE "C"
         _aControl[ i, ABM_CON_NAME ]   := "ABM2Control" + AllTrim( Str( i ) )
         _aControl[ i, ABM_CON_ROW ]    := nFila
         _aControl[ i, ABM_CON_COL ]    := nColumna + nAnchoEtiqueta + 20
         _aControl[ i, ABM_CON_WIDTH ]  := iif( ( _aEstructura[ i, DBS_LEN ] * 10 ) < 50, 50, _aEstructura[ i, DBS_LEN ] * 10 )
         _aControl[ i, ABM_CON_HEIGHT ] := 25
         _aControl[ i, ABM_CON_DES ]    := aAvisoCampo[ i ]
         _aControl[ i, ABM_CON_TYPE ]   := ABM_TEXTBOXC
         EXIT
      CASE "D"
         _aControl[ i, ABM_CON_NAME ]   := "ABM2Control" + AllTrim( Str( i ) )
         _aControl[ i, ABM_CON_ROW ]    := nFila
         _aControl[ i, ABM_CON_COL ]    := nColumna + nAnchoEtiqueta + 20
         _aControl[ i, ABM_CON_WIDTH ]  := _aEstructura[ i, DBS_LEN ] * 10
         _aControl[ i, ABM_CON_HEIGHT ] := 25
         _aControl[ i, ABM_CON_DES ]    := aAvisoCampo[ i ]
         _aControl[ i, ABM_CON_TYPE ]   := ABM_DATEPICKER
         EXIT
      CASE "N"
         _aControl[ i, ABM_CON_NAME ]   := "ABM2Control" + AllTrim( Str( i ) )
         _aControl[ i, ABM_CON_ROW ]    := nFila
         _aControl[ i, ABM_CON_COL ]    := nColumna + nAnchoEtiqueta + 20
         _aControl[ i, ABM_CON_WIDTH ]  := iif( ( _aEstructura[ i, DBS_LEN ] * 10 ) < 50, 50, _aEstructura[ i, DBS_LEN ] * 10 )
         _aControl[ i, ABM_CON_HEIGHT ] := 25
         _aControl[ i, ABM_CON_DES ]    := aAvisoCampo[ i ]
         _aControl[ i, ABM_CON_TYPE ]   := ABM_TEXTBOXN
         EXIT
      CASE "L"
         _aControl[ i, ABM_CON_NAME ]   := "ABM2Control" + AllTrim( Str( i ) )
         _aControl[ i, ABM_CON_ROW ]    := nFila
         _aControl[ i, ABM_CON_COL ]    := nColumna + nAnchoEtiqueta + 20
         _aControl[ i, ABM_CON_WIDTH ]  := 25
         _aControl[ i, ABM_CON_HEIGHT ] := 25
         _aControl[ i, ABM_CON_DES ]    := aAvisoCampo[ i ]
         _aControl[ i, ABM_CON_TYPE ]   := ABM_CHECKBOX
         EXIT
      CASE "M"
         _aControl[ i, ABM_CON_NAME ]   := "ABM2Control" + AllTrim( Str( i ) )
         _aControl[ i, ABM_CON_ROW ]    := nFila
         _aControl[ i, ABM_CON_COL ]    := nColumna + nAnchoEtiqueta + 20
         _aControl[ i, ABM_CON_WIDTH ]  := 300
         _aControl[ i, ABM_CON_HEIGHT ] := 70
         _aControl[ i, ABM_CON_DES ]    := aAvisoCampo[ i ]
         _aControl[ i, ABM_CON_TYPE ]   := ABM_EDITBOX
         nFila += 45
      ENDSWITCH
      IF _aEstructura[ i, DBS_TYPE ] $ "CDNLM"
         nFila += 35
      ENDIF
   NEXT

   // Datos de la tabla de la ventana de visualización.

   _aCampoTabla    := { "if(deleted(), 'X', ' ')" }
   _aAnchoTabla    := { 20 }
   _aCabeceraTabla := { "X" }
   _aAlineadoTabla := { BROWSE_JTFY_LEFT }

   FOR i := 1 to nEstructura
      IF _aVisibleEnTabla[ i ]
         aAdd( _aCampoTabla, _cArea + "->" + _aEstructura[ i, DBS_NAME ] )
         nAnchoCampo    := iif( ( _aEstructura[ i, DBS_LEN ] * 10 ) < 50,   ;
            50,                                    ;
            _aEstructura[ i, DBS_LEN ] * 10 )
         nAnchoEtiqueta := Len( _aNombreCampo[ i ] ) * 10
         aAdd( _aAnchoTabla, iif( nAnchoEtiqueta > nAnchoCampo,          ;
            nAnchoEtiqueta,                        ;
            nAnchoCampo ) )
         aAdd( _aCabeceraTabla, _aNombreCampo[ i ] )

         IF _aEstructura[ i, DBS_TYPE ] == "L"
            aAdd( _aAlineadoTabla, BROWSE_JTFY_CENTER )
         ELSEIF _aEstructura[ i, DBS_TYPE ] == "D"
            aAdd( _aAlineadoTabla, BROWSE_JTFY_CENTER )
         ELSEIF _aEstructura[ i, DBS_TYPE ] == "N"
            aAdd( _aAlineadoTabla, BROWSE_JTFY_RIGHT )
         ELSE
            aAdd( _aAlineadoTabla, BROWSE_JTFY_LEFT )
         ENDIF
      ENDIF
   NEXT

   // ------- Definición de la ventana de visualización.--------------------------
   DEFINE WINDOW wndABM2Edit               ;
         at 60, 30                       ;
         width _nAnchoPantalla - 60      ;
         height _nAltoPantalla - 140     ;
         title _cTitulo                  ;
         modal                           ;
         nosize                          ;
         nosysmenu                       ;
         on init {|| ABM2Redibuja() }    ;
         on release {|| ABM2salir( nRegistro, cIndiceActivo, cFiltroAnt, nArea ) } ;
         font _GetSysFont() size 9

      // Define la barra de estado de la ventana de visualización.
      DEFINE STATUSBAR font _GetSysFont() size 9
         statusitem _HMG_aLangLabel[ 19 ]                         // 1
         statusitem _HMG_aLangLabel[ 20 ]      width 100 raised   // 2
         statusitem _HMG_aLangLabel[ 2 ] + ': ' width 200 raised  // 3
      END STATUSBAR

      // Define la barra de botones de la ventana de visualización.
      DEFINE TOOLBAR tbEdit buttonsize 100, 32 flat righttext border
         button tbbCerrar  caption _HMG_aLangButton[ 1 ]  ;
            picture "MINIGUI_EDIT_CLOSE"  ;
            action  wndABM2Edit.Release
         button tbbNuevo   caption _HMG_aLangButton[ 2 ]  ;
            picture "MINIGUI_EDIT_NEW"  ;
            action  {|| ABM2Editar( .t. ) }
         button tbbEditar  caption _HMG_aLangButton[ 3 ]  ;
            picture "MINIGUI_EDIT_EDIT"  ;
            action  {|| ABM2Editar( .f. ) }
         button tbbBorrar  caption _HMG_aLangButton[ 4 ]  ;
            picture "MINIGUI_EDIT_DELETE"  ;
            action  {|| ABM2Borrar() }
         button tbbRecover caption _HMG_aLangButton[ 12 ]  ;
            picture "MINIGUI_EDIT_UNDO"  ;
            action  {|| ABM2Recover() }
         button tbbBuscar  caption _HMG_aLangButton[ 5 ]  ;
            picture "MINIGUI_EDIT_FIND"  ;
            action  {|| ABM2Buscar() }
         button tbbListado caption _HMG_aLangButton[ 6 ]  ;
            picture "MINIGUI_EDIT_PRINT"  ;
            action  {|| ABM2Imprimir() }
      END toolbar

   END WINDOW

   // ------- Creación de los controles de la ventana de visualización.-----------
   @ 50, 10 frame frmEditOpciones          ;
      of wndABM2Edit                  ;
      caption ""                      ;
      width wndABM2Edit.Width - 25    ;
      height 60
   @ 112, 10 frame frmEditTabla            ;
      of wndABM2Edit                  ;
      caption ""                      ;
      width wndABM2Edit.Width - 25    ;
      height wndABM2Edit.Height - 165
   @ 60, 20 label lblIndice               ;
      of wndABM2Edit                  ;
      value _HMG_aLangUser[26 ]       ;
      autosize                        ;
      font _GetSysFont() size 9
   @ 75, 20 combobox cbIndices             ;
      of wndABM2Edit                  ;
      items _aIndice                  ;
      value _nIndiceActivo            ;
      width 150                       ;
      font _GetSysFont() size 9     ;
      on change {|| ABM2CambiarOrden() }
   nColumna := wndABM2Edit.Width - 175
   aTextoOp := {}
   FOR i := 1 to Len( _aOpciones )
      aAdd( aTextoOp, _aOpciones[ i, ABM_OPC_TEXTO ] )
   NEXT
   @ 60, nColumna label lblOpciones        ;
      of wndABM2Edit                  ;
      value _HMG_aLangLabel[5 ]       ;
      autosize                        ;
      font _GetSysFont() size 9
   @ 75, nColumna combobox cbOpciones      ;
      of wndABM2Edit                  ;
      items aTextoOp                  ;
      value 1                         ;
      width 150                       ;
      font _GetSysFont() size 9     ;
      on change {|| ABM2EjecutaOpcion() }
   @ 65, ( wndABM2Edit.Width / 2 ) -110 button btnFiltro1  ;
      of wndABM2Edit                                  ;
      caption _HMG_aLangButton[ 10 ]                  ;
      action {|| ABM2ActivarFiltro() }                ;
      width 100                                       ;
      height 32                                       ;
      font _GetSysFont() size 9
   @ 65, ( wndABM2Edit.Width / 2 ) + 5 button btnFiltro2   ;
      of wndABM2Edit                                  ;
      caption _HMG_aLangButton[ 11 ]                  ;
      action {|| ABM2DesactivarFiltro() }             ;
      width 100                                       ;
      height 32                                       ;
      font _GetSysFont() size 9
   @ 132, 20 browse brwABM2Edit                                                    ;
      of wndABM2Edit                                                          ;
      width wndABM2Edit.Width - 45                                            ;
      height wndABM2Edit.Height - 195                                         ;
      headers _aCabeceraTabla                                                 ;
      widths _aAnchoTabla                                                     ;
      workarea &_cArea                                                        ;
      fields _aCampoTabla                                                     ;
      value ( _cArea )->( RecNo() )                                           ;
      font _GetSysFont() size 9                                             ;
      on change {|| ( _cArea )->( dbGoto( wndABM2Edit .brwABM2Edit. Value ) ),    ;
      ABM2Redibuja( .f. ) }                                     ;
      on dblclick {|| iif( wndABM2Edit .tbbEditar. Enabled, ABM2Editar( .f. ), ) }  ;
      justify _aAlineadoTabla paintdoublebuffer

   // Comprueba el estado de las opciones de usuario.
   IF Len( _aOpciones ) == 0
      wndABM2Edit .cbOpciones. Enabled := .f.
   ENDIF

   // ------- Activación de la ventana de visualización.--------------------------
   ACTIVATE WINDOW wndABM2Edit

   // ------- Restauración de SET NAVIGATION.-------------------------------------
   _HMG_ExtendedNavigation := _BakExtendedNavigation

   // ------- Restaurar SET DELETED a su valor inicial
   set( _SET_DELETED, _BackDeleted  )

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para MiniGUI
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2salir()
   * Descripción: Cierra la ventana de visualización de registros y sale.
   *  Parámetros: Ninguno.
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABM2salir( nRegistro, cIndiceActivo, cFiltroAnt, nArea )

   // ------- Declaración de variables locales.-----------------------------------
   LOCAL bFiltroAnt as codeblock           // Bloque de código del filtro.

   // ------- Inicialización de variables.----------------------------------------
   bFiltroAnt := iif( Empty( cFiltroAnt ), ;
      &( "{||NIL}" ), ;
      &( "{||" + cFiltroAnt + "}" ) )

   // ------- Restaura el area de la bdd inicial.---------------------------------
   ( _cArea )->( dbGoTo( nRegistro ) )
   ( _cArea )->( ordSetFocus( cIndiceActivo ) )
   ( _cArea )->( dbSetFilter( bFiltroAnt, cFiltroAnt ) )
   dbSelectArea( nArea )

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para MiniGUI
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2Redibuja()
   * Descripción: Actualización de la ventana de visualización de registros.
   *  Parámetros: Ninguno
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABM2Redibuja( lTabla )

   // ------- Declaración de variables locales.-----------------------------------
   LOCAL lDeleted /*as logical*/

   // ------- Control de parámetros.----------------------------------------------
   IF ValType( lTabla ) != "L"
      lTabla := .f.
   ENDIF

   // ------- Refresco de la barra de botones.------------------------------------
   IF ( _cArea )->( RecCount() ) == 0
      wndABM2Edit .tbbEditar. Enabled  := .f.
      wndABM2Edit .tbbBorrar. Enabled  := .f.
      wndABM2Edit .tbbBuscar. Enabled  := .f.
      wndABM2Edit .tbbListado. Enabled := .f.
   ELSE
      lDeleted := Deleted()
      wndABM2Edit .tbbEditar. Enabled  := !lDeleted
      wndABM2Edit .tbbBorrar. Enabled  := !lDeleted
      wndABM2Edit .tbbBuscar. Enabled  := .t.
      wndABM2Edit .tbbRecover. Enabled := lDeleted
      wndABM2Edit .tbbListado. Enabled := .t.
   ENDIF

   // ------- Refresco de la barra de estado.-------------------------------------
   wndABM2Edit .StatusBar. Item( 1 ) := _HMG_aLangLabel[ 19 ] + _cFiltro
   wndABM2Edit .StatusBar. Item( 2 ) := _HMG_aLangLabel[ 20 ] + iif( _lFiltro, _HMG_aLangUser[ 29 ], _HMG_aLangUser[ 30 ] )
   wndABM2Edit .StatusBar. Item( 3 ) := _HMG_aLangLabel[ 2 ] + ': ' + ;
      AllTrim( Str( ( _cArea )->( RecNo() ) ) ) + "/" + ;
      AllTrim( Str( ( _cArea )->( RecCount() ) ) )

   // ------- Refresca el browse si se indica.
   IF lTabla
      wndABM2Edit .brwABM2Edit. Value := ( _cArea )->( RecNo() )
      wndABM2Edit .brwABM2Edit. Refresh
   ENDIF

   // ------- Coloca el foco en el browse.
   wndABM2Edit .brwABM2Edit. SetFocus

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para MiniGUI
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2CambiarOrden()
   * Descripción: Cambia el orden activo.
   *  Parámetros: Ninguno.
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABM2CambiarOrden()

   // ------- Declaración de variables locales.-----------------------------------
   LOCAL nIndice /*as numeric*/                // Número del indice.

   // ------- Inicializa las variables.-------------------------------------------
   nIndice := wndABM2Edit .cbIndices. Value - 1

   // ------- Cambia el orden del area de trabajo.--------------------------------
   ( _cArea )->( ordSetFocus( nIndice ) )
   // (_cArea)->( dbGoTop() )
   _nIndiceActivo := ++nIndice
   ABM2Redibuja( .t. )

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para MiniGUI
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2EjecutaOpcion()
   * Descripción: Ejecuta las opciones del usuario.
   *  Parámetros: Ninguno
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABM2EjecutaOpcion()

   // ------- Declaración de variables locales.-----------------------------------
   LOCAL nItem    /*as numeric*/           // Numero del item seleccionado.
   LOCAL bBloque  as codebloc              // Bloque de codigo a ejecutar.

   // ------- Inicialización de variables.----------------------------------------
   nItem   := wndABM2Edit .cbOpciones. Value
   bBloque := _aOpciones[ nItem, ABM_OPC_BLOQUE ]

   // ------- Ejecuta la opción.--------------------------------------------------
   Eval( bBloque )

   // ------- Refresca el browse.
   ABM2Redibuja( .t. )

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para MiniGUI
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2Editar( lNuevo )
   * Descripción: Creación de la ventana de edición de registro.
   *  Parámetros: lNuevo          Valor lógico que indica si se está añadiendo un registro
   *                              o editando el actual.
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABM2Editar( lNuevo )

   // ------- Declaración de variables locales.-----------------------------------
   LOCAL i              as numeric         // Indice de iteración.
   LOCAL nAnchoEtiqueta /*as numeric*/     // Ancho máximo de las etiquetas.
   LOCAL nAltoControl   /*as numeric*/     // Alto total de los controles de edición.
   LOCAL nAncho         /*as numeric*/     // Ancho de la ventana de edición .
   LOCAL nAlto          /*as numeric*/     // Alto de la ventana de edición.
   LOCAL nAnchoTope     /*as numeric*/     // Ancho máximo de la ventana de edición.
   LOCAL nAltoTope      /*as numeric*/     // Alto máximo de la ventana de edición.
   LOCAL nAnchoSplit    /*as numeric*/     // Ancho de la ventana Split.
   LOCAL nAltoSplit     /*as numeric*/     // Alto de la ventana Split.
   LOCAL cTitulo        as character       // Título de la ventana.
   LOCAL cMascara       as character       // Máscara de edición de los controles numéricos.
   LOCAL nAnchoControl  /*as numeric*/
   LOCAL cMacroTemp     as character

   // ------- Control de parámetros.----------------------------------------------
   IF ValType( lNuevo ) != "L"
      lNuevo := .t.
   ENDIF

   // ------- Incialización de variables.-----------------------------------------
   nAnchoEtiqueta := 0
   nAnchoControl  := 0
   nAltoControl   := 0
   FOR i := 1 to Len( _aEtiqueta )
      nAnchoEtiqueta := iif( nAnchoEtiqueta > _aEtiqueta[ i, ABM_LBL_WIDTH ], ;
         nAnchoEtiqueta, ;
         _aEtiqueta[ i, ABM_LBL_WIDTH ] )
      nAnchoControl  := iif( nAnchoControl > _aControl[ i, ABM_CON_WIDTH ], ;
         nAnchoControl, ;
         _aControl[ i, ABM_CON_WIDTH ] )
      nAltoControl   += _aControl[ i, ABM_CON_HEIGHT ] + 10
   NEXT
   nAltoSplit  := 10 + nAltoControl + 25
   nAnchoSplit := 10 + nAnchoEtiqueta + 10 + nAnchoControl + 25
   nAlto       := 80 + nAltoSplit + 15 + iif( IsXPThemeActive(), 10, 0 )
   nAltoTope   := _nAltoPantalla - 130
   nAncho      := 15 + nAnchoSplit + 15
   nAncho      := iif( nAncho < 300, 300, nAncho )
   nAnchoTope  := _nAnchoPantalla - 60
   cTitulo     := iif( lNuevo, _HMG_aLangLabel[ 6 ], _HMG_aLangLabel[ 7 ] )

   // ------- Define la ventana de edición de registro.---------------------------
   DEFINE WINDOW wndABM2EditNuevo                                  ;
         at 70, 40                                               ;
         width iif( nAncho > nAnchoTope, nAnchoTope, nAncho )    ;
         height iif( nAlto > nAltoTope, nAltoTope, nAlto )       ;
         title cTitulo                                           ;
         modal                                                   ;
         nosize                                                  ;
         nosysmenu                                               ;
         font _GetSysFont() size 9

      // Define la barra de estado de la ventana de edición de registro.
      DEFINE STATUSBAR font _GetSysFont() size 9
         statusitem ""
      END STATUSBAR

      DEFINE SPLITBOX

         // Define la barra de botones de la ventana de edición de registro.
         DEFINE TOOLBAR tbEditNuevo buttonsize 100, 32 flat righttext
            button tbbCancelar caption _HMG_aLangButton[ 7 ]          ;
               picture "MINIGUI_EDIT_CANCEL"        ;
               action  wndABM2EditNuevo.Release
            button tbbAceptar  caption _HMG_aLangButton[ 8 ]          ;
               picture "MINIGUI_EDIT_OK"            ;
               action  ABM2EditarGuardar( lNuevo )
            button tbbCopiar   caption _HMG_aLangButton[ 9 ]          ;
               picture "MINIGUI_EDIT_COPY"          ;
               action  ABM2EditarCopiar()
         END toolbar

         // Define la ventana donde van contenidos los controles de edición.
         DEFINE WINDOW wndABM2EditNuevoSplit             ;
               width iif( nAncho > nAnchoTope,         ;
               nAnchoTope - 10,             ;
               nAnchoSplit  - 1 )           ;
               height iif( nAlto > nAltoTope,          ;
               nAltoTope - 95,             ;
               nAltoSplit - 1 )            ;
               virtual width nAnchoSplit               ;
               virtual height nAltoSplit               ;
               splitchild                              ;
               nocaption                               ;
               font _GetSysFont() size 9             ;
               focused
         END WINDOW
      END SPLITBOX
   END WINDOW

   // ------- Define las etiquetas de los controles.------------------------------
   FOR i := 1 to Len( _aEtiqueta )

      cMacroTemp := _aEtiqueta[ i, ABM_LBL_NAME ]
      @ _aEtiqueta[ i, ABM_LBL_ROW ], _aEtiqueta[ i, ABM_LBL_COL ]  ;
         LABEL &cMacroTemp                               ;
         of wndABM2EditNuevoSplit                        ;
         value _aNombreCampo[ i ]                        ;
         width _aEtiqueta[ i, ABM_LBL_WIDTH ]            ;
         height _aEtiqueta[ i, ABM_LBL_HEIGHT ]          ;
         vcenteralign                                    ;
         font _GetSysFont() size 9
   NEXT

   // ------- Define los controles de edición.------------------------------------
   FOR i := 1 to Len( _aControl )
      DO CASE
      CASE _aControl[ i, ABM_CON_TYPE ] == ABM_TEXTBOXC

         cMacroTemp := _aControl[ i, ABM_CON_NAME ]
         @ _aControl[ i, ABM_CON_ROW ], _aControl[ i, ABM_CON_COL ]    ;
            textbox &cMacroTemp                             ;
            of wndABM2EditNuevoSplit                        ;
            value ""                                        ;
            height _aControl[ i, ABM_CON_HEIGHT ]           ;
            width _aControl[ i, ABM_CON_WIDTH ]             ;
            font "arial" size 9                             ;
            maxlength _aEstructura[ i, DBS_LEN ]            ;
            on gotfocus ABM2ConFoco()                       ;
            on lostfocus ABM2SinFoco()                      ;
            on enter ABM2AlEntrar()
      CASE _aControl[ i, ABM_CON_TYPE ] == ABM_DATEPICKER
         cMacroTemp := _aControl[ i, ABM_CON_NAME ]
         @ _aControl[ i, ABM_CON_ROW ], _aControl[ i, ABM_CON_COL ]    ;
            datepicker &cMacroTemp                          ;
            of wndABM2EditNuevoSplit                        ;
            height _aControl[ i, ABM_CON_HEIGHT ]           ;
            width _aControl[ i, ABM_CON_WIDTH ] + 25        ;
            font "arial" size 9                             ;
            SHOWNONE                                        ;
            on gotfocus ABM2ConFoco()                       ;
            on lostfocus ABM2SinFoco()
      CASE _aControl[ i, ABM_CON_TYPE ] == ABM_TEXTBOXN
         IF _aEstructura[ i, DBS_DEC ] == 0
            cMacroTemp := _aControl[ i, ABM_CON_NAME ]
            @ _aControl[ i, ABM_CON_ROW ], _aControl[ i, ABM_CON_COL ]    ;
               textbox &cMacroTemp                             ;
               of wndABM2EditNuevoSplit                        ;
               value ""                                        ;
               height _aControl[ i, ABM_CON_HEIGHT ]           ;
               width _aControl[ i, ABM_CON_WIDTH ]             ;
               numeric                                         ;
               font "arial" size 9                             ;
               maxlength _aEstructura[ i, DBS_LEN ]            ;
               on gotfocus ABM2ConFoco( i )                    ;
               on lostfocus ABM2SinFoco( i )                   ;
               on enter ABM2AlEntrar()
         ELSE
            cMascara := Replicate( "9", _aEstructura[ i, DBS_LEN ] - ( _aEstructura[ i, DBS_DEC ] + 1 ) )
            cMascara += "."
            cMascara += Replicate( "9", _aEstructura[ i, DBS_DEC ] )
            cMacroTemp := _aControl[ i, ABM_CON_NAME ]
            @ _aControl[ i, ABM_CON_ROW ], _aControl[ i, ABM_CON_COL ]    ;
               textbox &cMacroTemp                             ;
               of wndABM2EditNuevoSplit                        ;
               value ""                                        ;
               height _aControl[ i, ABM_CON_HEIGHT ]           ;
               width _aControl[ i, ABM_CON_WIDTH ]             ;
               numeric                                         ;
               inputmask cMascara                              ;
               on gotfocus ABM2ConFoco()                       ;
               on lostfocus ABM2SinFoco()                      ;
               on enter ABM2AlEntrar()
         ENDIF
      CASE _aControl[ i, ABM_CON_TYPE ] == ABM_CHECKBOX
         cMacroTemp := _aControl[ i, ABM_CON_NAME ]
         @ _aControl[ i, ABM_CON_ROW ], _aControl[ i, ABM_CON_COL ]    ;
            checkbox &cMacroTemp                            ;
            of wndABM2EditNuevoSplit                        ;
            caption ""                                      ;
            height _aControl[ i, ABM_CON_HEIGHT ]           ;
            width _aControl[ i, ABM_CON_WIDTH ]             ;
            value .f.                                       ;
            on gotfocus ABM2ConFoco()                       ;
            on lostfocus ABM2SinFoco()
      CASE _aControl[ i, ABM_CON_TYPE ] == ABM_EDITBOX
         cMacroTemp := _aControl[ i, ABM_CON_NAME ]
         @ _aControl[ i, ABM_CON_ROW ], _aControl[ i, ABM_CON_COL ]    ;
            editbox &cMacroTemp                             ;
            of wndABM2EditNuevoSplit                        ;
            width _aControl[ i, ABM_CON_WIDTH ]             ;
            height _aControl[ i, ABM_CON_HEIGHT ]           ;
            value ""                                        ;
            font "arial" size 9                             ;
            on gotfocus ABM2ConFoco()                       ;
            on lostfocus ABM2SinFoco()
      ENDCASE
   NEXT

   // ------- Actualiza los controles si se está editando.------------------------
   IF !lNuevo
      FOR i := 1 to Len( _aControl )
         SetProperty( "wndABM2EditNuevoSplit", _aControl[ i, ABM_CON_NAME ], "Value", ( _cArea )->( FieldGet( i ) ) )
      NEXT
   ENDIF

   // ------- Establece el estado inicial de los controles.-----------------------
   FOR i := 1 to Len( _aControl )
      SetProperty( "wndABM2EditNuevoSplit", _aControl[ i, ABM_CON_NAME ], "Enabled", _aEditable[ i ] )
   NEXT

   // ------- Establece el estado del botón de copia.-----------------------------
   IF !lNuevo
      wndABM2EditNuevo .tbbCopiar. Enabled := .f.
   ENDIF

   // ------- Activa la ventana de edición de registro.---------------------------
   on key escape ;
      of wndABM2EditNuevoSplit ;
      action wndABM2EditNuevo .tbbCancelar. onclick

   on key return ;
      of wndABM2EditNuevoSplit ;
      action wndABM2EditNuevo .tbbAceptar. onclick

   ACTIVATE WINDOW wndABM2EditNuevo

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para MiniGUI
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2ConFoco()
   * Descripción: Actualiza las etiquetas de los controles y presenta los mensajes en la
   *              barra de estado de la ventana de edición de registro al obtener un
   *              control de edición el foco.
   *  Parámetros: Ninguno
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABM2ConFoco()

   // ------- Declaración de variables locales.-----------------------------------
   LOCAL i         /*as numeric*/          // Indice de iteración.
   LOCAL cControl  as character            // Nombre del control activo.
   LOCAL acControl /*as array*/            // Matriz con los nombre de los controles.

   // ------- Inicialización de variables.----------------------------------------
   cControl := This.Name
   acControl := {}
   FOR i := 1 to Len( _aControl )
      aAdd( acControl, _aControl[ i, ABM_CON_NAME ] )
   NEXT
   _nControlActivo := aScan( acControl, cControl )

   // ------- Pone la etiqueta en negrita.----------------------------------------
   SetProperty( "wndABM2EditNuevoSplit", _aEtiqueta[ _nControlActivo, ABM_LBL_NAME ], "FontBold", .t. )

   // ------- Presenta el mensaje en la barra de estado.--------------------------
   wndABM2EditNuevo .StatusBar. Item( 1 ) := _aControl[ _nControlActivo, ABM_CON_DES ]

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para MiniGUI
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2SinFoco()
   * Descripción: Restaura el estado de las etiquetas y de la barra de estado de la ventana
   *              de edición de registros al dejar un control de edición sin foco.
   *  Parámetros: Ninguno
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABM2SinFoco()

   // ------- Restaura el estado de la etiqueta.----------------------------------
   SetProperty( "wndABM2EditNuevoSplit", _aEtiqueta[ _nControlActivo, ABM_LBL_NAME ], "FontBold", .f. )

   // ------- Restaura el texto de la barra de estado.----------------------------
   wndABM2EditNuevo .StatusBar. Item( 1 ) := ""

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para MiniGUI
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2AlEntrar()
   * Descripción: Cambia al siguiente control de edición tipo TEXTBOX al pulsar la tecla
   *              ENTER.
   *  Parámetros: Ninguno
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABM2AlEntrar()

   // ------- Declaración de variables locales.-----------------------------------
   LOCAL lSalida   /*as logical*/              // Tipo de salida.
   LOCAL nTipo     /*as numeric*/              // Tipo del control.

   // ------- Inicializa las variables.-------------------------------------------
   lSalida := .t.

   // ------- Restaura el estado de la etiqueta.----------------------------------
   SetProperty( "wndABM2EditNuevoSplit", _aEtiqueta[ _nControlActivo, ABM_LBL_NAME ], "FontBold", .f. )

   // ------- Activa el siguiente control editable con evento ON ENTER.-----------
   DO WHILE lSalida
      _nControlActivo++
      IF _nControlActivo > Len( _aControl )
         _nControlActivo := 1
      ENDIF
      nTipo := _aControl[ _nControlActivo, ABM_CON_TYPE ]
      IF nTipo == ABM_TEXTBOXC .or. nTipo == ABM_TEXTBOXN
         IF _aEditable[ _nControlActivo ]
            lSalida := .f.
         ENDIF
      ENDIF
   ENDDO

   Domethod( "wndABM2EditNuevoSplit", _aControl[ _nControlActivo, ABM_CON_NAME ], "SetFocus" )

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para MiniGUI
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2EditarGuardar( lNuevo )
   * Descripción: Añade o guarda el registro en la bdd.
   *  Parámetros: lNuevo          Valor lógico que indica si se está añadiendo un registro
   *                              o editando el actual.
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABM2EditarGuardar( lNuevo )

   // ------- Declaración de variables locales.-----------------------------------
   LOCAL i          /*as numeric*/             // Indice de iteración.
   LOCAL xValor                                // Valor a guardar.
   LOCAL lResultado /*as logical*/             // Resultado del bloque del usuario.
   LOCAL aValores   /*as array*/               // Valores del registro.

   // ------- Guarda el registro.-------------------------------------------------
   IF _bGuardar == NIL

      // No hay bloque de código del usuario.
      IF lNuevo
         ( _cArea )->( dbAppend() )
      ENDIF

      IF ( _cArea )->( rlock() )

         FOR i := 1 to Len( _aEstructura )
            xValor := GetProperty( "wndABM2EditNuevoSplit", _aControl[ i, ABM_CON_NAME ], "Value" )
            ( _cArea )->( FieldPut( i, xValor ) )
         NEXT

         ( _cArea )->( dbunlock() )

         // Refresca la ventana de visualización.
         wndABM2EditNuevo.Release
         ABM2Redibuja( .t. )

      ELSE
         Msgstop ( _HMG_aLangUser[41 ], _cTitulo )
      ENDIF
   ELSE

      // Hay bloque de código del usuario.
      aValores := {}
      FOR i := 1 to Len( _aControl )
         xValor := GetProperty( "wndABM2EditNuevoSplit", _aControl[ i, ABM_CON_NAME ], "Value" )
         aAdd( aValores, xValor )
      NEXT
      lResultado := Eval( _bGuardar, aValores, lNuevo )
      IF ValType( lResultado ) != "L"
         lResultado := .t.
      ENDIF

      // Refresca la ventana de visualización.
      IF lResultado
         wndABM2EditNuevo.Release
         ABM2Redibuja( .t. )
      ENDIF
   ENDIF

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para MiniGUI
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2Seleccionar()
   * Descripción: Presenta una ventana para la selección de un registro.
   *  Parámetros: Ninguno
   *    Devuelve: [nReg]          Numero de registro seleccionado, o cero si no se ha
   *                              seleccionado ninguno.
   ****************************************************************************************/

STATIC FUNCTION ABM2Seleccionar()

   // ------- Declaración de variables locales.-----------------------------------
   LOCAL lSalida   as logical              // Control de bucle.
   LOCAL nReg      as numeric              // Valores del registro
   LOCAL nRegistro /*as numeric*/          // Número de registro.

   // ------- Inicialización de variables.----------------------------------------
   lSalida   := .f.
   nReg      := 0
   nRegistro := ( _cArea )->( RecNo() )

   // ------- Se situa en el primer registro.-------------------------------------
   ( _cArea )->( dbGoTop() )

   // ------- Creación de la ventana de selección de registro.--------------------
   DEFINE WINDOW wndSeleccionar            ;
         at 0, 0                         ;
         width 500                       ;
         height 300                      ;
         title _HMG_aLangLabel[ 8 ]      ;
         modal                           ;
         nosize                          ;
         nosysmenu                       ;
         font _GetSysFont() size 9

      // Define la barra de botones de la ventana de selección.
      DEFINE TOOLBAR tbSeleccionar buttonsize 100, 32 flat righttext border
         button tbbCancelarSel caption _HMG_aLangButton[ 7 ]               ;
            picture "MINIGUI_EDIT_CANCEL"             ;
            action  {|| lSalida := .f.,               ;
            nReg    := 0,                 ;
            wndSeleccionar.Release }
         button tbbAceptarSel  caption _HMG_aLangButton[ 8 ]                       ;
            picture "MINIGUI_EDIT_OK"                                         ;
            action  {|| lSalida := .t.,                                       ;
            nReg    := wndSeleccionar .brwSeleccionar. Value,       ;
            wndSeleccionar.Release }
      END toolbar

      // Define la barra de estado de la ventana de selección.
      DEFINE STATUSBAR font _GetSysFont() size 9
         statusitem _HMG_aLangUser[ 7 ]
      END STATUSBAR

      // Define la tabla de la ventana de selección.
      @ 55, 20 browse brwSeleccionar                                          ;
         width 460                                                       ;
         height 190                                                      ;
         headers _aCabeceraTabla                                         ;
         widths _aAnchoTabla                                             ;
         workarea &_cArea                                                ;
         fields _aCampoTabla                                             ;
         value ( _cArea )->( RecNo() )                                   ;
         font "arial" size 9                                             ;
         on dblclick {|| lSalida := .t.,                                 ;
         nReg := wndSeleccionar .brwSeleccionar. Value,    ;
         wndSeleccionar.Release }                        ;
         justify _aAlineadoTabla paintdoublebuffer

   END WINDOW

   // ------- Activa la ventana de selección de registro.-------------------------
   CENTER WINDOW wndSeleccionar
   ACTIVATE WINDOW wndSeleccionar

   // ------- Restuara el puntero de registro.------------------------------------
   ( _cArea )->( dbGoTo( nRegistro ) )

   RETURN ( nReg )

   /****************************************************************************************
   *  Aplicación: Comando EDIT para MiniGUI
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2EditarCopiar()
   * Descripción: Copia el registro seleccionado en los controles de edición del nuevo
   *              registro.
   *  Parámetros: Ninguno
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABM2EditarCopiar()

   // ------- Declaración de variables locales.-----------------------------------
   LOCAL i         /*as numeric*/          // Indice de iteración.
   LOCAL nRegistro /*as numeric*/          // Puntero de registro.
   LOCAL nReg      /*as numeric*/          // Numero de registro.

   // ------- Obtiene el registro a copiar.---------------------------------------
   nReg := ABM2Seleccionar()

   // ------- Actualiza los controles de edición.---------------------------------
   IF nReg != 0
      nRegistro := ( _cArea )->( RecNo() )
      ( _cArea )->( dbGoTo( nReg ) )
      FOR i := 1 to Len( _aControl )
         IF _aEditable[ i ]
            SetProperty( "wndABM2EditNuevoSplit", _aControl[ i, ABM_CON_NAME ], "Value", ( _cArea )->( FieldGet( i ) ) )
         ENDIF
      NEXT
      ( _cArea )->( dbGoTo( nRegistro ) )
   ENDIF

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para MiniGUI
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2Borrar()
   * Descripción: Borra el registro activo.
   *  Parámetros: Ninguno
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABM2Borrar()

   // ------- Borra el registro si se acepta.-------------------------------------
   IF MsgOKCancel( _HMG_aLangUser[ 8 ], _HMG_aLangLabel[ 16 ] )
      IF ( _cArea )->( rlock() )
         ( _cArea )->( dbDelete() )
         ( _cArea )->( dbCommit() )
         ( _cArea )->( dbunlock() )
         IF set( _SET_DELETED )
            ( _cArea )->( dbSkip() )
            IF ( _cArea )->( eof() )
               ( _cArea )->( dbGoBottom() )
            ENDIF
         ENDIF
         ABM2Redibuja( .t. )
      ELSE
         Msgstop( _HMG_aLangUser[41 ], _cTitulo )
      ENDIF
   ENDIF

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para MiniGUI
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2Recover()
   * Descripción: Restaurar el registro activo.
   *  Parámetros: Ninguno
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABM2Recover()

   // ------- Restaurar el registro si se acepta.-----------------------------------
   IF MsgOKCancel( _HMG_aLangUser[ 42 ], StrTran( _HMG_aLangButton[ 12 ], "&", "" ) )
      IF ( _cArea )->( rlock() )
         ( _cArea )->( dbRecall() )
         ( _cArea )->( dbCommit() )
         ( _cArea )->( dbunlock() )
         ABM2Redibuja( .t. )
      ELSE
         Msgstop( _HMG_aLangUser[41 ], _cTitulo )
      ENDIF
   ENDIF

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para MiniGUI
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2Buscar()
   * Descripción: Busca un registro por la clave del indice activo.
   *  Parámetros: Ninguno
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABM2Buscar()

   // ------- Declaración de variables locales.-----------------------------------
   LOCAL nControl   /*as numeric*/         // Numero del control.
   LOCAL lSalida    as logical             // Tipo de salida de la ventana.
   LOCAL xValor                            // Valor de busqueda.
   LOCAL cMascara   as character           // Mascara de edición del control.
   LOCAL lResultado /*as logical*/         // Resultado de la busqueda.
   LOCAL nRegistro  /*as numeric*/         // Numero de registro.

   // ------- Inicialización de variables.----------------------------------------
   nControl := _aIndiceCampo[ _nIndiceActivo ]

   // ------- Comprueba si se ha pasado una acción del usuario.--------------------
   IF _bBuscar != NIL
      // msgInfo( "ON FIND" )
      Eval( _bBuscar )
      ABM2Redibuja( .t. )

      RETURN NIL
   ENDIF

   // ------- Comprueba si hay un indice activo.----------------------------------
   IF _nIndiceActivo == 1
      msgExclamation( _HMG_aLangUser[ 9 ], _cTitulo )

      RETURN NIL
   ENDIF

   // ------- Comprueba que el campo indice no es del tipo memo o logico.---------
   IF _aEstructura[ nControl, DBS_TYPE ] == "L" .or. _aEstructura[ nControl, DBS_TYPE ] == "M"
      msgExclamation( _HMG_aLangUser[ 10 ], _cTitulo )

      RETURN NIL
   ENDIF

   // ------- Crea la ventana de busqueda.----------------------------------------
   DEFINE WINDOW wndABMBuscar              ;
         at 0, 0                         ;
         width 500                       ;
         height 170                      ;
         title _HMG_aLangLabel[ 9 ]      ;
         modal                           ;
         nosize                          ;
         nosysmenu                       ;
         font _GetSysFont() size 9

      // Define la barra de botones de la ventana de busqueda.
      DEFINE TOOLBAR tbBuscar buttonsize 100, 32 flat righttext border
         button tbbCancelarBus caption _HMG_aLangButton[ 7 ]         ;
            picture "MINIGUI_EDIT_CANCEL"                       ;
            action  {|| lSalida := .f.,                         ;
            xValor := wndABMBuscar .conBuscar. Value,           ;
            wndABMBuscar.Release }
         button tbbAceptarBus  caption _HMG_aLangButton[ 8 ]         ;
            picture "MINIGUI_EDIT_OK"                           ;
            action  {|| lSalida := .t.,                         ;
            xValor := wndABMBuscar .conBuscar. Value,           ;
            wndABMBuscar.Release }
      END toolbar

      // Define la barra de estado de la ventana de busqueda.
      DEFINE STATUSBAR font _GetSysFont() size 9
         statusitem ""
      END STATUSBAR
   END WINDOW

   // ------- Crea los controles de la ventana de busqueda.-----------------------
   // Frame.
   @ 45, 10 frame frmBuscar                        ;
      of wndABMBuscar                         ;
      caption ""                              ;
      width wndABMBuscar.Width - 25           ;
      height wndABMBuscar.Height - 100

   // Etiqueta.
   @ 60, 20 label lblBuscar                                ;
      of wndABMBuscar                                 ;
      value _aNombreCampo[ nControl ]                 ;
      width _aEtiqueta[ nControl, ABM_LBL_WIDTH ]     ;
      height _aEtiqueta[ nControl, ABM_LBL_HEIGHT ]   ;
      font _GetSysFont() size 9

   // Tipo de dato a buscar.
   DO CASE

      // Carácter.
   CASE _aControl[ nControl, ABM_CON_TYPE ] == ABM_TEXTBOXC
      @ 75, 20  textbox conBuscar                             ;
         of wndABMBuscar                                 ;
         value ""                                        ;
         height _aControl[ nControl, ABM_CON_HEIGHT ]    ;
         width _aControl[ nControl, ABM_CON_WIDTH ]      ;
         font "arial" size 9                             ;
         maxlength _aEstructura[ nControl, DBS_LEN ]

      // Fecha.
   CASE _aControl[ nControl, ABM_CON_TYPE ] == ABM_DATEPICKER
      @ 75, 20 datepicker conBuscar                           ;
         of wndABMBuscar                                 ;
         value Date()                                    ;
         height _aControl[ nControl, ABM_CON_HEIGHT ]    ;
         width _aControl[ nControl, ABM_CON_WIDTH ] + 25 ;
         font "arial" size 9

      // Numerico.
   CASE _aControl[ nControl, ABM_CON_TYPE ] == ABM_TEXTBOXN
      IF _aEstructura[ nControl, DBS_DEC ] == 0

         // Sin decimales.
         @ 75, 20 textbox conBuscar                              ;
            of wndABMBuscar                                 ;
            value ""                                        ;
            height _aControl[ nControl, ABM_CON_HEIGHT ]    ;
            width _aControl[ nControl, ABM_CON_WIDTH ]      ;
            numeric                                         ;
            font "arial" size 9                             ;
            maxlength _aEstructura[ nControl, DBS_LEN ]
      ELSE

         // Con decimales.
         cMascara := Replicate( "9", _aEstructura[ nControl, DBS_LEN ] - ( _aEstructura[ nControl, DBS_DEC ] + 1 ) )
         cMascara += "."
         cMascara += Replicate( "9", _aEstructura[ nControl, DBS_DEC ] )
         @ 75, 20 textbox conBuscar                              ;
            of wndABMBuscar                                 ;
            value ""                                        ;
            height _aControl[ nControl, ABM_CON_HEIGHT ]    ;
            width _aControl[ nControl, ABM_CON_WIDTH ]      ;
            numeric                                         ;
            inputmask cMascara
      ENDIF
   ENDCASE

   // ------- Actualiza la barra de estado.---------------------------------------
   wndABMBuscar .StatusBar. Item( 1 ) := _aControl[ nControl, ABM_CON_DES ]

   // ------- Comprueba el tamaño del control de edición del dato a buscar.-------
   IF wndABMBuscar .conBuscar. Width > wndABM2Edit.Width - 45
      wndABMBuscar .conBuscar. Width := wndABM2Edit.Width - 45
   ENDIF

   // ------- Activa la ventana de busqueda.--------------------------------------
   on key escape ;
      of wndABMBuscar ;
      action wndABMBuscar .tbbCancelarBus. onclick

   on key return ;
      of wndABMBuscar ;
      action wndABMBuscar .tbbAceptarBus. onclick

   CENTER WINDOW wndABMBuscar
   ACTIVATE WINDOW wndABMBuscar

   // ------- Busca el registro.--------------------------------------------------
   IF lSalida
      nRegistro := ( _cArea )->( RecNo() )
      lResultado := ( _cArea )->( dbSeek( xValor ) )
      IF !lResultado
         msgExclamation( _HMG_aLangUser[ 11 ], _cTitulo )
         ( _cArea )->( dbGoTo( nRegistro ) )
      ELSE
         ABM2Redibuja( .t. )
      ENDIF
   ENDIF

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para MiniGUI
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2ActivarFiltro()
   * Descripción: Filtra la base de datos.
   *  Parámetros: Ninguno
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABM2ActivarFiltro()

   // ------- Declaración de variables locales.-----------------------------------
   LOCAL aCompara   /*as array*/               // Comparaciones.
   LOCAL aCampos    /*as array*/               // Nombre de los campos.

   // ------- Comprueba que no hay ningun filtro activo.--------------------------
   IF _cFiltro != ""
      MsgInfo( _HMG_aLangUser[ 34 ], '' )
   ENDIF

   // ------- Inicialización de variables.----------------------------------------
   aCampos    := _aNombreCampo
   aCompara   := { _HMG_aLangLabel[ 27 ], ;
      _HMG_aLangLabel[ 28 ], ;
      _HMG_aLangLabel[ 29 ], ;
      _HMG_aLangLabel[ 30 ], ;
      _HMG_aLangLabel[ 31 ], ;
      _HMG_aLangLabel[ 32 ] }

   // ------- Crea la ventana de filtrado.----------------------------------------
   DEFINE WINDOW wndABM2Filtro                     ;
         at 0, 0                                 ;
         width 400                               ;
         height 325                              ;
         title _HMG_aLangLabel[ 21 ]             ;
         modal                                   ;
         nosize                                  ;
         nosysmenu                               ;
         on init {|| ABM2ControlFiltro() }       ;
         font _GetSysFont() size 9

      // Define la barra de botones de la ventana de filtrado.
      DEFINE TOOLBAR tbBuscar buttonsize 100, 32 flat righttext border
         button tbbCancelarFil caption _HMG_aLangButton[ 7 ]           ;
            picture "MINIGUI_EDIT_CANCEL"     ;
            action  {|| wndABM2Filtro.Release, ;
            ABM2Redibuja( .f. ) }
         button tbbAceptarFil  caption _HMG_aLangButton[ 8 ]           ;
            picture "MINIGUI_EDIT_OK"         ;
            action  {|| ABM2EstableceFiltro() }
      END toolbar

      // Define la barra de estado de la ventana de filtrado.
      DEFINE STATUSBAR font _GetSysFont() size 9
         statusitem ""
      END STATUSBAR
   END WINDOW

   // ------- Controles de la ventana de filtrado.
   // Frame.
   @ 45, 10 frame frmFiltro                ;
      of wndABM2Filtro                ;
      caption ""                      ;
      width wndABM2Filtro.Width - 25  ;
      height wndABM2Filtro.Height - 100
   @ 65, 20 label lblCampos                ;
      of wndABM2Filtro                ;
      value _HMG_aLangLabel[ 22 ]     ;
      width 140                       ;
      height 25                       ;
      font _GetSysFont() size 9
   @ 65, 220 label lblCompara              ;
      of wndABM2Filtro                ;
      value _HMG_aLangLabel[ 23 ]     ;
      width 140                       ;
      height 25                       ;
      font _GetSysFont() size 9
   @ 200, 20 label lblValor                ;
      of wndABM2Filtro                ;
      value _HMG_aLangLabel[ 24 ]     ;
      width 140                       ;
      height 25                       ;
      font _GetSysFont() size 9
   @ 85, 20 listbox lbxCampos                      ;
      of wndABM2Filtro                        ;
      width 140                               ;
      height 100                              ;
      items aCampos                           ;
      value 1                                 ;
      font "Arial" size 9                     ;
      on change {|| ABM2ControlFiltro() }     ;
      on gotfocus wndABM2Filtro .StatusBar. Item( 1 ) := _HMG_aLangLabel[ 25 ] ;
      on lostfocus wndABM2Filtro .StatusBar. Item( 1 ) := ""
   @ 85, 220 listbox lbxCompara                    ;
      of wndABM2Filtro                        ;
      width 140                               ;
      height 100                              ;
      items aCompara                          ;
      value 1                                 ;
      font "Arial" size 9                     ;
      on gotfocus wndABM2Filtro .StatusBar. Item( 1 ) := _HMG_aLangLabel[ 26 ] ;
      on lostfocus wndABM2Filtro .StatusBar. Item( 1 ) := ""
   @ 220, 20 textbox conValor              ;
      of wndABM2Filtro                ;
      value ""                        ;
      height 25                       ;
      width 160                       ;
      font "arial" size 9             ;
      maxlength 16

   // ------- Activa la ventana.
   CENTER WINDOW wndABM2Filtro
   ACTIVATE WINDOW wndABM2Filtro

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para MiniGUI
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2ControlFiltro()
   * Descripción: Comprueba que el filtro se puede aplicar.
   *  Parámetros: Ninguno
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABM2ControlFiltro()

   // ------- Declaración de variables locales.-----------------------------------
   LOCAL nControl /*as numeric*/
   LOCAL cMascara as character
   LOCAL cMensaje as character

   // ------- Inicializa las variables.
   nControl := wndABM2Filtro .lbxCampos. Value

   // ------- Comprueba que se puede crear el control.----------------------------
   IF _aEstructura[ nControl, DBS_TYPE ] == "M"
      msgExclamation( _HMG_aLangUser[ 35 ], _cTitulo )

      RETURN NIL
   ENDIF
   IF nControl == 0
      msgExclamation( _HMG_aLangUser[ 36 ], _cTitulo )

      RETURN NIL
   ENDIF

   // ------- Crea el nuevo control.----------------------------------------------
   wndABM2Filtro .conValor. Release
   cMensaje := _aControl[ nControl, ABM_CON_DES ]
   DO CASE

      // Carácter.
   CASE _aControl[ nControl, ABM_CON_TYPE ] == ABM_TEXTBOXC
      @ 226, 20  textbox conValor                                     ;
         of wndABM2Filtro                                        ;
         value ""                                                ;
         height _aControl[ nControl, ABM_CON_HEIGHT ]            ;
         width _aControl[ nControl, ABM_CON_WIDTH ]              ;
         font "arial" size 9                                     ;
         maxlength _aEstructura[ nControl, DBS_LEN ]             ;
         on gotfocus wndABM2Filtro .StatusBar. Item( 1 ) :=      ;
         cMensaje                                    ;
         on lostfocus wndABM2Filtro .StatusBar. Item( 1 ) := ""

      // Fecha.
   CASE _aControl[ nControl, ABM_CON_TYPE ] == ABM_DATEPICKER
      @ 226, 20 datepicker conValor                                   ;
         of wndABM2Filtro                                        ;
         value Date()                                            ;
         height _aControl[ nControl, ABM_CON_HEIGHT ]            ;
         width _aControl[ nControl, ABM_CON_WIDTH ] + 25         ;
         font "arial" size 9                                     ;
         on gotfocus wndABM2Filtro .StatusBar. Item( 1 ) :=      ;
         cMensaje                                    ;
         on lostfocus wndABM2Filtro .StatusBar. Item( 1 ) := ""

      // Numerico.
   CASE _aControl[ nControl, ABM_CON_TYPE ] == ABM_TEXTBOXN
      IF _aEstructura[ nControl, DBS_DEC ] == 0

         // Sin decimales.
         @ 226, 20 textbox conValor                                      ;
            of wndABM2Filtro                                        ;
            value ""                                                ;
            height _aControl[ nControl, ABM_CON_HEIGHT ]            ;
            width _aControl[ nControl, ABM_CON_WIDTH ]              ;
            numeric                                                 ;
            font "arial" size 9                                     ;
            maxlength _aEstructura[ nControl, DBS_LEN ]             ;
            on gotfocus wndABM2Filtro .StatusBar. Item( 1 ) :=      ;
            cMensaje                                    ;
            on lostfocus wndABM2Filtro .StatusBar. Item( 1 ) := ""

      ELSE

         // Con decimales.
         cMascara := Replicate( "9", _aEstructura[ nControl, DBS_LEN ] - ( _aEstructura[ nControl, DBS_DEC ] + 1 ) )
         cMascara += "."
         cMascara += Replicate( "9", _aEstructura[ nControl, DBS_DEC ] )
         @ 226, 20 textbox conValor                                      ;
            of wndABM2Filtro                                        ;
            value ""                                                ;
            height _aControl[ nControl, ABM_CON_HEIGHT ]            ;
            width _aControl[ nControl, ABM_CON_WIDTH ]              ;
            numeric                                                 ;
            inputmask cMascara                                      ;
            on gotfocus wndABM2Filtro .StatusBar. Item( 1 ) :=      ;
            cMensaje                                    ;
            on lostfocus wndABM2Filtro .StatusBar. Item( 1 ) := ""
      ENDIF

      // Logico
   CASE _aControl[ nControl, ABM_CON_TYPE ] == ABM_CHECKBOX
      @ 226, 20 checkbox conValor                                     ;
         of wndABM2Filtro                                        ;
         caption ""                                              ;
         height _aControl[ nControl, ABM_CON_HEIGHT ]            ;
         width _aControl[ nControl, ABM_CON_WIDTH ]              ;
         value .f.                                               ;
         on gotfocus wndABM2Filtro .StatusBar. Item( 1 ) :=      ;
         cMensaje                                    ;
         on lostfocus wndABM2Filtro .StatusBar. Item( 1 ) := ""

   ENDCASE

   // ------- Actualiza el valor de la etiqueta.----------------------------------
   wndABM2Filtro .lblValor. Value := _aNombreCampo[ nControl ]

   // ------- Comprueba el tamaño del control de edición del dato a buscar.-------
   IF wndABM2Filtro .conValor. Width > wndABM2Filtro.Width - 45
      wndABM2Filtro .conValor. Width := wndABM2Filtro.Width - 45
   ENDIF

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para MiniGUI
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2EstableceFiltro()
   * Descripción: Establece el filtro seleccionado.
   *  Parámetros: Ninguno.
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABM2EstableceFiltro()

   // ------- Declaración de variables locales.-----------------------------------
   LOCAL aOperador  /*as array*/
   LOCAL nCampo     /*as numeric*/
   LOCAL nCompara   /*as numeric*/
   LOCAL cValor     as character

   // ------- Inicialización de variables.----------------------------------------
   nCompara  := wndABM2Filtro .lbxCompara. Value
   nCampo    := wndABM2Filtro .lbxCampos. Value
   cValor    := HB_ValToStr( wndABM2Filtro .conValor. Value )
   aOperador := { "=", "<>", ">", "<", ">=", "<=" }

   // ------- Comprueba que se puede filtrar.-------------------------------------
   IF nCompara == 0
      msgExclamation( _HMG_aLangUser[ 37 ], _cTitulo )

      RETURN NIL
   ENDIF
   IF nCampo == 0
      msgExclamation( _HMG_aLangUser[ 36 ], _cTitulo )

      RETURN NIL
   ENDIF
   IF cValor == ""
      msgExclamation( _HMG_aLangUser[ 38 ], _cTitulo )

      RETURN NIL
   ENDIF
   IF _aEstructura[ nCampo, DBS_TYPE ] == "M"
      msgExclamation( _HMG_aLangUser[ 35 ], _cTitulo )

      RETURN NIL
   ENDIF

   // ------- Establece el filtro.------------------------------------------------
   DO CASE
   CASE _aEstructura[ nCampo, DBS_TYPE ] == "C"
      _cFiltro := "Upper(" + _cArea + "->" + ;
         _aEstructura[ nCampo, DBS_NAME ] + ")" + ;
         aOperador[ nCompara ]
      _cFiltro += "'" + Upper( AllTrim( cValor ) ) + "'"

   CASE _aEstructura[ nCampo, DBS_TYPE ] == "N"
      _cFiltro := _cArea + "->" + ;
         _aEstructura[ nCampo, DBS_NAME ] + ;
         aOperador[ nCompara ]
      _cFiltro += AllTrim( cValor )

   CASE _aEstructura[ nCampo, DBS_TYPE ] == "D"
      _cFiltro := _cArea + "->" + ;
         _aEstructura[ nCampo, DBS_NAME ] + ;
         aOperador[ nCompara ]
      _cFiltro += "CToD(" + "'" + cValor + "')"

   CASE _aEstructura[ nCampo, DBS_TYPE ] == "L"
      _cFiltro := _cArea + "->" + ;
         _aEstructura[ nCampo, DBS_NAME ] + ;
         aOperador[ nCompara ]
      _cFiltro += cValor
   ENDCASE
   ( _cArea )->( dbSetFilter( {|| &_cFiltro }, _cFiltro ) )
   _lFiltro := .t.
   wndABM2Filtro.Release
   ABM2Redibuja( .t. )

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para MiniGUI
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2DesactivarFiltro()
   * Descripción: Desactiva el filtro si procede.
   *  Parámetros: Ninguno
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABM2DesactivarFiltro()

   // ------- Desactiva el filtro si procede.
   IF !_lFiltro
      msgExclamation( _HMG_aLangUser[ 39 ], _cTitulo )
      ABM2Redibuja( .f. )

      RETURN NIL
   ENDIF
   IF msgYesNo( _HMG_aLangUser[ 40 ], _cTitulo )
      ( _cArea )->( dbClearFilter( NIL ) )
      _lFiltro := .f.
      _cFiltro := ""
      ABM2Redibuja( .t. )
   ENDIF

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para MiniGUI
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2Imprimir()
   * Descripción: Presenta la ventana de recogida de datos para la definición del listado.
   *  Parámetros: Ninguno
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABM2Imprimir()

   // ------- Declaración de variables locales.-----------------------------------
   LOCAL aCampoBase    /*as array*/        // Campos de la bdd.
   LOCAL aCampoListado /*as array*/        // Campos del listado.
   LOCAL nRegistro     /*as numeric*/      // Numero de registro actual.
   LOCAL nCampo        /*as numeric*/      // Numero de campo.
   LOCAL cRegistro1    as character        // Valor del registro inicial.
   LOCAL cRegistro2    as character        // Valor del registro final.
   LOCAL aImpresoras   as array            // Impresoras disponibles.

   // ------- Comprueba si se ha pasado la clausula ON PRINT.---------------------
   IF _bImprimir != NIL
      // msgInfo( "ON PRINT" )
      Eval( _bImprimir )
      ABM2Redibuja( .T. )

      RETURN NIL
   ENDIF

   // ------- Obtiene las impresoras disponibles.---------------------------------
   aImpresoras := {}
   INIT PRINTSYS
   GET PRINTERS TO aImpresoras
   RELEASE PRINTSYS

   // ------- Comprueba que hay un indice activo.---------------------------------
   IF _nIndiceActivo == 1
      msgExclamation( _HMG_aLangUser[ 9 ], _cTitulo )

      RETURN NIL
   ENDIF

   // ------- Inicialización de variables.----------------------------------------
   aCampoListado := {}
   aCampoBase    := _aNombreCampo
   SET DELETED ON
   nRegistro     := ( _cArea )->( RecNo() )
   IF ( _cArea )->( Deleted() )
      ( _cArea )->( dbSkip() )
   ENDIF

   // Registro inicial y final.
   nCampo := _aIndiceCampo[ _nIndiceActivo ]
   ( _cArea )->( dbGoTop() )
   cRegistro1 := HB_ValToStr( ( _cArea )->( FieldGet( nCampo ) ) )
   ( _cArea )->( dbGoBottom() )
   cRegistro2 := HB_ValToStr( ( _cArea )->( FieldGet( nCampo ) ) )
   ( _cArea )->( dbGoTo( nRegistro ) )

   // ------- Definición de la ventana de formato de listado.---------------------
   DEFINE WINDOW wndABM2Listado            ;
         at 0, 0                         ;
         width 390                       ;
         height 365                      ;
         title _HMG_aLangLabel[ 10 ]       ;
         icon "MINIGUI_EDIT_PRINT"       ;
         modal                           ;
         nosize                          ;
         nosysmenu                       ;
         font _GetSysFont() size 9

      // Define la barra de botones de la ventana de formato de listado.
      DEFINE TOOLBAR tbListado buttonsize 100, 32 flat righttext border
         button tbbCancelarLis caption _HMG_aLangButton[ 7 ]               ;
            picture "MINIGUI_EDIT_CANCEL"             ;
            action  wndABM2Listado.Release
         button tbbAceptarLis  caption _HMG_aLangButton[ 8 ]               ;
            picture "MINIGUI_EDIT_OK"                 ;
            action  ABM2Listado( aImpresoras )

      END toolbar

      // Define la barra de estado de la ventana de formato de listado.
      DEFINE STATUSBAR font _GetSysFont() size 9
         statusitem ""
      END STATUSBAR
   END WINDOW

   // ------- Define los controles de edición de la ventana de formato de listado.-
   // Frame.
   @ 45, 10 frame frmListado                       ;
      of wndABM2Listado                       ;
      caption ""                              ;
      width wndABM2Listado.Width - 25         ;
      height wndABM2Listado.Height - 100

   // Label
   @ 65, 20 label lblCampoBase             ;
      of wndABM2Listado               ;
      value _HMG_aLangLabel[ 11 ]       ;
      width 140                       ;
      height 25                       ;
      font _GetSysFont() size 9
   @ 65, 220 label lblCampoListado         ;
      of wndABM2Listado               ;
      value _HMG_aLangLabel[ 12 ]       ;
      width 140                       ;
      height 25                       ;
      font _GetSysFont() size 9
   @ 200, 20 label lblImpresoras           ;
      of wndABM2Listado               ;
      value _HMG_aLangLabel[ 13 ]       ;
      width 140                       ;
      height 25                       ;
      font _GetSysFont() size 9
   @ 200, 170 label lblInicial             ;
      of wndABM2Listado               ;
      value _HMG_aLangLabel[ 14 ]       ;
      width 160                       ;
      height 25                       ;
      font _GetSysFont() size 9
   @ 255, 170 label lblFinal               ;
      of wndABM2Listado               ;
      value _HMG_aLangLabel[ 15 ]       ;
      width 160                       ;
      height 25                       ;
      font _GetSysFont() size 9

   // Listbox.
   @ 85, 20 listbox lbxCampoBase                                           ;
      of wndABM2Listado                                               ;
      width 140                                                       ;
      height 100                                                      ;
      items aCampoBase                                                ;
      value 1                                                         ;
      font "Arial" size 9                                             ;
      on gotfocus wndABM2Listado .StatusBar. Item( 1 ) := _HMG_aLangUser[ 12 ] ;
      on lostfocus wndABM2Listado .StatusBar. Item( 1 ) := ""
   @ 85, 220 listbox lbxCampoListado                                       ;
      of wndABM2Listado                                               ;
      width 140                                                       ;
      height 100                                                      ;
      items aCampoListado                                             ;
      value 1                                                         ;
      font "Arial" size 9                                             ;
      on gotFocus wndABM2Listado .StatusBar. Item( 1 ) := _HMG_aLangUser[ 13 ] ;
      on lostfocus wndABM2Listado .StatusBar. Item( 1 ) := ""

   // ComboBox.
   @ 220, 20 combobox cbxImpresoras                                        ;
      of wndABM2Listado                                               ;
      items aImpresoras                                               ;
      value 1                                                         ;
      width 140                                                       ;
      font "Arial" size 9                                             ;
      on gotfocus wndABM2Listado .StatusBar. Item( 1 ) := _HMG_aLangUser[ 14 ] ;
      on lostfocus wndABM2Listado .StatusBar. Item( 1 ) := ""

   // PicButton.
   @ 90, 170 button btnMas                                                 ;
      of wndABM2Listado                                               ;
      picture "MINIGUI_EDIT_ADD"                                      ;
      action ABM2DefinirColumnas( ABM_LIS_ADD )                       ;
      width 40                                                        ;
      height 40                                                       ;
      on gotfocus wndABM2Listado .StatusBar. Item( 1 ) := _HMG_aLangUser[ 15 ] ;
      on lostfocus wndABM2Listado .StatusBar. Item( 1 ) := ""
   @ 140, 170 button btnMenos                                              ;
      of wndABM2Listado                                               ;
      picture "MINIGUI_EDIT_DEL"                                      ;
      action ABM2DefinirColumnas( ABM_LIS_DEL )                       ;
      width 40                                                        ;
      height 40                                                       ;
      on gotfocus wndABM2Listado .StatusBar. Item( 1 ) := _HMG_aLangUser[ 16 ] ;
      on lostfocus wndABM2Listado .StatusBar. Item( 1 ) := ""
   @ 220, 170 button btnSet1                                               ;
      of wndABM2Listado                                               ;
      picture "MINIGUI_EDIT_SET"                                      ;
      action ABM2DefinirRegistro( ABM_LIS_SET1 )                      ;
      width 25                                                        ;
      height 25                                                       ;
      on gotfocus wndABM2Listado .StatusBar. Item( 1 ) := _HMG_aLangUser[ 17 ] ;
      on lostfocus wndABM2Listado .StatusBar. Item( 1 ) := ""
   @ 275, 170 button btnSet2                                               ;
      of wndABM2Listado                                               ;
      picture "MINIGUI_EDIT_SET"                                      ;
      action ABM2DefinirRegistro( ABM_LIS_SET2 )                      ;
      width 25                                                        ;
      height 25                                                       ;
      on gotfocus wndABM2Listado .StatusBar. Item( 1 ) := _HMG_aLangUser[ 18 ] ;
      on lostfocus wndABM2Listado .StatusBar. Item( 1 ) := ""

   // CheckBox.
   @ 255, 20 checkbox chkVistas            ;
      of wndABM2Listado               ;
      caption _HMG_aLangLabel[ 18 ]   ;
      width 140                       ;
      height 25                       ;
      value .t.                       ;
      font _GetSysFont() size 9
   @ 275, 20 checkbox chkPrevio            ;
      of wndABM2Listado               ;
      caption _HMG_aLangLabel[ 17 ]   ;
      width 140                       ;
      height 25                       ;
      value .t.                       ;
      font _GetSysFont() size 9

   // Editbox.
   @ 220, 196 textbox txtRegistro1         ;
      of wndABM2Listado               ;
      value cRegistro1                ;
      height 25                       ;
      width 160                       ;
      font "arial" size 9             ;
      maxlength 16
   @ 275, 196 textbox txtRegistro2         ;
      of wndABM2Listado               ;
      value cRegistro2                ;
      height 25                       ;
      width 160                       ;
      font "arial" size 9             ;
      maxlength 16

   // ------- Estado de los controles.--------------------------------------------
   wndABM2Listado .txtRegistro1. Enabled := .f.
   wndABM2Listado .txtRegistro2. Enabled := .f.

   // ------- Comrprueba que la selección de registros es posible.----------------
   nCampo := _aIndiceCampo[ _nIndiceActivo ]
   IF _aEstructura[ nCampo, DBS_TYPE ] == "L" .or. _aEstructura[ nCampo, DBS_TYPE ] == "M"
      wndABM2Listado .btnSet1. Enabled := .f.
      wndABM2Listado .btnSet2. Enabled := .f.
   ENDIF

   // ------- Activación de la ventana de formato de listado.---------------------
   CENTER WINDOW wndABM2Listado
   ACTIVATE WINDOW wndABM2Listado

   // ------- Restaura.-----------------------------------------------------------
   SET DELETED OFF
   ( _cArea )->( dbGoTo( nRegistro ) )
   ABM2Redibuja( .f. )

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para MiniGUI
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2DefinirRegistro( nAccion )
   * Descripción:
   *  Parámetros: [nAccion]       Numerico. Indica el tipo de accion realizado.
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABM2DefinirRegistro( nAccion )

   // ------- Declaración de variables locales.-----------------------------------
   LOCAL nRegistro as character            // Puntero de registros.
   LOCAL nReg      as character            // Registro seleccionado.
   LOCAL cValor    as character            // Valor del registro seleccionado.
   LOCAL nCampo    /*as numeric*/          // Numero del campo indice.

   // ------- Inicializa las variables.-------------------------------------------
   nRegistro := ( _cArea )->( RecNo() )

   // ------- Selecciona el registro.---------------------------------------------
   nReg := ABM2Seleccionar()
   IF nReg == 0
      ( _cArea )->( dbGoTo( nRegistro ) )

      RETURN NIL
   ELSE
      ( _cArea )->( dbGoTo( nReg ) )
      nCampo := _aIndiceCampo[ _nIndiceActivo ]
      cValor := HB_ValToStr( ( _cArea )->( FieldGet( nCampo ) ) )
   ENDIF

   // ------- Actualiza según la acción.------------------------------------------
   DO CASE
   CASE nAccion == ABM_LIS_SET1
      wndABM2Listado .txtRegistro1. Value := cValor
   CASE nAccion == ABM_LIS_SET2
      wndABM2Listado .txtRegistro2. Value := cValor
   ENDCASE

   // ------- Restaura el registro.
   ( _cArea )->( dbGoTo( nRegistro ) )

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para MiniGUI
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2DefinirColumnas( nAccion )
   * Descripción: Controla el contenido de las listas al pulsar los botones de añadir y
   *              eliminar campos del listado.
   *  Parámetros: [nAccion]       Numerico. Indica el tipo de accion realizado.
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABM2DefinirColumnas( nAccion )

   // ------- Declaración de variables locales.-----------------------------------
   LOCAL aCampoBase    /*as array*/        // Campos de la bbd.
   LOCAL aCampoListado /*as array*/        // Campos del listado.
   LOCAL i             /*as numeric*/      // Indice de iteración.
   LOCAL nItem         /*as numeric*/      // Numero del item seleccionado.
   LOCAL cValor        as character

   // ------- Inicialización de variables.----------------------------------------
   aCampoBase  := {}
   aCampoListado := {}
   FOR i := 1 to wndABM2Listado .lbxCampoBase. ItemCount
      aAdd( aCampoBase, wndABM2Listado .lbxCampoBase. Item( i ) )
   NEXT
   FOR i := 1 to wndABM2Listado .lbxCampoListado. ItemCount
      aAdd( aCampoListado, wndABM2Listado .lbxCampoListado. Item( i ) )
   NEXT

   // ------- Ejecuta según la acción.--------------------------------------------
   DO CASE
   CASE nAccion == ABM_LIS_ADD

      // Obtiene la columna a añadir.
      nItem := wndABM2Listado .lbxCampoBase. Value
      cValor := wndABM2Listado .lbxCampoBase. Item( nItem )

      // Actualiza los datos de los campos de la base.
      IF Len( aCampoBase ) == 0
         msgExclamation( _HMG_aLangUser[ 23 ], _cTitulo )

         RETURN NIL
      ELSE
         wndABM2Listado .lbxCampoBase. DeleteAllItems
         FOR i := 1 to Len( aCampoBase )
            IF i != nItem
               wndABM2Listado .lbxCampoBase. AddItem( aCampoBase[ i ] )
            ENDIF
         NEXT
         wndABM2Listado .lbxCampoBase. Value := iif( nItem > 1, nItem - 1, 1 )
      ENDIF

      // Actualiza los datos de los campos del listado.
      IF Empty( cValor )
         msgExclamation( _HMG_aLangUser[ 23 ], _cTitulo )

         RETURN NIL
      ELSE
         wndABM2Listado .lbxCampoListado. AddItem( cValor )
         wndABM2Listado .lbxCampoListado. Value := ;
            wndABM2Listado .lbxCampoListado. ItemCount
      ENDIF
   CASE nAccion == ABM_LIS_DEL

      // Obtiene la columna a quitar.
      nItem := wndABM2Listado .lbxCampoListado. Value
      cValor := wndABM2Listado .lbxCampoListado. Item( nItem )

      // Actualiza los datos de los campos del listado.
      IF Len( aCampoListado ) == 0
         msgExclamation( _HMG_aLangUser[ 23 ], _cTitulo )

         RETURN NIL
      ELSE
         wndABM2Listado .lbxCampoListado. DeleteAllItems
         FOR i := 1 to Len( aCampoListado )
            IF i != nItem
               wndABM2Listado .lbxCampoListado. AddItem( aCampoListado[ i ] )
            ENDIF
         NEXT
         wndABM2Listado .lbxCampoListado. Value := ;
            wndABM2Listado .lbxCampoListado. ItemCount
      ENDIF

      // Actualiza los datos de los campos de la base.
      IF Empty( cValor )
         msgExclamation( _HMG_aLangUser[ 23 ], _cTitulo )

         RETURN NIL
      ELSE
         wndABM2Listado .lbxCampoBase. DeleteAllItems
         FOR i := 1 to Len( _aNombreCampo )
            IF aScan( aCampoBase, _aNombreCampo[ i ] ) != 0
               wndABM2Listado .lbxCampoBase. AddItem( _aNombreCampo[ i ] )
            ENDIF
            IF _aNombreCampo[ i ] == cValor
               wndABM2Listado .lbxCampoBase. AddItem( _aNombreCampo[ i ] )
            ENDIF
         NEXT
         wndABM2Listado .lbxCampoBase. Value := 1
      ENDIF
   ENDCASE

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para MiniGUI
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2Listado()
   * Descripción: Imprime la selecciona realizada por ABM2Imprimir()
   *  Parámetros: Ninguno
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABM2Listado( aImpresoras )

   // ------- Declaración de variables locales.-----------------------------------
   LOCAL i             /*as numeric*/      // Indice de iteración.
   LOCAL cCampo        /*as character*/    // Nombre del campo indice.
   LOCAL aCampo        /*as array*/        // Nombres de los campos.
   LOCAL nCampo        /*as numeric*/      // Numero del campo actual.
   LOCAL nPosicion     /*as numeric*/      // Posición del campo.
   LOCAL aNumeroCampo  /*as array*/        // Numeros de los campos.
   LOCAL aAncho        /*as array*/        // Anchos de las columnas.
   LOCAL nAncho        /*as numeric*/      // Ancho de las columna actual.
   LOCAL lPrevio       /*as logical*/      // Previsualizar.
   LOCAL lVistas       /*as logical*/      // Vistas en miniatura.
   LOCAL nImpresora    /*as numeric*/      // Numero de la impresora.
   LOCAL cImpresora    as character        // Nombre de la impresora.
   LOCAL lOrientacion  /*as logical*/      // Orientación de la página.
   LOCAL lSalida       /*as logical*/      // Control de bucle.
   LOCAL lCabecera     /*as logical*/      // ¿Imprimir cabecera?.
   LOCAL nFila         /*as numeric*/      // Numero de la fila.
   LOCAL nColumna      /*as numeric*/      // Numero de la columna.
   LOCAL nPagina       /*as numeric*/      // Numero de página.
   LOCAL nPaginas      /*as numeric*/      // Páginas totales.
   LOCAL cPie          as character        // Texto del pie de página.
   LOCAL nPrimero      /*as numeric*/      // Numero del primer registro a imprimir.
   LOCAL nUltimo       /*as numeric*/      // Numero del ultimo registro a imprimir.
   LOCAL nTotales      /*as numeric*/      // Registros totales a imprimir.
   LOCAL nRegistro     /*as numeric*/      // Numero del registro actual.
   LOCAL cRegistro1    as character        // Valor del registro inicial.
   LOCAL cRegistro2    as character        // Valor del registro final.
   LOCAL xRegistro1                        // Valor de comparación.
   LOCAL xRegistro2                        // Valor de comparación.

   // ------- Inicialización de variables.----------------------------------------
   // Previsualizar.
   lPrevio := wndABM2Listado .chkPrevio. Value
   lVistas := wndABM2Listado .chkVistas. Value

   // Nombre de la impresora.
   nImpresora := wndABM2Listado .cbxImpresoras. Value
   IF nImpresora == 0
      msgExclamation( _HMG_aLangUser[ 32 ], '' )
   ELSE
      cImpresora := aImpresoras[ nImpresora ]
   ENDIF

   // Nombre del campo.
   aCampo := {}
   FOR i := 1 to wndABM2Listado .lbxCampoListado. ItemCount
      cCampo := wndABM2Listado .lbxCampoListado. Item( i )
      aAdd( aCampo, cCampo )
   NEXT
   IF Len( aCampo ) == 0
      msgExclamation( _HMG_aLangUser[ 23 ], _cTitulo )

      RETURN NIL
   ENDIF

   // Número del campo.
   aNumeroCampo := {}
   FOR i := 1 to Len( aCampo )
      nPosicion := aScan( _aNombreCampo, aCampo[ i ] )
      aAdd( aNumeroCampo, nPosicion )
   NEXT

   // ------- Obtiene el ancho de impresión.--------------------------------------
   aAncho := {}
   FOR i := 1 to Len( aNumeroCampo )
      nCampo := aNumeroCampo[ i ]
      DO CASE
      CASE _aEstructura[ nCampo, DBS_TYPE ] == "D"
         nAncho := 9
      CASE _aEstructura[ nCampo, DBS_TYPE ] == "M"
         nAncho := 20
      OTHERWISE
         nAncho := _aEstructura[ nCampo, DBS_LEN ]
      ENDCASE
      nAncho := iif( Len( _aNombreCampo[ nCampo ] ) > nAncho,  ;
         Len( _aNombreCampo[ nCampo ] ),            ;
         nAncho )
      aAdd( aAncho, 2 + nAncho )
   NEXT

   // ------- Comprueba el ancho de impresión.------------------------------------
   nAncho := 0
   FOR i := 1 to Len( aAncho )
      nAncho += aAncho[ i ]
   NEXT
   IF nAncho > 164
      MsgExclamation( _HMG_aLangUser[ 24 ], _cTitulo )

      RETURN NIL
   ELSE
      lOrientacion := ( nAncho > 109 )  // Horizontal / Vertical
   ENDIF

   // ------- Valores de inicio y fin de listado.---------------------------------
   nRegistro  := ( _cArea )->( RecNo() )
   cRegistro1 := wndABM2Listado .txtRegistro1. Value
   cRegistro2 := wndABM2Listado .txtRegistro2. Value
   DO CASE
   CASE _aEstructura[ _aIndiceCampo[ _nIndiceActivo ], DBS_TYPE ] == "C"
      xRegistro1 := cRegistro1
      xRegistro2 := cRegistro2
   CASE _aEstructura[ _aIndiceCampo[ _nIndiceActivo ], DBS_TYPE ] == "N"
      xRegistro1 := Val( cRegistro1 )
      xRegistro2 := Val( cRegistro2 )
   CASE _aEstructura[ _aIndiceCampo[ _nIndiceActivo ], DBS_TYPE ] == "D"
      xRegistro1 := CToD( cRegistro1 )
      xRegistro2 := CToD( cRegistro2 )
   CASE _aEstructura[ _aIndiceCampo[ _nIndiceActivo ], DBS_TYPE ] == "L"
      xRegistro1 := ( cRegistro1 == ".t." )
      xRegistro2 := ( cRegistro2 == ".t." )
   ENDCASE
   ( _cArea )->( dbSeek( xRegistro2 ) )
   nUltimo := ( _cArea )->( RecNo() )
   ( _cArea )->( dbSeek( xRegistro1 ) )
   nPrimero := ( _cArea )->( RecNo() )

   // ------- Obtiene el número de páginas.---------------------------------------
   nTotales := 1
   ( _cArea )->( dbEval( {|| nTotales++ },, {|| !( RecNo() == nUltimo ) .and. !Eof() },,, .T. ) )
   ( _cArea )->( dbGoTo( nPrimero ) )
   IF lOrientacion
      IF Mod( nTotales, 33 ) == 0
         nPaginas := Int( nTotales / 33 )
      ELSE
         nPaginas := Int( nTotales / 33 ) + 1
      ENDIF
   ELSE
      IF Mod( nTotales, 55 ) == 0
         nPaginas := Int( nTotales / 55 )
      ELSE
         nPaginas := Int( nTotales / 55 ) + 1
      ENDIF
   ENDIF

   // ------- Inicializa el listado.----------------------------------------------
   INIT PRINTSYS

   // Opciones de la impresión.
   IF lPrevio
      SELECT PRINTER cImpresora PREVIEW
   ELSE
      SELECT PRINTER cImpresora
   ENDIF
   IF lVistas
      ENABLE THUMBNAILS
   ENDIF

   // Control de errores.
   IF HBPRNERROR > 0
      msgExclamation( _HMG_aLangUser[ 25 ], _cTitulo )

      RETURN NIL
   ENDIF

   // Definición de las fuentes del listado.
   DEFINE FONT "a8"   name "arial" size 8
   DEFINE FONT "a9"   name "arial" size 9
   DEFINE FONT "a9n"  name "arial" size 9  bold
   DEFINE FONT "a10"  NAME "arial" size 10
   DEFINE FONT "a12n" name "arial" size 12 bold

   // Definición de los tipos de linea.
   DEFINE PEN "l0" STYLE PS_SOLID width 0.0 color 0x000000
   DEFINE PEN "l1" STYLE PS_SOLID width 0.1 color 0x000000
   DEFINE PEN "l2" STYLE PS_SOLID width 0.2 color 0x000000

   // Definición de los patrones de relleno.
   DEFINE BRUSH "s0" STYLE BS_NULL
   DEFINE BRUSH "s1" STYLE BS_SOLID color RGB( 220, 220, 220 )

   // Inicio del listado.
   lCabecera := .t.
   lSalida   := .t.
   nFila     := iif( Empty( _cFiltro ), 12, 13 )
   nPagina   := 1
   START DOC
   SET UNITS ROWCOL
   IF lOrientacion
      SET PAGE ORIENTATION DMORIENT_LANDSCAPE ;
         PAPERSIZE DMPAPER_A4 FONT "a10"
   ELSE
      SET PAGE ORIENTATION DMORIENT_PORTRAIT  ;
         PAPERSIZE DMPAPER_A4 FONT "a10"
   ENDIF
   START PAGE
   DO WHILE lSalida

      // Cabecera el listado.
      IF lCabecera
         SET text align right
         SELECT pen "l2"
         @ 5, HBPRNMAXCOL - 5 say _cTitulo     font "a12n" to print
         @ 6, 10, 6, HBPRNMAXCOL - 5 line
         SELECT pen "l0"
         @ 7, 29 say _HMG_aLangUser[ 26 ]      font "a9n" to print
         @ 8, 29 say _HMG_aLangUser[ 27 ]      font "a9n" to print
         @ 9, 29 say _HMG_aLangUser[ 28 ]      font "a9n" to print
         IF ! Empty( _cFiltro )
            @ 10, 29 say _HMG_aLangUser[33 ] font "a9n" to print
         ENDIF
         SET text align left
         @ 7, 31 say ( _cArea )->( ordName() ) font "a9"  to print
         @ 8, 31 say cRegistro1                font "a9"  to print
         @ 9, 31 say cRegistro2                font "a9"  to print
         IF ! Empty( _cFiltro )
            @ 10, 31 say _cFiltro         font "a9"  to print
         ENDIF
         nColumna := 10
         SELECT pen "l1"
         SELECT brush "s1"
         FOR i := 1 to Len( aCampo )
            @ nFila - .9, nColumna, nFila, nColumna + aAncho[ i ] fillrect
            @ nFila - 1, nColumna + 1 say aCampo[ i ] font "a9n" to print
            nColumna += aAncho[ i ]
         NEXT
         SELECT pen "l0"
         SELECT brush "s0"
         lCabecera := .f.
      ENDIF

      // Registros.
      nColumna := 10
      FOR i := 1 to Len( aNumeroCampo )
         nCampo := aNumeroCampo[ i ]
         DO CASE
         CASE _aEstructura[ nCampo, DBS_TYPE ] == "N"
            SET text align right
            @ nFila, nColumna + aAncho[ i ] say ( _cArea )->( FieldGet( aNumeroCampo[ i ] ) ) font "a8" to print
         CASE _aEstructura[ nCampo, DBS_TYPE ] == "L"
            SET text align left
            @ nFila, nColumna + 1 say iif( ( _cArea )->( FieldGet( aNumeroCampo[ i ] ) ), _HMG_aLangUser[ 29 ], _HMG_aLangUser[ 30 ] ) font "a8" to print
         CASE _aEstructura[ nCampo, DBS_TYPE ] == "M"
            SET text align left
            @ nFila, nColumna + 1 say SubStr( ( _cArea )->( FieldGet( aNumeroCampo[ i ] ) ), 1, 20 ) font "a8" to print
         OTHERWISE
            SET text align left
            @ nFila, nColumna + 1 say ( _cArea )->( FieldGet( aNumeroCampo[ i ] ) ) font "a8" to print
         ENDCASE
         nColumna += aAncho[ i ]
      NEXT
      nFila++

      // Comprueba el final del registro.
      IF ( _cArea )->( RecNo() ) == nUltimo .or. ( _cArea )->( EOF() )
         lSalida := .f.
      ENDIF
      ( _cArea )->( dbSkip( 1 ) )

      // Pie.
      IF lOrientacion
         IF nFila > 44
            SET text align left
            SELECT pen "l2"
            @ 46, 10, 46, HBPRNMAXCOL - 5 line
            cPie := HB_ValToStr( Date() ) + " " + Time()
            @ 46, 10 say cPie font "a9n" to print
            SET text align right
            cPie := _HMG_aABMLangLabel[ 22 ] +        ;
               AllTrim( Str( nPagina ) ) +      ;
               "/" +                           ;
               AllTrim( Str( nPaginas ) )
            @ 46, HBPRNMAXCOL - 5 say cPie font "a9n" to print
            nPagina++
            nFila := iif( Empty( _cFiltro ), 12, 13 )
            lCabecera := .t.
         END PAGE
         START PAGE
      ENDIF
   ELSE
      IF nFila > 66
         SET text align left
         SELECT pen "l2"
         @ 68, 10, 68, HBPRNMAXCOL - 5 line
         cPie := HB_ValToStr( Date() ) + " " + Time()
         @ 68, 10 say cPie font "a9n" to print
         SET text align right
         cPie := _HMG_aABMLangLabel[ 22 ] +        ;
            AllTrim( Str( nPagina ) ) +      ;
            "/" +                           ;
            AllTrim( Str( nPaginas ) )
         @ 68, HBPRNMAXCOL - 5 say cPie font "a9n" to print
         nFila := iif( Empty( _cFiltro ), 12, 13 )
         nPagina++
         lCabecera := .t.
      END PAGE
      START PAGE
   ENDIF
ENDIF
ENDDO

// Comprueba que se imprime el pie de la ultima hoja.----------
IF nPagina == nPaginas
   IF lOrientacion
      SET text align left
      SELECT pen "l2"
      @ 46, 10, 46, HBPRNMAXCOL - 5 line
      cPie := HB_ValToStr( Date() ) + " " + Time()
      @ 46, 10 say cPie font "a9n" to print
      SET text align right
      cPie := _HMG_aABMLangLabel[ 22 ] +        ;
         AllTrim( Str( nPagina ) ) +      ;
         "/" +                           ;
         AllTrim( Str( nPaginas ) )
      @ 46, HBPRNMAXCOL - 5 say cPie font "a9n" to print
   ELSE
      SET text align left
      SELECT pen "l2"
      @ 68, 10, 68, HBPRNMAXCOL - 5 line
      cPie := HB_ValToStr( Date() ) + " " + Time()
      @ 68, 10 say cPie font "a9n" to print
      SET text align right
      cPie := _HMG_aABMLangLabel[ 22 ] +        ;
         AllTrim( Str( nPagina ) ) +      ;
         "/" +                           ;
         AllTrim( Str( nPaginas ) )
      @ 68, HBPRNMAXCOL - 5 say cPie font "a9n" to print
   ENDIF

END PAGE
ENDIF
END DOC

RELEASE PRINTSYS

// ------- Cierra la ventana.--------------------------------------------------
( _cArea )->( dbGoTo( nRegistro ) )
wndABM2Listado.Release

RETURN NIL
