/*
* Implementación del comando EDIT EXTENDED para la librería HMG.
* (c) Cristóbal Mollá [cemese@terra.es]

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this software; see the file COPYING. If not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA (or
visit the web site http://www.gnu.org/).

As a special exception, you have permission for additional uses of the text
contained in this file.

The exception is that, if you link this code with other
files to produce an executable, this does not by itself cause the resulting
executable to be covered by the GNU General Public License.
Your use of that executable is in no way restricted on account of linking
this code into it.

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
*      [aTableView]            Matriz de valores lógicos que indica si el campo referenciado
*                              por la matriz es visible en la tabla. Tiene que tener el mismo
*                              numero de elementos que campos la bdd. Por defecto toma todos
*                              los valores como verdaderos ( .t. ).
*      [aOptions]              Matriz de 2 niveles. el primero de tipo texto es la descripción
*                              de la opción. El segundo de tipo bloque de código es la opción
*                              a ejecutar cuando se selecciona. Si no se pasa esta variable,
*                              se desactiva la lista desplegable de opciones.
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
*      Ver DEMO.PRG para ejemplo de llamada al comando.
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
*              - Se cambia la referencia a _ExtendedNavigation por _HMG_SYSDATA [ 255 ]
*                para adecuarse a la sintaxis de la construción 76.
*              - Idioma Alemán listo. Gracias a Andreas Wiltfang.
*      Nov 03  - Problema con dbs en set exclusive. Gracias a cas_HMG.
*              - Problema con tablas con pocos campos. Gracias a cas_HMG.
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

MEMVAR _HMG_SYSDATA
MEMVAR _HMG_CMACROTEMP

// Ficheros de definiciones.---------------------------------------------------
#include "hmg.ch"
#include "dbstruct.ch"

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

// Declaración de variables globales.------------------------------------------
STATIC _cArea           as character            // Nombre del area de la bdd.
STATIC _aEstructura     as array                // Estructura de la bdd.
STATIC _aIndice         as array                // Nombre de los indices de la bdd.
STATIC _aIndiceCampo    as array                // Número del campo indice.
STATIC _nIndiceActivo   as array                // Indice activo.
STATIC _aNombreCampo    as array                // Nombre desciptivo de los campos de la bdd.
STATIC _aEditable       as array                // Indicador de si son editables.
STATIC _cTitulo         as character            // Título de la ventana.
STATIC _nAltoPantalla   as numeric              // Alto de la pantalla.
STATIC _nAnchoPantalla  as numeric              // Ancho de la pantalla.
STATIC _aEtiqueta       as array                // Datos de las etiquetas.
STATIC _aControl        as array                // Datos de los controles.
STATIC _aCampoTabla     as array                // Nombre de los campos para la tabla.
STATIC _aAnchoTabla     as array                // Anchos de los campos para la tabla.
STATIC _aCabeceraTabla  as array                // Texto de las columnas de la tabla.
STATIC _aAlineadoTabla  as array                // Alineación de las columnas de la tabla.
STATIC _aVisibleEnTabla as array                // Campos visibles en la tabla.
STATIC _nControlActivo  as numeric              // Control con foco.
STATIC _aOpciones       as array                // Opciones del usuario.
STATIC _bGuardar        as codeblock            // Acción para guardar registro.
STATIC _bBuscar         as codeblock            // Acción para buscar registro.
STATIC _bImprimir       as codeblock            // Acción para imprimir listado.
STATIC _lFiltro         as logical              // Indicativo de filtro activo.
STATIC _cFiltro         as character            // Condición de filtro.

/****************************************************************************************
*  Aplicación: Comando EDIT para HMG
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
      aOpciones, bGuardar, bBuscar, ;
      bImprimir )

   ////////// Declaración de variables locales.-----------------------------------
   LOCAL   i              as numeric       // Indice de iteración.
   LOCAL   k              as numeric       // Indice de iteración.
   LOCAL   nArea          as numeric       // Numero del area de la bdd.
   LOCAL   nRegistro      as numeric       // Número de regisrto de la bdd.
   LOCAL   lSalida        as logical       // Control de bucle.
   LOCAL   nVeces         as numeric       // Indice de iteración.
   LOCAL   cIndice        as character     // Nombre del indice.
   LOCAL   cIndiceActivo  as character     // Nombre del indice activo.
   LOCAL   cClave         as character     // Clave del indice.
   LOCAL   nInicio        as numeric       // Inicio de la cadena de busqueda.
   LOCAL   nAnchoCampo    as numeric       // Ancho del campo actual.
   LOCAL   nAnchoEtiqueta as numeric       // Ancho máximo de las etiquetas.
   LOCAL   nFila          as numeric       // Fila de creación del control de edición.
   LOCAL   nColumna       as numeric       // Columna de creación del control de edición.
   LOCAL   aTextoOp       as numeric       // Texto de las opciones de usuario.
   LOCAL   _BakExtendedNavigation          // Estado de SET NAVIAGTION.
   LOCAL _BackDeleted
   LOCAL cFiltroAnt     as character     // Condición del filtro anterior.
   PUBLIC  nImpLen

   ////////// Gusrdar estado actual de SET DELETED y activarlo
   _BackDeleted := set( _SET_DELETED )
   SET DELETED ON

   ////////// Inicialización del soporte multilenguaje.---------------------------
   InitMessages()

   ////////// Desactivación de SET NAVIGATION.------------------------------------
   _BakExtendedNavigation := _HMG_SYSDATA [ 255 ]
   _HMG_SYSDATA [ 255 ]    := .F.

   ////////// Control de parámetros.----------------------------------------------
   // Area de la base de datos.
   IF ( ValType( cArea ) != "C" ) .or. Empty( cArea )
      _cArea := Alias()
      IF _cArea == ""
         msgExclamation( _HMG_SYSDATA [ 130 ][1], "EDIT EXTENDED" )

         RETURN NIL
      ENDIF
   ELSE
      _cArea := cArea
   ENDIF
   _aEstructura := (_cArea)->( dbStruct() )

   // Título de la ventana.
   IF ( cTitulo == NIL )
      _cTitulo := _cArea
   ELSE
      IF ( Valtype( cTitulo ) != "C" )
         _cTitulo := _cArea
      ELSE
         _cTitulo := cTitulo
      ENDIF
   ENDIF

   // Nombres de los campos.
   lSalida := .t.
   IF ( ValType( aNombreCampo ) != "A" )
      lSalida := .f.
   ELSE
      IF ( HMG_LEN( aNombreCampo ) != HMG_LEN( _aEstructura ) )
         lSalida := .f.
      ELSE
         FOR i := 1 to HMG_LEN( aNombreCampo )
            IF ValType( aNombreCampo[i] ) != "C"
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
      FOR i := 1 to HMG_LEN( _aEstructura )
         aAdd( _aNombreCampo, HMG_UPPER( HB_ULEFT( _aEstructura[i,DBS_NAME], 1 ) ) + ;
            HMG_LOWER( HB_USUBSTR( _aEstructura[i,DBS_NAME], 2 ) ) )
      NEXT
   ENDIF

   // Texto de aviso en la barra de estado de la ventana de edición de registro.
   lSalida := .t.
   IF ( ValType( aAvisoCampo ) != "A" )
      lSalida := .f.
   ELSE
      IF ( HMG_LEN( aAvisoCampo ) != HMG_LEN( _aEstructura ) )
         lSalida := .f.
      ELSE
         FOR i := 1 to HMG_LEN( aAvisoCampo )
            IF Valtype( aAvisoCampo[i] ) != "C"
               lSalida := .f.
               EXIT
            ENDIF
         NEXT
      ENDIF
   ENDIF
   IF !lSalida
      aAvisoCampo := {}
      FOR i := 1 to HMG_LEN( _aEstructura )
         DO CASE
         CASE _aEstructura[i,DBS_TYPE] == "C"
            aAdd( aAvisoCampo, _HMG_SYSDATA [ 130 ][2] )
         CASE _aEstructura[i,DBS_TYPE] == "N"
            aAdd( aAvisoCampo, _HMG_SYSDATA [ 130 ][3] )
         CASE _aEstructura[i,DBS_TYPE] == "D"
            aAdd( aAvisoCampo, _HMG_SYSDATA [ 130 ][4] )
         CASE _aEstructura[i,DBS_TYPE] == "L"
            aAdd( aAvisoCampo, _HMG_SYSDATA [ 130 ][5] )
         CASE _aEstructura[i,DBS_TYPE] == "M"
            aAdd( aAvisoCampo, _HMG_SYSDATA [ 130 ][6] )
         OTHERWISE
            aAdd( aAvisoCampo, _HMG_SYSDATA [ 130 ][7] )
         ENDCASE
      NEXT
   ENDIF

   // Campos visibles en la tabla de la ventana de visualización de registros.
   lSalida := .t.
   IF ( Valtype( aVisibleEnTabla ) != "A" )
      lSalida := .f.
   ELSE
      IF HMG_LEN( aVisibleEnTabla ) != HMG_LEN( _aEstructura )
         lSalida := .f.
      ELSE
         FOR i := 1 to HMG_LEN( aVisibleEnTabla )
            IF ValType( aVisibleEnTabla[i] ) != "L"
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
      FOR i := 1 to HMG_LEN( _aEstructura )
         aAdd( _aVisibleEnTabla, .t. )
      NEXT
   ENDIF

   // Estado de los campos en la ventana de edición de registro.
   lSalida := .t.
   IF ( ValType( aEditable ) != "A" )
      lSalida := .f.
   ELSE
      IF HMG_LEN( aEditable ) != HMG_LEN( _aEstructura )
         lSalida := .f.
      ELSE
         FOR i := 1 to HMG_LEN( aEditable )
            IF ValType( aEditable[i] ) != "L"
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
      FOR i := 1 to HMG_LEN( _aEstructura )
         aAdd( _aEditable, .t.)
      NEXT
   ENDIF

   **** JK 104

   // Opciones del usuario.
   lSalida := .t.

   IF ValType( aOpciones ) != "A"
      lSalida := .f.
   ELSEIF HMG_LEN(aOpciones)<1
      lSalida := .f.
   ELSEIF HMG_LEN( aOpciones[1] ) != 2
      lSalida := .f.
   ELSE
      FOR i := 1 to HMG_LEN( aOpciones )
         IF ValType( aOpciones [i,ABM_OPC_TEXTO] ) != "C"
            lSalida := .f.
            EXIT
         ENDIF
         IF ValType( aOpciones [i,ABM_OPC_BLOQUE] ) != "B"
            lSalida := .f.
            EXIT
         ENDIF
      NEXT
   ENDIF

   **** END JK 104

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

   ////////// Selección del area de la bdd.---------------------------------------
   nRegistro     := (_cArea)->( RecNo() )
   nArea         := Select()
   cIndiceActivo := (_cArea)->( ordSetFocus() )
   cFiltroAnt    := (_cArea)->( dbFilter() )
   dbSelectArea( _cArea )
   (_cArea)->( dbGoTop() )

   ////////// Inicialización de variables.----------------------------------------
   // Filtro.
   IF (_cArea)->( dbFilter() ) == ""
      _lFiltro := .f.
   ELSE
      _lFiltro := .t.
   ENDIF
   _cFiltro := (_cArea)->( dbFilter() )

   // Indices de la base de datos.
   lSalida       := .t.
   k             := 1
   _aIndice      := {}
   _aIndiceCampo := {}
   nVeces        := 1
   aAdd( _aIndice, _HMG_SYSDATA [ 129 ][1] )
   aAdd( _aIndiceCampo, 0 )
   DO WHILE lSalida
      IF ( (_cArea)->( ordName( k ) ) == "" )
         lSalida := .f.
      ELSE
         cIndice := (_cArea)->( ordName( k ) )
         aAdd( _aIndice, cIndice )
         cClave := HMG_UPPER( (_cArea)->( ordKey( k ) ) )
         FOR i := 1 to HMG_LEN( _aEstructura )
            IF nVeces <= 1
               nInicio := HB_UAT( _aEstructura[i,DBS_NAME], cClave )
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
   IF ( (_cArea)->( ordSetFocus() ) == "" )
      _nIndiceActivo := 1
   ELSE
      _nIndiceActivo := aScan( _aIndice, (_cArea)->( ordSetFocus() ) )
   ENDIF

   // Tamaño de la pantalla.
   _nAltoPantalla  := getDesktopHeight()
   _nAnchoPantalla := getDesktopWidth()

   // Datos de las etiquetas y los controles de la ventana de edición.
   _aEtiqueta     := Array( HMG_LEN( _aEstructura ), ABM_LBL_LEN )
   _aControl      := Array( HMG_LEN( _aEstructura ), ABM_CON_LEN )
   nFila          := 10
   nColumna       := 10
   nAnchoEtiqueta := 0
   FOR i := 1 to HMG_LEN( _aNombreCampo )
      nAnchoEtiqueta := iif( nAnchoEtiqueta > ( HMG_LEN( _aNombreCampo[i] ) * 9 ),;
         nAnchoEtiqueta,;
         HMG_LEN( _aNombreCampo[i] ) * 9 )
   NEXT
   FOR i := 1 to HMG_LEN( _aEstructura )
      _aEtiqueta[i,ABM_LBL_NAME]   := "ABM2Etiqueta" + ALLTRIM( STR( i ,4,0) )
      _aEtiqueta[i,ABM_LBL_ROW]    := nFila
      _aEtiqueta[i,ABM_LBL_COL]    := nColumna
      _aEtiqueta[i,ABM_LBL_WIDTH]  := HMG_LEN( _aNombreCampo[i] ) * 9
      _aEtiqueta[i,ABM_LBL_HEIGHT] := 25
      DO CASE
      CASE _aEstructura[i,DBS_TYPE] == "C"
         _aControl[i,ABM_CON_NAME]   := "ABM2Control" + ALLTRIM( STR( i ,4,0) )
         _aControl[i,ABM_CON_ROW]    := nFila
         _aControl[i,ABM_CON_COL]    := nColumna + nAnchoEtiqueta + 20
         _aControl[i,ABM_CON_WIDTH]  := iif( ( _aEstructura[i,DBS_LEN] * 10 ) < 50, 50, _aEstructura[i,DBS_LEN] * 10 )
         _aControl[i,ABM_CON_HEIGHT] := 25
         _aControl[i,ABM_CON_DES]    := aAvisoCampo[i]
         _aControl[i,ABM_CON_TYPE]   := ABM_TEXTBOXC
         nFila += 35
      CASE _aEstructura[i,DBS_TYPE] == "D"
         _aControl[i,ABM_CON_NAME]   := "ABM2Control" + ALLTRIM( STR( i ,4,0) )
         _aControl[i,ABM_CON_ROW]    := nFila
         _aControl[i,ABM_CON_COL]    := nColumna + nAnchoEtiqueta + 20
         _aControl[i,ABM_CON_WIDTH]  := _aEstructura[i,DBS_LEN] * 10
         _aControl[i,ABM_CON_HEIGHT] := 25
         _aControl[i,ABM_CON_DES]    := aAvisoCampo[i]
         _aControl[i,ABM_CON_TYPE]   := ABM_DATEPICKER
         nFila += 35
      CASE _aEstructura[i,DBS_TYPE] == "N"
         _aControl[i,ABM_CON_NAME]   := "ABM2Control" + ALLTRIM( STR( i ,4,0) )
         _aControl[i,ABM_CON_ROW]    := nFila
         _aControl[i,ABM_CON_COL]    := nColumna + nAnchoEtiqueta + 20
         _aControl[i,ABM_CON_WIDTH]  := iif( ( _aEstructura[i,DBS_LEN] * 10 ) < 50, 50, _aEstructura[i,DBS_LEN] * 10 )
         _aControl[i,ABM_CON_HEIGHT] := 25
         _aControl[i,ABM_CON_DES]    := aAvisoCampo[i]
         _aControl[i,ABM_CON_TYPE]   := ABM_TEXTBOXN
         nFila += 35
      CASE _aEstructura[i,DBS_TYPE] == "L"
         _aControl[i,ABM_CON_NAME]   := "ABM2Control" + ALLTRIM( STR( i ,4,0) )
         _aControl[i,ABM_CON_ROW]    := nFila
         _aControl[i,ABM_CON_COL]    := nColumna + nAnchoEtiqueta + 20
         _aControl[i,ABM_CON_WIDTH]  := 25
         _aControl[i,ABM_CON_HEIGHT] := 25
         _aControl[i,ABM_CON_DES]    := aAvisoCampo[i]
         _aControl[i,ABM_CON_TYPE]   := ABM_CHECKBOX
         nFila += 35
      CASE _aEstructura[i,DBS_TYPE] == "M"
         _aControl[i,ABM_CON_NAME]   := "ABM2Control" + ALLTRIM( STR( i ,4,0) )
         _aControl[i,ABM_CON_ROW]    := nFila
         _aControl[i,ABM_CON_COL]    := nColumna + nAnchoEtiqueta + 20
         _aControl[i,ABM_CON_WIDTH]  := 300
         _aControl[i,ABM_CON_HEIGHT] := 70
         _aControl[i,ABM_CON_DES]    := aAvisoCampo[i]
         _aControl[i,ABM_CON_TYPE]   := ABM_EDITBOX
         nFila += 80
      ENDCASE
   NEXT

   // Datos de la tabla de la ventana de visualización.
   _aCampoTabla    := {}
   _aAnchoTabla    := {}
   _aCabeceraTabla := {}
   _aAlineadoTabla := {}
   FOR i := 1 to HMG_LEN( _aEstructura )
      IF _aVisibleEnTabla[i]
         aAdd( _aCampoTabla, _cArea + "->" + _aEstructura[i, DBS_NAME] )
         nAnchoCampo    := iif( ( _aEstructura[i,DBS_LEN] * 10 ) < 50,   ;
            50,                                    ;
            _aEstructura[i,DBS_LEN] * 10 )
         nAnchoEtiqueta := HMG_LEN( _aNombreCampo[i] ) * 10
         aAdd( _aAnchoTabla, iif( nAnchoEtiqueta > nAnchoCampo,          ;
            nAnchoEtiqueta,                        ;
            nAnchoCampo ) )
         aAdd( _aCabeceraTabla, _aNombreCampo[i] )
         aAdd( _aAlineadoTabla, iif( _aEstructura[i,DBS_TYPE] == "N",     ;
            BROWSE_JTFY_RIGHT,                   ;
            BROWSE_JTFY_LEFT ) )
      ENDIF
   NEXT

   ////////// Definición de la ventana de visualización.--------------------------
   DEFINE WINDOW wndABM2Edit               ;
         AT 60, 30                       ;
         WIDTH _nAnchoPantalla - 60      ;
         HEIGHT _nAltoPantalla - 140     ;
         TITLE _cTitulo                  ;
         modal                           ;
         NOSIZE                          ;
         NOSYSMENU                       ;
         ON INIT {|| ABM2Redibuja() }    ;
         ON RELEASE {|| ABM2salir(nRegistro, cIndiceActivo, cFiltroAnt, nArea) }   ;
         font "ms sans serif" size 9

      // Define la barra de estado de la ventana de visualización.
      DEFINE STATUSBAR font "ms sans serif" size 9
         statusitem _HMG_SYSDATA [ 129 ][19]                           // 1
         statusitem _HMG_SYSDATA [ 129 ][20]         width 100 raised  // 2
         statusitem _HMG_SYSDATA [ 129 ][2] +': '     width 200 raised // 3
      END STATUSBAR

      // Define la barra de botones de la ventana de visualización.
      DEFINE TOOLBAR tbEdit buttonsize 90, 32 flat righttext border
         button tbbCerrar  caption _HMG_SYSDATA [ 128 ][1]   ;
            PICTURE "HMG_EDIT_CLOSE"          ;
            ACTION  wndABM2Edit.Release
         button tbbNuevo   caption _HMG_SYSDATA [ 128 ][2]               ;
            PICTURE "HMG_EDIT_NEW"            ;
            ACTION  {|| ABM2Editar( .t. ) }
         button tbbEditar  caption _HMG_SYSDATA [ 128 ][3]               ;
            PICTURE "HMG_EDIT_EDIT"           ;
            ACTION  {|| ABM2Editar( .f. ) }
         button tbbBorrar  caption _HMG_SYSDATA [ 128 ][4]               ;
            PICTURE "HMG_EDIT_DELETE"         ;
            ACTION  {|| ABM2Borrar() }
         button tbbBuscar  caption _HMG_SYSDATA [ 128 ][5]               ;
            PICTURE "HMG_EDIT_FIND"           ;
            ACTION  {|| ABM2Buscar() }
         button tbbListado caption _HMG_SYSDATA [ 128 ][6]               ;
            PICTURE "HMG_EDIT_PRINT"          ;
            ACTION  {|| ABM2Imprimir() }
      END toolbar

   END WINDOW

   ////////// Creación de los controles de la ventana de visualización.-----------
   @ 45, 10 frame frmEditOpciones          ;
      of wndABM2Edit                  ;
      CAPTION ""                      ;
      WIDTH wndABM2Edit.Width - 25    ;
      HEIGHT 65
   @ 112, 10 frame frmEditTabla            ;
      of wndABM2Edit                  ;
      CAPTION ""                      ;
      WIDTH wndABM2Edit.Width - 25    ;
      HEIGHT wndABM2Edit.Height - 165
   @ 60, 20 label lblIndice               ;
      of wndABM2Edit                  ;
      VALUE _HMG_SYSDATA [ 130 ] [26]            ;
      WIDTH 150                       ;
      HEIGHT 25                       ;
      font "ms sans serif" size 9
   @ 75, 20 combobox cbIndices                     ;
      of wndABM2Edit                          ;
      ITEMS _aIndice                          ;
      VALUE _nIndiceActivo                    ;
      WIDTH 150                               ;
      font "arial" size 9                     ;
      ON CHANGE {|| ABM2CambiarOrden() }
   nColumna := wndABM2Edit.Width - 175
   aTextoOp := {}
   FOR i := 1 to HMG_LEN( _aOpciones )
      aAdd( aTextoOp, _aOpciones[i,ABM_OPC_TEXTO] )
   NEXT
   @ 60, nColumna label lblOpciones        ;
      of wndABM2Edit                  ;
      VALUE _HMG_SYSDATA [ 129 ] [5]            ;
      WIDTH 150                       ;
      HEIGHT 25                       ;
      font "ms sans serif" size 9
   @ 75, nColumna combobox cbOpciones              ;
      of wndABM2Edit                          ;
      ITEMS aTextoOp                          ;
      VALUE 1                                 ;
      WIDTH 150                               ;
      font "arial" size 9                     ;
      ON CHANGE {|| ABM2EjecutaOpcion() }
   @ 65, (wndABM2Edit.Width / 2)-110 button btnFiltro1     ;
      of wndABM2Edit                                  ;
      CAPTION _HMG_SYSDATA [ 128 ][10]                       ;
      ACTION {|| ABM2ActivarFiltro() }                ;
      WIDTH 100                                       ;
      HEIGHT 32                                       ;
      font "ms sans serif" size 9
   @ 65, (wndABM2Edit.Width / 2)+5 button btnFiltro2       ;
      of wndABM2Edit                                  ;
      CAPTION _HMG_SYSDATA [ 128 ][11]                    ;
      ACTION {|| ABM2DesactivarFiltro() }             ;
      WIDTH 100                                       ;
      HEIGHT 32                                       ;
      font "ms sans serif" size 9
   @ 132, 20 browse brwABM2Edit                                                    ;
      of wndABM2Edit                                                          ;
      WIDTH wndABM2Edit.Width - 45                                            ;
      HEIGHT wndABM2Edit.Height - 195                                         ;
      HEADERS _aCabeceraTabla                                                 ;
      WIDTHS _aAnchoTabla                                                     ;
      WORKAREA &_cArea                                                        ;
      FIELDS _aCampoTabla                                                     ;
      VALUE ( _cArea)->( RecNo() )                                            ;
      font "arial" size 9                                                     ;
      ON CHANGE {|| (_cArea)->( dbGoto( wndABM2Edit.brwABM2Edit.Value ) ),    ;
      ABM2Redibuja( .f. ) }                                     ;
      ON DBLCLICK ABM2Editar( .f. )                                           ;
      JUSTIFY _aAlineadoTabla

   // Comprueba el estado de las opciones de usuario.
   IF HMG_LEN( _aOpciones ) == 0
      wndABM2Edit.cbOpciones.Enabled := .f.
   ENDIF

   ////////// Activación de la ventana de visualización.--------------------------
   ACTIVATE WINDOW wndABM2Edit

   ////////// Restauración de SET NAVIGATION.-------------------------------------
   _HMG_SYSDATA [ 255 ] := _BakExtendedNavigation

   ////////// Restaurar SET DELETED a su valor inicial

   set( _SET_DELETED , _BackDeleted  )

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para HMG
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2salir()
   * Descripción: Cierra la ventana de visualización de registros y sale.
   *  Parámetros: Ninguno.
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABM2salir( nRegistro, cIndiceActivo, cFiltroAnt, nArea )

   ////////// Declaración de variables locales.-----------------------------------
   LOCAL bFiltroAnt as codeblock           // Bloque de código del filtro.

   ////////// Inicialización de variables.----------------------------------------
   bFiltroAnt := iif( Empty( cFiltroAnt ),;
      &("{||NIL}"),;
      &("{||" + cFiltroAnt + "}") )

   ////////// Restaura el area de la bdd inicial.---------------------------------
   (_cArea)->( dbGoTo( nRegistro ) )
   (_cArea)->( ordSetFocus( cIndiceActivo ) )
   (_cArea)->( dbSetFilter( bFiltroAnt, cFiltroAnt ) )
   dbSelectArea( nArea )

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para HMG
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2Redibuja()
   * Descripción: Actualización de la ventana de visualización de registros.
   *  Parámetros: Ninguno
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABM2Redibuja( lTabla )

   ////////// Control de parámetros.----------------------------------------------
   IF ValType( lTabla ) != "L"
      lTabla := .f.
   ENDIF

   ////////// Refresco de la barra de botones.------------------------------------
   IF (_cArea)->( RecCount() ) == 0
      wndABM2Edit.tbbEditar.Enabled  := .f.
      wndABM2Edit.tbbBorrar.Enabled  := .f.
      wndABM2Edit.tbbBuscar.Enabled  := .f.
      wndABM2Edit.tbbListado.Enabled := .f.
   ELSE
      wndABM2Edit.tbbEditar.Enabled  := .t.
      wndABM2Edit.tbbBorrar.Enabled  := .t.
      wndABM2Edit.tbbBuscar.Enabled  := .t.
      wndABM2Edit.tbbListado.Enabled := .t.
   ENDIF

   ////////// Refresco de la barra de estado.-------------------------------------
   wndABM2Edit.StatusBar.Item( 1 ) := _HMG_SYSDATA [ 129 ][19] + _cFiltro
   wndABM2Edit.StatusBar.Item( 2 ) := _HMG_SYSDATA [ 129 ][20] + iif( _lFiltro, _HMG_SYSDATA [ 130 ][29], _HMG_SYSDATA [ 130 ][30] )
   wndABM2Edit.StatusBar.Item( 3 ) := _HMG_SYSDATA [ 129 ][2] + ': '+                                  ;
      ALLTRIM( STR( (_cArea)->( RecNo() ) ) ) + "/" + ;
      ALLTRIM( STR( (_cArea)->( RecCount() ) ) )

   ////////// Refresca el browse si se indica.
   IF lTabla
      wndABM2Edit.brwABM2Edit.Value := (_cArea)->( RecNo() )
      wndABM2Edit.brwABM2Edit.Refresh
   ENDIF

   ////////// Coloca el foco en el browse.
   wndABM2Edit.brwABM2Edit.SetFocus

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para HMG
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2CambiarOrden()
   * Descripción: Cambia el orden activo.
   *  Parámetros: Ninguno
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABM2CambiarOrden()

   ////////// Declaración de variables locales.-----------------------------------
   LOCAL cIndice as character              // Nombre del indice.
   LOCAL nIndice as numeric                // Número del indice.

   ////////// Inicializa las variables.-------------------------------------------
   nIndice := wndABM2Edit.cbIndices.Value
   cIndice := wndABM2Edit.cbIndices.Item( nIndice )

   ////////// Cambia el orden del area de trabajo.--------------------------------
   nIndice--
   (_cArea)->( ordSetFocus( nIndice ) )
   // (_cArea)->( dbGoTop() )
   nIndice++
   _nIndiceActivo := nIndice
   ABM2Redibuja( .t. )

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para HMG
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2EjecutaOpcion()
   * Descripción: Ejecuta las opciones del usuario.
   *  Parámetros: Ninguno
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABM2EjecutaOpcion()

   ////////// Declaración de variables locales.-----------------------------------
   LOCAL nItem    as numeric               // Numero del item seleccionado.
   LOCAL bBloque  as codebloc              // Bloque de codigo a ejecutar.

   ////////// Inicialización de variables.----------------------------------------
   nItem   := wndABM2Edit.cbOpciones.Value
   bBloque := _aOpciones[nItem,ABM_OPC_BLOQUE]

   ////////// Ejecuta la opción.--------------------------------------------------
   Eval( bBloque )

   ////////// Refresca el browse.
   ABM2Redibuja( .t. )

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para HMG
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2Editar( lNuevo )
   * Descripción: Creación de la ventana de edición de registro.
   *  Parámetros: lNuevo          Valor lógico que indica si se está añadiendo un registro
   *                              o editando el actual.
   *    Devuelve:
   ****************************************************************************************/

STATIC FUNCTION ABM2Editar( lNuevo )

   ////////// Declaración de variables locales.-----------------------------------
   LOCAL i              as numeric         // Indice de iteración.
   LOCAL nAnchoEtiqueta as numeric         // Ancho máximo de las etiquetas.
   LOCAL nAltoControl   as numeric         // Alto total de los controles de edición.
   LOCAL nAncho         as numeric         // Ancho de la ventana de edición .
   LOCAL nAlto          as numeric         // Alto de la ventana de edición.
   LOCAL nAnchoTope     as numeric         // Ancho máximo de la ventana de edición.
   LOCAL nAltoTope      as numeric         // Alto máximo de la ventana de edición.
   LOCAL nAnchoSplit    as numeric         // Ancho de la ventana Split.
   LOCAL nAltoSplit     as numeric         // Alto de la ventana Split.
   LOCAL cTitulo        as character       // Título de la ventana.
   LOCAL cMascara       as array           // Máscara de edición de los controles numéricos.
   LOCAL NANCHOCONTROL

   ////////// Control de parámetros.----------------------------------------------
   IF ( ValType( lNuevo ) != "L" )
      lNuevo := .t.
   ENDIF

   ////////// Incialización de variables.-----------------------------------------
   nAnchoEtiqueta := 0
   nAnchoControl  := 0
   nAltoControl   := 0
   FOR i := 1 to HMG_LEN( _aEtiqueta )
      nAnchoEtiqueta := iif( nAnchoEtiqueta > _aEtiqueta[i,ABM_LBL_WIDTH],;
         nAnchoEtiqueta,;
         _aEtiqueta[i,ABM_LBL_WIDTH] )
      nAnchoControl  := iif( nAnchoControl > _aControl[i,ABM_CON_WIDTH],;
         nAnchoControl,;
         _aControl[i,ABM_CON_WIDTH] )
      nAltoControl   += _aControl[i,ABM_CON_HEIGHT] + 10
   NEXT
   nAltoSplit  := 10 + nAltoControl + 10 + 15
   nAnchoSplit := 10 + nAnchoEtiqueta + 10 + nAnchoControl + 10 + 15
   nAlto       := 15 + 65 + nAltoSplit + 15
   nAltoTope   := _nAltoPantalla - 130
   nAncho      := 15 + nAnchoSplit + 15
   nAncho      := iif( nAncho < 300, 300, nAncho )
   nAnchoTope  := _nAnchoPantalla - 60
   cTitulo     := iif( lNuevo, _HMG_SYSDATA [ 129 ][6], _HMG_SYSDATA [ 129 ][7] )

   ////////// Define la ventana de edición de registro.---------------------------
   DEFINE WINDOW wndABM2EditNuevo                                  ;
         AT 70, 40                                               ;
         WIDTH iif( nAncho > nAnchoTope, nAnchoTope, nAncho )    ;
         HEIGHT iif( nAlto > nAltoTope, nAltoTope, nAlto )       ;
         TITLE cTitulo                                           ;
         modal                                                   ;
         NOSIZE                                                  ;
         NOSYSMENU                                               ;
         font "ms sans serif" size 9

      // Define la barra de estado de la ventana de edición de registro.
      DEFINE STATUSBAR font "ms sans serif" size 9
         statusitem ""
      END STATUSBAR

      DEFINE SPLITBOX

         // Define la barra de botones de la ventana de edición de registro.
         DEFINE TOOLBAR tbEditNuevo buttonsize 90, 32 flat righttext
            button tbbCancelar caption _HMG_SYSDATA [ 128 ][7]              ;
               PICTURE "HMG_EDIT_CANCEL"        ;
               ACTION  wndABM2EditNuevo.Release
            button tbbAceptar  caption _HMG_SYSDATA [ 128 ][8]              ;
               PICTURE "HMG_EDIT_OK"            ;
               ACTION  ABM2EditarGuardar( lNuevo )
            button tbbCopiar   caption _HMG_SYSDATA [ 128 ][9]              ;
               PICTURE "HMG_EDIT_COPY"          ;
               ACTION  ABM2EditarCopiar()
         END toolbar

         // Define la ventana donde van contenidos los controles de edición.
         DEFINE WINDOW wndABM2EditNuevoSplit             ;
               WIDTH iif( nAncho > nAnchoTope,         ;
               nAnchoTope - 10,             ;
               nAnchoSplit  - 1 )           ;
               HEIGHT iif( nAlto > nAltoTope,          ;
               nAltoTope - 95,             ;
               nAltoSplit - 1 )            ;
               VIRTUAL width nAnchoSplit               ;
               VIRTUAL height nAltoSplit               ;
               splitchild                              ;
               nocaption                               ;
               font "ms sans serif" size 9             ;
               focused
         END WINDOW
      END SPLITBOX
   END WINDOW

   ////////// Define las etiquetas de los controles.------------------------------
   FOR i := 1 to HMG_LEN( _aEtiqueta )

      _HMG_cMacroTemp := _aEtiqueta[i,ABM_LBL_NAME]

      @ _aEtiqueta[i,ABM_LBL_ROW], _aEtiqueta[i,ABM_LBL_COL]  ;
         LABEL &_HMG_cMacroTemp ;
         of wndABM2EditNuevoSplit                        ;
         VALUE _aNombreCampo[i]                          ;
         WIDTH _aEtiqueta[i,ABM_LBL_WIDTH]               ;
         HEIGHT _aEtiqueta[i,ABM_LBL_HEIGHT]             ;
         font "ms sans serif" size 9
   NEXT

   ////////// Define los controles de edición.------------------------------------
   FOR i := 1 to HMG_LEN( _aControl )
      DO CASE
      CASE _aControl[i,ABM_CON_TYPE] == ABM_TEXTBOXC

         _HMG_cMacroTemp := _aControl[i,ABM_CON_NAME]
         @ _aControl[i,ABM_CON_ROW], _aControl[i,ABM_CON_COL]    ;
            TEXTbox &_HMG_cMacroTemp                      ;
            of wndABM2EditNuevoSplit                        ;
            VALUE ""                                        ;
            HEIGHT _aControl[i,ABM_CON_HEIGHT]              ;
            WIDTH _aControl[i,ABM_CON_WIDTH]                ;
            font "arial" size 9                             ;
            MAXLENGTH _aEstructura[i,DBS_LEN]               ;
            ON GOTFOCUS ABM2ConFoco()                       ;
            ON LOSTFOCUS ABM2SinFoco()                      ;
            ON ENTER ABM2AlEntrar( )
      CASE _aControl[i,ABM_CON_TYPE] == ABM_DATEPICKER
         _HMG_cMacroTemp := _aControl[i,ABM_CON_NAME]
         @ _aControl[i,ABM_CON_ROW], _aControl[i,ABM_CON_COL]    ;
            datepicker &_HMG_cMacroTemp           ;
            of wndABM2EditNuevoSplit                        ;
            HEIGHT _aControl[i,ABM_CON_HEIGHT]              ;
            WIDTH _aControl[i,ABM_CON_WIDTH] + 25           ;
            font "arial" size 9                             ;
            SHOWNONE                ;
            ON GOTFOCUS ABM2ConFoco()                       ;
            ON LOSTFOCUS ABM2SinFoco()
      CASE _aControl[i,ABM_CON_TYPE] == ABM_TEXTBOXN
         IF ( _aEstructura[i,DBS_DEC] == 0 )
            _HMG_cMacroTemp := _aControl[i,ABM_CON_NAME]
            @ _aControl[i,ABM_CON_ROW], _aControl[i,ABM_CON_COL]    ;
               TEXTbox &_HMG_cMacroTemp           ;
               of wndABM2EditNuevoSplit                        ;
               VALUE ""                                        ;
               HEIGHT _aControl[i,ABM_CON_HEIGHT]              ;
               WIDTH _aControl[i,ABM_CON_WIDTH]                ;
               NUMERIC                                         ;
               font "arial" size 9                             ;
               MAXLENGTH _aEstructura[i,DBS_LEN]               ;
               ON GOTFOCUS ABM2ConFoco( i )                    ;
               ON LOSTFOCUS ABM2SinFoco( i )                   ;
               ON ENTER ABM2AlEntrar()
         ELSE
            cMascara := ""
            cMascara := REPLICATE( "9", _aEstructura[i,DBS_LEN] -   ;
               ( _aEstructura[i,DBS_DEC] + 1 ) )
            cMascara += "."
            cMascara += REPLICATE( "9", _aEstructura[i,DBS_DEC] )
            _HMG_cMacroTemp := _aControl[i,ABM_CON_NAME]
            @ _aControl[i,ABM_CON_ROW], _aControl[i,ABM_CON_COL]    ;
               TEXTbox &_HMG_cMacroTemp              ;
               of wndABM2EditNuevoSplit                        ;
               VALUE ""                                        ;
               HEIGHT _aControl[i,ABM_CON_HEIGHT]              ;
               WIDTH _aControl[i,ABM_CON_WIDTH]                ;
               NUMERIC                                         ;
               INPUTMASK cMascara                              ;
               ON GOTFOCUS ABM2ConFoco()                       ;
               ON LOSTFOCUS ABM2SinFoco()                      ;
               ON ENTER ABM2AlEntrar()
         ENDIF
      CASE _aControl[i,ABM_CON_TYPE] == ABM_CHECKBOX
         _HMG_cMacroTemp := _aControl[i,ABM_CON_NAME]
         @ _aControl[i,ABM_CON_ROW], _aControl[i,ABM_CON_COL]    ;
            checkbox &_HMG_cMacroTemp             ;
            of wndABM2EditNuevoSplit                        ;
            CAPTION ""                                      ;
            HEIGHT _aControl[i,ABM_CON_HEIGHT]              ;
            WIDTH _aControl[i,ABM_CON_WIDTH]                ;
            VALUE .f.                                       ;
            ON GOTFOCUS ABM2ConFoco()                       ;
            ON LOSTFOCUS ABM2SinFoco()
      CASE _aControl[i,ABM_CON_TYPE] == ABM_EDITBOX
         _HMG_cMacroTemp := _aControl[i,ABM_CON_NAME]
         @ _aControl[i,ABM_CON_ROW], _aControl[i,ABM_CON_COL]    ;
            editbox &_HMG_cMacroTemp              ;
            of wndABM2EditNuevoSplit                        ;
            WIDTH _aControl[i,ABM_CON_WIDTH]                ;
            HEIGHT _aControl[i,ABM_CON_HEIGHT]              ;
            VALUE ""                                        ;
            font "arial" size 9                             ;
            ON GOTFOCUS ABM2ConFoco()                       ;
            ON LOSTFOCUS ABM2SinFoco()
      ENDCASE
   NEXT

   ////////// Actualiza los controles si se está editando.------------------------
   IF !lNuevo
      FOR i := 1 to HMG_LEN( _aControl )
         _HMG_cMacroTemp := _aControl[i,ABM_CON_NAME]
         wndABM2EditNuevoSplit.&(_HMG_cMacroTemp).Value := ;
            (_cArea)->( FieldGet( i ) )
      NEXT
   ENDIF

   ////////// Establece el estado inicial de los controles.-----------------------
   FOR i := 1 to HMG_LEN( _aControl )
      _HMG_cMacroTemp := _aControl[i,ABM_CON_NAME]
      wndABM2EditNuevoSplit.&(_HMG_cMacroTemp).Enabled := _aEditable[i]
   NEXT

   ////////// Establece el estado del botón de copia.-----------------------------
   IF !lNuevo
      wndABM2EditNuevo.tbbCopiar.Enabled := .f.
   ENDIF

   ////////// Activa la ventana de edición de registro.---------------------------
   ACTIVATE WINDOW wndABM2EditNuevo

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para HMG
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2ConFoco()
   * Descripción: Actualiza las etiquetas de los controles y presenta los mensajes en la
   *              barra de estado de la ventana de edición de registro al obtener un
   *              control de edición el foco.
   *  Parámetros: Ninguno
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABM2ConFoco()

   ////////// Declaración de variables locales.-----------------------------------
   LOCAL i         as numeric              // Indice de iteración.
   LOCAL cControl  as character            // Nombre del control activo.
   LOCAL acControl as array                // Matriz con los nombre de los controles.

   ////////// Inicialización de variables.----------------------------------------
   cControl := This.Name
   acControl := {}
   FOR i := 1 to HMG_LEN( _aControl )
      aAdd( acControl, _aControl[i,ABM_CON_NAME] )
   NEXT
   _nControlActivo := aScan( acControl, cControl )

   ////////// Pone la etiqueta en negrita.----------------------------------------
   _HMG_cMacroTemp := _aEtiqueta[_nControlActivo,ABM_LBL_NAME]
   wndABM2EditNuevoSplit.&(_HMG_cMacroTemp).FontBold := .t.

   ////////// Presenta el mensaje en la barra de estado.--------------------------
   wndABM2EditNuevo.StatusBar.Item( 1 ) := _aControl[_nControlActivo,ABM_CON_DES]

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para HMG
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2SinFoco()
   * Descripción: Restaura el estado de las etiquetas y de la barra de estado de la ventana
   *              de edición de registros al dejar un control de edición sin foco.
   *  Parámetros: Ninguno
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABM2SinFoco()

   ////////// Restaura el estado de la etiqueta.----------------------------------
   _HMG_cMacroTemp := _aEtiqueta[_nControlActivo,ABM_LBL_NAME]
   wndABM2EditNuevoSplit.&(_HMG_cMacroTemp).FontBold := .f.

   ////////// Restaura el texto de la barra de estado.----------------------------
   wndABM2EditNuevo.StatusBar.Item( 1 ) := ""

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para HMG
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2AlEntrar()
   * Descripción: Cambia al siguiente control de edición tipo TEXTBOX al pulsar la tecla
   *              ENTER.
   *  Parámetros: Ninguno
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABM2AlEntrar()

   ////////// Declaración de variables locales.-----------------------------------
   LOCAL lSalida   as logical              // * Tipo de salida.
   LOCAL nTipo     as numeric              // * Tipo del control.

   ////////// Inicializa las variables.-------------------------------------------
   lSalida  := .t.

   ////////// Restaura el estado de la etiqueta.----------------------------------
   _HMG_cMacroTemp := _aEtiqueta[_nControlActivo,ABM_LBL_NAME]
   wndABM2EditNuevoSplit.&(_HMG_cMacroTemp).FontBold := .f.

   ////////// Activa el siguiente control editable con evento ON ENTER.-----------
   DO WHILE lSalida
      _nControlActivo++
      IF _nControlActivo > HMG_LEN( _aControl )
         _nControlActivo := 1
      ENDIF
      nTipo := _aControl[_nControlActivo,ABM_CON_TYPE]
      IF nTipo == ABM_TEXTBOXC .or. nTipo == ABM_TEXTBOXN
         IF _aEditable[_nControlActivo]
            lSalida := .f.
         ENDIF
      ENDIF
   ENDDO
   _HMG_cMacroTemp := _aControl[_nControlActivo,ABM_CON_NAME]
   wndABM2EditNuevoSplit.&(_HMG_cMacroTemp).SetFocus

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para HMG
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2EditarGuardar( lNuevo )
   * Descripción: Añade o guarda el registro en la bdd.
   *  Parámetros: lNuevo          Valor lógico que indica si se está añadiendo un registro
   *                              o editando el actual.
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABM2EditarGuardar( lNuevo )

   ////////// Declaración de variables locales.-----------------------------------
   LOCAL i          as numeric             // * Indice de iteración.
   LOCAL xValor                            // * Valor a guardar.
   LOCAL lResultado as logical             // * Resultado del bloque del usuario.
   LOCAL aValores   as array               // * Valores del registro.

   ////////// Guarda el registro.-------------------------------------------------
   IF _bGuardar == NIL

      // No hay bloque de código del usuario.
      IF lNuevo
         (_cArea)->( dbAppend() )
      ENDIF

      IF (_cArea)->(rlock())

         FOR i := 1 to HMG_LEN( _aEstructura )
            _HMG_cMacroTemp := _aControl[i,ABM_CON_NAME]
            xValor := wndABM2EditNuevoSplit.&(_HMG_cMacroTemp).Value
            (_cArea)->( FieldPut( i, xValor ) )
         NEXT

         UNLOCK

         // Refresca la ventana de visualización.
         wndABM2EditNuevo.Release
         ABM2Redibuja( .t. )

      ELSE
         Msgstop ('Record locked by another user')
      ENDIF
   ELSE

      // Hay bloque de código del usuario.
      aValores := {}
      FOR i := 1 to HMG_LEN( _aControl )
         _HMG_cMacroTemp := _aControl[i,ABM_CON_NAME]
         xValor := wndABM2EditNuevoSplit.&(_HMG_cMacroTemp).Value
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
   *  Aplicación: Comando EDIT para HMG
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2Seleccionar()
   * Descripción: Presenta una ventana para la selección de un registro.
   *  Parámetros: Ninguno
   *    Devuelve: [nReg]          Numero de registro seleccionado, o cero si no se ha
   *                              seleccionado ninguno.
   ****************************************************************************************/

STATIC FUNCTION ABM2Seleccionar()

   ////////// Declaración de variables locales.-----------------------------------
   LOCAL lSalida   as logical              // Control de bucle.
   LOCAL nReg      as numeric              // Valores del registro
   LOCAL nRegistro as numeric              // Número de registro.

   ////////// Inicialización de variables.----------------------------------------
   lSalida   := .f.
   nReg      := 0
   nRegistro := (_cArea)->( RecNo() )

   ////////// Se situa en el primer registro.-------------------------------------
   (_cArea)->( dbGoTop() )

   ////////// Creación de la ventana de selección de registro.--------------------
   DEFINE WINDOW wndSeleccionar            ;
         AT 0, 0                         ;
         WIDTH 500                       ;
         HEIGHT 300                      ;
         TITLE _HMG_SYSDATA [ 129 ][8]            ;
         modal                           ;
         NOSIZE                          ;
         NOSYSMENU                       ;
         font "ms sans serif" size 9

      // Define la barra de botones de la ventana de selección.
      DEFINE TOOLBAR tbSeleccionar buttonsize 90, 32 flat righttext border
         button tbbCancelarSel caption _HMG_SYSDATA [ 128 ][7]                   ;
            PICTURE "HMG_EDIT_CANCEL"             ;
            ACTION  {|| lSalida := .f.,               ;
            nReg    := 0,                 ;
            wndSeleccionar.Release }
         button tbbAceptarSel  caption _HMG_SYSDATA [ 128 ][8]                                           ;
            PICTURE "HMG_EDIT_OK"                                         ;
            ACTION  {|| lSalida := .t.,                                       ;
            nReg    := wndSeleccionar.brwSeleccionar.Value,       ;
            wndSeleccionar.Release }
      END toolbar

      // Define la barra de estado de la ventana de selección.
      DEFINE STATUSBAR font "ms sans serif" size 9
         statusitem _HMG_SYSDATA [ 130 ][7]
      END STATUSBAR

      // Define la tabla de la ventana de selección.
      @ 55, 20 browse brwSeleccionar                                          ;
         WIDTH 460                                                       ;
         HEIGHT 190                                                      ;
         HEADERS _aCabeceraTabla                                         ;
         WIDTHS _aAnchoTabla                                             ;
         WORKAREA &_cArea                                                ;
         FIELDS _aCampoTabla                                             ;
         VALUE (_cArea)->( RecNo() )                                     ;
         font "arial" size 9                                             ;
         ON DBLCLICK {|| lSalida := .t.,                                 ;
         nReg := wndSeleccionar.brwSeleccionar.Value,    ;
         wndSeleccionar.Release }                        ;
         JUSTIFY _aAlineadoTabla

   END WINDOW

   ////////// Activa la ventana de selección de registro.-------------------------
   CENTER WINDOW wndSeleccionar
   ACTIVATE WINDOW wndSeleccionar

   ////////// Restuara el puntero de registro.------------------------------------
   (_cArea)->( dbGoTo( nRegistro ) )

   RETURN ( nReg )

   /****************************************************************************************
   *  Aplicación: Comando EDIT para HMG
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2EditarCopiar()
   * Descripción: Copia el registro seleccionado en los controles de edición del nuevo
   *              registro.
   *  Parámetros: Ninguno
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABM2EditarCopiar()

   ////////// Declaración de variables locales.-----------------------------------
   LOCAL i         as numeric              // Indice de iteración.
   LOCAL nRegistro as numeric              // Puntero de registro.
   LOCAL nReg      as numeric              // Numero de registro.

   ////////// Obtiene el registro a copiar.---------------------------------------
   nReg := ABM2Seleccionar()

   ////////// Actualiza los controles de edición.---------------------------------
   IF nReg != 0
      nRegistro := (_cArea)->( RecNo() )
      (_cArea)->( dbGoTo( nReg ) )
      FOR i := 1 to HMG_LEN( _aControl )
         IF _aEditable[i]
            _HMG_cMacroTemp := _aControl[i,ABM_CON_NAME]
            wndABM2EditNuevoSplit.&(_HMG_cMacroTemp).Value := ;
               (_cArea)->( FieldGet( i ) )
         ENDIF
      NEXT
      (_cArea)->( dbGoTo( nRegistro ) )
   ENDIF

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para HMG
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2Borrar()
   * Descripción: Borra el registro activo.
   *  Parámetros: Ninguno
   *    Devuelve: NIL
   ****************************************************************************************/

FUNCTION ABM2Borrar()

   ////////// Declaración de variables locales.-----------------------------------

   ////////// Borra el registro si se acepta.-------------------------------------

   IF MsgOKCancel( _HMG_SYSDATA [ 130 ][8], _HMG_SYSDATA [ 129 ][16] )
      IF (_cArea)->( rlock() )
         (_cArea)->( dbDelete() )
         (_cArea)->( dbCommit() )
         (_cArea)->( dbunlock() )
         IF .not. set( _SET_DELETED )
            SET DELETED ON
         ENDIF
         (_cArea)->( dbSkip() )
         IF (_cArea)->( eof() )
            (_cArea)->( dbGoBottom() )
         ENDIF
         ABM2Redibuja( .t. )
      ELSE
         Msgstop( _HMG_SYSDATA [ 130 ] [41] , _cTitulo )
      ENDIF
   ENDIF

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para HMG
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2Buscar()
   * Descripción: Busca un registro por la clave del indice activo.
   *  Parámetros: Ninguno
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABM2Buscar()

   ////////// Declaración de variables locales.-----------------------------------
   LOCAL nControl   as numeric             // Numero del control.
   LOCAL lSalida    as logical             // Tipo de salida de la ventana.
   LOCAL xValor                            // Valor de busqueda.
   LOCAL cMascara   as character           // Mascara de edición del control.
   LOCAL lResultado as logical             // Resultado de la busqueda.
   LOCAL nRegistro  as numeric             // Numero de registro.

   ////////// Inicialización de variables.----------------------------------------
   nControl := _aIndiceCampo[_nIndiceActivo]

   ////////// Comprueba si se ha pasado una acción del usuario.--------------------
   IF _bBuscar != NIL
      // msgInfo( "ON FIND" )
      Eval( _bBuscar )
      ABM2Redibuja( .t. )

      RETURN NIL
   ENDIF

   ////////// Comprueba si hay un indice activo.----------------------------------
   IF _nIndiceActivo == 1
      msgExclamation( _HMG_SYSDATA [ 130 ][9], _cTitulo )

      RETURN NIL
   ENDIF

   ////////// Comprueba que el campo indice no es del tipo memo o logico.---------
   IF _aEstructura[nControl,DBS_TYPE] == "L" .or. _aEstructura[nControl,DBS_TYPE] == "M"
      msgExclamation( _HMG_SYSDATA [ 130 ][10], _cTitulo )

      RETURN NIL
   ENDIF

   ////////// Crea la ventana de busqueda.----------------------------------------
   DEFINE WINDOW wndABMBuscar              ;
         AT 0, 0                         ;
         WIDTH 500                       ;
         HEIGHT 170                      ;
         TITLE _HMG_SYSDATA [ 129 ][9]            ;
         modal                           ;
         NOSIZE                          ;
         NOSYSMENU                       ;
         font "ms sans serif" size 9

      // Define la barra de botones de la ventana de busqueda.
      DEFINE TOOLBAR tbBuscar buttonsize 90, 32 flat righttext border
         button tbbCancelarBus caption _HMG_SYSDATA [ 128 ][7]                           ;
            PICTURE "HMG_EDIT_CANCEL"                     ;
            ACTION  {|| lSalida := .f.,                       ;
            xValor := wndABMBuscar.conBuscar.Value,  ;
            wndABMBuscar.Release }
         button tbbAceptarBus  caption _HMG_SYSDATA [ 128 ][8]                                ;
            PICTURE "HMG_EDIT_OK"                         ;
            ACTION  {|| lSalida := .t.,                       ;
            xValor := wndABMBuscar.conBuscar.Value,  ;
            wndABMBuscar.Release }
      END toolbar

      // Define la barra de estado de la ventana de busqueda.
      DEFINE STATUSBAR font "ms sans serif" size 9
         statusitem ""
      END STATUSBAR
   END WINDOW

   ////////// Crea los controles de la ventana de busqueda.-----------------------
   // Frame.
   @ 45, 10 frame frmBuscar                        ;
      of wndABMBuscar                         ;
      CAPTION ""                              ;
      WIDTH wndABMBuscar.Width - 25           ;
      HEIGHT wndABMBuscar.Height - 100

   // Etiqueta.
   @ 60, 20 label lblBuscar                                ;
      of wndABMBuscar                                 ;
      VALUE _aNombreCampo[nControl]                   ;
      WIDTH _aEtiqueta[nControl,ABM_LBL_WIDTH]        ;
      HEIGHT _aEtiqueta[nControl,ABM_LBL_HEIGHT]      ;
      font "ms sans serif" size 9

   // Tipo de dato a buscar.
   DO CASE

      // Carácter.
   CASE _aControl[nControl,ABM_CON_TYPE] == ABM_TEXTBOXC
      @ 75, 20  textbox conBuscar                             ;
         of wndABMBuscar                                    ;
         VALUE ""                                        ;
         HEIGHT _aControl[nControl,ABM_CON_HEIGHT]       ;
         WIDTH _aControl[nControl,ABM_CON_WIDTH]         ;
         font "arial" size 9                             ;
         MAXLENGTH _aEstructura[nControl,DBS_LEN]

      // Fecha.
   CASE _aControl[nControl,ABM_CON_TYPE] == ABM_DATEPICKER
      @ 75, 20 datepicker conBuscar                           ;
         of wndABMBuscar                                    ;
         VALUE Date()                                    ;
         HEIGHT _aControl[nControl,ABM_CON_HEIGHT]       ;
         WIDTH _aControl[nControl,ABM_CON_WIDTH] + 25    ;
         font "arial" size 9

      // Numerico.
   CASE _aControl[nControl,ABM_CON_TYPE] == ABM_TEXTBOXN
      IF ( _aEstructura[nControl,DBS_DEC] == 0 )

         // Sin decimales.
         @ 75, 20 textbox conBuscar                              ;
            of wndABMBuscar                                    ;
            VALUE ""                                        ;
            HEIGHT _aControl[nControl,ABM_CON_HEIGHT]       ;
            WIDTH _aControl[nControl,ABM_CON_WIDTH]         ;
            NUMERIC                                         ;
            font "arial" size 9                             ;
            MAXLENGTH _aEstructura[nControl,DBS_LEN]
      ELSE

         // Con decimales.
         cMascara := ""
         cMascara := REPLICATE( "9", _aEstructura[nControl,DBS_LEN] - ;
            ( _aEstructura[nControl,DBS_DEC] + 1 ) )
         cMascara += "."
         cMascara += REPLICATE( "9", _aEstructura[nControl,DBS_DEC] )
         @ 75, 20 textbox conBuscar                              ;
            of wndABMBuscar                                    ;
            VALUE ""                                        ;
            HEIGHT _aControl[nControl,ABM_CON_HEIGHT]       ;
            WIDTH _aControl[nControl,ABM_CON_WIDTH]         ;
            NUMERIC                                         ;
            INPUTMASK cMascara
      ENDIF
   ENDCASE

   ////////// Actualiza la barra de estado.---------------------------------------
   wndABMBuscar.StatusBar.Item( 1 ) := _aControl[nControl,ABM_CON_DES]

   ////////// Comprueba el tamaño del control de edición del dato a buscar.-------
   IF wndABMBuscar.conBuscar.Width > wndABM2Edit.Width - 45
      wndABMBuscar.conBuscar.Width := wndABM2Edit.Width - 45
   ENDIF

   ////////// Activa la ventana de busqueda.--------------------------------------
   CENTER WINDOW wndABMBuscar
   ACTIVATE WINDOW wndABMBuscar

   ////////// Busca el registro.--------------------------------------------------
   IF lSalida
      nRegistro := (_cArea)->( RecNo() )
      lResultado := (_cArea)->( dbSeek( xValor ) )
      IF !lResultado
         msgExclamation( _HMG_SYSDATA [ 130 ][11], _cTitulo )
         (_cArea)->( dbGoTo( nRegistro ) )
      ELSE
         ABM2Redibuja( .t. )
      ENDIF
   ENDIF

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para HMG
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2Filtro()
   * Descripción: Filtra la base de datos.
   *  Parámetros: Ninguno
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABM2ActivarFiltro()

   ////////// Declaración de variables locales.-----------------------------------
   LOCAL aCompara   as array               // Comparaciones.
   LOCAL aCampos    as array               // Nombre de los campos.

   ////////// Comprueba que no hay ningun filtro activo.--------------------------
   IF _cFiltro != ""
      MsgInfo( _HMG_SYSDATA [ 130 ][34], '' )
   ENDIF

   ////////// Inicialización de variables.----------------------------------------
   aCampos    := _aNombreCampo
   aCompara   := { _HMG_SYSDATA [ 129 ][27],;
      _HMG_SYSDATA [ 129 ][28],;
      _HMG_SYSDATA [ 129 ][29],;
      _HMG_SYSDATA [ 129 ][30],;
      _HMG_SYSDATA [ 129 ][31],;
      _HMG_SYSDATA [ 129 ][32] }

   ////////// Crea la ventana de filtrado.----------------------------------------
   DEFINE WINDOW wndABM2Filtro                     ;
         AT 0, 0                                 ;
         WIDTH 400                               ;
         HEIGHT 325                              ;
         TITLE _HMG_SYSDATA [ 129 ][21]            ;
         modal                                   ;
         NOSIZE                                  ;
         NOSYSMENU                               ;
         ON INIT {|| ABM2ControlFiltro() }       ;
         font "ms sans serif" size 9

      // Define la barra de botones de la ventana de filtrado.
      DEFINE TOOLBAR tbBuscar buttonsize 90, 32 flat righttext border
         button tbbCancelarFil caption _HMG_SYSDATA [ 128 ][7]           ;
            PICTURE "HMG_EDIT_CANCEL"     ;
            ACTION  {|| wndABM2Filtro.Release,;
            ABM2Redibuja( .f. ) }
         button tbbAceptarFil  caption _HMG_SYSDATA [ 128 ][8]           ;
            PICTURE "HMG_EDIT_OK"         ;
            ACTION  {|| ABM2EstableceFiltro() }
      END toolbar

      // Define la barra de estado de la ventana de filtrado.
      DEFINE STATUSBAR font "ms sans serif" size 9
         statusitem ""
      END STATUSBAR
   END WINDOW

   ////////// Controles de la ventana de filtrado.
   // Frame.
   @ 45, 10 frame frmFiltro                        ;
      of wndABM2Filtro                        ;
      CAPTION ""                              ;
      WIDTH wndABM2Filtro.Width - 25          ;
      HEIGHT wndABM2Filtro.Height - 100
   @ 65, 20 label lblCampos                ;
      of wndABM2Filtro                ;
      VALUE _HMG_SYSDATA [ 129 ][22]        ;
      WIDTH 140                       ;
      HEIGHT 25                       ;
      font "ms sans serif" size 9
   @ 65, 220 label lblCompara              ;
      of wndABM2Filtro                ;
      VALUE _HMG_SYSDATA [ 129 ][23]    ;
      WIDTH 140                       ;
      HEIGHT 25                       ;
      font "ms sans serif" size 9
   @ 200, 20 label lblValor                ;
      of wndABM2Filtro                ;
      VALUE _HMG_SYSDATA [ 129 ][24]        ;
      WIDTH 140                       ;
      HEIGHT 25                       ;
      font "ms sans serif" size 9
   @ 85, 20 listbox lbxCampos                      ;
      of wndABM2Filtro                        ;
      WIDTH 140                               ;
      HEIGHT 100                              ;
      ITEMS aCampos                           ;
      VALUE 1                                 ;
      font "Arial" size 9                     ;
      ON CHANGE {|| ABM2ControlFiltro() }     ;
      ON GOTFOCUS wndABM2Filtro.StatusBar.Item(1) := _HMG_SYSDATA [ 129 ][25] ;
      ON LOSTFOCUS wndABM2Filtro.StatusBar.Item(1) := ""
   @ 85, 220 listbox lbxCompara                    ;
      of wndABM2Filtro                        ;
      WIDTH 140                               ;
      HEIGHT 100                              ;
      ITEMS aCompara                          ;
      VALUE 1                                 ;
      font "Arial" size 9                     ;
      ON GOTFOCUS wndABM2Filtro.StatusBar.Item(1) := _HMG_SYSDATA [ 129 ][26] ;
      ON LOSTFOCUS wndABM2Filtro.StatusBar.Item(1) := ""
   @ 220, 20 textbox conValor              ;
      of wndABM2Filtro                ;
      VALUE ""                        ;
      HEIGHT 25                       ;
      WIDTH 160                       ;
      font "arial" size 9             ;
      MAXLENGTH 16

   ////////// Activa la ventana.
   CENTER WINDOW wndABM2Filtro
   ACTIVATE WINDOW wndABM2Filtro

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para HMG
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2ControlFiltro()
   * Descripción: Comprueba que el filtro se puede aplicar.
   *  Parámetros: Ninguno
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABM2ControlFiltro()

   ////////// Declaración de variables locales.-----------------------------------
   LOCAL nControl as numeric
   LOCAL cMascara as character
   LOCAL cMensaje as character

   ////////// Inicializa las variables.
   nControl := wndABM2Filtro.lbxCampos.Value

   ///////// Comprueba que se puede crear el control.-----------------------------
   IF _aEstructura[nControl,DBS_TYPE] == "M"
      msgExclamation( _HMG_SYSDATA [ 130 ][35], _cTitulo )

      RETURN NIL
   ENDIF
   IF nControl == 0
      msgExclamation( _HMG_SYSDATA [ 130 ][36], _cTitulo )

      RETURN NIL
   ENDIF

   ///////// Crea el nuevo control.-----------------------------------------------
   wndABM2Filtro.conValor.Release
   cMensaje := _aControl[nControl,ABM_CON_DES]
   DO CASE

      // Carácter.
   CASE _aControl[nControl,ABM_CON_TYPE] == ABM_TEXTBOXC
      @ 226, 20  textbox conValor                                     ;
         of wndABM2Filtro                                        ;
         VALUE ""                                                ;
         HEIGHT _aControl[nControl,ABM_CON_HEIGHT]               ;
         WIDTH _aControl[nControl,ABM_CON_WIDTH]                 ;
         font "arial" size 9                                     ;
         MAXLENGTH _aEstructura[nControl,DBS_LEN]                ;
         ON GOTFOCUS wndABM2Filtro.StatusBar.Item( 1 ) :=        ;
         cMensaje                                    ;
         ON LOSTFOCUS wndABM2Filtro.StatusBar.Item( 1 ) := ""

      // Fecha.
   CASE _aControl[nControl,ABM_CON_TYPE] == ABM_DATEPICKER
      @ 226, 20 datepicker conValor                                   ;
         of wndABM2Filtro                                        ;
         VALUE Date()                                            ;
         HEIGHT _aControl[nControl,ABM_CON_HEIGHT]               ;
         WIDTH _aControl[nControl,ABM_CON_WIDTH] + 25            ;
         font "arial" size 9                                     ;
         ON GOTFOCUS wndABM2Filtro.StatusBar.Item( 1 ) :=        ;
         cMensaje                                    ;
         ON LOSTFOCUS wndABM2Filtro.StatusBar.Item( 1 ) := ""

      // Numerico.
   CASE _aControl[nControl,ABM_CON_TYPE] == ABM_TEXTBOXN
      IF ( _aEstructura[nControl,DBS_DEC] == 0 )

         // Sin decimales.
         @ 226, 20 textbox conValor                                      ;
            of wndABM2Filtro                                        ;
            VALUE ""                                                ;
            HEIGHT _aControl[nControl,ABM_CON_HEIGHT]               ;
            WIDTH _aControl[nControl,ABM_CON_WIDTH]                 ;
            NUMERIC                                                 ;
            font "arial" size 9                                     ;
            MAXLENGTH _aEstructura[nControl,DBS_LEN]                ;
            ON GOTFOCUS wndABM2Filtro.StatusBar.Item( 1 ) :=        ;
            cMensaje                                    ;
            ON LOSTFOCUS wndABM2Filtro.StatusBar.Item( 1 ) := ""

      ELSE

         // Con decimales.
         cMascara := ""
         cMascara := REPLICATE( "9", _aEstructura[nControl,DBS_LEN] - ;
            ( _aEstructura[nControl,DBS_DEC] + 1 ) )
         cMascara += "."
         cMascara += REPLICATE( "9", _aEstructura[nControl,DBS_DEC] )
         @ 226, 20 textbox conValor                                      ;
            of wndABM2Filtro                                        ;
            VALUE ""                                                ;
            HEIGHT _aControl[nControl,ABM_CON_HEIGHT]               ;
            WIDTH _aControl[nControl,ABM_CON_WIDTH]                 ;
            NUMERIC                                                 ;
            INPUTMASK cMascara                                      ;
            ON GOTFOCUS wndABM2Filtro.StatusBar.Item( 1 ) :=        ;
            cMensaje                                    ;
            ON LOSTFOCUS wndABM2Filtro.StatusBar.Item( 1 ) := ""
      ENDIF

      // Logico
   CASE _aControl[nControl,ABM_CON_TYPE] == ABM_CHECKBOX
      @ 226, 20 checkbox conValor                                     ;
         of wndABM2Filtro                                        ;
         CAPTION ""                                              ;
         HEIGHT _aControl[nControl,ABM_CON_HEIGHT]               ;
         WIDTH _aControl[nControl,ABM_CON_WIDTH]                 ;
         VALUE .f.                                               ;
         ON GOTFOCUS wndABM2Filtro.StatusBar.Item( 1 ) :=        ;
         cMensaje                                    ;
         ON LOSTFOCUS wndABM2Filtro.StatusBar.Item( 1 ) := ""

   ENDCASE

   ////////// Actualiza el valor de la etiqueta.----------------------------------
   wndABM2Filtro.lblValor.Value := _aNombreCampo[nControl]

   ////////// Actualiza la barra de estado.---------------------------------------
   //wndABM2Filtro.StatusBar.Item( 1 ) := _aControl[nControl,ABM_CON_DES]

   ////////// Comprueba el tamaño del control de edición del dato a buscar.-------
   IF wndABM2Filtro.conValor.Width > wndABM2Filtro.Width - 45
      wndABM2Filtro.conValor.Width := wndABM2Filtro.Width - 45
   ENDIF

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para HMG
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2EstableceFiltro()
   * Descripción: Establece el filtro seleccionado.
   *  Parámetros: Ninguno.
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABM2EstableceFiltro()

   ////////// Declaración de variables locales.-----------------------------------
   LOCAL aOperador  as array
   LOCAL nCampo     as numeric
   LOCAL nCompara   as numeric
   LOCAL cValor     as character

   ////////// Inicialización de variables.----------------------------------------
   nCompara  := wndABM2Filtro.lbxCompara.Value
   nCampo    := wndABM2Filtro.lbxCampos.Value
   cValor    := HB_ValToStr( wndABM2Filtro.conValor.Value )
   aOperador := { "=", "<>", ">", "<", ">=", "<=" }

   ////////// Comprueba que se puede filtrar.-------------------------------------
   IF nCompara == 0
      msgExclamation( _HMG_SYSDATA [ 130 ][37], _cTitulo )

      RETURN NIL
   ENDIF
   IF nCampo == 0
      msgExclamation( _HMG_SYSDATA [ 130 ][36], _cTitulo )

      RETURN NIL
   ENDIF
   IF cValor == ""
      msgExclamation( _HMG_SYSDATA [ 130 ][38], _cTitulo )

      RETURN NIL
   ENDIF
   IF _aEstructura[nCampo,DBS_TYPE] == "M"
      msgExclamation( _HMG_SYSDATA [ 130 ][35], _cTitulo )

      RETURN NIL
   ENDIF

   ////////// Establece el filtro.------------------------------------------------
   DO CASE
   CASE _aEstructura[nCampo,DBS_TYPE] == "C"
      _cFiltro := "HMG_UPPER(" + _cArea + "->" + ;
         _aEstructura[nCampo,DBS_NAME] + ")"+ ;
         aOperador[nCompara]
      _cFiltro += "'" + HMG_UPPER( ALLTRIM( cValor ) ) + "'"

   CASE _aEstructura[nCampo,DBS_TYPE] == "N"
      _cFiltro := _cArea + "->" + ;
         _aEstructura[nCampo,DBS_NAME] + ;
         aOperador[nCompara]
      _cFiltro += ALLTRIM( cValor )

   CASE _aEstructura[nCampo,DBS_TYPE] == "D"
      _cFiltro := _cArea + "->" + ;
         _aEstructura[nCampo,DBS_NAME] + ;
         aOperador[nCompara]
      _cFiltro += "CToD(" + "'" + cValor + "')"

   CASE _aEstructura[nCampo,DBS_TYPE] == "L"
      _cFiltro := _cArea + "->" + ;
         _aEstructura[nCampo,DBS_NAME] + ;
         aOperador[nCompara]
      _cFiltro += cValor
   ENDCASE
   (_cArea)->( dbSetFilter( {|| &_cFiltro}, _cFiltro ) )
   _lFiltro := .t.
   wndABM2Filtro.Release
   ABM2Redibuja( .t. )

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para HMG
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función:
   * Descripción:
   *  Parámetros:
   *    Devuelve:
   ****************************************************************************************/

STATIC FUNCTION ABM2DesactivarFiltro()

   ////////// Desactiva el filtro si procede.
   IF !_lFiltro
      msgExclamation( _HMG_SYSDATA [ 130 ][39], _cTitulo )
      ABM2Redibuja( .f. )

      RETURN NIL
   ENDIF
   IF msgYesNo( _HMG_SYSDATA [ 130 ][40], _cTitulo )
      (_cArea)->( dbSetFilter( {|| NIL }, "" ) )
      _lFiltro := .f.
      _cFiltro := ""
      ABM2Redibuja( .t. )
   ENDIF

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para HMG
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2Imprimir()
   * Descripción: Presenta la ventana de recogida de datos para la definición del listado.
   *  Parámetros: Ninguno
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABM2Imprimir()

   ////////// Declaración de variables locales.-----------------------------------
   LOCAL aCampoBase    as array            // Campos de la bdd.
   LOCAL aCampoListado as array            // Campos del listado.
   LOCAL nRegistro     as numeric          // Numero de registro actual.
   LOCAL nCampo        as numeric          // Numero de campo.
   LOCAL cRegistro1    as character        // Valor del registro inicial.
   LOCAL cRegistro2    as character        // Valor del registro final.
   LOCAL aImpresoras   as array            // Impresoras disponibles.
   LOCAL NIMPLEN
   PRIVATE hbprn

   ////////// Comprueba si se ha pasado la clausula ON PRINT.---------------------
   IF _bImprimir != NIL
      // msgInfo( "ON PRINT" )
      Eval( _bImprimir )
      ABM2Redibuja( .T. )

      RETURN NIL
   ENDIF

   ////////// Obtiene las impresoras disponibles.---------------------------------
   aImpresoras := {}
   aImpresoras := aPrinters()
   IF ValType( nImpLen ) # 'N'
      nImpLen := HMG_LEN( aImpresoras )
   ENDIF
   aSize( aImpresoras, nImpLen )

   ////////// Comprueba que hay un indice activo.---------------------------------
   IF _nIndiceActivo == 1
      msgExclamation( _HMG_SYSDATA [ 130 ][9], _cTitulo )

      RETURN NIL
   ENDIF

   ////////// Inicialización de variables.----------------------------------------
   aCampoListado := {}
   aCampoBase    := _aNombreCampo
   nRegistro     := (_cArea)->( RecNo() )

   // Registro inicial y final.
   nCampo := _aIndiceCampo[_nIndiceActivo]
   ( _cArea)->( dbGoTop() )
   cRegistro1 := HB_ValToStr( (_cArea)->( FieldGet( nCampo ) ) )
   ( _cArea)->( dbGoBottom() )
   cRegistro2 := HB_ValToStr( (_cArea)->( FieldGet( nCampo ) ) )
   (_cArea)->( dbGoTo( nRegistro ) )

   ////////// Definición de la ventana de formato de listado.---------------------
   DEFINE WINDOW wndABM2Listado            ;
         AT 0, 0                         ;
         WIDTH 390                       ;
         HEIGHT 365                      ;
         TITLE _HMG_SYSDATA [ 129 ][10]   ;
         ICON "HMG_EDIT_PRINT"       ;
         modal                           ;
         NOSIZE                          ;
         NOSYSMENU                       ;
         font "ms sans serif" size 9

      // Define la barra de botones de la ventana de formato de listado.
      DEFINE TOOLBAR tbListado buttonsize 90, 32 flat righttext border
         button tbbCancelarLis caption _HMG_SYSDATA [ 128 ][7]                   ;
            PICTURE "HMG_EDIT_CANCEL"             ;
            ACTION  wndABM2Listado.Release
         button tbbAceptarLis  caption _HMG_SYSDATA [ 128 ][8]                   ;
            PICTURE "HMG_EDIT_OK"                 ;
            ACTION  ABM2Listado( aImpresoras )

      END toolbar

      // Define la barra de estado de la ventana de formato de listado.
      DEFINE STATUSBAR font "ms sans serif" size 9
         statusitem ""
      END STATUSBAR
   END WINDOW

   ////////// Define los controles de edición de la ventana de formato de listado.-
   // Frame.
   @ 45, 10 frame frmListado                       ;
      of wndABM2Listado                       ;
      CAPTION ""                              ;
      WIDTH wndABM2Listado.Width - 25         ;
      HEIGHT wndABM2Listado.Height - 100

   // Label
   @ 65, 20 label lblCampoBase             ;
      of wndABM2Listado               ;
      VALUE _HMG_SYSDATA [ 129 ][11]       ;
      WIDTH 140                       ;
      HEIGHT 25                       ;
      font "ms sans serif" size 9
   @ 65, 220 label lblCampoListado         ;
      of wndABM2Listado               ;
      VALUE _HMG_SYSDATA [ 129 ][12]           ;
      WIDTH 140                       ;
      HEIGHT 25                       ;
      font "ms sans serif" size 9
   @ 200, 20 label lblImpresoras           ;
      of wndABM2Listado               ;
      VALUE _HMG_SYSDATA [ 129 ][13]   ;
      WIDTH 140                       ;
      HEIGHT 25                       ;
      font "ms sans serif" size 9
   @ 200, 170 label lblInicial             ;
      of wndABM2Listado               ;
      VALUE _HMG_SYSDATA [ 129 ][14]           ;
      WIDTH 160                       ;
      HEIGHT 25                       ;
      font "ms sans serif" size 9
   @ 255, 170 label lblFinal               ;
      of wndABM2Listado               ;
      VALUE _HMG_SYSDATA [ 129 ][15]           ;
      WIDTH 160                       ;
      HEIGHT 25                       ;
      font "ms sans serif" size 9

   // Listbox.
   @ 85, 20 listbox lbxCampoBase                                           ;
      of wndABM2Listado                                               ;
      WIDTH 140                                                       ;
      HEIGHT 100                                                      ;
      ITEMS aCampoBase                                                ;
      VALUE 1                                                         ;
      font "Arial" size 9                                             ;
      ON GOTFOCUS wndABM2Listado.StatusBar.Item( 1 ) := _HMG_SYSDATA [ 130 ][12] ;
      ON LOSTFOCUS wndABM2Listado.StatusBar.Item( 1 ) := ""
   @ 85, 220 listbox lbxCampoListado                                       ;
      of wndABM2Listado                                               ;
      WIDTH 140                                                       ;
      HEIGHT 100                                                      ;
      ITEMS aCampoListado                                             ;
      VALUE 1                                                         ;
      font "Arial" size 9                                             ;
      ON GOTFOCUS wndABM2Listado.StatusBar.Item( 1 ) := _HMG_SYSDATA [ 130 ][13];
      ON LOSTFOCUS wndABM2Listado.StatusBar.Item( 1 ) := ""

   // ComboBox.
   @ 220, 20 combobox cbxImpresoras                                        ;
      of wndABM2Listado                                               ;
      ITEMS aImpresoras                                               ;
      VALUE 1                                                         ;
      WIDTH 140                                                       ;
      font "Arial" size 9                                             ;
      ON GOTFOCUS wndABM2Listado.StatusBar.Item( 1 ) := _HMG_SYSDATA [ 130 ][14] ;
      ON LOSTFOCUS wndABM2Listado.StatusBar.Item( 1 ) := ""

   // PicButton.
   @ 90, 170 button btnMas                                                 ;
      of wndABM2Listado                                               ;
      PICTURE "HMG_EDIT_ADD"                                      ;
      ACTION ABM2DefinirColumnas( ABM_LIS_ADD )                       ;
      WIDTH 40                                                        ;
      HEIGHT 40                                                       ;
      ON GOTFOCUS wndABM2Listado.StatusBar.Item( 1 ) := _HMG_SYSDATA [ 130 ][15] ;
      ON LOSTFOCUS wndABM2Listado.StatusBar.Item( 1 ) := ""
   @ 140, 170 button btnMenos                                              ;
      of wndABM2Listado                                               ;
      PICTURE "HMG_EDIT_DEL"                                      ;
      ACTION ABM2DefinirColumnas( ABM_LIS_DEL )                       ;
      WIDTH 40                                                        ;
      HEIGHT 40                                                       ;
      ON GOTFOCUS wndABM2Listado.StatusBar.Item( 1 ) := _HMG_SYSDATA [ 130 ][16] ;
      ON LOSTFOCUS wndABM2Listado.StatusBar.Item( 1 ) := ""
   @ 220, 170 button btnSet1                                               ;
      of wndABM2Listado                                               ;
      PICTURE "HMG_EDIT_SET"                                      ;
      ACTION ABM2DefinirRegistro( ABM_LIS_SET1 )                      ;
      WIDTH 25                                                        ;
      HEIGHT 25                                                       ;
      ON GOTFOCUS wndABM2Listado.StatusBar.Item( 1 ) := _HMG_SYSDATA [ 130 ][17] ;
      ON LOSTFOCUS wndABM2Listado.StatusBar.Item( 1 ) := ""
   @ 275, 170 button btnSet2                                               ;
      of wndABM2Listado                                               ;
      PICTURE "HMG_EDIT_SET"                                      ;
      ACTION ABM2DefinirRegistro( ABM_LIS_SET2 )                      ;
      WIDTH 25                                                        ;
      HEIGHT 25                                                       ;
      ON GOTFOCUS wndABM2Listado.StatusBar.Item( 1 ) := _HMG_SYSDATA [ 130 ][18] ;
      ON LOSTFOCUS wndABM2Listado.StatusBar.Item( 1 ) := ""

   // CheckBox.

   @ 275, 20 checkbox chkPrevio            ;
      of wndABM2Listado               ;
      CAPTION _HMG_SYSDATA [ 129 ][17]      ;
      WIDTH 140                       ;
      HEIGHT 25                       ;
      VALUE .t.                       ;
      font "ms sans serif" size 9

   // Editbox.
   @ 220, 196 textbox txtRegistro1         ;
      of wndABM2Listado               ;
      VALUE cRegistro1                ;
      HEIGHT 25                       ;
      WIDTH 160                       ;
      font "arial" size 9             ;
      MAXLENGTH 16
   @ 275, 196 textbox txtRegistro2         ;
      of wndABM2Listado               ;
      VALUE cRegistro2                ;
      HEIGHT 25                       ;
      WIDTH 160                       ;
      font "arial" size 9             ;
      MAXLENGTH 16

   ////////// Estado de los controles.--------------------------------------------
   wndABM2Listado.txtRegistro1.Enabled := .f.
   wndABM2Listado.txtRegistro2.Enabled := .f.

   ////////// Comrprueba que la selección de registros es posible.----------------
   nCampo := _aIndiceCampo[_nIndiceActivo]
   IF _aEstructura[nCampo,DBS_TYPE] == "L" .or. _aEstructura[nCampo,DBS_TYPE] == "M"
      wndABM2Listado.btnSet1.Enabled := .f.
      wndABM2Listado.btnSet2.Enabled := .f.
   ENDIF

   ////////// Activación de la ventana de formato de listado.---------------------
   CENTER WINDOW wndABM2Listado
   ACTIVATE WINDOW wndABM2Listado

   ////////// Restaura.-----------------------------------------------------------
   (_cArea)->( dbGoTo( nRegistro ) )
   ABM2Redibuja( .f. )

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para HMG
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2DefinirRegistro( nAccion )
   * Descripción:
   *  Parámetros:
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABM2DefinirRegistro( nAccion )

   ////////// Declaración de variables locales.-----------------------------------
   LOCAL nRegistro as character            // * Puntero de registros.
   LOCAL nReg      as character            // * Registro seleccionado.
   LOCAL cValor    as character            // * Valor del registro seleccionado.
   LOCAL nCampo    as numeric              // * Numero del campo indice.

   ////////// Inicializa las variables.-------------------------------------------
   nRegistro := (_cArea)->( RecNo() )
   cValor    := ""

   ////////// Selecciona el registro.---------------------------------------------
   nReg := ABM2Seleccionar()
   IF nReg == 0
      (_cArea)->( dbGoTo( nRegistro ) )

      RETURN NIL
   ELSE
      (_cArea)->( dbGoTo( nReg ) )
      nCampo := _aIndiceCampo[_nIndiceActivo]
      cValor := HB_ValToStr( (_cArea)->( FieldGet( nCampo ) ) )
   ENDIF

   ////////// Actualiza según la acción.------------------------------------------
   DO CASE
   CASE nAccion == ABM_LIS_SET1
      wndABM2Listado.txtRegistro1.Value := cValor
   CASE nAccion == ABM_LIS_SET2
      wndABM2Listado.txtRegistro2.Value := cValor
   ENDCASE

   ////////// Restaura el registro.
   (_cArea)->( dbGoTo( nRegistro ) )

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para HMG
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2DefinirColumnas( nAccion )
   * Descripción: Controla el contenido de las listas al pulsar los botones de añadir y
   *              eliminar campos del listado.
   *  Parámetros: [nAccion]       Numerico. Indica el tipo de accion realizado.
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABM2DefinirColumnas( nAccion )

   ////////// Declaración de variables locales.-----------------------------------
   LOCAL aCampoBase    as array            // * Campos de la bbd.
   LOCAL aCampoListado as array            // * Campos del listado.
   LOCAL i             as numeric          // * Indice de iteración.
   LOCAL nItem         as numeric          // * Numero del item seleccionado.
   LOCAL cvalor

   ////////// Inicialización de variables.----------------------------------------
   aCampoBase  := {}
   aCampoListado := {}
   FOR i := 1 to wndABM2Listado.lbxCampoBase.ItemCount
      aAdd( aCampoBase, wndABM2Listado.lbxCampoBase.Item( i ) )
   NEXT
   FOR i := 1 to wndABM2Listado.lbxCampoListado.ItemCount
      aAdd( aCampoListado, wndABM2Listado.lbxCampoListado.Item( i ) )
   NEXT

   ////////// Ejecuta según la acción.--------------------------------------------
   DO CASE
   CASE nAccion == ABM_LIS_ADD

      // Obtiene la columna a añadir.
      nItem := wndABM2Listado.lbxCampoBase.Value
      cValor := wndABM2Listado.lbxCampoBase.Item( nItem )

      // Actualiza los datos de los campos de la base.
      IF HMG_LEN( aCampoBase ) == 0
         msgExclamation( _HMG_SYSDATA [ 130 ][23], _cTitulo )

         RETURN NIL
      ELSE
         wndABM2Listado.lbxCampoBase.DeleteAllItems
         FOR i := 1 to HMG_LEN( aCampoBase )
            IF i != nItem
               wndABM2Listado.lbxCampoBase.AddItem( aCampoBase[i] )
            ENDIF
         NEXT
         nItem := iif( nItem > 1, nItem--, 1 )
         wndABM2Listado.lbxCampoBase.Value := nItem
      ENDIF

      // Actualiza los datos de los campos del listado.
      IF Empty( cValor )
         msgExclamation( _HMG_SYSDATA [ 130 ][23], _cTitulo )

         RETURN NIL
      ELSE
         wndABM2Listado.lbxCampoListado.AddItem( cValor )
         wndABM2Listado.lbxCampoListado.Value := ;
            wndABM2Listado.lbxCampoListado.ItemCount
      ENDIF
   CASE nAccion == ABM_LIS_DEL

      // Obtiene la columna a quitar.
      nItem := wndABM2Listado.lbxCampoListado.Value
      cValor := wndABM2Listado.lbxCampoListado.Item( nItem )

      // Actualiza los datos de los campos del listado.
      IF HMG_LEN( aCampoListado ) == 0
         msgExclamation( _HMG_SYSDATA [ 130 ][23], _cTitulo )

         RETURN NIL
      ELSE
         wndABM2Listado.lbxCampoListado.DeleteAllItems
         FOR i := 1 to HMG_LEN( aCampoListado )
            IF i != nItem
               wndABM2Listado.lbxCampoListado.AddItem( aCampoListado[i] )
            ENDIF
         NEXT
         nItem := iif( nItem > 1, nItem--, 1 )
         wndABM2Listado.lbxCampoListado.Value := ;
            wndABM2Listado.lbxCampoListado.ItemCount
      ENDIF

      // Actualiza los datos de los campos de la base.
      IF Empty( cValor )
         msgExclamation( _HMG_SYSDATA [ 130 ][23], _cTitulo )

         RETURN NIL
      ELSE
         wndABM2Listado.lbxCampoBase.DeleteAllItems
         FOR i := 1 to HMG_LEN( _aNombreCampo )
            IF aScan( aCampoBase, _aNombreCampo[i] ) != 0
               wndABM2Listado.lbxCampoBase.AddItem( _aNombreCampo[i] )
            ENDIF
            IF _aNombreCampo[i] == cValor
               wndABM2Listado.lbxCampoBase.AddItem( _aNombreCampo[i] )
            ENDIF
         NEXT
         wndABM2Listado.lbxCampoBase.Value := 1
      ENDIF
   ENDCASE

   RETURN NIL

   /****************************************************************************************
   *  Aplicación: Comando EDIT para HMG
   *       Autor: Cristóbal Mollá [cemese@terra.es]
   *     Función: ABM2Listado()
   * Descripción: Imprime la selecciona realizada por ABM2Imprimir()
   *  Parámetros: Ninguno
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABM2Listado( aImpresoras )

   ////////// Declaración de variables locales.-----------------------------------
   LOCAL i             as numeric          // * Indice de iteración.
   LOCAL cCampo        as character        // * Nombre del campo indice.
   LOCAL aCampo        as array            // * Nombres de los campos.
   LOCAL nCampo        as numeric          // * Numero del campo actual.
   LOCAL nPosicion     as numeric          // * Posición del campo.
   LOCAL aNumeroCampo  as array            // * Numeros de los campos.
   LOCAL aAncho        as array            // * Anchos de las columnas.
   LOCAL nAncho        as array            // * Ancho de las columna actual.
   LOCAL lPrevio       as logical          // * Previsualizar.

   //        local lVistas       as logical          // * Vistas en miniatura.
   LOCAL nImpresora    as numeric          // * Numero de la impresora.
   LOCAL cImpresora    as character        // * Nombre de la impresora.
   LOCAL lOrientacion  as logical          // * Orientación de la página.
   LOCAL lSalida       as logical          // * Control de bucle.
   LOCAL lCabecera     as logical          // * ¿Imprimir cabecera?.
   LOCAL nFila         as numeric          // * Numero de la fila.
   LOCAL nColumna      as numeric          // * Numero de la columna.
   LOCAL nPagina       as numeric          // * Numero de página.
   LOCAL nPaginas      as numeric          // * Páginas totales.
   LOCAL cPie          as character        // * Texto del pie de página.
   LOCAL nPrimero      as numeric          // * Numero del primer registro a imprimir.
   LOCAL nUltimo       as numeric          // * Numero del ultimo registro a imprimir.
   LOCAL nTotales      as numeric          // * Registros totales a imprimir.
   LOCAL nRegistro     as numeric          // * Numero del registro actual.
   LOCAL cRegistro1    as character        // * Valor del registro inicial.
   LOCAL cRegistro2    as character        // * Valor del registro final.
   LOCAL xRegistro1                        // * Valor de comparación.
   LOCAL xRegistro2                        // * Valor de comparación.
   LOCAL lSuccess
   LOCAL HBPRNMAXCOL   := 100
   LOCAL RF      := 4
   LOCAL CF      := 2

   ////////// Inicialización de variables.----------------------------------------
   // Previsualizar.
   lPrevio := wndABM2Listado.chkPrevio.Value

   // Nombre de la impresora.
   nImpresora := wndABM2Listado.cbxImpresoras.Value
   IF nImpresora == 0
      msgExclamation( _HMG_SYSDATA [ 130 ][32], '' )
   ELSE
      cImpresora := aImpresoras[nImpresora]
   ENDIF

   // Nombre del campo.
   aCampo := {}
   FOR i := 1 to wndABM2Listado.lbxCampoListado.ItemCount
      cCampo := wndABM2Listado.lbxCampoListado.Item( i )
      aAdd( aCampo, cCampo )
   NEXT
   IF HMG_LEN( aCampo ) == 0
      msgExclamation( _HMG_SYSDATA [ 130 ][23], _cTitulo )

      RETURN NIL
   ENDIF

   // Número del campo.
   aNumeroCampo := {}
   FOR i := 1 to HMG_LEN( aCampo )
      nPosicion := aScan( _aNombreCampo, aCampo[i] )
      aAdd( aNumeroCampo, nPosicion )
   NEXT

   ////////// Obtiene el ancho de impresión.--------------------------------------
   aAncho := {}
   nAncho := 0
   FOR i := 1 to HMG_LEN( aNumeroCampo )
      nCampo := aNumeroCampo[i]
      DO CASE
      CASE _aEstructura[nCampo,DBS_TYPE] == "D"
         nAncho := 9
      CASE _aEstructura[nCampo,DBS_TYPE] == "M"
         nAncho := 20
      OTHERWISE
         nAncho := _aEstructura[nCampo,DBS_LEN]
      ENDCASE
      nAncho := iif( HMG_LEN( _aNombreCampo[nCampo] ) > nAncho ,  ;
         HMG_LEN( _aNombreCampo[nCampo] ),            ;
         nAncho )
      aAdd( aAncho, 1 + nAncho )
   NEXT

   ////////// Comprueba el ancho de impresión.------------------------------------
   nAncho := 0
   FOR i := 1 to HMG_LEN( aAncho )
      nAncho += aAncho[i]
   NEXT
   IF nAncho > 164
      MsgExclamation( _HMG_SYSDATA [ 130 ][24], _cTitulo )

      RETURN NIL
   ELSE
      IF nAncho > 109                 // Horizontal.
         lOrientacion := .t.
      ELSE                            // Vertical.
         lOrientacion := .f.
      ENDIF
   ENDIF

   ////////// Valores de inicio y fin de listado.---------------------------------
   nRegistro  := (_cArea)->( RecNo() )
   cRegistro1 := wndABM2Listado.txtRegistro1.Value
   cRegistro2 := wndABM2Listado.txtRegistro2.Value
   DO CASE
   CASE _aEstructura[_aIndiceCampo[_nIndiceActivo],DBS_TYPE] == "C"
      xRegistro1 := cRegistro1
      xRegistro2 := cRegistro2
   CASE _aEstructura[_aIndiceCampo[_nIndiceActivo],DBS_TYPE] == "N"
      xRegistro1 := Val( cRegistro1 )
      xRegistro2 := Val( cRegistro2 )
   CASE _aEstructura[_aIndiceCampo[_nIndiceActivo],DBS_TYPE] == "D"
      xRegistro1 := CToD( cRegistro1 )
      xRegistro2 := CToD( cRegistro2 )
   CASE _aEstructura[_aIndiceCampo[_nIndiceActivo],DBS_TYPE] == "L"
      xRegistro1 := iif( cRegistro1 == ".t.", .t., .f. )
      xRegistro2 := iif( cRegistro2 == ".t.", .t., .f. )
   ENDCASE
   (_cArea)->( dbSeek( xRegistro2 ) )
   nUltimo := (_cArea)->( RecNo() )
   (_cArea)->( dbSeek( xRegistro1 ) )
   nPrimero := (_cArea)->( RecNo() )

   ////////// Obtiene el número de páginas.---------------------------------------
   nTotales := 0
   DO WHILE (_cArea)->( RecNo() ) != nUltimo .or. (_cArea)->( Eof() )
      nTotales++
      (_cArea)->( dbSkip( 1 ) )
   ENDDO
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
   (_cArea)->( dbGoTo( nPrimero ) )

   ////////// Inicializa el listado.----------------------------------------------

   // Opciones de la impresión.
   IF lPrevio

      IF lOrientacion

         SELECT PRINTER cImpresora ;
            TO lSuccess ;
            ORIENTATION PRINTER_ORIENT_LANDSCAPE ;
            PAPERSIZE PRINTER_PAPER_A4 ;
            PREVIEW

      ELSE

         SELECT PRINTER cImpresora ;
            TO lSuccess ;
            ORIENTATION PRINTER_ORIENT_PORTRAIT ;
            PAPERSIZE PRINTER_PAPER_A4 ;
            PREVIEW

      ENDIF

   ELSE

      IF lOrientacion

         SELECT PRINTER cImpresora ;
            TO lSuccess ;
            ORIENTATION PRINTER_ORIENT_LANDSCAPE ;
            PAPERSIZE PRINTER_PAPER_A4

      ELSE

         SELECT PRINTER cImpresora ;
            TO lSuccess ;
            ORIENTATION PRINTER_ORIENT_PORTRAIT ;
            PAPERSIZE PRINTER_PAPER_A4

      ENDIF

   ENDIF

   // Control de errores.
   IF lSuccess == .F.
      msgExclamation( _HMG_SYSDATA [ 130 ][25], _cTitulo )

      RETURN NIL
   ENDIF

   // Inicio del listado.
   lCabecera := .t.
   lSalida   := .t.
   nFila     := 13
   nPagina   := 1

   START PRINTDOC

      START PRINTPAGE

         DO WHILE lSalida

            // Cabecera el listado.
            IF lCabecera

               @ 5*RF, (HBPRNMAXCOL-HMG_LEN(_cTitulo)-6)*CF PRINT _cTitulo  FONT "COURIER NEW" SIZE 12 BOLD
               @ (6*RF) + 1 , 10*CF PRINT LINE TO (6*RF) + 1 , (HBPRNMAXCOL-5)*CF PENWIDTH 0.2

               @ 7*RF   , 11*CF PRINT _HMG_SYSDATA [ 130 ] [26]   FONT "COURIER NEW" SIZE 9 BOLD
               @ 8*RF   , 11*CF PRINT _HMG_SYSDATA [ 130 ][27]   FONT "COURIER NEW" SIZE 9 BOLD
               @ 9*RF   , 11*CF PRINT _HMG_SYSDATA [ 130 ][28]   FONT "COURIER NEW" SIZE 9 BOLD
               @ 10*RF   , 11*CF PRINT _HMG_SYSDATA [ 130 ][33]   FONT "COURIER NEW" SIZE 9 BOLD

               @ 7*RF   , 23*CF PRINT (_cArea)->( ordName() )   FONT "COURIER NEW" SIZE 9
               @ 8*RF   , 23*CF PRINT cRegistro1      FONT "COURIER NEW" SIZE 9
               @ 9*RF   , 23*CF PRINT cRegistro2      FONT "COURIER NEW" SIZE 9
               @ 10*RF   , 23*CF PRINT _cFiltro         FONT "COURIER NEW" SIZE 9

               nColumna := 10

               FOR i := 1 to HMG_LEN( aCampo )
                  @ 12*RF, nColumna*CF PRINT RECTANGLE TO 12*RF, nColumna + aAncho[i] PENWIDTH 0.2
                  @ 12*RF, (nColumna + 1) *CF PRINT aCampo[i] FONT "COURIER NEW" SIZE 9 BOLD
                  nColumna += aAncho[i]
               NEXT

               lCabecera := .f.

            ENDIF

            // Registros.
            nColumna := 10
            FOR i := 1 to HMG_LEN( aNumeroCampo )
               nCampo := aNumeroCampo[i]
               DO CASE
               CASE _aEstructura[nCampo,DBS_TYPE] == "N"

                  @ nFila*RF, ( nColumna + aAncho[i] ) *CF PRINT (_cArea)->( FieldGet( aNumeroCampo[i] ) ) FONT "COURIER NEW" SIZE 8

               CASE _aEstructura[nCampo,DBS_TYPE] == "L"

                  @ nFila*RF, ( nColumna + 1 )  *CF PRINT iif( (_cArea)->( FieldGet( aNumeroCampo[i] ) ), _HMG_SYSDATA [ 130 ][29], _HMG_SYSDATA [ 130 ][30] ) FONT "COURIER NEW" SIZE 8

               CASE _aEstructura[nCampo,DBS_TYPE] == "M"

                  @ nFila*RF, ( nColumna + 1 )  *CF PRINT HB_USUBSTR( (_cArea)->( FieldGet( aNumeroCampo[i] ) ), 1, 20 ) FONT "COURIER NEW" SIZE 8

               OTHERWISE

                  @ nFila*RF, ( nColumna + 1 )  *CF PRINT (_cArea)->( FieldGet( aNumeroCampo[i] ) ) FONT "COURIER NEW" SIZE 8

               ENDCASE

               nColumna += aAncho[i]

            NEXT

            nFila++

            // Comprueba el final del registro.
            IF (_cArea)->( RecNo() ) == nUltimo
               lSalida := .f.
            ENDIF
            IF (_cArea)->( EOF())
               lSalida := .f.
            ENDIF
            (_cArea)->( dbSkip( 1 ) )

            // Pie.
            IF lOrientacion
               IF nFila > 44

                  @ (46*RF) - 1 , 10 *CF  PRINT LINE TO (46*RF)-1, ( HBPRNMAXCOL - 5 ) *CF PENWIDTH 0.2

                  cPie := HB_ValToStr( Date() ) + " " + Time()

                  @ 46*RF, 10 *CF  PRINT cPie FONT "COURIER NEW" SIZE 9 BOLD

                  cPie := "Pagina:" + " " +          ;
                     ALLTRIM( STR( nPagina) ) +      ;
                     "/" +                           ;
                     ALLTRIM( STR( nPaginas ) )

                  @ 46*RF, ( HBPRNMAXCOL - HMG_LEN(cPie)-5 )  *CF PRINT cPie FONT "COURIER NEW" SIZE 9 BOLD

                  nPagina++
                  nFila := 13
                  lCabecera := .t.

               END PRINTPAGE

               START PRINTPAGE

               ENDIF
            ELSE
               IF nFila > 66

                  @ (68*RF)-1, 10 *CF  PRINT LINE TO (68*RF)-1, ( HBPRNMAXCOL- 5 )  *CF PENWIDTH 0.2

                  cPie := HB_ValToStr( Date() ) + " " + Time()

                  @ 68*RF, 10 *CF PRINT cPie FONT "COURIER NEW" SIZE 9 BOLD

                  cPie := "Pagina: " +                    ;
                     ALLTRIM( STR( nPagina) ) +      ;
                     "/" +                           ;
                     ALLTRIM( STR( nPaginas ) )

                  @ 68*RF, ( HBPRNMAXCOL - HMG_LEN(cPie)-5 )  *CF PRINT cPie FONT "COURIER NEW" SIZE 9 BOLD

                  nFila := 13
                  nPagina++
                  lCabecera := .t.

               END PRINTPAGE

               START PRINTPAGE

               ENDIF

            ENDIF
         ENDDO

         // Comprueba que se imprime el pie de la ultima hoja.----------
         IF lOrientacion

            @ (46*RF)-1, 10 *CF  PRINT LINE TO (46*RF)-1, ( HBPRNMAXCOL - 5 )  *CF PENWIDTH 0.2

            cPie := HB_ValToStr( Date() ) + " " + Time()
            @ 46*RF, 10 *CF  PRINT cPie FONT "COURIER NEW" SIZE 9 BOLD

            cPie := "Página: " +                    ;
               ALLTRIM( STR( nPagina) ) +      ;
               "/" +                           ;
               ALLTRIM( STR( nPaginas ) )
            @ 46*RF, ( HBPRNMAXCOL -HMG_LEN(cPie)-5 )  *CF PRINT cPie FONT "COURIER NEW" SIZE 9 BOLD
         ELSE

            @ (68*RF)-1, 10  *CF PRINT LINE TO (68*RF)-1, ( HBPRNMAXCOL - 5 ) *CF PENWIDTH 0.2
            cPie := HB_ValToStr( Date() ) + " " + Time()
            @ 68*RF, 10 *CF  PRINT cPie FONT "COURIER NEW" SIZE 9 BOLD

            cPie := "Página: " +                    ;
               ALLTRIM( STR( nPagina) ) +      ;
               "/" +                           ;
               ALLTRIM( STR( nPaginas ) )
            @ 68*RF, ( HBPRNMAXCOL - HMG_LEN(cPie)-5)  *CF PRINT cPie FONT "COURIER NEW" SIZE 9 BOLD

         ENDIF

      END PRINTPAGE

   END PRINTDOC

   ////////// Cierra la ventana.--------------------------------------------------
   (_cArea)->( dbGoTo( nRegistro ) )
   wndABM2Listado.Release

   RETURN NIL
